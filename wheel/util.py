#------------------------------------------------------------------------------



#------------------------------------------------------------------------------

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
