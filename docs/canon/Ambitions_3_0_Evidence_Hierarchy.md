# Ambitions 3.0 — Evidence Hierarchy

Status: Historical supporting canon; subordinate to `docs/truth/*`
Parent doc: [Ambitions 3.0 Front-End Redesign Index](./Ambitions_3_0_Front_End_Redesign_Index.md)  
Last updated: 2026-04-30

---

## Purpose

This document defines how evidence becomes proof, patterns, reviews, memories, and recommendations.

It prevents weak or ambiguous signals from becoming hidden personalization.

---

## Hierarchy

```text
Receipt → Proof → Pattern → Review → Memory → Recommendation
```

Each layer requires stronger evidence or stronger user control than the layer before it.

---

## Receipt

A receipt records what happened and what changed.

Receipt examples:

- Saved as Step
- Placed in Goal
- Rescheduled
- Still Counts
- Memory updated
- Plan adjusted

Receipt is the lowest durable trust object.

---

## Proof

Proof is evidence that progress, learning, or reality-sync occurred.

Proof may come from:

- Completed
- Still Counts
- artifact
- decision
- blocker resolved
- plan recovered
- meaningful partial progress

Proof is not gamification.

---

## Pattern

A pattern is repeated evidence across receipts, proof, closures, corrections, or planning behavior.

A single event is not a pattern.

Patterns may be used to suggest memory or planning defaults, not silently create them.

---

## Review

A review interprets receipts, proof, and patterns.

Review outputs may include:

- next step
- plan adjustment
- memory suggestion
- proof summary
- correction prompt
- recovery suggestion

Reviews must create a useful next action or insight.

---

## Memory

Memory is a user-inspectable personalization input that may shape recommendations.

Memory may be created from:

- explicit user entry
- user-confirmed pattern
- user correction
- planning default
- repeated low-risk behavior accepted by the user

Sensitive or high-impact memory requires explicit approval.

---

## Recommendation

Recommendations are outputs based on source facts, current context, eligibility, and user control.

A recommendation must be explainable without showing model confidence.

---

## Evidence Strength Rules

| Evidence | May create receipt | May create proof | May create pattern | May create memory | May recommend |
|---|---|---|---|---|---|
| Single capture | Yes | Maybe | No | No | Maybe with caution |
| Single closure | Yes | Maybe | No | No | Maybe locally |
| Repeated closures | Yes | Yes | Yes | Suggest only | Yes |
| User correction | Yes | Maybe | Yes | Strong candidate | Yes |
| Explicit user preference | Yes | No | Yes | Yes | Yes |
| Sensitive signal | Yes | Maybe | Maybe | Explicit approval only | Privacy-safe only |

---

## Weak Evidence Guardrails

Ambitions must not:

- create memory from one ambiguous behavior
- create sensitive memory without explicit approval
- turn one missed step into a user trait
- treat rejected recommendations as failure
- infer motivation from lack of completion
- treat open calendar space as availability without classification

---

## Acceptance Criteria

Evidence hierarchy is respected when:

- every recommendation can cite source facts
- memory can show source and freshness
- reviews distinguish facts from interpretations
- proof is not treated as score
- sensitive evidence remains privacy-safe
- user corrections override inferred patterns
