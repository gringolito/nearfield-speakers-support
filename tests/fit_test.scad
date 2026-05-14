// tests/fit_test.scad
// Prints a single tenon and a matching mortise block side-by-side.
// Use this to calibrate tenon_clearance for your printer:
//   - Print, then try to slide the tenon into the mortise
//   - Too tight: increase tenon_clearance in the main spec
//   - Too loose: decrease tenon_clearance
//   - Goal: firm slide-fit, no rocking

include <../modules/common.scad>;
include <../modules/joinery.scad>;

$fn = 64;

// Match the platform tenon dimensions from the spec
tenon_h = 14;
tenon_w = 26;
tenon_l = 17;
tenon_clearance = 0.1;

// Layout: tenon on the left, mortise block on the right, separated by 20 mm
GAP = 20;

// Print the tenon attached to a small base for stability
module test_tenon() {
    BASE_T = 4;
    union() {
        translate([-tenon_w/2 - 5, -tenon_h/2 - 5, 0])
            cube([tenon_w + 10, tenon_h + 10, BASE_T]);
        translate([0, 0, BASE_T])
            tenon(tenon_h, tenon_w, tenon_l);
    }
}

// Mortise block — same outer footprint, mortise cut into it
module test_mortise() {
    BLOCK_T = tenon_l + 5;   // 5 mm back wall
    difference() {
        translate([-tenon_w/2 - 5, -tenon_h/2 - 5, 0])
            cube([tenon_w + 10, tenon_h + 10, BLOCK_T]);
        translate([0, 0, BLOCK_T - tenon_l - PRINT_EPSILON])
            mortise_cutout(tenon_h, tenon_w, tenon_l, clearance = tenon_clearance);
    }
}

test_tenon();
translate([tenon_w + 10 + GAP, 0, 0]) test_mortise();
