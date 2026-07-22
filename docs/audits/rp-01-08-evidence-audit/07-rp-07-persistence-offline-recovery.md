<!-- markdownlint-disable MD013 MD060 -->

# RP-07 — Persistence, Offline, Conflict, and Recovery

Audit base: `main` at `29872755f705f6bd8e276aeac86dcf376ac5f0d8` on 2026-07-22.

## Executive verdict

`PARTIALLY_SUPPORTED`. Ambitions has substantial local persistence: production SwiftData repositories, SQLite event and projection stores, local FTS, a file command journal, durable authority receipts, and bounded restart/replay paths. This is a credible local-first substrate. It is not proof that every feature remains fully usable offline: the mutation registry keeps 50 production write-path rows unproven, including broad external, repair, storage, Capture, and Goals paths. CloudKit continuity is disabled by canon and its current coordinator defaults to a simulated client plus in-memory outbox. EventKit has narrow durable pending-operation identity and a file side-effect ledger, but its end-to-end mutation/reconciliation rows remain unproven. Generic pending queues, partial settlement, exact draft/query/context restoration, later-settlement notification, and product-wide conflict recovery are not supported.

The selected contextual recovery direction is compatible with the local substrate, but depends on major runtime state, proof, and restoration decisions.

Primary dispositions: `VISUAL_DIRECTION_SURVIVES`, `TARGETED_VISUAL_REFINEMENT_REQUIRED`, `ARCHITECTURE_DECISION_REQUIRED`, `RUNTIME_CAPABILITY_REQUIRED`, `RECONSTRUCTION_PLAN_ACTION_REQUIRED`.

## Scope and authority

This packet audits local persistence, offline read/write, synchronization, pending operations, retry, conflict, recovery, Receipt/Undo survival, restoration, and background/later settlement. Live source and the live mutation registry are implementation authority. Canon establishes the local-authority and disabled-continuity constraints, but does not prove completion. The attached Recovery campaign and closure package are provisional visual intent.

The audit coordinator’s targeted XCTest batch failed before execution with `FAILURE_CLASS=simulator_boot_failure` and `EXECUTED_TESTS=0`; it supplies no runtime evidence. Test definitions are cited only as inspectable proof intent.

## Persistence and reconciliation topology

```text
local intent
  -> FileCommandJournal
  -> EventStoreSQLite authority transaction
       + semantic/command events
       + RuntimeCommitReceipt
       + outbox intents
  -> ProjectionStoreSQLite / SwiftData repositories / SearchStoreFTS
  -> local receipt/history projections

optional external effect
  -> durable side-effect ledger claim
  -> external adapter attempt
  -> terminal / reconciliation-required result

optional CloudKit continuity
  -> policy/diagnostic scaffolding
  -> simulated client + in-memory outbox by default
  -> disabled until approved; not production sync authority
```

## Persistence inventory

| Store/state | Capability status | Current role | Evidence |
|---|---|---|---|
| SwiftData object repositories | `SUPPORTED` as production storage substrate | Goals, drafts, evidence, captures, reminders, teaching, event ledger, side effects, receipts, tombstones, snapshots, command records, app state. | E07-01 |
| SQLite runtime event store | `SUPPORTED` | Application Support event journal with checksum chain and health cursor. | E07-02 |
| SQLite authority receipt table | `SUPPORTED` | Atomic receipt/outbox record keyed by command identity. | E07-03 |
| SQLite projection store | `SUPPORTED` as substrate | Production projection composition. | E07-01 |
| FTS search store | `SUPPORTED` as substrate | Production FTS index exists; active Search also has repository aggregation. | E07-01 |
| File command journal | `SUPPORTED` as substrate | Production append/replay journal with checksum and runtime link models. | E07-01, E07-04 |
| Action Receipt/history repositories | `PARTIALLY_SUPPORTED` | Persistence exists, but meaningful mutation coverage is bounded. | E07-01, E07-05 |
| Capture draft | `ABSENT` in active composer path | Draft text/ID are view-model state, not bound to durable draft storage. | E07-06 |
| Search query/session | `ABSENT` | Query/results/status are SwiftUI `@State`. | E07-06 |
| Navigation/focus/scroll/keyboard | `UNKNOWN` | No evidence in this packet of durable exact-context restoration; exact field/focus/keyboard restoration is absent from the inspected active paths. | E07-06 |
| EventKit pending operation ID | `PARTIALLY_SUPPORTED` | File-backed fingerprint-to-operation identity exists; registry calls it unproven adapter state. | E07-07 |
| Generic pending-operation queue | `ABSENT` | No product-wide durable queue/settlement owner was found. | E07-05, E07-08 |
| CloudKit continuity outbox | `DEBUG_OR_FIXTURE_ONLY` as default durable claim | Coordinator defaults to simulated client and in-memory outbox; live client scaffolding is present but continuity is disabled. | E07-09, E07-10 |

