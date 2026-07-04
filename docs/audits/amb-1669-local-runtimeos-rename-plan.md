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

Current source owner count after the `ExternalWrites` slice: 19.

| Current owner | Swift files | Target owner | Status |
| --- | ---: | --- | --- |
| Boundary | 18 | Boundary | First slice renamed from `RuntimeBoundary` |
| Commands | 25 | Commands | Second slice renamed from `CommandSpine` |
| Transactions | 12 | Transactions | Third slice renamed from `TransactionKernel` |
| EventJournal | 10 | Events or EventJournal | Pending |
| ObjectState | 4 | State | Pending |
| Projections | 32 | Projections | Fourth slice renamed from `ProjectionEngine` |
| PrivateLifeRuntimeKernel | 37 | RuntimeKernel or collapsed into retained owners | Pending decision |
| PlanningEngine | 68 | Planning | Pending |
| TimeEngine | 35 | Scheduling | Pending |
| CaptureRouteGraph | 20 | CaptureRouting | Pending |
| TrustSystem | 29 | Inspection/Receipts | Pending |
| SearchRecall | 10 | Search | Pending |
| ExternalWrites | 13 | ExternalWrites | Fifth slice renamed from `SideEffectSystem` |
| SyncContinuity | 10 | Continuity | Pending |
| SourceAtlas | 80 | SourceAtlas or ReferencePacks | Pending decision |
| PrivacySecurity | 12 | Boundary or Privacy | Pending decision |
| Storage | 27 | Storage | Retain name |
| MigrationRepair | 17 | Repair | Pending |
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

## API Exposure

The moved `Boundary`, `Commands`, `Transactions`, `Projections`, and `ExternalWrites` source contains no `public` or `open` Swift API declarations.

Current exposure is same-module production/test use through Swift files under the existing `Ambitions` target and `AmbitionsTests` target. XcodeGen source discovery is directory-based through `project.yml`, so the move requires project regeneration but no package or target boundary change.

Known direct consumers of the moved `Boundary`, `Commands`, `Transactions`,
`Projections`, and `ExternalWrites` types remain same-module:

- `Commands`
- `Transactions`
- `Projections`
- `ExternalWrites`
- `PrivateLifeRuntimeKernel`
- `PlanningEngine`
- `TimeEngine`
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

Proceed one compartment at a time after guards pass:

1. `TrustSystem` -> `Inspection` or `Receipts`
2. `SearchRecall` -> `Search`
3. `MigrationRepair` -> `Repair`

Each next slice must update tests, current truth/proof references, and the LocalRuntimeProof owner list before closeout.
