#!/usr/bin/env bash
set -Eeuo pipefail

REPO_ROOT="$(git rev-parse --show-toplevel 2>/dev/null || pwd -P)"
cd "$REPO_ROOT"

HELPER="scripts/sim/simctl_screenshot.sh"
OUTPUT_DIR="output/visual-qa/screenshot-matrix"
SIMULATOR="${SIMULATOR_UDID:-booted}"
SMOKE=0
FORCE_FAILURE=0

usage() {
  cat >&2 <<'USAGE'
Usage: scripts/visual-qa/capture_matrix.sh [--smoke] [--force-failure] [--output-dir <dir>] [--simulator <udid|booted>]

Captures the Ambitions screenshot matrix through the centralized simulator image export helper.
USAGE
}

while [[ $# -gt 0 ]]; do
  case "$1" in
    --smoke) SMOKE=1; shift ;;
    --force-failure) FORCE_FAILURE=1; shift ;;
    --output-dir) OUTPUT_DIR="${2:-}"; shift 2 ;;
    --simulator) SIMULATOR="${2:-}"; shift 2 ;;
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
    echo "Smoke mode: \`$SMOKE\`"
    echo
  } > "$REPORT"
}

append_state_success() {
  local state="$1"
  local path="$2"
  {
    echo "- ${state}: \`${path}\`"
  } >> "$REPORT"
}

append_state_failure() {
  local state="$1"
  local diagnostic="$2"
  {
    echo "## Failed State"
    echo
    echo "- State: \`$state\`"
    echo "- Diagnostic: \`$diagnostic\`"
    echo
    echo "Screenshot export failure remains Red for visual QA."
  } >> "$REPORT"
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
  if ! resolved="$("$HELPER" "$destination" --simulator "$SIMULATOR" --diagnostic "$diagnostic")"; then
    write_report_header "RED"
    append_state_failure "$state" "$diagnostic"
    echo "$REPORT" >&2
    exit 1
  fi
  append_state_success "$state" "$resolved"
done

{
  echo
  echo "## Matrix State Contract"
  echo
  printf -- "- %s\n" "${full_states[@]}"
} >> "$REPORT"

echo "$REPORT"
