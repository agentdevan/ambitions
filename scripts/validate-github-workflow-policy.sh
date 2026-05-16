#!/usr/bin/env bash
set -euo pipefail

ROOT="${1:-.}"
cd "$ROOT"

WORKFLOWS_DIR=".github/workflows"
status=0

if [[ ! -d "$WORKFLOWS_DIR" ]]; then
  echo 'GREEN: .github/workflows is absent; no hosted workflow can auto-run.'
  exit 0
fi

shopt -s nullglob
workflow_files=("$WORKFLOWS_DIR"/*.yml "$WORKFLOWS_DIR"/*.yaml)

if [[ ${#workflow_files[@]} -eq 0 ]]; then
  echo 'GREEN: .github/workflows exists but contains no YAML workflows.'
  exit 0
fi

for file in "${workflow_files[@]}"; do
  echo "Inspecting $file"
  if grep -Eq '^on:[[:space:]]*\[[^]]*(push|pull_request)' "$file"; then
    echo "RED: $file has inline push/pull_request trigger" >&2
    status=1
  fi
  if grep -Eq '^[[:space:]]+(push|pull_request):[[:space:]]*$' "$file"; then
    echo "RED: $file has push/pull_request trigger block" >&2
    status=1
  fi
  if ! grep -Eq 'workflow_dispatch:' "$file"; then
    echo "YELLOW: $file does not contain workflow_dispatch" >&2
  fi
done

if [[ $status -eq 0 ]]; then
  echo 'GitHub workflow policy validation: GREEN/YELLOW-compatible'
else
  echo 'GitHub workflow policy validation: RED' >&2
fi

exit "$status"
