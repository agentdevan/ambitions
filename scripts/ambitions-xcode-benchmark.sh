#!/usr/bin/env bash
set -Eeuo pipefail

REPO_ROOT="${AMBITIONS_REPO_ROOT:-$(git rev-parse --show-toplevel 2>/dev/null || pwd -P)}"
cd "$REPO_ROOT"

usage() {
  cat <<'USAGE'
Usage:
  bash scripts/ambitions-xcode-benchmark.sh [--batch <BATCH>] [--scheme auto|Ambitions|AmbitionsUnitTests] [--test <ONLY_TESTING>] [--test-plan <PLAN>] [--workers <1,2,4>] [--refresh-packages]
  bash scripts/ambitions-xcode-benchmark.sh --status
  bash scripts/ambitions-xcode-benchmark.sh --identity
  bash scripts/ambitions-xcode-benchmark.sh --batch <BATCH> --lane <LANE> -- <command> [args...]

Purpose:
  Measure the local Xcode loop without destructive cleanup. The benchmark uses repo-local DerivedData,
  preboots/repairs only the selected simulator, runs build-for-testing once, then optionally compares
  test-without-building timings for a focused test or test plan.

  With --lane and --, the helper runs a local command, records elapsed time and exit code under ignored
  .codex/xcode-benchmarks artifacts, and returns the command exit code.

Defaults:
  --batch XCODE-BENCHMARK
  --scheme auto
  --workers 1

Examples:
  bash scripts/ambitions-xcode-benchmark.sh --status
  bash scripts/ambitions-xcode-benchmark.sh --batch LOCAL
  bash scripts/ambitions-xcode-benchmark.sh --batch LOCAL --test AmbitionsTests/SomeTestClass --workers 1,2,4
  bash scripts/ambitions-xcode-benchmark.sh --batch LOCAL --lane smoke -- scripts/ambitions-xcode-benchmark.sh --status
  AMBITIONS_SIM_NAME="iPhone 17" bash scripts/ambitions-xcode-benchmark.sh --batch LOCAL --test-plan Ambitions-Focused --workers 1,2
USAGE
}

BATCH="XCODE-BENCHMARK"
SCHEME="auto"
ONLY_TESTING=""
TEST_PLAN=""
WORKERS="${AMBITIONS_XCODE_TEST_WORKERS:-1}"
RESULT_ROOT=".codex/xcode-benchmarks"
DERIVED_DATA="$REPO_ROOT/.codex/DerivedData/Ambitions"
LANE=""
STATUS=0
IDENTITY_ONLY=0
COMMAND_MODE=0
REFRESH_PACKAGES=0
SAMPLE_STATE="warm"

