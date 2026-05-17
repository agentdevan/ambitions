# Ambitions 3.0 — UI Invention Upgrade Bank

Status: Historical supporting canon; subordinate to `docs/truth/*`
Parent doc: [Ambitions 3.0 Front-End Redesign Index](./Ambitions_3_0_Front_End_Redesign_Index.md)  
Evaluation framework: [Ambitions 3.0 UI Invention Evaluation Framework](./Ambitions_3_0_UI_Invention_Evaluation_Framework.md)  
Last updated: 2026-04-30

---

## Purpose

This bank canonizes 160 mature Ambitions-specific app upgrade ideas for future front-end, interaction, trust, planning, capture, goal, review, external-surface, accessibility, AI/personalization, and market/demo work.

These are not generic productivity features. They are Ambitions-native UI/product inventions designed around the Golden Launch Loop:

```text
Capture → Place → Plan → Do Today → Close / Recover → Save Proof
```

---

## Canon Status

All ideas in this bank are canonized as valid Ambitions 3.0 invention candidates.

This file does not mean all ideas are implemented.

Each idea still requires:

- implementation batch assignment
- owner surface
- detailed child spec if it changes UI architecture
- accessibility pass
- trust/privacy pass where relevant
- tests/previews
- implementation evidence before shipped claims

---

## Priority Legend

- P0: strengthens the Golden Launch Loop or resolves flagship coherence
- P1: high-impact flagship differentiation
- P2: maturity, polish, trust, accessibility, or depth
- P3: later expansion

---

# 1. System-Wide Flagship Inventions

## 1. Golden Thread

Priority: P0  
Loop: full loop  
Owner: system-wide object lifecycle

Every meaningful object can show its lifecycle:

```text
Captured from → Placed in → Planned for → Surfaced today → Closed as → Proof saved
```

Use in Step Detail, Goal Detail, receipts, reviews, and object info sheets.

Must not become a technical data lineage panel.

---

## 2. Object Passport

Priority: P1  
Loop: full loop  
Owner: object detail / trust

Every Step, Goal, Capture, Proof item, Memory, and Plan item can open a compact info sheet showing origin, current home, reason for appearance, source facts, privacy level, receipts, proof, and correction options.

Must feel like an iOS-native info sheet, not a database console.

---

## 3. What Changed Trail

Priority: P0  
Loop: Close / Recover, Save Proof  
Owner: receipts / trust

Any time Ambitions moves, adjusts, learns, or recommends something, the user can open a short trail:

```text
Captured Monday
Placed in Creative
Planned for Thursday
Moved because Thursday became full
Still Counts saved Friday
```

Must not become a verbose audit log in normal UI.

---

## 4. Why This Everywhere

Priority: P0  
Loop: Plan, Do Today, Place  
Owner: recommendation contract

Every recommendation has a compact explanation pattern with up to three source bullets.

Must not become a chatbot answer, AI confidence display, or defensive system explanation.

---

## 5. Reality-Safe Automation

Priority: P0  
Loop: full loop  
Owner: Automation & Trust

Automation posture is always visible:

```text
Suggested
Asked
Applied with your approval
Applied automatically
Needs review
```

Must not hide meaningful changes.

---

## 6. Object Safety State

Priority: P1  
Loop: full loop  
Owner: object lifecycle / trust

Objects can show calm safety states:

```text
Safe
Needs review
Private
Waiting
Blocked
Protected
Local only
```

Must not become warning badges or risk scores.

---

## 7. No Silent Change Ledger

Priority: P0  
Loop: Plan, Close / Recover, Trust  
Owner: You / Trust

You includes a visible rule:

```text
Ambitions never silently changes meaningful plans.
```

Below it, show what Ambitions may suggest, ask, or adjust.

---

## 8. Source Label System

Priority: P0  
Loop: Plan, Do Today, Recommendations  
Owner: recommendation contract

Every planned or recommended item shows a source label:

```text
User-set
Suggested
Calendar-derived
Based on closure
Based on planning default
Based on goal path
```

No source label means not eligible for flagship recommendation UI.

---

## 9. Correction Memory

Priority: P1  
Loop: Trust / Personalization  
Owner: What Ambitions Knows

When the user corrects Ambitions, the correction becomes a visible trust object and can optionally become memory.

Must require confirmation before high-impact or sensitive learning.

---

## 10. Ambient State Language

Priority: P1  
Loop: Plan, Today  
Owner: system copy / state matrix

System-wide day states:

```text
Clear
Tight
Protected
Away
Low-control
Needs recovery
Waiting-heavy
Open but do not fill
```

Use instead of scores.

---

# 2. Today / Day Rail Inventions

## 11. Reality Rail

Priority: P0  
Loop: Do Today, Close / Recover, Save Proof  
Owner: Today / Day Rail

