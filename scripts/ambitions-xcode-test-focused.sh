#!/usr/bin/env bash
set -Eeuo pipefail

REPO_ROOT="$(git rev-parse --show-toplevel 2>/dev/null || pwd -P)"
cd "$REPO_ROOT"

BATCH=""
TEST_ID=""
ONLY_TESTING=""
SCHEME="Ambitions"
RESULT_DIR=".codex/xcode-results"
LOG_DIR=".codex/xcode-logs"
SUMMARY_DIR=".codex/xcode-summaries"

while [[ "$#" -gt 0 ]]; do
  case "$1" in
    --batch) BATCH="${2:-}"; shift 2 ;;
    --test) TEST_ID="${2:-}"; shift 2 ;;
    --only-testing) ONLY_TESTING="${2:-}"; shift 2 ;;
    --scheme) SCHEME="${2:-$SCHEME}"; shift 2 ;;
    --results-dir) RESULT_DIR="${2:-$RESULT_DIR}"; shift 2 ;;
    --logs-dir) LOG_DIR="${2:-$LOG_DIR}"; shift 2 ;;
    --summaries-dir) SUMMARY_DIR="${2:-$SUMMARY_DIR}"; shift 2 ;;
    -h|--help)
      echo "Usage: scripts/ambitions-xcode-test-focused.sh --batch <BATCH> --test <TEST_ID>" >&2
      exit 0
      ;;
    *)
      echo "unsupported arg: $1" >&2
      exit 1
      ;;
  esac
done

[[ -n "$BATCH" ]] || { echo "--batch is required" >&2; exit 1; }
if [[ -z "$TEST_ID" && -z "$ONLY_TESTING" ]]; then
  echo "one of --test or --only-testing is required" >&2
  exit 1
fi

mkdir -p "$RESULT_DIR/$BATCH" "$LOG_DIR/$BATCH" "$SUMMARY_DIR/$BATCH"
TS="$(date -u +%Y%m%dT%H%M%SZ)"
RESULT_BUNDLE="$RESULT_DIR/$BATCH/$TS/focused-test.xcresult"
LOG_FILE="$LOG_DIR/$BATCH/$TS/focused-test.log"
SUMMARY_FILE="$SUMMARY_DIR/$BATCH/$TS/focused-test-summary.json"
mkdir -p "$RESULT_DIR/$BATCH/$TS" "$LOG_DIR/$BATCH/$TS" "$SUMMARY_DIR/$BATCH/$TS"
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

test_filter="${ONLY_TESTING:-$TEST_ID}"

TEST_CMD=(xcodebuild -project Ambitions.xcodeproj -scheme "$SCHEME" -destination "$SIM_DEST" -derivedDataPath "$DERIVED_DATA" test-without-building -only-testing "$test_filter" CODE_SIGNING_ALLOWED=NO -resultBundlePath "$RESULT_BUNDLE")

run_once() {
  set +e
  if command -v xcbeautify >/dev/null 2>&1; then
    "${TEST_CMD[@]}" 2>&1 | tee "$LOG_FILE" | xcbeautify
    status=${PIPESTATUS[0]}
  else
    "${TEST_CMD[@]}" 2>&1 | tee "$LOG_FILE"
    status=$?
  fi
  set -e
}

run_once
status=$?

if [[ "$status" -ne 0 ]]; then
  classification="$(python3 scripts/ambitions-xcode-failure-classifier.py --log "$LOG_FILE" --json | python3 -c 'import sys, json; print(json.load(sys.stdin).get("classification",""))' )"
  if [[ "$classification" == "simulator_boot_failure" ]]; then
    scripts/ambitions-xcode-sim-health.sh --repair --json >/dev/null 2>&1 || true
    run_once
    status=$?
  fi
fi

if command -v scripts/ambitions-xcode-result-extract.sh >/dev/null 2>&1; then
  scripts/ambitions-xcode-result-extract.sh --result "$RESULT_BUNDLE" --output-dir "$SUMMARY_DIR/$BATCH/$TS/extract" || true
fi

classification="$(python3 scripts/ambitions-xcode-failure-classifier.py --log "$LOG_FILE" --json | python3 -c 'import sys, json; print(json.load(sys.stdin).get("classification", ""))')"
[[ -z "$classification" ]] && classification="unknown"

cat > "$SUMMARY_FILE" <<JSON
{
  "batch": "$BATCH",
  "lane": "focused-test",
  "test": "$test_filter",
  "status": "$([ "$status" -eq 0 ] && echo passed || echo failed)",
  "failure_category": "$classification",
  "result_bundle": "$RESULT_BUNDLE",
  "log_file": "$LOG_FILE",
  "timestamp_utc": "$TS"
}
JSON

echo "FAILURE_CLASS=$classification"
((status == 0)) || exit "$status"
exit 0
