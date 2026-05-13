# CI/CD Workflow Implementation Plan

> **For agentic workers:** REQUIRED SUB-SKILL: Use superpowers:subagent-driven-development (recommended) or superpowers:executing-plans to implement this plan task-by-task. Steps use checkbox (`- [ ]`) syntax for tracking.

**Goal:** Add a GitHub Actions CI/CD pipeline that builds STLs, renders PNGs, validates geometry, and publishes tagged releases for the nearfield-speakers-support OpenSCAD project.

**Architecture:** Two workflow files — `ci.yml` (PR + master) and `release.yml` (tags). The CI workflow runs two jobs: `build-and-render` (OpenSCAD export + PNG renders + upsert PR comment) and `validate` (admesh geometry checks + upsert validation comment). The release workflow builds STLs and creates a GitHub Release with assets.

**Tech Stack:** GitHub Actions, OpenSCAD (headless via xvfb-run), admesh, actions/github-script@v9, softprops/action-gh-release@v3, git worktree (for ci-renders branch)

---

## File Map

| File | Action | Responsibility |
| --- | --- | --- |
| `docs/superpowers/specs/2026-05-12-ci-workflow-design.md` | Create | Design spec document |
| `scripts/validate-stl.sh` | Create | Per-STL geometry validation (manifold, bounds, triangles) |
| `.github/workflows/ci.yml` | Create | PR + master build, render, validate |
| `.github/workflows/release.yml` | Create | Tag-triggered STL release |

---

## Task 1: Write and commit the design spec

**Files:**

- Create: `docs/superpowers/specs/2026-05-12-ci-workflow-design.md`

- [ ] **Step 1: Create spec file**

```markdown
# CI/CD Workflow Design

## Context

OpenSCAD project for 3D-printable speaker wall brackets. Goal: automate STL
export, geometry validation, PNG renders for PRs, and tagged GitHub Releases.

## Workflow Files

### ci.yml (push to master + pull_request targeting master)

**build-and-render job:**
1. Install OpenSCAD + Xvfb
2. Run `export.sh` → 4 STLs
3. Render 4 PNGs (assembly, piece1, piece2, piece3) via xvfb-run
4. Upload STLs + PNGs as artifacts
5. (PRs only) Push PNGs to `ci-renders` branch at `pr-{N}/` via git worktree
6. (PRs only) Upsert PR comment with embedded render table via github-script@v9

**validate job (needs: build-and-render):**
1. Download STL artifacts
2. Run `scripts/validate-stl.sh` for each STL (manifold, bounds, triangle count)
3. (PRs only) Upsert validation report as a separate PR comment via github-script@v9

### release.yml (push matching v* tags)

**build job:** Install OpenSCAD, run `export.sh`, upload STL artifact

**release job (needs: build):** Download STLs, create GitHub Release with assets
via `softprops/action-gh-release@v3`

## Validation Checks (per STL)

| Check | Tool | Criteria |
| --- | --- | --- |
| Manifold | admesh output | No "open edges" or "unconnected" in output |
| Bounding box | admesh output | Fits within 225×225×265 mm (print volume) |
| Triangle count | admesh output | 500 ≤ count ≤ 500,000 |

### Per-piece expected bounds

| File | Max X | Max Y | Max Z |
| --- | --- | --- | --- |
| piece1-left.stl | 160 | 80 | 30 |
| piece1-right.stl | 160 | 80 | 30 |
| piece2-arm.stl | 120 | 35 | 30 |
| piece3-platform.stl | 200 | 135 | 30 |

## PR Comment Upsert Strategy

Each comment type has a unique HTML marker comment used to find and update it:
- Renders comment: `<!-- openscad-renders -->`
- Validation comment: `<!-- openscad-validation -->`

github-script lists all PR comments, finds one containing the marker,
and calls `updateComment` or `createComment` accordingly.

## Image Hosting

PNGs are pushed to the `ci-renders` orphan branch at `pr-{N}/assembly.png`
etc. via git worktree. The same path is overwritten on every push, making
the branch itself the upsert store. PR comment embeds them via
`raw.githubusercontent.com` URLs.
```

