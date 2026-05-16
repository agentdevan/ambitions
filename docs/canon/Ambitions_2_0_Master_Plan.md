# Ambitions 2.0 Master Plan

> Historical note: This file is retained for traceability only.
> It is not active product, implementation, release, or Codex process authority.
> Current authority starts in `docs/truth/README.md`.
> Use this only after reconciling against `docs/truth/*`, `docs/status/*`, and `docs/status/old-canon-classification-index.md`.

---

Adoption date: 2026-04-24

## Executive Summary

Ambitions 2.0 is a major app transformation, not a minor polish wave.

"Ambitions makes my life feel organized, and gives me the concrete steps to accomplish anything I set my mind to."

Expanded thesis:

"Ambitions exists to unlock people's lives by turning ambitions, goals, tasks, plans, and real-world constraints into clear next steps, believable plans, proof of progress, and calm recovery when life changes."

The active design source of truth is [design/Ambitions_Design_Constitution.md](design/Ambitions_Design_Constitution.md). It wins for design, IA, UX writing, component naming, interaction, trust, accessibility, and external-surface contracts when older active docs conflict.

The current master product and visual direction is [Ambitions_Master_Product_Visual_System_Spec_v2.md](Ambitions_Master_Product_Visual_System_Spec_v2.md). Its top-level thesis is: "Ambitions is a premium iPhone-native life operating system that uses adaptive panels, timeline rails, grounded time context, receipts, proof, and action closure to help people know where to start, take the right step, recover without shame, and trust what changed." It supersedes older conflicting language around next-move wording, manual Focus CTAs, guessed durations, vacation/free-time assumptions, silent reflow, stale overdue-task behavior, and punitive completion language.

Ambitions 2.0 is not merely a planner, habit tracker, goal app, calendar wrapper, analytics dashboard, or beautiful productivity app. It is the daily operating loop that keeps life objects continuous, believable, provable, recoverable, correctable, trusted, remembered, focused, strategically pathed, and calm.

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
- `You` is the Personal System Center: profile, personalization, What Ambitions Knows, Reviews, Analytics, Trust & Explanations, Privacy, Sync / Export, Integrations, Appearance, Notifications, Accessibility, and Settings.
- Life Areas are visible organization lenses inside Goals and You, not a sixth tab.
- North Stars are long-range dormant or identity-level ambitions under Life Areas.
- `Task = standalone One-Step Goal`; `Step = action inside a Goal, Path, or Plan`.
- Smart Attachment is the named Capture routing/correction system for attaching captured material to Life Areas, Ambitions, Goals, Plans, Steps, Tasks, Proof, Decisions, Rituals, or Waiting items.
- Panel Size and Display Density are active design controls: `Compact / Comfortable / Large` and `Minimal / Balanced / Detailed`, defaulting to `Balanced + Comfortable`.
- `GroupedNavigationList` is the official categorized settings/depth pattern. It is not primary execution UI.
- Top-level screens stay capped and calm: one dominant hero panel, one or two supporting panels, and deeper content below the fold.
- Detail screens can be denser when the density explains, edits, reviews, or audits a specific object.
- Rich widget-like panels are the default presentation model. Plain text cards are not the 2.0 design target.
- Ambitions is not a task manager with goals attached. It is a visual life execution system where Goal, Plan, Milestone, Task, Proof, Decision, Weather, and Archive stay connected by design.
- The Goal / Plan / Task visual systems are planned canon, not current UI completion: Goal Lifecycle Rail, Goal Atlas, Proof Spine as the vertical visual expression of Proof Rail, Next Visible Step, Goal Weather, Decision Trail, Timeline View, Milestone Cards, Kanban-lite Task Lane, Weekly Plan Strip, and Completion Archive.
- Every active goal must resolve to one obvious Next Visible Step; every plan must explain why the week is believable; every task must visibly serve a goal and create or support proof.
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
- Life Graph v1 is in Ambitions 2.0 scope as the shared relationship layer for goals, milestones, actions, blockers, people, commitments, resources, evidence, windows, constraints, decisions, memories, corrections, and receipts.
- Action Closure is in Ambitions 2.0 scope as a trust layer: every meaningful command must produce a visible result/receipt, explain what changed and why, offer correction, and offer undo where safely supported.
- Reality Reflow is in Ambitions 2.0 scope as the shared plan-mutation/recovery system. It must never silently reschedule work and must preserve Plan-owned calendar permission policy.
- The global shell/chrome is an Ambitions 2.0 product system, not incidental styling. A dedicated future batch must align the persistent app frame before later major surface redesigns consume it.
- The remaining roadmap must mature major Ambitions 2.0 inventions before release candidate rather than stopping at v1 foundations. [Ambitions_2_0_RC_Maturity_Plan.md](Ambitions_2_0_RC_Maturity_Plan.md) owns the maturity gates, RC milestones, batch size ceiling, dependency map, performance strategy, and mature-invention coverage.
- Accessibility Nutrition Facts are required: internal checklist first, user-facing `You -> Accessibility` summary only after verification.
- Accessibility claims remain unverified until audited; no user-facing accessibility claim should be published without evidence.
- Dedicated device runtime is an architecture guardrail only in Ambitions 2.0. Do not build active hardware/runtime surfaces unless they naturally fall out of sync, Now State, or Command Pipeline work.

