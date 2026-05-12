#!/usr/bin/env bash
set -Eeuo pipefail

REPO_ROOT="$(git rev-parse --show-toplevel 2>/dev/null || pwd -P)"
cd "$REPO_ROOT"

MRI_ROUTER="scripts/ambitions-mri-autonomous-router.py"
POST_PK="scripts/ambitions-post-pk-speed-train.sh"
STATE_VALIDATE="scripts/ambitions-state-advance-validate.py"
RUNNER_ACCESS="scripts/ambitions-runner-access-guard.py"

MODE="${1:---status}"
MAX_BATCHES="${MAX_BATCHES:-25}"
MRI_MAX_INTERVENTIONS="${MRI_MAX_INTERVENTIONS:-10}"

log() {
  printf '[mri-autonomous] %s\n' "$*"
}

fail() {
  printf '[mri-autonomous] ERROR: %s\n' "$*" >&2
  exit 1
}

require_file() {
  [[ -e "$1" ]] || fail "missing required file: $1"
}

require_base() {
  require_file "$MRI_ROUTER"
  require_file "$POST_PK"
  require_file "$STATE_VALIDATE"
  require_file "$RUNNER_ACCESS"
}

next_mri_line() {
  python3 "$MRI_ROUTER" --materialize-if-needed --next
}

run_mri_once() {
  require_base
  python3 "$RUNNER_ACCESS"
  python3 "$STATE_VALIDATE"
  local line batch prompt milestone
  line="$(next_mri_line)"
  if [[ "$line" == "NONE" || -z "$line" ]]; then
    log "no MRI intervention due; running one normal post-PK batch"
    bash "$POST_PK" --once
    return 0
  fi
  batch="$(awk '{print $1}' <<<"$line")"
  prompt="$(awk '{print $2}' <<<"$line")"
  milestone="$(awk '{print $3}' <<<"$line")"
  [[ -f "$prompt" ]] || fail "MRI prompt missing after materialization: $prompt"
  log "running MRI intervention: $batch ($milestone)"
  ACCESS_MODE=bypass \
  AUTO_BRANCH=0 \
  ALLOW_MAIN_COMMIT=1 \
  AUTO_COMMIT=1 \
  AUTO_PUSH=1 \
  KEEP_GOING_ON_YELLOW=1 \
  ALLOW_YELLOW_COMMIT=1 \
  MAX_REPAIR_PASSES=1 \
  make batch BATCH="$batch" PROMPT="$prompt"
  python3 "$MRI_ROUTER" --mark-complete "$batch"
  if ! git diff --quiet -- .codex/state/mri-autonomous-state.json; then
    git add -- .codex/state/mri-autonomous-state.json
    git commit --no-verify -m "MRI: mark $batch complete"
    git push --no-verify origin HEAD:main
  fi
}

run_until_blocked() {
  require_base
  local count=0
  local seen=""
  while [[ "$count" -lt "$MAX_BATCHES" ]]; do
    local line batch
    line="$(next_mri_line)"
    if [[ "$line" != "NONE" && -n "$line" ]]; then
      batch="$(awk '{print $1}' <<<"$line")"
      case " $seen " in
        *" $batch "*) fail "same MRI intervention loop detected: $batch" ;;
      esac
      seen="$seen $batch"
      count=$((count + 1))
      run_mri_once
      git pull --ff-only
      continue
    fi
    log "no MRI intervention due; delegating to post-PK speed train"
    MAX_BATCHES="$((MAX_BATCHES - count))" bash "$POST_PK" --until-blocked
    return $?
  done
  log "reached MAX_BATCHES=$MAX_BATCHES; stopping cleanly"
}

status() {
  require_base
  git status --short --branch
  python3 "$MRI_ROUTER" --status || true
  bash "$POST_PK" --status || true
}

case "$MODE" in
  -h|--help)
    cat <<'EOF'
Usage:
  scripts/ambitions-mri-autonomous-train.sh --status
  scripts/ambitions-mri-autonomous-train.sh --next
  scripts/ambitions-mri-autonomous-train.sh --once
  scripts/ambitions-mri-autonomous-train.sh --until-blocked

Behavior:
  If an MRI milestone is due, materialize MRI prompts, run the next MRI sidecar batch,
  mark it complete in .codex/state/mri-autonomous-state.json, push, and continue.
  If no MRI milestone is due, delegate to post-PK speed train.
EOF
    ;;
  --status)
    status
    ;;
  --next)
    require_base
    next_mri_line
    ;;
  --once)
    run_mri_once
    ;;
  --until-blocked|--until-complete)
    run_until_blocked
    ;;
  *)
    fail "unknown mode: $MODE"
    ;;
esac