The Day Rail evolves into a reality spine showing Start here, Now, Next, Later, Closure needed, and Proof saved as adaptive rail states.

Must preserve `AmbitionsDayRailView` and avoid dashboards.

---

## 12. Closure Diamond

Priority: P0  
Loop: Close / Recover  
Owner: Day Rail / Action Closure

Changed or unresolved steps become calm diamond rail nodes that open Action Closure.

Must not become overdue badges or failure states.

---

## 13. Proof Pulse

Priority: P1  
Loop: Save Proof  
Owner: Day Rail / Proof

When proof is saved, the rail shows a restrained pulse, then collapses into a small proof marker.

Must not use confetti, streaks, trophies, or gamified celebration.

---

## 14. Readiness Ring

Priority: P0  
Loop: Do Today  
Owner: Day Rail / Recommended Step

The recommended step shows qualitative readiness:

```text
Ready
Needs time
Needs place
Needs energy
Needs decision
Waiting
Too large
```

No percentages or model confidence.

---

## 15. Start Here Eligibility Check

Priority: P0  
Loop: Do Today  
Owner: recommendation contract

A step can become Start here only if it is ready or reviewable, fits context, has a source label, has an explanation, and has user controls.

Disqualified steps appear as Needs Review or another safe state.

---

## 16. Make Smaller Control

Priority: P0  
Loop: Plan, Do Today, Recovery  
Owner: Step Detail / Today

Oversized steps expose `Make smaller`.

Example:

```text
Record full demo → Record chorus scratch take
```

Must stay grounded in the same goal.

---

## 17. Day Pressure Band

Priority: P1  
Loop: Plan, Do Today  
Owner: Day Rail / Plan

Rail background subtly communicates spacious, workable, tight, too full, protected, or away.

Must not become a stress meter or heatmap.

---

## 18. Protected Time Veil

Priority: P1  
Loop: Plan, Do Today  
Owner: Day Rail / Schedule

During work, school, vacation, protected time, or away time, Today softens and states the protected context.

Must not treat every open minute as free time.

---

## 19. Still Counts Fast Path

Priority: P0  
Loop: Close / Recover, Save Proof  
Owner: Action Closure / Day Rail

Partial or changed progress gets a fast `Still Counts` route to proof.

This should become a flagship emotional-differentiation feature.

---

## 20. Rail Collapse Memory

Priority: P2  
Loop: Do Today / Personalization  
Owner: You / Planning Defaults

If a user repeatedly collapses Today detail, Ambitions suggests a calmer default density: Calm, Balanced, or Detailed.

Requires visible memory confirmation.

---

## 21. One-Decision Today

Priority: P0  
Loop: Do Today  
Owner: Today

The first Today viewport asks at most one meaningful decision.

Examples: Start now / Adjust plan, or Close the loop / Review later.

---

## 22. Day End Soft Closure

Priority: P1  
Loop: Close / Recover, Save Proof  
Owner: Today / Review

At night, Today shifts from execution to `What counted today?`, summarizing Completed, Still Counts, Moved, Waiting, Proof saved.

No guilt framing.

---

## 23. Tomorrow Carryover Gate

Priority: P0  
Loop: Close / Recover, Plan  
Owner: Action Closure / Plan

Unfinished steps do not automatically dump into tomorrow. The user chooses Carry forward, Reschedule, Not needed, Still Counts, or Review later.

---

## 24. Rail Why Not View

Priority: P1  
Loop: Recommendations / Trust  
Owner: Day Rail / Recommendation Ledger

Users can see why other candidates were not recommended.

Must be compact and optional.

---

## 25. Active Step Capsule

Priority: P1  
Loop: Started / Step Session  
Owner: Today / Step Session

When a Step Session is active, Today compresses into a capsule that resumes the step.

Must not label it incomplete.

---

# 3. Step Detail Inventions

## 26. Step Brief

Priority: P0  
Loop: Do Today  
Owner: Step Detail

Every Step Detail opens with what this is, why now, what it supports, what done means, and what counts.

---

## 27. Done Definition

Priority: P1  
Loop: Close / Recover  
Owner: Step Detail / Action Closure

Steps can define `Done when` and `Counts if`.

For creative or hard steps, `Counts if` may be more useful than binary done.

---

## 28. Step Weight

Priority: P1  
Loop: Plan, Do Today  
Owner: Plan / Step Detail

Steps have qualitative weight:

```text
Light
Medium
Heavy
Deep
Admin
Recovery
```

No points or scores.

---

## 29. Step Shape

Priority: P1  
Loop: Plan, Do Today  
Owner: Step Detail / Recommendation Contract

Steps can declare shape:

```text
Quick action
Deep work
Errand
Conversation
Decision
Creative pass
Recovery
Waiting
```

---

## 30. Friction Notes

Priority: P1  
Loop: Plan, Do Today, Recovery  
Owner: Step Detail

Step Detail can show likely friction such as needs quiet, laptop, energy, reply, place, or tool.

Offers Make smaller, move, or mark waiting.

---

## 31. Open Context

Priority: P1  
Loop: Goal connection / Do Today  
Owner: Step Detail

Step Detail shows connected Goal, Path, and Proof context so actions do not feel isolated.

---

## 32. Step Alternatives

Priority: P1  
Loop: Recovery / Goal Progress  
Owner: Step Detail / Goal Detail

Blocked steps can offer grounded alternatives under the same goal.

Must not produce unrelated busywork.

---

## 33. Step Expiry

Priority: P2  
Loop: Plan, Close / Recover  
Owner: Step Detail / Plan

Some steps naturally expire after meetings, vacations, deadlines, or events. Expired steps become closure prompts, not failures.

---

## 34. Step Readiness Checklist

Priority: P2  
Loop: Do Today  
Owner: Step Detail

Optional readiness checklist: Time, Place, Tool, Energy, Dependency.

Only visible when readiness is low.

---

## 35. Step Why It Matters One-Liner

Priority: P1  
Loop: Do Today / Goal connection  
Owner: Step Detail

A human one-liner connects action to ambition.

Must not become motivational fluff.

---

# 4. Step Session Inventions

## 36. Step Session, Not Focus Mode

Priority: P0  
Loop: Started  
Owner: Step Session

Step Session is an execution space, not a timer screen. It shows step title, why it matters, suggested duration, notes/proof, Close the loop, Pause, Adjust, and optional timer.

---

## 37. Proof Capture During Session

Priority: P1  
Loop: Started, Save Proof  
Owner: Step Session / Proof

Users can attach note, photo, file, text proof, decision, or blocker during a session.

---

## 38. Session Drift Detection

Priority: P1  
Loop: Recovery  
Owner: Step Session

Repeated pauses/exits trigger calm options: Too big? Make smaller, Move it, Mark waiting, Still Counts.

---

## 39. Counts If Session Mode

Priority: P1  
Loop: Close / Recover  
Owner: Step Session / Action Closure

For hard, creative, or emotional steps, session can show `This counts if...` criteria.

---

## 40. Session Landing Receipt

Priority: P1  
Loop: Save Proof  
Owner: Step Session / Receipts

After closure, session returns a receipt such as `Still Counts · Saved as proof` plus the next safe action.

---

## 41. Session Recovery Branch

Priority: P1  
Loop: Recovery  
Owner: Step Session / Placement Resolver

Blocked session outcomes can become Waiting, Decision, Needs a Place, or next smaller step.

---

## 42. Optional Timer Personality

Priority: P2  
Loop: Started / Personalization  
Owner: Step Session / Planning Defaults

Timer modes: Hidden, Soft estimate, Count-up, Countdown. Default is soft estimate or hidden.

---

## 43. Session Do Not Disturb Suggestion

Priority: P3  
Loop: Started  
Owner: Step Session

For deep steps, Ambitions may suggest silencing distractions but must not force system Focus.

---

## 44. Session Resume Card

Priority: P1  
Loop: Started / Do Today  
Owner: Today / Step Session

Mid-step exit produces a Resume card, not Incomplete copy.

---

## 45. Session Outcome Memory

Priority: P2  
Loop: Personalization  
Owner: Step Session / Memory

If a step type is repeatedly marked too large, Ambitions may ask to make future steps smaller by default.

Requires confirmation.

---

# 5. Capture Inventions

## 46. Quiet Command Sheet

Priority: P0  
Loop: Capture  
Owner: Capture

Capture is a premium bottom composer asking `What needs a place?`.

Must not become chat, notes, or inbox.

---

## 47. Capture Gravity

Priority: P1  
Loop: Capture, Place  
Owner: Capture / Placement Resolver

As the user types, Ambitions may show likely gravity: looks like a step, proof, goal, waiting, or needs a place.

Must not force classification.

---

## 48. Placement Preview

Priority: P0  
Loop: Place  
Owner: Placement Resolver

Before confirmation, show object type, destination, consequence, Place it, Change, Decide later.

---

## 49. Needs a Place Shelf

Priority: P0  
Loop: Place  
Owner: Capture / Place

Unclear captures go to a small safe shelf, not an inbox.

Language: `3 things need a place`.

---

## 50. Ready to Place

Priority: P1  
Loop: Place  
Owner: Placement Resolver

When enough signal exists, an unresolved capture becomes Ready to Place with one recommendation.

---

## 51. Grow into Goal

Priority: P0  
Loop: Capture, Place, Goals  
Owner: Capture / Goals

