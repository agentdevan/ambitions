#!/usr/bin/env bash
set -o pipefail
set -u

LOG_DIR="output/logs"
mkdir -p "$LOG_DIR"
LOG_FILE="$LOG_DIR/build-local-$(date +%Y%m%d-%H%M%S).log"

select_destination() {
  local devices_json
  devices_json="$(xcrun simctl list -j devices available 2>/dev/null || true)"

  if [[ -z "$devices_json" ]]; then
    echo "No available simulator inventory found." >&2
    return 1
  fi

  SIMCTL_DEVICES_JSON="$devices_json" python3 - <<'PY'
import json
import os
import sys

preferred_names = [
    "iPhone 17",
    "iPhone 17 Pro",
    "iPhone 17 Pro Max",
    "iPhone 16",
    "iPhone 16 Pro",
    "iPhone 16 Pro Max",
]

data = json.loads(os.environ["SIMCTL_DEVICES_JSON"])
devices_by_runtime = data.get("devices", {})

def emit(name: str) -> None:
    print(f"platform=iOS Simulator,name={name}")
    raise SystemExit(0)

def runtime_key_matches_ios_26(runtime_key: str) -> bool:
    return "SimRuntime.iOS-26" in runtime_key

for runtime_key in sorted(devices_by_runtime):
    if not runtime_key_matches_ios_26(runtime_key):
        continue
    runtime_devices = [
        device
        for device in devices_by_runtime.get(runtime_key, [])
        if device.get("isAvailable") and str(device.get("name", "")).startswith("iPhone")
    ]
    for preferred_name in preferred_names:
        for device in runtime_devices:
            if device.get("name") == preferred_name:
                emit(preferred_name)
    if runtime_devices:
        emit(str(runtime_devices[0].get("name")))

print("No available iOS 26 iPhone simulator found.", file=sys.stderr)
raise SystemExit(1)
PY
}

echo "Generating Ambitions.xcodeproj"
xcodegen generate

destination="$(select_destination)"
echo "Using destination: $destination"
echo "Writing log: $LOG_FILE"

if command -v xcbeautify >/dev/null 2>&1; then
  xcodebuild -project Ambitions.xcodeproj -scheme Ambitions -destination "$destination" build CODE_SIGNING_ALLOWED=NO 2>&1 | tee "$LOG_FILE" | xcbeautify
  status=${PIPESTATUS[0]}
else
  xcodebuild -project Ambitions.xcodeproj -scheme Ambitions -destination "$destination" build CODE_SIGNING_ALLOWED=NO 2>&1 | tee "$LOG_FILE"
  status=${PIPESTATUS[0]}
fi

exit "$status"
