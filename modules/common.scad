// Shared utility modules

// Rounded box with radius r on all edges and corners.
// size = [width, depth, height] — these are the OUTER dimensions.
module rounded_box(size, r, fn = 16) {
    assert(r <= size[0]/2 && r <= size[1]/2 && r <= size[2]/2,
           "rounded_box: r must be <= half of each dimension");
    minkowski() {
        cube([size[0] - 2*r, size[1] - 2*r, size[2] - 2*r]);
        sphere(r = r, $fn = fn);
    }
}

// Quarter-cylinder fillet. Place at the root of a rib.
// r = fillet radius, h = extrusion length along the rib axis.
// Occupies the positive X, positive Y quadrant — translate as needed.
module fillet_rod(r, h, fn = 16) {
    difference() {
        cube([r, r, h]);
        translate([r, r, -0.1])
            cylinder(r = r, h = h + 0.2, $fn = fn);
    }
}

// Through-hole with countersink for a flat-head screw.
// d = shaft diameter, csink_d = countersink diameter,
// csink_h = countersink depth, total_h = total hole depth.
// Aligned along Z, centered in XY.
module countersunk_hole(d, csink_d, csink_h, total_h, fn = 20) {
    union() {
        cylinder(d = d, h = total_h + 0.1, $fn = fn);
        translate([0, 0, total_h - csink_h])
            cylinder(d1 = d, d2 = csink_d, h = csink_h + 0.1, $fn = fn);
    }
}

// Rectangular mortise cavity (clearance already included in w/h).
// w = mortise width, h = mortise height, depth = mortise depth.
// angle_h = rotation in horizontal plane (toe-in), angle_v = rotation in
// vertical plane (tilt). Center in XY, open toward +Z.
module mortise_box(w, h, depth, angle_h = 0, angle_v = 0) {
    rotate([0, 0, angle_h])
        rotate([angle_v, 0, 0])
            translate([-w/2, -h/2, 0])
                cube([w, h, depth + 0.1]);
}
