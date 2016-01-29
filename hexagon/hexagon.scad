//------------------------------------------------------------------
/*





*/
//------------------------------------------------------------------

hexagon_radius = 10;
rounding_factor = 0.4;

//------------------------------------------------------------------
// Set the scaling value to compensate for print shrinkage

scale = 1/0.995; // ABS ~0.5% shrinkage
//scale = 1/0.998; // PLA ~0.2% shrinkage

function dim(x) = scale * x;

//------------------------------------------------------------------
// derived values

hex_r = dim(hexagon_radius);

//------------------------------------------------------------------

// control the number of facets on cylinders
facet_epsilon = 0.01;
function facets(r) = 180 / acos(1 - (facet_epsilon / r));

// small tweak to avoid differencing artifacts
epsilon = 0.05;

//------------------------------------------------------------------

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

module n_agon(n, r) {

  dtheta = 360/n;
  angle = [for (i=[0:n-1]) (i * dtheta)];
  points = [for (a=angle) [r * cos(a), r * sin(a)]];
  polygon(points=points, convexity=2);
}

module hexagon(r) {
    n_agon(6, r);
}

//------------------------------------------------------------------

module honeycomb_row(posn, n) {
  delta = [(3/2) * hex_r, (sqrt(3)/2) * hex_r, 0];
  for (i = [0:n]) {
    t = [posn[0] + i * delta[0], posn[1] + i * delta[1], 0];
    translate(t) {
      rounded(hex_r * rounding_factor) hexagon(hex_r + epsilon);
    }
  }
}

honeycomb_row([0,0,0], 10);

//------------------------------------------------------------------
