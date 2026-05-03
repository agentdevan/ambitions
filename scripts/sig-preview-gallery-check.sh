#!/usr/bin/env bash
set -u
ROOT="$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)"
cd "$ROOT"
echo "sig-preview-gallery-check"
rg -n "#Preview|previewDisplayName|large type|Reduce Motion|proof|blocked|overloaded|recovery|stale memory|rejected memory" Native/Ambitions Sources docs/codex docs/audits 2>/dev/null || true
echo "YELLOW until SIG13 preview gallery closeout is complete"
