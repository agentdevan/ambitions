#!/usr/bin/env bash
set -Eeuo pipefail

REPO_ROOT="$(git rev-parse --show-toplevel 2>/dev/null || pwd -P)"
cd "$REPO_ROOT"

BATCH=""
SCHEME="Ambitions"
RESULT_DIR=".codex/xcode-results"
LOG_DIR=".codex/xcode-logs"
SUMMARY_DIR=".codex/xcode-summaries"
TIMEOUT_DURATION="30m"
KILL_AFTER="60s"

while [[ "$#" -gt 0 ]]; do
  case "$1" in
    --batch) BATCH="${2:-}"; shift 2 ;;
    --scheme) SCHEME="${2:-$SCHEME}"; shift 2 ;;
    --results-dir) RESULT_DIR="${2:-$RESULT_DIR}"; shift 2 ;;
    --logs-dir) LOG_DIR="${2:-$LOG_DIR}"; shift 2 ;;
    --summaries-dir) SUMMARY_DIR="${2:-$SUMMARY_DIR}"; shift 2 ;;
    --timeout) TIMEOUT_DURATION="${2:-$TIMEOUT_DURATION}"; shift 2 ;;
    --kill-after) KILL_AFTER="${2:-$KILL_AFTER}"; shift 2 ;;
    -h|--help)
      echo "Usage: scripts/ambitions-xcode-build-for-testing.sh --batch <BATCH> [--scheme Ambitions|AmbitionsUnitTests|AmbitionsUITests] [--timeout 30m] [--kill-after 60s]" >&2
      exit 0
      ;;
    *)
      echo "unsupported arg: $1" >&2
      exit 1
      ;;
  esac
done

[[ -n "$BATCH" ]] || { echo "--batch is required" >&2; exit 1; }

mkdir -p "$RESULT_DIR/$BATCH" "$LOG_DIR/$BATCH" "$SUMMARY_DIR/$BATCH"
TS="$(date -u +%Y%m%dT%H%M%SZ)"
RUN_ID="$TS-bft-$$-${RANDOM:-0}"
RESULT_BUNDLE="$RESULT_DIR/$BATCH/$RUN_ID/build-for-testing.xcresult"
LOG_FILE="$LOG_DIR/$BATCH/$RUN_ID/build-for-testing.log"
SUMMARY_FILE="$SUMMARY_DIR/$BATCH/$RUN_ID/build-for-testing-summary.json"
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

write_sim_health_failure_summary() {
  local failure_class="$1"
  local health_payload="$2"
  local exit_code="${3:-22}"
  local selected_udid selected_name selected_state booted_count app_pid_count xcode_process_count

  selected_udid="$(json_field udid "$health_payload")"
  selected_name="$(json_field sim_name "$health_payload")"
  selected_state="$(json_field state "$health_payload")"
  booted_count="$(json_field booted_simulator_count "$health_payload")"
  app_pid_count="$(json_field ambitions_app_pid_count "$health_payload")"
  xcode_process_count="$(json_field xcode_process_count "$health_payload")"
  [[ -n "$booted_count" ]] || booted_count=0
  [[ -n "$app_pid_count" ]] || app_pid_count=0
  [[ -n "$xcode_process_count" ]] || xcode_process_count=0

  cat > "$SUMMARY_FILE" <<JSON
{
  "batch": "$BATCH",
  "lane": "build-for-testing",
  "scheme": "$SCHEME",
  "status": "failed",
  "failure_category": "$failure_class",
  "duration_seconds": 0,
  "result_bundle": "$RESULT_BUNDLE",
  "log_file": "$LOG_FILE",
  "timestamp_utc": "$TS",
  "run_id": "$RUN_ID",
  "reason": "simulator health unavailable",
  "selected_sim_name": "$selected_name",
  "selected_sim_udid": "$selected_udid",
  "selected_sim_state": "$selected_state",
  "booted_simulator_count": $booted_count,
  "ambitions_app_pid_count": $app_pid_count,
  "xcode_process_count": $xcode_process_count,
  "claim_boundary": "simulator preflight failure only; no build-for-testing proof produced"
}
JSON
  echo "FAILURE_CLASS=$failure_class"
  echo "DURATION_SECONDS=0"
  echo "SIM_HEALTH_STATUS=failed"
  echo "SIM_HEALTH_SUMMARY=$SUMMARY_FILE"
  exit "$exit_code"
}

sim_json=""
set +e
sim_json="$(scripts/ambitions-xcode-sim-health.sh --json)"
sim_status=$?
set -e
sim_failure="$(json_field failure_category "$sim_json")"
[[ -n "$sim_failure" ]] || sim_failure="simulator_health_unavailable"
if [[ "$sim_status" -ne 0 ]]; then
  write_sim_health_failure_summary "$sim_failure" "$sim_json" "$sim_status"
fi

