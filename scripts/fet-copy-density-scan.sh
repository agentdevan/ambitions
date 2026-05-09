#!/usr/bin/env bash
set -u

root="$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)"
cd "$root" || exit 1

echo "== FET copy density scan =="
echo "Scope: advisory read-only scan for architecture-explaining, compliance-heavy, AI-theater, quality-claim, or above-fold copy risk."
echo "Non-claim: this does not prove final product-language quality."
echo

if ! command -v rg >/dev/null 2>&1; then
  echo "YELLOW_HINT ripgrep unavailable; install rg for complete fast scan."
  exit 0
fi

targets=(Native/Ambitions Sources AppUI docs .codex)

rg -n "local-first|on-device|inspectable|source-backed|source backed|confirmation|confirmed|no silent changes|controls.*privacy|privacy.*visible|keeps.*visible|keeps direction connected|time shapes the week|coherent backbone|architecture|implementation|infrastructure|governance|compliance|diagnostic|debug|internal|engine|runtime|model confidence|AI confidence|AI explanation|AI-powered|machine learning|LLM|premium|flagship|Apple-level|FAANG-level|10/10|world-class|production-ready|release ready|TestFlight ready|App Store ready|visually approved|accessibility approved" "${targets[@]}" 2>/dev/null | head -360 || true

echo
echo "Reviewer rule: root UI copy must be short, user-value-first, and evidence-safe. Architecture/source/governance/trust detail belongs in drawers or reports unless directly useful."
exit 0