## Offline-read matrix

| Read capability | Capability status | Finding | Evidence |
|---|---|---|---|
| Local Goals/Captures/evidence/settings repositories | `PARTIALLY_SUPPORTED` | Production local repositories exist; full-domain correctness and migration proof are outside storage presence. | E07-01, E07-05 |
| Local Search Find | `SUPPORTED` for active repository results | Search reads local repositories and ranks locally. | E07-11 |
| Runtime history/events | `SUPPORTED` | SQLite fetch validates envelopes and event checksums. | E07-02 |
| Receipts | `PARTIALLY_SUPPORTED` | Durable for covered authority commits; broad mutation coverage is incomplete. | E07-03, E07-05 |
| Last valid projection after error | `PARTIALLY_SUPPORTED` | Stores can retain projections, but Search currently converts repository error to an empty result rather than exposing stale/local truth. | E07-11 |
| External calendar truth offline | `PARTIALLY_SUPPORTED` | Local side-effect records/derived state can persist; live external freshness is unverifiable offline. | E07-07, E07-08 |
| Private CloudKit graph offline | `ABSENT` as sync feature | Continuity is disabled; local core does not depend on it. | E07-09, E07-10 |

## Offline-write matrix

| Write capability | Capability status | Finding | Evidence |
|---|---|---|---|
| Bounded Time placement/Undo | `SUPPORTED` by registry proof declaration | Durable local journal/authority/replay rows. | E07-05 |
| Selected Today action/Receipt paths | `SUPPORTED` by registry proof declaration | Durable owner rows and projection materializers. | E07-05 |
| Quick Capture creation | `PARTIALLY_SUPPORTED` | Semantic authority and projection recovery are proven; parallel/direct Capture paths remain unproven. | E07-05 |
| Capture-to-Goal handoff | `SUPPORTED` by registry proof declaration | Durable atomic owner handoff with named restart/replay tests. | E07-05 |
| General Goals mutations | `PLANNED_NOT_IMPLEMENTED` at durable proof level | Registry classifies them unproven. | E07-05 |
| General Capture routing | `PLANNED_NOT_IMPLEMENTED` at durable proof level | Most route/archive/Time/attachment rows unproven. | E07-05 |
| Queue external calendar change offline | `PARTIALLY_SUPPORTED` | Durable operation identity and side-effect ledger primitives exist; production EventKit rows are unproven. | E07-05, E07-07, E07-08 |
| Queue CloudKit private-graph change | `CONTRADICTED` as current capability | Default outbox is in-memory and continuity must remain disabled. | E07-09, E07-10 |
| Accept unverifiable external work as settled | `ABSENT` | External result model distinguishes failure/permission/confirmation; no truthful basis to mark unverified work settled. | E07-08 |

## Pending-operation matrix

| Pending concern | Capability status | Finding | Evidence |
|---|---|---|---|
| Command `pending` / `queued` state | `PARTIALLY_SUPPORTED` | Enum cases exist, but no generic durable worker/later-settlement lifecycle is proven. | E07-12 |
| External claim identity | `PARTIALLY_SUPPORTED` | Side-effect outbox uses a durable ID and claim/finalize protocol. | E07-08 |
| EventKit pending identity across restart | `PARTIALLY_SUPPORTED` | File store persists fingerprint mapping; registry explicitly says adapter state is unproven. | E07-07, E07-05 |
| CloudKit pending entries across restart | `ABSENT` | Default store is in memory. | E07-09 |
| Cancellation | `UNKNOWN` | EventKit identity can complete/remove, but no product-wide cancellation contract was established. | E07-07 |
| Retry | `PARTIALLY_SUPPORTED` | Same durable side-effect ID can classify existing state as terminal or reconciliation-required; no generic retry scheduler. | E07-08 |
| Later settlement | `PARTIALLY_SUPPORTED` for external ledger recording | External result can finalize a receipt; no general later-settlement UX or background guarantee. | E07-08 |
| User notification of later result | `ABSENT` | No generic notification binding from pending settlement to user-visible recovery was found. | E07-05 |
| Scope-level pending/partial state | `ABSENT` | Shared command and side-effect states are whole-operation states. | E07-12 |

