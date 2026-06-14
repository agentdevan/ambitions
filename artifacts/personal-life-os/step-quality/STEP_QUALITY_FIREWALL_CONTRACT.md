# Step Quality Firewall Contract

Status: Active PLOS M09 downstream contract
Issue: AMB-711 / PLOS-090
Parent: AMB-627 / PLOS-M09
Scope: Contract, machine-readable model, fixture harness, and local validator for Step acceptance and rejection
Runtime implementation proof: none

## Purpose

The Step Quality Firewall blocks a Step candidate before it reaches a user-facing recommendation, schedule install, elastic variant, repair path, or Golden Slice proof when the candidate is generic, context-mismatched, source-weak, proof-weak, inaccessible, unsafe, or uninspectable.

This contract is a downstream blocking contract for M09 children and for AMB-617 / PLOS-M10. It defines the `StepQualityInput` and `StepQualityVerdict` shapes, required check families, fixture expectations, and runnable local validation surface. It does not wire the production Swift runtime or prove app behavior.

## Downstream Consumers

| Consumer | Required use |
|---|---|
| AMB-712 / PLOS-091 | Extend the generic Step blocked-list scanner without weakening this contract. Scanner authority: `artifacts/personal-life-os/step-quality/STEP_GENERIC_BLOCKED_LIST_SCANNER.md`. |
| AMB-713 / PLOS-092 | Fill in context-fit validation over time, energy, resources, location, deadline, and dependency fit. Validator authority: `artifacts/personal-life-os/step-quality/STEP_CONTEXT_FIT_VALIDATOR.md`. |
| AMB-714 / PLOS-093 | Fill in source/proof validation over authority state, trace, proof primitive, runtime eligibility, and stale/revoked blocks. Validator authority: `artifacts/personal-life-os/step-quality/STEP_SOURCE_PROOF_VALIDATOR.md`. |
| AMB-715 / PLOS-094 | Fill in accessibility and VoiceOver validation. |
| AMB-716 / PLOS-095 | Fill in elasticity coverage validation over shrink, extend, replace, proof-only, recovery-safe, split, and merge coverage. |
| AMB-717 / PLOS-096 | Fill in compiler repair path and safe fallback routing. |
| AMB-617 / PLOS-M10 | Use the validator as the minimum M10 dependency gate until production runtime integration exists. |

## StepQualityInput

`StepQualityInput` is the canonical input envelope for a candidate Step at the firewall boundary.

Required fields:

- `id`: stable candidate identifier.
- `stepText`: candidate Step copy.
- `actionVerb`: concrete user action verb.
- `object`: concrete object or target of the action.
- `durationMinutes`: positive bounded duration.
- `capabilityTarget`: declared capability intent and user skill state.
- `contextFit`: time, energy, resource, location, deadline, and dependency fit.
- `sourceAuthority`: source state, trace, freshness, review, risk, and runtime eligibility.
- `proofExpectation`: proof primitive, receipt requirement, and proof trace.
- `accessibility`: VoiceOver label, value, hint, and non-visual equivalence.
- `elasticityCoverage`: minimum viable, standard, extended, proof-only, recovery-safe, replacement, split, and merge coverage flags.
- `repairPath`: compiler repair owner, safe fallback, and rejection annotation target.

The machine-readable definition is `artifacts/personal-life-os/step-quality/STEP_QUALITY_FIREWALL_CONTRACT.json`.

## StepQualityVerdict

`StepQualityVerdict` is the canonical output envelope.

Required fields:

- `candidateId`: matching `StepQualityInput.id`.
- `decision`: `accept`, `reject`, or `degrade`.
- `status`: `green`, `yellow`, or `red`.
- `blockingCodes`: deterministic rule codes that block acceptance.
- `repairPath`: repair owner and safe fallback when blocked.
- `proofBoundary`: explicit no-claim boundary.
- `downstreamConsumers`: issue or phase consumers affected by the verdict.

The validator treats `accept` as legal only when all required checks are Green.

## Required Check Families

| Family | Green requirement | Red examples |
|---|---|---|
| Specific action | Has concrete action verb and object. | "Make progress", "continue", vague action. |
| Non-generic language | Does not match blocked phrases or generic patterns. | "Work on your goal", "do the next thing". |
| Capability fit | Declares capability intent and user skill state; copy matches beginner/expert/proof state. | Beginner receives expert Step; expert with proof receives starter-only Step. |
| Context fit | Time, energy, resource, location, deadline, and dependency fit are explicit. | High-energy Step in low-energy context; unavailable resources treated as available. |
| Source/proof | Eligible source or explicit starter/local proof state; proof primitive is present. | Stale/revoked/blocked source passes; proof expectation missing. |
| Safety/tone | Non-shaming, non-coercive, no unsafe instruction. | Shame, urgency theater, high-risk bypass. |
| Accessibility | VoiceOver label, value, hint, and non-visual summary exist. | Visual-only meaning or empty label. |
| Elasticity | At least minimum viable, standard, proof-only, recovery-safe, and replacement coverage are declared; split/merge states must be explicit. | Rigid single version with no recovery route. |
| Repair/fallback | Reject/degrade verdict names repair owner and safe fallback. | Rejection disappears or still surfaces to user. |

## Blocked Generic Phrases

The baseline blocked-list is intentionally conservative and must not be weakened by downstream work:

- work on your goal
- make progress
- research this
- review your plan
- continue
- do the next thing
- try to improve
- keep going
- make a plan
- work on it

Downstream scanner work may add stemming, semantic similarity, phrase windows, and locale support, but these exact phrases remain Red when used as candidate Step copy.

AMB-712 extends this baseline through:

