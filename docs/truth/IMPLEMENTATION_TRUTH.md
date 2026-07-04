# IMPLEMENTATION_TRUTH.md

Status: Active implementation/source truth  
Scope: Actual repo/source implementation status, scaffold status, compatibility debt, missing implementation, forbidden implementation claims, and implementation no-claim boundaries  
Applies to: Ambitions native iPhone repo  
Owner posture: Source truth, not product vision and not release proof  
Effective rule: Live source, project files, scripts, tests, and current proof evidence win over plans, historical docs, old canon, handoffs, batch-train docs, prompts, and aspirational reports.

This file does not define what Ambitions should become. That authority belongs to `docs/truth/PRIVATE_LIFE_ORCHESTRATION_TRUTH.md`, `docs/truth/PRODUCT_DESIGN_TRUTH.md`, `docs/truth/PRODUCT_MOAT_TRUTH.md`, and `docs/truth/PRODUCT_EXPERIENCE_CANON.md`.

This file does not define release readiness. That authority belongs to `docs/truth/RELEASE_TRUTH.md`.

## Codex digest
- Read when: work touches source, runtime wiring, project/package config, tests, source status, compatibility debt, account/R2/AI implementation claims, or implementation no-claim boundaries.
- Owns: implementation/source evidence standard, current source posture, compatibility debt classification, and forbidden implementation claims.
- Does not own: product vision, product-experience targets, visual acceptance, release readiness, or mutable proof beyond current evidence.
- Hard red: claiming source migration/account/R2/offline/accessibility/release behavior without live source and current proof, or treating current compatibility debt as product truth.
- Proof/closeout impact: implementation claims require live source/project/test/script evidence; source snapshot sections are evidence-bounded and must be refreshed when source architecture changes.

---

## 0. Private Life Orchestration implementation interpretation

Implementation status must be read through `PRIVATE_LIFE_ORCHESTRATION_TRUTH.md`: Ambitions' source work should preserve the core loop of `Intent -> Context -> Path -> Time Fit -> Reflow -> Action -> Proof -> Learning`.

The mission truth is not implementation proof. It does not prove goal pathing, schedule reflow, semantic intelligence, user learning, task execution, calendar/time behavior, habit/ritual behavior, assistant behavior, or runtime integration exists in the current app.

Future implementation claims for goal pathing, schedule reflow, semantic intelligence, user learning, or first-class task/calendar/habit/assistant behavior require current source, focused tests, scenario-gate evidence, runtime proof where relevant, and release proof when release/readiness is claimed.

## 1. Source Evidence Standard

Implementation evidence may come from current Swift source, project configuration, package manifests, resources, entitlements, privacy manifest, scripts, tests, current validation logs, checked-in current proof artifacts, and current repo tree evidence.

Implementation evidence may not come from old canon alone, batch-train prompts alone, handoff docs alone, audit reports alone, README claims alone, design truth alone, planning docs alone, generated reports without source/log backing, Codex memory, model inference, or expected behavior.

Implementation state labels:

| Label | Meaning |
|---|---|
| Source-present | Files/source exist in the repo. |
| Configured | Project/package/target/script config exists. |
| Wired | Source calls or dependency graph connect the feature to app runtime. |
| Scaffolded | Shape/contracts/source exist, but behavior is partial or not proven end-to-end. |
| Preview-backed | Works only through preview/demo/in-memory paths unless live proof exists. |
| Unproven | No current source/log/proof establishes the claim. |
| Not found | Inspection found no active repo/source evidence. |
| Historical | Exists only in old docs/prompts/audits/batch material. |
| Conflicting | Contradicts active truth, source, or release proof. |
| Compatibility debt | Source remains for routing/migration/history but is not current product truth. |

Truth-doc implementation claim labels:

| Label | Meaning |
|---|---|
| Implemented Green | Current source plus current validation/proof artifacts establish the exact implementation claim. Green must link to source paths and proof artifacts, and it must not imply release, visual, device, accessibility, privacy/legal, account, R2, CloudKit, or full-product readiness. |
| Implemented Yellow | Source or scaffolding exists, but validation is incomplete, stale, partial, environment-limited, owner acceptance is missing, or named debt remains. |
| Partial | A scoped subclaim has current evidence, while the broader claim remains unproven. State the proven subset and unsupported remainder. |
| Aspirational | Product or architecture direction without current source/proof. It may guide future work, but it is not implementation truth. |
| Deprecated | Retired, historical, stale, or compatibility-only material. It must not be expanded as active architecture. |
| Blocked | Implementation or proof cannot advance until a named blocker is removed. |
| Unknown | Live source/proof has not been inspected or no evidence was found. Unknown is not permission to infer. |

Any truth-doc claim using these labels must preserve the remediation direction from `PRODUCT_DESIGN_TRUTH.md`: keep the runtime law while reducing lore, use deep runtime with plain user-facing UI, delete before naming, prefer feature-local projection where canon allows, let proof automation outrank prose, and report no Green without linked evidence.

---

## 2. Repository Snapshot

### Mutable Snapshot Warning

Implementation standards in this file are stable truth. Current source snapshot sections are mutable inventory, evidence-bounded, and must be refreshed when major source architecture changes. Live source, current project files, current tests, and current proof still win over stale snapshot wording.

