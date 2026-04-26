# Ambitions 2.0 Batch Plan

Adoption date: 2026-04-24

## Purpose

This is the active post-Batch-60 execution plan. It begins at Batch 61 and supersedes prior roadmap direction where conflicts exist after Batch 60.

"Verify truth first, build shared systems once, then transform surfaces, then ship Apple-native external surfaces."

## Execution Rules

- Work on `main` only.
- One batch at a time.
- Do not drift beyond the active batch.
- Do not implement app features in docs-only batches.
- Do not build surfaces before owning systems exist.
- Do not build widgets or Live Activities before Canonical Now State and Command Pipeline are stable.
- Do not do sync work before data model and capability verification.
- Every batch completion report must list changed files and validation steps.
- Every future batch must name the maturity gate it advances from [Ambitions_2_0_RC_Maturity_Plan.md](Ambitions_2_0_RC_Maturity_Plan.md).
- Every feature batch must include a performance budget, accessibility requirement, degraded-state behavior, correction path, no-fake-precision boundary, and concrete acceptance criteria.
- Every future Goals, Goal Detail, Plan, widget, Path Builder, and Portfolio batch must preserve the Goal -> Plan -> Task -> Proof relationship: goal direction, believable path, meaningful milestone, concrete task, evidence of progress, decision trail, readable weather, and archive learning.
- Do not mark a maturity, hardening, verification, or RC-lock batch complete until the owning validation evidence exists.

## Batch List

| Batch | Name | Program |
| --- | --- | --- |
| 61 | Repo Truth and Ambitions 2.0 Capability Matrix | Truth, shell, and visual foundation |
| 62 | Ambitions 2.0 Shell IA | Truth, shell, and visual foundation |
| 63 | Rich Panel Design System | Truth, shell, and visual foundation |
| 64 | Accessibility Nutrition Layer | Truth, shell, and visual foundation |
| 65 | Memory / Event Ledger Foundation | Shared intelligence foundations |
| 66 | Recommendation Explanation Model | Shared intelligence foundations |
| 67 | Canonical Now State | Shared intelligence foundations |
| 68 | Command Pipeline Foundation | Shared intelligence foundations |
| 69 | Capture 2.0 Core | Core execution systems |
| 70 | Reality Model and Calendar Read/Write | Core execution systems |
| 71 | Believability, Capacity, and Goal Health | Core execution systems |
| 72 | Execution Resilience Stack | Core execution systems |
| 73 | Today 2.0 / Daily Operating Contract v1 | Phase A - daily value, shell, activation |
| 74 | Global Shell Chrome and Visual Alignment | Phase A - daily value, shell, activation |
| 75 | Activation Contract and First-Run Promise Spec | Phase A - daily value, shell, activation |
| 76 | Daily Loop Alpha QA and Performance Baseline | Phase A - daily value, shell, activation |
| 77 | Life Graph v1 Minimal Object Relationships | Phase B - shared object/trust foundations |
| 78 | Proof and Resource Graph v1 | Phase B - shared object/trust foundations |
| 79 | Commitment, Waiting Room, and Promise Ledger v1 | Phase B - shared object/trust foundations |
| 80 | Action Closure and Receipt System v1 | Phase B - shared object/trust foundations |
| 81 | Safe Automation Boundary and Undo Rules | Phase B - shared object/trust foundations |
| 82 | Foundation Performance and Persistence Budget Pass | Phase B - shared object/trust foundations |
| 83 | Goals 2.0 / Portfolio, Health, and Proof v1 | Phase C - core surfaces consume foundations |
| 84 | Goal Detail 2.0 / Mission Control, Assumptions, Proof Rail | Phase C - core surfaces consume foundations |
| 85 | Plan 2.0 / Believability Kernel and Plan Treaty | Phase C - core surfaces consume foundations |
| 86 | Reality Reflow v1 and Recovery Gradient | Phase C - core surfaces consume foundations |
| 87 | You 2.0 / Trust Center, Constitution, Memory Controls | Phase C - core surfaces consume foundations |
| 88 | Reviews v1 / Recovery Review and Life OS Receipt | Phase C - core surfaces consume foundations |
| 89 | Core Surface Integration QA and Performance Pass | Phase C - core surfaces consume foundations |
| 90 | Export / Import Proof and Disaster Drill | Phase D - trust, ambient continuity, platform surfaces |
| 91 | Apple-First Sync and Conflict Policy | Phase D - trust, ambient continuity, platform surfaces |
| 92 | App Intents and Shared Container Receipts | Phase D - trust, ambient continuity, platform surfaces |
| 93 | Widgets and Live Activity Ambient Continuity | Phase D - trust, ambient continuity, platform surfaces |
| 94 | External Surface Platform Verification and Performance Pass | Phase D - trust, ambient continuity, platform surfaces |
| 95 | Path Intelligence Foundation / Life Path Simulation | Phase E - long-range strategy and learning foundations |
| 96 | Domain Path Packs and Path Fork Simulator | Phase E - long-range strategy and learning foundations |
| 97 | Path Builder UI / Long-Range Roadmap v1 | Phase E - long-range strategy and learning foundations |
| 98 | Learning and Anticipation v1 | Phase E - long-range strategy and learning foundations |
| 99 | Memory Confidence, Correction Cards, and Narrative Memory Map | Phase E - long-range strategy and learning foundations |
| 100 | Strategy / Learning Integration QA and Performance Pass | Phase E - long-range strategy and learning foundations |
| 101 | Life Graph Mature Relationship Audit | Phase F - mature invention passes |
| 102 | Action Closure Mature Receipt / Undo / Trust Audit | Phase F - mature invention passes |
| 103 | Proof-Weighted Progress and Momentum Integrity Maturity | Phase F - mature invention passes |
| 104 | Commitments, Waiting, Promise Ledger, and Social Load Maturity | Phase F - mature invention passes |
| 105 | Believability Kernel, Constraint Gravity, and Plan Treaty Maturity | Phase F - mature invention passes |
| 106 | Reality Reflow, Recovery Gradient, and Save the Day Maturity | Phase F - mature invention passes |
| 107 | Ambition Portfolio Manager, Goal Weather, and Goal Scope Maturity | Phase F - mature invention passes |
| 108 | Personal Operating Constitution and Calm Intervention Maturity | Phase F - mature invention passes |
| 109 | Reviews, Life OS Receipt, and Narrative Memory Maturity | Phase F - mature invention passes |
| 110 | Path Forks, Future Self Simulation, and Domain Pack Maturity | Phase F - mature invention passes |
| 111 | Cross-Surface Continuity and Mode Lens Maturity | Phase F - mature invention passes |
| 112 | Mature Invention Performance Pass | Phase F - mature invention passes |
| 113 | Onboarding, Empty States, and Returning User Continuity | Phase G - onboarding, accessibility, release |
| 114 | Representative Scenario Fixtures and Indispensability QA v1 | Phase G - onboarding, accessibility, release |
| 115 | Accessibility Verification and User-Facing Nutrition Facts | Phase G - onboarding, accessibility, release |
| 116 | Visual Polish, Appearance Studio, and Shell Regression | Phase G - onboarding, accessibility, release |
| 117 | Offline, Data Safety, Migration, and Reliability Hardening | Phase G - onboarding, accessibility, release |
| 118 | Final Performance, Memory, and Responsiveness Pass | Phase G - onboarding, accessibility, release |
| 119 | Ambitions 2.0 RC Audit | Phase G - onboarding, accessibility, release |
| 120 | Ambitions 2.0 Release Candidate Lock | Phase G - onboarding, accessibility, release |

