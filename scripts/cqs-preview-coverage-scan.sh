#!/usr/bin/env bash
set -euo pipefail

ROOT="${1:-Native/Ambitions}"
STRICT="${CQS_STRICT:-0}"
PATTERN='#Preview|PreviewProvider|loading|empty|privacy|private details|stale|blocked|recovery|overloaded|Dynamic Type|Reduce Motion'

echo "CQS preview coverage scan"
echo "Root: ${ROOT}"

set +e
rg -n --glob '*.swift' "${PATTERN}" "${ROOT}"
STATUS=$?
set -e

if [[ "${STATUS}" -eq 0 ]]; then
  echo "CQS_PREVIEW_COVERAGE_HITS=1"
  echo "Review whether touched surfaces cover required states."
  [[ "${STRICT}" == "1" ]] && exit 1
  exit 0
fi

if [[ "${STATUS}" -eq 1 ]]; then
  echo "CQS_PREVIEW_COVERAGE_HITS=0"
  exit 0
fi

echo "CQS_PREVIEW_COVERAGE_SCAN_ERROR=${STATUS}"
exit "${STATUS}"