- [ ] **Step 2: Commit**

```bash
git add docs/superpowers/specs/2026-05-12-ci-workflow-design.md
git commit -m "docs: add CI/CD workflow design spec"
```

---

## Task 2: Create the STL validation script

**Files:**

- Create: `scripts/validate-stl.sh`

- [ ] **Step 1: Create the script**

```bash
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

# 1. Manifold: admesh reports open edges when mesh is not watertight
if echo "$STATS" | grep -qiE "open edges|unconnected|hole"; then
  MANIFOLD="❌"
  FAIL=1
else
  MANIFOLD="✅"
fi

# 2. Bounding box: parse "Min X = N.N, Max X = N.N" lines
parse_extent() {
  local axis="$1"
  echo "$STATS" | awk -v ax="$axis" '
    $0 ~ ("Min " ax) { gsub(/,/, ""); for(i=1;i<=NF;i++) if($i~/^-?[0-9]/) mn=$i }
    $0 ~ ("Max " ax) { gsub(/,/, ""); for(i=1;i<=NF;i++) if($i~/^-?[0-9]/) mx=$i }
    END { if(mn!="" && mx!="") printf "%.1f", mx - mn }
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
TRIANGLES=$(echo "$STATS" | grep -i "number of facets" | grep -oE '[0-9]+' | tail -1 || echo "0")
TRIANGLES=${TRIANGLES:-0}
if [[ "$TRIANGLES" -ge 500 && "$TRIANGLES" -le 500000 ]]; then
  TRI="✅ $TRIANGLES"
else
  TRI="❌ $TRIANGLES (expected 500–500,000)"
  FAIL=1
fi

[[ "$FAIL" -eq 0 ]] && RESULT="✅ PASS" || RESULT="❌ FAIL"
echo "| \`$BASENAME\` | $MANIFOLD | $BOUNDS | $TRI | $RESULT |"
exit $FAIL
```

- [ ] **Step 2: Make it executable**

```bash
chmod +x scripts/validate-stl.sh
```

- [ ] **Step 3: Smoke-test locally with an existing STL**

```bash
sudo apt-get install -y admesh   # or: brew install admesh
bash scripts/validate-stl.sh stl/piece1-left.stl 160 80 30
```

Expected output (single pipe-delimited markdown row):

```
| `piece1-left.stl` | ✅ | ✅ 160.0×80.0×30.0mm | ✅ <N> | ✅ PASS |
```

If bounding box parsing shows "⚠️ parse error", run `admesh stl/piece1-left.stl 2>&1` and inspect the actual output format, then update `parse_extent` to match the installed admesh version's output.

- [ ] **Step 4: Commit**

```bash
git add scripts/validate-stl.sh
git commit -m "feat: add STL validation script"
```

---

## Task 3: Create ci.yml

**Files:**

- Create: `.github/workflows/ci.yml`

- [ ] **Step 1: Create directory and file**

```bash
mkdir -p .github/workflows
```

`.github/workflows/ci.yml`:

