#!/usr/bin/env bash
set -Eeuo pipefail

REPO_ROOT="$(git rev-parse --show-toplevel 2>/dev/null || pwd -P)"
cd "$REPO_ROOT"

BATCH=""
TEST_IDS=()
ONLY_TESTING_FILTERS=()
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
RESULT_EXTRACTION_REQUESTED="${AMBITIONS_XCODE_RESULT_EXTRACTION:-auto}"

while [[ "$#" -gt 0 ]]; do
  case "$1" in
    --batch) BATCH="${2:-}"; shift 2 ;;
    --test)
      [[ "$#" -ge 2 ]] || { echo "--test requires a value" >&2; exit 2; }
      TEST_IDS+=("$2")
      shift 2
      ;;
    --only-testing)
      [[ "$#" -ge 2 ]] || { echo "--only-testing requires a value" >&2; exit 2; }
      ONLY_TESTING_FILTERS+=("$2")
      shift 2
      ;;
    --scheme) SCHEME="${2:-$SCHEME}"; shift 2 ;;
    --results-dir) RESULT_DIR="${2:-$RESULT_DIR}"; shift 2 ;;
    --logs-dir) LOG_DIR="${2:-$LOG_DIR}"; shift 2 ;;
    --summaries-dir) SUMMARY_DIR="${2:-$SUMMARY_DIR}"; shift 2 ;;
    --timeout) TIMEOUT_DURATION="${2:-$TIMEOUT_DURATION}"; shift 2 ;;
    --kill-after) KILL_AFTER="${2:-$KILL_AFTER}"; shift 2 ;;
    --test-launch-timeout) TEST_LAUNCH_TIMEOUT="${2:-$TEST_LAUNCH_TIMEOUT}"; shift 2 ;;
    --result-extraction) RESULT_EXTRACTION_REQUESTED="${2:-}"; shift 2 ;;
    --without-building|--test-without-building) XCODEBUILD_ACTION="test-without-building"; shift ;;
    --prebuild) UI_PREBUILD_MODE="always"; shift ;;
    --skip-prebuild) UI_PREBUILD_MODE="never"; shift ;;
    --prebuild-timeout) UI_PREBUILD_TIMEOUT_DURATION="${2:-$UI_PREBUILD_TIMEOUT_DURATION}"; shift 2 ;;
    --prebuild-kill-after) UI_PREBUILD_KILL_AFTER="${2:-$UI_PREBUILD_KILL_AFTER}"; shift 2 ;;
    -h|--help)
      echo "Usage: scripts/ambitions-xcode-test-focused.sh --batch <BATCH> (--test <TEST_ID>... | --only-testing <FILTER>...) [--scheme auto|Ambitions|AmbitionsModuleTests|AmbitionsUnitTests|AmbitionsUITests] [--timeout 15m] [--kill-after 60s] [--test-launch-timeout 30s] [--result-extraction auto|metadata|full] [--without-building] [--prebuild|--skip-prebuild] [--prebuild-timeout 35m]" >&2
      exit 0
      ;;
    *)
      echo "unsupported arg: $1" >&2
      exit 1
      ;;
  esac
done

case "$RESULT_EXTRACTION_REQUESTED" in
  auto|metadata|full) ;;
  *)
    echo "unsupported result extraction mode: $RESULT_EXTRACTION_REQUESTED (expected auto, metadata, or full)" >&2
    exit 2
    ;;
esac

