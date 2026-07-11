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
select_udid=""
select_name=""
selection_source="unselected"
exact_name_match_count=0
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

reset_simctl_transport_for_retry() {
  pkill -TERM -f 'xcrun simctl' >/dev/null 2>&1 || true
  pkill -TERM -f '/usr/bin/simctl' >/dev/null 2>&1 || true
  killall -9 com.apple.CoreSimulator.CoreSimulatorService >/dev/null 2>&1 || true
  killall -9 SimulatorTrampoline >/dev/null 2>&1 || true
  killall -9 SimLaunchHost.x86 >/dev/null 2>&1 || true
  killall -9 CoreSimulatorBridge >/dev/null 2>&1 || true
  sleep 3
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
    printf '{"sim_required":true,"status":"failed","failure_category":"%s","message":"%s","sim_name":"%s","udid":"%s","selection_source":"%s","exact_name_match_count":%s,"simctl_timeout":"%s"}\n' \
      "$(json_escape "$class")" \
      "$(json_escape "$message")" \
      "$(json_escape "$select_name")" \
      "$(json_escape "$select_udid")" \
      "$(json_escape "$selection_source")" \
      "$exact_name_match_count" \
      "$(json_escape "$SIMCTL_TIMEOUT")"
  else
    echo "FAILURE_CLASS=$class"
    echo "sim_health_message=$message"
    echo "selected_sim_name=$select_name"
    echo "selected_sim_udid=$select_udid"
    echo "selection_source=$selection_source"
    echo "exact_name_match_count=$exact_name_match_count"
    echo "simctl_timeout=$SIMCTL_TIMEOUT"
  fi
  exit "$exit_code"
}

ALL_DEVICES=""
if ! capture_bounded ALL_DEVICES "$SIMCTL_TIMEOUT" xcrun simctl list devices; then
  if (( REPAIR == 1 )); then
    reset_simctl_transport_for_retry
    if capture_bounded ALL_DEVICES "$SIMCTL_TIMEOUT" xcrun simctl list devices; then
      :
    else
      fail_health "simctl_unresponsive" "simctl list devices exceeded ${SIMCTL_TIMEOUT} after transport reset" 25
    fi
  else
    fail_health "simctl_unresponsive" "simctl list devices exceeded ${SIMCTL_TIMEOUT}" 25
  fi
fi
if [[ -z "$ALL_DEVICES" ]]; then
  fail_health "simctl_unavailable" "simctl list devices returned no output" 1
fi
DEVICES="$ALL_DEVICES"

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

available_device_rows() {
  python3 - "$DEVICES" <<'PY'
import re
import sys

pattern = re.compile(r"^\s*(.*?)\s+\(([0-9A-Fa-f-]{36})\)\s+\(([^)]+)\)\s*$")
for raw in sys.argv[1].splitlines():
    match = pattern.match(raw)
    if match:
        print("\t".join(match.groups()))
PY
}

AVAILABLE_DEVICE_ROWS="$(available_device_rows)"

device_name_for_udid() {
  local needle="$1"
  awk -F '\t' -v needle="$needle" '$2 == needle {print $1; exit}' <<<"$AVAILABLE_DEVICE_ROWS"
}

available_udid_exists() {
  local needle="$1"
  awk -F '\t' -v needle="$needle" '$2 == needle {found=1} END {exit(found ? 0 : 1)}' <<<"$AVAILABLE_DEVICE_ROWS"
}

exact_udids_for_name() {
  local needle="$1"
  awk -F '\t' -v needle="$needle" '$1 == needle {print $2}' <<<"$AVAILABLE_DEVICE_ROWS"
}

