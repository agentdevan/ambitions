#!/usr/bin/env bash
set -Eeuo pipefail

REPO_ROOT="$(git rev-parse --show-toplevel 2>/dev/null || pwd -P)"
cd "$REPO_ROOT"

AUTONOMOUS="scripts/ambitions-autonomous-train.sh"
ROUTER="scripts/ambitions-post-pk-speed-router.py"
STATE_VALIDATE="scripts/ambitions-state-advance-validate.py"
PROMPT_CHECK="scripts/ambitions-prompt-queue-consistency.py"
REPAIR_CLASSIFIER="scripts/ambitions-repair-classifier.py"
BUNDLE_PLANNER="scripts/ambitions-bundle-next-batches.py"
RUNNER_ACCESS="scripts/ambitions-runner-access-guard.py"

MODE="${1:---status}"
MAX_BATCHES="${MAX_BATCHES:-25}"
ALLOW_PK_IN_POST_PK_SPEED="${ALLOW_PK_IN_POST_PK_SPEED:-0}"

log() {
  printf '[post-pk-speed] %s\n' "$*"
}

fail() {
  printf '[post-pk-speed] ERROR: %s\n' "$*" >&2
  exit 1
}

require_file() {
  [[ -e "$1" ]] || fail "missing required file: $1"
}

require_base() {
  require_file "$AUTONOMOUS"
  require_file "$ROUTER"
  require_file "$STATE_VALIDATE"
  require_file "$PROMPT_CHECK"
  require_file "$REPAIR_CLASSIFIER"
  require_file "$BUNDLE_PLANNER"
  require_file "$RUNNER_ACCESS"
}

next_batch() {
  python3 "$ROUTER" --next | awk '{print $1; exit}'
}

ensure_post_pk_batch() {
  local batch="$1"
  if [[ "$batch" == PK* && "$ALLOW_PK_IN_POST_PK_SPEED" != "1" ]]; then
    fail "post-PK speed train refuses PK batch $batch; finish PK with current process or set ALLOW_PK_IN_POST_PK_SPEED=1 intentionally"
  fi
}

preflight() {
  require_base
  python3 "$RUNNER_ACCESS"
  python3 "$STATE_VALIDATE"
  local batch
  batch="$(next_batch)"
  [[ -n "$batch" ]] || fail "no executable batch found"
  ensure_post_pk_batch "$batch"
  python3 "$PROMPT_CHECK" "$batch"
  python3 "$ROUTER" --batch "$batch"
}

run_once() {
  preflight
  local batch
  batch="$(next_batch)"
  log "running one post-PK child batch: $batch"
  ACCESS_MODE=bypass \
  AUTO_BRANCH=0 \
  ALLOW_MAIN_COMMIT=1 \
  AUTO_COMMIT=1 \
  AUTO_PUSH=1 \
  KEEP_GOING_ON_YELLOW=1 \
  ALLOW_YELLOW_COMMIT=1 \
  MAX_REPAIR_PASSES=1 \
  "$AUTONOMOUS" --run-current
  python3 "$STATE_VALIDATE"
}

run_until_blocked() {
  preflight
  local count=0
  local seen=""
  while [[ "$count" -lt "$MAX_BATCHES" ]]; do
    local batch
    batch="$(next_batch)"
    [[ -n "$batch" ]] || { log "no executable batch found; stopping"; return 0; }
    ensure_post_pk_batch "$batch"
    case " $seen " in
      *" $batch "*) fail "same-batch loop detected: $batch" ;;
    esac
    seen="$seen $batch"
    count=$((count + 1))
    log "batch $count/$MAX_BATCHES: $batch"
    set +e
    ACCESS_MODE=bypass \
    AUTO_BRANCH=0 \
    ALLOW_MAIN_COMMIT=1 \
    AUTO_COMMIT=1 \
    AUTO_PUSH=1 \
    KEEP_GOING_ON_YELLOW=1 \
    ALLOW_YELLOW_COMMIT=1 \
    MAX_REPAIR_PASSES=1 \
    "$AUTONOMOUS" --run-current
    local exit_code=$?
    set -e
    if [[ "$exit_code" -ne 0 ]]; then
      log "child batch failed; classifying latest runner output"
      latest="$(find .codex/runs -mindepth 3 -maxdepth 3 -name '*.final.md' 2>/dev/null | sort | tail -1 || true)"
      if [[ -n "$latest" ]]; then
        python3 "$REPAIR_CLASSIFIER" "$latest" || true
      fi
      exit "$exit_code"
    fi
    python3 "$STATE_VALIDATE"
  done
  log "reached MAX_BATCHES=$MAX_BATCHES; stopping cleanly"
}

status() {
  require_base
  git status --short --branch
  python3 "$RUNNER_ACCESS" || true
  python3 "$STATE_VALIDATE" || true
  python3 "$ROUTER" || true
  python3 "$BUNDLE_PLANNER" --next || true
}

final_gate() {
  require_base
  git diff --check
  python3 "$RUNNER_ACCESS"
  python3 "$STATE_VALIDATE"
  make batch-self-check
  make prompt-audit
  log "post-PK final gate complete; heavy app/Xcode gates remain terminal-batch-owned"
}

case "$MODE" in
  -h|--help)
    cat <<'EOF'
Usage:
  scripts/ambitions-post-pk-speed-train.sh --status
  scripts/ambitions-post-pk-speed-train.sh --next
  scripts/ambitions-post-pk-speed-train.sh --once
  scripts/ambitions-post-pk-speed-train.sh --until-blocked
  scripts/ambitions-post-pk-speed-train.sh --final-gate
EOF
    ;;
  --status)
    status
    ;;
  --next)
    require_base
    python3 "$ROUTER" --next
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
    fail "unknown mode: $MODE"
    ;;
esac