Mutable inventory quarantine:

- Root-chain paths, source-present paths, and surface evidence paths below are current inventory only.
- They are not stable implementation law, product completeness proof, runtime proof, visual proof, accessibility proof, or release proof.
- If a path listed below disappears, moves, or becomes a compatibility shim, update this inventory instead of treating the old path as canon.
- Stable implementation law is the evidence standard, no-claim boundary, local-first/account/R2 boundary, hard stops, and proof hierarchy in this file.

Current repo posture from inspected evidence:

- Native iOS app source exists under `Native/Ambitions/`.
- Xcode project is generated from `project.yml`.
- The checked-in package manifest defines shared Swift packages.
- The app is SwiftUI-first.
- The configured deployment target is iOS 26.0.
- The configured Swift language version is 6.0.
- The repo has source for app, widget extension, share extension, unit tests, UI tests, design system package, widget UI package, retained local scripts, and compact truth/build docs.
- The app has local SwiftData persistence source.
- The app has App Group entitlement source.
- The app has a privacy manifest source.
- The repo has local build/setup scripts.
- No active release proof proves TestFlight/App Store/device readiness.
- Old docs, generated proof, prompts, train material, and Codex control-plane files are not retained as implementation evidence.

Primary evidence paths:

```text
README.md
AGENTS.md
project.yml
Package.swift
docs/truth/PRIVATE_LIFE_ORCHESTRATION_TRUTH.md
docs/truth/PRODUCT_DESIGN_TRUTH.md
docs/truth/PRODUCT_EXPERIENCE_CANON.md
Native/Ambitions/App/AmbitionsApp.swift
Native/Ambitions/App/AmbitionsRootScene.swift
Native/Ambitions/DesignSystem/StagePrimitives/SharedUI/LaunchGateView.swift
Native/Ambitions/App/AmbitionsStageHost.swift
Native/Ambitions/Stage/AmbitionsStage.swift
Native/Ambitions/App/AppContainerFactory.swift
Native/Ambitions/Core/LocalRuntimeOS/
Native/Ambitions/Core/Persistence/
Native/Ambitions/Core/Domain/
Native/Ambitions/Projection/StageScenes/TodayStageScene.swift
Native/Ambitions/Projection/StageScenes/GoalsStageScene.swift
Native/Ambitions/Projection/StageScenes/TimeStageScene.swift
Native/Ambitions/Projection/StageScenes/YouStageScene.swift
Native/Ambitions/Projection/OverlayScenes/CaptureStageScene.swift
Native/Ambitions/Projection/OverlayScenes/SearchStageScene.swift
Native/Ambitions/Surfaces/Today/TodaySurface.swift
Native/Ambitions/Surfaces/Goals/GoalsSurface.swift
Native/Ambitions/Surfaces/Time/TimeSurface.swift
Native/Ambitions/Surfaces/You/YouSurface.swift
Native/Ambitions/Composer/Capture/CaptureSurface.swift
Native/Ambitions/Stage/Motion/
Native/Ambitions/Support/Ambitions.entitlements
Native/Ambitions/Resources/PrivacyInfo.xcprivacy
Native/AmbitionsUITests/AmbitionsUITests.swift
```

Current app root chain inventory:

```text
AmbitionsApp -> AmbitionsRootScene -> LaunchGateView -> AmbitionsStageHost -> AmbitionsStage
```

This chain is source inventory only. It does not claim implementation completeness, runtime completeness, rendered product quality, accessibility conformance, device proof, or release readiness.

### LocalRuntimeOS implementation posture

As of Linear `AMB-1544` / `AMB-1545`, product truth names `Core/LocalRuntimeOS/` as the target backend/runtime architecture owner and uses this law:

```text
Command -> Event -> Projection -> Receipt -> Replay
```

Current implementation evidence is narrower:

