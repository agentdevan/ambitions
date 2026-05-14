#!/usr/bin/env bash
set -euo pipefail

# Convenience wrapper for the FAANG Visual + Design Authority lock-prep batch.
# The canonical execution path remains scripts/ambitions-codex-train.sh.

BATCH="VISUAL-DESIGN-AUTHORITY-LOCK-PREP-03"
PROMPT="prompts/batches/VISUAL-DESIGN-AUTHORITY-LOCK-PREP-03.md"

if [[ ! -f "$PROMPT" ]]; then
  echo "Missing prompt: $PROMPT" >&2
  exit 2
fi

exec scripts/ambitions-codex-train.sh "$BATCH" "$PROMPT"
