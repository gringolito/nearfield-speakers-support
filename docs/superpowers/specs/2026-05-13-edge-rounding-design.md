# Edge Rounding Design

**Date:** 2026-05-13
**Status:** Implemented
**Branch:** feat/edge-rounding

## Context

All external edges and corners of the three printed pieces (base, arm, platform) are currently sharp. Introducing parametric edge rounding improves aesthetics, eliminates stress concentrators that can cause layer delamination under load, and reduces sharp edges on a wall-mounted part. Default radius is 1 mm — visible improvement without compromising dimensional accuracy or print time.

## Design

### Parameters (nearfield-wall-mount.scad)

Three independent parameters replace the single `fillet_r = 0` currently in the `/* [Fillets] */` section:

```scad
/* [Fillets & Chamfers] */
edge_r   = 1.0; // [0:0.5:6]  Outer edge rounding radius (mm)
fillet_r = 1.0; // [0:0.5:6]  Tenon shoulder fillet radius (mm)
chamfer  = 1.0; // [0:0.5:6]  Mortise mouth chamfer depth (mm)
```

Each name matches its geometric operation:
- `edge_r` — radius of spherical rounding on all external piece edges
- `fillet_r` — tangent blend at tenon root (already implemented in `joinery.scad`, variable rename only)
- `chamfer` — linear bevel at mortise entry mouth (already implemented in `joinery.scad`, variable rename only)

Setting any parameter to `0` disables that specific treatment.

### New Utilities (modules/common.scad)

Two modules added:

**`rounded_cube(x, y, z, r, center=false)`** — hull of 8 spheres at the bounding-box corners. Produces true spherical rounding on all 12 edges and 8 vertices of a single cuboid. `center=false` default matches `cube()` — drop-in replacement. Used for single-solid geometry (base plate).

```scad
module rounded_cube(x, y, z, r, center=false) {
    r_ = min(r, x/2, y/2, z/2);
    fn_r = max(8, round($fn / 4));
    translate(center ? [0,0,0] : [x/2, y/2, z/2]) {
        if (r_ <= 0) {
            cube([x, y, z], center=true);
        } else {
            hull() {
                for (xi = [-(x/2 - r_), (x/2 - r_)])
                    for (yi = [-(y/2 - r_), (y/2 - r_)])
                        for (zi = [-(z/2 - r_), (z/2 - r_)])
                            translate([xi, yi, zi])
                                sphere(r=r_, $fn=fn_r);
            }
        }
    }
}
```

**`fillet_solid(r)`** — minkowski sum with a sphere applied to any child geometry via `render()` caching. Correctly handles `union()` of multiple solids: internal junctions stay sharp, only exposed external edges are rounded. Used for multi-solid additive geometry (platform). Outer dimensions grow by `r` in all directions (negligible for 1 mm default).

```scad
module fillet_solid(r) {
    fn_r = max(8, round($fn / 4));
    if (r <= 0) {
        children();
    } else {
        minkowski() {
            render() children();
            sphere(r=r, $fn=fn_r);
        }
    }
}
```

Resolution scales with `$fn / 4`, floor 8 facets.

### Base Piece (modules/base.scad)

Replace each outer additive `cube()` call with `rounded_cube()`. The function signature gains `edge_r` as a parameter. Subtractive operations (wall screw holes, mortise cutout) are unchanged — their mouth edges remain sharp, which is correct for FDM hole geometry.

### Platform Piece (modules/platform.scad)

The platform is a union of three solids (main slab, boss, lip). Rounding each solid individually would create concave artifacts at internal junctions (e.g. where the lip base meets the slab surface). Instead, `fillet_solid(edge_r)` is applied to the entire `union()` — internal junctions stay sharp, only the outer boundary is rounded.

```scad
fillet_solid(edge_r) union() {
    translate([-plat_w/2, 0, -plat_t])
        cube([plat_w, plat_depth, plat_t]);
    translate([-plat_boss_w/2, 0, -plat_t - plat_boss_extra_t])
        cube([plat_boss_w, plat_boss_depth, plat_boss_extra_t]);
    translate([-plat_w/2, plat_depth - lip_t, 0])
        cube([plat_w, lip_t, lip_h]);
}
```

Subtractive operations (mortise, clamping screw holes) applied after — their mouth edges remain sharp.

### Arm Piece (modules/arm.scad)

The arm is built by hulling ~20 thin rectangular wafers along a 3D centerline curve (`_arm_cross_section()`). Strategy: replace each rectangular wafer with a rounded-rectangle wafer (hull of 4 thin cylinders at the corners). Rounding propagates naturally through the consecutive `hull()` operations.

```scad
module _arm_wafer(w, h, r) {
    r_ = min(r, w/2, h/2);
    fn_r = max(8, round($fn / 4));
    if (r_ <= 0) {
        linear_extrude(0.1, center=true) square([w, h], center=true);
    } else {
        hull() {
            for (xi = [-(w/2 - r_), (w/2 - r_)])
                for (yi = [-(h/2 - r_), (h/2 - r_)])
                    translate([xi, yi, 0])
                        cylinder(r=r_, h=0.1, center=true, $fn=fn_r);
        }
    }
}
```

`arm_body()` and `_arm_cross_section()` gain `edge_r` parameters. The existing `n_samples` loop passes `edge_r` to each wafer.

This rounds:
- The 4 longitudinal edges running along the arm's length
- The perimeter of the root face and tip face

No minkowski used for the arm — render time impact is negligible.

### Joinery (modules/joinery.scad)

No structural changes. Only the variable name at call sites in `nearfield-wall-mount.scad` changes:
- `fillet = fillet_r` (already correct)
- `chamfer = chamfer` (replaces `chamfer = fillet_r`)

### Parameter Propagation

All three pieces receive `edge_r` as an explicit parameter from `nearfield-wall-mount.scad`:

```scad
base_plate(... chamfer=chamfer, edge_r=edge_r);
arm(... fillet_r=fillet_r, edge_r=edge_r);
platform_body(... chamfer=chamfer, edge_r=edge_r);
```

## Verification

1. **Preview render** (`$fn=16`): open `nearfield-wall-mount.scad` in OpenSCAD with `render_piece=0` (assembly view). All external edges of all three pieces should appear rounded. Verify no geometry disappears (safety cap `min(r, ...)` prevents collapse on thin features).

2. **Parameter sweep**: set `edge_r=0` — all pieces revert to sharp edges. Set `edge_r=3` — rounding visibly larger on all pieces. No geometry errors expected.

3. **Joint fit**: `tenon()` and `mortise_cutout()` fillet/chamfer unaffected. Run `tests/fit_test.scad` to confirm joint geometry unchanged.

4. **Export**: run `./scripts/export.sh`. All STLs export without manifold errors. Validate with `./scripts/validate-stl.sh`.

5. **Arm continuity**: With `edge_r=1`, the arm body should show smooth rounded edges from root to tip with no ridges at wafer boundaries (same smoothness as current zero-rounding version).
