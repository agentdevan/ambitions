#!/usr/bin/env bash
set -u
ROOT="$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)"
cd "$ROOT"
name="$(basename "$0")"
echo "$name: Codex OS deterministic advisory scan"
changed=$(git diff --name-only HEAD --)
if echo "$changed" | rg -q '^(Native/|Sources/|AppUI/Sources/|project.yml|Package.resolved|\.github/workflows/|.*\.xcodeproj|.*PrivacyInfo\.xcprivacy)'; then echo "RED forbidden boundary touched"; echo "$changed" | rg '^(Native/|Sources/|AppUI/Sources/|project.yml|Package.resolved|\.github/workflows/|.*\.xcodeproj|.*PrivacyInfo\.xcprivacy)'; exit 1; fi
echo "GREEN changed-file boundary contains no forbidden production families"