## Batch 61 - Repo Truth and Ambitions 2.0 Capability Matrix

- Purpose: Verify current repo truth before any feature implementation.
- Exact scope: Audit current docs, native source, project configuration, tests, CI, and release notes against [Ambitions_2_0_Capability_Matrix.md](Ambitions_2_0_Capability_Matrix.md). Fill evidence paths and current status.
- Likely areas affected: `docs/canon/Ambitions_2_0_Capability_Matrix.md`, `docs/codex/BATCH_REGISTRY.md`, targeted docs notes only if stale claims are found.
- Dependencies: Batch 60 complete by planning instruction.
- Implementation notes: Do not implement features. Do not rename tabs. Do not change Swift behavior.
- UI/UX expectations: None beyond documenting verified current UI truth.
- Acceptance criteria: Capability matrix has evidence paths, risks, next actions, and related batches for every initial row.
- Testing requirements: Run markdown checks if available and lightweight repo validation documented for docs-only changes.
- Out-of-scope items: Shell implementation, design system work, calendar work, sync work, widgets, Live Activities, path intelligence implementation.
- Risk notes: Existing docs may conflict with current user instruction; record conflicts without erasing history.
- Completion definition: Matrix is filled, conflicts are documented, changed files and validation are reported.
- Ready-to-paste Codex prompt:

```text
You are working in the Ambitions repo on main. Do not create or switch branches.

ACTIVE BATCH: Batch 61 - Repo Truth and Ambitions 2.0 Capability Matrix

Read AGENTS.md, MASTER_PRODUCT_SPEC.md, docs/codex/CONTEXT_INDEX.md, docs/codex/MASTER_CODEX_SYSTEM.md, docs/codex/BATCH_REGISTRY.md, and the Ambitions 2.0 canon files. Verify repo truth only. Fill docs/canon/Ambitions_2_0_Capability_Matrix.md with current status, evidence path, risk, next action, and related batch for each capability. Do not implement app features, refactor Swift, rename UI, or start Batch 62. Preserve historical docs. Report changed files and validation steps.
```

## Batch 62 - Ambitions 2.0 Shell IA

- Purpose: Implement the Today / Goals / Capture / Plan / You shell decision after Batch 61 verification.
- Exact scope: Shell IA, route ownership, labels, and subordinate placement for Insights and Habits.
- Likely areas affected: app routing, feature shell, tab labels, UI tests, canon docs if verified deltas require notes.
- Dependencies: Batch 61 complete.
- Implementation notes: `Capture` is singular. Insights is not a top-level tab. Habits is not a standalone top-level area.
- UI/UX expectations: Calm five-tab shell, no extra tab, no hidden primary navigation.
- Acceptance criteria: Top-level shell is Today / Goals / Capture / Plan / You and subordinate routes match canon.
- Testing requirements: XcodeGen generation, native build, targeted routing/UI tests, full relevant tests if routing touches shared shell.
- Out-of-scope items: Rich panel overhaul, calendar implementation, sync, widgets, Live Activities.
- Risk notes: Older docs and code may still use Profile/Insights/Habits names; migrate only the active shell scope.
- Completion definition: Shell behavior matches canon, tests pass or limitations are reported.
- Ready-to-paste Codex prompt:

```text
You are working in the Ambitions repo on main. Do not create or switch branches.

ACTIVE BATCH: Batch 62 - Ambitions 2.0 Shell IA

Use Batch 61 verified evidence. Implement only the top-level IA decision: Today, Goals, Capture, Plan, You. Capture is singular. Demote Insights from top-level navigation and absorb Habits out of standalone top-level navigation according to canon. Do not redesign surfaces or implement later systems. Report changed files and validation steps.
```

## Batch 63 - Rich Panel Design System

- Purpose: Create shared rich widget-like panel foundations.
- Exact scope: Shared panel primitives, visual tokens, dark/light palette direction, panel type foundations.
- Likely areas affected: shared UI component sources, design docs, preview fixtures, snapshot/UI tests if present.
- Dependencies: Batch 62 complete.
- Implementation notes: Build reusable primitives before applying them broadly.
- UI/UX expectations: Warm charcoal/blue-black dark mode, warm off-white light mode, meaningful state, not plain text cards.
- Acceptance criteria: Reusable panel types exist for later surfaces and pass accessibility baseline review.
- Testing requirements: Native build, component previews if available, targeted UI tests, contrast/reduced-motion review where possible.
- Out-of-scope items: Full Today/Goals/Plan redesign, widgets, Live Activities.
- Risk notes: Avoid one-off styling and nested-card layouts.
- Completion definition: Shared panel system is ready for later surface consumption.
- Ready-to-paste Codex prompt:

