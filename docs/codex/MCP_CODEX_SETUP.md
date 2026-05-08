# MCP Codex Setup

<!-- markdownlint-disable MD013 -->

Status: Setup guide for local Ambitions MCP servers.  
Date: 2026-05-08  
Scope: dedicated Ambitions Mac VM / Codex setup.

## What This Installs

The first Ambitions MCP server is:

```text
tools/mcp/ambitions_repo_mcp/
```

It is read-only and local-only. It exposes repo-truth tools for Codex:

- active batch detection
- EFC overlay status
- source-truth stack
- changed-file impact routing
- EFC applicability
- forbidden claim scanning
- closeout shape validation
- current repo posture summary

It does not run shell commands, write files, access secrets, use the network, or become part of the Ambitions app runtime.

## Install On The Mac VM

From the Ambitions repo root:

```bash
cd /Users/devan/Documents/GitHub/ambitions
python3 tools/mcp/ambitions_repo_mcp/server.py --self-test
```

If the self-test passes, the server can be configured for Codex.

## Codex Config Option

Open your Codex config file:

```bash
mkdir -p ~/.codex
nano ~/.codex/config.toml
```

Add:

```toml
[mcp_servers.ambitionsRepo]
command = "python3"
args = ["/Users/devan/Documents/GitHub/ambitions/tools/mcp/ambitions_repo_mcp/server.py"]
```

Then verify through Codex CLI if your installed Codex version supports it:

```bash
codex mcp list
```

Some Codex versions also support adding MCPs through a command such as:

```bash
codex mcp add ambitionsRepo -- python3 /Users/devan/Documents/GitHub/ambitions/tools/mcp/ambitions_repo_mcp/server.py
```

If the command is unavailable, use the `config.toml` method.

## Recommended Codex Prompt After Setup

```text
Use the ambitionsRepo MCP before touching the repo. First call get_active_batch, summarize_repo_posture, and check_efc_applicability for the target files. Preserve the current active batch and do not claim release/device/accessibility/legal/privacy proof unless the MCP and repo evidence support it.
```

## Safety Notes

- This server is read-only.
- It only reads inside the repo root.
- It does not expose a shell tool.
- It does not use external network.
- It does not access Keychain, environment secrets, or files outside the repo.
- It does not add runtime dependencies to the Ambitions app.

## Troubleshooting

Run self-test:

```bash
python3 tools/mcp/ambitions_repo_mcp/server.py --self-test
```

Expected output includes:

```text
ambitions_repo_mcp self-test passed
```

If Codex cannot see the server:

1. Confirm the path in `~/.codex/config.toml` is absolute.
2. Confirm `python3` exists on the Mac VM.
3. Run the self-test from repo root.
4. Restart the Codex session.

## Non-Claims

Installing this MCP server does not mean any app behavior, build, test, visual QA, accessibility, physical-device, App Store, TestFlight, legal/privacy, sync, hosted AI, hosted CI, telemetry, or release claim is proven.
