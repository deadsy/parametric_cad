#!/usr/bin/python
#------------------------------------------------------------------------------

from polygon import *
from dxfwrite import DXFEngine as dxf

import math

#------------------------------------------------------------------------------

def output_dxf(p, fname):
  d = dxf.drawing(fname)
  p.emit_dxf(d)
  d.save()

#------------------------------------------------------------------------------

def build_polygon():

  points = [
    point((0.0, 0.0)),
    point((100.0, 100.0), 5, 50.0),
    point((200.0, 0.0), 10, 30.0),
    point((300.0, 100.0), 7, 5.0),
    point((0.0, 100.0)),
  ]

  return polygon(points, closed=False)

#------------------------------------------------------------------------------

def main():

  p = build_polygon()
  p.smooth()

  output_dxf(p, 'test.dxf')

  print p.emit_polygon('test0')
  print p.emit_linear('test1', 3)
  print p.emit_rotate('test2')
  print p.emit_rotate('test3', angle=math.pi)


main()

#------------------------------------------------------------------------------
