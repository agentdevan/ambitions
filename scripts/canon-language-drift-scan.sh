#!/usr/bin/env bash
set -u
ROOT="$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)"
cd "$ROOT" || exit

echo "canon-language-drift-scan"

pattern='next best move|your best next move|generic AI dashboard|generic habit tracker|Plan tab|Plan screen|top-level Plan|Profile tab|Insights tab|Habits tab|ACUI|Ambitions 5\.0|AI confidence|AI explanation|productivity score'
changed="$(git diff --name-only HEAD -- Native Sources AppUI docs README.md AGENTS.md .agents 2>/dev/null | tr '\n' ' ')"

if [ -n "$changed" ]; then
  # shellcheck disable=SC2086
  new_hits="$(rg -n -i "$pattern" $changed 2>/dev/null || true)"
  if [ -n "$new_hits" ]; then
    echo "YELLOW changed-file language drift candidates"
    printf '%s\n' "$new_hits" | head -80
  else
    echo "GREEN no changed-file canon language drift candidates"
  fi
else
  echo "GREEN no changed files to scan for new canon language drift"
fi

backlog="$(rg -n -i "$pattern" Native Sources AppUI docs README.md AGENTS.md .agents 2>/dev/null | head -80 || true)"
if [ -n "$backlog" ]; then
  echo "YELLOW existing backlog / guardrail hits follow"
  printf '%s\n' "$backlog"
fi

exit 0
