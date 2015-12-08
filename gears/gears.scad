//------------------------------------------------------------------
/*

Involute Gears

*/
//------------------------------------------------------------------
// control the number of facets on cylinders

_accuracy = 0.001;
function facets(r) = 180 / acos(1 - (_accuracy / r));

//------------------------------------------------------------------

epsilon = 0.001;

//------------------------------------------------------------------

pi = 3.1415926535;

// degrees to radians
function d2r(d) = (d * pi) / 180;

// radians to degrees
function r2d(r) = (180 * r) / pi;

// return the involute coordinate
// r = base radius
// theta = involute angle (degrees)
function involute(r, theta) = [
  r * (cos(theta) + d2r(theta) * sin(theta)),
  r * (sin(theta) - d2r(theta) * cos(theta))
];

// return the involute angle (degrees)
// r = base radius
// d = involute radial distance
function involute_angle(r, d) = r2d(sqrt(pow(d / r, 2) - 1));

// mirror across the x-axis
function mirror_x(p) = [p[0], -p[1]];

// rotate point p by theta (degrees)
function rotate_point(p, theta) = [
  cos(theta) * p[0] - sin(theta) * p[1],
  sin(theta) * p[0] + cos(theta) * p[1]
];

//------------------------------------------------------------------

module involute_gear_tooth (
  number_teeth,
  pitch_radius,
  root_radius,
  base_radius,
  outer_radius,
  backlash,
  involute_facets
) {

  // work out the angular extent of the tooth on the base radius
  pitch_point = involute(base_radius, involute_angle(base_radius, pitch_radius));
  face_angle = atan2(pitch_point[1], pitch_point[0]);
  backlash_angle = r2d(backlash / pitch_radius) / 2;
  center_angle = (90 / number_teeth) + face_angle - backlash_angle;

  // work out the angles over which the involute will be used
  start_angle = involute_angle(base_radius, max(base_radius, root_radius));
  stop_angle = involute_angle(base_radius, outer_radius);
  dtheta = (stop_angle - start_angle) / involute_facets;

  union() {
    for (i=[0:involute_facets - 1]) {
      theta = start_angle + (i * dtheta);
      // create the involute points and rotate them down
      p0 = rotate_point(involute(base_radius, theta), -center_angle);
      p1 = rotate_point(involute(base_radius, theta + dtheta), -center_angle);
      // mirror the points across the x axis
      p0m = mirror_x(p0);
      p1m = mirror_x(p1);
      // build the trapezoid for the segment
      polygon (
        points = [[0,0], p0, p1, p1m, p0m],
        paths = [[0,1,2,3,4,0]]
      );
    }
  }
}

//------------------------------------------------------------------
// generate a 2D involute gear
// number_teeth = number of teeth
// pitch_diameter = diameter of pitch circle
// pressure_angle = pressure angle (degrees)
// backlash = backlash expressed as units of pitch circumference
// clearance = additional root clearance
// ring_width = width of ring wall (from root circle)
// involute_facets = number of facets for involute flank

module involute_gear(
  number_teeth,
  pitch_diameter,
  pressure_angle,
  backlash,
  clearance,
  ring_width,
  involute_facets
) {

  pitch_radius = pitch_diameter / 2;

  // base circle radius
  base_radius = pitch_radius * cos(pressure_angle);

  // addendum: radial distance from pitch circle to outside circle
  addendum = pitch_diameter / number_teeth;
  // dedendum: radial distance from pitch circle to root circle
  dedendum = addendum + clearance;

  outer_radius = pitch_radius + addendum;
  root_radius = pitch_radius - dedendum;
  ring_radius = root_radius - ring_width;

  difference() {
    union() {
      for (i = [1:number_teeth]) {
        rotate([0,0,i * (360 / number_teeth)]) {
           involute_gear_tooth (
             number_teeth,
             pitch_radius,
             root_radius,
             base_radius,
             outer_radius,
             backlash,
             involute_facets
           );
        }
      }
      circle(r = root_radius, $fn = facets(root_radius));
    }
    circle(r = ring_radius, $fn = facets(ring_radius));
  }
}

//------------------------------------------------------------------

module spur_gear(
  number_teeth = 20,
  pitch_diameter = 2,
  pressure_angle = 20,
  backlash = 0,
  clearance = 0,
  ring_width = 0.2,
  involute_facets = 5,
  height = 1
) {
  linear_extrude(height = height) {
    involute_gear(
      number_teeth = number_teeth,
      pitch_diameter = pitch_diameter,
      pressure_angle = pressure_angle,
      backlash = backlash,
      clearance = clearance,
      ring_width = ring_width,
      involute_facets = involute_facets
    );
  }
}

//------------------------------------------------------------------

module helical_gear(
  number_teeth,
  pitch_diameter,
  pressure_angle,
  backlash,
  clearance,
  ring_width,
  involute_facets,
  height,
  helix_angle
) {

  twist_angle = r2d(2 * height * tan(helix_angle) / pitch_diameter);

  linear_extrude(height = height, twist = twist_angle) {
    involute_gear(
      number_teeth = number_teeth,
      pitch_diameter = pitch_diameter,
      pressure_angle = pressure_angle,
      backlash = backlash,
      clearance = clearance,
      ring_width = ring_width,
      involute_facets = involute_facets
    );
  }
}

//------------------------------------------------------------------

module test_involute_gear_tooth() {
  involute_gear_tooth (
    number_teeth = 20,
    pitch_radius = 10,
    root_radius = 8,
    base_radius = 9,
    outer_radius = 11,
    backlash = 0,
    involute_facets = 5
  );
}

module test_involute_gear() {
  involute_gear(
    number_teeth = 32,
    pitch_diameter = 50,
    pressure_angle = 20,
    backlash = 0,
    clearance = 0,
    ring_width = 5,
    involute_facets = 10
  );
}

module test_spur_gear() {
  spur_gear(
    number_teeth = 20,
    pitch_diameter = 2,
    pressure_angle = 20,
    backlash = 0,
    clearance = 0,
    ring_width = 0.2,
    involute_facets = 5,
    height = 0.25
  );
}

module test_helical_gear() {
  helical_gear(
    number_teeth = 32,
    pitch_diameter = 4,
    pressure_angle = 20,
    backlash = 0,
    clearance = 0,
    ring_width = 0.2,
    involute_facets = 5,
    height = 1,
    helix_angle = 15
  );
}

//------------------------------------------------------------------

//test_involute_gear_tooth();
//test_involute_gear();
//test_spur_gear();
test_helical_gear();

//------------------------------------------------------------------

