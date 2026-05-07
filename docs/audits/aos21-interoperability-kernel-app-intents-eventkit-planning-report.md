# AOS21 Interoperability Kernel App Intents EventKit Planning Report

Status: Green
Date: 2026-05-07

## Batch

AOS21 Interoperability Kernel App Intents EventKit Planning.

## Files Changed

- `Native/Ambitions/Domain/AmbitionsOSInteroperabilityModels.swift`
- `Native/AmbitionsTests/Domain/AmbitionsOSInteroperabilityModelsTests.swift`
- `docs/audits/aos21-interoperability-kernel-app-intents-eventkit-planning-report.md`
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

AOS21 adds an additive value-model-only interoperability planning contract for
external surfaces. The model records App Intent, Shortcut, Spotlight, EventKit,
Reminder, Widget, Live Activity, and Share Extension planning surfaces without
implementing those platform integrations.

The validator blocks external invocation, calendar writes, permission prompts,
remote sync, background refresh, missing Source Atlas confirmation for
source-sensitive suggestions, missing external redaction, raw sensitive payload
projection, missing user-reviewed receipts, missing performance budgets, missing
compatibility review, hidden mutation, runtime-store behavior, hosted/remote
dependency, and unsupported release/platform language.

## What This Adds

- typed interoperability surfaces and action kinds
- planning-only capability states
- user-reviewed interoperability receipts
- source/freshness/review requirements for calendar/reminder/external actions
- external-redaction privacy projection requirements
- local approval, performance, and compatibility review gates
- release-claim and platform-overclaim guards
- focused XCTest coverage for the validator paths

## What This Does Not Claim

- App Intent implementation
- EventKit or Reminders implementation
- Shortcut, Spotlight, Widget, Live Activity, or Share Extension implementation
- platform permission prompt behavior
- external calendar/reminder writes
- background refresh
- sync/cloud/backend behavior
- persistence/schema migration
- route/raw-value, entitlement, signing, project, dependency, or release config change
- hosted AI or hosted CI proof
- physical-device proof
- public accessibility conformance
- legal/privacy compliance
- App Store, TestFlight, release, platform, or device readiness

## Validation

- `git status --short`
- `git branch --show-current`
- `git rev-parse HEAD`
- `git log -1 --oneline`
- `test ! -d .github/workflows`
- `xcodegen generate`
- `xcodebuild -project Ambitions.xcodeproj -scheme Ambitions -derivedDataPath output/DerivedData-aos21 -destination "platform=iOS Simulator,name=iPhone 17" -only-testing:AmbitionsTests/AmbitionsOSInteroperabilityModelsTests test CODE_SIGNING_ALLOWED=NO`
- `xcodebuild -quiet -project Ambitions.xcodeproj -scheme Ambitions -derivedDataPath output/DerivedData-aos21-rerun -destination "platform=iOS Simulator,name=iPhone 17" -only-testing:AmbitionsTests/AmbitionsOSInteroperabilityModelsTests test CODE_SIGNING_ALLOWED=NO`
- `git diff --check`
- `scripts/run-doc-qa.sh || true`
- `scripts/batch-train-gate-check.sh || true`
- `scripts/swiftui-architecture-scan.sh || true`
- `scripts/build-local.sh || true`
- `xcodebuild -project Ambitions.xcodeproj -scheme Ambitions -derivedDataPath output/DerivedData-aos21-build -destination "platform=iOS Simulator,name=iPhone 17" build CODE_SIGNING_ALLOWED=NO`

## Proof Artifacts

- Focused test result bundle:
  `output/DerivedData-aos21-rerun/Logs/Test/Test-Ambitions-2026.05.07_01-54-18--0400.xcresult`
- Initial focused run exposed a narrow test fixture compile issue because the
  test used a non-existent `HumanProgressSourceState.unverified` case.
- The test was repaired to use the existing `.sourceNeeded` source-state
  vocabulary and the focused rerun passed.

## Yellow Advisories

- `scripts/run-doc-qa.sh || true` surfaced the existing stale-guidance,
  deprecated-language, markdownlint, and one-redirect lychee advisory backlog.
  Owner: Codex docs QA backlog. Follow-up: run a dedicated docs QA cleanup
  batch. Recheck: `scripts/run-doc-qa.sh` reports no advisory backlog.
- `scripts/batch-train-gate-check.sh || true` reported only the expected
  mid-batch dirty working tree. Owner: current AOS21 closeout. Follow-up:
  commit/push the batch. Recheck: rerun after commit on a clean tree.
- `scripts/swiftui-architecture-scan.sh || true` reported the existing large
  file/responsibility backlog. Owner: maintainability train. Follow-up:
  continue ME/extraction batches when selected. Recheck: architecture scan
  reports no required extraction backlog or the backlog has owner records.
- `scripts/build-local.sh || true` hit the known shared Xcode DerivedData build
  database corruption. Owner: local Mac Xcode environment. Follow-up: clean or
  replace the shared DerivedData database outside product scope. Recheck:
  `scripts/build-local.sh` succeeds without the shared database error.

These advisories are accepted non-blocking Yellow because focused tests and the
dedicated repo-local DerivedData build passed, no workflow directory exists,
and no AOS21 implementation boundary was breached.

## Next Eligible Batch

AOS22 Longevity Kernel Archive Aging.
