module piece3_platform() {
    difference() {
        union() {
            // Arm receiver boss (rear edge, centered in Y)
            translate([0, (platform_w - boss_h) / 2, 0])
                cube([boss_w, boss_h, boss3_protrusion]);

            // Shelf body
            translate([0, 0, boss3_protrusion])
                cube([platform_depth, platform_w, platform_t]);

            // Front safety lip
            translate([platform_depth - lip_t, 0, boss3_protrusion])
                cube([lip_t, platform_w, platform_t + lip_h]);
        }

        // Mortise in boss top face (opens at Z=boss3_protrusion), tilted 12° in XZ plane
        translate([boss_w / 2, platform_w / 2, boss3_protrusion - tenon_l - 0.1])
            rotate([0, tilt, 0])
                mortise_box(
                    w     = tenon_w + 2 * tenon_clearance,
                    h     = tenon_h + 2 * tenon_clearance,
                    depth = tenon_l
                );

        // Axial screw access hole through boss bottom face (Z=0)
        translate([boss_w / 2, platform_w / 2, -0.1])
            rotate([0, -tilt, 0])
                cylinder(d = screw_m5_d, h = boss3_protrusion + tenon_l + 0.2, $fn = 20);
    }
}
