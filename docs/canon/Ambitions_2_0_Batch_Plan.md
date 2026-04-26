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
| 73 | Today 2.0 / Daily Operating Contract | Primary loop transformation |
| 74 | Global Shell Chrome and Visual Alignment | Primary loop transformation |
| 75 | Life Graph v1 and Object Relationships | Primary loop transformation |
| 76 | Action Closure and Receipt System | Primary loop transformation |
| 77 | Goals and Goal Detail 2.0 | Primary loop transformation |
| 78 | Plan 2.0 and Reality Reflow | Primary loop transformation |
| 79 | You 2.0, Personal Operating Constitution, and Trust Center | Primary loop transformation |
| 80 | Reviews and Review Constellation | Primary loop transformation |
| 81 | Sync / Export / Import Trust | Apple platform completion |
| 82 | App Intents and Shared Container | Apple platform completion |
| 83 | Widgets and Live Activity v1 | Apple platform completion |
| 84 | Path Intelligence Foundation | Full path intelligence |
| 85 | Path Builder / Life Path Simulation UI | Full path intelligence |
| 86 | Learning and Anticipation | Learning, onboarding, and release hardening |
| 87 | Onboarding, Empty States, and Returning User Continuity | Learning, onboarding, and release hardening |
| 88 | Accessibility Verification and User-Facing Nutrition Facts | Learning, onboarding, and release hardening |
| 89 | Release Hardening / Indispensability QA | Learning, onboarding, and release hardening |

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
- Implementation notes: Internal checklist first; no user-facing claims until Batch 88 verification.
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

## Batch 73 - Today 2.0 / Daily Operating Contract

- Purpose: Transform Today into the user's current agreement with reality.
- Exact scope: Daily Operating Contract, Today Contract, Daily Operating Brief, one protected must-do, one best next move, one intentionally-not-today item, one recovery fallback, one reason this matters, one Action Closure entry path, Friction Radar v1, Recovery Autopilot entry, Save the Day entry if safe, Attention Shield, Anti-Plan / Not Today summary, Ambient Status Orb candidate, One Move Doctrine, rich visual quality bar, and Mode Lens awareness without hidden navigation.
- Dependencies: Batches 63, 67, 68, 71, and 72 complete.
- Out-of-scope items: Goals/Plan/You redesign, global chrome implementation beyond safe Today consumption, widgets, sync, full Path Builder.
- Completion definition: Today is calm, believable, recovery-aware, receipt-aware, and useful as the first step in the operating loop without closing any other batch.

## Batch 74 - Global Shell Chrome and Visual Alignment

- Purpose: Unify app-level shell/header/bottom-tab visual presentation with the Ambitions 2.0 design language before the remaining major surface redesigns.
- Exact scope: near-black navy shell canvas, premium bottom tab bar, amber active tab treatment, muted blue-gray inactive treatment, shared safe-area and scroll-edge behavior, centralized spacing, centralized shell tokens only, top-level and detail header patterns, sheet/modal header pattern, optional Continuity Ribbon v1, Not Today / Anti-Plan strip candidate, stale capture/status candidate, Action Closure Tray presentation, Mode Lens, Ambient Status Orb placement rules, Life Graph Breadcrumb rules, Mission Control Lanes rules, Proof Rail rules, Trust Badge rules, Save the Day entry placement rules, Appearance Studio preservation, and Accessibility Nutrition handoff.
- Dependencies: Batches 62, 63, 64, and 73 complete.
- Non-goals: no tab IA changes, no tab renames, no restored Insights/Profile/Habits top-level labels, no full Today/Goals/Plan/You redesigns, no product logic, no hidden navigation, no second command pipeline, no generic toast system, no hard-coded screen colors, and no Appearance Studio or accessibility bypass.
- Completion definition: Later surface batches can consume one coherent shell/chrome system.

## Batch 75 - Life Graph v1 and Object Relationships

