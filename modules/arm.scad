// modules/arm.scad
// Piece 2 — arm with 3D-curved centerline and tenons at both ends.
// Modeled with the root at the origin, root tangent in +Y direction,
// curve bending in +X (toe-in) and -Z (tilt down) as t goes from 0 to 1.
//
// In the assembled bracket, +Y is "forward" (perpendicular to wall),
// +X is lateral (rightward for the right-hand arm), +Z is up.

include <common.scad>;
include <joinery.scad>;

// Centerline position at parameter t in [0, 1].
//   Returns a 3D point. t=0 is the root face, t=1 is the tip face.
function arm_centerline_pos(t, arm_length, toe_in_deg, tilt_deg) =
    let(
        theta_p = toe_in_deg * t,
        theta_s = tilt_deg   * t,
        R_plan  = arm_length / (toe_in_deg * PI / 180),
        R_side  = arm_length / (tilt_deg   * PI / 180)
    ) [
        R_plan * (1 - cos(theta_p)),   // X: plan-view lateral offset
        arm_length * t,                 // Y: linear forward progress
        -R_side * (1 - cos(theta_s))   // Z: side-view downward drop
    ];

// Cross-section height at parameter t (linear taper from root to tip).
function arm_cross_section_h(t, arm_root_h, arm_tip_h) =
    arm_root_h + (arm_tip_h - arm_root_h) * t;

// Yaw angle at parameter t (about the Z axis), expressed as the
// rotate-Z angle that maps the local +Y axis toward +X. Because
// rotate-Z by +θ maps +Y toward -X (standard right-handed convention),
// the angle returned is NEGATIVE so that the wafer's normal direction
// follows the centerline curve into +X as t increases.
function arm_yaw(t, toe_in_deg) = -toe_in_deg * t;

// Pitch angle at parameter t (about the X axis after yaw). Negative
// pitch tilts the local +Y axis downward (toward -Z).
function arm_pitch(t, tilt_deg) = -tilt_deg * t;

// Builds the arm body (no tenons) as a series of hulled segments
// connecting cross-sections sampled along the centerline.
module arm_body(arm_length, toe_in_deg, tilt_deg,
                arm_root_h, arm_tip_h, arm_w, edge_r = 0, n_samples = 20) {
    for (i = [0 : n_samples - 1]) {
        t1 = i       / n_samples;
        t2 = (i + 1) / n_samples;
        hull() {
            _arm_cross_section(t1, arm_length, toe_in_deg, tilt_deg,
                               arm_root_h, arm_tip_h, arm_w, edge_r);
            _arm_cross_section(t2, arm_length, toe_in_deg, tilt_deg,
                               arm_root_h, arm_tip_h, arm_w, edge_r);
        }
    }
}

// _arm_wafer(w, h, r): thin slab in the XY plane, centered at origin,
//   with corners rounded to radius r. Replaces the linear_extrude+square
//   wafer used by _arm_cross_section(). r=0 falls back to the original
//   rectangular wafer. Width along X, height along Y, 0.1 mm thin in Z.
module _arm_wafer(w, h, r) {
    r_ = min(r, w/2, h/2);
    fn_r = max(8, round($fn / 4));
    if (r_ <= 0) {
        linear_extrude(0.1, center = true)
            square([w, h], center = true);
    } else {
        hull() {
            for (xi = [-(w/2 - r_), (w/2 - r_)])
                for (yi = [-(h/2 - r_), (h/2 - r_)])
                    translate([xi, yi, 0])
                        cylinder(r = r_, h = 0.1, center = true, $fn = fn_r);
        }
    }
}

// Helper: place a thin extruded cross-section at the right position
// and orientation for parameter t.
//
// IMPORTANT — orientation sequence (innermost-out, in execution order):
//   1. `_arm_wafer(arm_w, h, edge_r)` → wafer in XY plane,
//      X = lateral, Y = height, Z = thin.
//   2. `rotate([90, 0, 0])` → rotates the wafer into the XZ plane,
//      X = lateral, Z = height, Y = thin (this is the orientation
//      perpendicular to the +Y tangent at the root).
//   3. `rotate([pitch, 0, 0])` → tilts the wafer down (pitch is negative)
//      so the wafer's normal (originally +Y) tilts toward -Z.
//   4. `rotate([0, 0, yaw])` → yaws the wafer in the XY plane. The yaw
//      value is negative (see arm_yaw) so the wafer's normal rotates
//      toward +X (matching the centerline curve).
//   5. `translate(pos)` → places the wafer at the centerline point.
module _arm_cross_section(t, arm_length, toe_in_deg, tilt_deg,
                          arm_root_h, arm_tip_h, arm_w, edge_r = 0) {
    pos = arm_centerline_pos(t, arm_length, toe_in_deg, tilt_deg);
    yaw = arm_yaw(t, toe_in_deg);
    pitch = arm_pitch(t, tilt_deg);
    h = arm_cross_section_h(t, arm_root_h, arm_tip_h);

    translate(pos)
        rotate([0, 0, yaw])         // yaw about Z (yaw is already negated)
        rotate([pitch, 0, 0])       // pitch about X
            rotate([90, 0, 0])      // orient wafer in XZ plane (X=arm_w, Z=h, thin in Y)
                _arm_wafer(arm_w, h, edge_r);
}

