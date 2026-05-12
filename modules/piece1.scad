module piece1_base(side = "left") {
    sign = (side == "left") ? 1 : -1;

    difference() {
        union() {
            // Main plate body
            cube([base_w, base_h, base_t]);

            // Arm receiver boss
            translate([base_w/2 - boss_w/2, base_h/2 - boss_h/2, base_t])
                cube([boss_w, boss_h, boss1_protrusion]);
        }

        // 4 countersunk wall mounting holes (csink at rear face Z=0)
        translate([base_w/2 - wall_hole_spacing/2, wall_hole_upper_y, base_t + 0.1])
            rotate([180, 0, 0])
                countersunk_hole(wall_hole_d, wall_csink_d, 3, base_t + 0.2);
        translate([base_w/2 + wall_hole_spacing/2, wall_hole_upper_y, base_t + 0.1])
            rotate([180, 0, 0])
                countersunk_hole(wall_hole_d, wall_csink_d, 3, base_t + 0.2);
        translate([base_w/2 - wall_hole_spacing/2, wall_hole_lower_y, base_t + 0.1])
            rotate([180, 0, 0])
                countersunk_hole(wall_hole_d, wall_csink_d, 3, base_t + 0.2);
        translate([base_w/2 + wall_hole_spacing/2, wall_hole_lower_y, base_t + 0.1])
            rotate([180, 0, 0])
                countersunk_hole(wall_hole_d, wall_csink_d, 3, base_t + 0.2);

        // Mortise opening at boss top face, angled by toe_in
        translate([base_w/2, base_h/2, base_t + boss1_protrusion - tenon_l - 0.1])
            rotate([0, 0, sign * toe_in])
                mortise_box(
                    w     = tenon_w + 2 * tenon_clearance,
                    h     = tenon_h + 2 * tenon_clearance,
                    depth = tenon_l
                );

        // M5 axial screw access hole through boss top face
        // Screw passes through boss into tenon end-face insert (piece2)
        translate([base_w/2, base_h/2, base_t + boss1_protrusion + 0.1])
            rotate([180, 0, 0])
                cylinder(d = screw_m5_d, h = boss1_protrusion + tenon_l + 0.2, $fn = 20);
    }
}
