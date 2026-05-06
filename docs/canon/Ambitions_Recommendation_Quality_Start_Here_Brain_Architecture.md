# Ambitions Recommendation Quality Start Here Brain Architecture
<!-- markdownlint-disable MD013 -->

Status: HPS06 source truth / docs-domain architecture. No production Swift implementation.
Date: 2026-05-06
Train: HPS01-HPS12 Human Progress Systems Upgrade

## Purpose

Recommendation Quality and the Start Here Brain define how Ambitions should
choose, reject, explain, degrade, and evaluate candidate actions before any
future AOS or LDI runtime makes recommendations visible.

Start Here is not an AI suggestion card. It is the user's grounded daily
decision surface.

HPS06 is architecture only. It does not implement recommendation runtime,
candidate ranking, model logic, personalization, persistence, schema, sync,
cloud, AI runtime, UI, or evaluation automation.

## Product Boundary

Recommendations must remain:

- source-grounded
- privacy-aware
- time-fit aware
- proof-aware
- commitment-aware
- user-reviewable
- fallback-safe
- non-shaming
- explainable without model jargon

Recommendations must not become:

- confidence scores
- guaranteed outcomes
- hidden plan mutation
- engagement hooks
- professional advice
- career or education certainty
- health, legal, financial, or crisis guidance
- a conversational answer surface
- a sixth tab
- a many-suggestion command surface

## Candidate Families

| Candidate family | Purpose | Default posture |
|---|---|---|
| `DoNowCandidate` | A concrete step that can be started now. | Requires time fit and privacy review. |
| `RecoverCandidate` | A smaller safe recovery step after overload, block, stale plan, or missed context. | Non-shaming and user-controlled. |
| `ReviewSourceCandidate` | A source, requirement, freshness, or claim needs review before action. | Source-first. |
| `AddProofCandidate` | Proof can clarify progress, requirement support, or option value. | User-owned and private. |
| `ClarifyCaptureCandidate` | A capture/open loop needs placement, route, or meaning. | No hidden promotion. |
| `ProtectTimeCandidate` | Capacity, protected time, or commitment fit needs care. | Plan-owned and no silent calendar write. |
| `AskUserCandidate` | The safest next move is a question or confirmation. | No assumption promotion. |
| `NotNowCandidate` | A candidate should be delayed, parked, hidden, or cooled down. | Respectful and reversible. |

## Candidate Evidence Fields

Every recommendation candidate that may reach Start Here, Goals, Plan, Capture,
You, AOS, LDI, or an external surface must carry:

- `id`
- `candidateFamily`
- `title`
- `whyThis`
- `whyNow`
- `whyNotAlternatives`
- `sourceState`
- `freshnessState`
- `proofState`
- `commitmentContext`
- `timeFitState`
- `privacyClass`
- `riskState`
- `fallbackState`
- `reviewState`
- `receipts`

## Eligibility Gates

A candidate may be eligible only when:

- it has a concrete user-visible action or review question
- source/freshness state is adequate for its risk level
- proof needs are represented
- commitment impact is visible
- time/capacity fit is plausible
- privacy class permits the target surface
- user control is preserved
- fallback is safe if skipped
- it does not require professional/legal/human review first

## Rejection Gates

A candidate must be rejected or degraded when it:

- relies on unsupported source claims
- uses inferred memory as fact
- hides a mutation
- exposes sensitive content externally
- creates shame or pressure
- suggests professional advice
- implies guaranteed eligibility or outcome
- depends on stale critical requirements
- overloads the user's current capacity
- repeats after the user rejected or cooled it down
- lacks a safe fallback

## Explanation Contract

Every surfaced candidate must be able to answer:

- why this
- why now
- why not the alternatives
- what source supports it
- what proof or commitment it advances
- how it fits time and capacity
- what privacy constraints apply
- what happens if skipped
- what still counts if adapted

Explanations must avoid model jargon, hidden inference language, and fake
precision. Use evidence strength, source state, freshness state, and review
state instead.

## Recovery Behavior

Recovery recommendations must:

- reduce scope
- preserve dignity
- keep proof and option value visible
- avoid overdue/shame language
- offer review or pause when action is unsafe
- avoid silent rescheduling
- write or propose receipts only after user confirmation

## Regression Oracle

Future recommendation implementation must be tested against golden scenarios:

- overloaded day
- stale source
- private commitment
- inferred memory candidate
- rejected recommendation cooldown
- proof needed before action
- conflicting requirement
- minor or student-data sensitivity
- career/education uncertainty
- health/legal/financial/professional boundary
- crisis or safety boundary
- no available time
- recovery after disruption
- option value after pivot
- external-surface redaction

## API Contract Families

These are architecture contracts, not implemented Swift APIs in HPS06.

### Candidate Generation API

Purpose: produce possible candidates from goals, commitments, captures, proof,
requirements, memory, time, privacy, and source state.

Required output:

- candidate summaries
- source/proof/time/privacy evidence
- missing evidence notes
- candidate family
- initial risk state

### Candidate Rejection API

Purpose: reject unsafe, unsupported, stale, hidden-mutation, privacy-risky, or
overloading candidates before they reach Start Here.

Required output:

- rejected candidate id
- rejection reason
- safer fallback
- review owner
- receipt need if user-facing

### Recommendation Explanation API

Purpose: prepare user-facing explanation without model jargon or fake
certainty.

Required output:

- why this
- why now
- why not alternatives
- source/freshness/proof labels
- privacy label
- fallback
- correction/rejection control

### Recommendation Evaluation API

Purpose: run candidate behavior against regression scenarios before a batch can
claim recommendation quality.

Required output:

- scenario id
- expected safe behavior
- actual behavior
- privacy/source/proof result
- no-claim result
- repair owner

## Start Here Projection

Start Here may show only one primary recommendation object by default. Secondary
candidates must remain folded, delayed, or review-only so Today does not become
a many-suggestion surface.

External surfaces receive redacted summaries only and must not expose sensitive
recommendation details.

## No-Claim Boundary

This document does not implement recommendation runtime, AOS runtime, LDI
runtime, model behavior, personalization, persistence, schema, sync, cloud,
analytics, UI, external-surface recommendation behavior, professional advice,
legal/privacy compliance, App Store readiness, TestFlight readiness, release
readiness, physical-device behavior, or public accessibility conformance.
