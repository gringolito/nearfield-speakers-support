# Nearfield Speaker Wall Mount — Design Spec

**Date:** 2026-05-13
**Status:** Approved — ready for implementation plan
**Replaces:** the prior 3-piece design with angled-mortise joinery (rolled back due to agent execution drift during implementation, not mechanical failure)

---

## Purpose

3D-printable wall bracket for nearfield bookshelf speakers (up to **6 kg**, reference enclosure ~150 × 250 × 200 mm). Acoustic angles are structurally encoded in the bracket — no articulating joints, no calibration drift over time. Optimized for FDM printing in **PLA+** on a **225 × 225 × 265 mm** bed without support material.

---

## Core design principle

**All angular complexity lives in the arm body.** The base plate has only perpendicular features. The platform is a flat slab. Both join the arm via perpendicular tenon-mortise interfaces.

This isolates tolerance-sensitive geometry to one place (the arm itself) and keeps the receiving pieces simple. The previous attempt distributed angles into the joint faces (angled mortises) — that approach is structurally valid but high-risk during execution, because the joint is the most sensitive surface for FDM tolerances.

---

## Acoustic premises

| Parameter | Default | Range |
|---|---|---|
| Horizontal toe-in (per bracket, rotation toward listener) | 26° | 20–30° |
| Vertical tilt (downward, aiming tweeter at ear height) | 12° | 10–15° |
| Wall-to-platform-front distance | ~80 + 220 = 300 mm | configurable |
| Maximum supported speaker mass | 6 kg | hard limit |

---

## Architecture — 3 pieces per bracket

| Piece | L / R | Print orientation | Approximate footprint |
|---|---|---|---|
| **P1 — Base** | Universal (1 STL) | Flat on bed, wall-face down | 100 × 180 × 22 mm |
| **P2 — Arm** | Mirrored (2 STLs: `arm-left`, `arm-right`) | Laid on its side, height vertical | ~80 × 60 × 40 mm |
| **P3 — Platform** | Universal (1 STL) | Flat on bed, top-face down | 220 × 134 × 22 mm (incl. boss) |

Per pair (two brackets): **4 unique STLs**, **6 prints total**.

### P1 — Base plate

A vertical rectangular slab parallel to the wall. Front face contains:
- 1× perpendicular mortise pocket at mid-height for the arm root tenon
- 2× wall screw clearance holes in a vertical pair, centered laterally

Universal between left and right brackets (no asymmetry).

### P2 — Arm (the structural member)

A 3D-curved member. The arm's centerline is the superposition of two circular arcs:

- **Plan-view arc** (looking down): tangent perpendicular to wall at root, tangent at 26° toward listener at tip. Approximate radius R ≈ 176 mm for the default 80 mm arc length.
- **Side-view arc** (looking from the side): tangent horizontal at root, tangent 12° downward at tip. Approximate radius R ≈ 382 mm.

The cross-section tapers along the length:
- **Root** (mating face with base): ~60 mm vertical × 40 mm lateral
- **Tip** (mating face with platform): ~30 mm vertical × 40 mm lateral

The taper concentrates material at the root, where bending moment is maximum, and removes material toward the tip, where it is zero. The arm has no separate ribs or gussets — the solid tapered profile *is* the rib.

The arm has a **tenon** protruding from both the root face (mates with base) and the tip face (mates with platform). Both tenons are perpendicular to their local face.

### P3 — Platform

A flat horizontal slab carrying the speaker. Features:
- **Front lip** — 15 mm tall × 6 mm thick, perpendicular to platform top, anti-slide
- **Back mortise** — perpendicular pocket on the back edge, receives the arm tip tenon
- **Boss** — local thickening of the platform body around the mortise area, ~30 × 60 × 12 mm extending downward from the platform body. The boss provides material for the lateral clamping screws and for the mortise walls.

Universal between left and right brackets. The platform is symmetric; its orientation is fully defined by which face mates with the arm (the back face).

---

## Joints

Both joints are the same family — only the tenon size differs slightly between root (larger, carries cumulative moment) and tip (smaller, carries only platform-side moment).

**Joint geometry (platform side, indicative):**

