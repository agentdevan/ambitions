#!/usr/bin/env bash
set -u

root="$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)"
cd "$root" || exit 1

echo "== Signature Interface symbol grammar scan =="
echo "Scope: advisory scan for SF Symbol/image usage and icon-only meaning risk."

if ! command -v rg >/dev/null 2>&1; then
  echo "YELLOW_HINT ripgrep unavailable; install rg for complete fast scan."
  exit 0
fi

rg -n "Image\\(systemName:|Label\\(|symbolRenderingMode|accessibilityLabel|Button\\s*\\{" Native AppUI Sources 2>/dev/null || true
echo "Symbol scan complete; reviewers must verify icon-label pairing and non-color meaning."
