#------------------------------------------------------------------------------
"""
Polygons
"""
#------------------------------------------------------------------------------

from dxfwrite import DXFEngine as dxf
import math

#------------------------------------------------------------------------------
# 2D vector math

def add(a, b):
  return (a[0] + b[0], a[1] + b[1])

def scale(a, k):
  return (k * a[0], k * a[1])

def dot(a, b):
  return (a[0] * b[0]) + (a[1] * b[1])

def length(a):
  return math.sqrt((a[0] * a[0]) + (a[1] * a[1]))

def normalise(a):
  return scale(a, 1/length(a))

#------------------------------------------------------------------------------

class point(object):
  """2d point with properties"""

  # radius for marking the point on a dxf drawing
  dxf_radius = 1.0

  def init(self, p):
    self.p = p
    self.facets = 0
    self.radius = 0.0

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
