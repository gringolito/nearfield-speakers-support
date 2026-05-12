include <../nearfield-wall-mount.scad>

gap = 2;

// Arm tenon (from piece2 wall-side end) — solid cube
color("Coral")
translate([-tenon_w/2, -tenon_h/2, 0])
    cube([tenon_w, tenon_h, tenon_l]);

// Mortise cavity (from piece1 boss) — shown as solid for size comparison
color("SteelBlue", 0.5)
translate([-(tenon_w + 2*tenon_clearance)/2, -(tenon_h + 2*tenon_clearance)/2, tenon_l + gap])
    cube([
        tenon_w + 2 * tenon_clearance,
        tenon_h + 2 * tenon_clearance,
        tenon_l
    ]);

echo("Tenon:", tenon_w, "x", tenon_h, "x", tenon_l, "mm");
echo("Mortise:", tenon_w + 2*tenon_clearance, "x", tenon_h + 2*tenon_clearance, "mm");
echo("Per-side clearance:", tenon_clearance, "mm");