```text
Work on main only. ACTIVE BATCH: Batch 63 - Rich Panel Design System. Implement shared rich panel primitives and design tokens only. Follow docs/canon/Ambitions_2_0_Visual_System.md. Do not rebuild Today, Goals, Plan, Capture, or You. Do not implement later systems. Report changed files and validation steps.
```

## Batch 64 - Accessibility Nutrition Layer

- Purpose: Add internal accessibility audit infrastructure before public claims.
- Exact scope: Checklist storage/docs, audit templates, code/docs hooks where appropriate.
- Likely areas affected: accessibility docs, QA docs, possibly shared UI metadata if verified necessary.
- Dependencies: Batch 63 complete.
- Implementation notes: Internal checklist first; no user-facing claims until Batch 115 verification.
- UI/UX expectations: Panels remain auditable for Dynamic Type, VoiceOver, contrast, motion, and tap targets.
- Acceptance criteria: Screen-level audit template and internal workflow exist.
- Testing requirements: Markdown validation and any targeted accessibility/unit checks for touched code.
- Out-of-scope items: User-facing You -> Accessibility summary, full accessibility verification.
- Risk notes: Do not claim verified support without test evidence.
- Completion definition: Future batches can record accessibility nutrition consistently.
- Ready-to-paste Codex prompt:

```text
Work on main only. ACTIVE BATCH: Batch 64 - Accessibility Nutrition Layer. Build only the internal accessibility checklist/audit layer described in canon. Do not add user-facing Accessibility Nutrition claims yet. Do not drift into surface redesign. Report changed files and validation steps.
```

## Batch 65 - Memory / Event Ledger Foundation

- Purpose: Establish one local event ledger for meaningful user and system events.
- Exact scope: Ledger model/contracts, persistence path if verified appropriate, tests, docs updates.
- Likely areas affected: domain, services, persistence, tests, docs.
- Dependencies: Batch 64 complete.
- Implementation notes: Do not create feature-specific histories.
- UI/UX expectations: No major UI surface work; any visible debug/admin copy must be avoided.
- Acceptance criteria: Events can record action, delay, skip, move, split, recovery, review, correction, schedule, export/import.
- Testing requirements: Targeted unit/persistence tests, native build, full relevant test suite.
- Out-of-scope items: Reviews UI, sync merge, widgets, Live Activities.
- Risk notes: Persistence migrations must be narrow and backward-safe.
- Completion definition: Ledger is reusable and tested.
- Ready-to-paste Codex prompt:

```text
Work on main only. ACTIVE BATCH: Batch 65 - Memory / Event Ledger Foundation. Implement the shared local event ledger foundation only. Do not build Reviews UI, sync, widgets, or surface redesigns. Keep changes inside existing architecture boundaries and report changed files plus validation.
```

## Batch 66 - Recommendation Explanation Model

- Purpose: Create one explanation model for why-this and why-changed reasoning.
- Exact scope: Explanation contracts, evidence categories, consumers behind stable adapters, tests.
- Likely areas affected: domain/services, Today/Goal Detail adapters only if needed, tests, docs.
- Dependencies: Batch 65 complete.
- Implementation notes: Explanations distinguish evidence, assumption, memory, calendar-derived context, and uncertainty.
- UI/UX expectations: Minimal surface hooks only; no full redesign.
- Acceptance criteria: Shared explanation objects can power `Why This` and `Why Changed`.
- Testing requirements: Targeted explanation tests, native build, full relevant tests.
- Out-of-scope items: Full sheets, contextual insights system, calendar implementation.
- Risk notes: Avoid hard-coded screen-specific rationale strings.
- Completion definition: Later surfaces can consume explanations without duplicating logic.
- Ready-to-paste Codex prompt:

```text
Work on main only. ACTIVE BATCH: Batch 66 - Recommendation Explanation Model. Implement shared explanation contracts and tests only. Do not build full insight surfaces, calendar features, or UI redesigns. Report changed files and validation.
```

## Batch 67 - Canonical Now State

- Purpose: Create one current-state projection for app and later external surfaces.
- Exact scope: Now State contracts, projection service, tests, narrow existing consumers if needed.
- Likely areas affected: services/runtime/domain, Today adapters, tests.
- Dependencies: Batch 66 complete.
- Implementation notes: Do not duplicate widget-specific or notification-specific current-state logic.
- UI/UX expectations: No visible redesign required.
- Acceptance criteria: Now State exposes current action, next action, schedule pressure, recovery state, and goal pressure.
- Testing requirements: Targeted Now State tests, native build, relevant full tests.
- Out-of-scope items: Widgets, Live Activities, App Intents changes except compatibility if required.
- Risk notes: Keep projection local-first and deterministic.
- Completion definition: Stable internal Now State exists for later batches.
- Ready-to-paste Codex prompt:

```text
Work on main only. ACTIVE BATCH: Batch 67 - Canonical Now State. Build the shared Now State projection only. Do not implement widgets, Live Activities, App Intents expansion, or surface redesigns. Report changed files and validation.
```

## Batch 68 - Command Pipeline Foundation

- Purpose: Route user and external commands through one validated local pipeline.
- Exact scope: Command contracts, validation, execution, event emission, tests.
- Likely areas affected: services/domain/runtime, existing action handlers, tests.
- Dependencies: Batch 67 complete.
- Implementation notes: External surfaces must not get separate command logic later.
- UI/UX expectations: Existing behavior preserved unless the pipeline requires a bug fix.
- Acceptance criteria: Key actions execute through shared command path and record events.
- Testing requirements: Targeted command tests, native build, full relevant tests.
- Out-of-scope items: App Intents productization, widgets, Live Activities, new feature surfaces.
- Risk notes: Avoid broad rewiring beyond proven command seams.
- Completion definition: Command pipeline is stable enough for Capture, Today, and external surface batches.
- Ready-to-paste Codex prompt:

