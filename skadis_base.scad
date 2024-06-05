module skadis_base() {
    cube([4.5, 10, 4.6]);
    translate([0, 0, -4.5]) cube([4.5, 15, 4.5]);
    translate([0, -22, 0]) cube([4.5, 5.4, 4.6]);
}

//difference() {
//    cube([60, 60, 4.6], center = true);
//    skadis_base();
//}