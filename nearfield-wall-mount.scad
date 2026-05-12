/* [Acoustic Angles] */
// Horizontal toe-in angle (degrees) [20:1:30]
toe_in = 26;
// Downward vertical tilt (degrees) [10:1:15]
tilt = 12;
// Speaker side: "left" or "right"
side = "left"; // [left, right]

/* [Piece 1 - Wall Base Plate] */
base_h = 160;           // plate height (mm) [140:10:180]
base_w = 80;            // plate width (mm) [70:5:100]
base_t = 10;            // plate thickness (mm) [8:1:12]
wall_hole_d = 5.5;      // wall screw hole diameter (mm)
wall_hole_spacing = 40; // horizontal spacing between hole pair (mm)
wall_hole_upper_y = 130;// upper hole height from bottom (mm)
wall_hole_lower_y = 25; // lower hole height from bottom (mm)
wall_csink_d = 10;      // countersink diameter (mm)
boss1_protrusion = 20;  // arm boss protrusion from plate front (mm)

/* [Piece 2 - Arm] */
// Distance between boss seating faces (Piece 1 to Piece 3)
arm_length = 80;        // (mm) [70:5:130]
arm_w = 35;             // arm body width (mm) [30:5:45]
arm_h = 30;             // arm body height (mm) [25:5:40]
rib_t = 9;              // lateral rib thickness (mm) [8:1:12]
rib_depth = 50;         // max rib depth at wall end (mm) [40:5:65]

/* [Piece 3 - Platform] */
platform_depth = 200;       // platform depth, wall to front (mm) [180:10:220]
platform_w = 135;       // platform width (mm) [120:5:145]
platform_t = 6;         // shelf thickness (mm) [5:1:8]
lip_h = 15;             // front safety lip height (mm) [12:1:18]
lip_t = 6;              // front safety lip thickness (mm) [5:1:8]
boss3_protrusion = 24;  // arm boss protrusion below shelf bottom (mm)

/* [Joint - Tenon/Mortise] */
tenon_w = 28;           // tenon width (mm)
tenon_h = 18;           // tenon height (mm)
tenon_l = 14;           // tenon length (mm)
tenon_clearance = 0.2;  // per-side clearance in mortise (mm) [0.1:0.05:0.3]

/* [Hardware] */
insert_m5_od = 7.0;     // M5 heat-set insert outer diameter (mm)
insert_m5_depth = 10.0; // M5 heat-set insert depth (mm)
screw_m5_d = 5.2;       // M5 pass-through hole diameter (mm)

/* [Fillets] */
fillet_main = 6;        // external corner fillet radius (mm)
fillet_rib = 8;         // arm-to-rib root fillet radius (mm)
fillet_small = 3;       // secondary fillet radius (mm)

/* [Render] */
// 0=assembly preview  1=Piece 1  2=Piece 2  3=Piece 3
render_piece = 1; // [0:3]

// --- derived ---
arm_total_l = arm_length + 2 * tenon_l; // 108 mm
boss_w = tenon_w + 2 * fillet_main + 4; // 44 mm
boss_h = tenon_h + 2 * fillet_main + 4; // 34 mm

include <modules/common.scad>
include <modules/piece1.scad>
include <modules/piece2.scad>
include <modules/piece3.scad>
include <modules/assembly.scad>

// --- dispatch ---
if (render_piece == 0) assembly_preview();
else if (render_piece == 1) piece1_base(side);
else if (render_piece == 2) piece2_arm();
else if (render_piece == 3) piece3_platform();
