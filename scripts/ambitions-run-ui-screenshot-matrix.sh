#!/usr/bin/env bash
set -Eeuo pipefail

REPO_ROOT="$(git rev-parse --show-toplevel 2>/dev/null || pwd -P)"
cd "$REPO_ROOT"

BATCH="DESIGN_TRUTH_TRAIN_05_6"
SCHEME="AmbitionsUITests"
DESTINATION="${AMBITIONS_XCODE_UI_DESTINATION:-}"
TIMEOUT_DURATION="20m"
KILL_AFTER="60s"
PREBUILD_TIMEOUT_DURATION="${AMBITIONS_XCODE_UI_PREBUILD_TIMEOUT:-35m}"
RESULT_DIR=".codex/xcode-results"
LOG_DIR=".codex/xcode-logs"
SUMMARY_DIR=".codex/xcode-summaries"
MAX_RETRIES=1
SKIP_PREBUILD=0
DERIVED_DATA="$REPO_ROOT/.codex/DerivedData/Ambitions"

usage() {
  cat >&2 <<'EOF'
Usage: scripts/ambitions-run-ui-screenshot-matrix.sh [options]

Runs the AMB-962 Today screenshot matrix through scripts/ambitions-bounded-xcodebuild.sh.

Options:
  --batch <name>          Batch directory under .codex outputs. Default: DESIGN_TRUTH_TRAIN_05_6.
  --scheme <name>         Xcode scheme. Default: AmbitionsUITests.
  --destination <spec>    Xcode destination. Default: health-selected simulator UDID.
  --timeout <duration>    Wall-clock timeout. Default: 20m.
  --kill-after <duration> Timeout kill-after grace. Default: 60s.
  --prebuild-timeout <d>  Build-for-testing timeout. Default: 35m.
  --skip-prebuild         Run xcodebuild test directly instead of test-without-building.
  --results-dir <path>    Result root. Default: .codex/xcode-results.
  --logs-dir <path>       Log root. Default: .codex/xcode-logs.
  --summaries-dir <path>  Summary root. Default: .codex/xcode-summaries.
  -h, --help              Show this help.
EOF
}

while [[ "$#" -gt 0 ]]; do
  case "$1" in
    --batch) BATCH="${2:-}"; shift 2 ;;
    --scheme) SCHEME="${2:-}"; shift 2 ;;
    --destination) DESTINATION="${2:-}"; shift 2 ;;
    --timeout) TIMEOUT_DURATION="${2:-}"; shift 2 ;;
    --kill-after) KILL_AFTER="${2:-}"; shift 2 ;;
    --prebuild-timeout) PREBUILD_TIMEOUT_DURATION="${2:-}"; shift 2 ;;
    --skip-prebuild) SKIP_PREBUILD=1; shift ;;
    --results-dir) RESULT_DIR="${2:-}"; shift 2 ;;
    --logs-dir) LOG_DIR="${2:-}"; shift 2 ;;
    --summaries-dir) SUMMARY_DIR="${2:-}"; shift 2 ;;
    -h|--help)
      usage
      exit 0
      ;;
    *)
      echo "unsupported arg: $1" >&2
      exit 2
      ;;
  esac
done

[[ -n "$BATCH" ]] || { echo "--batch must not be empty" >&2; exit 2; }
[[ -n "$SCHEME" ]] || { echo "--scheme must not be empty" >&2; exit 2; }
[[ -n "$TIMEOUT_DURATION" ]] || { echo "--timeout must not be empty" >&2; exit 2; }
[[ -n "$KILL_AFTER" ]] || { echo "--kill-after must not be empty" >&2; exit 2; }
[[ -n "$PREBUILD_TIMEOUT_DURATION" ]] || { echo "--prebuild-timeout must not be empty" >&2; exit 2; }

TEST_ID="AmbitionsUITests/AmbitionsUITests/testAMB962TodayReconstructionScreenshotMatrix"
TS="$(date -u +%Y%m%dT%H%M%SZ)"
mkdir -p "$RESULT_DIR/$BATCH" "$LOG_DIR/$BATCH" "$SUMMARY_DIR/$BATCH"
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

classify_failure() {
  local status="$1"
  local log_file="$2"
  local result_bundle="$3"
  local detected="unknown"

  if [[ "$status" -eq 0 ]]; then
    echo "passed"
    return
  fi

  if [[ -f "$log_file" ]]; then
    detected="$(python3 scripts/ambitions-xcode-failure-classifier.py --log "$log_file" --json | python3 -c 'import sys, json; print(json.load(sys.stdin).get("classification","unknown"))' )"
    if [[ -n "$detected" && "$detected" != "unknown" ]]; then
      echo "$detected"
      return
    fi
  fi

  if [[ -e "$result_bundle" && ! -f "$result_bundle/Info.plist" ]]; then
    echo "corrupt_xcresult"
    return
  fi

  if [[ "$status" -eq 124 ]]; then
    echo "test_timeout"
  else
    echo "unknown"
  fi
}

