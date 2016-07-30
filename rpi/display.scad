//------------------------------------------------------------------
/*

Rasberry Pi 7" Display

*/
//------------------------------------------------------------------

include <utils.scad>;

//------------------------------------------------------------------

// nominal outside dimensions of display lens
lens_width = 192.96;
lens_height = 110.76;
lens_corner_radius = 6.5;

// nominal display dimensions
display_width = 155;
display_height = 87;

//------------------------------------------------------------------
// generate a 2d polygon for the display lens

lens_w = 192.96;
lens_h = 110.76;
lens_r = 6.5;

module display_lens_2d() {
  rounded(r = lens_r) square(size = [lens_w, lens_h]);
}

//------------------------------------------------------------------

display_lens_2d();

//------------------------------------------------------------------
