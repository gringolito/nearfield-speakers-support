# Handed Base and Platform — Design

**Date:** 2026-05-14
**Status:** Approved, ready for plan
**Scope:** Make `base_plate()` and `platform_body()` handed (canonically right, mirrored for left) so their clamping-screw geometry matches the arms, which already have inserts only on the −X face of each tenon.

## Problem

The arms have heat-set inserts only on the **−X face** of both the root tenon ([arm.scad:154](../../../modules/arm.scad#L154)) and the tip tenon (via `insert_holes` in [joinery.scad:79](../../../modules/joinery.scad#L79)). The left arm is produced at the top level by `mirror([1,0,0]) arm_module()` ([nearfield-wall-mount.scad:204](../../../nearfield-wall-mount.scad#L204)).

The base and platform, however, currently drill **passthrough** clamping-screw holes that exit on both lateral faces of their bosses:

- `base.scad:141-148` — cylinder of length `boss_w + 2*PRINT_EPSILON` along X.
- `platform.scad:93-98` — `clamping_screw_hole(piece_thru = plat_boss_w, …)` produces the same passthrough behaviour from `joinery.scad:91-100`.

Visually this leaves a "ghost" hole on the side opposite the screw with no function. It is aesthetically wrong and was a source of confusion for the user when reasoning about the assembly.

## Goals

1. The clamping-screw holes only break out on **one** face of the boss — the same external face on which the matching arm tenon's inserts live.
2. Aesthetic improvement on the visible (entry) face: shallow cosmetic counterbore so the SHCS head is partially recessed.
3. Mirror the existing handed-arm convention: canonical geometry is the right-hand piece; the left-hand piece is produced by `mirror([1,0,0])` in the top-level dispatch.

## Non-goals

- No change to the slab outline, mortise position, wall-screw layout, or boss footprint.
- No change to `base_plate()` / `platform_body()` parameter signatures.
- No change to fastener type (still M5 SHCS), no countersunk (countersunk would wedge against boss walls and risk delamination on a 3D-printed part).
- No move of the boss off the slab centerline. Slab remains laterally symmetric; only the screw geometry on the boss becomes asymmetric.

## Design

### Hand convention

Canonical geometry is the **right-hand** bracket. The screw counterbores live on the **−X** face of the boss in the canonical orientation. `mirror([1,0,0])` at the dispatch level produces the left-hand piece, putting the counterbore on +X. This matches `arm()`'s existing convention.

### New screw-hole geometry

Each clamping screw is now composed of three coaxial features along the local X axis, all entering from the −X face of the boss:

1. **Counterbore** (cosmetic recess for the SHCS head)
   - Diameter: `SCREW_M5_HEAD_D` (8.8 mm, already in `common.scad`).
   - Depth: `SCREW_M5_COUNTERBORE_DEPTH` (new, 2.0 mm). The M5 SHCS head is 5 mm tall, so ~3 mm of head sits proud — partial recess, intentional, not flush.
2. **Shank clearance**
   - Diameter: `SCREW_M5_D` (5.2 mm).
   - Extent: from the bottom of the counterbore (`x = -piece_thru/2 + counterbore_h`) up to `x = piece_thru/2 - far_wall`, where `far_wall = MIN_BOSS_SCREW_WALL` (3 mm). Crosses the mortise pocket internally without issue (mortise is subtracted separately).
3. **Far wall**: solid. No hole on the +X face.

The +X face is now intact in the canonical (right) piece, preserving `MIN_BOSS_SCREW_WALL` mm of plastic.

### `clamping_screw_hole` signature change

In `joinery.scad`:

```scad
module clamping_screw_hole(piece_thru, tenon_z_pos = 0, tenon_l = 17,
                           spacing       = 10,
                           screw_d       = SCREW_M5_D,
                           counterbore_d = 0,           // 0 = no counterbore (default)
                           counterbore_h = 0,
                           far_wall      = 0)           // 0 = passthrough (default)
```

- Defaults preserve the current passthrough behaviour. No existing caller breaks.
- When `counterbore_d > 0`, a cylinder of diameter `counterbore_d` and length `counterbore_h` is subtracted from the −X face, coaxial with the shank.
- When `far_wall > 0`, the shank cylinder is shortened to leave `far_wall` mm of solid plastic on the +X face: `shank_length = piece_thru - far_wall + PRINT_EPSILON`.

### `base_plate()` change

Today `base.scad:141-148` builds the screw holes inline with a `for (dy = …)` loop, duplicating the geometry that `clamping_screw_hole` produces. As part of this change the inline loop is **replaced by a single call to `clamping_screw_hole`** for symmetry with `platform.scad`. The base will pass the new counterbore + far-wall parameters.

The module's parameter signature does **not** change.

### `platform_body()` change

The existing call in `platform.scad:93-98` gains the three new parameters (`counterbore_d`, `counterbore_h`, `far_wall`).

The module's parameter signature does **not** change.

### Constants moved / added in `common.scad`

```scad
SCREW_M5_COUNTERBORE_DEPTH = 2.0;   // cosmetic counterbore depth (M5 SHCS, partial recess)
MIN_BOSS_SCREW_WALL        = 3.0;   // moved from nearfield-wall-mount.scad
```

`MIN_BOSS_SCREW_WALL` is moved up so `joinery.scad` and the asserts in `nearfield-wall-mount.scad` can both reference the same constant. The top-level asserts that already use it (lines 98, 103) keep working unchanged.

### New top-level asserts in `nearfield-wall-mount.scad`

```scad
assert(boss_w >= SCREW_M5_HEAD_D + MIN_BOSS_SCREW_WALL,
       "boss_w too small for counterbore mouth + far-side wall");
assert(plat_boss_w >= SCREW_M5_HEAD_D + MIN_BOSS_SCREW_WALL,
       "plat_boss_w too small for counterbore mouth + far-side wall");
```

With current defaults (`boss_w = plat_boss_w = arm_w = 40`, threshold = 11.8) both pass.

### Dispatch rewrite in `nearfield-wall-mount.scad`

Render piece menu expands from 5 entries to 7. The numbering is regrouped by piece (base, arm, platform) so future additions stay clean:

```scad
// 0 = assembly preview
// 1 = base-right          2 = base-left
// 3 = arm-right           4 = arm-left
// 5 = platform-right      6 = platform-left
render_piece = 0; // [0:assembly, 1:base-right, 2:base-left, 3:arm-right, 4:arm-left, 5:platform-right, 6:platform-left]

if      (render_piece == 0) assembly_preview();
else if (render_piece == 1) base_module();
else if (render_piece == 2) mirror([1,0,0]) base_module();
else if (render_piece == 3) arm_module();
else if (render_piece == 4) mirror([1,0,0]) arm_module();
else if (render_piece == 5) platform_module();
else if (render_piece == 6) mirror([1,0,0]) platform_module();
else assert(false, str("unknown render_piece: ", render_piece));
```

**Index change is breaking** for any external tool that maps render_piece integers to STL filenames. CI render generation and `scripts/` must be updated in lockstep.

### `assembly_preview()`

No code change. The preview already renders the right-hand bracket (canonical orientation). Visually the only difference is that the base and platform bosses will now show a solid +X face instead of the ghost hole — exactly the goal.

## Files touched

| File | Change |
| --- | --- |
| `modules/common.scad` | Add `SCREW_M5_COUNTERBORE_DEPTH`; move `MIN_BOSS_SCREW_WALL` from top-level |
| `modules/joinery.scad` | Extend `clamping_screw_hole` with `counterbore_d`, `counterbore_h`, `far_wall` params (defaults preserve current behaviour) |
| `modules/base.scad` | Replace inline `for (dy = …)` screw-hole loop with a single `clamping_screw_hole(...)` call passing the new params |
| `modules/platform.scad` | Pass the new params on the existing `clamping_screw_hole` call |
| `nearfield-wall-mount.scad` | 2 new asserts; rewrite dispatch for 6 piece options; update Customizer comment block |
| `scripts/` | Update STL export pipeline (if it iterates `render_piece`) to produce 6 piece STLs with new names (`base-right.stl`, `base-left.stl`, `platform-right.stl`, `platform-left.stl`, `arm-right.stl`, `arm-left.stl`). Verify during planning. |
| `docs/` renders | Update CI rendered-images pipeline to emit the 6 piece renders + assembly. Verify during planning. |
| `tests/` | Add coverage for: counterbore present on −X face only; +X face solid (no breakthrough); mirrored versions produce the flipped geometry. Verify existing test layout during planning. |

## Acceptance criteria

1. `render_piece = 1` (base-right) produces a base whose boss has the counterbore + clearance hole on its −X face, and a solid +X face with at least 3 mm of plastic.
2. `render_piece = 2` (base-left) is the mirror of (1).
3. Same for plate-right / plate-left (`render_piece = 5` / `6`).
4. Each clamping screw seats with its SHCS head partially recessed (~2 mm sunk, ~3 mm proud) into the counterbore.
5. The right-hand assembly preview (`render_piece = 0`) shows no ghost holes on either boss.
6. Top-level asserts still pass with the default parameter set.
7. Arm geometry is untouched. With the new numbering, `render_piece = 3` produces the same `arm-right` STL that `render_piece = 2` produced before; `render_piece = 4` matches the prior `render_piece = 3`.

## Risks and notes

- **CI render pipeline drift.** If the rendered-images CI workflow hardcodes filenames or the integer range `[1..4]`, it will break. Plan must include the workflow update.
- **STL filename change for the base and platform.** Anyone downloading prebuilt STLs gets new names (`base-right.stl` instead of `base.stl`). Acceptable — first-time release of the handed pieces, no users to break.
- **Far-wall thickness assumption.** `MIN_BOSS_SCREW_WALL = 3 mm` was originally sized for "wall of plastic around the screw on each free face" of the passthrough hole. Reusing it for the now-blind far face is conservative — the far wall is no longer pierced, so 3 mm is plenty.
- **`tenon_z_pos` semantics in `base_plate`.** Today the base computes `screw_z_center` directly and uses an inline loop, sidestepping `tenon_z_pos`. Switching to `clamping_screw_hole` requires translating `screw_z_center` into the (`tenon_z_pos`, `tenon_l`) convention the module expects. The plan must verify the translated values produce screw positions byte-identical to the current ones (down to floating-point round-off — a regression test should catch any drift).
