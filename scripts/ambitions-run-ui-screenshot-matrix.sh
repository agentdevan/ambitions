#!/usr/bin/env bash
set -Eeuo pipefail

REPO_ROOT="$(git rev-parse --show-toplevel 2>/dev/null || pwd -P)"
cd "$REPO_ROOT"

BATCH="DESIGN_TRUTH_TRAIN_05_6"
SCHEME="AmbitionsUITests"
DESTINATION="platform=iOS Simulator,name=iPhone 17 Pro,OS=26.5"
TIMEOUT_DURATION="20m"
KILL_AFTER="60s"
RESULT_DIR=".codex/xcode-results"
LOG_DIR=".codex/xcode-logs"
SUMMARY_DIR=".codex/xcode-summaries"
MAX_RETRIES=1

usage() {
  cat >&2 <<'EOF'
Usage: scripts/ambitions-run-ui-screenshot-matrix.sh [options]

Runs the AMB-962 Today screenshot matrix through scripts/ambitions-bounded-xcodebuild.sh.

Options:
  --batch <name>          Batch directory under .codex outputs. Default: DESIGN_TRUTH_TRAIN_05_6.
  --scheme <name>         Xcode scheme. Default: AmbitionsUITests.
  --destination <spec>    Xcode destination. Default: platform=iOS Simulator,name=iPhone 17 Pro,OS=26.5.
  --timeout <duration>    Wall-clock timeout. Default: 20m.
  --kill-after <duration> Timeout kill-after grace. Default: 60s.
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
[[ -n "$DESTINATION" ]] || { echo "--destination must not be empty" >&2; exit 2; }
[[ -n "$TIMEOUT_DURATION" ]] || { echo "--timeout must not be empty" >&2; exit 2; }
[[ -n "$KILL_AFTER" ]] || { echo "--kill-after must not be empty" >&2; exit 2; }

TEST_ID="AmbitionsUITests/AmbitionsUITests/testAMB962TodayReconstructionScreenshotMatrix"
TS="$(date -u +%Y%m%dT%H%M%SZ)"
mkdir -p "$RESULT_DIR/$BATCH" "$LOG_DIR/$BATCH" "$SUMMARY_DIR/$BATCH"

XCODE_TEST_TIMEOUT_ARGS=()
if xcodebuild -help 2>&1 | grep -q -- "-test-timeouts-enabled"; then
  XCODE_TEST_TIMEOUT_ARGS=(
    -test-timeouts-enabled YES
    -default-test-execution-time-allowance 240
    -maximum-test-execution-time-allowance 300
  )
fi

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
    -project Ambitions.xcodeproj \
    -scheme "$SCHEME" \
    -destination "$DESTINATION" \
    "${XCODE_TEST_TIMEOUT_ARGS[@]}" \
    -only-testing:"$TEST_ID" \
    -resultBundlePath "$result_bundle" \
    test
  local status=$?
  set -e

  if [[ -e "$result_bundle" ]]; then
    scripts/ambitions-xcode-result-extract.sh --result "$result_bundle" --output-dir "$extract_dir" || true
  fi

  local summary_file="$SUMMARY_DIR/$BATCH/${run_id}/summary.json"
  mkdir -p "$(dirname "$summary_file")"
  cat > "$summary_file" <<JSON
{
  "attempt": $attempt,
  "batch": "$BATCH",
  "destination": "$DESTINATION",
  "extract_dir": "$extract_dir",
  "log_file": "$log_file",
  "result_bundle": "$result_bundle",
  "status_code": $status,
  "test_id": "$TEST_ID",
  "timeout": "$TIMEOUT_DURATION",
  "kill_after": "$KILL_AFTER",
  "xcode_test_timeout_flags": "$([[ "${#XCODE_TEST_TIMEOUT_ARGS[@]}" -gt 0 ]] && echo enabled || echo unavailable)"
}
JSON

  return "$status"
}

attempt=0
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
