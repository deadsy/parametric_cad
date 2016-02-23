//------------------------------------------------------------------

include <utils.scad>;
use <gears.scad>;

//------------------------------------------------------------------

function scale(x) = x * abs_shrink;

//------------------------------------------------------------------

gear_module = scale(80/16);
pressure_angle = 20;
gear_backlash = scale(0);
gear_clearance = scale(0);
involute_facets = 10;

//------------------------------------------------------------------

indent_r = scale((1/16) * mm_per_inch);

module plate_hole_2d() {
  plate_hole_r = scale(0.6);
  circle(r=plate_hole_r, $fn = facets(plate_hole_r));
}

module plate_holes_2d() {
  hdelta = scale(17);
  translate([hdelta,hdelta,0]) plate_hole_2d();
  translate([-hdelta,hdelta,0]) plate_hole_2d();
  translate([hdelta,-hdelta,0]) plate_hole_2d();
  translate([-hdelta,-hdelta,0]) plate_hole_2d();
}

module plate_indent_2d() {
  circle(r=indent_r, $fn=facets(indent_r));
  translate([-indent_r,0,0]) square(size=[2*indent_r,indent_r]);
}

module plate() {

  plate_r = (16 * gear_module / 2) * 0.83;
  plate_h = scale(5);
  rod_length = scale(62);

  difference() {
    union() {
      cylinder(r=plate_r, h = plate_h, $fn = facets(plate_r));
    }
    union() {
      translate([0,0,-epsilon]) {
        cylinder(r=hole_radius, h=plate_h+(2*epsilon), $fn = facets(hole_radius));
        linear_extrude(height=plate_h+(2*epsilon), convexity=2) plate_holes_2d();
      }
      rotate([90,0,0]) translate([0, plate_h-indent_r+epsilon, -rod_length/2])
        linear_extrude(height=rod_length, convexity=2) plate_indent_2d();
    }
  }
}


//------------------------------------------------------------------
// stacked gears

hub_radius = scale(20/2);
hub_height = scale(1);

hole_radius = scale((3/16) * mm_per_inch); // 3/8"

module stacked_gears() {

  sg_height = scale(10);
  sg1_teeth = 16;
  sg2_teeth = 12;

  difference() {
    union() {
      // 16 tooth spur gear
      sg1_pd = sg1_teeth * gear_module;
      spur_gear(
        number_teeth = sg1_teeth,
        gear_module = gear_module,
        pressure_angle = pressure_angle,
        backlash = gear_backlash,
        clearance = gear_clearance,
        ring_width = sg1_pd / 2,
        involute_facets = involute_facets,
        height = sg_height
      );
      // 12 tooth spur gear
      sg2_pd = sg2_teeth * gear_module;
      translate([0,0,sg_height - epsilon]) {
        spur_gear(
          number_teeth = sg2_teeth,
          gear_module = gear_module,
          pressure_angle = pressure_angle,
          backlash = gear_backlash,
          clearance = gear_clearance,
          ring_width = sg2_pd / 2,
          involute_facets = involute_facets,
          height = sg_height + epsilon
        );
      }
      // hub to reduce friction
      translate([0,0,(2 * sg_height) - epsilon]) {
        cylinder(r=hub_radius, h=hub_height + epsilon, $fn = facets(hub_radius));
      }
    }
    union() {
      translate([0,0,-epsilon]) {
        cylinder(r=hole_radius, h=hub_height+(2*sg_height)+2*epsilon, $fn = facets(hub_radius));
        linear_extrude(height=scale(10), convexity=2) plate_holes_2d();
      }
    }
  }
}

//------------------------------------------------------------------

module crown_gear32_1() {

  cg_hole_r = scale((5/32) * mm_per_inch);
  cg_hub_r = scale(20/2);

  cg_teeth = 32;
  cg_r = cg_teeth * gear_module / 2;

  cg_bh1 = scale(2);
  cg_bh2 = scale(9);
  cg_bh = cg_bh1 + cg_bh2;

  cg_cb_depth = scale(4);
  cg_cb_r = scale(10);

