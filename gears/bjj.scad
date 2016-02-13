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
// stacked gears

hub_radius = scale(20/2);
hub_height = scale(2);

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
    translate([0,0,-epsilon]) {
        cylinder(
          r=hole_radius,
          h=hub_height + (2 * sg_height) + 2 * epsilon,
          $fn = facets(hub_radius)
        );
    }
  }
}

//------------------------------------------------------------------

module crown_gear32() {

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

crown_gear32();
//stacked_gears();

//------------------------------------------------------------------
