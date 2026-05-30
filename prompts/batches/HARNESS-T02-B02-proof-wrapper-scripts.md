<!-- AMBITIONS_RUNNER_REQUIRED: true -->
<!-- RUN_WITH: scripts/ambitions-codex-train.sh -->
<!-- DIRECT_CODEX_EXECUTION: forbidden_unless_user_explicitly_bypasses_runner -->

# HARNESS-T02-B02 — Proof Wrapper Scripts

Issue: AMB-295

## Objective
Install Slice 1 proof wrapper scripts that collect git metadata, environment metadata, command logs, exit codes, and artifact manifests.

## Scope
Docs/scripts/prompts only. No app source. No `docs/truth/*` changes.

## Required outputs
- `scripts/harness/ambitions-proof-baseline.sh`
- `scripts/harness/ambitions-xcresult-summary.py`

## Non-claims
This batch does not prove app implementation, build success, test success, accessibility, device, TestFlight, App Store, privacy/legal, or release readiness.
