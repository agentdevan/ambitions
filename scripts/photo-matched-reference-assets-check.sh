#!/usr/bin/env bash
set -u

ROOT="$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)"
cd "$ROOT"

echo "photo-matched-reference-assets-check"

REFERENCE_DIR="docs/reference/visual-targets/ambitionsos-photo-matched"
ASSET_DIR="$REFERENCE_DIR/assets"
README_PATH="$REFERENCE_DIR/README.md"

required_assets=(
  "$ASSET_DIR/ambitionsos-photo-target-01-today.png"
  "$ASSET_DIR/ambitionsos-photo-target-02-surfaces.png"
  "$ASSET_DIR/ambitionsos-photo-target-03-flow.png"
  "$ASSET_DIR/ambitionsos-photo-target-04-memory-trust.png"
)

status=0

if [[ ! -d "$REFERENCE_DIR" ]]; then
  echo "RED missing reference folder: $REFERENCE_DIR"
  status=1
fi

for asset in "${required_assets[@]}"; do
  if [[ ! -f "$asset" ]]; then
    echo "RED missing reference image: $asset"
    status=1
  fi
done

if [[ ! -f "$README_PATH" ]]; then
  echo "RED missing reference README: $README_PATH"
  status=1
fi

if [[ -d "Native/Ambitions/Assets.xcassets" ]]; then
  if find Native/Ambitions/Assets.xcassets -type f -name 'ambitionsos-photo-target-*.png' | rg -q .; then
    echo "RED photo-matched reference image found in production asset catalog"
    find Native/Ambitions/Assets.xcassets -type f -name 'ambitionsos-photo-target-*.png'
    status=1
  fi
fi

old_filename="ambitionsos-photo-target-03-capture-to-proof-"flow".png"
if rg -n --fixed-strings "$old_filename" . \
  --glob '!scripts/photo-matched-reference-assets-check.sh' \
  --glob '!docs/reference/visual-targets/ambitionsos-photo-matched/assets/*.png'; then
  echo "RED old non-Windows-safe reference filename still appears"
  status=1
fi

claim_scan_paths=("$REFERENCE_DIR")
while IFS= read -r report; do
  claim_scan_paths+=("$report")
done < <(find docs/audits -maxdepth 1 -type f -name 'dav*-photo-matched-visual-alignment-report.md' 2>/dev/null | sort)

if rg -n "App Store ready|TestFlight ready|production ready|production-ready|release ready|Apple Design Award winner|Apple Design Award status" "${claim_scan_paths[@]}" \
  --glob '!docs/reference/visual-targets/ambitionsos-photo-matched/assets/*.png'; then
  echo "RED unsupported readiness or award claim found near photo-matched references"
  status=1
fi

if [[ "$status" -eq 0 ]]; then
  echo "GREEN photo-matched reference assets verified"
fi

exit "$status"
