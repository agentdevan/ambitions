# MCP External Server Setup Report

Date: 2026-05-08
Result: Partial Green / Yellow for unavailable external prerequisites
Type: Codex MCP setup and external MCP policy

## Commands Run

```bash
which codex || true
codex --version || true
codex mcp list || true
which xcodebuildmcp || true
xcodebuildmcp --version || true
which docker || true
docker --version || true
which xcodegen || true
xcodegen --version || true
```

## Verified

- Codex CLI exists at `/usr/local/bin/codex`.
- Codex CLI version: `codex-cli 0.129.0`.
- `ambitionsRepo` was added and appears in `codex mcp list`.
- `openaiDeveloperDocs` was added and appears in `codex mcp list`.
- Existing `xcodebuildmcp` appears in `codex mcp list` via `npx -y xcodebuildmcp@latest mcp`.
- XcodeGen exists at `/usr/local/bin/xcodegen`, version `2.45.4`.
- Simulator `iPhone 17` is available.

## Yellow / Not Installed

- Standalone `xcodebuildmcp` binary was not found in PATH.
- Docker was not found, so GitHub official MCP was not installed.
- No GitHub token was requested, created, stored, or written.

## Config Changes

- Added global Codex MCP entry: `ambitionsRepo`.
- Added global Codex MCP entry: `openaiDeveloperDocs`.
- Created `.xcodebuildmcp/config.yaml` with simulator-only defaults for scheme `Ambitions` and simulator `iPhone 17`.

## Non-Claims

This setup does not claim app build success, test success, simulator run proof, device proof, public accessibility proof, release readiness, App Store readiness, TestFlight readiness, legal/privacy signoff, hosted CI, or GitHub write capability.
