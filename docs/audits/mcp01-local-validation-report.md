# MCP01 Local Validation Report

Date: 2026-05-08
Result: Green with pytest Yellow
Batch: MCP01 local validation
Type: read-only Ambitions Repo MCP validation

## Active Batch Evidence

Current active batch before validation:

- Current batch: `PK02 Architecture Boundary Scanner / Accepted Yellow`
- Next eligible batch: `PK03 AppUnitOfWork Foundation`
- Sources checked: `.codex/state/active-batch.yml`, `.codex/reports/current-batch-train-state.md`, `docs/codex/BATCH_REGISTRY.md`

## Commands Run

```bash
git status --short
git pull --ff-only
python3 tools/mcp/ambitions_repo_mcp/server.py --self-test
python3 -m pytest tools/mcp/ambitions_repo_mcp/tests
```

Manual JSON-RPC smoke test was also run against `tools/mcp/ambitions_repo_mcp/server.py` for:

- `initialize`
- `tools/list`
- `get_active_batch`
- `check_efc_applicability`

Raw logs:

- `.codex/logs/mcp/mcp01-self-test-2026-05-08.log`
- `.codex/logs/mcp/mcp01-pytest-2026-05-08.log`
- `.codex/logs/mcp/mcp01-jsonrpc-manual-2026-05-08.log`

## Outputs

Self-test:

```text
ambitions_repo_mcp self-test passed
```

Pytest:

```text
/Applications/Xcode.app/Contents/Developer/usr/bin/python3: No module named pytest
```

Manual JSON-RPC confirmed:

- server info: `ambitions_repo_mcp` version `0.1.0`
- tool list exposed all eight expected read-only tools
- `get_active_batch` returned `PK02 Architecture Boundary Scanner` and `PK03 AppUnitOfWork Foundation`
- `check_efc_applicability` triggered for `Native/Ambitions/Features/Today/TodayView.swift`

## Result

MCP01 is safe to use as a read-only local repo-truth MCP.

Pytest remains Yellow because pytest is not installed in the active Python environment. No random dependency installation was performed.

## Non-Claims

This validation does not claim app build success, app test success, simulator proof, physical-device proof, public accessibility proof, release readiness, App Store readiness, TestFlight readiness, legal/privacy signoff, hosted CI proof, or GitHub tooling proof.
