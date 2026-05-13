# Nearfield Speaker Wall Mount

[![CI](https://github.com/gringolito/nearfield-speakers-support/actions/workflows/ci.yml/badge.svg)](https://github.com/gringolito/nearfield-speakers-support/actions/workflows/ci.yml)
[![License: CC BY-SA 4.0](https://img.shields.io/badge/License-CC%20BY--SA%204.0-lightgrey.svg)](https://creativecommons.org/licenses/by-sa/4.0/)

3D-printable parametric wall brackets for nearfield bookshelf speakers. Acoustic angles are built into the structure — no articulating joints, no wobble, no drift.

![Assembly preview](https://raw.githubusercontent.com/gringolito/nearfield-speakers-support/ci-renders/latest/assembly.png)

---

## The story

I needed to mount a pair of bookshelf speakers above my monitors for nearfield desktop listening. Every off-the-shelf bracket I found used articulating arms or ball joints — exactly the mechanism I didn't want. Articulating joints accumulate micro-movement under vibration and gradually drift out of alignment. Tighten them hard enough to prevent that and the adjustment becomes difficult to reproduce.

The two acoustic angles that matter are **toe-in** (horizontal rotation toward the listening position) and **tilt** (downward angle to aim the tweeter at ear height). Getting these exactly right is a one-time calibration — after that, nothing should ever move.

This bracket encodes both angles structurally. Toe-in lives in the wall base plate. Tilt lives in the speaker platform. The arm connecting them is a straight member with no embedded angles and all its bending resistance concentrated in two triangular ribs. The joint between pieces is a guided tenon locked with a single M5 screw: the tenon handles shear by geometry, the screw only provides clamping force.

The three-piece split exists because a single-piece bracket for this geometry would not fit on a 225 × 225 mm print bed. The split turned out to be a feature: to try different toe-in angles you reprint only the base plate, and the same arm and platform work for both speakers.

Everything prints without supports, flat-side-down.

---

## Pieces

The bracket is three separate printed pieces per speaker:

| Piece | Function | Print footprint |
|---|---|---|
| Piece 1 — Wall base plate | Mounts to wall; encodes horizontal toe-in angle | 160 × 80 mm |
| Piece 2 — Arm | Transfers load from platform to base; two triangular ribs for rigidity | 108 × 53 mm |
| Piece 3 — Platform | Supports the speaker; encodes downward tilt angle; front safety lip | 200 × 135 mm |

```text
WALL                                                               FRONT
 │
 │  ┌──────────┐ tenon → ┌────┬───────────────────┐ tenon → ┌───────────────────┬──┐
 │  │ PIECE 1  │         │ R  │    PIECE 2        │         │    PIECE 3        │  │
 │  │  BASE    │◄mortise │ I  │    ARM            │◄mortise │    PLATFORM       │ ▲│
 │  │  26° toe │  26°    │ B  │    (straight)     │  12°    │    200 × 135 mm   │  │
 │  └──────────┘         └────┴───────────────────┘  tilt   └───────────────────┴──┘
 │  160×80×10 mm                                                            lip
```

The full pair (two speakers) uses four STL files:

| File | Description |
|---|---|
| `piece1-left.stl` | Base plate for the left speaker |
| `piece1-right.stl` | Base plate for the right speaker (mirrored) |
| `piece2-arm.stl` | Arm — identical for both sides |
| `piece3-platform.stl` | Platform — identical for both sides |

| Piece 1 | Piece 2 | Piece 3 |
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
| Platform depth | 200 mm |
| Platform width | 135 mm |
| Arm length (boss face to boss face) | 80 mm |
| Maximum load per bracket | 6 kg |

This fits most small bookshelf speakers up to roughly 200 × 150 mm (depth × width). If your speakers are larger or you want different acoustic angles, see [Customizing](#customizing).

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
| M5 × 16 mm socket head cap screw | 2× |
| M5 heat-set insert (OD 7.0 mm, depth 10 mm) | 4× |
| M5 wall screw with appropriate anchor | 4× |
| Dense EVA or neoprene sheet, 2–4 mm | cut to fit |

**Steps:**

1. Press-fit the four M5 heat-set inserts:
   - 1× into the boss on Piece 1 (perpendicular to the mortise axis)
   - 2× into the tenons on Piece 2, one at each end
   - 1× into the boss on Piece 3
2. Mount Piece 1 to the wall with four M5 screws into wall anchors. The lower hole pair is at 25 mm from the bottom edge of the plate; the upper pair at 130 mm.
3. Slide the wall-side tenon of Piece 2 into the mortise of Piece 1. The angled mortise guides the arm to the correct toe-in position automatically.
4. Insert an M5 × 16 mm screw through Piece 1's lateral clamping hole and thread it into the insert in Piece 2's tenon. Tighten until both flange faces are in firm contact.
5. Slide Piece 3 onto the platform-side tenon of Piece 2. The mortise in Piece 3 is angled at 12° and sets the downward tilt.
6. Insert the second M5 × 16 mm screw through Piece 3's clamping hole and tighten.
7. Apply EVA or neoprene pads (see [Vibration isolation](#vibration-isolation)).
8. Place the speaker on the platform.

---

## Customizing

All geometry is controlled by parameters in [nearfield-wall-mount.scad](nearfield-wall-mount.scad). Open it in OpenSCAD — all parameters are exposed in the built-in Customizer panel (View → Customizer).

### Acoustic angles

```openscad
toe_in = 26; // horizontal toe-in angle (°) [20–30]
tilt   = 12; // downward vertical tilt (°) [10–15]
```

Toe-in is the angle between the speaker's forward axis and the wall normal. For a typical nearfield listening distance of 60–90 cm, values between 24° and 28° are common. Tilt points the tweeter toward ear height; 10–14° covers most desk configurations.

**Changing toe-in requires reprinting only Piece 1.** Changing tilt requires reprinting only Piece 3. The arm stays the same.

### Platform dimensions

```openscad
platform_depth = 200; // wall to front edge (mm) [180–220]
platform_w     = 135; // platform width (mm) [120–145]
lip_h          = 15;  // front safety lip height (mm) [12–18]
```

Size the platform so it extends at least 10 mm beyond the speaker's base on each side. The front lip should sit partway up the speaker's front baffle to prevent forward toppling.

### Arm length

```openscad
arm_length = 80; // boss face to boss face (mm) [70–130]
```

Keep this as short as your setup allows. Bending moment at the wall scales linearly with arm length. If you push beyond 100 mm, increase `rib_depth` proportionally to maintain the same section modulus at the critical root cross-section.

### Print tolerance adjustment

```openscad
tenon_clearance = 0.2; // per-side clearance in mortise (mm) [0.1–0.3]
```

The default 0.2 mm per side works for most printers. If the tenon is too tight, increase toward 0.3 mm; if loose, decrease toward 0.1 mm. Print `tests/fit_test.scad` to check the fit against a small test mortise before printing full pieces.

### Generating STLs after changes

```bash
./export.sh
```

Or generate a single piece:

```bash
# Piece 1 — left speaker
openscad -o stl/piece1-left.stl -D 'render_piece=1' -D 'side="left"' nearfield-wall-mount.scad

# Piece 1 — right speaker
openscad -o stl/piece1-right.stl -D 'render_piece=1' -D 'side="right"' nearfield-wall-mount.scad

# Piece 2 — arm (same for both sides)
openscad -o stl/piece2-arm.stl -D 'render_piece=2' nearfield-wall-mount.scad

# Piece 3 — platform (same for both sides)
openscad -o stl/piece3-platform.stl -D 'render_piece=3' nearfield-wall-mount.scad
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
| Piece 1 — Base | Rear face (wall contact) | Boss and plate build upward; wall-contact surface is smooth first layer |
| Piece 2 — Arm | Top face, ribs up | Layer planes parallel to the arm's bending load — strongest direction |
| Piece 3 — Platform | Bottom face, boss up | Shelf and lip build upward; mortise cavity bridges cleanly without support |

### Workflow

Print Piece 2 first. Use `tests/fit_test.scad` to validate the tenon fit against a small test mortise before printing Pieces 1 and 3. Adjust `tenon_clearance` if needed, then print the remaining pieces.

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

- **Larger print bed:** With a 300 × 300 mm bed, Piece 2 and Piece 3 can be merged into a single cantilever — the three-piece split exists only to fit a 225 × 225 mm constraint.
- **Different fastener sizes:** Replace the M5 hardware by adjusting `insert_m5_od`, `insert_m5_depth`, and `screw_m5_d`.
- **Ceiling mount:** Invert the tilt direction and flip the base plate geometry for overhead installation.
- **Monitor arm integration:** Replace Piece 1 with a VESA receiver or clamp adapter while keeping the arm and platform unchanged.
- **Different materials:** The geometry was designed for FDM/PLA+. For SLA or CNC machining, the rib taper profile can be simplified significantly.

---

## Contributing

Issues and pull requests are welcome. The CI pipeline builds all four STL files and validates their geometry against print-bed dimensions on every push and pull request. Renders of all pieces are posted automatically as a comment on each PR — you can see exactly what changed without printing anything.

---

## License

Copyright (c) 2026 Filipe Utzig

This work is licensed under [Creative Commons Attribution-ShareAlike 4.0 International (CC BY-SA 4.0)](https://creativecommons.org/licenses/by-sa/4.0/).

You are free to share and adapt this material for any purpose, even commercially, provided you give appropriate credit and distribute any derivative works under the same license.
