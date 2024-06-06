module chamfer(xy, distance, center = false) {
       trf = center ? [0, 0, 0] : [xy[0]/2, xy[1]/2, 0];
       translate(trf) hull() {
        linear_extrude(height = 0.00001) square(xy, center = true);
        translate([0, 0, distance]) linear_extrude(height = 0.00001) square([xy[0]+distance*2, xy[1]+distance*2], center = true);
        }
}

chamfer([10, 10], 2, center = false);