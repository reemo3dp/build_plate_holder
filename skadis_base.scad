
module skadis_base() {
    translate([-4.5/2, 4.6, 22]) rotate([90, 0, 0]) union() {
        cube([4.5, 10, 4.6]);
        translate([0, 0, -4.5]) cube([4.5, 15, 4.5]);
        translate([0, -22, 0]) cube([4.5, 5.4, 4.6]);
    }
}

function SKADIS_HINGE_CENTER() = 5+(22/2);
function SKADIS_TOTAL_HEIGHT() = 22+5+10;
function SKADIS_TOTAL_DEPTH() = 5+4.6;

skadis_base();