capture_identity() {
  local candidates=()
  local candidate
  local workspace_candidates=(
    "$REPO_ROOT/Ambitions.xcworkspace/xcshareddata/swiftpm/Package.resolved"
    "$REPO_ROOT/Ambitions.xcodeproj/project.xcworkspace/xcshareddata/swiftpm/Package.resolved"
    "$REPO_ROOT/Native/Ambitions.xcworkspace/xcshareddata/swiftpm/Package.resolved"
    "$REPO_ROOT/Native/Ambitions.xcodeproj/project.xcworkspace/xcshareddata/swiftpm/Package.resolved"
  )
  for candidate in "${workspace_candidates[@]}"; do
    [[ -f "$candidate" ]] && candidates+=("$candidate")
  done
  if (( ${#candidates[@]} > 1 )); then
    PACKAGE_PATH=""
    PACKAGE_IDENTITY="unknown"
    PACKAGE_IDENTITY_SOURCE="workspace-resolved"
    PACKAGE_IDENTITY_STATUS="ambiguous"
    return 3
  elif (( ${#candidates[@]} == 1 )); then
    PACKAGE_PATH="${candidates[0]}"
    PACKAGE_IDENTITY="$(shasum -a 256 "$PACKAGE_PATH" | awk '{print $1}')"
    PACKAGE_IDENTITY_SOURCE="workspace-resolved"
    PACKAGE_IDENTITY_STATUS="resolved"
  elif [[ -f "$REPO_ROOT/Packages/AmbitionsDesignSystem/Package.resolved" ]]; then
    PACKAGE_PATH="$REPO_ROOT/Packages/AmbitionsDesignSystem/Package.resolved"
    PACKAGE_IDENTITY="$(shasum -a 256 "$PACKAGE_PATH" | awk '{print $1}')"
    PACKAGE_IDENTITY_SOURCE="package-resolved"
    PACKAGE_IDENTITY_STATUS="resolved"
  elif [[ -f "$REPO_ROOT/Packages/AmbitionsDesignSystem/Package.swift" && -f "$REPO_ROOT/project.yml" ]]; then
    PACKAGE_PATH="$REPO_ROOT/Packages/AmbitionsDesignSystem/Package.swift+$REPO_ROOT/project.yml#packages"
    PACKAGE_IDENTITY="$(
      { cat "$REPO_ROOT/Packages/AmbitionsDesignSystem/Package.swift"; awk '/^packages:/{emit=1} emit && /^[^[:space:]]/ && !/^packages:/{exit} emit{print}' "$REPO_ROOT/project.yml"; } \
        | shasum -a 256 | awk '{print $1}'
    )"
    PACKAGE_IDENTITY_SOURCE="manifest-fallback"
    PACKAGE_IDENTITY_STATUS="resolved"
  else
    PACKAGE_PATH=""
    PACKAGE_IDENTITY="unknown"
    PACKAGE_IDENTITY_SOURCE="none"
    PACKAGE_IDENTITY_STATUS="unknown"
    return 4
  fi
  COMMIT="$(git rev-parse HEAD)"
  DIRTY_STATE="$([[ -n "$(git status --porcelain --untracked-files=no)" ]] && echo dirty || echo clean)"
  CACHE_IDENTITY="$DERIVED_DATA"
}

while [[ "$#" -gt 0 ]]; do
  case "$1" in
    --batch) BATCH="${2:-$BATCH}"; shift 2 ;;
    --scheme) SCHEME="${2:-$SCHEME}"; shift 2 ;;
    --test|--only-testing) ONLY_TESTING="${2:-}"; shift 2 ;;
    --test-plan) TEST_PLAN="${2:-}"; shift 2 ;;
    --workers) WORKERS="${2:-$WORKERS}"; shift 2 ;;
    --results-dir) RESULT_ROOT="${2:-$RESULT_ROOT}"; shift 2 ;;
    --lane) LANE="${2:-}"; shift 2 ;;
    --state) SAMPLE_STATE="${2:-}"; shift 2 ;;
    --refresh-packages) REFRESH_PACKAGES=1; shift ;;
    --status) STATUS=1; shift ;;
    --identity) IDENTITY_ONLY=1; shift ;;
    --) COMMAND_MODE=1; shift; break ;;
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

if [[ "$IDENTITY_ONLY" -eq 1 ]]; then
  identity_status=0
  capture_identity || identity_status=$?
  printf 'package_identity_status=%s\npackage_identity_source=%s\npackage_path=%s\npackage_identity=%s\n' \
    "$PACKAGE_IDENTITY_STATUS" "$PACKAGE_IDENTITY_SOURCE" "$PACKAGE_PATH" "$PACKAGE_IDENTITY"
  exit "$identity_status"
fi

if [[ "$STATUS" -eq 1 ]]; then
  cat <<EOF
status=installed
path=scripts/ambitions-xcode-benchmark.sh
artifact_root=$RESULT_ROOT
claim_boundary=timing evidence only; not build, test, release, accessibility, device, TestFlight, or App Store proof
EOF
  exit 0
fi

if [[ "$COMMAND_MODE" -eq 1 ]]; then
  [[ -n "$BATCH" ]] || { echo "--batch is required" >&2; exit 2; }
  [[ -n "$LANE" ]] || { echo "--lane is required" >&2; exit 2; }
  [[ "$#" -gt 0 ]] || { echo "command after -- is required" >&2; exit 2; }

  TS="$(date -u +%Y%m%dT%H%M%SZ)"
  OUT_DIR="$RESULT_ROOT/$BATCH/$TS"
  SUMMARY_FILE="$OUT_DIR/benchmark-summary.json"
  mkdir -p "$OUT_DIR"

  start_epoch="$(date +%s)"
  set +e
  "$@"
  status=$?
  set -e
  end_epoch="$(date +%s)"
  duration=$((end_epoch - start_epoch))

  capture_identity || { echo "package identity is ${PACKAGE_IDENTITY_STATUS}; refusing benchmark sample" >&2; exit 25; }
  XCODE_VERSION="$(xcodebuild -version 2>/dev/null | tr '\n' ' ' || true)"
  MACOS_VERSION="$(sw_vers -productVersion 2>/dev/null || true)"
  CPU="$(sysctl -n machdep.cpu.brand_string 2>/dev/null || uname -m)"
  MEMORY_BYTES="$(sysctl -n hw.memsize 2>/dev/null || echo unknown)"
  python3 - "$SUMMARY_FILE" "$BATCH" "$LANE" "$TS" "$status" "$duration" "$*" "$COMMIT" "$DIRTY_STATE" "$XCODE_VERSION" "$MACOS_VERSION" "$CPU" "$MEMORY_BYTES" "$CACHE_IDENTITY" "$SAMPLE_STATE" "$PACKAGE_PATH" "$PACKAGE_IDENTITY" <<'PY'
