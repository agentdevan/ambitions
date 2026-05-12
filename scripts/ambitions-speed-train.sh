#!/usr/bin/env bash
set -Eeuo pipefail

REPO_ROOT="$(git rev-parse --show-toplevel 2>/dev/null || pwd -P)"
cd "$REPO_ROOT"

AUTONOMOUS="scripts/ambitions-autonomous-train.sh"
ACCESS_GUARD="scripts/ambitions-runner-access-guard.py"
STALE_CHECK="scripts/ambitions-stale-state-check.py"
QUEUE_GUARD="scripts/ambitions-speed-queue-guard.py"
LANE_POLICY="scripts/ambitions-speed-lane-policy.py"
CLAIM_SCAN="scripts/ambitions-unsupported-claim-scan.py"
PROMPT_AUDIT="scripts/ambitions-prompt-audit.sh"
PROCESS_PREFLIGHT="scripts/ambitions-process-preflight.sh"
QUEUE="docs/codex/GLOBAL_QUEUE_CANONICAL_ORDER.json"

MODE="${1:---status}"
MAX_BATCHES="${MAX_BATCHES:-25}"
SPEED_PUSH="${SPEED_PUSH:-1}"
SPEED_ALLOW_YELLOW="${SPEED_ALLOW_YELLOW:-1}"
SPEED_MAX_REPAIR_PASSES="${SPEED_MAX_REPAIR_PASSES:-1}"
SPEED_ALLOW_DIRTY="${SPEED_ALLOW_DIRTY:-0}"
SPEED_RUN_HEAVY_FINAL_GATE="${SPEED_RUN_HEAVY_FINAL_GATE:-0}"

usage() {
  cat <<'EOF'
Usage:
  scripts/ambitions-speed-train.sh --status
  scripts/ambitions-speed-train.sh --next
  scripts/ambitions-speed-train.sh --once
  scripts/ambitions-speed-train.sh --until-blocked
  scripts/ambitions-speed-train.sh --final-gate

Environment:
  MAX_BATCHES=25                 maximum child batches in one speed run
  SPEED_PUSH=1                   auto-push successful child commits
  SPEED_ALLOW_YELLOW=1           allow accepted Yellow commits/continuation
  SPEED_MAX_REPAIR_PASSES=1      one bounded repair pass per batch
  SPEED_ALLOW_DIRTY=0            require clean preflight unless set to 1
EOF
}

log() {
  printf '[speed-train] %s\n' "$*"
}

fail() {
  printf '[speed-train] ERROR: %s\n' "$*" >&2
  exit 1
}

require_file() {
  local path="$1"
  [[ -e "$path" ]] || fail "missing required file: $path"
}

require_base_files() {
  require_file "$AUTONOMOUS"
  require_file "$ACCESS_GUARD"
  require_file "$STALE_CHECK"
  require_file "$QUEUE_GUARD"
  require_file "$CLAIM_SCAN"
  require_file "$PROMPT_AUDIT"
  require_file "$PROCESS_PREFLIGHT"
  require_file "$QUEUE"
}

next_batch() {
  "$AUTONOMOUS" --next | awk '/^Next batch:/ {print $3; exit}'
}

next_prompt() {
  "$AUTONOMOUS" --next | awk '/^Prompt:/ {print $2; exit}'
}

speed_preflight() {
  require_base_files
  python3 "$ACCESS_GUARD"
  local batch
  batch="$(next_batch)"
  [[ -n "$batch" ]] || fail "no next batch found"
  python3 "$STALE_CHECK"
  python3 "$QUEUE_GUARD" "$batch"
  python3 "$CLAIM_SCAN" docs prompts .codex
  if [[ -f "$LANE_POLICY" ]]; then
    python3 "$LANE_POLICY" "$batch" || true
  fi
  "$PROMPT_AUDIT" >/dev/null
  if [[ "$SPEED_ALLOW_DIRTY" != "1" ]]; then
    "$PROCESS_PREFLIGHT" --assert-clear
  else
    log "SPEED_ALLOW_DIRTY=1; skipping assert-clear preflight"
  fi
}

speed_postflight() {
  python3 "$ACCESS_GUARD"
  python3 "$STALE_CHECK"
  local batch
  batch="$(next_batch || true)"
  if [[ -n "$batch" ]]; then
    python3 "$QUEUE_GUARD" "$batch"
  fi
  python3 "$CLAIM_SCAN" docs prompts .codex
}

