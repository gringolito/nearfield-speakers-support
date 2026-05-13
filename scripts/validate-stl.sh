#!/usr/bin/env bash
set -euo pipefail

# Usage: validate-stl.sh <file.stl> <max_x_mm> <max_y_mm> <max_z_mm>
# Prints one markdown table row; exits 0 on PASS, 1 on FAIL.

FILE="${1:?Usage: validate-stl.sh <file.stl> <max_x_mm> <max_y_mm> <max_z_mm>}"
MAX_X="${2:?missing max_x_mm}"
MAX_Y="${3:?missing max_y_mm}"
MAX_Z="${4:?missing max_z_mm}"

BASENAME=$(basename "$FILE")
FAIL=0

STATS=$(admesh "$FILE" 2>&1 || true)

# 1. Manifold: check "Total disconnected facets" is 0 in both columns
DISCONNECTED=$(echo "$STATS" | grep -i "total disconnected facets" | grep -oE '[0-9]+' | head -1 || echo "1")
if [[ "${DISCONNECTED:-1}" -eq 0 ]]; then
  MANIFOLD="✅"
else
  MANIFOLD="❌ ($DISCONNECTED disconnected)"
  FAIL=1
fi

# 2. Bounding box: parse "Min X = N.N, Max X = N.N" (both values on the same line)
parse_extent() {
  local axis="$1"
  echo "$STATS" | awk -v ax="$axis" '
    $0 ~ ("Min " ax " =") {
      gsub(/,/, " ")
      for(i=1;i<=NF;i++) {
        if($i == "Min" && $(i+1) == ax) mn = $(i+3)+0
        if($i == "Max" && $(i+1) == ax) mx = $(i+3)+0
      }
    }
    END { if(mn!="" || mx!="") printf "%.1f", mx - mn }
  '
}

X=$(parse_extent X)
Y=$(parse_extent Y)
Z=$(parse_extent Z)

if [[ -n "$X" && -n "$Y" && -n "$Z" ]]; then
  BOUNDS_OK=$(awk -v x="$X" -v y="$Y" -v z="$Z" \
    -v mx="$MAX_X" -v my="$MAX_Y" -v mz="$MAX_Z" \
    'BEGIN { print (x+0 <= mx+0 && y+0 <= my+0 && z+0 <= mz+0) ? 1 : 0 }')
  if [[ "$BOUNDS_OK" -eq 1 ]]; then
    BOUNDS="✅ ${X}×${Y}×${Z}mm"
  else
    BOUNDS="❌ ${X}×${Y}×${Z}mm (max ${MAX_X}×${MAX_Y}×${MAX_Z})"
    FAIL=1
  fi
else
  BOUNDS="⚠️ parse error"
  FAIL=1
fi

# 3. Triangle count: parse "Number of facets : N" line
TRIANGLES=$(echo "$STATS" | grep -i "number of facets" | grep -oE '[0-9]+' | head -1 || echo "0")
TRIANGLES=${TRIANGLES:-0}
if [[ "$TRIANGLES" -ge 100 && "$TRIANGLES" -le 500000 ]]; then
  TRI="✅ $TRIANGLES"
else
  TRI="❌ $TRIANGLES (expected 100–500,000)"
  FAIL=1
fi

[[ "$FAIL" -eq 0 ]] && RESULT="✅ PASS" || RESULT="❌ FAIL"
echo "| \`$BASENAME\` | $MANIFOLD | $BOUNDS | $TRI | $RESULT |"
exit $FAIL
