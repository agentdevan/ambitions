#!/usr/bin/env bash
set -uo pipefail

SCHEME="${SCHEME:-Ambitions}"
DESTINATION="${DESTINATION:-}"
SIMULATOR_NAME="${SIMULATOR_NAME:-iPhone 17}"
SIMULATOR_UDID="${SIMULATOR_UDID:-}"
RUN_STAMP="${RUN_STAMP:-$(date -u +%Y%m%dT%H%M%SZ)}"
OUTPUT_ROOT="${OUTPUT_ROOT:-artifacts/strict-build-launch/${RUN_STAMP}}"
DERIVED_DATA="${OUTPUT_ROOT}/DerivedData"
LOG_DIR="${OUTPUT_ROOT}/logs"
SCREENSHOT_DIR="${OUTPUT_ROOT}/screenshots"
STATUS_JSON="${OUTPUT_ROOT}/phase-status.json"
mkdir -p "${LOG_DIR}" "${SCREENSHOT_DIR}"

PHASE_STATUS=()
FIRST_FAILURE=0

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

boot_selected_simulator() {
  xcrun simctl boot "${SIMULATOR_UDID}" || true
  xcrun simctl bootstatus "${SIMULATOR_UDID}" -b
}

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
  set -e
  echo "${phase}: exit ${exit_code}"
  record_phase "${phase}" "${exit_code}" "${log_path}"
  write_status_json
  return "${exit_code}"
}

{
  echo "run_stamp=${RUN_STAMP}"
  echo "scheme=${SCHEME}"
  echo "destination=${DESTINATION}"
  echo "simulator_name=${SIMULATOR_NAME}"
  echo "simulator_udid=${SIMULATOR_UDID}"
  echo "output_root=${OUTPUT_ROOT}"
  echo "head=$(git rev-parse HEAD 2>/dev/null || true)"
  echo "branch=$(git branch --show-current 2>/dev/null || true)"
  sw_vers 2>/dev/null || true
  xcodebuild -version 2>/dev/null || true
  xcode-select -p 2>/dev/null || true
  xcrun simctl list devices available 2>/dev/null || true
} > "${LOG_DIR}/toolchain.txt" 2>&1

if ! command -v xcodegen >/dev/null 2>&1; then
  echo "xcodegen not found" > "${LOG_DIR}/xcodegen-missing.log"
  record_phase "xcodegen_available" 127 "${LOG_DIR}/xcodegen-missing.log"
  write_status_json
  python3 scripts/ci/parse_strict_build_failures.py --root "${OUTPUT_ROOT}" || true
  exit 127
fi

run_phase xcodegen xcodegen generate || true
if [[ "${FIRST_FAILURE}" != "0" ]]; then
  python3 scripts/ci/parse_strict_build_failures.py --root "${OUTPUT_ROOT}" || true
  exit "${FIRST_FAILURE}"
fi

run_phase xcode_list xcodebuild -project Ambitions.xcodeproj -list -json || true
if [[ "${FIRST_FAILURE}" != "0" ]]; then
  python3 scripts/ci/parse_strict_build_failures.py --root "${OUTPUT_ROOT}" || true
  exit "${FIRST_FAILURE}"
fi

run_phase resolve_packages xcodebuild -project Ambitions.xcodeproj -scheme "${SCHEME}" -resolvePackageDependencies || true
if [[ "${FIRST_FAILURE}" != "0" ]]; then
  python3 scripts/ci/parse_strict_build_failures.py --root "${OUTPUT_ROOT}" || true
  exit "${FIRST_FAILURE}"
fi

SIMULATOR_UDID="$(select_simulator_udid)"
export SIMULATOR_UDID
if [[ -z "${DESTINATION}" ]]; then
  DESTINATION="platform=iOS Simulator,id=${SIMULATOR_UDID}"
