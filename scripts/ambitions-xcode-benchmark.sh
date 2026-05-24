#!/usr/bin/env bash
set -Eeuo pipefail

REPO_ROOT="$(git rev-parse --show-toplevel 2>/dev/null || pwd -P)"
cd "$REPO_ROOT"

usage() {
  cat <<'USAGE'
Usage:
  bash scripts/ambitions-xcode-benchmark.sh [--batch <BATCH>] [--scheme <SCHEME>] [--test <ONLY_TESTING>] [--test-plan <PLAN>] [--workers <1,2,4>]

Purpose:
  Measure the local Xcode loop without destructive cleanup. The benchmark uses repo-local DerivedData,
  preboots/repairs only the selected simulator, runs build-for-testing once, then optionally compares
  test-without-building timings for a focused test or test plan.

Defaults:
  --batch XCODE-BENCHMARK
  --scheme Ambitions
  --workers 1

Examples:
  bash scripts/ambitions-xcode-benchmark.sh --batch LOCAL
  bash scripts/ambitions-xcode-benchmark.sh --batch LOCAL --test AmbitionsTests/SomeTestClass --workers 1,2,4
  AMBITIONS_SIM_NAME="iPhone 17" bash scripts/ambitions-xcode-benchmark.sh --batch LOCAL --test-plan Ambitions-Focused --workers 1,2
USAGE
}

BATCH="XCODE-BENCHMARK"
SCHEME="Ambitions"
ONLY_TESTING=""
TEST_PLAN=""
WORKERS="${AMBITIONS_XCODE_TEST_WORKERS:-1}"
RESULT_ROOT=".codex/xcode-benchmarks"
DERIVED_DATA="$REPO_ROOT/.codex/DerivedData/Ambitions"

while [[ "$#" -gt 0 ]]; do
  case "$1" in
    --batch) BATCH="${2:-$BATCH}"; shift 2 ;;
    --scheme) SCHEME="${2:-$SCHEME}"; shift 2 ;;
    --test|--only-testing) ONLY_TESTING="${2:-}"; shift 2 ;;
    --test-plan) TEST_PLAN="${2:-}"; shift 2 ;;
    --workers) WORKERS="${2:-$WORKERS}"; shift 2 ;;
    --results-dir) RESULT_ROOT="${2:-$RESULT_ROOT}"; shift 2 ;;
    -h|--help)
      usage
      exit 0
      ;;
    *)
      echo "unsupported arg: $1" >&2
      usage >&2
      exit 2
      ;;
  esac
done

mkdir -p "$DERIVED_DATA"
TS="$(date -u +%Y%m%dT%H%M%SZ)"
OUT_DIR="$RESULT_ROOT/$BATCH/$TS"
mkdir -p "$OUT_DIR"
STEPS_JSONL="$OUT_DIR/steps.jsonl"
SUMMARY_JSON="$OUT_DIR/summary.json"
: > "$STEPS_JSONL"

normalize_workers() {
  printf '%s\n' "$WORKERS" | tr ',' ' '
}

json_append_step() {
  local name="$1"
  local status="$2"
  local duration="$3"
  local log_file="$4"
  python3 - "$STEPS_JSONL" "$name" "$status" "$duration" "$log_file" <<'PY'
import json
import sys
from pathlib import Path
path = Path(sys.argv[1])
name, status, duration, log_file = sys.argv[2], int(sys.argv[3]), float(sys.argv[4]), sys.argv[5]
with path.open("a", encoding="utf-8") as fh:
    fh.write(json.dumps({
        "name": name,
        "status": status,
        "duration_seconds": round(duration, 3),
        "log_file": log_file,
    }) + "\n")
PY
}

run_step() {
  local name="$1"
  shift
  local safe_name
  safe_name="$(printf '%s' "$name" | tr '/ :' '___')"
  local log_file="$OUT_DIR/$safe_name.log"
  local start end duration status
  start="$(python3 - <<'PY'
import time
print(time.time())
PY
)"
  echo "[xcode-benchmark] running $name"
  set +e
  if command -v xcbeautify >/dev/null 2>&1; then
    "$@" 2>&1 | tee "$log_file" | xcbeautify
    status=${PIPESTATUS[0]}
  else
    "$@" 2>&1 | tee "$log_file"
    status=$?
  fi
  set -e
  end="$(python3 - <<'PY'
import time
print(time.time())
PY
)"
  duration="$(python3 - "$start" "$end" <<'PY'
import sys
print(float(sys.argv[2]) - float(sys.argv[1]))
PY
)"
  json_append_step "$name" "$status" "$duration" "$log_file"
  echo "[xcode-benchmark] $name status=$status duration=${duration}s log=$log_file"
  return "$status"
}

