# Ambitions 2.0 Roadmap

This roadmap now runs through Ambitions 2.0 RC maturity instead of stopping at v1 foundations. [Ambitions_2_0_RC_Maturity_Plan.md](Ambitions_2_0_RC_Maturity_Plan.md) is the canon control doc for maturity gates, RC milestones, dependency mapping, batch size ceilings, performance strategy, concrete acceptance criteria, and mature-invention coverage.

[design/Ambitions_Design_Constitution.md](design/Ambitions_Design_Constitution.md) is the active design source of truth for IA, UX writing, component naming, interaction, trust, accessibility, and external-surface contracts. Future roadmap work must reconcile against it before implementation.

[Ambitions_2_0_Roadmap_Merge_Audit.md](Ambitions_2_0_Roadmap_Merge_Audit.md) is the active merge map between original Batches 89-120 and the newer D01-D26 Design Constitution delta/alignment backlog. D01-D26 take precedence over Batches 89-120 wherever there is any conflict.

[ROADMAP_BATCH_CLASSIFICATION.md](ROADMAP_BATCH_CLASSIFICATION.md) is the active launch-classification layer for D01-D26. It distinguishes launch-critical, soon-after-launch, post-launch, deferred, decision-gated, and infrastructure-unlock work. Any future roadmap interpretation must preserve that classification unless a later explicit canon decision supersedes it.

[Ambitions_2_0_Object_Terminology.md](Ambitions_2_0_Object_Terminology.md) is the active shared terminology source for Life Area, Ambition, North Star, Goal, Path, Plan, Milestone, Step, Task / One-Step Goal, Proof, Receipt, Review, Archive, Ritual, Waiting, Decision, and Memory / What Ambitions Knows.

## Launch Cutline

First launch should prove the Golden Launch Loop, not the entire life operating system.

Launch proof:

```text
A meaningful goal can become organized, doable, and actionable today.
```

Launch-critical work must map to at least one step:

```text
1. Capture one meaningful goal or task.
2. Put it in the right place.
3. Turn it into a doable plan.
4. Show what to do today.
5. When today is too much, make it doable.
6. Save proof that progress happened.
```

Do not treat widgets, Live Activities, sync, advanced memory, advanced reviews, semantic zoom, North Stars, full personalization, or full App Intents / Shortcuts maturity as first-launch requirements unless a later explicit decision proves they are required for the Golden Launch Loop.

## Shippable Milestones

These milestones describe the Ambitions 2.0 maturity arc. They are not all first-launch scope.

- Milestone A - Ambitions 2.0 Alpha: prove the daily operating loop across Today, Global Chrome, Activation Contract, Life Graph foundation, Proof / Resource foundation, Commitments / Waiting, Action Closure v1, Goals/Goal Detail proof loop v1, Plan believability/Reflow v1, and daily-loop performance baseline. Launch-critical work inside this milestone must follow [ROADMAP_BATCH_CLASSIFICATION.md](ROADMAP_BATCH_CLASSIFICATION.md).
- Milestone B - Ambitions 2.0 Beta: prove cross-surface continuity and trust through You Trust Center, Constitution, Reviews / Life OS Receipt, export/import proof, Apple-first sync/conflict policy, App Intent receipts, widgets/Live Activity continuity, external platform verification, and scenario validation. Most external-surface and sync work is post-launch/deferred unless required by the Golden Launch Loop.
- Milestone C - Ambitions 2.0 RC1: mature the strategic system through Path Intelligence, Domain Path Packs, Path Fork Simulator, Path Builder v1, learning/correction, Memory Confidence, Narrative Memory Map, mature Reality Reflow, mature Goal Portfolio, and strategy/learning performance proof. This is maturity scope, not first-launch proof.
- Milestone D - Ambitions 2.0 RC2: mature all inventions and harden release through mature audits, onboarding/re-entry, Accessibility Nutrition verification, Appearance Studio/shell regression, data safety, performance, RC audit, and release-candidate lock.

