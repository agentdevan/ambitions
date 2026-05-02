#!/usr/bin/env bash
set -u

root="$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)"
cd "$root" || exit 1

echo "== Signature Interface readiness gate =="
echo "Scope: advisory local gate for SI docs, prompts, scripts, and UI-quality scan readiness."
echo "Non-claim: this gate does not prove SI implementation, human visual approval, device proof, accessibility conformance, or release readiness."
echo

fail=0

if [[ ! -f docs/canon/Ambitions_Signature_Interface_System.md ]]; then
  echo "YELLOW_HINT missing SI canon until formalization creates it"
fi

if [[ -d docs/codex/batches ]]; then
  count=$(find docs/codex/batches -name 'SI*.md' | wc -l | tr -d ' ')
  echo "SI_PROMPT_COUNT $count"
fi

for script in \
  scripts/si-component-inventory.sh \
  scripts/si-anti-generic-ui-scan.sh \
  scripts/si-top-level-composition-scan.sh \
  scripts/si-preview-coverage-scan.sh \
  scripts/si-accessibility-scan.sh \
  scripts/si-motion-reduce-motion-scan.sh \
  scripts/si-file-size-scan.sh \
  scripts/si-symbol-grammar-scan.sh; do
  if [[ ! -x "$script" ]]; then
    echo "YELLOW_HINT $script is missing or not executable"
    fail=1
  fi
done

scripts/si-visual-qa-report.sh || true

if [[ "$fail" -eq 0 ]]; then
  echo "SI readiness advisory gate complete."
else
  echo "SI readiness advisory gate complete with script setup hints."
fi

exit 0
