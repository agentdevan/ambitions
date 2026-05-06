#!/usr/bin/env bash
set -euo pipefail

# Advisory scan: flags Source Atlas packs/runtime attempting to store universal scheduled plans.
# Non-mutating. Does not print private source contents.

ROOT="$(git rev-parse --show-toplevel 2>/dev/null || pwd)"
cd "$ROOT"

status=0
SEARCH_ROOTS=("docs/codex" "docs/canon" "Sources/Ambitions/SourceAtlas" "Resources/SourceAtlas" "tools/source-atlas")

if ! grep -R "StepCandidateSeed\|Steps Are Generated\|generated-step" "${SEARCH_ROOTS[@]}" >/dev/null 2>&1; then
  echo "SA STEP BOUNDARY WARNING: generated-step boundary vocabulary not found."
  status=1
fi

if grep -R "universal scheduled step\|identical final plan\|final scheduled plan" "Sources/Ambitions/SourceAtlas" "Resources/SourceAtlas" "tools/source-atlas" 2>/dev/null; then
  echo "SA STEP BOUNDARY WARNING: possible universal scheduled plan language detected in Source Atlas implementation assets."
  status=1
fi

exit "$status"
