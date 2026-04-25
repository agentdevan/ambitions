# Ambitions 2.0 Systems Architecture

## Purpose

This document defines the consolidated Ambitions 2.0 systems. Product surfaces consume these systems; they do not duplicate them.

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
- Owned concepts: drift, missed work, split action, smaller version, reschedule, protect later, replan, review prompt.
- Consumed by: Today, Plan, Goal Detail, Reviews, Command Pipeline.
- Dependencies: Canonical Now State, Reality Model, Memory / Event Ledger.
- Must not be duplicated: per-screen skip/delay/recovery rules.
- Ambitions 2.0 scope: shared recovery decisions and surface-safe actions.
- Later scope: more personalized recovery once enough verified memory exists.

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
