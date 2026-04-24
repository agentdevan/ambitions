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
| 73 | Today 2.0 Rich Execution Center | Primary surface transformation |
| 74 | Goals and Goal Detail 2.0 | Primary surface transformation |
| 75 | Plan 2.0 Calendar-Aware Believability Workspace | Primary surface transformation |
| 76 | You 2.0, Reviews, Memory, and Trust | Primary surface transformation |
| 77 | Contextual Insights and Review System | Primary surface transformation |
| 78 | Apple-First Sync and Export/Import | Apple platform completion |
| 79 | App Intents and Shared Container | Apple platform completion |
| 80 | Widgets and Live Activity v1 | Apple platform completion |
| 81 | Path Intelligence Foundation | Full path intelligence |
| 82 | Path Builder and Long-Range Path UI | Full path intelligence |
| 83 | Learning and Anticipation v1 | Learning, onboarding, and release hardening |
| 84 | Onboarding, Empty States, and Returning User Continuity | Learning, onboarding, and release hardening |
| 85 | Accessibility Verification and User-Facing Nutrition Facts | Learning, onboarding, and release hardening |
| 86 | Ambitions 2.0 Release Hardening | Learning, onboarding, and release hardening |

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
- Implementation notes: Internal checklist first; no user-facing claims until Batch 85 verification.
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

## Batch 73 - Today 2.0 Rich Execution Center

- Purpose: Transform Today into the rich execution center.
- Exact scope: Today hero decision panel, supporting panels, Now State, recovery, contextual insight hooks.
- Likely areas affected: Today feature, shared panels, view models, tests.
- Dependencies: Batches 63, 67, 68, 72 complete.
- Implementation notes: Today consumes shared systems; no duplicated current-state logic.
- UI/UX expectations: One dominant hero panel, one or two supporting panels, deeper content below fold.
- Acceptance criteria: Today is calm, actionable, explainable, and recovery-aware.
- Testing requirements: Targeted Today tests, UI tests, native build, relevant full tests, manual simulator review.
- Out-of-scope items: Goals/Plan/You redesign, widgets.
- Risk notes: Avoid dense task-list dashboard behavior.
- Completion definition: Today matches 2.0 visual/product architecture.
- Ready-to-paste Codex prompt:

```text
Work on main only. ACTIVE BATCH: Batch 73 - Today 2.0 Rich Execution Center. Rebuild only Today using the shared panel system, Now State, Command Pipeline, and Execution Resilience Stack. Do not redesign other tabs or start widgets. Report changed files and validation.
```

## Batch 74 - Goals and Goal Detail 2.0

- Purpose: Transform Goals and Goal Detail around goal health, path progress, and explanations.
- Exact scope: Goals overview, Goal Detail rich panels, explanation surfaces, path preview hooks.
- Likely areas affected: Goals feature, Goal Detail, shared panels, tests.
- Dependencies: Batches 63, 66, 71 complete.
- Implementation notes: Detail may be denser; top-level Goals remains capped.
- UI/UX expectations: Goal health visible without analytics density; explanations available without clutter.
- Acceptance criteria: Goals and Goal Detail present believable progress and why-this reasoning.
- Testing requirements: Targeted Goals/Goal Detail tests, UI tests, native build, manual review.
- Out-of-scope items: Full path builder, Plan redesign, sync.
- Risk notes: Avoid long-range promises before Batch 81/82.
- Completion definition: Goals surfaces match 2.0 architecture using existing systems.
- Ready-to-paste Codex prompt:

```text
Work on main only. ACTIVE BATCH: Batch 74 - Goals and Goal Detail 2.0. Transform only Goals and Goal Detail with rich panels, goal health, and explanation hooks. Do not build the full Path Builder or redesign Plan. Report changed files and validation.
```

## Batch 75 - Plan 2.0 Calendar-Aware Believability Workspace

- Purpose: Transform Plan into the calendar-aware believability workspace.
- Exact scope: Plan hero, open windows, fixed/flexible blocks, rituals/habit absorption, calendar-aware actions, recovery/review prompts.
- Likely areas affected: Plan feature, calendar services, shared panels, tests.
- Dependencies: Batches 63, 70, 71, 72 complete.
- Implementation notes: Permission actions are explicit and Plan-owned.
- UI/UX expectations: Calm shaping workspace, not a calendar clone.
- Acceptance criteria: Plan works without permission and improves with calendar access.
- Testing requirements: Targeted Plan/calendar tests, UI tests, native build, manual permission review.
- Out-of-scope items: Apple-first sync, widgets, full Reviews rebuild.
- Risk notes: Avoid calendar data overcollection and habit standalone resurrection.
- Completion definition: Plan 2.0 is usable, believable, and permission-safe.
- Ready-to-paste Codex prompt:

