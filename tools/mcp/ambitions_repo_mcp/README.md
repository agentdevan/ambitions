# Ambitions Repo MCP

Read-only local MCP server for Ambitions Codex production work.

## Purpose

`ambitions_repo_mcp` gives Codex deterministic local tools for:

- active batch detection
- EFC overlay status
- source-truth stack
- EFC applicability checks
- changed-file impact routing
- forbidden claim scanning
- batch closeout shape validation
- concise repo posture summaries

It is intentionally read-only and stdlib-only.

## Safety

This server:

- reads only inside the Ambitions repo root
- does not write files
- does not execute shell commands
- does not access secrets or Keychain
- does not use network
- does not add dependencies to the Ambitions app
- does not claim app build/test/release readiness

## Self-Test

From repo root:

```bash
python3 tools/mcp/ambitions_repo_mcp/server.py --self-test
```

## Codex Config

Add to `~/.codex/config.toml`:

```toml
[mcp_servers.ambitionsRepo]
command = "python3"
args = ["/Users/devan/Documents/GitHub/ambitions/tools/mcp/ambitions_repo_mcp/server.py"]
```

See `docs/codex/MCP_CODEX_SETUP.md` for details.

## Tools

- `get_active_batch`
- `get_efc_overlay_status`
- `get_source_truth_stack`
- `check_efc_applicability`
- `changed_file_impact`
- `detect_forbidden_claims`
- `check_batch_closeout_shape`
- `summarize_repo_posture`

## Protocol

The server implements the stdio JSON-RPC MCP surface needed by Codex:

- `initialize`
- `tools/list`
- `tools/call`
- `ping`

It avoids external Python dependencies so it can run on a clean Mac VM.
