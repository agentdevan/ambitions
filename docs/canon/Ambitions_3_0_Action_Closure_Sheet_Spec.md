# Ambitions 3.0 — Action Closure Sheet Spec

Status: Historical supporting canon; subordinate to `docs/truth/*`
Parent doc: [Ambitions 3.0 Front-End Redesign Index](./Ambitions_3_0_Front_End_Redesign_Index.md)  
Last updated: 2026-04-30

---

## Product Purpose

Action Closure is how Ambitions handles reality.

A step is not simply done or failed. It needs a calm closure outcome that records what actually happened, what still counts, what changed, and what should happen next.

Action Closure supports the Golden Launch Loop step:

```text
Close / Recover
```

---

## Surface Ownership

Primary owner: Action Closure system  
Primary component concept: `ActionClosureSheet`  
Primary surfaces: Today Day Rail, Step Detail, Step Session, Goal Detail, Plan, Reviews  
Supporting surfaces: Trust Center, Receipts & History, Proof Rail

Action Closure is a shared grammar. It must not be recreated differently per surface.

---

## Canonical Closure Outcomes

| Outcome | User-facing label | Meaning | Creates proof? |
|---|---|---|---|
| completed | Completed | Finished as intended | Yes |
| stillCounts | Still Counts | Meaningful progress happened differently | Yes |
| rescheduled | Rescheduled | Still matters, moved to another time | Maybe |
| skippedNotNeeded | Not needed | Intentionally removed | No |
| blocked | Blocked | Cannot progress due to obstacle | Maybe |
| waiting | Waiting | Dependent on person, time, info, place, or tool | Maybe |
| needsRecovery | Needs recovery | Plan/day needs repair | Maybe |
| needsReview | Needs review | User is unsure | No |
| reviewLater | Review later | User defers closure decision | No |

---

## Closure Sheet Anatomy

The closure sheet should include:

- object title
- original plan/context
- calm prompt
- top 3–4 likely outcomes
- optional note
- privacy label if relevant
- receipt preview
- confirm action

Do not show all closure outcomes at once by default. Full outcome list belongs behind `More options`.

---

## Default Prompt Patterns

Normal:

```text
Close the loop
What happened with this step?
```

Stale prior step:

```text
One step needs a quick check.
```

Recovery:

```text
The day changed. Nothing is broken.
```

Still Counts:

```text
You made real progress even if the original step changed.
```

---

## Recommended Action Sets

### Normal step

- Completed
- Still Counts
- Rescheduled
- Not needed

### Stale prior step

- Still Counts
- Rescheduled
- Not needed
- Review later

### Blocker detected

- Blocked
- Waiting
- Make smaller
- Needs review

### Overloaded day

- Still Counts
- Rescheduled
- Needs recovery
- Review later

### Away / protected day

- Not needed
- Rescheduled
- Review later

---

## Closure Reason Taxonomy

Optional reasons:

- no time
- no energy
- wrong context
- blocked
- waiting
- no longer needed
- too large
- forgot
- reprioritized
- completed differently
- away/protected time
- missing tool
- missing place
- missing person

Reasons should not be required for fast closure unless the outcome needs them for trust or future planning.

---

## Closure-To-Learning Rule

Closure can inform future recommendations only when:

- the pattern repeats
- the learning is low-risk or user-confirmed
- the memory is visible and correctable
- sensitive categories follow confirmation rules

Do not silently create sensitive/high-impact memory from a single closure.

---

## Receipts

Every meaningful closure creates a receipt.

Receipt examples:

```text
Completed · Draft PM notes
Still Counts · Saved as proof
Rescheduled · Friday
Waiting · Alex reply
Needs recovery · Plan review suggested
```

Receipts should indicate whether undo or correction is available.

---

## Proof Creation

Closure can create proof when the outcome records real movement.

Proof can be created from:

- Completed
- Still Counts
- blocker resolved
- decision made
- plan recovered
- artifact created
- meaningful partial progress

Not every closure creates proof.

---

## Non-Goals

Do not use Action Closure to:

- shame the user
- create failure states
- create streak pressure
- mark old work as failed automatically
- auto-complete based on elapsed time
- silently change plans without receipt
- replace Step Session

---

## Accessibility Requirements

- Sheet title must identify the object being closed.
- Outcome buttons must be 44x44 pt minimum.
- Outcome labels must be clear without color.
- VoiceOver should read outcome meaning where helpful.
- Dynamic Type must not hide the primary outcomes.
- Reduce Motion must not remove closure clarity.

---

## Acceptance Criteria

Action Closure is acceptable when:

- shared outcome grammar is used across surfaces
- stale steps become closure prompts, not task debt
- Still Counts is available where relevant
- closure creates receipts
- proof is created only when meaningful
- user can undo or correct where safe
- closure language avoids failure/shame framing
- closure can inform planning only through trust-safe learning rules