```text
Work on main only. ACTIVE BATCH: Batch 68 - Command Pipeline Foundation. Implement shared command validation/execution/event emission only. Preserve behavior and do not productize App Intents, widgets, or Live Activities. Report changed files and validation.
```

## Batch 69 - Capture 2.0 Core

- Purpose: Make Capture a first-class singular top-level intake and triage flow.
- Exact scope: Capture core UI/data flow for raw, goal, plan, seed, waiting, archive routing.
- Likely areas affected: Capture feature, routing, command pipeline adapters, tests.
- Dependencies: Batch 68 complete.
- Implementation notes: Capture routes into Goals/Plan/Waiting/Archive; it does not become a second planner.
- UI/UX expectations: Rich Capture panels, fast input, clear triage action.
- Acceptance criteria: Capture tab supports deterministic triage destinations.
- Testing requirements: Targeted Capture tests, UI tests, native build, relevant full tests.
- Out-of-scope items: Full Goals/Plan redesign, sync, widgets.
- Risk notes: Prevent duplicate capture states.
- Completion definition: Capture 2.0 core is usable and tested.
- Ready-to-paste Codex prompt:

```text
Work on main only. ACTIVE BATCH: Batch 69 - Capture 2.0 Core. Implement only singular Capture core intake and triage using existing/shared systems. Do not redesign Goals or Plan beyond necessary routing. Report changed files and validation.
```

## Batch 70 - Reality Model and Calendar Read/Write

- Purpose: Add permission-safe calendar-aware planning reality.
- Exact scope: Reality Model, calendar read, user-confirmed calendar write, local-first derived insight policy, tests.
- Likely areas affected: services, permissions, Plan adapters, persistence if needed, tests, privacy docs.
- Dependencies: Batch 68 complete; Batch 69 complete unless registry says otherwise.
- Implementation notes: Plan works without permission. Request access only after explicit Plan action.
- UI/UX expectations: Clear permission rationale and degraded state.
- Acceptance criteria: Calendar read supports open windows/conflicts; write creates confirmed blocks; denial preserves Plan usability.
- Testing requirements: Targeted calendar/service tests, permission flow tests where possible, native build, relevant full tests.
- Out-of-scope items: Full Plan redesign, sync, widgets, HealthKit.
- Risk notes: Calendar data minimization is mandatory.
- Completion definition: Calendar read/write is trustworthy and local-first.
- Ready-to-paste Codex prompt:

```text
Work on main only. ACTIVE BATCH: Batch 70 - Reality Model and Calendar Read/Write. Implement permission-safe Reality Model calendar read/write only. Plan must work without permission, and permission may be requested only from explicit Plan actions. Do not redesign Plan fully or add sync/widgets. Report changed files and validation.
```

## Batch 71 - Believability, Capacity, and Goal Health

- Purpose: Connect capacity and goal health to believable planning.
- Exact scope: Capacity model, goal health calculations, believability status, tests.
- Likely areas affected: domain/services, Goals/Plan adapters, tests.
- Dependencies: Batch 70 complete.
- Implementation notes: Use Reality Model; do not invent per-surface scoring.
- UI/UX expectations: Minimal state exposure only where existing surfaces need it.
- Acceptance criteria: Goal health and plan believability derive from shared capacity/reality data.
- Testing requirements: Targeted domain tests, native build, relevant full tests.
- Out-of-scope items: Full Goal Detail redesign, long-range path builder UI.
- Risk notes: Avoid fake precision and punitive language.
- Completion definition: Shared believable-state contracts exist and are tested.
- Ready-to-paste Codex prompt:

```text
Work on main only. ACTIVE BATCH: Batch 71 - Believability, Capacity, and Goal Health. Implement shared believability/capacity/goal-health logic only. Do not redesign Today, Goals, or Plan. Report changed files and validation.
```

## Batch 72 - Execution Resilience Stack

- Purpose: Centralize recovery decisions after drift or disruption.
- Exact scope: Recovery model/actions, smaller-step, split, reschedule, protect later, review prompt, tests.
- Likely areas affected: domain/services, command pipeline, Today/Plan adapters, tests.
- Dependencies: Batch 71 complete.
- Implementation notes: Recovery is shared, non-punitive, and event-backed.
- UI/UX expectations: Recovery panels may be minimal until surface batches.
- Acceptance criteria: Core recovery actions are deterministic and record events.
- Testing requirements: Targeted recovery/command tests, native build, relevant full tests.
- Out-of-scope items: Today 2.0 redesign, Reviews rebuild.
- Risk notes: Avoid duplicating old skip/delay logic.
- Completion definition: Later surfaces can consume one recovery stack.
- Ready-to-paste Codex prompt:

```text
Work on main only. ACTIVE BATCH: Batch 72 - Execution Resilience Stack. Implement shared recovery/resilience logic only. Do not rebuild Today or Reviews. Report changed files and validation.
```

## Future Batch Detail Standard

The detailed maturity gate model, dependency map, scenario fixtures, safe undo categories, external surface proof gates, performance strategy, and batch template live in [Ambitions_2_0_RC_Maturity_Plan.md](Ambitions_2_0_RC_Maturity_Plan.md).

Every future batch below inherits the required template:

- Purpose, user-facing promise, maturity gate advanced, smallest useful v1 or mature target.
- Sources of truth consumed, receipt/explanation produced, correction path, undo/safety boundary where relevant, failure/degraded state.
- Performance budget, accessibility requirement, no-fake-precision boundary, indispensability scenario improved.
- Likely files/areas affected, dependencies, out-of-scope items, validation requirements, concrete acceptance criteria, and ready-to-paste Codex prompt.

The compact batch definitions below are canonical sequencing. The active-batch implementation prompt must expand the inherited template before edits.

## Phase A - Daily Value, Shell, Activation

Milestone A starts here. Goal: prove the daily operating loop without starting broad future systems.

### Batch 73 - Today 2.0 / Daily Operating Contract v1