import json
import sys
from pathlib import Path

summary, batch, lane, ts, status, duration, command, commit, dirty, xcode, macos, cpu, memory, cache, state, package, package_identity = sys.argv[1:]
payload = {
    "batch": batch,
    "lane": lane,
    "timestamp_utc": ts,
    "exit_code": int(status),
    "duration_seconds": int(duration),
    "command": command,
    "commit": commit,
    "dirty_state": dirty,
    "xcode_version": xcode,
    "macos_version": macos,
    "cpu": cpu,
    "memory_bytes": memory,
    "derived_data": cache,
    "warm_cold": state,
    "package_path": package,
    "package_identity": package_identity,
    "scenario": lane,
    "artifact_root": ".codex/xcode-benchmarks",
    "claim_boundary": "timing evidence only; not build, test, release, accessibility, device, TestFlight, or App Store proof",
}
Path(summary).write_text(json.dumps(payload, indent=2, sort_keys=True) + "\n", encoding="utf-8")
PY

  echo "BENCHMARK_SUMMARY=$SUMMARY_FILE"
  echo "BENCHMARK_DURATION_SECONDS=$duration"
  exit "$status"
fi

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

parallel_args_for_worker() {
  local worker="$1"
  if [[ "$worker" == "1" ]]; then
    printf '%s\n' "-parallel-testing-enabled" "NO"
  else
    printf '%s\n' "-parallel-testing-enabled" "YES" "-parallel-testing-worker-count" "$worker"
  fi
}