Broad intent can become a goal through a compact question such as `What would be true if this was working?`.

Must not become a long wizard.

---

## 52. Capture as Proof

Priority: P0  
Loop: Capture, Save Proof  
Owner: Capture / Proof

Already-done captures can be saved as proof.

Example: `Sent the demo to Mike` -> `Save as proof · Music Goal`.

---

## 53. Capture as Waiting

Priority: P1  
Loop: Capture, Place  
Owner: Placement Resolver

Dependency-based captures can become Waiting items instead of Today tasks.

---

## 54. Capture as Decision

Priority: P1  
Loop: Capture, Place, Plan  
Owner: Placement Resolver / Plan

Choice-based captures can become Decisions that surface in Plan or Goal Detail.

---

## 55. Capture Privacy Guard

Priority: P0  
Loop: Capture, Trust  
Owner: Capture / Trust

Potentially sensitive captures save privately and hide details from widgets/previews by default.

---

## 56. Capture Use My Words

Priority: P1  
Loop: Capture, Place  
Owner: Capture

Structured objects keep original user wording visible.

Prevents sterile productivity translation.

---

## 57. Capture Duplicate Sense

Priority: P1  
Loop: Place / Object Ownership  
Owner: Placement Resolver

Similar captures can attach to existing goals/steps to avoid object sprawl.

---

## 58. Capture Recovery Mode

Priority: P1  
Loop: Recovery  
Owner: Capture / Action Closure

After a disrupted day, Capture can ask `What changed?` and route to Still Counts, Needs Recovery, Waiting, or Not needed.

---

## 59. Capture From Step Session

Priority: P1  
Loop: Started, Capture, Proof  
Owner: Step Session / Capture

Quick capture during Step Session defaults to the current step/goal context.

---

## 60. Capture Later But Safe

Priority: P0  
Loop: Capture, Place  
Owner: Capture

`Decide later` saves safely to Needs a Place with receipt.

No guilt backlog.

---

# 6. Plan Inventions

## 61. Believability View

Priority: P0  
Loop: Plan  
Owner: Plan

Plan asks `Does this hold together?` with qualitative states: Clear, Workable, Tight, Too much planned, Needs recovery, Protected, Low-control.

---

## 62. Capacity Envelope

Priority: P1  
Loop: Plan  
Owner: Plan

Available capacity appears as a soft envelope, not rigid precision.

Example: `Today can hold about 2 medium steps after work.`

---

## 63. Pressure Weeks

Priority: P1  
Loop: Plan / Month Life Shape  
Owner: Plan

Month view highlights heavy weeks, protected weeks, milestone weeks, recovery weeks, and open weeks.

---

## 64. Open Time Classification

Priority: P0  
Loop: Plan, Do Today  
Owner: Plan / Schedule

Open time is classified as available, flexible, protected, low-control, recovery, open but do not fill, or unavailable.

---

## 65. Plan Fit Reasons

Priority: P1  
Loop: Plan / Trust  
Owner: Plan

When something does or does not fit, Plan explains why in short source facts.

---

## 66. Reflow Preview

Priority: P0  
Loop: Plan, Trust  
Owner: Plan

Plan changes show before/after and require approval for meaningful changes.

---

## 67. Plan Treaty

Priority: P1  
Loop: Plan  
Owner: Plan

A short human agreement summarizes the day/week plan.

Example: `Keep one creative step, protect Friday night, move admin to Sunday.`

---

## 68. Planning Defaults

Priority: P0  
Loop: Plan / Personalization  
Owner: You / Plan

User-owned defaults include ideal step size, max heavy steps, creative/admin windows, recovery preference, vacation behavior, and automation comfort.

---

## 69. Vacation Truth

Priority: P0  
Loop: Plan / Protected Time  
Owner: Plan / You

Vacation/away time is not free time unless explicitly marked available.

---

## 70. Planning Debt

Priority: P1  
Loop: Plan  
Owner: Plan

Planning debt is unresolved decisions that stop the plan from holding, not task debt.

---

## 71. Decision Pressure

Priority: P1  
Loop: Plan / Decisions  
Owner: Plan

Plan surfaces choices blocking the plan, such as two competing Saturday items.

---

## 72. Recovery Budget

Priority: P1  
Loop: Plan / Recovery  
Owner: Plan

Plan reserves recovery space after overloaded periods.

---

## 73. Plan Confidence Without Scores

Priority: P0  
Loop: Plan  
Owner: Plan / Copy

Use qualitative labels: Looks doable, Tight but possible, Does not hold, Needs your choice.

No percentages.

---

## 74. Week Shape Summary

Priority: P1  
Loop: Plan / Week  
Owner: Plan

