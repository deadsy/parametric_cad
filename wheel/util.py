#------------------------------------------------------------------------------
"""
common utility functions
"""
#------------------------------------------------------------------------------

import math

#------------------------------------------------------------------------------
# constants

mm_per_in = 25.4

#------------------------------------------------------------------------------

# control the faceting error for rotations
facet_epsilon = 0.01

# small tweak to avoid differencing artifacts
epsilon = 0.05

#------------------------------------------------------------------------------

def d2r(d):
  """degrees to radians"""
  return (float(d) / 180.0) * math.pi

def r2d(r):
  """radians to degrees"""
  return (float(r) * 180.0) / math.pi

def facets(r):
  """return the required number of polygon facets for a given radius"""
  return int(math.pi / math.acos(1 - (facet_epsilon / r)))

#------------------------------------------------------------------------------

def scad_comment(s):
  """return the string as an openscad comment"""
  return '\n'.join(['// %s' % l for l in s.split('\n')])

#------------------------------------------------------------------------------
