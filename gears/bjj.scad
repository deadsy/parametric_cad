//------------------------------------------------------------------

include <utils.scad>;
use <gears.scad>;

//------------------------------------------------------------------

gear_module = scale(80/16);
pressure_angle = 20;
gear_backlash = scale(0);
gear_clearance = scale(0);
involute_facets = 10;

sg_height = scale(10);
sg1_teeth = 16;
sg2_teeth = 12;

hub_radius = scale(20/2);
hub_height = scale(2);

hole_radius = scale(9.525/2); // 3/8"

//------------------------------------------------------------------

module stacked_gears() {
  difference() {
    union() {
      // 16 tooth spur gear
      sg1_pd = gear_module * sg1_teeth;
      spur_gear(
        number_teeth = sg1_teeth,
        pitch_diameter = sg1_pd,
        pressure_angle = pressure_angle,
        backlash = gear_backlash,
        clearance = gear_clearance,
        ring_width = sg1_pd / 2,
        involute_facets = involute_facets,
        height = sg_height
      );
      // 12 tooth spur gear
      sg2_pd = gear_module * sg2_teeth;
      translate([0,0,sg_height - epsilon]) {
        spur_gear(
          number_teeth = sg2_teeth,
          pitch_diameter = sg2_pd,
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

module crown_rack() {
  rack(
    number_teeth = 10,
    gear_module = gear_module,
    pressure_angle = pressure_angle,
    backlash = gear_backlash,
    base_height = scale(5),
    base_width = sg_height
  );
}

//------------------------------------------------------------------

crown_rack();
//stacked_gears();

//------------------------------------------------------------------