- Purpose / promise: Transform Today into the user's current agreement with reality: one protected must-do, one best next move, one intentionally-not-today item, one recovery fallback, one reason this matters, and one Action Closure entry path.
- Maturity gate advanced: Gate 2 for Daily Operating Contract, One Move Doctrine, Save the Day entry, Attention Shield, Anti-Plan / Not Today, and Ambient Status Orb candidate.
- Sources consumed: Canonical Now State, Command Pipeline, Goal Believability, Execution Resilience, Recommendation Explanation, Rich Panel Visual System.
- Receipt/explanation: why-this-now explanation and Action Closure entry point; no broad receipt system ownership.
- Correction / undo / degraded state: user can change the suggested move, recover when no move fits, and see calendar-denied/manual fallback truth.
- Performance / accessibility: Today top-level remains one hero plus one or two support panels; no dashboard clutter or expensive scroll animation.
- Dependencies: Batches 63, 67, 68, 71, and 72 complete.
- Out of scope: Goals/Plan/You redesign, global chrome implementation beyond safe Today consumption, widgets, sync, full Path Builder, Batch 74 shell work.
- Concrete acceptance criteria: Today shows exactly the daily contract elements above; urgent outside-lens items are not hidden; copy avoids engine names; no top-level IA changes; Batch 73 remains not closed until validated.
- Ready prompt: Implement only Batch 73 Today Daily Operating Contract v1 on main; do not start Batch 74, do not change top-level IA, and report validation truthfully.

### Batch 74 - Global Shell Chrome and Visual Alignment

- Purpose / promise: Unify app-level shell/header/bottom-tab visual presentation before remaining major surface redesigns consume it.
- Maturity gate advanced: Gate 2 for Global Chrome, Mode Lens, Continuity Ribbon, Action Closure Tray placement, Ambient Status Orb placement, Life Graph Breadcrumb rules, Mission Control Lanes rules, Proof Rail rules, Trust Badge treatment, and Save the Day placement.
- Sources consumed: Visual System, design-system spec, Accessibility Nutrition, Appearance Studio, Today 2.0 output.
- Receipt/explanation: shell-level receipt placement rules only; no new product logic.
- Correction / undo / degraded state: Appearance Studio and accessibility preferences remain respected; Reduce Motion has non-motion state clarity.
- Performance / accessibility: near-black navy canvas, warm dark premium interface, amber active accent, muted blue-gray inactive states, high contrast, no excessive blur stacking, no hard-coded shell colors.
- Dependencies: Batches 62, 63, 64, and 73 complete.
- Out of scope: tab IA changes, tab renames, restored Insights/Profile/Habits top-level labels, hidden navigation, second command pipeline, generic toast system, broad surface redesign.
- Concrete acceptance criteria: Today / Goals / Capture / Plan / You remain the only top-level tabs; Capture remains singular; shell tokens centralize chrome styling; global chrome includes Mode Lens, Continuity Ribbon, Action Closure Tray, Save the Day entry, Ambient Status Orb, Life Graph Breadcrumb, Mission Control Lanes, Not Today / Anti-Plan strip, Proof Rail, and Trust Badge rules.
- Ready prompt: Implement only Batch 74 global chrome and visual alignment; preserve Today / Goals / Capture / Plan / You and do not start product logic for later batches.

### Batch 75 - Activation Contract and First-Run Promise Spec

- Purpose / promise: Define the first-run promise without falsely teaching unbuilt systems.
- Maturity gate advanced: Gate 1 for Activation Contract, first meaningful goal, first Today Contract setup, first recovery example, first explanation receipt, and first trust/export message.
- Dependencies: Batches 73-74 complete.
- Out of scope: full onboarding implementation, new core engines, sync claims, and user-facing Accessibility Nutrition claims.
- Concrete acceptance criteria: activation copy maps to built or scheduled surfaces; first-run promises are local-first and manual-first; no unverified AI, sync, or external surface claims.
- Ready prompt: Plan and implement only the Activation Contract spec surfaces for Batch 75; keep promises truthful to current implementation and queued canon.

### Batch 76 - Daily Loop Alpha QA and Performance Baseline

- Purpose / promise: Prove the daily loop is useful, calm, and fast enough before shared object foundations expand.
- Maturity gate advanced: Gate 5 for Today, global chrome, activation, Action Closure entry path, and Mode Lens v1.
- Dependencies: Batches 73-75 complete.
- Out of scope: new feature systems, broad UI transformation, sync, external surfaces.
- Concrete acceptance criteria: focused scenario proof for missed day/week, low-energy day, calendar denied, and urgent deadline; performance baseline recorded without claiming unmeasured numbers; accessibility checklist updated.
- Ready prompt: Run Batch 76 daily loop QA and performance baseline only; fix only issues required to make the current loop truthful and stable.

## Phase B - Shared Object And Trust Foundations

Goal: build shared object/trust foundations before broad surface consumption.

### Batch 77 - Life Graph v1 Minimal Object Relationships

- Purpose / promise: Establish one local relationship layer for goal, action, capture, commitment, waiting item, proof/evidence, resource/link/file, decision, correction, and receipt.
- Maturity gate advanced: Gate 1 for Life Graph, Life Graph Breadcrumb data, and Mission Control Lanes foundation.
- Dependencies: Batches 65, 66, 68, 69, 71, 72, and 76 complete.
- Out of scope: broad UI redesign, Path Builder UI, sync backend logic, external integrations, destructive migrations.
- Concrete acceptance criteria: no feature-specific relationship store is introduced; persistence is additive and export/import effects are documented; tests cover relationship integrity and correction-ready references.
- Ready prompt: Implement only Batch 77 Life Graph v1 minimal relationships; keep changes additive, tested, and free of broad UI claims.

### Batch 78 - Proof and Resource Graph v1

