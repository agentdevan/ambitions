#!/usr/bin/env bash
set -euo pipefail

REPO_ROOT="$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)"
SERVER="$REPO_ROOT/tools/mcp/ambitions_repo_mcp/server.py"
CODEX_CONFIG_DIR="$HOME/.codex"
CODEX_CONFIG="$CODEX_CONFIG_DIR/config.toml"

if [[ ! -f "$SERVER" ]]; then
  echo "Missing MCP server: $SERVER" >&2
  exit 1
fi

python3 "$SERVER" --self-test

mkdir -p "$CODEX_CONFIG_DIR"

cat <<EOF

Ambitions Repo MCP self-test passed.

Add this to $CODEX_CONFIG:

[mcp_servers.ambitionsRepo]
command = "python3"
args = ["$SERVER"]

Then restart Codex or run:

codex mcp list

If your Codex supports it, you can also add it with:

codex mcp add ambitionsRepo -- python3 "$SERVER"

EOF
