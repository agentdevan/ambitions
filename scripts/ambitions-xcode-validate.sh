#!/usr/bin/env bash
set -Eeuo pipefail

REPO_ROOT="$(git rev-parse --show-toplevel 2>/dev/null || pwd -P)"
cd "$REPO_ROOT"

usage() {
  cat <<'USAGE'
Usage:
  scripts/ambitions-xcode-validate.sh --batch <BATCH> --lane <none|build|build-for-testing|focused-test|test-plan|ui-proof|terminal-device-proof> [--test <ID>] [--test-plan <Name>] [--json]
USAGE
}

BATCH=""
LANE=""
TEST=""
TEST_PLAN=""
JSON=0
while [[ "$#" -gt 0 ]]; do
  case "$1" in
    --batch) BATCH="$2"; shift 2 ;;
    --lane) LANE="$2"; shift 2 ;;
    --test) TEST="$2"; shift 2 ;;
    --test-plan) TEST_PLAN="$2"; shift 2 ;;
    --json) JSON=1; shift ;;
    -h|--help)
      usage
      exit 0
      ;;
    *)
      echo "unsupported arg: $1" >&2
      usage >&2
      exit 1
      ;;
  esac
done

[[ -n "$BATCH" ]] || { echo "--batch is required" >&2; exit 1; }
[[ -n "$LANE" ]] || { echo "--lane is required" >&2; exit 1; }

RESULT_BASE=".codex/xcode-results"
LOG_BASE=".codex/xcode-logs"
SUMMARY_BASE=".codex/xcode-summaries"
DERIVED_DATA_DIR=".codex/DerivedData/Ambitions"
mkdir -p "$RESULT_BASE" "$LOG_BASE" "$SUMMARY_BASE"

TS="$(date -u +%Y%m%dT%H%M%SZ)"
SUMMARY_FILE="$SUMMARY_BASE/$BATCH/$TS/validate-summary.json"
mkdir -p "$SUMMARY_BASE/$BATCH/$TS"

map_exit_code() {
  local class="$1"
  case "$class" in
    no_validation_required) echo 10 ;;
    test_failure|test_discovery_failure) echo 20 ;;
    compile_error|signing_error) echo 21 ;;
    simulator_boot_failure|missing_destination) echo 22 ;;
    xcodegen_project_drift|stale_derived_data) echo 23 ;;
    tool_missing) echo 24 ;;
    test_timeout) echo 25 ;;
    *) echo 26 ;;
  esac
}

classify_from_log() {
  local log_file="$1"
  local fallback="${2:-unknown}"
  if [[ -z "$log_file" || ! -f "$log_file" ]]; then
    echo "$fallback"
    return
  fi
  python3 scripts/ambitions-xcode-failure-classifier.py --log "$log_file" --json \
    | python3 -c 'import sys, json; print(json.load(sys.stdin).get("classification","unknown"))' \
    || echo "$fallback"
}

run_xcodebuild_build() {
  local log_file="$1"
  local result_file="$2"
  local run_status
  mkdir -p "$(dirname "$log_file")" "$(dirname "$result_file")" "$DERIVED_DATA_DIR"

  set +e
  xcodebuild -project Ambitions.xcodeproj \
    -scheme Ambitions \
    -derivedDataPath "$DERIVED_DATA_DIR" \
    build \
    CODE_SIGNING_ALLOWED=NO CODE_SIGNING_REQUIRED=NO \
    -resultBundlePath "$result_file" \
    2>&1 | tee "$log_file"
  run_status=$?
  set -e

  printf '%s:%s\n' "$run_status" "$(classify_from_log "$log_file" "unknown")"
}

run_wrapper() {
  local run_output status class
  set +e
  run_output="$("$@" 2>&1)"
  status=$?
  set -e

  class="$(printf '%s\n' "$run_output" | awk -F= '/^FAILURE_CLASS=/{print $2; exit}')"
  if [[ -z "$class" ]]; then
    class="unknown"
  fi
  printf '%s:%s\n' "$status" "$class"
}

preboot_simulator() {
  if command -v scripts/ambitions-xcode-sim-health.sh >/dev/null 2>&1; then
    if ! scripts/ambitions-xcode-sim-health.sh --json --repair >/dev/null 2>&1; then
      return 1
    fi
  fi
  return 0
}

clean_local_derived_data() {
  scripts/ambitions-deriveddata-manager.sh clean --batch "$BATCH" --reason "$1" >/dev/null 2>&1 || true
}

run_validation_command() {
  local allow_sim_retry="$1"
  shift

  local status_and_class attempt_status attempt_class
  local attempts=0
  while (( attempts < 2 )); do
    status_and_class="$(run_wrapper "$@")"
    attempt_status="${status_and_class%%:*}"
    attempt_class="${status_and_class#*:}"
    attempt_class="${attempt_class%%:*}"

    if [[ "$attempt_status" == 0 || "$attempt_status" == "0" ]]; then
      echo "$status_and_class"
      return 0
    fi

    if [[ "$allow_sim_retry" == "1" && "$attempt_class" == "simulator_boot_failure" && "$attempts" -eq 0 ]]; then
      attempts=$((attempts + 1))
      scripts/ambitions-xcode-sim-health.sh --repair --json >/dev/null 2>&1 || true
      continue
    fi

    echo "$status_and_class"
    return 1
  done

  echo "$status_and_class"
  return 1
}

