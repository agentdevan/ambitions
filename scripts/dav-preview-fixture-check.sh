#!/usr/bin/env bash
set -u
ROOT="$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)"
cd "$ROOT"
echo "dav-preview-fixture-check"
rg -n "overloaded|recovery|Reduce Motion|Dynamic Type|stale memory|rejected memory|routed capture|goal with proof|goal with blocker|Still Counts" Native/Ambitions/PreviewSupport Sources/Previews docs/audits docs/codex 2>/dev/null || true
echo "YELLOW until DAV12 fixture closeout is complete"

