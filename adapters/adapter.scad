//------------------------------------------------------------------
/*

Adapters for connecting a tool to a dust collector.

*/
//------------------------------------------------------------------
// Set the scaling value to compensate for print shrinkage

scale = 1/0.92; // ABS ~8% shrinkage
//scale = 1/0.98; // PLA ~2% shrinkage

function dim(x) = scale * x;

//------------------------------------------------------------------
// Basic parameters- The adapter fits around the outside diameter
// of the pipes on the tool and the vaccuum.

// Specify the outside diameter of the pipes to be fitted:
diameter_1 = dim(57.15); // mm
diameter_2 = dim(42.16); // mm

// Specify the length of the adapter at the respective diameters:
length_1 = dim(30); // mm
length_2 = dim(30); // mm

// Specify the transition length between the diameters:
// (A longer transition will reduce the overhang angle)
transition_length = dim(20); // mm

// Specify the wall thickness:
wall_thickness = dim(4); // mm

// The ID of the adapter will be larger than the OD of the fitted
// pipe by this clearance factor:
clearance = 1.02; // no unit

// An internal taper in the adapter will allow a push fit:
taper = 1; // degrees

//------------------------------------------------------------------
// control the number of facets on cylinders

facet_epsilon = 0.01;
function facets(r) = 180 / acos(1 - (facet_epsilon / r));

//------------------------------------------------------------------
// derived values

r1 = diameter_1 / 2;
r2 = diameter_2 / 2;

//------------------------------------------------------------------
// generate a 2D polygon for the adapter wall

module adapter_wall() {

  ir1 = r1 * clearance;
  ir2 = r2 * clearance;
  or1 = ir1 + wall_thickness;
  or2 = ir2 + wall_thickness;
  t1 = length_1 * sin(taper);
  t2 = length_2 * sin(taper);

  points = [
    [ir1,0],
    [or1, 0],
    [or1, length_1],
    [or2, length_1 + transition_length],
    [or2, length_1 + transition_length + length_2],
    [ir2, length_1 + transition_length + length_2],
    [ir2 - t2, length_1 + transition_length],
    [ir1 - t1, length_1],
  ];
  polygon(points=points, convexity = 2);
}

//------------------------------------------------------------------

module adapter() {
  overhang_angle = atan2(abs(r2 - r1), transition_length);
  echo("overhang angle is ", overhang_angle, "degrees");
  rotate_extrude(angle = 360, $fn = facets(r1)) {
    adapter_wall();
  }
}

adapter();

//------------------------------------------------------------------


