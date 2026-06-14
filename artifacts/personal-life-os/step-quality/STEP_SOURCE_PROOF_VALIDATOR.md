# Step Source/Proof Validator

Status: Active PLOS M09 downstream validator
Issue: AMB-714 / PLOS-093
Parent: AMB-627 / PLOS-M09
Scope: Source/proof validation contract, machine-readable rules, fixtures, and local validator linkage
Runtime implementation proof: none

## Purpose

The Step Source/Proof Validator blocks or degrades a Step candidate when its source state, trace, freshness, review, runtime eligibility, risk posture, proof primitive, receipt requirement, or proof trace is missing or unsafe.

This validator extends the AMB-711 Step Quality Firewall contract. It is a downstream control-plane artifact for AMB-715 through AMB-717 and the AMB-617 / PLOS-M10 Golden Slice dependency gate. It does not wire production Swift runtime behavior.

## Required Inputs

The validator consumes the canonical `StepQualityInput` envelope and reads:

- `sourceAuthority.state`
- `sourceAuthority.sourceTraceId`
- `sourceAuthority.sourceHash`
- `sourceAuthority.freshnessState`
- `sourceAuthority.reviewState`
- `sourceAuthority.riskClass`
- `sourceAuthority.runtimeEligible`
- `sourceAuthority.hardcodedStepOutput`
- `proofExpectation.primitive`
- `proofExpectation.receiptRequired`
- `proofExpectation.proofTraceId`
- `proofExpectation.receiptKind`

## Blocking Outputs

The validator emits deterministic `StepQualityVerdict.blockingCodes`:

- `source_not_eligible`
- `source_state_blocked`
- `source_trace_missing`
- `source_freshness_invalid`
- `source_review_invalid`
- `source_risk_blocked`
- `source_runtime_ineligible`
- `hardcoded_step_output`
- `missing_proof_expectation`
- `proof_missing`
- `proof_receipt_missing`
- `proof_trace_missing`
- `source_proof_repair_required`

Any source/proof failure requires Step Graph Compiler repair or a safe starter/local proof fallback before a Step can be surfaced.

## Acceptance Rules

Accepted source/proof candidates must:

- use an allowed source state: `official-current`, `maintainer-curated`, `local-proof-only`, or `starter-guidance-only`
- carry a non-empty source trace identifier and source hash when source-backed
- have current, local-only, or starter-bounded freshness
- have approved, local-proof, or starter-bounded review state
- stay within low, medium-bounded, or starter-bounded risk class
- be runtime eligible
- not be a hardcoded finished Step output
- declare a proof primitive, require a receipt, and carry a proof trace identifier

Blocked, stale, revoked, review-required, high-risk, runtime-ineligible, missing-trace, missing-proof, missing-receipt, missing-proof-trace, and hardcoded finished Step outputs must reject.

## Downstream Consumers

- AMB-715 / PLOS-094 must validate accessibility semantics over source/proof-bounded Step copy.
- AMB-716 / PLOS-095 must validate elasticity variants without source/proof bypass.
- AMB-717 / PLOS-096 must route failed source/proof cases through compiler repair and safe fallback.
- AMB-617 / PLOS-M10 must keep this validator runnable until production runtime integration exists.

## No-Claim Boundary

AMB-714 does not claim app source changes, Swift/domain runtime implementation, production Step Quality Firewall wiring, Source Atlas publication, R2 writes, UI implementation, accessibility certification, device proof, measured performance proof, privacy/legal approval, release readiness, TestFlight readiness, App Store readiness, M09 parent completion, M10 Golden Slice readiness, or full PLOS project completion.
