#!/usr/bin/env bash
set -u

root="$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)"
cd "$root" || exit 1

echo "== FET copy density scan =="
echo "Scope: advisory read-only scan for architecture-explaining, compliance-heavy, AI-theater, or above-fold copy risk."
echo "Non-claim: this does not prove final product language quality."
echo

if ! command -v rg >/dev/null 2>&1; then
  echo "YELLOW_HINT ripgrep unavailable; install rg for complete fast scan."
  exit 0
fi

rg -n "architecture|implementation|infrastructure|compliance|diagnostic|debug|internal|engine|runtime|model confidence|AI confidence|AI explanation|AI-powered|machine learning|LLM|premium|flagship|Apple-level|FAANG-level|10/10|world-class|release ready|TestFlight ready|App Store ready|visually approved|accessibility approved" Native Sources AppUI docs .codex 2>/dev/null | head -300 || true

echo "Copy density scan complete; output is capped at 300 hits. UI-touching batches are hard Red when root UI explains internal architecture instead of user value or quality claims outrun screenshot/rubric evidence."