- Source-present Boundary foundation source exists under `Native/Ambitions/Core/LocalRuntimeOS/Boundary/`, including `PrivateLifeRuntimeBoundary`, `CapabilityMatrix`, `NetworkEgressPolicy`, `LocalOnlyMode`, `AccountBoundary`, `SourceAtlasBoundary`, `PrivacyBoundary`, `SourceAtlasNoPrivateGraphEgressAudit`, and `SourceAtlasPublicArtifactBoundary`.
- The former legacy runtime privacy/source-atlas boundary owners and the former `Core/Persistence` Source Atlas public-artifact privacy-boundary owner were removed from those owners.
- Focused simulator tests cover Boundary canonical owner files, old owner removal, local-only runtime requirements, capability decisions, offline-core account independence, private-graph sync denial, public-reference/account-identity egress allowance, private runtime/R2 egress denial, hosted private graph denial, external cloud LLM denial, Source Atlas access decisions, private-graph egress markers, and public-artifact cache metadata.
- Source-present Commands source exists under `Native/Ambitions/Core/LocalRuntimeOS/Commands/`, including `AmbitionsCommand`, `CommandEnvelope`, `CommandCompiler`, `CommandValidator`, `CommandAuthorizer`, `CommandIdempotencyKey`, `CommandJournal`, `CommandReducer`, `CommandResult`, `CommandReceiptFactory`, and `CommandReplayAdapter`.
- `AmbitionsCommandExecutor` and `TodayCommandActionHandler` compile commands into envelopes, append those envelopes to the injected command journal before scoped mutation, preserve duplicate idempotency replay through prior command execution records, and persist typed command receipt metadata on recorded results. Focused simulator tests cover Commands canonical owner files, envelope compilation, append-only journal checksums, authorization denial, reducer output, typed receipts, replay recorder behavior, scoped capture mutation ordering, journal-failure blocking, Today command routing, and app-container command-journal wiring.
- This Commands proof now covers the scanner-tracked high-risk mutation seams and focused runtime paths required by `scripts/ambitions-local-runtime-proof.py`; it is still not a claim that every present or future app path is command-only, nor that LocalRuntimeOS is complete.
- Source-present Transactions foundation source exists under `Native/Ambitions/Core/LocalRuntimeOS/Transactions/`, including `RuntimeTransaction`, `RuntimeTransactionCoordinator`, `RuntimeMutationPlan`, `RuntimeWriteSet`, `RuntimeReadSet`, `RuntimeCommitReceipt`, `RuntimeRollbackPlan`, `RuntimeConflictDetector`, `RuntimeIdempotencyStore`, and `RuntimeMutation`.
- Focused simulator tests cover Transactions canonical owner files, old owner removal, validated transaction preparation, read/write set construction, rollback-plan construction, event append, projection materialization, replayable commit receipts, duplicate idempotency replay, stale read-set conflict detection, and invalid-command rejection.
- Source-present EventJournal foundation source exists under `Native/Ambitions/Core/LocalRuntimeOS/EventJournal/`, including runtime event envelopes, cursors, append-only stores, checksums, command replay projection, compaction snapshots, and tombstone event append support.
- `AmbitionsCommandExecutor` and `TodayCommandActionHandler` append runtime command execution events when a runtime event store is injected; focused tests cover the standalone executor duplicate-replay path and EventJournal checksum/replay behavior.
- Source-present Projections foundation source exists under `Native/Ambitions/Core/LocalRuntimeOS/Projections/`, including projection definitions, cursors, invalidations, diffs, checksums, event-fed materialization, Today/Goals/Time/You/Search/Widget/App Intent/Receipt/Privacy projection outputs, and an inventory of existing surface read-model scaffolding.
- `ProjectionMaterializer` materializes projection outputs from `RuntimeEventStore` envelopes and focused tests cover canonical owner files, definition coverage, inventory path existence, event-fed projection outputs, privacy-safe external filtering, cursor/checksum creation, invalidation, and diffs.
- Source-present Storage foundation source exists under `Native/Ambitions/Core/LocalRuntimeOS/Storage/`, including `EventStoreSQLite`, `ObjectStoreSwiftData`, `ProjectionStoreSQLite`, `SearchStoreFTS`, `BlobStoreFileSystem`, `AppGroupSnapshotStore`, `BackupStore`, and `MigrationStore`.
- `ObjectStoreSwiftData.swift` owns the SwiftData object-store source; the former `Core/Persistence` local-store owner file was removed.
- Focused simulator tests cover the storage manifest, SwiftData object-store authority rules, SQLite event append/query/checksum behavior, projection persistence, FTS search rebuild/privacy filtering, blob integrity, redacted external snapshots, encrypted backup/decrypt integrity, and migration dry-run metadata.
- Source-present Search source exists under `Native/Ambitions/Core/LocalRuntimeOS/Search/`, including `LocalSearchIndex`, `FTSIndex`, `SemanticLocalIndex`, `ResultRanker`, `FindActInspectContract`, `SearchActionValidator`, and `SearchRebuildPipeline`.
- The former legacy runtime local search index owner file was removed from that owner.
- Focused simulator tests cover Search canonical owner files, old owner removal, moved local search ranking behavior, FTS-backed Find / Act / Inspect results, result provenance, privacy filtering, action validation, deterministic local semantic ranking with no external model use, and projection-fed search rebuild.
- Source-present ObjectState foundation source exists under `Native/Ambitions/Core/LocalRuntimeOS/ObjectState/`, including `ObjectStateRegistry`, family descriptors for `GoalThreadStore`, `LifeAreaStore`, `StepStore`, `CaptureStore`, `TimeBlockStore`, `ClosureStore`, `ProofStore`, `ReceiptStore`, `UserSystemStore`, and `AppStateStore`, `RuntimeObjectStateMutationContext`, `ObjectStateWriteReceipt`, object-state store contracts, and `SwiftDataAppStateStore`.
- `SwiftDataAppStateStore` is the only migrated ObjectState recorder in this slice. It refuses writes without command, transaction, event, projection, receipt, replay, rollback, and local-only context, then delegates AppState persistence through the SwiftData app-state repository.
- Focused simulator tests cover ObjectState canonical owner files, required family registry coverage, SwiftData not being promoted to mutation authority, tracked remaining family debt, AppState write rejection without sanctioned runtime context, rollback-context enforcement, and AppState write success only after command/event/projection/receipt/replay context exists.
- Source-present ExternalWrites foundation source exists under `Native/Ambitions/Core/LocalRuntimeOS/ExternalWrites/`, including `SideEffectOutbox`, `SideEffectPolicyEngine`, `NotificationOutbox`, `EventKitOutbox`, `WidgetRefreshOutbox`, `AppIntentBridge`, `ShareExtensionIntake`, `ExternalReconciliation`, side-effect ledger models, and the SwiftData side-effect ledger repository.
- As of `AMB-1732`, the unused `ReminderOutbox` duplicate authority was removed after source search found no production callers. Reminder side-effect attempts and result receipts route through `EventKitOutbox` and `EventKitIntegrationService` in the inspected source paths.
- The former `Core/Domain/SideEffectLedgerModels.swift` file and the former `Core/Persistence` side-effect ledger repository struct were removed from those owners.
- Focused simulator tests cover ExternalWrites owner files, old owner removal, policy blocking without local commit evidence, a real SwiftData local commit followed by queued external attempt/result recording, side-effect ledger modeling/repository behavior, notification outbox recording, EventKit outbox recording, and notification payload minimization for private ambient snapshots.
- Source-present PrivateLifeRuntimeKernel foundation source exists under `Native/Ambitions/Core/LocalRuntimeOS/PrivateLifeRuntimeKernel/`, including `PrivateLifeRuntimeKernel`, `DecisionKernel`, `RecommendationKernel`, `CapacityFitKernel`, `RecoveryKernel`, `ClosureKernel`, `ProofKernel`, `AdaptationKernel`, `ExplanationKernel`, `ReplayableDecisionTrace`, and `PersonalizationFactorLedger`.
- The former legacy runtime private-life runtime kernel, replayable decision trace, and personalization factor ledger builder files and the former `Core/Domain/PersonalizationFactorLedgerModels.swift` owner were removed from those owners.
- Focused simulator tests cover local-only kernel boundary behavior, deterministic decision records, recommendation gating for missing/unsafe/quarantined traces, life-context runtime effects, personalization factor replay, source ownership, and typed local-runtime signal preservation.
- Source-present PlanningEngine source exists under `Native/Ambitions/Core/LocalRuntimeOS/PlanningEngine/`, including `PlanningGraph`, `StepCandidateField`, `GoalPathPlanner`, `FreeFloatingStepPlanner`, `PlanRepairEngine`, `SmallerStepEngine`, `DependencyResolver`, and `ProgressPreservationEngine`.
- The former `Core/Domain/Planning` files, the former `Core/Domain/GoalEngine` StepCandidateField model files, and the former legacy runtime StepCandidateField generator / Source Atlas bridge files were removed from those owners.
- Focused simulator tests cover PlanningEngine canonical owner files, old owner removal, deterministic planning graph construction, dependency resolution, progress preservation, smaller-step proposal selection, plan repair tracing, unscoped free-floating step planning, moved planning evaluation behavior, and the StepCandidateField simulation gauntlet.
- Source-present TimeEngine source exists under `Native/Ambitions/Core/LocalRuntimeOS/TimeEngine/`, including `LifeCalendarStore`, `TimeBlockGraph`, `ProtectedTimeEngine`, `ConstraintEngine`, `CapacityEnvelopeEngine`, `RecurrenceEngine`, `ConflictProposalEngine`, `PlacementEngine`, `RecoveryWindowEngine`, `TemporalMath`, `ProtectedStepPlacementPolicy`, and `PriorityPlacementPolicy`.
- The former legacy runtime protected-placement and priority-placement policy owner files were removed from that owner, and the rendered Time placement coordinator now evaluates placement commands through `PlacementEngine` before producing Time or runtime mutations.
- Focused simulator tests cover TimeEngine canonical owner files, old owner removal, protected near-term placement review before mutation, graph conflict surfacing, DST-safe recurrence math, and durable local calendar store persistence/reload behavior.
- Source-present PrivacySecurity foundation source exists under `Native/Ambitions/Core/LocalRuntimeOS/PrivacySecurity/`, including `PrivacyClassifier`, `RedactionEngine`, `EgressFirewall`, `ExportPolicy`, `LocalAuthGate`, `FileProtectionPolicy`, `EncryptedBlobVault`, `PrivacyManifestRuntimeMap`, `SensitiveSurfacePolicy`, and moved `StoragePrivacySecurityBoundary` validation.
- The former `Core/Persistence` storage privacy/security boundary owner was removed from that owner.
- Focused simulator tests cover PrivacySecurity owner files, old owner removal, private notification redaction, private R2/public-reference egress denial, public reference egress allowance, export review gating, local-auth gating, encrypted blob-vault round trip, and local-only privacy manifest mapping.
- Source-present MigrationRepair foundation source exists under `Native/Ambitions/Core/LocalRuntimeOS/MigrationRepair/`, including `SchemaLedger`, `MigrationDSL`, `MigrationPlanner`, `DryRunMigration`, `PreMigrationBackup`, `StoreInvariantChecker`, `CorruptionQuarantine`, `RuntimeDoctor`, `RepairPlanEngine`, and `RestoreRollback`.
- The former `Core/Persistence` migration/repair owner files were removed from that owner.
- Focused simulator tests cover MigrationRepair owner files, old owner removal, schema ledger validation, migration planning, non-executable repair-plan gating, pre-migration backup receipts, invariant checking, non-destructive corruption quarantine/runtime doctor behavior, restore rollback, and dry-run review.
- As of `AMB-1597`, `RuntimeDoctor` exposes redacted local drift readers and receipt-backed preview repair plans across command journal, event store, projection store, search index, blob vault, side-effect outbox, sync continuity, privacy boundary, migration state, and storage-tier health domains. The proof is local-only and non-executable: it supports reviewable repair previews and receipts, not destructive automatic repair, app-wide repair routing, privacy/legal approval, or release data-safety Green.
- Source-present Diagnostics foundation source exists under `Native/Ambitions/Core/LocalRuntimeOS/Diagnostics/`, including `LocalBackendHealth`, `RuntimeTraceInspector`, `ProjectionInspector`, `CommandInspector`, `PrivacyInspector`, `SyncInspector`, `StoreInspector`, and `PerformanceBudgetLedger`.
- Focused simulator tests cover Diagnostics owner files, redacted deterministic diagnostic records, runtime trace non-append/local-only failure reporting, duplicate-safe projection inspection, store health duplicate/schema/missing-tier reporting, and performance budget overage surfacing.
- Source-present SyncContinuity source exists under `Native/Ambitions/Core/LocalRuntimeOS/SyncContinuity/`, including `LocalAuthoritativeSyncModel`, `CloudKitContinuityAdapter`, `SyncEnvelope`, `SyncEligibilityPolicy`, `AccountStateMachine`, `CausalMergeEngine`, `ConflictPolicyEngine`, `TombstoneSync`, and `SignOutDeleteResetCoordinator`.
- The former `Core/Persistence` SyncCapability and CloudKit continuity owner files and the former `Core/Domain/Planning` LivingPlan continuity owner file were removed from those owners.
- Focused simulator tests cover SyncContinuity owner files, old owner removal, local-device authority across unavailable account states, proof-backed envelope eligibility, private-graph payload denial, CloudKit zone preparation denial before proof, deterministic merge/conflict quarantine behavior, tombstone metadata propagation limits, sign-out cleanup retaining local data, and preserved account-state diagnostics.
- Source-present SourceAtlas source exists under `Native/Ambitions/Core/LocalRuntimeOS/SourceAtlas/`, including `PublicPackRequestCompiler`, `ManifestVerifier`, `SignatureVerifier`, `PublicPackCache`, `FreshnessEngine`, `LastKnownGoodStore`, `R2GatewayClient`, `PublicOnlyFirewall`, `SourceAtlasProjection`, and the moved Source Atlas model, pack, cache, refresh, import, composition, proof, and runtime bridge source.
- The former `Core/Domain`, `Core/Persistence`, and legacy runtime SourceAtlas owner files and their old `Native/AmbitionsTests/Domain`, `Native/AmbitionsTests/Persistence`, and `Native/AmbitionsTests/Runtime` SourceAtlas test owners were removed from those owners.
- Focused simulator tests cover SourceAtlas owner files, old owner removal, public-only request compilation, private-graph request rejection, safe R2 GET request metadata compilation for public reference objects, manifest hash/signature verification, freshness evaluation, last-known-good cache selection, and SourceAtlas projection materialization.
- SourceAtlas proof remains bounded to local source/test behavior. It does not prove R2 production deployment, public transparency logs, production signing operations, app-wide SourceAtlas consumption, or full LocalRuntimeOS completion.
- Source-present CaptureRouteGraph foundation source exists under `Native/Ambitions/Core/LocalRuntimeOS/CaptureRouteGraph/`, including `CaptureIntakeJournal`, `CaptureDraftStore`, `CaptureClassifier`, `CaptureRouteResolver`, `CaptureAttachmentVault`, `CapturePromotionTransaction`, `CaptureCorrectionLedger`, and `CaptureDirectLookupIndex`.
- The former `Core/Domain` CaptureRouteGraph and CaptureRouteCommandMapping owner files were removed from that owner.
- Focused simulator tests cover CaptureRouteGraph owner files, old owner removal, durable intake before classification, route-decision event traces, draft and direct-lookup indexing, attachment checksum/quarantine behavior, correction ledger writes, promotion transaction receipts, and DefaultCaptureService create/promotion routing through CaptureRouteGraph.
- Source-present Inspection source exists under `Native/Ambitions/Core/LocalRuntimeOS/Inspection/`, including event ledger models, action receipt history models, action receipt proof ledger models, `ProofLedger`, `SourceRecordLedger`, entity revision tombstones, ledger replay models, `AuditTrail`, `UndoLedger`, `HistoryQueryEngine`, trust repository contracts, SwiftData trust repositories, unavailable trust repositories, and the goal-intent receipt persistence recorder.
- The former `Core/Domain` receipt/event/proof/tombstone/replay model owner files, the former legacy runtime `ProofLedger.swift` owner file, and the former `Core/Persistence` trust-history and goal-intent receipt recorder owner files were removed from those owners.
- Focused Inspection test source covers canonical owner files, old owner removal, and command/event/receipt/proof/source/audit/undo/history/replay planning behavior. This is source/build scope only unless current closeout proof shows simulator execution.
- Remaining persistence and domain scaffolding exists primarily under `Native/Ambitions/Core/Persistence/` and `Native/Ambitions/Core/Domain/`; the former legacy runtime owner has been pruned, with runtime authority under `Native/Ambitions/Core/LocalRuntimeOS/`.
- `Native/Ambitions/Core/LocalRuntimeOS/` is source-present for the bound architecture subtree and has scanner-clean high-risk mutation coverage through the current LocalRuntimeProof gate. This is still not a claim of complete local runtime OS coverage across full cross-path replay, active app-wide storage consumption, full ObjectState migration beyond AppState, full app-wide side-effect outbox enforcement, app-wide Inspection consumption across every receipt/proof/history/undo/trust inspection path, app-wide PlanningEngine consumption across every goal/pathing/planning path, app-wide TimeEngine consumption across every scheduling/time/recovery/recurrence path, app-wide capacity/recovery/correction/projection invalidation ownership, app-wide privacy firewall/network-egress enforcement beyond the current source/runtime gates, destructive or executed migration/repair automation beyond receipt-backed previews, app-wide diagnostics consumption or repair routing, app-wide Search consumption by every search or Memory Lens path, or production CloudKit continuity.
- Current SwiftData persistence source is now owned by `ObjectStoreSwiftData`, but the app has not yet proven every app path consumes only the new storage tier split.
- Existing command, moved trust/receipt/event/proof scaffolding, side-effect ledger, snapshot ledger, Source Atlas, remaining runtime, and repository code may be reused or moved as scaffolding, but they do not prove the LocalRuntimeOS spine is complete.
- `scripts/ambitions-local-runtime-proof.py` is the repo-local LocalRuntimeProof gate. It currently separates source-present owner coverage from app-wide runtime proof and must be Green, with focused runtime test evidence, before claiming the full LocalRuntimeOS mutation spine is proven.
- As of `AMB-1599`, `docs/qa/local-runtime-proof/current-local-runtime-proof.json` and `docs/qa/local-runtime-proof/current-local-runtime-proof.md` record LocalRuntimeProof Gate Green for `20` semantic/fail-closed LRO-100 checklist items with `0` blockers and machine-readable checklist status. That proves the current source/runtime gate for the checked source tree only. It does not prove Visual Green, Release Green, physical-device behavior, privacy/legal approval, TestFlight readiness, App Store readiness, production R2 deployment, production CloudKit continuity, future/unscanned code paths, or total LocalRuntimeOS/product completion.

