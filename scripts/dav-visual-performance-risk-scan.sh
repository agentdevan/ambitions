#!/usr/bin/env bash
set -u
ROOT="$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)"
cd "$ROOT"
echo "dav-visual-performance-risk-scan"
rg -n "repeatForever|blur\\(|Material|TimelineView|Canvas|drawingGroup|onReceive|Timer|animation\\(" Sources Native/Ambitions 2>/dev/null || true

report="docs/audits/dav13-visual-performance-rendering-battery-risk-report.md"
required=(
  "TimelineView"
  "Canvas"
  "blur"
  "repeatForever"
  "Reduce Motion"
  "battery"
  "rendering"
  "fallback"
)

missing=0
if [[ ! -f "$report" ]]; then
  echo "RED missing DAV13 performance risk report: $report"
  missing=1
else
  for pattern in "${required[@]}"; do
    if ! rg -n "$pattern" "$report" >/dev/null 2>&1; then
      echo "RED missing DAV13 risk classification term: $pattern"
      missing=1
    fi
  done
fi

if [[ "$missing" -eq 0 ]]; then
  echo "GREEN DAV13 rendering and battery risk classification present"
else
  echo "RED DAV13 rendering and battery risk classification incomplete"
fi
exit "$missing"
