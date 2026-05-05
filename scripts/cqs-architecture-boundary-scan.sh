#!/usr/bin/env bash
set -euo pipefail

ROOT="${1:-Native/Ambitions}"
STRICT="${CQS_STRICT:-0}"

echo "CQS architecture boundary scan"
echo "Root: ${ROOT}"

TMP_OUTPUT="$(mktemp)"
trap 'rm -f "${TMP_OUTPUT}"' EXIT

set +e
{
  rg -n --glob '*.swift' '^import SwiftUI' "${ROOT}/Domain" 2>/dev/null
  rg -n --glob '*.swift' '^import SwiftData' "${ROOT}/Features" 2>/dev/null
  find "${ROOT}" -name '*.swift' -type f -print0 2>/dev/null |
    xargs -0 wc -l 2>/dev/null |
    awk '$1 > 1200 && $2 != "total" { print $0 }'
} | tee "${TMP_OUTPUT}"
STATUS=${PIPESTATUS[0]}
set -e

if [[ "${STATUS}" -gt 1 ]]; then
  echo "CQS_ARCHITECTURE_SCAN_ERROR=${STATUS}"
  exit "${STATUS}"
fi

if [[ -s "${TMP_OUTPUT}" ]]; then
  echo "CQS_ARCHITECTURE_HITS=1"
  [[ "${STRICT}" == "1" ]] && exit 1
  exit 0
else
  echo "CQS_ARCHITECTURE_HITS=0"
  exit 0
fi
