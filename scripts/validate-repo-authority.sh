#!/usr/bin/env bash
set -euo pipefail

ROOT="${1:-.}"
cd "$ROOT"

status=0

fail() {
  printf 'RED: %s\n' "$1" >&2
  status=1
}

warn() {
  printf 'YELLOW: %s\n' "$1" >&2
}

pass() {
  printf 'GREEN: %s\n' "$1"
}

require_file() {
  local path="$1"
  if [[ ! -f "$path" ]]; then
    fail "missing required file: $path"
  else
    pass "found $path"
  fi
}

require_file README.md
require_file docs/README.md
require_file docs/truth/README.md
require_file docs/status/README.md
require_file docs/status/old-canon-classification-index.md
require_file docs/status/repo-governance-master-cleanup-plan.md
require_file docs/runtime/PRIVATE_LIFE_RUNTIME_PROOF_SPEC.md

if grep -q 'docs/truth/README.md' README.md; then
  pass 'README routes to docs/truth/README.md'
else
  fail 'README does not route to docs/truth/README.md'
fi

if grep -q 'docs/truth/README.md\|truth/README.md' docs/README.md; then
  pass 'docs/README routes to truth files'
else
  fail 'docs/README does not route to truth files'
fi

if [[ -f docs/canon/README.md ]] && grep -qi 'supporting\|historical\|subordinate' docs/canon/README.md; then
  pass 'docs/canon/README is subordinate/supporting/historical'
else
  warn 'docs/canon/README did not clearly state subordinate/supporting/historical posture'
fi

if [[ -f docs/AmbitionsCanon/README.md ]] && grep -qi 'supporting\|subordinate' docs/AmbitionsCanon/README.md; then
  pass 'docs/AmbitionsCanon/README is supporting/subordinate'
else
  warn 'docs/AmbitionsCanon/README did not clearly state supporting/subordinate posture'
fi

# Old active-canon claims in legacy families are high-risk. Ignore archive/audit/status files.
old_active_hits=$(grep -RIn --include='*.md' 'Status: Active canon\|Status: Active Ambitions\|Status: Active .*canon' docs/canon 2>/dev/null \
  | grep -E 'Ambitions_2_0|Ambitions_3_0|Ambitions_4_0|PXOS|ACUI' \
  | grep -v 'SOURCE_OF_TRUTH_MAP.md' || true)
if [[ -n "$old_active_hits" ]]; then
  warn "legacy canon active-status claims remain:"
  printf '%s\n' "$old_active_hits" >&2
else
  pass 'no legacy family active-canon status claims found in docs/canon'
fi

if grep -RIn --include='*.md' 'Today / Goals / Capture / Plan / You' README.md docs/truth docs/status frontend 2>/dev/null \
  | grep -v 'historical\|Historical\|compatibility\|Compatibility\|old-canon\|Train B' >/tmp/ambitions-plan-hits.$$; then
  warn 'potential active Plan top-level IA reference found:'
  cat /tmp/ambitions-plan-hits.$$ >&2
else
  pass 'no obvious active Plan top-level IA reference found in front-door/truth/status/frontend paths'
fi
rm -f /tmp/ambitions-plan-hits.$$

if [[ $status -eq 0 ]]; then
  printf 'Ambitions repo authority validation: GREEN/YELLOW-compatible\n'
else
  printf 'Ambitions repo authority validation: RED\n' >&2
fi

exit "$status"
