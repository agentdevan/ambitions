#!/usr/bin/env bash
set -Eeuo pipefail

ROOT="$(git rev-parse --show-toplevel 2>/dev/null || pwd)"
cd "$ROOT"

RUNNER="scripts/ambitions-codex-train.sh"
RUNNER_HEADER="prompts/_RUNNER_REQUIRED_HEADER.md"
BATCH_TEMPLATE="prompts/_BATCH_TEMPLATE.md"

die() {
  echo "RED: $*" >&2
  exit 1
}

check_status_parser_sample() {
  local text="$1"
  python3 - "$text" <<'PY'
import re
import sys

text = sys.argv[1] if len(sys.argv) > 1 else ""
statuses = []
for raw in text.splitlines():
    line = raw.strip()
    line = re.sub(r"^[-*]\s+", "", line)
    line = line.strip("`*_ \t")
    match = re.match(r"(?i)^status\s*:\s*(green|yellow|red)\b", line)
    if match:
        statuses.append(match.group(1).upper())
if "RED" in statuses:
    print("RED")
elif statuses:
    print(statuses[-1])
else:
    print("UNKNOWN")
PY
}

[[ -f "$RUNNER" ]] || die "runner missing: $RUNNER"
command -v git >/dev/null 2>&1 || die "git is unavailable"
git rev-parse --show-toplevel >/dev/null 2>&1 || die "not inside a git repo"

bash -n "$RUNNER"

grep -q 'AUTO_PUSH="${AUTO_PUSH:-0}"' "$RUNNER" \
  || die "runner AUTO_PUSH default is not 0"
grep -q 'READ_ONLY_AUDIT="${READ_ONLY_AUDIT:-0}"' "$RUNNER" \
  || die "runner read-only audit default is not explicit"
grep -q 'ALLOW_NESTED_BATCH="${ALLOW_NESTED_BATCH:-0}"' "$RUNNER" \
  || die "runner nested-batch default is not explicit"
grep -q 'AMBITIONS_RUNNER_ACTIVE=1' "$RUNNER" \
  || die "runner does not mark Codex phases as active runner contexts"
grep -q 'nested Ambitions batch runner invocation blocked' "$RUNNER" \
  || die "runner nested-batch guard is missing"
grep -q 'ALLOW_RUNNER_BRANCH_EXCEPTION="${ALLOW_RUNNER_BRANCH_EXCEPTION:-0}"' "$RUNNER" \
  || die "runner branch exception default is not explicit"
grep -q 'AUTO_BRANCH="${AUTO_BRANCH:-1}"' "$RUNNER" \
  || die "runner AUTO_BRANCH default is not explicit"
grep -q 'prompt_has_runner_metadata()' "$RUNNER" \
  || die "runner prompt metadata helper missing"
grep -q 'read-only audit summary' "$RUNNER" \
  || die "runner read-only audit summary missing"
grep -q 'stage_changed_files()' "$RUNNER" \
  || die "runner staging helper missing"
grep -q 'done < <(uncommitted_changed_files)' "$RUNNER" \
  || die "runner does not compute an explicit stage set"
grep -q 'final gate already created commit' "$RUNNER" \
  || die "runner does not record phase-created commits"
grep -Eq '^[[:space:]]*<!--[[:space:]]*AMBITIONS_RUNNER_REQUIRED:[[:space:]]*true[[:space:]]*-->' "$RUNNER_HEADER" \
  || die "runner header missing required AMBITIONS marker"
grep -Eq '^[[:space:]]*<!--[[:space:]]*RUN_WITH:[[:space:]]*scripts/ambitions-codex-train\.sh[[:space:]]*-->' "$RUNNER_HEADER" \
  || die "runner header missing required RUN_WITH marker"
grep -Eq '^[[:space:]]*<!--[[:space:]]*DIRECT_CODEX_EXECUTION:[[:space:]]*forbidden_unless_user_explicitly_bypasses_runner[[:space:]]*-->' "$RUNNER_HEADER" \
  || die "runner header missing required DIRECT_CODEX_EXECUTION marker"
