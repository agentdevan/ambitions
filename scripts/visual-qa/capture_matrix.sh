#!/usr/bin/env bash
set -Eeuo pipefail

REPO_ROOT="$(git rev-parse --show-toplevel 2>/dev/null || pwd -P)"
cd "$REPO_ROOT"

HELPER="scripts/sim/simctl_screenshot.sh"
OUTPUT_DIR="output/visual-qa/screenshot-matrix"
SIMULATOR="${SIMULATOR_UDID:-booted}"
APP_BUNDLE_ID="${AMBITIONS_APP_BUNDLE_ID:-com.ambitions.ios}"
SMOKE=0
FORCE_FAILURE=0
LAUNCH_APP=1

usage() {
  cat >&2 <<'USAGE'
Usage: scripts/visual-qa/capture_matrix.sh [--smoke] [--force-failure] [--output-dir <dir>] [--simulator <udid|booted>] [--app-bundle-id <bundle>] [--no-launch]

Captures the Ambitions screenshot matrix through the centralized simulator image export helper.
USAGE
}

while [[ $# -gt 0 ]]; do
  case "$1" in
    --smoke) SMOKE=1; shift ;;
    --force-failure) FORCE_FAILURE=1; shift ;;
    --output-dir) OUTPUT_DIR="${2:-}"; shift 2 ;;
    --simulator) SIMULATOR="${2:-}"; shift 2 ;;
    --app-bundle-id) APP_BUNDLE_ID="${2:-}"; shift 2 ;;
    --no-launch) LAUNCH_APP=0; shift ;;
    -h|--help) usage; exit 0 ;;
    *) echo "unsupported arg: $1" >&2; usage; exit 2 ;;
  esac
done

if [[ ! -x "$HELPER" ]]; then
  echo "missing executable screenshot helper: $HELPER" >&2
  exit 1
fi

mkdir -p "$OUTPUT_DIR/screenshots" "$OUTPUT_DIR/diagnostics"
output_abs="$(cd "$OUTPUT_DIR" && pwd -P)"
REPORT="$output_abs/visual-qa-matrix-report.md"

full_states=(
  "today-normal"
  "today-low-capacity"
  "today-protected-time"
  "today-recovery"
  "today-source-stale"
  "today-source-unavailable"
  "today-empty-manual"
  "today-receipt"
  "goals-normal"
  "goals-blocked"
  "capture-normal"
  "capture-empty"
  "time-normal"
  "time-protected-time"
  "you-normal"
  "you-dynamic-type"
  "you-reduce-motion"
  "you-increase-contrast"
)

smoke_states=(
  "today-normal"
  "today-recovery"
  "you-reduce-motion"
)

if [[ "$SMOKE" -eq 1 ]]; then
  states=("${smoke_states[@]}")
else
  states=("${full_states[@]}")
fi

write_report_header() {
  local status="$1"
  {
    echo "# Visual QA Screenshot Matrix"
    echo
    echo "Status: $status"
    echo "Helper: \`$HELPER\`"
    echo "Output directory: \`$output_abs\`"
    echo "Simulator: \`$SIMULATOR\`"
    echo "App bundle id: \`$APP_BUNDLE_ID\`"
    echo "Launch app: \`$LAUNCH_APP\`"
    echo "Smoke mode: \`$SMOKE\`"
    echo
  } > "$REPORT"
}

append_state_success() {
  local state="$1"
  local path="$2"
  local route="$3"
  {
    echo "- ${state}: \`${path}\` via \`${route}\`"
  } >> "$REPORT"
}

append_state_failure() {
  local state="$1"
  local diagnostic="$2"
  local reason="${3:-Screenshot export failure remains Red for visual QA.}"
  {
    echo "## Failed State"
    echo
    echo "- State: \`$state\`"
    echo "- Diagnostic: \`$diagnostic\`"
    echo
    echo "$reason"
  } >> "$REPORT"
}

