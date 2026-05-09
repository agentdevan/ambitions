#!/usr/bin/env bash
set -u

root="$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)"
cd "$root" || exit 1

echo "== FET first viewport budget scan =="
echo "Scope: advisory read-only scan for first-viewport density risk."
echo "Non-claim: static scan hints do not prove visual quality, screenshots, accessibility, or release readiness."
echo

if ! command -v rg >/dev/null 2>&1; then
  echo "YELLOW_HINT ripgrep unavailable; install rg for complete fast scan."
  exit 0
fi

files=$(git diff --name-only -- 'Native/**/*.swift' 'Sources/**/*.swift' 'AppUI/**/*.swift' 'docs/**/*.md' 2>/dev/null || true)
if [[ -z "$files" ]]; then
  files=$(printf "%s\n" \
    Native/Ambitions/App/AmbitionsRootView.swift \
    Native/Ambitions/Features/Today/TodayScreen.swift \
    Native/Ambitions/Features/Today/TodayPanels.swift \
    Native/Ambitions/Features/Today/TodayDayRailPanels.swift \
    Native/Ambitions/Features/Goals/GoalsScreen.swift \
    Native/Ambitions/Features/Captures/CapturesScreen.swift \
    Native/Ambitions/Features/Plan/PlanScreen.swift \
    Native/Ambitions/Features/Profile/ProfileScreen.swift \
    Native/Ambitions/Features/Profile/ProfileRootSurface.swift \
    Sources/Components/RichPanelPrimitives.swift)
  echo "No changed Swift UI files detected; scanning canonical top-level owner hints."
fi

while IFS= read -r file; do
  [[ -f "$file" ]] || continue
  case "$file" in
    *.swift)
      chips=$(rg -n "Chip|chip|Pill|pill|TagPill|Badge|badge" "$file" | wc -l | tr -d ' ')
      body_text=$(rg -n "Text\\(|Label\\(" "$file" | wc -l | tr -d ' ')
      panels=$(rg -n "AppCard|HeroCard|AmbitionRichPanel|HeroDecisionPanel|Panel|Card|SectionHeader|VStack|LazyVStack" "$file" | wc -l | tr -d ' ')
      primary_markers=$(rg -n "Hero|Primary|StartHere|LifeShape|Composer|Constellation|UserSystem|PersonalSystem|Reality" "$file" | wc -l | tr -d ' ')
      echo "FET_VIEWPORT_HINT file=$file primary_markers=$primary_markers support_panel_stack_markers=$panels chips_or_pills=$chips text_or_label_calls=$body_text"
      if [[ "$chips" -gt 20 || "$panels" -gt 40 || "$body_text" -gt 80 ]]; then
        echo "YELLOW_DENSITY_RISK $file has high static density markers; UI batches must prove first viewport budget with rendered evidence."
      fi
      ;;
    *.md)
      rg -n "first viewport|above the fold|primary object|chip|body-copy|stacked|generic panel|architecture copy" "$file" || true
      ;;
  esac
done <<< "$files"

echo
echo "Hard Red mapping for UI-touching batches: >1 primary object, >2 support objects, >4 chips, >12 body-copy lines, >1 floating control, >1 bottom navigation system, nested primary card stack, or architecture copy above fold."
exit 0
