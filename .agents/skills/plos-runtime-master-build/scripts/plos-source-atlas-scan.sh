#!/usr/bin/env bash
set -euo pipefail
cd "$(git rev-parse --show-toplevel)"
mkdir -p artifacts/plos-runtime/script-output; find Native tools scripts -maxdepth 5 \( -iname "*SourceAtlas*" -o -iname "*source-atlas*" \) > artifacts/plos-runtime/script-output/plos-source-atlas.log 2>&1
