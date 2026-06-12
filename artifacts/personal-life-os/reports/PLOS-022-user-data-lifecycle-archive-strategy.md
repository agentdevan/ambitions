# PLOS-022 User Data Lifecycle and Archive Strategy

Status: Green for AMB-655 lifecycle/archive strategy documentation scope; Yellow for later archive implementation, delete/reset/export UX, retention enforcement, compaction, CloudKit lifecycle transport, device, accessibility, privacy/legal, performance, and release proof
Linear issue: AMB-655
Parent issue: AMB-610
Program phase: PLOS-M02 local data, CloudKit, R2 boundary, and data lifecycle foundation
Updated: 2026-06-12
Branch: main

## Closeout Header

- PLOS child closeout: yes
- Linear issue: AMB-655
- Parent issue: AMB-610
- Green/Yellow/Red status: Green for lifecycle/archive strategy documentation scope; Yellow for unimplemented archive feature behavior, retention enforcement, delete/reset/export UX, CloudKit lifecycle transport, compaction, accessibility, performance, privacy/legal, device, and release proof.
- Pushed to main: pending at report creation
- Push hash: pending at report creation
- App source changed: no
- Runtime features implemented: no
- PLOS-M00 executed: no; AMB-608 / PLOS-M00 and AMB-609 / PLOS-M01 were already complete before this M02 child started.
- Linear identifiers used: AMB issue identifiers only
- Validation run: see Validation
- Red blockers: none for AMB-655 documentation scope
- Yellow limits: this report defines lifecycle policy and archive strategy. It does not implement archive UI, retention enforcement, delete/reset/export flows, CloudKit lifecycle propagation, or compaction.
- Owner approval claimed: no
- Release/TestFlight/App Store readiness claimed: no
- Next recommended action: after AMB-655 commit, push, and Linear closeout, continue AMB-656 / PLOS-023 only.

## Scope

AMB-655 defines create, active, archive, delete, export, restore, reset, and compaction semantics for user-owned data before later implementation work. It prioritizes user-owned clarity over convenience and prevents vague deletion or export claims from entering implementation.

This child does not implement archive features, retention jobs, delete/reset/export UX, CloudKit lifecycle propagation, compaction, annual archives, privacy manifest changes, App Review work, release work, or app runtime behavior.

## Existing-First Inspection

Repo and Linear evidence inspected before adding this artifact:

- Linear parent `AMB-610` and child `AMB-655` by actual `AMB-*` identifiers.
- `artifacts/personal-life-os/reports/PLOS-020-local-data-cloud-boundary.md`.
- `artifacts/personal-life-os/reports/PLOS-021-cloudkit-schema-constraints.md`.
- `Native/Ambitions/Persistence/PortableSnapshotContracts.swift`.
- `Native/Ambitions/Persistence/PortableSnapshotService.swift`.
- `Native/Ambitions/Persistence/PreMigrationBackup.swift`.
- `Native/Ambitions/Persistence/SwiftDataStore.swift`.
- `Native/Ambitions/Persistence/PersistenceContracts.swift`.
- `Native/Ambitions/Persistence/SwiftDataRepositories.swift`.
- `Native/Ambitions/Domain/EntityRevisionTombstoneModels.swift`.
- `Native/Ambitions/Domain/AmbitionGraphLineageModels.swift`.
- `Native/Ambitions/Domain/ActionClosureReceiptModels.swift`.
- `Native/Ambitions/Domain/GoalEngine/GoalEngineContracts.swift`.

Validation artifacts:

- `artifacts/personal-life-os/validation/PLOS-022-lifecycle-required-search-log.txt`
- `artifacts/personal-life-os/validation/PLOS-022-focused-lifecycle-search-log.txt`

## Source Anchors

Current source already defines several lifecycle primitives:

- `GoalLifecycleState` includes `draft`, `active`, `paused`, `completed`, and `archived`.
- Capture models and services include archived capture status and archive receipts.
- `PortableSnapshotService` exports selected categories, performs dry-run import, supports replace-local-store restore, and supports merge-with-conflict-report import.
- `PortableExportManifest` classifies export categories and requires preview/redaction for sensitive categories.
- `EntityRevisionTombstone` records deleted, superseded, replaced, reset, and conflict-recovered states with lineage, privacy class, receipt, replay, and source references.
- `EntityRevisionTombstoneLifecycleState` distinguishes `recoverable` from `finalized`.
- `ActionReceiptHistoryRecord` remains local-only by default and carries privacy, proof relevance, confirmation-before-broader-use, and proof freshness lineage.
- `PreMigrationBackupService` can prepare a backup receipt and explicitly keeps migration execution disallowed.
- `AmbitionsPersistenceStore.resetAllData()` hard-deletes SwiftData records across current persisted stores.

## M00 / M01 Consumption Evidence

AMB-655 consumes M00 governance outputs and M01 runtime maps as load-bearing inputs:

- M00 local data/cloud boundary law and reporting contracts require explicit delete/export/archive semantics and no false Green.
- AMB-646 / PLOS-010 active runtime path proof keeps this child documentation-scoped instead of mutating runtime source.
- AMB-649 / PLOS-013 runtime model ownership map identifies goals, captures, proof, receipts, tombstones, local learning, settings, CloudKit continuity, and privacy controls as distinct lifecycle owners.
- AMB-651 / PLOS-015 production-vs-fixture classification prevents treating tests, fixtures, generated artifacts, or proof logs as product lifecycle implementation.
- AMB-652 / PLOS-016 crosswalk keeps M02 lifecycle work under the PLOS parent rather than reopening older AFEP/UIQL/Source Atlas control planes.

No source file is changed by AMB-655, so source-ownership gating is recorded as not applicable for implementation. Current source was inspected only to define the lifecycle matrix.

## Lifecycle Stage Matrix

