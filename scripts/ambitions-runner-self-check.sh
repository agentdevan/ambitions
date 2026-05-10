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
  if grep -Eiq 'STATUS:[[:space:]]*RED|Hard Red|HARD RED|RED[[:space:]]*/[[:space:]]*STOP' <<<"$text"; then
    printf 'RED\n'
  elif grep -Eiq 'STATUS:[[:space:]]*YELLOW' <<<"$text"; then
    printf 'YELLOW\n'
  elif grep -Eiq 'STATUS:[[:space:]]*GREEN' <<<"$text"; then
    printf 'GREEN\n'
  else
    printf 'UNKNOWN\n'
  fi
}

[[ -f "$RUNNER" ]] || die "runner missing: $RUNNER"
command -v git >/dev/null 2>&1 || die "git is unavailable"
git rev-parse --show-toplevel >/dev/null 2>&1 || die "not inside a git repo"

bash -n "$RUNNER"

grep -q 'AUTO_PUSH="${AUTO_PUSH:-0}"' "$RUNNER" \
  || die "runner AUTO_PUSH default is not 0"
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
grep -Fq 'Today / Goals / Capture / Time / You' "$BATCH_TEMPLATE" \
  || die "batch template IA is not the canonical top-level active IA"
grep -Fq 'Today / Goals / Capture / Time / You' docs/codex/ambitions-hybrid-runner.md \
  || die "hybrid runner docs do not match canonical top-level IA"

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
[[ "$(check_status_parser_sample 'STATUS: RED')" == "RED" ]] \
  || die "RED parser sample failed"
[[ "$(check_status_parser_sample 'no explicit status')" == "UNKNOWN" ]] \
  || die "UNKNOWN parser sample failed"

safe_batch_id="$(printf '%s' "SELF-CHECK" | tr -c 'A-Za-z0-9._-' '-')"
timestamp="$(date -u +%Y%m%dT%H%M%SZ)"
run_dir=".codex/runs/$safe_batch_id/$timestamp"
[[ "$run_dir" == .codex/runs/SELF-CHECK/* ]] \
  || die "run directory derivation failed"

echo "GREEN: runner self-check passed"
echo "- bash syntax: ok"
echo "- git repo detection: ok"
echo "- run directory derivation: $run_dir"
echo "- access flags: ${flags_output//$'\n'/ }"
echo "- status parser samples: Green/Yellow/Red/Unknown ok"
echo "- explicit staging helper: present"
echo "- nested batch guard: present"
echo "- codex exec invoked: no"
echo "- app source mutation: no"
echo "- commit: no"
echo "- push: no"
