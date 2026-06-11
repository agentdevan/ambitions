#!/usr/bin/env bash
set -euo pipefail
cd "$(git rev-parse --show-toplevel)"
bash scripts/codex/program-phase-gate.sh source-atlas Pack
