#!/usr/bin/env bash
set -euo pipefail
cd "$(git rev-parse --show-toplevel)"
mkdir -p artifacts/source-atlas-factory/script-output; rg -n "SourceAtlas.*Pack|PackFactory|pack manifest|runtime eligibility" Native tools scripts > artifacts/source-atlas-factory/script-output/saf-pack-boundary.log 2>&1; exit 0