## Goal / Plan / Task Visual Systems Integration

The Goal / Plan / Task visual systems are newly integrated planned canon. They do not change current implementation status until their owning batches run.

Ambitions must be a beautiful, visual, low-stress representation of a person's goals, plans, and tasks. A goal shows the desired direction. A plan shows the path that can actually hold. A task shows the next visible action. Proof shows the goal becoming real. The user should never have to mentally translate a giant task list into a life direction.

Integrated systems:

- Goal Lifecycle Rail: Goals overview timeline and lifecycle states including Previous, Active, Future, Parked, Blocked, Waiting, Completed, and Cancelled / Dropped. User-facing copy should not use `Protected` for normal priority/status language.
- Goal Atlas: visual map of related life goals; preview in Goals, connected goals in Goal Detail, full map in Path Builder, mature portfolio map in Batch 107.
- Proof Spine: vertical Goal Detail expression of Proof Rail.
- Next Visible Step: one visually obvious next action for every active goal, selected by Goals/Goal Detail/Plan and consumed by Today/widgets.
- Goal Weather: user-facing visual language for goal health with Clear, Cloudy, Stormy, Foggy, and privacy/security-only protected states. Normal goal priority should use plain copy such as `Most important goal`.
- Decision Trail: human-readable record of goal and plan changes, including pause, resume, cancel, complete, merge, replace, and scope decisions.
- Timeline View: compact and detailed goal/milestone/task timeline context.
- Milestone Cards: meaningful goal checkpoints that prevent endless task-list presentation.
- Kanban-lite Task Lane: Goal Detail-only task board with Later, Next, Doing, Waiting, and Done.
- Weekly Plan Strip: seven-day plan visualization connecting active goals to this week.
- Completion Archive: premium archive for completed, cancelled, dropped, parked, merged, and transformed goals as learning artifacts.

## Design Constitution Implementation Track

The design constitution reconciliation is canon/documentation integration, not proof that all surfaces are implemented. Future implementation batches must consume the new contracts without falsely claiming completion.

Future implementation ownership:

- Life Areas Overview / Life Areas Atlas: Goals, You, Path Builder, and Portfolio maturity batches. First-launch can use simpler area labels before the full Atlas ships.
- North Stars: Goals, Life Areas, Path Intelligence, and Portfolio maturity batches. Post-launch unless required by a later explicit decision.
- One-Step Goals: Capture, Today, Goals, Goal Detail, Plan, Reviews, and mature portfolio/recovery batches. Launch-critical because standalone one-step work supports Capture and Today.
- Smart Attachment: Capture 2.0 hardening, Command Pipeline, receipts, and correction/memory batches. Launch-critical for Capture/place/routing.
- You Personal System Center: You, Trust Center, What Ambitions Knows, Reviews, Accessibility, Sync / Export, Appearance, Notifications, and Settings batches. Baseline trust is launch-critical; full system-center depth is soon-after-launch.
- GroupedNavigationList: You, Trust Center, Memory, Settings, Goal Detail depth, and Plan controls. Infrastructure/surface depth, not first proof by itself.
- Panel Size + Display Density: rich panel system, Appearance Studio, accessibility verification, and visual polish batches. Soon-after-launch unless needed for accessibility verification.
- Screen Contract Matrix implementation: core surface integration QA and surface maturity batches. Infrastructure-unlock for launch-critical surfaces.
- Component Contract Matrix implementation: rich panel, global chrome, trust, review, and external-surface batches.
- Trust Center / What Ambitions Knows: You, memory confidence, correction, sync/export, and receipt maturity batches. Baseline trust/memory visibility is launch-critical if memory is visible or used.
- External surface contracts: App Intents, widgets, Live Activities, notifications, Shortcuts, and external verification batches. Mostly post-launch/deferred unless scoped to safe capture/open routes.
- Accessibility Nutrition verification: verified accessibility work only; launch-critical for user-visible core surfaces.