## Synchronization and source-priority model

| Source | Current authority | Capability status | Conflict/recovery behavior |
|---|---|---|---|
| Local event authority | Canonical for covered mutations. | `PARTIALLY_SUPPORTED` product-wide | Durable receipt/replay for bounded rows. |
| SwiftData/projection stores | Derived/compatibility storage depending on row. | `PARTIALLY_SUPPORTED` | Registry prevents treating presence as owner proof. |
| External EventKit | Separate external side effect after local decision/confirmation. | `PARTIALLY_SUPPORTED` | Durable claim/receipt primitives; end-to-end rows unproven. |
| CloudKit continuity | Not enabled authority. | `PLANNED_NOT_IMPLEMENTED` | Policy-gated scaffolding; no production private graph sync. |
| R2/Source Atlas | Public reference only, never private graph authority. | `SUPPORTED` as a constitutional boundary, not audited behavior | Cannot resolve private-data conflicts. |

The source priority supported by both code and canon is: local store remains authoritative; external operations have separate results; CloudKit cannot become authority [E07-09, E07-10]. Merge, tombstone propagation, old-client compatibility, and divergence resolution remain unimplemented continuity requirements, not current behavior.

## Retry and recovery matrix

| Recovery capability | Capability status | Finding | Evidence |
|---|---|---|---|
| Same-command idempotent replay | `SUPPORTED` for covered authority commits | Existing receipt returned by command ID. | E07-03 |
| Projection catch-up after authority | `PARTIALLY_SUPPORTED` | Runtime can mark post-authority materialization for recovery; covered Capture tests are named but not executed. | E07-05, E07-13 |
| Generic automatic retry | `ABSENT` | No product-wide durable retry scheduler found. | E07-05, E07-08 |
| Manual retry | `PARTIALLY_SUPPORTED` | Side-effect reconciliation and feature-local actions can retry; ownership is not unified. | E07-08 |
| Reauthentication | `PLANNED_NOT_IMPLEMENTED` | Cloud/account continuity is disabled; external permission flows are separate. | E07-09, E07-10 |
| Permission repair / Open Settings | `PARTIALLY_SUPPORTED` | External result distinguishes permission denial; full settings-return restoration is outside this proof. | E07-08 |
| Contextual recovery state | `PARTIALLY_SUPPORTED` | `RecoveryState` carries reason, proof IDs, receipt, and reentry step. | E07-14 |
| Time recovery action | `PARTIALLY_SUPPORTED` | Current recovery card is explicitly suggestion-only and makes no schedule changes. | E07-14 |
| System-wide recovery | `ABSENT` | No unified state/host that aggregates unsafe roots was found. | E07-14 |

## Conflict capability matrix

| Conflict | Capability status | Current support | Evidence |
|---|---|---|---|
| Duplicate idempotency key | `SUPPORTED` for covered authority | Durable receipt replay and runtime conflict kind. | E07-03, E07-15 |
| Stale read overlap | `PARTIALLY_SUPPORTED` | Detector compares transaction read cursor/object overlap with committed receipts supplied to it. | E07-15 |
| Projection cursor regression | `PARTIALLY_SUPPORTED` | Explicit runtime conflict kind. | E07-15 |
| External duplicate/reconciliation | `PARTIALLY_SUPPORTED` | Existing nonterminal side-effect returns `reconciliationRequired`; adapter proof incomplete. | E07-08 |
| Concurrent domain edit | `PARTIALLY_SUPPORTED` | Bounded Capture-to-Goal tests are named; no product-wide merge. | E07-05, E07-13 |
| Calendar conflict | `PLANNED_NOT_IMPLEMENTED` | EventKit rows unproven; no general conflict settlement model. | E07-05 |
| Goal conflict | `ABSENT` as shared runtime capability | Goals mutation rows unproven. | E07-05 |
| Identity conflict | `ABSENT` | No generic merge/dedup conflict owner found in active runtime. | E07-15 |
| Offline divergence / sync conflict | `PLANNED_NOT_IMPLEMENTED` | Continuity explicitly requires future deterministic conflict/merge proof. | E07-10 |