| Stage | Meaning | User-visible rule | Required receipt / lineage | Export rule | Delete / restore rule | Current source anchor |
|---|---|---|---|---|---|---|
| Create | A user-owned object first enters local storage or an inspectable local draft. | The user should be able to see what was created and where it lives. | Creation receipt or event ledger entry when the create action has side effects. | Eligible only through user-selected export categories. | Created objects can later be archived, deleted, reset, or restored by category policy. | Goal, Capture, Evidence, Feedback, Teaching Signal, App State repositories. |
| Active | Object can affect recommendations, Start Here, schedules, proof, or local learning. | Active objects may influence local planning and must remain inspectable. | Receipts explain material mutations and proof relevance. | Export requires category preview and redaction where private. | Active delete must create tombstone or safe receipt before removal from influencing surfaces. | Goal lifecycle, capture status, receipt history, event ledger. |
| Paused / held | Object remains local but should not actively drive recommendations unless explicitly resumed. | Paused state is not deletion and must not be hidden as if gone. | Pause/resume receipt or event is required where runtime effects change. | Export may include paused state if selected. | Restore is resume, not import. Delete still needs tombstone/receipt semantics. | Goal `paused`; Life Context paused/deleted fields. |
| Completed | Object is finished but may still support proof, history, and review. | Completed objects can remain visible through history/proof surfaces without creating shame or score pressure. | Completion receipt and proof lineage when applicable. | Export can include completed goals/receipts after preview. | Delete should preserve necessary tombstone/receipt lineage unless user chooses full reset. | Goal `completed`, action receipt history, proof ledger concepts. |
| Archived | Object is out of active flow but retained locally for user-owned history, recovery, or future reference. | Archive is reversible or inspectable unless explicitly finalized; archive is not hard delete. | Archive receipt or event; tombstone only when archive replaces active object state. | Export may include archived objects only in selected categories and with redaction. | Restore means unarchive/reopen when source supports it; no hidden reactivation. | Goal `archived`, Capture `archived`, service archive actions. |
| Deleted | Object is removed from active and normal historical surfaces. | Deletion must say whether it is recoverable, finalized, or part of reset. | Tombstone with reason `deleted` or receipt-backed delete; lineage must preserve no-resurrection rules. | Export should exclude deleted private content by default; tombstone/lineage may export safely. | Recoverable tombstones may support restore; finalized tombstones block resurrection. | `EntityRevisionTombstoneReason.deleted`, `fetchRecoverable`, `fetchFinalized`. |
| Reset | A category, system area, or full local store is cleared. | Reset is broader than delete and must require explicit confirmation before durable mutation. | Reset receipt and tombstones for affected object families where later sync/import could resurrect data. | Reset does not create export; pre-reset backup is separate and user-controlled. | Restore requires user-selected import from a prior local package; no silent cloud restore. | `resetAllData()`, tombstone reason `reset`, pre-migration backup. |
| Export | User creates a portable local package. | Export is user-initiated, previewed, and category-selected. | Export manifest records categories, counts, exclusions, redaction rules, and local-only trust posture. | Export package can include selected goals/plans, captures, proof, receipts, memory, and settings. | Export does not delete or mutate local data. Import/restore is separate. | `PortableSnapshotService.exportSnapshot`, `PortableExportManifest`. |
| Restore / import | User imports a portable package into local storage. | Dry-run and conflict report must precede risky durable restore. | Import report and conflict report identify accepted, skipped, and ambiguous records. | Imported data must respect package schema and category contents. | Replace-local-store requires explicit confirmation; merge must not silently overwrite ambiguous local state. | `dryRunImportSnapshot`, `manualMergePlan`, `replaceLocalStore`, `mergeWithConflictReport`. |
| Compact / annual archive | Long-running data is summarized or stored in lower-churn form. | Compaction cannot erase proof needed for user trust, delete semantics, or source freshness. | Compaction receipt must record inputs, outputs, retained proof, and dropped private detail. | Export should disclose whether content is raw, summarized, or redacted. | Restore from compacted state must not claim full-fidelity unless source exists. | Future-owned by AMB-660 / PLOS-027 and M21/M26. |

## Object Family Lifecycle Rules

