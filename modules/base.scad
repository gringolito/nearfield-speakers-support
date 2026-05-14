// modules/base.scad
// Piece 1 — wall base plate. Universal between L and R.

include <common.scad>;
include <joinery.scad>;

// base_plate(): produces the base oriented for print: wall-facing face
//   at z = 0, front face at z = base_t. Width along X, height along Y.
//   Mortise opens on the front face (+Z) at mid-height. Wall screws
//   pierce the base in the +Z direction.
module base_plate(base_h, base_w, base_t,
                  tenon_h_base, tenon_w_base, tenon_l_base,
                  tenon_clearance,
                  wall_screw_count, wall_screw_spacing,
                  insert_spacing,
                  fillet_r = 0) {

    // The mortise is in the center of the front face at mid-height.
    mortise_center_y = base_h / 2;
    mortise_z_back   = base_t - tenon_l_base;  // bottom of mortise pocket

    difference() {
        // Solid base plate
        translate([0, 0, 0])
            cube([base_w, base_h, base_t]);

        // Mortise pocket on front face
        translate([base_w/2, mortise_center_y, mortise_z_back])
            mortise_cutout(tenon_h_base, tenon_w_base,
                           tenon_l_base, clearance = tenon_clearance,
                           chamfer = fillet_r);

        // 2 wall screw holes (countersunk on the front face)
        wall_screw_y_centers = [
            base_h/2 - wall_screw_spacing/2,
            base_h/2 + wall_screw_spacing/2
        ];
        for (y = wall_screw_y_centers) {
            translate([base_w/2, y, -PRINT_EPSILON])
                cylinder(d = WALL_SCREW_D,
                         h = base_t + 2*PRINT_EPSILON);
            // Counterbore on front face (z = base_t side)
            translate([base_w/2, y, base_t - WALL_SCREW_HEAD_H])
                cylinder(d = WALL_SCREW_HEAD_D,
                         h = WALL_SCREW_HEAD_H + PRINT_EPSILON);
        }

        // 2 lateral clamping screw holes piercing through to the mortise
        // Origin of clamping_screw_hole assumes mortise center.
        translate([base_w/2, mortise_center_y, mortise_z_back])
            clamping_screw_hole(piece_thru = base_w,
                                tenon_z_pos = 0,
                                tenon_l = tenon_l_base,
                                spacing = insert_spacing);
    }
}
