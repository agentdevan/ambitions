#!/usr/bin/env bash
set -u
ROOT="$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)"
cd "$ROOT"
echo "pxeq-visual-noise-scan: advisory"
rg -n -i "unreadable glass|heavy blur|fake AI glow|starfield|decorative gradient|visual noise|atmospheric material|translucency" docs/codex docs/audits .codex Native Sources AppUI 2>/dev/null || true
echo "YELLOW advisory scan complete"

