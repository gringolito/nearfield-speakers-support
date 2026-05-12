#!/usr/bin/env bash
set -euo pipefail

SCAD="nearfield-wall-mount.scad"
OUT="stl"

mkdir -p "$OUT"

echo "Exporting Piece 1 — Left..."
openscad -o "$OUT/piece1-left.stl" -D 'render_piece=1' -D 'side="left"' "$SCAD"

echo "Exporting Piece 1 — Right..."
openscad -o "$OUT/piece1-right.stl" -D 'render_piece=1' -D 'side="right"' "$SCAD"

echo "Exporting Piece 2 — Arm..."
openscad -o "$OUT/piece2-arm.stl" -D 'render_piece=2' "$SCAD"

echo "Exporting Piece 3 — Platform..."
openscad -o "$OUT/piece3-platform.stl" -D 'render_piece=3' "$SCAD"

echo ""
echo "Done. STLs written to $OUT/:"
ls -lh "$OUT/"
