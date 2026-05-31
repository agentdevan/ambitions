# AFRI-016 Deterministic Planner Rule Engine Proof

Status: Local proof packet for AMB-368 / AFRI-016.

## Scope

- Added `PlanningRuleTrace` to planner recommendations so each selected step carries a deterministic, inspectable rule trace.
- Added a local context vector with goal mode, time fit, feasibility, fragility, step state, dependency state, learned fit, timeline risk, energy fit, energy learning, shared-life pressure, user defaults, and review cadence.
- Exposed deterministic trace identifiers for `SourceRecord`, `Receipt`, and `ReplayTrace` without adding a new planner owner or network dependency.
- Surfaced rule reasons, confidence, fallback reason IDs, and You / What Ambitions knows control visibility.

## Proof Boundaries

- This is domain-model and focused test proof for local recommendation traces.
- It does not claim final Today UI wiring, final You UI inspection, release readiness, device validation, accessibility proof, privacy/legal signoff, or app-store readiness.
- Existing Today selection behavior remains the fallback behavior; this patch annotates selected candidates with inspectable traces.
- No cloud LLM, hosted inference, analytics, backend, or network dependency was added.

## Validation

- Pre-implementation guard: `python3 scripts/ambitions-parallel-implementation-guard.py --phase pre --batch AMB-368 --prompt /tmp/AMB-368-AFRI-016-guard-prompt.md`
  - Result: Green.
  - Report: `build/reports/parallel-implementation-guard/AMB-368-pre.md`
- Focused planner validation: `xcodebuild test -project Ambitions.xcodeproj -scheme Ambitions -destination id=8ACCD665-4807-4102-B526-5A1AE20686A8 -only-testing:AmbitionsTests/PlanningDomainModelsTests`
  - First result: Red, 1 focused assertion failure in the new trace fallback expectation.
  - Repair: surfaced deterministic neutral energy-learning reason codes in trace fallback reason IDs.
  - Final result: Green, 13 tests, 0 failures.
  - Final rerun after guard wording repair: Green, 13 tests, 0 failures.
  - Result bundle: `/Users/devan/Library/Developer/Xcode/DerivedData/Ambitions-clensfmdeeuxsueugpmolbvkzbxq/Logs/Test/Test-Ambitions-2026.05.31_13-12-03--0400.xcresult`
- Post-implementation guard: `python3 scripts/ambitions-parallel-implementation-guard.py --phase post --batch AMB-368 --prompt /tmp/AMB-368-AFRI-016-guard-prompt.md --changed-from 95cf13a0e --changed-path Native/Ambitions/Domain/Planning/PlanningEvaluation.swift --changed-path Native/AmbitionsTests/Domain/PlanningDomainModelsTests.swift --changed-path docs/codex/concept-lock-registry.yml --changed-path docs/proof/afri/afri-016-deterministic-planner-rule-engine-proof.md`
  - Result: Green.
  - Report: `build/reports/parallel-implementation-guard/AMB-368-post.md`

## Rollback

- Remove `PlanningRuleTrace`, `PlanningRuleContextVector`, and `PlanningNextStepCandidate.ruleTrace`.
- Remove the selector trace construction helpers and fallback reason exposure.
- Remove `testDeterministicSelectorExposesInspectableLocalRuleTrace`.
- Revert this proof packet.
