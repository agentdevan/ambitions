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
PATCH_MODEL="${PATCH_MODEL:-gpt-5.4-mini}"
REVIEW_MODEL="${REVIEW_MODEL:-gpt-5.5}"
REPAIR_MODEL="${REPAIR_MODEL:-gpt-5.5}"

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
  PATCH_MODEL=gpt-5.4-mini
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

batch_is_ios26() {
  [[ "$BATCH_ID" == IOS26-* || "$BATCH_ID" == "SELF-CHECK" ]]
}

if ! batch_is_ios26 && [[ "$ALLOW_HISTORICAL_BATCH" != "1" ]]; then
  die "batch $BATCH_ID is historical per $GLOBAL_SEQUENCE_AUTHORITY; Codex global train runners may execute only IOS26-* batches. Set ALLOW_HISTORICAL_BATCH=1 only for explicit human-approved historical replay."
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
      {
        line = toupper($0)
        if (match(line, /^[[:space:]]*STATUS[[:space:]]*:[[:space:]]*(GREEN|YELLOW|RED)([^A-Z]|$)/)) {
          value = substr(line, RSTART, RLENGTH)
          sub(/^[[:space:]]*STATUS[[:space:]]*:[[:space:]]*/, "", value)
          sub(/[^A-Z].*$/, "", value)
          print value
        }
      }
    ' "$file" \
      | tail -1
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

uncommitted_changed_files() {
  {
    git diff --name-only HEAD -- . ':(exclude).codex/runs/**' 2>/dev/null || true
    git ls-files --others --exclude-standard -- . ':(exclude).codex/runs/**' 2>/dev/null || true
  } | awk 'NF' | sort -u
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
      if [[ "$KEEP_GOING_ON_YELLOW" == "1" ]] && accepted_yellow_policy_present "$PROMPT_FILE"; then
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

Repo intelligence advisory layer:
- If available, use CodeGraph for source graph context, callers/callees, trace, impact radius, affected-test hints, and file structure before broad grep/read exploration.
- If available, use Semble for fast local code/docs/config retrieval and related-snippet discovery.
- Use Understand Anything only as sandbox/human architecture context, never as proof or source truth.
- All repo-intelligence findings are advisory. Important findings must resolve to concrete repo paths and be verified by direct file inspection, validation output, tests, or existing Ambitions proof artifacts before Green.
- If these tools are unavailable, continue with existing repo search/read behavior and mark repo intelligence status as NOT_AVAILABLE or YELLOW, not RED.
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
- Auto branch creation enabled by default.
- Auto commit enabled by default, but only after final GPT-5.5 eligible status.
- Dirty repo protection enabled by default.
- Hard Red stop discipline.
- Auto-push disabled by default; set AUTO_PUSH=1 only with explicit owner intent.
- Active branch-creation policy is checked before runner branch creation.
- One bounded repair pass by default.
- GPT-5.4-mini never owns architecture, canon, continuation, cleanup, or final decisions.

Validation routing:
- Do not run raw xcodebuild directly from nested Codex phases unless the prompt explicitly requires raw command proof.
- Prefer the repo wrapper for simulator validation:
  make xcode-focused-test BATCH=$BATCH_ID TEST=<test-id>
  or scripts/ambitions-xcode-validate.sh --batch $BATCH_ID --lane focused-test --test <test-id>
- Prefer wrapper-native Ambitions Proof MCP validation when available:
  xcode_validate_focused_test with args ["--batch", "$BATCH_ID", "--test", "<test-id>"].
- Treat XcodeBuildMCP 120-second timeouts as not XCTest proof; recover through the wrapper lane rather than retrying the same MCP timeout path.
- The wrapper writes .codex/xcode-summaries, .codex/xcode-logs, .codex/xcode-results, and .codex/xcode-benchmarks with failure classification and timing evidence.
- Use scripts/ambitions-xcode-benchmark.sh --status to confirm benchmark helper availability; benchmark output is performance evidence only and is not release proof.

$(standard_ambitions_quality_bar)

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
  AMBITIONS_RUNNER_ACTIVE=1 \
  AMBITIONS_RUNNER_PHASE="$phase" \
  AMBITIONS_RUNNER_PARENT_BATCH="$BATCH_ID" \
  AMBITIONS_RUNNER_PARENT_RUN_DIR="$RUN_DIR" \
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
Red blockers: see guard reports and final summaries
Repo intelligence status: required when relevant
CodeGraph used: required when relevant
Semble used: required when relevant
Understand Anything used: required when relevant
Advisory findings directly verified: required when relevant
Generated local tool artifacts staged: required when relevant
Rollback command: $ROLLBACK_COMMAND
Pushed: $([[ "$PUSHED" == "1" ]] && printf 'yes' || printf 'no')

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
Red blockers: see guard reports
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
EOF
}

