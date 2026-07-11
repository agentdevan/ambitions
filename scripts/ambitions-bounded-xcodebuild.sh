#!/usr/bin/env bash
set -Eeuo pipefail

REPO_ROOT="$(git rev-parse --show-toplevel 2>/dev/null || pwd -P)"
cd "$REPO_ROOT"

TIMEOUT_DURATION="15m"
KILL_AFTER="60s"
LOG_FILE=""
LANE_TOKEN=""
TEST_LAUNCH_TIMEOUT=""
MONITOR_TEMP_LOG=""
MONITOR_STATUS_FILE=""

usage() {
  cat >&2 <<'EOF'
Usage: scripts/ambitions-bounded-xcodebuild.sh [options] -- <xcodebuild args>

Options:
  --timeout <duration>     Wall-clock timeout passed to gtimeout/timeout. Default: 15m.
  --kill-after <duration>  Grace period before force kill after timeout. Default: 60s.
  --test-launch-timeout <duration>
                           Fail a test action before XCTest starts. Disabled by default.
  --log <path>             Write combined stdout/stderr to this log file.
  -h, --help               Show this help.

Examples:
  scripts/ambitions-bounded-xcodebuild.sh --timeout 1m -- -version
  scripts/ambitions-bounded-xcodebuild.sh --timeout 20m --kill-after 60s -- -project Ambitions.xcodeproj test
EOF
}

while [[ "$#" -gt 0 ]]; do
  case "$1" in
    --timeout)
      TIMEOUT_DURATION="${2:-}"
      shift 2
      ;;
    --kill-after)
      KILL_AFTER="${2:-}"
      shift 2
      ;;
    --test-launch-timeout)
      TEST_LAUNCH_TIMEOUT="${2:-}"
      shift 2
      ;;
    --log)
      LOG_FILE="${2:-}"
      shift 2
      ;;
    -h|--help)
      usage
      exit 0
      ;;
    --)
      shift
      break
      ;;
    *)
      break
      ;;
  esac
done

[[ -n "$TIMEOUT_DURATION" ]] || { echo "--timeout value must not be empty" >&2; exit 2; }
[[ -n "$KILL_AFTER" ]] || { echo "--kill-after value must not be empty" >&2; exit 2; }
[[ "$#" -gt 0 ]] || { usage; exit 2; }

XCODEBUILD_ARGS=("$@")
if [[ "${#XCODEBUILD_ARGS[@]}" -gt 0 && "${XCODEBUILD_ARGS[0]}" == "xcodebuild" ]]; then
  XCODEBUILD_ARGS=("${XCODEBUILD_ARGS[@]:1}")
fi
[[ "${#XCODEBUILD_ARGS[@]}" -gt 0 ]] || { usage; exit 2; }

TIMEOUT_TOOL=""
if command -v gtimeout >/dev/null 2>&1; then
  TIMEOUT_TOOL="$(command -v gtimeout)"
elif command -v timeout >/dev/null 2>&1; then
  TIMEOUT_TOOL="$(command -v timeout)"
fi

