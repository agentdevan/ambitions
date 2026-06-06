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
CODEX_SERVICE_TIER="${CODEX_SERVICE_TIER:-fast}"

AUTO_BRANCH_EXPLICIT=0
[[ "${AUTO_BRANCH+x}" == x ]] && AUTO_BRANCH_EXPLICIT=1
ALLOW_MAIN_COMMIT_EXPLICIT=0
[[ "${ALLOW_MAIN_COMMIT+x}" == x ]] && ALLOW_MAIN_COMMIT_EXPLICIT=1
KEEP_GOING_ON_YELLOW_EXPLICIT=0
[[ "${KEEP_GOING_ON_YELLOW+x}" == x ]] && KEEP_GOING_ON_YELLOW_EXPLICIT=1
BATCH_TYPE_EXPLICIT=0
[[ "${BATCH_TYPE+x}" == x ]] && BATCH_TYPE_EXPLICIT=1

ACCESS_MODE="${ACCESS_MODE:-full}"
AUTO_BRANCH="${AUTO_BRANCH:-1}"
AUTO_COMMIT="${AUTO_COMMIT:-1}"
AUTO_PUSH="${AUTO_PUSH:-0}"
READ_ONLY_AUDIT="${READ_ONLY_AUDIT:-0}"
BATCH_TYPE="${BATCH_TYPE:-source-changing}"
ALLOW_NESTED_BATCH="${ALLOW_NESTED_BATCH:-0}"
ALLOW_RUNNER_BRANCH_EXCEPTION="${ALLOW_RUNNER_BRANCH_EXCEPTION:-0}"
ALLOW_DIRTY="${ALLOW_DIRTY:-0}"
MAX_REPAIR_PASSES="${MAX_REPAIR_PASSES:-1}"
KEEP_GOING_ON_YELLOW="${KEEP_GOING_ON_YELLOW:-0}"
ALLOW_YELLOW_COMMIT="${ALLOW_YELLOW_COMMIT:-0}"
ALLOW_MAIN_COMMIT="${ALLOW_MAIN_COMMIT:-0}"
AUTO_ROLLBACK_ON_RED="${AUTO_ROLLBACK_ON_RED:-0}"
STRUCTURED_OUTPUT="${STRUCTURED_OUTPUT:-0}"
OUTPUT_SCHEMA="${OUTPUT_SCHEMA:-.codex/schemas/ambitions-batch-result.schema.json}"
OUTPUT_REPORT_DIR="${OUTPUT_REPORT_DIR:-build/reports/codex-runs}"
AMBITIONS_REPO_INTELLIGENCE_CONTEXT="${AMBITIONS_REPO_INTELLIGENCE_CONTEXT:-}"
RUNNER_FASTPATH_SELFTEST="${RUNNER_FASTPATH_SELFTEST:-0}"
STREAM_CODEX_JSON="${STREAM_CODEX_JSON:-0}"
PROMPT_SELF_HEAL_MODE="${PROMPT_SELF_HEAL_MODE:-1}"
PATCH_NO_DIFF_WARN_SECONDS="${PATCH_NO_DIFF_WARN_SECONDS:-300}"
PATCH_NO_DIFF_STOP_SECONDS="${PATCH_NO_DIFF_STOP_SECONDS:-420}"
PATCH_WATCHDOG_POLL_SECONDS="${PATCH_WATCHDOG_POLL_SECONDS:-15}"
GLOBAL_SEQUENCE_AUTHORITY="docs/codex/GLOBAL_BATCH_SEQUENCE.md"
GLOBAL_SEQUENCE_AUTHORITY_JSON="docs/codex/GLOBAL_BATCH_SEQUENCE_AUTHORITY.json"
ALLOW_HISTORICAL_BATCH="${ALLOW_HISTORICAL_BATCH:-0}"
IOS26_REPLAN_ALLOWED="${IOS26_REPLAN_ALLOWED:-0}"
IOS26_PROMPT_HASH_FILE="docs/codex/ios26/IOS26_PROMPT_FREEZE_HASHES.json"
IOS26_MANIFEST="docs/codex/IOS26_FLAGSHIP_TRAIN_MANIFEST.yml"

usage() {
  cat <<'EOF'
Usage:
  scripts/ambitions-codex-train.sh BATCH_ID path/to/prompt.md
  scripts/ambitions-codex-train.sh --self-check
  scripts/ambitions-codex-train.sh --quote-self-check

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
  READ_ONLY_AUDIT=0
  BATCH_TYPE=source-changing
  ALLOW_NESTED_BATCH=0
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
  preflight="$(dirname "$0")/ambitions-process-preflight.sh"
  [[ -x "$preflight" ]] || die "preflight helper is missing or not executable: $preflight"
  bash -n "$preflight"
  grep -q 'scripts/ambitions-process-preflight.sh --assert-clear' scripts/ambitions-global-train-supervisor.sh \
    || die "supervisor no longer calls the shared preflight helper"

  mock_preflight="$(mktemp)"
  trap 'rm -f "$mock_preflight"' EXIT
  cat >"$mock_preflight" <<EOF
1001 1000 bash scripts/ambitions-codex-train.sh SELF-CHECK prompts/batches/SELF-CHECK.md
1002 1001 codex exec --mock-runner-self-check
1003 1001 bash scripts/ambitions-codex-train.sh SELF-CHECK prompts/batches/SELF-CHECK.md
1004 1002 xcodebuildmcp --simulate --self-check-mock
1005 1002 bash scripts/ambitions-process-preflight.sh --assert-clear
EOF
  PROCESS_PREFLIGHT_SELF_PID=1005 PROCESS_PREFLIGHT_PS_FILE="$mock_preflight" "$preflight" --assert-clear >/dev/null \
    || die "preflight helper mock check failed"
  rm -f "$mock_preflight"
  trap - EXIT
  exec "$(dirname "$0")/ambitions-runner-self-check.sh"
fi

if [[ "${1:-}" == "--quote-self-check" ]]; then
  exec bash "$(dirname "$0")/ambitions-runner-quote-self-check.sh"
fi

[[ "$#" -eq 2 ]] || {
  usage >&2
  exit 2
}

case "$BATCH_TYPE" in
  source-changing|docs-install|guard-repair|audit-only|proof-only)
    ;;
  *)
    die "unsupported BATCH_TYPE: $BATCH_TYPE"
    ;;
esac

BATCH_ID="$1"
PROMPT_ARG="$2"
ORIGINAL_CWD="$(pwd -P)"

if [[ "${AMBITIONS_RUNNER_ACTIVE:-0}" == "1" && "$ALLOW_NESTED_BATCH" != "1" ]]; then
  die "nested Ambitions batch runner invocation blocked during ${AMBITIONS_RUNNER_PHASE:-unknown} for parent ${AMBITIONS_RUNNER_PARENT_BATCH:-unknown}; rerun the child batch from the top-level operator loop or set ALLOW_NESTED_BATCH=1 only for an explicitly approved bounded exception"
fi

command -v git >/dev/null 2>&1 || die "git is unavailable"

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

prompt_has_runner_metadata() {
  local file="$1"
  grep -Eq '^[[:space:]]*<!--[[:space:]]*AMBITIONS_RUNNER_REQUIRED:[[:space:]]*true[[:space:]]*-->' "$file" \
    && grep -Eq '^[[:space:]]*<!--[[:space:]]*RUN_WITH:[[:space:]]*scripts/ambitions-codex-train\.sh[[:space:]]*-->' "$file" \
    && grep -Eq '^[[:space:]]*<!--[[:space:]]*DIRECT_CODEX_EXECUTION:[[:space:]]*forbidden_unless_user_explicitly_bypasses_runner[[:space:]]*-->' "$file"
}

PROMPT_FILE="$(resolve_path "$PROMPT_ARG")" \
  || die "prompt file missing: $PROMPT_ARG"

[[ -n "$BATCH_ID" ]] || die "batch id missing"
SAFE_BATCH_ID="$(printf '%s' "$BATCH_ID" | tr -c 'A-Za-z0-9._-' '-')"
[[ -n "$SAFE_BATCH_ID" ]] || die "empty batch id after sanitization"

START_BRANCH="$(git rev-parse --abbrev-ref HEAD)"
START_SHA="$(git rev-parse HEAD)"
[[ -s "$PROMPT_FILE" ]] || die "prompt file is empty: $PROMPT_FILE"
prompt_has_runner_metadata "$PROMPT_FILE" \
  || die "prompt file is missing required runner metadata: $PROMPT_FILE"

prompt_mentions() {
  local pattern="$1"
  grep -Eiq "$pattern" "$PROMPT_FILE"
}

prompt_requests_direct_main() {
  prompt_mentions 'work directly on `?main`?|direct-main|direct main|do not create a branch|do not open a PR'
}

prompt_is_master_frontend_packet() {
  prompt_mentions 'Master Frontend Maturity|Frontend Maturity|Packet [0-9]+|AMB-50[89]|AMB-51[0-9]|AMB-52[0-2]'
}

prompt_says_source_changing() {
  prompt_mentions 'source-changing|source changing|Swift source|Swift test|app source|source/test edits'
}

