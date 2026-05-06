# Ambitions AI Governance Evaluation Assurance Lab Architecture
<!-- markdownlint-disable MD013 -->

Status: HPS10 source truth / docs-evaluation governance architecture. No production Swift implementation.
Date: 2026-05-06
Train: HPS01-HPS12 Human Progress Systems Upgrade

## Purpose

The AI Governance and Evaluation Assurance Lab defines how Ambitions should
prove future AOS, LDI, recommendation, source, proof, memory, privacy, and
external-surface behavior before any intelligence behavior is treated as safe.

The lab exists so intelligence cannot remain vibe-based. Every high-risk
behavior must have fixtures, expected safe outcomes, failure classifications,
repair owners, claim-truth boundaries, and evidence receipts.

HPS10 is architecture only. It does not implement test fixtures, runtime
evaluation, model evaluation, CI gates, telemetry, analytics, source packs,
AOS runtime, LDI runtime, UI, external-surface behavior, or release behavior.

## Product Boundary

The assurance lab must remain:

- evidence-bound
- privacy-safe
- source-aware
- professional-boundary aware
- regression-oriented
- repair-owner explicit
- local/user-data minimizing
- no-claim by default
- useful to Codex and human reviewers

It must not become:

- production telemetry
- user-data analytics
- model benchmarking theater
- release approval
- legal/privacy signoff
- public safety certification
- hidden product scoring
- acquisition certainty
- a sixth tab
- a broad monitoring surface

## Assurance Object Families

| Object family | Purpose | Default posture |
|---|---|---|
| `GoldenScenario` | A canonical user/life/source/privacy situation with expected safe behavior. | Fixture-backed before claim. |
| `RedTeamScenario` | A high-risk or adversarial case that must fail safely. | Blocks unsafe claim. |
| `RegressionOracle` | Expected behavior for recommendations, memory, source, proof, LDI, or AOS. | Deterministic and reviewable. |
| `ClaimTruthTest` | A test or review that prevents unsupported copy or readiness claims. | No-claim by default. |
| `RiskRegisterEntry` | A named intelligence, safety, privacy, source, or claim risk. | Owner required. |
| `AssuranceLedgerEntry` | Evidence that a scenario, scan, review, or repair ran. | Scope-labeled. |
| `RepairOwner` | Named future batch, train, or human owner for a gap. | Required for Yellow. |
| `FixtureFamily` | A reusable group of scenario inputs and expected outcomes. | Privacy-safe. |

## Required Assurance Fields

Every assurance item must carry:

- `id`
- `family`
- `riskClass`
- `surfaceOwner`
- `kernelOwner`
- `scenarioSummary`
- `inputBoundary`
- `expectedSafeBehavior`
- `forbiddenBehavior`
- `sourceState`
- `privacyState`
- `professionalBoundaryState`
- `claimBoundaryState`
- `validationStatus`
- `repairOwner`
- `evidenceLinks`
- `lastReviewedAt`
- `receipts`

## Minimum Golden Scenarios

The AOS golden scenario set must include:

- ADHD overload
- new baby / family pressure
- forgotten promise
- relationship commitment
- work deadline
- stale source
- source conflict
- private goal
- career false-certainty
- education eligibility ambiguity
- minor/student-data risk
- professional-boundary risk
- unsafe dream
- crisis-coded input
- memory hallucination
- open-loop recovery
- path pivot
- proof revocation
- no-claim release copy
- external-surface redaction

## LDI Red-Team Expansion

The LDI red-team set must inherit the 45 fixture families from
`docs/canon/AmbitionsOS_LDI_Evaluation_And_Governance.md` and add explicit
expected outcomes for:

- unsafe operationalization blocked
- crisis support posture
- professional-boundary scaffold
- source check first
- source stale review
- source conflict review
- impossible timeline review
- North Star extraction
- privacy-sensitive handling
- unsupported domain exploration
- user assumption rejection
- pack withdrawn or downgraded
- jurisdiction change
- capacity collapse

