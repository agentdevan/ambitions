#!/usr/bin/env bash
# scripts/dev/toolkit-snapshot.sh
# Bounded read-only readiness check script for Ambitions development environment.
# Do not print secrets, tokens, signing identities, private keys, or API keys.
# Usage: ./scripts/dev/toolkit-snapshot.sh > docs/dev/toolkit-snapshots/toolkit-snapshot-$(date +%Y%m%d-%H%M).md

set -euo pipefail

echo "# Ambitions Dev Toolkit Snapshot"
echo "Generated at: $(date -R)"
echo ""

echo "## 1. Machine / OS / VM Snapshot"
echo "\`\`\`text"
echo "macOS Version:"
sw_vers
echo ""
echo "Hardware & Kernel:"
uname -a
sysctl -n machdep.cpu.brand_string 2>/dev/null || echo "CPU info unavailable"
echo "RAM (bytes):"
sysctl -n hw.memsize 2>/dev/null || echo "RAM info unavailable"
echo ""
echo "Disk Usage:"
df -h /
echo ""
echo "User & Shell:"
echo "User: $(whoami)"
echo "Shell: ${SHELL:-unknown}"
echo "Current Path: $(pwd)"
echo "\`\`\`"
echo ""

echo "## 2. Xcode / Apple Toolchain"
echo "\`\`\`text"
echo "Selected Developer Path: $(xcode-select -p)"
xcodebuild -version
echo ""
echo "Command Line Tools Pkg Info:"
pkgutil --pkg-info=com.apple.pkg.CLTools_Executables 2>/dev/null || echo "CLTools pkg info not found"
echo ""
echo "Available SDKs:"
xcodebuild -showsdks
echo ""
echo "Simulator Runtimes:"
xcrun simctl list runtimes
echo "\`\`\`"
echo ""

echo "## 3. Apple Developer Apps / Resources"
echo "\`\`\`text"
echo "SF Symbols App: $(ls -ld "/Applications/SF Symbols.app" 2>/dev/null || ls -ld "/Applications/SF Symbols Beta.app" 2>/dev/null || echo "Missing")"
echo "Icon Composer App: $(ls -ld "/Applications/Icon Composer.app" 2>/dev/null || echo "Missing")"
echo "Xcode Stable: $(ls -ld "/Applications/Xcode.app" 2>/dev/null || echo "Missing")"
echo "Xcode Beta: $(ls -ld "/Applications/Xcode-beta.app" 2>/dev/null || echo "Missing")"
echo "Instruments Path: $(xcrun --find instruments 2>/dev/null || echo "Missing")"
echo "xctrace Path: $(xcrun --find xctrace 2>/dev/null || echo "Missing")"
echo "\`\`\`"
echo ""

echo "## 4. Swift & CLI Developer Tools"
echo "\`\`\`text"
echo "Swift Compiler:"
swift --version
echo ""
echo "Swift Package Manager:"
swift package --version 2>/dev/null || echo "SwiftPM version check failed"
echo ""
echo "CLI Tools version checks:"
echo "Homebrew: $(which brew >/dev/null && brew --version | head -n 1 || echo "Missing")"
echo "XcodeGen: $(which xcodegen >/dev/null && xcodegen --version || echo "Missing")"
echo "SwiftFormat: $(which swiftformat >/dev/null && swiftformat --version || echo "Missing")"
echo "swift-format: $(which swift-format >/dev/null && swift-format --version || echo "Missing")"
echo "SwiftLint: $(which swiftlint >/dev/null && swiftlint version || echo "Missing")"
echo "xcbeautify: $(which xcbeautify >/dev/null && xcbeautify --version || echo "Missing")"
echo "xcpretty: $(which xcpretty >/dev/null && xcpretty --version || echo "Missing")"
echo "xcparse: $(which xcparse >/dev/null && xcparse version || echo "Missing")"
echo "periphery: $(which periphery >/dev/null && periphery version || echo "Missing")"
echo "sourcery: $(which sourcery >/dev/null && sourcery --version || echo "Missing")"
echo "fastlane: $(which fastlane >/dev/null && fastlane --version || echo "Missing")"
echo "git-lfs: $(which git-lfs >/dev/null && git-lfs version || echo "Missing")"
echo "Python 3: $(which python3 >/dev/null && python3 --version || echo "Missing")"
echo "Node: $(which node >/dev/null && node --version || echo "Missing")"
echo "npm: $(which npm >/dev/null && npm --version || echo "Missing")"
echo "pnpm: $(which pnpm >/dev/null && pnpm --version || echo "Missing")"
echo "yarn: $(which yarn >/dev/null && yarn --version || echo "Missing")"
echo "\`\`\`"
echo ""

echo "## 5. Repo Build / Git Snapshot"
echo "\`\`\`text"
echo "Branch & Status:"
git status --short --branch
echo ""
echo "HEAD Commit SHA: $(git rev-parse HEAD)"
echo ""
echo "Remotes (Redacted):"
git remote -v | sed 's#https://.*@#https://REDACTED@#g'
echo ""
echo "Project structures found:"
find . -maxdepth 3 -name 'project.yml' -o -name '*.xcodeproj' -o -name '*.xcworkspace' -o -name 'Package.swift'
echo "\`\`\`"
echo ""
