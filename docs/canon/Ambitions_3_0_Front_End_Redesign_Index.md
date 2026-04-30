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
- Capture: Minimal composer plus placement routes
- Plan: Contextual Day / Week / Month / Life Shape planner
- Goals: Mission Control / Goal Detail path system
- You: Personal system center for setup, trust, memory, history, and planning defaults

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

---

## Planned Child Docs

These docs should be added as the redesign proceeds. Keep links here even before implementation begins.

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

### Plan

- [ ] Plan Day scope redesign
- [ ] Plan Week scope redesign
- [ ] Month / Life Shape redesign
- [ ] Schedule & Availability setup
- [ ] Planning Defaults setup
- [ ] Vacation / Away Time setup
- [ ] Reflow preview and plan integrity UI

### You

- [ ] You / Personal System Center redesign
- [ ] Planning Setup section
- [ ] Automation & Trust controls
- [ ] What Ambitions Knows
- [ ] Receipts and history
- [ ] Privacy / data controls
- [ ] Reviews and reflections

### System-wide

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
3. Compare the child doc against existing repo canon and implementation.
4. Do not implement child specs blindly if they conflict with higher-priority canon.
5. Preserve the canonical tabs: Today, Goals, Capture, Plan, You.
6. Keep changes modular and testable.
7. Avoid widening the app.
8. Prefer reusable primitives over one-off UI.
9. Add previews and tests with every build batch.
10. Do not claim release readiness unless physical-device, accessibility, and App Store gates are actually verified.

---

## Human / ChatGPT Usage Instructions

When discussing future redesign work:

1. Add the new redesign topic to this parent doc.
2. Create a linked child doc for that specific surface or component.
3. Keep child docs implementation-grade, not just conceptual.
4. Record decisions in the child doc rather than scattering them across chat.
5. If a child doc changes the product direction, update this parent doc too.

---

## Current Priority

The current highest-priority Ambitions 3.0 front-end redesign object is:

> Today — Ambitions Day Rail

Reason:

Today is the flagship daily-use surface. If Today does not immediately answer what matters now, why it matters, what fits, what changed, and what counted, Ambitions cannot feel like the most important app on a user’s phone.

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

---

## Current Linked Specs

- [Ambitions 3.0 — Day Rail SwiftUI Build Spec](./Ambitions_3_0_Day_Rail_SwiftUI_Build_Spec.md)
