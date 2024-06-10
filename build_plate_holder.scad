NUMBER_OF_PLATES = 4;
BUILD_PLATE_WIDTH = 350;
THICKNESS_MULTIPLIER = BUILD_PLATE_WIDTH/120;
EXTRA_MARGIN = 2.4;
THICKNESS = 2.4;
WALL_THICKNESS = 2.4*THICKNESS_MULTIPLIER;
SIDE_THICKNESS = 4.8*THICKNESS_MULTIPLIER;
FLOOR_THICKNESS = 3*THICKNESS_MULTIPLIER;
BACKPLATE_THICKNESS = 4.6;
CHAMFER_SIDE = 3*THICKNESS_MULTIPLIER;
CHAMFER_TOP = 0.77*THICKNESS_MULTIPLIER;
SKADIS_BACKPLATE = true;
STAIRCASE=true;
STAIRCASE_GAP=10;
LOGO="r3d";


// CALCULATED
BACKPLATE_EXTRA_DISTANCE = SKADIS_BACKPLATE ? SKADIS_TOTAL_DEPTH() - BACKPLATE_THICKNESS : 0;
BACKPLATE_DISTANCE = SKADIS_BACKPLATE ? BACKPLATE_THICKNESS + BACKPLATE_EXTRA_DISTANCE : WALL_THICKNESS;
FLANGE_HEIGHT = min(60, max(40, BUILD_PLATE_WIDTH / 3));
TOP_FLANGE_WIDTH = BUILD_PLATE_WIDTH / 6;
BOTTOM_FLANGE_WIDTH = BUILD_PLATE_WIDTH / 4;
PLATE_WIDTH = BUILD_PLATE_WIDTH + EXTRA_MARGIN;
TOTAL_WIDTH = PLATE_WIDTH + SIDE_THICKNESS * 2;
TOTAL_DEPTH_PER_PLATE = WALL_THICKNESS + THICKNESS;
TOTAL_DEPTH = TOTAL_DEPTH_PER_PLATE * NUMBER_OF_PLATES + BACKPLATE_DISTANCE;
TOTAL_HEIGHT = FLANGE_HEIGHT + FLOOR_THICKNESS;
CHAMFER_LENGTH = sqrt(2 * CHAMFER_SIDE ^ 2);
BOTTOM_OFFSET = STAIRCASE ? STAIRCASE_GAP*(NUMBER_OF_PLATES-1) : 0;
MAX_HEIGHT  = STAIRCASE ? BOTTOM_OFFSET + TOTAL_HEIGHT : TOTAL_HEIGHT;
LOGO_FILE = LOGO == "voron" ? "voron.svg" : "reemo3dp.svg";
LOGO_DEPTH=0.8;

SKADIS_Y_DIST = 40;

use <chamfer.scad>;
use <skadis_base.scad>;

module build_plate_holder()
{
    difference()
    {
        union()
        {
            if(SKADIS_BACKPLATE) {
                skadis_backplate();
            } else {
                standing_backplate();
            }
            build_plate_segments();
        }
        union()
        {
            edge_chamfers();
            for (i = [1:NUMBER_OF_PLATES - 1])
            {
                if(!STAIRCASE) {
                    translate([ 0, -i * TOTAL_DEPTH_PER_PLATE, 0 ]) 
                        single_plate_segment_top_chamfer();
                }
                translate([ 0, -i * TOTAL_DEPTH_PER_PLATE + WALL_THICKNESS/2, 0 ]) 
                    side_cylinder();
            }
            if(true) {
                if(SKADIS_BACKPLATE) {
                    backplate_segment_top_chamfer();
                } else {
                    single_plate_segment_top_chamfer();
                }
            }
        }
    }
}