```text
Work on main only. ACTIVE BATCH: Batch 75 - Plan 2.0 Calendar-Aware Believability Workspace. Transform only Plan using Reality Model, calendar read/write, believability, rituals, and recovery. Do not add sync/widgets or rebuild You. Report changed files and validation.
```

## Batch 76 - You 2.0, Reviews, Memory, and Trust

- Purpose: Transform You into trust, memory, reviews, preferences, and export/sync entry.
- Exact scope: You shell, Reviews home, Memory summaries, trust panels, preferences, Accessibility placeholder state.
- Likely areas affected: You/Profile feature, Reviews routes, shared panels, tests.
- Dependencies: Batches 63, 65, 66 complete.
- Implementation notes: User-facing Accessibility Nutrition remains unverified until Batch 85.
- UI/UX expectations: Utility surface is calm and not core workflow.
- Acceptance criteria: You owns reviews, memory, trust, and preferences without overloading top level.
- Testing requirements: Targeted You/Profile/Review tests, UI tests, native build.
- Out-of-scope items: Verified Accessibility Nutrition summary, sync implementation, release hardening.
- Risk notes: Avoid claiming sync/accessibility support beyond evidence.
- Completion definition: You 2.0 owns trust and review entry points.
- Ready-to-paste Codex prompt:

```text
Work on main only. ACTIVE BATCH: Batch 76 - You 2.0, Reviews, Memory, and Trust. Transform only You/Profile, review entry, memory summaries, and trust panels using existing shared systems. Do not claim verified Accessibility Nutrition or implement sync. Report changed files and validation.
```

## Batch 77 - Contextual Insights and Review System

- Purpose: Complete Insights demotion into contextual surfaces and reviews.
- Exact scope: Today insight panels, Plan evidence prompts, Goal Detail explanation links, You -> Reviews, `Why This` / `Why Changed` sheets.
- Likely areas affected: Today, Plan, Goals, You/Reviews, shared explanation UI, tests.
- Dependencies: Batches 66, 73, 74, 75, 76 complete.
- Implementation notes: Do not recreate Insights as a top-level tab.
- UI/UX expectations: Insight appears where decisions happen.
- Acceptance criteria: Insight destinations match demotion architecture.
- Testing requirements: Targeted cross-surface review/explanation tests, UI tests, native build.
- Out-of-scope items: New analytics tab, sync, widgets.
- Risk notes: Cross-surface work can sprawl; keep to insight/review routing.
- Completion definition: Insights is fully productized outside top-level nav.
- Ready-to-paste Codex prompt:

```text
Work on main only. ACTIVE BATCH: Batch 77 - Contextual Insights and Review System. Implement only contextual insight/review placement after Insights demotion. Do not recreate a top-level Insights tab or build unrelated analytics. Report changed files and validation.
```

## Batch 78 - Apple-First Sync and Export/Import

- Purpose: Implement trustable Apple-first sync direction and export/import fallback.
- Exact scope: Verified data model boundary, sync status, conflict policy, export/import UX and tests.
- Likely areas affected: persistence, services, You trust surfaces, tests, release/privacy docs.
- Dependencies: Batch 61 verification and Batch 65 ledger complete; relevant data model evidence complete.
- Implementation notes: Export/import is required even if sync is available.
- UI/UX expectations: Calm trust panels with clear local/synced/export states.
- Acceptance criteria: Sync and export/import claims match implementation evidence.
- Testing requirements: Targeted persistence/export/import/sync-boundary tests, native build, relevant full tests.
- Out-of-scope items: Non-Apple sync providers, widgets, HealthKit.
- Risk notes: Do not ship sync behavior before conflict policy is explicit.
- Completion definition: Apple-first sync/export trust layer is implemented or precisely bounded by verified status.
- Ready-to-paste Codex prompt:

```text
Work on main only. ACTIVE BATCH: Batch 78 - Apple-First Sync and Export/Import. Implement only verified Apple-first sync/export/import trust scope after data model verification. Preserve export/import as fallback. Do not add non-Apple sync or external surfaces. Report changed files and validation.
```

## Batch 79 - App Intents and Shared Container

