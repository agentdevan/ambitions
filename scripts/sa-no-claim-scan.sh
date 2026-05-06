#!/usr/bin/env bash
set -euo pipefail

# Advisory scan: flags unsupported Source Atlas certainty/release claims.
# Non-mutating. Prints filenames and matching lines only.

ROOT="$(git rev-parse --show-toplevel 2>/dev/null || pwd)"
cd "$ROOT"

status=0
TARGETS=(
  "docs/canon/Ambitions_Source_Atlas.md"
  "docs/codex/SOURCE_ATLAS_GATE_MATRIX.md"
  "docs/codex/SOURCE_ATLAS_COMPOSITION_GOAL_PROJECTION_MODEL.md"
  "docs/codex/SOURCE_ATLAS_UNIVERSAL_SOURCE_BINDER_COVERAGE_MAP.md"
  "docs/codex/SOURCE_ATLAS_CODEX_OS_UPGRADE_MAP.md"
  "docs/codex/SOURCE_ATLAS_HPS_AOS_LDI_INTEGRATION_MAP.md"
  "docs/codex/GLOBAL_SOURCE_ATLAS_COMPLETION_ORDER_OVERLAY.md"
  ".codex/skills"
  "Resources/SourceAtlas"
  "tools/source-atlas"
)
EXISTING=()
for target in "${TARGETS[@]}"; do
  [[ -e "$target" ]] && EXISTING+=("$target")
done

PATTERN="official[- ]complete|always[- ]current|guarantees eligibility|certifies eligibility|legal advice|career certainty|education certainty|Source Atlas covers every goal|top 10,000 global goals|production source packs are ready|App Store ready|TestFlight ready"

if grep -RInE "$PATTERN" "${EXISTING[@]}" >/tmp/sa-no-claim-scan.$$ 2>/dev/null; then
  grep -v "Do not say:" /tmp/sa-no-claim-scan.$$ \
    | grep -v "must not be treated" \
    | grep -v "No-claim boundary" \
    | grep -v "forbidden" \
    | grep -v "without evidence" \
    | grep -v "without claiming" \
    | grep -v "do not make" \
    | grep -v "not claim" \
    | grep -v "does not claim" \
    | grep -v "cannot claim" \
    > /tmp/sa-no-claim-scan-filtered.$$ || true
  if [[ -s /tmp/sa-no-claim-scan-filtered.$$ ]]; then
    cat /tmp/sa-no-claim-scan-filtered.$$
    echo "SA NO CLAIM WARNING: unsupported Source Atlas claim language detected."
    status=1
  fi
  rm -f /tmp/sa-no-claim-scan.$$
  rm -f /tmp/sa-no-claim-scan-filtered.$$
else
  rm -f /tmp/sa-no-claim-scan.$$
fi

exit "$status"
