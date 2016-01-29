//------------------------------------------------------------------
/*

Angle Brackets

*/
//------------------------------------------------------------------
// Parameters

bracket_angle = 80;

bracket_length = 120;
arm1_length = 30;
arm2_length = 30;
wall_thickness = 3;

arm1_holes = 3;
arm1_hole_diameter = 5;
arm1_hole_spacing = 0.8;
arm1_hole_position = 0.7;

arm2_holes = 2;
arm2_hole_diameter = 6;
arm2_hole_spacing = 0.4;
arm2_hole_position = 0.6;

number_of_webs = 4;
web_size = 0.8;
web_spacing = 0.3;

fillet_factor = 1.0;
rounding_factor = 0.2;

//------------------------------------------------------------------
// Set the scaling value to compensate for print shrinkage

scale = 1/0.995; // ABS ~0.5% shrinkage
//scale = 1/0.998; // PLA ~0.2% shrinkage

function dim(x) = scale * x;

//------------------------------------------------------------------
// derived values

bracket_l = dim(bracket_length);
arm1 = dim(arm1_length);
arm2 = dim(arm2_length);
wall_t = dim(wall_thickness);
arm1_hole_r = dim(arm1_hole_diameter/2);
arm2_hole_r = dim(arm2_hole_diameter/2);

//------------------------------------------------------------------
// control the number of facets on cylinders

facet_epsilon = 0.01;
function facets(r) = 180 / acos(1 - (facet_epsilon / r));

// small tweak to avoid differencing artifacts
epsilon = 0.05;

//------------------------------------------------------------------
// rounded/filleted edges

module outset(d=1) {
  minkowski() {
    circle(r=d, $fn=facets(d));
    children(0);
  }
}

module inset(d=1) {
  render() inverse() outset(d=d) inverse() children(0);
}

module inverse() {
  difference() {
    square(1e5, center=true);
    children(0);
  }
}

module rounded(r=1) {
  outset(d=r) inset(d=r) children(0);
}

module filleted(r=1) {
  inset(d=r) render() outset(d=r) children(0);
}

//------------------------------------------------------------------

module hole(n, r, k) {
  space = bracket_l/(n - 1 + (2 * k));
  for (i = [1:n]) {
    translate([(k + i - 1) * space, 0, -epsilon]) {
      cylinder(h=wall_t + (2 * epsilon), r = r, $fn=facets(r));
    }
  }
}

module holes() {
  if (arm1_holes > 0) {
    translate([arm1_hole_position * arm1,0,0]) rotate([-90,-90,0]) {
      hole(arm1_holes, arm1_hole_r, arm1_hole_spacing);
    }
  }
  if (arm2_holes > 0) {
    d = arm2_hole_position * arm2;
    c = cos(bracket_angle);
    s = sin(bracket_angle);
    translate([d * c, d * s, 0]) rotate([0,-90,90+bracket_angle]) {
      hole(arm2_holes, arm2_hole_r, arm2_hole_spacing);
    }
  }
}

module web_profile() {
  c = cos(bracket_angle);
  s = sin(bracket_angle);
  d1 = arm1 * (1-web_size);
  d2 = arm2 * (1-web_size);
  wt = wall_t - epsilon;

  points = [
    [(c + 1) * wt/s, wt],
    [(c * arm2) + (s * wt) - (c * d2), (s * arm2) - (c * wt) - (s * d2)],
    [arm1 - d1, wt],
  ];
  polygon(points=points, convexity=2);
}

module web() {
  linear_extrude(height=wall_t) {
    web_profile();
  }
}

module webs() {
  space = (bracket_l - (number_of_webs * wall_t)) / (number_of_webs - 1 + (2 * web_spacing));
  for (i = [1:number_of_webs]) {
    translate([0, 0, (web_spacing * space) + (i - 1) * (space + wall_t)]) {
       web();
    }
  }
}

module bracket_profile() {
  c = cos(bracket_angle);
  s = sin(bracket_angle);
  d1 = arm1 * (1-web_size);
  d2 = arm2 * (1-web_size);
  points = [
    [arm1, wall_t],
    [arm1, 0],
    [0, 0],
    [c * arm2, s * arm2],
    [(c * arm2) + (s * wall_t), (s * arm2) - (c * wall_t)],
    [(c + 1) * wall_t/s, wall_t],
  ];
  rounded(rounding_factor * wall_t) filleted(fillet_factor * wall_t) polygon(points=points, convexity=2);
}

module bracket() {
  difference() {
    union() {
      linear_extrude(height=bracket_l) {
        bracket_profile();
      }
      if (number_of_webs > 0) {
        webs();
      }
    }
    holes();
  }
}

bracket();

//------------------------------------------------------------------
