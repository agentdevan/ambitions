#!/usr/bin/env bash
set -euo pipefail

BATCH="VISUAL-DESIGN-FINAL-FORM-LOCK-REPAIR-05"
PROMPT="prompts/batches/VISUAL-DESIGN-FINAL-FORM-LOCK-REPAIR-05.md"

if [[ ! -f "$PROMPT" ]]; then
  echo "Missing prompt: $PROMPT" >&2
  exit 2
fi

exec scripts/ambitions-codex-train.sh "$BATCH" "$PROMPT"
