#!/usr/bin/env bash
set -euo pipefail

ROOT="$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)"
cd "${ROOT}"

SIMULATOR_NAME="${AMBITIONS_CI_SIMULATOR_NAME:-iPhone 17}"
SIM_DESTINATION="${AMBITIONS_SIM_DESTINATION:-}"

if [[ -z "${SIM_DESTINATION}" ]]; then
  if command -v xcrun >/dev/null 2>&1 && xcrun simctl list devices available | grep -q "${SIMULATOR_NAME}"; then
    SIM_DESTINATION="platform=iOS Simulator,name=${SIMULATOR_NAME}"
  elif command -v xcrun >/dev/null 2>&1; then
    RESOLVED_NAME="$(xcrun simctl list devices available | awk -F '[()]' '/iPhone/ { gsub(/^[[:space:]]+|[[:space:]]+$/, "", $1); print $1; exit }')"
    if [[ -n "${RESOLVED_NAME}" ]]; then
      SIM_DESTINATION="platform=iOS Simulator,name=${RESOLVED_NAME}"
    fi
  fi
fi

echo "Ambitions Swift 6 final gate"
echo "Root: ${ROOT}"
echo "Simulator destination: ${SIM_DESTINATION:-unresolved}"
echo "Code signing: simulator default"

python3 scripts/ambitions-swift6-modernization-scan.py --self-test
python3 tools/tests/test_ambitions_swift6_modernization_scan.py
python3 scripts/ambitions-swift6-modernization-scan.py . --strict

if ! command -v xcodegen >/dev/null 2>&1; then
  echo "xcodegen is required for full Swift 6 final gate. Install xcodegen, then rerun." >&2
  exit 1
fi

if ! command -v xcodebuild >/dev/null 2>&1; then
  echo "xcodebuild is required for full Swift 6 final gate. Run on macOS with Xcode installed." >&2
  exit 1
fi

if [[ -z "${SIM_DESTINATION}" ]]; then
  echo "No available iPhone simulator destination resolved." >&2
  xcrun simctl list devices available || true
  exit 1
fi

xcodegen generate

xcodebuild build \
  -project Ambitions.xcodeproj \
  -scheme Ambitions \
  -destination "${SIM_DESTINATION}"

xcodebuild test \
  -project Ambitions.xcodeproj \
  -scheme Ambitions \
  -destination "${SIM_DESTINATION}" \
  -only-testing:AmbitionsTests/StorageMigrationPlanScaffoldTests \
  -only-testing:AmbitionsTests/StorageMigrationExecutionReadinessTestingTests \
  -only-testing:AmbitionsTests/AppIntentRoutingTests \
  -only-testing:AmbitionsTests/ExternalActionCommandServiceTests \
  -only-testing:AmbitionsTests/ExternalSurfaceControlContractsTests

echo "AMBITIONS_SWIFT6_FINAL_GATE_STATUS=GREEN"
