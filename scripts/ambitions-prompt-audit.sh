#!/usr/bin/env bash
set -Eeuo pipefail

ROOT="$(git rev-parse --show-toplevel 2>/dev/null || pwd)"
cd "$ROOT"

if [[ ! -d prompts ]]; then
  echo "GREEN: no prompts directory"
  exit 0
fi

missing=()

while IFS= read -r file; do
  case "$file" in
    prompts/_RUNNER_REQUIRED_HEADER.md|prompts/_BATCH_TEMPLATE.md)
      continue
      ;;
    prompts/archive/*|prompts/archives/*|prompts/archived/*)
      continue
      ;;
  esac

  file_missing=0
  grep -q 'AMBITIONS_RUNNER_REQUIRED: true' "$file" || file_missing=1
  grep -q 'RUN_WITH: scripts/ambitions-codex-train.sh' "$file" || file_missing=1
  grep -q 'DIRECT_CODEX_EXECUTION:' "$file" || file_missing=1

  if [[ "$file_missing" == "1" ]]; then
    missing+=("$file")
  fi
done < <(find prompts -type f -name '*.md' | sort)

if [[ "${#missing[@]}" -gt 0 ]]; then
  echo "RED: active prompt files missing runner metadata"
  printf '%s\n' "${missing[@]}"
  exit 1
fi

echo "GREEN: all active prompt files require the Ambitions runner"
