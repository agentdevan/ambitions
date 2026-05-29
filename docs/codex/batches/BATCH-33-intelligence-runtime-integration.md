# Batch 33 — Ambitions 2.0 Batch 14 / Intelligence Runtime Integration

<!-- AMB-291-CANON-HYGIENE-REPAIR: BEGIN -->

> AMB-291 repair status: **canon-hygiene-reconciled**
> This file was reviewed as part of the actual canon content/hygiene rewrite pass.
> It is not standalone active product truth. Use `docs/truth/*` and current manifest/sequence authority before implementation.
> Conflict types reconciled: same_source_file_targeted_by_multiple_active_batches, same_surface_multiple_active_batches
> Prior recommended actions: Expedite, Merge
> Candidate references: AMB28-same_source_file_targeted_by_multiple_active_batches-21600714, AMB28-same_source_file_targeted_by_multiple_active_batches-23423927, AMB28-same_source_file_targeted_by_multiple_active_batches-41488053, AMB28-same_source_file_targeted_by_multiple_active_batches-50843547, AMB28-same_source_file_targeted_by_multiple_active_batches-85327957, AMB28-same_source_file_targeted_by_multiple_active_batches-87116582, AMB28-same_source_file_targeted_by_multiple_active_batches-97805658, AMB28-same_source_file_targeted_by_multiple_active_batches-98301428, AMB28-same_surface_multiple_active_batches-26899932, AMB28-same_surface_multiple_active_batches-34058953, AMB28-same_surface_multiple_active_batches-96568748

<!-- AMB-291-CANON-HYGIENE-REPAIR: END -->

<!-- AMB-291-CANON-HYGIENE-HEADER: BEGIN -->

> Canon hygiene status: **execution-work-order-needs-sequencing**
> AMB-291 note: This batch/prompt is a work-order artifact and must be sequenced before execution.
> Active authority: `docs/truth/*`, `docs/codex/GLOBAL_BATCH_SEQUENCE_AUTHORITY.json`, and `docs/codex/IOS26_FLAGSHIP_TRAIN_MANIFEST.yml`.
> Before using this file for implementation, run `make change-impact-check` and follow `docs/ops/change-protocol/implementation-prompt-template.md`.
> Resolution classes: authority-rewrite, merge-overlap
> Dispositions: merge-or-sequence-file-ownership, merge-or-sequence-surface-ownership, rewrite-authority-reference

<!-- AMB-291-CANON-HYGIENE-HEADER: END -->

## Status

Completed

## Goal

Integrate the completed Ambitions 2.0 intelligence layers behind one stable runtime-owned, goal-centered service seam so live app consumers can reuse canonical intelligence outputs through runtime composition instead of feature-local wiring.

This batch stayed composition-only. It did not add new intelligence behavior, broaden the product shell, or widen unrelated runtime payloads.

## What Landed

- added a runtime-owned goal-intelligence seam in `Native/Ambitions/Runtime/AmbitionsRuntimeGoalIntelligence.swift`
- kept the runtime contract narrow and goal-centered through:
  - `RuntimeGoalIntelligenceServicing`
  - `RuntimeGoalIntelligenceRequest`
  - `RuntimeGoalIntelligenceContext`
- reused canonical existing intelligence outputs directly rather than creating mirror runtime models:
  - `GoalOrchestrationMetadata`
  - `GoalTeachingApplicableSet`
  - `GoalExplainabilityState`
  - optional `WhyNowExplanationMetadata`
- wired the live runtime to expose the new seam in:
  - `Native/Ambitions/Runtime/AmbitionsRuntimeContracts.swift`
  - `Native/Ambitions/Runtime/AmbitionsRuntimeFactory.swift`
- composed the runtime seam from existing canonical services only:
  - orchestration-backed goal/draft metadata
  - `DefaultGoalExplainabilityProjector`
  - `DefaultGoalTeachingSignalService`
  - `LearningAnticipationService` for optional why-now read-through
- migrated `Native/Ambitions/Features/Goals/GoalsFeatureService.swift` to use the runtime seam for:
  - explainability reads
  - applicable teaching-signal reads
  - explainability correction capture
- migrated `Native/Ambitions/Features/Today/TodayFeatureService.swift` only for the existing narrow why-this path
- kept compatibility fallback construction paths thin and delegated back to the same canonical services instead of creating a second live composition path
- added runtime and consumer parity coverage in:
  - `Native/AmbitionsTests/Runtime/AmbitionsRuntimeGoalIntelligenceServiceTests.swift`
  - `Native/AmbitionsTests/Runtime/AmbitionsRuntimeBoundaryTests.swift`
  - `Native/AmbitionsTests/App/AppContainerFactoryTests.swift`
  - `Native/AmbitionsTests/Goals/GoalDetailExplainabilityActionTests.swift`
  - `Native/AmbitionsTests/Today/TodayFreshGoalVisibilityTests.swift`

## What Did Not Land

- no new engine behavior, ranking, heuristics, or correction logic
- no portfolio-wide or shell-wide intelligence aggregation
- no broad product-shell rollout of path/resource/energy/correction/explanation experiences
- no runtime-wide snapshot or notification payload expansion
- no persistence schema or orchestrator contract redesign
- no Insights runtime-intelligence adoption
- no Batch 34 shell integration work

## Validation That Actually Ran

- `xcodegen generate`
  - passed
- native app build:
  - `xcodebuild -project Ambitions.xcodeproj -scheme Ambitions -sdk iphonesimulator -destination "generic/platform=iOS Simulator" CODE_SIGNING_ALLOWED=NO build`
  - passed
- authoritative native unit validation:
  - `xcodebuild -project Ambitions.xcodeproj -scheme Ambitions -destination "platform=iOS Simulator,id=8ACCD665-4807-4102-B526-5A1AE20686A8" -only-testing:AmbitionsTests test`
  - passed
  - result: 320 tests, 0 failures
- note on filtered runtime-only validation:
  - the narrow filtered `-only-testing:AmbitionsTests/Runtime/...` invocation returned `0 tests executed` in this environment
  - full `AmbitionsTests` validation was therefore treated as the source of truth for closeout

## Completion Notes

- the live runtime now owns one goal-centered intelligence seam instead of leaving explainability/correction access feature-locally wired
- the runtime seam remains composition-only and reuses canonical intelligence services without inventing new behavior
- Goals now reads explainability and correction flows through runtime composition
- Today only reuses the seam for its existing narrow why-this path
- compatibility fallback paths remain thin and non-canonical
- Insights remains unchanged
- no additional Batch 33 bug was found during wrap-up
- the checked-out branch remained `main` during implementation, validation, and wrap-up

## Subsequent Batch

Batch 34 — Ambitions 2.0 Batch 15 / Ambitions 2.0 product shell integration completed the current queued Ambitions 2.0 registry wave.

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
