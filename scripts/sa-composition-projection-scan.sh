#!/usr/bin/env bash
set -euo pipefail

# Advisory scan: flags Source Atlas one-pack-per-goal and missing composition/projection references.
# Non-mutating. Does not inspect or print private source contents.

ROOT="$(git rev-parse --show-toplevel 2>/dev/null || pwd)"
cd "$ROOT"

status=0

require_file() {
  local file="$1"
  if [[ ! -f "$file" ]]; then
    echo "SA COMPOSITION WARNING: missing $file"
    status=1
  fi
}

require_file "docs/codex/SOURCE_ATLAS_COMPOSITION_GOAL_PROJECTION_MODEL.md"
require_file "docs/codex/SOURCE_ATLAS_GATE_MATRIX.md"
require_file "docs/codex/batch-trains/SA01_SA32_SOURCE_ATLAS_FULL_MATURITY_TRAIN.md"

if ! grep -R "GoalProjection\|PersonalPathInstance\|ProjectionRecipe\|CapabilityGraph" docs/codex docs/canon .codex/skills >/dev/null 2>&1; then
  echo "SA COMPOSITION WARNING: no composition/projection vocabulary found in docs/canon/docs/codex/.codex/skills"
  status=1
fi

if grep -R "one pack per goal\|one-pack-per-goal" docs/codex docs/canon .codex/skills >/dev/null 2>&1; then
  :
else
  echo "SA COMPOSITION WARNING: one-pack-per-goal prohibition not found"
  status=1
fi

exit "$status"
