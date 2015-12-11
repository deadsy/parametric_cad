//------------------------------------------------------------------



//------------------------------------------------------------------

use <gears.scad>;

//------------------------------------------------------------------

module oil_pump_wheel() {

  gear_width = 1/4;

  difference() {

    union() {
      translate([0,0,-gear_width/2]) {
        spur_gear(
          number_teeth = 40,
          pitch_diameter = 5/4,
          pressure_angle = 20,
          backlash = 0,
          clearance = 0,
          ring_width = 3/32,
          involute_facets = 5,
          height = gear_width
        );
      }
      cylinder(
        h = gear_width/2,
        r = 1/2,
        $fn = facets(1/2),
        center = true
      );
      cylinder(
        h = 3/4,
        r = 1/4,
        $fn = facets(1/4),
        center = true
      );
    }

    union() {
      for(i = [0:5]) {
        rotate([0,0,i * 60]) {
          translate([3/8,0,0]) {
            cylinder(
              h = 1,
              r = 1/8,
              $fn = facets(1/8),
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

  gear_width = 1/4;
  translate([0,0,-gear_width/2]) {
    spur_gear(
      number_teeth = 10,
      pitch_diameter = 5/16,
      pressure_angle = 20,
      backlash = 0,
      clearance = 0,
      ring_width = 0.1,
      involute_facets = 5,
      height = gear_width
    );
  }
}

//------------------------------------------------------------------


module wallaby_gears() {

//  oil_pump_wheel();
  oil_pump_pinion();

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
