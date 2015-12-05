#! /usr/bin/python
#------------------------------------------------------------------------------

import dxfwrite
from dxfwrite import DXFEngine as dxf

import math

#------------------------------------------------------------------------------

# number of linear segments in involute tooth curve
_INVOLUTE_STEPS = 20

# number of linear segments in cycloid curve
_CYCLOID_STEPS = 1000

#------------------------------------------------------------------------------

def r2d(r):
    return (r * 180.0) / math.pi

def d2r(d):
    return (d * math.pi) / 180.0

def mult_matrix(a, v):
    """return x = A.v"""
    return ((a[0][0] * v[0]) + (a[0][1] * v[1]), (a[1][0] * v[0]) + (a[1][1] * v[1]))

def rot_matrix(theta):
    """rotation matrix: theta radians about the origin"""
    c = math.cos(theta)
    s = math.sin(theta)
    return ((c, -s),(s, c))

def mirror_x(p):
    """mirror a point about the x-axis"""
    return (p[0], -p[1])

#------------------------------------------------------------------------------

def involute_point(base, theta):
    """ return the involute point
        base = base circle radius
        theta = involute angle
    """
    x1 = base * math.cos(theta)
    y1 = base * math.sin(theta)
    l = base * theta
    x2 = x1 + l * math.sin(theta)
    y2 = y1 - l * math.cos(theta)
    return (x2, y2)

def involute_radius(base, theta):
    """ return the involute radius
        base = base circle radius
        theta = involute angle
    """
    return math.sqrt(radius * radius * (1.0 + (theta * theta)))

def involute_theta(base, radius):
    """ return the involute angle
        base = base radius
        radius = radial distance of involute point
    """
    return math.sqrt(((radius * radius)/(base * base)) - 1.0)

#------------------------------------------------------------------------------

def hyper_cycloid_point(pr, n, theta):
    """ return the cycloid point
        pr = pitch radius
        n = number of lobes
        theta = angle
    """
    n += 1
    cr = pr / float(n)
    # outer cycloid
    cx = (pr + cr) * math.cos(theta)
    cy = (pr + cr) * math.sin(theta)
    # the external cycloid turns forwards (+ve with theta)
    ctheta = float(n) * theta
    x = cx + (cr * math.cos(ctheta))
    y = cy + (cr * math.sin(ctheta))
    return (x, y)

def hypo_cycloid_point(pr, n, theta):
    """ return the cycloid point
        pr = pitch radius
        n = number of lobes
        theta = angle
    """
    n -= 1
    cr = pr / float(n)
    # inner cycloid
    cx = (pr - cr) * math.cos(theta)
    cy = (pr - cr) * math.sin(theta)
    # the internal cycloid turns backwards (-ve with theta)
    ctheta = -1.0 * float(n) * theta
    #ctheta += math.pi
    x = cx + (cr * math.cos(ctheta))
    y = cy + (cr * math.sin(ctheta))
    return (x, y)

#------------------------------------------------------------------------------

class cycloid_gear:

    def __init__(self, n, pd):
        self.n = n # number of teeth
        self.pd = pd # pitch diameter
        # derived values
        self.pr = self.pd / 2.0 # pitch radius
        self.ap = (2.0 * math.pi) / float(self.n) # angular pitch

    def __str__(self):
        s = []
        s.append('number of teeth %d' % self.n)
        s.append('pitch diameter %.3f' % self.pd)
        s.append('angular pitch %.3f' % r2d(self.ap))
        return '\n'.join(s)

    def hyper_cycloid(self):
        seg = []
        theta = 0.0
        theta_step = math.pi * 2.0 / float(_CYCLOID_STEPS)
        for i in range(_CYCLOID_STEPS + 1):
            seg.append(hyper_cycloid_point(self.pr, self.n, theta))
            theta += theta_step
        self.hyper_seg = seg

    def hypo_cycloid(self):
        seg = []
        theta = 0.0
        theta_step = math.pi * 2.0 / float(_CYCLOID_STEPS)
        for i in range(_CYCLOID_STEPS + 1):
            seg.append(hypo_cycloid_point(self.pr, self.n, theta))
            theta += theta_step
        self.hypo_seg = seg

    def draw_cycloids(self, d):
        d.add(dxf.polyline(self.hyper_seg))
        d.add(dxf.polyline(self.hypo_seg))

    def draw_circles(self, d):
        d.add(dxf.circle(center = (0.0, 0.0), radius = self.pr))

    def draw(self, d):
        self.hyper_cycloid()
        self.hypo_cycloid()
        self.draw_circles(d)
        self.draw_cycloids(d)

#------------------------------------------------------------------------------