sim_udid="$(json_field udid "$sim_json")"
sim_state="$(json_field state "$sim_json")"
if [[ -z "$sim_udid" || "$sim_state" != "Booted" ]]; then
  write_sim_health_failure_summary "simulator_not_booted" "$sim_json" 22
fi

SIM_DEST="platform=iOS Simulator,id=${sim_udid}"

need_output="$(scripts/ambitions-xcodegen-needed.sh || true)"
need_flag="$(awk -F= '/^XCODEGEN_NEEDED=/{print $2}' <<<"$need_output")"
need_reason="$(awk -F= '/^REASON=/{print $2}' <<<"$need_output")"

if [[ "$need_flag" == "1" ]]; then
  if ! command -v xcodegen >/dev/null 2>&1; then
    python3 - "$SUMMARY_FILE" "$BATCH" "$TS" "$RUN_ID" "$need_reason" <<'PY'
import json
import sys
from pathlib import Path

path, batch, timestamp, run_id, reason = sys.argv[1:]
payload = {
    "batch": batch,
    "lane": "build-for-testing",
    "status": "failed",
    "failure_category": "tool_missing",
    "timestamp_utc": timestamp,
    "run_id": run_id,
    "reason": reason,
}
Path(path).write_text(json.dumps(payload, indent=2, sort_keys=True) + "\n", encoding="utf-8")
PY
    echo "FAILURE_CLASS=tool_missing"
    exit 24
  fi
  xcodegen generate >/dev/null
fi

BUILD_CMD=(
  xcodebuild
  -project Ambitions.xcodeproj
  -scheme "$SCHEME"
  -sdk iphonesimulator
  -destination "$SIM_DEST"
  -derivedDataPath "$DERIVED_DATA"
  build-for-testing
  CODE_SIGNING_ALLOWED=NO
  CODE_SIGNING_REQUIRED=NO
  COMPILER_INDEX_STORE_ENABLE=NO
  ONLY_ACTIVE_ARCH=YES
  -resultBundlePath "$RESULT_BUNDLE"
)
BOUNDED_BUILD_CMD=(scripts/ambitions-bounded-xcodebuild.sh --timeout "$TIMEOUT_DURATION" --kill-after "$KILL_AFTER" --log "$LOG_FILE" -- "${BUILD_CMD[@]}")

run_start="$(python3 - <<'PY'
import time
print(time.time())
PY
)"
set +e
if command -v xcbeautify >/dev/null 2>&1; then
  "${BOUNDED_BUILD_CMD[@]}" 2>&1 | xcbeautify
  status=${PIPESTATUS[0]}
else
  "${BOUNDED_BUILD_CMD[@]}"
  status=$?
fi
set -e
duration_seconds="$(python3 - "$run_start" <<'PY'
import sys
import time
print(round(time.time() - float(sys.argv[1]), 3))
PY
)"

if command -v scripts/ambitions-xcode-result-extract.sh >/dev/null 2>&1; then
  scripts/ambitions-xcode-result-extract.sh --result "$RESULT_BUNDLE" --output-dir "$SUMMARY_DIR/$BATCH/$TS/extract" || true
fi

classification="passed"
if [[ "$status" -eq 0 ]]; then
  classification="passed"
elif [[ "$status" -eq 124 ]]; then
  detected="$(python3 scripts/ambitions-xcode-failure-classifier.py --log "$LOG_FILE" --json | python3 -c 'import sys, json; print(json.load(sys.stdin).get("classification","unknown"))' )"
  if [[ "$detected" != "unknown" ]]; then
    classification="$detected"
  else
    classification="timeout"
  fi
elif [[ -f "$LOG_FILE" ]]; then
  classification="$(python3 scripts/ambitions-xcode-failure-classifier.py --log "$LOG_FILE" --json | python3 -c 'import sys, json; print(json.load(sys.stdin).get("classification","unknown"))' )"
fi

if [[ "$status" -ne 0 && -e "$RESULT_BUNDLE" && ! -f "$RESULT_BUNDLE/Info.plist" && "$classification" == "unknown" ]]; then
  classification="corrupt_xcresult"
fi

cat > "$SUMMARY_FILE" <<JSON
{
  "batch": "$BATCH",
  "lane": "build-for-testing",
  "scheme": "$SCHEME",
  "status": "$([ "$status" -eq 0 ] && echo passed || echo failed)",
  "failure_category": "$classification",
  "duration_seconds": $duration_seconds,
  "result_bundle": "$RESULT_BUNDLE",
  "log_file": "$LOG_FILE",
  "timestamp_utc": "$TS",
  "run_id": "$RUN_ID",
  "reason": "$need_reason",
  "sim_destination": "$SIM_DEST",
  "claim_boundary": "build-for-testing proof only; not UI, visual, accessibility, device, TestFlight, App Store, or release proof"
}
JSON

echo "FAILURE_CLASS=$classification"
echo "DURATION_SECONDS=$duration_seconds"
exit "$status"
