#!/usr/bin/env bash
set -u

root="$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)"
cd "$root" || exit 1

echo "== Signature Interface file-size scan =="
echo "Scope: advisory line-count scan for Swift files under UI-bearing roots."

roots=(Native/Ambitions AppUI Sources)
for path in "${roots[@]}"; do
  [[ -d "$path" ]] || continue
  find "$path" -type f -name '*.swift' -print 2>/dev/null
done | sort | while IFS= read -r file; do
  lines=$(wc -l < "$file" | tr -d ' ')
  if [[ "$lines" -ge 1000 ]]; then
    echo "RED_REVIEW $lines $file"
  elif [[ "$lines" -ge 700 ]]; then
    echo "YELLOW_REVIEW $lines $file"
  elif [[ "$lines" -ge 400 ]]; then
    echo "SIZE_WATCH $lines $file"
  fi
done

echo "File-size scan complete; thresholds are advisory unless a batch prompt makes them blocking."