Unsupported implementation claims until future source proof exists:

- every meaningful state change in every present or future app path is forced through the command/event/projection/receipt/replay law
- the EventJournal is the sole canonical mutation record for every meaningful runtime mutation
- duplicate and failed command replay are deterministic across every runtime path
- all app-facing projections are consumed by Stage/surfaces/widgets/App Intents only from `Projections`
- every app path treats SwiftData only as the object store tier
- SQLite/FTS-backed journal, projection, and search stores are active across all production mutation/read paths
- every external side-effect path is fully outboxed with leases, retry, confirmation, and receipts
- every capture entrypoint, extension, widget/App Intent bridge, attachment flow, and direct repository fallback path is forced through the durable CaptureRouteGraph before classification/promotion
- every trust/proof/source/history/receipt/undo path is produced and consumed only through Inspection
- Source Atlas is a signed public-reference package manager
- CloudKit continuity is approved or implemented as user-owned event-envelope sync
- migration/repair/diagnostics prove runtime, privacy, release, or data-safety Green

---

## 3. Current Product/Source Alignment

Active product/design truth from `PRODUCT_DESIGN_TRUTH.md` is:

```text
Persistent surfaces:
Today / Goals / Time / You

Global composer:
Capture

Cross-surface behavior layer:
Motion

Inspectable trust layer:
Proof / Source / Privacy / History / Receipts
```