exact_count_for_name() {
  local needle="$1"
  exact_udids_for_name "$needle" | count_lines
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

mcp_default_udid="$(xcodebuildmcp_default_simulator_field simulatorId || true)"
mcp_default_name="$(xcodebuildmcp_default_simulator_field simulatorName || true)"

select_unique_exact_name() {
  local requested_name="$1"
  local source="$2"
  local matches

  select_name="$requested_name"
  selection_source="$source"
  matches="$(exact_udids_for_name "$requested_name")"
  exact_name_match_count="$(printf '%s\n' "$matches" | count_lines)"

  if [[ "$exact_name_match_count" -eq 0 ]]; then
    fail_health "simulator_not_available" "no available simulator exactly named ${requested_name}" 2
  fi
  if [[ "$exact_name_match_count" -gt 1 ]]; then
    fail_health "simulator_name_ambiguous" "${exact_name_match_count} available simulators are exactly named ${requested_name}; provide AMBITIONS_SIM_UDID or a valid MCP simulatorId" 2
  fi

  select_udid="$(printf '%s\n' "$matches" | awk 'NF {print; exit}')"
}

if [[ -n "${AMBITIONS_SIM_UDID:-}" ]]; then
  select_udid="${AMBITIONS_SIM_UDID}"
  selection_source="environment_udid"
  if ! available_udid_exists "$select_udid"; then
    fail_health "simulator_not_available" "AMBITIONS_SIM_UDID ${select_udid} is not an available simulator" 2
  fi
  select_name="$(device_name_for_udid "$select_udid")"
  exact_name_match_count="$(exact_count_for_name "$select_name")"
elif [[ -n "${AMBITIONS_SIM_NAME:-}" ]]; then
  select_name="${AMBITIONS_SIM_NAME}"
  selection_source="environment_name"
  if [[ -n "$mcp_default_udid" ]] \
    && [[ "$mcp_default_name" == "$select_name" ]] \
    && available_udid_exists "$mcp_default_udid" \
    && [[ "$(device_name_for_udid "$mcp_default_udid")" == "$select_name" ]]; then
    select_udid="$mcp_default_udid"
    selection_source="mcp_profile_udid"
    exact_name_match_count="$(exact_count_for_name "$select_name")"
  else
    select_unique_exact_name "$select_name" "environment_name"
  fi
elif [[ -n "$mcp_default_udid" ]] && available_udid_exists "$mcp_default_udid"; then
  select_udid="$mcp_default_udid"
  select_name="$(device_name_for_udid "$select_udid")"
  selection_source="mcp_profile_udid"
  exact_name_match_count="$(exact_count_for_name "$select_name")"
elif [[ -n "$mcp_default_name" ]]; then
  select_unique_exact_name "$mcp_default_name" "mcp_profile_name"
else
  for candidate in "iPhone 17 Pro Max" "iPhone 17 Pro" "iPhone 17" "iPhone 16" "iPhone 15"; do
    candidate_count="$(exact_count_for_name "$candidate")"
    if [[ "$candidate_count" -eq 0 ]]; then
      continue
    fi
    select_unique_exact_name "$candidate" "fallback_name"
    break
  done
fi

if [[ -z "$select_udid" ]]; then
  selection_source="fallback_name"
  fail_health "simulator_not_available" "no supported available iPhone simulator found" 2
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

boot_output=""
if [[ "$state" != "Booted" && "$REPAIR" -eq 1 ]]; then
  capture_bounded boot_output "$SIMCTL_TIMEOUT" xcrun simctl boot "$select_udid" || true
fi

if [[ "$REPAIR" -eq 1 ]]; then
  bootstatus_output=""
  if ! capture_bounded bootstatus_output "$SIMCTL_TIMEOUT" xcrun simctl bootstatus "$select_udid" -b; then
    fail_health "simulator_boot_failure" "simctl bootstatus -b failed for ${select_udid}: ${bootstatus_output}${boot_output:+; boot: ${boot_output}}" 22
  fi
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
  printf '{"sim_required":true,"status":"%s","failure_category":"%s","sim_name":"%s","udid":"%s","selection_source":"%s","exact_name_match_count":%s,"state":"%s","repair":%s,"erase_selected":%s,"allow_active_xcode":%s,"kill_active_xcode":%s,"xcode_process_blocking":%s,"simctl_timeout":"%s","booted_simulator_count":%s,"booted_simulator_count_before":%s,"booted_udids":"%s","booted_udids_before":"%s","ambitions_app_pid_count":%s,"ambitions_app_pid_count_before":%s,"ambitions_app_pids":"%s","ambitions_app_pids_before":"%s","xcode_process_count":%s,"xcode_process_count_before":%s,"xcode_process_pids":"%s","xcode_process_pids_before":"%s"}\n' \
    "$health_status" \
    "$failure_category" \
    "$(json_escape "$select_name")" \
    "$(json_escape "$select_udid")" \
    "$(json_escape "$selection_source")" \
    "$exact_name_match_count" \
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
  echo "selection_source=${selection_source}"
  echo "exact_name_match_count=${exact_name_match_count}"
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