module side_cylinder() {
    translate([0, 0, -BOTTOM_OFFSET]) cylinder(h = MAX_HEIGHT  , r = WALL_THICKNESS/2, $fn = 100);
    translate([TOTAL_WIDTH, 0, -BOTTOM_OFFSET]) cylinder(h = MAX_HEIGHT  , r = WALL_THICKNESS/2, $fn = 100);
}

module standing_backplate()
{
    difference() {
        union()
        {
            flanges();
            cube([ TOTAL_WIDTH, WALL_THICKNESS, TOTAL_HEIGHT ]);
            if(STAIRCASE) {
                translate([0, 0, -BOTTOM_OFFSET]) cube([TOTAL_WIDTH, WALL_THICKNESS, BOTTOM_OFFSET]);
                
            }
        }
    }
}


module build_plate_segments()
{
    difference()
    {
        union()
        {
            for (i = [0:NUMBER_OF_PLATES - 1])
            {
                height = STAIRCASE ? STAIRCASE_GAP * (-i) : 0;
                translate([ 0, -i * TOTAL_DEPTH_PER_PLATE, height  ]) 
                    difference() { 
                        single_plate_segment();
                        if(STAIRCASE && i > 0) {
                            single_plate_segment_top_chamfer();
                        }
                    }
                if(STAIRCASE) {
                    translate([0, -(i+1) * TOTAL_DEPTH_PER_PLATE, -BOTTOM_OFFSET]) cube([TOTAL_WIDTH, TOTAL_DEPTH_PER_PLATE, STAIRCASE_GAP * (NUMBER_OF_PLATES-i-1)]);
                }
            }
        }
        logo();
    }


}

    module logo()
    {
        width = 15 * BUILD_PLATE_WIDTH/120;
        height = min(TOTAL_HEIGHT-width-10, 15 * BUILD_PLATE_WIDTH/120);

        // Voron logo is 1mm x 1mm
        

        offset_left = (BOTTOM_FLANGE_WIDTH - (BOTTOM_FLANGE_WIDTH - TOP_FLANGE_WIDTH) / TOTAL_HEIGHT * height) / 2;
        
        
        translate([offset_left-width/2, -TOTAL_DEPTH_PER_PLATE * NUMBER_OF_PLATES-0.1, height-BOTTOM_OFFSET])  scale([width, -1, width]) rotate([90, 0, 0]) linear_extrude(height = LOGO_DEPTH, convexity = 10) import(file = LOGO_FILE);
        
        translate([TOTAL_WIDTH-offset_left-width/2, -TOTAL_DEPTH_PER_PLATE * NUMBER_OF_PLATES-0.1, height-BOTTOM_OFFSET])  scale([width, -1, width]) rotate([90, 0, 0]) linear_extrude(height = LOGO_DEPTH, convexity = 10) import(file = LOGO_FILE);

    }

module edge_chamfers()
{
    
    translate([ 0, BACKPLATE_DISTANCE - CHAMFER_LENGTH / 2, -BOTTOM_OFFSET ]) rotate([ 0, 0, 45 ])
        cube([ CHAMFER_SIDE, CHAMFER_SIDE, MAX_HEIGHT ]);
    translate([ TOTAL_WIDTH, BACKPLATE_DISTANCE - CHAMFER_LENGTH / 2, -BOTTOM_OFFSET ]) rotate([ 0, 0, 45 ])
        cube([ CHAMFER_SIDE, CHAMFER_SIDE, MAX_HEIGHT ]);

    translate([ 0, BACKPLATE_DISTANCE - CHAMFER_LENGTH / 2 - TOTAL_DEPTH, -BOTTOM_OFFSET ]) rotate([ 0, 0, 45 ])
        cube([ CHAMFER_SIDE, CHAMFER_SIDE, MAX_HEIGHT ]);
    translate([ TOTAL_WIDTH, BACKPLATE_DISTANCE - CHAMFER_LENGTH / 2 - TOTAL_DEPTH, -BOTTOM_OFFSET ]) rotate([ 0, 0, 45 ])
        cube([ CHAMFER_SIDE, CHAMFER_SIDE, MAX_HEIGHT ]);
}