## Design Constitution Coverage Verification

This roadmap explicitly carries the Design Constitution forward as planned implementation work. None of these rows claim shipped behavior unless a later batch records validation evidence.

| Constitution area | Roadmap coverage | Required implementation posture |
| --- | --- | --- |
| Life Areas Overview / Life Areas Atlas | Goals, You, Path Builder, Portfolio maturity | Planned; full Atlas is soon-after-launch unless simplified area routing is enough for launch. |
| North Stars / dormant Ambitions | Goals, Life Areas, Path Intelligence, Portfolio maturity | Post-launch/deferred; dormant ambition semantics must precede surface polish. |
| One-Step Goals | Capture, Today, Goals, Goal Detail, Plan, Reviews, Recovery | Launch-critical; do not create a Tasks tab. |
| Task = standalone One-Step Goal | Object model and One-Step Goals batches | Launch-critical terminology/model rule. |
| Step = contained plan/path/goal action | Object model, Goal Detail, Plan, Path Builder | Launch-critical terminology/model rule. |
| Smart Attachment | Capture, Command Pipeline, receipts, correction/memory | Launch-critical; must include receipts and correction. |
| Smart Attachment receipts and correction | Receipt / Action Closure, Capture, What Ambitions Knows | Launch-critical baseline; correction must create or update receipt trail. |
| You as Personal System Center | You, Trust Center, What Ambitions Knows, Reviews, Settings | Soon-after-launch full depth; baseline You/Trust is launch-critical. |
| Trust Center | You, receipt maturity, sync/export, privacy | Launch-critical baseline; trust claims remain conservative. |
| What Ambitions Knows | You, memory confidence, correction, Trust Center | Launch-critical only if memory is visible/used; richer center soon-after-launch. |
| GroupedNavigationList | You, Trust Center, Memory, Settings, Plan controls | Infrastructure-unlock / soon-after-launch. |
| Panel Size | Rich panel, Appearance Studio, accessibility verification | Soon-after-launch unless accessibility requires it. |
| Display Density | Rich panel, Appearance Studio, accessibility verification | Soon-after-launch unless accessibility requires it. |
| Screen Contract Matrix implementation | Core surface integration QA and surface maturity | Infrastructure-unlock for launch-critical surfaces. |
| Component Contract Matrix implementation | Shared components, rich panels, trust, review, external surfaces | Infrastructure-unlock. |
| UX Writing / State Language Matrix implementation | Surface transformations, notifications, receipts, trust | Launch-critical visible-copy gate. |
| Accessibility Nutrition screen verification | Batch 115 / release hardening | Launch-critical for core surfaces; user-facing claims require evidence. |
| External Surfaces Contract | App Intents, widgets, Live Activities, notifications, Shortcuts | Post-launch/deferred unless safe capture/open route is scoped. |
| Widgets after Now State stability | Ambient continuity and external verification | Deferred until Today/Now truth and privacy are stable. |
| Live Activities after Now State and Command Pipeline stability | Ambient continuity and external verification | Deferred until active focus/time-sensitive slices are verified. |
| App Intents / Shortcuts | Shared Command Pipeline and receipts | Post-launch for full maturity; safe capture/open routes may remain scoped. |
| Notification frequency/privacy controls | External surfaces, You notifications, Trust Center | Post-launch unless notifications ship in first launch. |
| Receipt search/history | Action Closure maturity, Trust Center, Archive, Reviews | Baseline proof/receipt is launch-critical; full search/history soon-after-launch. |
| Local-first calendar-derived insight | Reality Model, Plan, Reviews | Launch-critical only for Plan behaviors that expose calendar context. |
| Plan-owned calendar permission | Reality Model, Plan, release verification | Locked; no onboarding permission request. |
| Motion grammar and Reduce Motion variants | Visual system, component matrix, accessibility verification | Launch-critical for visible core motion if used. |
| Semantic Zoom fallbacks | Goals, Life Areas, Path Builder, accessibility/performance QA | Deferred until accessible list fallback and bounded rendering are ready. |
| Safe-zone modularity rules | Panel density/size, rich panel, visual polish | Infrastructure/surface quality. |
| Today Plan Layer | Today transformation, Plan integration, core surface QA | Launch-critical; Today must show the calm planned day, not only one current step. |
| Life Areas / North Stars / Goals semantic zoom | Goals, Life Areas, Path Builder, accessibility/performance QA | Split: Goals basics launch-critical; North Stars/Semantic Zoom deferred. |

