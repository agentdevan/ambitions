#!/usr/bin/env bash
set -u

root="$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)"
cd "$root" || exit 1

echo "== FET bottom chrome conflict scan =="
echo "Scope: advisory read-only scan for tab bar, Meridian rail, toolbar, floating action, receipt overlay, and safe-area competition."
echo "Non-claim: this does not prove chrome is visible, tappable, accessible, or release-ready."
echo

if ! command -v rg >/dev/null 2>&1; then
  echo "YELLOW_HINT ripgrep unavailable; install rg for complete fast scan."
  exit 0
fi

targets=(
  Native/Ambitions/App
  Native/Ambitions/Features
  Sources/Components
  docs/codex
  docs/AmbitionsCanon
)

rg -n "TabView|tabBar|tab bar|toolbarBackground|toolbar\\(|ToolbarItem|safeAreaInset|safeAreaPadding|floating|Floating|global.*plus|global.*add|global action|receipt overlay|continuity receipt|bottomTrailing|bottomBar|Meridian|destination rail|custom tab|UITabBar|home indicator|composer" "${targets[@]}" 2>/dev/null | head -360 || true

echo
echo "Reviewer rule: bottom chrome must name a single owner. Native tab bar, custom Meridian rail, floating global action, toolbar, composer, and receipt overlay cannot visually compete in rendered evidence."
exit 0
