#!/usr/bin/env bash
set -u
status=0
echo "ldi-gate-check: required Living Dream source truth and train registration"
required=(
  "docs/canon/AmbitionsOS_Living_Dream_Architecture_Index.md"
  "docs/canon/AmbitionsOS_Living_Dream_System_Map.md"
  "docs/canon/AmbitionsOS_Dream_Handling_Lanes_And_Ladder.md"
  "docs/canon/AmbitionsOS_Source_Claim_Graph_And_Pack_System.md"
  "docs/canon/AmbitionsOS_Living_Plan_Recompiler.md"
  "docs/canon/AmbitionsOS_Safety_Legality_Feasibility_Triage.md"
  "docs/canon/AmbitionsOS_Continuity_Sync_Archive_And_Merge.md"
  "docs/canon/AmbitionsOS_LDI_Evaluation_And_Governance.md"
  "docs/codex/batch-trains/LDI01_LDI22_LIVING_DREAM_INTELLIGENCE_TRAIN.md"
  "docs/codex/LDI_BATCH_GATE_MATRIX.md"
  "docs/codex/LDI_DEPENDENCY_GRAPH.md"
  "docs/codex/LDI_INVARIANT_LEDGER.md"
  "docs/codex/LDI_FIXTURE_STRATEGY.md"
  "docs/codex/LDI_SOURCE_PACK_SCHEMA.md"
  "docs/codex/LDI_ROADMAP_TO_IMPLEMENTATION_REORDER_PROTOCOL.md"
)
for f in "${required[@]}"; do
  if [[ ! -f "$f" ]]; then
    echo "RED: missing required LDI artifact: $f"
    status=1
  fi
done
for f in docs/codex/GLOBAL_FUTURE_BATCH_EXECUTION_ORDER.md docs/codex/GLOBAL_FUTURE_BATCH_DEPENDENCY_GRAPH.md docs/codex/GLOBAL_FUTURE_BATCH_GATE_MATRIX.md docs/codex/BATCH_REGISTRY.md docs/codex/CONTEXT_INDEX.md; do
  if ! rg -q "LDI01|Living Dream" "$f"; then
    echo "RED: missing LDI registry reference in $f"
    status=1
  fi
done
for n in $(seq -w 1 22); do
  if ! rg -q "LDI$n" docs/codex/batches docs/codex/batch-trains/LDI01_LDI22_LIVING_DREAM_INTELLIGENCE_TRAIN.md; then
    echo "RED: missing LDI$n prompt or train reference"
    status=1
  fi
done
if [[ -x scripts/ldi-release-claim-scan.sh ]]; then
  scripts/ldi-release-claim-scan.sh || status=1
fi
if [[ "$status" -eq 0 ]]; then
  echo "PASS: LDI source truth, train, prompts, and registry references are present."
fi
exit "$status"
