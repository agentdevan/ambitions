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

## Reality Model

- Purpose: Model believable capacity, fixed/flexible commitments, plan pressure, conflict, and schedule reality.
- Owned concepts: open windows, fixed commitments, flexible work, calendar conflicts, capacity, believability, plan pressure.
- Consumed by: Plan, Today, Goals, Reviews, Path Intelligence.
- Dependencies: calendar permission boundary, local plan data, Memory / Event Ledger.
- Must not be duplicated: calendar parsing, capacity math, believability scoring.
- Ambitions 2.0 scope: calendar read/write, no-permission fallback, local-first derived insight policy.
- Later scope: richer external integrations only after trust boundaries exist.

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
- Owned concepts: why this, why changed, evidence, assumption, memory, calendar-derived context, uncertainty, user correction.
- Consumed by: Today panels, Goal Detail, Plan prompts, Reviews, You trust surfaces.
- Dependencies: Memory / Event Ledger, Reality Model, Path Intelligence, Command Pipeline.
- Must not be duplicated: screen-specific rationale strings that invent their own logic.
- Ambitions 2.0 scope: reusable explanation object and `Why This` / `Why Changed` surfaces.
- Later scope: deeper source audit when retrieval-backed sources expand.

## Memory / Event Ledger

- Purpose: Durable local record of meaningful events and learning inputs.
- Owned concepts: action completed, delayed, skipped, moved, split, recovered, reviewed, corrected, imported/exported, scheduled, unscheduled, priority/reality changes, commitment capture/routing, Context Lens changes/inferences, goal scope, deliverables, deadlines, displacement, and priority-conflict recovery.
- Consumed by: Now State, Reviews, Path Intelligence, Explanation, Accessibility Nutrition, sync/export.
- Dependencies: persistence boundaries, Command Pipeline.
- Must not be duplicated: parallel histories inside features.
- Ambitions 2.0 scope: local-first ledger and review projections.
- Later scope: cross-device merge policy after Apple-first sync verification.
- Batch 65 implementation status: The canonical local ledger foundation exists as `EventLedgerEntry` / `EventLedgerKind` with repository, SwiftData, in-memory, redaction/delete, and adapter helpers for current evidence, feedback, and teaching signals. Its taxonomy includes future-safe event hooks for Priority Reality Model, Context Lens, Commitment Capture, and Goal Container scope changes without implementing those behaviors. Broad feature emission, review projections, portable snapshot inclusion, sync merge policy, and UI history surfaces remain deferred to their owning batches.

## Command Pipeline

- Purpose: One route for user and external commands to change app state.
- Owned concepts: command intent, validation, execution, event emission, undo/recovery where supported, external action safety.
- Consumed by: app UI, App Intents, widgets, Live Activities, notifications, Capture, Plan, Today.
- Dependencies: Memory / Event Ledger, Now State, domain services, persistence.
- Must not be duplicated: separate command paths for widgets, intents, or shortcuts.
- Ambitions 2.0 scope: stable local command execution and external-safe command descriptors.
- Later scope: broader automation only after sync and conflict rules hold.

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
