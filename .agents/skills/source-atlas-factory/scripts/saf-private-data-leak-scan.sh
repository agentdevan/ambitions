#!/usr/bin/env bash
set -euo pipefail
cd "$(git rev-parse --show-toplevel)"
mkdir -p artifacts/source-atlas-factory/script-output; rg -n "goal|capture|calendar|receipt|profile|personal context|private user" tools/source-atlas Native/Ambitions/Domain/SourceAtlas* > artifacts/source-atlas-factory/script-output/saf-private-data-leak.log 2>&1; exit 0
