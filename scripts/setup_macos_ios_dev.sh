#!/usr/bin/env bash

set -euo pipefail

usage() {
  cat <<'EOF'
Usage: scripts/setup_macos_ios_dev.sh [--minimal]

Bootstraps the Ambitions macOS iOS development toolchain.

Installs:
- XcodeGen (required by this repo)
- xcbeautify, swiftformat, swiftlint (useful local iOS tooling)

Verifies:
- Xcode CLI selection
- xcodegen project generation
- xcodebuild project discovery

Options:
  --minimal    Install only XcodeGen, then verify the generated project
  -h, --help   Show this help message
EOF
}

MINIMAL=0

while [[ $# -gt 0 ]]; do
  case "$1" in
    --minimal)
      MINIMAL=1
      shift
      ;;
    -h|--help)
      usage
      exit 0
      ;;
    *)
      echo "Unknown argument: $1" >&2
      usage >&2
      exit 1
      ;;
  esac
done

if [[ "$(uname -s)" != "Darwin" ]]; then
  echo "This setup script must be run on macOS." >&2
  exit 1
fi

REPO_ROOT="$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)"

require_command() {
  local command_name="$1"
  local install_hint="$2"

  if ! command -v "$command_name" >/dev/null 2>&1; then
    echo "Missing required command '$command_name'. ${install_hint}" >&2
    exit 1
  fi
}

install_brew_formula() {
  local formula="$1"

  if brew list --formula "$formula" >/dev/null 2>&1; then
    echo "Already installed: $formula"
    return
  fi

  echo "Installing: $formula"
  brew install "$formula"
}

echo "Checking Xcode command-line tools"
require_command xcode-select "Install Xcode and select it with 'sudo xcode-select -s /Applications/Xcode.app'."
require_command xcodebuild "Install Xcode and make sure command-line tools are selected."

XCODE_PATH="$(xcode-select -p)"
echo "Using Xcode toolchain at: $XCODE_PATH"
xcodebuild -version

echo "Checking Homebrew"
require_command brew "Install Homebrew from https://brew.sh first."

echo "Updating Homebrew metadata"
brew update

echo "Installing repo-required tooling"
install_brew_formula xcodegen

if [[ "$MINIMAL" -eq 0 ]]; then
  echo "Installing useful local iOS development tooling"
  install_brew_formula xcbeautify
  install_brew_formula swiftformat
  install_brew_formula swiftlint
fi

echo "Generating Ambitions Xcode project"
cd "$REPO_ROOT"
rm -rf Ambitions.xcodeproj
xcodegen generate

echo "Verifying generated project"
xcodebuild -project Ambitions.xcodeproj -list

cat <<'EOF'

Setup complete.

Next commands:
  xcodebuild -project Ambitions.xcodeproj -scheme Ambitions -resolvePackageDependencies
  xcodebuild -project Ambitions.xcodeproj -scheme Ambitions -sdk iphonesimulator -destination "generic/platform=iOS Simulator" CODE_SIGNING_ALLOWED=NO build
EOF
