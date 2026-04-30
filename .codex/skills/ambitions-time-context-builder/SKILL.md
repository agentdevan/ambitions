---
name: ambitions-time-context-builder
description: Use for Ambitions Time Context Hierarchy, Schedule & Availability, free-time calculation, vacation or away behavior, durations, rigidity, readiness, cognitive fit, automation levels, and optional receipt-backed reflow behavior. Enforces local-first deterministic planning models and tests without sync, network, or account dependencies.
---

# Ambitions Time Context Builder

## Purpose

Use this skill for Time Context Hierarchy, Schedule & Availability, free time calculation, vacation/away behavior, durations, rigidity, readiness, cognitive fit, automation levels, and reflow behavior.

## Required Grounding

Before editing, locate existing planner, schedule, calendar, recovery, Today, Plan, and domain models. Extend existing seams before introducing a new abstraction.

High-value searches:

- `rg -n "Reality|Calendar|Availability|Reflow|Duration|Rigidity|Readiness|Cognitive|Automation|Vacation|Schedule" Native Sources AppUI`
- `rg -n "PlanFeatureService|RealityModel|ExecutionResilience|ActionClosure|Receipt|Calendar" Native Sources`

## Time Context Order

The model and projection order must be:

1. Hard Context
2. Availability Context
3. Cognitive Context
4. Recommendation Layer

Free time is calculated only after excluding configured work, school, vacation/away, calendar events, commute/buffers, protected blocks, reserved commitments, sleep/recovery blocks, and family/household anchors.

## Required Rules

- Vacation/away is unavailable/protected by default unless explicitly marked available.
- Durations must be user-set, user-accepted, clearly suggested, historically grounded, actual, or unset.
- Guessed durations must never be displayed as fact.
- Reflow after early completion must be optional, receipt-backed, and reversible.
- Ambitions never fills open time just because it exists.
- Meaningful automation changes must be permissioned, receipt-backed, and undoable.
- Do not add sync, network, backend, account, or cloud dependencies.

## Required Model Concepts

Use existing names where the repo already has compatible concepts. Otherwise add additive local-first domain models for:

- `TimeContextBlock`
- `TimeContextKind`
- `ContextSource`
- `AvailabilityWindow`
- `AvailabilityState`
- `DurationMetadata`
- `DurationSource`
- `StepOccurrence`
- `RigidityLevel`
- `ReadinessState`
- `ContextRequirement`
- `CognitiveFit`
- `ReflowOpportunity`
- `ReflowReason`
- `ReflowOption`
- `AutomationLevel`
- `VacationAvailabilityBehavior`

Prefer `Codable`, `Equatable`, and `Sendable` where appropriate for domain/value types.

## Procedure

1. Locate existing planner, schedule, and time models.
2. Name the primary files and touch budget before edits.
3. Extend existing seams before creating new abstractions.
4. Keep local-first and deterministic.
5. Add `Codable`, `Equatable`, and `Sendable` where appropriate.
6. Add fixtures for work, school, low-control work, vacation, protected time, buffers, and missing schedule.
7. Add tests for free-time exclusion, vacation behavior, duration labeling, guided automation default, and reflow permission.
8. Do not add sync/network/account dependencies.

## Validation

- Run `xcodegen generate` when Swift target membership or `project.yml` changes.
- Run focused model/service tests for touched planning/time seams.
- Run broader Plan/Today tests only when projections or UI routes change.
- Run `git diff --check`.
- Report duration and free-time assumptions as verified only when tests or inspected code prove them.

## Follow-On Skills

- Use `ambitions-action-closure-receipts` if reflow or schedule changes create closure receipts.
- Use `ambitions-ios-surface-polisher` if time context appears in visible Plan, Today, or You surfaces.
- Use `ambitions-v2-validation-closeout` for broad v2 integration closeout.
