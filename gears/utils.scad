//------------------------------------------------------------------
/*

Utility Functions/Definitions

*/
//-----------------------------------------------------------------
// scaling

mm_per_inch = 25.4;
al_shrink = 1/0.99; // ~1%
pla_shrink = 1/0.998; //~0.2%
abs_shrink = 1/0.995; //~0.5%

//------------------------------------------------------------------
// control the number of facets on cylinders

facet_epsilon = 0.05;
function facets(r) = 180 / acos(1 - (facet_epsilon / r));

// small tweak to avoid differencing artifacts
epsilon = 0.05;

//------------------------------------------------------------------

pi = 3.1415926535;

// degrees to radians
function d2r(d) = (d * pi) / 180;

// radians to degrees
function r2d(r) = (180 * r) / pi;

//------------------------------------------------------------------
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
