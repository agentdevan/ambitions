# MCP Local Production OS Plan

<!-- markdownlint-disable MD013 -->

Status: Active plan for Ambitions local MCP tooling.  
Date: 2026-05-08  
Scope: local Mac / Codex production acceleration. Not app runtime.

## Purpose

Ambitions MCP is a local production operating layer for Codex. It gives Codex deterministic tools for repo truth, active batch state, EFC applicability, forbidden claim scanning, closeout validation, and changed-file impact routing.

MCP is not part of the Ambitions app runtime. It is developer tooling for the dedicated Ambitions Mac VM.

## Core Principle

```text
MCP improves production speed by making repo truth executable.
MCP must not become an unbounded shell, telemetry system, hosted service, or app dependency.
```

## Deployment Model

Ambitions uses local stdio MCP servers installed from the repo and configured in the Mac VM's Codex config.

Initial server:

```text
tools/mcp/ambitions_repo_mcp/
```

This first server is read-only and stdlib-only. It has no arbitrary shell execution, no external network, no writes, no secrets access, and no production app dependency.

## Phase 1 — Repo Truth MCP

Server: `ambitions_repo_mcp`

Tools:

- `get_active_batch`
- `get_efc_overlay_status`
- `get_source_truth_stack`
- `check_efc_applicability`
- `changed_file_impact`
- `detect_forbidden_claims`
- `check_batch_closeout_shape`
- `summarize_repo_posture`

Outcome:

Codex can start every batch by asking the repo for active state and EFC obligations instead of rereading and guessing from long docs.

## Phase 2 — Controlled Proof MCP

Server: `ambitions_proof_mcp`

Allowed named tools only:

- `list_available_validations`
- `run_named_validation`
- `collect_latest_logs`
- `generate_proof_packet`
- `check_validation_policy`

Allowed validation names:

- `mcp01_self_test`
- `repo_claim_scan`
- `efc_applicability_scan`
- `doc_link_scan_basic`
- `git_status_summary`
- `xcodegen_check_dry_run`
- `build_local`
- `focused_tests`

No generic shell tool is allowed. Commands must be allowlisted and must produce claim-safe evidence packets.

## Phase 3 — Visual / Accessibility MCP

Future modules:

- `ambitions_visual_mcp`
- `ambitions_accessibility_mcp`

Targets:

- simulator screenshot capture
- visual baseline/diff packets
- FVQ proof packet generation
- accessibility tree extraction
- Accessibility Shadow Surface validation
- Dynamic Type / Reduce Motion / Differentiate Without Color checks

## Phase 4 — Fixture / Source / Release MCP

Future modules:

- `ambitions_fixture_mcp`
- `ambitions_source_atlas_mcp`
- `ambitions_release_truth_mcp`

Targets:

- Ambitions Twin Fixtures
- source-pack schema validation
- changed claim IDs and local impact match
- release truth packet generation
- App Store claim scanning
- support/privacy URL readiness

## External MCP Policy

External MCPs are governed by [MCP External Server Setup](MCP_EXTERNAL_SERVER_SETUP.md) and [GitHub Native Tooling Policy](GITHUB_NATIVE_TOOLING_POLICY.md).

Current approved posture:

- Ambitions Repo MCP: local read-only.
- OpenAI Developer Docs MCP: configured for docs lookup.
- GitHub MCP: read-only future setup only; no token in repo; no write tools.
- XcodeBuildMCP: simulator workflow only until baseline validation expands.
- Hosted CI: not allowed without explicit cost/security/runner approval.

## Security Rules

Hard rules for all Ambitions MCPs:

- read-only first
- local-only by default
- no arbitrary shell passthrough
- no filesystem access outside repo root
- no secrets or keychain access
- no external network by default
- no hosted AI or user-data server
- no telemetry or analytics
- no production app dependency
- no app-source mutation unless a later explicitly approved write MCP exists
- no public release claim without repo evidence

## Production Speed Moat

The MCP moat is not the protocol itself. The moat is the Ambitions-specific proof stack:

- active batch safety
- EFC applicability
- source-truth resolution
- changed-file impact routing
- claim scanning
- closeout shape validation
- future visual/accessibility/source/release proof tools

This turns Ambitions from a repo with strong docs into a repo with executable production truth.

## Non-Claims

This plan does not implement app behavior, change production Swift, add app dependencies, create hosted CI, or claim release/device/accessibility/legal/privacy readiness.
