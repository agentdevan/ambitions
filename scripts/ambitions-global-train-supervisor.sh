#!/usr/bin/env bash
set -Eeuo pipefail

MODE="${1:---once}"
LOCK_FILE=".codex/state/global-train.lock"
LEDGER=".codex/state/global-train-attempt-ledger.md"
QUEUE="docs/codex/GLOBAL_QUEUE_CANONICAL_ORDER.json"
RUNNER="scripts/ambitions-codex-train.sh"
AUDIT="scripts/ambitions-prompt-audit.sh"
PREFLIGHT="scripts/ambitions-process-preflight.sh"
FRONTEND_AUTHORITY_CHECK="scripts/ambitions-global-train-frontend-authority-check.py"
CODEX_OS_SELECTION="build/codex-os/batch-selection.json"
CODEX_OS_NEXT_ACTION="build/codex-os/next-action.json"

die() {
  echo "ERROR: $*" >&2
  exit 1
}

repo_root() {
  git rev-parse --show-toplevel 2>/dev/null || die "not inside a git repo"
}

cd "$(repo_root)"

usage() {
  cat <<'EOF'
Usage:
  scripts/ambitions-global-train-supervisor.sh --status
  scripts/ambitions-global-train-supervisor.sh --next
  scripts/ambitions-global-train-supervisor.sh --once
  scripts/ambitions-global-train-supervisor.sh --until-complete

Default mode: --once
EOF
}

require_base_files() {
  [[ -x "$RUNNER" ]] || die "$RUNNER is missing or not executable"
  [[ -x "$AUDIT" ]] || die "$AUDIT is missing or not executable"
  [[ -x "$PREFLIGHT" ]] || die "$PREFLIGHT is missing or not executable"
  [[ -f "$FRONTEND_AUTHORITY_CHECK" ]] || die "$FRONTEND_AUTHORITY_CHECK is missing"
  [[ -f "$QUEUE" ]] || die "$QUEUE is missing"
  [[ -f "$LEDGER" ]] || die "$LEDGER is missing"
}

active_conflicts() {
  {
    pgrep -fl 'ambitions-codex-train|codex exec' || true
    pgrep -fl '(^|/| )xcodebuild( |$)' || true
  } | awk 'NF' | sort -u
}

