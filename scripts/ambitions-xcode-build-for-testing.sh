#!/usr/bin/env bash
set -Eeuo pipefail

REPO_ROOT="$(git rev-parse --show-toplevel 2>/dev/null || pwd -P)"
cd "$REPO_ROOT"

BATCH=""
SCHEME="Ambitions"
RESULT_DIR=".codex/xcode-results"
LOG_DIR=".codex/xcode-logs"
SUMMARY_DIR=".codex/xcode-summaries"

while [[ "$#" -gt 0 ]]; do
  case "$1" in
    --batch) BATCH="${2:-}"; shift 2 ;;
    --scheme) SCHEME="${2:-$SCHEME}"; shift 2 ;;
    --results-dir) RESULT_DIR="${2:-$RESULT_DIR}"; shift 2 ;;
    --logs-dir) LOG_DIR="${2:-$LOG_DIR}"; shift 2 ;;
    --summaries-dir) SUMMARY_DIR="${2:-$SUMMARY_DIR}"; shift 2 ;;
    -h|--help)
      echo "Usage: scripts/ambitions-xcode-build-for-testing.sh --batch <BATCH>" >&2
      exit 0
      ;;
    *)
      echo "unsupported arg: $1" >&2
      exit 1
      ;;
  esac
done

[[ -n "$BATCH" ]] || { echo "--batch is required" >&2; exit 1; }

mkdir -p "$RESULT_DIR/$BATCH" "$LOG_DIR/$BATCH" "$SUMMARY_DIR/$BATCH"
TS="$(date -u +%Y%m%dT%H%M%SZ)"
RUN_ID="$TS-bft-$$-${RANDOM:-0}"
RESULT_BUNDLE="$RESULT_DIR/$BATCH/$RUN_ID/build-for-testing.xcresult"
LOG_FILE="$LOG_DIR/$BATCH/$RUN_ID/build-for-testing.log"
SUMMARY_FILE="$SUMMARY_DIR/$BATCH/$RUN_ID/build-for-testing-summary.json"
mkdir -p "$RESULT_DIR/$BATCH/$RUN_ID" "$LOG_DIR/$BATCH/$RUN_ID" "$SUMMARY_DIR/$BATCH/$RUN_ID"
DERIVED_DATA="$REPO_ROOT/.codex/DerivedData/Ambitions"
mkdir -p "$DERIVED_DATA"

sim_json="$(scripts/ambitions-xcode-sim-health.sh --json || true)"
if [[ -n "${AMBITIONS_SIM_UDID:-}" ]]; then
  sim_udid="${AMBITIONS_SIM_UDID}"
else
  sim_udid="$(python3 - "$sim_json" <<'PY'
import json, sys
text = sys.argv[1] if len(sys.argv) > 1 else "{}"
try:
    data = json.loads(text)
except Exception:
    data = {}
print(data.get("udid", ""))
PY
)"
fi

SIM_DEST="platform=iOS Simulator,name=iPhone 17"
if [[ -n "${AMBITIONS_SIM_UDID:-}" || -n "$sim_udid" ]]; then
  sim="${AMBITIONS_SIM_UDID:-$sim_udid}"
  [[ -n "$sim" ]] && SIM_DEST="platform=iOS Simulator,id=${sim}"
fi

need_output="$(scripts/ambitions-xcodegen-needed.sh || true)"
need_flag="$(awk -F= '/^XCODEGEN_NEEDED=/{print $2}' <<<"$need_output")"
need_reason="$(awk -F= '/^REASON=/{print $2}' <<<"$need_output")"

if [[ "$need_flag" == "1" ]]; then
  if ! command -v xcodegen >/dev/null 2>&1; then
    python3 - "$SUMMARY_FILE" "$BATCH" "$TS" "$RUN_ID" "$need_reason" <<'PY'
import json
import sys
from pathlib import Path

path, batch, timestamp, run_id, reason = sys.argv[1:]
payload = {
    "batch": batch,
    "lane": "build-for-testing",
    "status": "failed",
    "failure_category": "tool_missing",
    "timestamp_utc": timestamp,
    "run_id": run_id,
    "reason": reason,
}
Path(path).write_text(json.dumps(payload, indent=2, sort_keys=True) + "\n", encoding="utf-8")
PY
    echo "FAILURE_CLASS=tool_missing"
    exit 24
  fi
  xcodegen generate >/dev/null
fi

BUILD_CMD=(xcodebuild -project Ambitions.xcodeproj -scheme "$SCHEME" -sdk iphonesimulator -destination "$SIM_DEST" -derivedDataPath "$DERIVED_DATA" build-for-testing CODE_SIGNING_ALLOWED=NO CODE_SIGNING_REQUIRED=NO -resultBundlePath "$RESULT_BUNDLE")

set +e
if command -v xcbeautify >/dev/null 2>&1; then
  "${BUILD_CMD[@]}" 2>&1 | tee "$LOG_FILE" | xcbeautify
  status=${PIPESTATUS[0]}
else
  "${BUILD_CMD[@]}" 2>&1 | tee "$LOG_FILE"
  status=$?
fi
set -e

if command -v scripts/ambitions-xcode-result-extract.sh >/dev/null 2>&1; then
  scripts/ambitions-xcode-result-extract.sh --result "$RESULT_BUNDLE" --output-dir "$SUMMARY_DIR/$BATCH/$TS/extract" || true
fi

classification="unknown"
if [[ -f "$LOG_FILE" ]]; then
  classification="$(python3 scripts/ambitions-xcode-failure-classifier.py --log "$LOG_FILE" --json | python3 -c 'import sys, json; print(json.load(sys.stdin).get("classification","unknown"))' )"
fi

cat > "$SUMMARY_FILE" <<JSON
{
  "batch": "$BATCH",
  "lane": "build-for-testing",
  "status": "$([ "$status" -eq 0 ] && echo passed || echo failed)",
  "failure_category": "$classification",
  "result_bundle": "$RESULT_BUNDLE",
  "log_file": "$LOG_FILE",
  "timestamp_utc": "$TS",
  "run_id": "$RUN_ID",
  "reason": "$need_reason"
}
JSON

echo "FAILURE_CLASS=$classification"
exit "$status"
