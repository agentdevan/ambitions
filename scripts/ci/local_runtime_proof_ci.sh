#!/usr/bin/env bash
set -uo pipefail

ROOT="$(git rev-parse --show-toplevel)"
cd "${ROOT}" || exit 1

RUN_STAMP="${RUN_STAMP:-local-runtime-proof-$(date -u +%Y%m%dT%H%M%SZ)}"
OUTPUT_ROOT="${OUTPUT_ROOT:-artifacts/local-runtime-proof/${RUN_STAMP}}"
LOG_DIR="${OUTPUT_ROOT}/logs"
RESULT_BUNDLE="${OUTPUT_ROOT}/focused-localruntime-tests.xcresult"
DERIVED_DATA="${DERIVED_DATA:-${RUNNER_TEMP:-/tmp}/ambitions-local-runtime-proof-${RUN_STAMP}-DerivedData}"
SCHEME="${SCHEME:-Ambitions}"
SIMULATOR_NAME="${SIMULATOR_NAME:-iPhone 17}"
STATUS_JSON="${OUTPUT_ROOT}/phase-status.json"
SUMMARY_MD="${OUTPUT_ROOT}/ci-summary.md"

mkdir -p "${LOG_DIR}"

PHASE_STATUS=()
FIRST_FAILURE=0

record_phase() {
  local phase="$1"
  local exit_code="$2"
  local log_path="$3"
  PHASE_STATUS+=("{\"phase\":\"${phase}\",\"exit_code\":${exit_code},\"log\":\"${log_path}\"}")
  if [[ "${exit_code}" != "0" && "${FIRST_FAILURE}" == "0" ]]; then
    FIRST_FAILURE="${exit_code}"
  fi
}

write_status_json() {
  {
    echo "["
    local count="${#PHASE_STATUS[@]}"
    local index=0
    for item in "${PHASE_STATUS[@]}"; do
      index=$((index + 1))
      if [[ "${index}" -lt "${count}" ]]; then
        echo "  ${item},"
      else
        echo "  ${item}"
      fi
    done
    echo "]"
  } > "${STATUS_JSON}"
}

run_phase() {
  local phase="$1"
  shift
  local log_path="${LOG_DIR}/${phase}.log"
  echo "=== ${phase} ==="
  echo "$ $*" > "${log_path}"
  set +e
  "$@" >> "${log_path}" 2>&1
  local exit_code="$?"
  set -u -o pipefail
  echo "${phase}: exit ${exit_code}"
  record_phase "${phase}" "${exit_code}" "${log_path}"
  write_status_json
  return "${exit_code}"
}

write_architecture_inventory() {
  python3 scripts/ambitions-architecture-inventory.py --json > "${OUTPUT_ROOT}/architecture-inventory.json"
}

write_local_runtime_proof() {
  python3 scripts/ambitions-local-runtime-proof.py \
    --write-json "${OUTPUT_ROOT}/local-runtime-proof.json" \
    --write-markdown "${OUTPUT_ROOT}/local-runtime-proof.md" \
    --json > "${OUTPUT_ROOT}/local-runtime-proof.stdout.json"
}

boot_selected_simulator() {
  xcrun simctl boot "${SIMULATOR_UDID}" || true
  xcrun simctl bootstatus "${SIMULATOR_UDID}" -b
}

write_environment_summary() {
  {
    echo "# LocalRuntimeProof CI Environment"
    echo
    echo "- run_stamp: \`${RUN_STAMP}\`"
    echo "- github_run_id: \`${GITHUB_RUN_ID:-local}\`"
    echo "- github_run_attempt: \`${GITHUB_RUN_ATTEMPT:-local}\`"
    echo "- github_event: \`${GITHUB_EVENT_NAME:-local}\`"
    echo "- github_ref: \`${GITHUB_REF:-local}\`"
    echo "- head_sha: \`$(git rev-parse HEAD)\`"
    echo "- scheme: \`${SCHEME}\`"
    echo "- simulator_name_preference: \`${SIMULATOR_NAME}\`"
    echo "- output_root: \`${OUTPUT_ROOT}\`"
    echo "- derived_data: \`${DERIVED_DATA}\`"
    echo
    echo "## Host"
    sw_vers 2>/dev/null || true
    echo
    echo "## Xcode"
    xcodebuild -version 2>/dev/null || true
    xcode-select -p 2>/dev/null || true
    echo
    echo "## Available Simulators"
    xcrun simctl list devices available 2>/dev/null || true
  } > "${OUTPUT_ROOT}/environment-summary.md" 2>&1
  git rev-parse HEAD > "${OUTPUT_ROOT}/commit-sha.txt"
}

select_simulator_udid() {
  python3 - <<'PY'
import json
import os
import subprocess
import sys

preferred = os.environ.get("SIMULATOR_NAME", "iPhone 17")
explicit = os.environ.get("SIMULATOR_UDID", "").strip()
if explicit:
    print(explicit)
    raise SystemExit(0)

payload = subprocess.check_output(
    ["xcrun", "simctl", "list", "devices", "available", "-j"],
    text=True,
)
devices = json.loads(payload).get("devices", {})
candidates = []
for runtime, runtime_devices in devices.items():
    if "iOS" not in runtime:
        continue
    for device in runtime_devices:
        if not device.get("isAvailable", True):
            continue
        name = device.get("name", "")
        udid = device.get("udid", "")
        if not udid:
            continue
        candidates.append(
            (
                0 if name == preferred else 1,
                0 if name.startswith("iPhone") else 1,
                0 if device.get("state") == "Booted" else 1,
                name,
                udid,
                runtime,
            )
        )

if not candidates:
    print("No available iOS simulator found.", file=sys.stderr)
    raise SystemExit(2)

candidates.sort()
print(candidates[0][4])
PY
}

