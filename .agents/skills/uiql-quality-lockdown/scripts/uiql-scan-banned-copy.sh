#!/usr/bin/env bash
set -euo pipefail
cd "$(git rev-parse --show-toplevel)"
mkdir -p artifacts/ui-quality-lockdown/script-output; rg -n "best next move|next best move|Begin Focus|Start Focus|overdue|failed|streak broken|productivity dropped" Native Sources AppUI docs/truth AGENTS.md > artifacts/ui-quality-lockdown/script-output/uiql-banned-copy.log 2>&1; rc=$?; [ $rc -eq 1 ] && exit 0 || exit $rc