set +e
sim_health_json="$(scripts/ambitions-xcode-sim-health.sh --json)"
sim_health_status=$?
set -e
sim_failure="$(json_field failure_category "$sim_health_json")"
[[ -n "$sim_failure" ]] || sim_failure="simulator_health_unavailable"
sim_udid="$(json_field udid "$sim_health_json")"
sim_state="$(json_field state "$sim_health_json")"
if [[ "$sim_health_status" -ne 0 || -z "$sim_udid" || "$sim_state" != "Booted" ]]; then
  health_summary="$SUMMARY_DIR/$BATCH/${TS}-AMB962-health/summary.json"
  mkdir -p "$(dirname "$health_summary")"
  cat > "$health_summary" <<JSON
{
  "batch": "$BATCH",
  "status": "failed",
  "failure_category": "$sim_failure",
  "test_id": "$TEST_ID",
  "xcodebuild_action": "not_run",
  "claim_boundary": "simulator preflight failure only; no AMB-962 screenshot proof produced"
}
JSON
  echo "FAILURE_CLASS=$sim_failure"
  echo "AMB962_STATUS=failed_or_timed_out"
  echo "AMB962_HEALTH_SUMMARY=$health_summary"
  exit "$([[ "$sim_failure" == "simctl_unresponsive" ]] && echo 25 || echo 22)"
fi

if [[ -z "$DESTINATION" ]]; then
  DESTINATION="platform=iOS Simulator,id=${sim_udid}"
fi

XCODE_TEST_TIMEOUT_ARGS=()
if xcodebuild -help 2>&1 | grep -q -- "-test-timeouts-enabled"; then
  XCODE_TEST_TIMEOUT_ARGS=(
    -test-timeouts-enabled YES
    -default-test-execution-time-allowance 240
    -maximum-test-execution-time-allowance 300
  )
fi

run_prebuild() {
  local run_id="${TS}-AMB962-build-for-testing"
  local result_bundle="$RESULT_DIR/$BATCH/${run_id}.xcresult"
  local log_file="$LOG_DIR/$BATCH/${run_id}.log"
  local extract_dir="$SUMMARY_DIR/$BATCH/${run_id}/extract"
  local summary_file="$SUMMARY_DIR/$BATCH/${run_id}/summary.json"

  rm -rf "$result_bundle"
  mkdir -p "$(dirname "$result_bundle")" "$(dirname "$log_file")" "$extract_dir" "$(dirname "$summary_file")"

  echo "AMB962_PREBUILD_REQUIRED=1"
  echo "AMB962_PREBUILD_RESULT_BUNDLE=$result_bundle"
  echo "AMB962_PREBUILD_EXTRACT_DIR=$extract_dir"

  set +e
  scripts/ambitions-bounded-xcodebuild.sh \
    --timeout "$PREBUILD_TIMEOUT_DURATION" \
    --kill-after "$KILL_AFTER" \
    --log "$log_file" \
    -- \
    -skipPackagePluginValidation \
    -skipMacroValidation \
    -project Ambitions.xcodeproj \
    -scheme "$SCHEME" \
    -sdk iphonesimulator \
    -destination "$DESTINATION" \
    -derivedDataPath "$DERIVED_DATA" \
    build-for-testing \
    CODE_SIGNING_ALLOWED=NO \
    CODE_SIGNING_REQUIRED=NO \
    COMPILER_INDEX_STORE_ENABLE=NO \
    ONLY_ACTIVE_ARCH=YES \
    -resultBundlePath "$result_bundle"
  local status=$?
  set -e

  if [[ -e "$result_bundle" ]]; then
    scripts/ambitions-xcode-result-extract.sh --result "$result_bundle" --output-dir "$extract_dir" || true
  fi

  local failure_category
  local status_label
  failure_category="$(classify_failure "$status" "$log_file" "$result_bundle")"
  if [[ "$status" -eq 0 ]]; then
    status_label="passed"
  else
    status_label="failed"
  fi

  cat > "$summary_file" <<JSON
{
  "batch": "$BATCH",
  "destination": "$DESTINATION",
  "extract_dir": "$extract_dir",
  "log_file": "$log_file",
  "result_bundle": "$result_bundle",
  "scheme": "$SCHEME",
  "status": "$status_label",
  "status_code": $status,
  "failure_category": "$failure_category",
  "timeout": "$PREBUILD_TIMEOUT_DURATION",
  "test_id": "$TEST_ID",
  "xcodebuild_action": "build-for-testing"
}
JSON

  return "$status"
}

