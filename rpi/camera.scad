//------------------------------------------------------------------
/*

Housing for RPi Camera Module V2.1

*/
//------------------------------------------------------------------

camera_board_width = 25;
camera_board_height = 24;
camera_board_thickness = 1;
camera_cable_width = 16;
camera_hole_diameter = 2;
camera_hole_to_edge = 2;
camera_hole_width = 21;
camera_hole_height = 12.5;

//------------------------------------------------------------------
// utility functions

// scaling
pla_shrink = 1/0.999; //~0.1%
abs_shrink = 1/0.995; //~0.5%
function scale(x) = pla_shrink * x;

// small tweak to avoid differencing artifacts
epsilon = 0.05;

// control the number of facets on cylinders
facet_epsilon = 0.03;
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
// camera board

module camera_pcb_holes() {
  h = camera_board_thickness + (2 * epsilon);
  r = camera_hole_diameter/2;

  basex = camera_hole_to_edge;
  basey = camera_hole_to_edge;
  dx = camera_hole_width;
  dy = camera_hole_height;

  posn = [[0,0], [0,1], [1,0], [1,1]];
  for (x = posn) {
    translate([basex + x[0] * dx, basey + x[1] * dy, -epsilon])
      cylinder(h=h, r=r, $fn=facets(r));
  }
}

module camera_pcb() {
  difference() {
    linear_extrude(height=camera_board_thickness)
      rounded(r=camera_hole_to_edge)
      square(size=[camera_board_width, camera_board_height]);
    camera_pcb_holes();
  }
}

module camera_board() {
  color("green") camera_pcb();
}

camera_board();

//------------------------------------------------------------------
