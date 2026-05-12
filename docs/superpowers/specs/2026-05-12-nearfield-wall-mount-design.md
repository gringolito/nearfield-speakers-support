# Nearfield Bookshelf Wall Mount — Design Spec

**Date:** 2026-05-12
**Material:** PLA+
**Print volume:** 225 × 225 × 265 mm
**Maximum load:** 6 kg per bracket

---

## 1. Context and Goals

FDM 3D-printed wall bracket for small bookshelf speakers in nearfield desktop use, installed above monitors. Primary goals:

- Precise acoustic positioning (fixed toe-in + tilt, structurally integrated)
- Maximum mechanical rigidity — no moving parts, no articulations
- Minimal vibration transmission to the wall
- Compatibility with M5 heat-set inserts
- Support-free printing on a 225 × 225 mm bed

---

## 2. Design Decisions

| Decision | Choice | Rationale |
|---|---|---|
| Structure | 3 rigid modular pieces | Single-piece exceeds available print volume |
| Joint | Guided tenon + M5 clamping | Self-aligning; tenon resists shear by geometry, not by the screw |
| Angle distribution | Toe-in in base · Tilt in platform | Perfectly straight arm = optimal layer orientation; angles reprinted independently |
| Isolation surfaces | Flat | User applies EVA/neoprene 2–4 mm freely |
| Moving parts | None | Maximum torsional rigidity, minimum resonance |

---

## 3. Architecture — 3 Pieces

```
WALL                                                            FRONT
│
│  ╔══════════╗  tenon →  ╔════╦════════════════╗  tenon →  ╔════════════════╦══╗
│  ║ PIECE 1  ║           ║ R  ║   PIECE 2      ║           ║   PIECE 3      ║  ║
│  ║  BASE    ║◄ mortise  ║ I  ║   ARM          ║◄ mortise  ║   PLATFORM     ║▲ ║
│  ║  26°toe  ║  26° toe  ║ B  ║   (straight)   ║  12° tilt ║   200×135 mm   ║  ║
│  ╚══════════╝           ╚════╩════════════════╝           ╚════════════════╩══╝
│  160×80×10mm                 80mm + ribs                                   lip
│  4× M5 wall holes            2× triangular ribs                           15mm
│  1× M5 insert                1× M5 insert per tenon (2 total)             1× M5 insert
```

### Print footprints

| Piece | Footprint (X×Y) | Height (Z) | Fits on bed? |
|---|---|---|---|
| Piece 1 — Base | 160 × 80 mm | ~30 mm (plate 10mm + boss 20mm) | ✓ |
| Piece 2 — Arm | 108 × 53 mm | ~80 mm (arm_h + rib_depth) | ✓ |
| Piece 3 — Platform | 200 × 135 mm | ~45 mm (boss 24mm + shelf 6mm + lip 15mm) | ✓ |

### STLs for the full pair (2 speakers)

- `piece1-left.stl` — base with toe-in mortise for left speaker
- `piece1-right.stl` — mirrored base for right speaker (mirror X)
- `piece2-arm.stl` — arm + ribs (identical for both sides)
- `piece3-platform.stl` — platform (identical for both sides)

---

## 4. Piece 1 — Wall Base Plate

**Function:** Distribute load on the wall; anchor the arm with correct toe-in angle.

### Geometry

- Main plate: 160 mm (H) × 80 mm (W) × 10 mm (T) — flat rear face for wall contact
- 4 wall mounting holes (M5/6, countersunk for flat-head screws):
  - 2 upper: Y = 130 mm from bottom, horizontal spacing 40 mm
  - 2 lower: Y = 25 mm from bottom, horizontal spacing 40 mm
- **Arm receiver boss** (protrudes 20 mm forward from the front face of the plate):
  - Boss dimensions: ~44 × 30 mm (X×Y), centered horizontally at Y = 80 mm
  - Internal mortise: 28.4 × 18.4 × 14 mm (tenon + 0.2 mm clearance per side); `tenon_l` = 14 mm fits within the 20 mm boss (back wall = 6 mm)
  - Rotation: `toe_in` degrees in the horizontal plane — boss/mortise axis points toward room center
  - For `side = "right"`: mirror entire Piece 1 in X
- 1× lateral hole in boss for M5 clamping screw: perpendicular to tenon axis, centered at mortise mid-depth
- Fillets: R6 on all external corners of plate and boss; R3 on decorative edges; smooth plate→boss transition with R8

### Print orientation

Rear face (wall contact side) flat on the bed. Boss points upward (Z) during printing. No supports needed.

---

## 5. Piece 2 — Arm + Ribs

**Function:** Transfer load from platform to base; provide bending and torsional rigidity via ribs.

### Body geometry

