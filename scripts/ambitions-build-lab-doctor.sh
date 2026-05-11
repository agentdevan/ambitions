#!/usr/bin/env bash
set -Eeuo pipefail

usage() {
  cat <<'USAGE'
Usage:
  scripts/ambitions-build-lab-doctor.sh
  scripts/ambitions-build-lab-doctor.sh --json
  scripts/ambitions-build-lab-doctor.sh --strict
USAGE
}

REPO_ROOT="$(git rev-parse --show-toplevel 2>/dev/null || pwd -P)"
cd "$REPO_ROOT"

STRICT=0
FORMAT="text"
while [[ "$#" -gt 0 ]]; do
  case "$1" in
    --json) FORMAT="json" ;;
    --strict) STRICT=1 ;;
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

xcode_path="$(xcode-select -p 2>/dev/null || true)"
[[ -z "$xcode_path" ]] && xcode_path="(not set)"

xcode_version_line="$(xcodebuild -version 2>/dev/null | head -n 1 || true)"
[[ -z "$xcode_version_line" ]] && xcode_version_line="(missing xcodebuild)"
active_xcode_version="$(awk 'NR==1 {print $2}' <<<"$xcode_version_line")"
[[ -z "$active_xcode_version" ]] && active_xcode_version="(unknown)"

xcode_build="$(command -v xcodebuild >/dev/null 2>&1 && echo true || echo false)"
xcodegen_tool="$(command -v xcodegen >/dev/null 2>&1 && echo true || echo false)"
xcbeautify_tool="$(command -v xcbeautify >/dev/null 2>&1 && echo true || echo false)"
xcparse_tool="$(command -v xcparse >/dev/null 2>&1 && echo true || echo false)"
tuist_tool="$(command -v tuist >/dev/null 2>&1 && echo true || echo false)"
yq_tool="$(command -v yq >/dev/null 2>&1 && echo true || echo false)"
jq_tool="$(command -v jq >/dev/null 2>&1 && echo true || echo false)"
watchman_tool="$(command -v watchman >/dev/null 2>&1 && echo true || echo false)"

pinned_xcode="(unknown)"
if [[ -f .xcode-version ]]; then
  pinned_xcode="$(tr -d '[:space:]' < .xcode-version)"
fi

version_status="ok"
if [[ "$xcode_version_line" == "(missing xcodebuild)" ]]; then
  version_status="missing_xcodebuild"
elif [[ "$xcode_build" == "false" ]]; then
  version_status="missing_xcodebuild"
elif [[ "$pinned_xcode" != "(unknown)" && -n "$pinned_xcode" && "$active_xcode_version" != "$pinned_xcode" ]]; then
  version_status="mismatch"
fi

sim_selector="${AMBITIONS_SIM_UDID:-${AMBITIONS_SIM_NAME:-auto-detect}}"
sim_health="{}"
if [[ "$xcode_build" == "true" ]] && command -v scripts/ambitions-xcode-sim-health.sh >/dev/null 2>&1; then
  sim_health="$(scripts/ambitions-xcode-sim-health.sh --json --no-sim 2>/dev/null || true)"
fi

if [[ -x scripts/ambitions-xcodegen-needed.sh ]]; then
  need_output="$(scripts/ambitions-xcodegen-needed.sh || true)"
else
  need_output=$'XCODEGEN_NEEDED=unknown\nREASON=doctor unable to run xcodegen-needed'
fi
xcodegen_needed="$(awk -F= '/^XCODEGEN_NEEDED=/{print $2}' <<<"$need_output")"
xcodegen_reason="$(awk -F= '/^REASON=/{print $2}' <<<"$need_output")"

recommended_lane="none"
case "$xcodegen_needed" in
  1) recommended_lane="build-for-testing" ;;
  0|unknown|"") recommended_lane="focused-test" ;;
  *) recommended_lane="unknown" ;;
esac

missing_required=()
missing_optional=()
[[ "$xcode_build" == "false" ]] && missing_required+=(xcodebuild)
[[ "$xcodegen_tool" == "false" ]] && missing_required+=(xcodegen)
[[ "$xcbeautify_tool" == "false" ]] && missing_optional+=(xcbeautify)
[[ "$xcparse_tool" == "false" ]] && missing_optional+=(xcparse)
[[ "$yq_tool" == "false" ]] && missing_optional+=(yq)
[[ "$jq_tool" == "false" ]] && missing_optional+=(jq)
[[ "$watchman_tool" == "false" ]] && missing_optional+=(watchman)

derived_data=".codex/DerivedData/Ambitions"
result_root=".codex/xcode-results"
log_root=".codex/xcode-logs"
summary_root=".codex/xcode-summaries"