## Recommendation Regression Oracle

Recommendation tests must prove:

- why-this, why-now, and why-not-alternatives exist
- source/freshness/proof/privacy labels are present
- fake certainty is absent
- rejected recommendations cool down
- private content stays private
- source-needed candidates degrade to review
- no hidden plan mutation occurs
- external surfaces receive redacted summaries only
- no professional advice is implied

## Privacy Leak Scenarios

Privacy leak tests must include:

- private commitment in widget
- sensitive proof in logs
- minor/student context in external projection
- private attachment in export without review
- inferred memory shown as fact
- local-only goal projected externally
- notification reveals sensitive source
- preview fixture implies real private data

## Source And Professional-Boundary Scenarios

Source/professional scenarios must include:

- stale official source
- conflicting sources
- unsupported source claim
- copied source without freshness
- career requirement uncertainty
- education eligibility ambiguity
- legal/medical/financial boundary
- professional review required
- jurisdiction changed
- source superseded

## Claim Truth Tests

Claim truth tests must block unsupported claims about:

- App Store readiness
- TestFlight readiness
- release readiness
- legal/privacy signoff
- physical-device proof
- public accessibility conformance
- security certification
- official requirement verification
- professional advice
- production AI behavior
- hosted AI
- user-data server
- sync readiness
- acquisition outcome

## AI Risk Register

The AI risk register must track:

- hallucinated memory
- unsupported source claim
- stale source used as current
- hidden mutation
- unsafe dream operationalization
- professional-boundary overreach
- private content leak
- model-required core path
- no deterministic fallback
- battery/performance overrun
- user rejection ignored
- external-surface overexposure
- release/readiness overclaim

Every risk needs owner, mitigation, evidence requirement, next review trigger,
and allowed Yellow posture.

## Continuous Assurance Ledger

The assurance ledger records:

- command or review name
- timestamp
- scope
- scenario family
- pass/fail/Yellow status
- evidence link
- what was not proven
- repair owner
- next review trigger

The ledger must not store user personal data.

## API Contract Families

These are architecture contracts, not implemented Swift APIs in HPS10.

### Scenario Registry API

Purpose: list scenario families and required expected outcomes.

Required output:

- scenario ids
- owners
- risk classes
- expected safe behavior
- forbidden behavior
- evidence requirements

### Regression Oracle API

Purpose: define deterministic expected behavior for a kernel or surface.

Required output:

- oracle id
- input boundary
- expected output
- forbidden output
- claim boundary
- repair owner

### Risk Register API

Purpose: track risks and owners.

Required output:

- risk id
- risk class
- owner
- mitigation
- evidence requirement
- review trigger
- Yellow/Red posture

### Assurance Ledger API

Purpose: record validation evidence without user personal data.

Required output:

- ledger entry id
- validation command or review
- scope
- result
- evidence link
- unproven claims
- next action

### Claim Truth API

Purpose: reject unsupported launch, platform, safety, professional, or
intelligence claims.

Required output:

- claim text or claim family
- required evidence
- current evidence
- allowed wording
- blocked wording
- owner

## Regression Oracle

Future AOS/LDI/evaluation implementation must prove:

- every scenario has expected safe behavior
- every high-risk fixture has a repair owner
- every unsafe or professional-boundary case fails safely
- privacy-sensitive fixtures do not leak externally
- source-stale and source-conflict states block confident action
- unsupported release/platform claims are blocked
- model-optional paths retain deterministic fallback
- assurance records name what was not proven

## No-Claim Boundary

This document does not implement fixture runtime, tests, CI gates, model
evaluation, analytics, telemetry, AOS runtime, LDI runtime, source packs,
recommendation behavior, UI, external projection behavior, professional advice,
legal/privacy signoff, App Store readiness, TestFlight readiness, release
readiness, physical-device behavior, public accessibility conformance,
security certification, or acquisition outcome.
