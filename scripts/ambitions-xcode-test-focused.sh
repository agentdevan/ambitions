#!/usr/bin/env bash
set -Eeuo pipefail

REPO_ROOT="$(git rev-parse --show-toplevel 2>/dev/null || pwd -P)"
cd "$REPO_ROOT"

BATCH=""
TEST_ID=""
ONLY_TESTING=""
SCHEME="auto"
RESULT_DIR=".codex/xcode-results"
LOG_DIR=".codex/xcode-logs"
SUMMARY_DIR=".codex/xcode-summaries"
TIMEOUT_DURATION="${AMBITIONS_XCODE_FOCUSED_TEST_TIMEOUT:-15m}"
KILL_AFTER="60s"
XCODEBUILD_ACTION="test"
UI_PREBUILD_MODE="${AMBITIONS_XCODE_UI_PREBUILD:-auto}"
UI_PREBUILD_TIMEOUT_DURATION="${AMBITIONS_XCODE_UI_PREBUILD_TIMEOUT:-${AMBITIONS_XCODE_BUILD_FOR_TESTING_TIMEOUT:-45m}}"
UI_PREBUILD_KILL_AFTER="${AMBITIONS_XCODE_UI_PREBUILD_KILL_AFTER:-$KILL_AFTER}"
SIM_HEALTH_TIMEOUT="${AMBITIONS_XCODE_SIM_HEALTH_TIMEOUT:-${AMBITIONS_SIM_HEALTH_TIMEOUT:-30s}}"
TEST_LAUNCH_TIMEOUT="${AMBITIONS_XCODE_TEST_LAUNCH_TIMEOUT:-30s}"

while [[ "$#" -gt 0 ]]; do
  case "$1" in
    --batch) BATCH="${2:-}"; shift 2 ;;
    --test) TEST_ID="${2:-}"; shift 2 ;;
    --only-testing) ONLY_TESTING="${2:-}"; shift 2 ;;
    --scheme) SCHEME="${2:-$SCHEME}"; shift 2 ;;
    --results-dir) RESULT_DIR="${2:-$RESULT_DIR}"; shift 2 ;;
    --logs-dir) LOG_DIR="${2:-$LOG_DIR}"; shift 2 ;;
    --summaries-dir) SUMMARY_DIR="${2:-$SUMMARY_DIR}"; shift 2 ;;
    --timeout) TIMEOUT_DURATION="${2:-$TIMEOUT_DURATION}"; shift 2 ;;
    --kill-after) KILL_AFTER="${2:-$KILL_AFTER}"; shift 2 ;;
    --test-launch-timeout) TEST_LAUNCH_TIMEOUT="${2:-$TEST_LAUNCH_TIMEOUT}"; shift 2 ;;
    --without-building|--test-without-building) XCODEBUILD_ACTION="test-without-building"; shift ;;
    --prebuild) UI_PREBUILD_MODE="always"; shift ;;
    --skip-prebuild) UI_PREBUILD_MODE="never"; shift ;;
    --prebuild-timeout) UI_PREBUILD_TIMEOUT_DURATION="${2:-$UI_PREBUILD_TIMEOUT_DURATION}"; shift 2 ;;
    --prebuild-kill-after) UI_PREBUILD_KILL_AFTER="${2:-$UI_PREBUILD_KILL_AFTER}"; shift 2 ;;
    -h|--help)
      echo "Usage: scripts/ambitions-xcode-test-focused.sh --batch <BATCH> --test <TEST_ID> [--scheme auto|Ambitions|AmbitionsUnitTests|AmbitionsUITests] [--timeout 15m] [--kill-after 60s] [--test-launch-timeout 30s] [--without-building] [--prebuild|--skip-prebuild] [--prebuild-timeout 35m]" >&2
      exit 0
      ;;
    *)
      echo "unsupported arg: $1" >&2
      exit 1
      ;;
  esac
done

[[ -n "$BATCH" ]] || { echo "--batch is required" >&2; exit 1; }
if [[ -z "$TEST_ID" && -z "$ONLY_TESTING" ]]; then
  echo "one of --test or --only-testing is required" >&2
  exit 1
