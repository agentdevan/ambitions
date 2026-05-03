#!/usr/bin/env bash
set -u
ROOT="$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)"
cd "$ROOT"
echo "sig-accessibility-evidence-check"
rg -n "VoiceOver|Dynamic Type|accessibility|accessibilityLabel|accessibilityIdentifier|non-color|motor" Native/Ambitions Sources docs/canon docs/codex docs/audits .codex 2>/dev/null || true
echo "YELLOW until SIG15 records final accessibility/motion closeout"
