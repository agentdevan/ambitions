#!/usr/bin/env bash
set -Eeuo pipefail

REPO_ROOT="$(git rev-parse --show-toplevel 2>/dev/null || pwd -P)"
cd "$REPO_ROOT"

HELPER="scripts/sim/simctl_screenshot.sh"
SCAN_PATHS=(
  "scripts"
  "Native/AmbitionsTests"
  "Native/AmbitionsUITests"
  "validation"
  ".codex/validation"
)

if [[ ! -f "$HELPER" ]]; then
  echo "missing centralized screenshot helper: $HELPER" >&2
  exit 1
fi

SCREENSHOT_EXPORT_RE="xcrun[[:space:]]+simctl[[:space:]]+io[^[:cntrl:]]*screenshot|simctl[[:space:]]+io[^[:cntrl:]]*screenshot|simctl[[:space:]]+screenshot"

matches="$(
  rg -n "$SCREENSHOT_EXPORT_RE" "${SCAN_PATHS[@]}" \
    -g '!scripts/sim/simctl_screenshot.sh' \
    -g '!scripts/sim/simctl_screenshot_smoke.sh' \
    -g '!scripts/visual-qa/validate_screenshot_callers.sh' || true
)"

if [[ -n "$matches" ]]; then
  echo "direct simulator screenshot export callers must use $HELPER" >&2
  echo "$matches" >&2
  exit 1
fi

cat <<REPORT
Status: GREEN
Centralized helper: $HELPER
Scanned paths:
$(printf -- "- %s\n" "${SCAN_PATHS[@]}")
Direct simctl screenshot callers: none
REPORT
