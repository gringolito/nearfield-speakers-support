# Arm-to-Base Boss Retention Design

**Date:** 2026-05-14
**Status:** Implemented
**Branch:** feat/arm-to-base-boss-retention

## Context

Commit `95dea05` ("Passthrough arm-to-base tenon") simplified the base/arm joint to a passthrough tenon and removed the lateral M5 clamping screws that previously locked the arm in place. The result is mechanically incomplete: only press-fit friction holds the arm in the mortise, and the speaker's bending moment about the lateral axis (~5400 N·mm) progressively works the joint loose under vibration. The upper edge of the tenon tries to slip out the front face of the base.

This design reintroduces positive retention without thickening the entire base. A **frontal boss** at the joint carries two M5 cap screws into heat-set inserts in the arm root tenon. The boss is sized to match the arm's root cross-section so it visually reads as a continuation of the arm; the rest of the base stays thin for aesthetics.

Two secondary improvements are bundled in because they touch the same geometry:
1. Switch the base from the `rounded_cube` rounding helper to the `fillet_solid` (minkowski + pre-inset compensation) pattern already used by `platform.scad`, and clip the boss front face flat the same way `platform.scad` clips its back face. This keeps mating surfaces sharp where they meet the arm.
2. Stack the two clamping screws **vertically** (along the wall-mounted vertical axis) rather than along the tenon axis. Vertical spacing forms a moment couple against the bending moment — the actual loading mode of the joint, not just axial pull-out.

## Design

### Boss Geometry (`modules/base.scad`)

The boss is added inside the same `difference()` that produces the slab. Five new module parameters:

```scad
module base_plate(...,
                  boss_w, boss_h, boss_depth,
                  boss_blend_h = 0,
                  ...) {
```

The fillet_solid union now contains three contributions:

1. **Slab** — pre-inset by `r` on every face except the wall face (`z=0`). The wall face is clipped flat by an outer `intersection()` so the base sits flush against the wall.

2. **Boss skirt** — a `hull()` between two thin slabs:
   - Bottom layer at `z = base_t`, footprint expanded by `boss_blend_h` laterally
   - Top layer at `z = base_t + boss_blend_h`, footprint matching the boss
   Provides an explicit chamfered transition from slab to boss main body. Setting `boss_blend_h = 0` collapses the skirt; the minkowski's natural fillet at the boss/slab corner remains.

3. **Boss main body** — pre-inset by `r` only on the lateral faces. The bottom face joins the skirt internally; the top (front) face is **NOT** pre-inset. The intersection clip below trims its post-minkowski bulge to a flat face with sharp edges. The arm root seats against this surface like the platform's back face seats against the arm tip.

The intersection clip box has `z` extent `[0, base_t + boss_depth]`, simultaneously clipping the wall face and the boss front face.

### Lateral Clamping Screws (`modules/base.scad`)

Two M5 clearance holes through the boss, X-aligned cylinders. Spacing is along the **Y axis**, not Z:

```scad
for (dy = [-insert_spacing/2, insert_spacing/2]) {
    translate([base_w/2 - boss_w/2 - PRINT_EPSILON,
               mortise_center_y + dy,
               screw_z_center])
        rotate([0, 90, 0])
            cylinder(d = SCREW_M5_D, h = boss_w + 2*PRINT_EPSILON);
}
```

This makes the existing `clamping_screw_hole()` joinery helper unsuitable for the base joint (it spaces along Z), so the cuts are inlined.

`screw_z_center` is the midpoint of the boss **main body** (not the full boss depth), so the screws clear the skirt:

```scad
screw_z_center = base_t + (boss_depth + boss_blend_h) / 2;
```

Equivalent to `base_t + boss_blend_h + (boss_depth - boss_blend_h) / 2`.

### Heat-set Inserts in the Arm Root Tenon (`modules/arm.scad`)

The arm module gains a `boss_blend_h` parameter and computes the insert position in tenon-local coordinates:

```scad
base_insert_z = (boss_depth - boss_blend_h) / 2;
```

This is the midpoint of the boss main body measured from the arm root face (tenon-local `z=0`). Two insert holes on the tenon's `-X` face, spaced along tenon-local `+Y` by `insert_spacing`. After the existing outer `rotate([90,0,0])`, tenon-local `+Y` maps to world `+Z` — vertical when wall-mounted.

