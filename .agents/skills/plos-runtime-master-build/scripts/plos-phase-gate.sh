#!/usr/bin/env bash
set -euo pipefail
cd "$(git rev-parse --show-toplevel)"
phase=${1:-M00}; bash scripts/codex/program-phase-gate.sh plos "$phase"
