#! /usr/bin/python
#------------------------------------------------------------------------------

import dxfwrite
from dxfwrite import DXFEngine as dxf

import math

#------------------------------------------------------------------------------

def dim(x):
  scale = 1.0/0.98 # 2% Al shrinkage
  return scale * float(x)

def d2r(d):
  return (float(d) / 180.0) * math.pi

def r2d(r):
  return (float(r) * 180.0) / math.pi

facet_epsilon = 0.01

def facets(r):
  return int(math.pi / math.acos(1 - (facet_epsilon / r)))

# small tweak to avoid differencing artifacts
epsilon = 0.05

#------------------------------------------------------------------------------

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

  draw_radius = 1.0

  def __init__(self, x, y, radius = 0.0):
    self.x = x
    self.y = y
    self.radius = radius

  def emit_dxf(self, d):
    color = (1,2)[self.radius == 0.0]
    d.add(dxf.circle(center = (self.x, self.y), radius = self.draw_radius, color = color))

  def emit_scad(self, f):
    f.write('[%f, %f],\n' % (self.x, self.y))

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
      return False
    pn = self.next_point(i)
    pp = self.prev_point(i)
    if pp is None or pn is None:
      # can't smooth the endpoints of an open polygon
      return False
    # work out the angle
    v0 = normalise((pp.x - p.x, pp.y - p.y))
    v1 = normalise((pn.x - p.x, pn.y - p.y))
    theta = math.acos(dot(v0, v1))
    if theta >= smooth_angle:
      # smooth enough
      return False

    p0 = add((p.x, p.y), scale(v0, p.radius))
    p1 = add((p.x, p.y), scale(v1, p.radius))

    del self.points[i]
    self.points.insert(i, point(p0[0], p0[1], p.radius / 2.0))
    self.points.insert(i + 1, point(p1[0], p1[1], p.radius / 2.0))

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
      x.append((p.x, p.y))
    flags = (0, dxfwrite.POLYLINE_CLOSED)[self.closed]
    d.add(dxf.polyline(x, flags = flags))

  def emit_scad(self, f):
    f.write('module %s() {\n' % self.name)
    f.write('points = [\n')
    for p in self.points:
      p.emit_scad(f)
    f.write('];\n')
    f.write('polygon(points=points, convexity = 2);\n');
    f.write('}\n')

#------------------------------------------------------------------------------

class extrusion(object):

  def __init__(self, name, etype):
    self.name = '%s_extrusion' % name
    self.etype = etype

  def emit_scad(self, f):
    self.profile.emit_scad(f)
    f.write('module %s() {\n' % self.name)
    if self.etype == 'rotate':
      f.write('rotate_extrude(angle = %f, $fn = %d) {' % (self.angle, self.facets))
    elif self.etype == 'linear':
      f.write('linear_extrude(height=%f) {' % self.length)
    else:
      assert False
    f.write('%s();}\n' % self.profile.name)
    f.write('}\n')

#------------------------------------------------------------------------------

def output_dxf(p, fname):
  d = dxf.drawing(fname)
  p.emit_dxf(d)
  d.save()

#------------------------------------------------------------------------------

def output_scad(e_list, fname):
    f = open(fname, 'w')
    for e in e_list:
      e.emit_scad(f)
    f.write('wheel_extrusion();\n')

    theta = 360.0 / number_of_webs

    if pie_print:
      f.write('rotate([0,0,%f])\n' % (theta * (float(number_of_webs) + 2.0)/4.0));
      f.write('translate([0,%f,%f])\n' % (-shaft_r, plate_t - epsilon))
      f.write('rotate([90,0,0])\n')
      f.write('web_extrusion();\n')
    else:
      f.write('for (i = [1:%d]) {\n' % number_of_webs)
      f.write('rotate([0,0,i * %f])\n' % theta);
      f.write('translate([0,%f,%f])\n' % (-shaft_r, plate_t - epsilon))
      f.write('rotate([90,0,0])\n')
      f.write('web_extrusion();\n')
      f.write('}\n')

    f.close()

