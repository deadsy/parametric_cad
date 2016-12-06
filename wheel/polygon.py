#------------------------------------------------------------------------------
"""
Smoothable Polygons

Polygons are be expressed as a point list.
The smoothing for each polygon point can be specified.
"""
#------------------------------------------------------------------------------

import math

import dxfwrite
from dxfwrite import DXFEngine as dxf

import util

#------------------------------------------------------------------------------
# 2D vector math

def add(a, b):
  """add 2d vectors"""
  return (a[0] + b[0], a[1] + b[1])

def sub(a, b):
  """subtract 2 vectors"""
  return (a[0] - b[0], a[1] - b[1])

def scale(a, k):
  """scale a 2d vector by k"""
  return (k * a[0], k * a[1])

def dot(a, b):
  """return the 2d dot product"""
  return (a[0] * b[0]) + (a[1] * b[1])

def cross(a, b):
  """return the 2d cross product"""
  return (a[0] * b[1]) - (a[1] * b[0])

def length(a):
  """return the length of a 2d vector"""
  return math.sqrt(dot(a, a))

def normalise(a):
  """scale a 2d vector to length 1"""
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
  """return +1, -1 or 0"""
  return (a > 0) - (a < 0)

#------------------------------------------------------------------------------

class point(object):
  """2d point with properties"""

  # radius for marking the point on a dxf drawing
  dxf_radius = 1.0

  def __init__(self, p, facets=0, radius=0.0):
    """specify a smoothable point"""
    self.p = p
    self.facets = facets # number of facets in smoothing
    self.radius = radius # radius of smoothing

  def emit_dxf(self, d):
    """emit dxf code for the point"""
    color = (1, 2)[self.radius == 0.0]
    d.add(dxf.circle(center=(self.p[0], self.p[1]), radius=self.dxf_radius, color=color))

  def emit_scad(self):
    """emit openscad code for the point"""
    return '[%f, %f],' % (self.p[0], self.p[1])

#------------------------------------------------------------------------------

class polygon(object):

  def __init__(self, points=[], closed=False):
    """create a polygon"""
    self.points = points
    self.closed = closed

  def add(self, p):
    """add a point to the polygon point list"""
    self.points.append(p)

  def next_point(self, i):
    """return the next point on the polygon list"""
    if i == len(self.points) - 1:
      return (None, self.points[0])[self.closed]
    return self.points[i + 1]

  def prev_point(self, i):
    """return the previous point on the polygon list"""
    if i == 0:
      return (None, self.points[-1])[self.closed]
    return self.points[i - 1]

  def max_x(self):
    """return the maximum x value of the polygon points"""
    return max([p.p[0] for p in self.points])

  def smooth_point(self, i):
    """smooth the i-th point- return True if we smoothed it"""
    p = self.points[i]

    if p.radius == 0.0:
      # fixed point
      return False

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
    if d1 > length(sub(pp.p, p.p)) or d1 > length(sub(pn.p, p.p)):
      # unable to smooth - radius is too large
      return False

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

  def smooth(self):
    """smooth the polygon"""
    done = False
    while not done:
      done = True
      for i in range(len(self.points)):
        if self.smooth_point(i):
          done = False

  def emit_dxf(self, d):
    """emit the dxf code for the polygon"""
    x = []
    for p in self.points:
      p.emit_dxf(d)
      x.append((p.p[0], p.p[1]))
    flags = (0, dxfwrite.POLYLINE_CLOSED)[self.closed]
    d.add(dxf.polyline(x, flags=flags))

  def emit_polygon(self, name, convexity=2, extrude=''):
    """emit an openscad module for the polygon"""
    s = []
    s.append('module %s() {' % name)
    s.append('points = [')
    s.extend([p.emit_scad() for p in self.points])
    s.append('];')
    s.append('%spolygon(points=points, convexity=%d);' % (extrude, convexity))
    s.append('}')
    return '\n'.join(s)

  def emit_linear(self, name, l, convexity=2):
    """emit openscad code for a 3d linear extrusion"""
    return self.emit_polygon(name, convexity, extrude='linear_extrude(height=%f) ' % l)

  def emit_rotate(self, name, angle=None, convexity=2):
    """emit openscad code for a 3d rotated extrusion"""
    facets = util.facets(self.max_x())
    if angle is None:
      cmd = 'rotate_extrude($fn=%d) ' % facets
    else:
      cmd = 'rotate_extrude(angle=%f, $fn=%d) ' % (util.r2d(angle), facets)
    return self.emit_polygon(name, convexity, extrude=cmd)

#------------------------------------------------------------------------------