| Family | Active owner | Archive rule | Delete/reset rule | Export rule | Restore rule | Risk |
|---|---|---|---|---|---|---|
| Goals and plans | GoalEngine and SwiftData goal repositories. | Archive moves out of active recommendations; completed and archived remain history/proof candidates. | Delete requires tombstone/receipt before sync/import can resurrect or erase lineage. Reset clears local data only after explicit confirmation. | Included in `goals_and_plans` after preview. | Merge by id/revision/updatedAt; ambiguous conflict requires review. | High user intent sensitivity and goal graph references. |
| Steps and plan sections | Embedded in goals/plans. | Inherit parent goal/archive policy unless future Step owner separates them. | Deleted/cancelled steps should preserve receipt if they affected schedule/proof. | Export through goals/plans package. | Restore through parent goal plan or conflict report. | High churn if transient recommendations are retained. |
| Captures | Capture repository/service. | Archive removes from open intake without deleting content. | Delete must distinguish user deletion from archive and avoid future routing from deleted private text. | Included in `captures` category only when selected. | Restore via selected package, with linked-goal warnings if references are missing. | Raw text sensitivity. |
| Proof/evidence | Progress evidence repository. | Usually retained as proof history, not active task material. | Delete/reset requires lineage decision because proof can support receipts and progress review. | Included in `proof` only when selected and previewed. | Restore only with goal reference warnings if target goal absent. | Private proof content and possible media size. |
| Receipts and action history | Action receipt history and event ledger. | Archive usually means historical visibility, not mutation. | Delete/reset must preserve enough tombstone/lineage to prevent false proof and resurrection unless full reset is explicit. | Included in `receipts` with redaction rules. | Restore via receipt package and conflict report. | Longitudinal growth and proof trust. |
| Tombstones and lineage | Entity revision tombstone repository. | Finalized tombstones are archive-like guardrails; recoverable tombstones support restore. | Tombstones should survive ordinary delete paths until retention policy says otherwise. Full reset may clear after explicit confirmation. | Export safe tombstones and lineage views redact private source/receipt/replay references. | Restore must keep recoverable/finalized meaning. | Loss can resurrect deleted records. |
| Memory / teaching signals | Goal teaching signal repository and learning models. | Archive or disable must remove active ranking effect without pretending data is deleted. | Reset/delete must stop future ranking and preserve receipt when learning changed recommendations. | Included in `memory` only when selected. | Restore requires local review if source goal is absent or stale. | Sensitive behavioral pattern data. |
| Settings / app state | App state repository. | Not usually archived; versioned state can be replaced. | Reset returns to default state and may clear last-opened references. | Included in `settings` with preference labels. | Restore only from selected package; last-opened missing goal should fall back safely. | Low volume, migration-sensitive. |
| Schedule/reminders/life context | Reality, reminder, life-context owners. | Archive/pause removes active scheduling influence without deleting private context. | Delete has explicit `deletedAt` or delete repository paths; hard delete needs receipt/tombstone policy before broad sync. | Raw calendar/native context remains excluded; derived summaries require review. | Restore only from local package if future owner includes it. | Sensitive context and protected-time implications. |
| Source Atlas public packs | Source Atlas store/cache. | Revoked/stale packs are quarantined, not user-private archives. | Delete local cache does not delete public authority; no private user data in R2. | Public/reference export only, not user lifecycle export. | Restore by hash/signature/freshness, not private backup. | Must not mix with private user lifecycle. |

## Archive Strategy

Archive means retained but inactive, not deleted. Future archive implementation must:

- Remove archived objects from active recommendation and routing surfaces unless a future issue explicitly defines a review context.
- Preserve user-readable history and receipt trail where the object influenced recommendations, schedule, proof, or learning.
- Keep archive reversible only when the source owner can restore without hidden mutation.
- Mark finalized archive/replace states when restore would be unsafe or misleading.
- Avoid using archive as a quiet parking lot for unsafe, high-risk, unsupported, or source-stale content.

## Delete and Reset Strategy

Delete and reset semantics cannot be vague:

- Ordinary delete must create or preserve a tombstone/receipt when the record has influenced recommendations, proof, schedule, local learning, CloudKit outbox, or export lineage.
- A recoverable tombstone supports user-controlled restore or conflict recovery.
- A finalized tombstone blocks resurrection by import, CloudKit, cache, or replay.
- Full local reset may hard-delete persisted records, but only after explicit confirmation and after any required user-selected backup/export path.
- CloudKit lifecycle propagation remains future-owned; until proven, local deletion is local authoritative state and no cloud deletion claim is made.
- R2 is never a private delete target because private user data must not be stored in R2.

## Export and Restore Strategy

Export:

- User-initiated only.
- Category-selected through `PortableExportSelection`.
- Preview-backed through `PortableExportManifest` counts, privacy class, exclusions, and redaction rules.
- Local-only trust posture by default.
- Excludes raw calendar events, cloud sync/account data, and external rendered state in current source.

Restore:

- Dry-run before durable mutation.
- Replace-local-store requires explicit confirmation and pre-reset awareness.
- Merge-with-conflict-report must not silently overwrite ambiguous local records.
- Missing references create warnings rather than silent discard.
- Restore cannot imply CloudKit sync, account restore, or release-grade backup.

## Migration and Backup Strategy

Before future storage migrations or lifecycle-altering compaction:

- Run storage invariant checks.
- Produce a pre-migration backup report and receipt.
- Require a non-empty package when backup is used as a migration gate.
- Keep migration execution disallowed until the active migration issue explicitly authorizes it.
- Preserve schema versions, tombstones, receipt history, lineage, and privacy classifications.