fi
echo "${SIMULATOR_UDID}" > "${OUTPUT_ROOT}/simulator-udid.txt"
echo "${DESTINATION}" > "${OUTPUT_ROOT}/destination.txt"

run_phase simulator_build xcodebuild \
  -project Ambitions.xcodeproj \
  -scheme "${SCHEME}" \
  -destination "${DESTINATION}" \
  -derivedDataPath "${DERIVED_DATA}" \
  -skipPackagePluginValidation \
  -skipMacroValidation \
  CODE_SIGNING_ALLOWED=NO \
  build || true
if [[ "${FIRST_FAILURE}" != "0" ]]; then
  python3 scripts/ci/parse_strict_build_failures.py --root "${OUTPUT_ROOT}" || true
  exit "${FIRST_FAILURE}"
fi

APP_PATH="$(find "${DERIVED_DATA}/Build/Products" -name 'Ambitions.app' -type d | head -n 1)"
if [[ -z "${APP_PATH}" ]]; then
  APP_PATH="$(find "${DERIVED_DATA}/Build/Products" -name '*.app' -type d ! -name '*Tests.app' ! -name '*UITests.app' | head -n 1)"
fi
if [[ -z "${APP_PATH}" ]]; then
  echo "No built app bundle found under ${DERIVED_DATA}/Build/Products" > "${LOG_DIR}/find-app.log"
  record_phase "find_app_bundle" 2 "${LOG_DIR}/find-app.log"
  write_status_json
  python3 scripts/ci/parse_strict_build_failures.py --root "${OUTPUT_ROOT}" || true
  exit 2
fi

echo "${APP_PATH}" > "${OUTPUT_ROOT}/built-app-path.txt"
BUNDLE_ID="$(/usr/libexec/PlistBuddy -c 'Print CFBundleIdentifier' "${APP_PATH}/Info.plist" 2>/dev/null || true)"
if [[ -z "${BUNDLE_ID}" ]]; then
  echo "Unable to read CFBundleIdentifier from ${APP_PATH}/Info.plist" > "${LOG_DIR}/bundle-id.log"
  record_phase "bundle_id" 2 "${LOG_DIR}/bundle-id.log"
  write_status_json
  python3 scripts/ci/parse_strict_build_failures.py --root "${OUTPUT_ROOT}" || true
  exit 2
fi

echo "${BUNDLE_ID}" > "${OUTPUT_ROOT}/bundle-id.txt"

run_phase simulator_boot boot_selected_simulator || true
if [[ "${FIRST_FAILURE}" != "0" ]]; then
  python3 scripts/ci/parse_strict_build_failures.py --root "${OUTPUT_ROOT}" || true
  exit "${FIRST_FAILURE}"
fi

run_phase simulator_install xcrun simctl install "${SIMULATOR_UDID}" "${APP_PATH}" || true
if [[ "${FIRST_FAILURE}" != "0" ]]; then
  python3 scripts/ci/parse_strict_build_failures.py --root "${OUTPUT_ROOT}" || true
  exit "${FIRST_FAILURE}"
fi

run_phase simulator_launch xcrun simctl launch "${SIMULATOR_UDID}" "${BUNDLE_ID}" || true
if [[ "${FIRST_FAILURE}" != "0" ]]; then
  python3 scripts/ci/parse_strict_build_failures.py --root "${OUTPUT_ROOT}" || true
  exit "${FIRST_FAILURE}"
fi

sleep 4
run_phase simulator_screenshot xcrun simctl io "${SIMULATOR_UDID}" screenshot "${SCREENSHOT_DIR}/launch.png" || true
python3 scripts/ci/parse_strict_build_failures.py --root "${OUTPUT_ROOT}" || true

if [[ "${FIRST_FAILURE}" != "0" ]]; then
  exit "${FIRST_FAILURE}"
fi

echo "GREEN_SIMULATOR_LAUNCHED" > "${OUTPUT_ROOT}/strict-build-status.txt"
echo "GREEN_SIMULATOR_LAUNCHED"