- `arm_length` = distance between the two boss seating faces (Piece 1 ↔ Piece 3) = 80 mm
- Total Piece 2 length = `arm_length` + 2 × `tenon_l` = 80 + 14 + 14 = **108 mm**
- Rectangular body: 108 mm × `arm_w` × `arm_h` (108 × 35 × 30 mm), with tenons at each end
- Arm axis 100% straight — no angle incorporated

### Lateral triangular ribs

```
SIDE VIEW (rib profile)

← wall                      front →
┌─────────────────────────────────┐  ← arm top (arm_h)
│            ARM BODY             │
├─────────────────────────────────┤
│██████████████████████████░░░░░  │  rib_depth = 50 mm (max, wall side)
│████████████████████░░░░░        │  linear taper to 0 mm (platform side)
│█████████████░░░░░               │
│████████░░░                      │
│████░                            │
└─────────────────────────────────┘
```

- 2 ribs (one on each lateral side of the arm)
- Thickness: `rib_t` = 9 mm
- Maximum depth: `rib_depth` = 50 mm (wall side)
- Linear taper to 0 mm (platform side)
- Root fillet R8 at body→rib transition (stress concentration prevention)

### Full cross-section

```
  ← rib_t=9 →← arm_w=35 →← rib_t=9 →
  ┌──────────┬─────────────┬──────────┐  arm_h = 30mm
  │          │    BODY     │          │
  │   RIB    │             │   RIB    │
  ├──────────┘             └──────────┤
  │                                   │  rib_depth = 50mm (wall end)
  └───────────────────────────────────┘
  total width = 53 mm
```

### Tenons

- **Wall-side tenon:** 28 × 18 × 14 mm, square face (no angle — angle lives in Piece 1 mortise)
- **Platform-side tenon:** 28 × 18 × 14 mm, square face (no angle — angle lives in Piece 3 mortise)
- Each tenon has 1× heat-set insert M5 hole perpendicular to the tenon axis
- R6 fillets at the root of both tenons

### Print orientation

Arm top face flat on the bed. Ribs point upward during printing. Tenons point sideways. No supports needed.

---

## 6. Piece 3 — Platform

**Function:** Support the speaker enclosure; encode 12° downward tilt; provide front safety lip.

### Geometry

- Shelf: `platform_d` × `platform_w` × `platform_t` (200 × 135 × 6 mm)
- Top surfaces: flat (EVA applied by user — 2–4 mm)
- **Front safety lip:**
  - Position: front edge of the shelf (top face)
  - Dimensions: `lip_h` × `lip_t` = 15 × 6 mm
  - R4 fillet at lip root (inner face)
- **Arm receiver boss** (protrudes 24 mm below the shelf bottom face):
  - Boss dimensions: ~44 × 30 mm (X×Y), centered on shelf width, at rear edge
  - Internal mortise: 28.4 × 18.4 × 14 mm (tenon + 0.2 mm clearance); back wall = 10 mm
  - Rotation: `tilt` degrees in the vertical plane (mortise tilted 12° — opening faces slightly rearward/downward)
  - 1× M5 heat-set insert perpendicular to tenon axis, housed in boss
- R6 fillets on all external shelf corners
- R3 fillets at shelf→lip transition (outer face); R8 at shelf→boss transition

### Print orientation

Platform bottom face (with boss) flat on the bed. Front lip and shelf surface point upward during printing. Mortise opening faces the bed — cavity is printable via bridging. No supports needed.

---

## 7. Guided Tenon Joint — Detail

```
SIDE VIEW OF ASSEMBLED JOINT

╔══════════╗
║ PIECE 1  ║──── M5 pass-through screw
║  (base)  ║
║          ╫────► M5 heat-set insert in Piece 2 tenon
╚══════════╝
     ║  tenon (28×18×14mm) seated in angled mortise
╔════╩═════════════════════════╗
║        PIECE 2 (arm)         ║
╚═══════════════════╦══════════╝
                    ║  tenon (28×18×14mm) seated in angled mortise
         ╔══════════╩═══╗
         ║   PIECE 3    ║──── M5 pass-through screw
         ║  (platform)  ║
         ╚══════════════╝
```

**Mechanical principle:**
- The tenon resists shear (force perpendicular to the screw) by geometry
- The M5 screw pulls axially, keeping the flange faces in contact
- No micro-movement possible under continuous vibration

**Tenon tolerance:** `tenon_clearance = 0.2 mm` per side. Adjust per printer (0.1 mm for well-calibrated printers, 0.3 mm for looser tolerances).

---

## 8. Full OpenSCAD Parameters

