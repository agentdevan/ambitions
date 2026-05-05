#!/usr/bin/env bash
set -euo pipefail

ROOT="${1:-.}"
STRICT="${CQS_STRICT:-0}"
PATTERN='TODO|FIXME|stub|placeholder|Generic(Card|View|Panel)|Helper|Manager|Coordinator|AI confidence|AI explanation|fake AI|productivity score'

echo "CQS prompt-built smell scan"
echo "Root: ${ROOT}"

set +e
rg -n --hidden --glob '!/.git/**' --glob '!Ambitions.xcodeproj/**' "${PATTERN}" "${ROOT}"
STATUS=$?
set -e

if [[ "${STATUS}" -eq 0 ]]; then
  echo "CQS_PROMPT_SMELL_HITS=1"
  [[ "${STRICT}" == "1" ]] && exit 1
  exit 0
fi

if [[ "${STATUS}" -eq 1 ]]; then
  echo "CQS_PROMPT_SMELL_HITS=0"
  exit 0
fi

echo "CQS_PROMPT_SMELL_SCAN_ERROR=${STATUS}"
exit "${STATUS}"
