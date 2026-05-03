#!/usr/bin/env bash
set -u
ROOT="$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)"
cd "$ROOT"
echo "sig-haptics-intent-check"
rg -n "haptic|sensoryFeedback|UIImpactFeedbackGenerator|Premium Tactility|tactility" Native/Ambitions Sources docs/canon docs/codex .codex 2>/dev/null || true
echo "YELLOW until SIG11 haptics/tactility owner batch runs"
