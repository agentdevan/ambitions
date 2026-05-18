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
- autonomy preflight
- validation planning
- continuation decisions
- active truth resolution
- obsolete authority scanning
- batch prompt preflight
- latest run summarization
- queue next-action lookup

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
- does not bypass the Ambitions runner

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

## Base Tools

- `get_active_batch`
- `get_efc_overlay_status`
- `get_source_truth_stack`
- `check_efc_applicability`
- `changed_file_impact`
- `detect_forbidden_claims`
- `check_batch_closeout_shape`
- `summarize_repo_posture`

## Autonomy Control-Plane Tools

- `autonomy_preflight`
- `required_validation_plan`
- `continuation_oracle`
- `resolve_active_truth`
- `obsolete_authority_scan`
- `batch_prompt_preflight`
- `latest_run_summary`
- `queue_next_action`

Recommended start-of-batch MCP sequence:

```text
get_active_batch
summarize_repo_posture
autonomy_preflight
required_validation_plan
batch_prompt_preflight
```

Recommended post-run MCP sequence:

```text
latest_run_summary
continuation_oracle
check_batch_closeout_shape
detect_forbidden_claims
```

## Protocol

The server implements the stdio JSON-RPC MCP surface needed by Codex:

- `initialize`
- `tools/list`
- `tools/call`
- `ping`

It avoids external Python dependencies so it can run on a clean Mac VM.

## Non-Claims

This MCP server provides read-only routing, truth, and proof-planning intelligence only. It does not prove release readiness, TestFlight readiness, App Store readiness, physical-device validation, public accessibility conformance, legal/privacy signoff, hosted CI safety, or production app behavior.