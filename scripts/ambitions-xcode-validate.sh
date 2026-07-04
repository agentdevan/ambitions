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
BENCHMARK_BASE=".codex/xcode-benchmarks"
DERIVED_DATA_DIR=".codex/DerivedData/Ambitions"
mkdir -p "$RESULT_BASE" "$LOG_BASE" "$SUMMARY_BASE" "$BENCHMARK_BASE"

TS="$(date -u +%Y%m%dT%H%M%SZ)"
RUN_ID="$TS-validate-$$-${RANDOM:-0}"
SUMMARY_FILE="$SUMMARY_BASE/$BATCH/$RUN_ID/validate-summary.json"
BENCHMARK_FILE="$BENCHMARK_BASE/$BATCH/$RUN_ID/validate-benchmark.json"
mkdir -p "$SUMMARY_BASE/$BATCH/$RUN_ID" "$BENCHMARK_BASE/$BATCH/$RUN_ID"
START_EPOCH="$(date +%s)"
SLOW_THRESHOLD_SECONDS="${AMBITIONS_XCODE_SLOW_THRESHOLD_SECONDS:-300}"

map_exit_code() {
  local class="$1"
  case "$class" in
    no_validation_required) echo 10 ;;
    test_failure|test_discovery_failure) echo 20 ;;
    compile_error|signing_error) echo 21 ;;
    simulator_boot_failure|simulator_launcher_failure|missing_destination) echo 22 ;;
    xcodegen_project_drift|stale_derived_data) echo 23 ;;
    tool_missing) echo 24 ;;
    test_timeout|automation_event_timeout|launch_wait_timeout|idle_wait_timeout|mcp_timeout_no_test_log|simctl_unresponsive) echo 25 ;;
    corrupt_xcresult|result_extraction_failure) echo 26 ;;
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
    2>&1 | tee "$log_file" >&2
  run_status=$?
  set -e

  printf '%s:%s\n' "$run_status" "$(classify_from_log "$log_file" "unknown")"
}

run_wrapper() {
  local run_output status class executed
  set +e
  run_output="$("$@" 2>&1)"
  status=$?
  set -e

  class="$(printf '%s\n' "$run_output" | awk -F= '/^FAILURE_CLASS=/{print $2; exit}')"
  if [[ -z "$class" ]]; then
    class="unknown"
  fi
  executed="$(printf '%s\n' "$run_output" | awk -F= '/^EXECUTED_TESTS=/{print $2; exit}')"
  printf '%s:%s:%s\n' "$status" "$class" "$executed"
}

PREBOOT_FAILURE_CLASS=""
preboot_simulator() {
  PREBOOT_FAILURE_CLASS=""
  if command -v scripts/ambitions-xcode-sim-health.sh >/dev/null 2>&1; then
    local output status
    set +e
    output="$(scripts/ambitions-xcode-sim-health.sh --json --repair 2>&1)"
    status=$?
    set -e
    PREBOOT_FAILURE_CLASS="$(python3 - "$output" <<'PY'
import json
import sys

try:
    data = json.loads(sys.argv[1])
except Exception:
    data = {}
print(data.get("failure_category") or "simulator_boot_failure")
PY
)"
    if [[ "$status" -ne 0 ]]; then
      return 1
    fi
  fi
  return 0
}

clean_local_derived_data() {
  scripts/ambitions-deriveddata-manager.sh clean --batch "$BATCH" --reason "$1" >/dev/null 2>&1 || true
}

swift_changes_since_base() {
  local base="${AMBITIONS_XCODE_CHANGED_BASE:-}"
  if [[ -n "$base" ]] && git cat-file -e "$base^{commit}" >/dev/null 2>&1; then
    git diff --name-only "$base" -- '*.swift' | grep -q .
    return $?
  fi
  if git diff --name-only -- '*.swift' | grep -q .; then
    return 0
  fi
  if git diff --cached --name-only -- '*.swift' | grep -q .; then
    return 0
  fi
  git ls-files --others --exclude-standard -- '*.swift' | grep -q .
}

