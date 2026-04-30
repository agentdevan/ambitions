#!/usr/bin/env bash
set -u
shopt -s globstar nullglob 2>/dev/null || true

LOG_DIR="docs/audits/doc-qa"
mkdir -p "$LOG_DIR"

timestamp="$(date +%Y%m%d-%H%M%S)"
strict="${DOC_QA_STRICT:-0}"
overall=0

run_and_log() {
  local name="$1"
  shift
  local log="$LOG_DIR/${timestamp}-${name}.log"

  echo "Running $name"
  "$@" >"$log" 2>&1
  local status=$?
  local lines
  lines="$(wc -l < "$log" | tr -d ' ')"
  if [[ "$lines" -le 220 ]]; then
    cat "$log"
  else
    sed -n '1,160p' "$log"
    echo "... output truncated in console; full log has $lines lines ..."
    tail -60 "$log"
  fi
  echo "Log: $log"
  echo
  return "$status"
}

echo "Ambitions docs QA"
echo "================="
echo "DOC_QA_STRICT=$strict"
echo

run_and_log "stale-guidance" rg -n --hidden --glob '!/.git/**' 'Ambitions_2_0|v2 is now active|Batch 61|Waves 1-19|Master Product and Visual System Spec v2 is now the active|Batch 89-120' AGENTS.md README.md docs/README.md docs/codex docs/canon/Ambitions_3_0_* docs/canon/README.md
stale_status=$?
if [[ "$stale_status" -gt 1 ]]; then
  overall=1
fi

run_and_log "deprecated-language" rg -n --hidden --glob '!/.git/**' 'Start Focus|Focus Session|best next move|next best move|AI confidence|productivity score|profile tab|insights tab|habits tab|overdue|failed|missed' .
deprecated_status=$?
if [[ "$deprecated_status" -gt 1 ]]; then
  overall=1
fi

if command -v markdownlint-cli2 >/dev/null 2>&1; then
  run_and_log "markdownlint" markdownlint-cli2 "README.md" "AGENTS.md" "docs/**/*.md" ".codex/**/*.md" "Native/**/AGENTS.md" "#docs/archive" "#.codex/skills/*/SKILL.md" "#.agents" "#node_modules" "#.git" "#Ambitions.xcodeproj"
  markdown_status=$?
  if [[ "$strict" == "1" && "$markdown_status" -ne 0 ]]; then
    overall=1
  fi
else
  echo "SKIP: markdownlint-cli2 is not installed."
  [[ "$strict" == "1" ]] && overall=1
fi

if command -v lychee >/dev/null 2>&1; then
  run_and_log "lychee" lychee --no-progress --accept 200,204,206,429 --max-concurrency 4 README.md docs/**/*.md
  lychee_status=$?
  if [[ "$strict" == "1" && "$lychee_status" -ne 0 ]]; then
    overall=1
  elif [[ "$lychee_status" -ne 0 ]]; then
    echo "ADVISORY: lychee reported link/network failures; not failing because DOC_QA_STRICT is not 1."
  fi
else
  echo "SKIP: lychee is not installed."
  [[ "$strict" == "1" ]] && overall=1
fi

if [[ "$overall" -eq 0 ]]; then
  echo "Docs QA completed. Advisory findings may remain in logs."
else
  echo "Docs QA failed under current strictness."
fi

exit "$overall"
