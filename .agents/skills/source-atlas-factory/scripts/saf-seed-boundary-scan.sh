#!/usr/bin/env bash
set -euo pipefail
cd "$(git rev-parse --show-toplevel)"
mkdir -p artifacts/source-atlas-factory/script-output; rg -n "seed|Seed|hardcoded|personal Step" Native tools scripts > artifacts/source-atlas-factory/script-output/saf-seed-boundary.log 2>&1; exit 0
