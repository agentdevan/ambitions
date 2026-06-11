#!/usr/bin/env bash
set -euo pipefail
cd "$(git rev-parse --show-toplevel)"
mkdir -p artifacts/ui-quality-lockdown/script-output; rg -n "Card|card stack|dashboard|KPI|score" Native/Ambitions Sources AppUI > artifacts/ui-quality-lockdown/script-output/uiql-card-anatomy.log 2>&1; exit 0
