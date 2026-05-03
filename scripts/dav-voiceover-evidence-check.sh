#!/usr/bin/env bash
set -u
ROOT="$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)"
cd "$ROOT"
echo "dav-voiceover-evidence-check"
rg -n "VoiceOver|accessibilityLabel|accessibilityElement|accessibilityIdentifier|accessibilitySortPriority" Sources Native/Ambitions docs/codex docs/audits 2>/dev/null || true
echo "YELLOW until DAV11 records VoiceOver evidence"

