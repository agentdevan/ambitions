# AMB-1737 Today Flagship Acceptance

Status: Implemented Yellow / source acceptance
Date: 2026-07-05
Scope: AMB-1737
Baseline SHA: `61f43c345a1471deda275efc2c0e9d270f4e3a8d`

## Purpose

AMB-1737 accepts the current Today flagship surface only at the source and
projection layer. It verifies that Today has a real local source path, a
dominant Reality Meridian / Start here object, capacity/reflow state, Capture
pressure, proof/receipt inspection, and closure/recovery routes.

This packet does not claim rendered product acceptance, screenshot proof,
accessibility proof, simulator proof, physical-device proof, Visual Green,
Runtime Green, Release Green, or AMB-1479 closure.

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
- Linear AMB-1737, AMB-1751, AMB-1776, and AMB-1479 state
- Current Today source under `Native/Ambitions/Surfaces/Today`
- Current Today product objects under
  `Native/Ambitions/DesignSystem/ProductObjects/Today*`
- Current receipt/proof source under
  `Native/Ambitions/Core/LocalRuntimeOS/Inspection`

## Source Acceptance Map

| AMB-1737 criterion | Current source evidence | Status |
| --- | --- | --- |
| Today root / Reality Meridian | `TodaySurface` renders `TodayObjectView`, which renders `RealityMeridianView`; `DayRailViewState.contract` names `Reality Meridian / Start Here`. | Source present |
| Start Here / primary next action | `StartHereSurface` owns Start here, primary action button, `Open step`, `Start now`, proof caption, source summary, and trust details. | Source present |
| Useful without account sign-in | `RepositoryBackedTodayService.loadSnapshot()` reads local goals, drafts, evidence, captures, event ledger, and app state repositories; no account gate appears in Today load path. | Source present |
| Captured items surface in intake/review lane | `TodayReadModelProjector` includes captures in reality, believability, Canonical Now State, Capture urgency, and One-Step Goals projection; `capturePanel` opens Capture. | Source present |
| Capacity/reflow feedback without calendar-clone UI | `CanonicalNowStateProjector`, `ExecutionResilienceProjector`, `todayTimeLayer`, `frictionSignal`, `recoveryFallbackEntry`, `saveTheDayAction`, and `dayRailMode` project pressure/recovery states into Today. | Source present |
| Proof/receipt inspection details | `StartHereSurface` exposes `Why this?` and `Trust details`; `DayRailProofSlotState`, `TodayActionClosureSheet`, `TodayReceiptCommandService`, and `ActionReceiptProofLedgerEntry` preserve receipt/proof paths. | Source present |
| Empty state | `TodayExecutionProjector.emptyGuidance`, `DayRailEmptySurface`, and `TodayExperienceMode.empty` provide empty guidance and no-fake-certainty copy. | Source present |
| Loading and error states | `TodayViewModel.state` uses `AsyncViewState.loading`, `.loaded`, and `.failed`; `refresh` writes `Unable to load Today` on failure. | Source present |
| Offline/degraded state | `sourceFreshness` can project `.offline`, `.localOnly`, `.denied`, `.blocked`, and `.unavailable`; Today copy keeps recovery local and source reviewable. | Source present |
| Completed-day state | Today derives completed proof from evidence and local receipt history, and `TodayStageScene` exposes completed proof state from `dayRail.proofSlot`. | Source present |
| Closure/control language | This slice normalizes visible `Still counts` and `Not needed` capitalization across Today receipt/closure presentation. | Source repaired |

## Source Changes In This Slice

The source edit is intentionally narrow:

- `Still Counts` -> `Still counts`
- `Not Needed` -> `Not needed`

Touched source paths:

- `Native/Ambitions/Surfaces/Today/Projection/TodayExecutionProjector+02-TodayExecutionProjector+Projector02-contractEntries.swift`
- `Native/Ambitions/Surfaces/Today/Projection/TodayExecutionCompatibility.swift`
- `Native/Ambitions/Surfaces/Today/Projection/TodayFeatureService+02-RepositoryBackedTodayService+Repository03-openWindows.swift`
- `Native/Ambitions/Core/LocalRuntimeOS/Inspection/ActionReceiptClosureStateProjection.swift`
- `Native/Ambitions/Core/LocalRuntimeOS/Inspection/ActionReceiptProofLedgerModels.swift`

No route, persistence, command, projection ownership, or runtime authority was
changed.

## Proof Ceiling

Claim status: Implemented Yellow.

Allowed claim:

- Today has current source and projection evidence for a local, accountless
  Reality Meridian / Start here surface with capacity/reflow, Capture pressure,
  proof/receipt inspection, empty/loading/error/degraded states, and closure
  language aligned to current product law.

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
- Simulator/device proof.
- AMB-1479 visual specification authority closure.

## Architecture Closeout

- `Final Architecture Tree` inspected: yes.
- Canonical owners touched: `Surfaces/Today` and
  `Core/LocalRuntimeOS/Inspection`.
- Non-canonical owners touched: none.
- Files moved or created: this audit packet only.
- Old or non-canonical paths removed: none.
- Compatibility shims left behind: none.
- Architecture debt: no new architecture debt introduced; existing AMB-1479
  visual-spec authority blocker remains external to this source acceptance.
- Next repair train if debt remains: AMB-1479 for visual-spec authority and
  AMB-1744/AMB-1765 for screenshot/device proof.
- No equivalent folder or path interpretation was used.

## Private Life Orchestration Relationship

This work protects:

```text
Intent -> Context -> Path -> Time Fit -> Reflow -> Action -> Proof -> Learning
```

Today now has source-level evidence for intent and context entering from local
captures/goals/evidence, path and time fit from the Reality Meridian projection,
reflow and recovery from resilience projection, action from Start here, proof
from local receipts, and learning from rejection/closure feedback.

## Validation Boundary

No xcodebuild, XCTest, UI test, simulator run, screenshot capture, accessibility
proof, or device proof was run under the current no-testing authorization.
Static validation commands are recorded in the companion JSON packet and Linear
closeout.
