#!/usr/bin/env bash
set -euo pipefail

# Advisory scan: verifies OCR output remains review-required in Source Atlas docs.
# Non-mutating.

ROOT="$(git rev-parse --show-toplevel 2>/dev/null || pwd)"
cd "$ROOT"

if grep -RIn "OCR.*review-required\|OCR output is always review-required\|ocrDerived" docs/codex docs/canon .codex/skills >/dev/null 2>&1; then
  exit 0
fi

echo "SA OCR WARNING: OCR review-required boundary not found."
exit 1