[[ -n "$BATCH" ]] || { echo "--batch is required" >&2; exit 1; }
if ((${#TEST_IDS[@]} > 0 && ${#ONLY_TESTING_FILTERS[@]} > 0)); then
  echo "cannot mix --test and --only-testing in one focused run" >&2
  exit 2
fi
if ((${#TEST_IDS[@]} == 0 && ${#ONLY_TESTING_FILTERS[@]} == 0)); then
  echo "one of --test or --only-testing is required" >&2
  exit 2
fi

if ((${#TEST_IDS[@]} > 0)); then
  TEST_FILTERS=("${TEST_IDS[@]}")
else
  TEST_FILTERS=("${ONLY_TESTING_FILTERS[@]}")
fi
for test_filter_candidate in "${TEST_FILTERS[@]}"; do
  if [[ -z "${test_filter_candidate//[[:space:]]/}" ]]; then
    echo "test filters must not be empty" >&2
    exit 2
  fi
done

filter_prefix() {
  case "$1" in
    AmbitionsModuleTests|AmbitionsModuleTests/*) printf '%s\n' module ;;
    AmbitionsTests|AmbitionsTests/*) printf '%s\n' unit ;;
    AmbitionsUITests|AmbitionsUITests/*) printf '%s\n' ui ;;
    *) printf '%s\n' unknown ;;
  esac
}

scheme_accepts_prefix() {
  local scheme="$1"
  local prefix="$2"
  case "$scheme:$prefix" in
    AmbitionsModuleTests:module|AmbitionsUnitTests:unit|AmbitionsUITests:ui) return 0 ;;
    Ambitions:unit|Ambitions:ui|Ambitions:unknown) return 0 ;;
    *) return 1 ;;
  esac
}

resolve_scheme() {
  local prefix first_prefix
  if [[ "$SCHEME" != "auto" ]]; then
    case "$SCHEME" in
      Ambitions|AmbitionsModuleTests|AmbitionsUnitTests|AmbitionsUITests) ;;
      *)
        echo "unsupported focused-test scheme: $SCHEME" >&2
        return 2
        ;;
    esac
    if ((${#TEST_FILTERS[@]} > 1)); then
      for test_filter_candidate in "${TEST_FILTERS[@]}"; do
        if [[ "$(filter_prefix "$test_filter_candidate")" == "unknown" ]]; then
          echo "multi-filter runs require recognized test target prefixes" >&2
          return 2
        fi
      done
    fi
    for test_filter_candidate in "${TEST_FILTERS[@]}"; do
      prefix="$(filter_prefix "$test_filter_candidate")"
      if ! scheme_accepts_prefix "$SCHEME" "$prefix"; then
        echo "scheme $SCHEME does not accept filter prefix for $test_filter_candidate" >&2
        return 2
      fi
    done
    printf '%s\n' "$SCHEME"
    return
  fi

  first_prefix="$(filter_prefix "${TEST_FILTERS[0]}")"
  if ((${#TEST_FILTERS[@]} > 1)); then
    if [[ "$first_prefix" == "unknown" ]]; then
      echo "multi-filter auto runs require recognized test target prefixes" >&2
      return 2
    fi
    for test_filter_candidate in "${TEST_FILTERS[@]:1}"; do
      prefix="$(filter_prefix "$test_filter_candidate")"
      if [[ "$prefix" != "$first_prefix" ]]; then
        echo "auto-scheme batches require the same test target prefix" >&2
        return 2
      fi
    done
  fi

  case "$first_prefix" in
    module) printf '%s\n' "${AMBITIONS_XCODE_MODULE_TEST_SCHEME:-AmbitionsModuleTests}" ;;
    unit) printf '%s\n' "${AMBITIONS_XCODE_UNIT_TEST_SCHEME:-AmbitionsUnitTests}" ;;
    ui) printf '%s\n' "${AMBITIONS_XCODE_UI_TEST_SCHEME:-AmbitionsUITests}" ;;
    unknown) printf '%s\n' "${AMBITIONS_XCODE_FULL_TEST_SCHEME:-Ambitions}" ;;
  esac
}

if ! RESOLVED_SCHEME="$(resolve_scheme)"; then
  exit 2
fi

RESULT_EXTRACTION_MODE="$RESULT_EXTRACTION_REQUESTED"
if [[ "$RESULT_EXTRACTION_MODE" == "auto" ]]; then
  case "$RESOLVED_SCHEME" in
    AmbitionsModuleTests|AmbitionsUnitTests) RESULT_EXTRACTION_MODE="metadata" ;;
    *) RESULT_EXTRACTION_MODE="full" ;;
  esac
fi

REQUESTED_FILTER_COUNT="${#TEST_FILTERS[@]}"
test_filter="${TEST_FILTERS[0]}"
if ((REQUESTED_FILTER_COUNT == 1)); then
  test_display="$test_filter"
else
  test_display="$(IFS=,; printf '%s' "${TEST_FILTERS[*]}")"
fi
TESTS_JSON="$(python3 - "${TEST_FILTERS[@]}" <<'PY'
import json
import sys
print(json.dumps(sys.argv[1:], separators=(",", ":")))
PY
)"
TEST_FILTER_JSON="$(python3 - "$test_display" <<'PY'
import json
import sys
print(json.dumps(sys.argv[1]))
PY
)"

mkdir -p "$RESULT_DIR/$BATCH" "$LOG_DIR/$BATCH" "$SUMMARY_DIR/$BATCH"
TS="$(date -u +%Y%m%dT%H%M%SZ)"
if ((REQUESTED_FILTER_COUNT == 1)); then
  test_slug="$(printf '%s' "$test_filter" | tr -c 'A-Za-z0-9._-' '-' | cut -c1-80)"
else
  first_slug="$(printf '%s' "$test_filter" | tr -c 'A-Za-z0-9._-' '-' | cut -c1-60)"
  filter_hash="$(python3 - "${TEST_FILTERS[@]}" <<'PY'
import hashlib
import json
import sys
payload = json.dumps(sys.argv[1:], ensure_ascii=False, separators=(",", ":"))
print(hashlib.sha256(payload.encode("utf-8")).hexdigest()[:10])
PY
)"
  test_slug="${first_slug}-plus-$((REQUESTED_FILTER_COUNT - 1))-${filter_hash}"
fi
[[ -n "$test_slug" ]] || test_slug="focused"
RUN_ID="$TS-$test_slug-$$-${RANDOM:-0}"
RESULT_BUNDLE="$RESULT_DIR/$BATCH/$RUN_ID/focused-test.xcresult"
LOG_FILE="$LOG_DIR/$BATCH/$RUN_ID/focused-test.log"
SUMMARY_FILE="$SUMMARY_DIR/$BATCH/$RUN_ID/focused-test-summary.json"
RESULT_EXTRACTION_SUMMARY_FILE=""
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

PROOF_SCOPE="focused"
case "$RESOLVED_SCHEME" in
  AmbitionsModuleTests) PROOF_SCOPE="module-focused-fast" ;;
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
  "test": $TEST_FILTER_JSON,
  "tests": $TESTS_JSON,
  "requested_filter_count": $REQUESTED_FILTER_COUNT,
  "scheme": "$RESOLVED_SCHEME",
  "requested_result_extraction_mode": "$RESULT_EXTRACTION_REQUESTED",
  "result_extraction_mode": "$RESULT_EXTRACTION_MODE",
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
  "test": $TEST_FILTER_JSON,
  "tests": $TESTS_JSON,
  "requested_filter_count": $REQUESTED_FILTER_COUNT,
  "scheme": "$RESOLVED_SCHEME",
  "proof_scope": "$PROOF_SCOPE",
  "requested_result_extraction_mode": "$RESULT_EXTRACTION_REQUESTED",
  "result_extraction_mode": "$RESULT_EXTRACTION_MODE",
  "result_extraction_summary": "$RESULT_EXTRACTION_SUMMARY_FILE",
  "result_bundle_retained": false,
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
  "test": $TEST_FILTER_JSON,
  "tests": $TESTS_JSON,
  "requested_filter_count": $REQUESTED_FILTER_COUNT,
  "scheme": "$RESOLVED_SCHEME",
  "proof_scope": "$PROOF_SCOPE",
  "requested_result_extraction_mode": "$RESULT_EXTRACTION_REQUESTED",
  "result_extraction_mode": "$RESULT_EXTRACTION_MODE",
  "result_extraction_summary": "$RESULT_EXTRACTION_SUMMARY_FILE",
  "result_bundle_retained": false,
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
)
for test_filter_candidate in "${TEST_FILTERS[@]}"; do
  TEST_CMD+=("-only-testing:$test_filter_candidate")
done
TEST_CMD+=(
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

result_bundle_corrupt=false
RESULT_BUNDLE_RETAINED=false
if [[ -e "$RESULT_BUNDLE" ]]; then
  RESULT_BUNDLE_RETAINED=true
fi
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
  if [[ ! "$executed_tests" =~ ^[0-9]+$ || "$executed_tests" -eq 0 ]]; then
    status=65
    classification="test_discovery_failure"
  elif [[ "$RESULT_BUNDLE_RETAINED" != "true" ]]; then
    status=65
    classification="missing_xcresult"
  elif [[ "$result_bundle_corrupt" == "true" ]]; then
    status=65
    classification="corrupt_xcresult"
  else
    classification="passed"
  fi
fi
if [[ "$status" -ne 0 && -e "$RESULT_BUNDLE" && ! -f "$RESULT_BUNDLE/Info.plist" && "$classification" == "unknown" ]]; then
  classification="corrupt_xcresult"
fi
[[ -z "$classification" ]] && classification="unknown"
if [[ "$result_bundle_corrupt" == "true" && "$executed_tests" =~ ^[0-9]+$ && "$executed_tests" -eq 0 ]]; then
  status=65
  if [[ -z "$(grep -E "Test Suite|Test Case|Testing started" "$LOG_FILE" 2>/dev/null || true)" ]]; then
    classification="mcp_timeout_no_test_log"
  else
    classification="corrupt_xcresult"
  fi
fi

if [[ "$RESULT_EXTRACTION_REQUESTED" == "auto" && "$status" -ne 0 && -f "$RESULT_BUNDLE/Info.plist" ]]; then
  RESULT_EXTRACTION_MODE="full"
fi
if command -v scripts/ambitions-xcode-result-extract.sh >/dev/null 2>&1; then
  RESULT_EXTRACTION_SUMMARY_FILE="$(
    scripts/ambitions-xcode-result-extract.sh \
      --result "$RESULT_BUNDLE" \
      --output-dir "$SUMMARY_DIR/$BATCH/$RUN_ID/extract" \
      --mode "$RESULT_EXTRACTION_MODE" || true
  )"
fi

duration_seconds="$(python3 - "$run_start" <<'PY'
import sys
import time
print(round(time.time() - float(sys.argv[1]), 3))
PY
)"
xcode_observer_seconds="$(extract_xcode_observer_seconds "$LOG_FILE")"
xctest_wall_seconds="$(extract_xctest_wall_seconds "$LOG_FILE")"

cat > "$SUMMARY_FILE" <<JSON
{
  "batch": "$BATCH",
  "lane": "focused-test",
  "test": $TEST_FILTER_JSON,
  "tests": $TESTS_JSON,
  "requested_filter_count": $REQUESTED_FILTER_COUNT,
  "scheme": "$RESOLVED_SCHEME",
  "proof_scope": "$PROOF_SCOPE",
  "requested_result_extraction_mode": "$RESULT_EXTRACTION_REQUESTED",
  "result_extraction_mode": "$RESULT_EXTRACTION_MODE",
  "result_extraction_summary": "$RESULT_EXTRACTION_SUMMARY_FILE",
  "result_bundle_retained": $RESULT_BUNDLE_RETAINED,
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
