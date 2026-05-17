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
RUNNER="scripts/ambitions-codex-train.sh"

[[ -f "$REPO_DOCTOR" ]] || { echo "missing repo doctor: $REPO_DOCTOR" >&2; exit 1; }
[[ -f "$RUNNER" ]] || { echo "missing runner: $RUNNER" >&2; exit 1; }

echo "Ambitions authorized batch preflight: repo doctor"
python3 "$REPO_DOCTOR"

echo "Ambitions authorized batch: running $BATCH_ID"
ACCESS_MODE="${ACCESS_MODE:-full}" \
AUTO_BRANCH="${AUTO_BRANCH:-1}" \
AUTO_COMMIT="${AUTO_COMMIT:-1}" \
AUTO_PUSH="${AUTO_PUSH:-0}" \
ALLOW_DIRTY="${ALLOW_DIRTY:-0}" \
MAX_REPAIR_PASSES="${MAX_REPAIR_PASSES:-2}" \
KEEP_GOING_ON_YELLOW="${KEEP_GOING_ON_YELLOW:-1}" \
bash "$RUNNER" "$BATCH_ID" "$PROMPT_FILE"

echo "Ambitions authorized batch closeout: repo doctor"
python3 "$REPO_DOCTOR"
