# Ambitions 3.0 — Screenshot Readiness Spec

Status: Historical supporting canon; subordinate to `docs/truth/*`
Parent doc: [Ambitions 3.0 Front-End Redesign Index](./Ambitions_3_0_Front_End_Redesign_Index.md)  
Last updated: 2026-04-30

---

## Purpose

Ambitions should be screenshot-ready without becoming fake.

This spec defines what it means for a screen to be investor-ready, App Store-ready, and design-review-ready while still reflecting real product truth.

---

## Screenshot Readiness Thesis

A great Ambitions screenshot should make a person understand the app before reading a paragraph.

Each screenshot should show:

- one dominant purpose
- one signature object
- one premium visual idea
- one clear user value
- one trustworthy next action

---

## Global Screenshot Rules

Every screenshot-ready surface must pass:

- instantly understandable in 3 seconds
- no equal-weight card pile
- no generic to-do feel
- no fake calendar clone
- no fake AI dashboard
- no productivity score
- no streak or gamification pressure
- no inaccessible tiny text
- no placeholder content that looks like production data
- no future capability shown as shipped behavior
- no visual noise added only for decoration

---

## Required Screenshot Set

Minimum Ambitions 3.0 screenshot set:

1. Today — Day Rail / Start here
2. Today — Close the loop / Still Counts
3. Capture — What needs a place?
4. Capture — Suggested Place / Needs a Place
5. Plan — Week Believability
6. Plan — Month / Life Shape
7. Goals — Ambition Portfolio
8. Goal Detail — Mission Control / Proof
9. You — You are in control
10. Trust — What Ambitions Knows / Receipts
11. First Run — first useful object
12. Recovery — Make today doable

---

## Screen-Specific Readiness

### Today — Day Rail

Must show:

- compact context header
- `Start here`
- one recommended step
- Now / Next / Later rail
- source/duration/context label
- one clear primary action

Must not show:

- separate dashboard cards above rail
- generic task list
- focus-timer-first UI
- productivity score

### Today — Closure

Must show:

- calm closure prompt
- Still Counts option where relevant
- receipt/proof result
- no failure/shame copy

### Capture

Must show:

- restrained dark-sky/starfield only if tasteful
- bottom composer
- `What needs a place?`
- suggested place after input
- Change / Decide later route

Must not show:

- chat bubble UI
- generic notes UI
- inbox backlog as first impression

### Plan

Must show:

- Day / Week / Month scope clarity
- believability / pressure without scores
- open windows or pressure weeks
- protected/vacation truth where relevant

Must not show:

- raw calendar clone
- impossible week pretending to hold
- silent auto-reflow

### Goals

Must show:

- Ambition Portfolio feel
- most important goal
- next visible step
- proof marker
- lane-based Goal Detail depth

Must not show:

- KPI dashboard
- project-management board
- fake progress percentages

### You

Must show:

- `You are in control`
- Planning Setup high on the screen
- What Ambitions Knows
- Receipts & History
- calm grouped navigation

Must not show:

- generic settings page
- social profile
- data-console language

---

## Content Fixture Rules

Use content that proves the Golden Launch Loop.

Canonical demo fixture:

```text
Release 3 songs by August 1
```

Supporting examples may include:

- Draft verse idea
- Schedule vocal session
- Export rough mix
- Send demo for feedback
- Save feedback as proof
- Reschedule recording because day became too full

Avoid generic placeholders:

- Task 1
- Goal title
- Lorem ipsum
- Buy milk unless testing a household task route

---

## Visual Quality Checklist

A screenshot passes visual quality when:

- first viewport has one dominant idea
- type hierarchy is obvious
- spacing feels premium
- panels are not crowded
- dark mode has depth without mud
- light mode remains usable where shown
- accent color is restrained
- rails/nodes communicate state, not decoration
- empty space feels intentional
- primary CTA is obvious
- secondary actions do not compete

---

## Trust Checklist

A screenshot passes trust quality when:

- the user can tell why something appears
- source labels are truthful
- automation does not appear controlling
- receipts/proof are visible where relevant
- sensitive/private items are protected
- future-only behavior is not shown as shipped

---

## Accessibility Screenshot Checks

Before using a screenshot for investor/App Store material, verify:

- text contrast is acceptable
- Dynamic Type does not break the intended layout in equivalent QA
- touch targets appear reasonably sized
- no meaning is color-only
- reduce-motion state has equivalent clarity if motion is part of the story
- screenshot copy is readable on small phone preview

---

## No Fake Capability Rule

Screenshots may use preview fixtures, but they must not imply unimplemented behavior is shipped.

Allowed:

- deterministic preview fixtures
- canonical demo content
- clearly implemented UI states
- planned states in internal design boards labeled as planned

Not allowed:

- App Store screenshots showing future-only sync/export/AI/memory/platform behavior as if shipped
- fake calendar writes
- fake automation outcomes
- fake accessibility claims
- fake cloud/sync status

---

## Acceptance Criteria

A screen is screenshot-ready when:

- it shows one signature object
- it maps to the Golden Launch Loop
- it has no dashboard/card-wall drift
- it uses canon copy
- it is privacy-safe
- it is visually premium
- it is honest about implementation truth
