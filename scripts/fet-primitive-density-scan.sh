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

targets=(Native/Ambitions Sources AppUI docs/codex docs/AmbitionsCanon .codex/skills)

echo "-- Primitive/card/panel markers --"
rg -n "AmbitionRichPanel|HeroDecisionPanel|AppCard|HeroCard|StateDrivenMaterialPanel|RoundedRectangle|UnevenRoundedRectangle|Card|Panel|Dashboard|dashboard|metric card|progress card|component demo|debug|diagnostic|proof screen" "${targets[@]}" 2>/dev/null | head -300 || true

echo
echo "-- Nested content risk markers --"
rg -n "contentSlot|visualSlot|VStack\\(|LazyVStack\\(|ForEach\\(|ScrollView\\(|Grid|LazyVGrid|TagPill|AmbitionChip" Native/Ambitions Sources/Components 2>/dev/null | head -300 || true

echo
echo "-- Required density roles --"
rg -n "flagshipPrimary|supportCompact|detailDisclosure|receiptDrawer|listRow|settingsGroup" Native Sources AppUI docs/codex .codex 2>/dev/null | head -200 || true

echo
echo "Reviewer rule: new or materially changed primitive usage must name one density role and prove that signature objects are not generic rounded cards or unlimited panel stacks."
exit 0
