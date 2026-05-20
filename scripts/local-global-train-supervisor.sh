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

  cat <<'MSG'
Refusing to auto-stage or auto-push runner output.
Broad staging is not allowed for Ambitions trains.

Next step:
  1. Review the changed paths above.
  2. Stage only runner-owned, batch-scoped paths from a normal Codex session.
  3. Commit and push explicitly after validation.
MSG
  exit 7
done

echo "Reached MAX_LOOPS=$MAX_LOOPS. Stopping."
exit 13
