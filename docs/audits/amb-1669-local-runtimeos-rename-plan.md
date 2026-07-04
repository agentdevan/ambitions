# AMB-1669 LocalRuntimeOS Rename Plan

Status: In progress
Date: 2026-07-03
Scope: AMB-1669 M03 Runtime Simplification
Baseline: `main` / `origin/main` `6bfac0ec7f054dcbfa0597fe3b9452d00e1b4a5c`

## Purpose

AMB-1669 keeps the LocalRuntimeOS mutation law while reducing architecture lore:

```text
Command -> Event -> Projection -> Receipt -> Replay
```

This artifact records the current folder/type dependency graph, target runtime map, API exposure posture, and applied rename slices.

## Current Owner Graph

Current source owner count after the `Scheduling` slice: 19.

| Current owner | Swift files | Target owner | Status |
| --- | ---: | --- | --- |
| Boundary | 18 | Boundary | First slice renamed from `RuntimeBoundary` |
| Commands | 25 | Commands | Second slice renamed from `CommandSpine` |
| Transactions | 12 | Transactions | Third slice renamed from `TransactionKernel` |
| EventJournal | 10 | Events or EventJournal | Pending |
| State | 4 | State | Ninth slice renamed from `ObjectState` |
| Projections | 32 | Projections | Fourth slice renamed from `ProjectionEngine` |
| PrivateLifeRuntimeKernel | 37 | RuntimeKernel or collapsed into retained owners | Pending decision |
| Planning | 68 | Planning | Tenth slice renamed from `PlanningEngine` |
| Scheduling | 35 | Scheduling | Eleventh slice renamed from `TimeEngine` and collapsed numbered ScheduleInstall split filenames |
| CaptureRouteGraph | 20 | CaptureRouting | Pending |
| Inspection | 29 | Inspection | Sixth slice renamed from `TrustSystem` |
| Search | 10 | Search | Seventh slice renamed from `SearchRecall` |
| ExternalWrites | 13 | ExternalWrites | Fifth slice renamed from `SideEffectSystem` |
| SyncContinuity | 10 | Continuity | Pending |
| SourceAtlas | 80 | SourceAtlas or ReferencePacks | Pending decision |
| PrivacySecurity | 12 | Boundary or Privacy | Pending decision |
| Storage | 27 | Storage | Retain name |
| Repair | 20 | Repair | Eighth slice renamed from `MigrationRepair` and split over-cap RuntimeDoctor repair operator types |
| Diagnostics | 8 | Diagnostics | Retain name |

## First Rename Slice

Applied first:

```text
Native/Ambitions/Core/LocalRuntimeOS/RuntimeBoundary/
Native/AmbitionsTests/LocalRuntimeOS/RuntimeBoundary/
```

to:

```text
Native/Ambitions/Core/LocalRuntimeOS/Boundary/
Native/AmbitionsTests/LocalRuntimeOS/Boundary/
```

Reason:

- `Boundary` is explicitly named by AMB-1669 target direction.
- The old owner was a folder-level architecture noun, not a behavior type.
- The move changes canonical ownership without changing runtime behavior.
- Behavior types such as `PrivateLifeRuntimeBoundary`, `SourceAtlasBoundary`, and `NetworkEgressPolicy` remain intact because they are concrete contract types, not folder owners.

## Second Rename Slice

Applied second:

```text
Native/Ambitions/Core/LocalRuntimeOS/CommandSpine/
Native/AmbitionsTests/LocalRuntimeOS/CommandSpine/
```

to:

```text
Native/Ambitions/Core/LocalRuntimeOS/Commands/
Native/AmbitionsTests/LocalRuntimeOS/Commands/
```

Reason:

- `Commands` is explicitly named by AMB-1669 target direction.
- The old owner was a folder-level lore noun; retained Swift types such as
  `AmbitionsCommand`, `CommandJournal`, and `CommandCompiler` already carry the
  behavior contract plainly.
- The move changes canonical ownership without changing runtime behavior.
- The ownership test now proves required `Commands` files exist and the old
  `CommandSpine` production/test owner paths are gone.

## Third Rename Slice

Applied third:

```text
Native/Ambitions/Core/LocalRuntimeOS/TransactionKernel/
Native/AmbitionsTests/LocalRuntimeOS/TransactionKernel/
```

to:

```text
Native/Ambitions/Core/LocalRuntimeOS/Transactions/
Native/AmbitionsTests/LocalRuntimeOS/Transactions/
```

Reason:

- `Transactions` is explicitly named by AMB-1669 target direction.
- The old owner was a folder-level architecture noun; retained Swift types such
  as `RuntimeTransaction`, `RuntimeTransactionCoordinator`, and
  `RuntimeMutationPlan` already carry the behavior contract plainly.
