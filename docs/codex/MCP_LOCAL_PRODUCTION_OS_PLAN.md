# MCP Local Production OS Plan

<!-- markdownlint-disable MD013 -->

Status: Active plan for Ambitions local MCP tooling.  
Date: 2026-05-18  
Scope: local Mac / Codex production acceleration. Not app runtime.

## Purpose

Ambitions MCP is a local production operating layer for Codex. It gives Codex deterministic tools for repo truth, active batch state, EFC applicability, forbidden claim scanning, closeout validation, changed-file impact routing, validation planning, continuation decisions, prompt preflight, run summaries, and queue next-action lookup.

MCP is not part of the Ambitions app runtime. It is developer tooling for the dedicated Ambitions Mac VM.

## Core Principle

```text
MCP improves production speed by making repo truth executable.
MCP must not become an unbounded shell, telemetry system, hosted service, or app dependency.
```

## Deployment Model

Ambitions uses local stdio MCP servers installed from the repo and configured in the Mac VM's Codex config.

Implemented servers:

```text
tools/mcp/ambitions_repo_mcp/
tools/mcp/ambitions_proof_mcp/
```

The repo MCP is read-only and stdlib-only. It has no arbitrary shell execution, no external network, no writes, no secrets access, and no production app dependency.

The proof MCP exposes allowlisted validation execution only. It is not a generic shell and does not expose signing, release upload, hosted CI creation, network, secrets, or git mutation tools.

## Phase 1 — Repo Truth + Autonomy Control MCP

Server: `ambitions_repo_mcp`

Base tools:

- `get_active_batch`
- `get_efc_overlay_status`
- `get_source_truth_stack`
- `check_efc_applicability`
- `changed_file_impact`
- `detect_forbidden_claims`
- `check_batch_closeout_shape`
- `summarize_repo_posture`

Autonomy control-plane tools:

- `autonomy_preflight`
- `required_validation_plan`
- `continuation_oracle`
- `resolve_active_truth`
- `obsolete_authority_scan`
- `batch_prompt_preflight`
- `latest_run_summary`
- `queue_next_action`

Outcome:

Codex can start every batch by asking the repo for active state, source truth, EFC obligations, validation requirements, and continuation rules instead of rereading and guessing from long docs.

Recommended start-of-batch sequence:

```text
get_active_batch
summarize_repo_posture
autonomy_preflight
required_validation_plan
batch_prompt_preflight
```

Recommended post-run sequence:

```text
latest_run_summary
continuation_oracle
check_batch_closeout_shape
detect_forbidden_claims
```

## Phase 2 — Controlled Proof MCP

Server: `ambitions_proof_mcp`

Allowed named tools only:

- `list_available_validations`
- `run_named_validation`
- `collect_latest_logs`
- `generate_proof_packet`
- `check_validation_policy`
- `xcode_latest_summary`
- `xcode_failure_classification`

Preferred validation names:

- `mcp01_self_test`
- `repo_claim_scan`
- `efc_applicability_scan`
- `doc_link_scan_basic`
- `git_status_summary`
- `xcodegen_check_dry_run`
- `xcode_validate_build`
- `xcode_validate_build_for_testing`
- `xcode_validate_focused_test`
- `xcode_validate_test_plan`

Legacy fallback validation names:

- `build_local`
- `focused_tests`

No generic shell tool is allowed. Commands must be allowlisted and must produce claim-safe evidence packets.

Simulator/Xcode validations route through `scripts/ambitions-xcode-validate.sh` and use a server-side 1800-second timeout for simulator workflows.

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
- Ambitions Proof MCP: local allowlisted proof execution.
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
- obsolete authority scanning
- changed-file impact routing
- validation planning
- continuation decisions
- prompt preflight
- run summarization
- claim scanning
- closeout shape validation
- future visual/accessibility/source/release proof tools

This turns Ambitions from a repo with strong docs into a repo with executable production truth.

## Non-Claims

This plan does not implement app behavior, change production Swift, add app dependencies, create hosted CI, or claim release/device/accessibility/legal/privacy readiness.