- Purpose: Productize App Intents and shared container boundaries over stable commands.
- Exact scope: App Intents, shared container data, route payloads, command pipeline integration, tests.
- Likely areas affected: App Intents target, shared models, routing, project.yml, tests.
- Dependencies: Batches 67, 68, 78 complete or explicitly verified not required for local intent scope.
- Implementation notes: Intents execute through Command Pipeline.
- UI/UX expectations: External entry lands in canonical shell context.
- Acceptance criteria: Intents are useful, safe, and do not duplicate command logic.
- Testing requirements: XcodeGen, native build, intent/routing tests, relevant full tests.
- Out-of-scope items: Widgets/Live Activities UI, share extension unless explicitly in scope.
- Risk notes: Shared container payloads must remain privacy-safe.
- Completion definition: App Intents and shared container are stable for external surfaces.
- Ready-to-paste Codex prompt:

```text
Work on main only. ACTIVE BATCH: Batch 79 - App Intents and Shared Container. Implement only App Intents/shared container integration through Canonical Now State and Command Pipeline. Do not build widgets or Live Activities yet. Report changed files and validation.
```

## Batch 80 - Widgets and Live Activity v1

- Purpose: Ship simple polished first versions of widgets and Live Activities.
- Exact scope: v1 widget(s), v1 Live Activity, payloads, landing routes, tests.
- Likely areas affected: widget/activity targets, shared snapshots, routing, project.yml, tests.
- Dependencies: Batches 67, 68, 79 complete.
- Implementation notes: Simple polished v1 only; consume Now State and Command Pipeline.
- UI/UX expectations: Glanceable, warm, rich panels consistent with app visual system.
- Acceptance criteria: External surfaces render useful current state and land correctly in app.
- Testing requirements: XcodeGen, native build, widget/activity tests where possible, manual platform review as available.
- Out-of-scope items: Complex external controls, non-phone hardware, Watch/TV.
- Risk notes: Avoid overpromising platform validation not run.
- Completion definition: v1 external surfaces are real, simple, and validated as far as environment allows.
- Ready-to-paste Codex prompt:

```text
Work on main only. ACTIVE BATCH: Batch 80 - Widgets and Live Activity v1. Implement only simple polished v1 widgets and Live Activity surfaces after Now State and Command Pipeline stability. Do not add advanced external behavior or non-phone hardware. Report changed files and validation.
```

## Batch 81 - Path Intelligence Foundation

- Purpose: Establish full long-range path intelligence contracts.
- Exact scope: Path families, stage models, prerequisites, readiness, alternatives, capacity/explanation hooks, tests.
- Likely areas affected: domain/services, path intelligence tests, docs.
- Dependencies: Batches 65, 66, 71 complete.
- Implementation notes: Include Career, Education / Certification, Creative, Finance, Health / Fitness without HealthKit, Home / Life Admin, Relationships / Personal Life solo only.
- UI/UX expectations: No full path builder UI yet.
- Acceptance criteria: Path contracts support broad coherent families without template sprawl.
- Testing requirements: Targeted path tests, native build, relevant full tests.
- Out-of-scope items: HealthKit, household/shared life, food/calorie sync, long-range UI.
- Risk notes: Avoid unsupported domain specificity.
- Completion definition: Path Intelligence foundation is testable and reusable.
- Ready-to-paste Codex prompt:

```text
Work on main only. ACTIVE BATCH: Batch 81 - Path Intelligence Foundation. Implement only shared long-range path intelligence contracts for the approved path families. Do not build Path Builder UI or deferred HealthKit/household/food features. Report changed files and validation.
```

## Batch 82 - Path Builder and Long-Range Path UI

- Purpose: Surface Path Intelligence in builder and long-range Goal Detail UI.
- Exact scope: Path Builder, long-range path panels, path edit/review flows, tests.
- Likely areas affected: Goals/Goal Detail, path services, shared panels, tests.
- Dependencies: Batch 81 complete.
- Implementation notes: UI consumes path contracts; it does not create path logic.
- UI/UX expectations: Detail can be denser; top-level Goals remains calm.
- Acceptance criteria: Users can inspect and adjust long-range paths connected to daily action.
- Testing requirements: Targeted path UI/tests, native build, UI tests, manual review.
- Out-of-scope items: New path families beyond approved scope, HealthKit, household/shared life.
- Risk notes: Avoid fantasy planning and excessive density.
- Completion definition: Long-range path UI is usable and grounded.
- Ready-to-paste Codex prompt:

```text
Work on main only. ACTIVE BATCH: Batch 82 - Path Builder and Long-Range Path UI. Build only Path Builder and long-range path UI over Batch 81 contracts. Do not add new path families or deferred integrations. Report changed files and validation.
```

## Batch 83 - Learning and Anticipation v1

