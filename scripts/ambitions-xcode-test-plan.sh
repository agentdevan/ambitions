#!/usr/bin/env bash
set -Eeuo pipefail

REPO_ROOT="$(git rev-parse --show-toplevel 2>/dev/null || pwd -P)"
cd "$REPO_ROOT"

BATCH=""
TEST_PLAN=""
SCHEME="auto"
RESULT_DIR=".codex/xcode-results"
LOG_DIR=".codex/xcode-logs"
SUMMARY_DIR=".codex/xcode-summaries"
TIMEOUT_DURATION="${AMBITIONS_XCODE_TEST_PLAN_TIMEOUT:-45m}"
KILL_AFTER="${AMBITIONS_XCODE_TEST_PLAN_KILL_AFTER:-60s}"

while [[ "$#" -gt 0 ]]; do
  case "$1" in
    --batch) BATCH="${2:-}"; shift 2 ;;
    --test-plan) TEST_PLAN="${2:-}"; shift 2 ;;
    --scheme) SCHEME="${2:-$SCHEME}"; shift 2 ;;
    --results-dir) RESULT_DIR="${2:-$RESULT_DIR}"; shift 2 ;;
    --logs-dir) LOG_DIR="${2:-$LOG_DIR}"; shift 2 ;;
    --summaries-dir) SUMMARY_DIR="${2:-$SUMMARY_DIR}"; shift 2 ;;
    --timeout) TIMEOUT_DURATION="${2:-$TIMEOUT_DURATION}"; shift 2 ;;
    --kill-after) KILL_AFTER="${2:-$KILL_AFTER}"; shift 2 ;;
    -h|--help)
      echo "Usage: scripts/ambitions-xcode-test-plan.sh --batch <BATCH> --test-plan <PLAN_NAME> [--scheme auto|AmbitionsSmoke|AmbitionsScreenshots|AmbitionsReleaseCandidate] [--timeout 45m] [--kill-after 60s]" >&2
      exit 0
      ;;
    *)
      echo "unsupported arg: $1" >&2
      exit 1
      ;;
  esac
done

[[ -n "$BATCH" ]] || { echo "--batch is required" >&2; exit 1; }
[[ -n "$TEST_PLAN" ]] || { echo "--test-plan is required" >&2; exit 1; }
[[ -n "$TIMEOUT_DURATION" ]] || { echo "--timeout must not be empty" >&2; exit 2; }
[[ -n "$KILL_AFTER" ]] || { echo "--kill-after must not be empty" >&2; exit 2; }

PLAN_PATH=""
if [[ -f "Native/TestPlans/$TEST_PLAN.xctestplan" ]]; then
  PLAN_PATH="Native/TestPlans/$TEST_PLAN.xctestplan"
elif [[ -f "Native/TestPlans/$TEST_PLAN" ]]; then
  PLAN_PATH="Native/TestPlans/$TEST_PLAN"
elif [[ -f "$TEST_PLAN" ]]; then
  PLAN_PATH="$TEST_PLAN"
fi

if [[ -z "$PLAN_PATH" ]]; then
  echo "test plan not found: $TEST_PLAN"
  echo "suggestion: run scripts/ambitions-xcode-validate.sh --batch $BATCH --lane focused-test --test AmbitionsTests/SomeFocusedTest" >&2
  exit 24
fi

mkdir -p "$RESULT_DIR/$BATCH" "$LOG_DIR/$BATCH" "$SUMMARY_DIR/$BATCH"
TS="$(date -u +%Y%m%dT%H%M%SZ)"
RESULT_BUNDLE="$RESULT_DIR/$BATCH/$TS/test-plan.xcresult"
LOG_FILE="$LOG_DIR/$BATCH/$TS/test-plan.log"
SUMMARY_FILE="$SUMMARY_DIR/$BATCH/$TS/test-plan-summary.json"
mkdir -p "$RESULT_DIR/$BATCH/$TS" "$LOG_DIR/$BATCH/$TS" "$SUMMARY_DIR/$BATCH/$TS"
DERIVED_DATA="$REPO_ROOT/.codex/DerivedData/Ambitions"
mkdir -p "$DERIVED_DATA"

plan_basename() {
  basename "$TEST_PLAN" .xctestplan
}

XCODE_TEST_PLAN_NAME="$(plan_basename)"