- The move changes canonical ownership without changing runtime behavior.
- The ownership test now proves required `Transactions` files exist and the old
  `TransactionKernel` production/test owner paths are gone.

## Fourth Rename Slice

Applied fourth:

```text
Native/Ambitions/Core/LocalRuntimeOS/ProjectionEngine/
Native/AmbitionsTests/LocalRuntimeOS/ProjectionEngine/
```

to:

```text
Native/Ambitions/Core/LocalRuntimeOS/Projections/
Native/AmbitionsTests/LocalRuntimeOS/Projections/
```

Reason:

- `Projections` is explicitly named by AMB-1669 target direction.
- The old owner was a folder-level architecture noun; retained Swift types such
  as `ProjectionDefinition`, `ProjectionMaterializer`, and
  `ProjectionStoreSurfaceReadAdapter` already carry the behavior contract
  plainly.
- The move changes canonical ownership without changing runtime behavior.
- The ownership test now proves required `Projections` files exist and the old
  `ProjectionEngine` production/test owner paths are gone.
- The slice also renames the moved projector extension shards away from
  `+02/+03/+04` filenames into descriptive owner-local filenames, so the move
  does not introduce new blocked suffix-split files under the new owner.

## Fifth Rename Slice

Applied fifth:

```text
Native/Ambitions/Core/LocalRuntimeOS/SideEffectSystem/
Native/AmbitionsTests/LocalRuntimeOS/SideEffectSystem/
```

to:

```text
Native/Ambitions/Core/LocalRuntimeOS/ExternalWrites/
Native/AmbitionsTests/LocalRuntimeOS/ExternalWrites/
```

Reason:

- `ExternalWrites` is explicitly named by AMB-1670's retained-owner test scope
  and is the clearer half of AMB-1669's `ExternalWrites/Outbox` target.
- `Outbox` would be too narrow for the owner because the folder also owns App
  Intent handoff, Share Extension intake, external reconciliation, and
  external-creation import source.
- Concrete behavior types such as `SideEffectOutbox`, `NotificationOutbox`,
  `EventKitOutbox`, `WidgetRefreshOutbox`, and side-effect ledger records remain
  intact because they name behavior, not the folder owner.
- The move changes canonical ownership without changing runtime behavior.
- The ownership test now proves required `ExternalWrites` files exist and the
  old `SideEffectSystem` production/test owner paths are gone.

## Sixth Rename Slice

Applied sixth:

```text
Native/Ambitions/Core/LocalRuntimeOS/TrustSystem/
Native/AmbitionsTests/LocalRuntimeOS/TrustSystem/
```

to:

```text
Native/Ambitions/Core/LocalRuntimeOS/Inspection/
Native/AmbitionsTests/LocalRuntimeOS/Inspection/
```

Reason:

- `Inspection` is the clearer half of AMB-1669's `Inspection/Receipts` target.
- `Receipts` would be too narrow for the owner because the folder also owns
  proof, source records, audit, undo, history, replay, tombstones, and
  repository contracts.
- The move changes canonical ownership without changing runtime behavior.
- The moved owner-local commit-planner types now use `Inspection` names.
- The ownership test now proves required `Inspection` files exist and the old
  `TrustSystem` production/test owner paths are gone.
- The slice also renames the moved receipt and event-ledger shard files away
  from `+02/+03/+04/+05/+06/+07/+08` filenames into descriptive owner-local
  filenames, so the move does not introduce new blocked suffix-split files
  under the new owner.

## Seventh Rename Slice

Applied seventh:

```text
Native/Ambitions/Core/LocalRuntimeOS/SearchRecall/
Native/AmbitionsTests/LocalRuntimeOS/SearchRecall/
```

to:

```text
Native/Ambitions/Core/LocalRuntimeOS/Search/
Native/AmbitionsTests/LocalRuntimeOS/Search/
```

Reason:

- `Search` is explicitly named by AMB-1669 target direction.
- The old owner paired search with recall as folder-level lore; retained Swift
  types such as `LocalSearchIndex`, `FTSIndex`, `MemoryLensService`, and
  `FindActInspectResult` already carry the concrete behavior plainly.
- The move changes canonical ownership without changing runtime behavior.
- Owner-facing API types now use `Search*` names instead of `SearchRecall*`
  names, and receipt/schema strings use `search` instead of `search_recall`.
- The ownership test now proves required `Search` files exist and the old
  `SearchRecall` production/test owner paths are gone.

## Eighth Rename Slice

Applied eighth:

```text
Native/Ambitions/Core/LocalRuntimeOS/MigrationRepair/
Native/AmbitionsTests/LocalRuntimeOS/MigrationRepair/
```

to:

```text
Native/Ambitions/Core/LocalRuntimeOS/Repair/
Native/AmbitionsTests/LocalRuntimeOS/Repair/
```

Reason:

- `Repair` is explicitly named by AMB-1669 target direction and AMB-1670's
  retained-owner test scope.
- The old owner paired migration and repair as a folder-level name; retained
  Swift types such as `MigrationDSL`, `MigrationPlanner`, `RuntimeDoctor`,
  `RepairPlanEngine`, and `RestoreRollback` already carry the concrete
  behavior plainly.
- The move changes canonical ownership without changing runtime behavior.
- Owner-facing repair proof API types now use `RepairProof*` names instead of
  `MigrationRepairProof*` names, and the DSL schema string uses `repair_dsl`
  instead of `migration_repair_dsl`.
- The ownership test now proves required `Repair` files exist and the old
  `MigrationRepair` production/test owner paths are gone.
- The slice also splits the touched `RuntimeDoctorRepairOperator.swift` type
  cluster into descriptive owner-local files, so the moved owner does not leave
  a diff-scoped Swift file above the 600-line remediation cap.

## Ninth Rename Slice

Applied ninth:

```text
Native/Ambitions/Core/LocalRuntimeOS/ObjectState/
Native/AmbitionsTests/LocalRuntimeOS/ObjectState/
```

to:

```text
Native/Ambitions/Core/LocalRuntimeOS/State/
Native/AmbitionsTests/LocalRuntimeOS/State/
```

Reason:

- `State` is explicitly named by AMB-1669 target direction.
- The old owner used `ObjectState` as a folder-level architecture name; retained
  Swift types such as `ObjectStateFamily`, `ObjectStateRegistry`, and
  `ObjectStateWriteReceipt` still carry the concrete behavior contract plainly.
- The move changes canonical ownership without changing runtime behavior.
- The ownership test now proves required `State` files exist and the old
  `ObjectState` production/test owner paths are gone.

## Tenth Rename Slice

Applied tenth:

```text
Native/Ambitions/Core/LocalRuntimeOS/PlanningEngine/
Native/AmbitionsTests/LocalRuntimeOS/PlanningEngine/
```

to:

```text
Native/Ambitions/Core/LocalRuntimeOS/Planning/
Native/AmbitionsTests/LocalRuntimeOS/Planning/
```

Reason:

- `Planning` is explicitly named by AMB-1669 target direction.
- The old owner used `PlanningEngine` as a folder-level architecture name;
  retained Swift types such as `GoalPathPlanner`, `PlanRepairEngine`,
  `SmallerStepEngine`, `StepElasticityEngine`, and `StepGraphCompiler` still
  carry concrete behavior contracts plainly.
- The move changes canonical ownership without changing runtime behavior.
- Owner-facing runtime trace API now uses `PlanningRuntimeTrace` instead of
  `PlanningEngineRuntimeTrace`.
- The touched `+02` / `+03` / `+04` split filenames in this owner were renamed
  to descriptive owner-local filenames in the same slice to comply with the
  AMB-1658 remediation freeze.
- The ownership test now proves required `Planning` files exist and the old
  `PlanningEngine` production/test owner paths are gone.

## API Exposure

The moved `Boundary`, `Commands`, `Transactions`, `Projections`, `ExternalWrites`, `Inspection`, `Search`, `Repair`, `State`, and `Planning` source contains no `public` or `open` Swift API declarations.

Current exposure is same-module production/test use through Swift files under the existing `Ambitions` target and `AmbitionsTests` target. XcodeGen source discovery is directory-based through `project.yml`, so the move requires project regeneration but no package or target boundary change.

Known direct consumers of the moved `Boundary`, `Commands`, `Transactions`,
`Projections`, `ExternalWrites`, `Inspection`, `Search`, `Repair`, `State`, and
`Planning` types remain same-module:

- `Commands`
- `Transactions`
- `Projections`
- `ExternalWrites`
- `Inspection`
- `Search`
- `Repair`
- `State`
- `Planning`
- `PrivateLifeRuntimeKernel`
- `Scheduling`
- `PrivacySecurity`
- `SourceAtlas`
- runtime/domain tests

## Proof Ceiling

This slice can support Source Green for the folder-owner rename if validation passes. It does not claim:

- full AMB-1669 completion
- all LocalRuntimeOS names simplified
- AMB-1670 ownership-test completion
- app-wide runtime completion
- Visual Green
- Release Green
- device proof
- accessibility proof
- privacy/legal approval
- TestFlight or App Store readiness
- production R2 or CloudKit readiness

## Next Rename Candidates

Next concrete candidates, one at a time after guards:

- `CaptureRouteGraph` -> `CaptureRouting`
- `SyncContinuity` -> `Continuity`

`EventJournal`, `PrivateLifeRuntimeKernel`, `SourceAtlas`, and `PrivacySecurity`
require retain/collapse decision records before source moves. Each future slice
must update tests, current truth/proof references, and the LocalRuntimeProof
owner list before closeout.
