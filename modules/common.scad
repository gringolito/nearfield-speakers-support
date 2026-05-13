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

// --- M6 wall screw geometry ---
WALL_SCREW_D       = 6.5;   // clearance for 6 mm wood screw
WALL_SCREW_HEAD_D  = 12.0;  // countersunk head diameter
WALL_SCREW_HEAD_H  = 4.0;   // counterbore depth

// --- Print tolerances ---
PRINT_EPSILON = 0.01;       // overlap to avoid coplanar-face artifacts

module preview_marker(pos = [0,0,0], r = 2, color = "red") {
    color(color) translate(pos) sphere(r);
}