  difference() {
    union() {
      cylinder(h=cg_bh, r=cg_hub_r, , $fn = facets(cg_hub_r));
      cylinder(h=cg_bh2, r=cg_r);
      crown_gear(
        number_teeth = cg_teeth,
        gear_module = gear_module,
        pressure_angle = pressure_angle,
        backlash = gear_backlash,
        tooth_length = scale(10),
        pitch_position = 0.8,
        base_height = cg_bh
      );
    }
    union () {
      translate([0,0,-epsilon])
        cylinder(h = cg_bh + (2 * epsilon), r = cg_hole_r, $fn = facets(cg_hole_r));
      translate([0.75 * cg_r,0,-epsilon]) {
        cylinder(h = cg_bh + (2 * epsilon), r = cg_hole_r, $fn = facets(cg_hole_r));
        translate([0,0,cg_bh2 - cg_cb_depth + epsilon])
          cylinder(h = cg_cb_depth + epsilon, r = cg_cb_r, $fn = facets(cg_cb_r));
      }
    }
  }
}

//------------------------------------------------------------------

module crown_gear32_2(mode) {

  cg_hole_r = scale((5/32) * mm_per_inch);
  cg_hub_r = scale(20/2);

  cg_teeth = 32;
  cg_r = cg_teeth * gear_module / 2;
  pitch_position = 0.7;
  tooth_length = scale(10);

  cg_bh1 = scale(3);
  cg_bh2 = gear_module * 2.25;
  cg_bh = cg_bh1 + cg_bh2;
  cg_hub_h = cg_bh + scale(1);

  inner_radius = cg_r - (pitch_position * tooth_length);

  cg_cb_depth = scale(4);
  cg_cb_r = scale(10);

  if (mode == "gear") {
    difference() {
      union() {
        crown_gear(
          number_teeth = cg_teeth,
          gear_module = gear_module,
          pressure_angle = pressure_angle,
          backlash = gear_backlash,
          tooth_length = tooth_length,
          pitch_position = pitch_position,
          base_height = cg_bh1
        );
        cylinder(h=cg_bh, r=inner_radius, $fn = facets(inner_radius));
        cylinder(h=cg_hub_h, r=cg_hub_r, , $fn = facets(cg_hub_r));
      }
      union () {
        translate([0,0,-epsilon])
          cylinder(h = cg_hub_h + (2 * epsilon), r = cg_hole_r, $fn = facets(cg_hole_r));
        translate([0.75 * cg_r,0,-epsilon]) {
          cylinder(h = cg_bh + (2 * epsilon), r = cg_hole_r, $fn = facets(cg_hole_r));
          translate([0,0,cg_bh - cg_cb_depth + epsilon])
            cylinder(h = cg_cb_depth + epsilon, r = cg_cb_r, $fn = facets(cg_cb_r));
        }
      }
    }
  }
  
  if (mode == "handle") {
    handle_r1 = scale(10);
    handle_h1 = scale(6);
    handle_r2 = scale(15);
    handle_h2 = scale(20);
    handle_hole_r = scale(2);
    handle_hole_d = scale(10);
    handle_shaft_r = 0.97 * cg_hole_r;
    handle_shaft_h = 1.03 * (cg_bh - cg_cb_depth);
  
    rotate_extrude($fn=facets(handle_r2)) {
      points = [
        [0, 0],
        [handle_r1, 0],
        [handle_r2, handle_h1],
        [handle_r2, handle_h1 + handle_h2],
        [handle_r1, 2 * handle_h1 + handle_h2],
        [handle_shaft_r, 2 * handle_h1 + handle_h2],
        [handle_shaft_r, 2 * handle_h1 + handle_h2 + handle_shaft_h],
        [handle_hole_r, 2 * handle_h1 + handle_h2 + handle_shaft_h],
        [handle_hole_r, 2 * handle_h1 + handle_h2 + handle_shaft_h - handle_hole_d],
        [0, 2 * handle_h1 + handle_h2 + handle_shaft_h - handle_hole_d]
      ];
      polygon(points = points); 
    }
  }
}

//------------------------------------------------------------------

//crown_gear32_1();
//crown_gear32_2("gear");
crown_gear32_2("handle");
//stacked_gears();
//plate();

//------------------------------------------------------------------