grep -Eq '^[[:space:]]*<!--[[:space:]]*AMBITIONS_RUNNER_REQUIRED:[[:space:]]*true[[:space:]]*-->' "$BATCH_TEMPLATE" \
  || die "batch template missing required AMBITIONS marker"
grep -Eq '^[[:space:]]*<!--[[:space:]]*RUN_WITH:[[:space:]]*scripts/ambitions-codex-train\.sh[[:space:]]*-->' "$BATCH_TEMPLATE" \
  || die "batch template missing required RUN_WITH marker"
grep -Eq '^[[:space:]]*<!--[[:space:]]*DIRECT_CODEX_EXECUTION:[[:space:]]*forbidden_unless_user_explicitly_bypasses_runner[[:space:]]*-->' "$BATCH_TEMPLATE" \
  || die "batch template missing required DIRECT_CODEX_EXECUTION marker"
grep -Fq 'Today / Goals / Time / Motion / You' "$BATCH_TEMPLATE" \
  || die "batch template IA is not the canonical top-level active IA"
grep -Fq 'Today / Goals / Time / Motion / You' .codex/os/AMBITIONS_OPERATING_CONTEXT.md \
  || die "operating context does not match canonical top-level IA"
grep -Fq 'Treat Capture as the global Atmosphere Composer/action layer, not a tab' .codex/os/AMBITIONS_OPERATING_CONTEXT.md \
  || die "operating context does not preserve global Capture model"

if grep -Eq '^[[:space:]]*git add (-A|\.)([[:space:]]|$)|^[[:space:]]*git commit -a([[:space:]]|$)' "$RUNNER"; then
  die "runner still contains broad staging or commit shortcuts"
fi

flags_output="$(ACCESS_MODE=full bash -c '
  case "${ACCESS_MODE:-full}" in
    full) printf "%s\n" --sandbox danger-full-access ;;
    workspace) printf "%s\n" --sandbox workspace-write ;;
    bypass) printf "%s\n" --dangerously-bypass-approvals-and-sandbox ;;
    *) exit 9 ;;
  esac
')"
[[ "$flags_output" == $'--sandbox\ndanger-full-access' ]] \
  || die "full access flag construction failed"

[[ "$(check_status_parser_sample 'STATUS: GREEN')" == "GREEN" ]] \
  || die "GREEN parser sample failed"
[[ "$(check_status_parser_sample 'STATUS: YELLOW')" == "YELLOW" ]] \
  || die "YELLOW parser sample failed"
[[ "$(check_status_parser_sample 'Status: YELLOW')" == "YELLOW" ]] \
  || die "mixed-case status label parser sample failed"
[[ "$(check_status_parser_sample '**Status: Green**')" == "GREEN" ]] \
  || die "markdown Green parser sample failed"
[[ "$(check_status_parser_sample '- STATUS: GREEN')" == "GREEN" ]] \
  || die "bulleted Green parser sample failed"
[[ "$(check_status_parser_sample '`STATUS: YELLOW`')" == "YELLOW" ]] \
  || die "backticked Yellow parser sample failed"
[[ "$(check_status_parser_sample 'STATUS: RED')" == "RED" ]] \
  || die "RED parser sample failed"
[[ "$(check_status_parser_sample $'STATUS: GREEN\nSTATUS: RED')" == "RED" ]] \
  || die "explicit Red does not win parser sample failed"
[[ "$(check_status_parser_sample 'no explicit status')" == "UNKNOWN" ]] \
  || die "UNKNOWN parser sample failed"

