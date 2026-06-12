# PLOS-023 Local Database Index and Query Strategy

Status: Green for AMB-656 local index/query strategy documentation scope; Yellow for later persistence implementation, measured performance proof, compaction, paging, migration, device, accessibility, privacy/legal, and release proof
Linear issue: AMB-656
Parent issue: AMB-610
Program phase: PLOS-M02 local data, CloudKit, R2 boundary, and data lifecycle foundation
Updated: 2026-06-12
Branch: main

## Closeout Header

- PLOS child closeout: yes
- Linear issue: AMB-656
- Parent issue: AMB-610
- Green/Yellow/Red status: Green for local database indexing/queryability strategy documentation scope; Yellow for unimplemented indexes, query rewrites, paging, compaction, migration, measured performance, device, accessibility, privacy/legal, and release proof.
- Pushed to main: pending at report creation
- Push hash: pending at report creation
- App source changed: no
- Runtime features implemented: no
- PLOS-M00 executed: no; AMB-608 / PLOS-M00 and AMB-609 / PLOS-M01 were already complete before this M02 child started.
- Linear identifiers used: AMB issue identifiers only
- Validation run: see Validation
- Red blockers: none for AMB-656 documentation scope
- Yellow limits: this report defines query/index strategy. It does not add indexes, rewrite repositories, migrate storage, run performance benchmarks, or prove scale behavior.
- Owner approval claimed: no
- Release/TestFlight/App Store readiness claimed: no
- Next recommended action: after AMB-656 commit, push, and Linear closeout, continue AMB-657 / PLOS-024 only.

## Scope

AMB-656 defines local database indexing, ordering, hot query, and compaction-aware retrieval strategy for current SwiftData-backed Ambitions storage. It optimizes for local-first truth and later performance hardening without changing production persistence behavior.

This child does not implement a full persistence rewrite, add SwiftData indexes, change model schemas, change repository code, add migrations, run performance benchmarks, or claim runtime scale proof.

## Existing-First Inspection

Repo and Linear evidence inspected before adding this artifact:

- Linear parent `AMB-610` and child `AMB-656` by actual `AMB-*` identifiers.
- `artifacts/personal-life-os/reports/PLOS-013-runtime-model-ownership-map.md`.
- `artifacts/personal-life-os/reports/PLOS-015-production-fixture-test-script-classification.md`.
- `artifacts/personal-life-os/reports/PLOS-020-local-data-cloud-boundary.md`.
- `artifacts/personal-life-os/reports/PLOS-021-cloudkit-schema-constraints.md`.
- `artifacts/personal-life-os/reports/PLOS-022-user-data-lifecycle-archive-strategy.md`.
- `Native/Ambitions/Persistence/SwiftDataModels.swift`.
- `Native/Ambitions/Persistence/SwiftDataRepositories.swift`.
- `Native/Ambitions/Persistence/PersistenceContracts.swift`.
- `Native/Ambitions/Persistence/StorageSchemaVersionLedger.swift`.
- `Native/Ambitions/Persistence/StorageInvariantChecker.swift`.

Validation artifacts:

- `artifacts/personal-life-os/validation/PLOS-023-query-index-required-search-log.txt`
- `artifacts/personal-life-os/validation/PLOS-023-focused-query-index-search-log.txt`

## M00 / M01 Consumption Evidence

AMB-656 consumes M00 governance outputs and M01 runtime maps as load-bearing inputs:

- M00 reporting and validation contracts require index strategy to be explicit and no-claim bounded before any performance Green.
- AMB-646 / PLOS-010 active runtime proof keeps this child documentation-scoped instead of mutating repositories.
- AMB-649 / PLOS-013 model ownership map identifies query-sensitive owners: Goal, Step, Source Atlas, proof, receipt, replay, local learning, CloudKit continuity, and privacy controls.
- AMB-651 / PLOS-015 classification prevents treating generated logs or tests as product runtime query proof.
- AMB-655 / PLOS-022 lifecycle strategy identifies receipt history, event ledger, tombstones, runtime snapshots, proof/evidence, memory signals, and annual archives as long-running growth areas.

No source file is changed by AMB-656, so source-ownership gating is not applicable for implementation. Current source was inspected only to define the query/index strategy.

## Current Query Posture

Current SwiftData storage uses:

- Unique ids via `@Attribute(.unique)` on record ids.
- Denormalized routing fields beside encoded `snapshotData` payloads.
- String timestamps for most core records.
- Date shadow columns for event, command, side-effect, tombstone, action receipt history, and some ledger records.
- Repository methods that often fetch all records, then filter/sort in memory.
- Explicit bounded list budgets for goals, captures, and actionable steps.
- Separate projection/proof/operational graph record stores with surface, snapshot, ambition, receipt, replay, and checksum fields.