require_no_process_conflicts() {
  local preflight_output preflight_exit
  set +e
  preflight_output="$(scripts/ambitions-process-preflight.sh --assert-clear 2>&1)"
  preflight_exit=$?
  set -e
  if [[ "$preflight_exit" -ne 0 ]]; then
    printf '%s\n' "$preflight_output" >&2
    printf '\nDEBUG: broad process scan output after helper classification:\n' >&2
    active_conflicts | awk 'NF' >&2 || true
    exit "$preflight_exit"
  fi
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

write_lock() {
  mkdir -p "$(dirname "$LOCK_FILE")"
  cat >"$LOCK_FILE" <<EOF
pid: $$
command: $0 $MODE
batch: ${1:-unknown}
timestamp: $(date -u +%Y-%m-%dT%H:%M:%SZ)
run_dir: pending
EOF
}

clear_lock() {
  if [[ -f "$LOCK_FILE" ]]; then
    local pid
    pid="$(read_lock_pid)"
    [[ "$pid" == "$$" ]] && rm -f "$LOCK_FILE"
  fi
}

trap clear_lock EXIT

tracked_dirty() {
  git status --porcelain --untracked-files=no
}

require_clean_tracked_worktree() {
  local dirty
  dirty="$(tracked_dirty)"
  if [[ -n "$dirty" ]]; then
    printf 'RED: dirty tracked worktree blocks global train launch:\n%s\n' "$dirty" >&2
    exit 1
  fi
}

queue_next_batch() {
  python3 - "$QUEUE" <<'PY'
import json, sys
path = sys.argv[1]
with open(path, "r", encoding="utf-8") as fh:
    data = json.load(fh)
for batch in data.get("batches", []):
    if batch.get("classification") == "executable_now":
        print(batch.get("id", ""))
        sys.exit(0)
print("")
PY
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

prompt_for_batch() {
  local batch="$1"
  if [[ -f "prompts/batches/${batch}-FINALIZE-01.md" ]]; then
    printf 'prompts/batches/%s-FINALIZE-01.md\n' "$batch"
  else
    printf 'prompts/batches/%s.md\n' "$batch"
  fi
}

next_batch() {
  if [[ -f "$CODEX_OS_SELECTION" ]]; then
    local codex_os_batch
    codex_os_batch="$(python3 - "$CODEX_OS_SELECTION" <<'PY'
import json, sys
path = sys.argv[1]
try:
    with open(path, "r", encoding="utf-8") as fh:
        data = json.load(fh)
except Exception:
    print("")
    raise SystemExit(0)
classification = str(data.get("classification", ""))
if classification in {"executable_now", "active", "queued", "active_partial"}:
    print(data.get("selected_batch", ""))
else:
    print("")
PY
    )"
    if [[ -n "$codex_os_batch" ]]; then
      printf '%s\n' "$codex_os_batch"
      return 0
    fi
  fi
  local finalize_child
  finalize_child="$(ledger_requires_finalization)"
  if [[ -n "$finalize_child" ]]; then
    printf '%s-FINALIZE-01\n' "$finalize_child"
    return 0
  fi
  queue_next_batch
}

next_prompt() {
  local batch="$1"
  if [[ "$batch" == *-FINALIZE-01 ]]; then
    printf 'prompts/batches/%s.md\n' "$batch"
  else
    prompt_for_batch "$batch"
  fi
}

print_status() {
  require_base_files
  echo "Global train supervisor status"
  echo "Repo: $(pwd)"
  echo "Branch: $(git rev-parse --abbrev-ref HEAD)"
  echo "Tracked dirty files:"
  tracked_dirty || true
  echo
  echo "Frontend authority hook: $FRONTEND_AUTHORITY_CHECK"
  echo
  echo "Process conflicts:"
  active_conflicts || true
  echo
  echo "Current ledger attempt:"
  awk '/^## Current Active Attempt/ {show=1} show {print} /^## Attempt History/ {exit}' "$LEDGER"
}

print_next() {
  require_base_files
  python3 -m json.tool "$QUEUE" >/dev/null
  if [[ -f "$CODEX_OS_NEXT_ACTION" ]]; then
    echo "Codex OS next action:"
    python3 -m json.tool "$CODEX_OS_NEXT_ACTION"
    echo
  fi
  local batch prompt
  batch="$(next_batch)"
  if [[ -z "$batch" ]]; then
    echo "Next batch: none"
    echo "Prompt: none"
    echo "Reason: no executable next batch found"
    return 0
  fi
  prompt="$(next_prompt "$batch")"
  echo "Next batch: $batch"
  echo "Prompt: $prompt"
}

audit_prompts() {
  set +e
  "$AUDIT"
  local exit_code=$?
  set -e
  if [[ "$exit_code" -eq 0 ]]; then
    return 0
  fi
  die "prompt audit failed with exit code $exit_code"
}

run_frontend_authority_hook() {
  local batch="$1"
  local prompt="$2"
  python3 "$FRONTEND_AUTHORITY_CHECK" --batch "$batch" --prompt "$prompt"
}

run_once() {
  require_base_files
  python3 -m json.tool "$QUEUE" >/dev/null
  audit_prompts
  require_no_process_conflicts
  require_clean_tracked_worktree
  clear_stale_lock_if_safe

  local batch prompt
  batch="$(next_batch)"
  [[ -n "$batch" ]] || die "no executable next batch found"
  [[ "$batch" != "RUN-GLOBAL-BATCH-TRAIN-TO-COMPLETION" ]] || die "refusing to run the global conductor prompt as a child batch"
  prompt="$(next_prompt "$batch")"
  [[ -f "$prompt" ]] || die "prompt missing: $prompt"

  run_frontend_authority_hook "$batch" "$prompt"

  write_lock "$batch"
  echo "Running one global-train batch through canonical runner: $batch"
  # The supervisor writes its own lock before launching the child runner; tracked
  # dirt is already rejected above, so allow that supervisor-owned untracked lock.
  ALLOW_DIRTY=1 AUTO_BRANCH=0 ALLOW_MAIN_COMMIT=1 make batch BATCH="$batch" PROMPT="$prompt"
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
      *" $batch "*) die "repeated same-batch launch blocked in this supervisor pass: $batch" ;;
    esac
    seen="$seen $batch"
    run_once
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
  --once)
    run_once
    ;;
  --until-complete)
    run_until_complete
    ;;
  *)
    usage >&2
    exit 2
    ;;
esac
