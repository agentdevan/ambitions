#!/usr/bin/env bash
set -u
ROOT="$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)"
cd "$ROOT"
echo "sig-surface-polish-check"
rg -n "photo-matched|premium|product-still|material depth|soft edge|Mission Control|Personal System Center" docs/audits docs/canon docs/codex Native/Ambitions Sources 2>/dev/null || true
echo "YELLOW until future SIG surface batches provide rendered evidence"
