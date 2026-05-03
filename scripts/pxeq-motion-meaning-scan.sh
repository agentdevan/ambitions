#!/usr/bin/env bash
set -u
ROOT="$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)"
cd "$ROOT"
echo "pxeq-motion-meaning-scan: advisory"
rg -n -i "motion|animation|animated|transition|Reduce Motion|state change|haptic" docs/codex docs/audits .codex Native Sources AppUI 2>/dev/null || true
echo "YELLOW advisory scan complete"

