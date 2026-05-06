#!/usr/bin/env bash
set -euo pipefail

# Advisory scan: checks Source Atlas offline/source-needed fallback requirements.
# Non-mutating.

ROOT="$(git rev-parse --show-toplevel 2>/dev/null || pwd)"
cd "$ROOT"

status=0
HAYSTACK="docs/codex docs/canon .codex/skills"

for term in "offline fallback" "last-known-good" "source-needed" "no internet"; do
  if ! grep -R -i "$term" $HAYSTACK >/dev/null 2>&1; then
    echo "SA OFFLINE WARNING: missing fallback term '$term'"
    status=1
  fi
done

exit "$status"
