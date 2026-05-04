#!/usr/bin/env bash
set -u
echo "ldi-global-order-consistency-check: LDI train placement and registry consistency"
status=0
files=(
  docs/codex/GLOBAL_FUTURE_BATCH_EXECUTION_ORDER.md
  docs/codex/GLOBAL_FUTURE_BATCH_DEPENDENCY_GRAPH.md
  docs/codex/GLOBAL_FUTURE_BATCH_GATE_MATRIX.md
  docs/codex/BATCH_REGISTRY.md
  docs/codex/CONTEXT_INDEX.md
  docs/codex/batch-trains/LDI01_LDI22_LIVING_DREAM_INTELLIGENCE_TRAIN.md
)
for f in "${files[@]}"; do
  if [[ ! -f "$f" ]]; then
    echo "RED: missing $f"
    status=1
  elif ! rg -q "LDI01" "$f" || ! rg -q "LDI22" "$f" || ! rg -q "Living Dream" "$f"; then
    echo "RED: incomplete LDI01-LDI22/Living Dream reference in $f"
    status=1
  fi
done
if ! rg -q "after AOS30" docs/codex/GLOBAL_FUTURE_BATCH_EXECUTION_ORDER.md docs/codex/LDI_DEPENDENCY_GRAPH.md; then
  echo "RED: default after AOS30 placement not recorded"
  status=1
fi
if [[ "$status" -eq 0 ]]; then
  echo "PASS: LDI appears consistently in global order, dependency, gate, registry, context, and train files."
fi
exit "$status"
