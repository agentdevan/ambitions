#!/usr/bin/env bash
set -euo pipefail

# Advisory scan: flags wording that could allow private source content leakage.
# Non-mutating. Prints filenames and matching lines only.

ROOT="$(git rev-parse --show-toplevel 2>/dev/null || pwd)"
cd "$ROOT"

status=0
TARGETS=(
  "docs/canon/Ambitions_Source_Atlas.md"
  "docs/codex/SOURCE_ATLAS_GATE_MATRIX.md"
  "docs/codex/SOURCE_ATLAS_UNIVERSAL_SOURCE_BINDER_COVERAGE_MAP.md"
  "docs/codex/SOURCE_ATLAS_UI_OBJECT_LANGUAGE.md"
  "docs/codex/SOURCE_ATLAS_CODEX_OS_UPGRADE_MAP.md"
  ".codex/skills"
  "Resources/SourceAtlas"
  "tools/source-atlas"
)
EXISTING=()
for target in "${TARGETS[@]}"; do
  [[ -e "$target" ]] && EXISTING+=("$target")
done

PATTERN="log private source|analytics.*private source|widget.*private document|Live Activit.*private document|notification.*private document|print private source contents"

if grep -RInE "$PATTERN" "${EXISTING[@]}" >/tmp/sa-private-leak-scan.$$ 2>/dev/null; then
  grep -v "must not" /tmp/sa-private-leak-scan.$$ \
    | grep -v "must never" \
    | grep -v "forbid" \
    | grep -v "forbidden" \
    | grep -v "does not" \
    > /tmp/sa-private-leak-scan-filtered.$$ || true
  if [[ -s /tmp/sa-private-leak-scan-filtered.$$ ]]; then
    cat /tmp/sa-private-leak-scan-filtered.$$
    echo "SA PRIVATE LEAK WARNING: possible private source leakage wording detected."
    status=1
  fi
  rm -f /tmp/sa-private-leak-scan.$$
  rm -f /tmp/sa-private-leak-scan-filtered.$$
else
  rm -f /tmp/sa-private-leak-scan.$$
fi

exit "$status"
