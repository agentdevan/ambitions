# PFC11 Sync Implementation And Conflict Tests Prompt
<!-- markdownlint-disable MD013 -->

Status: Complete / Green as explicit local-only sync closure and safe deferral.
Date: 2026-05-06
Train: PFC01-PFC40 Platform / Framework / Compliance Completion Train
Owner: Sync

## Purpose

Run the PFC11 decision branch after PFC09 and PFC10. PFC11 may implement
bounded CloudKit sync only if predecessor source truth approves it. If sync is
not approved, PFC11 must close as an explicit local-only deferral, preserve the
current runtime no-claim boundary, and name the proof required before future
implementation.

PFC11 does not implement sync by default.

## Source Truth

Read before execution:

- `docs/audits/pfc09-icloud-cloudkit-sync-strategy-decision-report.md`
- `docs/canon/Ambitions_CloudKit_Schema_Zone_Conflict_Model.md`
- `docs/audits/pfc10-cloudkit-schema-zone-conflict-model-report.md`
- `docs/canon/DATA_LOCAL_SYNC_EXPORT.md`
- `docs/canon/Ambitions_Security_Threat_Model_And_Secrets_Audit.md`
- `Native/Ambitions/Persistence/SyncCapabilityContracts.swift`
- `Native/AmbitionsTests/Persistence/SyncCapabilityTests.swift`

## Allowed Files

- `docs/codex/batches/PFC11_Sync_Implementation_And_Conflict_Tests_Prompt.md`
- `docs/audits/pfc11-sync-implementation-conflict-tests-deferral-report.md`
- `docs/codex/batch-trains/PFC01_PFC40_PLATFORM_FRAMEWORK_COMPLIANCE_TRAIN.md`
- `docs/codex/GLOBAL_FULL_STACK_COMPLETION_ORDER.md`
- `docs/codex/GLOBAL_OPTIMIZED_IMPLEMENTATION_ORDER.md`
- `docs/codex/GLOBAL_FUTURE_BATCH_DEPENDENCY_GRAPH.md`
- `docs/codex/BATCH_REGISTRY.md`
- `docs/codex/CONTEXT_INDEX.md`
- `.codex/reports/current-run-state.md`
- `.codex/reports/current-batch-train-state.md`

## Forbidden Files

- Production Swift edits, test edits, persistence schema, CloudKit containers,
  entitlements, signing, project files, workflows, dependencies, privacy
  manifests, lockfiles, generated files, account UI, backend/network/auth code,
  AI/LDI runtime, user-facing sync UI, App Store Connect state, and any
  release/legal/privacy compliance claim.

## Decision Rule

If PFC09/PFC10 do not approve sync implementation, PFC11 must close as explicit
local-only deferral:

- Current runtime remains `LocalOnlySyncCapability`.
- Sync remains unavailable.
- CloudKit remains future-only.
- PFC14 becomes the next eligible global batch.
- Future PFC11 reactivation requires a human/product/platform approval source,
  entitlement/container/signing authorization, reopened privacy/security/legal
  review, migration/rollback proof, and the PFC10 test plan.

## Required Validation

Run:

- `git status --short`
- `git diff --check`
- touched-doc trailing whitespace scan
- focused existing `SyncCapabilityTests`
- `scripts/cqs-privacy-security-claim-scan.sh <touched PFC11 docs> || true`
- `scripts/run-doc-qa.sh || true`
- `scripts/batch-train-gate-check.sh || true`

Do not run broader build/test unless source, tests, project, entitlements,
dependencies, or sync runtime files change.

## Closeout

Close Green if the deferral preserves local-only runtime truth, blocks fake sync
claims, keeps implementation prerequisites explicit, and changes no runtime,
schema, entitlement, signing, project, workflow, dependency, or release files.
