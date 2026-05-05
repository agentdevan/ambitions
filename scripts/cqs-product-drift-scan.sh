#!/usr/bin/env bash
set -euo pipefail

ROOT="${1:-.}"
STRICT="${CQS_STRICT:-0}"
PATTERN='dashboard|habit tracker|streak|inbox|notes app|chatbot|AI confidence|calendar clone|productivity score|KPI|OKR|generic productivity|task board'

echo "CQS product drift scan"
echo "Root: ${ROOT}"

set +e
rg -n -i --hidden --glob '!/.git/**' --glob '!Ambitions.xcodeproj/**' "${PATTERN}" "${ROOT}"
STATUS=$?
set -e

if [[ "${STATUS}" -eq 0 ]]; then
  echo "CQS_PRODUCT_DRIFT_HITS=1"
  [[ "${STRICT}" == "1" ]] && exit 1
  exit 0
fi

if [[ "${STATUS}" -eq 1 ]]; then
  echo "CQS_PRODUCT_DRIFT_HITS=0"
  exit 0
fi

echo "CQS_PRODUCT_DRIFT_SCAN_ERROR=${STATUS}"
exit "${STATUS}"