## Performance and Compaction Risks

Risk areas for later owners:

- Required lifecycle search produced 30,860 lines and focused lifecycle search produced 8,064 lines, showing broad lifecycle vocabulary across source, tests, docs, and artifacts; future validation should prefer bounded focused searches.
- Receipt history, event ledger, tombstones, runtime snapshots, proof/evidence, and memory signals can grow over years.
- Fetching all tombstones with `limit: .max` for export is acceptable as source evidence but needs compaction and paging strategy before runtime scale claims.
- Full-store reset currently iterates through every SwiftData model family; future large-store behavior needs performance proof before Green.
- Annual snapshot and 20-year compaction remain AMB-660 / PLOS-027 owned.

## Validation

Commands run for AMB-655:

- `git status --short --branch` - clean on `main` before AMB-655 execution.
- `git pull --ff-only` - already up to date.
- `git rev-parse HEAD` - BASE_SHA `6b1bd9cc58ee23f9d59e4fdc4a42e15fc47fe506`.
- Linear issue fetch for `AMB-655` - succeeded.
- Linear status update for `AMB-655` to In Progress - succeeded.
- `rg -n "archive|delete|export|receipt" . > artifacts/personal-life-os/validation/PLOS-022-lifecycle-required-search-log.txt` - exited `0`, 30,860 lines.
- Focused lifecycle search over Persistence, Domain, Support, tests, docs/codex, and PLOS-020/PLOS-021 reports - exited `0`, 8,064 lines, artifact `artifacts/personal-life-os/validation/PLOS-022-focused-lifecycle-search-log.txt`.
- Focused source inspection of portable snapshot export/import, pre-migration backup, SwiftData reset, tombstones/lineage, receipt history, repository contracts, and lifecycle state source.

Closeout validation run after report creation:

- `git diff --check` - exited `0`.
- `python3 -m json.tool artifacts/plos-runtime/PLOS_EXECUTION_QUEUE.json` - exited `0`.
- `python3 -m json.tool artifacts/plos-runtime/PLOS_LINEAR_ISSUE_MAP.json` - exited `0`.
- `python3 scripts/codex/plos-readiness-validate.py` - exited `0`.
- `scripts/codex/program-preflight.sh plos` - exited `0`, artifact `artifacts/plos-runtime/script-output/program-preflight-20260612T173520.log`.
- `scripts/codex/program-phase-gate.sh plos M02` - exited `0`, artifact `artifacts/plos-runtime/script-output/program-phase-gate-M02-20260612T173520.log`.
- `python3 scripts/codex/linear-closeout-validate.py --program plos --scope child artifacts/personal-life-os/reports/PLOS-022-user-data-lifecycle-archive-strategy.md` - exited `0`.
- `bash scripts/codex/program-proof-index.sh plos` - exited `0`, wrote `artifacts/proof-ledger/proof-index.json` with 50 entries and artifact `artifacts/plos-runtime/script-output/program-proof-index-20260612T173524.log`.
- `git diff --cached --check` - pending until staging.

Not run:

- Build/test/screenshot/accessibility/performance validation was not run because AMB-655 is documentation/control-plane lifecycle strategy work and no app source, project, UI, runtime, test source, privacy manifest, entitlement, archive implementation, delete/reset/export implementation, or CloudKit lifecycle transport changed.

## Runtime Path Proof

Not applicable for implementation proof. AMB-655 uses current source anchors and prior M02 boundary reports to define lifecycle policy, but it does not implement or change runtime behavior.

## Privacy / Safety / Source Checks

Green for AMB-655 documentation scope:

- Delete, reset, export, restore, and archive semantics are explicit.
- Export remains user-initiated, category-selected, previewed, redacted where required, and local-only by default.
- Tombstones and receipts are treated as lineage/proof safety objects, not optional cleanup noise.
- R2 remains excluded from private user lifecycle handling.
- CloudKit lifecycle propagation remains future-owned and not claimed.

