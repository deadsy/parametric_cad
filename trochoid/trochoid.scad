//------------------------------------------------------------------
/*

Trochoids

*/
//------------------------------------------------------------------
// w = wheel ratio  (epi < 0, hypo > 0)
// p = generating radius

function trochoid(w, p, theta) = [
  (1 - w) * cos(theta) - (p * w) * cos((1-(1/w)) * theta),
  (1 - w) * sin(theta) - (p * w) * sin((1-(1/w)) * theta)
];

//------------------------------------------------------------------
// See- http://mathinteract.com/, http://scot.tk/re/Trochoids/Trochoids.htm

module trochoid_polygon (
  n,
  d,
  s,
  p,
  facets
) {
  w = s * (n/d);
  dtheta = (n * 360) / facets;
  theta = [for (i=[0:facets]) i * dtheta];
  points = [for (t=theta) trochoid(w, p, t)];
  polygon(points=points, convexity = 10);
}

//------------------------------------------------------------------

module test_trochoid() {
  //trochoid_polygon(1, 10, 1, 2, 200);
  trochoid_polygon(3, 2, 1, 1.5, 200);
}

//------------------------------------------------------------------

test_trochoid();

//------------------------------------------------------------------
