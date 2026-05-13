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
                arm_root_h, arm_tip_h, arm_w, n_samples = 20) {
    for (i = [0 : n_samples - 1]) {
        t1 = i       / n_samples;
        t2 = (i + 1) / n_samples;
        hull() {
            _arm_cross_section(t1, arm_length, toe_in_deg, tilt_deg,
                               arm_root_h, arm_tip_h, arm_w);
            _arm_cross_section(t2, arm_length, toe_in_deg, tilt_deg,
                               arm_root_h, arm_tip_h, arm_w);
        }
    }
}

// Helper: place a thin extruded cross-section at the right position
// and orientation for parameter t.
//
// IMPORTANT — orientation sequence (innermost-out, in execution order):
//   1. `square([arm_w, h])` + `linear_extrude(0.1)` → wafer in XY plane,
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
                          arm_root_h, arm_tip_h, arm_w) {
    pos = arm_centerline_pos(t, arm_length, toe_in_deg, tilt_deg);
    yaw = arm_yaw(t, toe_in_deg);
    pitch = arm_pitch(t, tilt_deg);
    h = arm_cross_section_h(t, arm_root_h, arm_tip_h);

    translate(pos)
        rotate([0, 0, yaw])         // yaw about Z (yaw is already negated)
        rotate([pitch, 0, 0])       // pitch about X
            rotate([90, 0, 0])      // orient wafer in XZ plane (X=arm_w, Z=h, thin in Y)
                linear_extrude(0.1, center = true)
                    square([arm_w, h], center = true);
}

// arm(): full arm with root tenon and tip tenon.
//   The root tenon protrudes in -Y direction from the root face (t=0).
//   The tip tenon protrudes from the tip face (t=1) along the local
//   tangent direction.
module arm(arm_length, toe_in_deg, tilt_deg,
           arm_root_h, arm_tip_h, arm_w,
           tenon_h_base, tenon_w_base, tenon_l_base,
           tenon_h_plat, tenon_w_plat, tenon_l_plat,
           insert_spacing,
           n_samples = 20) {

    union() {
        // Body
        arm_body(arm_length, toe_in_deg, tilt_deg,
                 arm_root_h, arm_tip_h, arm_w, n_samples);

        // Root tenon — protrudes in -Y from origin
        // Build it pre-positioned so it sticks out the back of the arm
        difference() {
            rotate([90, 0, 0])  // orient tenon Z-axis to -Y direction
                tenon(tenon_h_base, tenon_w_base, tenon_l_base);
            // Insert holes in the tenon
            rotate([90, 0, 0])
                insert_holes(tenon_w_base, tenon_l_base,
                             spacing = insert_spacing);
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
                tenon(tenon_h_plat, tenon_w_plat, tenon_l_plat);
                insert_holes(tenon_w_plat, tenon_l_plat,
                             spacing = insert_spacing);
            }
    }
}
