#!/usr/bin/env bash
set -u
ROOT="$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)"
cd "$ROOT"
echo "transformative-motion-preview-check"
rg -n "#Preview|previewDisplayName|Transformative Motion|motion preview|Reduce Motion" Native/Ambitions Sources docs/codex docs/audits 2>/dev/null || true
echo "YELLOW until SIG13/DAV12 preview gallery includes motion scenarios"
