# PFC08 Corruption Recovery Backup Restore Plan Report
<!-- markdownlint-disable MD013 -->

Result: Green
Date: 2026-05-05
Train: PFC01-PFC40 Platform / Framework / Compliance Completion Train
Batch: PFC08 Corruption Recovery / Backup / Restore Plan
Owner: Persistence / Reliability

## Summary

PFC08 completed a docs-only corruption, backup, restore, and recovery plan. The
current repo has service-level export/import and malformed-package safety proof
from PFC07, but it does not yet have a finished user-facing You / Trust Center
backup/restore flow, production-store migration proof on real user data, CloudKit
or account sync, automated backups, or device-level restore evidence.

No production Swift, schema, test, workflow, project, dependency, signing,
entitlement, privacy manifest, lockfile, generated file, CloudKit/sync/account
runtime, user-facing export/import/delete UI, AI/LDI runtime, or
release/legal/App Store/TestFlight/device/public accessibility claim was changed
or created.

## Files Inspected

- `docs/audits/pfc06-schema-persistence-source-truth-report.md`
- `docs/audits/pfc07-migration-ladder-backward-compatibility-tests-report.md`
- `docs/canon/DATA_LOCAL_SYNC_EXPORT.md`
- `docs/canon/TRUST_PRIVACY_MEMORY.md`
- `Native/Ambitions/Persistence/SwiftDataStore.swift`
- `Native/Ambitions/Persistence/PortableSnapshotContracts.swift`
- `Native/Ambitions/Persistence/PortableSnapshotService.swift`
- `Native/Ambitions/Persistence/LegacyImportService.swift`
- `Native/Ambitions/Persistence/SyncCapabilityContracts.swift`
- `Native/AmbitionsTests/Persistence/PortableSnapshotServiceTests.swift`
- `Native/AmbitionsTests/Persistence/PersistenceRepositoryTests.swift`
- `Native/Ambitions/Features/Profile/ProfileFeatureService.swift`
- `Native/Ambitions/Features/Profile/ProfileScreen.swift`

## Files Changed

- `docs/codex/batches/PFC08_Corruption_Recovery_Backup_Restore_Plan_Prompt.md`
- `docs/audits/pfc08-corruption-recovery-backup-restore-plan-report.md`
- `docs/codex/batch-trains/PFC01_PFC40_PLATFORM_FRAMEWORK_COMPLIANCE_TRAIN.md`
- `docs/codex/GLOBAL_FULL_STACK_COMPLETION_ORDER.md`
- `docs/codex/GLOBAL_OPTIMIZED_IMPLEMENTATION_ORDER.md`
- `docs/codex/BATCH_REGISTRY.md`
- `docs/codex/CONTEXT_INDEX.md`
- `.codex/reports/current-run-state.md`
- `.codex/reports/current-batch-train-state.md`

## Current Recovery Evidence

Existing evidence from PFC07:

- 28 focused persistence tests passed with 0 failures.
- `PortableSnapshotServiceTests` proves unsupported portable snapshot schema
  versions are rejected before import.
- `PortableSnapshotServiceTests` proves malformed portable packages fail decode
  and leave existing local data untouched.
- `PortableSnapshotServiceTests` proves legacy packages without manifests can
  merge without deleting local data.
- `PortableSnapshotServiceTests` proves manifest mismatches and partial-package
  references produce reviewable warnings instead of silent drops.
- `PortableSnapshotServiceTests` proves an encoded portable package can restore
  into a fresh in-memory store.
- `SyncCapabilityTests` proves the current sync posture is local-only and
  unavailable.

Existing implementation boundaries:

- `AmbitionsPersistenceStore.resetAllData()` is a technical store reset used by
  portable snapshot replace-local-store import and tests.
- `resetAllData()` is not a user-facing delete-all-memory action.
- `PortableImportMode.replaceLocalStore` requires explicit confirmation in the
  import safety summary and must stay confirmation-gated in future UI.
- `DATA_LOCAL_SYNC_EXPORT.md` keeps export-before-cloud-sync and no-sync-claim
  posture active.

## Recovery Scenario Matrix

