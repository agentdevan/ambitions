# Ambitions 2.0 Systems Architecture

## Purpose

This document defines the consolidated Ambitions 2.0 systems. Product surfaces consume these systems; they do not duplicate them.

Ambitions 2.0 systems should be clustered into a small set of product layers instead of one engine per screen or one batch per invention:

- Life Graph / Relationship Layer
- Action Closure / Trust Layer
- Daily Execution / Today Layer
- Reality / Plan Layer
- Goals / Portfolio Layer
- Memory / Learning / Reviews Layer
- Long-Range Strategy Layer
- Shell / Ambient Continuity Layer

Each layer must stay local-first, explainable, correction-aware, and conservative about automation.

Future implementation must follow the maturity gates in [Ambitions_2_0_RC_Maturity_Plan.md](Ambitions_2_0_RC_Maturity_Plan.md). Foundations are not enough for RC: each major system needs a first useful surface, cross-surface integration, trust/correction/degraded behavior, performance/accessibility proof, and RC verification before release-candidate lock.

## Source Of Truth Ownership

Do not create duplicate engines when inventions overlap:

- Believability Kernel owns believable / not-believable state.
- Constraint Gravity owns dominant constraint detection.
- Reality Reflow owns mutation suggestions.
- Action Closure owns receipts and undo/correction presentation.
- Trust Ledger owns user-facing trust-impacting history.
- Event Ledger remains raw event history.
- Proof Rail Engine owns proof organization and presentation.
- Proof Spine is the vertical Goal Detail / Mission Control expression of Proof Rail, not a separate proof engine.
- Memory Confidence Engine owns confidence state of learned memories.
- Safe Automation Boundary owns what Ambitions may suggest, prepare, confirm, execute, or never automate.
- Ambition Portfolio Manager owns portfolio-level goal pressure.
- Goal Scope Governor owns scope expansion, shrink, park, and protect logic.
- Goal Weather is the user-facing visual language for goal health, not a separate health engine.
- Goal Atlas is the portfolio/map layer over Life Graph and Path Builder relationships, not a parallel path store.
- Decision Trail is the user-facing goal/plan change history over Event Ledger, Action Closure, and Plan Treaty decisions, not a second event log.

## Life Graph / Relationship Layer

- Purpose: First-class object graph for goals, milestones, actions, blockers, people, commitments, waiting items, resources, evidence, windows, constraints, decisions, memories, corrections, and receipts.
- Owned concepts: Life Graph v1, Resource Graph v1, Promise Ledger, lightweight Person / Commitment / Waiting relationships, proof types, dependencies, prerequisites, constraints, memory/correction links, Life Graph Breadcrumb data, Proof Rail relationships, and Mission Control Lens foundations.
- Consumed by: Capture, Today, Goals, Goal Detail, Plan, You, Reviews, Path Intelligence, Action Closure, Memory, Commitments, Waiting Room, and Proof of Progress.
- Dependencies: Capture 2.0, Event Ledger, Recommendation Explanation Model, Command Pipeline, existing goal/path/resource foundations.
- Must not be duplicated: feature-specific object relationship stores, isolated waiting lists, per-surface proof attachments, or path-only graph logic.
- Ambitions 2.0 scope: v1 graph relationships and proof/commitment/resource links before major Goals/Plan/You surface expansion.
- Later scope: richer external integrations only after sync/export and Safe Automation Boundary are verified.

## Action Closure / Trust Layer

- Purpose: Every meaningful command must produce a visible, actionable result that tells the user what happened, what changed, why, what is next, what can be undone, and what can be corrected.
- Owned concepts: Action Closure, Action Closure Tray, receipt model, result states, undo eligibility, correction entry, why-changed links, safe failure states, external action receipts, calendar write receipts, export/import receipts, Trust Ledger handoff, and Safe Automation Boundary v1.
- Result states include: created, changed, scheduled, moved, attached, exported, drafted/prepared, completed, failed safely, needs confirmation, and undo available where safely supported.
- Consumed by: app UI, Command Pipeline, Plan calendar writes, Capture routing, Goals changes, Reviews, You Trust Center, App Intents, widgets, Live Activities, export/import, and future prepared actions.
- Dependencies: Command Pipeline, Event Ledger, Recommendation Explanation Model, Reality Model, sync/export policy.
- Must not be duplicated: generic toast systems, per-feature success copy, external-surface-specific command result logic, or silent mutation paths.
- Ambitions 2.0 scope: shared receipt model and UI presentation before Goals/Plan/You/Reviews/App Intents/Widgets/Sync consume it.
- Later scope: more automation only through the Safe Automation Boundary.

