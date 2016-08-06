//------------------------------------------------------------------
/*

Mount for XV11 Lidar Unit

*/
//------------------------------------------------------------------

// measurements taken from device
lidar_width0 = 73.5;
lidar_width1 = 43.7;
lidar_length = 72.6;
lidar_pillar_diameter0 = 9.4;
lidar_pillar_diameter1 = 6;
lidar_pillar_step = 4;

// preferences
lidar_base_width = 15;
lidar_height = 30;
lidar_base_z = 4;
lidar_mount_hole_diameter = 3;
lidar_pillar_hole_diamater = 2;

//------------------------------------------------------------------

// small tweak to avoid differencing artifacts
epsilon = 0.05;

// control the number of facets on cylinders
facet_epsilon = 0.03;
function facets(r) = 180 / acos(1 - (facet_epsilon / r));

// rounded/filleted edges

module rounded(r=1) {
  offset(r=r, $fn=facets(r)) offset(r=-r, $fn=facets(r)) children(0);
}
module filleted(r=1) {
  offset(r=-r, $fn=facets(r)) render() offset(r=r, $fn=facets(r)) children(0);
}

//------------------------------------------------------------------
// Mounting pillar with support webs

// single pillar web
module pillar_web(
  web_height,
  web_radius,
  web_width
) {
  h = web_height;
  r = web_radius;
  w = web_width;
  points = [
    [0,0],
    [r,0],
    [0,h],
  ];
  rotate([90,0,0]) translate([0,0,-w/2]) linear_extrude(height=w) polygon(points=points);
}

// multiple pillar webs
module pillar_webs(
  number_webs,
  web_height,
  web_radius,
  web_width
) {
  theta = 360 / number_webs;
  for (i = [1:number_webs]) {
    rotate([0,0,i * theta]) pillar_web(web_height, web_radius, web_width);
  }
}

// pillar
module pillar0(
  pillar_height,
  pillar_radius
) {
  h = pillar_height;
  r = pillar_radius;
  cylinder(h=h, r=r, $fn=facets(r));
}

module pillar1(
  pillar_height,
  pillar_step,
  pillar_radius0,
  pillar_radius1,
) {
  x0 = pillar_radius0;
  x1 = pillar_radius1;
  y0 = pillar_height - pillar_step;
  y1 = pillar_height;

  points = [
    [0,0],
    [x0,0],
    [x0,y0],
    [x1,y0],
    [x1,y1],
    [0,y1],
  ];
  rotate_extrude($fn=facets(x0)) polygon(points=points);
}

module pillar_hole(
  pillar_height,
  hole_depth,
  hole_radius
) {
  h = hole_depth + epsilon;
  r = hole_radius;
  z_ofs = pillar_height - hole_depth;
  translate([0,0,z_ofs]) cylinder(h=h, r=r, $fn=facets(r));
}

// pillar with webs
module webbed_pillar0(
  pillar_height,
  pillar_radius,
  hole_depth,
  hole_radius,
  number_webs,
  web_height,
  web_radius,
  web_width,
) {
  difference() {
    union() {
      pillar0(pillar_height, pillar_radius);
      pillar_webs(number_webs, web_height, web_radius, web_width);
    }
    pillar_hole(pillar_height, hole_depth, hole_radius);
  }
}

module webbed_pillar1(
  pillar_height,
  pillar_step,
  pillar_radius0,
  pillar_radius1,
  hole_depth,
  hole_radius,
  number_webs,
  web_height,
  web_radius,
  web_width,
) {
  difference() {
    union() {
      pillar1(pillar_height, pillar_step, pillar_radius0, pillar_radius1);
      pillar_webs(number_webs, web_height, web_radius, web_width);
    }
    pillar_hole(pillar_height, hole_depth, hole_radius);
  }
}

//------------------------------------------------------------------

// countersunk hole
module hole_countersunk(
  length,
  radius,
) {
  l = length;
  r = radius;
  if (r > l) {
    points = [
      [0, 0],
      [(2 * r) - l, 0],
      [2 * r, l],
      [0, l]
    ];
    rotate_extrude($fn=facets(r)) polygon(points=points);
  } else {
    points = [
      [0, 0],
      [r, 0],
      [r, l - r],
      [2 * r, l],
      [0, l]
    ];
    rotate_extrude($fn=facets(r)) polygon(points=points);
  }
}

//------------------------------------------------------------------

module lidar_base_2d() {
  w0 = lidar_width0/2;
  w1 = lidar_width1/2;
  l = lidar_length;
  points = [
    [-w0,0],
    [w0,0],
    [w1,l],
    [-w1,l],
  ];
  polygon(points=points);
}

module lidar_base() {
  r0 = lidar_base_width / 1.8;
  r1 = r0 / 1.2;
  linear_extrude(height = lidar_base_z) difference() {
    offset(r=r0, $fn=facets(r0)) lidar_base_2d();
    rounded(r=r1) offset(r=-r1, $fn=facets(r1)) lidar_base_2d();
  }
}

module lidar_pillar() {
  z = lidar_height - lidar_base_z + epsilon;
  z_ofs = lidar_base_z - epsilon;
  translate([0,0,z_ofs]) webbed_pillar1(
    pillar_height = z,
    pillar_step = lidar_pillar_step,
    pillar_radius0 = lidar_pillar_diameter0 / 2,
    pillar_radius1 = lidar_pillar_diameter1 / 2,
    hole_depth = lidar_height / 3,
    hole_radius = lidar_pillar_hole_diamater / 2,
    number_webs = 4,
    web_height = lidar_height / 1.2,
    web_radius = lidar_base_width / 2.1,
    web_width = 2
  );
}

module lidar_pillars() {
  w0 = lidar_width0 / 2;
  w1 = lidar_width1 / 2;
  l = lidar_length;
  translate([w0,0]) lidar_pillar();
  translate([-w0,0]) lidar_pillar();
  translate([w1,l]) lidar_pillar();
  translate([-w1,l]) lidar_pillar();
}

module lidar_mount_hole() {
  h = lidar_base_z + (2 * epsilon);
  r = lidar_mount_hole_diameter / 2;
  translate([0,0,-epsilon])hole_countersunk(h, r);
}

module lidar_mount_holes() {
  w0 = lidar_width0 / 2;
  w1 = lidar_width1 / 2;
  b = w0;
  m = w1 - w0;

  f0 = 0.18;
  f1 = 0.84;
  y0 = lidar_length * f0;
  y1 = lidar_length * f1;
  x0 = (m * f0) + b;
  x1 = (m * f1) + b;

  translate([x0,y0]) lidar_mount_hole();
  translate([x1,y1]) lidar_mount_hole();
  translate([-x0,y0]) lidar_mount_hole();
  translate([-x1,y1]) lidar_mount_hole();
}

module lidar_mount() {
  difference() {
    union() {
      lidar_base();
      lidar_pillars();
    }
    lidar_mount_holes();
  }
}

lidar_mount();

//------------------------------------------------------------------