resolve_scheme() {
  if [[ "$SCHEME" != "auto" ]]; then
    printf '%s\n' "$SCHEME"
    return
  fi

  if [[ -n "$ONLY_TESTING" && -z "$TEST_PLAN" ]]; then
    case "$ONLY_TESTING" in
      AmbitionsTests|AmbitionsTests/*)
        printf '%s\n' "${AMBITIONS_XCODE_UNIT_TEST_SCHEME:-AmbitionsUnitTests}"
        return
        ;;
    esac
  fi

  printf '%s\n' "${AMBITIONS_XCODE_FULL_TEST_SCHEME:-Ambitions}"
}

json_append_step() {
  local name="$1"
  local status="$2"
  local duration="$3"
  local log_file="$4"
  local state="$5"
  python3 - "$STEPS_JSONL" "$name" "$status" "$duration" "$log_file" "$state" "$COMMIT" "$DIRTY_STATE" "$XCODE_VERSION" "$MACOS_VERSION" "$CPU" "$MEMORY_BYTES" "$DERIVED_DATA" "$PACKAGE_PATH" "$PACKAGE_IDENTITY" "$COMMAND_TEXT" <<'PY'
import json
import sys
from pathlib import Path
path = Path(sys.argv[1])
name, status, duration, log_file, state, commit, dirty, xcode, macos, cpu, memory, cache, package, package_identity, command = sys.argv[2:]
with path.open("a", encoding="utf-8") as fh:
    fh.write(json.dumps({
        "name": name, "scenario": name,
        "status": int(status), "exit_code": int(status),
        "duration_seconds": round(float(duration), 3),
        "log_file": log_file,
        "warm_cold": state, "commit": commit, "dirty_state": dirty,
        "xcode_version": xcode, "macos_version": macos, "cpu": cpu,
        "memory_bytes": memory, "derived_data": cache, "package_path": package,
        "package_identity": package_identity,
        "command": command,
    }) + "\n")
PY
}

run_step() {
  local name="$1"
  local state="$2"
  shift 2
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
  printf -v COMMAND_TEXT '%q ' "$@"
  json_append_step "$name" "$status" "$duration" "$log_file" "$state"
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
RESOLVED_SCHEME="$(resolve_scheme)"
capture_identity || { echo "package identity is ${PACKAGE_IDENTITY_STATUS}; refusing benchmark sample" >&2; exit 25; }
XCODE_VERSION="$(xcodebuild -version 2>/dev/null | tr '\n' ' ' || true)"
MACOS_VERSION="$(sw_vers -productVersion 2>/dev/null || true)"
CPU="$(sysctl -n machdep.cpu.brand_string 2>/dev/null || uname -m)"
MEMORY_BYTES="$(sysctl -n hw.memsize 2>/dev/null || echo unknown)"
COMMAND_TEXT=""

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
  -skipPackagePluginValidation
  -skipMacroValidation
  -project Ambitions.xcodeproj
  -scheme "$RESOLVED_SCHEME"
  -sdk iphonesimulator
  -destination "$SIM_DEST"
  -derivedDataPath "$DERIVED_DATA"
  -showBuildTimingSummary
  build-for-testing
  CODE_SIGNING_ALLOWED=NO
  CODE_SIGNING_REQUIRED=NO
  COMPILER_INDEX_STORE_ENABLE=NO
  ONLY_ACTIVE_ARCH=YES
  -resultBundlePath "$BUILD_RESULT"
)

if [[ "$REFRESH_PACKAGES" -eq 1 ]]; then
  run_step "refresh-packages" "cold" scripts/ambitions-bounded-xcodebuild.sh -- xcodebuild -project Ambitions.xcodeproj -scheme "$RESOLVED_SCHEME" -resolvePackageDependencies
  capture_identity || { echo "package identity is ${PACKAGE_IDENTITY_STATUS} after refresh" >&2; exit 25; }
fi
BUILD_CMD=(xcodebuild -disableAutomaticPackageResolution -onlyUsePackageVersionsFromResolvedFile "${BUILD_CMD[@]:1}")

build_status=0
run_step "build-for-testing" "cold" scripts/ambitions-bounded-xcodebuild.sh -- "${BUILD_CMD[@]}" || build_status=$?

if [[ "$build_status" -eq 0 && -n "$ONLY_TESTING" ]]; then
  for worker in $(normalize_workers); do
    TEST_RESULT="$OUT_DIR/focused-test-workers-$worker.xcresult"
    mapfile -t PARALLEL_ARGS < <(parallel_args_for_worker "$worker")
    TEST_CMD=(
      xcodebuild
      -skipPackagePluginValidation
      -skipMacroValidation
      -project Ambitions.xcodeproj
      -scheme "$RESOLVED_SCHEME"
      -destination "$SIM_DEST"
      -derivedDataPath "$DERIVED_DATA"
      "${PARALLEL_ARGS[@]}"
      test-without-building
      -only-testing "$ONLY_TESTING"
      CODE_SIGNING_ALLOWED=NO
      CODE_SIGNING_REQUIRED=NO
      COMPILER_INDEX_STORE_ENABLE=NO
      ONLY_ACTIVE_ARCH=YES
      -resultBundlePath "$TEST_RESULT"
    )
    TEST_CMD=(xcodebuild -disableAutomaticPackageResolution -onlyUsePackageVersionsFromResolvedFile "${TEST_CMD[@]:1}")
    run_step "focused-test workers=$worker" "warm" scripts/ambitions-bounded-xcodebuild.sh -- "${TEST_CMD[@]}" || true
  done
fi

if [[ "$build_status" -eq 0 && -n "$TEST_PLAN" ]]; then
  for worker in $(normalize_workers); do
    PLAN_RESULT="$OUT_DIR/test-plan-$TEST_PLAN-workers-$worker.xcresult"
    mapfile -t PARALLEL_ARGS < <(parallel_args_for_worker "$worker")
    PLAN_CMD=(
      xcodebuild
      -skipPackagePluginValidation
      -skipMacroValidation
      -project Ambitions.xcodeproj
      -scheme "$RESOLVED_SCHEME"
      -testPlan "$TEST_PLAN"
      -destination "$SIM_DEST"
      -derivedDataPath "$DERIVED_DATA"
      "${PARALLEL_ARGS[@]}"
      test-without-building
      CODE_SIGNING_ALLOWED=NO
      CODE_SIGNING_REQUIRED=NO
      COMPILER_INDEX_STORE_ENABLE=NO
      ONLY_ACTIVE_ARCH=YES
      -resultBundlePath "$PLAN_RESULT"
    )
    PLAN_CMD=(xcodebuild -disableAutomaticPackageResolution -onlyUsePackageVersionsFromResolvedFile "${PLAN_CMD[@]:1}")
    run_step "test-plan $TEST_PLAN workers=$worker" "warm" scripts/ambitions-bounded-xcodebuild.sh -- "${PLAN_CMD[@]}" || true
  done
fi

python3 - "$SUMMARY_JSON" "$STEPS_JSONL" "$BATCH" "$RESOLVED_SCHEME" "$SIM_DEST" "$DERIVED_DATA" <<'PY'
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
    "claim_boundary": "timing evidence only; not build, test, release, accessibility, device, TestFlight, or App Store proof",
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