## Daily Execution / Today Layer

- Purpose: Turn the current day into a Daily Operating Contract: one protected must-do, one best next move, one intentionally-not-today item, one recovery fallback, one reason this matters, one Action Closure path, and one Save the Day escape hatch.
- Owned concepts: Daily Operating Contract, Today Contract, Daily Operating Brief, One Move Doctrine, Attention Shield, Save the Day Mode, Recovery Gradient, Anti-Plan / Not Today summary, Friction Radar v1, Ambient Status Orb for day believability, and Mode Lens awareness.
- Consumed by: Today, Plan, Capture, Reviews, widgets, App Intents.
- Dependencies: Canonical Now State, Reality Model, Goal Believability, Execution Resilience, Action Closure, Life Graph relationships.
- Must not be duplicated: Today-only priority logic, dense dashboards, or hidden navigation modes.
- Ambitions 2.0 scope: v1 daily contract and rescue flow in Today 2.0, with deeper plan handling in Plan 2.0.

## Reality / Plan Layer

- Purpose: Decide whether a day, week, plan, commitment, goal, or path is actually believable under current constraints, then reflow safely when reality changes.
- Owned concepts: Believability Kernel, Reality Reflow Engine, Constraint Gravity Engine, Plan Treaty, Opportunity Window Engine, Window Magnetism, Personal Capacity Envelope, Context Switching Toll, Calendar Boundary Contract, Decision Debt Engine, Weekly Plan Strip, Next Visible Step selection for the plan window, and confirmed calendar writes with receipts/undo where safe.
- Consumed by: Plan, Today, Goals, Reviews, Path Builder, Action Closure.
- Dependencies: Reality Model, calendar permission boundary, Goal Believability, Execution Resilience, Personal Operating Constitution.
- Must not be duplicated: screen-specific feasibility labels, silent rescheduling, calendar clone UI, or Plan-independent calendar writes.
- Ambitions 2.0 scope: Reality Reflow v1 and Plan Treaty in Plan 2.0, with no silent rescheduling and Plan-owned calendar permission preserved.
- Batch 85 planned scope: Weekly Plan Strip shows the seven-day path from active goals into the current week; Plan believability consumes Goal Weather and proof density; Plan Treaty writes Decision Trail notes when major scope changes occur; only Next and Doing task-lane items heavily influence Today/Plan.

## Goals / Portfolio Layer

- Purpose: Treat goals as a capacity-limited portfolio with proof-weighted progress, constraints, assumptions, and status.
- Owned concepts: Ambition Portfolio Manager, Goal Scope Governor, Goal Lifecycle Rail, Goal Atlas, Goal Weather, Momentum Integrity Engine, Proof-Weighted Progress, Proof Spine, Next Visible Step, Decision Trail, Timeline View, Milestone Cards, Kanban-lite Task Lane, Completion Archive, Assumption Watchtower, Goal Contract, Goal Health MRI, Path Filmstrip, Previous/Active/Future/Parked/Blocked/Waiting/Protected/Completed/Cancelled / Dropped states, early Mission Control lanes, Life Graph Breadcrumb, Proof Rail, and Ambient Status Orb for goal health.
- Consumed by: Goals, Goal Detail, Plan, Today, Reviews, Path Builder.
- Dependencies: Life Graph, Proof Rail Engine, Believability Kernel, Event Ledger, Path Intelligence, Action Closure.
- Must not be duplicated: fake progress percentages, equal-weight goal dashboards, generic top-level task boards, separate proof spines outside Proof Rail, separate health/weather engines, or full Path Builder logic inside Goal Detail before the owning path batches.
- Ambitions 2.0 scope: Goals / Goal Detail 2.0 consumes Life Graph and Action Closure foundations, but does not build full Path Builder yet.
- Batch 83 planned scope: Goals overview becomes a premium ambition portfolio with a hero for current ambition portfolio, Lifecycle Rail for Previous -> Active -> Future, state chips for Protected / Waiting / Blocked / Parked / Completed / Cancelled, visual goal cards, Next Visible Step on every active goal card, Goal Weather v1, compact lifecycle timeline, Completion Archive states, and optional Goal Atlas preview.
- Batch 84 planned scope: Goal Detail becomes Mission Control with Path, Now, Proof, Risk, Decisions, and Tasks lanes; it includes goal-specific lifecycle timeline, Proof Spine, Decision Trail, Milestone Cards, Kanban-lite Task Lane, connected goals from Goal Atlas, dominant Next Visible Step, end-state summaries for completed/parked/cancelled goals, and Goal Weather explanations.
- Batch 107 planned scope: Ambition Portfolio Manager matures Goal Weather, Completion Archive intelligence, proof maturity comparison, cancelled/dropped learning summaries, Goal Atlas as the mature portfolio view, stuck-task detection, and goal scope maturity.

