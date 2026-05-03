#!/usr/bin/env bash
set -u
ROOT="$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)"
cd "$ROOT"
echo "sig-reduce-motion-coverage-check"
rg -n "accessibilityReduceMotion|Reduce Motion|reduceMotion|Reduce_Motion" Native/Ambitions Sources docs/canon docs/codex docs/audits .codex 2>/dev/null || true
test -f docs/canon/Ambitions_4_0_Reduce_Motion_Transformation_Equivalents.md || { echo "RED missing Reduce Motion transformation equivalents"; exit 1; }
echo "YELLOW until SIG15/DAV11 closeout verifies all affected surfaces"
