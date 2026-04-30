# Ambitions 3.0 Front-End Redesign Index

Status: Active planning parent doc  
Owner intent: Redesign each major Ambitions front-end surface with implementation-grade documentation before Codex build work.  
Last updated: 2026-04-30

---

## Purpose

This document is the parent index for the Ambitions 3.0 front-end redesign effort.

Ambitions 3.0 is not a new app, new product category, or replacement vision. It is the next front-end refinement layer for the existing Ambitions product direction: a premium iPhone-native life operating system for execution, goals, planning, capture, recovery, trust, and self-direction.

The goal of this parent doc is to give Codex, ChatGPT, and human reviewers one durable entry point for every front-end redesign spec created during the Ambitions 3.0 process.

Each child doc should be specific enough for implementation, but this parent doc should preserve the overall system logic, sequencing, and quality bar.

Supporting historical front-end program: [Ambitions Full Front-End Transformation Program](./Ambitions_Full_Frontend_Transformation_Program.md). Use that document only as supporting frontend ambition/history where it does not conflict with active 3.0 canon.

---

## Ambitions 3.0 Design Thesis

Ambitions should feel like:

- Native iPhone-first
- Premium
- Calm
- Restrained
- Human
- Expensive
- Trustworthy
- Useful enough to become one of the most important apps on someone’s phone

Ambitions should help the user:

- Know what matters now
- See the believable path through the day
- Understand how daily steps connect to larger ambitions
- Capture thoughts without friction
- Turn captures into useful structure
- Plan realistically
- Recover without shame
- Trust what changed
- Understand why Ambitions recommends something
- Feel their life is more organized, not more judged
- Become more successful by completing their ambitions with Ambitions as the support system

---

## Golden Launch Loop

Ambitions 3.0 front-end work must perfect this loop:

```text
Capture → Place → Plan → Do Today → Close / Recover → Save Proof
```

The complete 230-upgrade backlog for this loop now lives in:

- [Ambitions 3.0 — Golden Launch Loop Upgrade Bank](./Ambitions_3_0_Golden_Launch_Loop_Upgrade_Bank.md)

This upgrade bank is active front-end canon for Ambitions 3.0 planning. It must be used when creating Capture, Place, Plan, Today, Action Closure, Proof, Trust, AI/personalization, visual system, copy, and roadmap child specs.

### Day Rail protection rule

The Ambitions Day Rail is locked as the Today signature object. Golden Launch Loop upgrades must strengthen the Day Rail instead of replacing it.

Any Do Today upgrade must preserve:

- `AmbitionsDayRailView` as the dominant Today object.
- The compact Today context header above the rail.
- The rail as the Now / Next / Later navigation spine.
- `Start here` as one recommended step, not a dashboard of competing recommendations.
- Rail row tap opens Step Detail; only `Start now` opens Step Session.
- Closure and proof appear inside or directly attached to the rail.
- No generic timeline, task list, calendar clone, focus-timer-first redesign, productivity score, streak system, or extra Today dashboard stack.
- No starfield treatment on Today. Starfield remains Capture and First Run only unless canon is revised.

If a future implementation would conflict with the Day Rail spec, the Day Rail spec wins.

---

## Non-Negotiable Product Constraints

Ambitions 3.0 must not turn Ambitions into:

- A generic task app
- A habit tracker
- A calendar clone
- A project-management board
- A fake AI dashboard
- A SaaS dashboard
- A productivity guilt machine
- A gamified streak app
- A wide app with too many exposed top-level features

The canonical top-level tabs remain:

1. Today
2. Goals
3. Capture
4. Plan
5. You

No Ambitions 3.0 child spec should add new top-level tabs unless the parent canon is explicitly revised.

---

## Ambitions 3.0 Front-End Principles

### 1. Deep, not wide

Top-level screens should be calm and minimal, with meaningful drill-downs instead of exposed clutter.

### 2. Believable, not aspirational-only

Ambitions should help users make realistic progress in real life. It should not merely visualize goals beautifully.

### 3. Recovery is product quality

Missed, changed, blocked, or unfinished steps should become closure moments, not shame moments.

### 4. Trust must be visible

If Ambitions recommends, moves, adjusts, learns, or saves something, the user should be able to understand what happened and why.

### 5. Premium means restraint

Use fewer components, stronger hierarchy, native iOS patterns, refined typography, calm motion, and intentional spacing.

### 6. AI should feel grounded, not theatrical

Avoid fake confidence, black-box magic, and assistant-like noise. Prefer explainable recommendations, evidence labels, and user control.

### 7. Every top-level surface needs a signature object

Each main tab should have a clear flagship object or interaction that defines its purpose.

Examples:

- Today: Ambitions Day Rail
- System-wide shell: Ambition Meridian Shell
- Capture: Minimal composer plus placement routes
- Plan: Contextual Day / Week / Month / Life Shape planner
- Goals: Mission Control / Goal Detail path system
- You: Personal system center for setup, trust, memory, history, and planning defaults

