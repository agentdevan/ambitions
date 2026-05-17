# Ambitions 3.0 — Recommendation Eligibility Engine

Status: Historical supporting canon; subordinate to `docs/truth/*`
Parent doc: [Ambitions 3.0 Front-End Redesign Index](./Ambitions_3_0_Front_End_Redesign_Index.md)  
Related doc: [Ambitions 3.0 Recommendation Contract](./Ambitions_3_0_Recommendation_Contract.md)  
Last updated: 2026-04-30

---

## Purpose

This document defines when Ambitions may recommend, surface, or withhold work.

It prevents fake intelligence, unsafe automation, and recommendations that do not fit real life.

---

## Core Rule

Ambitions may recommend only what it can explain, ground, and allow the user to change.

---

## Candidate Inputs

Allowed candidate sources:

- user-created step
- goal next visible step
- plan item
- capture placed as step
- recovery action
- waiting/blocker resolution
- review carry-forward
- decision needing action
- proof follow-up

---

## Eligibility Requirements For Start Here

A step can become `Start here` only if:

1. It is ready or reviewable.
2. It has no unresolved blocker unless resolving the blocker is the step.
3. It fits current or next available context.
4. It has a source label.
5. It has a duration source or intentionally unset duration.
6. It can explain why it appears.
7. It has user control: Start now, Open step, Adjust plan, Make smaller, or Review later.
8. It does not violate protected/away time.
9. It does not require unavailable tools, places, or people.
10. It does not depend on hidden sensitive memory.

---

## Disqualification Rules

A step must not become `Start here` if:

- it is waiting on another person
- it requires a blocked dependency
- it violates protected time
- it assumes vacation/away time is free time
- it needs more time than the available window unless the recommended action is `Make smaller`
- its only justification is priority
- Ambitions cannot explain why it appears
- it uses sensitive memory without confirmed permission
- user recently rejected the same recommendation in the same context

---

## Surface Buckets

Eligible work may be projected as:

- Start here
- Now
- Next
- Later
- Needs review
- Waiting
- Blocked
- Not chosen
- Hidden/private item

---

## Not Chosen Reasons

When useful, Ambitions may explain why something was not chosen:

- needs more time
- better later
- waiting on dependency
- blocked
- protected time
- lower fit for current context
- too large for current window
- sensitive/private detail hidden
- recently rejected

---

## Source Labels

Every recommendation should show one source label:

- User-set
- Suggested
- Calendar-derived
- Based on closure
- Based on planning default
- Based on goal path
- Based on review
- Based on correction

No source label means not eligible for flagship recommendation UI.

---

## Duration Source Labels

Allowed duration source labels:

- User-set
- Suggested
- Accepted
- Historical
- Actual
- Unset

Ambitions must not pretend duration precision it does not have.

---

## Recommendation Cooling

If the user dismisses or rejects a recommendation repeatedly, Ambitions should reduce resurfacing in that context.

User correction overrides inferred patterns.

---

## Sensitive Recommendations

If a recommendation involves private/sensitive details:

- compact surfaces show privacy-safe labels
- external surfaces hide details
- memory source must be confirmed when required
- explanation should preserve privacy

---

## Acceptance Criteria

A recommendation system is acceptable when:

- every recommended step passes eligibility
- disqualified items are safely bucketed
- Not chosen explanations are available where useful
- source labels exist
- user controls exist
- rejection/correction affects future suggestions
- protected and away time are respected
- sensitive details are not exposed
