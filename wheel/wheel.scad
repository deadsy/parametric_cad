//------------------------------------------------------------------
/*

Pottery Wheel

A wheel with a flat surface on one side and a hub on the other.

*/
//------------------------------------------------------------------
/* [Global] */

/*[General]*/
wheel_diameter = 360;
hub_diameter = 50;
hub_length = 60;
shaft_diameter = 25;
shaft_length = 40;
wall_height = 40;
wall_thickness = 6;

/*[Webs]*/
number_of_webs = 6;
web_size_at_hub = 0.8; // [0:0.05:1]
web_height_at_wall = 0.8; // [0:0.05:1]

/*[Casting]*/
draft_angle = 2;

/*[Fillets]*/
fillet_factor = 2.0;
rounding_factor = 0.2; // [0:0.05:1]

/* [Hidden] */
//------------------------------------------------------------------
// Set the scaling value to compensate for print shrinkage

scale = 1/0.995; // ABS ~0.5% shrinkage
//scale = 1/0.998; // PLA ~0.2% shrinkage

function dim(x) = scale * x;

//------------------------------------------------------------------
// derived values





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






//------------------------------------------------------------------
