#!/usr/bin/env bash
set -Eeuo pipefail

# Owner-authorized Ambitions batch entrypoint.
#
# Preferred command when the owner wants Codex to run with full local repo access
# while preserving Ambitions governance gates, repo-doctor enforcement, and
# runner metadata requirements.
#
# Usage:
#   scripts/ambitions-authorized-batch.sh BATCH_ID path/to/prompt.md

if [[ "$#" -ne 2 ]]; then
  echo "Usage: scripts/ambitions-authorized-batch.sh BATCH_ID path/to/prompt.md" >&2
  exit 2
fi

BATCH_ID="$1"
PROMPT_FILE="$2"

command -v git >/dev/null 2>&1 || { echo "git is unavailable" >&2; exit 1; }
REPO_ROOT="$(git rev-parse --show-toplevel 2>/dev/null)" || { echo "not inside a git repo" >&2; exit 1; }
cd "$REPO_ROOT"

REPO_DOCTOR="scripts/governance/ambitions-repo-doctor.py"
CODEx_OS_SYNC="python3 scripts/codex-os/ambitions-codex-os-sync-governance.py"
RUNNER="scripts/ambitions-codex-train.sh"

[[ -f "$REPO_DOCTOR" ]] || { echo "missing repo doctor: $REPO_DOCTOR" >&2; exit 1; }
[[ -f "$RUNNER" ]] || { echo "missing runner: $RUNNER" >&2; exit 1; }

echo "Ambitions authorized batch preflight: repo doctor"
PRE_EXIT=0
python3 "$REPO_DOCTOR" || PRE_EXIT=$?

echo "Ambitions authorized batch preflight: Codex OS sync"
$CODEx_OS_SYNC || PRE_EXIT=$?

if [[ "$PRE_EXIT" -ne 0 ]]; then
  echo "Ambitions authorized batch preflight failed with exit code $PRE_EXIT" >&2
  exit "$PRE_EXIT"
fi

echo "Ambitions authorized batch: running $BATCH_ID"
ACCESS_MODE="${ACCESS_MODE:-full}" \
AUTO_BRANCH="${AUTO_BRANCH:-1}" \
AUTO_COMMIT="${AUTO_COMMIT:-1}" \
AUTO_PUSH="${AUTO_PUSH:-0}" \
ALLOW_DIRTY="${ALLOW_DIRTY:-0}" \
MAX_REPAIR_PASSES="${MAX_REPAIR_PASSES:-2}" \
KEEP_GOING_ON_YELLOW="${KEEP_GOING_ON_YELLOW:-1}" \
set +e
bash "$RUNNER" "$BATCH_ID" "$PROMPT_FILE"
RUN_EXIT=$?
set -e

echo "Ambitions authorized batch closeout: repo doctor"
POST_EXIT=0
python3 "$REPO_DOCTOR" || POST_EXIT=$?

echo "Ambitions authorized batch closeout: Codex OS sync"
$CODEx_OS_SYNC || POST_EXIT=$?

LATEST_RUN_DIR="$(find ".codex/runs/$BATCH_ID" -mindepth 1 -maxdepth 1 -type d 2>/dev/null | sort | tail -1 || true)"
if [[ -n "$LATEST_RUN_DIR" ]]; then
  SUMMARY_PATH="$LATEST_RUN_DIR/final-summary.md"
  mkdir -p build/codex-os
  cat > build/codex-os/authorized-batch-summary.txt <<EOF
batch_id=$BATCH_ID
prompt_file=$PROMPT_FILE
run_dir=$LATEST_RUN_DIR
final_summary_path=$SUMMARY_PATH
EOF
  echo "Authorized batch final summary path: $SUMMARY_PATH"
else
  echo "Authorized batch final summary path unavailable"
fi

FINAL_EXIT="$RUN_EXIT"
if [[ "$FINAL_EXIT" -eq 0 && "$POST_EXIT" -ne 0 ]]; then
  FINAL_EXIT="$POST_EXIT"
fi

if [[ "$POST_EXIT" -ne 0 ]]; then
  echo "Ambitions authorized batch closeout finished with exit code $POST_EXIT" >&2
fi

exit "$FINAL_EXIT"