resolve_scheme() {
  if [[ "$SCHEME" != "auto" ]]; then
    printf '%s\n' "$SCHEME"
    return
  fi

  case "$XCODE_TEST_PLAN_NAME" in
    Smoke) printf '%s\n' "AmbitionsSmoke" ;;
    Runtime) printf '%s\n' "AmbitionsRuntime" ;;
    Accessibility) printf '%s\n' "AmbitionsAccessibility" ;;
    Screenshots) printf '%s\n' "AmbitionsScreenshots" ;;
    ReleaseCandidate) printf '%s\n' "AmbitionsReleaseCandidate" ;;
    *) printf '%s\n' "Ambitions" ;;
  esac
}

RESOLVED_SCHEME="$(resolve_scheme)"

json_field() {
  local key="$1"
  local payload="$2"
  python3 - "$key" "$payload" <<'PY'
import json
import sys

key, payload = sys.argv[1], sys.argv[2]
try:
    data = json.loads(payload)
except Exception:
    data = {}
value = data.get(key, "")
if isinstance(value, bool):
    print("true" if value else "false")
else:
    print(value)
PY
}

if command -v scripts/ambitions-xcodegen-needed.sh >/dev/null 2>&1; then
  need_output="$(scripts/ambitions-xcodegen-needed.sh || true)"
  need_required="$(awk -F= '/^XCODEGEN_NEEDED=/{print $2}' <<<"$need_output")"
  if [[ "$need_required" == "1" ]]; then
    if ! command -v xcodegen >/dev/null 2>&1; then
      echo "FAILURE_CLASS=tool_missing"
      exit 24
    fi
    xcodegen generate >/dev/null
  fi
fi

set +e
sim_line="$(scripts/ambitions-xcode-sim-health.sh --json)"
sim_status=$?
set -e
sim_failure="$(json_field failure_category "$sim_line")"
[[ -n "$sim_failure" ]] || sim_failure="simulator_health_unavailable"
sim_udid="$(json_field udid "$sim_line")"
sim_state="$(json_field state "$sim_line")"
if [[ "$sim_status" -ne 0 || -z "$sim_udid" || "$sim_state" != "Booted" ]]; then
  cat > "$SUMMARY_FILE" <<JSON
{
  "batch": "$BATCH",
  "lane": "test-plan",
  "test_plan": "$TEST_PLAN",
  "plan_path": "$PLAN_PATH",
  "status": "failed",
  "failure_category": "$sim_failure",
  "result_bundle": "$RESULT_BUNDLE",
  "log_file": "$LOG_FILE",
  "timestamp_utc": "$TS",
  "sim_destination": "unavailable",
  "claim_boundary": "simulator preflight failure only; no test-plan proof produced"
}
JSON
  echo "FAILURE_CLASS=$sim_failure"
  exit "$([[ "$sim_failure" == "simctl_unresponsive" ]] && echo 25 || echo 22)"
fi

SIM_DEST="platform=iOS Simulator,id=${sim_udid}"

extract_executed_tests() {
  local log_file="$1"
  python3 - "$log_file" <<'PY'
import re
import sys
from pathlib import Path

path = Path(sys.argv[1])
text = path.read_text(encoding="utf-8", errors="replace") if path.exists() else ""
executed = [int(match.group(1)) for match in re.finditer(r"\bExecuted\s+(\d+)\s+tests?\b", text)]
if executed:
    print(executed[-1])
else:
    print(len(re.findall(r"Test Case '.+' (passed|failed) \(", text)))
PY
}

XCODE_TEST_TIMEOUT_ARGS=()
if xcodebuild -help 2>&1 | grep -q -- "-test-timeouts-enabled"; then
  XCODE_TEST_TIMEOUT_ARGS=(
    -test-timeouts-enabled YES
    -default-test-execution-time-allowance "${AMBITIONS_XCODE_DEFAULT_TEST_ALLOWANCE_SECONDS:-240}"
    -maximum-test-execution-time-allowance "${AMBITIONS_XCODE_MAX_TEST_ALLOWANCE_SECONDS:-360}"
  )
fi

