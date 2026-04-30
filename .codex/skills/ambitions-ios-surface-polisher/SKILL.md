---
name: ambitions-ios-surface-polisher
description: Use for implementing or polishing Ambitions iOS surfaces under the current master product and visual system, including Today, Plan, You, Capture, Goals, Goal Detail, Trust Center, What Ambitions Knows, Reviews, Appearance Studio, Recovery Flow, shared AmbitionsUI components, previews, and fixtures.
---

# Ambitions iOS Surface Polisher

## Purpose

Use this skill for implementing and polishing Ambitions iOS surfaces according to the current master product and visual system.

## Applies To

- Today
- Plan
- You
- Capture
- Goals
- Goal Detail
- Trust Center
- What Ambitions Knows
- Reviews
- Appearance Studio
- Recovery Flow
- shared AmbitionsUI components
- previews and fixtures

## Required Grounding

Inspect the current surface and shared components before editing:

- `Native/Ambitions/Features/`
- `Sources/`
- `AppUI/Sources/`
- `docs/canon/Ambitions_2_0_Visual_System.md`
- `docs/canon/design/Ambitions_Design_Constitution.md`
- `docs/review/VISUAL_REVIEW_CHECKLIST.md` when visible UI changes materially

## Surface Rules

- Preserve an iPhone-native SwiftUI feel.
- Use a dark-mode-first warm graphite visual style.
- Prefer compact contextual headers.
- Avoid large wasteful top-level title blocks.
- Preserve the persistent tab bar on top-level screens.
- Respect safe areas.
- Avoid card-pile dashboard feel and fake SaaS analytics look.
- Rows, rail items, and panels need predictable tap behavior.
- Everything that looks tappable should be tappable or clearly disabled.
- Capture is bottom-composer-driven and not chat UI.
- Plan is not a generic calendar clone.
- You is a Personal System Center, not Profile.
- Goals is an Ambition Portfolio, not a task board.
- Keep screens deep, not wide.

## Component Priorities

Prefer existing components or canonical wrappers/adapters for:

- `AppBackground`
- `SurfacePanel`
- `CompactContextHeader`
- `HeroStepPanel`
- `TimeContextLens`
- `TimeContextBadge`
- `DurationBadge`
- `DurationSourceLabel`
- `DayTimelineRail`
- `TimelineRailRow`
- `TimelineRailMarker`
- `AvailabilityWindowPanel`
- `PlanHealthPanel`
- `EvidenceSourceChip`
- `ScheduleSourceLabel`
- `RigidityChip`
- `ReadinessChip`
- `ContextRequirementChip`
- `ReflowOpportunityPanel`
- `GroupedNavigationSection`
- `AmbitionsNavigationRow`
- `UserSystemProfilePanel`
- `ReceiptTrail`
- `ClosureCheckInPanel`

## Procedure

1. Reuse existing components where possible.
2. Add canonical wrappers/adapters rather than duplicating systems.
3. Build tokens/components before screens.
4. Update previews with realistic product states.
5. Run the visual review checklist where UI changes are visible.
6. Confirm forbidden copy is not introduced.
7. Keep screens deep, not wide.
8. Avoid broad surface adoption unless the requested scope requires it.

## Validation

- Run `xcodegen generate` when Swift target membership or `project.yml` changes.
- Run focused Swift tests for touched services/projections.
- Run focused UI smoke or simulator build when top-level surfaces, navigation, or visible hierarchy changes.
- Run `git diff --check`.
- Note any manual visual review, accessibility, Dynamic Type, Reduce Motion, or real-device proof that was not run.

## Follow-On Skills

- Use `ambitions-canon-v2-reconciler` if UI work reveals stale canon or roadmap wording.
- Use `ambitions-time-context-builder` for schedule, availability, duration, or reflow model needs.
- Use `ambitions-action-closure-receipts` for closure prompts and receipt trails.
- Use `ambitions-v2-validation-closeout` before declaring broad surface integration complete.