scripts/ambitions-xcode-version-check.sh >/dev/null 2>&1 || true
scripts/ambitions-build-lab-doctor.sh --json >/dev/null 2>&1 || true

status=0
failure_class="unknown"
run_status_and_class=""
case "$LANE" in
  none)
    status=10
    failure_class="no_validation_required"
    ;;

  build)
    need_output="$(scripts/ambitions-xcodegen-needed.sh || true)"
    need_flag="$(awk -F= '/^XCODEGEN_NEEDED=/{print $2}' <<<"$need_output")"
    need_reason="$(awk -F= '/^REASON=/{print $2}' <<<"$need_output")"
    if [[ "$need_flag" == "1" ]]; then
      if ! command -v xcodegen >/dev/null 2>&1; then
        status=24
        failure_class="tool_missing"
      elif ! xcodegen generate >/dev/null; then
        status=23
        failure_class="xcodegen_project_drift"
      fi
    fi
    if [[ "$status" -eq 0 ]]; then
      result_file="$RESULT_BASE/$BATCH/$TS/build.xcresult"
      log_file="$LOG_BASE/$BATCH/$TS/build.log"
      run_status_and_class="$(run_xcodebuild_build "$log_file" "$result_file")"
      status="${run_status_and_class%%:*}"
      failure_class="${run_status_and_class#*:}"
      failure_class="${failure_class%%:*}"
    fi
    ;;

  build-for-testing)
    if ! preboot_simulator; then
      status=22
      failure_class="simulator_boot_failure"
    fi
    if [[ "$status" -eq 0 ]]; then
      mkdir -p "$RESULT_BASE/$BATCH/$TS" "$LOG_BASE/$BATCH/$TS" "$SUMMARY_BASE/$BATCH/$TS"
      run_status_and_class="$(run_validation_command 0 scripts/ambitions-xcode-build-for-testing.sh \
        --batch "$BATCH" \
        --results-dir "$RESULT_BASE" \
        --logs-dir "$LOG_BASE" \
        --summaries-dir "$SUMMARY_BASE")"
      status="${run_status_and_class%%:*}"
      failure_class="${run_status_and_class#*:}"
      failure_class="${failure_class%%:*}"
    fi
    ;;

  focused-test)
    [[ -n "$TEST" ]] || TEST="AmbitionsTests/Focused"
    if ! preboot_simulator; then
      status=22
      failure_class="simulator_boot_failure"
    else
      mkdir -p "$RESULT_BASE/$BATCH/$TS" "$LOG_BASE/$BATCH/$TS" "$SUMMARY_BASE/$BATCH/$TS"
      run_status_and_class="$(run_validation_command 1 scripts/ambitions-xcode-test-focused.sh \
        --batch "$BATCH" \
        --test "$TEST" \
        --results-dir "$RESULT_BASE" \
        --logs-dir "$LOG_BASE" \
        --summaries-dir "$SUMMARY_BASE")"
      status="${run_status_and_class%%:*}"
      failure_class="${run_status_and_class#*:}"
      failure_class="${failure_class%%:*}"
    fi
    ;;

  test-plan|ui-proof|terminal-device-proof)
    if ! preboot_simulator; then
      status=22
      failure_class="simulator_boot_failure"
    else
      case "$LANE" in
        test-plan) [[ -n "$TEST_PLAN" ]] || TEST_PLAN="Ambitions-Focused" ;;
        ui-proof) TEST_PLAN="Ambitions-UI" ;;
        terminal-device-proof) TEST_PLAN="Ambitions-ReleaseProof" ;;
      esac
      mkdir -p "$RESULT_BASE/$BATCH/$TS" "$LOG_BASE/$BATCH/$TS" "$SUMMARY_BASE/$BATCH/$TS"
      run_status_and_class="$(run_validation_command 1 scripts/ambitions-xcode-test-plan.sh \
        --batch "$BATCH" \
        --test-plan "$TEST_PLAN" \
        --results-dir "$RESULT_BASE" \
        --logs-dir "$LOG_BASE" \
        --summaries-dir "$SUMMARY_BASE")"
      status="${run_status_and_class%%:*}"
      failure_class="${run_status_and_class#*:}"
      failure_class="${failure_class%%:*}"
    fi
    ;;

  *)
    echo "unsupported lane: $LANE" >&2
    exit 1
    ;;
esac

if [[ "$status" -ne 0 ]] && [[ "$status" != "10" ]]; then
  status="$(map_exit_code "$failure_class")"
  if [[ "$status" -eq 23 ]]; then
    clean_local_derived_data "$failure_class"
  fi
fi

if [[ "$status" -eq 0 ]]; then
  failure_class="passed"
fi

cat > "$SUMMARY_FILE" <<JSON
{
  "batch": "$BATCH",
  "lane": "$LANE",
  "timestamp_utc": "$TS",
  "exit_code": $status,
  "status": "$([ "$status" -eq 0 ] && echo passed || echo failed)",
  "failure_category": "$failure_class",
  "test": "$TEST",
  "test_plan": "$TEST_PLAN",
  "result_root": "$RESULT_BASE/$BATCH/$TS",
  "log_root": "$LOG_BASE/$BATCH/$TS",
  "derived_data": "$DERIVED_DATA_DIR"
}
JSON

if [[ "$status" -eq 0 ]]; then
  echo "xcode validation passed"
else
  echo "xcode validation failed ($status): $failure_class"
fi

if (( JSON == 1 )); then
  cat "$SUMMARY_FILE"
fi

exit "$status"