| Element | Dimension |
|---|---|
| Tenon (on arm tip) | 14 mm vertical × 26 mm lateral × 17 mm long |
| Mortise (in platform boss) | 14.2 × 26.2 × 17.1 mm (0.1 mm clearance per side; 0.1 mm clearance at tenon depth-tip) |
| Heat-set inserts in tenon | 2× M5, OD 6.4 mm, depth 8 mm, axes perpendicular to tenon long axis, spaced 10 mm apart along tenon |
| Clamping screws | 2× M5 × 16 mm SHCS, lateral entry through the receiving piece, threading into inserts |

The 17 mm tenon length is set by the receiving piece's available depth: the platform boss is 22 mm thick (10 mm body + 12 mm boss extension), leaving 17 mm of mortise depth plus 5 mm of back-wall material. The same constraint applies to the base.

**Joint geometry (base side):** Same family, larger tenon (~16 mm vertical × 30 mm lateral × 17 mm long) to accommodate the higher cumulative moment via a larger cross-section. Tenon length matches the platform side, since base thickness (22 mm) provides the same 17 mm of available mortise depth.

### Mechanical analysis

Worst case: 6 kg speaker (60 N) acting at the platform centroid (110 mm from the arm-platform joint, ~190 mm from the base-arm joint).

| Joint | Bending moment | Tenon section modulus | Bending stress | Safety factor vs PLA+ yield (40 MPa) |
|---|---|---|---|---|
| Arm-platform | 6.6 N·m | 850 mm³ | 7.8 MPa | ~5× |
| Base-arm | 11.4 N·m | 1280 mm³ | 8.9 MPa | ~4.5× |

PLA+ creep limit under sustained load is ~15 MPa (conservative). Working stresses stay below this, so long-term creep is not expected to compromise the joint.

2× M5 inserts per joint provide redundancy (each insert resists ~250–400 N pullout; pull-out demand under worst case is well below this) and prevent the platform from rotating about a single screw axis.

---

## Parameter table

All parameters exposed in OpenSCAD Customizer.

### Acoustic

| Parameter | Default | Range | Purpose |
|---|---|---|---|
| `toe_in_deg` | 26 | 20–30 | Horizontal rotation toward listener (per bracket) |
| `tilt_deg` | 12 | 10–15 | Downward tilt of the platform |

### Geometry — arm

| Parameter | Default | Range | Purpose |
|---|---|---|---|
| `arm_length` | 80 mm | 50–100 | Centerline arc length from root tenon face to tip tenon face |
| `arm_root_h` | 60 mm | 50–70 | Arm vertical dimension at root |
| `arm_tip_h` | 30 mm | 25–40 | Arm vertical dimension at tip |
| `arm_w` | 40 mm | 35–50 | Arm lateral dimension (constant along length) |

### Geometry — base

| Parameter | Default | Range | Purpose |
|---|---|---|---|
| `base_h` | 180 mm | 160–220 | Base plate vertical height |
| `base_w` | 100 mm | 80–140 | Base plate horizontal width |
| `base_t` | 22 mm | 22–28 | Base plate thickness (perpendicular to wall). Minimum 22 mm to host the 17 mm-deep mortise pocket with a 5 mm back wall. |

### Geometry — platform

| Parameter | Default | Range | Purpose |
|---|---|---|---|
| `plat_depth` | 220 mm | 200–300 | Platform front-back length |
| `plat_w` | 134 mm | 130–140 | Platform left-right width |
| `plat_t` | 10 mm | 8–14 | Platform body thickness (excluding boss) |
| `plat_boss_w` | 60 mm | 50–80 | Boss width (lateral) |
| `plat_boss_depth` | 30 mm | 25–40 | Boss extension forward from back edge |
| `plat_boss_extra_t` | 12 mm | 10–18 | Additional thickness of boss below body |
| `lip_h` | 15 mm | 12–18 | Front lip height |
| `lip_t` | 6 mm | 5–8 | Front lip thickness |

### Geometry — fillets

| Parameter | Default | Range | Purpose |
|---|---|---|---|
| `fillet_r` | 6 mm | 4–10 | Default fillet radius at structural transitions |

### Joints