write_ci_summary() {
  local status="GREEN"
  if [[ "${FIRST_FAILURE}" != "0" ]]; then
    status="RED"
  fi
  {
    echo "# LocalRuntimeProof CI Summary"
    echo
    echo "- status: \`${status}\`"
    echo "- head_sha: \`$(git rev-parse HEAD)\`"
    echo "- runtime_proof: \`${OUTPUT_ROOT}/local-runtime-proof.json\`"
    echo "- architecture_inventory: \`${OUTPUT_ROOT}/architecture-inventory.json\`"
    echo "- xctest_log: \`${LOG_DIR}/focused-localruntime-xctest.log\`"
    echo "- xctest_result_bundle: \`${RESULT_BUNDLE}\`"
    echo
    echo "## Phase Status"
    echo
    echo "| Phase | Exit | Log |"
    echo "| --- | ---: | --- |"
    for item in "${PHASE_STATUS[@]}"; do
      python3 - "${item}" <<'PY'
import json
import sys
item = json.loads(sys.argv[1])
print(f"| `{item['phase']}` | `{item['exit_code']}` | `{item['log']}` |")
PY
    done
    echo
    echo "## Non-claims"
    echo
    echo "This CI proof does not prove Visual Green, Release Green, privacy/legal approval, TestFlight readiness, App Store readiness, production R2 deployment, production CloudKit continuity, physical-device behavior, or total product completion."
  } > "${SUMMARY_MD}"
}

run_xcode_tests() {
  local log_path="${LOG_DIR}/focused-localruntime-xctest.log"
  rm -rf "${RESULT_BUNDLE}"
  mkdir -p "$(dirname "${RESULT_BUNDLE}")"
  local destination="platform=iOS Simulator,id=${SIMULATOR_UDID}"
  local args=(
    -project Ambitions.xcodeproj
    -scheme "${SCHEME}"
    -configuration Debug
    -destination "${destination}"
    -derivedDataPath "${DERIVED_DATA}"
    -resultBundlePath "${RESULT_BUNDLE}"
    -skipMacroValidation
    -skipPackagePluginValidation
    -collect-test-diagnostics never
    -skip-testing:AmbitionsUITests
    -only-testing:AmbitionsTests/AmbitionsCommandExecutorTests
    -only-testing:AmbitionsTests/CommandsLeafTests
    -only-testing:AmbitionsTests/LocalRuntimeOSTransactionsOwnershipTests
    -only-testing:AmbitionsTests/RuntimeEventJournalTests
    -only-testing:AmbitionsTests/LocalRuntimeOSProjectionsTests
    -only-testing:AmbitionsTests/StorageTierTests
    -only-testing:AmbitionsTests/ObjectStateTests
    -only-testing:AmbitionsTests/ExternalWritesTests
    -only-testing:AmbitionsTests/PrivacySecurityTests
    -only-testing:AmbitionsTests/SourceAtlasPublicOnlyBoundaryGateTests
    -only-testing:AmbitionsTests/SyncContinuityTests
    -only-testing:AmbitionsTests/RuntimeDoctorTests
    -only-testing:AmbitionsTests/StoreInvariantCheckerTests
    -only-testing:AmbitionsTests/LocalRuntimeDiagnosticsTests
    -only-testing:AmbitionsTests/TrustSystemTests
    -only-testing:AmbitionsTests/CaptureRouteGraphTests
    -only-testing:AmbitionsTests/ExternalSurfaceSnapshotTests
    -only-testing:AmbitionsTests/AppIntentRoutingTests
    -only-testing:AmbitionsTests/FeatureServiceMutationAuthorityTests
    test
  )
  echo "=== focused_localruntime_xctest ==="
  printf '$ xcodebuild' > "${log_path}"
  printf ' %q' "${args[@]}" >> "${log_path}"
  printf '\n' >> "${log_path}"
  set +e
  xcodebuild "${args[@]}" 2>&1 | tee -a "${log_path}"
  local exit_code="${PIPESTATUS[0]}"
  set -u -o pipefail
  echo "focused_localruntime_xctest: exit ${exit_code}"
  record_phase "focused_localruntime_xctest" "${exit_code}" "${log_path}"
  write_status_json
  return "${exit_code}"
}

write_environment_summary

run_phase xcodegen xcodegen generate || { write_ci_summary; exit "${FIRST_FAILURE}"; }
run_phase architecture_inventory write_architecture_inventory || { write_ci_summary; exit "${FIRST_FAILURE}"; }
run_phase local_runtime_proof write_local_runtime_proof || { write_ci_summary; exit "${FIRST_FAILURE}"; }

SIMULATOR_UDID="$(select_simulator_udid)"
export SIMULATOR_UDID
echo "${SIMULATOR_UDID}" > "${OUTPUT_ROOT}/simulator-udid.txt"
run_phase simulator_boot boot_selected_simulator || { write_ci_summary; exit "${FIRST_FAILURE}"; }
run_xcode_tests || { write_ci_summary; exit "${FIRST_FAILURE}"; }

write_ci_summary
echo "GREEN_LOCAL_RUNTIME_PROOF_CI"