Current source-state reality:

- Source may still contain Motion feature files, Motion tests, Motion screenshots, and Motion proof artifacts.
- Source may still contain Capture screen modes, capture navigation routes, capture inbox terms, or other compatibility paths.
- Source may still contain `Plan`, `Profile`, `Captures`, `Pulse`, `DayTimelineRail`, `GoalMissionControl`, `RealityMeridian`, `ConstellationAtlas`, `LifeShapeField`, `AtmosphereComposer`, `OpenField`, or other prior/internal names.
- These source facts do not override current product truth.

Implementation classification:

- Motion source is now compatibility debt unless reused as `Stage/Motion` behavior infrastructure.
- `Capture` source and composer logic may be reused as global Capture infrastructure, but not as a top-level tab contract.
- `Plan` may exist as compatibility code for Time behavior, but not as a root surface.
- `Profile` may exist as compatibility code for You behavior, but not as a root surface.
- `Pulse` may appear as historical/proof primitive naming only, not as a current tab or surface.
- Reality Meridian, Constellation Atlas, LifeShape Field, Atmosphere Composer, Open Field, Motion Current, and User System Profile may remain as internal source/type names where they already exist, but they are not user-facing surface names and must not override current product language.

Hard implementation truth:

```text
If current source routes to Motion as a canonical root tab, that is product drift.
If current source routes to Capture as a canonical root tab, that is product drift.
If tests require Motion as a root tab, those tests are stale and must be migrated.
If scripts validate Motion as a root IA surface, those scripts are stale and must be migrated.
```