## Memory / Learning / Reviews Layer

- Purpose: Convert experience into future behavior without black-box personalization.
- Owned concepts: Memory Confidence Engine, Correction Cards, Narrative Memory Map, Review Constellation, Life OS Receipt, Why Changed Log, Re-entry Engine, Clarity Debt Engine, Recovery Review, Pattern Review, Memory Review, Correction Review, and Memory Receipts.
- Consumed by: Reviews, You, Today, Goals, Plan, Path Builder, Learning and Anticipation.
- Dependencies: Event Ledger, Recommendation Explanation Model, Action Closure receipts, Life Graph, Proof of Progress.
- Must not be duplicated: analytics dashboards, uncorrectable recommendations, or claims that Ambitions learned without evidence.
- Ambitions 2.0 scope: Reviews and Learning batches must use evidence, user-confirmed signals, corrections, and memory confidence states.

## Long-Range Strategy Layer

- Purpose: Simulate believable life paths and alternatives without fantasy planning.
- Owned concepts: Life Path Simulation, Path Forks, Path Fork Simulator, Domain Path Packs, Future Self Simulator, Goal Atlas expansion into Path Builder, milestone roadmap nodes, lifecycle timeline as long-range planning, Decision Trail visibility across roadmap changes, Weekly Plan Strip rollups, pause/limited-time simulations, fallback paths, people/stakeholders, prerequisites, dependencies, proof requirements, and resource links.
- Consumed by: Goals, Goal Detail, Path Builder, Plan, Reviews.
- Dependencies: Life Graph, Reality / Plan layer, Goals / Portfolio layer, Proof Rail Engine, Memory / Reviews layer.
- Must not be duplicated: per-feature path templates, unsupported domain specificity, or strategy UI before contracts exist.
- Ambitions 2.0 scope: Path Intelligence Foundation owns contracts; Path Builder owns UI over those contracts.

## Shell / Ambient Continuity Layer

- Purpose: Make Ambitions feel like one coherent personal operating system instead of five separate tabs.
- Owned concepts: Global Chrome, Mode Lens, Continuity Ribbon, Trust Badge, Ambient Status Orb placement, Action Closure Tray placement, External Continuity Contract, stale-state handling, privacy-safe payloads, app landing routes, and no separate external logic.
- Consumed by: all tabs, details, sheets, App Intents, widgets, Live Activities, onboarding, release hardening.
- Dependencies: Visual System, Appearance Studio, Accessibility Nutrition, Now State, Command Pipeline, Action Closure, Sync/Export Trust.
- Must not be duplicated: per-screen shell hacks, hidden tabs, generic toasts, or hard-coded screen colors.
- Ambitions 2.0 scope: dedicated global chrome batch after Today 2.0 and before remaining major surface redesigns.

## Canonical Now State

