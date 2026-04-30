# Ambitions 3.0 — Recommendation Contract

Status: Active Ambitions 3.0 recommendation and personalization canon contract  
Parent doc: [Ambitions 3.0 Front-End Redesign Index](./Ambitions_3_0_Front_End_Redesign_Index.md)  
Last updated: 2026-04-30

---

## Purpose

Ambitions recommendations must feel grounded, explainable, correctable, and calm.

This contract applies anywhere Ambitions suggests a step, place, duration, plan window, recovery action, proof attachment, memory, automation setting, or review.

---

## Recommendation Anatomy

Every meaningful recommendation must include:

1. Recommended object
2. Recommendation type
3. Source facts
4. Assumptions
5. Excluded alternatives when useful
6. Qualitative fit only
7. User control
8. Correction route
9. Receipt if accepted and meaningful
10. Memory impact, if any

---

## Recommendation Types

- Recommended step
- Suggested place
- Suggested duration
- Suggested plan window
- Suggested recovery action
- Suggested proof attachment
- Suggested memory
- Suggested automation setting
- Suggested review
- Suggested smaller version of a step
- Suggested waiting/blocker state

---

## Source Facts

Allowed source fact categories:

- user-entered goal
- user-entered plan
- capture text
- schedule or availability
- calendar-derived context when permission exists
- protected block
- deadline
- readiness
- dependency
- location/tool requirement
- prior closure pattern
- proof history
- recent correction
- planning default
- automation setting

---

## Forbidden Recommendation Behavior

Ambitions must not:

- say `AI recommends` in normal UI
- expose model confidence in normal UI
- imply a perfect or optimal answer
- fill open time just because it exists
- recommend steps blocked by readiness or dependencies unless resolving the blocker is the step
- create sensitive memory from a single ambiguous signal
- change meaningful plans silently
- hide assumptions
- make recommendations feel like commands

---

## User-Facing Language

Use:

- Recommended because
- Based on
- Why this?
- Not chosen
- You can change this
- Looks like this fits
- Suggested
- Needs your decision

Avoid:

- AI confidence
- model reasoning
- optimization score
- algorithm decided
- productivity score
- best possible step

---

## Recommended Step Eligibility

A step can become `Start here` only if:

1. It is ready or reviewable.
2. It has no unresolved blocker unless the recommended action is to resolve the blocker.
3. Its duration is user-set, accepted, suggested, historical, actual, or unset.
4. It fits the current or next available context.
5. It has a source label.
6. It can explain why it is recommended.
7. It has a user control path: start, open, adjust, make smaller, or review later.

---

## Recommended Step Disqualification

A step must not become `Start here` if:

- it is waiting on another person
- it requires a location or tool the user does not have
- it violates protected time
- it assumes vacation is free time
- it needs more time than the available window unless the action is `Make smaller`
- its only justification is generic priority
- Ambitions cannot explain why it appears

---

## Explanation Sheet Requirements

A `Why this?` sheet should show:

- recommendation title
- recommended because
- source facts
- assumptions where useful
- not chosen alternatives where useful
- correction action
- trust note if automation or memory influenced it

Preferred structure:

```text
Why this step?

Recommended because:
- You have a 42-minute open window.
- This is estimated at 25 minutes.
- It moves Career Growth forward.

Not chosen:
- Music session — better later tonight.
- Budget review — needs more time.

You can change this.
```

---

## Feedback And Correction

Every meaningful recommendation should allow one of:

- accept
- change
- not now
- make smaller
- review later
- do not suggest this again in this context
- explain more

Feedback may inform future recommendations only when it follows Trust / Privacy / Memory rules.

---

## Recommendation Ledger

A recommendation ledger should eventually record:

- candidates considered
- chosen recommendation
- source facts used
- assumptions
- excluded alternatives
- user response
- closure outcome
- proof created
- correction given
- future memory impact

This ledger is a trust object, not a user-facing AI console.

---

## Acceptance Criteria

A recommendation feature is acceptable when:

- it is explainable in plain language
- it uses qualitative fit, not numeric confidence
- it identifies source facts
- it exposes user control
- it avoids silent meaningful changes
- it creates receipts when accepted changes matter
- it does not create hidden sensitive memory
- it degrades safely when evidence is missing
