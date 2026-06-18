#!/usr/bin/env bash
set -uo pipefail

run_bounded() {
  if command -v gtimeout >/dev/null 2>&1; then
    gtimeout "$@"
  elif command -v timeout >/dev/null 2>&1; then
    timeout "$@"
  else
    shift
    "$@"
  fi
}

check() {
  label="$1"
  shift
  if "$@" >/tmp/ambitions-host-toolchain-check.out 2>/tmp/ambitions-host-toolchain-check.err; then
    first="$(head -n 1 /tmp/ambitions-host-toolchain-check.out)"
    echo "OK $label ${first:+- $first}"
  else
    echo "WARN $label unavailable"
    sed -n '1,2p' /tmp/ambitions-host-toolchain-check.err 2>/dev/null || true
  fi
}

echo "== Ambitions Host Toolchain =="
check "brew" brew --version
check "gtimeout" gtimeout --version
check "xcbeautify" xcbeautify --version
check "xcresultparser" xcresultparser --version
check "xcparse" xcparse --help
check "swiftformat" swiftformat --version
check "swiftlint" swiftlint version
check "jq" jq --version
check "ripgrep" rg --version
check "shellcheck" shellcheck --version
check "gh" gh --version
check "git-lfs" git lfs version

echo
echo "== Xcode =="
xcode-select --print-path || true
xcrun xcodebuild -version || true

echo
echo "== Simulator Health =="
run_bounded 20s xcrun simctl list runtimes || true
run_bounded 20s xcrun simctl list devices available || true