- Purpose: Single current-state projection for Today, widgets, Live Activities, App Intents, Plan, and recovery.
- Owned concepts: current action, next action, active focus, schedule pressure, recovery state, goal pressure, trusted summary.
- Consumed by: Today, Plan, Goal Detail, widgets, Live Activities, App Intents, notifications, reviews.
- Dependencies: Memory / Event Ledger, Reality Model, Command Pipeline, Execution Resilience, calendar-derived summaries when allowed.
- Must not be duplicated: per-surface "now" calculations, widget-specific next-action logic, notification-only state.
- Ambitions 2.0 scope: stable projection and local consumers.
- Later scope: richer cross-device projections after sync stability.
- Batch 67 implementation status: The internal shared contract exists as `CanonicalNowState` with context lens/source/override fields, current and best next action references, confidence and explanation references, schedule/priority/deadline pressure, active focus reference, capture urgency, blockers/waiting, recovery state, urgent outside-lens summary, active and passive goal pressure, Event Ledger and Recommendation Explanation references, privacy/local-only markers, and schema versioning. `CanonicalNowStateProjector` provides a deterministic, local-only projection from existing goals, captures, progress evidence, feedback, recent Event Ledger entries, and optional Recommendation Explanation objects without requiring calendar permission, fixed work schedules, surface redesign, widgets, Live Activities, App Intents productization, Capture 2.0, Plan 2.0, or a full Priority Reality Model.
- Future batches should consume this contract through their owning systems rather than adding separate per-surface "now" calculations. Batch 67 does not persist Now State and does not implement runtime context switching, calendar-aware scheduling, Command Pipeline mutation, Today 2.0 UI, or external-surface productization.

## Reality Model

- Purpose: Model believable capacity, fixed/flexible commitments, plan pressure, conflict, and schedule reality.
- Owned concepts: open windows, fixed commitments, flexible work, calendar conflicts, capacity, believability, plan pressure.
- Consumed by: Plan, Today, Goals, Reviews, Path Intelligence.
- Dependencies: calendar permission boundary, local plan data, Memory / Event Ledger.
- Must not be duplicated: calendar parsing, capacity math, believability scoring.
- Ambitions 2.0 scope: calendar read/write, no-permission fallback, local-first derived insight policy.
- Later scope: richer external integrations only after trust boundaries exist.
- Batch 70 implementation status: The shared foundation now exists as `RealitySnapshot`, `RealityWindow`, `AvailabilitySummary`, `OpenWindowCandidate`, `CalendarDerivedContext`, `RealityConflictSummary`, `ScheduledAmbitionsBlock`, `CapacityEstimate`, `CalendarPermissionState`, and `ScheduledBlockWriteIntent`, with `RealityModelProjector` building deterministic no-permission and calendar-aware snapshots. EventKit is behind `CalendarRealityServicing`, `CalendarPermissionServicing`, and `CalendarBlockWriting`; calendar read is requested only through Plan's explicit calendar-aware action, derived busy windows discard raw event titles, and confirmed calendar block writes require a user-confirmed intent. Batch 70 does not implement full Plan 2.0 UI, automatic scheduling, sync/export, Today redesign, widgets, Live Activities, App Intents productization, Path Intelligence UI, onboarding, or Reviews.

## Believability, Capacity, And Goal Health

