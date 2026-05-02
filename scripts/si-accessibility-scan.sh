#!/usr/bin/env bash
set -u

root="$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)"
cd "$root" || exit 1

echo "== Signature Interface accessibility scan =="
echo "Scope: advisory scan for accessibility labels, identifiers, sort priority, Dynamic Type, and color-only risk."

if ! command -v rg >/dev/null 2>&1; then
  echo "YELLOW_HINT ripgrep unavailable; install rg for complete fast scan."
  exit 0
fi

rg -n "accessibilityLabel|accessibilityHint|accessibilityIdentifier|accessibilitySortPriority|dynamicTypeSize|ScaledMetric|minimumScaleFactor|foregroundStyle\\(|foregroundColor\\(" Native AppUI Sources 2>/dev/null || true
echo "Accessibility scan complete; this is not public accessibility conformance proof."