route_for_state() {
  case "$1" in
    today-*) echo "ambitions://tab/today?origin=visual_qa" ;;
    goals-*) echo "ambitions://tab/goals?origin=visual_qa" ;;
    capture-*) echo "ambitions://tab/capture?origin=visual_qa" ;;
    time-*) echo "ambitions://tab/time?origin=visual_qa" ;;
    you-*) echo "ambitions://tab/you?origin=visual_qa" ;;
    *) echo "ambitions://tab/today?origin=visual_qa" ;;
  esac
}

write_route_diagnostic() {
  local state="$1"
  local route="$2"
  local command="$3"
  local stderr_path="$4"
  local diagnostic="$5"
  {
    echo "# Visual QA Route Diagnostic"
    echo
    echo "Status: RED"
    echo "State: \`$state\`"
    echo "App bundle id: \`$APP_BUNDLE_ID\`"
    echo "Simulator: \`$SIMULATOR\`"
    echo "Route: \`$route\`"
    echo
    echo "## Failing Command"
    echo
    echo '```bash'
    echo "$command"
    echo '```'
    echo
    echo "## Last stderr"
    echo
    echo '```text'
    if [[ -s "$stderr_path" ]]; then
      sed -n '1,80p' "$stderr_path"
    else
      echo "<empty>"
    fi
    echo '```'
  } > "$diagnostic"
}

prepare_state() {
  local state="$1"
  local diagnostic="$2"
  local route
  route="$(route_for_state "$state")"

  if [[ "$LAUNCH_APP" -ne 1 ]]; then
    echo "$route"
    return 0
  fi

  local launch_stderr="$output_abs/diagnostics/${state}.launch.stderr"
  local openurl_stderr="$output_abs/diagnostics/${state}.openurl.stderr"
  if ! xcrun simctl launch "$SIMULATOR" "$APP_BUNDLE_ID" >/dev/null 2>"$launch_stderr"; then
    write_route_diagnostic "$state" "$route" "xcrun simctl launch $SIMULATOR $APP_BUNDLE_ID" "$launch_stderr" "$diagnostic"
    return 1
  fi
  if ! xcrun simctl openurl "$SIMULATOR" "$route" >/dev/null 2>"$openurl_stderr"; then
    write_route_diagnostic "$state" "$route" "xcrun simctl openurl $SIMULATOR $route" "$openurl_stderr" "$diagnostic"
    return 1
  fi
  sleep 1
  echo "$route"
}

if [[ "$FORCE_FAILURE" -eq 1 ]]; then
  write_report_header "RED"
  diagnostic="$output_abs/diagnostics/forced-failure.diagnostic.md"
  set +e
  "$HELPER" "$output_abs/screenshots/forced-failure.png" --simulator "AMB-394-NO-SUCH-SIMULATOR" --diagnostic "$diagnostic" --retries 1 >/tmp/ambitions-capture-matrix-forced.out 2>/tmp/ambitions-capture-matrix-forced.err
  status=$?
  set -e
  if [[ "$status" -eq 0 ]]; then
    echo "forced failure unexpectedly succeeded" >&2
    exit 1
  fi
  append_state_failure "forced-failure" "$diagnostic"
  echo "$REPORT"
  exit "$status"
fi

write_report_header "GREEN"
echo "## Captured States" >> "$REPORT"
echo >> "$REPORT"

for state in "${states[@]}"; do
  destination="$output_abs/screenshots/${state}.png"
  diagnostic="$output_abs/diagnostics/${state}.diagnostic.md"
  if ! route="$(prepare_state "$state" "$diagnostic")"; then
    write_report_header "RED"
    append_state_failure "$state" "$diagnostic" "App launch or route preparation returned Red before screenshot export."
    echo "$REPORT" >&2
    exit 1
  fi
  if ! resolved="$("$HELPER" "$destination" --simulator "$SIMULATOR" --diagnostic "$diagnostic")"; then
    write_report_header "RED"
    append_state_failure "$state" "$diagnostic"
    echo "$REPORT" >&2
    exit 1
  fi
  append_state_success "$state" "$resolved" "$route"
done

{
  echo
  echo "## Matrix State Contract"
  echo
  printf -- "- %s\n" "${full_states[@]}"
} >> "$REPORT"

echo "$REPORT"
