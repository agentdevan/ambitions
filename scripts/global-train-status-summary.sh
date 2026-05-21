#!/usr/bin/env bash
set -u
ROOT="$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)"
cd "$ROOT"

AUTHORITY="docs/codex/GLOBAL_BATCH_SEQUENCE.md"
AUTHORITY_JSON="docs/codex/GLOBAL_BATCH_SEQUENCE_AUTHORITY.json"
RESOLVER="scripts/ambitions-next-batch-resolver.py"

echo "global-train-status-summary.sh: Codex OS deterministic status summary"
echo "Authority: $AUTHORITY"
echo "Historical policy: all non-IOS26 batches are historical and non-runnable"
echo

python3 -m json.tool "$AUTHORITY_JSON" >/dev/null
python3 "$RESOLVER"
echo
echo "Working tree:"
git status --short