focused_tests_are_all_unit() {
  [[ -n "$TEST" ]] || return 1
  local suite
  IFS=',' read -r -a suites_for_scheme <<< "$TEST"
  for suite in "${suites_for_scheme[@]}"; do
    suite="$(printf '%s' "$suite" | sed 's/^[[:space:]]*//;s/[[:space:]]*$//')"
    [[ -n "$suite" ]] || continue
    case "$suite" in
      AmbitionsTests|AmbitionsTests/*) ;;
      *) return 1 ;;
    esac
  done
  return 0
}

focused_prebuild_scheme_for_tests() {
  if focused_tests_are_all_unit; then
    printf '%s\n' "${AMBITIONS_XCODE_UNIT_TEST_SCHEME:-AmbitionsUnitTests}"
  else
    printf '%s\n' "${AMBITIONS_XCODE_FULL_TEST_SCHEME:-Ambitions}"
  fi
}

third_status_field() {
  local value="$1"
  local rest="${value#*:}"
  if [[ "$rest" == "$value" ]]; then
    printf '\n'
    return
  fi
  rest="${rest#*:}"
  if [[ "$rest" == "$value" ]]; then
    printf '\n'
    return
  fi
  printf '%s\n' "${rest%%:*}"
}

write_benchmark_summary() {
  local phase="$1"
  local exit_code="$2"
  local category="$3"
  local end_epoch duration slow
  end_epoch="$(date +%s)"
  duration=$((end_epoch - START_EPOCH))
  slow=false
  if [[ "$duration" -ge "$SLOW_THRESHOLD_SECONDS" ]]; then
    slow=true
  fi
  python3 - "$BENCHMARK_FILE" "$BATCH" "$LANE" "$TS" "$phase" "$exit_code" "$category" "$duration" "$SLOW_THRESHOLD_SECONDS" "$slow" "$DERIVED_DATA_DIR" <<'PY'
import json
import sys
from pathlib import Path

(
    path,
    batch,
    lane,
    timestamp,
    phase,
    exit_code,
    category,
    duration,
    threshold,
    slow,
    derived_data,
) = sys.argv[1:]

payload = {
    "batch": batch,
    "lane": lane,
    "timestamp_utc": timestamp,
    "phase": phase,
    "exit_code": int(exit_code),
    "failure_category": category,
    "duration_seconds": int(duration),
    "slow_threshold_seconds": int(threshold),
    "slow_validation": slow == "true",
    "derived_data": derived_data,
    "artifact_root": ".codex/xcode-benchmarks",
    "claim_boundary": "timing evidence only; not build, test, release, accessibility, device, TestFlight, or App Store proof",
}
Path(path).write_text(json.dumps(payload, indent=2, sort_keys=True) + "\n", encoding="utf-8")
PY
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

    if [[ "$allow_sim_retry" == "1" && ( "$attempt_class" == "simulator_boot_failure" || "$attempt_class" == "simulator_launcher_failure" ) && "$attempts" -eq 0 ]]; then
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
if [[ -x scripts/ambitions-build-lab-doctor.sh ]]; then
  scripts/ambitions-build-lab-doctor.sh --json >/dev/null 2>&1 || true
fi

status=0
failure_class="unknown"
run_status_and_class=""
prebuild_for_focused_test=false
prebuild_status="not_run"
prebuild_failure_class="not_run"
focused_prebuild_scheme="not_run"
focused_executed_tests=0
focused_suite_count=0
focused_rerun_after_prebuild=false
case "$LANE" in
  none)
    status=10
    failure_class="no_validation_required"
    ;;

  build)
    need_output="$(scripts/ambitions-xcodegen-needed.sh || true)"
    need_flag="$(awk -F= '/^XCODEGEN_NEEDED=/{print $2}' <<<"$need_output")"
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
      result_file="$RESULT_BASE/$BATCH/$RUN_ID/build.xcresult"
      log_file="$LOG_BASE/$BATCH/$RUN_ID/build.log"
      run_status_and_class="$(run_xcodebuild_build "$log_file" "$result_file")"
      status="${run_status_and_class%%:*}"
      failure_class="${run_status_and_class#*:}"
      failure_class="${failure_class%%:*}"
    fi
    ;;

  build-for-testing)
    if ! preboot_simulator; then
      status=22
      failure_class="${PREBOOT_FAILURE_CLASS:-simulator_boot_failure}"
    fi
    if [[ "$status" -eq 0 ]]; then
      mkdir -p "$RESULT_BASE/$BATCH/$RUN_ID" "$LOG_BASE/$BATCH/$RUN_ID" "$SUMMARY_BASE/$BATCH/$RUN_ID"
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
      failure_class="${PREBOOT_FAILURE_CLASS:-simulator_boot_failure}"
    else
      mkdir -p "$RESULT_BASE/$BATCH/$RUN_ID" "$LOG_BASE/$BATCH/$RUN_ID" "$SUMMARY_BASE/$BATCH/$RUN_ID"
      if [[ "${AMBITIONS_XCODE_SKIP_PREBUILD:-0}" != "1" ]] && swift_changes_since_base; then
        prebuild_for_focused_test=true
        focused_prebuild_scheme="$(focused_prebuild_scheme_for_tests)"
        echo "Swift source/test changes detected; running $focused_prebuild_scheme build-for-testing before focused tests" >&2
        run_status_and_class="$(run_validation_command 0 scripts/ambitions-xcode-build-for-testing.sh \
          --batch "$BATCH" \
          --scheme "$focused_prebuild_scheme" \
          --results-dir "$RESULT_BASE" \
          --logs-dir "$LOG_BASE" \
          --summaries-dir "$SUMMARY_BASE")"
        prebuild_status="${run_status_and_class%%:*}"
        prebuild_failure_class="${run_status_and_class#*:}"
        prebuild_failure_class="${prebuild_failure_class%%:*}"
        if [[ "$prebuild_status" != "0" ]]; then
          status="$prebuild_status"
          failure_class="$prebuild_failure_class"
        fi
      fi

      if [[ "$status" -eq 0 ]]; then
        IFS=',' read -r -a focused_suites <<< "$TEST"
        for suite in "${focused_suites[@]}"; do
          suite="$(printf '%s' "$suite" | sed 's/^[[:space:]]*//;s/[[:space:]]*$//')"
          [[ -n "$suite" ]] || continue
          focused_suite_count=$((focused_suite_count + 1))
          run_status_and_class="$(run_validation_command 1 scripts/ambitions-xcode-test-focused.sh \
            --batch "$BATCH" \
            --test "$suite" \
            --results-dir "$RESULT_BASE" \
            --logs-dir "$LOG_BASE" \
            --summaries-dir "$SUMMARY_BASE")"
          status="${run_status_and_class%%:*}"
          failure_class="${run_status_and_class#*:}"
          failure_class="${failure_class%%:*}"
          executed="$(third_status_field "$run_status_and_class")"
          if [[ "$executed" =~ ^[0-9]+$ ]]; then
            focused_executed_tests=$((focused_executed_tests + executed))
          fi

          if [[ "$status" != "0" && ( "$failure_class" == "stale_derived_data" || "$failure_class" == "test_discovery_failure" ) ]]; then
            focused_rerun_after_prebuild=true
            echo "Focused test reported $failure_class; rebuilding test bundle and retrying once" >&2
            [[ "$focused_prebuild_scheme" == "not_run" ]] && focused_prebuild_scheme="$(focused_prebuild_scheme_for_tests)"
            run_status_and_class="$(run_validation_command 0 scripts/ambitions-xcode-build-for-testing.sh \
              --batch "$BATCH" \
              --scheme "$focused_prebuild_scheme" \
              --results-dir "$RESULT_BASE" \
              --logs-dir "$LOG_BASE" \
              --summaries-dir "$SUMMARY_BASE")"
            prebuild_status="${run_status_and_class%%:*}"
            prebuild_failure_class="${run_status_and_class#*:}"
            prebuild_failure_class="${prebuild_failure_class%%:*}"
            if [[ "$prebuild_status" == "0" ]]; then
              run_status_and_class="$(run_validation_command 1 scripts/ambitions-xcode-test-focused.sh \
                --batch "$BATCH" \
                --test "$suite" \
                --results-dir "$RESULT_BASE" \
                --logs-dir "$LOG_BASE" \
                --summaries-dir "$SUMMARY_BASE")"
              status="${run_status_and_class%%:*}"
              failure_class="${run_status_and_class#*:}"
              failure_class="${failure_class%%:*}"
              executed="$(third_status_field "$run_status_and_class")"
              if [[ "$executed" =~ ^[0-9]+$ ]]; then
                focused_executed_tests=$((focused_executed_tests + executed))
              fi
            fi
          fi

          if [[ "$status" != "0" ]]; then
            break
          fi
        done
      fi
    fi
    ;;

  test-plan|ui-proof|terminal-device-proof)
    if ! preboot_simulator; then
      status=22
      failure_class="${PREBOOT_FAILURE_CLASS:-simulator_boot_failure}"
    else
      case "$LANE" in
        test-plan) [[ -n "$TEST_PLAN" ]] || TEST_PLAN="Ambitions-Focused" ;;
        ui-proof) TEST_PLAN="Ambitions-UI" ;;
        terminal-device-proof) TEST_PLAN="Ambitions-ReleaseProof" ;;
      esac
      mkdir -p "$RESULT_BASE/$BATCH/$RUN_ID" "$LOG_BASE/$BATCH/$RUN_ID" "$SUMMARY_BASE/$BATCH/$RUN_ID"
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
  write_benchmark_summary "pre_cleanup" "$status" "$failure_class"
  if [[ "$status" -eq 23 ]]; then
    clean_local_derived_data "$failure_class"
  fi