#------------------------------------------------------------------------------

draft_angle = d2r(4.0)
smooth_angle = d2r(140.0)
core_draft_angle = d2r(10.0)

# nominal values
wheel_diameter = 25.4 * 12.0
hub_diameter = 40.0
hub_height = 53.0
shaft_diameter = 21 # 1" target size - reduced for machining allowance
shaft_length = 45.0
wall_height = 35.0
wall_thickness = 4.0
plate_thickness = 7.0
web_width = 4.0
web_height = 25.0
number_of_webs = 6
core_height = 15

core_print = True
pie_print = True

# derived values
wheel_r = dim(wheel_diameter/2)
hub_r = dim(hub_diameter/2)
hub_h = dim(hub_height)
shaft_r = dim(shaft_diameter/2)
shaft_l = dim(shaft_length)
wall_h = dim(wall_height)
wall_t = dim(wall_thickness)
plate_t = dim(plate_thickness)
web_w = dim(web_width/2)
web_h = dim(web_height)
core_h = dim(core_height)

#------------------------------------------------------------------------------

def build_wheel_profile():
  """build wheel profile"""
  draft0 = (hub_h - plate_t) * math.tan(draft_angle)
  draft1 = (wall_h - plate_t) * math.tan(draft_angle)
  draft2 = wall_h * math.tan(draft_angle)
  draft3 = core_h * math.tan(core_draft_angle)

  if core_print:

    points = (
      point(0, 0),
      point(0, hub_h + core_h),
      point(shaft_r - draft3, hub_h + core_h),
      point(shaft_r, hub_h),

      point(hub_r, hub_h, 2.0),
      point(hub_r + draft0, plate_t, 2.0),
      point(wheel_r - wall_t - draft1, plate_t, 2.0),
      point(wheel_r - wall_t, wall_h, 1.0),
      point(wheel_r, wall_h, 1.0),
      point(wheel_r + draft2, 0),
    );
  else:
    points = (
      point(0, 0),
      point(0, hub_h - shaft_l),
      point(shaft_r, hub_h - shaft_l),
      point(shaft_r, hub_h),

      point(hub_r, hub_h, 2.0),
      point(hub_r + draft0, plate_t, 2.0),
      point(wheel_r - wall_t - draft1, plate_t, 2.0),
      point(wheel_r - wall_t, wall_h, 1.0),
      point(wheel_r, wall_h, 1.0),
      point(wheel_r + draft2, 0),
    );

  name = 'wheel'
  p = polygon(closed = True)
  p.name = '%s_profile' % name
  for x in points:
    p.add(x)
  return p

def build_web_profile():
  """build web profile"""
  draft = web_h * math.tan(draft_angle)
  x0 = (2 * web_w) + draft
  x1 = web_w + draft
  x2 = web_w
  points = (
    point(-x0, 0),
    point(-x1, 0, 1.0),
    point(-x2, web_h, 1.0),
    point(x2, web_h, 1.0),
    point(x1, 0, 1.0),
    point(x0, 0),
  );
  name = 'web'
  p = polygon(closed = False)
  p.name = '%s_profile' % name
  for x in points:
    p.add(x)
  return p

def build_wheel_extrusion(p):
  e = extrusion('wheel', 'rotate')
  e.profile = p
  e.facets = facets(hub_r)
  e.angle = (360, 360/number_of_webs)[pie_print]
  return e

def build_web_extrusion(p):
  e = extrusion('web', 'linear')
  e.profile = build_web_profile()
  e.length = wheel_r - (wall_t/2) - shaft_r
  return e

#------------------------------------------------------------------------------

def main():

  e0 = build_wheel_extrusion(build_wheel_profile())
  e0.profile.smooth()
  output_dxf(e0.profile, 'wheel.dxf')

  e1 = build_web_extrusion(build_web_profile())
  e1.profile.smooth()
  output_dxf(e1.profile, 'web.dxf')

  output_scad((e0, e1), 'wheel.scad')

main()

#------------------------------------------------------------------------------