## Dependency-Safe Constitution Sequence

The implementation sequence below overlays the existing batch plan without renumbering completed history. Future prompts should use this order when expanding or reconciling Batch 89+ work.

1. Canon and source-of-truth cleanup.
2. Shared object model terminology and docs.
3. Shared component primitives.
4. GroupedNavigationList foundation.
5. Panel Size + Display Density foundation.
6. Receipt / Action Closure design contract.
7. Smart Attachment design/data contract.
8. Life Areas / North Stars object model.
9. One-Step Goals object model.
10. Screen contract implementation pass.
11. Today surface transformation.
12. Capture surface transformation.
13. Goals / Life Areas / North Stars transformation.
14. Plan / Timeline / Rituals transformation.
15. You Personal System Center transformation.
16. Trust Center / What Ambitions Knows.
17. Accessibility Nutrition verification.
18. External surfaces: widgets, Live Activities, App Intents.
19. Release-candidate validation.

Key dependencies: object terminology precedes surfaces; component primitives precede screen implementations; receipts precede Smart Attachment correction and external actions; Life Areas/North Stars and One-Step Goals precede Goals semantic zoom; Today Plan Layer depends on Now State, Plan believability, and Reality Model; external surfaces depend on Now State, Command Pipeline, receipts, privacy snapshots, and verification.

## Implementation Gap Audit Delta Track

[Ambitions_2_0_Implementation_Gap_Audit.md](Ambitions_2_0_Implementation_Gap_Audit.md) records the repo-wide implementation gap audit against the Design Constitution. The audit preserves completed batch history and adds future delta/alignment work where implemented foundations need Constitution alignment. These are planned implementation batches, not completed claims.

Use [ROADMAP_BATCH_CLASSIFICATION.md](ROADMAP_BATCH_CLASSIFICATION.md) as the active classification layer for these deltas.

Dependency-safe delta order:

1. Shell IA / Tab Alignment Delta. Launch-critical.
2. Shared object terminology cleanup for Task vs Step, Life Area, North Star, Ritual, Receipt. Launch-critical.
3. GroupedNavigationList Component. Infrastructure-unlock / soon-after-launch.
4. Panel Size + Display Density. Soon-after-launch.
5. Receipt / Action Closure search and privacy contract. Launch-critical baseline; full search soon-after-launch.
6. Smart Attachment Foundation. Launch-critical.
7. Life Areas Overview / Atlas object model. Soon-after-launch full Atlas; simplified area routing can support launch.
8. North Stars / Dormant Ambitions object model. Post-launch.
9. One-Step Goals Object Model. Launch-critical.
10. Screen Contract Matrix implementation pass. Infrastructure-unlock.
11. Today 2.0 Design Constitution Alignment. Launch-critical.
12. Capture + Quiet Command Sheet Alignment. Launch-critical.
13. Goals / Life Areas / North Stars transformation and Semantic Zoom. Split: Goals basics launch-critical; North Stars/Semantic Zoom deferred.
14. Goal Detail Mission Control Lanes Alignment. Launch-critical baseline / soon-after-launch full lanes.
15. Plan Believability + Timeline Widget Alignment. Launch-critical for Plan/doable path/recovery.
16. Ritual Split Alignment. Soon-after-launch unless current Habits language breaks IA.
17. You Personal System Center Alignment. Soon-after-launch full structure; baseline You/Trust launch-critical.
18. Trust Center Alignment. Launch-critical baseline.
19. What Ambitions Knows. Launch-critical only if memory is visible/used; richer center soon-after-launch.
20. UX Writing Cleanup. Launch-critical.
21. Accessibility Nutrition Verification. Launch-critical.
22. External Surfaces Contract Alignment. Post-launch / decision-gated.
23. Widgets Alignment. Deferred.
24. Live Activities Alignment. Deferred.
25. App Intents / Shortcuts Alignment. Post-launch except safe capture/open routes.
26. Release Candidate Validation. Launch-critical final gate.

