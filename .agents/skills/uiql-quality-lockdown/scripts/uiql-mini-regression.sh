#!/usr/bin/env bash
set -euo pipefail
cd "$(git rev-parse --show-toplevel)"
bash .agents/skills/uiql-quality-lockdown/scripts/uiql-scan-banned-copy.sh && bash .agents/skills/uiql-quality-lockdown/scripts/uiql-scan-card-anatomy.sh && bash .agents/skills/uiql-quality-lockdown/scripts/uiql-scan-shell.sh
