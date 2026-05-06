#!/usr/bin/env bash
set -euo pipefail

# Advisory scan: flags obvious duplicate source-pack anti-patterns.
# Non-mutating. Intended to be strengthened once pack schema directories exist.

ROOT="$(git rev-parse --show-toplevel 2>/dev/null || pwd)"
cd "$ROOT"

status=0

PACK_DIRS=("Resources/SourceAtlas" "tools/source-atlas" "Sources/Ambitions/SourceAtlas")
found_dir=0
for dir in "${PACK_DIRS[@]}"; do
  [[ -d "$dir" ]] && found_dir=1
done

if [[ "$found_dir" -eq 0 ]]; then
  echo "SA DUPLICATION INFO: Source Atlas pack/runtime directories not present yet; docs-only stage."
  exit 0
fi

if grep -R "make-varsity-football\.pack\|make-it-to-the-nfl\.pack\|improve-catching\.pack\|become-pickleball-pro\.pack" "${PACK_DIRS[@]}" 2>/dev/null; then
  echo "SA DUPLICATION WARNING: example one-pack-per-goal filenames detected. Use domain/capability/overlay packs instead."
  status=1
fi

exit "$status"
