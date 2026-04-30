# Ambitions 3.0 — Personalization Consent Model

Status: Active Ambitions 3.0 trust/personalization canon  
Parent doc: [Ambitions 3.0 Front-End Redesign Index](./Ambitions_3_0_Front_End_Redesign_Index.md)  
Related docs: [Evidence Hierarchy](./Ambitions_3_0_Evidence_Hierarchy.md), [Trust / Privacy / Memory](./TRUST_PRIVACY_MEMORY.md)  
Last updated: 2026-04-30

---

## Purpose

This document defines how Ambitions may learn from behavior, corrections, and preferences.

Personalization must feel earned, visible, and reversible.

---

## Core Rule

Ambitions may suggest personalization before it applies personalization.

High-impact, sensitive, or ambiguous learning requires explicit user approval.

---

## Consent Ladder

| Signal | Default behavior |
|---|---|
| Observed once | Never create memory. May create receipt. |
| Repeated low-risk pattern | Suggest memory. |
| Sensitive pattern | Ask explicitly before memory or recommendation use. |
| User correction | Strongest signal; may suggest memory. |
| User-entered preference | May become memory with receipt. |
| User deletion | Hard stop for that memory. |
| User pause | Do not use until resumed. |

---

## Memory Statuses

- Candidate
- Confirmed
- Active
- Paused
- Corrected
- Deleted
- Expired
- Needs Review

---

## Memory Card Requirements

Each memory card must show:

- memory summary
- source
- freshness
- what it affects
- privacy level
- correction action
- pause action where safe
- delete action where safe

---

## Sensitive Memory

Sensitive memory includes:

- health
- finances
- relationship/family details
- location patterns
- protected time
- private goals
- sensitive Life Areas
- calendar-derived private commitments

Sensitive memory requires explicit approval before shaping recommendations.

---

## Correction Priority

User correction outranks inferred patterns.

If a user corrects Ambitions repeatedly, the system should suggest a preference instead of continuing to guess.

---

## Deletion Rule

Deleting a memory means Ambitions must stop using that memory for recommendations.

Receipts may preserve that deletion happened, but should not preserve sensitive detail unless privacy rules allow it.

---

## Trust Simulation

Before enabling stronger automation or memory learning, Ambitions may show:

```text
Here is what Ambitions would have changed this week.
Approve this level?
```

Trust Simulation should be a preview, not a silent change.

---

## User-Facing Copy

Use:

- Remember this?
- Use this for recommendations?
- Change this
- Pause this
- Forget this
- This shapes recommendations
- Based on your correction

Avoid:

- AI learned
- behavior profile
- prediction model
- hidden memory
- confidence

---

## Acceptance Criteria

The consent model is mature when:

- memory creation is visible
- sensitive memory requires approval
- corrections outrank inferred patterns
- deletion and pause behavior are respected
- recommendations can show memory source
- trust receipts are created for meaningful memory changes
- user-facing copy stays plain and non-creepy
