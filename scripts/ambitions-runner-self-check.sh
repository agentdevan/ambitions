#!/usr/bin/env bash
set -Eeuo pipefail

ROOT="$(git rev-parse --show-toplevel 2>/dev/null || pwd)"
cd "$ROOT"

RUNNER="scripts/ambitions-codex-train.sh"
BATCH_TEMPLATE="prompts/_BATCH_TEMPLATE.md"
OPERATING_CONTEXT=".codex/os/AMBITIONS_OPERATING_CONTEXT.md"
PRODUCT_TRUTH="docs/truth/PRODUCT_DESIGN_TRUTH.md"

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
[[ -f "$PRODUCT_TRUTH" ]] || die "product truth missing: $PRODUCT_TRUTH"
[[ -f "$OPERATING_CONTEXT" ]] || die "operating context missing: $OPERATING_CONTEXT"
[[ -f "$BATCH_TEMPLATE" ]] || die "batch template missing: $BATCH_TEMPLATE"
command -v git >/dev/null 2>&1 || die "git is unavailable"
git rev-parse --show-toplevel >/dev/null 2>&1 || die "not inside a git repo"

bash -n "$RUNNER"

# Runner safety checks.
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
grep -q 'stage_changed_files()' "$RUNNER" \
  || die "runner staging helper missing"

if grep -Eq '^[[:space:]]*git add (-A|\.)([[:space:]]|$)|^[[:space:]]*git commit -a([[:space:]]|$)' "$RUNNER"; then
  die "runner still contains broad staging or commit shortcuts"
fi

# Current canon checks.
grep -Fq 'Today / Goals / Time / You' "$PRODUCT_TRUTH" \
  || die "product truth missing four-surface law"
grep -Fq 'Capture is the global composer' "$PRODUCT_TRUTH" \
  || die "product truth missing global Capture law"
grep -Fq 'Motion is cross-surface behavior' "$PRODUCT_TRUTH" \
  || die "product truth missing Motion behavior law"
grep -Fq 'Ambitions supports custom Ambitions Accounts at launch' "$PRODUCT_TRUTH" \
  || die "product truth missing Ambitions Account launch law"
grep -Fq 'R2 is not a user-data backend' "$PRODUCT_TRUTH" \
  || die "product truth missing R2 boundary"
grep -Fq 'Hosted AI services and cloud LLMs are not core architecture' "$PRODUCT_TRUTH" \
  || die "product truth missing hosted AI/cloud LLM boundary"

grep -Fq 'Today / Goals / Time / You' "$OPERATING_CONTEXT" \
  || die "operating context missing four-surface law"
grep -Fq 'Motion' "$OPERATING_CONTEXT" \
  || die "operating context missing Motion behavior reference"
grep -Fq 'Capture' "$OPERATING_CONTEXT" \
  || die "operating context missing Capture reference"

if grep -Fq 'Today / Goals / Time / Motion / You' "$BATCH_TEMPLATE"; then
  die "batch template still advertises Motion as top-level IA"
fi
if grep -Fq 'Motion replaces Pulse as the approved fifth tab' "$BATCH_TEMPLATE"; then
  die "batch template still contains stale Motion fifth-tab law"
fi

[[ "$(check_status_parser_sample 'STATUS: GREEN')" == "GREEN" ]] \
  || die "GREEN parser sample failed"
[[ "$(check_status_parser_sample 'STATUS: YELLOW')" == "YELLOW" ]] \
  || die "YELLOW parser sample failed"
[[ "$(check_status_parser_sample 'STATUS: RED')" == "RED" ]] \
  || die "RED parser sample failed"
[[ "$(check_status_parser_sample $'STATUS: GREEN\nSTATUS: RED')" == "RED" ]] \
  || die "explicit Red does not win parser sample failed"
[[ "$(check_status_parser_sample 'no explicit status')" == "UNKNOWN" ]] \
  || die "UNKNOWN parser sample failed"

safe_batch_id="$(printf '%s' "SELF-CHECK" | tr -c 'A-Za-z0-9._-' '-')"
timestamp="$(date -u +%Y%m%dT%H%M%SZ)"
run_dir=".codex/runs/$safe_batch_id/$timestamp"
[[ "$run_dir" == .codex/runs/SELF-CHECK/* ]] \
  || die "run directory derivation failed"

read_only_output="$(env \
  -u AMBITIONS_RUNNER_ACTIVE \
  -u AMBITIONS_RUNNER_PHASE \
  -u AMBITIONS_RUNNER_PARENT_BATCH \
  -u AMBITIONS_RUNNER_PARENT_RUN_DIR \
  READ_ONLY_AUDIT=1 \
  bash "$RUNNER" SELF-CHECK "$BATCH_TEMPLATE")"
grep -Fq 'Ambitions runner read-only audit summary' <<<"$read_only_output" \
  || die "read-only audit summary missing"
grep -Fq 'Side effects: no branch creation, no run directory, no Codex phases, no commit, no push' <<<"$read_only_output" \
  || die "read-only audit side-effect summary missing"

echo "GREEN: runner self-check passed"
echo "- bash syntax: ok"
echo "- product truth: four surfaces, global Capture, Motion behavior, account/R2/no-hosted-AI boundaries present"
echo "- operating context: current canon present"
echo "- run directory derivation: $run_dir"
echo "- status parser samples: Green/Yellow/Red/Unknown ok"
echo "- read-only audit posture: present"
echo "- nested batch guard: present"
echo "- app source mutation: no"
echo "- commit: no"
echo "- push: no"
