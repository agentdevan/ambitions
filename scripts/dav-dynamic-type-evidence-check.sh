#!/usr/bin/env bash
set -u
ROOT="$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)"
cd "$ROOT"
echo "dav-dynamic-type-evidence-check"
rg -n "Dynamic Type|dynamicType|sizeCategory|font\\(" Sources Native/Ambitions docs/codex docs/audits 2>/dev/null || true
echo "YELLOW until DAV11 records Dynamic Type evidence"

