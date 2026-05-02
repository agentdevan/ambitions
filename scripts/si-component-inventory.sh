#!/usr/bin/env bash
set -u

root="$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)"
cd "$root" || exit 1

echo "== Signature Interface component inventory =="
echo "Scope: advisory read-only scan of SwiftUI component names and likely SI primitive families."
echo "Non-claim: this does not prove implementation quality, visual approval, accessibility conformance, or device proof."

if ! command -v rg >/dev/null 2>&1; then
  echo "YELLOW_HINT ripgrep unavailable; install rg for complete fast inventory."
  exit 0
fi

rg -n "AmbitionsSurfaceShell|AdaptivePanel|AmbitionsActionButton|QuietActionButton|GroupedNavigationList|GroupedNavigationRow|DayTimelineRail|HeroStepPanel|LifePathView|MissionControlLane|LifeShapeMap|CaptureAtmosphereComposer|TrustReceiptToast|ProofPreview|SourceFreshnessLabel|SystemProfileHeader|AmbitionsLoadingState|AmbitionsStatusSymbol|AmbitionsInAppModule" Native AppUI Sources 2>/dev/null || true
echo "Inventory complete; classify missing primitives against the active SI batch scope."
