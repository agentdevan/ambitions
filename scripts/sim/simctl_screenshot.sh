#!/usr/bin/env bash
set -Eeuo pipefail

usage() {
  cat >&2 <<'USAGE'
Usage: scripts/sim/simctl_screenshot.sh <output.png> [--simulator <udid|booted>] [--diagnostic <path>] [--retries <count>]

Captures a simulator screenshot through a hardened, diagnosable export path.
USAGE
}

if [[ $# -lt 1 ]]; then
  usage
  exit 2
fi

REQUESTED_DEST="$1"
shift

SIMULATOR="${SIMULATOR_UDID:-booted}"
DIAGNOSTIC_PATH=""
RETRIES=3
BACKOFF_SECONDS=1

while [[ $# -gt 0 ]]; do
  case "$1" in
    --simulator)
      SIMULATOR="${2:-}"
      shift 2
      ;;
    --diagnostic)
      DIAGNOSTIC_PATH="${2:-}"
      shift 2
      ;;
    --retries)
      RETRIES="${2:-}"
      shift 2
      ;;
    -h|--help)
      usage
      exit 0
      ;;
    *)
      echo "unsupported arg: $1" >&2
      usage
      exit 2
      ;;
  esac
done

if [[ -z "$REQUESTED_DEST" || "$REQUESTED_DEST" == */ ]]; then
  echo "screenshot destination must be a .png file path, not a directory" >&2
  exit 2
fi

if [[ "${REQUESTED_DEST##*.}" != "png" ]]; then
  echo "screenshot destination must end in .png: $REQUESTED_DEST" >&2
  exit 2
fi

case "$RETRIES" in
  ''|*[!0-9]*)
    echo "--retries must be a positive integer" >&2
    exit 2
    ;;
esac
if [[ "$RETRIES" -lt 1 ]]; then
  echo "--retries must be at least 1" >&2
  exit 2
fi

REPO_ROOT="$(git rev-parse --show-toplevel 2>/dev/null || pwd -P)"
cd "$REPO_ROOT"

dest_dir="$(dirname "$REQUESTED_DEST")"
dest_base="$(basename "$REQUESTED_DEST")"
mkdir -p "$dest_dir"
dest_dir_abs="$(cd "$dest_dir" && pwd -P)"
RESOLVED_DEST="$dest_dir_abs/$dest_base"

if [[ -z "$DIAGNOSTIC_PATH" ]]; then
  DIAGNOSTIC_PATH="${RESOLVED_DEST%.png}.diagnostic.md"
fi
diagnostic_dir="$(dirname "$DIAGNOSTIC_PATH")"
diagnostic_base="$(basename "$DIAGNOSTIC_PATH")"
mkdir -p "$diagnostic_dir"
diagnostic_dir_abs="$(cd "$diagnostic_dir" && pwd -P)"
DIAGNOSTIC_PATH="$diagnostic_dir_abs/$diagnostic_base"

TEMP_DIR="$(mktemp -d "${TMPDIR:-/tmp}/ambitions-simctl-screenshot.XXXXXX")"
TEMP_OUTPUT="$TEMP_DIR/capture.png"
STDERR_LOG="$TEMP_DIR/simctl-stderr.log"
BOOTSTATUS_LOG="$TEMP_DIR/bootstatus.log"
LAST_COMMAND=""
LAST_STATUS=0

cleanup() {
  rm -rf "$TEMP_DIR"
}
trap cleanup EXIT

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

write_diagnostic() {
  local status_label="$1"
  local reason="$2"
  local dir_listing=""
  dir_listing="$(ls -la "$dest_dir_abs" 2>&1 || true)"
  {
    echo "# Simctl Screenshot Diagnostic"
    echo
    echo "Status: $status_label"
    echo "Reason: $reason"
    echo
    echo "## Paths"
    echo
    echo "- Requested destination: \`$REQUESTED_DEST\`"
    echo "- Resolved destination: \`$RESOLVED_DEST\`"
    echo "- Destination directory writable: \`$([[ -w "$dest_dir_abs" ]] && echo yes || echo no)\`"
    echo "- Temp directory: \`$TEMP_DIR\`"
    echo "- Diagnostic path: \`$DIAGNOSTIC_PATH\`"
    echo "- Working directory: \`$(pwd -P)\`"
    echo "- Current user: \`$(id -un 2>/dev/null || whoami)\`"
    echo
    echo "## Failing Command"
    echo
    echo "\`\`\`bash"
    echo "$LAST_COMMAND"
    echo "\`\`\`"
    echo
    echo "## Last stderr"
    echo
    echo "\`\`\`text"
    cat "$STDERR_LOG" 2>/dev/null || true
    echo "\`\`\`"
    echo
    echo "## xcodebuild -version"
    echo
    echo "\`\`\`text"
    xcodebuild -version 2>&1 || true
    echo "\`\`\`"
    echo
    echo "## xcrun simctl list devices booted"
    echo
    echo "\`\`\`text"
    xcrun simctl list devices booted 2>&1 || true
    echo "\`\`\`"
    echo
    echo "## xcrun simctl list devices"
    echo
    echo "\`\`\`text"
    xcrun simctl list devices 2>&1 || true
    echo "\`\`\`"
    echo
    echo "## Destination directory listing"
    echo
    echo "\`\`\`text"
    echo "$dir_listing"
    echo "\`\`\`"
  } > "$DIAGNOSTIC_PATH"
}

if ! command -v xcrun >/dev/null 2>&1; then
  LAST_COMMAND="command -v xcrun"
  echo "xcrun not found" > "$STDERR_LOG"
  write_diagnostic "RED" "xcrun is unavailable"
  echo "diagnostic: $DIAGNOSTIC_PATH" >&2
  exit 1
fi

LAST_COMMAND="xcrun simctl bootstatus $SIMULATOR -b"
if ! xcrun simctl bootstatus "$SIMULATOR" -b > "$BOOTSTATUS_LOG" 2> "$STDERR_LOG"; then
  write_diagnostic "RED" "simulator is not booted or bootstatus failed"
  echo "diagnostic: $DIAGNOSTIC_PATH" >&2
  exit 1
fi

rm -f "$TEMP_OUTPUT" "$RESOLVED_DEST"

attempt=1
while [[ "$attempt" -le "$RETRIES" ]]; do
  rm -f "$TEMP_OUTPUT"
  LAST_COMMAND="xcrun simctl io $SIMULATOR screenshot $TEMP_OUTPUT"
  if xcrun simctl io "$SIMULATOR" screenshot "$TEMP_OUTPUT" > /dev/null 2> "$STDERR_LOG"; then
    if [[ -s "$TEMP_OUTPUT" ]] && png_header_ok "$TEMP_OUTPUT"; then
      mv -f "$TEMP_OUTPUT" "$RESOLVED_DEST"
      echo "$RESOLVED_DEST"
      exit 0
    fi
    echo "simctl produced an empty or non-PNG screenshot at $TEMP_OUTPUT" > "$STDERR_LOG"
    LAST_STATUS=1
  else
    LAST_STATUS=$?
  fi
  if [[ "$attempt" -lt "$RETRIES" ]]; then
    sleep "$BACKOFF_SECONDS"
  fi
  attempt=$((attempt + 1))
done

write_diagnostic "RED" "screenshot capture failed after $RETRIES attempts"
echo "diagnostic: $DIAGNOSTIC_PATH" >&2
exit "${LAST_STATUS:-1}"
