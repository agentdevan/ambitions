#!/usr/bin/env bash
set -u
ROOT="$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)"
cd "$ROOT"
echo "pxeq-static-ui-drift-scan: advisory"
rg -n -i "static UI|static screen|documentation-driven UI|lifeless|placeholder UI|wire up later|visual only" docs/codex docs/audits .codex Native Sources AppUI 2>/dev/null || true
echo "YELLOW advisory scan complete"