## Top-Level IA

### Today

Daily execution center. Shows what matters now, the next believable action, schedule pressure, recovery options, and contextual insight panels.

### Goals

Goal portfolio and Goal Detail entry. Shows active direction, goal health, path progress, next milestone, and explanation surfaces.

### Capture

Fast intake and triage. Owns raw capture, quick goal seeds, plan seeds, waiting items, archive, and routing into Goals or Plan. Capture remains singular.

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

## Object Model And Life Organization

Canonical object hierarchy:

```text
Life Area
-> Ambition / North Star
-> Goal
-> Path
-> Plan
-> Milestone
-> Step
-> Proof
-> Receipt / Review
```

Tasks are standalone One-Step Goals. They can exist without a Life Area, Ambition, Goal, or Plan; they can still carry category, time, reminder, location, priority, proof, history, and review value; and they can be promoted into Goals, attached to Goals, or converted into Rituals. A Goal can be demoted into a Task when the structure is too heavy, with a receipt.

Life Areas and North Stars are primary organization lenses inside Goals and You. Life Areas Overview is the plain user-facing surface. Life Areas Atlas is the richer visual system name. Neither creates a sixth tab.

## Scope

Ambitions 2.0 includes:

- top-level shell IA change to Today / Goals / Capture / Plan / You
- Insights demotion
- Habits absorption
- You Personal System Center
- Life Areas / North Stars
- One-Step Goals
- Smart Attachment
- GroupedNavigationList
- Panel Size and Display Density controls
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
- Life Graph v1 and object relationships as the connector between Capture, Today, Goals, Plan, You, Reviews, Path Intelligence, Proof of Progress, Commitments, Waiting Room, corrections, and receipts
- Action Closure and receipts across app actions, calendar writes, export/import, external surfaces, corrections, safe failures, and undo-eligible changes
- Living Capture, Commitments and Waiting Room, Proof of Progress, Correction Cards, Anti-Plan / Not Today, Personal Operating Constitution, Review Constellation, and Life OS Receipt as Ambitions 2.0 v1 commitments where scoped by owning batches
- bounded Ambitions-specific engines such as Believability Kernel, Constraint Gravity, Decision Debt, Attention Shield, Opportunity Window, Momentum Integrity, Memory Confidence, Assumption Watchtower, Proof Rail, Trust Ledger, Narrative Memory Map, Re-entry, Safe Automation Boundary, and the one-step doctrine, clustered into roadmap layers rather than one batch per invention
- Accessibility Nutrition Layer
- Apple-first sync
- export/import trust fallback
- App Intents and shared container readiness
- simple polished Widgets and Live Activity v1 after Now State and Command Pipeline stability
- onboarding, empty states, returning-user continuity, verification, and release hardening
- maturity gates for every major invention: foundation, first useful surface, cross-surface integration, trust/correction/degraded state, performance/accessibility, and RC verification
- recurring and dedicated performance passes after major feature waves
- representative scenario validation before RC

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
2. One recommended step before breadth.
3. Insight belongs at the decision point.
4. Recovery is a first-class execution path.
5. Plan must degrade gracefully without permissions.
6. Trust requires explanation, export/import, and local-first handling.
7. Rich visual state must reduce reading burden.
8. Top-level surfaces must stay calm.
9. Build shared systems once before surfaces consume them.
10. Apple-native external surfaces follow stable internal truth.
11. One-step doctrine: when the user is overwhelmed, Ambitions collapses complexity into one believable step.
12. Proof over theater: progress must be backed by actions, artifacts, decisions, feedback, resolved blockers, calendar completions, notes, files, links, photos, or reflections rather than fake percentages alone.
13. Correction over black boxes: recommendations, assumptions, memory, and actions must be correctable and future behavior must learn only from evidence and user-confirmed signals.
14. Do Less Better: Ambitions may recommend dropping, shrinking, parking, or reviewing instead of adding work.
15. Maturity over novelty: a major invention is not release-ready until it is coherent, correctable, accessible, performant, trusted, and verified across its required surfaces.
16. No hidden complexity: when the product becomes smarter, the user's next decision must become easier.
17. Goal direction before task volume: the user should never have to translate a giant task list into a life direction; Ambitions must show the direction, path, next action, and proof relationship directly.
18. Archive as intelligence: completed, cancelled, dropped, parked, merged, or transformed goals preserve why they changed and what was learned instead of becoming dead clutter.

