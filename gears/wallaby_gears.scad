//------------------------------------------------------------------

use <utils.scad>;
use <gears.scad>;

//------------------------------------------------------------------

module oil_pump_wheel() {

  gear_width = dim(1/4);

  difference() {
    union() {
      translate([0,0,-gear_width/2]) {
        spur_gear(
          number_teeth = 40,
          pitch_diameter = dim(5/4),
          pressure_angle = 20,
          backlash = dim(0),
          clearance = dim(0),
          ring_width = dim(3/32),
          involute_facets = 8,
          height = gear_width
        );
      }
      // gear body
      cylinder(
        h = gear_width/2,
        r = dim(1/2),
        center = true
      );
      // hub
      cylinder(
        h = dim(3/4),
        r = dim(1/4),
        $fn = facets(dim(1/4)),
        center = true
      );
    }
    // holes in gear body
    union() {
      for(i = [0:5]) {
        rotate([0,0,i * 60]) {
          translate([dim(3/8),0,0]) {
            cylinder(
              h = gear_width,
              r = dim(7/64),
              $fn = facets(dim(7/64)),
              center = true
            );
          }
        }
      }
    }
  }
}


//------------------------------------------------------------------

module oil_pump_pinion() {

  gear_width = dim(1/4);

  translate([0,0,-gear_width/2]) {
    spur_gear(
      number_teeth = 10,
      pitch_diameter = dim(5/16),
      pressure_angle = 20,
      backlash = dim(0),
      clearance = dim(0),
      ring_width = dim(0.1),
      involute_facets = 8,
      height = gear_width
    );
  }
}

//------------------------------------------------------------------


module wallaby_gears() {

  oil_pump_wheel();
//  oil_pump_pinion();

/*
  translate([3,0,0]) {
    spur_gear(
      number_teeth = 20,
      pitch_diameter = 5/8,
      pressure_angle = 20,
      backlash = 0,
      clearance = 0,
      ring_width = 0.125,
      involute_facets = 5,
      height = 0.25
    );
  }



  }*/



}

wallaby_gears();


//------------------------------------------------------------------
