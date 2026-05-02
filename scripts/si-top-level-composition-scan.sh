#!/usr/bin/env bash
set -u

root="$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)"
cd "$root" || exit 1

echo "== Signature Interface top-level composition scan =="
echo "Scope: advisory scan for top-level tab drift and stack-heavy surface hints."

if ! command -v rg >/dev/null 2>&1; then
  echo "YELLOW_HINT ripgrep unavailable; install rg for complete fast scan."
  exit 0
fi

echo "-- Top-level destination mentions --"
rg -n "Today|Goals|Capture|Plan|You|Insights|Habits|Tasks|Profile" Native/Ambitions/App Native/Ambitions/Features docs/canon docs/codex 2>/dev/null || true

echo "-- Potential stack-heavy top-level surfaces --"
rg -n "struct .*Screen|struct .*View|VStack|LazyVStack|ScrollView" Native/Ambitions/Features 2>/dev/null || true

echo "Composition scan complete; reviewers must verify one-primary-object and visual-orientation evidence."