The previous `insert_holes()` joinery helper (which spaces along the tenon's long axis) is replaced with inline cuts at this position.

### World-Space Alignment Math

With the screws at base-local Z = `base_t + (boss_depth + boss_blend_h)/2`, base-local Z maps to world Y after the assembly's `rotate([270,0,0])`. So screws in world Y:

```
Y_screw = base_t + (boss_depth + boss_blend_h) / 2
```

The arm root face is at world `Y = base_t + boss_depth`, and the tenon protrudes in `-Y` from there. Inserts at tenon-local z = `(boss_depth - boss_blend_h)/2` land at world Y:

```
Y_insert = (base_t + boss_depth) - (boss_depth - boss_blend_h) / 2
        = base_t + boss_depth/2 + boss_blend_h/2
        = base_t + (boss_depth + boss_blend_h) / 2
```

`Y_screw == Y_insert`. The screws thread through the boss directly into the inserts.

### Parameters (`nearfield-wall-mount.scad`)

```scad
/* [Base boss] */
boss_w       = 40; // [30:2:50]   match arm_w
boss_h       = 60; // [40:5:70]   match arm_root_h
boss_depth   = 16; // [16:2:28]
boss_blend_h = 4;  // [0:1:8]
```

The base is now rounded by `fillet_solid(edge_r)` (matching platform) instead of `rounded_cube(edge_r)`. The same `edge_r` parameter governs.

`tenon_l_base` is now derived: `base_t + boss_depth`. Removed as an independent parameter.

### Tuned Dimensions

| Parameter | Old | New | Reason |
|---|---|---|---|
| `base_t` | 10 | 6 | Thinner slab, more material concentrated at the boss |
| `tenon_h_base` | 20 | 25 | Larger mortise cross-section for the longer passthrough tenon |
| `tenon_w_base` | 25 | 22 | Companion to above |
| `insert_spacing` | 8 | 10 | Better moment-couple arm with the new vertical layout |
| `boss_depth` | — | 16 | Enough for one screw + 3 mm walls; main body = 12 mm after skirt |
| `boss_blend_h` | — | 4 | Visible chamfered transition without dominating the boss |
| `WALL_SCREW_HEAD_H` (`common.scad`) | 4 | 3 | Matches the thinner slab (counterbore depth) |

### Asserts (`nearfield-wall-mount.scad`)

Catches bad parameter configurations before producing degenerate geometry:

```scad
MIN_BOSS_SCREW_WALL = 3;  // mm

assert(boss_h >= insert_spacing + SCREW_M5_D + 2*MIN_BOSS_SCREW_WALL,
       "boss_h too small to safely host two vertically-stacked lateral screws");

assert(boss_depth - boss_blend_h >= SCREW_M5_D + 2*MIN_BOSS_SCREW_WALL,
       "boss main body too short to host the lateral screw between skirt top and front face");

assert(boss_w >= tenon_w_base + 2*MIN_BOSS_SCREW_WALL,
       "boss_w must be wider than the mortise plus screw-wall margins");

assert(boss_w <= base_w,
       "boss must fit within the base footprint laterally");

assert(boss_h <= base_h - 2*WALL_SCREW_HEAD_D,
       "boss must not overlap the wall screw counterbores");
```

Plus `edge_r` inset asserts inside `base_plate()` itself, mirroring `platform_body()`:

```scad
assert(base_t - r > 0, ...);
assert(base_w - 2*r > 0, ...);
assert(base_h - 2*r > 0, ...);
assert(boss_w - 2*r > 0, ...);
assert(boss_h - 2*r > 0, ...);
assert(boss_w + 2*blend_h <= base_w, ...);
assert(boss_h + 2*blend_h <= base_h, ...);
```

## Mechanical Rationale

- **Bending moment dominates:** Speaker weight × cantilever ≈ 5400 N·mm at the joint. The moment about the lateral X axis rotates the arm forward; top of tenon tries to slip out, bottom presses in.
- **Vertical screw spacing forms a moment couple.** Two screws at the same Z (along the tenon axis) only give redundancy against axial pull-out — they all see the same shear direction. Two screws stacked along Y (vertical when wall-mounted) react in opposite directions and form an actual couple resisting the rotation.
- **Screws in shear, not tension.** Each screw experiences ~180 N of shear against the ~4900 N M5 shear capacity — ≈27× safety factor.
- **Inserts loaded radially, not axially.** The strong direction for both heat-set inserts and FDM layer adhesion (the arm prints on its lateral face, so the insert axis sits in the layer plane).
- **Boss localizes the clamping material.** Tenon engagement grows from 10 mm to `base_t + boss_depth = 22 mm` (≈2.2× shear engagement) while the slab stays thin.

## Verification

1. **Manifold render of all four pieces:** `./scripts/export.sh` produces `stl/{base, arm-right, arm-left, platform}.stl` without errors. All four report `Status: NoError` and a finite genus.

2. **Top-down ortho render of the base:** confirms boss is centered on the slab, chamfered skirt visible around its base, mortise passthrough opens through the wall side, screw exits visible on the lateral faces.

3. **Lateral render of the arm:** the two insert holes on the root tenon's `-X` face are stacked vertically (along the tenon's local Y axis, which becomes world Z when assembled).

4. **Assembly render (`render_piece = 0`):** arm root face sits flush against the boss front face; platform attaches at the arm tip.

5. **Insert/screw alignment (math):** with the defaults, both land at world `Y = 16 mm`. Confirm by reading the spec's "World-Space Alignment Math" section.

6. **Asserts trigger early on bad configs:**
   - `boss_depth=10`: passes (single-screw check) — boss_depth – boss_blend_h = 6 ≥ 11.2 is FALSE, fails on main-body height
   - `boss_depth=14, boss_blend_h=6`: fails on `boss main body too short`
   - `boss_h=15`: fails on `boss_h too small`

7. **CI:** `.github/workflows/ci.yml` renders all four pieces with `--hardwarnings` and validates bounding boxes fit the 225×225 mm print bed.
