#!/usr/bin/env bash
set -euo pipefail

REPO_ROOT="/Users/devan/Documents/GitHub/ambitions"
cd "${REPO_ROOT}"

export DEVELOPER_DIR="${DEVELOPER_DIR:-/Applications/Xcode.app/Contents/Developer}"
export XCODEBUILDMCP_ENABLED_WORKFLOWS="${XCODEBUILDMCP_ENABLED_WORKFLOWS:-session-management,project-discovery,simulator-management,simulator,ui-automation,debugging,utilities,swift-package}"
export XCODEBUILDMCP_SENTRY_DISABLED="${XCODEBUILDMCP_SENTRY_DISABLED:-true}"

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

if [[ "${AMBITIONS_XCODEBUILDMCP_CLEAN_PEERS:-1}" == "1" ]]; then
  terminate_matching_peers TERM "xcodebuildmcp@2\\.6\\.2 mcp"
  terminate_matching_peers TERM "node .*/xcodebuildmcp mcp"
  sleep 1
  terminate_matching_peers KILL "xcodebuildmcp@2\\.6\\.2 mcp"
  terminate_matching_peers KILL "node .*/xcodebuildmcp mcp"
fi

exec /usr/local/bin/npx -y xcodebuildmcp@2.6.2 mcp