The next implementation prompt should start with D03 unless a direct user instruction chooses another delta. D01 shell alignment and D02 shared object terminology cleanup are complete for planning purposes; do not implement Smart Attachment, Life Areas, North Stars, One-Step Goals, external surfaces, or accessibility claims before their prerequisites are satisfied.

Original Batches 89-120 remain preserved future roadmap intent, but they are no longer the next unchanged execution sequence. Use [Ambitions_2_0_Roadmap_Merge_Audit.md](Ambitions_2_0_Roadmap_Merge_Audit.md) before planning any Batch 89-120 work; no original batch may run before the D batch that owns its required Constitution foundation.

## Program 1 - Truth, Shell, And Visual Foundation

- Goal: Verify repo truth, lock the Today / Goals / Capture / Plan / You shell, and establish the rich panel design system.
- Why it comes here: Surface transformation cannot start from stale capability assumptions or a disputed IA.
- Systems affected: Accessibility Nutrition Layer, Visual System, Capability Matrix, shell routing.
- User-facing outcome: The app has a clear 2.0 structure and visual language.
- Technical foundation created: capability evidence, IA decisions, panel primitives, accessibility checklist.
- Risks: false status claims, shell churn, visual components outrunning data.
- Dependencies: Batch 60 planning completion and Batch 61 verification.
- Launch classification: infrastructure-unlock / launch-critical only where it directly supports the Golden Launch Loop.
- Not included yet: feature behavior changes beyond active batch scope, widgets, sync, calendar implementation beyond verified planning.

## Program 2 - Shared Intelligence Foundations

- Goal: Build Memory / Event Ledger, Recommendation Explanation Model, Canonical Now State, and Command Pipeline foundations.
- Why it comes here: Surfaces, widgets, intents, and reviews need one source of truth.
- Systems affected: Memory / Event Ledger, Explanation, Now State, Command Pipeline.
- User-facing outcome: Recommendations and actions become consistent and explainable.
- Technical foundation created: local events, reusable explanation, stable current-state projection, safe command path.
- Risks: duplicate histories, command paths outside the pipeline, explanation copy not backed by evidence.
- Dependencies: Program 1 truth and design foundations.
- Launch classification: infrastructure-unlock; user-facing launch scope must still use human copy and avoid AI/model/confidence language.
- Not included yet: external surfaces, sync merge, full path UI.

## Program 3 - Core Execution Systems

- Goal: Rebuild Capture, Reality Model/calendar read-write, goal health, and Execution Resilience.
- Why it comes here: Daily execution must rest on real capacity, permission-safe calendar context, and shared recovery.
- Systems affected: Reality Model, Execution Resilience, Command Pipeline, Event Ledger.
- User-facing outcome: Capture routes cleanly, Plan can become calendar-aware, Today can recover when life changes.
- Technical foundation created: local-first calendar-derived insights, recovery actions, plan-doability model.
- Risks: permission overreach, calendar write ambiguity, habit logic duplication.
- Dependencies: Program 2 command and memory foundations.
- Launch classification: launch-critical for Capture/place/routing, Plan/doable path, Today/recovery, and receipt/proof support.
- Not included yet: widgets, Live Activities, Apple-first sync, full long-range path UI.