This is acceptable for current local-first planning scope, but it is not scale/performance Green. Hot paths need staged hardening before broad runtime expansion.

## Hot Query Matrix

| Query path | Current source anchor | Current pattern | Hotness | Strategy | Privacy boundary |
|---|---|---|---|---|---|
| Goal list for Today/Goals | `SwiftDataGoalRepository.listGoals()` | Fetch all goals/plans/sections/steps, compose plan map, sort by `updatedAt`, bound results. | High | Preserve bounded result count; future predicate/sort by state and updated date; avoid decoding full plan graph for list summary when not needed. | Private local goals only. |
| Single goal detail | `goal(id:)` | Fetch all goals then first by id; fetch all plan records to compose map. | High | Use id lookup/predicate first; compose only target plan graph. | Private local goal graph. |
| Actionable steps | `listActionableSteps()` | Fetch all steps, decode, filter completed/cancelled, sort for actionability, bound. | High | Add state/timing/order fields as query drivers; cap candidate set before expensive decoding. | Private execution data. |
| Captures | `listCaptures()`, `capture(id:)` | Fetch all captures, sort by `updatedAt`, bound; id lookup uses list then first. | High | Use status, linkedGoalID, updatedAt, and id as query targets; never index raw text for search without privacy review. | Raw private user text. |
| Proof/evidence | `listEvidence(goalID:)` | Fetch all evidence, optional goal filter, sort by `capturedAt`. | Medium/high | Use goalID, stepID, capturedAt, evidence kind as query targets; avoid unbounded proof history in first-screen flows. | Private proof data. |
| Feedback/receipts | `listEvents(goalID:)`, `ActionReceiptHistoryRepository.fetch` | Fetch all then filter/sort/search projection. | High over time | Use goalID, stepID, occurredAtDate, source domain, privacy, proof relevance, trust status as query targets; retention policy remains AMB-657-owned. | Proof/audit data, local-only by default. |
| Event ledger | `fetchRecent`, `fetchEvents(goalID/captureID/kind/date)` | Fetch all, filter, sort using `occurredAtDate`. | High | Date and object filters should become first-class predicate paths; keep bounded recent queries. | Local trust/event history. |
| Tombstones/lineage | `fetchRecent`, `fetch(for:)`, `fetch(lineageID:)`, `fetchRecoverable`, `fetchFinalized` | Fetch all, filter/sort by entity, lineage, lifecycle, recorded date. | Medium/high over years | Query by entityID, lineageID, lifecycleState, recordedAtDate; preserve finalized/recoverable semantics. | Delete/reset lineage; no R2. |
| Runtime snapshot ledger | `fetchRecent`, `fetchEnvelope`, `fetchEnvelopes(containing:)` | Fetch all, decode envelopes, then reference-match. | Medium/high as replay grows | Use envelope id, generatedAt, checksum, provenanceHash, and reference materialization; avoid decoding all payloads for reference search. | Highly sensitive replay data. |
| Ambition graph projections | `fetchRecords(surface:snapshotID:limit:)` | Fetch all, filter by surface/snapshot, sort by generatedAt. | High for surfaces | Surface, snapshotID, ambitionID, generatedAt, projectionHash, invalidation reason should drive queries. | Local projection only, privacy class preserved. |
| Source Atlas cache/packs | Source Atlas store models and M01 map | Public pack/cache selection and quarantine. | Medium/high in M04-M06 | Keep public source pack queries separate from private user data; index pack id/hash/freshness/revocation/review state. | Public reference only unless combined locally. |
| Export/import packages | `PortableSnapshotService` | Loads many categories concurrently; tombstones can use `limit: .max`. | Medium/high for large stores | Use category counts, bounded previews, paging, and compaction before large export Green. | User-initiated local export only. |

## Index Target Strategy

Do not index raw private text by default. Prefer deterministic, low-leakage local query fields:

- Identity: `id`, `goalID`, `stepID`, `captureID`, `planID`, `sectionID`, `lineageID`, `sourceSnapshotID`, `ambitionID`.
- Lifecycle: `stateRaw`, `statusRaw`, `deletedAt`, `lifecycleStateRaw`, `privacyClassRaw`, `localOnly`.
- Time/order: `updatedAt`, `updatedAtDate`, `createdAt`, `createdAtDate`, `occurredAtDate`, `recordedAtDate`, `generatedAt`, `orderIndex`.
- Trust/proof: `receiptID`, `replayTraceID`, `sourceRecordID`, `proofID`, `proofRelevanceRaw`, `privacyLevelRaw`, `requiresConfirmationBeforeBroaderUse`.
- Projection/source: `surfaceRaw`, `projectionHash`, `checksum`, `provenanceHash`, `invalidationReasonRaw`, `compatibilityStatusRaw`.
- CloudKit future fields: `recordName`, `family`, `schemaVersion`, `localRevision`, `reviewState`, tombstone metadata, sync ledger counts.

