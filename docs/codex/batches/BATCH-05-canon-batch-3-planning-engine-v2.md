# Batch 05 — Canon Batch 3 / Planning Engine v2

<!-- AMB-291-CANON-HYGIENE-REPAIR: BEGIN -->

> AMB-291 repair status: **canon-hygiene-reconciled**
> This file was reviewed as part of the actual canon content/hygiene rewrite pass.
> It is not standalone active product truth. Use `docs/truth/*` and current manifest/sequence authority before implementation.
> Conflict types reconciled: same_surface_multiple_active_batches, stale_or_unknown_active_status
> Prior recommended actions: Expedite
> Candidate references: AMB28-same_surface_multiple_active_batches-34058953, AMB28-same_surface_multiple_active_batches-66075429, AMB28-stale_or_unknown_active_status-66891157

<!-- AMB-291-CANON-HYGIENE-REPAIR: END -->

<!-- AMB-291-CANON-HYGIENE-HEADER: BEGIN -->

> Canon hygiene status: **execution-work-order-needs-sequencing**
> AMB-291 note: This batch/prompt is a work-order artifact and must be sequenced before execution.
> Active authority: `docs/truth/*`, `docs/codex/GLOBAL_BATCH_SEQUENCE_AUTHORITY.json`, and `docs/codex/IOS26_FLAGSHIP_TRAIN_MANIFEST.yml`.
> Before using this file for implementation, run `make change-impact-check` and follow `docs/ops/change-protocol/implementation-prompt-template.md`.
> Resolution classes: authority-rewrite, merge-overlap, merge-overlap-before-proof, status-expedite
> Dispositions: clarify-status-before-use, merge-before-proof, merge-or-sequence-surface-ownership, rewrite-authority-reference

<!-- AMB-291-CANON-HYGIENE-HEADER: END -->

## Status

Completed

## Goal

Strengthen Ambitions' canonical planning brain so the app can derive a more believable, explainable next move with explicit confidence and plan-risk signals before recovery, time orchestration, or ambient surfaces expand.

## In Scope

- audit the current planning/recommendation pipeline
- formalize feasibility scoring where justified
- formalize recommendation confidence usage through the planning flow
- add fragility and pressure markers for plans or recommendations where justified
- add pacing and effort-posture rules at existing planner seams
- strengthen canonical next-step derivation rules
- refine planning-domain outputs/contracts only where needed
- add focused tests for feasibility, confidence, next-step derivation, and planning-output behavior

## Out Of Scope

- recovery engine behavior changes
- cause-of-drift or reschedule behavior changes beyond compile compatibility
- time orchestration / EventKit work
- calendar conflict logic
- App Intents
- widgets / Live Activities
- sync
- life graph / household / device work
- large UI redesigns
- speculative AI or narration behavior

## Current Repo Notes

- `GoalEngineOrchestrator`, `GoalPlanner`, inference confidence, plan linting, feedback confidence, Today ranking, and external next-action snapshots already exist.
- `RepositoryBackedGoalsService.createGoal` still has a deterministic micro-plan path and should be routed narrowly through the canonical goal engine without redesigning the create-goal UX.
- Planning evaluation metadata should round-trip through additive Codable fields and existing snapshot payloads. No SwiftData columns are expected.
- Today and external snapshots should consume one shared next-step selector instead of separate ranking logic.

## Exit Criteria

- planning outputs expose deterministic feasibility, confidence, pressure, fragility, and effort-posture metadata
- goal creation uses the canonical planning engine while preserving clear planned / starter / clarification / blocked persistence behavior
- Today and external snapshots use the same next-step selector
- focused tests cover planning evaluation, canonical goal creation, selector reuse, and persistence compatibility
- XcodeGen generation, build, targeted tests, and full AmbitionsTests validation pass before this batch is marked completed

## Completion Note

Completed after `xcodegen generate`, simulator build, targeted Batch 3 tests, and full `AmbitionsTests` validation passed on iPhone 17 simulator.

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
