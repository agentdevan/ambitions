<!-- AMBITIONS_RUNNER_REQUIRED: true -->
<!-- RUN_WITH: scripts/ambitions-codex-train.sh -->
<!-- DIRECT_CODEX_EXECUTION: forbidden_unless_user_explicitly_bypasses_runner -->

# HARNESS-T02-B01 — Artifact Manifest Schema (AMB-294)

## Batch ID
HARNESS-T02-B01-artifact-manifest-schema

## Active source truth
- docs/truth/README.md
- docs/truth/PRODUCT_DESIGN_TRUTH.md
- docs/truth/PRODUCT_MOAT_TRUTH.md
- docs/truth/IMPLEMENTATION_TRUTH.md
- docs/truth/RELEASE_TRUTH.md
- docs/truth/CODEX_PROCESS_TRUTH.md
- docs/truth/HISTORICAL_POLICY.md
- AGENTS.md

## Objective
Install artifact-manifest schema support for the harness lane as docs/scripts only.

## Allowed scope
- docs/codex/harness/**
- scripts/harness/**
- prompts/** if needed for wiring

## Forbidden scope
- No edits to docs/truth/*
- No edits to Swift/app source
- No release/build/app/accessibility/privacy/legal/device/TestFlight/App Store readiness claims
- No branch creation or push

## Required deliverables
1. docs/codex/harness/HARNESS_ARTIFACT_SCHEMA.md
2. scripts/harness/ambitions-artifact-manifest.py

## Acceptance gates
- HARNESS_ARTIFACT_SCHEMA.md defines required fields.
- ambitions-artifact-manifest.py can emit JSON.
- Manifest supports Green / Yellow / Red.
- Manifest includes claims made and claims not made.
- Manifest is tied to branch/SHA and command output.

## Validation
- python3 -m py_compile scripts/harness/ambitions-artifact-manifest.py
- grep checks for Green/Yellow/Red, claims made/claims not made, branch/SHA/command/artifact/status in HARNESS_ARTIFACT_SCHEMA.md
- Scope check: only docs/scripts/prompts paths changed

## Hard Red
Stop if any docs/truth/* or Swift/source files are modified.

## Rollback
Use targeted `git restore -- <path>` for any out-of-scope file changes.

## Required status output
Must output STATUS: GREEN | YELLOW | RED with explicit non-claims.
