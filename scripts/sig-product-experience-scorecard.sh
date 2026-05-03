#!/usr/bin/env bash
set -u
ROOT="$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)"
cd "$ROOT"
echo "sig-product-experience-scorecard"
test -f docs/codex/SIG_APPLE_AWARD_CALIBER_SCORECARD.md || { echo "RED missing SIG scorecard"; exit 1; }
rg -q "dark studio premium feel|No visual identity split|Photo-reference fidelity" docs/codex/SIG_APPLE_AWARD_CALIBER_SCORECARD.md && echo "GREEN SIG scorecard present" || { echo "RED incomplete SIG scorecard"; exit 1; }