## Partial settlement, Receipt, and Undo persistence

- Partial settlement is `ABSENT`: neither command status nor side-effect result contains per-scope completed/failed/deferred/uncertain outcomes [E07-12].
- Durable authority Receipts survive restart for covered commands because they are stored in SQLite and replayed by command ID [E07-03]. This is `PARTIALLY_SUPPORTED` product-wide because registry coverage is bounded [E07-05].
- Time Undo is `SUPPORTED` by the registry’s row-specific proof declaration; generic Undo persistence is `UNKNOWN`/`PLANNED_NOT_IMPLEMENTED` [E07-05].
- External Receipts can be recorded in the side-effect ledger, but external reversal and interruption behavior remain `PARTIALLY_SUPPORTED` [E07-08].

## Restoration capability

| Restored state | Capability status | Finding |
|---|---|---|
| Canonical local object/event state | `PARTIALLY_SUPPORTED` | Local stores survive relaunch; meaningful mutation coverage varies. |
| Authority Receipt/replay identity | `SUPPORTED` for covered commands | SQLite receipt lookup by command ID. |
| Capture draft/expression/stage | `ABSENT` in active path | View-model-local fields. |
| Search query/results/selection | `ABSENT` | SwiftUI `@State`, no durable session store. |
| Pending EventKit operation identity | `PARTIALLY_SUPPORTED` | File-backed identity, unproven adapter lifecycle. |
| Pending CloudKit operation | `ABSENT` across relaunch | Default outbox in memory. |
| Focus/scroll/keyboard/external origin | `UNKNOWN` | No exact restoration proof in this packet. |
| Recovery reentry step | `PARTIALLY_SUPPORTED` | Domain contract has `reentryStepID`; universal wiring is not established. |

## Background and later-settlement behavior

`PARTIALLY_SUPPORTED` only for narrow adapter storage. Side-effect records can be claimed/finalized and produce an external receipt [E07-08], but the audit found no generic durable scheduler, retry policy, background execution guarantee, later-settlement notification, or cross-root settlement projection. CloudKit pending entries are in memory [E07-09]. Any visual promise that “Ambitions will finish this later” must be capability-gated to a proven adapter and must not imply timing or notification guarantees.

## Visual-assumption comparison

| Provisional recovery assumption | Capability status | Disposition | Direction IDs |
|---|---|---|---|
| Recovery attaches to the affected object/context | `PARTIALLY_SUPPORTED` | `VISUAL_DIRECTION_SURVIVES`, `TARGETED_VISUAL_REFINEMENT_REQUIRED` | AVF-RECOVERY-S07-R00, AVF-COHERENCE-S07-R00 |
| Current truth remains visible during recovery | `PARTIALLY_SUPPORTED` | `VISUAL_DIRECTION_SURVIVES`, `RUNTIME_CAPABILITY_REQUIRED` | AVF-RECOVERY-S07-R00 |
| Local Truth Horizon communicates freshness/verification | `PLANNED_NOT_IMPLEMENTED` | `ARCHITECTURE_DECISION_REQUIRED`, `RUNTIME_CAPABILITY_REQUIRED` | AVF-RECOVERY-S07-R00, AVF-SEARCH-D07-R00 |
| Pending operations survive and settle later | `PARTIALLY_SUPPORTED` for narrow EventKit adapter only | `TARGETED_VISUAL_REFINEMENT_REQUIRED` | AVF-RECOVERY-S07-R00, AVF-TIME-S07-R00 |
| Partial settlement is displayed by scope | `ABSENT` | `RUNTIME_CAPABILITY_REQUIRED` | AVF-RECOVERY-S07-R00, AVF-COHERENCE-S07-R00 |
| Exact Capture/Search context returns after interruption | `ABSENT` | `UX_BLUEPRINT_DECISION_REQUIRED`, `RUNTIME_CAPABILITY_REQUIRED` | AVF-CAPTURE-S07-R00, AVF-SEARCH-D07-R00 |
| One system-wide passage appears only when multiple roots are unsafe | `ABSENT` | `ARCHITECTURE_DECISION_REQUIRED` | AVF-RECOVERY-S07-R00 |
| Offline core is fully equivalent | `PARTIALLY_SUPPORTED` | `RECONSTRUCTION_PLAN_ACTION_REQUIRED`; do not overclaim beyond proven rows | AVF-RECOVERY-S07-R00, AVF-COHERENCE-S07-R00 |