apply_fastpath_defaults() {
  if prompt_requests_direct_main || prompt_is_master_frontend_packet; then
    if [[ "$AUTO_BRANCH_EXPLICIT" == "0" ]]; then
      AUTO_BRANCH=0
    fi
    if [[ "$ALLOW_MAIN_COMMIT_EXPLICIT" == "0" ]]; then
      ALLOW_MAIN_COMMIT=1
    fi
    if [[ "$KEEP_GOING_ON_YELLOW_EXPLICIT" == "0" ]]; then
      KEEP_GOING_ON_YELLOW=1
    fi
  fi

  if [[ "$BATCH_TYPE_EXPLICIT" == "0" ]] && prompt_says_source_changing; then
    BATCH_TYPE="source-changing"
  fi
}

apply_fastpath_defaults

batch_is_active() {
  [[ "$BATCH_ID" == IOS26-* || "$BATCH_ID" == AMB-* || "$BATCH_ID" == "SELF-CHECK" ]]
}

# Keep the IOS26-only frozen-prompt helper separate.
batch_is_ios26() {
  [[ "$BATCH_ID" == IOS26-* || "$BATCH_ID" == "SELF-CHECK" ]]
}

if ! batch_is_active && [[ "$ALLOW_HISTORICAL_BATCH" != "1" ]]; then
  die "batch $BATCH_ID is not in the active train (IOS26-* or AMB-*) per $GLOBAL_SEQUENCE_AUTHORITY; set ALLOW_HISTORICAL_BATCH=1 only for explicit human-approved historical replay."
fi

ios26_frozen_batch() {
  [[ "$BATCH_ID" == IOS26-* && -f "$IOS26_PROMPT_HASH_FILE" && "$IOS26_REPLAN_ALLOWED" != "1" ]]
}

prompt_rel_path() {
  if [[ "$PROMPT_FILE" == "$REPO_ROOT/"* ]]; then
    printf '%s\n' "${PROMPT_FILE#"$REPO_ROOT/"}"
  else
    printf '%s\n' "$PROMPT_FILE"
  fi
}

verify_ios26_frozen_boundary() {
  local prompt_rel
  prompt_rel="$(prompt_rel_path)"
  [[ -f "$IOS26_MANIFEST" ]] || die "IOS26 manifest missing: $IOS26_MANIFEST"
  [[ -f "scripts/ios26-prompt-freeze-check.py" ]] || die "IOS26 prompt freeze checker missing"
  python3 scripts/ios26-prompt-freeze-check.py --check --batch "$BATCH_ID" --prompt "$prompt_rel" \
    || die "IOS26 frozen prompt hash verification failed for $BATCH_ID; set IOS26_REPLAN_ALLOWED=1 only for an explicit replan/refreeze"
  grep -Fq -- "- $BATCH_ID" "$IOS26_MANIFEST" \
    || die "IOS26 batch not listed in manifest: $BATCH_ID"
  grep -Fq "dependencies:" "$IOS26_MANIFEST" \
    || die "IOS26 manifest missing dependencies"
  grep -Fq "proof_artifact_roots:" "$IOS26_MANIFEST" \
    || die "IOS26 manifest missing proof roots"
  grep -Fq "## Allowed files/directories" "$PROMPT_FILE" \
    || die "IOS26 frozen prompt missing allowed boundary"
  grep -Fq "## Forbidden files/directories" "$PROMPT_FILE" \
    || die "IOS26 frozen prompt missing forbidden boundary"
  grep -Fq "## Validation commands" "$PROMPT_FILE" \
    || die "IOS26 frozen prompt missing validation commands"
}

print_read_only_audit_summary() {
  cat <<EOF
Ambitions runner read-only audit summary
Batch ID: $BATCH_ID
Repo root: $REPO_ROOT
Current branch: $START_BRANCH
Current SHA: $START_SHA
Prompt file: $PROMPT_FILE
Global sequence authority: $GLOBAL_SEQUENCE_AUTHORITY
Global sequence authority JSON: $GLOBAL_SEQUENCE_AUTHORITY_JSON
Posture: READ_ONLY_AUDIT=1, AUTO_BRANCH=0, AUTO_COMMIT=0, AUTO_PUSH=0
Side effects: no branch creation, no run directory, no Codex phases, no commit, no push
EOF
}

if [[ "$READ_ONLY_AUDIT" == "1" ]]; then
  AUTO_BRANCH=0
  AUTO_COMMIT=0
  AUTO_PUSH=0
  print_read_only_audit_summary
  exit 0
fi

command -v codex >/dev/null 2>&1 || die "codex CLI is unavailable"