run_attempt() {
  local attempt="$1"
  local suffix=""
  if [[ "$attempt" -gt 0 ]]; then
    suffix="-retry${attempt}"
  fi

  local run_id="${TS}-AMB962${suffix}"
  local result_bundle="$RESULT_DIR/$BATCH/${run_id}.xcresult"
  local log_file="$LOG_DIR/$BATCH/${run_id}.log"
  local extract_dir="$SUMMARY_DIR/$BATCH/${run_id}/extract"
  local xcodebuild_action="test-without-building"
  if [[ "$SKIP_PREBUILD" -eq 1 ]]; then
    xcodebuild_action="test"
  fi

  rm -rf "$result_bundle"
  mkdir -p "$(dirname "$result_bundle")" "$(dirname "$log_file")" "$extract_dir"

  echo "AMB962_ATTEMPT=$attempt"
  echo "AMB962_RESULT_BUNDLE=$result_bundle"
  echo "AMB962_EXTRACT_DIR=$extract_dir"

  set +e
  scripts/ambitions-bounded-xcodebuild.sh \
    --timeout "$TIMEOUT_DURATION" \
    --kill-after "$KILL_AFTER" \
    --log "$log_file" \
    -- \
    -skipPackagePluginValidation \
    -skipMacroValidation \
    -project Ambitions.xcodeproj \
    -scheme "$SCHEME" \
    -sdk iphonesimulator \
    -destination "$DESTINATION" \
    -derivedDataPath "$DERIVED_DATA" \
    "${XCODE_TEST_TIMEOUT_ARGS[@]}" \
    -parallel-testing-enabled NO \
    "$xcodebuild_action" \
    -only-testing:"$TEST_ID" \
    CODE_SIGNING_ALLOWED=NO \
    CODE_SIGNING_REQUIRED=NO \
    COMPILER_INDEX_STORE_ENABLE=NO \
    ONLY_ACTIVE_ARCH=YES \
    -resultBundlePath "$result_bundle"
  local status=$?
  set -e

  if [[ -e "$result_bundle" ]]; then
    scripts/ambitions-xcode-result-extract.sh --result "$result_bundle" --output-dir "$extract_dir" || true
  fi

  local summary_file="$SUMMARY_DIR/$BATCH/${run_id}/summary.json"
  local failure_category
  local status_label
  failure_category="$(classify_failure "$status" "$log_file" "$result_bundle")"
  if [[ "$status" -eq 0 ]]; then
    status_label="passed"
  else
    status_label="failed"
  fi
  mkdir -p "$(dirname "$summary_file")"
  cat > "$summary_file" <<JSON
{
  "attempt": $attempt,
  "batch": "$BATCH",
  "destination": "$DESTINATION",
  "extract_dir": "$extract_dir",
  "log_file": "$log_file",
  "result_bundle": "$result_bundle",
  "status": "$status_label",
  "status_code": $status,
  "failure_category": "$failure_category",
  "test_id": "$TEST_ID",
  "timeout": "$TIMEOUT_DURATION",
  "kill_after": "$KILL_AFTER",
  "prebuild_required": $([[ "$SKIP_PREBUILD" -eq 1 ]] && echo false || echo true),
  "xcodebuild_action": "$xcodebuild_action",
  "xcode_test_timeout_flags": "$([[ "${#XCODE_TEST_TIMEOUT_ARGS[@]}" -gt 0 ]] && echo enabled || echo unavailable)"
}
JSON

  return "$status"
}

attempt=0
if [[ "$SKIP_PREBUILD" -ne 1 ]]; then
  set +e
  run_prebuild
  prebuild_status=$?
  set -e

  if [[ "$prebuild_status" -ne 0 ]]; then
    echo "AMB962_STATUS=failed_or_timed_out"
    echo "AMB962_PREBUILD_STATUS_CODE=$prebuild_status"
    exit "$prebuild_status"
  fi
fi

set +e
run_attempt "$attempt"
status=$?
set -e

if [[ "$status" -eq 124 && "$MAX_RETRIES" -gt 0 ]]; then
  echo "AMB962_INFRASTRUCTURE_TIMEOUT=1"
  echo "AMB962_RETRY_POLICY=shutdown_all_then_retry_once"
  xcrun simctl shutdown all || true
  attempt=1
  set +e
  run_attempt "$attempt"
  status=$?
  set -e
fi

if [[ "$status" -eq 0 ]]; then
  echo "AMB962_STATUS=passed"
else
  echo "AMB962_STATUS=failed_or_timed_out"
  echo "AMB962_FINAL_STATUS_CODE=$status"
fi

exit "$status"