## Program 4 - Primary Surface Transformation

- Goal: Transform Today into a Daily Operating Contract, align global chrome, then transform Goals, Plan, You, contextual insights, reviews, and absorbed habits using shared loop systems.
- Why it comes here: Core systems must exist before surfaces present them.
- Systems affected: Now State, Reality Model, Explanation, Reviews, Visual System, Global Chrome, Action Closure, Life Graph, Proof Rail, Trust Ledger.
- User-facing outcome: The primary app feels like one coherent personal system rather than separate tabs.
- Technical foundation created: surface consumers of shared systems instead of duplicated logic; permanent shell/header/tab visual alignment; Action Closure and Life Graph foundations for later surfaces.
- Risks: top-level density creep, rebuilding Insights as a tab, treating Habits as standalone, turning global chrome into feature content, or building surface-specific receipt/proof/navigation systems.
- Dependencies: Programs 1-3.
- Launch classification: launch-critical for Today, Capture, Goals basics, Plan, You/Trust baseline, UX writing cleanup, and accessibility verification; post-launch/deferred for full semantic zoom, North Stars, advanced reviews, and deep personalization.
- Not included yet: widgets/Live Activities before Now State and Command Pipeline are stable, non-phone hardware.

Primary-surface sequencing is loop-first and now continues through maturity:

- Batch 73 makes Today the Daily Operating Contract.
- Batch 74 aligns global shell/chrome before the remaining major surface redesigns consume it.
- Batch 75 defines the Activation Contract and first-run promise.
- Batch 76 verifies the Daily Loop Alpha and performance baseline.
- Batches 77-82 establish Life Graph, Proof / Resource Graph, Commitments / Waiting, Action Closure, Safe Automation, and foundation performance.
- Batches 83-89 transform Goals, Goal Detail, Plan, Reality Reflow, You, and Reviews around proof, recovery, correction, trust, memory, and continuity.
- Batch 83 establishes Goals as a premium ambition portfolio with Goal Lifecycle Rail, Goal Weather v1, Goal Atlas preview, Completion Archive states, Next Visible Step on every active goal card, and compact lifecycle timeline.
- Batch 84 makes Goal Detail feel like Mission Control with goal-specific lifecycle timeline, Proof Spine, Decision Trail, Milestone Cards, Kanban-lite Task Lane, connected goals, dominant Next Visible Step, end-state summaries, and Weather explanation.
- Batch 85 makes Plan 2.0 visual and doable with Weekly Plan Strip, Next Visible Step selection, Goal Weather and proof density in plan-doability, Plan Treaty Decision Trail notes, active-goal plan window, and Next/Doing task-lane weighting.

## Program 5 - Trust, Ambient Continuity, And Apple Platform Completion

- Goal: Ship export/import proof, Apple-first sync/conflict policy, App Intents, shared container receipts, Widgets, Live Activity ambient continuity, and external surface verification as trust surfaces with receipts and stale-state truth.
- Why it comes here: External surfaces need stable Now State, Command Pipeline, data boundaries, and trust language.
- Systems affected: Sync/Export Trust Layer, Command Pipeline, Now State, Event Ledger, Action Closure, Trust Ledger, External Continuity Contract.
- User-facing outcome: Ambitions works cleanly across Apple-native entry points with trustworthy fallback.
- Technical foundation created: shared external payloads, sync/export policy, simple external surface consumers, external proof gates.
- Risks: sync before model verification, external command duplication, overbuilding widgets, stale external state without visible trust status, or external actions without receipts.
- Dependencies: stable Now State, Command Pipeline, verified data model.
- Launch classification: post-launch/deferred except safe in-app capture/open routes and any trust/privacy controls required by shipped external surfaces.
- Not included yet: non-phone hardware prototype, HealthKit, household/shared life.
- Batch 93 widgets and Live Activity ambient continuity include calm snapshot concepts for Next Visible Step, Active Goal Timeline, Goal Portfolio, Next Milestone, Weekly Plan Strip, and next proof action. They must stay ambient and must not show every goal. Do not expose `Protected Goal` as normal widget copy.