- Purpose / promise: Make proof and resources first-class relationship objects without fake progress theater.
- Maturity gate advanced: Gate 1 for Resource Graph, Proof of Progress, Proof Rail Engine foundation, proof types, resource links, evidence categories, and proof/export implications.
- Dependencies: Batch 77 complete.
- Out of scope: dense artifact dashboards, external provider integrations, unverified file-provider claims.
- Concrete acceptance criteria: proof can attach to goals/actions/reviews/paths; Proof Rail data is shared; qualitative proof states avoid fake precision; manual resource entry works.
- Ready prompt: Implement only Batch 78 Proof and Resource Graph v1; preserve manual-first resource/proof workflows and avoid dashboard density.

### Batch 79 - Commitment, Waiting Room, and Promise Ledger v1

- Purpose / promise: Keep waiting-on-people and commitments visible without polluting Today.
- Maturity gate advanced: Gate 1 for Commitments, Waiting Room, Promise Ledger, lightweight people relationships, and Social Load Meter only as a lightweight qualitative signal under Commitments / Waiting / Promise Ledger.
- Dependencies: Batches 77-78 complete.
- Out of scope: household/shared collaboration, contact-provider integration, social automation.
- Concrete acceptance criteria: waiting items are findable, lower Today pressure appropriately, attach to Life Graph, and remain manually useful without external data.
- Ready prompt: Implement only Batch 79 commitments/waiting foundation; keep people data local, manual-first, and non-collaborative.

### Batch 80 - Action Closure and Receipt System v1

- Purpose / promise: Every meaningful command can answer what happened, what changed, why, what is next, what can be undone, and what can be corrected.
- Maturity gate advanced: Gate 1 for Action Closure Layer, receipt model, Action Closure Tray integration points, Trust Ledger handoff, and external receipt format.
- Dependencies: Batches 65, 66, 68, 70, 72, 74, and 77 complete.
- Out of scope: automatic scheduling, generic toast spam, sync backend implementation, external surface productization.
- Concrete acceptance criteria: receipt states include created, changed, scheduled, moved, attached, exported, prepared, completed, failed safely, needs confirmation, and undo available; unsupported commands fail safely without success history.
- Ready prompt: Implement only Batch 80 Action Closure v1 and receipt contracts; do not productize external surfaces or broad automation.

### Batch 81 - Safe Automation Boundary and Undo Rules

- Purpose / promise: Define what Ambitions may suggest, prepare, confirm, execute, or never automate.
- Maturity gate advanced: Gate 1 for Safe Automation Boundary, safe undo categories, confirmation-required categories, destructive trust boundaries, and user-facing automation controls.
- Dependencies: Batch 80 complete.
- Out of scope: cloud AI, unconfirmed automation, destructive migrations, silent rescheduling.
- Concrete acceptance criteria: safe undo and confirmation-required lists from the RC Maturity Plan are encoded in docs/tests or contracts; calendar writes, exports, sync conflict resolution, deletion, external App Intent actions, memory forgetting, broad reflows, and destructive trust actions require explicit safety treatment.
- Ready prompt: Implement only Batch 81 Safe Automation Boundary and undo rules; keep automation conservative and user-confirmed.

### Batch 82 - Foundation Performance and Persistence Budget Pass

- Purpose / promise: Keep the new graph, proof, waiting, receipt, and automation foundations fast and migration-safe before surface expansion.
- Maturity gate advanced: Gate 5 for foundation systems.
- Dependencies: Batches 77-81 complete.
- Out of scope: new features or surface redesign.
- Concrete acceptance criteria: graph/ledger/proof queries are bounded or projected; repeated duplicate calculations are removed; export/import and sync/conflict effects are documented; migration safety is reviewed.
- Ready prompt: Run Batch 82 foundation performance and persistence budget pass; fix only foundation risks required before core surface consumption.

## Phase C - Core Surfaces Consume Foundations

Goal: make the core operating loop visible across Goals, Plan, You, and Reviews.

### Batches 83-89

| Batch | Purpose / promise | Gate | Key dependencies | Concrete acceptance criteria |
| --- | --- | --- | --- | --- |
| 83 | Goals 2.0 makes Goals a premium ambition portfolio, not a list: hero for current ambition portfolio, Goal Lifecycle Rail, Goal Weather v1, Goal Atlas preview, Completion Archive states, Next Visible Step on every active goal card, compact lifecycle timeline, proof v1, Ambition Portfolio Manager v1, and Momentum Integrity v1 without becoming an analytics dashboard. | Gate 2 | 74, 77-82 | Goals consumes Life Graph, Proof, Action Closure, and Believability; top-level Goals keeps one hero/support hierarchy; Lifecycle Rail includes Previous, Active, Future plus Protected/Waiting/Blocked/Parked/Completed/Cancelled / Dropped state chips; every active goal card has one Next Visible Step and weather indicator; copy avoids fake percentages and engine names. |
| 84 | Goal Detail 2.0 becomes Mission Control for one goal with Path/Now/Proof/Risk/Decisions/Tasks lanes, goal-specific lifecycle timeline, Proof Spine as the vertical Proof Rail expression, Decision Trail, Milestone Cards, Kanban-lite Task Lane, connected Goal Atlas goals, dominant Next Visible Step, assumptions, Assumption Watchtower, Life Graph Breadcrumb, Weather explanation, end-state summary, and Action Closure receipts. | Gate 2 | 83 | Detail density stays object-scoped; assumptions are correctable; proof and receipts are inspectable; Milestone Cards protect the screen from endless task lists; Kanban-lite remains goal-specific with Later/Next/Doing/Waiting/Done; completed/parked/cancelled goals preserve what happened and why; no full Path Builder before Batch 97. |
| 85 | Plan 2.0 shows believable week shaping through Weekly Plan Strip, Believability Kernel, Plan Treaty, Personal Capacity Envelope, Opportunity Window Engine, Decision Debt, active-goal plan window, Next Visible Step selection, Goal Weather/proof-density believability inputs, and calendar-denied manual fallback. | Gate 2 | 70, 71, 72, 74, 80, 81 | Calendar permission remains Plan-owned; no silent calendar writes; no calendar clone UI; Plan shows why work fits or does not fit; Plan Treaty creates Decision Trail notes for major scope changes; only Next and Doing task-lane items heavily feed Today/Plan. |
| 86 | Reality Reflow v1 and Recovery Gradient turn disruption into safe mutation suggestions, Save the Day deeper handling, and Not Today / Anti-Plan integration. | Gate 2 | 85 | Broad reflows require confirmation; recovery options are explainable; lower-priority work can shrink, move, park, or review without shame. |
| 87 | You 2.0 becomes Trust Center, Constitution, memory controls, correction center, Appearance Studio preservation, and Safe Automation controls. | Gate 2 | 74, 80, 81 | You is not a junk drawer; sync/export status is truthful; Accessibility Nutrition remains unverified until Batch 115; memory controls are correction-aware. |
| 88 | Reviews v1 adds Recovery Review, Daily Receipt, Weekly Life OS Receipt, Goal Review, Memory Review, Correction Review, Review Constellation, Re-entry, and Clarity Debt without restoring Insights. | Gate 2 | 80, 83-87 | Reviews consume receipts/proof/memory confidence, produce narrative memory, and stay non-punitive; no top-level Insights tab. |
| 89 | Core Surface Integration QA and Performance Pass proves Today, Goals, Goal Detail, Plan, You, Reviews, Capture, Life Graph, Proof, Waiting, and Action Closure behave as one loop. | Gates 3 and 5 | 83-88 | Representative scenarios pass for five competing goals, missed week, wrong recommendation corrected, waiting on another person, calendar denied; performance budget and accessibility checklist updated. |

