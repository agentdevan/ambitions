#!/usr/bin/env bash
set -u
ROOT="$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)"
cd "$ROOT"
echo "sig-performance-risk-scan"
rg -n "blur\\(|shadow\\(|TimelineView|matchedGeometryEffect|drawingGroup|Material|performance|battery|overdraw" Native/Ambitions Sources docs/canon docs/codex docs/audits .codex 2>/dev/null || true
echo "YELLOW until SIG14 performance and battery QA runs"