fi

mkdir -p "$RESULT_DIR/$BATCH" "$LOG_DIR/$BATCH" "$SUMMARY_DIR/$BATCH"
TS="$(date -u +%Y%m%dT%H%M%SZ)"
test_filter="${ONLY_TESTING:-$TEST_ID}"
test_slug="$(printf '%s' "$test_filter" | tr -c 'A-Za-z0-9._-' '-' | cut -c1-80)"
[[ -n "$test_slug" ]] || test_slug="focused"
RUN_ID="$TS-$test_slug-$$-${RANDOM:-0}"
RESULT_BUNDLE="$RESULT_DIR/$BATCH/$RUN_ID/focused-test.xcresult"
LOG_FILE="$LOG_DIR/$BATCH/$RUN_ID/focused-test.log"
SUMMARY_FILE="$SUMMARY_DIR/$BATCH/$RUN_ID/focused-test-summary.json"
mkdir -p "$RESULT_DIR/$BATCH/$RUN_ID" "$LOG_DIR/$BATCH/$RUN_ID" "$SUMMARY_DIR/$BATCH/$RUN_ID"
DERIVED_DATA="$REPO_ROOT/.codex/DerivedData/Ambitions"
mkdir -p "$DERIVED_DATA"

run_with_optional_timeout() {
  local duration="$1"
  shift

  if command -v gtimeout >/dev/null 2>&1; then
    gtimeout "$duration" "$@"
  elif command -v timeout >/dev/null 2>&1; then
    timeout "$duration" "$@"
  else
    "$@"
  fi
}

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

