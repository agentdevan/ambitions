#!/usr/bin/env bash
set -Eeuo pipefail

usage() {
  cat <<'USAGE'
Usage:
  scripts/ambitions-xcode-sim-health.sh [--json] [--repair] [--erase-selected] [--no-sim]
USAGE
}

REPO_ROOT="$(git rev-parse --show-toplevel 2>/dev/null || pwd -P)"
cd "$REPO_ROOT"

JSON=0
REPAIR=0
ERASE_SELECTED=0
NO_SIM=0
while [[ "$#" -gt 0 ]]; do
  case "$1" in
    --json) JSON=1 ;;
    --repair) REPAIR=1 ;;
    --erase-selected) ERASE_SELECTED=1 ;;
    --no-sim) NO_SIM=1 ;;
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

DEVICES="$(xcrun simctl list devices available 2>/dev/null || true)"
if [[ -z "$DEVICES" ]]; then
  echo "simctl list devices unavailable" >&2
  exit 1
fi

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

select_udid=""
select_name=""

if [[ -n "${AMBITIONS_SIM_UDID:-}" ]]; then
  select_udid="${AMBITIONS_SIM_UDID}"
  select_name="$(echo "$DEVICES" | awk -v udid="$select_udid" 'index($0, udid) {line=$0; sub(/^[[:space:]]*/, "", line); marker=index(line, " ("); if (marker > 0) line=substr(line, 1, marker - 1); print line; exit}')"
elif [[ -n "${AMBITIONS_SIM_NAME:-}" ]]; then
  select_udid="$(find_sim_udid "${AMBITIONS_SIM_NAME}")"
  select_name="${AMBITIONS_SIM_NAME}"
else
  for candidate in "iPhone 17" "iPhone 16" "iPhone 15"; do
    select_udid="$(find_sim_udid "$candidate")"
    if [[ -n "$select_udid" ]]; then
      select_name="$candidate"
      break
    fi
  done
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

state="$(xcrun simctl list devices | awk -v udid="$select_udid" 'index($0,udid){
  if (index($0, "(Booted)") > 0) print "Booted";
  else if (index($0, "(Shutdown)") > 0) print "Shutdown";
  else print "Unknown";
  exit
}')"

if [[ "$ERASE_SELECTED" -eq 1 ]]; then
  xcrun simctl erase "$select_udid" >/dev/null 2>&1 || true
  state="Shutdown"
fi

if [[ "$state" != "Booted" && "$REPAIR" -eq 1 ]]; then
  xcrun simctl boot "$select_udid" >/dev/null 2>&1 || true
  state="$(xcrun simctl list devices | awk -v udid="$select_udid" 'index($0,udid){
    if (index($0, "(Booted)") > 0) print "Booted";
    else if (index($0, "(Shutdown)") > 0) print "Shutdown";
    else print "Unknown";
    exit
  }')"
fi

if [[ "$JSON" -eq 1 ]]; then
  printf '{"sim_required":true,"sim_name":"%s","udid":"%s","state":"%s","repair":%s}\n' \
    "${select_name}" "$select_udid" "$state" "$([[ "$REPAIR" -eq 1 ]] && echo true || echo false)"
else
  echo "selected_sim_name=${select_name}"
  echo "selected_sim_udid=${select_udid}"
  echo "selected_sim_state=${state}"
  if [[ "$REPAIR" -eq 1 ]]; then
    echo "repair_requested=true"
  fi
fi

if [[ "$state" != "Booted" ]]; then
  exit 22
fi

exit 0
