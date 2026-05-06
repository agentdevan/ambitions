#!/usr/bin/env bash
set -euo pipefail

# Advisory scan: reports whether Source Atlas pack schema validation assets exist.
# Non-mutating. Runtime schema implementation is future-owned by SA06.

ROOT="$(git rev-parse --show-toplevel 2>/dev/null || pwd)"
cd "$ROOT"

status=0

if [[ ! -f "docs/codex/SOURCE_ATLAS_GATE_MATRIX.md" ]]; then
  echo "SA PACK SCHEMA WARNING: missing Source Atlas gate matrix"
  status=1
fi

if ! grep -R "Pack Schema Validation Gate" docs/codex docs/canon >/dev/null 2>&1; then
  echo "SA PACK SCHEMA WARNING: Pack Schema Validation Gate not documented"
  status=1
fi

if [[ ! -d "Resources/SourceAtlas" && ! -d "tools/source-atlas" ]]; then
  echo "SA PACK SCHEMA INFO: pack schema/runtime directories not present yet; docs-only stage."
fi

exit "$status"
