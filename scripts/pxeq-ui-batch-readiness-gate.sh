#!/usr/bin/env bash
set -u
ROOT="$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)"
cd "$ROOT"
echo "pxeq-ui-batch-readiness-gate"
missing=0
for f in docs/codex/PXEQ_PRODUCT_EXPERIENCE_EQUIVALENCE_GATE.md docs/codex/PXEQ_LIVING_INTERFACE_RUBRIC.md docs/codex/PXEQ_SURFACE_BEHAVIOR_MATRIX.md docs/codex/PXEQ_VISUAL_SYSTEM_CONSERVATIVE_FUTURISM_RULES.md docs/codex/PXEQ_MOTION_AND_STATE_CHANGE_RULES.md docs/codex/PXEQ_MINIMALISM_WITH_UTILITY_RULES.md docs/codex/PXEQ_UI_IMPLEMENTATION_EVIDENCE_TEMPLATE.md .codex/review-boards/product-experience-equivalence-board.md; do
  test -f "$f" || { echo "RED missing $f"; missing=1; }
done
if ! rg -q "PXEQ" docs/codex/GLOBAL_FUTURE_BATCH_GATE_MATRIX.md docs/codex/batches/EB*.md; then
  echo "RED PXEQ is not wired into gate matrix and EB prompts"
  missing=1
fi
[ "$missing" -eq 0 ] && echo "GREEN PXEQ UI readiness gate is installed"
exit "$missing"

