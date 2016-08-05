

lidar_width0 = 60;
lidar_width1 = 90;
lidar_length = 80;

module pillar_web(
  web_width,
  web_radius,
  web_height
) {
  points = [
    [0,0],
    [web_radius,0],
    [0,web_height],
  ];
  linear_extrude(height=web_width) polygon(p=points);
}

module pillar_webs(
  web_width,
  web_radius,
  web_height,
  number_webs
) {
}

module pillar(
  pillar_radius,
  pillar_height,
  hole_radius,
  hole_depth
) {
}

module webbed_pillar(
  pillar_radius,
  pillar_height,
  hole_radius,
  hole_depth,
  web_width,
  web_radius,
  web_height,
  number_webs
) {
}

pillar_web();