Week top summary: heavy days, protected evenings, open windows, decisions blocking progress.

---

## 75. Plan-to-Today Handoff

Priority: P0  
Loop: Plan -> Do Today  
Owner: Plan / Today

Plan hands Today the recommended step, available window, context label, duration source, pressure state, and recovery suggestion.

---

# 7. Goals Inventions

## 76. Ambition Portfolio

Priority: P0  
Loop: Goals / Save Proof  
Owner: Goals

Goals Home becomes a portfolio of active direction, not a list.

Sections: Active Ambitions, Most important now, Needs review, Waiting, Proof recently saved, Parked.

---

## 77. Goal Weather

Priority: P1  
Loop: Goals / Reviews  
Owner: Goals

Qualitative goal states: Clear, Moving, Waiting, Blocked, Too broad, Needs proof, Needs next step, At risk, Parked.

No health scores.

---

## 78. Next Visible Step Requirement

Priority: P0  
Loop: Goals -> Do Today  
Owner: Goals / Goal Detail

Every active goal shows next visible step, waiting reason, blocked reason, needs review, or parked.

---

## 79. Goal Mission Control

Priority: P0  
Loop: Goals / Plan / Proof  
Owner: Goal Detail

Goal Detail lanes: Overview, Path, Steps, Proof, Decisions, Risks, Archive.

---

## 80. Proof Rail

Priority: P0  
Loop: Save Proof  
Owner: Goal Detail

Proof Rail shows decisions, artifacts, feedback, Still Counts, blockers resolved, and plan adjustments.

Not a checklist.

---

## 81. Assumptions Lane

Priority: P1  
Loop: Goals / Plan  
Owner: Goal Detail

Serious goals can list assumptions such as recording frequency, revision time, or deadline rigidity.

When assumptions break, Plan adapts with user approval.

---

## 82. Goal Risk Card

Priority: P1  
Loop: Goals / Recovery  
Owner: Goal Detail

Risks become reality cards with suggested grounded steps.

---

## 83. Goal Path Compression

Priority: P1  
Loop: Goals  
Owner: Goal Detail

Long paths compress into Now, Next, Later, Waiting, Proof.

---

## 84. Goal Decision Log

Priority: P1  
Loop: Goals / Receipts  
Owner: Goal Detail

Major goal changes record deadline changes, scope changes, milestone moves, pause, archive, and why.

---

## 85. Goal Scope Guard

Priority: P1  
Loop: Capture, Goals  
Owner: Goals

If a goal is too broad, Ambitions suggests it may be an Ambition and offers to create the first goal under it.

---

## 86. Goal Proof Threshold

Priority: P2  
Loop: Goals / Proof  
Owner: Goal Detail

Some goals define proof types: artifact, conversation, financial progress, health record, practice session, decision.

---

## 87. Goal Parking

Priority: P1  
Loop: Goals / Review  
Owner: Goals

Parked goals are not failed. They are inactive but preserved for review.

---

## 88. Goal Recovery

Priority: P1  
Loop: Goals / Recovery  
Owner: Goal Detail

Dormant goals ask: Still yours? Resume, Make smaller, Park, Archive.

---

## 89. Goal Relationship Map

Priority: P2  
Loop: Goals / Plan  
Owner: Goal Detail

Goal Detail shows supports, competes with, and depends on relationships.

---

## 90. Goal Why It Matters Lock

Priority: P1  
Loop: Goals / Motivation without fluff  
Owner: Goal Detail

Goals have stable human reasons that anchor action without hype.

---

# 8. You / Trust / Memory Inventions

## 91. You Are In Control Panel

Priority: P0  
Loop: Trust / Personalization  
Owner: You

Top of You shows guided automation status, memories needing review, receipts, and setup completeness.

---

## 92. What Ambitions Knows

Priority: P0  
Loop: Trust / Memory  
Owner: You / Trust

Grouped memory cards show creative windows, preferred step size, protected evenings, sensitive areas, and corrections.

Each card shows source, freshness, what it affects, change, pause, delete.

---

## 93. Memory Source Card

Priority: P0  
Loop: Trust / Memory  
Owner: What Ambitions Knows

Memory cards explain what Ambitions learned, source, effect, and controls: Keep, Change, Pause, Delete.

---

## 94. Trust Center Modes

Priority: P1  
Loop: Trust  
Owner: Trust Center

Qualitative trust states: Clear, Needs Review, Limited, Private, Paused, Confirmation Needed, Local Only, Not Set Up, Unavailable.

---

## 95. Automation Ladder

Priority: P0  
Loop: Trust / Automation  
Owner: Automation & Trust

Per-domain automation levels: Suggest only, Ask before changing, Apply safe changes, Never automate.

Domains include Today recommendations, Plan reflow, Memory learning, Capture placement, Proof attachment, Notifications, Calendar writes.

