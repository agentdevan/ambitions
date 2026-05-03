#!/usr/bin/env bash
set -u
ROOT="$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)"
cd "$ROOT"
name="$(basename "$0")"
echo "$name: Codex OS deterministic advisory scan"
if git diff --name-only HEAD -- | rg -q '^(Native/.*\.swift|Sources/.*\.swift|AppUI/Sources/.*\.swift)$'; then echo "RED production Swift touched"; exit 1; fi
echo "GREEN no production Swift touched"