Green implementation standard:

- Source Green requires more than canonical paths: active root source must avoid architecture-as-UI copy and avoid generic wrapper ownership of the first viewport.
- Runtime Green requires typed mutation, receipt, proof, undo, and accessibility consequences for scoped meaningful mutations.
- LocalRuntimeOS Runtime Green additionally requires current source/test proof for command validation, event append, projection materialization, receipt generation, replay/idempotency behavior, and side-effect separation for the scoped mutation.
- Interaction Green requires object-owned mutation feedback, keyboard/safe-area behavior, and accessibility actions where user-facing changes occur.
- Visual Green and Release Green remain unavailable to Codex without current independent visual, physical-device, accessibility, and release proof under `IMPLEMENTATION_ACCEPTANCE_TRUTH.md` and `RELEASE_TRUTH.md`.

---

## 4. Native iPhone / Xcode / Project Structure

Implementation truth:

- The repo uses XcodeGen.
- `Ambitions.xcodeproj` is generated and should not be treated as checked-in source truth.
- The configured app platform is iOS.
- The deployment target in `project.yml` is iOS 26.0.
- Swift version in `project.yml` is 6.0.
- The app target is named `Ambitions`.
- Native app source is under `Native/Ambitions`.
- Resources are under `Native/Ambitions/Resources`.
- Entitlements are configured through source paths in `project.yml`.

