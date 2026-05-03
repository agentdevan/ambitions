#!/usr/bin/env bash
set -u
ROOT="$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)"
cd "$ROOT"
echo "dav-visual-primitive-inventory"
missing=0
for term in LivingSurfaceBackground AdaptiveModuleChrome EvidenceLabel PressureGlow ProofPulse ContextAtmosphereLayer QuietCommandSurface GroupedNavigationSystem LivingTabContext StateDrivenMaterialPanel; do
  rg -q "$term" Sources Native/Ambitions docs/codex 2>/dev/null || { echo "YELLOW missing or not yet implemented: $term"; missing=1; }
done
[ "$missing" -eq 0 ] && echo "GREEN DAV primitives inventoried"
exit 0

