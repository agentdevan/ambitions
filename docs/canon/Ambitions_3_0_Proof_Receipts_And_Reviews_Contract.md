# Ambitions 3.0 — Proof, Receipts, And Reviews Contract

Status: Historical supporting canon; subordinate to `docs/truth/*`
Parent doc: [Ambitions 3.0 Front-End Redesign Index](./Ambitions_3_0_Front_End_Redesign_Index.md)  
Last updated: 2026-04-30

---

## Purpose

Proof, receipts, and reviews are related but not interchangeable.

This contract prevents Ambitions from turning progress evidence into gamification, receipts into disposable toast, or reviews into analytics dashboards.

---

## Core Distinction

```text
Receipt = what happened and what changed.
Proof = evidence that progress, learning, or reality-sync occurred.
Review = meaning extracted from receipts and proof to guide what happens next.
```

A receipt may create proof.

Proof may appear in a review.

A review may create a recommendation.

Do not merge these into one generic history object.

---

## Receipt Definition

A receipt is a trust object.

It explains:

- what happened
- what changed
- why it changed
- who or what changed it
- undo/correction availability
- source
- privacy state where relevant

Receipts appear as:

- toast
- peek
- trail
- search result
- export item where implemented

A toast is only the smallest receipt presentation. It is not the full receipt system.

---

## Proof Definition

Proof is evidence that movement happened.

Proof may include:

- completed step
- partial progress
- Still Counts
- artifact created
- decision made
- blocker resolved
- scope clarified
- plan recovered
- feedback received
- learning captured
- meaningful conversation

Proof is not limited to task completion.

---

## Review Definition

A review turns what happened into what should happen next.

Review types:

- What Counted Today
- Daily Receipt
- Weekly Life OS Receipt
- Goal Review
- Memory Review
- Recovery Review
- Pattern Review

Reviews should answer:

1. What happened?
2. What changed?
3. What counted?
4. What still holds?
5. What needs correction?
6. What carries forward?
7. What should happen next?

---

## Proof Privacy

Proof can be:

- standard
- private
- sensitive summary
- hidden from external surfaces
- excluded from widgets
- exportable
- excluded from export only when implemented and verified

Do not claim advanced privacy behavior before it is implemented and verified.

---

## Receipt Visibility Levels

| Level | Use |
|---|---|
| Toast | immediate confirmation |
| Peek | short drill-down after a toast/card |
| Trail | chronological object history |
| Search | full receipt history |
| Export | user-controlled data package |

Meaningful receipts must be recoverable later once the relevant trail/search surface exists.

---

## Proof Is Not Celebration

Proof should feel like evidence, not gamification.

Allowed language:

- Saved as proof
- Still Counts
- Progress saved
- What counted
- Proof attached

Avoid:

- streak-centered framing
- achievement framing
- perfect-day framing
- loud celebration copy
- pressure-based motivation

---

## What Counted Today

`What Counted Today` summarizes:

- completed
- Still Counts
- rescheduled
- waiting
- blocked
- proof saved
- plan changed
- no silent changes

It should not score the user.

---

## Goal Proof Rail

Goal Detail should include a Proof Rail that shows evidence of movement over time.

Proof Rail items may include:

- completed work
- artifacts
- decisions
- feedback
- risks resolved
- still-counts progress
- recovery moments
- plan adjustments

Proof Rail should not become a checklist.

---

## Review Output Rules

A review output should create one or more of:

- next recommended step
- recovery action
- plan adjustment
- memory suggestion
- correction prompt
- proof summary
- archive/update action

A review that only displays analytics without guiding action is off-canon.

---

## Trust Rules

- Proof and receipts respect sensitive Life Area behavior.
- Receipt undo availability must be truthful.
- Proof correction should be possible where safe.
- Deleting proof should explain history effects.
- Export claims must be evidence-backed.
- External surfaces must hide sensitive details by default.

---

## Acceptance Criteria

This contract is satisfied when:

- receipts, proof, and reviews stay distinct
- meaningful actions create receipts
- proof includes more than completion
- reviews turn history into next action or correction
- proof avoids gamification
- sensitive proof is hidden in compact/external surfaces
- receipt trails remain recoverable beyond toast presentation
