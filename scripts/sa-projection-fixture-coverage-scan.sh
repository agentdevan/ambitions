#!/usr/bin/env bash
set -euo pipefail

# Advisory scan: checks that projection fixture families are represented in docs/tests/fixtures.
# Non-mutating.

ROOT="$(git rev-parse --show-toplevel 2>/dev/null || pwd)"
cd "$ROOT"

status=0
SEARCH_ROOTS=("docs/codex" "docs/canon" "Sources/Ambitions/SourceAtlas" "Resources/SourceAtlas" "tools/source-atlas")
HAYSTACK=()
for root in "${SEARCH_ROOTS[@]}"; do
  [[ -e "$root" ]] && HAYSTACK+=("$root")
done

check_term() {
  local label="$1"
  local pattern="$2"
  if ! grep -R -i "$pattern" "${HAYSTACK[@]}" >/dev/null 2>&1; then
    echo "SA PROJECTION FIXTURE WARNING: missing fixture family for $label"
    status=1
  fi
}

check_term "pickleball skill slice" "pickleball"
check_term "football varsity / NFL" "football"
check_term "U.S. president strict source overlay" "president"
check_term "job posting example-only" "job posting"
check_term "school program strict review" "school program"
check_term "certification strict review" "certification"
check_term "option value / still counts" "still counts\|option value"

exit "$status"
