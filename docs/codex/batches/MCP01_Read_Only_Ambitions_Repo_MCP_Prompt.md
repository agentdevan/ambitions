# MCP01 — Read-Only Ambitions Repo MCP Prompt

<!-- markdownlint-disable MD013 -->

Status: Active source-truth prompt for the first Ambitions MCP server.  
Date: 2026-05-08  
Batch code: MCP01  
Type: local developer tooling / Codex acceleration. No app runtime dependency.

## Mission

Create the first local Ambitions MCP server for the dedicated Ambitions Mac VM.

The server must be read-only, local-only, stdlib-only, and safe for Codex to use before touching the repo. It should make active batch state, EFC proof obligations, source-truth stack, changed-file impact, forbidden claim scanning, and closeout-shape validation executable.

## Product Boundary

MCP01 is developer tooling only. It must not become part of the Ambitions iPhone app runtime.

## Required Files

- `tools/mcp/ambitions_repo_mcp/README.md`
- `tools/mcp/ambitions_repo_mcp/server.py`
- `tools/mcp/ambitions_repo_mcp/pyproject.toml`
- `tools/mcp/ambitions_repo_mcp/tests/test_server_tools.py`
- `scripts/setup-ambitions-repo-mcp.sh`
- `docs/codex/MCP_LOCAL_PRODUCTION_OS_PLAN.md`
- `docs/codex/MCP_CODEX_SETUP.md`
- `docs/audits/mcp01-read-only-ambitions-repo-mcp-report.md`

## Required Tools

The server must expose:

- `get_active_batch`
- `get_efc_overlay_status`
- `get_source_truth_stack`
- `check_efc_applicability`
- `changed_file_impact`
- `detect_forbidden_claims`
- `check_batch_closeout_shape`
- `summarize_repo_posture`

## Safety Requirements

- Read-only.
- No arbitrary shell execution.
- No network access.
- No secrets or Keychain access.
- No filesystem access outside the repo root.
- No writes.
- No production Swift changes.
- No app dependencies.
- No hosted CI.
- No telemetry or analytics.
- No release, App Store, TestFlight, device, public accessibility, legal/privacy, or build claims.

## Protocol Requirements

- Use JSON-RPC 2.0 over stdio.
- Stdout must emit only valid MCP messages.
- Logging must not write to stdout.
- The server must respond to `initialize`, `tools/list`, `tools/call`, and `ping`.
- Tool responses must return text content containing structured JSON.

## Validation

At minimum:

```bash
python3 tools/mcp/ambitions_repo_mcp/server.py --self-test
```

Optional if local Python test tooling exists:

```bash
python3 -m pytest tools/mcp/ambitions_repo_mcp/tests
```

## Green Criteria

MCP01 is Green if:

- server files exist;
- self-test exists and can be run locally;
- tools are read-only and repo-root bounded;
- setup docs explain Codex config;
- docs index the MCP plan;
- audit report records non-claims.

## Yellow Criteria

Accepted Yellow is allowed if local tests are not run from the current environment, provided the server remains docs/tooling-only and no app behavior changed.

## Red Criteria

Hard Red if MCP01:

- adds arbitrary shell execution;
- writes to repo or user files;
- accesses secrets or external network;
- modifies app source or build/signing files;
- claims release/device/accessibility/legal/privacy proof;
- becomes an app runtime dependency.
