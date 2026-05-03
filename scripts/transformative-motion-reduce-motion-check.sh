#!/usr/bin/env bash
set -u
ROOT="$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)"
cd "$ROOT"
echo "transformative-motion-reduce-motion-check"
test -f docs/canon/Ambitions_4_0_Reduce_Motion_Transformation_Equivalents.md || { echo "RED missing Reduce Motion equivalents"; exit 1; }
rg -n "Reduce Motion|reduceMotion|accessibilityReduceMotion" docs/canon docs/codex Native/Ambitions Sources 2>/dev/null || true
echo "YELLOW until implementation batches prove every primitive"
