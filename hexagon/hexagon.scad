//------------------------------------------------------------------
/*





*/
//------------------------------------------------------------------

hexagon_radius = 10;
rounding_factor = 0.4;
cell_size = 0.9;

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

module honeycomb_row(posn, cols, r1, r2) {
  delta = [(3/2) * r1, (sqrt(3)/2) * r1, 0];
  for (i = [0:cols-1]) {
    t = [posn[0] + i * delta[0], posn[1] + i * delta[1], 0];
    translate(t) {
      hexagon(r2);
    }
  }
}

module honeycomb_grid(posn, rows, cols, r1, r2) {
  delta = [(3/2) * r1, (sqrt(3)/2) * r1, 0];
  for (i = [0:rows-1]) {
    t = [posn[0] + i * delta[0], posn[1] - i * delta[1], 0];
    honeycomb_row(t, cols, r1, r2);
  }
}

linear_extrude(height=50) {
  difference () {
    outset((1 - cell_size) * hex_r) honeycomb_grid([0,0,0], 10, 10, hex_r, hex_r + epsilon);
    rounded(3) honeycomb_grid([0,0,0], 10, 10, hex_r, hex_r * cell_size);
  }
}
//------------------------------------------------------------------
