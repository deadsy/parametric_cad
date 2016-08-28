//------------------------------------------------------------------
/*

PCB Clip

*/
//------------------------------------------------------------------

module clip(
  pcb_height,
  pcb_thickness,
  clip_height,
  clip_thickness,
  clip_depth,
  clip_width
) {
  theta0 = 45;
  factor = 0.8;
  x0 = clip_thickness - clip_depth;
  x1 = x0 + (clip_depth * factor);
  x2 = clip_thickness;
  y0 = pcb_height;
  y1 = y0 + pcb_thickness;
  y2 = y1 + (clip_depth * factor * tan(theta0));
  y3 = y2 + clip_height;
  points = [
    [0,0],
    [x2,0],
    [x2,y0],
    [x0,y0],
    [x0,y1],
    [x1,y2],
    [x0,y3],
    [0,y3],
  ];
  translate([0,clip_width/2,0])
  rotate([90,0,0])
  linear_extrude(height=clip_width) polygon(points=points);
}

module clip_pair(
  pcb_height,
  pcb_thickness,
  clip_height,
  clip_thickness,
  clip_depth,
  clip_width,
  clip_distance,
){
  x_ofs = clip_distance + (clip_thickness - clip_depth) * 2;

  translate([-x_ofs/2,0,0]) union(){
    clip(
      pcb_height,
      pcb_thickness,
      clip_height,
      clip_thickness,
      clip_depth,
      clip_width
    );
    translate([x_ofs,0,0]) rotate([0,0,180])clip(
      pcb_height,
      pcb_thickness,
      clip_height,
      clip_thickness,
      clip_depth,
      clip_width
    );
  }
}

//------------------------------------------------------------------
