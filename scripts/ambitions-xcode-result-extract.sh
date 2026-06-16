#!/usr/bin/env bash
set -Eeuo pipefail

REPO_ROOT="$(git rev-parse --show-toplevel 2>/dev/null || pwd -P)"
cd "$REPO_ROOT"

RESULT=""
OUT_DIR=""
while [[ "$#" -gt 0 ]]; do
  case "$1" in
    --result) RESULT="$2"; shift 2 ;;
    --output-dir) OUT_DIR="$2"; shift 2 ;;
    -h|--help)
      echo "Usage: scripts/ambitions-xcode-result-extract.sh --result <path> --output-dir <dir>" >&2
      exit 0
      ;;
    *)
      echo "unsupported arg: $1" >&2
      exit 1
      ;;
  esac
done

if [[ -z "$RESULT" || -z "$OUT_DIR" ]]; then
  echo "Usage: scripts/ambitions-xcode-result-extract.sh --result <path> --output-dir <dir>" >&2
  exit 1
fi

if [[ ! -e "$RESULT" ]]; then
  echo "result bundle missing: $RESULT" >&2
  exit 1
fi

mkdir -p "$OUT_DIR"
mkdir -p "$OUT_DIR/attachments" "$OUT_DIR/screenshots" "$OUT_DIR/logs" "$OUT_DIR/coverage"

if command -v xcparse >/dev/null 2>&1; then
  xcparse attachments "$RESULT" "$OUT_DIR/attachments" >/tmp/ambitions-xcparse.log 2>&1 || true
  xcparse screenshots "$RESULT" "$OUT_DIR/screenshots" >/tmp/ambitions-xcparse.log 2>&1 || true
  xcparse logs "$RESULT" "$OUT_DIR/logs" >/tmp/ambitions-xcparse.log 2>&1 || true
  xcparse coverage "$RESULT" "$OUT_DIR/coverage" >/tmp/ambitions-xcparse.log 2>&1 || true
  extracted=true
else
  extracted=false
  echo "xcparse missing: install with brew install chargepoint/xcparse/xcparse (or run scripts/ambitions-build-lab-doctor.sh --json for full matrix)" >&2
fi

summary_file="$OUT_DIR/summary.json"
cat > "$summary_file" <<JSON
{
  "result_bundle": "$RESULT",
  "xcparse_available": $extracted,
  "attachments": "$OUT_DIR/attachments",
  "screenshots": "$OUT_DIR/screenshots",
  "logs": "$OUT_DIR/logs",
  "coverage": "$OUT_DIR/coverage"
}
JSON

echo "$summary_file"
