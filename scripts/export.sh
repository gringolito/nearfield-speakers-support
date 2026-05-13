#!/usr/bin/env bash
# Generate all STL files for the nearfield wall mount.
# Output: stl/{base,arm-right,arm-left,platform}.stl
# Optional: also stl/assembly.stl when ASSEMBLY=1.

set -euo pipefail

SCAD_FILE="nearfield-wall-mount.scad"
OUT_DIR="stl"

mkdir -p "$OUT_DIR"

declare -A PIECES=(
    [1]="base"
    [2]="arm-right"
    [3]="arm-left"
    [4]="platform"
)

for num in "${!PIECES[@]}"; do
    name="${PIECES[$num]}"
    out="$OUT_DIR/$name.stl"
    echo "Rendering $name -> $out"
    openscad --hardwarnings -o "$out" -D "render_piece=$num" "$SCAD_FILE"
done

if [[ "${ASSEMBLY:-0}" == "1" ]]; then
    echo "Rendering assembly preview -> $OUT_DIR/assembly.stl"
    openscad --hardwarnings -o "$OUT_DIR/assembly.stl" -D "render_piece=0" "$SCAD_FILE"
fi

echo "Done. STLs in $OUT_DIR/"
ls -la "$OUT_DIR/"
