#!/usr/bin/env bash
set -u
ROOT="$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)"
cd "$ROOT"
echo "dav-product-experience-scorecard"
test -f docs/codex/DAV_PRODUCT_EXPERIENCE_SCORECARD.md || { echo "RED missing DAV scorecard"; exit 1; }
rg -q "4/5" docs/codex/DAV_PRODUCT_EXPERIENCE_SCORECARD.md docs/audits 2>/dev/null && echo "GREEN scorecard threshold referenced" || echo "YELLOW scorecard exists; implementation scores pending"
exit 0

