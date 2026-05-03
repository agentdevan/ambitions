#!/usr/bin/env bash
set -euo pipefail
if git diff --name-only HEAD | rg '^(Native|Sources|AppUI|\.github|project.yml|Package|.*\.xcodeproj|.*\.xcprivacy)' ; then
  echo "Forbidden integration boundary touched" >&2
  exit 1
fi
rg -n "Forbidden Files|Allowed Files|production Swift|release-claim" docs/codex/batches/EB*.md
