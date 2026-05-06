# PFC16 Live Activities Implementation And Tests Report
<!-- markdownlint-disable MD013 -->

Result: Green
Date: 2026-05-06
Train: PFC01-PFC40 Platform / Framework / Compliance Completion Train
Batch: PFC16 Live Activities Implementation And Tests
Owner: Live Activities / Platform / Privacy

## Summary

PFC16 hardened the existing ActivityKit `Active Step Focus Window` source path
without adding new Live Activity candidates, entitlements, signing, project
changes, dependencies, persistence/schema changes, sync/account/backend
behavior, or release claims. Stale and unavailable Live Activity content now
collapses to open/confirm copy instead of carrying ambient focus title/detail
text, and the spoken accessibility summary uses the same redacted state.

## Files Read

- `docs/codex/GLOBAL_FULL_STACK_COMPLETION_ORDER.md`
- `docs/codex/batch-trains/PFC01_PFC40_PLATFORM_FRAMEWORK_COMPLIANCE_TRAIN.md`
- `docs/canon/Ambitions_Live_Activities_ActivityKit_Strategy.md`
- `docs/audits/pfc15-live-activities-activitykit-strategy-report.md`
- `docs/canon/design/external-surfaces-contract.md`
- `docs/widget-live-activity-manual-testing.md`
- `Native/Ambitions/ExternalSnapshots/NextStepActivityAttributes.swift`
- `Native/Ambitions/Notifications/NextStepLiveActivityService.swift`
- `Native/AmbitionsWidgetExtension/NextStepLiveActivityWidget.swift`
- `Native/AmbitionsTests/App/ExternalSurfaceSnapshotTests.swift`

## Files Changed

- `Native/Ambitions/ExternalSnapshots/NextStepActivityAttributes.swift`
- `Native/Ambitions/Notifications/NextStepLiveActivityService.swift`
- `Native/AmbitionsWidgetExtension/NextStepLiveActivityWidget.swift`
- `Native/AmbitionsTests/App/ExternalSurfaceSnapshotTests.swift`
- `docs/codex/batches/PFC16_Live_Activities_Implementation_And_Tests_Prompt.md`
- `docs/audits/pfc16-live-activities-implementation-tests-report.md`
- train-state, registry, context, dependency, and global-order docs

No entitlement, signing, project, workflow, dependency, privacy manifest,
persistence schema, sync/account, backend, AI/LDI runtime, App Store Connect,
or release file changed.

## Implementation

- `NextStepActivityAttributes.ContentState` now exposes
  `accessibilitySummary` so the widget renderer and source tests use the same
  spoken redaction contract.
- Stale Live Activity state now uses `Open Ambitions to refresh` plus
  `Confirm the latest local state in Ambitions.`
- Unavailable Live Activity state now uses `Open Ambitions` plus
  `Confirm the latest local state in Ambitions.`
- `NextStepLiveActivityLifecycleDecision` gives the service a pure, testable
  end-versus-request/update decision without touching ActivityKit runtime state.
- Focused tests cover stale privacy copy, stale ambient text suppression,
  accessibility-summary redaction, and ending when no concrete step exists.

## Tests Run

- `git status --short`
- `git diff --check`
- `xcodebuild test -scheme Ambitions -destination 'platform=iOS Simulator,name=iPhone 17' -only-testing:AmbitionsTests/ExternalSurfaceSnapshotTests`
- `scripts/build-local.sh`
- PFC16-targeted CQS scans
- `scripts/run-doc-qa.sh || true`
- `scripts/batch-train-gate-check.sh || true`

## Validation Result

- Green.
- `git diff --check` passed.
- Focused Xcode tests passed: `ExternalSurfaceSnapshotTests` executed 13 tests
  with 0 failures. Result bundle:
  `/Users/devan/Library/Developer/Xcode/DerivedData/Ambitions-clensfmdeeuxsueugpmolbvkzbxq/Logs/Test/Test-Ambitions-2026.05.06_11-02-46--0400.xcresult`.
- `scripts/build-local.sh` passed and generated
  `output/logs/build-local-20260506-110646.log`.
- PFC16-targeted CQS privacy/security claim scans reported
  `CQS_PRIVACY_SECURITY_CLAIM_HITS=0` for the prompt, report, ActivityKit
  content-state file, service file, widget renderer, and focused test file.
- `scripts/cqs-accessibility-motion-scan.sh || true` reported existing broad
  advisory hits across `Native/Ambitions`. PFC16 adds source proof that stale
  Live Activity accessibility summary uses the same redacted state as visible
  content.
- `scripts/cqs-performance-budget-scan.sh || true` reported existing broad
  advisory hits and flagged the existing Live Activity `update` call in
  `NextStepLiveActivityService`. PFC16 routes that call through a pure
  lifecycle decision seam and does not add a high-frequency update loop.
- `scripts/run-doc-qa.sh || true` completed with advisory stale-guidance,
  deprecated-language, markdownlint backlog, and lychee 0 errors / 1 redirect.
  Logs:
  `docs/audits/doc-qa/20260506-110716-stale-guidance.log`,
  `docs/audits/doc-qa/20260506-110716-deprecated-language.log`,
  `docs/audits/doc-qa/20260506-110716-markdownlint.log`, and
  `docs/audits/doc-qa/20260506-110716-lychee.log`.
- `scripts/batch-train-gate-check.sh || true` completed with the expected
  working-tree Yellow hint before commit.

## Repairs Attempted

- Repaired stale/unavailable Live Activity content-state behavior so stale
  external snapshots cannot keep rendering private ambient focus text.
- Added a pure lifecycle decision seam so the no-concrete-step end path is
  source-testable without requiring ActivityKit device/runtime proof.

## Remaining Yellow Items

- Rendered Lock Screen and Dynamic Island behavior remains unproven.
- Physical-device ActivityKit lifecycle delivery remains unproven.
- Manual VoiceOver, Dynamic Type, Reduce Motion, contrast, and truncation review
  remain human/operator proof.
- App Store/TestFlight/release readiness, legal/privacy compliance, final
  privacy-label truth, and public accessibility conformance remain blocked.

## Red Classification

No Red. Entitlement/signing/project changes, new Live Activity candidates,
sensitive Lock Screen/Dynamic Island content exposure, unsupported release
claims, or rendered/device proof claims without evidence would be Hard Red.

## Rollback Path

Revert the PFC16 commit to restore the prior Live Activity content-state and
service decision behavior and remove PFC16 prompt/report/train-state updates.
No entitlement, signing, project, workflow, dependency, schema, or generated
rollback is needed.

## Next Eligible Batch

PFC18 App Intents / Shortcuts Implementation And Tests.
