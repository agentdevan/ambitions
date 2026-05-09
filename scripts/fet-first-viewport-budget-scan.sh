#!/usr/bin/env bash
set -u

root="$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)"
cd "$root" || exit 1

echo "== FET first viewport budget scan =="
echo "Scope: advisory read-only scan for first-viewport density risk in touched frontend files."
echo "Non-claim: this does not prove visual quality, screenshots, accessibility, or release readiness."
echo

if ! command -v rg >/dev/null 2>&1; then
  echo "YELLOW_HINT ripgrep unavailable; install rg for complete fast scan."
  exit 0
fi

files=$(git diff --name-only -- 'Native/**/*.swift' 'Sources/**/*.swift' 'AppUI/**/*.swift' 'docs/**/*.md' 2>/dev/null || true)
if [[ -z "$files" ]]; then
  echo "No changed frontend/doc files detected in working tree."
  exit 0
fi

echo "$files" | while IFS= read -r file; do
  [[ -f "$file" ]] || continue
  case "$file" in
    *.swift)
      chips=$(rg -n "Chip|chip|Pill|pill|Tag|tag|Badge|badge" "$file" | wc -l | tr -d ' ')
      bodies=$(rg -n "Text\\(|Label\\(" "$file" | wc -l | tr -d ' ')
      cards=$(rg -n "Card|Panel|Hero|Section|VStack|LazyVStack" "$file" | wc -l | tr -d ' ')
      echo "FET_VIEWPORT_HINT $file chips_or_pills=$chips text_or_label_calls=$bodies card_panel_stack_markers=$cards"
      ;;
    *.md)
      rg -n "first viewport|above the fold|primary object|chip|body-copy|stacked|generic panel" "$file" || true
      ;;
  esac
done

echo "Review hints manually. UI-touching batches are hard Red if screenshot evidence shows >4 chips above fold, >12 body-copy lines above fold, more than one primary object, or unlimited nested primary content."
