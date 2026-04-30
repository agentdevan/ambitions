#!/usr/bin/env bash
set -o pipefail
set -u

LOG_DIR="output/logs"
mkdir -p "$LOG_DIR"
LOG_FILE="$LOG_DIR/test-local-$(date +%Y%m%d-%H%M%S).log"

select_destination() {
  local preferred=("iPhone 17" "iPhone 16")
  local devices
  devices="$(xcrun simctl list devices available 2>/dev/null || true)"

  for name in "${preferred[@]}"; do
    if printf "%s\n" "$devices" | grep -Fq "$name ("; then
      echo "platform=iOS Simulator,name=$name"
      return 0
    fi
  done

  local fallback
  fallback="$(printf "%s\n" "$devices" | sed -n 's/^[[:space:]]*\(iPhone[^()]*\) (.*/\1/p' | head -1 | sed 's/[[:space:]]*$//')"
  if [[ -z "$fallback" ]]; then
    echo "No available iPhone simulator found." >&2
    return 1
  fi

  echo "platform=iOS Simulator,name=$fallback"
}

echo "Generating Ambitions.xcodeproj"
xcodegen generate

destination="$(select_destination)"
echo "Using destination: $destination"
echo "Writing log: $LOG_FILE"
echo "Note: the FAANG handoff report records known full UI smoke failures. Do not upgrade readiness claims from this command alone."

if command -v xcbeautify >/dev/null 2>&1; then
  xcodebuild -project Ambitions.xcodeproj -scheme Ambitions -destination "$destination" test CODE_SIGNING_ALLOWED=NO 2>&1 | tee "$LOG_FILE" | xcbeautify
  status=${PIPESTATUS[0]}
else
  xcodebuild -project Ambitions.xcodeproj -scheme Ambitions -destination "$destination" test CODE_SIGNING_ALLOWED=NO 2>&1 | tee "$LOG_FILE"
  status=${PIPESTATUS[0]}
fi

if [[ "$status" -ne 0 ]]; then
  echo "test-local failed. Check $LOG_FILE and classify whether failures are known UI smoke debt, wrapper/tooling issues, or new regressions."
fi

exit "$status"
