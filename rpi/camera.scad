//------------------------------------------------------------------
/*

Housing for RPi Camera Module V2.1

*/
//------------------------------------------------------------------

// camera board
camera_board_x = 24.9;
camera_board_y = 23.8;
camera_board_z = 0.9;
camera_hole_diameter = 2;
camera_hole_to_edge = 2;
camera_hole_x = 21;
camera_hole_y = 12.5;

// camera body
camera_body_x = 8.2;
camera_body_y = 8.2;
camera_body_y_ofs = 10.3;
camera_body_z0 = 2.2;
camera_body_z1 = 4.5;
camera_body_diameter = 7.1;

// camera cable
camera_cable_x = 16;
camera_cable_y = 30;
camera_cable_z = 0.1;

// camera connector
camera_connector_x = 21.3;
camera_connector_y = 5.5;
camera_connector_z = 2.7;

// camera housing
housing_board_clearance = 0.3;
housing_lid_clearance = 0.3;
housing_cable_clearance = 0.3;
housing_wall_t0 = 6; // thick wall in board cavity
housing_wall_t1 = 2; // thin wall in lid cavity
housing_sides = 10;
housing_rounding = 4;
housing_x = camera_board_x + 2 * (housing_board_clearance + housing_sides);
housing_y = camera_board_y + 2 * (housing_board_clearance + housing_wall_t0);
housing_z = 11;
housing_post_z = max(camera_connector_z, 3);
housing_base_z = 2;

// camera lid
lid_x = housing_x - 2 * (housing_lid_clearance + housing_wall_t1);
lid_y = housing_y - 2 * (housing_lid_clearance + housing_wall_t1);
lid_z = 4;

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

module camera_body() {
  dx = (camera_board_x - camera_body_x)/2;
  translate([dx,camera_body_y_ofs,camera_board_z]) {
    r = camera_body_diameter/2;
    dx = camera_body_x/2;
    dy = camera_body_y/2;
    cube(size=[camera_body_x,camera_body_y,camera_body_z0]);
    translate([dx,dy,0]) cylinder(h=camera_body_z1, r=r, $fn=facets(r));
  }
}

module camera_cable() {
  x_ofs = (camera_board_x - camera_cable_x)/2;
  y_ofs = camera_board_y - (camera_connector_y/2);
  z_ofs = -camera_connector_z / 2;
  translate([x_ofs,y_ofs,z_ofs])
    cube(size=[camera_cable_x,camera_cable_y,camera_cable_z]);
}

module camera_connector() {
  x_ofs = (camera_board_x - camera_connector_x)/2;
  y_ofs = camera_board_y - camera_connector_y;
  z_ofs = -camera_connector_z;
  translate([x_ofs,y_ofs,z_ofs])
    cube(size=[camera_connector_x,camera_connector_y,camera_connector_z]);
}

module camera_board() {
  x_ofs = -camera_board_x/2;
  y_ofs = housing_board_clearance + housing_wall_t0;
  z_ofs = housing_base_z + housing_post_z;
  translate([x_ofs,y_ofs,z_ofs]) {
    color("DarkGreen") camera_pcb();
    color("DimGray") camera_body();
    color("LightBlue") camera_cable();
    color("SaddleBrown") camera_connector();
  }
}

//------------------------------------------------------------------

module housing_external_2d() {
  rounded(r=housing_rounding)
    square(size=[housing_x, housing_y]);
}

module housing_cavity_2d() {
  x = camera_board_x + (2 * housing_board_clearance);
  y = camera_board_y + (2 * housing_board_clearance);
  x_ofs = (housing_x - x) / 2;
  y_ofs = (housing_y - y) / 2;
  r = camera_hole_to_edge + housing_board_clearance;
  translate([x_ofs,y_ofs])
    rounded(r=r)
    square(size=[x, y]);
}

module housing_external() {
  linear_extrude(height=housing_z) housing_external_2d();
}

module housing_cavity() {
  h = housing_z - housing_base_z + epsilon;
  translate([0,0,housing_base_z]) linear_extrude(height=h) housing_cavity_2d();
}

module lid_cavity() {
  h = lid_z + epsilon;
  z_ofs = housing_z - lid_z;
  translate([0,0,z_ofs]) linear_extrude(height=h) {
    x = lid_x + housing_lid_clearance;
    y = lid_y + housing_lid_clearance;
    x_ofs = (housing_x - x) / 2;
    y_ofs = (housing_y - y) / 2;    
    r = housing_rounding - housing_wall_t1;
    translate([x_ofs,y_ofs])
      rounded(r=r)
      square(size=[x,y]);
  }
}

module cable_cavity() {
  x = camera_cable_x + (2 * housing_cable_clearance);
  y = ((housing_y - camera_board_y)/2) - housing_board_clearance + (2 * epsilon);
  x_ofs = (housing_x - x) / 2;
  y_ofs = housing_y - y + epsilon;
  z_ofs = housing_base_z + housing_post_z - (camera_connector_z / 2) - housing_cable_clearance;
  translate([x_ofs,y_ofs,z_ofs]) linear_extrude(height=housing_z) {
     square(size=[x,y]);
  }
}

module housing() {
  x_ofs = -housing_x / 2;
  translate([x_ofs, 0, 0]) {
    difference() {
      housing_external();
      union() {
        housing_cavity();
        lid_cavity();
        cable_cavity();
      }
    }
  }
}

//------------------------------------------------------------------

module lid_top() {
  x = lid_x;
  y = lid_y;
  x_ofs = x / 2;
  y_ofs = (housing_y - y) / 2;
  z_ofs = housing_z - lid_z;
  r = housing_rounding - housing_wall_t1 - housing_lid_clearance;
  translate([-x_ofs,y_ofs,z_ofs]) linear_extrude(height=lid_z) {
    rounded(r=r)
     square(size=[x,y]);
  }
}

module lid() {
  #lid_top();
}

//------------------------------------------------------------------

camera_board();
housing();
lid();

//------------------------------------------------------------------
