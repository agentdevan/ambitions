#!/usr/bin/env bash
set -u
ROOT="$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)"
cd "$ROOT"
name="$(basename "$0")"
echo "$name: Codex OS deterministic advisory scan"
missing=0
for n in $(seq -w 1 40); do
  ls docs/codex/batches/EB${n}_*.md >/dev/null 2>&1 || { echo "RED missing EB${n} prompt"; missing=1; }
  rg -q "EB${n}" docs/codex/EB_EXTERNAL_BRAIN_DEPENDENCY_GRAPH.md docs/codex/GLOBAL_FUTURE_BATCH_EXECUTION_ORDER.md docs/codex/EB_OPTIMIZED_IMPLEMENTATION_ORDER.md 2>/dev/null || { echo "RED EB${n} missing from graph/order docs"; missing=1; }
done
[ "$missing" -eq 0 ] && echo "GREEN EB01-EB40 present in prompt/order/graph surfaces"
exit "$missing"
