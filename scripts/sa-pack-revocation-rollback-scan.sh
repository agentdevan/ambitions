#!/usr/bin/env bash
set -euo pipefail

# Advisory scan: checks revocation/rollback language for Source Atlas packs.
# Non-mutating.

ROOT="$(git rev-parse --show-toplevel 2>/dev/null || pwd)"
cd "$ROOT"

status=0
HAYSTACK="docs/codex docs/canon .codex/skills"

for term in revoked rollback quarantine invalid corrupt hash signature; do
  if ! grep -R -i "$term" $HAYSTACK >/dev/null 2>&1; then
    echo "SA REVOCATION WARNING: missing pack safety term $term"
    status=1
  fi
done

exit "$status"
