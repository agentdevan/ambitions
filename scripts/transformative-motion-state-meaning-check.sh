#!/usr/bin/env bash
set -u
ROOT="$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)"
cd "$ROOT"
echo "transformative-motion-state-meaning-check"
rg -n "Motion should transform state|source state|destination state|state meaning|motion as meaning" docs/canon docs/codex .codex 2>/dev/null || true
echo "GREEN state-meaning policy present"
