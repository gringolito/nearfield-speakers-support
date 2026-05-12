module piece2_arm() {
    difference() {
        union() {
            // arm body
            cube([arm_total_l, arm_w, arm_h]);

            // Y=0 rib: extends from Y=−rib_t to Y=0, Z=arm_h to arm_h+rib_depth
            _rib();
            // Y=arm_w rib: mirror of Y=0 rib
            translate([0, arm_w, 0])
                mirror([0, 1, 0])
                    _rib();

            // rib root fillets
            _rib_fillet(y_offset = 0,     mirror_y = false);
            _rib_fillet(y_offset = arm_w, mirror_y = true);
        }

        // Wall-side tenon insert hole (X=0 face, +0.1 epsilon past face)
        translate([-0.1, arm_w/2, arm_h/2])
            rotate([0, 90, 0])
                cylinder(d = insert_m5_od, h = insert_m5_depth + 0.2, $fn = 20);

        // Platform-side tenon insert hole (X=arm_total_l face, +0.1 epsilon)
        translate([arm_total_l + 0.1, arm_w/2, arm_h/2])
            rotate([0, -90, 0])
                cylinder(d = insert_m5_od, h = insert_m5_depth + 0.2, $fn = 20);
    }
}

// Triangular rib: profile in XZ plane, rib_t thick in -Y.
// Wall end (X=0): full rib_depth; platform end (X=arm_total_l): tapers to 0.
module _rib() {
    translate([0, 0, arm_h])
        rotate([90, 0, 0])
            linear_extrude(height = rib_t, convexity = 2)
                polygon([
                    [0,           0        ],
                    [arm_total_l, 0        ],
                    [0,           rib_depth]
                ]);
}

// Quarter-cylinder fillet at arm-body/rib junction, running the full arm length.
module _rib_fillet(y_offset, mirror_y) {
    r = fillet_rib;
    translate([0, y_offset, arm_h])
        translate([arm_total_l, 0, 0])
            rotate([0, -90, 0]) {
                if (!mirror_y)
                    mirror([0, 1, 0]) fillet_rod(r, arm_total_l);
                else
                    fillet_rod(r, arm_total_l);
            }
}
