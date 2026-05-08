# MCP Codex Local Registration Report

Date: 2026-05-08
Result: Partial Green / external prerequisites Yellow
Type: Codex MCP local registration

## Commands Run

```bash
which codex || true
codex --version || true
codex mcp list || true
codex mcp add ambitionsRepo -- python3 /Users/devan/Documents/GitHub/ambitions/tools/mcp/ambitions_repo_mcp/server.py
codex mcp add openaiDeveloperDocs --url https://developers.openai.com/mcp
codex mcp list
which xcodebuildmcp || true
xcodebuildmcp --version || true
which docker || true
docker --version || true
```

## Verified Codex MCP Registration

`codex mcp list` now shows:

- `ambitionsRepo` with command `python3` and the repo-local MCP01 server path.
- `openaiDeveloperDocs` with URL `https://developers.openai.com/mcp`.
- existing `xcodebuildmcp` with command `npx -y xcodebuildmcp@latest mcp`.

## Not Installed

GitHub official MCP was not installed because Docker was unavailable and no read-only GitHub token was created or requested.

Standalone `xcodebuildmcp` was not installed in PATH. The existing Codex MCP entry uses `npx`.

## Config Changes

Global Codex MCP config was updated by `codex mcp add` for:

- `ambitionsRepo`
- `openaiDeveloperDocs`

Repo-local `.xcodebuildmcp/config.yaml` was created with simulator-only defaults:

```yaml
schemaVersion: 1
enabledWorkflows:
  - simulator
sessionDefaults:
  default:
    scheme: Ambitions
    simulatorName: iPhone 17
```

## Non-Claims

This registration report does not claim GitHub MCP readiness, GitHub write tools, hosted CI, build success, simulator run proof, device proof, public accessibility proof, release readiness, App Store readiness, TestFlight readiness, legal/privacy signoff, or signing automation.
