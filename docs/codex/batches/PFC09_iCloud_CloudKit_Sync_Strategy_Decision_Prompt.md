# PFC09 iCloud CloudKit Sync Strategy Decision Prompt
<!-- markdownlint-disable MD013 -->

Status: Complete / Green as docs-only sync strategy decision record.
Date: 2026-05-05
Train: PFC01-PFC40 Platform / Framework / Compliance Completion Train
Owner: Sync / Privacy

## Purpose

Decide the current Ambitions sync strategy for the platform train using existing
canon and repo evidence. PFC09 must separate current launch truth from future
sync options.

This batch does not implement sync, create CloudKit containers, add entitlements,
add account systems, add server/backend integrations, alter persistence schema,
or make release/privacy/legal claims.

## Source Truth

Read before execution:

- `docs/canon/DATA_LOCAL_SYNC_EXPORT.md`
- `docs/canon/TRUST_PRIVACY_MEMORY.md`
- `docs/canon/Ambitions_Platform_Legal_And_Framework_Completion_Plan.md`
- `docs/audits/pfc06-schema-persistence-source-truth-report.md`
- `docs/audits/pfc07-migration-ladder-backward-compatibility-tests-report.md`
- `docs/audits/pfc08-corruption-recovery-backup-restore-plan-report.md`
- `Native/Ambitions/Persistence/SyncCapabilityContracts.swift`
- `Native/AmbitionsTests/Persistence/SyncCapabilityTests.swift`

## Allowed Files

- `docs/codex/batches/PFC09_iCloud_CloudKit_Sync_Strategy_Decision_Prompt.md`
- `docs/audits/pfc09-icloud-cloudkit-sync-strategy-decision-report.md`
- `docs/codex/batch-trains/PFC01_PFC40_PLATFORM_FRAMEWORK_COMPLIANCE_TRAIN.md`
- `docs/codex/GLOBAL_FULL_STACK_COMPLETION_ORDER.md`
- `docs/codex/GLOBAL_OPTIMIZED_IMPLEMENTATION_ORDER.md`
- `docs/codex/BATCH_REGISTRY.md`
- `docs/codex/CONTEXT_INDEX.md`
- `.codex/reports/current-run-state.md`
- `.codex/reports/current-batch-train-state.md`

## Forbidden Files

- Production Swift, tests, persistence schema, CloudKit containers, entitlements,
  signing, project files, workflows, dependencies, privacy manifests, lockfiles,
  generated files, network/auth/backend/AI/LDI runtime, and user-facing sync UI.

## Required Decision

Choose one current strategy:

- Current launch strategy: explicit local-only / no launch sync.
- Future option A: Apple-first private CloudKit sync after export/trust proof.
- Future option B: server-backed sync only after account, legal, privacy,
  security, business, and data-processing decisions.
- Future option C: remain local-only indefinitely.

PFC09 must not choose a future sync implementation path unless existing source
truth authorizes it. If not authorized, record the current local-only strategy
and defer future provider selection to a later human/product/platform decision.

## Required Validation

Run:

- `git status --short`
- `git diff --check`
- touched-doc trailing whitespace scan
- `scripts/cqs-privacy-security-claim-scan.sh <touched PFC09 docs> || true`
- `scripts/run-doc-qa.sh || true`
- `scripts/batch-train-gate-check.sh || true`

Do not run build/test unless source, tests, project, entitlements, dependencies,
or sync runtime files change.

## Closeout

Close Green if the decision record preserves local-first truth, blocks fake sync
claims, names future prerequisites, and makes no implementation edits.
