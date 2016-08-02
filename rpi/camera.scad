//------------------------------------------------------------------
/*

Housing for RPi Camera Module V2.1

*/
//------------------------------------------------------------------

// camera board
camera_board_x = 25;
camera_board_y = 24;
camera_board_z = 1;
camera_cable_x = 16;
camera_hole_diameter = 2;
camera_hole_to_edge = 2;
camera_hole_x = 21;
camera_hole_y = 12.5;

// camera base
base_z = 4;
base_rounding = 4;
base_foot_x = 8;
base_foot_y = 8;
base_foot_hole_to_edge = 4;
base_foot_hole_diameter = 3;

// camera housing
housing_to_board_clearance = 0.5;
housing_wall_thickness = 3;

//------------------------------------------------------------------
// utility functions

// scaling
pla_shrink = 1/0.999; //~0.1%
abs_shrink = 1/0.995; //~0.5%

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
  h = camera_board_z + (2 * epsilon);
  r = camera_hole_diameter/2;

  basex = camera_hole_to_edge;
  basey = camera_hole_to_edge;
  dx = camera_hole_x;
  dy = camera_hole_y;

  posn = [[0,0], [0,1], [1,0], [1,1]];
  for (x = posn) {
    translate([basex + x[0] * dx, basey + x[1] * dy, -epsilon])
      cylinder(h=h, r=r, $fn=facets(r));
  }
}

module camera_pcb() {
  difference() {
    linear_extrude(height=camera_board_z)
      rounded(r=camera_hole_to_edge)
      square(size=[camera_board_x, camera_board_y]);
    camera_pcb_holes();
  }
}

module camera_board() {
  color("green") camera_pcb();
}

//------------------------------------------------------------------

housing_delta = housing_to_board_clearance + housing_wall_thickness; 
housing_x = camera_board_x + (2 * housing_delta);
housing_y = camera_board_y + (2 * housing_delta);

module housing_2d() {
  r = camera_hole_to_edge + housing_delta; 
  rounded(r=r)
    square(size=[housing_x, housing_y]);
}

module foot_2d() {
}

module base_2d() {
  union() {
    square(size=[housing_x, housing_y]);
  }
}

//------------------------------------------------------------------

camera_board();
housing_2d();

//------------------------------------------------------------------
