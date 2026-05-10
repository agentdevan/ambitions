#!/usr/bin/env bash
set -Eeuo pipefail

# Ambitions hybrid Codex batch runner.
#
# Default access uses explicit full-access sandbox flags:
#   --sandbox danger-full-access
#
# If an older installed Codex CLI rejects those flags, set ACCESS_MODE=bypass
# to use:
#   --dangerously-bypass-approvals-and-sandbox
#
# This runner orchestrates Codex phases. It does not decide product truth,
# release readiness, accessibility conformance, or batch completion by itself.

CONDUCTOR_MODEL="${CONDUCTOR_MODEL:-gpt-5.5}"
PATCH_MODEL="${PATCH_MODEL:-gpt-5.3-codex-spark}"
REVIEW_MODEL="${REVIEW_MODEL:-gpt-5.5}"
REPAIR_MODEL="${REPAIR_MODEL:-gpt-5.5}"

ACCESS_MODE="${ACCESS_MODE:-full}"
AUTO_BRANCH="${AUTO_BRANCH:-1}"
AUTO_COMMIT="${AUTO_COMMIT:-1}"
AUTO_PUSH="${AUTO_PUSH:-0}"
ALLOW_RUNNER_BRANCH_EXCEPTION="${ALLOW_RUNNER_BRANCH_EXCEPTION:-0}"
ALLOW_DIRTY="${ALLOW_DIRTY:-0}"
MAX_REPAIR_PASSES="${MAX_REPAIR_PASSES:-1}"
KEEP_GOING_ON_YELLOW="${KEEP_GOING_ON_YELLOW:-0}"
ALLOW_YELLOW_COMMIT="${ALLOW_YELLOW_COMMIT:-0}"
ALLOW_MAIN_COMMIT="${ALLOW_MAIN_COMMIT:-0}"
AUTO_ROLLBACK_ON_RED="${AUTO_ROLLBACK_ON_RED:-0}"

usage() {
  cat <<'EOF'
Usage:
  scripts/ambitions-codex-train.sh BATCH_ID path/to/prompt.md
  scripts/ambitions-codex-train.sh --self-check

Example:
  scripts/ambitions-codex-train.sh SI07 prompts/SI07.md

Environment defaults:
  CONDUCTOR_MODEL=gpt-5.5
  PATCH_MODEL=gpt-5.3-codex-spark
  REVIEW_MODEL=gpt-5.5
  REPAIR_MODEL=gpt-5.5
  ACCESS_MODE=full
  AUTO_BRANCH=1
  AUTO_COMMIT=1
  AUTO_PUSH=0
  ALLOW_RUNNER_BRANCH_EXCEPTION=0
  ALLOW_DIRTY=0
  MAX_REPAIR_PASSES=1
  KEEP_GOING_ON_YELLOW=0
  ALLOW_YELLOW_COMMIT=0
  ALLOW_MAIN_COMMIT=0
  AUTO_ROLLBACK_ON_RED=0
EOF
}

die() {
  echo "ERROR: $*" >&2
  exit 1
}

if [[ "${1:-}" == "-h" || "${1:-}" == "--help" ]]; then
  usage
  exit 0
fi

if [[ "${1:-}" == "--self-check" ]]; then
  exec "$(dirname "$0")/ambitions-runner-self-check.sh"
fi

[[ "$#" -eq 2 ]] || {
  usage >&2
  exit 2
}

BATCH_ID="$1"
PROMPT_ARG="$2"
ORIGINAL_CWD="$(pwd -P)"

command -v git >/dev/null 2>&1 || die "git is unavailable"
command -v codex >/dev/null 2>&1 || die "codex CLI is unavailable"

REPO_ROOT="$(git rev-parse --show-toplevel 2>/dev/null)" \
  || die "not inside a git repo"
cd "$REPO_ROOT"

