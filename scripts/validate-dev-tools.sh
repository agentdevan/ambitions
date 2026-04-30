#!/usr/bin/env bash
set -u

missing=0

check_command() {
  local name="$1"
  local version_command="$2"

  if ! command -v "$name" >/dev/null 2>&1; then
    echo "MISSING: $name"
    missing=1
    return
  fi

  echo "FOUND: $name -> $(command -v "$name")"
  if [[ -n "$version_command" ]]; then
    bash -lc "$version_command" 2>/dev/null | head -5 || true
  fi
}

echo "Ambitions developer tool validation"
echo "===================================="

check_command "xcodebuild" "xcodebuild -version"

if command -v xcode-select >/dev/null 2>&1; then
  echo "FOUND: xcode-select -> $(command -v xcode-select)"
  xcode-select -p || missing=1
else
  echo "MISSING: xcode-select"
  missing=1
fi

check_command "xcodegen" "xcodegen --version"
check_command "rg" "rg --version"
check_command "git" "git --version"
check_command "gh" "gh --version"
check_command "jq" "jq --version"
check_command "xcbeautify" "xcbeautify --version"
check_command "markdownlint-cli2" "markdownlint-cli2 --version"
check_command "lychee" "lychee --version"

echo
echo "Optional staged tools are not required:"
for tool in swiftlint swift-format fastlane; do
  if command -v "$tool" >/dev/null 2>&1; then
    echo "OPTIONAL PRESENT: $tool -> $(command -v "$tool")"
  else
    echo "OPTIONAL ABSENT: $tool"
  fi
done

exit "$missing"
