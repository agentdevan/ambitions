#!/usr/bin/env bash
set -euo pipefail
cd "$(git rev-parse --show-toplevel)"
mkdir -p artifacts/ui-quality-lockdown/script-output; git diff --name-only > artifacts/ui-quality-lockdown/script-output/uiql-changed-files.log
