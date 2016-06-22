#!/usr/bin/python
#------------------------------------------------------------------------------

from polygon import *

from dxfwrite import DXFEngine as dxf

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

  p = polygon(closed = False)
  for x in points:
    p.add(x)
  return p

#------------------------------------------------------------------------------

def main():

  p = build_polygon()
  p.smooth()
  output_dxf(p, 'test.dxf')

main()

#------------------------------------------------------------------------------
