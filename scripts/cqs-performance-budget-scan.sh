#!/usr/bin/env bash
set -euo pipefail

ROOT="${1:-Native/Ambitions}"
STRICT="${CQS_STRICT:-0}"
PATTERN='Timer\.|CADisplayLink|onReceive|Task \{|while true|repeatForever|withAnimation|GeometryReader|LazyVStack|ScrollView|reloadAllTimelines|update\('

echo "CQS performance budget scan"
echo "Root: ${ROOT}"

set +e
rg -n --glob '*.swift' "${PATTERN}" "${ROOT}"
STATUS=$?
set -e

if [[ "${STATUS}" -eq 0 ]]; then
  echo "CQS_PERFORMANCE_BUDGET_HITS=1"
  echo "Review hits for bounded work, render cost, and background/update budgets."
  [[ "${STRICT}" == "1" ]] && exit 1
  exit 0
fi

if [[ "${STATUS}" -eq 1 ]]; then
  echo "CQS_PERFORMANCE_BUDGET_HITS=0"
  exit 0
fi

echo "CQS_PERFORMANCE_BUDGET_SCAN_ERROR=${STATUS}"
exit "${STATUS}"