Required proof before claiming build success:

```bash
xcodegen generate
xcodebuild -project Ambitions.xcodeproj -scheme Ambitions -resolvePackageDependencies
xcodebuild -project Ambitions.xcodeproj -scheme Ambitions -destination "<simulator>" build CODE_SIGNING_ALLOWED=NO
```

with current logs, exit codes, branch, and commit SHA.

---

## 5. Domain and Persistence Status

Source evidence includes broad domain/model areas:

```text
Native/Ambitions/Domain/
Native/Ambitions/Domain/GoalEngine/
Native/Ambitions/Domain/Planning/
Native/Ambitions/Domain/Reschedule/
Native/Ambitions/Core/LocalRuntimeOS/Storage/ObjectStoreSwiftDataModels.swift
Native/Ambitions/Core/LocalRuntimeOS/Storage/ObjectStoreSwiftData.swift
```

SwiftData persisted records are source-present for goals, goal drafts, goal plans, plan sections, steps, progress evidence, feedback events, captures, teaching signals, event ledger, and app state.

Implementation truth:

- Domain model source is extensive.
- Persistence records exist for key product objects.
- Repositories are wired through `AppContainerFactory`.
- Some domain areas may be model/scaffold-heavy rather than complete behavior.
- Mature local intelligence, personalization, recommendation, proof transfer, and recovery loops are not proven merely by model presence.

Do not claim the full external-brain graph, personalization, local learning, deterministic recommendation, model usage, persistence safety, or migrations are complete unless current source and proof establish those claims.

---

## 6. Local-First, Account, R2, and AI Status

### Local persistence

Source truth:

- SwiftData persistence source exists.
- `AmbitionsPersistenceStore` creates a SwiftData `ModelContainer` from `Native/Ambitions/Core/LocalRuntimeOS/Storage/ObjectStoreSwiftData.swift`.
- Store supports persistent and in-memory modes.
- Live configuration uses persistent mode.
- Repositories are built from `SwiftData*Repository` types in `AppContainerFactory`.
- Unit-of-work transaction receipt source exists.
- App Group entitlement exists.

Unproven: migration safety, corruption recovery, backup/restore, data deletion/export UX, long-running data integrity, physical-device persistence, App Group behavior across extensions, and legal/privacy correctness.

### Ambitions Account

Product truth requires custom Ambitions Accounts at launch using Sign in with Apple and Google Sign-In for optional identity, entitlement, and R2 reference-pack access.

The app must keep its offline core usable with no account. Ambitions Account source must not store or sync the private life graph unless future canon explicitly approves user-owned sync and current proof exists.

Current source truth:

```text
Unproven until source and logs prove otherwise.
```

Do not claim Ambitions Account, Sign in with Apple, Google Sign-In, account recovery, account entitlements, account-gated R2 access, or account private life graph behavior is implemented unless current source and proof establish those claims.

### R2 / Source Atlas

Product truth makes R2 first-class for Source Atlas/reference freshness.

Current source truth:

- Source Atlas model source exists in the repo.
- Source Atlas Foundry tooling exists under `tools/source-atlas/` for public/reference harvesting, bundle compilation, validation, R2 staging plans, and R2 staging upload support.
- The Foundry and Ambitions-native MCP tooling can support versioned reference-pack manifests, provenance/freshness records, public/reference boundary checks, and staging upload plans.
- Local developer/tooling proof may validate Foundry output shape or R2 staging access. That does not prove app runtime fetch, cache, entitlement gating, production promotion, pack verification, privacy boundary, or release readiness.
- No release proof currently validates app-side R2 fetch, cache, entitlement gating, pack verification, production freshness, or privacy boundary.

Hard boundary:

- R2 is not a user-data backend.
- R2 must never become a private life graph backend.
- R2 requests must not include private user context.
- Goals, captures, calendar context, schedule assumptions, proof, receipts, closure history, behavior patterns, inferred priorities, profile, or personal context must not be uploaded to R2.

Do not claim R2 freshness, R2 production updates, Source Atlas pack readiness, R2 entitlement gating, or R2 privacy validation unless current source and proof establish those claims.

### External/cloud LLM status

Product truth excludes external/cloud LLMs, hosted AI services, and cloud model APIs from core architecture.

