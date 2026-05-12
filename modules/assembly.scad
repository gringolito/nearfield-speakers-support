// Assembly preview — installed orientation, for visual sanity-check.
// All parameters and includes live in nearfield-wall-mount.scad.

module assembly_preview() {

    // ── Piece 1: Wall base plate (SteelBlue) ─────────────────────────────
    // Print orientation: X=width(80), Y=height(160), Z=thickness(10)+boss(20).
    // Rear face at Z=0 (print) → Y=0 in installed (against the wall).
    // rotate([90,0,0]) maps (x,y,z) → (x, z, -y):
    //   plate height Y=160 → new_Z = -160..0  → lifted +base_h → Z=0..160 ✓
    //   plate thickness Z=10 → new_Y = 0..10 (away from wall) ✓
    color("SteelBlue", 0.9)
    translate([0, 0, base_h])
        rotate([90, 0, 0])
            piece1_base("left");

    // ── Piece 2: Arm (Coral) ─────────────────────────────────────────────
    // Print orientation: length along X(108), width along Y(35), height along Z(30).
    // Ribs extend from Z=arm_h upward in print (away from bed top face).
    // Installed: arm runs along +Y, top face up, ribs hang below (−Z).
    //
    // Transform (applied innermost-first in OpenSCAD):
    //   1. rotate([180,0,0]): flip upside-down → ribs now at negative Z, top face at -Z=0
    //      body:  X=0..108, Y=0..-35, Z=0..-30
    //      ribs:  Z < -30 (rib_depth below)
    //   2. rotate([0,0,90]): spin so length runs along +Y
    //      new_X=-y, new_Y=x, new_Z=z
    //      body:  new_X=0..35, new_Y=0..108, new_Z=0..-30
    //      ribs:  new_Z < -30
    //   3. translate([x, y, arm_h]): position in installed space
    //      lift by arm_h so body occupies Z=0..arm_h, ribs hang below Z=0.
    //
    // X: centered on plate → base_w/2 - arm_w/2 = 22.5
    // Y: starts after plate front + boss = base_t + boss1_protrusion = 30
    color("Coral", 0.9)
    translate([base_w/2 - arm_w/2, base_t + boss1_protrusion, arm_h])
        rotate([0, 0, 90])
            rotate([180, 0, 0])
                piece2_arm();

    // ── Piece 3: Speaker platform (MediumSeaGreen) ───────────────────────
    // Print orientation: depth along X(200), width along Y(135), boss at X=0.
    //   boss: X=0..44, Y=(135-34)/2..(135+34)/2, Z=0..24
    //   shelf: Z=24..30, lip at X=194..200
    // Installed: depth runs along +Y (from wall outward), width along X.
    //
    // Transform:
    //   rotate([0,0,90]): (x,y,z) → (-y, x, z)
    //     depth X=0..200 → new_Y=0..200 (runs from wall outward) ✓
    //     width Y=0..135 → new_X=0..-135 (needs X translation)
    //     Z stays: boss at Z=0..24, shelf at Z=24..30 ✓
    //
    // X: after rotation piece occupies new_X=-135..0; shift by +platform_w/2 + base_w/2
    //    = 67.5 + 40 = 107.5  → piece at X=-27.5..107.5, center=40=base_w/2 ✓
    // Y: boss (print X=0) maps to new_Y=0; arm platform face is at
    //    base_t + boss1_protrusion + arm_total_l = 10+20+108 = 138 → translate Y=138
    // Z: boss3_protrusion connects underside of shelf to arm top face (arm_h=30);
    //    shelf top = arm_h + platform_t = 36 — place boss bottom at arm_h − boss3_protrusion
    //    = 30 - 24 = 6. Translate Z = arm_h - boss3_protrusion.
    color("MediumSeaGreen", 0.9)
    translate([
        base_w/2 + platform_w/2,
        base_t + boss1_protrusion + arm_total_l,
        arm_h - boss3_protrusion
    ])
        rotate([0, 0, 90])
            piece3_platform();

}
