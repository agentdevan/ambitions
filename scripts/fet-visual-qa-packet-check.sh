#!/usr/bin/env bash
set -u

root="$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)"
cd "$root" || exit 1

echo "== FET visual QA packet check =="
echo "Scope: advisory read-only check for screenshot/preview evidence packet references."
echo "Non-claim: this does not create screenshot proof, human visual approval, device proof, accessibility conformance, or release readiness."
echo

if ! command -v rg >/dev/null 2>&1; then
  echo "YELLOW_HINT ripgrep unavailable; install rg for complete fast scan."
  exit 0
fi

changed_ui=$(git diff --name-only -- 'Native/**/*.swift' 'Sources/**/*.swift' 'AppUI/**/*.swift' 2>/dev/null || true)
if [[ -n "$changed_ui" ]]; then
  echo "FET_UI_TOUCH_HINT changed Swift UI-ish files:"
  echo "$changed_ui"
else
  echo "No changed Swift UI files detected in working tree."
fi

evidence_hits=$(rg -n "screenshot|simulator|preview evidence|visual QA|FET scorecard|frontend scorecard|first viewport|above the fold|Dynamic Type|VoiceOver|Reduce Motion" docs/audits docs/codex .codex 2>/dev/null | head -300 || true)
if [[ -n "$evidence_hits" ]]; then
  echo "$evidence_hits"
else
  echo "YELLOW_HINT no visual QA packet references found under docs/audits docs/codex .codex"
fi

echo "Visual QA packet check complete; output is capped at 300 hits. UI-touching batches with no simulator screenshots or preview evidence are hard Red."
