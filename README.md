# Nearfield Speaker Wall Mount

[![CI](https://github.com/gringolito/nearfield-speakers-support/actions/workflows/ci.yml/badge.svg)](https://github.com/gringolito/nearfield-speakers-support/actions/workflows/ci.yml)
[![License: CC BY-SA 4.0](https://img.shields.io/badge/License-CC%20BY--SA%204.0-lightgrey.svg)](https://creativecommons.org/licenses/by-sa/4.0/)

3D-printable parametric wall brackets for nearfield bookshelf speakers. Acoustic angles are built into the structure — no articulating joints, no wobble, no drift.

![Assembly preview](https://raw.githubusercontent.com/gringolito/nearfield-speakers-support/ci-renders/latest/assembly.png)

---

## The story

I needed to mount a pair of bookshelf speakers above my monitors for nearfield desktop listening. Every off-the-shelf bracket I found used articulating arms or ball joints — exactly the mechanism I didn't want. Articulating joints accumulate micro-movement under vibration and gradually drift out of alignment. Tighten them hard enough to prevent that and the adjustment becomes difficult to reproduce.

The two acoustic angles that matter are **toe-in** (horizontal rotation toward the listening position) and **tilt** (downward angle to aim the tweeter at ear height). Getting these exactly right is a one-time calibration — after that, nothing should ever move.

This bracket encodes both angles structurally. All angular complexity lives in the 3D-curved arm body. The base plate has only perpendicular features. The platform is a flat slab. Both join the arm via perpendicular tenon-mortise interfaces. The joint between pieces is a guided tenon locked with two M5 screws: the tenon handles shear by geometry, the screws only provide clamping force.

The three-piece split exists because a single-piece bracket for this geometry would not fit on a 225 × 225 mm print bed. The split is also a feature: to try different toe-in or tilt angles you reprint only the arm, and the same base and platform work for both speakers.

Everything prints without supports, flat-side-down.

---

## Pieces

The bracket is three separate printed pieces per speaker:

| Piece | Function | Print footprint |
|---|---|---|
| Base (P1) | Mounts to wall; perpendicular mortise + 2 wall screw holes | 100 × 180 × 22 mm |
| Arm (P2) | Structural cantilever encoding both toe-in (26°) and tilt (12°) in its 3D-curved body | ~80 × 60 × 40 mm |
| Platform (P3) | Supports the speaker; flat slab with rear boss for joint + front lip | 220 × 134 × 22 mm |

```text
WALL                                                                  FRONT
 │
 │  ┌──────────┐     ╭──────╮                       ┌───────────────────┬──┐
 │  │   BASE   │◄────┤ ARM  ├──────tangent at 26°───┤    PLATFORM       │ ▲│
 │  │ 100×180  │ M5  │ curve│  curves down 12°      │    220 × 134      │  │
 │  │ univ L/R │     │ L/R  │                       │    universal      │  │
 │  └──────────┘     ╰──────╯                       └───────────────────┴──┘
 │  vertical pair                                                       lip
 │  of M6 screws
```

The full pair (two speakers) uses four STL files:

| File | Description |
|---|---|
| `base.stl` | Wall base plate — identical for both sides |
| `arm-right.stl` | Right-hand arm (toe-in curves toward listener) |
| `arm-left.stl` | Left-hand arm (mirrored) |
| `platform.stl` | Platform — identical for both sides |

| Base | Arm | Platform |
|---|---|---|
| ![Piece 1](https://raw.githubusercontent.com/gringolito/nearfield-speakers-support/ci-renders/latest/piece1.png) | ![Piece 2](https://raw.githubusercontent.com/gringolito/nearfield-speakers-support/ci-renders/latest/piece2.png) | ![Piece 3](https://raw.githubusercontent.com/gringolito/nearfield-speakers-support/ci-renders/latest/piece3.png) |

---

## Quick start

### Option A — Print the ready-to-use STLs

Download the four STL files from the [latest release](https://github.com/gringolito/nearfield-speakers-support/releases/latest). No OpenSCAD required.

Default geometry:

| Parameter | Value |
|---|---|
| Horizontal toe-in | 26° |
| Downward tilt | 12° |
| Platform depth | 220 mm |
| Platform width | 134 mm |
| Arm length (root face to tip face) | 80 mm |
| Maximum load per bracket | 6 kg |

This fits most small bookshelf speakers up to roughly 220 × 134 mm (depth × width). If your speakers are larger or you want different acoustic angles, see [Customizing](#customizing).

### Option B — Build from source

Requires [OpenSCAD](https://openscad.org/).

```bash
git clone https://github.com/gringolito/nearfield-speakers-support.git
cd nearfield-speakers-support
./export.sh
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
5. Slide the platform's back mortise onto the arm's tip tenon. The platform is symmetric; the arm's curved tip establishes the tilt angle.
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

### Platform dimensions

```openscad
plat_depth = 220; // wall-to-front-edge distance (mm) [200–300]
plat_w     = 134; // platform width (mm) [120–145]
lip_h      = 15;  // front safety lip height (mm) [12–18]
```

Size the platform so it extends at least 10 mm beyond the speaker's base on each side. The front lip should sit partway up the speaker's front baffle to prevent forward toppling.

### Arm length

```openscad
arm_length = 80; // root face to tip face (mm) [50–100]
```

Keep this as short as your setup allows. Bending moment at the wall scales linearly with arm length.

### Print tolerance adjustment

```openscad
tenon_clearance = 0.1; // per-side clearance in mortise (mm) [0.1–0.3]
```

The default 0.1 mm per side works for most printers. If the tenon is too tight, increase toward 0.3 mm; if loose, decrease toward 0.1 mm. Print `tests/fit_test.scad` to check the fit against a small test mortise before printing full pieces.

### Generating STLs after changes

```bash
./export.sh
```

Or generate a single piece:

```bash
# Base — same for both sides
openscad -o stl/base.stl -D 'render_piece="base"' nearfield-wall-mount.scad

# Arm — right and left
openscad -o stl/arm-right.stl -D 'render_piece="arm"' -D 'side="right"' nearfield-wall-mount.scad
openscad -o stl/arm-left.stl  -D 'render_piece="arm"' -D 'side="left"'  nearfield-wall-mount.scad

# Platform — same for both sides
openscad -o stl/platform.stl -D 'render_piece="platform"' nearfield-wall-mount.scad
```

---

## Print settings

### Material

| Material | Notes |
| --- | --- |
| **PETG** | Best balance of strength, thermal stability, and printability. Handles the sustained load and minor heat without creep. |
| **ABS / ASA** | Better long-term structural stability and heat resistance. ASA adds UV resistance — worth it if the brackets are near a window. |
| **PLA+** | Can deform under sustained load above ~40°C, and may lose rigidity over time near heat sources. Acceptable for cool, stable environments. |

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
| Platform | Top face (speaker contact surface) | First layer becomes the speaker contact surface — print with fresh build plate |

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
- **Different fastener sizes:** Replace the M5 hardware by adjusting `insert_m5_od`, `insert_m5_depth`, and `screw_m5_d`.
- **Ceiling mount:** Invert the tilt direction and flip the base plate geometry for overhead installation.
- **Monitor arm integration:** Replace the base with a VESA receiver or clamp adapter while keeping the arm and platform unchanged.
- **Different materials:** The geometry was designed for FDM/PLA+. For SLA or CNC machining, the arm taper profile can be simplified significantly.

---

## Contributing

Issues and pull requests are welcome. The CI pipeline builds all four STL files and validates their geometry against print-bed dimensions on every push and pull request. Renders of all pieces are posted automatically as a comment on each PR — you can see exactly what changed without printing anything.

---

## License

Copyright (c) 2026 Filipe Utzig

This work is licensed under [Creative Commons Attribution-ShareAlike 4.0 International (CC BY-SA 4.0)](https://creativecommons.org/licenses/by-sa/4.0/).

You are free to share and adapt this material for any purpose, even commercially, provided you give appropriate credit and distribute any derivative works under the same license.