resolve_scheme() {
  if [[ "$SCHEME" != "auto" ]]; then
    printf '%s\n' "$SCHEME"
    return
  fi

  case "$test_filter" in
    AmbitionsTests|AmbitionsTests/*)
      printf '%s\n' "${AMBITIONS_XCODE_UNIT_TEST_SCHEME:-AmbitionsUnitTests}"
      ;;
    AmbitionsUITests|AmbitionsUITests/*)
      printf '%s\n' "${AMBITIONS_XCODE_UI_TEST_SCHEME:-AmbitionsUITests}"
      ;;
    *)
      printf '%s\n' "${AMBITIONS_XCODE_FULL_TEST_SCHEME:-Ambitions}"
      ;;
  esac
}

RESOLVED_SCHEME="$(resolve_scheme)"
PROOF_SCOPE="focused"
case "$RESOLVED_SCHEME" in
  AmbitionsUnitTests) PROOF_SCOPE="unit-focused-fast" ;;
  AmbitionsUITests) PROOF_SCOPE="ui-focused-fast" ;;
  Ambitions) PROOF_SCOPE="full-scheme-focused" ;;
esac
REQUESTED_XCODEBUILD_ACTION="$XCODEBUILD_ACTION"
UI_PREBUILD_REQUIRED=false
UI_PREBUILD_STATUS=0
UI_PREBUILD_FAILURE_CLASS="not_run"
UI_PREBUILD_OUTPUT_FILE=""
UI_PREBUILD_SUMMARY_FILE=""

if [[ "$RESOLVED_SCHEME" == "AmbitionsUITests" && "$REQUESTED_XCODEBUILD_ACTION" == "test" ]]; then
  case "$UI_PREBUILD_MODE" in
    0|false|FALSE|no|NO|never|NEVER)
      UI_PREBUILD_REQUIRED=false
      ;;
    *)
      UI_PREBUILD_REQUIRED=true
      ;;
  esac
fi

need_output="$(scripts/ambitions-xcodegen-needed.sh || true)"
need_flag="$(awk -F= '/^XCODEGEN_NEEDED=/{print $2}' <<<"$need_output")"
if [[ "$need_flag" == "1" ]]; then
  if ! command -v xcodegen >/dev/null 2>&1; then
    cat > "$SUMMARY_FILE" <<JSON
{
  "batch": "$BATCH",
  "lane": "focused-test",
  "test": "$test_filter",
  "scheme": "$RESOLVED_SCHEME",
  "xcodebuild_action": "$XCODEBUILD_ACTION",
  "status": "failed",
  "failure_category": "tool_missing",
  "executed_tests": 0,
  "result_bundle": "$RESULT_BUNDLE",
  "log_file": "$LOG_FILE",
  "timestamp_utc": "$TS",
  "run_id": "$RUN_ID"
}
JSON
    echo "FAILURE_CLASS=tool_missing"
    echo "EXECUTED_TESTS=0"
    exit 24
  fi
  xcodegen generate >/dev/null
fi

write_sim_health_failure_summary() {
  local failure_class="$1"
  local health_payload="$2"
  local exit_code="${3:-22}"
  local selected_udid selected_name selected_state selection_source exact_name_match_count booted_count app_pid_count xcode_process_count

  selected_udid="$(json_field udid "$health_payload")"
  selected_name="$(json_field sim_name "$health_payload")"
  selected_state="$(json_field state "$health_payload")"
  selection_source="$(json_field selection_source "$health_payload")"
  exact_name_match_count="$(json_field exact_name_match_count "$health_payload")"
  booted_count="$(json_field booted_simulator_count "$health_payload")"
  app_pid_count="$(json_field ambitions_app_pid_count "$health_payload")"
  xcode_process_count="$(json_field xcode_process_count "$health_payload")"
  [[ -n "$booted_count" ]] || booted_count=0
  [[ -n "$app_pid_count" ]] || app_pid_count=0
  [[ -n "$xcode_process_count" ]] || xcode_process_count=0
  [[ -n "$exact_name_match_count" ]] || exact_name_match_count=0

  cat > "$SUMMARY_FILE" <<JSON
{
  "batch": "$BATCH",
  "lane": "focused-test",
  "test": "$test_filter",
  "scheme": "$RESOLVED_SCHEME",
  "proof_scope": "$PROOF_SCOPE",
  "requested_xcodebuild_action": "$REQUESTED_XCODEBUILD_ACTION",
  "xcodebuild_action": "not_run",
  "status": "failed",
  "failure_category": "$failure_class",
  "executed_tests": 0,
  "duration_seconds": 0,
  "xcode_observer_seconds": null,
  "xctest_wall_seconds": null,
  "result_bundle": "$RESULT_BUNDLE",
  "log_file": "$LOG_FILE",
  "timestamp_utc": "$TS",
  "run_id": "$RUN_ID",
  "selected_sim_name": "$selected_name",
  "selected_sim_udid": "$selected_udid",
  "selected_sim_state": "$selected_state",
  "simulator_selection_source": "$selection_source",
  "simulator_exact_name_match_count": $exact_name_match_count,
  "booted_simulator_count": $booted_count,
  "ambitions_app_pid_count": $app_pid_count,
  "xcode_process_count": $xcode_process_count,
  "ui_prebuild_required": $UI_PREBUILD_REQUIRED,
  "ui_prebuild_status": "not_run",
  "ui_prebuild_failure_category": "$UI_PREBUILD_FAILURE_CLASS",
  "claim_boundary": "simulator preflight failure only; no focused test proof produced"
}
JSON
  echo "FAILURE_CLASS=$failure_class"
  echo "EXECUTED_TESTS=0"
  echo "DURATION_SECONDS=0"
  echo "SCHEME=$RESOLVED_SCHEME"
  echo "SIM_HEALTH_STATUS=failed"
  echo "SIM_HEALTH_SUMMARY=$SUMMARY_FILE"
  exit "$exit_code"
}

sim_health_retryable() {
  case "$1" in
    simctl_unresponsive|simctl_unavailable|simulator_not_booted|xcode_process_active) return 0 ;;
    *) return 1 ;;
  esac
}

sim_json=""
set +e
sim_json="$(scripts/ambitions-xcode-sim-health.sh --json --timeout "$SIM_HEALTH_TIMEOUT")"
sim_status=$?
set -e
sim_failure="$(json_field failure_category "$sim_json")"
[[ -n "$sim_failure" ]] || sim_failure="simulator_health_unavailable"
if [[ "$sim_status" -ne 0 ]] && sim_health_retryable "$sim_failure"; then
  set +e
  sim_json="$(scripts/ambitions-xcode-sim-health.sh --json --repair --timeout "$SIM_HEALTH_TIMEOUT")"
  sim_status=$?
  set -e
  sim_failure="$(json_field failure_category "$sim_json")"
  [[ -n "$sim_failure" ]] || sim_failure="simulator_health_unavailable"
fi
if [[ "$sim_status" -ne 0 ]]; then
  write_sim_health_failure_summary "$sim_failure" "$sim_json" "$sim_status"
fi

sim_udid="$(json_field udid "$sim_json")"
sim_name="$(json_field sim_name "$sim_json")"
sim_state="$(json_field state "$sim_json")"
sim_selection_source="$(json_field selection_source "$sim_json")"
sim_exact_name_match_count="$(json_field exact_name_match_count "$sim_json")"
[[ -n "$sim_exact_name_match_count" ]] || sim_exact_name_match_count=0
if [[ -z "$sim_udid" || "$sim_state" != "Booted" ]]; then
  write_sim_health_failure_summary "simulator_not_booted" "$sim_json" 22
fi

SIM_DEST="platform=iOS Simulator,id=${sim_udid}"
sim="$sim_udid"

extract_executed_tests() {
  local log_file="$1"
  python3 - "$log_file" <<'PY'
import re
import sys
from pathlib import Path

text = Path(sys.argv[1]).read_text(encoding="utf-8", errors="replace") if Path(sys.argv[1]).exists() else ""
executed = [int(match.group(1)) for match in re.finditer(r"\bExecuted\s+(\d+)\s+tests?\b", text)]
if executed:
    print(executed[-1])
else:
    print(len(re.findall(r"Test Case '.+' (passed|failed) \(", text)))
PY
}

extract_xcode_observer_seconds() {
  local log_file="$1"
  python3 - "$log_file" <<'PY'
import re
import sys
from pathlib import Path

path = Path(sys.argv[1])
text = path.read_text(encoding="utf-8", errors="replace") if path.exists() else ""
matches = re.findall(r"IDETestOperationsObserverDebug:\s+([0-9.]+) elapsed", text)
print(matches[-1] if matches else "null")
PY
}

extract_xctest_wall_seconds() {
  local log_file="$1"
  python3 - "$log_file" <<'PY'
import re
import sys
from pathlib import Path

path = Path(sys.argv[1])
text = path.read_text(encoding="utf-8", errors="replace") if path.exists() else ""
matches = re.findall(r"\bExecuted\s+\d+\s+tests?.* in [0-9.]+ \(([0-9.]+)\) seconds", text)
print(matches[-1] if matches else "null")
PY
}

run_once() {
  set +e
  if command -v xcbeautify >/dev/null 2>&1; then
    "${BOUNDED_TEST_CMD[@]}" 2>&1 | xcbeautify
    status=${PIPESTATUS[0]}
  else
    "${BOUNDED_TEST_CMD[@]}"
    status=$?
  fi
  set -e
}

run_start="$(python3 - <<'PY'
import time
print(time.time())
PY
)"

if [[ "$UI_PREBUILD_REQUIRED" == "true" ]]; then
  UI_PREBUILD_OUTPUT_FILE="$SUMMARY_DIR/$BATCH/$RUN_ID/ui-prebuild-output.log"
  ui_prebuild_marker="$SUMMARY_DIR/$BATCH/$RUN_ID/ui-prebuild-start.marker"
  : > "$ui_prebuild_marker"

  echo "UI_PREBUILD_REQUIRED=1"
  echo "UI_PREBUILD_TIMEOUT=$UI_PREBUILD_TIMEOUT_DURATION"
  set +e
  scripts/ambitions-xcode-build-for-testing.sh \
    --batch "$BATCH" \
    --scheme "$RESOLVED_SCHEME" \
    --results-dir "$RESULT_DIR" \
    --logs-dir "$LOG_DIR" \
    --summaries-dir "$SUMMARY_DIR" \
    --timeout "$UI_PREBUILD_TIMEOUT_DURATION" \
    --kill-after "$UI_PREBUILD_KILL_AFTER" \
    2>&1 | tee "$UI_PREBUILD_OUTPUT_FILE"
  UI_PREBUILD_STATUS=${PIPESTATUS[0]}
  set -e

  UI_PREBUILD_FAILURE_CLASS="$(awk -F= '/^FAILURE_CLASS=/{value=$2} END{print value}' "$UI_PREBUILD_OUTPUT_FILE")"
  [[ -n "$UI_PREBUILD_FAILURE_CLASS" ]] || UI_PREBUILD_FAILURE_CLASS="unknown"
  UI_PREBUILD_SUMMARY_FILE="$(find "$SUMMARY_DIR/$BATCH" -type f -name build-for-testing-summary.json -newer "$ui_prebuild_marker" -print 2>/dev/null | sort | tail -1)"

  if [[ "$UI_PREBUILD_STATUS" -ne 0 ]]; then
    duration_seconds="$(python3 - "$run_start" <<'PY'
import sys
import time
print(round(time.time() - float(sys.argv[1]), 3))
PY
)"
    cat > "$SUMMARY_FILE" <<JSON
{
  "batch": "$BATCH",
  "lane": "focused-test",
  "test": "$test_filter",
  "scheme": "$RESOLVED_SCHEME",
  "proof_scope": "$PROOF_SCOPE",
  "requested_xcodebuild_action": "$REQUESTED_XCODEBUILD_ACTION",
  "xcodebuild_action": "not_run",
  "status": "failed",
  "failure_category": "ui_prebuild_$UI_PREBUILD_FAILURE_CLASS",
  "executed_tests": 0,
  "duration_seconds": $duration_seconds,
  "xcode_observer_seconds": null,
  "xctest_wall_seconds": null,
  "result_bundle": "$RESULT_BUNDLE",
  "log_file": "$LOG_FILE",
  "timestamp_utc": "$TS",
  "run_id": "$RUN_ID",
  "sim_destination": "$SIM_DEST",
  "selected_sim_name": "$sim_name",
  "selected_sim_udid": "$sim_udid",
  "selected_sim_state": "$sim_state",
  "simulator_selection_source": "$sim_selection_source",
  "simulator_exact_name_match_count": $sim_exact_name_match_count,
  "ui_prebuild_required": true,
  "ui_prebuild_status": "failed",
  "ui_prebuild_failure_category": "$UI_PREBUILD_FAILURE_CLASS",
  "ui_prebuild_timeout": "$UI_PREBUILD_TIMEOUT_DURATION",
  "ui_prebuild_log_file": "$UI_PREBUILD_OUTPUT_FILE",
  "ui_prebuild_summary_file": "$UI_PREBUILD_SUMMARY_FILE",
  "claim_boundary": "focused test execution proof only; UI build-for-testing prebuild is prerequisite proof, not UI, visual, accessibility, device, TestFlight, App Store, or release proof"
}
JSON
    echo "FAILURE_CLASS=ui_prebuild_$UI_PREBUILD_FAILURE_CLASS"
    echo "EXECUTED_TESTS=0"
    echo "DURATION_SECONDS=$duration_seconds"
    echo "SCHEME=$RESOLVED_SCHEME"
    exit "$UI_PREBUILD_STATUS"
  fi

  XCODEBUILD_ACTION="test-without-building"
fi

TEST_CMD=(
  xcodebuild
  -skipPackagePluginValidation
  -skipMacroValidation
  -disableAutomaticPackageResolution
  -onlyUsePackageVersionsFromResolvedFile
  -project Ambitions.xcodeproj
  -scheme "$RESOLVED_SCHEME"
  -sdk iphonesimulator
  -destination "$SIM_DEST"
  -derivedDataPath "$DERIVED_DATA"
  -parallel-testing-enabled NO
  "$XCODEBUILD_ACTION"
  "-only-testing:$test_filter"
  CODE_SIGNING_ALLOWED=NO
  CODE_SIGNING_REQUIRED=NO
  COMPILER_INDEX_STORE_ENABLE=NO
  ONLY_ACTIVE_ARCH=YES
  -resultBundlePath "$RESULT_BUNDLE"
)
BOUNDED_TEST_CMD=(scripts/ambitions-bounded-xcodebuild.sh --timeout "$TIMEOUT_DURATION" --kill-after "$KILL_AFTER" --test-launch-timeout "$TEST_LAUNCH_TIMEOUT" --log "$LOG_FILE" -- "${TEST_CMD[@]}")

classify_log_failure() {
  python3 scripts/ambitions-xcode-failure-classifier.py --log "$LOG_FILE" --json \
    | python3 -c 'import sys, json; print(json.load(sys.stdin).get("classification", ""))'
}

is_simulator_retry_class() {
  case "$1" in
    simulator_boot_failure|simulator_launcher_failure) return 0 ;;
    *) return 1 ;;
  esac
}

mark_status_from_log_failure() {
  [[ "$status" -eq 0 ]] || return 0

  local detected
  detected="$(classify_log_failure)"
  case "$detected" in
    ""|unknown) ;;
    *)
      status=65
      classification="$detected"
      ;;
  esac
}

repair_simulator_for_retry() {
  if [[ "$classification" == "simulator_launcher_failure" && -n "${sim:-}" ]]; then
    run_with_optional_timeout "$SIM_HEALTH_TIMEOUT" xcrun simctl shutdown "$sim" >/dev/null 2>&1 || true
  fi

  scripts/ambitions-xcode-sim-health.sh --repair --json --timeout "$SIM_HEALTH_TIMEOUT" >/dev/null 2>&1
}

classification=""
run_once
status=$?

if [[ "$status" -eq 0 ]] && grep -Eq "Testing failed:|\\*\\* TEST EXECUTE FAILED \\*\\*" "$LOG_FILE"; then
  status=65
fi
if [[ "$status" -eq 0 ]] && grep -Eq "Test Case '.+' failed|Test Suite '.+' failed|XCTAssert.+ failed|: error: -\\[.+\\] : XCTAssert" "$LOG_FILE"; then
  status=65
fi
mark_status_from_log_failure

if [[ "$status" -ne 0 ]]; then
  [[ -n "$classification" ]] || classification="$(classify_log_failure)"
  if is_simulator_retry_class "$classification"; then
    set +e
    repair_simulator_for_retry
    repair_status=$?
    set -e
    if [[ "$repair_status" -eq 0 ]]; then
      run_once
      status=$?
      classification=""
      if [[ "$status" -eq 0 ]] && grep -Eq "Testing failed:|\\*\\* TEST EXECUTE FAILED \\*\\*" "$LOG_FILE"; then
        status=65
      fi
      if [[ "$status" -eq 0 ]] && grep -Eq "Test Case '.+' failed|Test Suite '.+' failed|XCTAssert.+ failed|: error: -\\[.+\\] : XCTAssert" "$LOG_FILE"; then
        status=65
      fi
      mark_status_from_log_failure
    else
      status="$repair_status"
      classification="simulator_boot_failure"
    fi
  fi
fi

if command -v scripts/ambitions-xcode-result-extract.sh >/dev/null 2>&1; then
  scripts/ambitions-xcode-result-extract.sh --result "$RESULT_BUNDLE" --output-dir "$SUMMARY_DIR/$BATCH/$RUN_ID/extract" || true
fi

result_bundle_corrupt=false
if [[ -e "$RESULT_BUNDLE" && ! -f "$RESULT_BUNDLE/Info.plist" ]]; then
  result_bundle_corrupt=true
fi

if [[ "$status" -eq 124 ]]; then
  detected="$(classify_log_failure)"
  if [[ "$detected" != "unknown" && -n "$detected" ]]; then
    classification="$detected"
  elif [[ ! -s "$LOG_FILE" || ( -e "$RESULT_BUNDLE" && ! -f "$RESULT_BUNDLE/Info.plist" && -z "$(grep -E "Test Suite|Test Case|Testing started" "$LOG_FILE" 2>/dev/null || true)" ) ]]; then
    classification="mcp_timeout_no_test_log"
  else
    classification="timeout"
  fi
else
  classification="$(classify_log_failure)"
fi
executed_tests="$(extract_executed_tests "$LOG_FILE")"
if [[ "$status" -eq 0 ]]; then
  if [[ "$executed_tests" =~ ^[0-9]+$ && "$executed_tests" -gt 0 ]]; then
    classification="passed"
  else
    status=65
    classification="test_discovery_failure"
  fi
fi
if [[ "$status" -ne 0 && -e "$RESULT_BUNDLE" && ! -f "$RESULT_BUNDLE/Info.plist" && "$classification" == "unknown" ]]; then
  classification="corrupt_xcresult"
fi
[[ -z "$classification" ]] && classification="unknown"
duration_seconds="$(python3 - "$run_start" <<'PY'
import sys
import time
print(round(time.time() - float(sys.argv[1]), 3))
PY
)"
xcode_observer_seconds="$(extract_xcode_observer_seconds "$LOG_FILE")"
xctest_wall_seconds="$(extract_xctest_wall_seconds "$LOG_FILE")"
if [[ "$result_bundle_corrupt" == "true" && "$executed_tests" =~ ^[0-9]+$ && "$executed_tests" -eq 0 ]]; then
  status=65
  if [[ -z "$(grep -E "Test Suite|Test Case|Testing started" "$LOG_FILE" 2>/dev/null || true)" ]]; then
    classification="mcp_timeout_no_test_log"
  else
    classification="corrupt_xcresult"
  fi
fi

cat > "$SUMMARY_FILE" <<JSON
{
  "batch": "$BATCH",
  "lane": "focused-test",
  "test": "$test_filter",
  "scheme": "$RESOLVED_SCHEME",
  "proof_scope": "$PROOF_SCOPE",
  "requested_xcodebuild_action": "$REQUESTED_XCODEBUILD_ACTION",
  "xcodebuild_action": "$XCODEBUILD_ACTION",
  "status": "$([ "$status" -eq 0 ] && echo passed || echo failed)",
  "failure_category": "$classification",
  "executed_tests": $executed_tests,
  "duration_seconds": $duration_seconds,
  "xcode_observer_seconds": $xcode_observer_seconds,
  "xctest_wall_seconds": $xctest_wall_seconds,
  "result_bundle": "$RESULT_BUNDLE",
  "log_file": "$LOG_FILE",
  "timestamp_utc": "$TS",
  "run_id": "$RUN_ID",
  "sim_destination": "$SIM_DEST",
  "selected_sim_name": "$sim_name",
  "selected_sim_udid": "$sim_udid",
  "selected_sim_state": "$sim_state",
  "simulator_selection_source": "$sim_selection_source",
  "simulator_exact_name_match_count": $sim_exact_name_match_count,
  "ui_prebuild_required": $UI_PREBUILD_REQUIRED,
  "ui_prebuild_status": "$([[ "$UI_PREBUILD_REQUIRED" == "true" ]] && { [ "$UI_PREBUILD_STATUS" -eq 0 ] && echo passed || echo failed; } || echo not_run)",
  "ui_prebuild_failure_category": "$UI_PREBUILD_FAILURE_CLASS",
  "ui_prebuild_timeout": "$UI_PREBUILD_TIMEOUT_DURATION",
  "ui_prebuild_log_file": "$UI_PREBUILD_OUTPUT_FILE",
  "ui_prebuild_summary_file": "$UI_PREBUILD_SUMMARY_FILE",
  "claim_boundary": "focused test execution proof only; UI build-for-testing prebuild is prerequisite proof, not UI, visual, accessibility, device, TestFlight, App Store, or release proof"
}
JSON

echo "FAILURE_CLASS=$classification"
echo "EXECUTED_TESTS=$executed_tests"
echo "DURATION_SECONDS=$duration_seconds"
echo "SCHEME=$RESOLVED_SCHEME"
((status == 0)) || exit "$status"
exit 0
