// nearfield-wall-mount.scad
// Top-level: parameters (Customizer-friendly) + render_piece dispatch.

include <modules/common.scad>;
include <modules/joinery.scad>;
include <modules/base.scad>;

/* [Render] */
// 0 = assembly preview, 1 = base, 2 = arm-right, 3 = arm-left, 4 = platform
render_piece = 0; // [0:assembly, 1:base, 2:arm-right, 3:arm-left, 4:platform]

/* [Acoustic angles] */
toe_in_deg = 26; // [20:1:30]
tilt_deg   = 12; // [10:1:15]

/* [Arm geometry] */
arm_length  = 80;  // [50:5:100]
arm_root_h  = 60;  // [50:5:70]
arm_tip_h   = 30;  // [25:5:40]
arm_w       = 40;  // [35:5:50]

/* [Base geometry] */
base_h = 180; // [160:10:220]
base_w = 100; // [80:10:140]
base_t = 22;  // [22:2:28]

/* [Platform geometry] */
plat_depth        = 220; // [200:10:300]
plat_w            = 134; // [130:2:140]
plat_t            = 10;  // [8:1:14]
plat_boss_w       = 60;  // [50:5:80]
plat_boss_depth   = 30;  // [25:5:40]
plat_boss_extra_t = 12;  // [10:2:18]
lip_h             = 15;  // [12:1:18]
lip_t             = 6;   // [5:1:8]

/* [Joints] */
tenon_h_plat = 14;
tenon_w_plat = 26;
tenon_l_plat = 17;
tenon_h_base = 16;
tenon_w_base = 30;
tenon_l_base = 17;
tenon_clearance = 0.1;  // per-side
insert_spacing  = 10;

/* [Wall mounting] */
wall_screw_count   = 2;
wall_screw_spacing = 120;

/* [Fillets] */
fillet_r = 6; // [4:1:10]

/* [Quality] */
$fn = 64;

// Sanity asserts on parameters that interact:
assert(tenon_l_plat + 5 <= plat_t + plat_boss_extra_t,
       "platform mortise depth + 5 mm back wall must fit within platform thickness at boss");
assert(tenon_l_base + 5 <= base_t,
       "base mortise depth + 5 mm back wall must fit within base_t");
assert(arm_tip_h <= arm_root_h,
       "arm must taper inward (tip height <= root height)");

// --- Stub modules (filled in by subsequent tasks) ---
module base_module() {
    base_plate(base_h = base_h,
               base_w = base_w,
               base_t = base_t,
               tenon_h_base = tenon_h_base,
               tenon_w_base = tenon_w_base,
               tenon_l_base = tenon_l_base,
               tenon_clearance = tenon_clearance,
               wall_screw_count = wall_screw_count,
               wall_screw_spacing = wall_screw_spacing,
               insert_spacing = insert_spacing);
}
module arm_module()        { cube([arm_w, arm_length, arm_root_h]); }
module platform_module()   { cube([plat_w, plat_depth, plat_t]); }
module assembly_preview()  { base_module(); }

// --- Dispatch ---
if      (render_piece == 0) assembly_preview();
else if (render_piece == 1) base_module();
else if (render_piece == 2) arm_module();
else if (render_piece == 3) mirror([1,0,0]) arm_module();
else if (render_piece == 4) platform_module();
else assert(false, str("unknown render_piece: ", render_piece));