- Purpose: Add first learning/anticipation layer from verified local behavior.
- Exact scope: Derived learning from events, anticipation signals, recommendation adjustments, tests.
- Likely areas affected: services/domain, Memory/Event Ledger, explanation, tests.
- Dependencies: Batches 65, 66, 81, 82 complete.
- Implementation notes: Learn from local evidence; user-correctable; no black-box claims.
- UI/UX expectations: Subtle panels or explanations only where useful.
- Acceptance criteria: Learning influences recommendations with explanation and correction path.
- Testing requirements: Targeted learning tests, native build, relevant full tests.
- Out-of-scope items: Retrieval expansion, HealthKit, household/shared life.
- Risk notes: Avoid claiming certainty from sparse data.
- Completion definition: v1 learning is local, explainable, and bounded.
- Ready-to-paste Codex prompt:

```text
Work on main only. ACTIVE BATCH: Batch 83 - Learning and Anticipation v1. Implement only local, evidence-derived learning and anticipation v1 with explanation support. Do not add black-box AI behavior or deferred integrations. Report changed files and validation.
```

## Batch 84 - Onboarding, Empty States, and Returning User Continuity

- Purpose: Make first-run, empty, degraded, and returning-user states match Ambitions 2.0.
- Exact scope: Onboarding, empty states, error/degraded states, re-entry continuity, permission education.
- Likely areas affected: onboarding/launch, Today, Goals, Capture, Plan, You, shared panels, tests.
- Dependencies: Primary surface batches complete.
- Implementation notes: Permission education must match Plan calendar policy and sync/export truth.
- UI/UX expectations: Warm, calm, low cognitive load, rich panels.
- Acceptance criteria: New and returning users understand what to do without stale/demo copy.
- Testing requirements: Targeted UI tests, native build, manual state review.
- Out-of-scope items: New core systems, release hardening closure.
- Risk notes: Avoid copy that claims unverified accessibility/sync/platform support.
- Completion definition: First-run and re-entry states are coherent and truthful.
- Ready-to-paste Codex prompt:

```text
Work on main only. ACTIVE BATCH: Batch 84 - Onboarding, Empty States, and Returning User Continuity. Update only onboarding, empty/degraded states, permission education, and return continuity. Do not add new core systems. Report changed files and validation.
```

## Batch 85 - Accessibility Verification and User-Facing Nutrition Facts

- Purpose: Verify accessibility and publish truthful You -> Accessibility summary.
- Exact scope: Audit five tabs, Goal Detail, Capture triage, Plan calendar flow, Why sheets, Reviews, widgets/Live Activity if present; add user-facing summary.
- Likely areas affected: accessibility records, You -> Accessibility, shared UI fixes, tests/docs.
- Dependencies: Batches 64 and 80 complete.
- Implementation notes: User-facing claims must match verification.
- UI/UX expectations: Summary is plain, calm, and specific about verified/unverified support.
- Acceptance criteria: Accessibility Nutrition claims are backed by audit evidence.
- Testing requirements: Dynamic Type, VoiceOver, Reduce Motion, contrast, tap target, gesture alternative review; automated tests where available.
- Out-of-scope items: New product features, unrelated redesign.
- Risk notes: Manual verification may require real device/simulator limits to be documented.
- Completion definition: Verified accessibility summary is live or blocked with precise unverified items.
- Ready-to-paste Codex prompt:

```text
Work on main only. ACTIVE BATCH: Batch 85 - Accessibility Verification and User-Facing Nutrition Facts. Perform and record accessibility verification, fix only scoped accessibility issues, and add user-facing You -> Accessibility summary only for verified claims. Do not add unrelated features. Report changed files and validation.
```

## Batch 86 - Ambitions 2.0 Release Hardening

- Purpose: Close Ambitions 2.0 release readiness.
- Exact scope: Regression fixes, docs truth, performance review, release docs, screenshots/store readiness notes, validation closure.
- Likely areas affected: docs, tests, small bug fixes across touched areas, release assets if required.
- Dependencies: Batches 61-85 complete.
- Implementation notes: Hardening only; no new scope.
- UI/UX expectations: Preserve 2.0 visual system and calm shell.
- Acceptance criteria: Release docs, validation, known limitations, and registry status are truthful.
- Testing requirements: XcodeGen, native build, full unit/UI tests where environment supports, archive sanity if documented, manual audit list.
- Out-of-scope items: New systems, new external surfaces, deferred scope.
- Risk notes: Do not claim Apple-side signing/App Store validation unless run.
- Completion definition: Ambitions 2.0 is release-candidate ready or has a precise blocker list.
- Ready-to-paste Codex prompt:

```text
Work on main only. ACTIVE BATCH: Batch 86 - Ambitions 2.0 Release Hardening. Perform release hardening only: regression closure, docs truth, validation, performance/accessibility follow-up, and release readiness. Do not add new features or deferred scope. Report changed files, validation, unresolved blockers, and registry recommendation.
```
