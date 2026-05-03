#!/usr/bin/env bash
set -u
ROOT="$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)"
cd "$ROOT"

last_commit="$(git rev-parse --short HEAD 2>/dev/null || echo unknown)"
dirty="$(git status --short 2>/dev/null || true)"
next="$(scripts/global-train-next-batch.sh 2>/dev/null || true)"
active="$(grep -m 1 '^Current batch:' .codex/reports/current-batch-train-state.md 2>/dev/null | sed 's/^Current batch: //')"

echo "Resume Ambitions global patch train from current repo truth."
echo
echo "Last commit: $last_commit"
echo "Current active batch: ${active:-unknown}"
echo "$next"
echo
echo "Dirty files:"
if [ -n "$dirty" ]; then
  echo "$dirty"
else
  echo "clean"
fi
echo
echo "First commands:"
cat <<'COMMANDS'
git status --short
git branch --show-current
git log --oneline -8
cat .codex/reports/current-run-state.md || true
cat .codex/reports/current-batch-train-state.md || true
scripts/global-train-next-batch.sh || true
scripts/global-train-status-summary.sh || true
scripts/batch-train-gate-check.sh || true
COMMANDS
echo
echo "Required validation baseline:"
cat <<'COMMANDS'
git diff --check
scripts/photo-matched-reference-assets-check.sh || true
scripts/dav-product-experience-scorecard.sh || true
scripts/batch-train-gate-check.sh || true
COMMANDS
echo
echo "Open Yellow ledger: docs/codex/YELLOW_OWNER_LEDGER.md"
echo "Do not restart completed batches. Do not discard uncommitted work without inspection. Do not fake proof."