---

## 96. Memory Review Ritual

Priority: P1  
Loop: Trust / Reviews  
Owner: You / Reviews

Weekly prompt: `Ambitions learned these things. Keep them?`

---

## 97. Receipts & History

Priority: P0  
Loop: Trust / Receipts  
Owner: You / Receipts

Searchable views: What changed, What counted, What moved, What Ambitions suggested, What I corrected.

---

## 98. Privacy Preview

Priority: P1  
Loop: Trust / External Surfaces  
Owner: You / Privacy

Before enabling widgets/notifications, show what may appear outside the app.

---

## 99. Data Boundaries

Priority: P1  
Loop: Trust / Data  
Owner: You / Privacy

Show calm categories: Stored on device, Used for recommendations, Shown outside app, Exportable, Not stored.

---

## 100. Planning Setup Value Copy

Priority: P0  
Loop: Personalization / Plan  
Owner: You

Rows explain why setup matters, such as schedule helping Ambitions find real open windows.

---

## 101. Personal System Review

Priority: P1  
Loop: Reviews / Trust  
Owner: You / Reviews

Monthly review asks what changed about life: schedule, goals, availability, energy, priorities, or nothing.

---

## 102. Corrections Inbox

Priority: P2  
Loop: Trust / Personalization  
Owner: You / Trust

A list of places the user corrected Ambitions, used to review patterns.

Not a task inbox.

---

## 103. Forget This Everywhere

Priority: P0  
Loop: Trust / Memory  
Owner: Recommendation / Memory

Any memory-influenced recommendation has Change this, Forget this, or Do not use for recommendations.

---

## 104. Trust Receipts

Priority: P1  
Loop: Trust / Receipts  
Owner: You / Receipts

Settings and automation changes create receipts too.

---

# 9. Reviews Inventions

## 105. What Counted Today

Priority: P0  
Loop: Save Proof / Review  
Owner: Reviews / Today

Daily review shows Completed, Still Counts, Moved, Waiting, Proof saved, Plan changed.

No score.

---

## 106. Weekly Life OS Receipt

Priority: P1  
Loop: Reviews  
Owner: Reviews / You

Weekly receipt includes what moved, waited, changed, still matters, needs decision, and what Ambitions learned.

---

## 107. Review-to-Plan Bridge

Priority: P1  
Loop: Reviews -> Plan  
Owner: Reviews / Plan

Review ends by carrying forward one step, one waiting item, or one planning decision.

---

## 108. Proof Highlights

Priority: P1  
Loop: Save Proof / Reviews  
Owner: Reviews

Review highlights real progress, decisions, and Still Counts moments.

---

## 109. Drift Detection

Priority: P1  
Loop: Reviews / Plan  
Owner: Reviews

If behavior diverges from goals, Ambitions calmly asks whether to adjust the plan.

Must not accuse the user.

---

## 110. Life Area Balance Without Judgment

Priority: P2  
Loop: Reviews  
Owner: Reviews / You

Show attention patterns by Life Area without balance scores or shame.

---

## 111. Stuck Pattern Review

Priority: P1  
Loop: Reviews / Goals / Recovery  
Owner: Reviews / Goal Detail

Repeated blocked/waiting closures suggest a different next step, smaller step, waiting state, path change, or parked goal.

---

## 112. Still Counts Gallery

Priority: P1  
Loop: Save Proof / Reviews  
Owner: Reviews / Proof

A review surface for meaningful partial progress.

Emotionally unique, not gamified.

---

## 113. Decisions Made

Priority: P1  
Loop: Reviews / Proof  
Owner: Reviews

Reviews treat decisions as progress: reduced scope, moved deadline, protected time.

---

## 114. Review Memory Suggestions

Priority: P1  
Loop: Reviews / Memory  
Owner: Reviews / What Ambitions Knows

Repeated patterns may become memory suggestions only after user confirmation.

---

# 10. First Run / Onboarding Inventions

## 115. First Useful Object

Priority: P0  
Loop: Capture -> Place  
Owner: First Run / Capture

First run creates one useful object before setup.

---

## 116. No Permission Wall

Priority: P0  
Loop: First Run / Trust  
Owner: Onboarding

No calendar, notifications, account, or AI setup request before value.

---

## 117. First Run Starfield

Priority: P1  
Loop: First Run / Visual Signature  
Owner: Onboarding

Restrained dark-sky visual identity allowed for First Run only.

---

## 118. Demo Goal Fixture

Priority: P0  
Loop: Demo / Screenshot / Tests  
Owner: Preview Fixtures

Use `Release 3 songs by August 1` across previews, screenshots, investor demos, and onboarding samples.

---

## 119. Setup After Value

