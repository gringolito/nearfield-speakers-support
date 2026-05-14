// modules/platform.scad
// Piece 3 — platform with boss + lip. Universal between L and R.

include <common.scad>;
include <joinery.scad>;

// platform(): modeled right-side-up (Z=0 is the speaker resting surface,
//   +Z is up toward the speaker, -Z is down toward the boss/wall).
//   The exported STL has the boss extending in -Z. When loaded in a slicer,
//   the boss's lowest face naturally lands on the bed — this is the
//   intended print orientation ("boss-face down"). The speaker resting
//   surface prints upward as a clean top surface.
//
//   Coordinate frame:
//     +X = lateral right, +Y = forward (toward lip), +Z = up
//     Back of platform at y = 0, front at y = plat_depth.
//     Lip is at y = plat_depth, extending +Z direction (above the platform).
//     Boss extends -Z (below the platform) at the back, opening into the
//     mortise pocket where the arm tip tenon engages.

module platform_body(plat_depth, plat_w, plat_t,
                     plat_boss_w, plat_boss_depth, plat_boss_extra_t,
                     lip_h, lip_t,
                     tenon_h_plat, tenon_w_plat, tenon_l_plat,
                     tenon_clearance, insert_spacing,
                     chamfer = 0,
                     edge_r = 0) {
    // Origin: platform top face center at z = 0.
    //   +X = lateral right, +Y = forward (toward lip), +Z = up
    //   Back of platform at y = 0, front at y = plat_depth.
    //   Lip is at y = plat_depth, extending +Z direction (above the platform).
    //   Boss extends -Z (below the platform) at the back.
    //
    // The mortise center is placed at the geometric center of the full
    // back face (slab + boss), so the arm tip face — which is centered on
    // its tenon — lands centered on the platform back face. With the
    // matching pair (plat_boss_w = arm_w, plat_t + plat_boss_extra_t =
    // arm_tip_h) the boss + lower slab back face exactly covers the arm
    // tip face, mirroring the base-boss / arm-root relationship.

    // Each piece's external faces are pre-inset by edge_r so that after
    // fillet_solid()'s minkowski expansion, the final outer dimensions
    // match the requested parameters. The slab and boss extend in -Y to
    // y=0 pre-fillet (no -Y inset); an intersection at y >= 0 then clips
    // off the back-side fillet bulge, leaving the back face perfectly flat
    // with sharp edges to mate flush with the arm tip. All other faces
    // keep their fillets. r=0 collapses to the original geometry.
    r = edge_r;
    assert(plat_t   - 2*r > 0, "edge_r too large: plat_t - 2*edge_r must be > 0");
    assert(lip_t    - 2*r > 0, "edge_r too large: lip_t - 2*edge_r must be > 0");
    assert(plat_w   - 2*r > 0, "edge_r too large: plat_w - 2*edge_r must be > 0");
    assert(plat_boss_w     - 2*r > 0, "edge_r too large: plat_boss_w - 2*edge_r must be > 0");
    assert(plat_boss_depth - r   > 0, "edge_r too large: plat_boss_depth - edge_r must be > 0");
    assert(plat_t + plat_boss_extra_t >= tenon_h_plat + 2*tenon_clearance,
           "back face (plat_t + plat_boss_extra_t) too short to fit the mortise height (tenon_h_plat + 2*clearance)");

    difference() {
        intersection() {
            fillet_solid(r) union() {
                // Main slab — back face at y=0 (clipped flat by the
                // intersection below). Top/bottom inset by r.
                translate([-plat_w/2 + r, 0, -plat_t + r])
                    cube([plat_w - 2*r, plat_depth - r, plat_t - 2*r]);

                // Boss — back face at y=0 (clipped flat). Top joins slab.
                translate([-plat_boss_w/2 + r, 0, -plat_t - plat_boss_extra_t + r])
                    cube([plat_boss_w - 2*r, plat_boss_depth - r, plat_boss_extra_t]);

                // Lip — front strip above slab. Back is internal to slab.
                translate([-plat_w/2 + r, plat_depth - lip_t + r, -r])
                    cube([plat_w - 2*r, lip_t - 2*r, lip_h]);
            }
            // Clip at y >= 0 to flatten the back face with sharp edges.
            translate([-(plat_w + 2*r), 0, -(plat_t + plat_boss_extra_t + 2*r)])
                cube([2*(plat_w + 2*r), plat_depth + 2*r, plat_t + plat_boss_extra_t + lip_h + 4*r]);
        }

        // Mortise pocket on the back face (y = 0), extending in +Y into the boss.
        // Centered at the geometric midpoint of the full back face
        // (slab + boss), so the arm tip face — which is centered on its
        // tenon — lands centered on the platform back face. Equivalent to
        // mortise-drop-from-slab-top = (plat_t + plat_boss_extra_t)/2.
        mortise_z_center = -(plat_t + plat_boss_extra_t) / 2;
        translate([0, 0, mortise_z_center])
            rotate([-90, 0, 0])  // map mortise long axis (+Z) to +Y (into boss)
                mortise_cutout(tenon_h_plat, tenon_w_plat,
                               tenon_l_plat, clearance = tenon_clearance,
                               chamfer = chamfer);

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
