#!/usr/bin/env bash
set -u
ROOT="$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)"
cd "$ROOT"
name="$(basename "$0")"
echo "$name: Codex OS deterministic advisory scan"
echo "Focused lanes: app shell/navigation, capture, memory, receipts, trust/privacy, accessibility, onboarding, today, plan, goals, you, external routing, widgets/shortcuts when present"
