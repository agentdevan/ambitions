#!/usr/bin/env bash
set -Eeuo pipefail

REPO_ROOT="$(git rev-parse --show-toplevel 2>/dev/null || pwd -P)"
cd "$REPO_ROOT"

RESULT=""
OUT_DIR=""
MODE="full"
while [[ "$#" -gt 0 ]]; do
  case "$1" in
    --result) RESULT="$2"; shift 2 ;;
    --output-dir) OUT_DIR="$2"; shift 2 ;;
    --mode) MODE="${2:-}"; shift 2 ;;
    -h|--help)
      echo "Usage: scripts/ambitions-xcode-result-extract.sh --result <path> --output-dir <dir> [--mode full|metadata]" >&2
      exit 0
      ;;
    *)
      echo "unsupported arg: $1" >&2
      exit 1
      ;;
  esac
done

case "$MODE" in
  full|metadata) ;;
  *)
    echo "unsupported extraction mode: $MODE (expected full or metadata)" >&2
    exit 2
    ;;
esac

if [[ -z "$RESULT" || -z "$OUT_DIR" ]]; then
  echo "Usage: scripts/ambitions-xcode-result-extract.sh --result <path> --output-dir <dir> [--mode full|metadata]" >&2
  exit 1
fi

if [[ ! -e "$RESULT" ]]; then
  echo "result bundle missing: $RESULT" >&2
  exit 1
fi

if [[ ! -f "$RESULT/Info.plist" ]]; then
  mkdir -p "$OUT_DIR"
  summary_file="$OUT_DIR/summary.json"
  corrupt_xcparse_available=false
  if command -v xcparse >/dev/null 2>&1; then
    corrupt_xcparse_available=true
  fi
  corrupt_rich_artifacts_requested=false
  if [[ "$MODE" == "full" ]]; then
    corrupt_rich_artifacts_requested=true
  fi
  cat > "$summary_file" <<JSON
{
  "result_bundle": "$RESULT",
  "result_bundle_retained": true,
  "extraction_mode": "$MODE",
  "xcparse_available": $corrupt_xcparse_available,
  "xcparse_invoked": false,
  "xcparse_pass_count": 0,
  "xcparse_success_count": 0,
  "rich_artifacts_requested": $corrupt_rich_artifacts_requested,
  "rich_artifacts_extracted": false,
  "attachments": null,
  "screenshots": null,
  "logs": null,
  "coverage": null,
  "status": "failed",
  "failure_category": "corrupt_xcresult",
  "reason": "result bundle is missing Info.plist"
}
JSON
  echo "corrupt_xcresult: result bundle missing Info.plist: $RESULT" >&2
  echo "$summary_file"
  exit 65
fi

mkdir -p "$OUT_DIR"
xcparse_available=false
xcparse_invoked=false
xcparse_pass_count=0
xcparse_success_count=0
rich_artifacts_requested=false
rich_artifacts_extracted=false
attachments_path=""
screenshots_path=""
logs_path=""
coverage_path=""

if command -v xcparse >/dev/null 2>&1; then
  xcparse_available=true
fi

if [[ "$MODE" == "full" ]]; then
  rich_artifacts_requested=true
  attachments_path="$OUT_DIR/attachments"
  screenshots_path="$OUT_DIR/screenshots"
  logs_path="$OUT_DIR/logs"
  coverage_path="$OUT_DIR/coverage"
  mkdir -p "$attachments_path" "$screenshots_path" "$logs_path" "$coverage_path"

  if [[ "$xcparse_available" == "true" ]]; then
    xcparse_invoked=true
    xcparse_log="$OUT_DIR/xcparse.log"
    : > "$xcparse_log"
    for artifact in attachments screenshots logs coverage; do
      ((xcparse_pass_count += 1))
      artifact_path="$OUT_DIR/$artifact"
      if xcparse "$artifact" "$RESULT" "$artifact_path" >>"$xcparse_log" 2>&1; then
        ((xcparse_success_count += 1))
      fi
    done
    if [[ "$xcparse_success_count" -eq 4 ]]; then
      rich_artifacts_extracted=true
    fi
  else
    echo "xcparse missing: install with brew install chargepoint/xcparse/xcparse (or run scripts/ambitions-build-lab-doctor.sh --json for full matrix)" >&2
  fi
fi

summary_file="$OUT_DIR/summary.json"
python3 - \
  "$summary_file" \
  "$RESULT" \
  "$MODE" \
  "$xcparse_available" \
  "$xcparse_invoked" \
  "$xcparse_pass_count" \
  "$xcparse_success_count" \
  "$rich_artifacts_requested" \
  "$rich_artifacts_extracted" \
  "$attachments_path" \
  "$screenshots_path" \
  "$logs_path" \
  "$coverage_path" <<'PY'
import json
import sys
from pathlib import Path

(
    summary_file,
    result_bundle,
    extraction_mode,
    xcparse_available,
    xcparse_invoked,
    xcparse_pass_count,
    xcparse_success_count,
    rich_artifacts_requested,
    rich_artifacts_extracted,
    attachments,
    screenshots,
    logs,
    coverage,
) = sys.argv[1:]

payload = {
    "result_bundle": result_bundle,
    "result_bundle_retained": True,
    "extraction_mode": extraction_mode,
    "xcparse_available": xcparse_available == "true",
    "xcparse_invoked": xcparse_invoked == "true",
    "xcparse_pass_count": int(xcparse_pass_count),
    "xcparse_success_count": int(xcparse_success_count),
    "rich_artifacts_requested": rich_artifacts_requested == "true",
    "rich_artifacts_extracted": rich_artifacts_extracted == "true",
    "attachments": attachments or None,
    "screenshots": screenshots or None,
    "logs": logs or None,
    "coverage": coverage or None,
    "claim_boundary": (
        "metadata-only result preservation; rich artifacts were not extracted"
        if extraction_mode == "metadata"
        else "rich artifact extraction attempt; individual pass counts report actual extraction"
    ),
}
Path(summary_file).write_text(json.dumps(payload, indent=2, sort_keys=True) + "\n", encoding="utf-8")
PY

echo "$summary_file"