### 8. Every meaningful object must answer the Golden Loop questions

Every step, capture, goal input, plan item, closure, receipt, and proof artifact should be able to answer:

```text
1. Where did this come from?
2. Where does it belong?
3. What is the next believable step?
4. When should it surface?
5. Why is it recommended?
6. What happened to it?
7. Did it still count?
8. What changed because of it?
9. Can the user undo or correct it?
10. Where is the proof?
```

If a surface cannot answer these questions, it is not yet integrated into the Ambitions 3.0 front-end loop.

---

## Active Ambitions 3.0 Child Docs

### 1. Today — Ambitions Day Rail

Document: [Ambitions 3.0 — Day Rail SwiftUI Build Spec](./Ambitions_3_0_Day_Rail_SwiftUI_Build_Spec.md)

Status: Active implementation spec draft  
Surface: Today  
Primary component: `AmbitionsDayRailView`  
Purpose: Make the Today screen’s signature object a premium execution spine that shows the user’s believable path through the day.

Core thesis:

> The Ambitions Day Rail should not show the user’s day. It should show the user’s believable path through the day.

### 2. System-wide — Ambition Meridian Shell

Document: [Ambitions 3.0 — Ambition Meridian Shell SwiftUI Build Spec](./Ambitions_3_0_Ambition_Meridian_Shell_SwiftUI_Build_Spec.md)

Status: Active implementation-grade child doc  
Surface: System-wide across Today, Goals, Capture, Plan, and You  
Primary component: `AmbitionsMeridianShell`  
Purpose: Replace the feeling of a standard five-tab dock with a premium connected-node navigation instrument that keeps Today as home, Capture globally available, and active context visible without intrusive pills or badges.

Core thesis:

> The Ambition Meridian Shell should not be a styled tab bar. It should be Ambitions’ signature navigation instrument: one calm connected line that shows where the user is, what is active, what needs closure, and where they can go.

### 3. System-wide — Golden Launch Loop Upgrade Bank

Document: [Ambitions 3.0 — Golden Launch Loop Upgrade Bank](./Ambitions_3_0_Golden_Launch_Loop_Upgrade_Bank.md)

Status: Active front-end canon companion  
Surfaces: Capture, Place, Plan, Today, Close / Recover, Proof, Trust, AI/personalization, visual system, copy, roadmap  
Primary loop: `Capture → Place → Plan → Do Today → Close / Recover → Save Proof`  
Purpose: Preserve the full 230-upgrade backlog for perfecting the launch loop while protecting the locked Day Rail invention.

Core thesis:

> Capture is how things enter. The Day Rail is where life gets executed. Action Closure is how reality gets handled. Receipts and proof are how trust compounds.

---

## Planned Child Docs

These docs should be added as the redesign proceeds. Keep links here even before implementation begins.

### Golden Launch Loop

- [x] 230-upgrade Golden Launch Loop bank
- [ ] Universal object lifecycle contract
- [ ] Recommended Step model refinement
- [ ] Step source and duration source labels
- [ ] Why This explanation system
- [ ] Receipt and proof creation contract
- [ ] Guided automation trust boundary system

### Today

- [x] Ambitions Day Rail
- [ ] Today Hero Step Panel refinement
- [ ] Step Detail
- [ ] Step Session
- [ ] Action Closure Sheet
- [ ] Today Recovery / Protect the Day flow
- [ ] Today Receipts / Proof Peek

### Goals

- [ ] Goals Home / Portfolio redesign
- [ ] Goal Detail / Mission Control redesign
- [ ] Goal Path / Roadmap visualization
- [ ] Proof Rail inside Goal Detail
- [ ] Goal health, pressure, and assumptions UI

### Capture

- [ ] Capture composer redesign
- [ ] Dark-sky/starfield Capture background rules
- [ ] Needs a Place flow
- [ ] Ready to Place flow
- [ ] Grow into Goal flow
- [ ] Capture-to-Today promotion
- [ ] Capture-to-proof promotion
- [ ] Capture decide-later queue

### Place

- [ ] Placement resolver
- [ ] Placement preview
- [ ] Placement receipt
- [ ] Placement undo
- [ ] Placement privacy checks
- [ ] Bulk placement

### Plan

- [ ] Plan Day scope redesign
- [ ] Plan Week scope redesign
- [ ] Month / Life Shape redesign
- [ ] Schedule & Availability setup
- [ ] Planning Defaults setup
- [ ] Vacation / Away Time setup
- [ ] Reflow preview and plan integrity UI
- [ ] Believability and overcommitment checks

### Close / Recover

- [ ] Unified Action Closure sheet
- [ ] Still Counts flagship treatment
- [ ] Recovery modes
- [ ] Closure reason taxonomy
- [ ] Long absence recovery
- [ ] Vacation return recovery

