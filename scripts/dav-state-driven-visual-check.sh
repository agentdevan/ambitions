#!/usr/bin/env bash
set -u
ROOT="$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)"
cd "$ROOT"
echo "dav-state-driven-visual-check"
rg -n "empty|overloaded|recovery|blocked|stale|private|sensitive|proof|pressure|capacity|confidence|source" Sources Native/Ambitions docs/codex docs/audits 2>/dev/null || true
echo "YELLOW advisory scan complete"

