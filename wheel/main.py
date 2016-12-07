#!/usr/bin/python
#------------------------------------------------------------------------------
"""
Parameteric Pottery Wheel Generation
See: https://github.com/deadsy/parametric_cad/tree/master/wheel
"""
#------------------------------------------------------------------------------

import math

from dxfwrite import DXFEngine as dxf
from polygon import *
import util

#------------------------------------------------------------------------------
# overall build controls

scale = 1.0/0.98      # 2% Al shrinkage
core_print = False     # add the core print to the wheel
pie_print = False      # create a 1/n pie segment (n = number of webs)

#------------------------------------------------------------------------------

def dim(x):
  """scale a nominal dimension"""
  return scale * float(x)

#------------------------------------------------------------------------------

#draft angles
draft_angle = util.d2r(4.0) # standard overall draft
core_draft_angle = util.d2r(10.0) # draft angle for the core print

# nominal size values (mm)
wheel_diameter = util.mm_per_in * 12.0  # total wheel diameter
hub_diameter = 40.0           # base diameter of central shaft hub
hub_height = 53.0             # height of cental shaft hub
shaft_diameter = 21           # 1" target size - reduced for machining allowance
shaft_length = 45.0           # length of shaft bore
wall_height = 35.0            # height of wheel side walls
wall_thickness = 4.0          # base thickness of outer wheel walls
plate_thickness = 7.0         # thickness of wheel top plate
web_width = 4.0               # base thickness of reinforcing webs
web_height = 25.0             # height of reinforcing webs
number_of_webs = 6            # number of reinforcing webs
core_height = 15              # height of core print

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

web_l = wheel_r - (wall_t/2) - shaft_r # web length

#------------------------------------------------------------------------------

def wheel_profile():
  """build wheel profile"""
  draft0 = (hub_h - plate_t) * math.tan(draft_angle)
  draft1 = (wall_h - plate_t) * math.tan(draft_angle)
  draft2 = wall_h * math.tan(draft_angle)
  draft3 = core_h * math.tan(core_draft_angle)
  if core_print:
    points = [
      point((0, 0)),
      point((0, hub_h + core_h)),
      point((shaft_r - draft3, hub_h + core_h)),
      point((shaft_r, hub_h)),
      point((hub_r, hub_h), 5, 2.0),
      point((hub_r + draft0, plate_t), 5, 2.0),
      point((wheel_r - wall_t - draft1, plate_t), 5, 2.0),
      point((wheel_r - wall_t, wall_h), 5, 1.0),
      point((wheel_r, wall_h), 5, 1.0),
      point((wheel_r + draft2, 0)),
    ]
  else:
    points = [
      point((0, 0)),
      point((0, hub_h - shaft_l)),
      point((shaft_r, hub_h - shaft_l)),
      point((shaft_r, hub_h)),
      point((hub_r, hub_h), 5, 2.0),
      point((hub_r + draft0, plate_t), 5, 2.0),
      point((wheel_r - wall_t - draft1, plate_t), 5, 2.0),
      point((wheel_r - wall_t, wall_h), 5, 1.0),
      point((wheel_r, wall_h), 5, 1.0),
      point((wheel_r + draft2, 0)),
    ]
  p = polygon(points, closed=False)
  p.smooth()
  return p

#------------------------------------------------------------------------------

def web_profile():
  """build web profile"""
  draft = web_h * math.tan(draft_angle)
  x0 = (2 * web_w) + draft
  x1 = web_w + draft
  x2 = web_w
  points = [
    point((-x0, 0)),
    point((-x1, 0), 3, 1.0),
    point((-x2, web_h), 3, 1.0),
    point((x2, web_h), 3, 1.0),
    point((x1, 0), 3, 1.0),
    point((x0, 0)),
  ]
  p = polygon(points, closed=False)
  p.smooth()
  return p

#------------------------------------------------------------------------------

def core_profile():
  """build core profile"""
  draft = core_h * math.tan(core_draft_angle)
  x0 = (2 * web_w) + draft
  x1 = web_w + draft
  x2 = web_w
  points = [
    point((0, 0)),
    point((0, core_h + shaft_l)),
    point((shaft_r, core_h + shaft_l), 3, 2.0),
    point((shaft_r, core_h)),
    point((shaft_r - draft, 0)),
  ]
  p = polygon(points, closed=True)
  p.smooth()
  return p

#------------------------------------------------------------------------------

def output_dxf(p, fname):
  d = dxf.drawing(fname)
  p.emit_dxf(d)
  d.save()

#------------------------------------------------------------------------------

def output_wheel(fname):
  """output scad for the wheel"""

  wheel= wheel_profile()
  web = web_profile()

  f = open(fname, 'w')
  f.write('%s\n' % util.scad_comment(__doc__))
  f.write('%s\n' % web.emit_linear('web', web_l))

  theta = (2.0 * math.pi) / number_of_webs

  if pie_print:
    f.write('rotate([0,0,%f])\n' % (util.r2d(theta) * (float(number_of_webs) + 2.0)/4.0));
    f.write('translate([0,%f,%f])\n' % (-shaft_r, plate_t - util.epsilon))
    f.write('rotate([90,0,0])\n')
    f.write('web();\n')
    f.write('%s\n' % wheel.emit_rotate('wheel', angle=theta))
    f.write('wheel();\n')
  else:
    f.write('for (i = [1:%d]) {\n' % number_of_webs)
    f.write('rotate([0,0,i * %f])\n' % util.r2d(theta));
    f.write('translate([0,%f,%f])\n' % (-shaft_r, plate_t - util.epsilon))
    f.write('rotate([90,0,0])\n')
    f.write('web();\n')
    f.write('}\n')
    f.write('%s\n' % wheel.emit_rotate('wheel'))
    f.write('wheel();\n')

  f.close()

#------------------------------------------------------------------------------

def output_core_box(fname):
  """output scad for the core box"""
  core = core_profile()

  f = open(fname, 'w')
  f.write('%s\n' % util.scad_comment(__doc__))
  f.write('%s\n' % core.emit_rotate('core'))

  w = 4.2 * shaft_r
  d = 1.2 * shaft_r
  h = (core_h + shaft_l) * 1.1

  hole_r = ((3.0/16.0) * util.mm_per_in) / 2.0

  f.write('module hole() {\n')
  f.write('rotate([0,-90,0]) cylinder(h=%f,r=%f,$fn=%d);\n' % (d, hole_r, util.facets(hole_r)))
  f.write('}\n')

  dy = w * 0.37
  x0 = h * 0.1
  x1 = h * 0.9

  f.write('module holes() {\n')
  f.write('translate([0,%f,%f]) hole();\n' % (dy,x0))
  f.write('translate([0,%f,%f]) hole();\n' % (-dy,x0))
  f.write('translate([0,%f,%f]) hole();\n' % (dy,x1))
  f.write('translate([0,%f,%f]) hole();\n' % (-dy,x1))
  f.write('}\n')

  f.write('rotate([0,-90,0])\n')
  f.write('difference() {\n')
  f.write('translate([%f,%f,0]) cube([%f,%f,%f]);\n' % (-d, -w/2, d, w, h))
  f.write('union() {\n')
  f.write('core();\n')
  f.write('holes();\n')
  f.write('}\n')
  f.write('}\n')

  f.close()

#------------------------------------------------------------------------------

def main():

  #output_dxf(core, 'core.dxf')
  #output_dxf(web, 'web.dxf')
  #output_dxf(wheel, 'wheel.dxf')

  output_wheel('wheel.scad')
  output_core_box('core_box.scad')

main()

#------------------------------------------------------------------------------
