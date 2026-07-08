#!/usr/bin/env bash
set -Eeuo pipefail

REPO_ROOT="$(git rev-parse --show-toplevel 2>/dev/null || pwd -P)"
cd "$REPO_ROOT"

BATCH="AMB_1815_DETERMINISTIC_SCREENSHOT_LANE"
TEST_ID="${AMBITIONS_DETERMINISTIC_SCREENSHOT_TEST_ID:-AmbitionsUITests/DeterministicScreenshotLaneUITests}"
TIMEOUT_DURATION="20m"
KILL_AFTER="60s"
PREBUILD_TIMEOUT_DURATION="${AMBITIONS_XCODE_UI_PREBUILD_TIMEOUT:-35m}"

usage() {
  cat >&2 <<'EOF'
Usage: scripts/ambitions-run-deterministic-screenshot-lane.sh [options]

Runs the deterministic Ambitions screenshot lane:
  AmbitionsUITests/DeterministicScreenshotLaneUITests

Override with AMBITIONS_DETERMINISTIC_SCREENSHOT_TEST_ID for a narrower class/test.

Options:
  --batch <name>             Batch directory under .codex outputs.
  --timeout <duration>       Focused UI test timeout. Default: 20m.
  --kill-after <duration>    Timeout kill-after grace. Default: 60s.
  --prebuild-timeout <dur>   UI prebuild timeout. Default: AMBITIONS_XCODE_UI_PREBUILD_TIMEOUT or 35m.
  --without-building         Forward test-without-building to the focused runner.
  --skip-prebuild            Forward skip-prebuild to the focused runner.
  -h, --help                 Show this help.
EOF
}

EXTRA_ARGS=()
while [[ "$#" -gt 0 ]]; do
  case "$1" in
    --batch) BATCH="${2:-}"; shift 2 ;;
    --timeout) TIMEOUT_DURATION="${2:-}"; shift 2 ;;
    --kill-after) KILL_AFTER="${2:-}"; shift 2 ;;
    --prebuild-timeout) PREBUILD_TIMEOUT_DURATION="${2:-}"; shift 2 ;;
    --without-building|--test-without-building) EXTRA_ARGS+=("--without-building"); shift ;;
    --skip-prebuild) EXTRA_ARGS+=("--skip-prebuild"); shift ;;
    -h|--help)
      usage
      exit 0
      ;;
    *)
      echo "unsupported arg: $1" >&2
      exit 2
      ;;
  esac
done

[[ -n "$BATCH" ]] || { echo "--batch must not be empty" >&2; exit 2; }
[[ -n "$TIMEOUT_DURATION" ]] || { echo "--timeout must not be empty" >&2; exit 2; }
[[ -n "$KILL_AFTER" ]] || { echo "--kill-after must not be empty" >&2; exit 2; }
[[ -n "$PREBUILD_TIMEOUT_DURATION" ]] || { echo "--prebuild-timeout must not be empty" >&2; exit 2; }

exec scripts/ambitions-xcode-test-focused.sh \
  --batch "$BATCH" \
  --scheme AmbitionsUITests \
  --test "$TEST_ID" \
  --timeout "$TIMEOUT_DURATION" \
  --kill-after "$KILL_AFTER" \
  --prebuild-timeout "$PREBUILD_TIMEOUT_DURATION" \
  "${EXTRA_ARGS[@]}"