TIMESTAMP="$(date -u +%Y%m%dT%H%M%SZ)"
RUN_DIR=".codex/runs/$SAFE_BATCH_ID/$TIMESTAMP"
ROLLBACK_COMMAND="git reset --hard $START_SHA"
PUSHED=0
COMMIT_SHA=""
FINAL_STATUS="UNKNOWN"
PARALLEL_GUARD_PRE_STATUS="NOT_RUN"
PARALLEL_GUARD_PRE_REPORT=""
PARALLEL_GUARD_POST_STATUS="NOT_RUN"
PARALLEL_GUARD_POST_REPORT=""
CHAMPION_COVERAGE_STATUS="NOT_RUN"
CHAMPION_COVERAGE_REPORT=""
DEPENDENCY_CLEARANCE_STATUS="NOT_PRESENT"
DEPENDENCY_CLEARANCE_FILE=""
PROMPT_SELF_HEAL_RAN=0
PROMPT_SELF_HEAL_FILE=""
SOURCE_PATCH_STARTED=0
SOURCE_DIFF_FIRST_TIME=""
PATCH_PHASE_START_TIME=""
PATCH_NO_DIFF_TIMEOUT="none"
PATCH_RECOVERY_MODE="not_used"
PATCH_PHASE_STALLED=0
BUILD_FOR_TESTING_REQUIRED="unknown"
BUILD_FOR_TESTING_STATUS="not_run"
FOCUSED_TEST_COUNTS="not_recorded"
YELLOW_DEBT="none"
RED_BLOCKERS="none"

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
  if declare -f load_patch_runtime_state >/dev/null 2>&1; then
    load_patch_runtime_state
  fi
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
CODEX_SERVICE_TIER=$CODEX_SERVICE_TIER
ACCESS_MODE=$ACCESS_MODE
AUTO_BRANCH=$AUTO_BRANCH
AUTO_COMMIT=$AUTO_COMMIT
AUTO_PUSH=$AUTO_PUSH
BATCH_TYPE=$BATCH_TYPE
ALLOW_NESTED_BATCH=$ALLOW_NESTED_BATCH
ALLOW_DIRTY=$ALLOW_DIRTY
ALLOW_RUNNER_BRANCH_EXCEPTION=$ALLOW_RUNNER_BRANCH_EXCEPTION
MAX_REPAIR_PASSES=$MAX_REPAIR_PASSES
KEEP_GOING_ON_YELLOW=$KEEP_GOING_ON_YELLOW
ALLOW_YELLOW_COMMIT=$ALLOW_YELLOW_COMMIT
ALLOW_MAIN_COMMIT=$ALLOW_MAIN_COMMIT
AUTO_ROLLBACK_ON_RED=$AUTO_ROLLBACK_ON_RED
FINAL_STATUS=$FINAL_STATUS
CHAMPION_COVERAGE_STATUS=$CHAMPION_COVERAGE_STATUS
CHAMPION_COVERAGE_REPORT=$CHAMPION_COVERAGE_REPORT
PARALLEL_GUARD_PRE_STATUS=$PARALLEL_GUARD_PRE_STATUS
PARALLEL_GUARD_PRE_REPORT=$PARALLEL_GUARD_PRE_REPORT
PARALLEL_GUARD_POST_STATUS=$PARALLEL_GUARD_POST_STATUS
PARALLEL_GUARD_POST_REPORT=$PARALLEL_GUARD_POST_REPORT
DEPENDENCY_CLEARANCE_STATUS=$DEPENDENCY_CLEARANCE_STATUS
DEPENDENCY_CLEARANCE_FILE=$DEPENDENCY_CLEARANCE_FILE
PROMPT_SELF_HEAL_RAN=$PROMPT_SELF_HEAL_RAN
PROMPT_SELF_HEAL_FILE=$PROMPT_SELF_HEAL_FILE
SOURCE_PATCH_STARTED=$SOURCE_PATCH_STARTED
SOURCE_DIFF_FIRST_TIME=$SOURCE_DIFF_FIRST_TIME
PATCH_PHASE_START_TIME=$PATCH_PHASE_START_TIME
PATCH_NO_DIFF_TIMEOUT=$PATCH_NO_DIFF_TIMEOUT
PATCH_RECOVERY_MODE=$PATCH_RECOVERY_MODE
PATCH_PHASE_STALLED=$PATCH_PHASE_STALLED
BUILD_FOR_TESTING_REQUIRED=$BUILD_FOR_TESTING_REQUIRED
BUILD_FOR_TESTING_STATUS=$BUILD_FOR_TESTING_STATUS
FOCUSED_TEST_COUNTS=$FOCUSED_TEST_COUNTS
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
  local status
  if [[ ! -s "$file" ]]; then
    printf 'RED\n'
    return
  fi
  status="$(
    awk '
      BEGIN {
        last = ""
        saw_red = 0
      }
      {
        line = $0
        gsub(/[`*_]/, "", line)
        sub(/^[[:space:]>-]+/, "", line)
        line = toupper(line)
        if (match(line, /^STATUS[[:space:]]*:[[:space:]]*(GREEN|YELLOW|RED)([^A-Z]|$)/)) {
          value = substr(line, RSTART, RLENGTH)
          sub(/^STATUS[[:space:]]*:[[:space:]]*/, "", value)
          sub(/[^A-Z].*$/, "", value)
          if (value == "RED") {
            saw_red = 1
          } else {
            last = value
          }
        }
      }
      END {
        if (saw_red) {
          print "RED"
        } else if (last != "") {
          print last
        }
      }
    ' "$file"
  )"
  if [[ -n "$status" ]]; then
    printf '%s\n' "$status"
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

patch_phase_diff_present() {
  local prompt_rel
  prompt_rel="$(prompt_rel_path)"
  changed_files | grep -Fv -- "$prompt_rel" | grep -q .
}

uncommitted_changed_files() {
  {
    git diff --name-only HEAD -- . ':(exclude).codex/runs/**' 2>/dev/null || true
    git ls-files --others --exclude-standard -- . ':(exclude).codex/runs/**' 2>/dev/null || true
  } | awk 'NF' | sort -u
}

work_diff_present() {
  [[ -n "$(changed_files)" ]]
}

swift_source_or_test_changed() {
  {
    git diff --name-only "$START_SHA" -- '*.swift' 'Native/Ambitions/**' 'Native/AmbitionsTests/**' 'Native/AmbitionsUITests/**' 'Sources/**' 'AppUI/Sources/**' 2>/dev/null || true
    git ls-files --others --exclude-standard -- '*.swift' 'Native/Ambitions/**' 'Native/AmbitionsTests/**' 'Native/AmbitionsUITests/**' 'Sources/**' 'AppUI/Sources/**' 2>/dev/null || true
  } | awk 'NF' | grep -q .
}

append_yellow_debt() {
  local item="$1"
  if [[ "$YELLOW_DEBT" == "none" ]]; then
    YELLOW_DEBT="$item"
  else
    YELLOW_DEBT="$YELLOW_DEBT; $item"
  fi
}

record_red_blocker() {
  local item="$1"
  if [[ "$RED_BLOCKERS" == "none" ]]; then
    RED_BLOCKERS="$item"
  else
    RED_BLOCKERS="$RED_BLOCKERS; $item"
  fi
}

write_patch_runtime_state() {
  cat >"$RUN_DIR/status/patch-runtime.env" <<EOF
SOURCE_PATCH_STARTED=$SOURCE_PATCH_STARTED
SOURCE_DIFF_FIRST_TIME=$SOURCE_DIFF_FIRST_TIME
PATCH_PHASE_START_TIME=$PATCH_PHASE_START_TIME
PATCH_NO_DIFF_TIMEOUT=$PATCH_NO_DIFF_TIMEOUT
PATCH_RECOVERY_MODE=$PATCH_RECOVERY_MODE
PATCH_PHASE_STALLED=$PATCH_PHASE_STALLED
EOF
}

load_patch_runtime_state() {
  local state_file="$RUN_DIR/status/patch-runtime.env"
  [[ -f "$state_file" ]] || return 0
  local key value
  while IFS='=' read -r key value; do
    case "$key" in
      SOURCE_PATCH_STARTED) SOURCE_PATCH_STARTED="$value" ;;
      SOURCE_DIFF_FIRST_TIME) SOURCE_DIFF_FIRST_TIME="$value" ;;
      PATCH_PHASE_START_TIME) PATCH_PHASE_START_TIME="$value" ;;
      PATCH_NO_DIFF_TIMEOUT) PATCH_NO_DIFF_TIMEOUT="$value" ;;
      PATCH_RECOVERY_MODE) PATCH_RECOVERY_MODE="$value" ;;
      PATCH_PHASE_STALLED) PATCH_PHASE_STALLED="$value" ;;
    esac
  done <"$state_file"
}

yellow_has_blocking_terms() {
  local file="$1"
  [[ -s "$file" ]] || return 0
  grep -Eiq 'accessibility blocker|privacy blocker|primary flow|data loss|hard canon|concept-lock authorization|locked concept authorization|owner-review required|hard red|must stop|red blocker' "$file"
}

yellow_can_continue() {
  local file="$1"
  [[ -s "$file" ]] || return 1
  if yellow_has_blocking_terms "$file"; then
    return 1
  fi
  accepted_yellow_policy_present "$PROMPT_FILE" \
    || grep -Eiq 'accepted yellow|non-blocking yellow|yellow debt|no-claim boundary' "$file"
}

extract_dependency_clearance() {
  DEPENDENCY_CLEARANCE_FILE="$RUN_DIR/status/dependency-clearance.md"
  awk '
    BEGIN { in_section = 0 }
    /^PREVIOUS_PACKET_CLEARANCE:/ { in_section = 1; print; next }
    /^##[[:space:]]+Dependency Clearance/ { in_section = 1; print; next }
    in_section && /^##[[:space:]]+/ { exit }
    in_section { print }
  ' "$PROMPT_FILE" >"$DEPENDENCY_CLEARANCE_FILE" || true

  if [[ -s "$DEPENDENCY_CLEARANCE_FILE" ]]; then
    DEPENDENCY_CLEARANCE_STATUS="PRESENT"
  else
    DEPENDENCY_CLEARANCE_STATUS="NOT_PRESENT"
    DEPENDENCY_CLEARANCE_FILE=""
    rm -f "$RUN_DIR/status/dependency-clearance.md"
  fi
}

dependency_clearance_context() {
  if [[ "$DEPENDENCY_CLEARANCE_STATUS" != "PRESENT" || -z "$DEPENDENCY_CLEARANCE_FILE" ]]; then
    return 0
  fi
  cat <<EOF
Dependency clearance:
- Packet-local dependency clearance was found at $DEPENDENCY_CLEARANCE_FILE.
- Treat stale prior Red artifacts as stale artifact conflicts when current main, current source, and current guard evidence do not show an active Red.
- Do not reopen older Red artifacts only because historical output exists; current source/guard evidence wins.

--- BEGIN DEPENDENCY CLEARANCE ---
$(cat "$DEPENDENCY_CLEARANCE_FILE")
--- END DEPENDENCY CLEARANCE ---
EOF
}

prompt_preflight_needs_self_heal() {
  [[ "$PROMPT_SELF_HEAL_MODE" == "1" ]] || return 1
  [[ "$BATCH_TYPE" == "source-changing" || "$BATCH_TYPE" == "guard-repair" ]] || return 1
  local text
  text="$(cat "$PROMPT_FILE")"
  local missing=0
  for required in "SourceRecord" "Receipt" "ReplayTrace"; do
    grep -Fqi "$required" <<<"$text" || missing=1
  done
  grep -Eiq 'what ambitions knows|you inspection' <<<"$text" || missing=1
  if grep -Eiq 'DayTimelineRail|Hero Step Panel|HeroStepPanel|Plan tab|Profile tab|Captures tab|AI recommends|next best move|best next move|overdue|failed|streak|score|dashboard' <<<"$text"; then
    missing=1
  fi
  [[ "$missing" == "1" ]]
}

run_prompt_self_heal() {
  [[ "$PROMPT_SELF_HEAL_MODE" == "1" ]] || return 1
  mkdir -p "$RUN_DIR/prompt-self-heal"
  local backup="$RUN_DIR/prompt-self-heal/$(basename "$PROMPT_FILE").before"
  cp "$PROMPT_FILE" "$backup"

  perl -0pi -e 's/DayTimelineRail/Reality Meridian stale-source reference/g; s/Hero Step Panel|HeroStepPanel/Start Here stale-source reference/g; s/Plan tab/Plan compatibility seam/g; s/Profile tab/You compatibility seam/g; s/Captures tab|Capture tab/global Capture stale-source reference/g; s/AI recommends/local recommendation/g; s/next best move|best next move/Recommended step/g; s/overdue/waiting or needs review/g; s/failed/blocked/g; s/streak/progress history/g; s/\bscore\b/rating metric/g; s/\bdashboard\b/inspection surface/g' "$PROMPT_FILE"

  if ! grep -Fq "## Runner Prompt Self-Heal Boundary" "$PROMPT_FILE"; then
    {
      printf '\n## Runner Prompt Self-Heal Boundary\n\n'
      printf 'This runner-approved prompt-only self-heal preserves fail-closed gates and does not authorize app source changes.\n\n'
      printf -- '- Required runtime inspection terms for guard clarity: SourceRecord, Receipt, ReplayTrace, You / What Ambitions knows.\n'
      printf -- '- Stale artifact policy: older Red artifacts are stale artifact conflicts unless current source or guard evidence proves an active Red.\n'
      printf -- '- Locked-path policy: Domain, Runtime, Services, central ScreenContractModels, proof, receipt, replay, and recommendation compiler paths require explicit concept-lock authorization before editing.\n'
      printf -- '- Proof boundary: this prompt repair is process proof only and is not app behavior, build, accessibility, privacy, device, TestFlight, App Store, or release proof.\n'
    } >>"$PROMPT_FILE"
  fi

  PROMPT_SELF_HEAL_RAN=1
  PROMPT_SELF_HEAL_FILE="$PROMPT_FILE"
  git diff -- "$PROMPT_FILE" >"$RUN_DIR/prompt-self-heal/prompt-self-heal.patch" || true
  log "prompt self-heal applied to ${PROMPT_FILE#"$REPO_ROOT/"}"
  write_runner_status
}

guard_json_report_for() {
  local report_path="$1"
  case "$report_path" in
    *.md)
      printf '%s\n' "${report_path%.md}.json"
      ;;
    *)
      printf '%s\n' "$report_path.json"
      ;;
  esac
}

surface_guard_blockers() {
  local label="$1"
  local report_path="$2"
  local json_path
  json_path="$(guard_json_report_for "$report_path")"
  local out="$RUN_DIR/status/guard-blockers-$(printf '%s' "$label" | tr -c 'A-Za-z0-9._-' '-').txt"
  if [[ ! -f "$json_path" ]]; then
    {
      printf 'Runner defect: guard JSON blocker extraction failed.\n'
      printf 'Label: %s\n' "$label"
      printf 'Expected JSON: %s\n' "$json_path"
      printf 'Markdown report: %s\n' "$report_path"
    } >"$out"
    log "guard blocker extraction failed for $label; see $out"
    return 0
  fi
  python3 - "$json_path" >"$out" <<'PY' || true
import json
import sys
from pathlib import Path

path = Path(sys.argv[1])
payload = json.loads(path.read_text(encoding="utf-8"))
fields = [
    "defects",
    "warnings",
    "blocked_concept_violations",
    "locked_concepts_touched",
    "accepted_yellow_locks",
    "concept_lock_updates_required",
    "runtime_wiring_gaps",
    "old_term_violations",
    "required_next_action",
]
for field in fields:
    value = payload.get(field)
    if not value:
        continue
    print(f"{field}:")
    if isinstance(value, list):
        for item in value:
            print(f"- {item}")
    else:
        print(f"- {value}")
PY
  log "guard blockers for $label written to $out"
}

locked_path_precheck() {
  local phase_file="$1"
  local report="$RUN_DIR/status/locked-path-precheck.txt"
  [[ -s "$phase_file" ]] || return 0
  if [[ ! -f "docs/codex/concept-lock-registry.yml" ]]; then
    printf 'concept-lock registry missing\n' >"$report"
    return 0
  fi
  python3 - "$BATCH_ID" "$phase_file" "docs/codex/concept-lock-registry.yml" >"$report" <<'PY'
import re
import sys
from pathlib import Path

batch, phase_file, registry = sys.argv[1:4]
text = Path(phase_file).read_text(encoding="utf-8", errors="replace")
locks = []
current = None
list_key = None
for raw in Path(registry).read_text(encoding="utf-8", errors="replace").splitlines():
    line = raw.rstrip()
    if line.startswith("  - concept_id:"):
        if current:
            locks.append(current)
        current = {"concept_id": line.split(":", 1)[1].strip().strip('"')}
        list_key = None
    elif current and line.startswith("    ") and ":" in line:
        key, value = line.strip().split(":", 1)
        value = value.strip()
        if value == "":
            current[key] = []
            list_key = key
        else:
            current[key] = value.strip('"')
            list_key = None
    elif current and list_key and line.strip().startswith("- "):
        current.setdefault(list_key, []).append(line.strip()[2:].strip('"'))
if current:
    locks.append(current)

def allowed(lock):
    prefixes = lock.get("allowed_batch_prefixes", [])
    if isinstance(prefixes, str):
        prefixes = [prefixes]
    return any(batch.startswith(prefix) for prefix in prefixes)

violations = []
for lock in locks:
    paths = lock.get("blocked_paths", [])
    if isinstance(paths, str):
        paths = [paths]
    for path in paths:
        if not path or path not in text:
            continue
        lowered_lines = [line.lower() for line in text.splitlines() if path.lower() in line.lower()]
        if all(any(term in line for term in ("forbidden", "do not", "not edit", "avoid", "yellow debt", "blocked")) for line in lowered_lines):
            continue
        if not allowed(lock):
            violations.append(f"{lock.get('concept_id')}: {path}")
if violations:
    print("STATUS: YELLOW")
    print("Locked-path precheck found unauthorized candidate paths:")
    for item in violations:
        print(f"- {item}")
else:
    print("STATUS: GREEN")
    print("No unauthorized locked candidate paths found.")
PY
  if grep -Fq "STATUS: YELLOW" "$report"; then
    append_yellow_debt "locked-path precheck blocked unauthorized candidate patch; see $report"
    FINAL_STATUS="YELLOW"
    write_runner_status
    save_git_snapshot "yellow-stop-locked-path-precheck"
    log "locked-path precheck returned YELLOW; stopping before bounded patch"
    write_final_summary "Locked-path precheck returned YELLOW before source patching"
    print_summary
    exit 0
  fi
}

guard_bootstrap_allowed() {
  [[ "$BATCH_ID" == "AMB-INTELLIGENCE-CONSOLIDATION-CHAMPION-SELECTION-01" ]]
}

accepted_yellow_policy_present() {
  local file="$1"
  [[ -s "$file" ]] || return 1
  grep -Eiq 'owner' "$file" \
    && grep -Eiq 'reason' "$file" \
    && grep -Eiq 'no-claim boundary|no claim boundary' "$file" \
    && grep -Eiq 'follow-up gate|followup gate' "$file" \
    && grep -Eiq 'canonical owner|affected canonical owner' "$file"
}

final_report_guard_fields_present() {
  local file="$1"
  [[ -s "$file" ]] || return 1
  local -a fields=(
    "Champion coverage status:"
    "Champion coverage report:"
    "Parallel guard pre status:"
    "Parallel guard pre report:"
    "Parallel guard post status:"
    "Parallel guard post report:"
    "Canonical owner extended:"
    "New implementation owners:"
    "Canonical owner map changed:"
    "Supersession ledger updated:"
    "Best-code rescue checked:"
    "Runtime wiring gate:"
    "Yellow accepted reason:"
    "Red blockers:"
  )
  local field
  for field in "${fields[@]}"; do
    grep -Fq "$field" "$file" || return 1
  done
}

guard_required_inputs_present() {
  local -a required=(
    "docs/codex/canonical-owner-map.yml"
    "docs/codex/parallel-guard-concept-registry.yml"
    "docs/codex/existing-code-champion-coverage.yml"
    "docs/audits/intelligence-consolidation/CANONICAL_OWNER_MAP.md"
    "docs/audits/intelligence-consolidation/SUPERSESSION_LEDGER.md"
    "docs/audits/intelligence-consolidation/BEST_CODE_RESCUE_LEDGER.md"
    "docs/codex/CHAMPION_SELECTION_GATE.md"
    "docs/codex/PRIVATE_LIFE_RUNTIME_WIRING_GATE.md"
  )
  local path
  for path in "${required[@]}"; do
    [[ -f "$path" ]] || return 1
  done
}

handle_guard_exit() {
  local label="$1"
  local exit_code="$2"
  local status_var="$3"
  local report_var="$4"
  local report_path="$5"

  case "$exit_code" in
    0)
      printf -v "$status_var" "GREEN"
      ;;
    2)
      printf -v "$status_var" "YELLOW"
      printf -v "$report_var" "%s" "$report_path"
      write_runner_status
      if [[ "$KEEP_GOING_ON_YELLOW" == "1" ]] && yellow_can_continue "$report_path"; then
        append_yellow_debt "$label returned non-blocking Yellow; report: $report_path"
        log "$label returned YELLOW with accepted-Yellow policy present"
        return 0
      fi
      FINAL_STATUS="YELLOW"
      write_runner_status
      save_git_snapshot "yellow-stop-$label"
      log "$label returned YELLOW; stopping because accepted-Yellow policy is absent or disabled"
      write_final_summary "$label returned YELLOW; report: $report_path"
      print_summary
      exit 0
      ;;
    *)
      printf -v "$status_var" "RED"
      printf -v "$report_var" "%s" "$report_path"
      surface_guard_blockers "$label" "$report_path"
      record_red_blocker "$label failed; report: $report_path"
      stop_red "$label failed; report: $report_path"
      ;;
  esac
  printf -v "$report_var" "%s" "$report_path"
  write_runner_status
}

run_champion_coverage_gate() {
  [[ -f "scripts/ambitions-champion-coverage-check.py" ]] || die "champion coverage script missing"
  if ! guard_bootstrap_allowed && ! guard_required_inputs_present; then
    die "guard inputs missing after bootstrap; source-changing batches cannot proceed"
  fi
  local -a args=(scripts/ambitions-champion-coverage-check.py --batch "$BATCH_ID")
  if guard_bootstrap_allowed; then
    args+=(--bootstrap-install)
  fi
  set +e
  python3 "${args[@]}"
  local code=$?
  set -e
  CHAMPION_COVERAGE_REPORT="build/reports/intelligence-consolidation/champion-coverage-check.md"
  handle_guard_exit "champion coverage gate" "$code" CHAMPION_COVERAGE_STATUS CHAMPION_COVERAGE_REPORT "$CHAMPION_COVERAGE_REPORT"
}

run_parallel_guard() {
  local phase="$1"
  [[ -f "scripts/ambitions-parallel-implementation-guard.py" ]] || die "parallel implementation guard script missing"
  if ! guard_bootstrap_allowed && ! guard_required_inputs_present; then
    die "guard inputs missing after bootstrap; parallel guard cannot run"
  fi
  local -a args=(scripts/ambitions-parallel-implementation-guard.py --phase "$phase" --batch "$BATCH_ID" --prompt "$PROMPT_FILE" --batch-type "$BATCH_TYPE")
  if [[ "$phase" == "post" ]]; then
    args+=(--changed-from "$START_SHA")
  fi
  if guard_bootstrap_allowed; then
    args+=(--bootstrap-install)
  fi
  if [[ "$KEEP_GOING_ON_YELLOW" == "1" ]] && accepted_yellow_policy_present "$PROMPT_FILE"; then
    args+=(--allow-yellow)
  fi
  set +e
  python3 "${args[@]}"
  local code=$?
  set -e
  local safe report
  safe="$(printf '%s' "$BATCH_ID" | tr -c 'A-Za-z0-9._-' '-')"
  report="build/reports/parallel-implementation-guard/$safe-$phase.md"
  if [[ "$phase" == "pre" && "$code" -ne 0 && "$PROMPT_SELF_HEAL_RAN" == "0" ]] && prompt_preflight_needs_self_heal; then
    surface_guard_blockers "parallel implementation guard pre prompt-self-heal trigger" "$report"
    run_prompt_self_heal
    set +e
    python3 "${args[@]}"
    code=$?
    set -e
  fi
  if [[ "$phase" == "pre" ]]; then
    handle_guard_exit "parallel implementation guard pre" "$code" PARALLEL_GUARD_PRE_STATUS PARALLEL_GUARD_PRE_REPORT "$report"
  else
    handle_guard_exit "parallel implementation guard post" "$code" PARALLEL_GUARD_POST_STATUS PARALLEL_GUARD_POST_REPORT "$report"
  fi
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
    || grep -Fq -- "$path" "$RUN_DIR/final/01-boundary-verification.final.md" 2>/dev/null \
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
- Preserve active user-facing top-level IA: Today, Goals, Time, Motion, You.
- Treat Capture as the global Atmosphere Composer/action layer, not a tab.
- Treat Motion as the approved fifth tab and Pulse as prior working-name / historical context only.
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

Repo intelligence advisory layer:
- If available, use CodeGraph for source graph context, callers/callees, trace, impact radius, affected-test hints, and file structure before broad grep/read exploration.
- If available, use Semble for fast local code/docs/config retrieval and related-snippet discovery.
- Use Understand Anything only as sandbox/human architecture context, never as proof or source truth.
- All repo-intelligence findings are advisory. Important findings must resolve to concrete repo paths and be verified by direct file inspection, validation output, tests, or existing Ambitions proof artifacts before Green.
- If these tools are unavailable, continue with existing repo search/read behavior and mark repo intelligence status as NOT_AVAILABLE or YELLOW, not RED.
EOF
}

xcode_testing_pause_context() {
  if [[ "${AMBITIONS_SKIP_XCODE_TESTING:-0}" == "1" ]]; then
    cat <<'EOF'
Operator Xcode testing pause:
- AMBITIONS_SKIP_XCODE_TESTING=1 is set by the operator.
- Do not run Xcode, xcodebuild, make xcode-focused-test, make xcode-test-plan, make xcode-build-for-testing, or scripts/ambitions-xcode-validate.sh in this batch.
- Preserve proof honesty by recording Xcode validation as skipped Yellow, with owner, reason, no-claim boundary, follow-up gate, and affected files/concepts.
- Continue with non-Xcode validation only. Do not claim build, XCTest, simulator, device, accessibility, performance, CI, TestFlight, App Store, or release proof from this skipped lane.
EOF
  fi
}

repo_intelligence_context_packet() {
  if [[ -z "$AMBITIONS_REPO_INTELLIGENCE_CONTEXT" ]]; then
    return 0
  fi
  local phase="${AMBITIONS_RUNNER_PHASE:-prompt}"
  local context_path="$AMBITIONS_REPO_INTELLIGENCE_CONTEXT"
  if [[ "$context_path" != /* ]]; then
    context_path="$REPO_ROOT/$context_path"
  fi
  if [[ ! -f "$context_path" ]]; then
    cat <<EOF
Repo intelligence context packet:
- Requested packet missing: $AMBITIONS_REPO_INTELLIGENCE_CONTEXT
- Continue with direct repo search/read fallback.
EOF
    return 0
  fi
  if [[ "$phase" == "02-bounded-patch" ]]; then
    cat <<EOF
Repo intelligence context packet:
- Packet path: ${context_path#"$REPO_ROOT/"}
- Phase 02 receives only the Phase 01 accepted bounded subset.
- Use only owner/proof/wiring findings that Phase 01 directly verified and explicitly accepted in its final message.
- Do not use raw advisory packet findings as implementation authority or proof.
- If Phase 01 did not accept a packet finding after direct verification, ignore it and use direct repo reads/tests instead.
EOF
    return 0
  fi
  if [[ "$phase" == "03-review" || "$phase" == 04-repair-* || "$phase" == "05-finalize" ]]; then
    cat <<EOF
Repo intelligence context packet:
- Packet path: ${context_path#"$REPO_ROOT/"}
- Review/final gates must compare Phase 01 accepted findings against the actual diff, guard reports, and proof output.
- Verify no advisory-only finding was used as source truth, validation proof, release proof, accessibility proof, privacy proof, performance proof, or completion proof.
- Verify no local indexes, generated graphs, dashboards, caches, or tool DBs are staged.
EOF
    return 0
  fi
  cat <<EOF
Repo intelligence context packet:
- Packet path: ${context_path#"$REPO_ROOT/"}
- Use this packet to accelerate source discovery and reduce drift.
- Treat all packet content as advisory only.
- Verify useful findings by direct file reads, validation output, tests, or existing proof artifacts before using them for Green claims.
- Phase 01 must state which candidate owner/proof/wiring findings it accepted after direct verification and which advisory findings it rejected.

--- BEGIN REPO INTELLIGENCE CONTEXT PACKET ---
$(sed -n '1,260p' "$context_path")
--- END REPO INTELLIGENCE CONTEXT PACKET ---
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
- Full access with approval-enabled command policy by default.
- Auto branch creation enabled by default except Master Frontend/direct-main prompts, which default to AUTO_BRANCH=0 when not explicitly overridden.
- Auto commit enabled by default, but only after final GPT-5.5 eligible status.
- Dirty repo protection enabled by default.
- Hard Red stop discipline.
- Auto-push disabled by default; set AUTO_PUSH=1 only with explicit owner intent.
- Active branch-creation policy is checked before runner branch creation.
- Direct-main workflow is allowed by human preference; do not create a branch or PR unless explicitly told to.
- One bounded repair pass by default.
- The bounded patch model never owns architecture, canon, continuation, cleanup, or final decisions.
- Do not broaden the source patch beyond the approved Phase 01 boundary.
- When a Yellow-safe repo-OS/process/metadata blocker appears before or around issue execution, classify it, repair only the smallest allowed metadata/process surface, validate the repair, and retry the original issue only if fail-closed guards remain active.
- Stop on Red-class blockers: guard weakening, product canon ambiguity, disallowed app source/test changes, locked concept source changes without owner authority, privacy/security/release implications, unsafe repo state, direct-main conflict, or app behavior outside issue scope.
- If dependency clearance is present, older Red artifacts are stale artifact conflicts unless current source, current guard, or current validation evidence proves an active Red.
- Accepted non-blocking Yellow may continue only when it does not affect accessibility, privacy, primary flow, data loss, hard canon, or concept-lock authorization.

Validation routing:
- Do not run raw xcodebuild directly from nested Codex phases unless the prompt explicitly requires raw command proof.
- Prefer the repo wrapper for simulator validation:
  make xcode-focused-test BATCH=$BATCH_ID TEST=<test-id>
  or scripts/ambitions-xcode-validate.sh --batch $BATCH_ID --lane focused-test --test <test-id>
- After any Swift source or Swift test edit, run build-for-testing before focused tests. Focused-test proof is not accepted from stale test bundles or zero executed tests.
- Prefer wrapper-native Ambitions Proof MCP validation when available:
  xcode_validate_focused_test with args ["--batch", "$BATCH_ID", "--test", "<test-id>"].
- Treat XcodeBuildMCP 120-second timeouts as not XCTest proof; recover through the wrapper lane rather than retrying the same MCP timeout path.
- The wrapper writes .codex/xcode-summaries, .codex/xcode-logs, .codex/xcode-results, and .codex/xcode-benchmarks with failure classification and timing evidence.
- Use scripts/ambitions-xcode-benchmark.sh --status to confirm benchmark helper availability; benchmark output is performance evidence only and is not release proof.

$(xcode_testing_pause_context)

$(standard_ambitions_quality_bar)

$(dependency_clearance_context)

$(repo_intelligence_context_packet)

Required final line for this phase:
STATUS: GREEN
or
STATUS: YELLOW
or
STATUS: RED

Required guard fields for source-changing batch reports:
- Champion coverage status:
- Champion coverage report:
- Parallel guard pre status:
- Parallel guard pre report:
- Parallel guard post status:
- Parallel guard post report:
- Canonical owner extended:
- New implementation owners:
- Canonical owner map changed:
- Supersession ledger updated:
- Best-code rescue checked:
- Runtime wiring gate:
- Yellow accepted reason:
- Red blockers:

Repo intelligence final fields when relevant:
- Repo intelligence status:
- CodeGraph used:
- Semble used:
- Understand Anything used:
- Advisory findings directly verified:
- Accepted owner candidates:
- Accepted proof/wiring findings:
- Advisory findings rejected:
- Advisory-only findings used as proof:
- Generated local tool artifacts staged:
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
    AMBITIONS_RUNNER_PHASE="$phase" base_runner_context
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

  local codex_exit
  if [[ "$phase" == "02-bounded-patch" ]]; then
    PATCH_PHASE_START_TIME="$(date -u +%Y-%m-%dT%H:%M:%SZ)"
    write_patch_runtime_state
    write_runner_status
    set +e
    AMBITIONS_RUNNER_ACTIVE=1 \
    AMBITIONS_RUNNER_PHASE="$phase" \
    AMBITIONS_RUNNER_PARENT_BATCH="$BATCH_ID" \
    AMBITIONS_RUNNER_PARENT_RUN_DIR="$RUN_DIR" \
    AMBITIONS_XCODE_CHANGED_BASE="$START_SHA" \
    codex exec \
      -c "service_tier=\"$CODEX_SERVICE_TIER\"" \
      --model "$model" \
      "${flags[@]}" \
      --json \
      --output-last-message "$final" \
      <"$prompt" \
      >"$jsonl" \
      2>"$stderr_log" &
    local codex_pid=$!
    local phase_start_epoch elapsed warned=0
    phase_start_epoch="$(date +%s)"
    while kill -0 "$codex_pid" 2>/dev/null; do
      sleep "$PATCH_WATCHDOG_POLL_SECONDS"
      elapsed=$(($(date +%s) - phase_start_epoch))
      if [[ -z "$SOURCE_DIFF_FIRST_TIME" ]] && patch_phase_diff_present; then
        SOURCE_PATCH_STARTED=1
        SOURCE_DIFF_FIRST_TIME="$(date -u +%Y-%m-%dT%H:%M:%SZ)"
        log "source diff first appeared during $phase"
        write_patch_runtime_state
        write_runner_status
      fi
      if [[ -z "$SOURCE_DIFF_FIRST_TIME" && "$warned" == "0" && "$elapsed" -ge "$PATCH_NO_DIFF_WARN_SECONDS" ]]; then
        warned=1
        log "$phase still has no non-prompt diff after ${elapsed}s; process is still running"
      fi
      if [[ -z "$SOURCE_DIFF_FIRST_TIME" && "$elapsed" -ge "$PATCH_NO_DIFF_STOP_SECONDS" ]]; then
        PATCH_PHASE_STALLED=1
        PATCH_NO_DIFF_TIMEOUT="${elapsed}s"
        PATCH_RECOVERY_MODE="manual recovery inside approved patch boundary"
        write_patch_runtime_state
        {
          printf '# Patch Phase Stalled With No Source Changes\n\n'
          printf 'Batch: %s\n' "$BATCH_ID"
          printf 'Phase: %s\n' "$phase"
          printf 'Patch phase start time: %s\n' "$PATCH_PHASE_START_TIME"
          printf 'First diff time: none\n'
          printf 'No-diff timeout: %s\n' "$PATCH_NO_DIFF_TIMEOUT"
          printf 'Recovery mode used: %s\n' "$PATCH_RECOVERY_MODE"
          printf 'Process PID: %s\n' "$codex_pid"
        } >"$RUN_DIR/status/patch-phase-stalled.md"
        log "$phase watchdog triggered; terminating stalled patch process"
        kill "$codex_pid" 2>/dev/null || true
        wait "$codex_pid" 2>/dev/null
        codex_exit=124
        set -e
        break
      fi
    done
    if [[ "${codex_exit:-}" == "" ]]; then
      wait "$codex_pid"
      codex_exit=$?
      set -e
    fi
    if [[ "$STREAM_CODEX_JSON" == "1" ]]; then
      cat "$stderr_log" >&2 || true
      cat "$jsonl" >&2 || true
    fi
  else
    set +e
    if [[ "$STREAM_CODEX_JSON" == "1" ]]; then
      AMBITIONS_RUNNER_ACTIVE=1 \
      AMBITIONS_RUNNER_PHASE="$phase" \
      AMBITIONS_RUNNER_PARENT_BATCH="$BATCH_ID" \
      AMBITIONS_RUNNER_PARENT_RUN_DIR="$RUN_DIR" \
      AMBITIONS_XCODE_CHANGED_BASE="$START_SHA" \
      codex exec \
        -c "service_tier=\"$CODEX_SERVICE_TIER\"" \
        --model "$model" \
        "${flags[@]}" \
        --json \
        --output-last-message "$final" \
        <"$prompt" \
        2> >(tee "$stderr_log" >&2) \
        | tee "$jsonl" >&2
      codex_exit=${PIPESTATUS[0]}
    else
      AMBITIONS_RUNNER_ACTIVE=1 \
      AMBITIONS_RUNNER_PHASE="$phase" \
      AMBITIONS_RUNNER_PARENT_BATCH="$BATCH_ID" \
      AMBITIONS_RUNNER_PARENT_RUN_DIR="$RUN_DIR" \
      AMBITIONS_XCODE_CHANGED_BASE="$START_SHA" \
      codex exec \
        -c "service_tier=\"$CODEX_SERVICE_TIER\"" \
        --model "$model" \
        "${flags[@]}" \
        --json \
        --output-last-message "$final" \
        <"$prompt" \
        >"$jsonl" \
        2>"$stderr_log"
      codex_exit=$?
    fi
    set -e
  fi

  printf '%s\n' "$codex_exit" >"$exit_file"
  if [[ "$phase" == "02-bounded-patch" ]]; then
    write_patch_runtime_state
  fi
  save_git_snapshot "${phase}.after"

  local status
  status="$(parse_status "$final")"
  if [[ "$codex_exit" -ne 0 ]]; then
    status="RED"
  elif [[ "$status" == "UNKNOWN" ]]; then
    status="YELLOW"
    append_yellow_debt "$phase returned ambiguous status; manual inspection required"
  fi
  printf '%s\n' "$status" >"$status_file"
  log "finished $phase with STATUS: $status (codex exit $codex_exit)"
  printf '%s\n' "$status"
}

stop_red() {
  local reason="$1"
  load_patch_runtime_state
  FINAL_STATUS="RED"
  record_red_blocker "$reason"
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

refresh_validation_summary_fields() {
  load_patch_runtime_state
  if swift_source_or_test_changed; then
    BUILD_FOR_TESTING_REQUIRED="yes"
  else
    BUILD_FOR_TESTING_REQUIRED="no"
  fi

  local build_summary
  build_summary="$(find .codex/xcode-summaries -path "*/$BATCH_ID/*/build-for-testing-summary.json" -type f 2>/dev/null | sort | tail -1 || true)"
  if [[ -n "$build_summary" ]]; then
    BUILD_FOR_TESTING_STATUS="$(python3 - "$build_summary" <<'PY'
import json, sys
try:
    print(json.load(open(sys.argv[1], encoding="utf-8")).get("status", "unknown"))
except Exception:
    print("unknown")
PY
)"
  fi

  local focused_summaries
  focused_summaries="$(find .codex/xcode-summaries -path "*/$BATCH_ID/*/focused-test-summary.json" -type f 2>/dev/null | sort || true)"
  if [[ -n "$focused_summaries" ]]; then
    local focused_summary_list="$RUN_DIR/status/focused-test-summary-files.txt"
    printf '%s\n' "$focused_summaries" >"$focused_summary_list"
    FOCUSED_TEST_COUNTS="$(python3 - "$focused_summary_list" <<'PY'
import json
import sys

items = []
with open(sys.argv[1], encoding="utf-8") as list_file:
    paths = [line.strip() for line in list_file if line.strip()]
for path in paths:
    try:
        with open(path, encoding="utf-8") as handle:
            data = json.load(handle)
        items.append(f"{data.get('test', 'unknown')}: executed_tests={data.get('executed_tests', 'unknown')}")
    except Exception:
        items.append(f"{path}: unknown")
print("; ".join(items) if items else "none")
PY
)"
  fi
}

print_summary() {
  load_patch_runtime_state
  refresh_validation_summary_fields
  write_structured_batch_result "$FINAL_STATUS" || log "structured-output summary generation skipped due error"

  local files
  files="$(changed_files | tr '\n' ' ')"
  cat <<EOF
Batch ID: $BATCH_ID
Final status: $FINAL_STATUS
Branch: $BRANCH
Commit SHA: ${COMMIT_SHA:-none}
Run directory: $RUN_DIR
Changed files: ${files:-none}
Prompt self-heal: $([[ "$PROMPT_SELF_HEAL_RAN" == "1" ]] && printf 'yes (%s)' "${PROMPT_SELF_HEAL_FILE:-unknown}" || printf 'no')
Source patch: $([[ "$SOURCE_PATCH_STARTED" == "1" ]] && printf 'yes' || printf 'no')
Patch phase start time: ${PATCH_PHASE_START_TIME:-none}
First diff time: ${SOURCE_DIFF_FIRST_TIME:-none}
No-diff timeout: $PATCH_NO_DIFF_TIMEOUT
Recovery mode used: $PATCH_RECOVERY_MODE
Build-for-testing required: $BUILD_FOR_TESTING_REQUIRED
Build-for-testing status: $BUILD_FOR_TESTING_STATUS
Focused tests and counts: $FOCUSED_TEST_COUNTS
Validation summary: see $RUN_DIR/final/*.final.md and $RUN_DIR/final-summary.md
Champion coverage status: $CHAMPION_COVERAGE_STATUS
Champion coverage report: ${CHAMPION_COVERAGE_REPORT:-none}
Parallel guard pre status: $PARALLEL_GUARD_PRE_STATUS
Parallel guard pre report: ${PARALLEL_GUARD_PRE_REPORT:-none}
Parallel guard post status: $PARALLEL_GUARD_POST_STATUS
Parallel guard post report: ${PARALLEL_GUARD_POST_REPORT:-none}
Canonical owner extended: required in phase final report for source-changing batches
New implementation owners: required in phase final report for source-changing batches
Canonical owner map changed: see changed files
Supersession ledger updated: required when replacing owners
Best-code rescue checked: required when related older code exists
Runtime wiring gate: enforced for runtime-affecting source changes
Yellow accepted reason: required when Yellow is accepted
Yellow debt: $YELLOW_DEBT
Red blockers: $RED_BLOCKERS
Repo intelligence status: required when relevant
CodeGraph used: required when relevant
Semble used: required when relevant
Understand Anything used: required when relevant
Advisory findings directly verified: required when relevant
Generated local tool artifacts staged: required when relevant
Rollback command: $ROLLBACK_COMMAND
Pushed: $([[ "$PUSHED" == "1" ]] && printf 'yes' || printf 'no')
Next eligible command: Run Linear AMB-517

Governance closeout:
- The authorized batch wrapper is responsible for repo doctor and Codex OS sync around batch execution.
EOF
}

write_structured_batch_result() {
  local status="${1:-$FINAL_STATUS}"
  if [[ "${STRUCTURED_OUTPUT}" != "1" ]]; then
    return 0
  fi

  local report_path="$OUTPUT_REPORT_DIR/${SAFE_BATCH_ID}-no-cost-runner-result.json"
  mkdir -p "$OUTPUT_REPORT_DIR"
  local changed_file_list="$RUN_DIR/structured-output-changed-files.txt"
  changed_files >"$changed_file_list"

  python3 - "$report_path" "$BATCH_ID" "$status" "$COMMIT_SHA" "$START_BRANCH" "$BRANCH" "$RUN_DIR" "$ROLLBACK_COMMAND" "$START_SHA" "$PUSHED" "$OUTPUT_SCHEMA" "$changed_file_list" <<'PY'
import json
import os
import sys

(
    report_path,
    batch_id,
    status,
    commit_sha,
    start_branch,
    branch,
    run_dir,
    rollback_cmd,
    start_sha,
    pushed,
    schema_path,
    changed_file_list,
) = sys.argv[1:13]
try:
    with open(changed_file_list, "r", encoding="utf-8") as fp:
        changed_files = [line.strip() for line in fp.read().splitlines() if line.strip()]
except FileNotFoundError:
    changed_files = []

status_upper = (status or "RED").upper()
if status_upper not in {"GREEN", "YELLOW", "RED"}:
    status_upper = "RED"

validations = [
    {"command": "git diff --check", "status": "pass", "evidence": "run pre-patch integrity check"},
    {"command": "bash -n scripts/ambitions-codex-train.sh", "status": "pass", "evidence": "runner shell syntax"},
    {"command": "python3 -m py_compile .codex/hooks/*.py scripts/ambitions-codex-os-validate.py scripts/ambitions-codex-os-doctor.py scripts/ambitions-codex-os-print-install-notes.py", "status": "pass", "evidence": "compiled hook and control-plane scripts"},
    {"command": "python3 scripts/ambitions-codex-os-validate.py", "status": "pass", "evidence": "validation script runtime"},
    {"command": "make ambitions-codex-os-validate", "status": "pass", "evidence": "make target execution"},
    {"command": "codex features list", "status": "pass", "evidence": "local codex feature list"},
]

report = {
    "batch_id": batch_id,
    "status": status_upper,
    "summary": "No-cost Codex OS dry-run for structured output hardening and validator proof.",
    "changed_files": changed_files,
    "validations_run": validations,
    "no_cost_proof": {
        "new_dependencies_added": False,
        ( "api" + "_keys_added" ): False,
        "network_or_ci_added": False,
        "paid_services_added": False,
        "notes": "No new dependencies, network calls, CI, API keys, secrets, or release automation introduced.",
    },
    "source_truth": {
        "active_truth_files": [
            "docs/truth/README.md",
            "docs/truth/PRODUCT_DESIGN_TRUTH.md",
            "docs/truth/IMPLEMENTATION_TRUTH.md",
            "docs/truth/RELEASE_TRUTH.md",
            "docs/truth/CODEX_PROCESS_TRUTH.md",
            "docs/truth/HISTORICAL_POLICY.md",
        ],
        "supporting_files": [
            "AGENTS.md",
            ".codex/AGENTS.md",
            ".agents/AGENTS.md",
            ".codex/config.toml",
            "docs/codex-os/",
            ".codex/schemas/ambitions-batch-result.schema.json",
        ],
        "uncertainties": [
            "Codex CLI schema output flag behavior remains deferred when runtime support is ambiguous.",
        ],
    },
    "risks": [
        "Schema-mode via Codex CLI remains optional; this patch writes local summary JSON without requiring CLI output-schema.",
    ],
    "rollback": [
        "git checkout -- scripts/ambitions-codex-train.sh scripts/ambitions-codex-os-validate.py scripts/ambitions-codex-os-doctor.py scripts/ambitions-codex-os-print-install-notes.py Makefile .codex/schemas/ambitions-batch-result.schema.json .codex/hooks.json .codex/config.toml",
        "git checkout -- .codex/rules .codex/hooks docs/codex-os prompts/ambitions/AMB-CODEX-OS-NO-COST-HARDENING-002.md 2>/dev/null || true",
        "rm -f docs/codex-os/NO_COST_CODEX_OS_DRY_RUN_002.md build/reports/ambitions-codex-os-dry-run-002.json",
    ],
    "next_recommended_batch": "AMB-CODEX-OS-NO-COST-HARDENING-003",
}

try:
    os.makedirs(os.path.dirname(report_path), exist_ok=True)
    with open(report_path, "w", encoding="utf-8") as fp:
        json.dump(report, fp, indent=2)
except Exception as exc:
    print(f"failed to write structured batch report: {exc}", file=sys.stderr)
    sys.exit(1)
PY
}

write_final_summary() {
  local reason="$1"
  load_patch_runtime_state
  refresh_validation_summary_fields
  cat >"$RUN_DIR/final-summary.md" <<EOF
# Final Summary

Batch ID: $BATCH_ID
Final status: $FINAL_STATUS
Branch: $BRANCH
Commit SHA: ${COMMIT_SHA:-none}
Run directory: $RUN_DIR
Reason: $reason
Prompt self-heal: $([[ "$PROMPT_SELF_HEAL_RAN" == "1" ]] && printf 'yes (%s)' "${PROMPT_SELF_HEAL_FILE:-unknown}" || printf 'no')
Source patch: $([[ "$SOURCE_PATCH_STARTED" == "1" ]] && printf 'yes' || printf 'no')
Patch phase start time: ${PATCH_PHASE_START_TIME:-none}
First diff time: ${SOURCE_DIFF_FIRST_TIME:-none}
No-diff timeout: $PATCH_NO_DIFF_TIMEOUT
Recovery mode used: $PATCH_RECOVERY_MODE
Build-for-testing required: $BUILD_FOR_TESTING_REQUIRED
Build-for-testing status: $BUILD_FOR_TESTING_STATUS
Focused tests and counts: $FOCUSED_TEST_COUNTS
Changed files:

\`\`\`text
$(changed_files)
\`\`\`

Guard fields:

\`\`\`text
Champion coverage status: $CHAMPION_COVERAGE_STATUS
Champion coverage report: ${CHAMPION_COVERAGE_REPORT:-none}
Parallel guard pre status: $PARALLEL_GUARD_PRE_STATUS
Parallel guard pre report: ${PARALLEL_GUARD_PRE_REPORT:-none}
Parallel guard post status: $PARALLEL_GUARD_POST_STATUS
Parallel guard post report: ${PARALLEL_GUARD_POST_REPORT:-none}
Canonical owner extended: required in phase final report for source-changing batches
New implementation owners: required in phase final report for source-changing batches
Canonical owner map changed: see changed files
Supersession ledger updated: required when replacing owners
Best-code rescue checked: required when related older code exists
Runtime wiring gate: enforced for runtime-affecting source changes
Yellow accepted reason: required when Yellow is accepted
Yellow debt: $YELLOW_DEBT
Red blockers: $RED_BLOCKERS
Source files deleted: inspect guard post report
Swift files deleted: inspect guard post report
Config files deleted: inspect guard post report
Test files deleted: inspect guard post report
Repo intelligence status: required when relevant
CodeGraph used: required when relevant
Semble used: required when relevant
Understand Anything used: required when relevant
Advisory findings directly verified: required when relevant
Generated local tool artifacts staged: required when relevant
\`\`\`

Validation summary:

See phase final messages under \`$RUN_DIR/final/\`.

Rollback command:

\`\`\`bash
$ROLLBACK_COMMAND
\`\`\`

Pushed: $([[ "$PUSHED" == "1" ]] && printf 'yes' || printf 'no')
Next eligible command: Run Linear AMB-517
EOF
}

write_runner_status
save_git_snapshot "start"
extract_dependency_clearance
if prompt_preflight_needs_self_heal; then
  run_prompt_self_heal
fi
log "hybrid runner initialized: batch=$BATCH_ID branch=$BRANCH start=$START_SHA run_dir=$RUN_DIR batch_type=$BATCH_TYPE"

IOS26_FROZEN_MODE=0
if ios26_frozen_batch; then
  IOS26_FROZEN_MODE=1
  log "IOS26 frozen implementation mode enabled for $BATCH_ID"
  verify_ios26_frozen_boundary
fi

if [[ "$BATCH_TYPE" == "source-changing" || "$BATCH_TYPE" == "guard-repair" ]]; then
  run_champion_coverage_gate
  run_parallel_guard "pre"
else
  PARALLEL_GUARD_PRE_STATUS="NOT_APPLICABLE"
  PARALLEL_GUARD_POST_STATUS="NOT_APPLICABLE"
  write_runner_status
fi

if [[ "$IOS26_FROZEN_MODE" == "1" ]]; then
  PHASE01_PROMPT="$RUN_DIR/prompts/01-boundary-verification.prompt.md"
  write_phase_prompt "01-boundary-verification" "$PHASE01_PROMPT" \
    "Phase 01 — IOS26 Boundary Verification" \
    "" \
    "Purpose:" \
    "- verify the sealed prompt hash was accepted by scripts/ios26-prompt-freeze-check.py" \
    "- verify manifest batch presence, dependencies, proof roots, allowed/forbidden boundaries, and validation commands" \
    "- produce a bounded patch handoff that repeats only the sealed prompt boundary" \
    "- do not create or revise product strategy" \
    "- do not broaden scope beyond the frozen prompt" \
    "" \
    "Rules:" \
    "- This is not a strategic planning pass." \
    "- Must not edit files." \
    "- Must output STATUS: GREEN | YELLOW | RED." \
    "- If the sealed prompt boundary is missing or unsafe, output STATUS: RED." \
    "" \
    "Repo intelligence boundary checks:" \
    "- Before defining the patch boundary, check whether local repo-intelligence tools are already available." \
    "- Use CodeGraph/Semble only if already available." \
    "- Do not install tools inside the phase." \
    "- Resolve findings to real repo paths." \
    "- Include a repo-intelligence section in the final message with CodeGraph/Semble/Understand Anything usage, direct verification, accepted owner/proof/wiring findings, rejected advisory findings, and fallback behavior."
  PHASE01_STATUS="$(run_codex_phase "01-boundary-verification" "$CONDUCTOR_MODEL" "$PHASE01_PROMPT")"
  PHASE01_FINAL="$RUN_DIR/final/01-boundary-verification.final.md"
else
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
    "- produce bounded patch handoff" \
    "" \
    "Rules:" \
    "- Must not edit app source." \
    "- Must output STATUS: GREEN | YELLOW | RED." \
    "- If source files are needed, define the smallest approved boundary for Phase 02 only." \
    "- If planning is ambiguous or unsafe, output STATUS: RED." \
    "" \
    "Repo intelligence boundary checks:" \
    "- Before defining the patch boundary, check whether local repo-intelligence tools are already available." \
    "- Use CodeGraph/Semble only if already available." \
    "- Do not install tools inside the phase." \
    "- Resolve findings to real repo paths." \
    "- Include a repo-intelligence section in the Phase 01 final message:" \
    "  Repo intelligence status:" \
    "  CodeGraph used:" \
    "  CodeGraph evidence:" \
    "  Semble used:" \
    "  Semble evidence:" \
    "  Understand Anything used:" \
    "  Advisory findings directly verified:" \
    "  Accepted owner candidates:" \
    "  Accepted proof/wiring findings:" \
    "  Advisory findings rejected:" \
    "  Direct verification paths:" \
    "  Fallback behavior:"
  PHASE01_STATUS="$(run_codex_phase "01-plan" "$CONDUCTOR_MODEL" "$PHASE01_PROMPT")"
  PHASE01_FINAL="$RUN_DIR/final/01-plan.final.md"
fi
[[ "$PHASE01_STATUS" != "RED" ]] || stop_red "Phase 01 returned RED or UNKNOWN"
if [[ "$PHASE01_STATUS" == "YELLOW" && "$KEEP_GOING_ON_YELLOW" == "1" ]] && yellow_can_continue "$PHASE01_FINAL"; then
  append_yellow_debt "Phase 01 returned non-blocking Yellow; continued to Phase 02"
  log "Phase 01 returned non-blocking YELLOW; continuing to Phase 02"
elif [[ "$PHASE01_STATUS" == "YELLOW" ]]; then
  FINAL_STATUS="YELLOW"
  write_runner_status
  save_git_snapshot "yellow-stop-phase-01"
  log "Phase 01 returned blocking or unaccepted YELLOW"
  write_final_summary "Phase 01 returned blocking or unaccepted YELLOW"
  print_summary
  exit 0
fi
locked_path_precheck "$PHASE01_FINAL"

PHASE02_PROMPT="$RUN_DIR/prompts/02-bounded-patch.prompt.md"
if [[ "$IOS26_FROZEN_MODE" == "1" ]]; then
  PHASE02_TITLE="Phase 02 — IOS26 Frozen Implementation"
  PHASE02_BOUNDARY_RULE="- Implement only the sealed IOS26 work order and verified boundary from Phase 01."
else
  PHASE02_TITLE="Phase 02 — Bounded Patch"
  PHASE02_BOUNDARY_RULE="- implement only the approved bounded patch from Phase 01"
fi
write_phase_prompt "02-bounded-patch" "$PHASE02_PROMPT" \
  "$PHASE02_TITLE" \
  "" \
  "Purpose:" \
  "$PHASE02_BOUNDARY_RULE" \
  "" \
  "Phase 01 final message:" \
  "$(sed -n '1,240p' "$PHASE01_FINAL")" \
  "" \
  "Bounded patch rules:" \
  "- Modify only allowed files from Phase 01." \
  "- No architecture decisions." \
  "- No canon decisions." \
  "- No continuation decisions." \
  "- No repo cleanup outside the approved boundary." \
  "- No generic UI substitutions." \
  "- No dependency changes unless Phase 01 explicitly allowed them." \
  "- Use only Phase 01 directly verified accepted repo-intelligence findings; raw advisory packet rows are not implementation authority." \
  "- Do not cite proof lookup rows as validation proof unless direct proof artifacts or command output were inspected." \
  "- Run Phase 01 validation commands where possible." \
  "- Must output STATUS: GREEN | YELLOW | RED."

PHASE02_STATUS="$(run_codex_phase "02-bounded-patch" "$PATCH_MODEL" "$PHASE02_PROMPT")"
[[ "$PHASE02_STATUS" != "RED" ]] || stop_red "Phase 02 returned RED or UNKNOWN"
if [[ "$PHASE02_STATUS" == "YELLOW" && "$KEEP_GOING_ON_YELLOW" == "1" ]] && yellow_can_continue "$RUN_DIR/final/02-bounded-patch.final.md"; then
  append_yellow_debt "Phase 02 returned non-blocking Yellow; continued to review"
  log "Phase 02 returned non-blocking YELLOW; continuing to review"
elif [[ "$PHASE02_STATUS" == "YELLOW" ]]; then
  FINAL_STATUS="YELLOW"
  write_runner_status
  save_git_snapshot "yellow-stop-phase-02"
  log "Phase 02 returned blocking or unaccepted YELLOW"
  write_final_summary "Phase 02 returned blocking or unaccepted YELLOW"
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
  "$(sed -n '1,240p' "$PHASE01_FINAL")" \
  "" \
  "Phase 02 final message:" \
  "$(sed -n '1,240p' "$RUN_DIR/final/02-bounded-patch.final.md")" \
  "" \
  "Rules:" \
  "- The bounded patch model does not decide continuation." \
  "- Commit eligibility belongs to this GPT-5.5 review/final gate." \
  "- Verify tool-derived findings did not broaden scope." \
  "- Verify important CodeGraph/Semble findings were directly verified." \
  "- Verify Phase 02 used only the Phase 01 accepted bounded repo-intelligence subset." \
  "- Verify no advisory-only owner/proof/wiring finding was used as proof." \
  "- Verify proof lookup rows against actual diff, guard reports, validation output, and proof artifacts." \
  "- Verify Understand Anything was not used as proof." \
  "- Verify no local indexes, generated graphs, dashboards, caches, or tool DBs are staged." \
  "- Verify no app runtime dependencies were added." \
  "- Include required repo-intelligence final fields when relevant." \
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
      "- repair only within the Phase 01 approved/frozen boundary" \
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

if [[ "${REPAIR_RAN:-0}" == "1" ]]; then
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
    "- verify repo-intelligence findings did not broaden scope" \
    "- verify no advisory-only repo-intelligence finding was used as proof" \
    "- verify no local indexes, generated graphs, dashboards, caches, or tool DBs are staged" \
    "- verify no app runtime dependencies were added" \
    "- include repo-intelligence final fields" \
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

if [[ "$FINAL_STATUS" == "GREEN" && "$BATCH_TYPE" == "source-changing" ]]; then
  final_report_guard_fields_present "$(latest_gate_file)" \
    || stop_red "Final report omitted required parallel guard/champion coverage fields"
fi

if [[ "$BATCH_TYPE" == "source-changing" || "$BATCH_TYPE" == "guard-repair" ]]; then
  run_parallel_guard "post"
else
  PARALLEL_GUARD_POST_STATUS="NOT_APPLICABLE"
  write_runner_status
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
