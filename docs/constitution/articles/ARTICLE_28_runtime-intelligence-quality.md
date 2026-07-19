# Article 28 — Runtime intelligence quality

## INTELLIGENCE-001 — Decision trace

Every meaningful recommendation or automatic minor change records:

- policy ID and version,
- eligible inputs,
- explicit user rules applied,
- excluded or unavailable inputs,
- result,
- materiality,
- rationale,
- correction path,
- receipt linkage.

Internal confidence may be recorded for testing and diagnostics but is not primary UI.

## INTELLIGENCE-002 — Insufficient context

When context is insufficient, Ambitions does not fabricate certainty. It may offer neutral actions, ask one necessary question, expose alternatives, or remain quiet.

## INTELLIGENCE-003 — Rule precedence

Default precedence:

1. Protected and Fixed constraints,
2. explicit per-object rule,
3. explicit per-Goal rule,
4. explicit global user rule,
5. explicit correction,
6. learned pattern,
7. system default.

A lower-precedence signal may not silently override a higher-precedence rule.

## INTELLIGENCE-004 — Learning lifecycle

Every learned factor defines:

- permitted source signals,
- minimum evidence,
- decay or staleness,
- inspection,
- correction,
- reset/deletion,
- export classification,
- CloudKit eligibility,
- sensitive-factor prohibition,
- regression tests.

## INTELLIGENCE-005 — Sensitive inference prohibition

The runtime may not infer or store sensitive traits unrelated to the user’s explicit product intent. Health, identity, relationship, financial, or other sensitive conclusions require explicit product scope and privacy review.

## INTELLIGENCE-006 — Quality corpus

Planning quality is tested across sparse and dense schedules, travel, time-zone change, caregiving interruptions, low capacity, deadline pressure, conflicting Goals, recurrence, repeated deferral, new-user cold start, explicit corrections, and insufficient context.

## INTELLIGENCE-007 — No silent quality regression

A policy change that reduces constraint preservation, correction compliance, explanation quality, or scenario success requires explicit review and cannot be hidden by aggregate pass counts.

---