module skadis_backplate()
{
    skadis_distance = floor((TOTAL_WIDTH-50)/SKADIS_Y_DIST);
    height = -BOTTOM_OFFSET+ floor(MAX_HEIGHT/20)*20 - SKADIS_TOTAL_HEIGHT();
    difference()
    {
        union()
        {
            // floor
            translate([0, 0, -BOTTOM_OFFSET]) cube([ TOTAL_WIDTH, BACKPLATE_DISTANCE, FLOOR_THICKNESS + BOTTOM_OFFSET ]);
            
            // walls
            cube([ SIDE_THICKNESS, BACKPLATE_DISTANCE, TOTAL_HEIGHT ]);
            translate([ TOTAL_WIDTH - SIDE_THICKNESS, 0, 0 ])
                cube([ SIDE_THICKNESS, BACKPLATE_DISTANCE, TOTAL_HEIGHT ]);
            // backplate
            translate([ 0, BACKPLATE_DISTANCE - BACKPLATE_THICKNESS, -BOTTOM_OFFSET ])
                cube([ TOTAL_WIDTH, BACKPLATE_THICKNESS, MAX_HEIGHT ]);
        }
        union()
        {
            if(skadis_distance % 2 == 0) {
                #translate(
                [ TOTAL_WIDTH / 2, BACKPLATE_DISTANCE, height] )
                rotate([ 0, 0, 180 ]) skadis_base();
            }

            translate(
                [ TOTAL_WIDTH / 2 + SKADIS_Y_DIST*skadis_distance / 2, BACKPLATE_DISTANCE, height])
                rotate([ 0, 0, 180 ]) skadis_base();
            translate(
                [ TOTAL_WIDTH / 2 - SKADIS_Y_DIST*skadis_distance /2, BACKPLATE_DISTANCE, height])
                rotate([ 0, 0, 180 ]) skadis_base();
        }
    }
}

module single_plate_segment()
{
    translate([ 0, -TOTAL_DEPTH_PER_PLATE, 0 ]) difference() {
        union()
        {
            flanges();
            cube([ TOTAL_WIDTH, TOTAL_DEPTH_PER_PLATE, FLOOR_THICKNESS ]);
            cube([ SIDE_THICKNESS, TOTAL_DEPTH_PER_PLATE, FLANGE_HEIGHT + FLOOR_THICKNESS ]);
            translate([ TOTAL_WIDTH - SIDE_THICKNESS, 0 ]) cube([ SIDE_THICKNESS, TOTAL_DEPTH_PER_PLATE, TOTAL_HEIGHT ]);
        }
    }
}

module single_plate_segment_top_chamfer()
{
    translate([ SIDE_THICKNESS, -THICKNESS, TOTAL_HEIGHT - CHAMFER_TOP ]) chamfer([ PLATE_WIDTH, THICKNESS ], CHAMFER_TOP);
}

module backplate_segment_top_chamfer()
{
    translate([ SIDE_THICKNESS, -THICKNESS, TOTAL_HEIGHT -CHAMFER_TOP ])
        chamfer([ PLATE_WIDTH, BACKPLATE_EXTRA_DISTANCE + THICKNESS ],CHAMFER_TOP);
}

module flanges()
{
    flange();
    translate([ TOTAL_WIDTH, 0 ]) mirror([ 1, 0, 0 ]) flange();
}

module flange()
{
    translate([ 0, WALL_THICKNESS, FLOOR_THICKNESS ]) rotate([ 90, 0, 0 ]) linear_extrude(WALL_THICKNESS) polygon(
        points = [ [ 0, 0 ], [ 0, FLANGE_HEIGHT ], [ TOP_FLANGE_WIDTH, FLANGE_HEIGHT ], [ BOTTOM_FLANGE_WIDTH, 0 ] ]);
}

build_plate_holder();