- Purpose: Establish Life Graph v1 as the shared object relationship layer before remaining surface expansion.
- Exact scope: goals, milestones, actions, blockers, people, commitments, waiting items, resources, evidence, windows, constraints, decisions, memories, corrections, receipts, dependencies, prerequisites, proof types, Resource Graph v1, Promise Ledger / lightweight people relationships, Commitments and Waiting Room relationship model, Life Graph Breadcrumb data, Proof Rail data, and Mission Control Lens foundations.
- Dependencies: Batches 65, 66, 68, 69, 71, 72 complete.
- Out-of-scope items: full Path Builder UI, sync backend logic, external integrations, and broad surface redesign.
- Completion definition: Capture, Goals, Plan, You, Reviews, Path Intelligence, Action Closure, Proof of Progress, and Waiting Room can use one relationship model.

## Batch 76 - Action Closure and Receipt System

- Purpose: Establish Action Closure as a shared trust system before later surfaces and external actions consume it.
- Exact scope: receipt model, result states, undo eligibility, correction entry, why-changed linkage, safe failure states, external action receipt format, calendar write receipts, export/import receipts, Trust Ledger handoff, Safe Automation Boundary v1, and premium Action Closure Tray integration points.
- Dependencies: Batches 65, 66, 68, 70, 72, and 74 complete.
- Out-of-scope items: automatic scheduling, generic toast spam, broad automation, sync backend implementation, and external surface productization.
- Completion definition: meaningful commands can answer what happened, what changed, why, what is next, what can be undone, and what can be corrected.

## Batch 77 - Goals and Goal Detail 2.0

- Purpose: Transform Goals and Goal Detail around portfolio clarity, proof, assumptions, constraints, and living goal containers.
- Exact scope: Goal Scope Governor, Goal Health MRI, Path Filmstrip, Goal Contract, Assumption Ledger / Assumption Watchtower, Proof of Progress v1, Proof-Weighted Progress, active/passive/waiting/blocked/parked/protected/completed states, Ambition Portfolio Manager v1, Goal Weather, Momentum Integrity Engine, Mission Control lanes v1 (Path, Now, Proof, Risk), Life Graph Breadcrumb, Proof Rail, Ambient Status Orb for goal health, and Action Closure receipts for goal changes.
- Dependencies: Batches 63, 66, 71, 74, 75, and 76 complete.
- Out-of-scope items: full Path Builder, Plan redesign, sync, and unsupported path-family expansion.
- Completion definition: Goals shows what is active, at risk, blocked, parked, proven, or protected without becoming an analytics dashboard.

## Batch 78 - Plan 2.0 and Reality Reflow

- Purpose: Transform Plan into the calendar-aware believability and Reality Reflow workspace.
- Exact scope: Plan Negotiator, Window Magnetism, Opportunity Window Engine, Ambition Debt, Decision Debt Engine, Conflict Court, Calendar Boundary Contract, Plan Treaty, Personal Capacity Envelope, Context Switching Toll, Constraint Gravity Engine, Believability Kernel consumption, Save the Day deeper handling, manual availability fallback when calendar is denied, Reality Reflow Engine v1, confirmed calendar writes with receipts and undo where safe, Not Today / Anti-Plan integration, Action Closure receipts, Ambient Status Orb for week pressure, and no calendar clone UI.
- Dependencies: Batches 63, 70, 71, 72, 74, and 76 complete.
- Out-of-scope items: silent rescheduling, automatic calendar writes, sync, widgets, full Reviews rebuild.
- Completion definition: Plan prevents overcommitment, reflows reality safely, and preserves Plan-owned calendar permission.

## Batch 79 - You 2.0, Personal Operating Constitution, and Trust Center

