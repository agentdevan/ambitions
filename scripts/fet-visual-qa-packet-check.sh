#!/usr/bin/env bash
set -u

root="$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)"
cd "$root" || exit 1

echo "== FET visual QA packet check =="
echo "Scope: advisory read-only check for screenshot/preview evidence packet structure and references."
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

standard="docs/codex/FRONTEND_SCREENSHOT_EVIDENCE_STANDARD.md"
if [[ -f "$standard" ]]; then
  echo "FOUND $standard"
else
  echo "RED_MISSING $standard"
fi

packet_dirs=$(find docs/audits/screenshots -maxdepth 2 -type d 2>/dev/null | sort || true)
if [[ -n "$packet_dirs" ]]; then
  echo "-- screenshot packet directories --"
  echo "$packet_dirs"
else
  echo "YELLOW_HINT no docs/audits/screenshots packet directories found. Docs/tooling-only batches may classify this as not applicable; UI-touching batches cannot close Green without rendered evidence."
fi

echo "-- evidence references --"
rg -n "screenshot|simulator|preview screenshot|preview evidence|rendered visual|visual QA|FET scorecard|frontend scorecard|first viewport|above the fold|Dynamic Type|VoiceOver|Reduce Motion" docs/audits docs/codex .codex 2>/dev/null | head -360 || true

echo
echo "Required UI packet shape: docs/audits/screenshots/<batch-id>/<batch-id>-<surface>-after-dark.png plus metadata/limitations, or documented preview screenshot equivalents. Build logs are not visual evidence."
exit 0