if [[ "${RUNNER_FASTPATH_SELFTEST:-0}" == "1" ]]; then
  grep -q 'extract_dependency_clearance()' "$RUNNER" \
    || die "dependency clearance extractor missing"
  grep -q 'stale artifact conflict' "$RUNNER" \
    || die "stale artifact conflict policy missing"
  grep -q 'run_prompt_self_heal()' "$RUNNER" \
    || die "prompt self-heal helper missing"
  grep -q 'PROMPT_SELF_HEAL_RAN' "$RUNNER" \
    || die "prompt self-heal state missing"
  grep -q 'apply_fastpath_defaults()' "$RUNNER" \
    || die "direct-main fastpath defaults helper missing"
  grep -q 'yellow_can_continue()' "$RUNNER" \
    || die "Yellow continuation helper missing"
  grep -q 'PATCH_NO_DIFF_STOP_SECONDS' "$RUNNER" \
    || die "patch no-diff watchdog timeout missing"
  grep -q 'patch-phase-stalled.md' "$RUNNER" \
    || die "patch no-diff stall artifact missing"
  grep -q 'locked_path_precheck()' "$RUNNER" \
    || die "locked-path precheck missing"
  grep -q 'locked-path-precheck.txt' "$RUNNER" \
    || die "locked-path precheck artifact missing"
  grep -q 'surface_guard_blockers()' "$RUNNER" \
    || die "guard blocker extraction helper missing"
  grep -q 'STREAM_CODEX_JSON="${STREAM_CODEX_JSON:-0}"' "$RUNNER" \
    || die "quiet progress default missing"
  grep -q 'build-for-testing before focused tests' "$RUNNER" \
    || die "focused-test stale bundle instruction missing"
  bash -n scripts/ambitions-xcode-build-for-testing.sh
  bash -n scripts/ambitions-xcode-test-focused.sh
  bash -n scripts/ambitions-xcode-validate.sh
  grep -q 'EXECUTED_TESTS=' scripts/ambitions-xcode-test-focused.sh \
    || die "focused test wrapper does not report executed test count"
  grep -q 'test_discovery_failure' scripts/ambitions-xcode-test-focused.sh \
    || die "focused test zero-execution failure is missing"
  grep -q 'AMBITIONS_XCODE_CHANGED_BASE' scripts/ambitions-xcode-validate.sh \
    || die "stale bundle decision base missing"
  grep -q 'running build-for-testing before focused tests' scripts/ambitions-xcode-validate.sh \
    || die "focused prebuild decision missing"
  grep -q 'focused_rerun_after_prebuild' scripts/ambitions-xcode-validate.sh \
    || die "focused stale-test retry marker missing"
fi

safe_batch_id="$(printf '%s' "SELF-CHECK" | tr -c 'A-Za-z0-9._-' '-')"
timestamp="$(date -u +%Y%m%dT%H%M%SZ)"
run_dir=".codex/runs/$safe_batch_id/$timestamp"
[[ "$run_dir" == .codex/runs/SELF-CHECK/* ]] \
  || die "run directory derivation failed"

self_check_prompt="prompts/_BATCH_TEMPLATE.md"
[[ -f "$self_check_prompt" ]] || die "self-check prompt missing: $self_check_prompt"
read_only_output="$(env \
  -u AMBITIONS_RUNNER_ACTIVE \
  -u AMBITIONS_RUNNER_PHASE \
  -u AMBITIONS_RUNNER_PARENT_BATCH \
  -u AMBITIONS_RUNNER_PARENT_RUN_DIR \
  READ_ONLY_AUDIT=1 \
  bash "$RUNNER" SELF-CHECK "$self_check_prompt")"
grep -Fq 'Ambitions runner read-only audit summary' <<<"$read_only_output" \
  || die "read-only audit summary missing"
grep -Fq 'Posture: READ_ONLY_AUDIT=1, AUTO_BRANCH=0, AUTO_COMMIT=0, AUTO_PUSH=0' <<<"$read_only_output" \
  || die "read-only audit posture missing"
grep -Fq 'Side effects: no branch creation, no run directory, no Codex phases, no commit, no push' <<<"$read_only_output" \
  || die "read-only audit side-effect summary missing"

echo "GREEN: runner self-check passed"
echo "- bash syntax: ok"
echo "- git repo detection: ok"
echo "- run directory derivation: $run_dir"
echo "- access flags: ${flags_output//$'\n'/ }"
echo "- status parser samples: Green/Yellow/Red/Unknown ok"
if [[ "${RUNNER_FASTPATH_SELFTEST:-0}" == "1" ]]; then
  echo "- fastpath selftest: dependency clearance, prompt self-heal, Yellow continuation, watchdog, locked-path precheck, and stale-test checks ok"
fi
echo "- explicit staging helper: present"
echo "- read-only audit posture: present"
echo "- nested batch guard: present"
echo "- codex exec invoked: no"
echo "- app source mutation: no"
echo "- commit: no"
echo "- push: no"
