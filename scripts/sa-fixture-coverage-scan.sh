#!/usr/bin/env bash
set -euo pipefail

# Advisory scan: broad Source Atlas fixture coverage wrapper.
# Non-mutating.

ROOT="$(git rev-parse --show-toplevel 2>/dev/null || pwd)"
cd "$ROOT"

status=0

if [[ -x "scripts/sa-projection-fixture-coverage-scan.sh" ]]; then
  scripts/sa-projection-fixture-coverage-scan.sh || status=1
else
  bash scripts/sa-projection-fixture-coverage-scan.sh || status=1
fi

exit "$status"
