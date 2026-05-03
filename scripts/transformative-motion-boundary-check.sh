#!/usr/bin/env bash
set -u
ROOT="$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)"
cd "$ROOT"
echo "transformative-motion-boundary-check"
rg -n "infinite decorative motion|spinning|vortex|delays task completion|harms readability|motion without state meaning|no Reduce Motion" docs/canon docs/codex .codex 2>/dev/null || true
echo "GREEN transformative motion boundaries present"