DESTINATION=""
RESULT_BUNDLE=""
DERIVED_DATA_PATH=""
IS_TEST_ACTION=0
for ((i = 0; i < ${#XCODEBUILD_ARGS[@]}; i++)); do
  case "${XCODEBUILD_ARGS[$i]}" in
    test|test-without-building)
      IS_TEST_ACTION=1
      ;;
    -destination)
      if (( i + 1 < ${#XCODEBUILD_ARGS[@]} )); then
        DESTINATION="${XCODEBUILD_ARGS[$((i + 1))]}"
      fi
      ;;
    -resultBundlePath)
      if (( i + 1 < ${#XCODEBUILD_ARGS[@]} )); then
        RESULT_BUNDLE="${XCODEBUILD_ARGS[$((i + 1))]}"
      fi
      ;;
    -derivedDataPath)
      if (( i + 1 < ${#XCODEBUILD_ARGS[@]} )); then
        DERIVED_DATA_PATH="${XCODEBUILD_ARGS[$((i + 1))]}"
      fi
      ;;
  esac
done

if [[ -n "$TEST_LAUNCH_TIMEOUT" && "$IS_TEST_ACTION" -ne 1 ]]; then
  echo "--test-launch-timeout requires an xcodebuild test or test-without-building action" >&2
  exit 2
fi

if [[ -n "$LOG_FILE" ]]; then
  mkdir -p "$(dirname "$LOG_FILE")"
fi

echo "ambitions-bounded-xcodebuild"
echo "timeout_tool=${TIMEOUT_TOOL:-none}"
echo "timeout=$TIMEOUT_DURATION"
echo "kill_after=$KILL_AFTER"
echo "test_launch_timeout=${TEST_LAUNCH_TIMEOUT:-disabled}"
echo "destination=${DESTINATION:-not provided}"
echo "result_bundle=${RESULT_BUNDLE:-not provided}"
echo "derived_data=${DERIVED_DATA_PATH:-not provided}"
echo "log_file=${LOG_FILE:-not provided}"
printf 'command:'
printf ' %q' xcodebuild "${XCODEBUILD_ARGS[@]}"
printf '\n'

CMD=(xcodebuild "${XCODEBUILD_ARGS[@]}")
if [[ -n "$TIMEOUT_TOOL" ]]; then
  RUN_CMD=("$TIMEOUT_TOOL" -k "$KILL_AFTER" "$TIMEOUT_DURATION" "${CMD[@]}")
else
  echo "WARNING: no gtimeout/timeout binary found; running without a wall-clock bound." >&2
  RUN_CMD=("${CMD[@]}")
fi

printf -v LANE_COMMAND '%q ' "${CMD[@]}"
LANE_TOKEN="$(python3 scripts/ambitions-xcode-lane-lock.py acquire --command "$LANE_COMMAND" --owner-pid "$$" --owner-parent-pid "$PPID")"
release_xcode_lane() {
  [[ -n "$LANE_TOKEN" ]] || return 0
  python3 scripts/ambitions-xcode-lane-lock.py release --token "$LANE_TOKEN" >/dev/null || true
  LANE_TOKEN=""
}
cleanup_bounded_runner() {
  release_xcode_lane
  [[ -z "$MONITOR_TEMP_LOG" ]] || rm -f "$MONITOR_TEMP_LOG"
  [[ -z "$MONITOR_STATUS_FILE" ]] || rm -f "$MONITOR_STATUS_FILE"
}
trap cleanup_bounded_runner EXIT

duration_seconds_ceil() {
  python3 - "$1" <<'PY'
import math
import re
import sys

match = re.fullmatch(r"\s*([0-9]+(?:\.[0-9]+)?)\s*(ms|s|m|h)?\s*", sys.argv[1])
if not match:
    raise SystemExit(2)
value = float(match.group(1))
unit = match.group(2) or "s"
multiplier = {"ms": 0.001, "s": 1.0, "m": 60.0, "h": 3600.0}[unit]
print(max(1, math.ceil(value * multiplier)))
PY
}

terminate_owned_process_tree() {
  local root_pid="$1"
  python3 - "$root_pid" <<'PY'
import os
import signal
import subprocess
import sys
import time

root = int(sys.argv[1])

def snapshot():
    output = subprocess.check_output(["ps", "-axo", "pid=,ppid="], text=True)
    children = {}
    live = set()
    for raw in output.splitlines():
        parts = raw.split()
        if len(parts) != 2:
            continue
        pid, ppid = map(int, parts)
        live.add(pid)
        children.setdefault(ppid, []).append(pid)
    return live, children

live, children = snapshot()
targets = set()
stack = [root]
while stack:
    pid = stack.pop()
    if pid in targets or pid not in live:
        continue
    targets.add(pid)
    stack.extend(children.get(pid, []))

targets.difference_update({os.getpid(), os.getppid()})
for pid in sorted(targets, reverse=True):
    try:
        os.kill(pid, signal.SIGTERM)
    except (ProcessLookupError, PermissionError):
        pass

deadline = time.monotonic() + 0.1
while time.monotonic() < deadline:
    remaining = []
    for pid in targets:
        try:
            os.kill(pid, 0)
            remaining.append(pid)
        except (ProcessLookupError, PermissionError):
            pass
    if not remaining:
        raise SystemExit(0)
    time.sleep(0.02)

for pid in sorted(targets, reverse=True):
    try:
        os.kill(pid, signal.SIGKILL)
    except (ProcessLookupError, PermissionError):
        pass
PY
}

run_with_test_launch_monitor() {
  local monitor_log="$LOG_FILE"
  local launch_timeout_seconds
  local runner_pid
  local termination_reason=""
  local detected=""
  local watch_payload=""
  local wait_status=0

  launch_timeout_seconds="$(duration_seconds_ceil "$TEST_LAUNCH_TIMEOUT")" || {
    echo "invalid --test-launch-timeout duration: $TEST_LAUNCH_TIMEOUT" >&2
    return 2
  }
  if [[ -z "$monitor_log" ]]; then
    MONITOR_TEMP_LOG="$(mktemp "${TMPDIR:-/tmp}/ambitions-xcode-launch.XXXXXX")"
    monitor_log="$MONITOR_TEMP_LOG"
  fi
  MONITOR_STATUS_FILE="$(mktemp "${TMPDIR:-/tmp}/ambitions-xcode-status.XXXXXX")"
  : > "$monitor_log"
  : > "$MONITOR_STATUS_FILE"

  set +e
  (
    set +e
    "${RUN_CMD[@]}" 2>&1 | tee "$monitor_log"
    command_status=${PIPESTATUS[0]}
    printf '%s\n' "$command_status" > "$MONITOR_STATUS_FILE"
    exit "$command_status"
  ) &
  runner_pid=$!

  watch_payload="$(python3 scripts/ambitions-xcode-failure-classifier.py \
    --log "$monitor_log" \
    --watch-test-launch \
    --completion-file "$MONITOR_STATUS_FILE" \
    --timeout-seconds "$launch_timeout_seconds" \
    --json 2>/dev/null || true)"
  detected="$(python3 -c 'import json, sys; print(json.load(sys.stdin).get("classification", "unknown"))' \
    <<<"$watch_payload" 2>/dev/null || true)"
  case "$detected" in
    simulator_launcher_failure) termination_reason="simulator_launcher_failure" ;;
    test_launch_timeout) termination_reason="test_launch_timeout" ;;
  esac

  if [[ -n "$termination_reason" ]]; then
    if [[ "$termination_reason" == "test_launch_timeout" ]]; then
      echo "XCODEBUILD_TEST_LAUNCH_TIMEOUT=1" | tee -a "$monitor_log" >&2
    else
      echo "XCODEBUILD_SIMULATOR_LAUNCH_FAILURE=1" | tee -a "$monitor_log" >&2
    fi
    terminate_owned_process_tree "$runner_pid"
  fi

  wait "$runner_pid"
  wait_status=$?

  if [[ "$termination_reason" == "test_launch_timeout" ]]; then
    return 124
  fi
  if [[ "$termination_reason" == "simulator_launcher_failure" ]]; then
    return 65
  fi
  if [[ -s "$MONITOR_STATUS_FILE" ]]; then
    wait_status="$(awk 'NF {value=$1} END {print value}' "$MONITOR_STATUS_FILE")"
  fi
  detected="$(python3 scripts/ambitions-xcode-failure-classifier.py --log "$monitor_log" --json 2>/dev/null \
    | python3 -c 'import json, sys; print(json.load(sys.stdin).get("classification", "unknown"))' 2>/dev/null || true)"
  if [[ "$detected" == "simulator_launcher_failure" ]]; then
    return 65
  fi
  return "${wait_status:-1}"
}

set +e
if [[ -n "$TEST_LAUNCH_TIMEOUT" ]]; then
  run_with_test_launch_monitor
  status=$?
elif [[ -n "$LOG_FILE" ]]; then
  "${RUN_CMD[@]}" 2>&1 | tee "$LOG_FILE"
  status=${PIPESTATUS[0]}
else
  "${RUN_CMD[@]}"
  status=$?
fi
set -e
if [[ "$status" -eq 124 && -n "$LOG_FILE" ]] \
  && grep -q "XCODEBUILD_TEST_LAUNCH_TIMEOUT=1" "$LOG_FILE" 2>/dev/null; then
  echo "TEST_LAUNCH_TIMEOUT_STATUS=124" >&2
  echo "timeout_cleanup=test_launch_owned_child_only" >&2
  exit 124
fi
if [[ -n "$TIMEOUT_TOOL" && ( "$status" -eq 124 || "$status" -eq 137 ) ]]; then
  if [[ -n "$LOG_FILE" ]] && ! grep -Eq "Test Suite|Test Case|Testing started|\\*\\* TEST" "$LOG_FILE" 2>/dev/null; then
    echo "XCODEBUILD_TIMEOUT_NO_TEST_LOG=1" | tee -a "$LOG_FILE" >&2
  fi
  echo "XCODEBUILD_TIMEOUT=1" >&2
  echo "TIMEOUT_STATUS=124" >&2
  echo "timeout_cleanup=timeout_owned_child_only" >&2
  exit 124
fi

exit "$status"