## Accessibility Checks

Not applicable. No UI or accessibility behavior changed. No accessibility verification or certification is claimed.

## Rollback / Failure Behavior

Rollback is to revert this AMB-655 artifact/control-plane commit. Later archive, delete/reset/export, restore, CloudKit lifecycle, compaction, and privacy declaration work must hold if this lifecycle matrix is removed or fails validation.

## Remaining Yellow / Red

Yellow:

- Local index/query strategy remains AMB-656 / PLOS-023.
- Receipt retention/delete/reset/export detail remains AMB-657 / PLOS-024.
- R2 source-only boundary remains AMB-658 / PLOS-025.
- App privacy declaration map remains AMB-659 / PLOS-026.
- Yearly archive/compaction remains AMB-660 / PLOS-027.
- M23 owns implementation-level CloudKit lifecycle propagation.
- M24 owns diagnostics/export support proof.
- M25/M26 own App Review/compliance/certification evidence.

Red blockers: none for AMB-655 scope.

## Follow-Up Issues Created

None.

## Next Issue To Run

AMB-656 / PLOS-023 only, after AMB-655 is committed, pushed to `main`, and updated in Linear.

## Non-Claims

AMB-655 does not claim runtime implementation, app source change, archive feature implementation, retention enforcement, delete/reset/export UX, restore UX, storage migration, CloudKit lifecycle propagation, R2 implementation, diagnostics implementation, privacy manifest correctness, privacy/legal approval, App Review readiness, release readiness, TestFlight readiness, App Store readiness, screenshot proof, accessibility verification, performance proof, owner approval, or PLOS-M03+ execution.

## PLOS Child Closeout

PLOS child closeout

Linear issue: AMB-655

Parent issue: AMB-610

Green/Yellow/Red status: Green for AMB-655 lifecycle/archive strategy documentation scope; Yellow for later archive implementation, retention enforcement, delete/reset/export UX, CloudKit lifecycle transport, index/query strategy, receipt retention detail, R2, privacy declaration, archive/compaction, implementation, release, accessibility, performance, device, and privacy/legal proof not claimed.

Pushed to main: pending at report creation

Push hash: pending at report creation

App source changed: no

Runtime features implemented: no

PLOS-M00 executed: no; AMB-608 and AMB-609 were already complete before this M02 child started.

Linear identifiers used: AMB issue identifiers only

Validation run:
- `git status --short --branch` - clean on `main` before child execution.
- `git pull --ff-only` - already up to date.
- Linear issue fetch for `AMB-655` - succeeded.
- Linear status update for `AMB-655` to In Progress - succeeded.
- `rg -n "archive|delete|export|receipt" . > artifacts/personal-life-os/validation/PLOS-022-lifecycle-required-search-log.txt` - exited `0`.
- Focused lifecycle search - exited `0`.
- Focused source inspection of export/import, backup, reset, tombstone, receipt, repository, and lifecycle owners.

Validation run after report creation:
- `git diff --check` - exited `0`.
- JSON validation for PLOS queue/map - exited `0`.
- PLOS readiness validation - exited `0`.
- PLOS preflight - exited `0`.
- PLOS M02 phase gate - exited `0`.
- PLOS child closeout validation - exited `0`.
- PLOS proof index regeneration - exited `0`.
- `git diff --cached --check` - pending until staging.

Red blockers: none for AMB-655 scope.

Yellow limits: no archive implementation, retention enforcement, delete/reset/export UX, restore UX, CloudKit lifecycle transport, compaction, privacy/legal approval, release readiness, TestFlight readiness, App Store readiness, accessibility proof, performance proof, device proof, or owner approval is claimed.

Next recommended action: after AMB-655 commit, push, and Linear closeout, continue AMB-656 / PLOS-023 only.
