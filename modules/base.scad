// modules/base.scad
// Piece 1 — wall base plate. Universal between L and R.

include <common.scad>;
include <joinery.scad>;

// base_plate(): produces the base oriented for print: wall-facing face
//   at z = 0, front face at z = base_t. Width along X, height along Y.
//   A boss protrudes from the front face (+Z) in the joint region. The
//   mortise is passthrough, spanning the full base+boss stack. Wall
//   screws pierce the base in the +Z direction. Two clamping screws
//   pierce the boss laterally (along X) and engage heat-set inserts on
//   the -X face of the arm tenon. The two clamping screws are spaced
//   along Y (vertical when wall-mounted), forming a moment couple that
//   resists the bending moment from the speaker load.
//
//   Geometry is rounded by fillet_solid (minkowski with sphere of
//   radius edge_r), pre-insetting each face by r so post-minkowski
//   dimensions match the requested parameters — the same pattern used
//   in modules/platform.scad. TWO faces are intentionally clipped flat
//   with sharp edges by the intersection at the end:
//     • z = 0 (wall face) — sits flush against the wall
//     • z = base_t + boss_depth (boss front face) — mates flush
//       against the arm root, just like the platform's back face mates
//       flush against the arm tip.
//   An explicit chamfered skirt of height boss_blend_h provides a
//   visible tapered transition between the slab top and the boss main
//   body. Setting boss_blend_h = 0 collapses the skirt and leaves only
//   the minkowski's natural fillet at the boss/slab junction.
module base_plate(base_h, base_w, base_t,
                  tenon_h_base, tenon_w_base, tenon_l_base,
                  tenon_clearance,
                  wall_screw_count, wall_screw_spacing,
                  insert_spacing,
                  boss_w, boss_h, boss_depth,
                  boss_blend_h = 0,
                  chamfer = 0,
                  edge_r = 0) {

    mortise_center_y = base_h / 2;

    r = edge_r;
    // Safety clamp: skirt cannot exceed half the boss depth.
    blend_h = min(boss_blend_h, boss_depth / 2);

    // Centerline of the lateral clamping screws — at the midpoint of the
    // boss main body (the vertical-walled section above the chamfered
    // skirt), NOT the midpoint of the full boss_depth. This keeps both
    // screws clear of the skirt's tapered region by symmetric margins.
    screw_z_center = base_t + (boss_depth + blend_h) / 2;

    assert(base_t - r > 0,    "edge_r too large: base_t - edge_r must be > 0");
    assert(base_w - 2*r > 0,  "edge_r too large: base_w - 2*edge_r must be > 0");
    assert(base_h - 2*r > 0,  "edge_r too large: base_h - 2*edge_r must be > 0");
    assert(boss_w - 2*r > 0,  "edge_r too large: boss_w - 2*edge_r must be > 0");
    assert(boss_h - 2*r > 0,  "edge_r too large: boss_h - 2*edge_r must be > 0");
    assert(boss_w + 2*blend_h <= base_w,
           "boss + skirt expansion exceeds base width");
    assert(boss_h + 2*blend_h <= base_h,
           "boss + skirt expansion exceeds base height");

    difference() {
        intersection() {
            fillet_solid(r) union() {
                // Slab — wall face (z=0) NOT inset (clipped flat by the
                // intersection below). All other faces inset by r.
                translate([r, r, 0])
                    cube([base_w - 2*r, base_h - 2*r, base_t - r]);

                // Boss skirt — explicit chamfered transition from slab
                // top (expanded footprint = boss + 2*blend_h) up to the
                // nominal boss footprint at z = base_t + blend_h. Built
                // as a hull between two thin slabs. Outer perimeters
                // inset by r so post-minkowski dimensions match.
                if (blend_h > 0) {
                    hull() {
                        translate([base_w/2 - boss_w/2 - blend_h + r,
                                   mortise_center_y - boss_h/2 - blend_h + r,
                                   base_t])
                            cube([boss_w + 2*blend_h - 2*r,
                                  boss_h + 2*blend_h - 2*r,
                                  PRINT_EPSILON]);
                        translate([base_w/2 - boss_w/2 + r,
                                   mortise_center_y - boss_h/2 + r,
                                   base_t + blend_h])
                            cube([boss_w - 2*r,
                                  boss_h - 2*r,
                                  PRINT_EPSILON]);
                    }
                }

                // Boss main body — sides inset by r so post-minkowski
                // width/height match. Bottom face joins the skirt (or
                // slab when blend_h=0) internally — no inset there. Top
                // (front) face NOT inset either; the intersection clip
                // below trims its fillet bulge to a flat face with sharp
                // edges so the arm root face seats against it cleanly
                // (no minkowski curvature at the joint mating surface).
                translate([base_w/2 - boss_w/2 + r,
                           mortise_center_y - boss_h/2 + r,
                           base_t + blend_h])
                    cube([boss_w - 2*r,
                          boss_h - 2*r,
                          boss_depth - blend_h]);
            }
            // Clip box: z extent [0, base_t + boss_depth]. Trims the
            // fillet bulge on BOTH the wall face (z=0) and the boss
            // front face (z=base_t + boss_depth), leaving flat mating
            // surfaces with sharp perimeter edges.
            translate([-r, -r, 0])
                cube([base_w + 2*r,
                      base_h + 2*r,
                      base_t + boss_depth]);
        }

        // Mortise pocket: passthrough through slab + skirt + boss.
        // tenon_l_base == base_t + boss_depth (asserted at top level).
        translate([base_w/2, mortise_center_y, 0])
            mortise_cutout(tenon_h_base, tenon_w_base,
                           tenon_l_base, clearance = tenon_clearance,
                           chamfer = chamfer);

        // Wall screw holes (countersunk on the front-of-slab face).
        wall_screw_y_centers = [
            base_h/2 - wall_screw_spacing/2,
            base_h/2 + wall_screw_spacing/2
        ];
        for (y = wall_screw_y_centers) {
            translate([base_w/2, y, -PRINT_EPSILON])
                cylinder(d = WALL_SCREW_D,
                         h = base_t + 2*PRINT_EPSILON);
            translate([base_w/2, y, base_t - WALL_SCREW_HEAD_H])
                cylinder(d = WALL_SCREW_HEAD_D,
                         h = WALL_SCREW_HEAD_H + PRINT_EPSILON);
        }

        // Lateral clamping screw holes through the boss. Two holes stacked
        // along Y (vertical when wall-mounted) at the boss's mid-depth Z
        // (= screw_z_center, the midpoint of the boss main body above the
        // chamfered skirt). The rotate([-90, 0, 0]) maps the helper's
        // local +Z (spacing axis) onto world +Y.
        //
        // shank_length is the thickness of the near (-X) boss wall up to
        // the mortise pocket — the screw only needs clearance through this
        // wall, then crosses the mortise cavity (already air) and engages
        // the insert in the arm tenon. The far (+X) boss wall stays solid.
        near_wall_t = (boss_w - tenon_w_base) / 2 - tenon_clearance;
        translate([base_w/2, mortise_center_y, screw_z_center])
            rotate([-90, 0, 0])
                clamping_screw_hole(piece_thru    = boss_w,
                                    spacing       = insert_spacing,
                                    counterbore_d = SCREW_M5_HEAD_D,
                                    counterbore_h = SCREW_M5_COUNTERBORE_DEPTH,
                                    shank_length  = near_wall_t);
   }
}
