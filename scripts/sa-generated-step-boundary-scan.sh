#!/usr/bin/env bash
set -euo pipefail

# Advisory scan: flags Source Atlas packs/runtime attempting to store universal scheduled plans.
# Non-mutating. Does not print private source contents.

ROOT="$(git rev-parse --show-toplevel 2>/dev/null || pwd)"
cd "$ROOT"

status=0
SEARCH_ROOTS=("docs/codex" "docs/canon" "Sources/Ambitions/SourceAtlas" "Resources/SourceAtlas" "tools/source-atlas")
EXISTING=()
for root in "${SEARCH_ROOTS[@]}"; do
  [[ -e "$root" ]] && EXISTING+=("$root")
done

if ! grep -R "StepCandidateSeed\|Steps Are Generated\|generated-step" "${EXISTING[@]}" >/dev/null 2>&1; then
  echo "SA STEP BOUNDARY WARNING: generated-step boundary vocabulary not found."
  status=1
fi

IMPLEMENTATION_ROOTS=()
for root in "Sources/Ambitions/SourceAtlas" "Resources/SourceAtlas" "tools/source-atlas"; do
  [[ -e "$root" ]] && IMPLEMENTATION_ROOTS+=("$root")
done

if [[ "${#IMPLEMENTATION_ROOTS[@]}" -gt 0 ]] && grep -R "universal scheduled step\|identical final plan\|final scheduled plan" "${IMPLEMENTATION_ROOTS[@]}" 2>/dev/null; then
  echo "SA STEP BOUNDARY WARNING: possible universal scheduled plan language detected in Source Atlas implementation assets."
  status=1
fi

exit "$status"
