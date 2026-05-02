#!/usr/bin/env bash
set -u

root="$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)"
cd "$root" || exit 1

echo "== Signature Interface anti-generic UI scan =="
echo "Scope: advisory read-only scan for generic dashboard/card/productivity drift language."
echo "Non-claim: this does not prove a surface passes visual QA or human approval."

if ! command -v rg >/dev/null 2>&1; then
  echo "YELLOW_HINT ripgrep unavailable; install rg for complete fast scan."
  exit 0
fi

rg -n "CardView|GenericCard|Dashboard|dashboard|kanban|OKR|calendar clone|chatbot|habit tracker|notes app|project management|AI confidence|AI explanation|model confidence" Native AppUI Sources docs .codex 2>/dev/null || true
echo "Anti-generic scan complete; hits require reviewer classification, not automatic failure."
