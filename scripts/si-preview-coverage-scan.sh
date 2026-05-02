#!/usr/bin/env bash
set -u

root="$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)"
cd "$root" || exit 1

echo "== Signature Interface preview coverage scan =="
echo "Scope: advisory read-only scan for SwiftUI previews near SI primitive names."

if ! command -v rg >/dev/null 2>&1; then
  echo "YELLOW_HINT ripgrep unavailable; install rg for complete fast scan."
  exit 0
fi

rg -n "#Preview|PreviewProvider|previewLayout|Dynamic Type|dynamicTypeSize|Reduce Motion|accessibility" Native AppUI Sources 2>/dev/null || true
echo "Preview scan complete; UI-changing SI batches still need batch-specific preview/state evidence."