Priority: P0  
Loop: First Run / You Setup  
Owner: Onboarding / You

After first object, setup prompts explain value: schedule helps recommendations become believable.

---

## 120. First Receipt Moment

Priority: P0  
Loop: First Run / Trust  
Owner: Onboarding / Receipts

First aha moment is a receipt such as `Saved as Goal · Creative` plus first step suggested.

---

# 11. External Surfaces Inventions

## 121. Lock Screen Start Here

Priority: P2  
Loop: Do Today / External Surfaces  
Owner: Widgets / Lock Screen

Widget shows only Start here, step title, duration, and context when privacy allows.

---

## 122. Closure Widget

Priority: P2  
Loop: Close / Recover  
Owner: Widgets

Privacy-safe widget can close the loop with Still Counts or Reschedule.

---

## 123. Live Activity Step Session

Priority: P2  
Loop: Started  
Owner: Live Activities

Live Activity shows active Step Session, suggested duration, and Close the loop.

Not timer-first.

---

## 124. Notification Receipts

Priority: P2  
Loop: Receipts / Notifications  
Owner: Notifications

Notifications confirm meaningful outcomes rather than nagging.

---

## 125. Protected Time Notification Rule

Priority: P1  
Loop: Trust / Notifications  
Owner: Notifications / Schedule

No execution pushes during protected/away time unless explicitly allowed.

---

## 126. Sensitive Widget Projection

Priority: P1  
Loop: Privacy / External Surfaces  
Owner: Widgets / Privacy

Private steps show generic labels such as `Private step`.

---

## 127. Siri Shortcut: Capture Something

Priority: P3  
Loop: Capture  
Owner: App Intents

Voice shortcut captures to Ambitions and saves safely to Needs a Place unless placement confidence is high.

---

## 128. Siri Shortcut: Close the Loop

Priority: P3  
Loop: Close / Recover  
Owner: App Intents

Shortcut asks what happened and offers Completed, Still Counts, Rescheduled, or Waiting.

---

# 12. Visual System Inventions

## 129. Rail / Node Language

Priority: P0  
Loop: visual system / full app  
Owner: Signature Objects and Rail Grammar

System-wide grammar: circle = step, diamond = closure/decision, document mark = proof/receipt, muted node = waiting/protected, aperture = capture.

---

## 130. Quiet Gold

Priority: P1  
Loop: visual system  
Owner: Design System

Warm gold is reserved for recommended step, proof saved, active rail node, and primary user-approved action.

---

## 131. Graphite Depth

Priority: P1  
Loop: visual system  
Owner: Design System

Dark mode uses layered graphite depth rather than flat black dashboard styling.

---

## 132. Premium Empty States

Priority: P1  
Loop: all surfaces  
Owner: Surface State Matrix

Empty states use calm, intentional language such as `Nothing needs you yet.`

---

## 133. Recovery Motion

Priority: P2  
Loop: Plan / Recovery  
Owner: Motion System

Plan changes can softly move objects along rail/path, with text equivalent for Reduce Motion.

---

## 134. Proof Glow

Priority: P2  
Loop: Save Proof  
Owner: Motion / Proof

Proof saved gets a soft momentary glow, then becomes a calm marker.

---

## 135. Collapse / Expand Discipline

Priority: P0  
Loop: all top-level surfaces  
Owner: Signature Objects

Every top-level screen has compact first viewport and drill-down for depth.

---

## 136. Native Sheet Hierarchy

Priority: P1  
Loop: all surfaces  
Owner: IA / Components

Sheets are used for Why this, Close the loop, Place it, Change this, Receipt peek. Full screens are used for Step Session, Goal Detail, Plan scope, You trust controls.

---

## 137. Contextual Header System

Priority: P1  
Loop: all tabs  
Owner: Shell / Headers

Compact state-aware headers such as Today · Work until 5, Plan · Week, Goals · Creative active, You · Guided.

---

## 138. App Icon Logic

Priority: P3  
Loop: brand / market  
Owner: Brand

Icon should imply direction, rail, ambition, and quiet premium. Avoid checkmarks, targets, rockets, trophies.

---

# 13. AI / Personalization Inventions

## 139. Recommendation Ledger

Priority: P1  
Loop: Recommendations / Trust  
Owner: Recommendation Contract

Ledger stores candidates, chosen step, why chosen, not chosen, user response, closure result, proof, and correction.

Not an AI console.

---

## 140. Pattern Permission

Priority: P0  
Loop: Memory / Trust  
Owner: What Ambitions Knows

Ambitions asks before using repeated behavior as memory.

---

## 141. Recommendation Rejection Learning

Priority: P1  
Loop: Personalization / Recommendations  
Owner: Recommendation Contract

Repeated ignored recommendations can trigger a suggestion to reduce that recommendation type.

