#!/usr/bin/env bash
set -u

echo "== Ambitions batch train preflight =="
echo "branch: $(git branch --show-current 2>/dev/null || true)"
echo "head: $(git rev-parse HEAD 2>/dev/null || true)"
echo "last: $(git log -1 --oneline 2>/dev/null || true)"
echo "status:"
git status --short

required=(
  "docs/codex/AMBITIONS_3_0_BATCH_TRAIN_ORCHESTRATOR.md"
  "docs/codex/BATCH_TRAIN_RUNNER_PROMPT.md"
  "docs/codex/batch-trains/README.md"
  "scripts/build-local.sh"
  "scripts/validate-dev-tools.sh"
)
missing=0
for f in "${required[@]}"; do
  if [[ ! -e "$f" ]]; then
    echo "MISSING_REQUIRED $f"
    missing=1
  fi
done

if git diff --name-only --cached | grep -q '^\.github/workflows/'; then
  echo "RED_HINT staged workflow change detected"
  missing=1
fi

exit "$missing"