status() {
  require_base_files
  log "status"
  git status --short --branch
  echo
  python3 "$ACCESS_GUARD" || true
  "$AUTONOMOUS" --status
  echo
  python3 "$STALE_CHECK" || true
  batch="$(next_batch || true)"
  if [[ -n "$batch" ]]; then
    python3 "$QUEUE_GUARD" "$batch" || true
    if [[ -f "$LANE_POLICY" ]]; then
      python3 "$LANE_POLICY" "$batch" || true
    fi
  fi
  python3 "$CLAIM_SCAN" docs prompts .codex || true
}

run_once() {
  speed_preflight
  local batch prompt
  batch="$(next_batch)"
  prompt="$(next_prompt)"
  [[ -n "$batch" ]] || fail "no next batch found"
  [[ -f "$prompt" ]] || fail "next prompt missing: $prompt"
  log "running one child batch: $batch"
  AUTO_BRANCH=0 \
  ALLOW_MAIN_COMMIT=1 \
  AUTO_COMMIT=1 \
  AUTO_PUSH="$SPEED_PUSH" \
  KEEP_GOING_ON_YELLOW="$SPEED_ALLOW_YELLOW" \
  ALLOW_YELLOW_COMMIT="$SPEED_ALLOW_YELLOW" \
  MAX_REPAIR_PASSES="$SPEED_MAX_REPAIR_PASSES" \
  ACCESS_MODE=full \
  "$AUTONOMOUS" --run-current
  speed_postflight
}

run_until_blocked() {
  speed_preflight
  local count=0
  local seen=""
  while [[ "$count" -lt "$MAX_BATCHES" ]]; do
    local batch prompt
    batch="$(next_batch)"
    prompt="$(next_prompt)"
    [[ -n "$batch" ]] || { log "no next batch found; stopping"; return 0; }
    [[ -f "$prompt" ]] || fail "next prompt missing: $prompt"
    python3 "$ACCESS_GUARD"
    python3 "$QUEUE_GUARD" "$batch"
    case " $seen " in
      *" $batch "*) fail "same-batch loop detected: $batch" ;;
    esac
    seen="$seen $batch"
    count=$((count + 1))
    log "batch $count/$MAX_BATCHES: $batch"
    AUTO_BRANCH=0 \
    ALLOW_MAIN_COMMIT=1 \
    AUTO_COMMIT=1 \
    AUTO_PUSH="$SPEED_PUSH" \
    KEEP_GOING_ON_YELLOW="$SPEED_ALLOW_YELLOW" \
    ALLOW_YELLOW_COMMIT="$SPEED_ALLOW_YELLOW" \
    MAX_REPAIR_PASSES="$SPEED_MAX_REPAIR_PASSES" \
    ACCESS_MODE=full \
    "$AUTONOMOUS" --run-current
    speed_postflight
  done
  log "reached MAX_BATCHES=$MAX_BATCHES; stopping cleanly"
}

final_gate() {
  require_base_files
  log "final heavy gate start"
  git diff --check
  python3 "$ACCESS_GUARD"
  python3 "$STALE_CHECK"
  batch="$(next_batch || true)"
  if [[ -n "$batch" ]]; then
    python3 "$QUEUE_GUARD" "$batch"
  fi
  python3 "$CLAIM_SCAN" docs prompts .codex
  make batch-self-check
  make prompt-audit
  if [[ "$SPEED_RUN_HEAVY_FINAL_GATE" == "1" ]]; then
    xcodegen generate
    scripts/ambitions-xcode-validate.sh --batch SPEED-TRAIN-FINAL-GATE --lane build-for-testing
  else
    log "heavy Xcode validation skipped; set SPEED_RUN_HEAVY_FINAL_GATE=1 to run build-for-testing"
  fi
  log "final heavy gate complete"
}

case "$MODE" in
  -h|--help)
    usage
    ;;
  --status)
    status
    ;;
  --next)
    require_base_files
    python3 "$ACCESS_GUARD"
    "$AUTONOMOUS" --next
    ;;
  --once)
    run_once
    ;;
  --until-blocked|--until-complete)
    run_until_blocked
    ;;
  --final-gate)
    final_gate
    ;;
  *)
    usage >&2
    exit 2
    ;;
esac
