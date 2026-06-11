#!/usr/bin/env bash
set -euo pipefail
cd "$(git rev-parse --show-toplevel)"

mkdir -p artifacts/ui-quality-lockdown/script-output
log="artifacts/ui-quality-lockdown/script-output/uiql-banned-copy.log"
changed_log="artifacts/ui-quality-lockdown/script-output/uiql-banned-copy-changed-files.log"
pattern="best next move|next best move|Begin Focus|Start Focus|streak broken|productivity dropped|AI recommends|AI recommended|dashboard/admin|debug panel"

{
  echo "UIQL banned-copy scan"
  echo "scope=${UIQL_SCAN_SCOPE:-changed}"
  echo "head=$(git rev-parse --short HEAD)"
  echo "pattern=$pattern"
  echo
  echo "Repo-wide reference findings, for classification only:"
  rg -n "$pattern" Native Sources AppUI docs/truth AGENTS.md 2>/dev/null || true
} > "$log"

files=()
if [ "${UIQL_SCAN_SCOPE:-changed}" = "all" ]; then
  while IFS= read -r file; do files+=("$file"); done < <(git ls-files 'Native/**/*.swift' 'Sources/**/*.swift' 'AppUI/**/*.swift')
else
  while IFS= read -r file; do files+=("$file"); done < <(git diff --name-only HEAD -- Native Sources AppUI | rg '\.swift$' || true)
fi

{
  echo "UIQL changed-source banned-copy findings"
  echo "files=${#files[@]}"
  if [ "${#files[@]}" -eq 0 ]; then
    echo "PASS no changed Swift source files in UIQL scope"
    exit 0
  fi
  rg -n "$pattern" "${files[@]}" 2>/dev/null || true
} > "$changed_log"

if rg -n "$pattern" "${files[@]}" >/tmp/uiql-banned-copy.$$ 2>/dev/null; then
  cat /tmp/uiql-banned-copy.$$ >> "$changed_log"
  rm -f /tmp/uiql-banned-copy.$$
  echo "FAIL changed Swift source contains UIQL-banned copy. See $changed_log"
  exit 1
fi
rm -f /tmp/uiql-banned-copy.$$
echo "PASS changed Swift source contains no UIQL-banned copy. Logs: $log $changed_log"