- Purpose: Transform You into the control surface for trust, memory, constitution, correction, privacy, and Appearance Studio.
- Exact scope: Trust Center, Memory Receipts, Correction Center, Personal Operating Constitution, Constitution Violation behavior, Disaster Drill entry, local-first/privacy/calendar-data explanations, sync/export status placeholders until implementation, Trust Badge / Trust status treatment, memory correction/forgetting controls where appropriate, Appearance Studio preservation, Safe Automation Boundary controls where appropriate, and Trust Ledger consumption.
- Dependencies: Batches 63, 64, 65, 66, 74, and 76 complete.
- Out-of-scope items: verified Accessibility Nutrition summary, unverified sync claims, actual sync backend, and unrelated settings sprawl.
- Completion definition: The user can trust and tune the system without You becoming a junk drawer.

## Batch 80 - Reviews and Review Constellation

- Purpose: Turn reviews into tactical recovery loops and narrative memory artifacts instead of analytics.
- Exact scope: Recovery Review, 90-second Review, Weekly Life OS Receipt, Goal Review, Pattern Review, Memory Review, Correction Review, Why Changed Log, Review-to-Action Compiler, Review Constellation, Pattern Reflection, anti-guilt missed-week recovery review, Outcome Receipts consumption, Proof of Progress consumption, Memory Receipts consumption, Narrative Memory Map, Re-entry Engine, Clarity Debt Engine, and rich-panel insight styling.
- Dependencies: Batches 65, 66, 76, 77, 78, and 79 complete.
- Out-of-scope items: restored top-level Insights tab, generic analytics dashboard, sync/export implementation.
- Completion definition: Reviews explain what changed, what worked, what repeated, what Ambitions learned, what the user corrected, what remains believable, and what should be protected next.

## Batch 81 - Sync / Export / Import Trust

- Purpose: Implement trustable Apple-first continuity and export/import fallback.
- Exact scope: export/import proof, Apple-first sync, conflict policy, disaster drill handoff, user-facing trust receipts, Trust Badge states, Trust Ledger entries, cross-device ambient continuity, new-phone/export-restore scenario, stale state truth, and no unverified sync claims.
- Dependencies: Batches 65, 76, 79 complete and data model evidence verified.
- Out-of-scope items: non-Apple sync providers, widgets, HealthKit, and unverified platform claims.
- Completion definition: Sync/export/import claims match implementation evidence and preserve user trust.

## Batch 82 - App Intents and Shared Container

- Purpose: Productize App Intents and shared container boundaries over stable commands, receipts, and external continuity.
- Exact scope: external action receipts, correction-safe commands, External Continuity Contract, `capture thought`, `what should I do now?`, `I am stuck`, `move this later`, `make it smaller`, `why this?`, Action Closure result states, stale/failed-safe command states, privacy-safe payloads, and no duplicate command logic.
- Dependencies: Batches 67, 68, 76, and 81 complete or explicitly verified not required for local-only intent scope.
- Out-of-scope items: widgets/Live Activities UI and share extension expansion unless explicitly scoped.
- Completion definition: App Intents land in canonical shell context and return trustworthy results.

## Batch 83 - Widgets and Live Activity v1

- Purpose: Ship simple polished first versions of widgets and Live Activities as ambient continuity surfaces.
- Exact scope: Lock Screen Next Move, Protected Block Live Activity, stale snapshot handling, denied-permission behavior, external surface validation gate, ambient continuity, Action Closure handoff where possible, Trust/status handling for stale data, and no mini-dashboard clutter.
- Dependencies: Batches 67, 68, 74, and 82 complete.
- Out-of-scope items: complex external controls, non-phone hardware, Watch/TV, and unverified platform claims.
- Completion definition: External surfaces render useful current state, expose stale/trust status, and land correctly in app as far as the environment can verify.

## Batch 84 - Path Intelligence Foundation

- Purpose: Establish Life Path Simulation contracts for broad coherent path families.
- Exact scope: Path Forks, Path Fork Simulator contracts, Domain Path Pack contracts, people/stakeholders, proof types, dependencies, prerequisites, fallback paths, pause/limited-time simulations, Future Self Simulator, `what if I pause?`, and `what can I do with 90 minutes?`.
- Dependencies: Batches 65, 66, 71, 75, 77, and 78 complete.
- Out-of-scope items: Path Builder UI, HealthKit, food/calorie sync, household/shared life, and unsupported domain specificity.
- Completion definition: Path contracts support simulation without fake certainty or template sprawl.

