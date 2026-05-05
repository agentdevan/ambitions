#!/usr/bin/env bash
set -euo pipefail

ROOT="${1:-Native/Ambitions}"
STRICT="${CQS_STRICT:-0}"
PATTERN='withAnimation|animation\(|matchedGeometryEffect|symbolEffect|foregroundColor\(|foregroundStyle\(|accessibilityHidden\(true\)|accessibilityLabel'

echo "CQS accessibility motion scan"
echo "Root: ${ROOT}"

set +e
rg -n --glob '*.swift' "${PATTERN}" "${ROOT}"
STATUS=$?
set -e

if [[ "${STATUS}" -eq 0 ]]; then
  echo "CQS_ACCESSIBILITY_MOTION_HITS=1"
  echo "Review hits for labels, color-only meaning, and Reduce Motion coverage."
  [[ "${STRICT}" == "1" ]] && exit 1
  exit 0
fi

if [[ "${STATUS}" -eq 1 ]]; then
  echo "CQS_ACCESSIBILITY_MOTION_HITS=0"
  exit 0
fi

echo "CQS_ACCESSIBILITY_MOTION_SCAN_ERROR=${STATUS}"
exit "${STATUS}"
