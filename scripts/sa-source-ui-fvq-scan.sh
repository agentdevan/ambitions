#!/usr/bin/env bash
set -euo pipefail

# Advisory scan: checks Source Atlas visible-state proof requirements.
# Non-mutating.

ROOT="$(git rev-parse --show-toplevel 2>/dev/null || pwd)"
cd "$ROOT"

UI_DOC="docs/codex/SOURCE_ATLAS_UI_OBJECT_LANGUAGE.md"
status=0

if [[ ! -f "$UI_DOC" ]]; then
  echo "SA UI FVQ WARNING: missing $UI_DOC"
  exit 1
fi

for term in SourceBadge FreshnessBadge SourceNeededFold ClaimReviewDrawer PrivateSourceShield OCRReviewNotice SourceImpactReceipt; do
  if ! grep -q "$term" "$UI_DOC"; then
    echo "SA UI FVQ WARNING: missing UI object $term"
    status=1
  fi
done

exit "$status"
