#!/usr/bin/env bash
set -euo pipefail

ROOT="$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)"
cd "$ROOT"

python3 scripts/ambitions-quality-gate.py "$@"
python3 scripts/ambitions-global-shell-completion-gate.py
