#!/usr/bin/env bash
set -euo pipefail
cd "$(git rev-parse --show-toplevel)"
mkdir -p artifacts/plos-runtime/script-output; git diff --name-only > artifacts/plos-runtime/script-output/plos-changed-files.log