resolve_path() {
  local raw="$1"
  local candidate
  if [[ "$raw" = /* ]]; then
    candidate="$raw"
  elif [[ -e "$ORIGINAL_CWD/$raw" ]]; then
    candidate="$ORIGINAL_CWD/$raw"
  else
    candidate="$REPO_ROOT/$raw"
  fi

  [[ -f "$candidate" ]] || return 1
  local dir base
  dir="$(cd "$(dirname "$candidate")" && pwd -P)"
  base="$(basename "$candidate")"
  printf '%s/%s\n' "$dir" "$base"
}

PROMPT_FILE="$(resolve_path "$PROMPT_ARG")" \
  || die "prompt file missing: $PROMPT_ARG"

SAFE_BATCH_ID="$(printf '%s' "$BATCH_ID" | tr -c 'A-Za-z0-9._-' '-')"
[[ -n "$SAFE_BATCH_ID" ]] || die "empty batch id after sanitization"

START_BRANCH="$(git rev-parse --abbrev-ref HEAD)"
START_SHA="$(git rev-parse HEAD)"
TIMESTAMP="$(date -u +%Y%m%dT%H%M%SZ)"
RUN_DIR=".codex/runs/$SAFE_BATCH_ID/$TIMESTAMP"
ROLLBACK_COMMAND="git reset --hard $START_SHA"
PUSHED=0
COMMIT_SHA=""
FINAL_STATUS="UNKNOWN"

if [[ "$ALLOW_DIRTY" != "1" ]]; then
  if [[ -n "$(git status --porcelain)" ]]; then
    die "dirty worktree; set ALLOW_DIRTY=1 to override"
  fi
fi

branch_creation_forbidden_by_active_state() {
  [[ -f ".codex/state/active-batch.yml" ]] \
    && grep -Eq '^[[:space:]]*branch_creation_allowed:[[:space:]]*false[[:space:]]*$' ".codex/state/active-batch.yml"
}

if [[ "$AUTO_BRANCH" == "1" ]]; then
  if branch_creation_forbidden_by_active_state && [[ "$ALLOW_RUNNER_BRANCH_EXCEPTION" != "1" ]]; then
    die "active batch state forbids branch creation; set AUTO_BRANCH=0 to stay on $START_BRANCH or ALLOW_RUNNER_BRANCH_EXCEPTION=1 to use the runner branch exception"
  fi
  if [[ "$START_BRANCH" =~ ^codex/${SAFE_BATCH_ID}/ ]]; then
    BRANCH="$START_BRANCH"
  else
    BRANCH="codex/$SAFE_BATCH_ID/$TIMESTAMP"
    git switch -c "$BRANCH"
  fi
else
  BRANCH="$START_BRANCH"
fi

mkdir -p "$RUN_DIR"/{prompts,jsonl,final,status,diff}

log() {
  printf '[%s] %s\n' "$(date -u +%Y-%m-%dT%H:%M:%SZ)" "$*" \
    | tee -a "$RUN_DIR/runner.log" >&2
}

write_runner_status() {
  cat >"$RUN_DIR/runner-status.env" <<EOF
BATCH_ID=$BATCH_ID
SAFE_BATCH_ID=$SAFE_BATCH_ID
START_BRANCH=$START_BRANCH
BRANCH=$BRANCH
START_SHA=$START_SHA
TIMESTAMP=$TIMESTAMP
RUN_DIR=$RUN_DIR
CONDUCTOR_MODEL=$CONDUCTOR_MODEL
PATCH_MODEL=$PATCH_MODEL
REVIEW_MODEL=$REVIEW_MODEL
REPAIR_MODEL=$REPAIR_MODEL
ACCESS_MODE=$ACCESS_MODE
AUTO_BRANCH=$AUTO_BRANCH
AUTO_COMMIT=$AUTO_COMMIT
AUTO_PUSH=$AUTO_PUSH
ALLOW_DIRTY=$ALLOW_DIRTY
ALLOW_RUNNER_BRANCH_EXCEPTION=$ALLOW_RUNNER_BRANCH_EXCEPTION
MAX_REPAIR_PASSES=$MAX_REPAIR_PASSES
KEEP_GOING_ON_YELLOW=$KEEP_GOING_ON_YELLOW
ALLOW_YELLOW_COMMIT=$ALLOW_YELLOW_COMMIT
ALLOW_MAIN_COMMIT=$ALLOW_MAIN_COMMIT
AUTO_ROLLBACK_ON_RED=$AUTO_ROLLBACK_ON_RED
FINAL_STATUS=$FINAL_STATUS
COMMIT_SHA=$COMMIT_SHA
PUSHED=$PUSHED
EOF
}

save_git_snapshot() {
  local label="$1"
  git status --short --branch >"$RUN_DIR/status/$label.status.txt"
  git diff HEAD --stat >"$RUN_DIR/diff/$label.diffstat.txt" || true
  git diff HEAD >"$RUN_DIR/diff/$label.patch" || true
}

cat >"$RUN_DIR/rollback.md" <<EOF
# Rollback

Batch: $BATCH_ID
Start branch: $START_BRANCH
Run branch: $BRANCH
Start SHA: $START_SHA

Hard reset rollback command:

\`\`\`bash
$ROLLBACK_COMMAND
\`\`\`

The runner will not execute rollback unless AUTO_ROLLBACK_ON_RED=1.
EOF

access_flags() {
  case "$ACCESS_MODE" in
    full)
      printf '%s\n' --sandbox danger-full-access
      ;;
    workspace)
      printf '%s\n' --sandbox workspace-write
      ;;
    bypass)
      printf '%s\n' --dangerously-bypass-approvals-and-sandbox
      ;;
    *)
      die "unsupported ACCESS_MODE: $ACCESS_MODE"
      ;;
  esac
}

parse_status() {
  local file="$1"
  if [[ ! -s "$file" ]]; then
    printf 'RED\n'
    return
  fi
  if grep -Eiq 'STATUS:[[:space:]]*RED|Hard Red|HARD RED|RED[[:space:]]*/[[:space:]]*STOP' "$file"; then
    printf 'RED\n'
  elif grep -Eiq 'STATUS:[[:space:]]*YELLOW' "$file"; then
    printf 'YELLOW\n'
  elif grep -Eiq 'STATUS:[[:space:]]*GREEN' "$file"; then
    printf 'GREEN\n'
  else
    printf 'UNKNOWN\n'
  fi
}

changed_files() {
  {
    git diff --name-only "$START_SHA" -- . ':(exclude).codex/runs/**' 2>/dev/null || true
    git ls-files --others --exclude-standard -- . ':(exclude).codex/runs/**' 2>/dev/null || true
  } | awk 'NF' | sort -u
}

uncommitted_changed_files() {
  {
    git diff --name-only HEAD -- . ':(exclude).codex/runs/**' 2>/dev/null || true
    git ls-files --others --exclude-standard -- . ':(exclude).codex/runs/**' 2>/dev/null || true
  } | awk 'NF' | sort -u
}

latest_gate_file() {
  if [[ -s "$RUN_DIR/final/05-finalize.final.md" ]]; then
    printf '%s\n' "$RUN_DIR/final/05-finalize.final.md"
  else
    printf '%s\n' "$RUN_DIR/final/03-review.final.md"
  fi
}

phase_or_gate_mentions_path() {
  local path="$1"
  local gate_file="$2"
  grep -Fq -- "$path" "$RUN_DIR/final/01-plan.final.md" 2>/dev/null \
    || grep -Fq -- "$path" "$gate_file" 2>/dev/null
}

expected_tooling_governance_path() {
  local path="$1"
  case "$path" in
    AGENTS.md|Makefile|scripts/ambitions-codex-train.sh|scripts/ambitions-wrap-prompt.sh|scripts/ambitions-prompt-audit.sh|scripts/ambitions-runner-self-check.sh|prompts/_RUNNER_REQUIRED_HEADER.md|prompts/_BATCH_TEMPLATE.md|docs/codex/ambitions-hybrid-runner.md|docs/codex/README.md|.codex/TOOLING_AND_VALIDATION.md|.codex/PR_PROTOCOL.md|.codex/VALIDATION_HARNESS.md|.codex/REVIEW_BOARD.md|.codex/DEPARTMENT_REGISTRY.md)
      return 0
      ;;
    *)
      return 1
      ;;
  esac
}

