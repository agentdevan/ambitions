#!/usr/bin/env bash
set -euo pipefail
phase="${1:?usage: amb-master-phase-gate.sh <phase>}"
scripts/codex/program-phase-gate.sh amb-master "$phase"
