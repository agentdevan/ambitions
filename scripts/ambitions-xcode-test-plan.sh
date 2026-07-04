#!/usr/bin/env bash
set -Eeuo pipefail

REPO_ROOT="$(git rev-parse --show-toplevel 2>/dev/null || pwd -P)"
cd "$REPO_ROOT"

BATCH=""
TEST_PLAN=""
SCHEME="Ambitions"
RESULT_DIR=".codex/xcode-results"
LOG_DIR=".codex/xcode-logs"
SUMMARY_DIR=".codex/xcode-summaries"

while [[ "$#" -gt 0 ]]; do
  case "$1" in
    --batch) BATCH="${2:-}"; shift 2 ;;
    --test-plan) TEST_PLAN="${2:-}"; shift 2 ;;
    --scheme) SCHEME="${2:-$SCHEME}"; shift 2 ;;
    --results-dir) RESULT_DIR="${2:-$RESULT_DIR}"; shift 2 ;;
    --logs-dir) LOG_DIR="${2:-$LOG_DIR}"; shift 2 ;;
    --summaries-dir) SUMMARY_DIR="${2:-$SUMMARY_DIR}"; shift 2 ;;
    -h|--help)
      echo "Usage: scripts/ambitions-xcode-test-plan.sh --batch <BATCH> --test-plan <PLAN_NAME>" >&2
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

run_xcode_plan() {
  set +e
  if command -v xcbeautify >/dev/null 2>&1; then
    xcodebuild -project Ambitions.xcodeproj \
      -scheme "$SCHEME" \
      -testPlan "$TEST_PLAN" \
      -destination "$SIM_DEST" \
      -derivedDataPath "$DERIVED_DATA" \
      test-without-building \
      CODE_SIGNING_ALLOWED=NO CODE_SIGNING_REQUIRED=NO \
      -resultBundlePath "$RESULT_BUNDLE" \
      2>&1 | tee "$LOG_FILE" | xcbeautify
    status=${PIPESTATUS[0]}
  else
    xcodebuild -project Ambitions.xcodeproj \
      -scheme "$SCHEME" \
      -testPlan "$TEST_PLAN" \
      -destination "$SIM_DEST" \
      -derivedDataPath "$DERIVED_DATA" \
      test-without-building \
      CODE_SIGNING_ALLOWED=NO CODE_SIGNING_REQUIRED=NO \
      -resultBundlePath "$RESULT_BUNDLE" \
      2>&1 | tee "$LOG_FILE"
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

cat > "$SUMMARY_FILE" <<JSON
{
  "batch": "$BATCH",
  "lane": "test-plan",
  "test_plan": "$TEST_PLAN",
  "plan_path": "$PLAN_PATH",
  "status": "$([ "$status" -eq 0 ] && echo passed || echo failed)",
  "failure_category": "$classification",
  "result_bundle": "$RESULT_BUNDLE",
  "log_file": "$LOG_FILE",
  "timestamp_utc": "$TS",
  "sim_destination": "$SIM_DEST"
}
JSON

echo "FAILURE_CLASS=$classification"
exit "$status"
