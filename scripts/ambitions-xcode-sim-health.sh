#!/usr/bin/env bash
set -Eeuo pipefail

usage() {
  cat <<'USAGE'
Usage:
  scripts/ambitions-xcode-sim-health.sh [--json] [--repair] [--erase-selected] [--kill-active-xcode] [--allow-active-xcode] [--no-sim] [--timeout 15s]
USAGE
}

REPO_ROOT="$(git rev-parse --show-toplevel 2>/dev/null || pwd -P)"
cd "$REPO_ROOT"

JSON=0
REPAIR=0
ERASE_SELECTED=0
NO_SIM=0
ALLOW_ACTIVE_XCODE="${AMBITIONS_SIM_HEALTH_ALLOW_ACTIVE_XCODE:-0}"
KILL_ACTIVE_XCODE=0
SIMCTL_TIMEOUT="${AMBITIONS_SIM_HEALTH_TIMEOUT:-15s}"
while [[ "$#" -gt 0 ]]; do
  case "$1" in
    --json) JSON=1 ;;
    --repair) REPAIR=1 ;;
    --erase-selected) ERASE_SELECTED=1 ;;
    --kill-active-xcode) KILL_ACTIVE_XCODE=1 ;;
    --allow-active-xcode) ALLOW_ACTIVE_XCODE=1 ;;
    --no-sim) NO_SIM=1 ;;
    --timeout)
      if [[ -z "${2:-}" ]]; then
        echo "--timeout requires a value" >&2
        exit 2
      fi
      SIMCTL_TIMEOUT="$2"
      shift
      ;;
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
  shift
done

case "$ALLOW_ACTIVE_XCODE" in
  1|true|TRUE|yes|YES) ALLOW_ACTIVE_XCODE=1 ;;
  *) ALLOW_ACTIVE_XCODE=0 ;;
esac

if (( NO_SIM == 1 )); then
  if (( JSON == 1 )); then
    printf '{"sim_required":false,"simulated":false}\n'
  fi
  exit 0
fi

if ! command -v xcrun >/dev/null 2>&1; then
  echo "tool_missing: xcrun" >&2
  exit 24
fi

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

capture_bounded() {
  local __target_var="$1"
  local duration="$2"
  shift 2
  local output
  local status

  set +e
  output="$(run_with_optional_timeout "$duration" "$@" 2>&1)"
  status=$?
  set -e
  printf -v "$__target_var" '%s' "$output"
  return "$status"
}

json_escape() {
  python3 - "$1" <<'PY'
import json
import sys
print(json.dumps(sys.argv[1])[1:-1])
PY
}

fail_health() {
  local class="$1"
  local message="$2"
  local exit_code="${3:-1}"
  if (( JSON == 1 )); then
    printf '{"sim_required":true,"status":"failed","failure_category":"%s","message":"%s","simctl_timeout":"%s"}\n' \
      "$(json_escape "$class")" "$(json_escape "$message")" "$(json_escape "$SIMCTL_TIMEOUT")"
  else
    echo "FAILURE_CLASS=$class"
    echo "sim_health_message=$message"
    echo "simctl_timeout=$SIMCTL_TIMEOUT"
  fi
  exit "$exit_code"
}

DEVICES=""
if ! capture_bounded DEVICES "$SIMCTL_TIMEOUT" xcrun simctl list devices available; then
  fail_health "simctl_unresponsive" "simctl list devices available exceeded ${SIMCTL_TIMEOUT}" 25
fi
if [[ -z "$DEVICES" ]]; then
  fail_health "simctl_unavailable" "simctl list devices available returned no output" 1
fi

ALL_DEVICES=""
if ! capture_bounded ALL_DEVICES "$SIMCTL_TIMEOUT" xcrun simctl list devices; then
  fail_health "simctl_unresponsive" "simctl list devices exceeded ${SIMCTL_TIMEOUT}" 25
fi
if [[ -z "$ALL_DEVICES" ]]; then
  fail_health "simctl_unavailable" "simctl list devices returned no output" 1
fi

booted_udids() {
  awk '/[0-9A-Fa-f-]{36}/ && /\(Booted\)/ {
    for (i = 1; i <= NF; i++) {
      value=$i;
      gsub(/[()]/, "", value);
      if (value ~ /^[0-9A-Fa-f-]{36}$/) print value
    }
  }' <<<"$ALL_DEVICES"
}

count_lines() {
  awk 'NF {count++} END {print count + 0}'
}

join_lines() {
  paste -sd, -
}

ambitions_app_pids() {
  ps -axo pid=,args= | awk '/\/Ambitions\.app\/Ambitions([[:space:]]|$)/ {print $1}'
}

