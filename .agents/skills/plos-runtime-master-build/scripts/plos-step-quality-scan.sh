#!/usr/bin/env bash
set -euo pipefail
cd "$(git rev-parse --show-toplevel)"
mkdir -p artifacts/plos-runtime/script-output; rg -n "Step|Recommended step|Start here|Start now|Open step" Native/Ambitions Native/AmbitionsTests > artifacts/plos-runtime/script-output/plos-step-quality.log 2>&1; exit 0
