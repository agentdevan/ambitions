#!/usr/bin/env bash
set -euo pipefail

# Advisory scan: verifies Universal Source Binder coverage terms are present.
# Non-mutating. Does not inspect or print private source contents.

ROOT="$(git rev-parse --show-toplevel 2>/dev/null || pwd)"
cd "$ROOT"

MAP="docs/codex/SOURCE_ATLAS_UNIVERSAL_SOURCE_BINDER_COVERAGE_MAP.md"
status=0

if [[ ! -f "$MAP" ]]; then
  echo "SA SOURCE CONTAINER WARNING: missing $MAP"
  exit 1
fi

require() {
  local label="$1"
  local pattern="$2"
  if ! grep -qi "$pattern" "$MAP"; then
    echo "SA SOURCE CONTAINER WARNING: missing coverage for $label"
    status=1
  fi
}

require "URL" "^### URL"
require "PDF" "^### PDF"
require "screenshot/image" "^### Screenshot / image"
require "copied/plain text" "^### Copied/plain text"
require "local file" "^### Local file"
require "official source pack" "^### Official source pack"
require "user mini-pack" "^### User mini-pack"
require "rulebook" "^### Rulebook"
require "school program page" "^### School program page"
require "job posting" "^### Job posting"
require "certification handbook" "^### Certification handbook"

exit "$status"
