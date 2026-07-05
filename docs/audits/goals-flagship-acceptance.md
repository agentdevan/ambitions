# AMB-1738 Goals Flagship Acceptance

Status: Implemented Yellow / source acceptance
Date: 2026-07-05
Scope: AMB-1738
Baseline SHA: `eb3f64d7bb8d42b9aa45f34850fe6b274bb77ad2`

## Purpose

AMB-1738 accepts the current Goals flagship surface only at the source and
projection layer. It verifies that Goals has a real local Constellation Atlas
root, life-area detail, goal detail, create/edit path, Today linkage,
proof/history inspection, local mutation, and degraded-state routes.

This packet does not claim rendered product acceptance, screenshot proof,
accessibility proof, simulator proof, physical-device proof, Visual Green,
Runtime Green, Release Green, or full UI journey proof.

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
- Linear AMB-1738 state
- Current Goals source under `Native/Ambitions/Surfaces/Goals`
- Current Goals product objects under
  `Native/Ambitions/DesignSystem/ProductObjects/Goal*`
- Current local runtime goal, proof, receipt, and persistence source under
  `Native/Ambitions/Core/LocalRuntimeOS`

## Source Acceptance Map

| AMB-1738 criterion | Current source evidence | Status |
| --- | --- | --- |
| Goals root / Constellation Atlas | `GoalsSurface` loads `GoalsObjectView`; `GoalsObjectView` renders `LifeAreaAtlasField` with "Constellation Atlas", life-area nodes, and a central Start here object. | Source present |
| Understandable goal IA without internal jargon | `GoalsObjectView`, `GoalsOverviewProjector`, `GoalsLifeAreaAtlasModels`, and `GoalsAccessibility` present life areas, active direction, pressure points, recent movement, one-step goals, archive, and proof/history as user-facing objects. | Source present |
| Life area detail | `AreaDetailScreen` loads the same Goals overview, opens goal detail for area goals, and routes area-scoped Goal, Step, Thought, and Proof capture. | Source present |
| Goal detail | `GoalDetailScreen`, `GoalDetailPathJournalSurfaces`, `GoalDetailBreadcrumbSurface`, `GoalTrustWhisperSurface`, and `GoalDetailProofRailSurface` expose object identity, path, journal, operations, clarification, blockers, suggestions, trust, proof, decisions, risks, receipts, and archive. | Source present |
| Goal creation/editing local mutation | `CreateGoalScreen`, `CreateGoalViewModel`, `RepositoryBackedGoalsService.createGoal`, `prepareGoalCreation`, `saveGoalCreation`, and `GoalCreationUnitOfWorkPayload` route creation through local repositories and optional unit-of-work receipts. | Source present |
| Detail action local mutation | `GoalDetailViewModel.perform`, `RepositoryBackedGoalsService.performAction`, and `performMutation` write feedback, evidence, goal timing, step state, priority, relevance, and recovery changes through local repositories. | Source present |
| Today linkage | `GoalsOverviewProjector`, `GoalsStageScene`, `GoalDetailMissionControlState`, and the Constellation Atlas copy keep life-area, goal thread, step chain, and Today link attached to Goals. | Source present |
| Proof/history inspection details | `GoalDetailProofRailSurface`, `GoalDetailReceiptsSurface`, `GoalDetailReviewTrailState`, `GoalDetailJournalSurface`, and proof/history rows keep evidence, decisions, assumptions, receipts, and archive as inspection details. | Source present |
| Empty, loading, and error states | `GoalsViewModel`, `GoalDetailViewModel`, `CreateGoalViewModel`, `AsyncViewState`, `DegradedStateSurface`, `GoalsOverview.emptyTitle`, and create preview/submission failure states cover empty/loading/error presentation. | Source present |
| Offline/no-account behavior | Goals source reads local goals, drafts, evidence, feedback, captures, and app state through `RepositoryBackedGoalsService.loadSnapshot()`; no account gate appears in the Goals load/create/detail path. Airplane-mode runtime proof was not run. | Source local-only; runtime proof absent |
| Archived/completed states | `GoalPortfolioLifecycleState`, `GoalDetailArchiveSurface`, `GoalsOverviewProjector.lowerPriority`, archive learning lines, and proof/history projections preserve completed, cancelled, parked, previous, future, and archive states. | Source present |
| Closure/control language | This slice normalizes visible Goals labels to sentence case for create flow, suggestion section, and atlas posture labels. | Source repaired |

## Source Changes In This Slice

The source edit is intentionally narrow:

- `Create Goal` -> `Create goal`
- `Creating Goal...` -> `Creating goal...`
- `Save Draft` -> `Save draft`
- `Saving Draft...` -> `Saving draft...`
- `Suggested Steps` -> `Suggested steps`
- `At Risk` -> `At risk`
- `Lower Priority` -> `Lower priority`

Touched source paths:

- `Native/Ambitions/Surfaces/Goals/CreateGoalScreen.swift`
- `Native/Ambitions/Surfaces/Goals/CreateGoalScreen+04-heroTitle.swift`
- `Native/Ambitions/Surfaces/Goals/GoalDetailScreen.swift`
- `Native/Ambitions/Surfaces/Goals/Projection/GoalsFeatureModels.swift`

No route, persistence, command, projection ownership, runtime authority, model
case, or repository behavior was changed.

## Proof Ceiling

Claim status: Implemented Yellow.

Allowed claim:

- Goals has current source and projection evidence for a local Constellation
  Atlas surface with life-area detail, goal detail, local create/edit/detail
  mutation paths, Today linkage, proof/history inspection, degraded states, and
  sentence-case visible labels in this slice.

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
- Airplane-mode proof.

## Architecture Closeout

- `Final Architecture Tree` inspected: yes.
- Canonical owners touched: `Surfaces/Goals`.
- Non-canonical owners touched: none.
- Files moved or created: this audit packet only.
- Old or non-canonical paths removed: none.
- Compatibility shims left behind: none.
- Architecture debt: no new architecture debt introduced; screenshot,
  accessibility, device, and full UI journey proof remain outside this
  no-testing source acceptance.
- Next repair train if debt remains: AMB-1744/AMB-1765 for screenshot/device
  proof and AMB-1743/AMB-1766 for accessibility proof.
- No equivalent folder or path interpretation was used.

## Private Life Orchestration Relationship

This work protects:

```text
Intent -> Context -> Path -> Time Fit -> Reflow -> Action -> Proof -> Learning
```

Goals now has source-level evidence for intent entering through Capture or
create flow, context through life areas and local graph state, path through
deterministic local planning, Today fit through linked step projection, reflow
through detail actions and adaptive recommendations, action through Start here
and detail operations, proof through local evidence/receipts, and learning
through feedback/history/archive surfaces.

## Validation Boundary

No xcodebuild, XCTest, UI test, simulator run, screenshot capture, accessibility
proof, airplane-mode walkthrough, or device proof was run under the current
no-testing authorization. Static validation commands are recorded in the
companion JSON packet and Linear closeout.