xcode_process_pids() {
  ps -axo pid=,args= | awk -v self="$$" -v parent="$PPID" '
    {
      pid=$1
      line=$0
      sub(/^[[:space:]]*[0-9]+[[:space:]]+/, "", line)
    }
    pid == self || pid == parent { next }
    line ~ /awk/ { next }
    line ~ /ambitions-xcode-sim-health/ { next }
    line ~ /xcodebuild|xcodebuildmcp|strict_build_launch|ambitions-bounded-xcodebuild|swift-frontend|swift-driver|XCTest/ &&
    line ~ /Ambitions\.xcodeproj|com\.ambitions\.ios|strict-build-launch|strict_build_launch|\.codex\/DerivedData\/Ambitions|output\/DerivedData-XcodeBuildMCP|Library\/Developer\/XcodeBuildMCP\/workspaces\/ambitions|\/Documents\/GitHub\/ambitions|actions-runner\/_work\/ambitions\/ambitions/ {
      print pid
    }
  ' | sort -n -u
}

terminate_xcode_process_tree() {
  local pids=()
  while IFS= read -r pid; do
    [[ -n "$pid" ]] || continue
    pids+=("$pid")
  done < <(xcode_process_pids)

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

def pid_tree(root_pids):
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

    collected = set()
    stack = list(root_pids)
    while stack:
        pid = stack.pop()
        if pid in collected or pid not in live:
            continue
        collected.add(pid)
        stack.extend(children.get(pid, []))
    return collected

targets = pid_tree(roots)
current = {os.getpid(), os.getppid()}
targets.difference_update(current)

for sig, delay in ((signal.SIGTERM, 2.0), (signal.SIGKILL, 0.0)):
    for pid in sorted(targets, reverse=True):
        try:
            os.kill(pid, sig)
        except ProcessLookupError:
            pass
        except PermissionError:
            pass
    if delay:
        time.sleep(delay)
        targets = {pid for pid in targets if os.path.exists(f"/proc/{pid}") or subprocess.run(["ps", "-p", str(pid)], stdout=subprocess.DEVNULL, stderr=subprocess.DEVNULL).returncode == 0}
        targets.difference_update(current)
        if not targets:
            break
PY
}

find_sim_udid() {
  local needle="$1"
  local udid
  if [[ -z "$needle" ]]; then
    return 1
  fi
  udid="$(echo "$DEVICES" | awk -v needle="$needle" '
    /^[[:space:]]*-- / { next }
    /[0-9A-Fa-f-]{36}/ {
      name=$0
      sub(/^[[:space:]]*/, "", name)
      sub(/[[:space:]]*\([0-9A-Fa-f-]{36}\).*/, "", name)
      if (name != needle) next
      for (i = 1; i <= NF; i++) {
        value=$i;
        gsub(/[()]/, "", value);
        if (value ~ /^[0-9A-Fa-f-]{36}$/) { udid=value }
      }
    }
    END { if (udid != "") print udid }
  ')"
  [[ -n "$udid" ]] && { echo "$udid"; return 0; }
  return 1
}

xcodebuildmcp_default_simulator_field() {
  local field="$1"
  python3 - "$field" <<'PY'
import pathlib
import re
import sys

field = sys.argv[1]
config_path = pathlib.Path(".xcodebuildmcp/config.yaml")
if not config_path.exists():
    raise SystemExit(0)

lines = config_path.read_text(encoding="utf-8").splitlines()
profile = None
for line in lines:
    match = re.match(r"^activeSessionDefaultsProfile:\s*(.+?)\s*$", line)
    if match:
        profile = match.group(1).strip().strip("'\"")
        break
if not profile:
    raise SystemExit(0)

in_profile = False
for raw in lines:
    if re.match(rf"^  {re.escape(profile)}:\s*$", raw):
        in_profile = True
        continue
    if in_profile and re.match(r"^  [^ ].*:\s*$", raw):
        break
    if not in_profile:
        continue
    match = re.match(r"^\s{4}([^:]+):\s*(.*?)\s*$", raw)
    if match and match.group(1) == field:
        print(match.group(2).strip().strip("'\""))
        raise SystemExit(0)
PY
}

select_udid=""
select_name=""

