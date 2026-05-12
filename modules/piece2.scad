module piece2_arm() {
    difference() {
        union() {
            // arm body
            cube([arm_total_l, arm_w, arm_h]);

            // ribs
            _rib(side = 0);
            translate([0, arm_w, 0])
                mirror([0, 1, 0])
                    _rib(side = 1);

            // rib root fillets
            _rib_fillet(y_offset = 0,     mirror_y = false);
            _rib_fillet(y_offset = arm_w, mirror_y = true);
        }

        // heat-set insert holes in tenon end faces
        // Wall-side tenon: insert enters from X=0 face (pointing -X)
        translate([0, arm_w/2, arm_h/2])
            rotate([0, 90, 0])
                cylinder(d = insert_m5_od, h = insert_m5_depth + 0.1, $fn = 20);

        // Platform-side tenon: insert enters from X=arm_total_l face (pointing +X)
        translate([arm_total_l, arm_w/2, arm_h/2])
            rotate([0, -90, 0])
                cylinder(d = insert_m5_od, h = insert_m5_depth + 0.1, $fn = 20);
    }
}

// Single triangular rib. Extruded rib_t mm along Y (negative Y direction).
// Triangular profile is in the XZ plane.
module _rib(side) {
    translate([0, -rib_t, arm_h])
        linear_extrude(height = rib_t) {
            polygon([
                [0,           0        ],  // wall end, arm bottom
                [arm_total_l, 0        ],  // platform end, arm bottom
                [0,           rib_depth]   // wall end, rib tip
            ]);
        }
}

// Root fillet at arm-body/rib junction, running the full arm length.
module _rib_fillet(y_offset, mirror_y) {
    r = fillet_rib;
    translate([0, y_offset + (mirror_y ? -r : 0), arm_h])
        rotate([mirror_y ? 180 : 0, 0, 0])
            linear_extrude(height = arm_total_l, convexity = 2)
                rotate([0, 0, 90])
                    difference() {
                        square([r, r]);
                        translate([r, r]) circle(r = r, $fn = 16);
                    }
}

