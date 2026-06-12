#!/usr/bin/env bash
set -u
root_dir() { git rev-parse --show-toplevel 2>/dev/null || pwd; }
root="$(root_dir)"
cd "$root" || exit 2
python3 scripts/codex/source-atlas-readiness-validate.py "$@"