```yaml
name: CI

on:
  push:
    branches: [master]
  pull_request:
    branches: [master]

permissions:
  contents: write
  pull-requests: write

jobs:
  build-and-render:
    runs-on: ubuntu-latest
    steps:
      - uses: actions/checkout@v6

      - name: Install OpenSCAD and Xvfb
        run: |
          sudo apt-get update -qq
          sudo apt-get install -y openscad xvfb

      - name: Build STLs
        run: ./export.sh

      - name: Render PNGs
        run: |
          mkdir -p renders
          declare -A NAMES=([0]=assembly [1]=piece1 [2]=piece2 [3]=piece3)
          for piece in 0 1 2 3; do
            xvfb-run openscad \
              --render \
              --camera=0,0,0,55,0,25,500 \
              --colorscheme=Starnight \
              -o "renders/${NAMES[$piece]}.png" \
              nearfield-wall-mount.scad \
              -D "render_piece=${piece}"
          done

      - name: Upload STL artifacts
        uses: actions/upload-artifact@v7
        with:
          name: stl-files
          path: stl/

      - name: Upload render artifacts
        uses: actions/upload-artifact@v7
        with:
          name: png-renders
          path: renders/

      - name: Push renders to ci-renders branch
        if: github.event_name == 'pull_request'
        run: |
          PR="${{ github.event.pull_request.number }}"
          git config user.email "github-actions[bot]@users.noreply.github.com"
          git config user.name "github-actions[bot]"

          if git ls-remote --exit-code origin ci-renders >/dev/null 2>&1; then
            git fetch origin ci-renders
            git worktree add /tmp/ci-renders origin/ci-renders
          else
            git worktree add --orphan -b ci-renders /tmp/ci-renders
          fi

          mkdir -p "/tmp/ci-renders/pr-${PR}"
          cp renders/*.png "/tmp/ci-renders/pr-${PR}/"

          cd /tmp/ci-renders
          git add "pr-${PR}/"
          git diff --staged --quiet && exit 0
          git commit -m "ci: renders for PR #${PR} [skip ci]"
          git push origin ci-renders

      - name: Upsert render comment
        if: github.event_name == 'pull_request'
        uses: actions/github-script@v9
        with:
          script: |
            const marker = '<!-- openscad-renders -->';
            const pr = context.payload.pull_request.number;
            const { owner, repo } = context.repo;
            const base = `https://raw.githubusercontent.com/${owner}/${repo}/ci-renders/pr-${pr}`;
            const body = [
              marker,
              '## OpenSCAD Renders',
              '',
              '| Assembly | Piece 1 | Piece 2 | Piece 3 |',
              '| --- | --- | --- | --- |',
              `| ![assembly](${base}/assembly.png) | ![piece1](${base}/piece1.png) | ![piece2](${base}/piece2.png) | ![piece3](${base}/piece3.png) |`,
            ].join('\n');

            const { data: comments } = await github.rest.issues.listComments({
              owner, repo, issue_number: pr,
            });
            const existing = comments.find(c => c.body.includes(marker));
            if (existing) {
              await github.rest.issues.updateComment({ owner, repo, comment_id: existing.id, body });
            } else {
              await github.rest.issues.createComment({ owner, repo, issue_number: pr, body });
            }

  validate:
    runs-on: ubuntu-latest
    needs: build-and-render
    steps:
      - uses: actions/checkout@v6

      - name: Download STL artifacts
        uses: actions/download-artifact@v7
        with:
          name: stl-files
          path: stl/

      - name: Install admesh
        run: sudo apt-get install -y admesh

      - name: Validate STLs
        id: validate
        run: |
          FAIL=0
          ROWS=""

          check() {
            local file="$1" mx="$2" my="$3" mz="$4"
            ROW=$(bash scripts/validate-stl.sh "$file" "$mx" "$my" "$mz") || FAIL=1
            ROWS="${ROWS}${ROW}"$'\n'
          }

          check stl/piece1-left.stl    160 80  30
          check stl/piece1-right.stl   160 80  30
          check stl/piece2-arm.stl     120 35  30
          check stl/piece3-platform.stl 200 135 30

          {
            echo "| File | Manifold | Dimensions | Triangles | Result |"
            echo "| --- | --- | --- | --- | --- |"
            printf '%s' "$ROWS"
          } > /tmp/validation-report.md

          echo "status=$([ $FAIL -eq 0 ] && echo pass || echo fail)" >> "$GITHUB_OUTPUT"
          exit $FAIL

      - name: Upsert validation comment
        if: github.event_name == 'pull_request' && always()
        uses: actions/github-script@v9
        with:
          script: |
            const fs = require('fs');
            const marker = '<!-- openscad-validation -->';
            const status = '${{ steps.validate.outputs.status }}';
            const icon = status === 'pass' ? '✅' : '❌';
            const table = fs.readFileSync('/tmp/validation-report.md', 'utf8');
            const body = `${marker}\n## STL Validation ${icon}\n\n${table}`;
            const pr = context.payload.pull_request.number;
            const { owner, repo } = context.repo;

            const { data: comments } = await github.rest.issues.listComments({
              owner, repo, issue_number: pr,
            });
            const existing = comments.find(c => c.body.includes(marker));
            if (existing) {
              await github.rest.issues.updateComment({ owner, repo, comment_id: existing.id, body });
            } else {
              await github.rest.issues.createComment({ owner, repo, issue_number: pr, body });
            }
