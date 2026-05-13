// modules/platform.scad
// Piece 3 — platform with boss + lip. Universal between L and R.

include <common.scad>;
include <joinery.scad>;

// platform(): oriented for print TOP-FACE-DOWN.
//   Z = 0 is the speaker resting surface (in real life, this is the platform top;
//        in print orientation, it's against the bed).
//   Z = plat_t is the underside of the platform body.
//   Boss extends from Z = plat_t to Z = plat_t + plat_boss_extra_t at the back.
//   The mortise opens on the back face (y = 0) and extends in +Y into the boss.
//   Lip extends in +Z direction (above the platform top, toward the speaker baffle).
//
// Strategy: model the part RIGHT-SIDE-UP (top face = +Z), then the export
//   script will apply a mirror or rotate transform to flip for printing.
//   This keeps the modeling intuitive and the print orientation independent.

module platform_body(plat_depth, plat_w, plat_t,
                     plat_boss_w, plat_boss_depth, plat_boss_extra_t,
                     lip_h, lip_t,
                     tenon_h_plat, tenon_w_plat, tenon_l_plat,
                     tenon_clearance, insert_spacing) {
    // Origin: platform top face center at z = 0.
    //   +X = lateral right, +Y = forward (toward lip), +Z = up
    //   Back of platform at y = 0, front at y = plat_depth.
    //   Lip is at y = plat_depth, extending +Z direction (above the platform).
    //   Boss extends -Z (below the platform) at the back.

    difference() {
        union() {
            // Main slab — origin at top face center
            translate([-plat_w/2, 0, -plat_t])
                cube([plat_w, plat_depth, plat_t]);

            // Boss — extends below the slab at the back, centered in X
            translate([-plat_boss_w/2, 0, -plat_t - plat_boss_extra_t])
                cube([plat_boss_w, plat_boss_depth, plat_boss_extra_t]);

            // Lip — sits on top of the platform at the front edge
            translate([-plat_w/2, plat_depth - lip_t, 0])
                cube([plat_w, lip_t, lip_h]);
        }

        // Mortise pocket on the back face (y = 0), extending in +Y into the boss.
        // Vertical center placed at the midpoint of the boss thickness.
        mortise_z_center = -plat_t - plat_boss_extra_t/2;
        translate([0, 0, mortise_z_center])
            rotate([-90, 0, 0])  // map mortise long axis (+Z) to +Y (into boss)
                mortise_cutout(tenon_h_plat, tenon_w_plat,
                               tenon_l_plat, clearance = tenon_clearance);

        // 2 lateral clamping screw holes piercing through the boss,
        // aligned with the inserts in the inserted tenon (insert centers
        // at y = tenon_l_plat/2 ± insert_spacing/2).
        translate([0, tenon_l_plat/2, mortise_z_center])
            rotate([-90, 0, 0])
                clamping_screw_hole(piece_thru = plat_boss_w,
                                    tenon_z_pos = -tenon_l_plat/2,
                                    tenon_l = tenon_l_plat,
                                    spacing = insert_spacing);
    }
}