Raw fields that should not become broad query indexes without a privacy review:

- Capture `rawText`.
- Goal title/summary as general full-text search.
- Proof notes and evidence detail.
- Receipt changed facts or raw receipt payloads.
- Replay trace payloads.
- Private Source Atlas intent/capability matching context.

## Ordering Rules

Stable local ordering must be explicit:

- User-facing current lists should prefer semantic state and time fields over raw insertion order.
- Recent histories should sort by Date shadow columns when present, with id tie-breakers.
- Plan steps and sections should preserve `orderIndex`.
- Projection stores should sort by `generatedAt`, then surface/id for determinism.
- Conflict/import reviews must not treat timestamp alone as authority when revision or tombstone semantics conflict.

## Compaction-Aware Retrieval

Long-running Ambitions data needs retrieval that can survive years of local use:

- First-screen Today/Goals/Capture/You queries should avoid decoding full ledgers, replay traces, and large proof payloads.
- Receipt, event, tombstone, proof, and runtime snapshot queries should be paged and date-bounded before M19/M24 performance Green.
- Export preview should compute counts and exclusions before loading all payload detail.
- Annual snapshot/20-year compaction in AMB-660 must preserve proof, tombstone, and receipt lineage while allowing older raw detail to move into summarized local archives.
- CloudKit future outbox/conflict/review ledgers need query-by-state and bounded retry windows before sync hardening claims.

## Implementation Follow-Up Targets

Future scoped issues should consider these changes only with migration and performance proof:

1. Replace fetch-all id lookups with predicate/id fetches for goals, captures, runtime snapshots, tombstones, and receipt history.
2. Move high-traffic filtering into SwiftData predicates where stable and safe.
3. Add or preserve Date shadow columns for string timestamp fields that drive hot history queries.
4. Add bounded paging for receipt history, event ledger, runtime snapshots, proof/evidence, and tombstones.
5. Add category count/preview query paths for portable export.
6. Materialize reference indexes for runtime snapshot artifact references instead of decoding all envelopes.
7. Keep public Source Atlas pack indexes physically and conceptually separate from private user lifecycle indexes.

## Validation

Commands run for AMB-656:

- `git status --short --branch` - clean on `main` before AMB-656 execution.
- `git pull --ff-only` - already up to date.
- `git rev-parse HEAD` - BASE_SHA `38d5279295d0fab6ad4ebf8a51535d854cdeaa32`.
- Linear issue fetch for `AMB-656` - succeeded.
- Linear status update for `AMB-656` to In Progress - succeeded.
- `rg -n "query|index|sort|fetch" . > artifacts/personal-life-os/validation/PLOS-023-query-index-required-search-log.txt` - exited `0`, 18,754 lines.
- Focused query/index search over Persistence, Domain, Services, tests, and PLOS-020/PLOS-022 reports - exited `0`, 5,045 lines, artifact `artifacts/personal-life-os/validation/PLOS-023-focused-query-index-search-log.txt`.
- Focused source inspection of SwiftData models, repositories, storage schema ledger, storage invariant checker, runtime model ownership map, production-vs-fixture classification, and M02 boundary/lifecycle reports.

Closeout validation run after report creation:

- `git diff --check` - exited `0`.
- `python3 -m json.tool artifacts/plos-runtime/PLOS_EXECUTION_QUEUE.json` - exited `0`.
- `python3 -m json.tool artifacts/plos-runtime/PLOS_LINEAR_ISSUE_MAP.json` - exited `0`.
- `python3 scripts/codex/plos-readiness-validate.py` - exited `0`.
- `scripts/codex/program-preflight.sh plos` - exited `0`, artifact `artifacts/plos-runtime/script-output/program-preflight-20260612T174122.log`.
- `scripts/codex/program-phase-gate.sh plos M02` - exited `0`, artifact `artifacts/plos-runtime/script-output/program-phase-gate-M02-20260612T174122.log`.
- `python3 scripts/codex/linear-closeout-validate.py --program plos --scope child artifacts/personal-life-os/reports/PLOS-023-local-database-index-query-strategy.md` - exited `0`.
- `bash scripts/codex/program-proof-index.sh plos` - exited `0`, wrote `artifacts/proof-ledger/proof-index.json` with 51 entries and artifact `artifacts/plos-runtime/script-output/program-proof-index-20260612T174130.log`.
- `git diff --cached --check` - pending until staging.

