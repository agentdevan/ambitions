#!/usr/bin/env bash
set -u

BATCH="${1:?Usage: $0 <BATCH_ID> <PROMPT_FILE>}"
PROMPT="${2:?Usage: $0 <BATCH_ID> <PROMPT_FILE>}"
MAX_LOOPS="${MAX_LOOPS:-300}"

export KEEP_GOING_ON_YELLOW="${KEEP_GOING_ON_YELLOW:-1}"
export AUTO_BRANCH="${AUTO_BRANCH:-0}"

mkdir -p .codex/logs

echo "Supervisor starting:"
echo "  BATCH=$BATCH"
echo "  PROMPT=$PROMPT"
echo "  KEEP_GOING_ON_YELLOW=$KEEP_GOING_ON_YELLOW"
echo "  AUTO_BRANCH=$AUTO_BRANCH"
echo "  MAX_LOOPS=$MAX_LOOPS"

if [[ "$(git branch --show-current)" != "main" ]]; then
  echo "ERROR: not on main. Current branch: $(git branch --show-current)"
  exit 2
fi

if ! git push --dry-run origin main; then
  echo "ERROR: normal terminal cannot push to origin/main. Fix GitHub credentials first."
  exit 3
fi

for i in $(seq 1 "$MAX_LOOPS"); do
  echo
  echo "=============================="
  echo "Supervisor loop $i / $MAX_LOOPS"
  echo "=============================="

  git fetch origin main

  LOCAL="$(git rev-parse main)"
  REMOTE="$(git rev-parse origin/main)"
  if [[ "$LOCAL" != "$REMOTE" ]]; then
    echo "Local main differs from origin/main. Rebasing."
    git rebase origin/main || exit 4
  fi

  LOG=".codex/logs/local-supervisor-${BATCH}-${i}.log"

  set +e
  make batch BATCH="$BATCH" PROMPT="$PROMPT" 2>&1 | tee "$LOG"
  RUNNER_STATUS="${PIPESTATUS[0]}"
  set -e

  echo "Runner exit status: $RUNNER_STATUS"

  if ! git diff --check; then
    echo "ERROR: git diff --check failed."
    exit 5
  fi

  if [[ -z "$(git status --porcelain)" ]]; then
    echo "No worktree changes after loop $i."

    if grep -Eiq "remaining active batches: *0|all active planned batches|full front end installed: *yes|Status: Green" "$LOG"; then
      echo "Train appears complete or cleanly closed."
      exit 0
    fi

    if grep -Eiq "Hard Red|Status: Red" "$LOG"; then
      echo "Runner stopped Red with no committable changes. See $LOG."
      exit 6
    fi

    echo "No changes, but train may not be complete. Stopping to avoid blind looping."
    exit 0
  fi

  echo "Dirty state after runner:"
  git status --short

  git add -A

  if ! git diff --cached --check; then
    echo "ERROR: git diff --cached --check failed."
    exit 7
  fi

  if git diff --cached --quiet; then
    echo "No staged changes after git add."
    exit 0
  fi

  ACTIVE_BATCH="$(python3 - <<'PY'
from pathlib import Path
import re

candidates = [
    Path(".codex/state/active-batch.yml"),
    Path(".codex/reports/current-batch-train-state.md"),
]

text = ""
for p in candidates:
    if p.exists():
        text += "\n" + p.read_text(errors="ignore")

patterns = [
    r"next_eligible_batch:\s*['\"]?([A-Za-z0-9_.-]+)",
    r"active_batch:\s*['\"]?([A-Za-z0-9_.-]+)",
    r"Batch ID:\s*(?:\x60)?([A-Za-z0-9_.-]+)",
    r"\b(PK\d+)\b",
]

for pat in patterns:
    m = re.search(pat, text)
    if m:
        print(m.group(1))
        raise SystemExit

print("GLOBAL-BATCH-TRAIN")
PY
)"

  COMMIT_MSG="${ACTIVE_BATCH}: supervisor checkpoint ${i}"

  echo "Committing: $COMMIT_MSG"
  git commit -m "$COMMIT_MSG" || exit 8

  echo "Pushing to origin/main"
  git push origin main || {
    echo "Push failed. Trying fetch/rebase/push."
    git fetch origin main || exit 9
    git rebase origin/main || exit 10
    git push origin main || exit 11
  }

  echo "Pushed commit:"
  git log --oneline -1

  if grep -Eiq "Hard Red|Status: Red" "$LOG"; then
    echo "Runner reported Red, but changes were committed/pushed. Stopping for inspection. See $LOG."
    exit 12
  fi
done

echo "Reached MAX_LOOPS=$MAX_LOOPS. Stopping."
exit 13
