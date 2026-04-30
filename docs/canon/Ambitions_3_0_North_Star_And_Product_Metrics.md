# Ambitions 3.0 — North Star And Product Metrics

Status: Active Ambitions 3.0 product metrics canon  
Parent doc: [Ambitions 3.0 Front-End Redesign Index](./Ambitions_3_0_Front_End_Redesign_Index.md)  
Strategy brief: [Ambitions 3.0 Product Strategy Brief](./Ambitions_3_0_Product_Strategy_Brief.md)  
Last updated: 2026-04-30

---

## Purpose

This document defines internal product metrics for Ambitions 3.0.

These metrics are for product quality, not user-facing scores.

---

## North Star

Ambitions succeeds when users repeatedly turn real intent into believable action and saved proof.

North Star candidate:

```text
Weekly Proof-Producing Closure
```

Meaning:

A user captures, places, starts or resolves a meaningful step, closes the loop, and saves proof at least once in a week.

---

## Supporting Metrics

### Activation

- first useful object completion
- first capture created
- first placement confirmed
- first receipt seen
- first recommended step opened

### Core Loop

- capture-to-place completion
- recommended step shown
- recommended step opened
- recommended step started
- step closed
- proof saved
- receipt peek opened

### Recovery

- closure prompt completed
- Still Counts selected
- rescheduled without stale carryover
- recovery contract started
- low-energy day used
- make smaller selected

### Planning

- Day Shape opened
- Week Shape opened
- Life Shape opened
- decision resolved
- reflow previewed
- reflow approved
- protected/away time set

### Trust

- Why this opened
- not-chosen reason opened
- memory candidate reviewed
- memory corrected
- memory paused/deleted
- automation level changed
- trust receipt opened

### Retention

- week 1 return
- weekly proof-producing closure
- review-to-plan bridge used
- returning capture-to-place completion

---

## Guardrails

Do not optimize for:

- number of tasks completed
- time spent in app
- streak length
- total notifications sent
- number of steps scheduled
- productivity score
- artificial engagement loops

---

## Quality Signals

Ambitions should improve:

- clarity of next step
- trust in recommendations
- ability to recover from broken plans
- proof saved from real progress
- reduction in stale unresolved work
- user correction success

---

## Metric Privacy Rules

Metrics must not include raw sensitive text.

Events should use object type, surface, source labels, privacy level, and outcome where needed.

Sensitive/private projection must be respected.

---

## Acceptance Criteria

Metrics are mature when:

- they map to the Golden Launch Loop
- they do not become user-facing scores
- they avoid raw private content
- they measure trust and recovery, not only completion
- they can guide product quality without creating shame loops
