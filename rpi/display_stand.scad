//------------------------------------------------------------------
/*

Simple Display Stand for Rasberry Pi 7" Display

Similar to: http://www.thingiverse.com/thing:1021025

But:

1) OpenSCAD
2) Allow the usb power port to be at the bottom (normal display orientation).
3) Allow some mounting holes on the foot.
4) Variable thickness display supports to accomodate various M3 screw lengths.
5) Added webbing for better strength.

*/
//------------------------------------------------------------------
/* [Global] */

base_height = 8;
base_length = 150;
base_width = 80;
base_hole_diameter = 4;

foot_sizex = 15;
foot_sizey = 20;

support_height = 120;
support_thickness1 = 5;
support_thickness2 = 12;
support_hole2edge = 7;
support_web_radius = 20;

display_angle = 15;

/* [Hidden] */
//------------------------------------------------------------------

// scaling
pla_shrink = 1/0.998; //~0.2%
abs_shrink = 1/0.995; //~0.5%
function scale(x) = pla_shrink * x;

// small tweak to avoid differencing artifacts
epsilon = 0.05;

// control the number of facets on cylinders
facet_epsilon = 0.05;
function facets(r) = 180 / acos(1 - (facet_epsilon / r));

// rounded/filleted edges
module inverse() {
  difference() {
    square(1e5, center=true);
    children(0);
  }
}
module rounded(r=1) {
  offset(r=r, $fn=facets(r)) offset(r=-r, $fn=facets(r)) children(0);
}
module filleted(r=1) {
  offset(r=-r, $fn=facets(r)) render() offset(r=r, $fn=facets(r)) children(0);
}

//------------------------------------------------------------------

// 4 x M3 mounting holes on display
mount_hole_w = scale(126.20);
mount_hole_h = scale(65.65);
mount_hole_r = scale(3.9/2);

// derived values
base_h = scale(base_height);
base_w = scale(base_width);
base_l = scale(base_length);
base_hole_r = scale(base_hole_diameter/2);

foot_sx = scale(foot_sizex);
foot_sy = scale(foot_sizey);

support_h = scale(support_height);
support_t1 = scale(support_thickness1);
support_t2 = scale(support_thickness2);
support_h2e = scale(support_hole2edge);
support_wr = scale(support_web_radius);

support_face_w = support_h2e + ((base_l - mount_hole_w) / 2);

//------------------------------------------------------------------

module base_profile_2d() {
  delta = base_h * tan(display_angle);
  points = [
    [0, 0],
    [0, base_h],
    [base_w - delta, base_h],
    [base_w, 0],
  ];
  polygon(points=points, convexity=2);
}

module base_hole_profile_2d() {
  delta = (base_h + (2 * epsilon)) * tan(display_angle);
  points = [
    [foot_sx, -epsilon],
    [foot_sx, base_h + epsilon],
    [base_w - foot_sx - delta, base_h + epsilon],
    [base_w - foot_sx, -epsilon],
  ];
  polygon(points=points, convexity=2);
}

module base() {
  hole_l = base_l - (2 * foot_sy);
  difference() {
    linear_extrude(height=base_l) base_profile_2d();
    translate([0,0,foot_sy]) linear_extrude(height=hole_l) base_hole_profile_2d();
  }
}

//------------------------------------------------------------------

module support_face_2d() {
  delta = support_h * tan(display_angle);
  delta_t = support_t1 / cos(display_angle);
  points = [
    [0, 0],
    [-delta, support_h],
    [-delta + delta_t, support_h],
    [delta_t, 0],
  ];
  polygon(points=points, convexity=2);
}

module support_face() {
  delta_t = support_t1 / cos(display_angle);
  translate([base_w - delta_t,0,0]) linear_extrude(height=support_face_w) support_face_2d();
}

module support_web_2d() {
  delta1 = support_h * tan(display_angle);
  delta2 = support_t2 / cos(display_angle);
  h = base_h + support_t2 - support_t1;
  delta3 = h * tan(display_angle);

  points = [
    [0, 0],
    [0, h],
    [base_w - delta2 - delta3, h],
    [base_w - delta1 - delta2, support_h],
    [base_w - delta1, support_h],
    [base_w, 0],
  ];
  filleted(r=support_wr) polygon(points=points, convexity=2);
}

module support_web() {
  linear_extrude(height=support_t1) support_web_2d();
}

module support_left() {
  translate([0,0,base_l - support_face_w]) support_face();
  translate([0,0,base_l - support_t1])support_web();
}

module support_right() {
  support_face();
  support_web();
}

module support() {
  support_left();
  support_right();
}

//------------------------------------------------------------------

module display_hole() {
  h = support_t1 + (2 * epsilon);
  rotate([0,90,0]) cylinder(h = h, r = mount_hole_r, $fn = facets(mount_hole_r));
}

module display_holes() {

  dx = support_t1 + epsilon;
  dy = support_h - mount_hole_h - (support_h2e * cos(display_angle));
  dz = (base_l - mount_hole_w) / 2;

  translate([base_w,0,0]) rotate([0,0,display_angle]) translate([-dx,dy,dz]) union() {
    dx = mount_hole_w;
    dy = mount_hole_h;
    display_hole();
    translate([0,dy,0]) display_hole();
    translate([0,dy,dx]) display_hole();
    translate([0,0,dx]) display_hole();
  }
}

module base_hole() {
  h = base_h + (2 * epsilon);
  translate([0,-epsilon,0]) rotate([-90,0,0]) cylinder(h = h, r = base_hole_r, $fn = facets(base_hole_r));
}

module base_holes() {
  union() {
    z0 = (foot_sizey + support_t1) / 2;
    z1 = base_l - z0;
    x0 = foot_sizex / 2;
    x1 = x0 + (0.6 * base_w);
    translate([x0,0,z0]) base_hole();
    translate([x0,0,z1]) base_hole();
    translate([x1,0,z0]) base_hole();
    translate([x1,0,z1]) base_hole();
  }
}

module holes() {
  display_holes();
  base_holes();
}

//------------------------------------------------------------------

module display_stand() {
  difference() {
    union() {
      base();
      support();
    }
    holes();
  }
}

rotate([90,0,0]) display_stand();

//------------------------------------------------------------------
