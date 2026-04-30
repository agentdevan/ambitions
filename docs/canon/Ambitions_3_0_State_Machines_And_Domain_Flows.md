# Ambitions 3.0 — State Machines And Domain Flows

Status: Active Ambitions 3.0 engineering/product canon  
Parent doc: [Ambitions 3.0 Front-End Redesign Index](./Ambitions_3_0_Front_End_Redesign_Index.md)  
Primitive architecture: [Ambitions 3.0 Primitive Architecture](./Ambitions_3_0_Primitive_Architecture.md)  
Last updated: 2026-04-30

---

## Purpose

This document defines the key state machines and domain flows required for Ambitions 3.0.

Codex should build state-based systems, not one-off screen behavior.

---

## Golden Domain Flow

```text
Capture → Place → Plan → Do Today → Close / Recover → Save Proof
```

Every major object should either move through this flow or intentionally stop in a safe visible state.

---

# Step State Machine

## States

```text
Captured
Placed
Planned
Recommended
Opened
Started
Paused
Closed
Proven
Waiting
Blocked
Rescheduled
Not Needed
Archived
```

## Meaning

| State | Meaning |
|---|---|
| Captured | Raw input may become or relate to a step. |
| Placed | Step has a home. |
| Planned | Step has timing/context relationship. |
| Recommended | Step is eligible to surface. |
| Opened | User inspected Step Detail. |
| Started | User began Step Session. |
| Paused | Step Session paused or exited safely. |
| Closed | Reality outcome recorded. |
| Proven | Proof attached or generated. |
| Waiting | Dependent on person, time, info, place, or tool. |
| Blocked | Cannot progress because obstacle must be resolved. |
| Rescheduled | Still matters, moved to another time. |
| Not Needed | Intentionally removed. |
| Archived | No longer active. |

## Required Transitions

- Captured -> Placed
- Placed -> Planned
- Planned -> Recommended
- Recommended -> Opened
- Recommended -> Started
- Opened -> Started
- Started -> Paused
- Started -> Closed
- Paused -> Started
- Paused -> Closed
- Closed -> Proven when proof exists
- Closed -> Rescheduled when moved
- Closed -> Waiting when dependency created
- Closed -> Blocked when obstacle created
- Any active state -> Not Needed with user action
- Any active state -> Archived with user action

## Forbidden Transitions

- Started -> Proven without closure or explicit proof capture
- Planned -> Rescheduled silently
- Recommended -> Started without user action
- Waiting -> Recommended without dependency review
- Blocked -> Recommended unless resolving blocker is the recommended step

---

# Capture Lifecycle

```text
Empty → Input → Suggested Place → Confirmed / Changed / Decide Later → Receipt
```

Possible outcomes:

- Step
- Goal
- Proof
- Waiting
- Decision
- Plan item
- Needs a Place
- Grow into Goal
- Not Needed

Failure rule:

```text
Raw input must remain safe if save or placement fails.
```

---

# Placement Lifecycle

```text
Candidate → Preview → Confirmed → Receipt → Owner Surface
```

Alternative paths:

- Candidate -> Needs a Decision
- Candidate -> Needs a Place
- Preview -> Change
- Confirmed -> Undo where safe
- Confirmed -> Correction route

Placement must show consequence before or immediately after confirmation.

---

# Plan Reflow Lifecycle

```text
Change detected → Reflow preview → User approval → Applied changes → Receipt
```

Forbidden:

```text
Meaningful plan change without preview, approval, or receipt.
```

Safe lightweight changes may be suggested but still need visibility.

---

# Action Closure Lifecycle

```text
Closure prompt → Outcome selected → Optional reason/proof → Receipt → Plan/Goal/Review update
```

Outcomes:

- Completed
- Still Counts
- Rescheduled
- Not needed
- Blocked
- Waiting
- Needs Recovery
- Needs Review
- Review later

---

# Proof Lifecycle

```text
Candidate proof → Attached / Created → Receipt → Proof Rail / Review projection
```

Proof sources:

- closure
- capture
- step session
- manual attach
- review
- decision
- blocker resolution
- artifact

Proof must not become gamification.

---

# Memory Lifecycle

```text
Signal → Candidate memory → User review where required → Confirmed memory → Active / Paused / Corrected / Deleted
```

Rules:

- observed once is not memory
- sensitive/high-impact signals require explicit approval
- user correction is strongest signal
- deletion is a hard stop for that memory

---

# Recommendation Lifecycle

```text
Candidates → Eligibility filter → Source facts → Recommendation → User response → Closure/feedback → Ledger
```

User responses:

- accept
- start
- open
- adjust
- make smaller
- review later
- reject for now
- do not suggest in this context
- correct source fact

---

## Acceptance Criteria

A feature using these flows is mature when:

- states are explicit
- transitions are tested
- forbidden transitions are prevented
- receipts exist for meaningful changes
- sensitive states preserve privacy
- user correction routes exist where safe
- implementation docs state which state machine changed
