#!/usr/bin/env bash
set -u
ROOT="$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)"
cd "$ROOT"
name="$(basename "$0")"
echo "$name: Codex OS deterministic advisory scan"
latest=$(ls -t docs/audits/*red* docs/audits/*Red* 2>/dev/null | head -1 || true)
echo "Latest Red report: ${latest:-none found}"
echo "Suggested repair: A source/dependency ledger, B focused proof target, C narrow execution only after A/B Green. Stop on data loss, source-truth corruption, privacy/security ambiguity, compatibility break, or false release claim."