| Scenario | Current Evidence | User-Facing Future Copy | Owner |
| --- | --- | --- | --- |
| Malformed portable package | Decode failure test leaves local data untouched. | `This package could not be opened. Your Ambitions data is still local.` | PFC25 / You Trust Center |
| Unsupported portable snapshot version | Unsupported schema test throws before import. | `This package needs a newer Ambitions review before import.` | PFC07 / PFC25 |
| Manifest mismatch | Manifest warning test preserves local data and reports review. | `Review this package before import. Some counts do not match.` | PFC25 |
| Partial package references | Reference warning test keeps records and asks for review. | `Some restored items need review before they are trusted.` | PFC25 |
| Merge conflict | Conflict tests keep newer local records or require user decision. | `Local data was kept where review is needed.` | PFC07 / PFC25 |
| Replace local store | Fresh-store restore test passes; confirmation is required. | `Replace local data only after export and explicit confirmation.` | PFC08 / PFC25 |
| Export failure | Canon copy exists, no UI proof in PFC08. | `Export did not complete. Your Ambitions data is still local.` | PFC25 |
| SwiftData store open failure | No production recovery implementation proved by PFC08. | `Ambitions could not open local data. Nothing was synced or deleted.` | PFC08 future repair / Platform |
| App Group unavailable in unsigned simulator tests | Observed as simulator/signing noise during tests, not production proof. | No user-facing claim from simulator-only evidence. | PFC12 |
| Device backup/restore | Not proved. | No claim until human/device proof exists. | PFC40 / release-human review |

## User-Facing Copy Rules

Allowed future copy patterns:

- `Your Ambitions data is still local.`
- `Review this package before import.`
- `Some restored items need review before they are trusted.`
- `Local data was kept where review is needed.`
- `Export did not complete. Your Ambitions data is still local.`
- `Replace local data only after export and explicit confirmation.`

Forbidden future copy patterns:

- Claims that cloud sync, account backup, iCloud restore, device backup, or
  automatic recovery exists before implementation proof.
- Shame or blame language for import, export, restore, or corruption failures.
- Copy implying data was backed up, synced, deleted, restored, or recovered when
  validation only proves local service-level behavior.
- Copy that treats technical `resetAllData()` as user-facing delete-all-memory.

## Future Implementation Requirements

Before user-facing recovery implementation:

1. Keep local-first truth visible.
2. Require explicit confirmation for replace-local-store and destructive
   actions.
3. Offer export before destructive recovery where export is available.
4. Keep delete-all-memory memory-only unless the user separately chooses a
   broader destructive action.
5. Preserve local data on malformed package decode and unsupported version
   errors.
6. Report conflicts and reference warnings instead of silently overwriting or
   dropping records.
7. Redact private previews and avoid sensitive content in widgets,
   notifications, Live Activities, logs, or external surfaces.
8. Do not claim CloudKit/account sync until PFC09-PFC11 approve and prove it.
9. Do not claim device backup/restore until human/device evidence exists.

## Stop Conditions For Future Recovery Work

Stop if any future batch requires:

- Destructive store reset without explicit confirmation.
- Delete-all-memory deleting goals, plans, captures, proof, receipts, reviews,
  or settings.
- Silent import overwrite without conflict reporting.
- CloudKit/account/server sync behavior before PFC09-PFC11 approval.
- External-surface exposure of sensitive restored data.
- Unsupported privacy/legal/release/App Store/TestFlight/device claim.
- Schema migration on production-like data without migration tests.
- Weakening local-first canon to pass validation.

## Validation Commands Run

- `git status --short`
- `git diff --check`
- touched-doc trailing whitespace scan
- `scripts/cqs-privacy-security-claim-scan.sh docs/codex/batches/PFC08_Corruption_Recovery_Backup_Restore_Plan_Prompt.md docs/audits/pfc08-corruption-recovery-backup-restore-plan-report.md || true`
- `scripts/run-doc-qa.sh || true`
- `scripts/batch-train-gate-check.sh || true`

## Validation Results

- `git diff --check`: PASS.
- Touched-doc trailing whitespace: PASS.
- CQS privacy/security claim scan: PASS with zero hits for the PFC08 prompt
  scan root.
- `scripts/run-doc-qa.sh || true`: PASS with accepted Yellow advisory backlog.
  Lychee reported 650 OK and 0 errors. Markdownlint and deprecated-language
  findings are repo-wide known backlog and were not introduced as production
  source changes by PFC08.
- `scripts/batch-train-gate-check.sh || true`: PASS with expected dirty-tree
  Yellow hint before commit.
- Focused persistence tests were not rerun for PFC08 because no production
  Swift, tests, schema, project, or recovery code changed. PFC07 immediately
  preceding this batch passed the focused persistence slice: 28 tests, 0
  failures.

## Result Classification

Green. PFC08 created the recovery plan and user-facing claim boundary without
changing implementation files. Remaining recovery UI, destructive action proof,
production-store migration proof, App Group/external-surface recovery, and
device backup evidence are owned by later PFC batches.

## Rollback Path

Revert the PFC08 commit to remove the docs-only prompt, audit report, and train
state updates. No production Swift, schema, test, generated project, workflow,
dependency, signing, or entitlement rollback is needed because none were
changed.

## Next Eligible Batch

PFC09 iCloud / CloudKit Sync Strategy Decision.
