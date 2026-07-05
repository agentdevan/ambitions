#!/usr/bin/env bash
set -euo pipefail

REPO_ROOT="/Users/devan/Documents/GitHub/ambitions"
cd "${REPO_ROOT}"

export DEVELOPER_DIR="${DEVELOPER_DIR:-/Applications/Xcode.app/Contents/Developer}"
export XCODEBUILDMCP_ENABLED_WORKFLOWS="${XCODEBUILDMCP_ENABLED_WORKFLOWS:-session-management,project-discovery,simulator-management,simulator,ui-automation,debugging,utilities,swift-package}"

exec /usr/local/bin/npx -y xcodebuildmcp@2.6.2 mcp
