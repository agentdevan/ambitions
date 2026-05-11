#!/usr/bin/env bash
set -Eeuo pipefail

usage() {
  cat <<'USAGE'
Usage:
  scripts/ambitions-xcode-version-check.sh
  scripts/ambitions-xcode-version-check.sh --strict
USAGE
}

REPO_ROOT="$(git rev-parse --show-toplevel 2>/dev/null || pwd -P)"
cd "$REPO_ROOT"

STRICT=0
if [[ "${1:-}" == "--strict" ]]; then
  STRICT=1
elif [[ "${1:-}" == "-h" || "${1:-}" == "--help" ]]; then
  usage
  exit 0
elif [[ "$#" -gt 0 ]]; then
  usage >&2
  exit 1
fi

if ! command -v xcode-select >/dev/null 2>&1; then
  echo "tool_missing: xcode-select"
  (( STRICT == 1 )) && exit 1
  exit 0
fi

xcode_path="$(xcode-select -p 2>/dev/null || true)"
if [[ -z "$xcode_path" || ! -d "$xcode_path" ]]; then
  echo "xcode-select -p failed"
  (( STRICT == 1 )) && exit 1
  exit 0
fi

if ! command -v xcodebuild >/dev/null 2>&1; then
  echo "xcodebuild missing"
  (( STRICT == 1 )) && exit 1
  exit 0
fi

xcode_version="$(xcodebuild -version 2>/dev/null | awk 'NR==1 {print $2}')"
[[ -z "$xcode_version" ]] && xcode_version="unknown"

expected_version=""
if [[ -f ".xcode-version" ]]; then
  expected_version="$(sed 's/[[:space:]]//g' .xcode-version)"
fi

if [[ -n "$expected_version" && "$expected_version" != "$xcode_version" ]]; then
  echo "xcode version mismatch: active=${xcode_version} required=${expected_version}"
  (( STRICT == 1 )) && exit 1
fi

echo "xcode-select: $xcode_path"
echo "xcodebuild: $xcode_version"
if [[ -n "$expected_version" ]]; then
  echo ".xcode-version: $expected_version"
fi

xcodebuild -version >/dev/null
exit 0