if [[ -n "${AMBITIONS_SIM_UDID:-}" ]]; then
  select_udid="${AMBITIONS_SIM_UDID}"
  select_name="$(echo "$DEVICES" | awk -v udid="$select_udid" 'index($0, udid) {line=$0; sub(/^[[:space:]]*/, "", line); marker=index(line, " ("); if (marker > 0) line=substr(line, 1, marker - 1); print line; exit}')"
elif [[ -n "${AMBITIONS_SIM_NAME:-}" ]]; then
  select_name="${AMBITIONS_SIM_NAME}"
  mcp_default_udid="$(xcodebuildmcp_default_simulator_field simulatorId || true)"
  mcp_default_name="$(xcodebuildmcp_default_simulator_field simulatorName || true)"
  if [[ "$mcp_default_name" == "$select_name" && -n "$mcp_default_udid" ]] && grep -q "$mcp_default_udid" <<<"$DEVICES"; then
    select_udid="$mcp_default_udid"
  else
    select_udid="$(find_sim_udid "${AMBITIONS_SIM_NAME}")"
  fi
else
  mcp_default_udid="$(xcodebuildmcp_default_simulator_field simulatorId || true)"
  if [[ -n "$mcp_default_udid" ]] && grep -q "$mcp_default_udid" <<<"$DEVICES"; then
    select_udid="$mcp_default_udid"
    select_name="$(echo "$DEVICES" | awk -v udid="$select_udid" 'index($0, udid) {line=$0; sub(/^[[:space:]]*/, "", line); marker=index(line, " ("); if (marker > 0) line=substr(line, 1, marker - 1); print line; exit}')"
  fi

  if [[ -z "$select_udid" ]]; then
    mcp_default_name="$(xcodebuildmcp_default_simulator_field simulatorName || true)"
    if [[ -n "$mcp_default_name" ]]; then
      select_udid="$(find_sim_udid "$mcp_default_name")"
      select_name="$mcp_default_name"
    fi
  fi

  if [[ -z "$select_udid" ]]; then
    for candidate in "iPhone 17 Pro Max" "iPhone 17 Pro" "iPhone 17" "iPhone 16" "iPhone 15"; do
      select_udid="$(find_sim_udid "$candidate")"
      if [[ -n "$select_udid" ]]; then
        select_name="$candidate"
        break
      fi
    done
  fi
fi

if [[ -z "$select_udid" ]]; then
  select_udid="$(echo "$DEVICES" | awk '/iPhone/ && /[0-9A-Fa-f-]{36}/ {
      for (i = 1; i <= NF; i++) {
        value=$i;
        gsub(/[()]/, "", value);
        if (value ~ /^[0-9A-Fa-f-]{36}$/) {print value; exit}
      }
    }')"
  select_name="$(echo "$DEVICES" | awk -v udid="$select_udid" 'index($0, udid) {line=$0; sub(/^[[:space:]]*/, "", line); marker=index(line, " ("); if (marker > 0) line=substr(line, 1, marker - 1); print line; exit}')"
fi

if [[ -z "$select_udid" ]]; then
  echo "no available simulator found" >&2
  exit 2
fi

state="$(awk -v udid="$select_udid" 'index($0,udid){
  if (index($0, "(Booted)") > 0) print "Booted";
  else if (index($0, "(Shutdown)") > 0) print "Shutdown";
  else print "Unknown";
  exit
}' <<<"$ALL_DEVICES")"

booted_before="$(booted_udids | join_lines)"
booted_count_before="$(printf '%s\n' "$booted_before" | tr ',' '\n' | count_lines)"
app_pids_before="$(ambitions_app_pids | join_lines)"
app_pid_count_before="$(printf '%s\n' "$app_pids_before" | tr ',' '\n' | count_lines)"
xcode_pids_before="$(xcode_process_pids | join_lines)"
xcode_process_count_before="$(printf '%s\n' "$xcode_pids_before" | tr ',' '\n' | count_lines)"

if [[ "$REPAIR" -eq 1 ]]; then
  while IFS= read -r booted_udid; do
    [[ -n "$booted_udid" ]] || continue
    xcrun simctl terminate "$booted_udid" com.ambitions.ios >/dev/null 2>&1 || true
  done < <(printf '%s\n' "$booted_before" | tr ',' '\n')

  while IFS= read -r booted_udid; do
    [[ -n "$booted_udid" ]] || continue
    if [[ "$booted_udid" != "$select_udid" ]]; then
      xcrun simctl shutdown "$booted_udid" >/dev/null 2>&1 || true
    fi
  done < <(printf '%s\n' "$booted_before" | tr ',' '\n')
fi

if [[ "$ERASE_SELECTED" -eq 1 ]]; then
  xcrun simctl erase "$select_udid" >/dev/null 2>&1 || true
  state="Shutdown"
fi

if [[ "$KILL_ACTIVE_XCODE" -eq 1 ]]; then
  terminate_xcode_process_tree
fi

if [[ "$state" != "Booted" && "$REPAIR" -eq 1 ]]; then
  xcrun simctl boot "$select_udid" >/dev/null 2>&1 || true
fi

if [[ "$REPAIR" -eq 1 || "$ERASE_SELECTED" -eq 1 ]]; then
  if ! capture_bounded ALL_DEVICES "$SIMCTL_TIMEOUT" xcrun simctl list devices; then
    fail_health "simctl_unresponsive" "post-repair simctl list devices exceeded ${SIMCTL_TIMEOUT}" 25
  fi
  state="$(awk -v udid="$select_udid" 'index($0,udid){
    if (index($0, "(Booted)") > 0) print "Booted";
    else if (index($0, "(Shutdown)") > 0) print "Shutdown";
    else print "Unknown";
    exit
  }' <<<"$ALL_DEVICES")"
