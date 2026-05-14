// nearfield-wall-mount.scad
// Top-level: parameters (Customizer-friendly) + render_piece dispatch.

include <modules/common.scad>;
include <modules/joinery.scad>;
include <modules/base.scad>;
include <modules/platform.scad>;
include <modules/arm.scad>;

/* [Render] */
// 0 = assembly preview, 1 = base, 2 = arm-right, 3 = arm-left, 4 = platform
render_piece = 0; // [0:assembly, 1:base, 2:arm-right, 3:arm-left, 4:platform]

/* [Acoustic angles] */
toe_in_deg = 26; // [20:1:30]
tilt_deg   = 12; // [10:1:15]

/* [Arm geometry] */
arm_length  = 70;  // [50:5:100]
arm_root_h  = 60;  // [50:5:70]
arm_tip_h   = 30;  // [25:5:40]
arm_w       = 40;  // [35:5:50]

/* [Base geometry] */
base_h = 140; // [160:10:220]
base_w = 90; // [80:10:140]
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
wall_screw_spacing = 100;

/* [Fillets & Chamfers] */
edge_r   = 1.0; // [0:0.5:6]
fillet_r = 1.0; // [0:0.5:6]
chamfer  = 1.0; // [0:0.5:6]

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
               insert_spacing = insert_spacing,
               chamfer = chamfer,
               edge_r = edge_r);
}
module arm_module() {
    arm(arm_length = arm_length,
        toe_in_deg = toe_in_deg,
        tilt_deg = tilt_deg,
        arm_root_h = arm_root_h,
        arm_tip_h = arm_tip_h,
        arm_w = arm_w,
        tenon_h_base = tenon_h_base,
        tenon_w_base = tenon_w_base,
        tenon_l_base = tenon_l_base,
        tenon_h_plat = tenon_h_plat,
        tenon_w_plat = tenon_w_plat,
        tenon_l_plat = tenon_l_plat,
        insert_spacing = insert_spacing,
        fillet_r = fillet_r,
        edge_r = edge_r);
}
module platform_module() {
    platform_body(plat_depth = plat_depth,
                  plat_w = plat_w,
                  plat_t = plat_t,
                  plat_boss_w = plat_boss_w,
                  plat_boss_depth = plat_boss_depth,
                  plat_boss_extra_t = plat_boss_extra_t,
                  lip_h = lip_h,
                  lip_t = lip_t,
                  tenon_h_plat = tenon_h_plat,
                  tenon_w_plat = tenon_w_plat,
                  tenon_l_plat = tenon_l_plat,
                  tenon_clearance = tenon_clearance,
                  insert_spacing = insert_spacing,
                  chamfer = chamfer,
                  edge_r = edge_r);
}
module assembly_preview() {
    // Show the right-hand bracket assembled.
    // Base in its real-world orientation: wall-facing face at y = 0, front at y = base_t.
    // Arm root tenon plugs into base's mortise.
    // Platform attaches at the arm tip.

    // Base — rotated so its front face is along +Y (matching arm root direction)
    color("steelblue")
        rotate([270, 0, 0])
            translate([-base_w/2, -base_h/2, 0])
                base_module();

    // Arm — origin at base's mortise location
    color("seagreen")
        translate([0, base_t, 0])
            arm_module();

    // Platform — translated to the arm tip.
    // tip_pos is in arm-local frame; arm is placed at [0, base_t, 0] in world,
    // so add base_t to Y. Inner translate lifts the platform so the mortise
    // centre (at -plat_t - plat_boss_extra_t/2 in platform Z) lands at
    // arm-tip-local Z = 0, aligning it with the tip tenon.
    tip_pos   = arm_centerline_pos(1, arm_length, toe_in_deg, tilt_deg);
    tip_yaw   = arm_yaw(1, toe_in_deg);
    tip_pitch = arm_pitch(1, tilt_deg);
    color("darkorange")
        translate([tip_pos[0], tip_pos[1] + base_t, tip_pos[2]])
            rotate([0, 0, tip_yaw])
            rotate([tip_pitch, 0, 0])
                translate([0, 0, plat_t + plat_boss_extra_t/2])
                    platform_module();
}

// --- Dispatch ---
if      (render_piece == 0) assembly_preview();
else if (render_piece == 1) base_module();
else if (render_piece == 2) arm_module();
else if (render_piece == 3) mirror([1,0,0]) arm_module();
else if (render_piece == 4) platform_module();
else assert(false, str("unknown render_piece: ", render_piece));
