#!/usr/bin/env bash
set -euo pipefail

# Advisory scan: verifies user-provided sources are not treated as official.
# Non-mutating.

ROOT="$(git rev-parse --show-toplevel 2>/dev/null || pwd)"
cd "$ROOT"

status=0

if ! grep -RIn "user-provided-is-not-official\|userProvided\|user-provided.*not official" docs/codex docs/canon .codex/skills >/dev/null 2>&1; then
  echo "SA USER SOURCE WARNING: user-provided-is-not-official boundary not found."
  status=1
fi

if grep -RInE "user-provided.*official by default|OCR.*official by default|copied text.*official by default" docs/codex docs/canon .codex/skills >/tmp/sa-user-source-scan.$$ 2>/dev/null; then
  cat /tmp/sa-user-source-scan.$$
  rm -f /tmp/sa-user-source-scan.$$
  echo "SA USER SOURCE WARNING: risky official-by-default wording detected."
  status=1
else
  rm -f /tmp/sa-user-source-scan.$$
fi

exit "$status"
