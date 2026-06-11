#!/usr/bin/env bash
set -euo pipefail
cd "$(git rev-parse --show-toplevel)"
mkdir -p artifacts/plos-runtime/script-output; rg -n "OpenAI|LLM|R2|CloudKit|user data|personal data" Native/Ambitions docs/truth > artifacts/plos-runtime/script-output/plos-privacy-boundary.log 2>&1; exit 0