- `artifacts/personal-life-os/step-quality/STEP_GENERIC_BLOCKED_LIST_SCANNER.md`
- `artifacts/personal-life-os/step-quality/STEP_GENERIC_BLOCKED_LIST_SCANNER.json`
- `artifacts/personal-life-os/step-quality/STEP_GENERIC_BLOCKED_LIST_SCANNER_FIXTURES.json`

The AMB-712 scanner adds case-insensitive, whitespace-normalized, punctuation-tolerant exact matching; vague verb plus generic object detection; generic progress-language blocking; and StepQualityVerdict repair linkage.

## Context-Fit Validator

AMB-713 extends the context-fit family through:

- `artifacts/personal-life-os/step-quality/STEP_CONTEXT_FIT_VALIDATOR.md`
- `artifacts/personal-life-os/step-quality/STEP_CONTEXT_FIT_VALIDATOR.json`
- `artifacts/personal-life-os/step-quality/STEP_CONTEXT_FIT_VALIDATOR_FIXTURES.json`

The AMB-713 validator adds field-level blocking codes for time, energy, resource, location, deadline, and dependency mismatch while preserving the aggregate `context_mismatch` code.

## Source/Proof Validator

AMB-714 extends the source/proof family through:

- `artifacts/personal-life-os/step-quality/STEP_SOURCE_PROOF_VALIDATOR.md`
- `artifacts/personal-life-os/step-quality/STEP_SOURCE_PROOF_VALIDATOR.json`
- `artifacts/personal-life-os/step-quality/STEP_SOURCE_PROOF_VALIDATOR_FIXTURES.json`

The AMB-714 validator adds blocking codes for source state, source trace, freshness, review, risk, runtime eligibility, hardcoded Step outputs, proof primitive, receipt requirement, and proof trace while preserving the aggregate `source_not_eligible` and `missing_proof_expectation` codes.

## Acceptance Fixture Requirements

Accepted fixtures must prove:

- concrete action and object
- declared capability target
- context fit across time, energy, resources, and location
- eligible source or explicitly bounded starter guidance
- proof expectation and receipt requirement
- VoiceOver semantics
- elasticity coverage
- no blocked phrase

Rejected fixtures must prove at least these Red blockers:

- generic Step passes attempt
- beginner/expert mismatch
- expert-after-proof starter mismatch
- stale or revoked source
- missing proof expectation
- missing accessibility semantics
- no elasticity coverage

Current fixture matrix: `artifacts/personal-life-os/step-quality/STEP_QUALITY_FIREWALL_FIXTURES.json`.

## Runnable Validator

Run:

```bash
python3 scripts/codex/step-quality-firewall-validate.py
```

The validator loads the JSON contract and fixture matrix, computes deterministic rule results, and fails if:

- an accepted fixture is rejected
- a rejected fixture passes
- an expected blocking code is missing
- the AMB-712 scanner fixtures are missing or fail
- the AMB-713 context-fit fixtures are missing or fail
- the AMB-714 source/proof fixtures are missing or fail
- a generic Step passes
- a beginner/expert mismatch passes
- a stale/revoked/blocked source passes
- proof expectation is missing and still accepted
- M10 has no runnable validator surface

## Existing-First Source Ownership

AMB-711 inspected existing Step and Source Atlas ownership before choosing an artifact/script scope:

- `Native/Ambitions/Runtime/StepCandidateFieldGenerator.swift` owns current Step candidate generation, ranking, rejection, traces, and accessibility summaries.
- `Native/Ambitions/Runtime/SourceAtlasStepCandidateFieldBridge.swift` owns Source Atlas Step candidate expansion and source trace preservation.
- `Native/Ambitions/Domain/GoalEngine/StepCandidateFieldModels.swift` owns Step candidate model seams, validity, rejection records, risk, proof, source, and elastic variants.
- `Native/Ambitions/Domain/GoalEngine/GoalEngineStepRewriter.swift` owns existing vague Step copy rewriting seams.
- `Native/Ambitions/Domain/ProjectStepOperationModels.swift` and `Native/Ambitions/Runtime/StepReallocationRuntimeBridge.swift` own reallocation and mutation-impact seams.

This contract intentionally avoids a parallel Swift runtime implementation. Production integration belongs to later active AMB issues after the remaining M09 validators and M10 scope are live-resolved.

## Green / Yellow / Red

Green for AMB-711 requires:

- `StepQualityInput` and `StepQualityVerdict` downstream shapes are explicit.
- A machine-readable contract exists.
- Accepted and rejected fixture sets exist.
- A runnable local validator exists and passes.
- Generic, capability-mismatched, stale/revoked-source, missing-proof, inaccessible, and rigid/no-elasticity examples are rejected.
- No runtime, UI, release, accessibility, privacy/legal, device, R2, or production-readiness claim exceeds evidence.

Yellow remains for:

- production Swift/runtime integration
- full scanner semantics
- full context-fit validator
- full source/proof validator
- full accessibility validator
- full elasticity coverage validator
- compiler repair implementation
- M10 Golden Slice runtime consumption

Red if:

- a generic Step passes
- a beginner/expert mismatch passes
- a stale, revoked, blocked, or unknown source drives an accepted Step
- proof expectation is missing and the Step accepts
- the validator is missing or failing
- private user data is added to public artifacts or logs
- this contract is treated as app runtime implementation proof

## No-Claim Boundary

AMB-711 does not claim app source changes, Swift/domain model implementation, production Step Quality Firewall runtime wiring, UI implementation, accessibility verification, VoiceOver certification, device proof, measured performance proof, R2 or Source Atlas publication, privacy/legal approval, release readiness, TestFlight readiness, App Store readiness, M09 parent completion, M10 Golden Slice readiness, or full PLOS project completion.
