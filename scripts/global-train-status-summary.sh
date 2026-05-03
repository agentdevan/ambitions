#!/usr/bin/env bash
set -u
ROOT="$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)"
cd "$ROOT"
echo "global-train-status-summary.sh: Codex OS deterministic status summary"
if rg -q "Complete: EB01|EB01 .*complete|EB01 is complete" docs/codex/BATCH_REGISTRY.md .codex/reports/current-run-state.md docs/codex/GLOBAL_FUTURE_BATCH_EXECUTION_ORDER.md; then
  current="048"
  last="EB01 complete as source-truth evidence"
  next="EB13 Trust Privacy User Control Canon"
else
  current="047"
  last="CS09 accepted Yellow / parked; External Brain integration committed"
  next="EB01 External Brain Source Truth And Kernel Architecture"
fi
echo "Active train: Ambitions 4.0 External Brain Foundation"
echo "Current global order: $current"
echo "Total planned batches: 153"
echo "Last completed/accepted state: $last"
echo "Next eligible batch: $next"
echo "Working tree:"
git status --short
