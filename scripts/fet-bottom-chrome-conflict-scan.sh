#!/usr/bin/env bash
set -u

root="$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)"
cd "$root" || exit 1

echo "== FET bottom chrome conflict scan =="
echo "Scope: advisory read-only scan for tab bar, toolbar, floating action, receipt overlay, and safe-area competition."
echo "Non-claim: this does not prove chrome is visible, tappable, accessible, or release-ready."
echo

if ! command -v rg >/dev/null 2>&1; then
  echo "YELLOW_HINT ripgrep unavailable; install rg for complete fast scan."
  exit 0
fi

targets=(Native Sources AppUI docs)
rg -n "TabView|tabBar|tab bar|safeAreaInset|safeAreaPadding|toolbar|ToolbarItem|floating|Floating|global action|receipt overlay|bottomTrailing|bottomBar|custom tab|tab rail|UITabBar" "${targets[@]}" 2>/dev/null | head -300 || true

echo "Chrome scan complete; output is capped at 300 hits. UI-touching batches are hard Red when native tab bar, custom tab rail, floating global action, toolbar, or receipt overlay compete visually or lack screenshot evidence."