- Purpose: Assess whether goals, goal actions, Capture commitments, Plan seeds, deliverable seeds, and scope-change seeds look believable against priority reality and capacity.
- Owned concepts: goal health status, believability snapshot, active/passive/optional/waiting posture, priority reality dimensions, deadline risk, capacity fit, context fit, open-window fit, explainable reasons, correction suggestions.
- Consumed by: future Goals, Goal Detail, Plan, Today, Reviews, Now State, Command Pipeline, and Recommendation Explanation consumers.
- Dependencies: Reality Model when available, Capture 2.0 metadata, Canonical Now State taxonomy, Recommendation Explanation Model, Event Ledger references, existing goal/plan models.
- Must not be duplicated: per-surface goal-health labels, hidden black-box priority scores, or Plan-specific believability math.
- Ambitions 2.0 scope: deterministic local shared assessment, no-calendar fallback, RealitySnapshot consumption, reference-safe Event Ledger/Recommendation Explanation ids, and side-effect-free Now/Command adapters.
- Later scope: Goals 2.0/Goal Detail 2.0 presentation, Today 2.0 execution surfacing, Plan 2.0 calendar-aware workspace, automatic recovery decisions, full scheduling/displacement behavior, and review surfaces.
- Batch 71 implementation status: The shared foundation now exists as `GoalBelievabilitySnapshot`, `GoalBelievabilityAssessment`, `GoalHealthStatus`, `GoalHealthSignal`, `GoalCapacityFit`, `GoalDeadlineRisk`, `GoalPriorityRealityAssessment`, `GoalBelievabilityReason`, `GoalBelievabilityRecommendation`, `GoalBelievabilityInput`, and `GoalBelievabilitySummary`, with `GoalBelievabilityProjector` assessing goals, goal next actions, Capture 2.0 commitments, Plan seeds, deliverable seeds, scope-change seeds, passive/flexible goals, waiting/optional items, context mismatch, calendar-derived conflicts, and capacity/deadline fit. It works without calendar access, consumes `RealitySnapshot` when supplied, produces `RecommendationExplanation` values for why-believable/not-believable/priority/defer/displacement/calendar/goal/plan-change cases, references Event Ledger ids without writing new ledger entries, and provides side-effect-free Now/Command helper projections. Batch 71 does not implement Goals 2.0, Goal Detail 2.0, Plan 2.0, Today 2.0, automatic scheduling, calendar writes, calendar permission prompts, full recovery, widgets, Live Activities, App Intents productization, sync/export, Path Intelligence UI, onboarding, or Reviews.

## Execution Resilience Stack

- Purpose: Turn disruption into recovery instead of shame.
- Owned concepts: drift, missed work, slipped deadlines, overloaded days, no open window, blocked/waiting pressure removal, priority conflict, displaced lower-priority work, passive work deferral, split action, smaller version, reschedule representation, protect deadline work, replan/open destination prompt, review prompt.
- Consumed by: Today, Plan, Goal Detail, Reviews, Command Pipeline.
- Dependencies: Canonical Now State, Reality Model, Believability/Goal Health, Recommendation Explanation Model, Memory / Event Ledger, Command Pipeline.
- Must not be duplicated: per-screen skip/delay/recovery rules.
- Ambitions 2.0 scope: shared recovery decisions and surface-safe actions.
- Later scope: more personalized recovery once enough verified memory exists.
- Batch 72 implementation status: The shared foundation now exists as `ExecutionResilienceSnapshot`, `ExecutionResilienceAssessment`, `ExecutionRecoveryOption`, `ExecutionRecoveryStrategy`, `ExecutionDisruption`, `ExecutionDisruptionKind`, `ExecutionRecoveryStatus`, `ExecutionRecoveryReason`, `ExecutionRecoveryRecommendation`, `ExecutionResilienceInput`, `RecoveryTradeoff`, `DisplacedWorkSummary`, and `ProtectedWorkSummary`, with `ExecutionResilienceProjector` producing deterministic, side-effect-free recovery assessments from Goal Believability assessments/snapshots, Reality snapshots, Canonical Now State, Capture 2.0 models, Event Ledger references, Recommendation Explanations, and Command descriptors. It distinguishes deadline-bound high-consequence work from passive/flexible goals, blocked/waiting items, no-open-window commitments, calendar conflict markers, overloaded days, scope increases, and added deliverables. It can generate explanation objects and representational commands for recovery/open/waiting/split/delay paths, but unsupported recovery commands remain blocked or unsupported in the command executor without side effects. Batch 72 does not build Today 2.0, Plan 2.0, Goals/Goal Detail 2.0, Reviews, automatic scheduling, calendar writes, calendar permission prompts, widgets, Live Activities, App Intents productization, sync/export, Path Intelligence UI, onboarding, or You/Profile redesign.

## Recommendation Explanation Model

