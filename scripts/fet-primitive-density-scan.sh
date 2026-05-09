#!/usr/bin/env bash
set -u

root="$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)"
cd "$root" || exit 1

echo "== FET primitive density scan =="
echo "Scope: advisory read-only scan for generic card/panel/list/dashboard drift and signature-object misuse."
echo "Non-claim: this does not prove a primitive is Ambitions-native or visually approved."
echo

if ! command -v rg >/dev/null 2>&1; then
  echo "YELLOW_HINT ripgrep unavailable; install rg for complete fast scan."
  exit 0
fi

rg -n "AppCard|CardView|GenericCard|card stack|stacked card|Panel|dashboard|Dashboard|metric card|progress card|rounded rectangle|RoundedRectangle|component demo|debug|diagnostic|proof screen|kanban|calendar clone|habit tracker|task list|AI wrapper|chatbot" Native Sources AppUI docs .codex 2>/dev/null | head -300 || true

echo "Primitive density scan complete; output is capped at 300 hits. Hits require reviewer classification. A signature object becoming a generic rounded card is hard Red for UI-touching work."
