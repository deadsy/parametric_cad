
use <pcb_clip.scad>;

module clip_test() {

  y_ofs = 23;

  translate([0,-2 * y_ofs,0]) clip_pair(
    pcb_height = 5,
    pcb_thickness = 1.5,
    clip_height = 2,
    clip_thickness = 2.7,
    clip_depth = 1,
    clip_width = 9,
    clip_distance = 20.6
  );
  translate([0,-1 * y_ofs,0]) clip_pair(
    pcb_height = 5,
    pcb_thickness = 1.5,
    clip_height = 2,
    clip_thickness = 2.6,
    clip_depth = 1,
    clip_width = 9,
    clip_distance = 20.7
  );
  translate([0,0,0]) clip_pair(
    pcb_height = 5,
    pcb_thickness = 1.5,
    clip_height = 2,
    clip_thickness = 2.5,
    clip_depth = 1,
    clip_width = 9,
    clip_distance = 20.8
  );
  translate([0,1 * y_ofs,0]) clip_pair(
    pcb_height = 5,
    pcb_thickness = 1.5,
    clip_height = 2,
    clip_thickness = 2.4,
    clip_depth = 1,
    clip_width = 9,
    clip_distance = 20.9
  );
  translate([0,2 * y_ofs,0]) clip_pair(
    pcb_height = 5,
    pcb_thickness = 1.5,
    clip_height = 2,
    clip_thickness = 2.3,
    clip_depth = 1,
    clip_width = 9,
    clip_distance = 21.0
  );
}

module test_base(h) {
  w = 28;
  l = 110;
  translate([-w/2,-l/2,0]) cube([w,l,h]);
}

h = 2;
epsilon = 0.001;
test_base(h);
translate([0,0,h - epsilon]) clip_test();
