# PFC10 CloudKit Schema Zone Conflict Model Prompt
<!-- markdownlint-disable MD013 -->

Status: Complete / Green as docs-only future CloudKit contract and test plan.
Date: 2026-05-06
Train: PFC01-PFC40 Platform / Framework / Compliance Completion Train
Owner: Sync

## Purpose

Define the future CloudKit schema, custom zone, conflict, tombstone, local-only
fallback, and account-unavailable model without implementing sync. PFC10 must
turn the PFC09 local-only decision into a reviewable future contract while
keeping current runtime truth unchanged.

PFC10 does not implement CloudKit, create containers, add entitlements, alter
signing, add account UX, change persistence schema, add network/backend code, or
claim shipped sync.

## Source Truth

Read before execution:

- `docs/audits/pfc09-icloud-cloudkit-sync-strategy-decision-report.md`
- `docs/canon/DATA_LOCAL_SYNC_EXPORT.md`
- `docs/canon/Ambitions_Platform_Legal_And_Framework_Completion_Plan.md`
- `docs/canon/Ambitions_Security_Threat_Model_And_Secrets_Audit.md`
- `Native/Ambitions/Persistence/SyncCapabilityContracts.swift`
- `Native/AmbitionsTests/Persistence/SyncCapabilityTests.swift`
- Official Apple CloudKit documentation for private databases, custom zones,
  records, subscriptions, and change tracking.

## Allowed Files

- `docs/codex/batches/PFC10_CloudKit_Schema_Zone_Conflict_Model_Prompt.md`
- `docs/canon/Ambitions_CloudKit_Schema_Zone_Conflict_Model.md`
- `docs/audits/pfc10-cloudkit-schema-zone-conflict-model-report.md`
- `docs/codex/batch-trains/PFC01_PFC40_PLATFORM_FRAMEWORK_COMPLIANCE_TRAIN.md`
- `docs/codex/GLOBAL_FULL_STACK_COMPLETION_ORDER.md`
- `docs/codex/GLOBAL_OPTIMIZED_IMPLEMENTATION_ORDER.md`
- `docs/codex/GLOBAL_FUTURE_BATCH_DEPENDENCY_GRAPH.md`
- `docs/codex/BATCH_REGISTRY.md`
- `docs/codex/CONTEXT_INDEX.md`
- `.codex/reports/current-run-state.md`
- `.codex/reports/current-batch-train-state.md`

## Forbidden Files

- Production Swift, tests, persistence schema, CloudKit containers,
  entitlements, signing, project files, workflows, dependencies, privacy
  manifests, lockfiles, generated files, network/auth/backend/AI/LDI runtime,
  user-facing sync UI, App Store Connect state, and any release/legal/privacy
  compliance claim.

## Required Contract

The contract must define:

- Current local-only truth and no-claim boundary.
- Future private CloudKit database stance.
- Container, custom zone, and record-family naming policy.
- Field privacy classes and excluded data.
- Tombstones, conflict states, merge rules, and deletion posture.
- Account unavailable, offline queue, retry, and local-only fallback states.
- Subscription/change-token posture.
- Migration, rollback, export/import, and privacy policy prerequisites.
- PFC11 test plan and Hard Red stop conditions.

## Required Validation

Run:

- `git status --short`
- `git diff --check`
- touched-doc trailing whitespace scan
- `scripts/cqs-privacy-security-claim-scan.sh <touched PFC10 docs> || true`
- `scripts/run-doc-qa.sh || true`
- `scripts/batch-train-gate-check.sh || true`

Do not run build/test unless source, tests, project, entitlements, dependencies,
or sync runtime files change.

## Closeout

Close Green if the docs-only contract preserves current local-only runtime
truth, defines a future CloudKit schema/zone/conflict model and test plan, names
approval and proof prerequisites, and makes no implementation or readiness
claim.
