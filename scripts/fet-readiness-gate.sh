#!/usr/bin/env bash
set -u

root="$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)"
cd "$root" || exit 1

echo "== FET readiness gate =="
echo "Scope: advisory local gate for FAANG Frontend Excellence source truth, reviewer skills, scripts, and visual-proof discipline."
echo "Non-claim: this gate does not prove current UI quality, screenshots, human visual approval, device proof, accessibility conformance, TestFlight/App Store readiness, or release readiness."
echo

fail=0

required_files=(
  docs/codex/FAANG_FRONTEND_IMPLEMENTATION_OPERATING_SYSTEM.md
  docs/codex/FRONTEND_EXCELLENCE_GATE_MATRIX.md
  docs/codex/batch-trains/FET01_FET12_FAANG_FRONTEND_EXCELLENCE_TRAIN.md
  docs/codex/batches/FET00_FAANG_FRONTEND_CODEX_OS_UPGRADE_PROMPT.md
  .codex/skills/faang-frontend-implementation-lead.md
  .codex/skills/ios-product-design-director.md
  .codex/skills/swiftui-senior-systems-engineer.md
  .codex/skills/first-viewport-composition-reviewer.md
  .codex/skills/screenshot-visual-qa-reviewer.md
  .codex/skills/primitive-misuse-density-reviewer.md
  .codex/skills/bottom-chrome-navigation-reviewer.md
  .codex/skills/copy-compression-product-language-reviewer.md
)

for file in "${required_files[@]}"; do
  if [[ ! -f "$file" ]]; then
    echo "RED_MISSING $file"
    fail=1
  else
    echo "FOUND $file"
  fi
done

required_scripts=(
  scripts/fet-first-viewport-budget-scan.sh
  scripts/fet-bottom-chrome-conflict-scan.sh
  scripts/fet-primitive-density-scan.sh
  scripts/fet-copy-density-scan.sh
  scripts/fet-visual-qa-packet-check.sh
)

for script in "${required_scripts[@]}"; do
  if [[ ! -x "$script" ]]; then
    echo "YELLOW_HINT $script is missing or not executable"
    fail=1
  else
    echo "EXECUTABLE $script"
  fi
done

if [[ -f docs/codex/GLOBAL_BATCH_AUTOMATED_GATE_PROTOCOL.md ]] && ! rg -q "FET readiness gate|FAANG Frontend|Frontend Excellence" docs/codex/GLOBAL_BATCH_AUTOMATED_GATE_PROTOCOL.md; then
  echo "RED_MISSING global gate protocol does not reference FET readiness"
  fail=1
fi

if [[ -f docs/codex/GLOBAL_FUTURE_BATCH_GATE_MATRIX.md ]] && ! rg -q "Frontend Excellence|FET" docs/codex/GLOBAL_FUTURE_BATCH_GATE_MATRIX.md; then
  echo "RED_MISSING global future gate matrix does not reference FET"
  fail=1
fi

scripts/fet-first-viewport-budget-scan.sh || true
echo
scripts/fet-bottom-chrome-conflict-scan.sh || true
echo
scripts/fet-primitive-density-scan.sh || true
echo
scripts/fet-copy-density-scan.sh || true
echo
scripts/fet-visual-qa-packet-check.sh || true

if [[ "$fail" -eq 0 ]]; then
  echo "FET readiness advisory gate complete."
else
  echo "FET readiness advisory gate complete with Red/Yellow setup hints."
fi

exit 0