## Unsupported resilience assumptions

- A generic durable operation queue exists: `ABSENT`.
- All pending work survives termination: `CONTRADICTED`; CloudKit defaults to an in-memory outbox and only narrow EventKit identity is file-backed.
- Every offline write follows the same authoritative path: `CONTRADICTED`; the registry retains many unproven production write paths.
- Partial settlement can distinguish complete/failed/deferred/uncertain scopes: `ABSENT`.
- Search/Capture exact context survives interruption: `ABSENT` in active paths.
- CloudKit synchronizes the private graph: `CONTRADICTED`; continuity is disabled and scaffolding is not production sync.
- Conflict covers calendar, Goals, identity, and offline divergence: `ABSENT` beyond bounded transaction/external cases.
- Later settlement always notifies the user: `ABSENT`.
- Receipts and Undo survive every interruption: `PARTIALLY_SUPPORTED` only for registry-proven rows.

## Required decisions

| Authority | Decision required |
|---|---|
| Devan | Whether the Recovery direction may keep Local Truth Horizon and partial settlement explicitly provisional until runtime support exists. |
| Architecture | Define the durable pending-operation owner and whether local command, external side effect, and future sync queues share one envelope or remain separate. |
| Architecture | Define source priority/freshness and the threshold for contextual versus system-wide recovery. |
| Runtime | Add scope-aware settlement, cancellation, retry, backoff, later-result publication, and durable notification contracts where approved. |
| Runtime | Establish conflict/merge semantics for domains and any future continuity before enabling it. |
| UX Blueprint | Define recovery placement, stale/local/unverified wording, safe retry, exact-context return, and inability-to-guarantee disclosures. |
| Reconstruction planning | Migrate unproven writes to proven local authority and add restart/replay/crash-boundary tests by owner. |
| Accessibility/platform planning | Define announcements and focus return for delayed, failed, permission-repair, and later-settled states. |

## Reconstruction implications

- Treat the live mutation registry as the migration inventory; storage presence alone cannot close offline/replay claims.
- Build a durable, typed pending-operation contract only after deciding owner, cancellation, compensation, and scope semantics.
- Keep CloudKit disabled until the constitutional consent/privacy/conflict/migration/recovery proof list is satisfied.
- Separate local authoritative success from external settlement; preserve local receipts even when projections or external effects need recovery.
- Add deterministic recovery projections driven by current state, Receipt, freshness, and retry capability rather than generic banners.
- Add focused non-network restart/replay tests for each core offline journey and adapter/device tests for external settlement.

## Evidence appendix

