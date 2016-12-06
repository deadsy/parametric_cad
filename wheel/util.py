#------------------------------------------------------------------------------
"""
common utility functions
"""
#------------------------------------------------------------------------------

import math

#------------------------------------------------------------------------------

# control the faceting error for rotations
facet_epsilon = 0.01

# small tweak to avoid differencing artifacts
epsilon = 0.05

#------------------------------------------------------------------------------

def dim(x):
  """scale a nominal dimension"""
  scale = 1.0/0.98 # 2% Al shrinkage
  return scale * float(x)

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
