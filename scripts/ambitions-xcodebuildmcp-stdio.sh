#!/usr/bin/env bash
set -euo pipefail

REPO_ROOT="/Users/devan/Documents/GitHub/ambitions"
cd "${REPO_ROOT}"

export DEVELOPER_DIR="${DEVELOPER_DIR:-/Applications/Xcode.app/Contents/Developer}"
export XCODEBUILDMCP_ENABLED_WORKFLOWS="${XCODEBUILDMCP_ENABLED_WORKFLOWS:-session-management,project-discovery,simulator-management,simulator,ui-automation,utilities,swift-package}"
export XCODEBUILDMCP_DISABLE_XCODE_AUTO_SYNC="${XCODEBUILDMCP_DISABLE_XCODE_AUTO_SYNC:-true}"
export XCODEBUILDMCP_SENTRY_DISABLED="${XCODEBUILDMCP_SENTRY_DISABLED:-true}"
export AMBITIONS_XCODEBUILDMCP_CLEAN_PEERS="${AMBITIONS_XCODEBUILDMCP_CLEAN_PEERS:-1}"

XCODEBUILDMCP_PACKAGE_VERSION="${XCODEBUILDMCP_PACKAGE_VERSION:-2.6.2}"
PEER_CLEANUP_GRACE_SECONDS="${AMBITIONS_XCODEBUILDMCP_PEER_CLEANUP_GRACE_SECONDS:-1}"

terminate_matching_peers() {
  local signal="$1"
  local pattern="$2"
  local pids

  pids="$(pgrep -f "${pattern}" 2>/dev/null || true)"
  if [[ -z "${pids}" ]]; then
    return 0
  fi

  while IFS= read -r pid; do
    if [[ -n "${pid}" && "${pid}" != "$$" ]]; then
      kill "-${signal}" "${pid}" 2>/dev/null || true
    fi
  done <<< "${pids}"
}

if [[ "${AMBITIONS_XCODEBUILDMCP_CLEAN_PEERS}" == "1" ]]; then
  terminate_matching_peers TERM "npm exec xcodebuildmcp(@[^[:space:]]*)? mcp"
  terminate_matching_peers TERM "xcodebuildmcp(@[^[:space:]]*)? mcp"
  terminate_matching_peers TERM "node .*/xcodebuildmcp mcp"
  sleep "${PEER_CLEANUP_GRACE_SECONDS}"
  terminate_matching_peers KILL "npm exec xcodebuildmcp(@[^[:space:]]*)? mcp"
  terminate_matching_peers KILL "xcodebuildmcp(@[^[:space:]]*)? mcp"
  terminate_matching_peers KILL "node .*/xcodebuildmcp mcp"
fi

exec /usr/local/bin/npx -y "xcodebuildmcp@${XCODEBUILDMCP_PACKAGE_VERSION}" mcp
