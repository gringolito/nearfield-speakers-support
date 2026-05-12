module piece2_arm() {
    tenon_y = (arm_w - tenon_w) / 2;   // Y offset to center tenon on body
    tenon_z = (arm_h - tenon_h) / 2;   // Z offset to center tenon on body

    difference() {
        union() {
            // Central arm body (arm_length, full cross-section)
            translate([tenon_l, 0, 0])
                cube([arm_length, arm_w, arm_h]);

            // Wall-side tenon stub (centered on body end face)
            translate([0, tenon_y, tenon_z])
                cube([tenon_l, tenon_w, tenon_h]);

            // Platform-side tenon stub (centered on body end face)
            translate([arm_total_l - tenon_l, tenon_y, tenon_z])
                cube([tenon_l, tenon_w, tenon_h]);

            // Ribs: body region only (X = tenon_l .. arm_total_l - tenon_l)
            translate([tenon_l, 0, 0]) _rib();
            translate([tenon_l, arm_w, 0])
                mirror([0, 1, 0])
                    _rib();

            // Rib root fillets: body region only
            translate([tenon_l, 0, 0]) _rib_fillet(y_offset = 0,     mirror_y = false);
            translate([tenon_l, 0, 0]) _rib_fillet(y_offset = arm_w, mirror_y = true);
        }

        // Wall-side tenon insert hole (enters from X=0 face)
        translate([-0.1, arm_w/2, arm_h/2])
            rotate([0, 90, 0])
                cylinder(d = insert_m5_od, h = insert_m5_depth + 0.2, $fn = 20);

        // Platform-side tenon insert hole (enters from X=arm_total_l face)
        translate([arm_total_l + 0.1, arm_w/2, arm_h/2])
            rotate([0, -90, 0])
                cylinder(d = insert_m5_od, h = insert_m5_depth + 0.2, $fn = 20);
    }
}

// Triangular rib: profile in XZ plane, rib_t thick in -Y.
// Spans arm_length; wall end full rib_depth, platform end tapers to 0.
// Call with translate([tenon_l, 0, 0]) to position on body.
module _rib() {
    translate([0, 0, arm_h])
        rotate([90, 0, 0])
            linear_extrude(height = rib_t, convexity = 2)
                polygon([
                    [0,           0        ],
                    [arm_length,  0        ],
                    [0,           rib_depth]
                ]);
}

// Quarter-cylinder fillet at arm-body/rib junction, spanning arm_length.
// Call with translate([tenon_l, 0, 0]) to position on body.
module _rib_fillet(y_offset, mirror_y) {
    r = fillet_rib;
    translate([0, y_offset, arm_h])
        translate([arm_length, 0, 0])
            rotate([0, -90, 0]) {
                if (!mirror_y)
                    mirror([0, 1, 0]) fillet_rod(r, arm_length);
                else
                    fillet_rod(r, arm_length);
            }
}
