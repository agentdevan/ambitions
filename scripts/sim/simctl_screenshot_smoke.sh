#!/usr/bin/env bash
set -Eeuo pipefail

REPO_ROOT="$(git rev-parse --show-toplevel 2>/dev/null || pwd -P)"
cd "$REPO_ROOT"

HELPER="scripts/sim/simctl_screenshot.sh"
OUT_DIR="output/visual-qa/simctl-smoke"
SUCCESS_PATH="$OUT_DIR/nested/simctl-smoke.png"
FAIL_PATH="$OUT_DIR/failure/forced-failure.png"
FAIL_DIAGNOSTIC="$OUT_DIR/failure/forced-failure.diagnostic.md"

usage() {
  cat >&2 <<'USAGE'
Usage: scripts/sim/simctl_screenshot_smoke.sh [--success-only|--failure-only]

Runs local smoke checks for the hardened simctl screenshot helper.
USAGE
}

mode="all"
while [[ $# -gt 0 ]]; do
  case "$1" in
    --success-only) mode="success"; shift ;;
    --failure-only) mode="failure"; shift ;;
    -h|--help) usage; exit 0 ;;
    *) echo "unsupported arg: $1" >&2; usage; exit 2 ;;
  esac
done

png_header_ok() {
  local file="$1"
  local header=""
  if command -v xxd >/dev/null 2>&1; then
    header="$(xxd -p -l 8 "$file" 2>/dev/null || true)"
  else
    header="$(od -An -tx1 -N8 "$file" 2>/dev/null | tr -d ' \n' || true)"
  fi
  [[ "$header" == "89504e470d0a1a0a" ]]
}

run_success() {
  mkdir -p "$(dirname "$SUCCESS_PATH")"
  first_output="$("$HELPER" "$SUCCESS_PATH")"
  [[ "$first_output" == /* ]]
  [[ -s "$SUCCESS_PATH" ]]
  png_header_ok "$SUCCESS_PATH"
  first_size="$(wc -c < "$SUCCESS_PATH" | tr -d ' ')"

  second_output="$("$HELPER" "$SUCCESS_PATH")"
  [[ "$second_output" == "$first_output" ]]
  [[ -s "$SUCCESS_PATH" ]]
  png_header_ok "$SUCCESS_PATH"
  second_size="$(wc -c < "$SUCCESS_PATH" | tr -d ' ')"
  [[ "$second_size" -gt 0 ]]

  cat <<REPORT
SUCCESS screenshot: $SUCCESS_PATH
Resolved output: $second_output
First size: $first_size
Second size: $second_size
REPORT
}

run_failure() {
  rm -f "$FAIL_PATH" "$FAIL_DIAGNOSTIC"
  set +e
  "$HELPER" "$FAIL_PATH" --simulator "AMB-393-NO-SUCH-SIMULATOR" --diagnostic "$FAIL_DIAGNOSTIC" --retries 1 >/tmp/ambitions-simctl-smoke-failure.out 2>/tmp/ambitions-simctl-smoke-failure.err
  status=$?
  set -e

  if [[ "$status" -eq 0 ]]; then
    echo "forced failure unexpectedly succeeded" >&2
    exit 1
  fi

  [[ -f "$FAIL_DIAGNOSTIC" ]]
  rg -q "Status: RED" "$FAIL_DIAGNOSTIC"
  rg -q "Requested destination" "$FAIL_DIAGNOSTIC"
  rg -q "xcrun simctl list devices" "$FAIL_DIAGNOSTIC"

  cat <<REPORT
FORCED failure diagnostic: $FAIL_DIAGNOSTIC
Exit status: $status
REPORT
}

case "$mode" in
  success) run_success ;;
  failure) run_failure ;;
  all)
    run_success
    run_failure
    ;;
esac