// arm(): full arm with root tenon and tip tenon.
//   The root tenon protrudes in -Y direction from the root face (t=0).
//   The tip tenon protrudes from the tip face (t=1) along the local
//   tangent direction.
//   fillet_r = fillet radius passed to tenon() shoulder transition (default 0).
// boss_depth + boss_blend_h together describe the base's frontal boss
// along the tenon's long axis: the boss's chamfered skirt occupies the
// first boss_blend_h of the tenon length (closest to the arm root face),
// and the rectangular boss main body occupies the remaining
// boss_depth - boss_blend_h before the slab. The root-tenon inserts are
// positioned at the midpoint of the boss MAIN BODY (not the midpoint of
// the full boss depth) so they line up exactly with the lateral
// clamping screws in the base, which are centered on the same point.
module arm(arm_length, toe_in_deg, tilt_deg,
           arm_root_h, arm_tip_h, arm_w,
           tenon_h_base, tenon_w_base, tenon_l_base,
           tenon_h_plat, tenon_w_plat, tenon_l_plat,
           insert_spacing,
           boss_depth, boss_blend_h,
           fillet_r = 0,
           edge_r = 0,
           n_samples = 20) {

    // Tenon-local Z of the boss main body midpoint, measured from the
    // arm root face (= tenon-local z=0). The root face mates against the
    // boss front face; the tenon's local +Z axis points away from the
    // arm along the tenon length (into the boss, then through the slab).
    // The boss main body starts at tenon-local z = 0 (boss front) and
    // ends at z = boss_depth - boss_blend_h, so its midpoint is at
    // (boss_depth - boss_blend_h) / 2.
    base_insert_z = (boss_depth - boss_blend_h) / 2;

    union() {
        // Body
        arm_body(arm_length, toe_in_deg, tilt_deg,
                 arm_root_h, arm_tip_h, arm_w, edge_r, n_samples);

        // Root tenon — protrudes in -Y from origin. Two insert holes on
        // the -X face at tenon-local z = base_insert_z (the boss main
        // body's mid-depth in assembled coords), spaced along tenon-local
        // Y by insert_spacing. The outer rotate([90,0,0]) maps tenon-local
        // +Y to world +Z, so the holes end up stacked vertically on the
        // tenon's lateral face — paired with the vertically-spaced screw
        // holes in the base boss.
        rotate([90, 0, 0])  // orient tenon Z-axis to -Y direction
            difference() {
                tenon(tenon_h_base, tenon_w_base, tenon_l_base, fillet = fillet_r);
                for (dy = [-insert_spacing/2, insert_spacing/2]) {
                    translate([-tenon_w_base/2 - PRINT_EPSILON,
                               dy,
                               base_insert_z])
                        rotate([0, 90, 0])
                            cylinder(d = INSERT_M4_OD,
                                     h = INSERT_M4_DEPTH + PRINT_EPSILON);
                }
            }

        // Tip tenon — protrudes from the tip face along the local tangent
        tip_pos   = arm_centerline_pos(1, arm_length, toe_in_deg, tilt_deg);
        tip_yaw   = arm_yaw(1, toe_in_deg);
        tip_pitch = arm_pitch(1, tilt_deg);
        translate(tip_pos)
            rotate([0, 0, tip_yaw])
            rotate([tip_pitch, 0, 0])
            rotate([-90, 0, 0])  // orient tenon to point along +Y (local)
            difference() {
                tenon(tenon_h_plat, tenon_w_plat, tenon_l_plat, fillet = fillet_r);
                insert_holes(tenon_w_plat, tenon_l_plat,
                             spacing = insert_spacing);
            }
    }
}
