#!/usr/bin/env bash
set -u
ROOT="$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)"
cd "$ROOT"
name="$(basename "$0")"
echo "$name: Codex OS deterministic advisory scan"
required=("Batch Identity" "Active 4.0 Status" "Purpose" "User-Visible Outcome" "Source Truth" "Allowed Files" "Forbidden Files" "Kernel Ownership" "Dependencies" "Privacy" "Accessibility" "Evidence Requirements" "Validation Commands" "Green Criteria" "Yellow Criteria" "Red Criteria" "Stop Conditions" "Commit Message" "Next Safe Path")
status=0
for f in docs/codex/batches/EB*.md; do for s in "${required[@]}"; do rg -q "$s" "$f" || { echo "YELLOW $f missing $s"; status=1; }; done; done
[ "$status" -eq 0 ] && echo "GREEN EB prompts include required markers" || true
