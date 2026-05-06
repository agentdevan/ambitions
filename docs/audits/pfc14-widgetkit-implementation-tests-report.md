# PFC14 WidgetKit Implementation And Tests Report
<!-- markdownlint-disable MD013 -->

Result: Green
Date: 2026-05-06
Train: PFC01-PFC40 Platform / Framework / Compliance Completion Train
Batch: PFC14 WidgetKit Implementation And Tests
Owner: Widgets / Platform / Privacy

## Summary

PFC14 hardened the existing WidgetKit projection path without adding new widget
families, entitlements, signing, project changes, dependencies, schema changes,
sync/account behavior, or release claims. Stale and unavailable widget
snapshots now collapse to open/refresh copy and suppress ambient variant rows,
so widgets do not invite action from stale data or leak ambient text after the
snapshot lease is no longer current.

## Files Read

- `docs/codex/GLOBAL_FULL_STACK_COMPLETION_ORDER.md`
- `docs/codex/batch-trains/PFC01_PFC40_PLATFORM_FRAMEWORK_COMPLIANCE_TRAIN.md`
- `docs/canon/Ambitions_WidgetKit_Strategy_And_Object_Map.md`
- `docs/audits/pfc13-widgetkit-strategy-object-map-report.md`
- `docs/audits/pfc12-app-groups-shared-storage-boundary-report.md`
- `Native/Ambitions/ExternalSnapshots/ExternalWidgetProjection.swift`
- `Native/AmbitionsWidgetExtension/NextStepWidget.swift`
- `Native/AmbitionsTests/App/ExternalWidgetProjectionTests.swift`
- `Native/AmbitionsTests/App/ExternalSurfaceSnapshotTests.swift`

## Files Changed

- `Native/Ambitions/ExternalSnapshots/ExternalWidgetProjection.swift`
- `Native/AmbitionsTests/App/ExternalWidgetProjectionTests.swift`
- `docs/codex/batches/PFC14_WidgetKit_Implementation_And_Tests_Prompt.md`
- `docs/audits/pfc14-widgetkit-implementation-tests-report.md`
- `docs/codex/batch-trains/PFC01_PFC40_PLATFORM_FRAMEWORK_COMPLIANCE_TRAIN.md`
- `docs/codex/GLOBAL_FULL_STACK_COMPLETION_ORDER.md`
- `docs/codex/GLOBAL_OPTIMIZED_IMPLEMENTATION_ORDER.md`
- `docs/codex/GLOBAL_FUTURE_BATCH_DEPENDENCY_GRAPH.md`
- `docs/codex/BATCH_REGISTRY.md`
- `docs/codex/CONTEXT_INDEX.md`
- `.codex/reports/current-run-state.md`
- `.codex/reports/current-batch-train-state.md`

No widget entitlement, signing, project, workflow, dependency, privacy
manifest, persistence schema, sync/account, backend, AI/LDI runtime, App Store
Connect, or release files changed.

## Implementation

- `ExternalWidgetProjection` now suppresses ambient variant rows when the
  snapshot lease is stale or unavailable.
- Stale widgets now use `Open Ambitions to refresh` plus `This may be behind.`
  rather than rendering potentially actionable ambient title/detail copy.
- Unavailable widgets now use `Open Ambitions` plus `Confirm the latest local
  state in Ambitions.`
- Focused tests cover missing snapshot fallback, stale copy, stale row
  suppression, and private ambient text not appearing in widget accessibility
  output.

## Tests Run

- `git status --short`
- `git diff --check`
- `xcodebuild test -scheme Ambitions -destination 'platform=iOS Simulator,name=iPhone 17' -only-testing:AmbitionsTests/ExternalWidgetProjectionTests -only-testing:AmbitionsTests/ExternalSurfaceSnapshotTests`
- `scripts/build-local.sh`
- `scripts/cqs-privacy-security-claim-scan.sh docs/codex/batches/PFC14_WidgetKit_Implementation_And_Tests_Prompt.md docs/audits/pfc14-widgetkit-implementation-tests-report.md Native/Ambitions/ExternalSnapshots/ExternalWidgetProjection.swift Native/AmbitionsTests/App/ExternalWidgetProjectionTests.swift || true`
- `scripts/cqs-accessibility-motion-scan.sh || true`
- `scripts/cqs-performance-budget-scan.sh || true`
- `scripts/run-doc-qa.sh || true`
- `scripts/batch-train-gate-check.sh || true`

## Validation Result

- Green.
- `git diff --check` passed.
- Focused Xcode tests passed: `ExternalSurfaceSnapshotTests` and
  `ExternalWidgetProjectionTests` executed 16 tests with 0 failures. Result
  bundle:
  `/Users/devan/Library/Developer/Xcode/DerivedData/Ambitions-clensfmdeeuxsueugpmolbvkzbxq/Logs/Test/Test-Ambitions-2026.05.06_10-57-04--0400.xcresult`.
- `scripts/build-local.sh` passed and generated
  `output/logs/build-local-20260506-105756.log`.
- PFC14-targeted CQS privacy/security claim scans reported
  `CQS_PRIVACY_SECURITY_CLAIM_HITS=0`.
- `scripts/cqs-accessibility-motion-scan.sh || true` reported existing
  advisory hits across `Native/Ambitions`, including the touched widget
  projection accessibility label definition. PFC14 adds focused proof that stale
  widget accessibility output does not include private ambient text or IDs.
- `scripts/cqs-performance-budget-scan.sh || true` reported existing broad
  advisory hits across `Native/Ambitions`; no PFC14 touched file was identified.
- `scripts/run-doc-qa.sh || true` completed with advisory stale-guidance,
  deprecated-language, markdownlint backlog, and lychee 0 errors / 1 redirect.
  Logs:
  `docs/audits/doc-qa/20260506-105833-stale-guidance.log`,
  `docs/audits/doc-qa/20260506-105833-deprecated-language.log`,
  `docs/audits/doc-qa/20260506-105833-markdownlint.log`, and
  `docs/audits/doc-qa/20260506-105833-lychee.log`.
- `scripts/batch-train-gate-check.sh || true` completed with the expected
  working-tree Yellow hint before commit.

## Repairs Attempted

- Repaired stale/unavailable widget projection behavior so stale external
  snapshots cannot keep rendering ambient rows.

## Remaining Yellow Items

- Rendered widget gallery/device behavior remains unproven.
- Lock Screen/accessory rendering and manual VoiceOver remain unproven.
- Physical-device proof, App Store/TestFlight/release readiness, legal/privacy
  compliance, final privacy-label truth, and public accessibility conformance
  remain blocked.

## Red Classification

No Red. Entitlement/signing/project changes, new widget families, sensitive
widget data exposure, unsupported release claims, or rendered/device proof
claims without evidence would be Hard Red.

## Rollback Path

Revert the PFC14 commit to restore the prior widget projection behavior and
remove the PFC14 prompt/report/train-state updates. No entitlement, signing,
project, workflow, dependency, schema, or generated rollback is needed.

## Next Eligible Batch

PFC16 Live Activities Implementation And Tests.
