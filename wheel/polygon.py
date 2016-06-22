#------------------------------------------------------------------------------
"""
Polygons
"""
#------------------------------------------------------------------------------

import dxfwrite
from dxfwrite import DXFEngine as dxf

import math
import util

#------------------------------------------------------------------------------
# 2D vector math

def add(a, b):
  return (a[0] + b[0], a[1] + b[1])

def sub(a, b):
  return (a[0] - b[0], a[1] - b[1])

def scale(a, k):
  return (k * a[0], k * a[1])

def dot(a, b):
  return (a[0] * b[0]) + (a[1] * b[1])

def cross(a, b):
  return (a[0] * b[1]) - (a[1] * b[0])

def length(a):
  return math.sqrt((a[0] * a[0]) + (a[1] * a[1]))

def normalise(a):
  return scale(a, 1/length(a))

def rot_matrix(theta):
    """rotation matrix: theta radians about the origin"""
    c = math.cos(theta)
    s = math.sin(theta)
    return (c, -s, s, c)

def mult_matrix(a, v):
    """return x = A.v"""
    return ((a[0] * v[0]) + (a[1] * v[1]), (a[2] * v[0]) + (a[3] * v[1]))

def sign(a):
  return (a > 0) - (a < 0)

#------------------------------------------------------------------------------

class point(object):
  """2d point with properties"""

  # radius for marking the point on a dxf drawing
  dxf_radius = 1.0

  def __init__(self, p, facets = 0, radius = 0.0):
    self.p = p
    self.facets = facets
    self.radius = radius

  def emit_dxf(self, d):
    color = (1,2)[self.radius == 0.0]
    d.add(dxf.circle(center = (self.p[0], self.p[1]), radius = self.dxf_radius, color = color))

  def emit_scad(self):
    return '[%f, %f],' % (self.p[0], self.p[1])

#------------------------------------------------------------------------------

class polygon(object):

  def __init__(self, closed):
    self.points = []
    self.closed = closed

  def add(self, p):
    self.points.append(p)

  def next_point(self, i):
    """next point"""
    if i == len(self.points) - 1:
      return (None, self.points[0])[self.closed]
    return self.points[i + 1]

  def prev_point(self, i):
    """previous point"""
    if i == 0:
      return (None, self.points[-1])[self.closed]
    return self.points[i - 1]

  def smooth_point(self, i):
    """smooth a point- return True if we smoothed it"""
    p = self.points[i]
    if p.radius == 0.0:
      # fixed point
      return
    pn = self.next_point(i)
    pp = self.prev_point(i)
    if pp is None or pn is None:
      # can't smooth the endpoints of an open polygon
      return False
    # work out the angle
    v0 = normalise(sub(pp.p, p.p))
    v1 = normalise(sub(pn.p, p.p))
    theta = math.acos(dot(v0, v1))

    # distance from vertex to circle tangent
    d1 = p.radius / math.tan(theta / 2.0)
    if d1 > length(sub(pp.p, p.p)):
      print('unable to smooth - radius is too large')
      return
    if d1 > length(sub(pn.p, p.p)):
      print('unable to smooth - radius is too large')
      return

    # tangent points
    p0 = add(p.p, scale(v0, d1))

    # distance from vertex to circle center
    d2 = p.radius / math.sin(theta / 2.0)
    # center of circle
    vc = normalise(add(v0, v1))
    c = add(p.p, scale(vc, d2))

    # rotation angle
    dtheta = sign(cross(v1, v0)) * (math.pi - theta) / p.facets
    # rotation matrix
    rm = rot_matrix(dtheta)
    # radius vector
    rv = sub(p0, c)

    # work out the points
    del self.points[i]
    for j in range(p.facets + 1):
      self.points.insert(i + j, point(add(c, rv)))
      rv = mult_matrix(rm, rv)
    return True

  def smooth_single(self):
    """smooth the polygon"""
    for i in range(len(self.points)):
      if self.smooth_point(i):
        return True
    return False

  def smooth(self):
    while self.smooth_single():
      pass

  def emit_dxf(self, d):
    x = []
    for p in self.points:
      p.emit_dxf(d)
      x.append((p.p[0], p.p[1]))
    flags = (0, dxfwrite.POLYLINE_CLOSED)[self.closed]
    d.add(dxf.polyline(x, flags = flags))

  def emit_scad(self):
    s = []
    s.append('module %s() {' % self.name)
    s.append('points = [')
    s.extend([p.emit_scad() for p in self.points])
    s.append('];')
    s.append('polygon(points=points, convexity = 2);')
    s.append('}')
    return '\n'.join(s)

#------------------------------------------------------------------------------

class linear_extrude(object):
  """linear extrusion of polygon"""

  def __init__(self, name):
    self.name = '%s_extrusion' % name

  def emit_scad(self):
    s = []
    s.append(self.profile.emit_scad())
    s.append('module %s() {' % self.name)
    s.append('linear_extrude(height=%f) {%s();}' % (self.length, self.profile.name))
    s.append('}')
    return '\n'.join(s)


class rotate_extrude(object):
  """rotational extrusion of polygon"""

  def __init__(self, name):
    self.name = '%s_extrusion' % name

  def emit_scad(self):
    s = []
    s.append(self.profile.emit_scad())
    s.append('module %s() {' % self.name)
    s.append('rotate_extrude(angle = %f, $fn = %d) {%s();}' % (self.angle, self.facets, self.profile.name))
    s.append('}')
    return '\n'.join(s)

#------------------------------------------------------------------------------
