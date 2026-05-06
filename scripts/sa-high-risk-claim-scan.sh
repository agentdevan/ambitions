#!/usr/bin/env bash
set -euo pipefail

# Advisory scan: checks high-risk Source Atlas claim categories remain review-bound.
# Non-mutating.

ROOT="$(git rev-parse --show-toplevel 2>/dev/null || pwd)"
cd "$ROOT"

status=0
HAYSTACK="docs/codex docs/canon .codex/skills"

for term in legalCivic educationEligibility certificationEligibility deadlineSensitive professionalBoundary healthMedical financial minorStudentData; do
  if ! grep -R "$term" $HAYSTACK >/dev/null 2>&1; then
    echo "SA HIGH RISK WARNING: missing risk class $term"
    status=1
  fi
done

exit "$status"
