# Ambitions 3.0 — AI Evaluation And Grounding Plan

Status: Active Ambitions 3.0 AI/personalization evaluation canon  
Parent doc: [Ambitions 3.0 Front-End Redesign Index](./Ambitions_3_0_Front_End_Redesign_Index.md)  
Related docs: [Recommendation Eligibility Engine](./Ambitions_3_0_Recommendation_Eligibility_Engine.md), [Evidence Hierarchy](./Ambitions_3_0_Evidence_Hierarchy.md)  
Last updated: 2026-04-30

---

## Purpose

This document defines how Ambitions evaluates intelligent recommendations without exposing AI theater to users.

Ambitions may become intelligent, but intelligence must stay grounded, explainable, correctable, and consent-based.

---

## Core Rule

Ambitions should not recommend what it cannot explain.

Ambitions should not learn what the user cannot inspect or correct.

---

## Allowed Inputs

Allowed with proper source labels and privacy handling:

- user-created goals
- user-created steps
- captures
- plans
- schedule and availability
- calendar-derived context when permission exists
- closure outcomes
- proof history
- user corrections
- planning defaults
- confirmed memory
- review outcomes

---

## Restricted Inputs

Require careful handling:

- sensitive Life Areas
- health-related details
- financial details
- relationship/family details
- location patterns
- calendar-derived private commitments
- inferred energy or motivation

---

## Forbidden Inferences

Ambitions must not infer:

- character flaws
- motivation level from non-completion
- mental health status
- sensitive life circumstances from one signal
- availability from open calendar space alone
- permanent preference from one action

---

## Evaluation Dimensions

Every recommendation should be evaluated internally against:

- eligibility
- context fit
- source fact quality
- readiness
- duration fit
- protected/away safety
- user correction history
- privacy safety
- explanation quality
- closure outcome

---

## Bad Recommendation Categories

- impossible now
- too large
- wrong context
- blocked
- waiting
- private detail exposed
- poor timing
- ignored prior correction
- no explanation
- violates protected time
- assumes open time is free time

---

## Feedback Signals

Allowed feedback signals:

- started
- opened but did not start
- adjusted
- made smaller
- rescheduled
- marked waiting
- marked blocked
- Still Counts
- rejected
- do not suggest in this context
- corrected source fact

Signals must be interpreted conservatively.

---

## Recommendation Quality Tests

Codex should add tests for:

- Start here eligibility
- disqualification
- not-chosen reasons
- protected/away time
- source labels
- duration source labels
- correction override
- sensitive memory block
- rejection cooling

---

## User-Facing Explanation Standard

A good explanation is short:

```text
Recommended because:
• You have 42 open minutes.
• This supports Release 3 songs.
• It does not require setup.
```

Do not show model confidence or model internals.

---

## Acceptance Criteria

AI/personalization is acceptable when:

- recommendations pass eligibility
- source facts are visible
- user can correct the recommendation
- sensitive data is protected
- memory use is inspectable
- bad recommendations can be categorized
- tests cover grounding and disqualification
