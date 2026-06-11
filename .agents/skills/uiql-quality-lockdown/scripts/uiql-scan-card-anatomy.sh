#!/usr/bin/env bash
set -euo pipefail
cd "$(git rev-parse --show-toplevel)"

mkdir -p artifacts/ui-quality-lockdown/script-output
log="artifacts/ui-quality-lockdown/script-output/uiql-card-anatomy.log"
changed_log="artifacts/ui-quality-lockdown/script-output/uiql-card-anatomy-changed-files.log"
pattern="Card|HeroCard|SurfaceCard|ModuleCard|Tile|Dashboard|KPI|scoreboard|score card|card stack"

{
  echo "UIQL card-anatomy scan"
  echo "scope=${UIQL_SCAN_SCOPE:-changed}"
  echo "head=$(git rev-parse --short HEAD)"
  echo "pattern=$pattern"
  echo
  echo "Repo-wide reference findings, for classification only:"
  rg -n "$pattern" Native/Ambitions Sources AppUI 2>/dev/null || true
} > "$log"

files=()
if [ "${UIQL_SCAN_SCOPE:-changed}" = "all" ]; then
  while IFS= read -r file; do files+=("$file"); done < <(git ls-files 'Native/Ambitions/**/*.swift' 'Sources/**/*.swift' 'AppUI/**/*.swift')
else
  while IFS= read -r file; do files+=("$file"); done < <(git diff --name-only HEAD -- Native/Ambitions Sources AppUI | rg '\.swift$' || true)
fi

{
  echo "UIQL changed-source card-anatomy findings"
  echo "files=${#files[@]}"
  if [ "${#files[@]}" -eq 0 ]; then
    echo "PASS no changed Swift source files in UIQL scope"
    exit 0
  fi
  echo
  echo "Whole-file reference findings in changed files, for classification only:"
  rg -n "$pattern" "${files[@]}" 2>/dev/null || true
  echo
  echo "Added-line blocking findings:"
  if [ "${UIQL_SCAN_SCOPE:-changed}" = "all" ]; then
    rg -n "$pattern" "${files[@]}" 2>/dev/null || true
  else
    git diff -U0 HEAD -- "${files[@]}" | rg "^\\+[^+].*($pattern)" || true
  fi
} > "$changed_log"

tmp="/tmp/uiql-card-anatomy.$$"
if [ "${UIQL_SCAN_SCOPE:-changed}" = "all" ]; then
  rg -n "$pattern" "${files[@]}" > "$tmp" 2>/dev/null || true
else
  git diff -U0 HEAD -- "${files[@]}" | rg "^\\+[^+].*($pattern)" > "$tmp" 2>/dev/null || true
fi
if [ -s "$tmp" ]; then
  cat "$tmp" >> "$changed_log"
  rm -f /tmp/uiql-card-anatomy.$$
  echo "FAIL changed Swift source adds unclassified card/list/dashboard anatomy terms. See $changed_log"
  exit 1
fi
rm -f /tmp/uiql-card-anatomy.$$
echo "PASS changed Swift source adds no UIQL card-anatomy blockers. Logs: $log $changed_log"