Not run:

- Build/test/screenshot/accessibility/performance validation was not run because AMB-656 is documentation/control-plane query strategy work and no app source, project, UI, runtime, test source, storage schema, migration, index, or repository implementation changed.

## Runtime Path Proof

Not applicable for implementation proof. AMB-656 inspects source owners and prior PLOS reports to define strategy, but it does not implement or change runtime behavior.

## Privacy / Safety / Source Checks

Green for AMB-656 documentation scope:

- Query strategy preserves local-first boundaries.
- Raw private text is explicitly excluded from broad index targets.
- Public Source Atlas query/index concerns remain separate from private user data.
- CloudKit outbox/conflict/query strategy remains future-owned and private database only.
- Performance proof is not claimed without measurement.

## Accessibility Checks

Not applicable. No UI or accessibility behavior changed. No accessibility verification or certification is claimed.

## Rollback / Failure Behavior

Rollback is to revert this AMB-656 artifact/control-plane commit. Later indexing, repository, compaction, export, CloudKit, and performance work must hold if this strategy is removed or fails validation.

## Remaining Yellow / Red

Yellow:

- Receipt retention/delete/reset/export detail remains AMB-657 / PLOS-024.
- R2 source-only boundary remains AMB-658 / PLOS-025.
- App privacy declaration map remains AMB-659 / PLOS-026.
- Yearly archive/compaction remains AMB-660 / PLOS-027.
- M19 owns measured performance hardening.
- M23 owns implementation-level CloudKit query/outbox/conflict indexing.
- M24 owns diagnostics/export support proof.

Red blockers: none for AMB-656 scope.

## Follow-Up Issues Created

None.

## Next Issue To Run

AMB-657 / PLOS-024 only, after AMB-656 is committed, pushed to `main`, and updated in Linear.

## Non-Claims

AMB-656 does not claim runtime implementation, app source change, persistence rewrite, schema migration, index implementation, query rewrite, performance proof, storage scale proof, CloudKit implementation, R2 implementation, diagnostics implementation, privacy manifest correctness, privacy/legal approval, App Review readiness, release readiness, TestFlight readiness, App Store readiness, screenshot proof, accessibility verification, owner approval, or PLOS-M03+ execution.

## PLOS Child Closeout

PLOS child closeout

Linear issue: AMB-656

Parent issue: AMB-610

Green/Yellow/Red status: Green for AMB-656 local database index/query strategy documentation scope; Yellow for later persistence implementation, indexing/query rewrites, migration, compaction, performance, CloudKit, R2, privacy declaration, implementation, release, accessibility, device, and privacy/legal proof not claimed.

Pushed to main: pending at report creation

Push hash: pending at report creation

App source changed: no

Runtime features implemented: no

PLOS-M00 executed: no; AMB-608 and AMB-609 were already complete before this M02 child started.

Linear identifiers used: AMB issue identifiers only

Validation run:
- `git status --short --branch` - clean on `main` before child execution.
- `git pull --ff-only` - already up to date.
- Linear issue fetch for `AMB-656` - succeeded.
- Linear status update for `AMB-656` to In Progress - succeeded.
- `rg -n "query|index|sort|fetch" . > artifacts/personal-life-os/validation/PLOS-023-query-index-required-search-log.txt` - exited `0`.
- Focused query/index search - exited `0`.
- Focused source inspection of SwiftData models, repositories, storage schema ledger, storage invariant checker, and M01/M02 proof reports.

Validation run after report creation:
- `git diff --check` - exited `0`.
- JSON validation for PLOS queue/map - exited `0`.
- PLOS readiness validation - exited `0`.
- PLOS preflight - exited `0`.
- PLOS M02 phase gate - exited `0`.
- PLOS child closeout validation - exited `0`.
- PLOS proof index regeneration - exited `0`.
- `git diff --cached --check` - pending until staging.

Red blockers: none for AMB-656 scope.

Yellow limits: no persistence rewrite, query rewrite, index implementation, migration, measured performance proof, storage scale proof, CloudKit implementation, privacy/legal approval, release readiness, TestFlight readiness, App Store readiness, accessibility proof, device proof, or owner approval is claimed.

Next recommended action: after AMB-656 commit, push, and Linear closeout, continue AMB-657 / PLOS-024 only.
