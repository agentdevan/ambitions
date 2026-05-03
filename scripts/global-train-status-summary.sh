#!/usr/bin/env bash
set -u
ROOT="$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)"
cd "$ROOT"
echo "global-train-status-summary.sh: Codex OS deterministic status summary"
completed() {
  local id="$1"
  rg -q "Complete: $id|$id .*complete|$id is complete|\| [0-9]{3} \| $id \| .*No; complete" docs/codex/BATCH_REGISTRY.md .codex/reports/current-run-state.md docs/codex/GLOBAL_FUTURE_BATCH_EXECUTION_ORDER.md 2>/dev/null
}
for id in EB01 EB13 EB25 EB19 EB02 EB07 EB31 EB32; do
  if ! completed "$id"; then
    case "$id" in
    EB01) name="External Brain Source Truth And Kernel Architecture"; global="047" ;;
    EB13) name="Trust Privacy User Control Canon"; global="048" ;;
    EB25) name="Accessibility Cognitive Load Canon"; global="049" ;;
    EB19) name="Product Maturity Onboarding Canon"; global="050" ;;
    EB02) name="Universal Capture Canon And Domain Model"; global="051" ;;
    EB07) name="Life Memory Graph Canon And Domain Model"; global="052" ;;
    EB31) name="Cross Kernel Primitives And Event Receipts"; global="053" ;;
    EB32) name="Cross Kernel Dependency And Gate Integration"; global="054" ;;
      *) name="Unknown"; global="unknown" ;;
    esac
    echo "Next eligible batch: $id $name"
    echo "Global order: $global"
    exit 0
  fi
done
echo "Next eligible batch: EB20 Value Based Onboarding And First Week Success"
echo "Global order: 055"

echo "Active train: Ambitions 4.0 External Brain Foundation"
echo "Total planned batches: 153"
echo "Working tree:"
git status --short
