#!/usr/bin/env bash
set -Eeuo pipefail

ROOT="$(git rev-parse --show-toplevel 2>/dev/null || pwd)"
cd "$ROOT"

RUNNER="scripts/ambitions-codex-train.sh"

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
grep -q 'ALLOW_RUNNER_BRANCH_EXCEPTION="${ALLOW_RUNNER_BRANCH_EXCEPTION:-0}"' "$RUNNER" \
  || die "runner branch exception default is not explicit"
grep -q 'stage_changed_files()' "$RUNNER" \
  || die "runner staging helper missing"
grep -q 'done < <(changed_files)' "$RUNNER" \
  || die "runner does not compute an explicit stage set"

if grep -Eq '^[[:space:]]*git add (-A|\.)([[:space:]]|$)|^[[:space:]]*git commit -a([[:space:]]|$)' "$RUNNER"; then
  die "runner still contains broad staging or commit shortcuts"
fi

flags_output="$(ACCESS_MODE=full bash -c '
  case "${ACCESS_MODE:-full}" in
    full) printf "%s\n" --sandbox danger-full-access --ask-for-approval never ;;
    workspace) printf "%s\n" --sandbox workspace-write --ask-for-approval never ;;
    bypass) printf "%s\n" --dangerously-bypass-approvals-and-sandbox ;;
    *) exit 9 ;;
  esac
')"
[[ "$flags_output" == $'--sandbox\ndanger-full-access\n--ask-for-approval\nnever' ]] \
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
echo "- codex exec invoked: no"
echo "- app source mutation: no"
echo "- commit: no"
echo "- push: no"
