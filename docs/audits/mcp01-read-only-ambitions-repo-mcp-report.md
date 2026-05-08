# MCP01 Read-Only Ambitions Repo MCP Report

<!-- markdownlint-disable MD013 -->

Date: 2026-05-08  
Result: Green with local-validation Yellow  
Batch: MCP01 — Read-Only Ambitions Repo MCP  
Type: local developer tooling / Codex acceleration

## Result

MCP01 installed the first Ambitions local MCP server into the repo:

```text
tools/mcp/ambitions_repo_mcp/
```

The server is read-only, stdlib-only, repo-root bounded, and intended for a dedicated Ambitions Mac VM. It is developer tooling for Codex and is not part of the Ambitions iPhone app runtime.

## Files Changed

Created:

- `docs/codex/MCP_LOCAL_PRODUCTION_OS_PLAN.md`
- `docs/codex/MCP_CODEX_SETUP.md`
- `docs/codex/batches/MCP01_Read_Only_Ambitions_Repo_MCP_Prompt.md`
- `docs/audits/mcp01-read-only-ambitions-repo-mcp-report.md`
- `tools/mcp/ambitions_repo_mcp/README.md`
- `tools/mcp/ambitions_repo_mcp/server.py`
- `tools/mcp/ambitions_repo_mcp/pyproject.toml`
- `tools/mcp/ambitions_repo_mcp/tests/test_server_tools.py`
- `scripts/setup-ambitions-repo-mcp.sh`

Updated:

- `docs/codex/README.md`
- `AGENTS.md`

## Tools Added

The MCP server exposes:

- `get_active_batch`
- `get_efc_overlay_status`
- `get_source_truth_stack`
- `check_efc_applicability`
- `changed_file_impact`
- `detect_forbidden_claims`
- `check_batch_closeout_shape`
- `summarize_repo_posture`

## Safety Properties

MCP01 is intentionally constrained:

- read-only
- no arbitrary shell tool
- no write tools
- no network access
- no secrets or Keychain access
- no filesystem access outside repo root
- no production Swift changes
- no app runtime dependency
- no hosted CI
- no telemetry or analytics
- no release/platform claim

## Protocol Shape

The server implements the local stdio JSON-RPC surface needed by Codex:

- `initialize`
- `notifications/initialized`
- `ping`
- `tools/list`
- `tools/call`

The server emits only MCP JSON messages to stdout during normal stdio mode.

## Validation

Validation installed:

```bash
python3 tools/mcp/ambitions_repo_mcp/server.py --self-test
```

Optional tests installed:

```bash
python3 -m pytest tools/mcp/ambitions_repo_mcp/tests
```

Validation not run from this environment:

- local Python self-test
- pytest
- Codex MCP registration
- `codex mcp list`
- local build/test/doc QA

Reason: this patch was performed through GitHub connector writes, not inside the Mac VM. The server must be validated on the dedicated Ambitions Mac VM before relying on it in Codex.

## Setup Command For Mac VM

From repo root:

```bash
python3 tools/mcp/ambitions_repo_mcp/server.py --self-test
bash scripts/setup-ambitions-repo-mcp.sh
```

Then add the printed config to `~/.codex/config.toml` or use `codex mcp add` if supported by the installed Codex version.

## EFC Applicability

EFC applicability: invoked.

- Product proof: not applicable; no app behavior changed.
- Trust proof: MCP tools expose active batch, EFC, source-truth, and claim-scan helpers.
- Privacy proof: no secrets/network/user data access; repo-root bounded reads only.
- Accessibility proof: not applicable; no UI behavior changed.
- Degraded-state proof: self-test detects missing required files.
- Test proof: self-test and pytest tests added, not run from this environment.
- Release-claim boundary: no release/device/accessibility/legal/privacy/App Store claim added.
- Recovery proof: rollback path below.
- Performance proof: not applicable beyond small bounded file reads.
- Continuation proof: AGENTS and Codex README now index MCP guidance.

## Active Batch State

Active batch state was checked during installation. At one check, `.codex/state/active-batch.yml` reported:

```text
Current batch: AFI14 Cross-Surface Coherence Review
Next eligible batch: AFI15 Founder Acceptance Review
```

MCP01 did not modify active batch state.

## Non-Claims

MCP01 does not claim:

- Ambitions app behavior implementation
- production Swift changes
- app build success
- test success
- Codex MCP registration on the Mac VM
- physical-device proof
- public accessibility proof
- release readiness
- App Store readiness
- TestFlight readiness
- legal/privacy compliance
- hosted AI
- user-data server
- telemetry or analytics
- hosted CI

## Rollback Path

Remove or revert:

- `tools/mcp/ambitions_repo_mcp/`
- `scripts/setup-ambitions-repo-mcp.sh`
- `docs/codex/MCP_LOCAL_PRODUCTION_OS_PLAN.md`
- `docs/codex/MCP_CODEX_SETUP.md`
- `docs/codex/batches/MCP01_Read_Only_Ambitions_Repo_MCP_Prompt.md`
- `docs/audits/mcp01-read-only-ambitions-repo-mcp-report.md`
- MCP references in `docs/codex/README.md`
- MCP references in `AGENTS.md`

No app data, schema, source code, signing, entitlement, dependency, generated project, or runtime rollback is required.

## Next Recommended MCP Work

After the Mac VM validates MCP01:

1. MCP02 — Controlled Proof MCP with allowlisted commands only.
2. MCP03 — Visual Proof MCP for screenshots and FVQ packets.
3. MCP04 — Accessibility Shadow MCP.
4. MCP05 — Ambitions Twin Fixture MCP.
5. MCP06 — Source Atlas Pack MCP.
6. MCP07 — Release Truth MCP.

Do not add shell/write/network MCPs until MCP01 is stable and a security review exists.
