# Ambitions 3.0 — Front-End Implementation Batch Plan

Status: Historical supporting canon; subordinate to `docs/truth/*`
Parent doc: [Ambitions 3.0 Front-End Redesign Index](./Ambitions_3_0_Front_End_Redesign_Index.md)
Source override: [Ambitions 3.0 Source Of Truth Override](./Ambitions_3_0_Source_Of_Truth_Override.md)
Last updated: 2026-04-30

---

## Purpose

This document turns Ambitions 3.0 front-end canon into an ordered implementation lane.

It is docs-only planning. It does not mark any feature implemented.

The plan exists to prevent Codex from building attractive but disconnected UI panels. Every front-end batch must strengthen the Golden Launch Loop:

```text
Capture → Place → Plan → Do Today → Close / Recover → Save Proof
```

---

## Non-Negotiables

Every batch must preserve:

- top-level tabs: Today, Goals, Capture, Plan, You
- Ambitions 3.0 supersession over older conflicting front-end canon
- `AmbitionsDayRailView` as Today signature object
- no separate Hero Step Panel above the Day Rail by default
- no top-level Insights, Habits, Tasks, Calendar, Profile, Life Areas, or AI tab
- local-first launch posture
- trust/privacy/data controls not being paywalled
- no launch sync claim without evidence
- no accessibility claim without evidence
- no device/platform/release readiness claim without evidence
- no AI/model/confidence/productivity-score wording in normal UI
- no shame/failure copy for closure or recovery

---

## Batch Status Vocabulary

Use these exact status labels:

- `canonized`: active docs define the behavior
- `implementation-scoped`: a batch can implement it
- `implemented`: app code exists
- `previewed`: deterministic preview exists
- `tested`: automated tests exist
- `device-verified`: real-device verification exists
- `release-ready`: device, accessibility, App Store, and evidence gates pass

Do not collapse these statuses.

---

## Required Batch Template

Every F-series batch should include:

```markdown
# FXX — Batch Name

## Purpose

## Canon Docs Read

## Current Behavior

## Target 3.0 Behavior

## Golden Launch Loop Mapping
- Capture:
- Place:
- Plan:
- Do Today:
- Close / Recover:
- Save Proof:
- Trust / Privacy:

## Files Likely Affected

## What Must Not Change

## Implementation Notes

## Acceptance Criteria

## Tests / Previews Required

## Accessibility Requirements

## Planned vs Shipped Distinction

## Completion Summary Requirements
```

---

# F-Series Batch Plan

## F00 — Current Implementation Gap Audit

Status: implementation-scoped docs batch
Primary output: `Ambitions_3_0_Current_Implementation_Gap_Audit.md`

Purpose: compare current SwiftUI implementation, previews, tests, and canon against Ambitions 3.0.

Must not change app code.

Acceptance:

- evidence-backed file paths
- P0/P1/P2/P3 severity
- Golden Launch Loop blockers identified
- recommended F-batch assignment per gap
- no implementation claims without evidence

---

## F01 — Today Day Rail Model Foundation

Purpose: define model/view-state primitives that let Today render the 3.0 Day Rail without rewriting every Today system at once.

Canon docs:

- `Ambitions_3_0_Day_Rail_SwiftUI_Build_Spec.md`
- `Ambitions_3_0_Signature_Objects_And_Rail_Grammar.md`
- `Ambitions_3_0_Recommendation_Contract.md`
- `Ambitions_3_0_Surface_State_Matrix.md`

Likely files:

- `Native/Ambitions/Features/Today/TodayFeatureModels.swift`
- `Native/Ambitions/Features/Today/TodayExecutionViewState.swift`
- `Native/AmbitionsTests/Today/*`
- new Day Rail model files if needed

Acceptance:

- `DayRailState` or equivalent exists
- recommended step eligibility is explicit
- duration source is represented
- context source is represented
- closure/proof slots are represented
- sensitive item projection is represented

---

## F02 — Today Day Rail Visual Implementation

Purpose: make `AmbitionsDayRailView` the visible Today signature object.

Likely files:

- `Native/Ambitions/Features/Today/TodayScreen.swift`
- `Native/Ambitions/Features/Today/TodayPanels.swift`
- new `AmbitionsDayRailView.swift`
- previews / fixtures

Acceptance:

- Day Rail owns Today first meaningful viewport
- `Start here` appears inside the rail as `DayRailHeroStepCard`
- Now / Next / Later rows are tappable
- row tap opens Step Detail route or placeholder route
- closure/proof cards attach to rail, not separate dashboard stack
- old separate hero-panel behavior is removed, hidden, or compatibility-gated

---

## F03 — Step Detail