fi

booted_after="$(booted_udids | join_lines)"
booted_count_after="$(printf '%s\n' "$booted_after" | tr ',' '\n' | count_lines)"
app_pids_after="$(ambitions_app_pids | join_lines)"
app_pid_count_after="$(printf '%s\n' "$app_pids_after" | tr ',' '\n' | count_lines)"
xcode_pids_after="$(xcode_process_pids | join_lines)"
xcode_process_count_after="$(printf '%s\n' "$xcode_pids_after" | tr ',' '\n' | count_lines)"

health_status="passed"
failure_category="passed"
xcode_process_blocking=false
if [[ "$state" != "Booted" ]]; then
  health_status="failed"
  failure_category="simulator_not_booted"
elif [[ "$xcode_process_count_after" -gt 0 && "$ALLOW_ACTIVE_XCODE" -ne 1 ]]; then
  health_status="failed"
  failure_category="xcode_process_active"
  xcode_process_blocking=true
fi

if [[ "$JSON" -eq 1 ]]; then
  printf '{"sim_required":true,"status":"%s","failure_category":"%s","sim_name":"%s","udid":"%s","state":"%s","repair":%s,"erase_selected":%s,"allow_active_xcode":%s,"kill_active_xcode":%s,"xcode_process_blocking":%s,"simctl_timeout":"%s","booted_simulator_count":%s,"booted_simulator_count_before":%s,"booted_udids":"%s","booted_udids_before":"%s","ambitions_app_pid_count":%s,"ambitions_app_pid_count_before":%s,"ambitions_app_pids":"%s","ambitions_app_pids_before":"%s","xcode_process_count":%s,"xcode_process_count_before":%s,"xcode_process_pids":"%s","xcode_process_pids_before":"%s"}\n' \
    "$health_status" \
    "$failure_category" \
    "$(json_escape "$select_name")" \
    "$(json_escape "$select_udid")" \
    "$(json_escape "$state")" \
    "$([[ "$REPAIR" -eq 1 ]] && echo true || echo false)" \
    "$([[ "$ERASE_SELECTED" -eq 1 ]] && echo true || echo false)" \
    "$([[ "$ALLOW_ACTIVE_XCODE" -eq 1 ]] && echo true || echo false)" \
    "$([[ "$KILL_ACTIVE_XCODE" -eq 1 ]] && echo true || echo false)" \
    "$xcode_process_blocking" \
    "$(json_escape "$SIMCTL_TIMEOUT")" \
    "$booted_count_after" \
    "$booted_count_before" \
    "$(json_escape "$booted_after")" \
    "$(json_escape "$booted_before")" \
    "$app_pid_count_after" \
    "$app_pid_count_before" \
    "$(json_escape "$app_pids_after")" \
    "$(json_escape "$app_pids_before")" \
    "$xcode_process_count_after" \
    "$xcode_process_count_before" \
    "$(json_escape "$xcode_pids_after")" \
    "$(json_escape "$xcode_pids_before")"
else
  echo "selected_sim_name=${select_name}"
  echo "selected_sim_udid=${select_udid}"
  echo "selected_sim_state=${state}"
  echo "simctl_timeout=${SIMCTL_TIMEOUT}"
  echo "booted_simulator_count=${booted_count_after}"
  echo "booted_simulator_count_before=${booted_count_before}"
  echo "booted_simulator_udids=${booted_after}"
  echo "booted_simulator_udids_before=${booted_before}"
  echo "ambitions_app_pid_count=${app_pid_count_after}"
  echo "ambitions_app_pid_count_before=${app_pid_count_before}"
  echo "ambitions_app_pids=${app_pids_after}"
  echo "ambitions_app_pids_before=${app_pids_before}"
  echo "xcode_process_count=${xcode_process_count_after}"
  echo "xcode_process_count_before=${xcode_process_count_before}"
  echo "xcode_process_pids=${xcode_pids_after}"
  echo "xcode_process_pids_before=${xcode_pids_before}"
  echo "xcode_process_blocking=${xcode_process_blocking}"
  echo "allow_active_xcode=$([[ "$ALLOW_ACTIVE_XCODE" -eq 1 ]] && echo true || echo false)"
  echo "kill_active_xcode=$([[ "$KILL_ACTIVE_XCODE" -eq 1 ]] && echo true || echo false)"
  if [[ "$REPAIR" -eq 1 ]]; then
    echo "repair_requested=true"
  fi
fi

if [[ "$state" != "Booted" ]]; then
  exit 22
fi

if [[ "$xcode_process_blocking" == "true" ]]; then
  exit 25
fi

exit 0
