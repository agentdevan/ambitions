# Ambitions 3.0 — Universal Object Lifecycle Contract

Status: Historical supporting canon; subordinate to `docs/truth/*`
Parent doc: [Ambitions 3.0 Front-End Redesign Index](./Ambitions_3_0_Front_End_Redesign_Index.md)  
Last updated: 2026-04-30

---

## Purpose

This contract defines how every meaningful object enters Ambitions, receives a home, appears at the right time, closes cleanly, and becomes proof.

It protects the Golden Launch Loop:

```text
Capture → Place → Plan → Do Today → Close / Recover → Save Proof
```

This is a cross-surface contract. It does not replace the Domain Model, Trust / Privacy / Memory canon, or Acceptance Gates. It governs how those existing objects participate in the Ambitions 3.0 front-end loop.

---

## Lifecycle

```text
Captured → Placed → Planned → Surfaced → Started → Closed → Proven
```

Every meaningful object should either progress through this lifecycle or intentionally stop with a safe, visible state.

---

## Lifecycle State Matrix

| Lifecycle state | Meaning | Primary owner | Required user visibility | Receipt required |
|---|---|---|---|---|
| Captured | Raw input entered Ambitions | Capture | Saved state + destination preview | Yes |
| Placed | Object has a home | Placement Resolver | Destination + Change route | Yes |
| Planned | Object has a time/context plan | Plan | Source, duration, rigidity, fit | Yes if meaningful |
| Surfaced | Object appears for action | Today / Day Rail | Why this, why now, source facts | Not always |
| Started | User begins action | Step Session | Current step, context, duration source | Optional |
| Closed | Reality outcome recorded | Action Closure | Outcome + correction route | Yes |
| Proven | Progress evidence saved | Proof / Goal Detail / Reviews | What counted + destination | Yes |

---

## Hard Rule

No meaningful object may enter Ambitions without at least one of:

- a clear destination
- a safe temporary destination
- a user-visible unresolved state
- a failed-safe message that preserves the input

Capture must never discard user intent.

---

## Object Eligibility

This lifecycle applies to:

- Capture
- Task / One-Step Goal
- Step
- Goal
- Path
- Milestone
- Plan item
- Waiting item
- Decision
- Action Closure
- Receipt
- Proof
- Memory when it affects recommendations
- Review when it creates future action

---

## Lifecycle Ownership Rules

### Capture owns Captured

Capture records raw intent and suggests a place without forcing the user to decide perfectly.

### Placement Resolver owns Placed

Placement decides the object home and must show where the object will appear before or immediately after confirmation.

### Plan owns Planned

Plan determines whether time, context, energy, readiness, and rigidity make the object believable.

### Today owns Surfaced

Today, through `AmbitionsDayRailView`, surfaces the believable path through the day.

### Step Session owns Started

Step Session is step-first, not timer-first, and opens only from `Start now` / `Open step` flows.

### Action Closure owns Closed

Action Closure records what actually happened without using shame, failure, or stale-task language.

### Proof / Receipts own Proven

Proof records evidence of movement. Receipts explain what happened, what changed, why, and whether the user can undo or correct it.

---

## Allowed Stops

An object may intentionally stop at:

- `Needs a Place`
- `Needs Review`
- `Waiting`
- `Blocked`
- `Not Needed`
- `Archived`
- `Parked`
- `No Longer Relevant`

A stopped object still needs a visible state and correction path where safe.

---

## Required Metadata

Every lifecycle-aware object should carry or project:

- origin
- current home
- current state
- source label
- privacy level
- latest receipt id where relevant
- correction route where safe
- proof relationship where applicable

Recommended planning metadata:

- duration source
- readiness
- rigidity
- context requirements
- availability fit
- cognitive fit
- dependency state

---

## Trust Rules

- Meaningful state changes create receipts.
- Reversible local changes prefer receipt + undo.
- Sensitive/high-impact memory creation follows Trust / Privacy / Memory confirmation rules.
- Calendar writes, destructive actions, delete memory, delete all memory, and major deadline changes require confirmation.
- Ambitions does not silently change meaningful plans.

---

## User-Facing Translation

Do not expose lifecycle jargon in normal UI.

| Internal lifecycle | Preferred user-facing copy |
|---|---|
| Captured | Saved |
| Placed | Saved as / Attached as / Placed in |
| Planned | Added to plan / Fits today / Needs review |
| Surfaced | Start here / Recommended step |
| Started | In progress |
| Closed | Completed / Still Counts / Rescheduled / Waiting / Not needed |
| Proven | Saved as proof / What counted |

---

## Acceptance Criteria

This contract is satisfied when:

- every major surface can say where an object came from, where it belongs, and what happens next
- no capture dead-ends
- every meaningful placement has a correction route
- Today surfaces only believable or reviewable work
- closure outcomes are non-shaming
- proof is distinct from completion
- receipts are distinct from disposable toasts
- sensitive objects are privacy-safe in compact and external surfaces
- implementation summaries distinguish planned canon from shipped code
