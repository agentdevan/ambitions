# AOS20 Adaptation Kernel Local Personalization Report

Status: Green
Date: 2026-05-07

## Batch Scope

AOS20 completed as additive Adaptation Kernel domain-contract evidence. The
batch adds typed value contracts and focused tests for local user-controlled
calibration, assumption review/rejection, seriousness-change receipts,
sensitive-adaptation privacy review, deterministic fallback, model-required
path blocking, hidden-personalization blocking, hidden-mutation blocking, and
release-claim truth boundaries.

## Files Changed

- `Native/Ambitions/Domain/AmbitionsOSAdaptationModels.swift`
- `Native/AmbitionsTests/Domain/AmbitionsOSAdaptationModelsTests.swift`
- `docs/audits/aos20-adaptation-kernel-local-personalization-report.md`
- `.codex/reports/current-run-state.md`
- `.codex/reports/current-batch-train-state.md`
- `docs/codex/AMBITIONSOS_AOS_EVIDENCE_LEDGER.md`
- `docs/codex/AMBITIONSOS_AOS_PRIVACY_PROJECTION_LEDGER.md`
- `docs/codex/AMBITIONSOS_AOS_RELEASE_CLAIM_BOUNDARY.md`
- `docs/codex/AMBITIONSOS_AOS_TEST_IMPACT_MATRIX.md`
- `docs/codex/AMBITIONSOS_AOS_TRACEABILITY_MATRIX.md`
- `docs/codex/BATCH_REGISTRY.md`
- `docs/codex/CONTEXT_INDEX.md`
- `docs/codex/GLOBAL_FULL_STACK_COMPLETION_ORDER.md`
- `docs/codex/GLOBAL_OPTIMIZED_IMPLEMENTATION_ORDER.md`
- `docs/codex/RESUME_GLOBAL_BATCH_TRAIN.md`
- `docs/codex/batch-trains/AOS01_AOS30_AMBITIONSOS_LOCAL_INTELLIGENCE_TRAIN.md`

## Implementation Summary

- Added `AmbitionsOSAdaptationProfile` as a value-only contract for local
  user-controlled calibration on You, Today, and Plan.
- Added typed adaptation dimensions, permission states, assumption states,
  receipt kinds, assumptions, receipts, and validator issues.
- Added `AmbitionsOSAdaptationValidator` gates for malformed profiles, missing
  user controls, hidden personalization, rejected or unreviewed assumptions,
  seriousness changes without receipts, sensitive adaptation without privacy
  review, missing deterministic fallback, model-required paths, forbidden
  personalization/release language, hidden mutation, and runtime-store
  behavior.
- Added focused tests covering valid contracts and each blocker category.
- Updated AOS ledgers, registry, context index, global order docs, and run
  state to mark AOS20 Green and select AOS21 as next.

## Validation

Commands run:

- `git status --short`
- `git branch --show-current`
- `git rev-parse HEAD`
- `git log -1 --oneline`
- `test ! -d .github/workflows`
- `xcodegen generate`
- `xcodebuild -project Ambitions.xcodeproj -scheme Ambitions -derivedDataPath output/DerivedData-aos20 -destination "platform=iOS Simulator,name=iPhone 17" -only-testing:AmbitionsTests/AmbitionsOSAdaptationModelsTests test CODE_SIGNING_ALLOWED=NO`
- `xcodebuild -quiet -project Ambitions.xcodeproj -scheme Ambitions -derivedDataPath output/DerivedData-aos20-rerun -destination "platform=iOS Simulator,name=iPhone 17" -only-testing:AmbitionsTests/AmbitionsOSAdaptationModelsTests test CODE_SIGNING_ALLOWED=NO`
- `git diff --check`
- `scripts/run-doc-qa.sh || true`
- `scripts/batch-train-gate-check.sh || true`
- `scripts/swiftui-architecture-scan.sh || true`
- `scripts/build-local.sh || true`
- `xcodebuild -project Ambitions.xcodeproj -scheme Ambitions -derivedDataPath output/DerivedData-aos20-build -destination "platform=iOS Simulator,name=iPhone 17" build CODE_SIGNING_ALLOWED=NO`

Focused proof:

- `AmbitionsOSAdaptationModelsTests`: passed after a narrow helper
  argument-order repair.
- Result bundle:
  `output/DerivedData-aos20-rerun/Logs/Test/Test-Ambitions-2026.05.07_00-53-45--0400.xcresult`
- Dedicated local build passed using repo-local DerivedData:
  `output/DerivedData-aos20-build`.

Advisory checks:

- `scripts/run-doc-qa.sh || true` completed with the existing advisory
  stale-guidance/deprecated-language/markdownlint backlog and lychee 0 errors /
  1 redirect.
- `scripts/batch-train-gate-check.sh || true` reported only the expected
  working-tree-changes hint before commit.
- `scripts/swiftui-architecture-scan.sh || true` reported the existing
  large-file/responsibility backlog.
- `scripts/build-local.sh || true` failed in the shared Xcode DerivedData path
  with the known malformed build database; the repo-local dedicated build
  passed.

## What This Does Not Claim

AOS20 does not claim adaptation runtime, personalization runtime, durable
memory storage, hidden learning, model runtime, LDI runtime, UI integration,
rendered simulator proof, public accessibility conformance, legal/privacy
compliance, physical-device proof, release readiness, App Store readiness,
TestFlight readiness, platform readiness, sync/cloud readiness, or any app
behavior change.

## Yellow Advisories

Owner: Codex/local toolchain maintenance.
Reason: The first focused run found a repairable test helper argument-order
compile error. A subsequent quiet rerun against `output/DerivedData-aos20` hit
a local Xcode build database lock after the failed invocation, and
`scripts/build-local.sh || true` hit the known malformed shared Xcode
DerivedData build database.
Follow-up: continue using fresh repo-local DerivedData paths when a failed
Xcode invocation leaves a lock; clean stale shared DerivedData in a toolchain
maintenance pass.
Recheck condition: AOS20 focused tests pass in a fresh DerivedData path, and
the dedicated repo-local build passes while future reruns avoid stale build
database locks.

## Next Eligible Batch

AOS21 Interoperability Kernel App Intents EventKit Planning is the next
eligible global batch after this Green closeout, unless newer repo evidence
selects a later batch.
