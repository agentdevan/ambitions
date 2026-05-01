#!/usr/bin/env bash
set -u

echo "== Ambitions SwiftUI architecture scan =="
roots=(Native/Ambitions AppUI Sources)
strict=${ARCHITECTURE_SCAN_STRICT:-0}
fail=0

while IFS= read -r file; do
  lines=$(wc -l < "$file" | tr -d ' ')
  if [[ "$lines" -ge 1000 ]]; then
    echo "EXTRACTION_REQUIRED $lines $file"
    [[ "$strict" == "1" ]] && fail=1
  elif [[ "$lines" -ge 700 ]]; then
    echo "EXTRACTION_RECOMMENDED $lines $file"
  elif [[ "$lines" -ge 400 ]]; then
    echo "RESPONSIBILITY_REVIEW $lines $file"
  fi
  if grep -Eq 'ViewState|Projector|Compatibility|ScreenContract|accessibilityIdentifier|Text\("' "$file"; then
    hits=$(grep -Eo 'ViewState|Projector|Compatibility|ScreenContract|accessibilityIdentifier|Text\("' "$file" | sort -u | wc -l | tr -d ' ')
    if [[ "$hits" -ge 4 ]]; then
      echo "RESPONSIBILITY_MIX_HINT $hits $file"
    fi
  fi
done < <(find "${roots[@]}" -type f -name '*.swift' 2>/dev/null | sort)

if [[ -f Native/Ambitions/Features/Today/TodayExecutionViewState.swift ]]; then
  today_lines=$(wc -l < Native/Ambitions/Features/Today/TodayExecutionViewState.swift | tr -d ' ')
  echo "TODAY_EXECUTION_VIEW_STATE_LINES $today_lines Native/Ambitions/Features/Today/TodayExecutionViewState.swift"
fi

echo "Architecture scan is advisory unless ARCHITECTURE_SCAN_STRICT=1."
exit "$fail"
