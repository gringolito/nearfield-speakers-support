// modules/common.scad
// Shared constants and small utilities.

// --- M5 heat-set insert geometry ---
INSERT_M5_OD     = 6.4;   // outer diameter to drill into the plastic
INSERT_M5_DEPTH  = 8.0;   // depth of the heat-set insert
INSERT_M5_LEAD   = 0.3;   // small lead-in chamfer at the mouth

// --- M5 clamping screw geometry ---
SCREW_M5_D       = 5.2;   // clearance hole diameter (slightly oversized)
SCREW_M5_HEAD_D  = 8.8;   // M5 SHCS head diameter (with margin)
SCREW_M5_HEAD_H  = 5.0;   // M5 SHCS head height (for counterbore)

// Cosmetic counterbore depth for the M5 clamping screw head on the
// boss's entry face. Partial recess only — head still sits proud by
// (SCREW_M5_HEAD_H - SCREW_M5_COUNTERBORE_DEPTH) mm. Increasing this
// risks weakening the boss wall on the entry side.
SCREW_M5_COUNTERBORE_DEPTH = 2.0;

// Minimum thickness of plastic to retain on the side of the boss
// opposite the clamping-screw entry (the "far wall"). Also reused as
// the safety margin around each screw vs. the boss's free faces.
MIN_BOSS_SCREW_WALL = 3.0;

// --- M6 wall screw geometry ---
WALL_SCREW_D       = 6.5;   // clearance for 6 mm wood screw
WALL_SCREW_HEAD_D  = 12.0;  // countersunk head diameter
WALL_SCREW_HEAD_H  = 2.0;   // counterbore depth

// --- Print tolerances ---
PRINT_EPSILON = 0.01;       // overlap to avoid coplanar-face artifacts

module preview_marker(pos = [0,0,0], r = 2, color = "red") {
    color(color) translate(pos) sphere(r);
}

// rounded_cube(x, y, z, r, center): rectangular solid with all 12 edges and
//   8 corners spherically rounded to radius r. Behaves like cube() when r=0.
//   center=false (default) places the corner at the origin, matching cube() behavior.
//   Uses hull() of 8 spheres — no minkowski, no render() needed.
module rounded_cube(x, y, z, r, center = false) {
    r_ = min(r, x/2, y/2, z/2);
    fn_r = max(8, round($fn / 4));
    translate(center ? [0, 0, 0] : [x/2, y/2, z/2]) {
        if (r_ <= 0) {
            cube([x, y, z], center = true);
        } else {
            hull() {
                for (xi = [-(x/2 - r_), (x/2 - r_)])
                    for (yi = [-(y/2 - r_), (y/2 - r_)])
                        for (zi = [-(z/2 - r_), (z/2 - r_)])
                            translate([xi, yi, zi])
                                sphere(r = r_, $fn = fn_r);
            }
        }
    }
}

// fillet_solid(r): spherically rounds the external edges of any solid geometry.
//   Unlike rounded_cube(), correctly handles unions — internal junctions stay
//   sharp, only exposed external edges are rounded. Use render() inside for
//   performance. Outer dimensions grow by r in all directions.
module fillet_solid(r) {
    fn_r = max(8, round($fn / 4));
    if (r <= 0) {
        children();
    } else {
        minkowski() {
            render() children();
            sphere(r = r, $fn = fn_r);
        }
    }
}
