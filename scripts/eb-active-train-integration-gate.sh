#!/usr/bin/env bash
set -euo pipefail
test -f docs/codex/batch-trains/EB01_EB40_EXTERNAL_BRAIN_FOUNDATION_TRAIN.md
count=$(find docs/codex/batches -name 'EB*.md' | wc -l | tr -d ' ')
test "$count" = "40"
rg -n "External Brain.*active planned Ambitions 4.0|New active planned total: 153|EB01" docs/codex/GLOBAL_FUTURE_BATCH_EXECUTION_ORDER.md docs/codex/BATCH_REGISTRY.md .codex/reports/current-run-state.md
