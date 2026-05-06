#!/usr/bin/env bash
set -euo pipefail

# Advisory scan: placeholder-safe pack validator for current docs-only stage.
# Non-mutating. Does not print pack contents.

ROOT="$(git rev-parse --show-toplevel 2>/dev/null || pwd)"
cd "$ROOT"

if [[ ! -d "Resources/SourceAtlas" ]]; then
  echo "SA PACK VALIDATE INFO: Resources/SourceAtlas not present yet; no packs to validate."
  exit 0
fi

if find Resources/SourceAtlas -type f \( -name "*.json" -o -name "*.jsonl" \) | grep -q .; then
  echo "SA PACK VALIDATE INFO: Source Atlas data files present; use batch-specific validators before runtime use."
else
  echo "SA PACK VALIDATE INFO: no Source Atlas JSON/JSONL pack files present."
fi