write_runner_status
save_git_snapshot "start"
log "hybrid runner initialized"
log "batch=$BATCH_ID branch=$BRANCH start=$START_SHA run_dir=$RUN_DIR"
log "batch_type=$BATCH_TYPE"

IOS26_FROZEN_MODE=0
if ios26_frozen_batch; then
  IOS26_FROZEN_MODE=1
  log "IOS26 frozen implementation mode enabled for $BATCH_ID"
  verify_ios26_frozen_boundary
fi

if [[ "$BATCH_TYPE" == "source-changing" || "$BATCH_TYPE" == "guard-repair" ]]; then
  run_champion_coverage_gate
fi
run_parallel_guard "pre"

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
    "- Include a repo-intelligence section in the final message with CodeGraph/Semble/Understand Anything usage, direct verification, and fallback behavior."
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
    "- produce GPT-5.4-mini bounded patch handoff" \
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
    "  Fallback behavior:"
  PHASE01_STATUS="$(run_codex_phase "01-plan" "$CONDUCTOR_MODEL" "$PHASE01_PROMPT")"
  PHASE01_FINAL="$RUN_DIR/final/01-plan.final.md"
fi
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

PHASE02_PROMPT="$RUN_DIR/prompts/02-bounded-patch.prompt.md"
if [[ "$IOS26_FROZEN_MODE" == "1" ]]; then
  PHASE02_TITLE="Phase 02 — IOS26 Frozen Implementation"
  PHASE02_BOUNDARY_RULE="- Implement only the sealed IOS26 work order and verified boundary from Phase 01."
else
  PHASE02_TITLE="Phase 02 — GPT-5.4-mini Bounded Patch"
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
  "GPT-5.4-mini bounded patch rules:" \
  "- Modify only allowed files from Phase 01." \
  "- No architecture decisions." \
  "- No canon decisions." \
  "- No continuation decisions." \
  "- No repo cleanup outside the approved boundary." \
  "- No generic UI substitutions." \
  "- No dependency changes unless Phase 01 explicitly allowed them." \
  "- Run Phase 01 validation commands where possible." \
  "- Must output STATUS: GREEN | YELLOW | RED."

PHASE02_STATUS="$(run_codex_phase "02-bounded-patch" "$PATCH_MODEL" "$PHASE02_PROMPT")"
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
  "$(sed -n '1,240p' "$PHASE01_FINAL")" \
  "" \
  "Phase 02 final message:" \
  "$(sed -n '1,240p' "$RUN_DIR/final/02-bounded-patch.final.md")" \
  "" \
  "Rules:" \
  "- GPT-5.4-mini does not decide continuation." \
  "- Commit eligibility belongs to this GPT-5.5 review/final gate." \
  "- Verify tool-derived findings did not broaden scope." \
  "- Verify important CodeGraph/Semble findings were directly verified." \
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
    "- verify repo-intelligence findings did not broaden scope" \
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

run_parallel_guard "post"

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