---

## 142. User Correction Over Model Guess

Priority: P0  
Loop: Trust / Personalization  
Owner: Trust / Memory

User corrections outrank inferred patterns. This should be visible in Trust.

---

## 143. Confidence Hidden, Evidence Visible

Priority: P0  
Loop: Recommendations / Trust  
Owner: Recommendation Contract

Never show model confidence. Show source facts.

---

## 144. Anti-Autopilot Check

Priority: P0  
Loop: Automation / Trust  
Owner: Automation & Trust

Major automation changes prompt review first.

---

## 145. Recommendation Cooling

Priority: P1  
Loop: Recommendations  
Owner: Recommendation Contract

Dismissed suggestions cool down and do not repeatedly resurface the same day.

---

## 146. Personalization Sandbox

Priority: P2  
Loop: You / Planning Defaults  
Owner: Planning Defaults

Users can preview how settings would affect a normal week before confirming.

---

# 14. Accessibility / ADHD Support Inventions

## 147. Cognitive Load Mode

Priority: P1  
Loop: all surfaces  
Owner: You / Accessibility

Density modes: Calm, Balanced, Detailed. Changes top-level density, not feature access.

---

## 148. One Thing Mode

Priority: P0  
Loop: Today / Recovery  
Owner: Today / Accessibility

Today can show only Start here when the user is overwhelmed.

---

## 149. Low Energy Day

Priority: P1  
Loop: Today / Plan / Recovery  
Owner: Today / Plan

User can mark Low energy today. Ambitions shifts to lighter steps, closure prompts, smaller steps, and recovery protection.

---

## 150. Time Blindness Support

Priority: P0  
Loop: Today / Plan  
Owner: Day Rail

Today uses Now / Next / Later with real windows and soft boundaries.

---

## 151. Too Much Escape Hatch

Priority: P0  
Loop: Recovery / Plan  
Owner: all overloaded surfaces

Every overloaded screen offers `Make this lighter`.

---

## 152. No-Scroll First Value

Priority: P0  
Loop: all top-level tabs  
Owner: signature objects

The first viewport of every top-level screen must contain the screen's value.

---

## 153. VoiceOver Rail Summary

Priority: P1  
Loop: Today / Accessibility  
Owner: Day Rail

Day Rail VoiceOver summary states recommended step, closure needs, and protected blocks.

---

## 154. Motion Meaning Equivalence

Priority: P1  
Loop: Motion / Accessibility  
Owner: Motion System

Every motion event has a text equivalent, such as Proof saved, Plan adjusted, Moved to Saturday.

---

## 155. Touch Target Discipline

Priority: P0  
Loop: all touch surfaces  
Owner: Accessibility / Components

Rail nodes are visual; rows are tappable. Do not rely on tiny nodes for actions.

---

# 15. Market / App Store / Investor Inventions

## 156. Still Counts Screenshot

Priority: P1  
Loop: market / recovery  
Owner: Screenshot Readiness

One screenshot centers Still Counts as differentiated emotional product value.

---

## 157. Start Here Screenshot

Priority: P1  
Loop: market / Today  
Owner: Screenshot Readiness

One screenshot shows Start here, duration, context, and reason.

---

## 158. What Ambitions Knows Screenshot

Priority: P1  
Loop: market / Trust  
Owner: Screenshot Readiness

One screenshot shows memory source, what it affects, and Change/Pause/Delete controls.

---

## 159. Life Shape Screenshot

Priority: P1  
Loop: market / Plan  
Owner: Screenshot Readiness

One screenshot shows pressure weeks, protected time, milestones, and life areas.

---

## 160. Investor Demo Story

Priority: P0  
Loop: full loop / market  
Owner: Demo Fixtures

Canonical demo story:

```text
Release 3 songs by August 1
```

Show:

```text
Capture → Place → Plan → Today → Step Session → Still Counts → Proof → Review
```

This is the clearest Ambitions story.

---

## First Canonization Set

The first ten ideas to move from bank to child specs are:

1. Reality Rail
2. Closure Diamond
3. Proof Pulse
4. Readiness Ring
5. Why This Everywhere / Why This Peel
6. Step Brief
7. Still Counts Fast Path
8. Placement Preview
9. Week Shape Summary
10. What Ambitions Knows Memory Card

These are the highest-leverage because they make Ambitions feel uniquely Ambitions immediately.

---

## Implementation Rule

Do not implement this whole bank at once.

Use this bank to select coherent invention packages and convert them into child docs or F-series implementation batches.

Every implemented idea must preserve:

- the five-tab shell
- the Golden Launch Loop
- the Day Rail as Today signature object
- one signature object per tab
- trust/privacy boundaries
- accessibility requirements
- planned vs shipped distinction
