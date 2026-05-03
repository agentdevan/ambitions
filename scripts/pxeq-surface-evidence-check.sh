#!/usr/bin/env bash
set -u
ROOT="$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)"
cd "$ROOT"
echo "pxeq-surface-evidence-check"
for f in docs/codex/PXEQ_PRODUCT_EXPERIENCE_EQUIVALENCE_GATE.md docs/codex/PXEQ_SURFACE_BEHAVIOR_MATRIX.md docs/codex/PXEQ_UI_IMPLEMENTATION_EVIDENCE_TEMPLATE.md; do
  test -f "$f" || { echo "RED missing $f"; exit 1; }
done
echo "GREEN PXEQ surface evidence files exist"

