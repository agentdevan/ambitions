#!/usr/bin/env bash
set -euo pipefail

REPO_ROOT="$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)"
SERVER="$REPO_ROOT/tools/mcp/ambitions_proof_mcp/server.py"

if [[ ! -f "$SERVER" ]]; then
  echo "Missing MCP server: $SERVER" >&2
  exit 1
fi

python3 "$SERVER" --self-test

cat <<EOF
Ambitions Proof MCP self-test passed.

Add this to ~/.codex/config.toml if it is not present:

[mcp_servers.ambitionsProof]
command = "python3"
args = ["$SERVER"]

Then restart Codex or run:

codex mcp list
EOF
