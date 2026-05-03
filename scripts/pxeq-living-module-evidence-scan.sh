#!/usr/bin/env bash
set -u
ROOT="$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)"
cd "$ROOT"
echo "pxeq-living-module-evidence-scan: advisory"
rg -n -i "living|evolving|state inputs|primary visual object|before/after product experience|preview evidence|fixture evidence" docs/codex docs/audits .codex 2>/dev/null || true
echo "YELLOW advisory scan complete"