| Parameter | Default | Purpose |
|---|---|---|
| `tenon_h_plat` | 14 mm | Tenon vertical at platform end |
| `tenon_w_plat` | 26 mm | Tenon lateral at platform end |
| `tenon_l_plat` | 17 mm | Tenon length at platform end (bounded by 22 mm boss thickness − 5 mm back wall) |
| `tenon_h_base` | 16 mm | Tenon vertical at base end (larger, more loaded) |
| `tenon_w_base` | 30 mm | Tenon lateral at base end |
| `tenon_l_base` | 17 mm | Tenon length at base end (bounded by 22 mm base thickness − 5 mm back wall) |
| `tenon_clearance` | 0.1 mm | Per-side clearance in mortise |
| `insert_m5_od` | 6.4 mm | Heat-set insert outer diameter |
| `insert_m5_depth` | 8 mm | Heat-set insert depth |
| `insert_spacing` | 10 mm | Distance between the 2 inserts along tenon length |

### Wall mounting

| Parameter | Default | Purpose |
|---|---|---|
| `wall_screw_d` | 6 mm | Wall screw shank diameter |
| `wall_screw_count` | 2 | Number of wall screws per bracket |
| `wall_screw_spacing` | 120 mm | Vertical distance between the 2 wall screws |

---

## Hardware BOM

**Per bracket:**

| Item | Qty | Notes |
|---|---|---|
| M5 heat-set insert (OD 6.4, depth 8) | 4 | 2 in arm root tenon, 2 in arm tip tenon |
| M5 × 16 mm SHCS | 4 | Lateral clamping screws (2 per joint) |
| M6 wall screw, ~60 mm | 2 | Length depending on wall thickness |
| Wall anchor | 2 | Type appropriate to wall (drywall / masonry / wood) |
| Dense EVA or neoprene, 2–4 mm | as needed | Cut to fit; see Vibration isolation |

**Per pair:** double everything.

---

## Print orientation per piece

| Piece | Bed contact face | Z height of print | Support material |
|---|---|---|---|
| Base | Wall-facing face (largest) | 22 mm | None |
| Arm | Side face (the lateral 40 mm dimension) | 60 mm (root) tapering to 30 mm (tip) | None (taper angle within FDM overhang limits) |
| Platform | Top face (speaker contact surface) | 22 mm (boss height) | None |

Printing the platform top-face-down means the first layer is the speaker-resting surface — first-layer quality therefore matters for acoustic isolation contact. Compensate with a fresh build plate and a careful first layer.

---

## Mirroring strategy

Only **P2 (the arm)** has L and R variants. In OpenSCAD, the right-hand arm is the canonical model; the left-hand arm is generated via `mirror([1, 0, 0])`.

Base and platform are generated once and used as-is on both sides.

---

## Vibration isolation

Dense EVA (Shore A ~45) or neoprene 2–4 mm, applied by the user at three contact surfaces:

1. **Platform top** — full coverage under the speaker enclosure
2. **Front lip inner face** — vertical strip contacting the speaker baffle
3. **Base back face** — rubber washers on wall screws, or a strip across the back

All three surfaces are intentionally flat to accept any isolator material without modification.

---

## Print settings (PLA+, indicative)

| Setting | Value |
|---|---|
| Layer height | 0.20 mm |
| Perimeters | 5 (minimum 4) |
| Infill | 45% gyroid (minimum 35%) |
| Top / bottom layers | 6 minimum |
| Supports | None |
| First layer (platform) | Slow, well-tuned — this becomes the speaker contact surface |

---

## Out of scope

- Articulating or adjustable joints
- Cable management features
- VESA or alternative mount adapters
- Asymmetric base plate (e.g., extended on one side)
- Tilt or toe-in adjustment at assembly time — angle changes require reprinting the arm
- Anti-theft features
- Integrated electrical or signal routing

---

## Implementation considerations (deferred to plan phase)

- **Arm 3D centerline modeling** — needs a path-based sweep in OpenSCAD. Candidate techniques: (a) `hull()` between N cross-sections sampled along the centerline; (b) custom `polygon` swept via a series of `multmatrix` transforms; (c) `linear_extrude` with `scale` and offset for an approximate solution. Decision deferred until plan phase, after a feasibility spike.
- **CI workflow alignment** — the existing `.github/workflows/ci.yml` references file names from the previous attempt (`piece1-left.stl`, `piece2-arm.stl`, etc.). New file names per this spec: `base.stl`, `arm-left.stl`, `arm-right.stl`, `platform.stl`. CI workflow must be updated as part of implementation.
- **Fit test** — before printing full pieces, the implementation plan should include a small `fit_test.scad` that prints just a tenon and a matching mortise so `tenon_clearance` can be calibrated for the user's specific printer.
- **OpenSCAD code structure** — file layout (top-level + `modules/`) deferred to plan phase.
