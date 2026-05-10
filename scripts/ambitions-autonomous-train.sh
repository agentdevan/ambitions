#!/usr/bin/env bash
set -Eeuo pipefail

REPO_ROOT="$(git rev-parse --show-toplevel 2>/dev/null || pwd -P)"
cd "$REPO_ROOT"

RUNNER="scripts/ambitions-codex-train.sh"
PREFLIGHT="scripts/ambitions-process-preflight.sh"
AUDIT="scripts/ambitions-prompt-audit.sh"
LEDGER=".codex/state/global-train-attempt-ledger.md"
QUEUE="docs/codex/GLOBAL_QUEUE_CANONICAL_ORDER.json"
LOCK_FILE=".codex/state/global-train.lock"

MODE="${1:---status}"

usage() {
  cat <<'EOF'
Usage:
  scripts/ambitions-autonomous-train.sh --status
  scripts/ambitions-autonomous-train.sh --next
  scripts/ambitions-autonomous-train.sh --run-current
  scripts/ambitions-autonomous-train.sh --until-complete
EOF
}

die() {
  echo "ERROR: $*" >&2
  exit 1
}

require_base_files() {
  [[ -x "$RUNNER" ]] || die "$RUNNER is missing or not executable"
  [[ -x "$PREFLIGHT" ]] || die "$PREFLIGHT is missing or not executable"
  [[ -x "$AUDIT" ]] || die "$AUDIT is missing or not executable"
  [[ -f "$LEDGER" ]] || die "$LEDGER is missing"
  [[ -f "$QUEUE" ]] || die "$QUEUE is missing"
}

read_lock_pid() {
  awk -F': ' '/^pid: / {print $2; exit}' "$LOCK_FILE" 2>/dev/null || true
}

clear_stale_lock_if_safe() {
  [[ -f "$LOCK_FILE" ]] || return 0
  local pid
  pid="$(read_lock_pid)"
  if [[ -n "$pid" ]] && kill -0 "$pid" 2>/dev/null; then
    die "global train lock is active at $LOCK_FILE for pid $pid"
  fi
  rm -f "$LOCK_FILE"
}

ledger_requires_finalization() {
  awk '
    /^## Current Active Attempt/ {active=1; next}
    /^## / && active {exit}
    active && /status: finalization-required/ {found=1}
    active && /selected child batch:/ {child=$0; sub(/.*selected child batch: /, "", child)}
    END {if (found && child != "") print child}
  ' "$LEDGER"
}

queue_next_batch() {
  python3 - "$QUEUE" <<'PY'
import json, sys

path = sys.argv[1]
with open(path, "r", encoding="utf-8") as fh:
    data = json.load(fh)

for batch in data.get("batches", []):
    if batch.get("classification") in {"executable_now", "executable_later"}:
        print(batch.get("id", ""))
        sys.exit(0)

print("")
PY
}

current_batch_prompt() {
  local batch="$1"
  if [[ "$batch" == *-FINALIZE-01 || "$batch" == *-REPAIR-01 ]]; then
    printf 'prompts/batches/%s.md\n' "$batch"
  elif [[ -f "prompts/batches/${batch}-FINALIZE-01.md" ]]; then
    printf 'prompts/batches/%s-FINALIZE-01.md\n' "$batch"
  else
    printf 'prompts/batches/%s.md\n' "$batch"
  fi
}

next_batch() {
  local finalize_child
  finalize_child="$(ledger_requires_finalization)"
  if [[ -n "$finalize_child" ]]; then
    printf '%s-FINALIZE-01\n' "$finalize_child"
    return 0
  fi

  queue_next_batch
}

print_status() {
  require_base_files
  echo "Autonomous train status"
  echo "Repo: $(pwd)"
  echo "Branch: $(git rev-parse --abbrev-ref HEAD)"
  echo "Tracked dirty files:"
  git status --porcelain --untracked-files=no
  echo
  echo "Attempt ledger current status:"
  awk '/^## Current Active Attempt/{show=1} show{print} /^## Attempt History/{exit}' "$LEDGER"
  echo
  echo "Next eligible batch from queue/ledger:"
  local batch batch_prompt
  batch="$(next_batch)"
  if [[ -n "$batch" ]]; then
    batch_prompt="$(current_batch_prompt "$batch")"
    echo "Next batch: $batch"
    echo "Prompt: $batch_prompt"
  else
    echo "No executable next batch found"
  fi
}

print_next() {
  require_base_files
  local batch prompt
  batch="$(next_batch)"
  [[ -n "$batch" ]] || die "no executable next batch found"
  prompt="$(current_batch_prompt "$batch")"
  echo "Next batch: $batch"
  echo "Prompt: $prompt"
}

current_attempt_status() {
  awk '
    /^## Current Active Attempt/ {active=1; next}
    active && /^## / {exit}
    active && /^- status:/ {sub(/^-[[:space:]]*status:[[:space:]]*/, "", $0); print $0; exit}
  ' "$LEDGER"
}

run_batch_once() {
  if [[ "${AMBITIONS_RUNNER_ACTIVE:-0}" == "1" && "${AMBITIONS_AUTONOMOUS_TRAIN_ACTIVE:-0}" != "1" ]]; then
    die "recursive autonomous runner invocation blocked; run the top-level batch launch outside the active runner phase"
  fi

  require_base_files
  local existing_status
  existing_status="$(current_attempt_status)"
  case "$existing_status" in
    yellow-unresolved|red-unresolved|unknown-unresolved|repair-required|blocked)
      die "cannot launch next child batch while attempt-ledger is unresolved: $existing_status"
      ;;
  esac

  "$AUDIT" >/dev/null

  "$PREFLIGHT" --assert-clear

  clear_stale_lock_if_safe

  local batch prompt
  batch="$(next_batch)"
  [[ -n "$batch" ]] || die "no executable next batch found"
  [[ "$batch" != "RUN-GLOBAL-BATCH-TRAIN-TO-COMPLETION" ]] || die "refusing to run the global conductor as a child batch: $batch"
  prompt="$(current_batch_prompt "$batch")"
  [[ -f "$prompt" ]] || die "prompt missing: $prompt"

  echo "Running autonomous global-train batch through canonical runner: $batch"
  AMBITIONS_AUTONOMOUS_TRAIN_ACTIVE=1 AUTO_BRANCH=0 ALLOW_MAIN_COMMIT=1 ALLOW_DIRTY=1 "$RUNNER" "$batch" "$prompt"
}

run_until_complete() {
  local seen=""
  while true; do
    local batch
    batch="$(next_batch)"
    if [[ -z "$batch" ]]; then
      echo "No executable next batch found."
      return 0
    fi

    case " $seen " in
      *" $batch "*)
        die "repeated same-batch launch blocked in this autonomous pass: $batch"
        ;;
    esac
    seen="$seen $batch"

    echo "==> next batch: $batch"
    run_batch_once
  done
}

case "$MODE" in
  -h|--help)
    usage
    ;;
  --status)
    print_status
    ;;
  --next)
    print_next
    ;;
  --run-current)
    run_batch_once
    ;;
  --until-complete)
    run_until_complete
    ;;
  *)
    usage >&2
    exit 2
    ;;
esac
