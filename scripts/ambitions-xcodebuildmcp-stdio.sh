#!/usr/bin/env bash
set -euo pipefail

REPO_ROOT="/Users/devan/Documents/GitHub/ambitions"
cd "${REPO_ROOT}"

export DEVELOPER_DIR="${DEVELOPER_DIR:-/Applications/Xcode.app/Contents/Developer}"
export XCODEBUILDMCP_ENABLED_WORKFLOWS="${XCODEBUILDMCP_ENABLED_WORKFLOWS:-session-management,project-discovery,simulator-management,simulator,ui-automation,utilities,swift-package}"
export XCODEBUILDMCP_DISABLE_XCODE_AUTO_SYNC="${XCODEBUILDMCP_DISABLE_XCODE_AUTO_SYNC:-true}"
export XCODEBUILDMCP_SENTRY_DISABLED="${XCODEBUILDMCP_SENTRY_DISABLED:-true}"
export XCODEBUILDMCP_MCP_IDLE_TIMEOUT_MS="${XCODEBUILDMCP_MCP_IDLE_TIMEOUT_MS:-600000}"

XCODEBUILDMCP_PACKAGE_VERSION="${XCODEBUILDMCP_PACKAGE_VERSION:-2.6.2}"
XCODEBUILDMCP_PACKAGE_ROOT="${XCODEBUILDMCP_PACKAGE_ROOT:-/Users/devan/.codex/mcp-node-packages/xcodebuildmcp-${XCODEBUILDMCP_PACKAGE_VERSION}}"
XCODEBUILDMCP_BIN="${XCODEBUILDMCP_PACKAGE_ROOT}/node_modules/.bin/xcodebuildmcp"
PEER_CLEANUP_GRACE_SECONDS="${AMBITIONS_XCODEBUILDMCP_PEER_CLEANUP_GRACE_SECONDS:-1}"

matching_xcodebuildmcp_peer_pids() {
  ps -axo pid=,command= | while IFS= read -r line; do
    local pid=""
    local command=""
    read -r pid command <<< "${line}"

    if [[ -z "${pid}" || "${pid}" == "$$" ]]; then
      continue
    fi

    case "${command}" in
      *"/node_modules/xcodebuildmcp/build/cli.js mcp"* | *"/node_modules/.bin/xcodebuildmcp mcp"*)
        printf '%s\n' "${pid}"
        ;;
    esac
  done
}

terminate_matching_peers() {
  local signal="$1"
  local pids

  pids="$(matching_xcodebuildmcp_peer_pids || true)"
  if [[ -z "${pids}" ]]; then
    return 0
  fi

  while IFS= read -r pid; do
    if [[ -n "${pid}" && "${pid}" != "$$" ]]; then
      kill "-${signal}" "${pid}" 2>/dev/null || true
    fi
  done <<< "${pids}"
}

if [[ "${1:-}" == "--cleanup-peers-and-exit" ]]; then
  echo "[ambitions-xcodebuildmcp] explicit peer cleanup enabled" >&2
  terminate_matching_peers TERM
  sleep "${PEER_CLEANUP_GRACE_SECONDS}"
  terminate_matching_peers KILL
  exit 0
fi

if [[ "${AMBITIONS_XCODEBUILDMCP_CLEAN_PEERS:-0}" == "1" ]]; then
  echo "[ambitions-xcodebuildmcp] ignoring AMBITIONS_XCODEBUILDMCP_CLEAN_PEERS during stdio startup; use --cleanup-peers-and-exit for maintenance" >&2
fi

if [[ ! -x "${XCODEBUILDMCP_BIN}" ]]; then
  mkdir -p "${XCODEBUILDMCP_PACKAGE_ROOT}"
  npm_config_update_notifier=false npm_config_fund=false npm_config_audit=false \
    /usr/local/bin/npm install --silent --prefix "${XCODEBUILDMCP_PACKAGE_ROOT}" \
    "xcodebuildmcp@${XCODEBUILDMCP_PACKAGE_VERSION}" </dev/null
fi

exec "${XCODEBUILDMCP_BIN}" mcp