```

- [ ] **Step 2: Commit**

```bash
git add .github/workflows/ci.yml
git commit -m "feat: add CI workflow (build, render, validate)"
```

---

## Task 4: Create release.yml

**Files:**

- Create: `.github/workflows/release.yml`

- [ ] **Step 1: Create file**

`.github/workflows/release.yml`:

```yaml
name: Release

on:
  push:
    tags:
      - 'v*'

permissions:
  contents: write

jobs:
  build:
    runs-on: ubuntu-latest
    steps:
      - uses: actions/checkout@v6

      - name: Install OpenSCAD
        run: |
          sudo apt-get update -qq
          sudo apt-get install -y openscad

      - name: Build STLs
        run: ./export.sh

      - name: Upload STL artifacts
        uses: actions/upload-artifact@v7
        with:
          name: stl-files
          path: stl/

  release:
    runs-on: ubuntu-latest
    needs: build
    steps:
      - name: Download STL artifacts
        uses: actions/download-artifact@v7
        with:
          name: stl-files
          path: stl/

      - name: Create GitHub Release
        uses: softprops/action-gh-release@v3
        with:
          name: Release ${{ github.ref_name }}
          generate_release_notes: true
          files: |
            stl/piece1-left.stl
            stl/piece1-right.stl
            stl/piece2-arm.stl
            stl/piece3-platform.stl
```

- [ ] **Step 2: Commit**

```bash
git add .github/workflows/release.yml
git commit -m "feat: add release workflow (tag-triggered STL release)"
```

---

## Task 5: Verify the full pipeline

- [ ] **Step 1: Push the branch and open a test PR**

```bash
git push origin master  # or your feature branch
```

Open a PR against master on GitHub. Wait for Actions to complete (~3–5 min).

Expected:
- `build-and-render` job passes: STL + PNG artifacts uploaded, PNGs pushed to `ci-renders` branch under `pr-{N}/`
- A comment appears on the PR with a 4-column render table showing embedded images
- `validate` job passes: all 4 STLs pass manifold/bounds/triangle checks
- A second comment appears on the PR with the validation table (all ✅ PASS)

- [ ] **Step 2: Push a second commit to the same PR**

```bash
git commit --allow-empty -m "test: trigger CI again"
git push
```

Expected: the two PR comments are **updated in place**, not duplicated.

- [ ] **Step 3: Merge the PR and confirm master CI runs cleanly**

Expected: `build-and-render` and `validate` jobs both pass; no PR comment steps run (they are guarded by `github.event_name == 'pull_request'`).

- [ ] **Step 4: Push a version tag**

```bash
git tag v0.1.0
git push origin v0.1.0
```

Expected: `release.yml` triggers, `build` job exports STLs, `release` job creates a GitHub Release named "Release v0.1.0" with all 4 STL files attached as assets and auto-generated release notes.

- [ ] **Step 5: Verify validation failure path**

On a new branch, temporarily rename an STL in `export.sh` to produce a wrong filename, push, and open a PR. Expected: `validate` job exits 1, the validation PR comment shows ❌ FAIL rows.

Revert the change before merging.
