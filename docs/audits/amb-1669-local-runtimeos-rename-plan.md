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

This artifact records the current folder/type dependency graph, target runtime map, API exposure posture, and first rename slice.

## Current Owner Graph

Current source owner count after the first slice: 19.

| Current owner | Swift files | Target owner | Status |
| --- | ---: | --- | --- |
| Boundary | 18 | Boundary | First slice renamed from `RuntimeBoundary` |
| CommandSpine | 25 | Commands or CommandPipeline | Pending |
| TransactionKernel | 12 | Transactions | Pending |
| EventJournal | 10 | Events or EventJournal | Pending |
| ObjectState | 4 | State | Pending |
| ProjectionEngine | 32 | Projections | Pending |
| PrivateLifeRuntimeKernel | 37 | RuntimeKernel or collapsed into retained owners | Pending decision |
| PlanningEngine | 68 | Planning | Pending |
| TimeEngine | 35 | Scheduling | Pending |
| CaptureRouteGraph | 20 | CaptureRouting | Pending |
| TrustSystem | 29 | Inspection/Receipts | Pending |
| SearchRecall | 10 | Search | Pending |
| SideEffectSystem | 13 | ExternalWrites/Outbox | Pending |
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

## API Exposure

The moved `Boundary` source contains no `public` or `open` Swift API declarations.

Current exposure is same-module production/test use through Swift files under the existing `Ambitions` target and `AmbitionsTests` target. XcodeGen source discovery is directory-based through `project.yml`, so the move requires project regeneration but no package or target boundary change.

Known direct consumers of the moved types remain same-module:

- `CommandSpine`
- `TransactionKernel`
- `ProjectionEngine`
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

1. `CommandSpine` -> `Commands` or `CommandPipeline`
2. `TransactionKernel` -> `Transactions`
3. `ProjectionEngine` -> `Projections`
4. `SideEffectSystem` -> `ExternalWrites` or `Outbox`
5. `TrustSystem` -> `Inspection` or `Receipts`
6. `SearchRecall` -> `Search`
7. `MigrationRepair` -> `Repair`

Each next slice must update tests, current truth/proof references, and the LocalRuntimeProof owner list before closeout.
