#!/usr/bin/env bash
set -u

root="$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)"
cd "$root" || exit 1

echo "== Signature Interface motion and Reduce Motion scan =="
echo "Scope: advisory scan for animation/haptic use and reduced-motion equivalents."

if ! command -v rg >/dev/null 2>&1; then
  echo "YELLOW_HINT ripgrep unavailable; install rg for complete fast scan."
  exit 0
fi

rg -n "withAnimation|\\.animation\\(|transition\\(|matchedGeometryEffect|sensoryFeedback|UIImpactFeedbackGenerator|accessibilityReduceMotion|reduceMotion" Native AppUI Sources 2>/dev/null || true
echo "Motion scan complete; motion work must include explicit Reduce Motion behavior before Green."
