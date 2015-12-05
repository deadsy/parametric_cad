#! /usr/bin/python
#------------------------------------------------------------------------------

import dxfwrite
from dxfwrite import DXFEngine as dxf

import math

#------------------------------------------------------------------------------

# number of linear segments in cam profile
_STEPS = 1000
theta_delta = 2.0 * math.pi / float(_STEPS)
_zero_tolerance = 0.0001

#------------------------------------------------------------------------------

class circle:
    def __init__(self, c = (0.0, 0.0), r = 0.0):
        self.c = c
        self.r = float(r)

    def __str__(self):
        return '(%f, %f) %f' % (self.c[0], self.c[1], self.r)

    def p2r(self, p):
        """convert a point on the circle to a theta position"""
        x = p[0] - self.c[0]
        y = p[1] - self.c[1]
        return math.atan2(y, x)

class line:
    """parameteric line"""

    def __init__(self, p = (0.0, 0.0), v = (0.0, 0.0)):
        self.p = p
        self.v = v

    def xy(self, t):
        x = self.p[0] + (self.v[0] * t)
        y = self.p[1] + (self.v[1] * t)
        return (x,y)


#------------------------------------------------------------------------------

def r2d(r):
    return (r * 180.0) / math.pi

def d2r(d):
    return (d * math.pi) / 180.0

def quadratic(a, b, c):
    """solve a quadratic- return a tuple with 0,1 or 2 solutions"""
    det = (b * b) - (4.0 * a * c)
    if det < -_zero_tolerance:
        return ()
    elif det <= _zero_tolerance:
        return (-b / (2.0 * a),)
    else:
        det = math.sqrt(det)
        return ((-b - det)/ (2.0 * a), (-b + det)/ (2.0 * a))

#------------------------------------------------------------------------------

def circle2circle(c1, c2):
    """intersect 2 circles"""

    y_equal = (c1.c[1] == c2.c[1])
    x_equal = (c1.c[0] == c2.c[0])

    if y_equal and x_equal:
        # co-centric circles
        if c1.r == c2.r:
            # infinite solutions
            return None
        else:
            # 0 solutions
            return ()

    if y_equal:
        # avoid div-by-zero in the general case
        # combine circle equations: x = b
        b = (c1.r * c1.r) - (c2.r * c2.r)
        b += (c2.c[0] * c2.c[0]) - (c1.c[0] * c1.c[0])
        b /= 2.0 * (c2.c[0] - c1.c[0])

        # substitute back into c1 to get a quadratic in y
        k = b - c1.c[0]
        qa = 1.0
        qb = -2.0 * c1.c[1]
        qc = (c1.c[1] * c1.c[1]) + (k * k) - (c1.r * c1.r)
        y = quadratic(qa, qb, qc)

        if len(y) == 0:
            return ()
        elif len(y) == 1:
            return ((b, y[0]),)
        else:
            return ((b, y[0]), (b, y[1]))

    # combine circle equations: y = mx + b
    m = (c1.c[0] - c2.c[0]) / (c2.c[1] - c1.c[1])
    b = (c1.r * c1.r) - (c2.r * c2.r)
    b += (c2.c[0] * c2.c[0]) - (c1.c[0] * c1.c[0])
    b += (c2.c[1] * c2.c[1]) - (c1.c[1] * c1.c[1])
    b /= 2.0 * (c2.c[1] - c1.c[1])

    # substitute back into c1 to get a quadratic in x
    k = b - c1.c[1]
    qa = 1.0 + (m * m)
    qb = (2.0 * m * k) - (2.0 * c1.c[0])
    qc = (c1.c[0] * c1.c[0]) + (k * k) - (c1.r * c1.r)
    x = quadratic(qa, qb, qc)

    if len(x) == 0:
        return ()
    elif len(x) == 1:
        x1 = x[0]
        y1 = (m * x[0]) + b
        return ((x1, y1),)
    else:
        x1 = x[0]
        x2 = x[1]
        y1 = (m * x[0]) + b
        y2 = (m * x[1]) + b
        return ((x1, y1), (x2, y2))

