# Nearfield Speaker Wall Mount

[![CI](https://github.com/gringolito/nearfield-speakers-support/actions/workflows/ci.yml/badge.svg)](https://github.com/gringolito/nearfield-speakers-support/actions/workflows/ci.yml)
[![License: CC BY-SA 4.0](https://img.shields.io/badge/License-CC%20BY--SA%204.0-lightgrey.svg)](https://creativecommons.org/licenses/by-sa/4.0/)

3D-printable parametric wall brackets for nearfield bookshelf speakers. Acoustic angles are built into the structure — no articulating joints, no wobble, no drift.

![Assembly preview](https://raw.githubusercontent.com/gringolito/nearfield-speakers-support/ci-renders/latest/assembly.png)

---

## The story

I needed to mount a pair of bookshelf speakers above my monitors for nearfield desktop listening. Every off-the-shelf bracket I found used articulating arms or ball joints — exactly the mechanism I didn't want. Articulating joints accumulate micro-movement under vibration and gradually drift out of alignment. Tighten them hard enough to prevent that and the adjustment becomes difficult to reproduce.

The two acoustic angles that matter are **toe-in** (horizontal rotation toward the listening position) and **tilt** (downward angle to aim the tweeter at ear height). Getting these exactly right is a one-time calibration — after that, nothing should ever move.

This bracket encodes both angles structurally. All angular complexity lives in the 3D-curved arm body. The base plate has only perpendicular features. The platform is a flat slab. Both join the arm via perpendicular tenon-mortise interfaces. Each joint is a guided tenon locked with two M5 screws: the tenon handles shear by geometry, the screws only provide clamping force. On the base side the mortise passes all the way through a frontal boss whose footprint matches the arm root — the boss localises the clamp material to the joint so the rest of the base can stay thin.

The three-piece split exists because a single-piece bracket for this geometry would not fit on a 225 × 225 mm print bed. The split is also a feature: to try different toe-in or tilt angles you reprint only the arm. All three pieces are handed (right/left), so a pair of speakers needs six STL files in total.

Everything prints without supports, flat-side-down.

---

## Pieces

The bracket is three separate printed pieces per speaker:

| Piece | Function | Print footprint |
|---|---|---|
| Base (P1) | Mounts to wall; thin slab with a frontal boss carrying the mortise + 2 wall screw holes. Right/left versions; clamping screws enter the inboard face only. | 90 × 140 × 22 mm (incl. boss) |
| Arm (P2) | Structural cantilever encoding both toe-in (26°) and tilt (12°) in its 3D-curved body. Right/left versions, mirrored about the bracket's long axis. | ~50 × 91 × 60 mm |
| Platform (P3) | Supports the speaker; flat slab with rear boss for joint + front lip. Right/left versions; clamping screws enter the inboard face only. | 130 × 200 × 43 mm |

```text
WALL                                                                  FRONT
 │
 │  ┌──────────┐     ╭──────╮                       ┌───────────────────┬──┐
 │  │   BASE   │◄────┤ ARM  ├──────tangent at 26°───┤    PLATFORM       │ ▲│
 │  │  90×140  │ M5  │ curve│  curves down 12°      │    200 × 130      │  │
 │  │   L/R    │     │ L/R  │                       │       L/R         │  │
 │  └──────────┘     ╰──────╯                       └───────────────────┴──┘
 │  vertical pair                                                       lip
 │  of M6 screws
```

The full pair (two speakers) uses six STL files — a right-hand and a left-hand version of each piece, mirrored about the bracket's long axis:

| File | Description |
|---|---|
| `base-right.stl` | Right-hand wall base plate (counterbore on the inboard face) |
| `base-left.stl` | Left-hand wall base plate (mirrored) |
| `arm-right.stl` | Right-hand arm (toe-in curves toward listener) |
| `arm-left.stl` | Left-hand arm (mirrored) |
| `platform-right.stl` | Right-hand platform (counterbore on the inboard face) |
| `platform-left.stl` | Left-hand platform (mirrored) |

| Base Right | Base Left | Arm Right | Arm Left | Platform Right | Platform Left |
|---|---|---|---|---|---|
| ![Base Right](https://raw.githubusercontent.com/gringolito/nearfield-speakers-support/ci-renders/latest/base-right.png) | ![Base Left](https://raw.githubusercontent.com/gringolito/nearfield-speakers-support/ci-renders/latest/base-left.png) | ![Arm Right](https://raw.githubusercontent.com/gringolito/nearfield-speakers-support/ci-renders/latest/arm-right.png) | ![Arm Left](https://raw.githubusercontent.com/gringolito/nearfield-speakers-support/ci-renders/latest/arm-left.png) | ![Platform Right](https://raw.githubusercontent.com/gringolito/nearfield-speakers-support/ci-renders/latest/platform-right.png) | ![Platform Left](https://raw.githubusercontent.com/gringolito/nearfield-speakers-support/ci-renders/latest/platform-left.png) |

---

## Quick start

### Option A — Print the ready-to-use STLs

Download the six STL files from the [latest release](https://github.com/gringolito/nearfield-speakers-support/releases/latest). No OpenSCAD required.

Default geometry:

| Parameter | Value |
|---|---|
| Horizontal toe-in | 26° |
| Downward tilt | 12° |
| Platform depth | 200 mm |
| Platform width | 130 mm |
| Arm length (root face to tip face) | 45 mm |
| Maximum load per bracket | 6 kg |

This fits most small bookshelf speakers up to roughly 200 × 130 mm (depth × width). If your speakers are larger or you want different acoustic angles, see [Customizing](#customizing).

### Option B — Build from source

Requires [OpenSCAD](https://openscad.org/).

```bash
git clone https://github.com/gringolito/nearfield-speakers-support.git
cd nearfield-speakers-support
./scripts/export.sh
```

STL files are written to `stl/`.

---

## Assembly

Hardware required **per bracket** — double everything for a pair:

| Item | Quantity |
|---|---|
| M5 × 16 mm socket head cap screw | 4× (2 per joint, 2 joints) |
| M5 heat-set insert (OD 6.4 mm, depth 8 mm) | 4× (2 per arm tenon, 2 tenons) |
| M6 wall screw (~60 mm) | 2× |
| Wall anchor (drywall / masonry / wood) | 2× |
| Dense EVA or neoprene sheet, 2–4 mm | cut to fit |

**Steps:**

1. Press-fit the four M5 heat-set inserts into the arm: 2× in the root tenon (base side), 2× in the tip tenon (platform side).
2. Mount the base to the wall with two M6 screws into wall anchors. The two holes are centered laterally in a vertical pair.
3. Slide the arm's root tenon into the base mortise. The perpendicular mortise guides the tenon; the arm's curved body sets the toe-in angle automatically.
4. Insert two M5 × 16 mm screws through the base's lateral clamping holes and thread them into the inserts in the arm's root tenon. Tighten until both flange faces are in firm contact.
5. Slide the platform's back mortise onto the arm's tip tenon. Use the same handedness for arm and platform (right with right, left with left); the arm's curved tip establishes the tilt angle automatically.
6. Insert two M5 × 16 mm screws through the platform's clamping holes and tighten.
7. Apply EVA or neoprene pads (see [Vibration isolation](#vibration-isolation)).
8. Place the speaker on the platform.

---

## Customizing

All geometry is controlled by parameters in [nearfield-wall-mount.scad](nearfield-wall-mount.scad). Open it in OpenSCAD — all parameters are exposed in the built-in Customizer panel (View → Customizer).

### Acoustic angles

```openscad
toe_in_deg = 26; // horizontal toe-in angle (°) [20–30]
tilt_deg   = 12; // downward vertical tilt (°) [10–15]
```

Toe-in is the angle between the speaker's forward axis and the wall normal. For a typical nearfield listening distance of 60–90 cm, values between 24° and 28° are common. Tilt points the tweeter toward ear height; 10–14° covers most desk configurations.

**Changing `toe_in_deg` or `tilt_deg` requires reprinting only the arm.** Both angles live in the arm's 3D-curved body; the base and platform are unaffected.

### Arm geometry

```openscad
arm_length = 45; // root face to tip face (mm) [40–100]
arm_root_h = 60; // arm cross-section height at root (mm) [50–70]
arm_tip_h  = 28; // arm cross-section height at tip (mm) [25–40]
arm_w      = 40; // arm cross-section width (lateral, mm) [35–50]
```

`arm_length` controls cantilever reach — keep it as short as your setup allows, since bending moment at the wall scales linearly with arm length. The cross-section tapers from `arm_root_h` at the base to `arm_tip_h` at the platform; `arm_tip_h <= arm_root_h` is enforced (asserted at load). `arm_w` is the lateral width and also seeds the boss footprints at both joints (`boss_w` and `plat_boss_w` default to `arm_w`).

**Changing any arm parameter requires reprinting only the arm.**

### Base plate

```openscad
base_h = 140; // base plate height (mm) [160–220]
base_w = 90;  // base plate width  (mm) [80–140]
base_t = 6;   // slab thickness    (mm) [10–28]
```

Size `base_h × base_w` so the wall-screw counterbores have at least `WALL_SCREW_HEAD_D` clearance around them. `base_t` is the slab thickness; the boss adds another `boss_depth` of material in front of the joint.

### Base boss (arm-side joint)

```openscad
boss_w       = arm_w;      // boss width  (mm) [30–50]   defaults to arm_w
boss_h       = arm_root_h; // boss height (mm) [40–70]   defaults to arm_root_h
boss_depth   = 16;         // boss protrusion from slab (mm) [16–28]
boss_blend_h = 4;          // chamfered skirt height (mm) [0–8]
```

The frontal boss receives the arm's root tenon and carries the two lateral clamping screws. Width and height default to the arm's root cross-section so the joint visually reads as a single piece. `boss_depth` is the protrusion in +Z; `boss_blend_h` is a chamfered transition from boss to slab (set to `0` to disable and rely only on the minkowski fillet at the boss/slab corner).

### Platform

```openscad
plat_depth = 200; // wall-to-front-edge distance (mm) [200–300]
plat_w     = 130; // platform width              (mm) [130–140]
plat_t     = 8;   // slab thickness              (mm) [8–14]
lip_h      = 15;  // front safety lip height     (mm) [12–18]
lip_t      = 5;   // front safety lip thickness  (mm) [5–8]
```

Size the platform so it extends at least 10 mm beyond the speaker's base on each side. The front lip should sit partway up the speaker's front baffle to prevent forward toppling.

### Platform boss (arm-side joint)

```openscad
plat_boss_w       = arm_w;              // boss width (mm) [30–50]   defaults to arm_w
plat_boss_depth   = 28;                 // mortise pocket depth (mm) [25–40]
plat_boss_extra_t = arm_tip_h - plat_t; // extra height below slab (mm) tracks arm_tip_h
```

The rear boss receives the arm's tip tenon. `plat_boss_w` defaults to `arm_w` so the joint reads cleanly. `plat_boss_extra_t` is sized so the total back-face height (`plat_t + plat_boss_extra_t`) equals `arm_tip_h`, making the platform back face exactly cover the arm tip face.

### Joints

```openscad
tenon_h_plat    = 12;  // platform tenon height (Z when assembled, mm)
tenon_w_plat    = 25;  // platform tenon width  (X when assembled, mm)
tenon_l_plat    = 20;  // platform tenon length (mm)
tenon_h_base    = 25;  // base tenon height (mm)
tenon_w_base    = 22;  // base tenon width  (mm)
// tenon_l_base = base_t + boss_depth  (passthrough — computed, not set)
tenon_clearance = 0.1; // per-side clearance in mortise (mm)
insert_spacing  = 10;  // vertical spacing between the two M5 inserts (mm)
```

Each joint is a guided rectangular tenon locked with two M5 screws into heat-set inserts. The base tenon is fully passthrough (its length is computed). `insert_spacing` is the center-to-center distance between the two inserts in each tenon — they form a moment couple that resists bending about the lateral axis.

### Wall mounting

```openscad
wall_screw_count   = 2;   // number of wall-anchor screws
wall_screw_spacing = 100; // vertical spacing between them (mm)
```

Two M6 wall screws stacked vertically on the base centerline. Increase `wall_screw_spacing` for heavier speakers or softer wall materials.

### Edge rounding and chamfers

```openscad
edge_r   = 2.0; // external edge rounding via minkowski (mm) [0–6]
fillet_r = 1.0; // tenon-shoulder fillet radius (mm) [0–6]
chamfer  = 1.0; // mortise-mouth chamfer (mm) [0–6]
```

`edge_r` rounds every external edge of all three pieces via a minkowski operation (set to `0` for hard-edged geometry, which is faster to render but less pleasant to the touch). `fillet_r` adds a tapered shoulder at the tenon root for stress relief. `chamfer` widens the mortise mouth for easier tenon entry. All three are independent; default values produce printable parts on a 0.4 mm nozzle.

### Print tolerance adjustment

```openscad
tenon_clearance = 0.1; // per-side clearance in mortise (mm) [0.1–0.3]
```

The default 0.1 mm per side works for most printers. If the tenon is too tight, increase toward 0.3 mm; if loose, decrease toward 0.1 mm. Print `tests/fit_test.scad` to check the fit against a small test mortise before printing full pieces.

### Generating STLs after changes

```bash
./scripts/export.sh
```

Or generate a single piece:

```bash
openscad -o stl/base-right.stl     -D render_piece=1 nearfield-wall-mount.scad
openscad -o stl/base-left.stl      -D render_piece=2 nearfield-wall-mount.scad
openscad -o stl/arm-right.stl      -D render_piece=3 nearfield-wall-mount.scad
openscad -o stl/arm-left.stl       -D render_piece=4 nearfield-wall-mount.scad
openscad -o stl/platform-right.stl -D render_piece=5 nearfield-wall-mount.scad
openscad -o stl/platform-left.stl  -D render_piece=6 nearfield-wall-mount.scad
```

---

## Print settings

### Material

| Material | Notes |
| --- | --- |
| **PETG** | Best balance of strength, thermal stability, and printability. Handles the sustained load and minor heat without creep. |
| **ABS / ASA** | Better long-term structural stability and heat resistance. ASA adds UV resistance — worth it if the brackets are near a window. |
| **PLA+** | Can deform under sustained load above ~40°C, and may lose rigidity over time near heat sources. Acceptable for cool, stable environments. |

The mechanical safety factor (~5×) in the design was calculated against PLA+ as a worst-case minimum-acceptable material. PETG, ABS, and ASA have superior creep resistance and are preferred when available.

### Slicer settings

| Setting | Value |
| --- | --- |
| Layer height | 0.24 mm |
| Perimeters | 6 (minimum 5) |
| Infill | 45–55% (minimum 35%) |
| Infill pattern | Gyroid or cubic |
| Top/bottom layers | 6 minimum |
| Supports | None |

### Bed orientation

| Piece | Flat face on bed | Notes |
| --- | --- | --- |
| Base | Wall-facing face | Print right-side up; counterbores for wall screws on the up-facing side |
| Arm | One of the lateral side faces | Print sits low; underside slope ~5° auto-bridges, no support needed |
| Platform | **Boss-face down** (the boss contacts the bed) | Boss underside is hidden in assembly; first-layer aesthetics there don't matter. The speaker-resting surface prints upward (cleaner finish). |

### Workflow

Print the arm first. Use `tests/fit_test.scad` to validate the tenon fit against a small test mortise before printing the base and platform. Adjust `tenon_clearance` if needed, then print the remaining pieces.

---

## Vibration isolation

Apply dense EVA (Shore A ~45) or neoprene (2–4 mm) at three contact surfaces:

1. **Platform top** — full coverage under the speaker enclosure. Attach with double-sided tape or contact adhesive.
2. **Front lip inner face** — a vertical strip that contacts the front baffle of the speaker.
3. **Base plate rear face** — horizontal strips at the top and bottom edges, or rubber washers on the wall screws.

All three surfaces are intentionally flat to accept any isolator material without modification.

---

## Adapting for other speakers

This project is licensed CC BY-SA 4.0. Adapt it freely — change dimensions, add cable routing, redesign the joint, integrate a VESA adapter — as long as you share the result under the same license and give attribution.

Some directions worth exploring:

- **Larger print bed:** With a 300 × 300 mm bed, the arm and platform can be merged into a single cantilever — the three-piece split exists only to fit a 225 × 225 mm constraint.
- **Different fastener sizes:** Replace the M5 hardware by adjusting the constants in `modules/common.scad` (`INSERT_M5_OD`, `INSERT_M5_DEPTH`, `SCREW_M5_D`, `SCREW_M5_HEAD_D`, `SCREW_M5_COUNTERBORE_DEPTH`).
- **Ceiling mount:** Invert the tilt direction and flip the base plate geometry for overhead installation.
- **Monitor arm integration:** Replace the base with a VESA receiver or clamp adapter while keeping the arm and platform unchanged.
- **Different materials:** The geometry was designed for FDM/PLA+. For SLA or CNC machining, the arm taper profile can be simplified significantly.

---

## Contributing

Issues and pull requests are welcome. The CI pipeline builds all six STL files and validates their geometry against print-bed dimensions on every push and pull request. Renders of all pieces are posted automatically as a comment on each PR — you can see exactly what changed without printing anything.

---

## License

Copyright (c) 2026 Filipe Utzig

This work is licensed under [Creative Commons Attribution-ShareAlike 4.0 International (CC BY-SA 4.0)](https://creativecommons.org/licenses/by-sa/4.0/).

You are free to share and adapt this material for any purpose, even commercially, provided you give appropriate credit and distribute any derivative works under the same license.