run_xcode_plan() {
  local -a plan_cmd
  rm -rf "$RESULT_BUNDLE"
  plan_cmd=(
    xcodebuild
    -skipPackagePluginValidation
    -skipMacroValidation
    -project Ambitions.xcodeproj
    -scheme "$RESOLVED_SCHEME"
    -testPlan "$XCODE_TEST_PLAN_NAME"
    -destination "$SIM_DEST"
    -derivedDataPath "$DERIVED_DATA"
    "${XCODE_TEST_TIMEOUT_ARGS[@]}"
    test-without-building
    CODE_SIGNING_ALLOWED=NO
    CODE_SIGNING_REQUIRED=NO
    COMPILER_INDEX_STORE_ENABLE=NO
    ONLY_ACTIVE_ARCH=YES
    -resultBundlePath "$RESULT_BUNDLE"
  )

  set +e
  if command -v xcbeautify >/dev/null 2>&1; then
    scripts/ambitions-bounded-xcodebuild.sh \
      --timeout "$TIMEOUT_DURATION" \
      --kill-after "$KILL_AFTER" \
      --log "$LOG_FILE" \
      -- "${plan_cmd[@]}" \
      2>&1 | xcbeautify
    status=${PIPESTATUS[0]}
  else
    scripts/ambitions-bounded-xcodebuild.sh \
      --timeout "$TIMEOUT_DURATION" \
      --kill-after "$KILL_AFTER" \
      --log "$LOG_FILE" \
      -- "${plan_cmd[@]}"
    status=$?
  fi
  set -e
}

run_xcode_plan
status=${status:-0}

if [[ "$status" -ne 0 ]]; then
  classification="$(python3 scripts/ambitions-xcode-failure-classifier.py --log "$LOG_FILE" --json | python3 -c 'import sys, json; print(json.load(sys.stdin).get("classification",""))' )"
  if [[ "$classification" == "simulator_boot_failure" || "$classification" == "simulator_launcher_failure" ]]; then
    scripts/ambitions-xcode-sim-health.sh --repair --json >/dev/null 2>&1 || true
    run_xcode_plan
    status=${status:-0}
  fi
fi

if command -v scripts/ambitions-xcode-result-extract.sh >/dev/null 2>&1; then
  scripts/ambitions-xcode-result-extract.sh --result "$RESULT_BUNDLE" --output-dir "$SUMMARY_DIR/$BATCH/$TS/extract" || true
fi

classification="$(python3 scripts/ambitions-xcode-failure-classifier.py --log "$LOG_FILE" --json | python3 -c 'import sys, json; print(json.load(sys.stdin).get("classification", ""))')"
[[ -z "$classification" ]] && classification="unknown"
executed_tests="$(extract_executed_tests "$LOG_FILE")"
if [[ "$status" -eq 0 ]]; then
  if [[ "$executed_tests" =~ ^[0-9]+$ && "$executed_tests" -gt 0 ]]; then
    classification="passed"
  else
    status=65
    classification="test_discovery_failure"
  fi
elif [[ "$status" -eq 124 && "$classification" == "unknown" ]]; then
  classification="test_timeout"
fi
if [[ "$status" -ne 0 && -e "$RESULT_BUNDLE" && ! -f "$RESULT_BUNDLE/Info.plist" && "$classification" == "unknown" ]]; then
  classification="corrupt_xcresult"
fi

cat > "$SUMMARY_FILE" <<JSON
{
  "batch": "$BATCH",
  "lane": "test-plan",
  "test_plan": "$TEST_PLAN",
  "xcode_test_plan_name": "$XCODE_TEST_PLAN_NAME",
  "plan_path": "$PLAN_PATH",
  "scheme": "$RESOLVED_SCHEME",
  "xcodebuild_action": "test-without-building",
  "status": "$([ "$status" -eq 0 ] && echo passed || echo failed)",
  "failure_category": "$classification",
  "executed_tests": $executed_tests,
  "timeout": "$TIMEOUT_DURATION",
  "kill_after": "$KILL_AFTER",
  "result_bundle": "$RESULT_BUNDLE",
  "log_file": "$LOG_FILE",
  "timestamp_utc": "$TS",
  "sim_destination": "$SIM_DEST",
  "claim_boundary": "test-plan execution proof only; prerequisite build-for-testing proof is recorded separately and this is not visual, accessibility, device, TestFlight, App Store, or release proof"
}
JSON

echo "FAILURE_CLASS=$classification"
echo "EXECUTED_TESTS=$executed_tests"
echo "SCHEME=$RESOLVED_SCHEME"
exit "$status"
