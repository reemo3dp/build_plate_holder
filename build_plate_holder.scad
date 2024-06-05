NUMBER_OF_PLATES    =   3;
BUILD_PLATE_WIDTH   =   120;
EXTRA_MARGIN        =   5;
THICKNESS           =   2;
WALL_THICKNESS      =   3;
FLOOR_THICKNESS     =   3;
BACKPLATE_THICKNESS =   10;

// CALCULATED
FLANGE_HEIGHT       =   BUILD_PLATE_WIDTH/3;
TOP_FLANGE_WIDTH    =   BUILD_PLATE_WIDTH/6;
BOTTOM_FLANGE_WIDTH =   BUILD_PLATE_WIDTH/4;
TOTAL_WIDTH         =   BUILD_PLATE_WIDTH + WALL_THICKNESS*2 + EXTRA_MARGIN;
TOTAL_DEPTH_PER_PLATE = WALL_THICKNESS+THICKNESS;
TOTAL_HEIGHT        = FLANGE_HEIGHT+FLOOR_THICKNESS;


SKADIS_Y_DIST       =   60.5;
SKADIS_Z_DIST       =   19.0;

include <skadis_base.scad>;

module build_plate_holder() {
    difference() {
        union() {
            backplate();
            for(i = [0 : NUMBER_OF_PLATES-1]) {
                difference() {
                    translate([0, -i*TOTAL_DEPTH_PER_PLATE, 0]) single_plate_segment();
                }
            }
        }
        for(i = [0 : NUMBER_OF_PLATES-2]) {
            translate([0, -THICKNESS-WALL_THICKNESS/2+-i*TOTAL_DEPTH_PER_PLATE, 0]) cylinder(h = TOTAL_HEIGHT, r = WALL_THICKNESS/4, $fn = 100);
            translate([TOTAL_WIDTH, -THICKNESS-WALL_THICKNESS/2+-i*TOTAL_DEPTH_PER_PLATE, 0]) cylinder(h = TOTAL_HEIGHT, r = WALL_THICKNESS/4, $fn = 100);
        }
    }
}


module backplate() {
    SKADIS_EDGE_INDEX = floor(TOTAL_WIDTH/2/SKADIS_Y_DIST);
        // TWO Skadis on the edges top, ONE bottom center
    difference() {
        cube([TOTAL_WIDTH, BACKPLATE_THICKNESS, TOTAL_HEIGHT]);
        union() {
            translate([TOTAL_WIDTH/2, BACKPLATE_THICKNESS, 10]) rotate([0, 0, 180]) skadis_base();
            
            translate([TOTAL_WIDTH/2+SKADIS_Y_DIST, BACKPLATE_THICKNESS, 10+SKADIS_Z_DIST]) rotate([0, 0, 180]) skadis_base();
               translate([TOTAL_WIDTH/2-SKADIS_Y_DIST, BACKPLATE_THICKNESS, 10+SKADIS_Z_DIST]) rotate([0, 0, 180]) skadis_base();
        }
    }
}

module single_plate_segment() {
    translate([0, -TOTAL_DEPTH_PER_PLATE, 0]) 
        union() {
            flanges();
            cube([TOTAL_WIDTH, TOTAL_DEPTH_PER_PLATE, FLOOR_THICKNESS]);
            cube([WALL_THICKNESS, TOTAL_DEPTH_PER_PLATE, FLANGE_HEIGHT+FLOOR_THICKNESS]);
            translate([TOTAL_WIDTH-WALL_THICKNESS, 0]) cube([WALL_THICKNESS, TOTAL_DEPTH_PER_PLATE, TOTAL_HEIGHT]);
        }
}

module flanges() {
    flange();
    translate([TOTAL_WIDTH,0]) mirror([1, 0, 0]) flange();
    
}

module flange() {
    translate([0, WALL_THICKNESS, FLOOR_THICKNESS]) rotate([90, 0, 0]) linear_extrude(WALL_THICKNESS) polygon(points = [[0, 0], [0, FLANGE_HEIGHT], [TOP_FLANGE_WIDTH, FLANGE_HEIGHT], [BOTTOM_FLANGE_WIDTH, 0]]);
}


build_plate_holder();