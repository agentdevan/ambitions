# Batch 34 — Ambitions 2.0 Batch 15 / Ambitions 2.0 Product Shell Integration

<!-- AMB-291-CANON-HYGIENE-HEADER: BEGIN -->

> Canon hygiene status: **execution-work-order-needs-sequencing**
> AMB-291 note: This batch/prompt is a work-order artifact and must be sequenced before execution.
> Active authority: `docs/truth/*`, `docs/codex/GLOBAL_BATCH_SEQUENCE_AUTHORITY.json`, and `docs/codex/IOS26_FLAGSHIP_TRAIN_MANIFEST.yml`.
> Before using this file for implementation, run `make change-impact-check` and follow `docs/ops/change-protocol/implementation-prompt-template.md`.
> Resolution classes: authority-rewrite, merge-overlap, merge-overlap-before-proof
> Dispositions: merge-before-proof, merge-or-sequence-surface-ownership, rewrite-authority-reference

<!-- AMB-291-CANON-HYGIENE-HEADER: END -->

## Status

Completed

## Goal

Integrate the completed Ambitions 2.0 intelligence stack into the actual product shell so path, resource, freshness, energy, correction, and explanation experiences become first-class parts of the core Goals and Today flows through the Batch 33 runtime seam.

This batch stayed shell-integration-only. It did not add new engine behavior, ranking logic, correction logic, freshness logic, tab-level redesign, or rollout into unrelated app areas.

## What Landed

- extended `RuntimeGoalIntelligenceServicing` additively with batch context loading while preserving the same `RuntimeGoalIntelligenceRequest` and `RuntimeGoalIntelligenceContext` contract used by single-target loading
- added a read-only shared shell summary projection in `Native/Ambitions/Features/Shared/GoalShellSummary.swift`
- projected compact runtime-backed shell summaries for:
  - path status
  - source/freshness attention
  - canonical energy terminology when runtime metadata exists
  - contradiction attention
  - correction or applied-teaching presence
  - compact explanation copy
- integrated Goals overview with compact runtime-backed intelligence state in rows
- added only lightweight trust-relevant Goals hero attention pills
- integrated Today Daily Targets, Focus, and Milestone with the same shared compact summary model
- preserved existing Today actions and navigation posture
- preserved Goal Detail as the only full-fidelity trust surface for explainability, source audit, contradiction detail, and correction controls
- added parity and compatibility coverage for runtime batch loading, Goals shell summaries, and Today shell summaries

## What Did Not Land

- no second full explainability system outside Goal Detail
- no new engine-level intelligence, ranking, contradiction, freshness, energy-learning, or teaching behavior
- no new Today action system, modal flow, or correction workflow
- no shell rollout into Captures, Habits, Insights, Profile, widgets, notifications, extensions, or other product areas
- no broad visual redesign
- no performance or caching architecture rewrite
- no normal Batch 35 was added to the current registry wave

## Validation That Actually Ran

- `xcodegen generate`
  - passed
- native app build:
  - `xcodebuild -project Ambitions.xcodeproj -scheme Ambitions -sdk iphonesimulator -destination "generic/platform=iOS Simulator" CODE_SIGNING_ALLOWED=NO build`
  - passed
- focused runtime/shell parity validation:
  - `xcodebuild -project Ambitions.xcodeproj -scheme Ambitions -destination "platform=iOS Simulator,name=iPhone 17" -only-testing:AmbitionsTests/AmbitionsRuntimeGoalIntelligenceServiceTests/testBatchLoadContextMatchesSingleTargetProjectionAndOrdering -only-testing:AmbitionsTests/GoalsShellIntegrationTests/testOverviewAddsCompactRuntimeBackedShellSummaryWithoutChangingOrdering -only-testing:AmbitionsTests/TodayShellIntegrationTests/testTodayCardsShareCompactRuntimeBackedShellSummaryWithoutChangingActionPosture test`
  - passed
- targeted runtime/shell compatibility validation:
  - `xcodebuild -project Ambitions.xcodeproj -scheme Ambitions -destination "platform=iOS Simulator,name=iPhone 17" -only-testing:AmbitionsTests/AmbitionsRuntimeGoalIntelligenceServiceTests -only-testing:AmbitionsTests/AppContainerFactoryTests -only-testing:AmbitionsTests/GoalDetailExplainabilityActionTests -only-testing:AmbitionsTests/TodayFreshGoalVisibilityTests -only-testing:AmbitionsTests/GoalsShellIntegrationTests -only-testing:AmbitionsTests/TodayShellIntegrationTests test`
  - passed
  - result: 18 tests, 0 failures
- full native unit suite:
  - `xcodebuild -project Ambitions.xcodeproj -scheme Ambitions -destination "platform=iOS Simulator,name=iPhone 17" -only-testing:AmbitionsTests test`
  - passed
  - result: 323 tests, 0 failures

## Not Verified

- manual simulator UI review of the compact shell presentation was not completed in this batch
- carry manual UI review forward as hardening/product-audit input, not as a blocker for Batch 34 closeout

## Completion Notes

- Goals overview and Today now consume compact runtime-backed shell summaries through the Batch 33 seam
- Goal Detail remains the only full-fidelity trust surface
- shell surfaces read through one consistent runtime-backed summary model
- no new engine behavior was introduced
- no additional Batch 34 bug was found during wrap-up
- the checked-out branch remained `main` during implementation, validation, and wrap-up

## Registry Wave Status

Batch 34 is the final queued batch in the current Ambitions 2.0 registry sequence. The current Ambitions 2.0 execution queue is complete and exhausted.

The next step is a post-2.0 whole-repo/app hardening and product-audit planning pass. Do not create a speculative normal Batch 35 in the current registry without an explicit new planning wave.

## Source-of-truth references

<!-- AMB-291-SOURCE-OF-TRUTH-REFERENCES: BEGIN -->

This file must not be treated as standalone active canon. Current authority must be resolved through:

- `docs/truth/README.md`
- `docs/truth/PRODUCT_DESIGN_TRUTH.md`
- `docs/truth/PRODUCT_MOAT_TRUTH.md`
- `docs/truth/IMPLEMENTATION_TRUTH.md`
- `docs/truth/RELEASE_TRUTH.md`
- `docs/truth/CODEX_PROCESS_TRUTH.md`
- `docs/truth/HISTORICAL_POLICY.md`
- `docs/codex/GLOBAL_BATCH_SEQUENCE_AUTHORITY.json`
- `docs/codex/IOS26_FLAGSHIP_TRAIN_MANIFEST.yml`
- `docs/ops/change-protocol/change-request-template.md`
- `docs/ops/change-protocol/change-impact-check.md`
- `docs/ops/change-protocol/implementation-prompt-template.md`
- `docs/ops/change-protocol/post-implementation-proof-reconciliation.md`

<!-- AMB-291-SOURCE-OF-TRUTH-REFERENCES: END -->

## Non-claims

<!-- AMB-291-NON-CLAIMS: BEGIN -->

- This file does not prove implementation.
- This file does not prove build success.
- This file does not prove test success.
- This file does not prove accessibility validation.
- This file does not prove performance validation.
- This file does not prove device validation.
- This file does not prove privacy/legal approval.
- This file does not prove TestFlight readiness.
- This file does not prove App Store readiness.
- This file does not prove release readiness.
- Linear status is not repo truth.

<!-- AMB-291-NON-CLAIMS: END -->