Ready prompt for each batch: Implement only the named Batch 83-89 scope on main, expand the inherited template before edits, preserve top-level IA, and do not start the next batch until validation is reported.

## Phase D - Trust, Ambient Continuity, Platform Surfaces

Goal: prove Apple-first continuity and external surfaces without fake platform claims.

### Batches 90-94

| Batch | Purpose / promise | Gate | Key dependencies | Concrete acceptance criteria |
| --- | --- | --- | --- | --- |
| 90 | Export / Import Proof and Disaster Drill verifies portable trust fallback, restore flow, export receipts, and new-phone scenario. | Gate 4 | 80, 87-89 | Export/import claims match evidence; restore scenario is documented; user can see what was exported/imported and what failed safely. |
| 91 | Apple-First Sync and Conflict Policy defines local-first sync status, conflict handling, stale state, Trust Ledger entries, and no backend requirement. | Gate 4 | 90 | No fake sync claims; conflict policy is inspectable; export/import remains fallback; non-Apple sync providers remain out of scope. |
| 92 | App Intents and Shared Container Receipts productize external actions over shared commands, snapshots, receipts, and correction-safe results. | Gate 3 | 67, 68, 80, 81, 91 | Intent results produce receipts, deep-link correctly, fail safely, do not leak private data, and do not duplicate command logic. |
| 93 | Widgets and Live Activity Ambient Continuity ship lightweight snapshot surfaces for Next Visible Step, Active Goal Timeline, Goal Portfolio, Next Milestone, Protected Goal, Weekly Plan Strip, next proof action, protected block, stale state, and denied permission. | Gate 3 | 74, 80, 92 | External surfaces are useful but not dashboards; widgets stay calm and ambient, never showing every goal; stale/trust status is visible; snapshots are lightweight; app restart behavior is covered. |
| 94 | External Surface Platform Verification and Performance Pass applies the external proof gates before production-ready claims. | Gates 5 and 6 | 92-93 | App Intents, widgets, Live Activities, and shared container behavior are verified or limitations are documented; no unverified platform claims remain. |

Ready prompt for each batch: Implement only the named Batch 90-94 scope, keep RC local-first and Apple-first, and verify external proof gates before production-ready language.

## Phase E - Long-Range Strategy And Learning Foundations

Goal: build strategic pathing and learning without black-box or external-provider requirements.

### Batches 95-100

| Batch | Purpose / promise | Gate | Key dependencies | Concrete acceptance criteria |
| --- | --- | --- | --- | --- |
| 95 | Path Intelligence Foundation / Life Path Simulation defines path families, stages, prerequisites, dependencies, proof requirements, fallback paths, and Future Self Simulator contracts. | Gate 1 | 77-89 | Path contracts are qualitative, local-first, and manual-first; HealthKit, food/calorie sync, household/shared life are out of scope. |
| 96 | Domain Path Packs and Path Fork Simulator add broad coherent packs and fork comparisons without template sprawl or fake certainty. | Gate 1 | 95 | Career, Education/Certification, Creative, Finance, Health/Fitness without HealthKit, Home/Life Admin, and solo Relationships/Personal Life are supported at safe manual-first depth. |
| 97 | Path Builder UI / Long-Range Roadmap v1 lets users inspect, compare, and adjust paths connected to daily action by expanding Goal Atlas, turning Milestone Cards into roadmap nodes, extending lifecycle timeline into long-range planning, showing Decision Trail across roadmap changes, and rolling Weekly Plan Strips into longer phases. | Gate 2 | 96 | Path Builder consumes Life Graph, Proof, Plan, Reviews, Goal Detail, Goal Atlas, milestones, lifecycle timeline, and Decision Trail; top-level tabs do not change; path density stays in drill-downs. |
| 98 | Learning and Anticipation v1 adds local pattern summaries and user-confirmed learning only. | Gate 1 | 88, 95-97 | Learning labels intelligence level; no black-box claims; recommendations cite evidence and correction paths. |
| 99 | Memory Confidence, Correction Cards, and Narrative Memory Map surface confidence, corrections, and narrative memory calmly. | Gates 2 and 4 | 88, 98 | Wrong assumptions can be corrected; never-suggest feedback is honored; memory forgetting uses safe confirmation. |
| 100 | Strategy / Learning Integration QA and Performance Pass verifies Path, learning, memory, proof, reviews, and daily decisions together. | Gates 3 and 5 | 95-99 | Scenarios include move apartments, Product transition, finish EP, pay off debt, study while working full-time; graph/path queries remain bounded. |

Ready prompt for each batch: Implement only the named Batch 95-100 scope, keep intelligence local/user-confirmed by default, and avoid external/cloud requirements for RC.