class involute_gear:

    def __init__(self, n, pd, pa):
        self.n = n # number of teeth
        self.pd = pd # pitch diameter
        self.pa = d2r(pa) # pressure angle
        # derived values
        self.p = float(self.n) / self.pd # diametrical pitch
        self.a = 1.0 / self.p # addendum
        self.b = 1.25 / self.p # dedendum
        self.c = 0.25 / self.p # clearance
        self.pr = self.pd / 2.0 # pitch radius
        self.br = self.pr * math.cos(self.pa) # base radius
        self.ar = self.pr + self.a # addendum/outside radius
        self.dr = self.pr - self.b # dedendum/inside radius
        self.ap = (2.0 * math.pi) / float(self.n) # angular pitch

    def __str__(self):
        s = []
        s.append('number of teeth %d' % self.n)
        s.append('pressure angle %.1f' % r2d(self.pa))
        s.append('outside diameter %.3f' % (2.0 * self.ar))
        s.append('pitch diameter %.3f' % self.pd)
        s.append('base diameter %.3f' % (2.0 * self.br))
        s.append('inside diameter %.3f' % (2.0 * self.dr))
        s.append('angular pitch %.3f' % r2d(self.ap))
        return '\n'.join(s)

    def involute(self):
        """create involute segment"""
        theta_end = involute_theta(self.br, self.ar)
        theta_step = theta_end / _INVOLUTE_STEPS
        theta = 0.0
        seg = []
        for i in range(_INVOLUTE_STEPS + 1):
            seg.append(involute_point(self.br, theta))
            theta += theta_step
        # rotate the involute back to the x-axis at the pitch radius
        theta = involute_theta(self.br, self.pr)
        (x, y) = involute_point(self.br, theta)
        ofs = math.atan2(y, x)
        # add angular_pitch/4 to get a 50/50 tooth/gap split on the pitch circle
        ofs += self.ap / 4.0
        # rotate the segment
        rot = rot_matrix(-ofs)
        seg = [mult_matrix(rot, p) for p in seg]
        self.seg_lower = seg
        # mirror the segment across the x-axis
        self.seg_upper = [mirror_x(p) for p in seg]

    def root(self):
        """create the root segment"""
        # get the base radius point of the upper involute
        (x, y) = self.seg_upper[0]
        theta = math.atan2(y, x)
        # the root goes from this angle to the angular pitch
        self.seg_root = (theta, self.ap - theta)

    def crown(self):
        """create the crown segment"""
        # get the addendum radius point of the upper involute
        (x, y) = self.seg_upper[-1]
        theta = math.atan2(y, x)
        self.seg_crown = (-theta, theta)

    def radial(self):
        """create the radial segments"""
        (x1, y1) = self.seg_upper[0]
        theta = math.atan2(y1, x1)
        x2 = self.dr * math.cos(theta)
        y2 = self.dr * math.sin(theta)
        self.seg_r_upper = [(x1, y1), (x2, y2)]
        self.seg_r_lower = [(x1, -y1), (x2, -y2)]

    def draw_radials(self, d):
        """draw all radials"""
        rot = rot_matrix(self.ap)
        for i in range(self.n):
            d.add(dxf.polyline(self.seg_r_upper))
            d.add(dxf.polyline(self.seg_r_lower))
            self.seg_r_upper = [mult_matrix(rot, p) for p in self.seg_r_upper]
            self.seg_r_lower = [mult_matrix(rot, p) for p in self.seg_r_lower]

    def draw_crowns(self, d):
        """draw all crowns"""
        start = r2d(self.seg_crown[0])
        end = r2d(self.seg_crown[1])
        delta = r2d(self.ap)
        for i in range(self.n):
            d.add(dxf.arc(self.ar, (0.0, 0.0), start, end))
            start += delta
            end += delta

    def draw_roots(self, d):
        """draw all the roots"""
        start = r2d(self.seg_root[0])
        end = r2d(self.seg_root[1])
        delta = r2d(self.ap)
        for i in range(self.n):
            d.add(dxf.arc(self.dr, (0.0, 0.0), start, end))
            start += delta
            end += delta

    def draw_involutes(self, d):
        """draw all the involutes"""
        rot = rot_matrix(self.ap)
        for i in range(self.n):
            d.add(dxf.polyline(self.seg_lower))
            d.add(dxf.polyline(self.seg_upper))
            self.seg_upper = [mult_matrix(rot, p) for p in self.seg_upper]
            self.seg_lower = [mult_matrix(rot, p) for p in self.seg_lower]

    def draw_circles(self, d):
       d.add(dxf.circle(center = (0.0, 0.0), radius = self.dr))
       d.add(dxf.circle(center = (0.0, 0.0), radius = self.br, color = 1))
       d.add(dxf.circle(center = (0.0, 0.0), radius = self.pr))
       d.add(dxf.circle(center = (0.0, 0.0), radius = self.ar))

    def draw(self, d):
        self.involute()
        self.root()
        self.crown()
        self.radial()
        self.draw_involutes(d)
        self.draw_roots(d)
        self.draw_crowns(d)
        self.draw_radials(d)
        self.draw_circles(d)

#------------------------------------------------------------------------------

def main():
    d = dxf.drawing('gear.dxf')
    #g = cycloid_gear(36, 1.5)
    g = involute_gear(32, 169.4, 8)
    g.draw(d)
    d.save()
    print g

main()
