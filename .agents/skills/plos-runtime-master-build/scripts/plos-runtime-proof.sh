#!/usr/bin/env bash
set -euo pipefail
cd "$(git rev-parse --show-toplevel)"
mkdir -p artifacts/plos-runtime/script-output; rg -n "Private Life Runtime|RecommendationTrace|Receipt|ReplayTrace|SourceRecord" Native/Ambitions Native/AmbitionsTests > artifacts/plos-runtime/script-output/plos-runtime-proof.log 2>&1; exit 0