if [[ "$FORMAT" == "json" ]]; then
  DR_REQUIRED_TOOL_JSON='{"xcodebuild":'"$xcode_build"',"xcodegen":'"$xcodegen_tool"',"xcbeautify":'"$xcbeautify_tool"',"xcparse":'"$xcparse_tool"',"tuist":'"$tuist_tool"',"yq":'"$yq_tool"',"jq":'"$jq_tool"',"watchman":'"$watchman_tool"'}'
  DR_SIM_HEALTH_JSON="$sim_health"
  DR_MISSING_REQUIRED_JSON='['
  first=1
  for item in "${missing_required[@]}"; do
    if [[ "$first" -eq 0 ]]; then
      DR_MISSING_REQUIRED_JSON+=","
    fi
    DR_MISSING_REQUIRED_JSON+="\"$item\""
    first=0
  done
  DR_MISSING_REQUIRED_JSON+=']'
  DR_MISSING_OPTIONAL_JSON='['
  first=1
  for item in "${missing_optional[@]}"; do
    if [[ "$first" -eq 0 ]]; then
      DR_MISSING_OPTIONAL_JSON+=","
    fi
    DR_MISSING_OPTIONAL_JSON+="\"$item\""
    first=0
  done
  DR_MISSING_OPTIONAL_JSON+=']'

  DR_MISSING_REQUIRED="$DR_MISSING_REQUIRED_JSON"
  DR_MISSING_OPTIONAL="$DR_MISSING_OPTIONAL_JSON"
  DR_SIM_SELECTOR="$sim_selector"
  DR_XCODE_PATH="$xcode_path"
  DR_XCODE_VERSION_LINE="$xcode_version_line"
  DR_PINNED_XCODE="$pinned_xcode"
  DR_VERSION_STATUS="$version_status"
  DR_XCODEGEN_NEEDED="$xcodegen_needed"
  DR_XCODEGEN_REASON="$xcodegen_reason"
  DR_RECOMMENDED_LANE="$recommended_lane"
  DR_ACTIVE_XCODE_VERSION="$active_xcode_version"

  DR_SIM_HEALTH="$DR_SIM_HEALTH_JSON"
  python3 - <<PY
import json
import os

sim_health = os.environ.get("DR_SIM_HEALTH", "{}")
  payload = {
  "xcode_path": os.environ.get("DR_XCODE_PATH", ""),
  "xcode_version": os.environ.get("DR_XCODE_VERSION_LINE", ""),
  "active_xcode_version": os.environ.get("DR_ACTIVE_XCODE_VERSION", ""),
  "pinned_xcode_version": os.environ.get("DR_PINNED_XCODE", ""),
  "version_status": os.environ.get("DR_VERSION_STATUS", ""),
  "required_tools": json.loads(os.environ.get("DR_REQUIRED_TOOL_JSON", "{}")),
  "sim_selector": os.environ.get("DR_SIM_SELECTOR", ""),
  "sim_health": json.loads(sim_health),
  "derived_data_path": ".codex/DerivedData/Ambitions",
  "result_root": ".codex/xcode-results",
  "log_root": ".codex/xcode-logs",
  "summary_root": ".codex/xcode-summaries",
  "xcodegen_needed": os.environ.get("DR_XCODEGEN_NEEDED", ""),
  "xcodegen_reason": os.environ.get("DR_XCODEGEN_REASON", ""),
  "recommended_lane": os.environ.get("DR_RECOMMENDED_LANE", ""),
  "missing_required": json.loads(os.environ.get("DR_MISSING_REQUIRED", "[]")),
  "missing_optional": json.loads(os.environ.get("DR_MISSING_OPTIONAL", "[]")),
}
print(json.dumps(payload, indent=2))
PY
else
  echo "Xcode: $xcode_version_line"
  echo "Pinned Xcode: $pinned_xcode"
  echo "Version status: $version_status"
  echo "Required tools: xcodebuild=$xcode_build xcodegen=$xcodegen_tool"
  echo "Optional tools: xcbeautify=$xcbeautify_tool xcparse=$xcparse_tool jq=$jq_tool yq=$yq_tool watchman=$watchman_tool"
  echo "Tuist: $tuist_tool"
  echo "Simulator selector: $sim_selector"
  echo "XCODEGEN_NEEDED=$xcodegen_needed ($xcodegen_reason)"
  echo "Recommended lane: $recommended_lane"
  echo "DerivedData path: $derived_data"
  echo "Results: $result_root"
  echo "Logs: $log_root"
  echo "Summaries: $summary_root"
  echo "Missing required: ${missing_required[*]:-none}"
  echo "Missing optional: ${missing_optional[*]:-none}"
fi

if (( STRICT == 1 && ${#missing_required[@]} > 0 )); then
  exit 1
fi
exit 0
