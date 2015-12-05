//------------------------------------------------------------------
/*

Involute Gears

*/
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
  pitch_radius,
  root_radius,
  base_radius,
  outer_radius,
  thick_angle,
  steps
) {
  // work out the angular extent of the tooth on the pitch radius
  pitch_point = involute(base_radius, involute_angle(base_radius, pitch_radius));
  pitch_angle = atan2(pitch_point[1], pitch_point[0]);
  center_angle = pitch_angle + (thick_angle / 2);

  // work out the angles over which the involute will be used
  start_angle = involute_angle(base_radius, max(base_radius, root_radius));
  stop_angle = involute_angle(base_radius, outer_radius);
  dtheta = (stop_angle - start_angle) / steps;

  union() {
    for (i=[0:steps-1]) {
      theta = start_angle + (i * dtheta);
      // create the involute points and rotate them down
      p0 = rotate_point(involute(base_radius, theta), -center_angle);
      p1 = rotate_point(involute(base_radius, theta + dtheta), -center_angle);
      // mirror the points across the x axis
      p0m = mirror_x(p0);
      p1m = mirror_x(p1);
      // build the trapezoid for the segment
      polygon (
        points = [p0, p1, p1m, p0m],
        paths = [[0,1,2,3,0]]
      );
    }
  }
}

//------------------------------------------------------------------

module involute_gear (
  number_teeth,
  pitch_radius,
  root_radius,
  base_radius,
  outer_radius,
  thick_angle,
  steps
) {

  tooth_angle = 360 / number_teeth;

  for (i = [1:number_teeth]) {
    rotate([0,0,i * tooth_angle]) {
      involute_gear_tooth(
        pitch_radius,
        root_radius,
        base_radius,
        outer_radius,
        thick_angle,
        steps
      );
    }
  }
}

//------------------------------------------------------------------

involute_gear(16, 100, 90, 95, 110, 10, 5);

//------------------------------------------------------------------

