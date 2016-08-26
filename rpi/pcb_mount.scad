//------------------------------------------------------------------
/*

4 Pillar PCB Mount

*/
//------------------------------------------------------------------

mount_width = 50;
mount_length = 60;
mount_height = 30;
mount_hole_diameter = 3;

pillar_diameter = 9.4;
pillar_hole_diameter = 2;

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

// single web
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

// multiple webs
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
module pillar(
  pillar_height,
  pillar_radius
) {
  h = pillar_height;
  r = pillar_radius;
  cylinder(h=h, r=r, $fn=facets(r));
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
module webbed_pillar(
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
      pillar(pillar_height, pillar_radius);
      pillar_webs(number_webs, web_height, web_radius, web_width);
    }
    pillar_hole(pillar_height, hole_depth, hole_radius);
  }
}

//------------------------------------------------------------------

module mount_base_2d() {
  w = mount_width;
  l = mount_length;
  points = [
    [0,0],
    [w,0],
    [w,l],
    [0,l],
  ];
  polygon(points=points);
}

//------------------------------------------------------------------