- Purpose: Explain why an action, plan change, recovery, or path recommendation exists.
- Owned concepts: why this, why now, why changed, why scheduled, why deferred, why recovered, why prioritized, why displaced, why routed, why goal/plan changed, why context lens, why calendar-aware, why believable/not believable, evidence, assumption, memory, calendar-derived context, priority/urgency/consequence/effort tradeoffs, deadline, capacity, path, deliverable, scope change, uncertainty, and user correction.
- Consumed by: Today panels, Goal Detail, Plan prompts, Reviews, You trust surfaces.
- Dependencies: Memory / Event Ledger, Reality Model, Path Intelligence, Command Pipeline.
- Must not be duplicated: screen-specific rationale strings that invent their own logic.
- Ambitions 2.0 scope: reusable explanation object and future `Why This` / `Why Changed` surfaces.
- Later scope: deeper source audit when retrieval-backed sources expand.
- Batch 66 implementation status: The shared value-model foundation exists as `RecommendationExplanation` with explanation/evidence/correction taxonomies, assumptions, uncertainty, related goal/capture/plan/review/Event Ledger ids, local-only/privacy metadata, calendar-derived/context-lens/priority/deadline/goal-scope markers, Event Ledger evidence helpers, and a narrow adapter from existing goal explainability state. It does not implement full explanation sheets, Priority Reality Model scoring, Context Lens runtime behavior, Commitment Capture classification, calendar behavior, recommendation history persistence, or Living Goal Container UI.
- Future batches must use this model while implementing the Priority Reality Model, Context Lens, Commitment Capture, Living Goal Containers, and the obvious destination for every user-created item. Those systems should provide the evidence; the explanation model should describe it without becoming a parallel planner or classifier.

## Memory / Event Ledger

- Purpose: Durable local record of meaningful events and learning inputs.
- Owned concepts: action completed, delayed, skipped, moved, split, recovered, reviewed, corrected, imported/exported, scheduled, unscheduled, priority/reality changes, commitment capture/routing, Context Lens changes/inferences, goal scope, deliverables, deadlines, displacement, and priority-conflict recovery.
- Consumed by: Now State, Reviews, Path Intelligence, Explanation, Accessibility Nutrition, sync/export.
- Dependencies: persistence boundaries, Command Pipeline.
- Must not be duplicated: parallel histories inside features.
- Ambitions 2.0 scope: local-first ledger and review projections.
- Later scope: cross-device merge policy after Apple-first sync verification.
- Batch 65 implementation status: The canonical local ledger foundation exists as `EventLedgerEntry` / `EventLedgerKind` with repository, SwiftData, in-memory, redaction/delete, and adapter helpers for current evidence, feedback, and teaching signals. Its taxonomy includes future-safe event hooks for Priority Reality Model, Context Lens, Commitment Capture, and Goal Container scope changes without implementing those behaviors. Broad feature emission, review projections, portable snapshot inclusion, sync merge policy, and UI history surfaces remain deferred to their owning batches.
- Batch 69 implementation status: Capture 2.0 actions now write truthful ledger events for executed capture creation, triage, goal attachment, archive, commitment capture/routing, deadline changes, priority changes, urgency changes, and user corrections when the capture service has a ledger repository. Unsupported or blocked capture operations do not emit success history.

## Command Pipeline

- Purpose: One route for user and external commands to change app state.
- Owned concepts: command intent, validation, execution, event emission, undo/recovery where supported, external action safety.
- Consumed by: app UI, App Intents, widgets, Live Activities, notifications, Capture, Plan, Today.
- Dependencies: Memory / Event Ledger, Now State, domain services, persistence.
- Must not be duplicated: separate command paths for widgets, intents, or shortcuts.
- Ambitions 2.0 scope: stable local command execution and external-safe command descriptors.
- Later scope: broader automation only after sync and conflict rules hold.
- Batch 68 implementation status: The shared foundation exists as `AmbitionsCommand` with command id/kind/source/target/payload/validation/execution/result timing/actor/relation/privacy/schema fields, plus `AmbitionsCommandKind`, `AmbitionsCommandSource`, target/payload/priority-hint models, validation states, execution statuses, and a `NowAction` mapping helper. `AmbitionsCommandExecutor` validates commands deterministically, executes open-destination as route-only results, executes quick capture through the existing capture service when available, and emits Event Ledger entries only for actually executed quick-capture commands. Unsupported future commands return explicit unsupported/blocked results without fake state changes or ledger history.
- Batch 68 does not productize App Intents, widgets, Live Activities, notifications, Capture 2.0, Plan 2.0, scheduling, calendar behavior, runtime Context Lens switching, full Priority Reality scoring, recovery stack execution, or broad UI action rewiring. Future batches should consume this foundation rather than adding parallel command paths.
- Batch 69 implementation status: The executor now aligns with Capture-owned commands for quick capture, route commitment, attach to goal, mark waiting, archive, set capture deadline/priority/urgency, and representational Plan-seed routing when a capture target exists. Plan item creation and schedule commands remain representation-only through Capture; no Plan 2.0 scheduling, calendar writes, or Today/Goals runtime rewiring is implemented.