## Goal / Plan / Task Visual Doctrine

The canonical hierarchy is:

- Goal = direction.
- Plan = believable path.
- Milestone = meaningful checkpoint.
- Task = standalone One-Step Goal.
- Step = contained action inside a Goal, Path, or Plan.
- Proof = evidence of real progress.
- Decision = reason the path changed.
- Weather = readable health signal.
- Archive = memory and learning.

The app visually prioritizes:

1. Current goal direction.
2. Next Visible Step.
3. Current plan window.
4. Proof of momentum.
5. Risk/blocker clarity.
6. Timeline context.
7. Archive/learning.

Every goal should answer what it is, why it matters, what state it is in, what the next visible step is, what proof exists, what could block it, what changed, and what happens next.

Every plan should answer whether it is believable, which goal it serves, what proof it creates, what is protected this week, and what needs to be reduced, deferred, or renegotiated.

Every Task should answer whether it stands alone, what it may attach to, why now, how much effort it requires, what proof it will create, and whether it is later, next, doing, waiting, or done. Every Step should answer which larger Goal, Path, or Plan it serves.

## P0 / P1 Design Risk Resolution References

The Design Constitution and supporting specs resolve the completed design audit risks by name:

- [design/Ambitions_Design_Constitution.md](design/Ambitions_Design_Constitution.md) locks IA, Insights demotion, Habits absorption, Task/Step distinction, Life Areas/North Stars, You Personal System Center, calendar permission timing, accessibility truth, motion doctrine, and external-surface gates.
- [design/screen-contract-matrix.md](design/screen-contract-matrix.md) locks screen contracts.
- [design/component-contract-matrix.md](design/component-contract-matrix.md) locks component contracts and accessibility requirements.
- [design/panel-density-size-spec.md](design/panel-density-size-spec.md) locks Panel Size, Display Density, and modularity safe zones.
- [design/grouped-navigation-list-spec.md](design/grouped-navigation-list-spec.md) locks GroupedNavigationList naming and usage.
- [design/smart-attachment-spec.md](design/smart-attachment-spec.md) locks Smart Attachment behavior.
- [design/ux-writing-state-language-matrix.md](design/ux-writing-state-language-matrix.md) locks writing and state language.
- [design/accessibility-nutrition-screen-matrix.md](design/accessibility-nutrition-screen-matrix.md) keeps Accessibility Nutrition unverified until audited.
- [design/external-surfaces-contract.md](design/external-surfaces-contract.md) locks notification, widget, Live Activity, App Intent, Shortcut, and future Focus Filter contracts.

## Design Constitution Implementation Sequencing

The Design Constitution is documented and ready for future implementation, but this plan does not claim the surfaces are fully implemented. Future roadmap work should preserve this order:

1. Canon/source-of-truth cleanup.
2. Shared object terminology.
3. Shared component primitives.
4. GroupedNavigationList foundation.
5. Panel Size + Display Density foundation.
6. Receipt / Action Closure contract.
7. Smart Attachment contract.
8. Life Areas / North Stars object model.
9. One-Step Goals object model.
10. Screen contract implementation.
11. Today transformation with Today Plan Layer.
12. Capture transformation with Smart Attachment.
13. Goals / Life Areas / North Stars transformation with accessible Semantic Zoom.
14. Plan / Timeline / Rituals transformation with local-first calendar-derived insight and Plan-owned permission.
15. You Personal System Center.
16. Trust Center / What Ambitions Knows with receipt search/history.
17. Accessibility Nutrition verification.
18. External surfaces after Now State, Command Pipeline, receipts, and privacy snapshots.
19. Release-candidate validation.

## Daily Continuity Loop

Ambitions 2.0 must become a daily continuity loop:

1. Capture messy life.
2. Classify what kind of life object it is.
3. Attach it to goals, people, time, resources, proof, or waiting.
4. Show one believable recommended step.
5. Protect what matters when reality breaks.
6. Produce a receipt for what changed.
7. Let the user correct memory, assumptions, recommendations, and actions.
8. Carry that learning into tomorrow.
9. Review what changed without guilt.
10. Preserve continuity across devices, external surfaces, export/import, and returning-user states.

The remaining roadmap must produce this loop, not five polished but separate tabs.

## Success Definition

Ambitions 2.0 succeeds when the app can turn a meaningful goal into a believable path, place the right action into the user's real day, explain why it matters, recover calmly when the plan breaks, and preserve user trust through local-first data handling, sync clarity, export/import, accessibility verification, and Apple-native continuity.

## Decision Log

The concise locked record lives in [Ambitions_2_0_Decision_Log.md](Ambitions_2_0_Decision_Log.md). This master plan explains those decisions and is the primary readable canon.