## Phase F - Mature Invention Passes

Goal: return to every major invention and make it RC-ready.

### Batches 101-112

| Batch | Mature invention audit | Gate | Concrete acceptance criteria |
| --- | --- | --- | --- |
| 101 | Life Graph Mature Relationship Audit | Gate 6 | Life Graph supports Breadcrumb, Mission Control Lanes, Proof Rail, Commitments/Waiting, Path Forks, Reviews, Memory, Trust Receipts, Action Closure, and Life OS Receipt with correction and performance proof. |
| 102 | Action Closure Mature Receipt / Undo / Trust Audit | Gate 6 | Receipts, undo-safe categories, confirmation-required categories, safe failures, calendar/export/sync/external receipts, and Trust Ledger integration are coherent across surfaces. |
| 103 | Proof-Weighted Progress and Momentum Integrity Maturity | Gate 6 | Progress uses proof rather than theater; Momentum Integrity is qualitative and explainable; proof gaps are clear and correctable. |
| 104 | Commitments, Waiting, Promise Ledger, and Social Load Maturity | Gate 6 | Waiting/commitments reduce pressure instead of hiding work; Promise Ledger remains local/manual-first; Social Load Meter remains a private, non-punitive qualitative signal, not a dashboard, score, top-level surface, high-weight engine, or inferred emotional/social judgment. |
| 105 | Believability Kernel, Constraint Gravity, and Plan Treaty Maturity | Gate 6 | Plan believability, dominant constraints, capacity, and treaty behavior are coherent across Today, Goals, Plan, Reviews, and Path. |
| 106 | Reality Reflow, Recovery Gradient, and Save the Day Maturity | Gate 6 | Reflow suggestions are safe, explainable, correctable, and never silent; Save the Day produces one believable recovery path. |
| 107 | Ambition Portfolio Manager, Goal Weather, and Goal Scope Maturity | Gate 6 | Portfolio pressure helps the next decision; mature Goal Weather avoids fake precision and explains changes; Completion Archive becomes a learning layer; cancelled/dropped goals get learning summaries; Goal Atlas is the mature portfolio view; goals with too many stuck tasks are detected; proof maturity comparison and scope maturity are correctable where safe. |
| 108 | Personal Operating Constitution and Calm Intervention Maturity | Gate 6 | Constitution violations are plain, calm, correctable, and bounded by Safe Automation Boundary; intervention never feels punitive. |
| 109 | Reviews, Life OS Receipt, and Narrative Memory Maturity | Gate 6 | Reviews consume receipts/proof/memory confidence, produce narrative memory, and feed future recommendations without becoming analytics. |
| 110 | Path Forks, Future Self Simulation, and Domain Pack Maturity | Gate 6 | Path forks and Future Self Simulation are qualitative, scenario-tested, and useful without external provider requirements. |
| 111 | Cross-Surface Continuity and Mode Lens Maturity | Gate 6 | Mode Lens works across Today, Capture, Plan, Reviews, and You without hidden navigation; Continuity Ribbon and Ambient Status Orb are coherent. |
| 112 | Mature Invention Performance Pass | Gate 5 | Top-level screens, rich panels, graph/ledger/proof/trust queries, widgets, Live Activities, and navigation meet the documented performance budgets or have blockers recorded. |

Ready prompt for each batch: Audit and mature only the named Batch 101-112 invention set, fixing gaps required for RC readiness and documenting any Devan decision needed for deferral.

## Phase G - Onboarding, Accessibility, Release

Goal: verify the full product as a release candidate.

### Batches 113-120

| Batch | Purpose / promise | Gate | Concrete acceptance criteria |
| --- | --- | --- | --- |
| 113 | Onboarding, Empty States, and Returning User Continuity make first-run, degraded, empty, and re-entry states truthful after mature systems exist. | Gate 4 | No stale/demo copy; no false education; returning after a month and missed-week scenarios land calmly. |
| 114 | Representative Scenario Fixtures and Indispensability QA v1 turns canon scenarios into reusable validation scripts/checklists. | Gate 6 | Scenarios cover apartments, Product transition, EP, new baby, debt, certification, missed week, five goals, calendar denied, export restore, wrong recommendation, waiting, urgent missed deadline, and low-energy day. |
| 115 | Accessibility Verification and User-Facing Nutrition Facts verifies VoiceOver, Dynamic Type, Reduce Motion, contrast, tap targets, rich panels, global chrome, external surfaces, receipts, and correction controls before user-facing claims. | Gates 5 and 6 | You -> Accessibility summary publishes only verified or conservative claims with evidence. |
| 116 | Visual Polish, Appearance Studio, and Shell Regression protects warm premium identity, token discipline, Appearance Studio, top-level calmness, and no tab IA drift. | Gate 6 | Today / Goals / Capture / Plan / You remain; Capture is singular; no restored top-level Insights/Profile/Habits; no hard-coded shell colors. |
| 117 | Offline, Data Safety, Migration, and Reliability Hardening verifies local/offline behavior, portable restore, sync conflict safety, additive migrations, Trust Ledger, and no lost data. | Gates 4 and 6 | No fake sync claims; no data-loss paths; degraded states and manual fallbacks are clear. |
| 118 | Final Performance, Memory, and Responsiveness Pass verifies launch/navigation/scroll/external snapshots/graph query responsiveness before RC audit. | Gate 5 | Performance results or blockers are recorded; no expensive always-on animations or heavy external computations remain. |
| 119 | Ambitions 2.0 RC Audit checks every major invention against Gate 6 and produces a precise blocker or deferral-decision list. | Gate 6 | All major inventions are mature by RC or explicitly escalated to Devan; no hidden v1 caveats. |
| 120 | Ambitions 2.0 Release Candidate Lock freezes RC truth after validation. | Gate 6 | Docs, copy, registry, validation evidence, release notes, and product claims match built behavior; no new feature work starts. |

Ready prompt for each batch: Execute only the named Batch 113-120 release-readiness scope, preserve completed history, and do not declare RC lock until validation evidence supports it.
