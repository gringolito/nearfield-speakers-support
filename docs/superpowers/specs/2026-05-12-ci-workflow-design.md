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