Purpose: create the lightweight inspection surface between rail row and Step Session.

Step Detail answers:

- what is this step?
- why is it here?
- what goal/plan does it support?
- is it ready?
- how long does it need?
- what can I change?

Acceptance:

- rail row tap opens Step Detail first
- `Start now` opens Step Session
- `Adjust plan`, `Why this?`, and `Make smaller` routes exist or are safely stubbed
- sensitive/private steps use compact privacy-safe labels

---

## F03.5 — Today Execution State Contract Hardening

Purpose: run immediately after F03 and before F04. Audit `TodayExecutionViewState.swift` after F01-F03 and extract Today rail/detail/projection responsibilities if thresholds are exceeded or if F04 would otherwise add complexity to the same file.

Rules:

- preserve behavior
- preserve F01-F03 tests
- do not build new behavior
- do not change user-visible UI except no-op structural preservation
- do not migrate global identifiers
- do not alter Step Session behavior

Acceptance:

- build passes
- `TodayViewModelTests` pass
- F01-F03 focused Today tests pass
- no user-facing copy change except incidental if required by extraction
- Today state/projection files have clearer ownership
- current run state and audit report are updated

---

## F04 — Step Session

Purpose: implement the real execution drill-down.

Rules:

- step-first, not timer-first
- optional timer only
- no `Start Focus` / `Focus Session` user-facing copy
- closure actions are visible

Acceptance:

- current step shown
- why it matters shown
- context/duration source shown
- proof/notes capture available or deliberately deferred
- Complete, Still Counts, Pause, Adjust available
- session end routes to Action Closure

---

## F05 — Action Closure Sheet

Purpose: create one shared closure grammar across Today, Step Detail, Step Session, Goal Detail, Plan, and Reviews.

Canon docs:

- `Ambitions_3_0_Action_Closure_Sheet_Spec.md`
- `Ambitions_3_0_Action_Verbs_And_Receipt_Grammar.md`
- `Ambitions_3_0_Proof_Receipts_And_Reviews_Contract.md`

Acceptance:

- top 3-4 likely outcomes shown by default
- full outcome list behind more options
- Completed, Still Counts, Rescheduled, Not needed, Blocked, Waiting, Needs Recovery, Needs Review supported
- closure creates receipt model/projection
- no failure/shame language

---

## F06 — Receipt Peek And Proof Saved

Purpose: make receipts visible beyond disposable toasts.

Acceptance:

- receipt toast exists for small confirmation
- receipt peek available by tap
- proof-saved state can attach to Day Rail
- receipt copy follows `[Result] · [Object] · [Destination or consequence]`
- sensitive receipts hide details in compact/external contexts

---

## F07 — Capture Composer Refinement

Purpose: bring Capture into 3.0 as a quiet command sheet with starfield restraint and post-input placement states.

Acceptance:

- top-level Capture remains composer-driven
- no chat UI
- no generic notes UI
- no long inbox before input
- bottom text field + mic inside field + add button right
- first-use state is ultra-minimal
- routes reveal after input

---

## F08 — Placement Resolver

Purpose: implement the Place step of the Golden Launch Loop.

Canon docs:

- `Ambitions_3_0_Placement_Resolver_Spec.md`
- `Ambitions_3_0_Object_Ownership_And_Appearance_Matrix.md`
- `CAPTURE_SMART_ATTACHMENT.md`

Acceptance:

- Suggested Place
- Needs a Decision
- Needs a Place
- Saved as Step / Goal / Proof / Waiting / Decision
- placement preview shows destination and consequence
- placement receipt is created
- wrong route can be changed
- sensitive/high-impact captures follow privacy checks

---

## F09 — Needs A Place / Ready To Place / Grow Into Goal

Purpose: complete Capture's secondary placement flows without creating a permanent inbox.

Acceptance:

- Needs a Place is temporary and safe
- Ready to Place gives clear next choices
- Grow into Goal helps transform broad intent into a meaningful goal
- unresolved items do not become shameful backlog

---

## F10 — Plan Day Scope

Purpose: make Plan's Day scope answer what the day can hold.

Acceptance:

- shows hard context
- shows open windows
- shows protected/away blocks
- shows what fits
- no raw calendar clone
- no silent reflow
- Today handoff is clear

---

## F11 — Plan Week Scope

Purpose: make Plan's Week scope answer whether the week actually holds.

Acceptance:

- shows pressure distribution
- identifies too much planned
- asks what should stay
- suggests lighter plan
- no fake precision score
- no silent reschedule

---

## F12 — Month / Life Shape

Purpose: make Month a life-shape planning view rather than a calendar grid.

Acceptance:

- life areas
- pressure weeks
- milestones
- protected time
- vacation / away
- major commitments
- review markers
- open weeks

---

## F13 — Goals Portfolio

Purpose: make Goals feel like an Ambition Portfolio, not a project board.

Acceptance:

- most important active goal highlighted
- goal rows show next visible step
- proof marker included
- risk/waiting marker if relevant
- no KPI wall
- no generic task board

---

## F13.5 — Goals / You / Trust Architecture Checkpoint

Purpose: run between F13 and F14 if Goals work reveals ownership, proof/trust boundary, memory, consent, or state-contract risk. Audit Goals, You, Trust, Evidence, Proof, and Memory boundaries; preserve behavior; clarify object ownership; prevent F14 from layering trust/memory controls over unclear goal/proof architecture.

Acceptance:

- build passes
- focused Goals/You/Trust tests pass where applicable
- ownership boundaries are documented
- privacy/memory risk is classified
- F14 can proceed safely or is blocked with exact repair prompt

---

## F14 — Goal Detail Mission Control

Purpose: make Goal Detail the one deep destination for a goal.

Required lanes:

- Overview
- Path
- Steps
- Proof
- Decisions
- Risks
- Archive

Acceptance:

- active goal has next visible step or a reason
- proof rail is evidence, not checklist
- decisions explain why things changed
- risks and waiting states are visible

---

## F15 — You Personal System Center

Purpose: make You a control center for setup, trust, memory, reviews, and personalization.

Acceptance:

- top status: `You are in control`
- Planning Setup appears high
- Schedule & Availability, Planning Defaults, Vacation / Away Time, Automation & Trust visible
- What Ambitions Knows and Receipts & History visible
- not a generic settings page
- no `Profile` user-facing naming

---

## F16 — Trust / Memory / Receipts Detail

Purpose: make trust controls actionable.

Acceptance:

- user can inspect memory categories
- memory source/freshness shown
- correction/delete/pause actions are visible where implemented
- receipt history route exists or is truthfully marked future
- export/import claims are truthful

---

## F16.5 — SwiftUI Architecture / State Contract Hardening

Purpose: run after F15 legacy identifier migration and F16 UI test modernization if architecture scan indicates risk before F17 Shell/Meridian. Audit feature state/projector/view boundaries across Today, Capture, Plan, Goals, You, AppUI, and Sources; extract giant feature files where risk is high; preserve behavior.

Acceptance:

- build passes
- focused tests pass
- full UI smoke is passing or all remaining failures are classified
- no feature behavior broadening
- no runtime dependencies
- architecture report created

---

## F17 — Ambition Meridian Shell Feature-Flagged

Purpose: introduce the Meridian only after content surfaces are stable.

Rules:

- routing remains TabView-safe
- feature flag or debug fallback exists
- destination labels accessible
- no persistent shell Close button
- no red badge/nag behavior
- Capture aperture is discoverable

Acceptance:

- Today / Goals / Capture / Plan / You each reachable in one tap
- VoiceOver order is correct
- Dynamic Type remains usable
- deep links are not broken

---

## F18 — Motion / Haptics / Accessibility Pass

Purpose: make 3.0 feel premium and accessible without motion noise.

Acceptance:

- Reduce Motion equivalent exists
- haptics are restrained
- rail/node states are not color-only
- Dynamic Type does not hide primary actions
- VoiceOver labels summarize purpose, state, and action

---

## F19 — Screenshot-Ready Polish

Purpose: make each top-level surface investor/App Store screenshot-ready without faking implementation.

Acceptance:

- one signature object per top-level screen
- no card pile
- no generic to-do/calendar/dashboard feel
- copy is human and canon-compliant
- screenshot states use real fixtures and clearly marked planned/future where needed

---

## F20 — 3.0 Release Evidence Gate

Purpose: verify implementation evidence before claiming Ambitions 3.0 readiness.

Acceptance:

- build/test commands recorded
- UI previews captured
- accessibility checklist completed
- real-device verification recorded if claimed
- App Store screenshot/readiness status truthfully documented

---

## Batch Dependency Rule

Do not build a dependent surface before its foundation exists.

Examples:

- Step Session depends on Step Detail or a clear Step route.
- Action Closure depends on shared closure outcomes.
- Receipt Peek depends on receipt projection.
- Placement Resolver depends on Capture post-input states.
- Meridian depends on stable root routing and top-level surface identity.

---

## Batch Completion Rule

A batch is complete only when it states:

- what changed
- what did not change
- canon docs read
- tests/previews run
- accessibility status
- planned vs shipped distinction
- remaining gaps

Do not call a batch complete merely because the app compiles.
