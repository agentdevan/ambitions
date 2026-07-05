# AMB-1739 Time Flagship Acceptance

Status: Implemented Yellow / source acceptance
Date: 2026-07-05
Scope: AMB-1739
Baseline SHA: `73375fc0ada94b28e24f21a5483ea52295aeb399`

## Purpose

AMB-1739 accepts the current Time flagship surface only at the source and
projection layer. It verifies that Time has a real local LifeShape Field root,
constraint and pressure projection, protected-placement review, reflow detail,
Today recompute source paths, optional calendar awareness, and external
adapter/outbox boundaries.

This packet does not claim rendered product acceptance, screenshot proof,
accessibility proof, simulator proof, physical-device proof, calendar permission
journey proof, Visual Green, Runtime Green, Release Green, or full UI journey
proof.

## Truth And Source Inputs

- `AGENTS.md`
- `docs/truth/CODEX_START_HERE.md`
- `docs/truth/PRODUCT_DESIGN_TRUTH.md`
- `docs/truth/PRODUCT_EXPERIENCE_CANON.md`
- `docs/truth/IMPLEMENTATION_ACCEPTANCE_TRUTH.md`
- `docs/truth/RELEASE_TRUTH.md`
- `.agents/skills/ambitions-source-truth-authority/SKILL.md`
- `.agents/skills/ambitions-architecture-tree-enforcement/SKILL.md`
- `.agents/skills/ambitions-ios-quality-gate/SKILL.md`
- `.agents/skills/ambitions-release-proof-honesty/SKILL.md`
- `.agents/skills/ambitions-runtime-contract-engineering/SKILL.md`
- Linear AMB-1739 state
- Current Time source under `Native/Ambitions/Surfaces/Time`
- Current LifeShape Field product objects under
  `Native/Ambitions/DesignSystem/ProductObjects/LifeShape*`
- Current mutation projection source under `Native/Ambitions/Projection/Mutations`
- Current local runtime scheduling, command, and outbox source under
  `Native/Ambitions/Core/LocalRuntimeOS`

## Source Acceptance Map

| AMB-1739 criterion | Current source evidence | Status |
| --- | --- | --- |
| Time root / LifeShape Field | `TimeSurface` loads `TimeObjectView`; `TimeObjectView` renders `LifeShapeFieldView`; `TimeStageScene` requires product object `LifeShape Field` with capacity, protected windows, pressure, horizons, and Capture order. | Source present |
| Constraint and pressure language | `TimeLifeShapeFieldProjection`, `TimePressureProjection`, `TimeTreatyCapacityProjection`, `TimeCapacityReviewState`, and `LifeShapeFieldCapacity` project qualitative capacity, pressure, protected time, recovery, and source state without a calendar-clone UI. | Source present |
| Time edit mutation path | `TimeViewModel.performLifeShapeMutation`, `TimeFieldMutationCoordinator`, `TimeMutation`, `RuntimeMutation`, and `TimeFieldMutationStateProjection` route LifeShape Field edits through visible local mutation, proof, receipt, announcement, Today recompute, and undo policy. | Source present |
| Protected placement review | `ProtectedPlacementReviewCard`, `ProtectedPlacementReviewState`, `ProtectedStepPlacementPolicy`, and `PriorityPlacementPolicy` require review before moving a Step into protected time and expose Keep as is / Move it choices. | Source present |
| Reflow detail connects back to Today | `TimeRealityReflowProjection`, `TimeReflowDecisionProjector`, `TimeReflowDecisionState`, and `TimeFieldMutationStateProjection` expose reflow reasons, suggestions, confirmation boundaries, and Today recompute text. | Source present |
| Calendar/reminder/outbox boundary where present | `RepositoryBackedTimeService.makeTimeCalendarAware`, `TimeCalendarAwarenessSupport`, `TimeCalendarRecoveryProjection`, `AmbitionsCommandExecutor+CalendarWriteIntent`, and `EventKitOutbox` keep calendar reads optional, writes confirmed/local first, and external effects recorded through outbox/receipt boundaries. | Source present |
| Empty, loading, error, offline, and no-permission states | `TimeViewModel`, `TimeSurface`, `AsyncViewState`, `DegradedStateSurface`, `TimeSurfaceMode.empty`, `TimeCalendarAwarenessStatus.denied`, `TimeCalendarAwarenessStatus.unavailable`, and manual Time source copy cover degraded source states. Calendar permission and airplane-mode runtime proof were not run. | Source present; runtime proof absent |
| Accessibility source support | `TimeAccessibility`, `TimeStageScene`, `LifeShapeFieldVisualField`, `LifeShapeFieldView`, and list-row fallbacks expose accessibility labels, values, large-text rows, and reduced-motion render-state hooks at source level. | Source present; accessibility proof absent |
| Closure/control language | This slice normalizes visible Time labels toward LifeShape Field language and removes banned list-value wording from Time list rows. | Source repaired |