## Program 6 - Full Path Intelligence And Learning Foundations

- Goal: Build Life Path Simulation for broad coherent path families, then connect it to local learning, Memory Confidence, Correction Cards, and Narrative Memory Map.
- Why it comes here: The app needs stable execution and explanation foundations before long-range UI expands.
- Systems affected: Path Intelligence, Reality Model, Explanation, Goals, Plan.
- User-facing outcome: Users can see long-range paths, forks, prerequisites, proof requirements, risks, fallback paths, and daily next actions.
- Technical foundation created: path families, path forks, Domain Path Pack contracts, Future Self Simulator, pause/limited-time simulations, builder, long-range path UI, learning/anticipation v1, memory confidence, correction cards, narrative memory.
- Risks: template sprawl, unsupported domains, ungrounded advice, fake certainty, or full path UI before Life Graph/proof/action-closure foundations exist.
- Dependencies: Memory, Explanation, Reality Model, surface transformation.
- Launch classification: post-launch / decision-gated.
- Not included yet: HealthKit, food/calorie sync, household/shared life.
- Batch 97 expands Goal Atlas into full Path Builder, turns Milestone Cards into roadmap nodes, expands lifecycle timeline into long-range visual planning, makes Decision Trail visible across roadmap changes, and rolls Weekly Plan Strips into longer roadmap phases.

## Program 7 - Mature Invention Passes

- Goal: Return to every major invention after v1 and cross-surface use, then make each release-candidate ready.
- Why it comes here: Mature behavior requires implementation evidence from core surfaces, external surfaces, pathing, learning, and reviews.
- Systems affected: Life Graph, Action Closure, Proof / Progress, Commitments / Waiting, Believability, Reality Reflow, Ambition Portfolio, Constitution, Reviews / Memory, Path / Future Self, Mode Lens, performance.
- User-facing outcome: The app feels coherent, correctable, fast, and trustworthy instead of like many v1 inventions.
- Technical foundation created: maturity audits, performance proof, correction/undo/trust closure, and blocker lists where needed.
- Risks: endless polish, late discovery of duplicated engines, performance regression, or cognitive load growth.
- Dependencies: Programs 1-6.
- Launch classification: RC/maturity scope, not first-launch proof unless a specific hardening item is required by the Golden Launch Loop.
- Not included yet: release lock or user-facing accessibility claims without verification.
- Batch 107 matures Ambition Portfolio Manager with mature Goal Weather, Completion Archive intelligence, portfolio-level proof maturity, cancelled/dropped learning summaries, Goal Atlas as the mature portfolio view, too-many-stuck-tasks detection, proof maturity comparison, and Goal Scope Maturity.

## Program 8 - Onboarding, Accessibility, And Release Hardening

- Goal: Complete learning, onboarding, empty states, returning-user continuity, verified accessibility nutrition, indispensability QA, and release hardening.
- Why it comes here: Claims and polish must follow real system behavior.
- Systems affected: Accessibility Nutrition, Reviews, Memory, onboarding, Global Chrome, Appearance Studio, release docs.
- User-facing outcome: The product feels trustworthy from first launch through release candidate.
- Technical foundation created: verification records, accessibility summary, scenario scripts, global chrome QA, rich-panel visual consistency QA, Appearance Studio regression QA, release readiness.
- Risks: unverified accessibility claims, stale screenshots/docs, performance regressions, shell inconsistency, rich-panel drift, or beautiful surfaces that do not feel indispensable.
- Dependencies: Programs 1-6.
- Launch classification: launch-critical for onboarding, empty states, core accessibility verification, and release-candidate validation; post-launch for mature reviews and advanced personalization.
- Not included yet: deferred 2.0 scope.
