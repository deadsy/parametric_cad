#! /usr/bin/python
#------------------------------------------------------------------------------

import dxfwrite
from dxfwrite import DXFEngine as dxf

#------------------------------------------------------------------------------

class point(object):

  draw_radius = 0.05

  def __init__(self, x, y):
    self.x = x
    self.y = y
    self.fixed = True

  def smooth(self):
    self.fixed = False

  def draw(self, d):
    color = (1,2)[self.fixed]
    d.add(dxf.circle(center = (self.x, self.y), radius = self.draw_radius, color = color))


class polygon(object):

  def __init__(self):
    self.points = []

  def add(self, p):
    self.points.append(p)

  def get_point(self, idx):
    return self.points[idx]

  def smooth_triplet(self, i):
    """smooth a triplet of points"""
    # p0 and p2 remain the same.
    # p1 will be replaced by two new points non-fixed points.
    p0 = self.points[i - 1]
    p1 = self.points[i]
    p2 = self.points[i + 1]
    return False

  def smooth_points(self):
    """smooth the points - return True after the first modified point"""
    for i in range(1, len(self.points) - 1):
      if not self.points[i].fixed:
        if self.smooth_triplet(i)
          return True
    # no points smoothed - we're done
    return False

  def draw(self, d):
    x = []
    for p in self.points:
      p.draw(d)
      x.append((p.x, p.y))
    d.add(dxf.polyline(x))

#------------------------------------------------------------------------------

def build_polygon(points):
  """build a polygon from a list of points"""
  p = polygon()
  for (x, y) in points:
    p.add(point(x, y))
  return p

#------------------------------------------------------------------------------

def main():

  #d = dxf.drawing('wheel.dxf')

  x = ((0,0), (1,1), (2,0))
  p = build_polygon(x)
  p.get_point(1).smooth()
  p.smooth()

  #p.draw(d)

  #d.save()

main()

#------------------------------------------------------------------------------
