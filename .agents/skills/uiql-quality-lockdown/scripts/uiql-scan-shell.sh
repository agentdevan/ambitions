#!/usr/bin/env bash
set -euo pipefail
cd "$(git rev-parse --show-toplevel)"
mkdir -p artifacts/ui-quality-lockdown/script-output; rg -n "AppTab|Capture|Motion|Pulse|Plan" Native/Ambitions/App Native/AmbitionsTests/App > artifacts/ui-quality-lockdown/script-output/uiql-shell.log 2>&1; exit 0