## Source Changes In This Slice

The source edit is intentionally narrow:

- Time accessibility loading/failure copy now says `LifeShape Field`.
- Time root accessibility summary now says `LifeShape Field`.
- LifeShape visual field labels now say `LifeShape Field` and `Time field`.
- Time list rows now use `Accessible` and `Time signals`.
- Time contract drill-down copy now says `Calendar awareness`.

Touched source paths:

- `Native/Ambitions/Surfaces/Time/TimeViewModel.swift`
- `Native/Ambitions/Surfaces/Time/TimeAccessibility.swift`
- `Native/Ambitions/DesignSystem/ProductObjects/LifeShapeFieldVisualField.swift`
- `Native/Ambitions/Surfaces/Time/Projection/TimeLifeShapeFieldProjection.swift`
- `Native/Ambitions/Surfaces/Time/Projection/TimeLifeSuiteState.swift`
- `Native/Ambitions/Surfaces/Time/TimeSurfaceContractSnapshot.swift`
- `Native/Ambitions/Projection/Mutations/TimeFieldMutationStateProjection.swift`

No route, persistence, command, projection ownership, runtime authority, model
case, repository behavior, external adapter behavior, or outbox behavior was
changed.

## Proof Ceiling

Claim status: Implemented Yellow.

Allowed claim:

- Time has current source and projection evidence for a local LifeShape Field
  surface with pressure/constraint projection, protected-placement review,
  local mutation/reflow/undo paths, Today recompute text, optional calendar
  awareness, and external adapter/outbox boundaries.

Forbidden claims from this packet:

- Visual Green.
- Runtime Green.
- Interaction Green.
- Release Green.
- Screenshot proof.
- Focused UI journey test proof.
- VoiceOver proof.
- Dynamic Type proof.
- Reduce Motion proof.
- Reduce Transparency proof.
- High Contrast proof.
- Calendar permission journey proof.
- Airplane-mode proof.
- Simulator/device proof.

## Architecture Closeout

- `Final Architecture Tree` inspected: yes.
- Canonical owners touched: `Surfaces/Time`, `DesignSystem/ProductObjects`,
  and `Projection/Mutations`.
- Non-canonical owners touched: none.
- Files moved or created: this audit packet only.
- Old or non-canonical paths removed: none.
- Compatibility shims left behind: none.
- Architecture debt: no new architecture debt introduced; screenshot,
  accessibility, device, calendar permission, airplane-mode, and full UI
  journey proof remain outside this no-testing source acceptance.
- Next repair train if debt remains: AMB-1744/AMB-1765 for screenshot/device
  proof and AMB-1743/AMB-1766 for accessibility proof.
- No equivalent folder or path interpretation was used.

## Private Life Orchestration Relationship

This work protects:

```text
Intent -> Context -> Path -> Time Fit -> Reflow -> Action -> Proof -> Learning
```

Time now has source-level evidence for context from local goals, captures,
evidence, and feedback; Time Fit from LifeShape Field capacity and pressure;
Reflow from reality-change suggestions and protected placement review; Action
from visible LifeShape Field mutation controls; Proof from local receipts and
mutation proof artifacts; and Learning from feedback/history inputs that shape
future Time projections.

## Validation Boundary

No xcodebuild, XCTest, UI test, simulator run, screenshot capture,
accessibility proof, calendar permission walkthrough, airplane-mode walkthrough,
or device proof was run under the current no-testing authorization. Static
validation commands are recorded in the companion JSON packet and Linear
closeout.
