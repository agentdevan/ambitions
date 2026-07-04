#!/usr/bin/env bash
set -Eeuo pipefail

REPO_ROOT="$(git rev-parse --show-toplevel 2>/dev/null || pwd -P)"
cd "$REPO_ROOT"

TIMEOUT_DURATION="15m"
KILL_AFTER="60s"
LOG_FILE=""

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

set +e
if [[ -n "$LOG_FILE" ]]; then
  "${RUN_CMD[@]}" 2>&1 | tee "$LOG_FILE"
  status=${PIPESTATUS[0]}
else
  "${RUN_CMD[@]}"
  status=$?
fi
set -e

cleanup_targeted_result_bundle_processes() {
  [[ -n "$RESULT_BUNDLE" ]] || return 0
  echo "timeout_cleanup=targeted_result_bundle"
  echo "timeout_cleanup_match=$RESULT_BUNDLE"

  local matched=0
  while IFS= read -r pid; do
    [[ -n "$pid" ]] || continue
    [[ "$pid" != "$$" && "$pid" != "$PPID" ]] || continue

    local command_line
    command_line="$(ps -p "$pid" -o command= 2>/dev/null || true)"
    [[ "$command_line" == *xcodebuild* ]] || continue
    matched=1
    echo "timeout_cleanup_pid=$pid"
    kill -TERM "$pid" 2>/dev/null || true
  done < <(pgrep -f "$RESULT_BUNDLE" 2>/dev/null || true)

  if [[ "$matched" -eq 1 ]]; then
    sleep 2
    while IFS= read -r pid; do
      [[ -n "$pid" ]] || continue
      [[ "$pid" != "$$" && "$pid" != "$PPID" ]] || continue

      local command_line
      command_line="$(ps -p "$pid" -o command= 2>/dev/null || true)"
      [[ "$command_line" == *xcodebuild* ]] || continue
      echo "timeout_cleanup_force_pid=$pid"
      kill -KILL "$pid" 2>/dev/null || true
    done < <(pgrep -f "$RESULT_BUNDLE" 2>/dev/null || true)
  fi
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
