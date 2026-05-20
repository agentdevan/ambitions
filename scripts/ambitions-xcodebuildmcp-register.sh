#!/usr/bin/env bash
set -Eeuo pipefail

ROOT="$(git rev-parse --show-toplevel 2>/dev/null || pwd -P)"
cd "$ROOT"

SERVER_NAME="xcodebuildmcp"
TOOL_TIMEOUT_SECONDS="${XCODEBUILDMCP_TOOL_TIMEOUT_SECONDS:-1800}"
STARTUP_TIMEOUT_SECONDS="${XCODEBUILDMCP_STARTUP_TIMEOUT_SECONDS:-60}"

if ! command -v codex >/dev/null 2>&1; then
  echo "RED: codex CLI not found in PATH" >&2
  exit 1
fi

mkdir -p .xcodebuildmcp
if [[ ! -f .xcodebuildmcp/config.yaml ]]; then
  cat > .xcodebuildmcp/config.yaml <<'YAML'
schemaVersion: 1
enabledWorkflows:
  - simulator
sessionDefaults:
  default:
    projectPath: Ambitions.xcodeproj
    scheme: Ambitions
    simulatorName: iPhone 17
    bundleId: com.ambitions.ios
YAML
fi

# Prefer a local, repo-stable MCP registration over a volatile global npx entry.
# Codex CLI versions differ in exact MCP timeout field support, so this script
# installs the server entry and records the timeout policy in repo docs/config.
# If the installed Codex supports per-server tool timeout flags in the future,
# this is the single place to wire them.
if codex mcp list 2>/dev/null | grep -q "^${SERVER_NAME}\b"; then
  codex mcp remove "$SERVER_NAME" >/dev/null 2>&1 || true
fi

codex mcp add "$SERVER_NAME" -- npx -y xcodebuildmcp@latest mcp

cat > .xcodebuildmcp/codex-timeout-policy.json <<JSON
{
  "server": "${SERVER_NAME}",
  "command": "npx -y xcodebuildmcp@latest mcp",
  "startup_timeout_seconds": ${STARTUP_TIMEOUT_SECONDS},
  "tool_timeout_seconds": ${TOOL_TIMEOUT_SECONDS},
  "policy": "Focused simulator tests must not use a 120-second client/tool timeout. If Codex still times out, use Ambitions Proof MCP wrapper-native xcode_validate_focused_test or configure the Codex MCP host with this timeout budget.",
  "preferred_repo_validation": "scripts/ambitions-xcode-validate.sh --lane focused-test --json",
  "proof_gate": "Only a passing Xcode Build Lab validate-summary.json verifies XCTest proof."
}
JSON

codex mcp list

echo "GREEN: xcodebuildmcp registered. Tool timeout policy recorded at .xcodebuildmcp/codex-timeout-policy.json"
echo "NOTE: If Codex still enforces a hard 120-second MCP tool timeout, use ambitionsProof.run_named_validation with xcode_validate_focused_test for focused XCTest proof."
