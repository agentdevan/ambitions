#!/usr/bin/env bash
set -u
ROOT="$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)"
cd "$ROOT"
name="$(basename "$0")"
echo "$name: Codex OS deterministic advisory scan"
report=$(ls -t docs/audits/*external-brain*report*.md docs/audits/*eb01*report*.md 2>/dev/null | head -1 || true)
if [ -z "$report" ]; then echo "YELLOW no EB batch evidence package found yet"; exit 0; fi
for section in "Source Truth" "Files" "Behavior" "Tests" "Privacy" "Accessibility" "Release" "Yellow" "Red" "Next"; do rg -q "$section" "$report" || echo "YELLOW missing evidence section hint: $section in $report"; done
echo "GREEN/YELLOW latest EB report evidence package scan complete"
