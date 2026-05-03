#!/usr/bin/env bash
set -u
ROOT="$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)"
cd "$ROOT"
echo "dav-visual-performance-risk-scan"
rg -n "repeatForever|blur\\(|Material|TimelineView|Canvas|drawingGroup|onReceive|Timer|animation\\(" Sources Native/Ambitions 2>/dev/null || true
echo "YELLOW until DAV13 classifies rendering/battery risk"

