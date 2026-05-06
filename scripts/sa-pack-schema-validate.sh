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

if [[ ! -f "Native/Ambitions/Domain/SourceAtlasPackModels.swift" ]]; then
  echo "SA PACK SCHEMA WARNING: SourceAtlasPackModels.swift not found"
  status=1
fi

if [[ ! -f "Native/AmbitionsTests/Domain/SourceAtlasPackModelsTests.swift" ]]; then
  echo "SA PACK SCHEMA WARNING: SourceAtlasPackModelsTests.swift not found"
  status=1
fi

if [[ -f "Native/Ambitions/Domain/SourceAtlasPackModels.swift" ]]; then
  if ! grep -q "SourceAtlasPackValidator" "Native/Ambitions/Domain/SourceAtlasPackModels.swift"; then
    echo "SA PACK SCHEMA WARNING: SourceAtlasPackValidator not found"
    status=1
  fi

  if ! grep -q "SourceAtlasRuntimeBoundary" "Native/Ambitions/Domain/SourceAtlasPackModels.swift"; then
    echo "SA PACK SCHEMA WARNING: SourceAtlas runtime boundary not found"
    status=1
  fi
fi

if [[ -f "Native/AmbitionsTests/Domain/SourceAtlasPackModelsTests.swift" ]]; then
  if ! grep -q "testUnsupportedSchemaIsRejectedByValidator" "Native/AmbitionsTests/Domain/SourceAtlasPackModelsTests.swift"; then
    echo "SA PACK SCHEMA WARNING: unsupported schema rejection test not found"
    status=1
  fi

  if ! grep -q "testRuntimeStoreBehaviorIsRejected" "Native/AmbitionsTests/Domain/SourceAtlasPackModelsTests.swift"; then
    echo "SA PACK SCHEMA WARNING: runtime-store rejection test not found"
    status=1
  fi
fi

exit "$status"
