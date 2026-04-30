# Ambitions 3.0 — Plan Life Suite Endgame

Status: Active Ambitions 3.0 Plan canon  
Parent doc: [Ambitions 3.0 Front-End Redesign Index](./Ambitions_3_0_Front_End_Redesign_Index.md)  
Primitive architecture: [Ambitions 3.0 Primitive Architecture](./Ambitions_3_0_Primitive_Architecture.md)  
Last updated: 2026-04-30

---

## Purpose

This document defines the endgame for Plan.

Plan is not a small believability panel. Plan is Ambitions' full Life Planning Suite.

---

## Core Thesis

Plan helps the user shape days, weeks, months, seasons, decisions, commitments, capacity, recovery, and ambition paths into a believable life.

Plan does not ask only:

```text
What is scheduled?
```

Plan asks:

```text
Does this hold together?
```

---

## What Plan Is

Plan is a suite for:

- Day Shape
- Week Shape
- Life Shape
- Horizon
- Capacity
- Commitments
- Decisions
- Reflow
- Recovery
- Planning Defaults
- Vacation / Away Time
- Plan-to-Today handoff
- Today-to-Plan return

---

## What Plan Is Not

Plan is not:

- a raw calendar clone
- a task scheduler
- an AI auto-planner
- a due-date list
- a productivity dashboard
- a project-management board
- a fake optimization surface

---

## Plan Suite Structure

```text
Plan
├── Day Shape
├── Week Shape
├── Life Shape
├── Horizon
├── Capacity
├── Commitments
├── Decisions
├── Reflow
├── Recovery
└── Planning Defaults
```

These are Plan rooms/lenses/scopes, not new top-level destinations.

---

## Day Shape

Question:

```text
What does today actually hold?
```

Owns:

- hard context
- work/school/protected blocks
- available windows
- current pressure
- planned steps
- recovery space
- Today handoff

Signature object:

```text
Day Shape Rail
```

This is not the Today rail. It shows fit and capacity, not live execution.

---

## Week Shape

Question:

```text
Can this week actually hold?
```

Owns:

- heavy days
- light days
- protected evenings
- admin windows
- creative windows
- deadline pressure
- decision blockers
- recovery gaps
- goal distribution

Signature object:

```text
Week Pressure Weave
```

---

## Life Shape

Question:

```text
What shape is my life taking?
```

Owns:

- milestone weeks
- pressure weeks
- protected arcs
- vacations / away time
- life area focus
- major commitments
- goal deadlines
- recovery weeks
- review markers

Signature object:

```text
Life Shape Map
```

This is not a month grid.

---

## Horizon

Question:

```text
What is the next meaningful chapter?
```

Owns:

- seasonal arcs
- quarterly goals
- major life events
- financial cycles
- career cycles
- creative cycles
- health cycles
- relationship/family commitments

Signature object:

```text
Horizon Arc
```

---

## Capacity

Question:

```text
How much can my life realistically hold?
```

Owns:

- available capacity
- energy bands
- heavy/light step limits
- admin capacity
- creative capacity
- recovery budget
- commute/transition buffers
- recurring obligations

Signature object:

```text
Capacity Envelope
```

---

## Commitments

Question:

```text
What is already spoken for?
```

Owns:

- calendar events
- work/school blocks
- protected time
- recurring obligations
- deadlines
- appointments
- family/social commitments
- away time

Signature object:

```text
Commitment Layer Stack
```

---

## Decisions

Question:

```text
What decisions are blocking the plan?
```

Owns:

- decision debt
- tradeoffs
- blocked goals
- schedule conflicts
- scope choices
- deadline choices
- what to drop
- what to defer
- what to protect

Signature object:

```text
Decision Deck
```

Decision actions:

- Decide now
- Collect info
- Ask someone
- Set decision date
- Remove decision
- Waiting

---

## Reflow

Question:

```text
What should change now that reality changed?
```

Owns:

- before / after plan
- what moved
- what stayed
- what became protected
- what became waiting
- what needs closure
- what creates receipt

Signature object:

```text
Reflow Preview
```

No silent reflow.

---

## Recovery

Question:

```text
How do I restart without shame?
```

Owns:

- missed day
- missed week
- long absence
- vacation return
- illness
- low energy
- overloaded plan
- goal restart

Signature object:

```text
Recovery Contract
```

Example:

```text
For the next 3 days, Ambitions will show one small step and closure prompts only.
```

---

## Planning Defaults

Question:

```text
How should Ambitions plan for me?
```

Owns:

- default step size
- max heavy steps
- preferred creative windows
- preferred admin windows
- recovery preference
- vacation behavior
- automation comfort
- notification posture

Ownership rule:

```text
You owns settings. Plan uses them.
```

---

## Plan Landing Behavior

Plan opens contextually:

- active day -> Day Shape
- planning window -> Week Shape
- long-range review -> Life Shape
- conflict moment -> Decisions
- changed day/week -> Reflow
- bad stretch -> Recovery

The user may still manually switch rooms/scopes.

---

## Plan-To-Today Handoff

Plan hands Today:

- recommended step candidate
- available window
- context label
- duration source
- pressure state
- recovery suggestion
- blockers/waiting state
- proof/receipt context

Today executes. Plan shapes.

---

## Today-To-Plan Return

Today returns:

- completed closures
- Still Counts closures
- rescheduled items
- waiting/blocker states
- actual durations
- rejected recommendations
- proof saved
- plan corrections

---

## Plan Language

Core phrase:

```text
Does this hold together?
```

Other approved copy:

- This week is tight.
- Choose what should stay.
- Open time is not always free time.
- Review before Ambitions changes anything.
- Away time is protected.

---

## Acceptance Criteria

Plan Life Suite is mature when:

- Day Shape, Week Shape, and Life Shape each have distinct jobs
- Plan-to-Today handoff is explicit
- Today-to-Plan return is explicit
- decisions blocking the plan are visible
- reflow is previewed and approved
- recovery is a planned mode
- vacation/away time is protected by default
- open time is classified before recommendation
- Plan never becomes a raw calendar clone