### Proof / Receipts

- [ ] Proof Rail
- [ ] What Counted review
- [ ] Receipt toast
- [ ] Receipt peek
- [ ] Receipt search
- [ ] Proof correction and privacy controls

### You

- [ ] You / Personal System Center redesign
- [ ] Planning Setup section
- [ ] Automation & Trust controls
- [ ] What Ambitions Knows
- [ ] Receipts and history
- [ ] Privacy / data controls
- [ ] Reviews and reflections

### System-wide

- [x] Ambition Meridian Shell
- [ ] Navigation and drill-down architecture
- [ ] Component system / design tokens
- [ ] Empty states
- [ ] Loading states
- [ ] Error states
- [ ] Accessibility system
- [ ] Motion and haptics system
- [ ] Copy and terminology guardrails
- [ ] App Store screenshot-ready surfaces

---

## Child Doc Required Structure

Every Ambitions 3.0 child doc should include these sections:

1. Product purpose
2. Surface ownership
3. User problem solved
4. Signature interaction or component
5. Non-goals
6. Visual direction
7. SwiftUI architecture
8. File plan
9. Domain/view state models
10. Component breakdown
11. Actions and navigation
12. Adaptive states
13. Accessibility requirements
14. Motion/haptics rules
15. Preview fixtures
16. Tests
17. Acceptance criteria
18. Codex implementation sequence
19. Known dependencies
20. Open questions

---

## Codex Usage Instructions

When using this parent doc with Codex:

1. Start with this file.
2. Open the child doc for the target surface.
3. Open the Ambition Meridian Shell spec when work touches the system-wide shell, app tabs, root routing, global Capture, active-step return state, closure state, or receipt state.
4. Open the Golden Launch Loop Upgrade Bank when the work touches Capture, Place, Plan, Today, Closure, Proof, Trust, AI/personalization, copy, or roadmap.
5. Compare the child doc against existing repo canon and implementation.
6. Do not implement child specs blindly if they conflict with higher-priority canon.
7. Preserve the canonical tabs: Today, Goals, Capture, Plan, You.
8. Preserve the locked Day Rail invention when working on Today or Do Today upgrades.
9. Keep changes modular and testable.
10. Avoid widening the app.
11. Prefer reusable primitives over one-off UI.
12. Add previews and tests with every build batch.
13. Do not claim release readiness unless physical-device, accessibility, and App Store gates are actually verified.

---

## Human / ChatGPT Usage Instructions

When discussing future redesign work:

1. Add the new redesign topic to this parent doc.
2. Create a linked child doc for that specific surface or component.
3. Keep child docs implementation-grade, not just conceptual.
4. Record decisions in the child doc rather than scattering them across chat.
5. If a child doc changes the product direction, update this parent doc too.
6. If a proposed Do Today upgrade changes the Day Rail, check the Day Rail protection rule before accepting it.
7. If a proposed shell upgrade changes top-level routing, check the Ambition Meridian Shell child doc before accepting it.

---

## Current Priority

The current highest-priority Ambitions 3.0 front-end redesign objects are:

1. Today — Ambitions Day Rail
2. System-wide — Ambition Meridian Shell
3. Golden Launch Loop integration

Reason:

Today is the flagship daily-use surface. If Today does not immediately answer what matters now, why it matters, what fits, what changed, and what counted, Ambitions cannot feel like the most important app on a user’s phone.

The Meridian Shell is the signature system-wide navigation object. If the shell feels like a generic tab bar, Ambitions loses the life-OS feeling before the user reaches the deeper product value.

The Golden Launch Loop ensures every major surface feeds that daily execution truth instead of becoming disconnected premium panels.

---

## Quality Bar

An Ambitions 3.0 front-end redesign is not complete until it is:

- Product-coherent
- Visually premium
- SwiftUI-buildable
- Accessibility-aware
- Trust-aware
- Testable
- Previewed
- Connected to existing canon
- Specific enough for Codex
- Calm enough for users
- Deep enough to feel like Ambitions
- Integrated into the Golden Launch Loop
- Non-regressive to the locked Day Rail when touching Today
- Non-regressive to the Ambition Meridian Shell when touching system-wide navigation

---

## Current Linked Specs

- [Ambitions 3.0 — Day Rail SwiftUI Build Spec](./Ambitions_3_0_Day_Rail_SwiftUI_Build_Spec.md)
- [Ambitions 3.0 — Ambition Meridian Shell SwiftUI Build Spec](./Ambitions_3_0_Ambition_Meridian_Shell_SwiftUI_Build_Spec.md)
- [Ambitions 3.0 — Golden Launch Loop Upgrade Bank](./Ambitions_3_0_Golden_Launch_Loop_Upgrade_Bank.md)
- [Ambitions Full Front-End Transformation Program](./Ambitions_Full_Frontend_Transformation_Program.md)