gate_allows_tooling_governance_changes() {
  local gate_file="$1"
  grep -Eiq 'expected tooling/governance changes|expected tooling governance changes|tooling/governance changes for this batch' "$gate_file" 2>/dev/null
}

validate_stage_set() {
  local gate_file="$1"
  shift
  local file

  [[ "$#" -gt 0 ]] || die "refusing to stage: no changed files outside .codex/runs"
  [[ -s "$gate_file" ]] || die "refusing to stage: final gate file missing or empty"

  for file in "$@"; do
    [[ -n "$file" ]] || die "refusing to stage: empty path in changed-file set"
    case "$file" in
      .codex/runs/*)
        die "refusing to stage run artifact: $file"
        ;;
    esac

    if phase_or_gate_mentions_path "$file" "$gate_file"; then
      continue
    fi

    if expected_tooling_governance_path "$file" && gate_allows_tooling_governance_changes "$gate_file"; then
      continue
    fi

    die "refusing to stage unapproved path not named by Phase 01 or final gate: $file"
  done
}

stage_changed_files() {
  local gate_file
  gate_file="$(latest_gate_file)"

  local -a files_to_stage=()
  local candidate
  while IFS= read -r candidate; do
    files_to_stage+=("$candidate")
  done < <(uncommitted_changed_files)

  printf '%s\n' "${files_to_stage[@]}" >"$RUN_DIR/status/files-to-stage.txt"
  validate_stage_set "$gate_file" "${files_to_stage[@]}"

  local file
  for file in "${files_to_stage[@]}"; do
    git add -- "$file"
  done

  git diff --cached --name-only >"$RUN_DIR/status/staged-files.txt"
  git diff --name-only >"$RUN_DIR/status/unstaged-files.txt" || true
  git ls-files --others --exclude-standard -- . ':(exclude).codex/runs/**' >>"$RUN_DIR/status/unstaged-files.txt" 2>/dev/null || true

  if [[ ! -s "$RUN_DIR/status/staged-files.txt" ]]; then
    die "refusing to commit: nothing staged after explicit path staging"
  fi
}

standard_ambitions_quality_bar() {
  cat <<'EOF'
Ambitions quality bar:
- Target is a world-class native iPhone-first product.
- Treat Ambitions as a premium native iPhone life operating system.
- Preserve active user-facing top-level IA: Today, Goals, Capture, Time, You.
- Treat Plan only as an internal compatibility seam or contextual/action noun where current source/truth allows it.
- Preserve the locked Start Here / Reality Meridian / LifeShape Field / Capture composer / You settings-style direction where relevant.
- Preserve 70% Apple quiet luxury, 20% local on-device intelligence, 10% executive command clarity.
- Preserve local-first / on-device-first posture unless active truth files say otherwise.
- No generic productivity-app thinking.
- No card-stack/dashboard/task-list fallback.
- No obsolete authority paths.
- No false release claims.
- No unproven accessibility, privacy, performance, or production claims.
- Distinguish active, supporting, historical, obsolete, archive-candidate, and delete-candidate materials when relevant.
- Include proof, validation, cleanup, and rollback details.

Truth precedence:
- If the quality bar conflicts with docs/truth/*, docs/truth/* wins.
- Do not promote compatibility or historical names as active truth unless current truth files allow it.
- Do not claim a batch ran or completed unless this phase actually proves that scoped claim.
EOF
}

base_runner_context() {
  cat <<EOF
You are operating in the Ambitions repo.

Batch ID: $BATCH_ID
Prompt file: $PROMPT_FILE
Run directory: $RUN_DIR
Starting commit: $START_SHA
Current branch: $BRANCH

Runner defaults:
- Full access / no approval prompts by default.
- Auto branch creation enabled by default.
- Auto commit enabled by default, but only after final GPT-5.5 eligible status.
- Dirty repo protection enabled by default.
- Hard Red stop discipline.
- Auto-push disabled by default; set AUTO_PUSH=1 only with explicit owner intent.
- Active branch-creation policy is checked before runner branch creation.
- One bounded repair pass by default.
- Spark never owns architecture, canon, continuation, cleanup, or final decisions.

$(standard_ambitions_quality_bar)

Required final line for this phase:
STATUS: GREEN
or
STATUS: YELLOW
or
STATUS: RED
EOF
}

append_user_prompt() {
  cat <<EOF

Original batch prompt follows:

--- BEGIN ORIGINAL PROMPT ---
$(cat "$PROMPT_FILE")
--- END ORIGINAL PROMPT ---
EOF
}

write_phase_prompt() {
  local phase="$1"
  local out="$2"
  shift 2
  {
    base_runner_context
    printf '\n'
    printf '%s\n' "$@"
    append_user_prompt
  } >"$out"
}

run_codex_phase() {
  local phase="$1"
  local model="$2"
  local prompt="$3"
  local jsonl="$RUN_DIR/jsonl/$phase.jsonl"
  local final="$RUN_DIR/final/$phase.final.md"
  local stderr_log="$RUN_DIR/jsonl/$phase.stderr.log"
  local exit_file="$RUN_DIR/status/$phase.exit-code.txt"
  local status_file="$RUN_DIR/status/$phase.status.txt"
  local -a flags=()
  local flag
  while IFS= read -r flag; do
    flags+=("$flag")
  done < <(access_flags)

  log "starting $phase with model $model"
  save_git_snapshot "${phase}.before"

  set +e
  codex exec \
    --model "$model" \
    "${flags[@]}" \
    --json \
    --output-last-message "$final" \
    <"$prompt" \
    2> >(tee "$stderr_log" >&2) \
    | tee "$jsonl" >&2
  local codex_exit
  codex_exit=${PIPESTATUS[0]}
  set -e

  printf '%s\n' "$codex_exit" >"$exit_file"
  save_git_snapshot "${phase}.after"

  local status
  status="$(parse_status "$final")"
  if [[ "$codex_exit" -ne 0 || "$status" == "UNKNOWN" ]]; then
    status="RED"
  fi
  printf '%s\n' "$status" >"$status_file"
  log "finished $phase with STATUS: $status (codex exit $codex_exit)"
  printf '%s\n' "$status"
}

stop_red() {
  local reason="$1"
  FINAL_STATUS="RED"
  write_runner_status
  save_git_snapshot "red-stop"
  cat >"$RUN_DIR/final-summary.md" <<EOF
# Final Summary

Batch ID: $BATCH_ID
Final status: RED
Branch: $BRANCH
Commit SHA: none
Run directory: $RUN_DIR
Reason: $reason
Rollback command:

\`\`\`bash
$ROLLBACK_COMMAND
\`\`\`

Pushed: no
EOF
  log "RED stop: $reason"
  if [[ "$AUTO_ROLLBACK_ON_RED" == "1" ]]; then
    log "AUTO_ROLLBACK_ON_RED=1; running rollback"
    git reset --hard "$START_SHA"
  else
    log "changes left uncommitted for inspection"
  fi
  print_summary
  exit 1
}

phase_requires_repair() {
  local final_file="$1"
  grep -Eiq 'REPAIR REQUIRED|repair required|requires repair' "$final_file"
}

commit_if_eligible() {
  local status="$1"
  local eligible=0

  if [[ "$AUTO_COMMIT" != "1" ]]; then
    log "AUTO_COMMIT=0; skipping commit"
    return 0
  fi

  if [[ "$status" == "GREEN" ]]; then
    eligible=1
  elif [[ "$status" == "YELLOW" && "$ALLOW_YELLOW_COMMIT" == "1" ]]; then
    eligible=1
  fi

  [[ "$eligible" == "1" ]] || die "final status $status is not commit-eligible"

  local current_branch
  current_branch="$(git rev-parse --abbrev-ref HEAD)"
  if [[ "$ALLOW_MAIN_COMMIT" != "1" && ( "$current_branch" == "main" || "$current_branch" == "master" ) ]]; then
    die "refusing to auto commit on $current_branch; set ALLOW_MAIN_COMMIT=1 to override"
  fi

  git status --short >"$RUN_DIR/status/pre-commit.status.txt"
  git diff HEAD --stat >"$RUN_DIR/diff/pre-commit.diffstat.txt" || true
  git diff HEAD >"$RUN_DIR/diff/pre-commit.patch" || true

  if [[ -z "$(uncommitted_changed_files)" ]]; then
    if [[ "$(git rev-parse HEAD)" != "$START_SHA" ]]; then
      COMMIT_SHA="$(git rev-parse HEAD)"
      printf '%s\n' "$COMMIT_SHA" >"$RUN_DIR/status/commit-sha.txt"
      log "final gate already created commit $COMMIT_SHA; skipping runner commit"
    else
      log "no changed files outside .codex/runs; skipping commit"
    fi
    return 0
  fi

  stage_changed_files

  if git diff --cached --quiet; then
    log "nothing staged after explicit path staging; skipping commit"
    return 0
  fi

  local changed_summary validation_summary
  changed_summary="$(git diff --cached --stat)"
  validation_summary="$(grep -RhiE 'validation|test|build|pass|fail|not run' "$RUN_DIR/final" 2>/dev/null | tail -40 || true)"

  git commit -m "$BATCH_ID: complete hybrid Codex batch" -m "$(cat <<EOF
Runner path: scripts/ambitions-codex-train.sh
Run directory: $RUN_DIR
Models: conductor=$CONDUCTOR_MODEL, patch=$PATCH_MODEL, review=$REVIEW_MODEL, repair=$REPAIR_MODEL
Status: $status

Validation summary:
$validation_summary

Changed file summary:
$changed_summary

Auto-push: $AUTO_PUSH
Staged files:
$(cat "$RUN_DIR/status/staged-files.txt" 2>/dev/null || true)
EOF
)"

  COMMIT_SHA="$(git rev-parse HEAD)"
  printf '%s\n' "$COMMIT_SHA" >"$RUN_DIR/status/commit-sha.txt"
  log "committed $COMMIT_SHA"
}

push_if_enabled() {
  if [[ "$AUTO_PUSH" != "1" ]]; then
    PUSHED=0
    return
  fi
  if [[ -z "$COMMIT_SHA" ]]; then
    log "AUTO_PUSH=1 but no commit was created; skipping push"
    PUSHED=0
    return
  fi
  local current_branch
  current_branch="$(git rev-parse --abbrev-ref HEAD)"
  git push -u origin "$current_branch"
  PUSHED=1
  log "pushed branch $current_branch"
}

print_summary() {
  local files
  files="$(changed_files | tr '\n' ' ')"
  cat <<EOF
Batch ID: $BATCH_ID
Final status: $FINAL_STATUS
Branch: $BRANCH
Commit SHA: ${COMMIT_SHA:-none}
Run directory: $RUN_DIR
Changed files: ${files:-none}
Validation summary: see $RUN_DIR/final/*.final.md and $RUN_DIR/final-summary.md
Rollback command: $ROLLBACK_COMMAND
Pushed: $([[ "$PUSHED" == "1" ]] && printf 'yes' || printf 'no')
EOF
}

write_final_summary() {
  local reason="$1"
  cat >"$RUN_DIR/final-summary.md" <<EOF
# Final Summary

Batch ID: $BATCH_ID
Final status: $FINAL_STATUS
Branch: $BRANCH
Commit SHA: ${COMMIT_SHA:-none}
Run directory: $RUN_DIR
Reason: $reason
Changed files:

\`\`\`text
$(changed_files)
\`\`\`

Validation summary:

See phase final messages under \`$RUN_DIR/final/\`.

Rollback command:

\`\`\`bash
$ROLLBACK_COMMAND
\`\`\`

Pushed: $([[ "$PUSHED" == "1" ]] && printf 'yes' || printf 'no')
EOF
}

write_runner_status
save_git_snapshot "start"
log "hybrid runner initialized"
log "batch=$BATCH_ID branch=$BRANCH start=$START_SHA run_dir=$RUN_DIR"

PHASE01_PROMPT="$RUN_DIR/prompts/01-plan.prompt.md"
write_phase_prompt "01-plan" "$PHASE01_PROMPT" \
  "Phase 01 — GPT-5.5 Plan" \
  "" \
  "Purpose:" \
  "- inspect repo" \
  "- identify active source truth" \
  "- define exact file boundary" \
  "- define forbidden files" \
  "- define validation commands" \
  "- define rollback command" \
  "- produce Spark handoff" \
  "" \
  "Rules:" \
  "- Must not edit app source." \
  "- Must output STATUS: GREEN | YELLOW | RED." \
  "- If source files are needed, define the smallest approved boundary for Phase 02 only." \
  "- If planning is ambiguous or unsafe, output STATUS: RED."

PHASE01_STATUS="$(run_codex_phase "01-plan" "$CONDUCTOR_MODEL" "$PHASE01_PROMPT")"
[[ "$PHASE01_STATUS" != "RED" ]] || stop_red "Phase 01 returned RED or UNKNOWN"
if [[ "$PHASE01_STATUS" == "YELLOW" && "$KEEP_GOING_ON_YELLOW" != "1" ]]; then
  FINAL_STATUS="YELLOW"
  write_runner_status
  save_git_snapshot "yellow-stop-phase-01"
  log "Phase 01 returned YELLOW and KEEP_GOING_ON_YELLOW=0"
  write_final_summary "Phase 01 returned YELLOW and KEEP_GOING_ON_YELLOW=0"
  print_summary
  exit 0
fi

PHASE02_PROMPT="$RUN_DIR/prompts/02-spark-bounded-patch.prompt.md"
write_phase_prompt "02-spark-bounded-patch" "$PHASE02_PROMPT" \
  "Phase 02 — Spark Bounded Patch" \
  "" \
  "Purpose:" \
  "- implement only the approved bounded patch from Phase 01" \
  "" \
  "Phase 01 final message:" \
  "$(sed -n '1,240p' "$RUN_DIR/final/01-plan.final.md")" \
  "" \
  "Spark rules:" \
  "- Modify only allowed files from Phase 01." \
  "- No architecture decisions." \
  "- No canon decisions." \
  "- No continuation decisions." \
  "- No repo cleanup outside the approved boundary." \
  "- No generic UI substitutions." \
  "- No dependency changes unless Phase 01 explicitly allowed them." \
  "- Run Phase 01 validation commands where possible." \
  "- Must output STATUS: GREEN | YELLOW | RED."

PHASE02_STATUS="$(run_codex_phase "02-spark-bounded-patch" "$PATCH_MODEL" "$PHASE02_PROMPT")"
[[ "$PHASE02_STATUS" != "RED" ]] || stop_red "Phase 02 returned RED or UNKNOWN"
if [[ "$PHASE02_STATUS" == "YELLOW" && "$KEEP_GOING_ON_YELLOW" != "1" ]]; then
  FINAL_STATUS="YELLOW"
  write_runner_status
  save_git_snapshot "yellow-stop-phase-02"
  log "Phase 02 returned YELLOW and KEEP_GOING_ON_YELLOW=0"
  write_final_summary "Phase 02 returned YELLOW and KEEP_GOING_ON_YELLOW=0"
  print_summary
  exit 0
fi

PHASE03_PROMPT="$RUN_DIR/prompts/03-review.prompt.md"
write_phase_prompt "03-review" "$PHASE03_PROMPT" \
  "Phase 03 — GPT-5.5 Review" \
  "" \
  "Purpose:" \
  "- inspect actual git diff" \
  "- review against Ambitions canon and active truth files" \
  "- review accessibility, privacy, repo hygiene, and validation proof" \
  "- rerun validation" \
  "- decide whether repair is required" \
  "" \
  "Phase 01 final message:" \
  "$(sed -n '1,240p' "$RUN_DIR/final/01-plan.final.md")" \
  "" \
  "Phase 02 final message:" \
  "$(sed -n '1,240p' "$RUN_DIR/final/02-spark-bounded-patch.final.md")" \
  "" \
  "Rules:" \
  "- Spark does not decide continuation." \
  "- Commit eligibility belongs to this GPT-5.5 review/final gate." \
  "- Must output STATUS: GREEN | YELLOW | RED." \
  "- If repair is required, include REPAIR REQUIRED."

PHASE03_STATUS="$(run_codex_phase "03-review" "$REVIEW_MODEL" "$PHASE03_PROMPT")"
REPAIR_RAN=0
FINAL_REVIEW_NEEDED=0

if [[ "$PHASE03_STATUS" == "RED" && "$MAX_REPAIR_PASSES" -gt 0 ]]; then
  FINAL_REVIEW_NEEDED=1
elif phase_requires_repair "$RUN_DIR/final/03-review.final.md" && [[ "$MAX_REPAIR_PASSES" -gt 0 ]]; then
  FINAL_REVIEW_NEEDED=1
elif [[ "$PHASE03_STATUS" == "RED" ]]; then
  stop_red "Phase 03 returned RED and no repair passes remain"
fi

if [[ "$FINAL_REVIEW_NEEDED" == "1" ]]; then
  for ((pass = 1; pass <= MAX_REPAIR_PASSES; pass++)); do
    REPAIR_RAN=1
    PHASE04_PROMPT="$RUN_DIR/prompts/04-repair-$pass.prompt.md"
    write_phase_prompt "04-repair-$pass" "$PHASE04_PROMPT" \
      "Phase 04 — GPT-5.5 Repair Pass $pass" \
      "" \
      "Purpose:" \
      "- repair only within the Phase 01 approved boundary" \
      "- do not broaden architecture" \
      "- rerun validation" \
      "- output STATUS: GREEN | YELLOW | RED" \
      "" \
      "Phase 03 review final message:" \
      "$(sed -n '1,240p' "$RUN_DIR/final/03-review.final.md")"

    PHASE04_STATUS="$(run_codex_phase "04-repair-$pass" "$REPAIR_MODEL" "$PHASE04_PROMPT")"
    [[ "$PHASE04_STATUS" != "RED" ]] || stop_red "Phase 04 repair pass $pass returned RED or UNKNOWN"
    FINAL_REVIEW_NEEDED=1
    break
  done
fi

if [[ "$REPAIR_RAN" == "1" ]]; then
  FINAL_PROMPT="$RUN_DIR/prompts/05-finalize.prompt.md"
  write_phase_prompt "05-finalize" "$FINAL_PROMPT" \
    "Final Gate — GPT-5.5 Finalize" \
    "" \
    "Purpose:" \
    "- inspect final git diff" \
    "- confirm exact changed files" \
    "- confirm validation proof" \
    "- confirm no forbidden files changed" \
    "- confirm no generic UI regression" \
    "- confirm no source-truth conflict" \
    "- decide commit eligibility" \
    "- output STATUS: GREEN | YELLOW | RED" \
    "" \
    "Review final message:" \
    "$(sed -n '1,240p' "$RUN_DIR/final/03-review.final.md")" \
    "" \
    "Latest repair final message:" \
    "$(sed -n '1,240p' "$RUN_DIR/final/04-repair-1.final.md")"

  FINAL_STATUS="$(run_codex_phase "05-finalize" "$REVIEW_MODEL" "$FINAL_PROMPT")"
else
  FINAL_STATUS="$PHASE03_STATUS"
fi

if [[ "$FINAL_STATUS" == "RED" ]]; then
  stop_red "Final gate returned RED or UNKNOWN"
fi

if [[ "$FINAL_STATUS" == "YELLOW" && "$ALLOW_YELLOW_COMMIT" != "1" ]]; then
  write_runner_status
  save_git_snapshot "yellow-final"
  log "Final status YELLOW; no commit because ALLOW_YELLOW_COMMIT=0"
  write_final_summary "Final status YELLOW; no commit because ALLOW_YELLOW_COMMIT=0"
  print_summary
  exit 0
fi

commit_if_eligible "$FINAL_STATUS"
push_if_enabled
write_runner_status
save_git_snapshot "final"

write_final_summary "Completed runner flow"
print_summary