Hosted AI services and cloud LLMs are not core architecture and are excluded from Ambitions app runtime dependencies.

Current source truth:

- No active app-source OpenAI/API/cloud LLM implementation is treated as core architecture by active truth.
- Retained docs and skills may mention AI/Codex as local contributor tooling, but those are not app runtime dependencies.

Codex must not add external LLM dependency, cloud model calls, chatbot-first UI, opaque model confidence, server-side user profiling, or hosted personal-data intelligence unless truth files are updated first.

---

## 7. Surface Implementation Status

### Today

Source-present evidence: `Native/Ambitions/Surfaces/Today/TodaySurface.swift`, `Native/Ambitions/Surfaces/Today/TodayObjectView.swift`, `Native/Ambitions/Projection/StageScenes/TodayStageScene.swift`, and `Native/Ambitions/Projection/SurfaceLenses/TodayLens.swift`.

Implementation truth: Today source exists and is wired in current app source. Product truth says Today is the Reality Window, not task list, calendar timeline, dashboard, or detached card stack. Final live-time, mutation, accessibility, safe-area, and flagship visual behavior remain unproven unless current proof exists.

### Goals

Source-present evidence: `Native/Ambitions/Surfaces/Goals/GoalsSurface.swift`, `Native/Ambitions/Surfaces/Goals/GoalsObjectView.swift`, `Native/Ambitions/Projection/StageScenes/GoalsStageScene.swift`, and `Native/Ambitions/Projection/SurfaceLenses/GoalsLens.swift`.

Implementation truth: Goals source exists. Product truth says Goals is the Life Area Atlas with Life Areas, Goal Threads, Step chains, proof history, and no KPI/ranked-score/dashboard drift. Final Life Area Atlas behavior remains unproven unless current proof exists.

### Time

Source-present evidence: `Native/Ambitions/Surfaces/Time/TimeSurface.swift`, `Native/Ambitions/Surfaces/Time/TimeObjectView.swift`, `Native/Ambitions/Projection/StageScenes/TimeStageScene.swift`, and `Native/Ambitions/Projection/SurfaceLenses/TimeLens.swift`.

Implementation truth: Time source exists. Plan compatibility code may still exist. Product truth says Time is Ambitions' native Life Calendar, not calendar clone, agenda clone, free/busy grid, productivity score, or AI scheduling surface. Final native Life Calendar implementation remains unproven unless current proof exists.

### You

Source-present evidence: `Native/Ambitions/Surfaces/You/YouSurface.swift`, `Native/Ambitions/Surfaces/You/YouObjectView.swift`, `Native/Ambitions/Projection/StageScenes/YouStageScene.swift`, and `Native/Ambitions/Projection/SurfaceLenses/YouLens.swift`.

Implementation truth: You source exists. Profile compatibility symbols may remain. Product truth says You is the local settings, personalization, privacy, learning, Source, receipts, and account-control surface, not social profile/admin/AI settings wall/generic settings dump. Final native settings/profile quality remains unproven unless current proof exists.

### Capture

Source-present evidence: `Native/Ambitions/Composer/Capture/CaptureSurface.swift`, `Native/Ambitions/Composer/Capture/CaptureAtmosphereComposer.swift`, `Native/Ambitions/Core/LocalRuntimeOS/CaptureRouteGraph/`, `Native/Ambitions/Projection/OverlayScenes/CaptureStageScene.swift`, and `Native/Ambitions/Projection/OverlayLenses/CaptureLens.swift`.

Implementation truth: Capture source exists. CaptureRouteGraph now has a source-present LocalRuntimeOS owner for durable intake, classification, route resolution, attachment staging, correction, direct lookup, and promotion receipts. Capture may still contain old route/screen assumptions outside that bounded source slice. Product truth says Capture is the global typed route graph and full-screen Stage composer, not a root tab. Final global composer behavior remains unproven unless current proof exists.

### Motion

Source-present evidence: `Native/Ambitions/Stage/Motion/`, `Native/Ambitions/Projection/StageMotionProjection.swift`, and `Native/Ambitions/DesignSystem/ProductObjects/MotionCurrentView.swift`.

Implementation truth: Motion source exists. Product truth says Motion is Stage/Motion behavior, not a root destination, activity feed, analytics surface, score, streak, XP layer, or dashboard. Final Stage/Motion behavior remains unproven unless current proof exists.

---

## 8. Implementation Hard Stops

Hard Red for implementation claims:

- claiming root IA is migrated before source/tests/scripts prove `Today / Goals / Time / You`
- claiming Motion is removed as root while source/tests still require Motion root
- claiming Capture is global-only while source/tests still require Capture root
- claiming Ambitions Account works without current auth/source/proof
- claiming R2 works without current fetch/cache/entitlement/privacy proof
- claiming hosted AI/cloud LLM is part of core runtime
- claiming offline core works if account/network becomes required
- claiming accessibility/performance/device/release readiness without current proof

This is implementation truth, not release proof.

---

## 9. Historical Proof Is Not Current Proof

Old batch reports, generated proof ledgers, screenshots, prompts, train closeouts, and deleted control-plane material are not implementation proof.

Current implementation claims require live source/project/test/script evidence and, where release-facing, current logs under `RELEASE_TRUTH.md`.
