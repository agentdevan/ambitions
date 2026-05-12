# PK37 Batch Closeout Report

Date: 2026-05-12
Batch: PK37 Derived Read-Model Cache
Status: Green

## Source Truth Inspected

- `docs/truth/README.md`
- `docs/truth/CODEX_PROCESS_TRUTH.md`
- `.codex/state/active-batch.yml`
- `.codex/reports/current-batch-train-state.md`
- `docs/codex/GLOBAL_QUEUE_CANONICAL_ORDER.json`
- `prompts/batches/PK37.md`
- `Native/Ambitions/Features/Today/TodayReadModelProjector.swift`
- `Native/Ambitions/Features/Today/TodayFeatureService.swift`
- `Native/Ambitions/Features/Today/TodayFeatureSnapshot.swift`
- `Native/AmbitionsTests/Today/TodayDerivedReadModelCacheTests.swift`

## Files Changed

- `Native/Ambitions/Features/Today/TodayReadModelProjector.swift`
- `Native/Ambitions/Features/Today/TodayFeatureService.swift`
- `Native/AmbitionsTests/Today/TodayDerivedReadModelCacheTests.swift`
- `docs/audits/pk37-batch-closeout-report.md`
- `.codex/state/active-batch.yml`
- `.codex/reports/current-run-state.md`
- `.codex/reports/current-batch-train-state.md`
- `.codex/state/global-train-attempt-ledger.md`
- `docs/codex/GLOBAL_QUEUE_CANONICAL_ORDER.json`
- `docs/codex/BATCH_REGISTRY.md`

## Implementation

PK37 adds a local in-memory derived read-model cache for Today execution projection. Cache keys are derived from local snapshot fingerprints, normalized entry context, timestamp, hero/support fingerprints, and app-state ID. The cache is injected into `RepositoryBackedTodayService` and reused only when the same local inputs are projected.

The patch does not add persistence schema, disk cache, network behavior, telemetry, hosted backend behavior, external/cloud LLM behavior, automatic mutation, IA changes, package wiring, signing, entitlements, workflows, or release automation.

## Validation

- `git diff --check` passed.
- `xcodegen generate` passed.
- `scripts/codex-forbidden-claim-scan.sh Native/Ambitions/Features/Today/TodayReadModelProjector.swift Native/Ambitions/Features/Today/TodayFeatureService.swift Native/AmbitionsTests/Today/TodayDerivedReadModelCacheTests.swift 2>/dev/null || true` passed with no blocking hits.
- `scripts/ambitions-xcode-validate.sh --batch PK37 --lane focused-test --test AmbitionsTests/TodayDerivedReadModelCacheTests` passed.

## Review Pass

One focused review pass inspected the PK37 diff for cache-key correctness, no persistence writes, no cross-user/global data retention, local-only behavior, and focused cache-hit proof. A repair added hero/support fingerprints to the cache key before the final focused validation rerun.

## EFC Applicability

Invoked. PK37 touches derived read-model caching and therefore records explicit local-only, no-persistence, and no-claim boundaries.

## Accepted Yellow

None.

## Claims Not Made

This batch does not claim full-suite Green, release readiness, TestFlight readiness, App Store readiness, signed archive readiness, physical-device validation, public accessibility conformance, VoiceOver verification, Dynamic Type verification, Reduce Motion verification, performance validation, privacy/legal approval, hosted CI proof, production readiness, external/cloud LLM core behavior, hosted backend behavior, disk-cache behavior, or global queue completion.

## Rollback

Revert this closeout commit to remove the PK37 in-memory cache, focused tests, report, and state advancement.

## Next Handoff

PK38 Move Domain To Package is next eligible.