| ID | Claim and capability status | Source, symbol, stable lines | Authority / currency | Verification and result | Confidence / remaining uncertainty | Directions |
|---|---|---|---|---|---|---|
| E07-01 | Production local stores are substantial: `SUPPORTED` as substrate. | `Native/Ambitions/App/Bootstrap/PersistenceBootstrap.swift`, lines 3-54, 57-95, 97-118. | Current production bootstrap; DEBUG seed clearly separated. | Source inspection confirmed SwiftData repositories, SQLite events/projections, FTS, file journal; DEBUG-only seed block. | High for composition, not feature correctness. | AVF-RECOVERY-S07-R00, AVF-COHERENCE-S07-R00. |
| E07-02 | Local event persistence/checksum exists: `SUPPORTED`. | `Native/Ambitions/Core/LocalRuntimeOS/Storage/EventStoreSQLite.swift`, `defaultLiveStore`, lines 15-42; append/fetch/health lines 44-104. | Current production store source. | Source inspection confirmed Application Support SQLite, append transaction, checksum validation, health cursor. | High. | AVF-RECOVERY-S07-R00. |
| E07-03 | Authority Receipts survive restart for covered commands: `SUPPORTED`. | `Native/Ambitions/Core/LocalRuntimeOS/Storage/EventStoreSQLiteAtomicCommit.swift`, `commitAuthority`, lines 69-145; schema/receipt lookup lines 245-307. | Current production authority store. | Source inspection confirmed atomic receipt persistence and existing-receipt replay by command ID. | High; current executable test result unavailable. | AVF-RECOVERY-S07-R00, AVF-COHERENCE-S07-R00. |
| E07-04 | File command journal has durable checksum/link models: `SUPPORTED` as substrate. | `Native/Ambitions/Core/LocalRuntimeOS/Commands/CommandJournal.swift`, lines 4-16, 28-54, 56-124, 126-170. | Current production source. | Source inspection confirmed append sequence/checksum and runtime receipt/event link fields. | High for schema; registry limits behavioral proof. | AVF-RECOVERY-S07-R00. |
| E07-05 | Product-wide persistence/offline mutation remains mixed: `PARTIALLY_SUPPORTED`. | `Native/Ambitions/Core/LocalRuntimeOS/Commands/MeaningfulMutationRegistry.swift`, lines 3-23, 38-85, 151-206, 285-403, 406-521. | Current source-owned proof registry. | `python3 scripts/ambitions-runtime-direct-write-audit.py --json` returned green registry coverage, 121 mutation rows, 55 markers, 50 unproven production write-path rows. | High for classification; named tests did not execute. | All RP-07 directions. |
| E07-06 | Exact Capture/Search session restoration is absent in active paths: `ABSENT`. | `Native/Ambitions/Composer/Capture/CaptureViewModel.swift`, draft fields lines 73-94; `Native/Ambitions/Stage/Overlays/QuietCommandSheetView.swift`, `@State` lines 11-15, query loading lines 34-43. | Current UI state source. | `rg -n "draftText\|memoryQuery\|AppStorage\|SceneStorage\|persist\|restore" ...` found transient fields and no durable binding in these paths. | High for these fields; broader shell restoration cannot reconstruct field/keyboard state without bindings. | AVF-CAPTURE-S07-R00, AVF-SEARCH-D07-R00, AVF-RECOVERY-S07-R00. |
| E07-07 | EventKit pending identity is narrowly durable: `PARTIALLY_SUPPORTED`. | `Native/Ambitions/Core/Permissions/CalendarReminders/EventKitPendingOperationIdentityStore.swift`, `FilePendingEventKitOperationStore`, lines 26-104; registry lines 509-511. | Current adapter source plus source-owned proof classification. | Source inspection found file-backed fingerprint mapping; registry calls it unproven adapter state. | High for storage; low for end-to-end EventKit behavior. | AVF-TIME-S07-R00, AVF-RECOVERY-S07-R00. |
| E07-08 | Side-effect claim/finalize/reconciliation exists: `PARTIALLY_SUPPORTED`. | `Native/Ambitions/Core/LocalRuntimeOS/ExternalWrites/SideEffectOutbox.swift`, claim/result enums lines 44-75; claim/classify/finalize lines 190-324; `FileSideEffectLedgerRepository.swift`, lines 10-99, 101-175. | Current production adapter source; registry labels file/EventKit rows unproven. | Source inspection found durable ID requirement, terminal/reconciliation classification, atomic file writes, external receipt recording. | Medium-high; no device execution. | AVF-TIME-S07-R00, AVF-RECOVERY-S07-R00. |
| E07-09 | CloudKit sync defaults are non-durable/simulated: `DEBUG_OR_FIXTURE_ONLY` for claimed active sync. | `Native/Ambitions/Core/LocalRuntimeOS/Continuity/CloudKitContinuityClient.swift`, adapter defaults lines 57-94, static simulated client lines 119-145, in-memory outbox/coordinator defaults lines 302-356. | Current production-compiled scaffolding; defaults are explicit simulation/local-only, not proof. | Source inspection found simulated zone response and `InMemoryCloudKitContinuityOutboxStore`. | High. A live client type exists, but active approved wiring was not established. | AVF-RECOVERY-S07-R00. |
| E07-10 | Private-graph continuity must remain disabled: `PLANNED_NOT_IMPLEMENTED`. | `docs/canon/CONSTITUTION.md`, `LAW-LOCAL-AUTHORITY-001` lines 758-767; `PRIVACY-CLOUDKIT-CONTINUITY-001` lines 802-813. | Current normative canon; target/guardrail, not implementation proof. | `python3 scripts/ambitions-canon.py query "receipt undo search capture offline recovery"` confirmed local/offline requirements; source inspection confirmed disabled-until-approved law. | High for authority boundary. | AVF-RECOVERY-S07-R00, AVF-COHERENCE-S07-R00. |
| E07-11 | Local Search read works structurally but hides read errors: `PARTIALLY_SUPPORTED`. | `Native/Ambitions/Core/LocalRuntimeOS/Search/MemoryLensService.swift`, repository reads/ranking lines 302-378. | Current production service source. | Source inspection found only local repositories/ranking and `catch { return [] }`. | High for code; current runtime test unavailable. | AVF-SEARCH-D07-R00, AVF-RECOVERY-S07-R00. |
| E07-12 | Generic pending/partial settlement is absent: `ABSENT`. | `Native/Ambitions/Core/LocalRuntimeOS/Commands/CommandResult.swift`, status lines 5-14; `Native/Ambitions/Core/LocalRuntimeOS/ExternalWrites/SideEffectLedgerModels.swift`, status lines 18-29. | Current shared result models. | `rg` for partial/uncertain/deferred scope settlement returned no source/test matches. | High for shared representation. | AVF-RECOVERY-S07-R00, AVF-COHERENCE-S07-R00. |
| E07-13 | Restart/replay tests exist, current result `UNKNOWN`. | `Native/AmbitionsTests/LocalRuntimeOS/Transactions/RuntimeAtomicCommitTests.swift`, tests lines 5-264; `TimeCommandReplayTests.swift`, tests lines 5-94; `CaptureGoalHandoffOwnerWriteTests.swift`, tests lines 5-270; `Native/AmbitionsTests/Runtime/P1FLocalSearchFoundationTests.swift`, tests lines 5, 108, 129. | Current test source only. | `rg -n "func test" ...` enumerated restart/replay/local-search tests. Coordinator batch failed at simulator boot; zero executed. | High tests exist; `UNKNOWN` pass/fail at audit SHA. | All RP-07 directions. |
| E07-14 | Recovery models are contextual but not universal: `PARTIALLY_SUPPORTED`. | `Native/Ambitions/Core/Domain/RecoveryState.swift`, lines 3-43, 58-74; `Native/Ambitions/Surfaces/Time/Projection/TimeCalendarRecoveryProjection.swift`, lines 22-85. | Current domain and Time projection source. | Source inspection found proof/receipt/reentry fields and a suggestion-only Time recovery card with no schedule change. | High for source; universal wiring absent. | AVF-RECOVERY-S07-R00. |
| E07-15 | Runtime conflict detection is narrow: `PARTIALLY_SUPPORTED`. | `Native/Ambitions/Core/LocalRuntimeOS/Transactions/RuntimeConflictDetector.swift`, lines 3-116; `RuntimeTransactionCoordinator.swift`, lines 152-155. | Current production transaction source. | Source inspection found duplicate, stale-overlap, cursor-regression only, against receipts supplied by the coordinator. | High for model; persistent cross-process conflict set behavior remains uncertain. | AVF-RECOVERY-S07-R00, AVF-COHERENCE-S07-R00. |
| E07-16 | Legacy runtime production-use guard is clean: `SUPPORTED` for no legacy runtime file references. | `scripts/ambitions-legacy-runtime-production-use-guard.py` and scanned live tree. | Current repository-native static guard. | `python3 scripts/ambitions-legacy-runtime-production-use-guard.py --json` returned `valid=true`, `findingCount=0`, `currentLegacyRuntimeFiles=0`. | High for this guard’s scope; does not prove mutation completeness. | AVF-COHERENCE-S07-R00. |

## Contradiction and unsupported-claim review

- Local storage presence is never promoted to feature-complete offline behavior.
- CloudKit scaffolding is not called active sync.
- EventKit file persistence is not called end-to-end external settlement.
- Test definitions are not treated as passing tests.
- Recovery state types are not treated as universal recovery orchestration.
- No visual direction was revised or approved.