fi

if [[ "$status" -eq 0 ]]; then
  failure_class="passed"
fi

write_benchmark_summary "final" "$status" "$failure_class"

duration_seconds="$(python3 - "$BENCHMARK_FILE" <<'PY'
import json
import sys
try:
    print(json.load(open(sys.argv[1], encoding="utf-8")).get("duration_seconds", 0))
except Exception:
    print(0)
PY
)"
slow_validation="$(python3 - "$BENCHMARK_FILE" <<'PY'
import json
import sys
try:
    print(str(json.load(open(sys.argv[1], encoding="utf-8")).get("slow_validation", False)).lower())
except Exception:
    print("false")
PY
)"

cat > "$SUMMARY_FILE" <<JSON
{
  "batch": "$BATCH",
  "lane": "$LANE",
  "timestamp_utc": "$TS",
  "exit_code": $status,
  "status": "$([ "$status" -eq 0 ] && echo passed || echo failed)",
  "failure_category": "$failure_class",
  "duration_seconds": $duration_seconds,
  "slow_threshold_seconds": $SLOW_THRESHOLD_SECONDS,
  "slow_validation": $slow_validation,
  "test": "$TEST",
  "test_plan": "$TEST_PLAN",
  "prebuild_for_focused_test": $prebuild_for_focused_test,
  "focused_prebuild_scheme": "$focused_prebuild_scheme",
  "prebuild_status": "$prebuild_status",
  "prebuild_failure_category": "$prebuild_failure_class",
  "focused_suite_count": $focused_suite_count,
  "focused_executed_tests": $focused_executed_tests,
  "focused_rerun_after_prebuild": $focused_rerun_after_prebuild,
  "run_id": "$RUN_ID",
  "result_root": "$RESULT_BASE/$BATCH",
  "log_root": "$LOG_BASE/$BATCH",
  "benchmark_file": "$BENCHMARK_FILE",
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