#------------------------------------------------------------------------------

def line2circle(l, c):
    """intersect line and circle"""
    k0 = l.p[0] - c.c[0]
    k1 = l.p[1] - c.c[1]
    qa = (l.v[0] * l.v[0]) + (l.v[1] * l.v[1])
    qb = 2.0 * ((k0 * l.v[0]) + (k1 * l.v[1]))
    qc = (k0 * k0) + (k1 * k1) - (c.r * c.r)
    return quadratic(qa, qb, qc)

#------------------------------------------------------------------------------

def draw_crosshair(d, location, size = 0.125):
    """add a crosshair to a drawing"""
    x = location[0]
    y = location[1]
    delta = size / 2.0
    s1 = ((x-delta, y), (x+delta, y))
    s2 = ((x, y-delta), (x, y+delta))
    d.add(dxf.polyline(s1))
    d.add(dxf.polyline(s2))

#------------------------------------------------------------------------------

class cam_type0:

    def __init__(self, offset = 0.0, radius = 1.0):
        self.offset = offset
        self.radius = radius

    def draw_base(self, d):
        c = circle((0.0, self.offset), self.radius)
        segs = []
        theta = 0.0
        for i in xrange(_STEPS + 1):
            l = line((0.0, 0.0), (math.cos(theta), math.sin(theta)))
            t_vals = line2circle(l, c)
            segs.append(l.xy(max(t_vals)))
            theta += theta_delta
        d.add(dxf.polyline(segs))

    def draw(self, d):
        draw_crosshair(d, (0.0, 0.0))
        self.draw_base(d)

#------------------------------------------------------------------------------

class cam_type1:
    """circular base, nose and flanks"""

    def __init__(self, ofs, base, nose, flank):
        self.flank = flank
        self.base = circle((0.0, 0.0), base)
        self.nose = circle((0.0, ofs), nose)
        c1 = circle(self.nose.c, flank - self.nose.r)
        c2 = circle(self.base.c, flank - self.base.r)
        flanks = circle2circle(c1, c2)
        self.flank1 = circle(flanks[0], flank)
        self.flank2 = circle(flanks[1], flank)

    def draw_lobes(self, d):

        nf1 = circle2circle(self.nose, self.flank1)[0]
        nf2 = circle2circle(self.nose, self.flank2)[0]
        bf1 = circle2circle(self.base, self.flank1)[0]
        bf2 = circle2circle(self.base, self.flank2)[0]

        n_theta1 = r2d(self.nose.p2r(nf1))
        n_theta2 = r2d(self.nose.p2r(nf2))
        d.add(dxf.arc(self.nose.r, self.nose.c, n_theta1, n_theta2))

        b_theta1 = r2d(self.base.p2r(bf1))
        b_theta2 = r2d(self.base.p2r(bf2))
        d.add(dxf.arc(self.base.r, self.base.c, b_theta2, b_theta1))

        f1_theta1 = r2d(self.flank1.p2r(nf1))
        f1_theta2 = r2d(self.flank1.p2r(bf1))
        d.add(dxf.arc(self.flank1.r, self.flank1.c, f1_theta2, f1_theta1))

        f2_theta1 = r2d(self.flank2.p2r(nf2))
        f2_theta2 = r2d(self.flank2.p2r(bf2))
        d.add(dxf.arc(self.flank2.r, self.flank2.c, f2_theta1, f2_theta2))


    def draw(self, d):
        draw_crosshair(d, (0.0, 0.0))
        self.draw_lobes(d)

#------------------------------------------------------------------------------

def main():

    cam = cam_type1(1.0, 1.0, 0.5, 5.0)
    d = dxf.drawing('cam.dxf')
    cam.draw(d)
    d.save()

main()

#------------------------------------------------------------------------------
