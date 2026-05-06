#!/usr/bin/env bash
set -euo pipefail

# Advisory scan: checks Source Atlas freshness-state vocabulary is documented.
# Non-mutating.

ROOT="$(git rev-parse --show-toplevel 2>/dev/null || pwd)"
cd "$ROOT"

status=0
HAYSTACK="docs/codex docs/canon .codex/skills"

for term in current aging stale staleCritical sourceChanged disputed revoked unknown needsReview; do
  if ! grep -R "$term" $HAYSTACK >/dev/null 2>&1; then
    echo "SA FRESHNESS WARNING: missing freshness term $term"
    status=1
  fi
done

exit "$status"