```openscad
// ============================================================
// Nearfield Bookshelf Wall Mount — Main Parameters
// ============================================================

// --- Acoustic angles ---
toe_in              = 26;       // horizontal toe-in angle (°) [20–30]
tilt                = 12;       // downward vertical tilt (°) [10–15]
side                = "left";   // "left" or "right" (mirrors Piece 1)

// --- Piece 1: Wall base plate ---
base_h              = 160;      // plate height (mm) [140–180]
base_w              = 80;       // plate width (mm) [70–100]
base_t              = 10;       // plate thickness (mm) [8–12]
wall_hole_d         = 5.5;      // wall screw hole diameter (mm)
wall_hole_spacing_h = 40;       // horizontal hole spacing (mm)
wall_hole_upper_y   = 130;      // upper hole height from bottom (mm)
wall_hole_lower_y   = 25;       // lower hole height from bottom (mm)
wall_hole_csink_d   = 10;       // countersink diameter (mm)

// --- Piece 2: Arm ---
arm_length          = 80;       // arm useful length, boss face to boss face (mm) [70–130]
arm_w               = 35;       // arm body width (mm) [30–45]
arm_h               = 30;       // arm body height (mm) [25–40]
rib_t               = 9;        // lateral rib thickness (mm) [8–12]
rib_depth           = 50;       // max rib depth at wall end (mm) [40–65]

// --- Piece 3: Platform ---
platform_d          = 200;      // platform depth (mm) [180–220]
platform_w          = 135;      // platform width (mm) [120–145]
platform_t          = 6;        // shelf thickness (mm) [5–8]
lip_h               = 15;       // front safety lip height (mm) [12–18]
lip_t               = 6;        // front safety lip thickness (mm) [5–8]

// --- Joint (Tenon/Mortise) ---
tenon_w             = 28;       // tenon width (mm)
tenon_h             = 18;       // tenon height (mm)
tenon_l             = 14;       // tenon length (mm)
tenon_clearance     = 0.2;      // per-side clearance in mortise (mm) [0.1–0.3]

// --- Hardware ---
insert_m5_od        = 7.0;      // M5 heat-set insert outer diameter (mm)
insert_m5_depth     = 10.0;     // M5 heat-set insert depth (mm)
screw_m5_pass_d     = 5.2;      // M5 pass-through hole diameter (mm)

// --- Fillets ---
fillet_main         = 6;        // main fillets, external corners (mm)
fillet_rib          = 8;        // arm→rib root fillet (mm)
fillet_small        = 3;        // secondary fillets (mm)

// --- Rendering ---
// 0 = assembled preview · 1 = Piece 1 · 2 = Piece 2 · 3 = Piece 3
render_piece        = 1;
```

---

## 9. Print Guide

| Piece | Bed Orientation | Supports | Recommended Infill | Perimeters |
|---|---|---|---|---|
| Piece 1 — Base | Rear face flat | No | 40% | 4 |
| Piece 2 — Arm | Top face flat, ribs up | No | 50% | 4 |
| Piece 3 — Platform | Bottom face flat | No | 40% | 4 |

**Recommended temperature (PLA+):** 215–220°C nozzle · 60°C bed

**Tolerance note:** Print Piece 2 first and test the tenon fit in a standalone mortise test print before printing full Pieces 1 and 3. Adjust `tenon_clearance` as needed.

---

## 10. BOM — Hardware per Bracket

| Item | Qty | Specification |
|---|---|---|
| M5 heat-set insert | 4× | OD 7.0 mm, depth 10 mm |
| M5 × 16 mm screw | 2× | Socket head cap screw (joint clamping) |
| Wall screw | 4× | 5 mm, with appropriate wall anchor |
| Dense EVA or neoprene | — | 2–4 mm, cut to fit platform and lip |

**For the full pair:** double all quantities above.

---

## 11. Vibration Isolation

Apply dense EVA (2–4 mm) or neoprene at the following interfaces:

1. **Platform ↔ Speaker:** cover the full top surface of the shelf
2. **Front lip ↔ Speaker:** vertical strip on the inner face of the lip
3. **Wall ↔ Base plate:** horizontal strips on the top and bottom edges of the rear plate (or rubber washers on wall screws)

Platform and lip surfaces are intentionally flat to allow easy EVA application with double-sided tape or contact adhesive.

---

## 12. PLA+ Mechanical Considerations

- **Creep under load:** PLA+ exhibits slow creep under sustained load above ~45°C. For warm environments (near windows or hot equipment), consider PETG instead.
- **Short arm:** `arm_length = 80 mm` keeps the bending moment low. Do not increase beyond 100 mm without revisiting the rib cross-section.
- **Root fillets:** The R8 fillets at the rib roots are essential to avoid stress concentration at FDM layer boundaries, which are naturally weaker in the inter-layer direction.
- **40–50% infill + 4 perimeters:** sufficient for the expected loads (6 kg max). Do not reduce below 30% infill.