## Batch 85 - Path Builder / Life Path Simulation UI

- Purpose: Surface Life Path Simulation in Path Builder and long-range Goal Detail UI.
- Exact scope: Domain Path Packs visible in UI, path-specific Mission Control lanes, proof/resource/people/waiting integration, Path Fork UI, Future Self Simulator UI, pause and limited-time simulations, long-range visual roadmap using the established visual system, Life Graph Breadcrumb, Proof Rail, and Ambient Status Orb for path health/pressure.
- Dependencies: Batch 84 complete.
- Out-of-scope items: new path families beyond approved scope, HealthKit, household/shared life.
- Completion definition: Users can inspect, compare, and adjust long-range paths connected to daily action.

## Batch 86 - Learning and Anticipation

- Purpose: Add local, evidence-derived learning and anticipation without black-box claims.
- Exact scope: Correction Cards, Memory Receipts learning loop, Memory Confidence Engine, wrong-assumption feedback, never-suggest-this-again feedback, user-confirmed learning only, Mode Lens learning boundaries where relevant, Narrative Memory Map consumption, and no black-box claims.
- Dependencies: Batches 65, 66, 75, 80, 84, and 85 complete.
- Out-of-scope items: retrieval expansion, unverified automation, HealthKit, household/shared life.
- Completion definition: Learning influences recommendations only when evidence and correction paths are clear.

## Batch 87 - Onboarding, Empty States, and Returning User Continuity

- Purpose: Make first-run, empty, degraded, and returning-user states match the operating-loop canon.
- Exact scope: Activation Contract, Return Path, Re-entry Engine consumption, first meaningful goal, first Today Contract, first recovery example, first explanation receipt, first Action Closure receipt, first trust/export message, introduction to singular Capture, Mode Lens introduction only if implemented, and empty-state rules for all primary surfaces.
- Dependencies: Primary loop, surface, and trust batches complete enough to avoid false education.
- Out-of-scope items: new core systems and release hardening closure.
- Completion definition: New and returning users understand what to do without stale/demo copy or guilt.

## Batch 88 - Accessibility Verification and User-Facing Nutrition Facts

- Purpose: Verify accessibility and publish truthful You -> Accessibility summary only after evidence exists.
- Exact scope: user-facing Accessibility Nutrition Facts only after verified, visual-system contrast verification, Dynamic Type / VoiceOver / Reduce Motion / tap target checks for rich panels, global chrome, Mode Lens, Continuity Ribbon, Action Closure Tray, bottom tabs, top headers, receipt/correction controls, widgets, and Live Activity if present.
- Dependencies: Batches 64 and 83 complete.
- Out-of-scope items: new product features and unverified claims.
- Completion definition: Accessibility Nutrition claims are backed by audit evidence or remain conservative/deferred.

## Batch 89 - Release Hardening / Indispensability QA

- Purpose: Close Ambitions 2.0 release readiness and test whether the product feels indispensable.
- Exact scope: Indispensability QA, global chrome QA, shell consistency QA, rich-panel visual consistency QA, Appearance Studio regression QA, docs truth, performance review, release docs, validation closure, and scenario scripts for missed day/week, calendar denied, new phone/export restore, five competing goals, urgent deadline, vague capture, wrong recommendation, blocked goal, returning after a month, widget stale state, Live Activity interrupted, VoiceOver/Dynamic Type, move apartments in 45 days, transition into Product in 12 months, finish an EP in 90 days, plan around a new baby, pay off debt while preserving rent, and study for certification while working full-time.
- Dependencies: Batches 61-88 complete.
- Out-of-scope items: new systems, new external surfaces, deferred scope, and unverified App Store claims.
- Completion definition: Ambitions 2.0 is release-candidate ready or has a precise blocker list.
