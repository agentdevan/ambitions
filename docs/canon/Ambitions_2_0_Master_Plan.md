# Ambitions 2.0 Master Plan

Adoption date: 2026-04-24

## Executive Summary

Ambitions 2.0 is a major app transformation, not a minor polish wave.

"Ambitions is a premium personal execution system that turns meaningful goals into believable daily action, explains why each action matters, and helps the user recover when real life disrupts the plan."

The product direction is:

"Calm shell, rich panels, meaningful visual state."

The execution direction is:

"Verify truth first, build shared systems once, then transform surfaces, then ship Apple-native external surfaces."

This plan supersedes prior roadmap direction after Batch 60 where conflicts exist. It does not rewrite completed history, and it does not claim implementation status for the new roadmap until Batch 61 verifies repo evidence.

## Locked Product Decisions

- Ambitions 2.0 includes many systems: Now State, reality modeling, recovery, explanation, memory, command execution, path intelligence, accessibility nutrition, Apple-first sync, export/import, widgets, Live Activities, App Intents, and calendar read/write.
- The top-level tabs are `Today`, `Goals`, `Capture`, `Plan`, and `You`.
- `Capture` is singular.
- `Insights` is demoted from top-level navigation now.
- `Habits` is absorbed now and must not remain a standalone top-level product area.
- Top-level screens stay capped and calm: one dominant hero panel, one or two supporting panels, and deeper content below the fold.
- Detail screens can be denser when the density explains, edits, reviews, or audits a specific object.
- Rich widget-like panels are the default presentation model. Plain text cards are not the 2.0 design target.
- Dark mode is flagship and uses warm charcoal / blue-black, never pure black or cold midnight.
- Light mode receives equal design priority with warm off-white surfaces.
- Calendar read and write are in Ambitions 2.0 scope.
- Plan works without calendar permission and becomes smarter with calendar access.
- Calendar permission is requested from Plan only after a clear user action such as `Make Plan calendar-aware` or `Find real open windows`.
- Calendar-derived insight data is local-first and clearly explained.
- Apple-first sync is in Ambitions 2.0 scope.
- Export/import remains required as a trust fallback.
- Widgets and Live Activities are in Ambitions 2.0 scope, after Canonical Now State and Command Pipeline are stable.
- Full long-range Path Intelligence is in Ambitions 2.0 scope.
- Accessibility Nutrition Facts are required: internal checklist first, user-facing `You -> Accessibility` summary only after verification.
- Dedicated device runtime is an architecture guardrail only in Ambitions 2.0. Do not build active hardware/runtime surfaces unless they naturally fall out of sync, Now State, or Command Pipeline work.

## Top-Level IA

### Today

Daily execution center. Shows what matters now, the next believable action, schedule pressure, recovery options, and contextual insight panels.

### Goals

Goal portfolio and Goal Detail entry. Shows active direction, goal health, path progress, next milestone, and explanation surfaces.

### Capture

Fast intake and triage. Owns raw capture, quick goal seeds, plan seeds, waiting items, archive, and routing into Goals or Plan.

### Plan

Believability workspace. Owns weekly/day shaping, open windows, calendar-aware mode, rituals, habit absorption, plan evidence, schedule blocks, and recovery/review prompts.

### You

Personal trust, memory, settings, reviews, accessibility, sync/export, preferences, and pattern reflection. `Profile` language may remain in code until a batch changes it, but product canon uses `You`.

## What Happened To Insights

Insights is no longer a persistent top-level destination.

Insight work lives in:

- `You -> Reviews`
- Today contextual insight panels
- Goal Detail explanation surfaces
- Plan evidence and review prompts
- `Why This` and `Why Changed` sheets

Insights must be useful where decisions happen. It must not become a detached analytics room.

## What Happened To Habits

Habits is no longer a standalone top-level product area.

Habit-shaped behavior is absorbed into:

- Plan
- rituals
- Today execution
- Reviews and pattern reflection

The product should not ask users to manage a separate habit app inside Ambitions.

## Visual Direction

Ambitions 2.0 uses rich, widget-like panels. A panel is not a generic card. A panel must have visual state, hierarchy, and a clear job.

Top-level surfaces use:

- one hero decision panel
- one or two supporting panels
- compact status and action treatments
- deeper evidence, settings, history, or review below the fold

Detail surfaces may use denser timelines, evidence groups, and settings clusters when they are attached to a specific goal, plan, review, capture, or trust object.

## Scope

Ambitions 2.0 includes:

- top-level shell IA change to Today / Goals / Capture / Plan / You
- Insights demotion
- Habits absorption
- rich panel visual system
- calendar read/write through Plan
- local-first calendar-derived insight policy
- Canonical Now State
- Reality Model
- Execution Resilience Stack
- Recommendation Explanation Model
- Memory / Event Ledger
- Command Pipeline
- Path Intelligence across broad coherent families
- Accessibility Nutrition Layer
- Apple-first sync
- export/import trust fallback
- App Intents and shared container readiness
- simple polished Widgets and Live Activity v1 after Now State and Command Pipeline stability
- onboarding, empty states, returning-user continuity, verification, and release hardening

## Path Families

Path Intelligence must support broad but coherent families:

- Career
- Education / Certification
- Creative
- Finance
- Health / Fitness without HealthKit
- Home / Life Admin
- Relationships / Personal Life, solo only

## Deferred Scope

Deferred from Ambitions 2.0:

- HealthKit
- food/calorie sync
- household/shared life
- non-phone hardware prototype

These may remain historical or later-vision ideas, but they are not active 2.0 implementation scope.

## Product Principles

1. Reality before aspiration.
2. One best next move before breadth.
3. Insight belongs at the decision point.
4. Recovery is a first-class execution path.
5. Plan must degrade gracefully without permissions.
6. Trust requires explanation, export/import, and local-first handling.
7. Rich visual state must reduce reading burden.
8. Top-level surfaces must stay calm.
9. Build shared systems once before surfaces consume them.
10. Apple-native external surfaces follow stable internal truth.

## Success Definition

Ambitions 2.0 succeeds when the app can turn a meaningful goal into a believable path, place the right action into the user's real day, explain why it matters, recover calmly when the plan breaks, and preserve user trust through local-first data handling, sync clarity, export/import, accessibility verification, and Apple-native continuity.

## Decision Log

The concise locked record lives in [Ambitions_2_0_Decision_Log.md](Ambitions_2_0_Decision_Log.md). This master plan explains those decisions and is the primary readable canon.