sim_json="$(scripts/ambitions-xcode-sim-health.sh --json --repair || true)"
if [[ -n "${AMBITIONS_SIM_UDID:-}" ]]; then
  sim_udid="${AMBITIONS_SIM_UDID}"
else
  sim_udid="$(python3 - "$sim_json" <<'PY'
import json
import sys
try:
    data = json.loads(sys.argv[1])
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
if [[ "$need_flag" == "1" ]]; then
  if ! command -v xcodegen >/dev/null 2>&1; then
    echo "[xcode-benchmark] xcodegen required but unavailable" >&2
    exit 24
  fi
  echo "[xcode-benchmark] regenerating Xcode project because xcodegen inputs changed"
  xcodegen generate >/dev/null
fi

BUILD_RESULT="$OUT_DIR/build-for-testing.xcresult"
BUILD_CMD=(
  xcodebuild
  -project Ambitions.xcodeproj
  -scheme "$SCHEME"
  -sdk iphonesimulator
  -destination "$SIM_DEST"
  -derivedDataPath "$DERIVED_DATA"
  -showBuildTimingSummary
  build-for-testing
  CODE_SIGNING_ALLOWED=NO
  CODE_SIGNING_REQUIRED=NO
  COMPILER_INDEX_STORE_ENABLE=NO
  -resultBundlePath "$BUILD_RESULT"
)

build_status=0
run_step "build-for-testing" "${BUILD_CMD[@]}" || build_status=$?

if [[ "$build_status" -eq 0 && -n "$ONLY_TESTING" ]]; then
  for worker in $(normalize_workers); do
    TEST_RESULT="$OUT_DIR/focused-test-workers-$worker.xcresult"
    TEST_CMD=(
      xcodebuild
      -project Ambitions.xcodeproj
      -scheme "$SCHEME"
      -destination "$SIM_DEST"
      -derivedDataPath "$DERIVED_DATA"
      -parallel-testing-enabled YES
      -parallel-testing-worker-count "$worker"
      test-without-building
      -only-testing "$ONLY_TESTING"
      CODE_SIGNING_ALLOWED=NO
      CODE_SIGNING_REQUIRED=NO
      COMPILER_INDEX_STORE_ENABLE=NO
      -resultBundlePath "$TEST_RESULT"
    )
    run_step "focused-test workers=$worker" "${TEST_CMD[@]}" || true
  done
fi

if [[ "$build_status" -eq 0 && -n "$TEST_PLAN" ]]; then
  for worker in $(normalize_workers); do
    PLAN_RESULT="$OUT_DIR/test-plan-$TEST_PLAN-workers-$worker.xcresult"
    PLAN_CMD=(
      xcodebuild
      -project Ambitions.xcodeproj
      -scheme "$SCHEME"
      -testPlan "$TEST_PLAN"
      -destination "$SIM_DEST"
      -derivedDataPath "$DERIVED_DATA"
      -parallel-testing-enabled YES
      -parallel-testing-worker-count "$worker"
      test-without-building
      CODE_SIGNING_ALLOWED=NO
      CODE_SIGNING_REQUIRED=NO
      COMPILER_INDEX_STORE_ENABLE=NO
      -resultBundlePath "$PLAN_RESULT"
    )
    run_step "test-plan $TEST_PLAN workers=$worker" "${PLAN_CMD[@]}" || true
  done
fi

python3 - "$SUMMARY_JSON" "$STEPS_JSONL" "$BATCH" "$SCHEME" "$SIM_DEST" "$DERIVED_DATA" <<'PY'
import json
import sys
from pathlib import Path
summary_path = Path(sys.argv[1])
steps_path = Path(sys.argv[2])
steps = []
if steps_path.exists():
    steps = [json.loads(line) for line in steps_path.read_text(encoding="utf-8").splitlines() if line.strip()]
summary = {
    "batch": sys.argv[3],
    "scheme": sys.argv[4],
    "sim_destination": sys.argv[5],
    "derived_data": sys.argv[6],
    "steps": steps,
    "fastest_successful_step_by_name": {},
}
for step in steps:
    if step["status"] != 0:
        continue
    name = step["name"]
    previous = summary["fastest_successful_step_by_name"].get(name)
    if previous is None or step["duration_seconds"] < previous["duration_seconds"]:
        summary["fastest_successful_step_by_name"][name] = step
summary_path.write_text(json.dumps(summary, indent=2) + "\n", encoding="utf-8")
PY

echo "[xcode-benchmark] summary=$SUMMARY_JSON"
if [[ "$build_status" -ne 0 ]]; then
  exit "$build_status"
fi
exit 0
