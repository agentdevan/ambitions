#!/usr/bin/env bash
set -u
ROOT="$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)"
cd "$ROOT"
echo "global-train-next-batch.sh: Codex OS deterministic next-batch calculation"
if rg -q "Complete: EB01|EB01 .*complete|EB01 is complete" docs/codex/BATCH_REGISTRY.md .codex/reports/current-run-state.md docs/codex/GLOBAL_FUTURE_BATCH_EXECUTION_ORDER.md; then
  echo "Next eligible batch: EB13 Trust Privacy User Control Canon"
  echo "Reason: EB01 is complete; EB13 is the optimized Trust/Privacy/User Control gate before durable memory"
else
  echo "Next eligible batch: EB01 External Brain Source Truth And Kernel Architecture"
  echo "Reason: no EB batch is complete; EB01 precedes all EB work"
fi
