#!/usr/bin/env bash
set -euo pipefail
cd "$(git rev-parse --show-toplevel)"
mkdir -p artifacts/plos-runtime/script-output; rg -n "reflow|Recovery|Still counts|Receipt" Native/Ambitions Native/AmbitionsTests > artifacts/plos-runtime/script-output/plos-reflow.log 2>&1; exit 0