## Capture 2.0 Core

- Purpose: First-class local intake and routing for thoughts, commitments, seeds, waiting items, optional items, and archive decisions.
- Owned concepts: capture kind, route, triage status, commitment kind, deadline text/kind, context lens hint, priority hints, goal relationship, deliverable/scope hints, waiting metadata, assumption summary, correction actions, privacy/local-only markers.
- Consumed by: Capture tab, Command Pipeline, Memory / Event Ledger, future Plan, future Goals, future Today, future reviews.
- Dependencies: capture repository, existing goal repository for safe attachment, Event Ledger repository when available, Recommendation Explanation references, Canonical Now State context-lens taxonomy.
- Must not be duplicated: parallel inbox models, feature-specific waiting/seed/archive stores, or Plan-owned scheduling behavior inside Capture.
- Ambitions 2.0 scope: local capture intake, conservative deterministic classification, visible assumptions, correction actions, Plan-seed representation, safe goal attachment, waiting/optional/archive routing, and truthful ledger emission.
- Later scope: full natural-language parsing, Priority Reality scoring, Context Lens runtime switching, Goal Container UI, Seed Vault expansion, Plan 2.0 scheduling, Today 2.0 execution, sync/export inclusion, widgets, App Intents productization, and Path Intelligence UI.
- Batch 69 implementation status: `Capture` now stores additive Capture 2.0 metadata with legacy decode defaults; `DefaultCaptureService` creates and routes raw captures, one-time commitments, deadline tasks, goal seeds, goal-supporting tasks, deliverable seeds, waiting items, optional/someday items, and archive items. The Capture tab exposes a calm quick-intake panel, grouped route states, visible assumptions, correction actions, goal attach when supported, and empty/error behavior that preserves user input.

## Path Intelligence Layer

- Purpose: Turn goals into broad but coherent long-range paths.
- Owned concepts: path family, stages, milestones, prerequisites, alternatives, readiness, capacity fit, domain rules.
- Consumed by: Goals, Goal Detail, Plan, Today, Reviews.
- Dependencies: Reality Model, Memory / Event Ledger, Explanation Model.
- Must not be duplicated: per-feature path templates or isolated goal strategy logic.
- Ambitions 2.0 scope: full long-range path intelligence for Career, Education / Certification, Creative, Finance, Health / Fitness without HealthKit, Home / Life Admin, and Relationships / Personal Life solo only.
- Later scope: HealthKit, household/shared life, and non-phone hardware are deferred.

## Accessibility Nutrition Layer

- Purpose: Treat accessibility as product trust infrastructure.
- Owned concepts: internal checklist, screen audit, verified claims, unverified claims, user-facing summary.
- Consumed by: design system, QA, You -> Accessibility, release hardening.
- Dependencies: visual system, implementation verification, manual audit results.
- Must not be duplicated: ad hoc accessibility claims in release notes or settings.
- Ambitions 2.0 scope: checklist first, user-facing summary after verification.
- Later scope: deeper assistive workflows after foundational verification.

## Apple-First Sync and Export/Import Trust Layer

- Purpose: Provide Apple-native continuity while preserving user control and trust fallback.
- Owned concepts: local-first data, sync status, conflict policy, export, import, backup, restore, trust copy.
- Consumed by: You, Command Pipeline, Memory / Event Ledger, widgets, App Intents, release hardening.
- Dependencies: verified data model, Event Ledger, export/import contracts.
- Must not be duplicated: feature-specific backup/sync paths.
- Ambitions 2.0 scope: Apple-first sync plan and export/import trust fallback.
- Later scope: non-Apple sync providers only after explicit canon approval.
