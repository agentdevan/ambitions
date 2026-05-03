#!/usr/bin/env bash
set -u
ROOT="$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)"
cd "$ROOT"
echo "dav-reduce-motion-check"
rg -n "accessibilityReduceMotion|reduceMotion|Reduce Motion" Sources Native/Ambitions docs/codex docs/audits 2>/dev/null || true
echo "YELLOW until DAV10/DAV11 closeout classifies all motion"

