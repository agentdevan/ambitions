#!/usr/bin/env bash
set -u
ROOT="$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)"
cd "$ROOT"
name="$(basename "$0")"
echo "$name: Codex OS deterministic advisory scan"
test -f docs/codex/EXTERNAL_BRAIN_RISK_REGISTER.md || { echo "RED missing risk register"; exit 1; }
echo "GREEN EB risk register exists"
