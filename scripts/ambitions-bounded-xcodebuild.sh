#!/usr/bin/env bash
set -Eeuo pipefail

REPO_ROOT="$(git rev-parse --show-toplevel 2>/dev/null || pwd -P)"
cd "$REPO_ROOT"

TIMEOUT_DURATION="15m"
KILL_AFTER="60s"
LOG_FILE=""
QUARANTINE_ACTIONS_RUNNER="${AMBITIONS_XCODE_QUARANTINE_ACTIONS_RUNNER:-1}"
QUARANTINE_INTERVAL_SECONDS="${AMBITIONS_XCODE_QUARANTINE_ACTIONS_RUNNER_INTERVAL_SECONDS:-10}"
QUARANTINE_WATCHDOG_PID=""

usage() {
  cat >&2 <<'EOF'
Usage: scripts/ambitions-bounded-xcodebuild.sh [options] -- <xcodebuild args>

Options:
  --timeout <duration>     Wall-clock timeout passed to gtimeout/timeout. Default: 15m.
  --kill-after <duration>  Grace period before force kill after timeout. Default: 60s.
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
for ((i = 0; i < ${#XCODEBUILD_ARGS[@]}; i++)); do
  case "${XCODEBUILD_ARGS[$i]}" in
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

if [[ -n "$LOG_FILE" ]]; then
  mkdir -p "$(dirname "$LOG_FILE")"
fi

echo "ambitions-bounded-xcodebuild"
echo "timeout_tool=${TIMEOUT_TOOL:-none}"
echo "timeout=$TIMEOUT_DURATION"
echo "kill_after=$KILL_AFTER"
echo "destination=${DESTINATION:-not provided}"
echo "result_bundle=${RESULT_BUNDLE:-not provided}"
echo "derived_data=${DERIVED_DATA_PATH:-not provided}"
echo "log_file=${LOG_FILE:-not provided}"
printf 'command:'
printf ' %q' xcodebuild "${XCODEBUILD_ARGS[@]}"
printf '\n'

case "$QUARANTINE_ACTIONS_RUNNER" in
  1|true|TRUE|yes|YES) QUARANTINE_ACTIONS_RUNNER=1 ;;
  *) QUARANTINE_ACTIONS_RUNNER=0 ;;
esac

external_actions_runner_xcode_pids() {
  python3 - "$$" "$PPID" <<'PY'
import os
import re
import subprocess
import sys

self_pid = int(sys.argv[1])
parent_pid = int(sys.argv[2])
current = {self_pid, parent_pid, os.getpid(), os.getppid()}

processes: dict[int, tuple[int, str]] = {}
children: dict[int, list[int]] = {}
output = subprocess.check_output(["ps", "-axo", "pid=,ppid=,args="], text=True)
for raw in output.splitlines():
    parts = raw.strip().split(None, 2)
    if len(parts) != 3:
        continue
    try:
        pid = int(parts[0])
        ppid = int(parts[1])
    except ValueError:
        continue
    args = parts[2]
    processes[pid] = (ppid, args)
    children.setdefault(ppid, []).append(pid)

own_tree = set(current)
stack = [self_pid]
while stack:
    pid = stack.pop()
    if pid in own_tree and pid != self_pid:
        continue
    own_tree.add(pid)
    stack.extend(children.get(pid, []))

def has_matching_ancestor(pid: int, pattern: re.Pattern[str]) -> bool:
    seen: set[int] = set()
    while pid in processes and pid not in seen:
        seen.add(pid)
        ppid, args = processes[pid]
        if pattern.search(args):
            return True
        pid = ppid
    return False

xcode_pattern = re.compile(r"xcodebuild|swift-frontend|swift-driver|SWBBuildService|actool|ibtool")
ambitions_pattern = re.compile(
    r"Ambitions\.xcodeproj|/Documents/GitHub/ambitions|actions-runner/_work/ambitions/ambitions"
)
external_runner_pattern = re.compile(
    r"actions-runner/_work/(_temp/ambitions-local-runtime-proof|ambitions/ambitions)"
    r"|artifacts/strict-build-launch"
    r"|strict_build_launch"
)
runner_ancestor_pattern = re.compile(
    r"/actions-runner/bin/Runner\.(Worker|Listener)"
    r"|/actions-runner/runsvc\.sh"
    r"|scripts/ci/strict_build_launch\.sh"
)

targets = []
for pid, (_ppid, args) in processes.items():
    if pid in own_tree:
        continue
    if not xcode_pattern.search(args):
        continue
    if not ambitions_pattern.search(args):
        continue
    if external_runner_pattern.search(args) or has_matching_ancestor(pid, runner_ancestor_pattern):
        targets.append(pid)

for pid in sorted(set(targets)):
    print(pid)
PY
}

terminate_pid_trees() {
  (("$#" > 0)) || return 0
  python3 - "$@" <<'PY'
import os
import signal
import subprocess
import sys
import time

roots = {int(pid) for pid in sys.argv[1:] if pid.isdigit()}
if not roots:
    raise SystemExit(0)

def collect_tree(root_pids):
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

    seen = set()
    stack = list(root_pids)
    while stack:
        pid = stack.pop()
        if pid in seen or pid not in live:
            continue
        seen.add(pid)
        stack.extend(children.get(pid, []))
    return seen

current = {os.getpid(), os.getppid()}
targets = collect_tree(roots)
targets.difference_update(current)

for sig, delay in ((signal.SIGTERM, 2.0), (signal.SIGKILL, 0.0)):
    for pid in sorted(targets, reverse=True):
        try:
            os.kill(pid, sig)
        except (ProcessLookupError, PermissionError):
            pass
    if not delay:
        break
    time.sleep(delay)
    remaining = set()
    for pid in targets:
        result = subprocess.run(["ps", "-p", str(pid)], stdout=subprocess.DEVNULL, stderr=subprocess.DEVNULL)
        if result.returncode == 0:
            remaining.add(pid)
    targets = remaining.difference(current)
    if not targets:
        break
PY
}

quarantine_external_actions_runner_xcode() {
  local reason="$1"
  local pids=()
  while IFS= read -r pid; do
    [[ -n "$pid" ]] || continue
    pids+=("$pid")
  done < <(external_actions_runner_xcode_pids)

  ((${#pids[@]} > 0)) || return 0
  echo "actions_runner_xcode_quarantine=$reason"
  printf 'actions_runner_xcode_quarantine_pids='
  printf '%s,' "${pids[@]}"
  printf '\n'
  terminate_pid_trees "${pids[@]}"
}

start_actions_runner_quarantine_watchdog() {
  [[ "$QUARANTINE_ACTIONS_RUNNER" -eq 1 ]] || return 0
  quarantine_external_actions_runner_xcode preflight
  (
    while true; do
      sleep "$QUARANTINE_INTERVAL_SECONDS"
      quarantine_external_actions_runner_xcode watchdog
    done
  ) &
  QUARANTINE_WATCHDOG_PID="$!"
}

stop_actions_runner_quarantine_watchdog() {
  [[ -n "$QUARANTINE_WATCHDOG_PID" ]] || return 0
  kill "$QUARANTINE_WATCHDOG_PID" >/dev/null 2>&1 || true
  wait "$QUARANTINE_WATCHDOG_PID" >/dev/null 2>&1 || true
  QUARANTINE_WATCHDOG_PID=""
}

CMD=(xcodebuild "${XCODEBUILD_ARGS[@]}")
if [[ -n "$TIMEOUT_TOOL" ]]; then
  RUN_CMD=("$TIMEOUT_TOOL" -k "$KILL_AFTER" "$TIMEOUT_DURATION" "${CMD[@]}")
else
  echo "WARNING: no gtimeout/timeout binary found; running without a wall-clock bound." >&2
  RUN_CMD=("${CMD[@]}")
fi

trap stop_actions_runner_quarantine_watchdog EXIT
start_actions_runner_quarantine_watchdog

set +e
if [[ -n "$LOG_FILE" ]]; then
  "${RUN_CMD[@]}" 2>&1 | tee "$LOG_FILE"
  status=${PIPESTATUS[0]}
else
  "${RUN_CMD[@]}"
  status=$?
fi
set -e
stop_actions_runner_quarantine_watchdog

cleanup_targeted_result_bundle_processes() {
  local match_value="$RESULT_BUNDLE"
  local match_label="result_bundle"
  if [[ -z "$match_value" && -n "$DERIVED_DATA_PATH" ]]; then
    match_value="$DERIVED_DATA_PATH"
    match_label="derived_data"
  fi
  [[ -n "$match_value" ]] || return 0
  echo "timeout_cleanup=targeted_${match_label}"
  echo "timeout_cleanup_match=$match_value"

  local pids=()
  while IFS= read -r pid; do
    [[ -n "$pid" ]] || continue
    [[ "$pid" != "$$" && "$pid" != "$PPID" ]] || continue

    local command_line
    command_line="$(ps -p "$pid" -o command= 2>/dev/null || true)"
    [[ "$command_line" == *xcodebuild* || "$command_line" == *swift-frontend* || "$command_line" == *swift-driver* ]] || continue
    echo "timeout_cleanup_pid=$pid"
    pids+=("$pid")
  done < <(pgrep -f "$match_value" 2>/dev/null || true)

  ((${#pids[@]} > 0)) || return 0

  python3 - "${pids[@]}" <<'PY'
import os
import signal
import subprocess
import sys
import time

roots = {int(pid) for pid in sys.argv[1:] if pid.isdigit()}
if not roots:
    raise SystemExit(0)

def collect_tree(root_pids):
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
    seen = set()
    stack = list(root_pids)
    while stack:
        pid = stack.pop()
        if pid in seen or pid not in live:
            continue
        seen.add(pid)
        stack.extend(children.get(pid, []))
    return seen

targets = collect_tree(roots)
targets.difference_update({os.getpid(), os.getppid()})
for pid in sorted(targets, reverse=True):
    try:
        os.kill(pid, signal.SIGTERM)
    except (ProcessLookupError, PermissionError):
        pass

time.sleep(2)
remaining = set()
for pid in targets:
    result = subprocess.run(["ps", "-p", str(pid)], stdout=subprocess.DEVNULL, stderr=subprocess.DEVNULL)
    if result.returncode == 0:
        remaining.add(pid)

for pid in sorted(remaining, reverse=True):
    try:
        os.kill(pid, signal.SIGKILL)
        print(f"timeout_cleanup_force_pid={pid}")
    except (ProcessLookupError, PermissionError):
        pass
PY
}

if [[ -n "$TIMEOUT_TOOL" && ( "$status" -eq 124 || "$status" -eq 137 ) ]]; then
  if [[ -n "$LOG_FILE" ]] && ! grep -Eq "Test Suite|Test Case|Testing started|\\*\\* TEST" "$LOG_FILE" 2>/dev/null; then
    echo "XCODEBUILD_TIMEOUT_NO_TEST_LOG=1" | tee -a "$LOG_FILE" >&2
  fi
  echo "XCODEBUILD_TIMEOUT=1" >&2
  echo "TIMEOUT_STATUS=124" >&2
  echo "Process inspection guidance:" >&2
  echo "  ps aux | rg 'xcodebuild|XCTest|CoreSimulator|${RESULT_BUNDLE:-<result-bundle>}'" >&2
  echo "  pgrep -af '${RESULT_BUNDLE:-<result-bundle>}'" >&2
  cleanup_targeted_result_bundle_processes
  exit 124
fi

exit "$status"
