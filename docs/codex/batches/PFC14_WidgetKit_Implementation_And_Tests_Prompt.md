# PFC14 WidgetKit Implementation And Tests Prompt
<!-- markdownlint-disable MD013 -->

Status: Complete / Green as bounded widget projection hardening and tests.
Date: 2026-05-06
Train: PFC01-PFC40 Platform / Framework / Compliance Completion Train
Owner: Widgets / Platform / Privacy

## Purpose

Implement or repair the existing WidgetKit path so widgets keep stale,
unavailable, privacy, routing, accessibility, and external-surface boundaries
aligned with PFC13. This batch may touch the existing widget projection and
focused widget tests only where needed.

PFC14 does not claim rendered widget gallery proof, physical-device proof, App
Store readiness, TestFlight readiness, release readiness, public accessibility
conformance, legal/privacy compliance, or final privacy-label truth.

## Source Truth

Read before execution:

- `docs/canon/Ambitions_WidgetKit_Strategy_And_Object_Map.md`
- `docs/audits/pfc13-widgetkit-strategy-object-map-report.md`
- `docs/audits/pfc12-app-groups-shared-storage-boundary-report.md`
- `Native/Ambitions/ExternalSnapshots/ExternalWidgetProjection.swift`
- `Native/AmbitionsWidgetExtension/NextStepWidget.swift`
- `Native/AmbitionsTests/App/ExternalWidgetProjectionTests.swift`
- `Native/AmbitionsTests/App/ExternalSurfaceSnapshotTests.swift`

## Allowed Files

- `Native/Ambitions/ExternalSnapshots/ExternalWidgetProjection.swift`
- `Native/AmbitionsWidgetExtension/NextStepWidget.swift`
- `Native/AmbitionsTests/App/ExternalWidgetProjectionTests.swift`
- `Native/AmbitionsTests/App/ExternalSurfaceSnapshotTests.swift`
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

## Forbidden Files

- Entitlements, signing, provisioning, project files, workflows, dependencies,
  privacy manifests, persistence schema, sync/account/backend runtime, AI/LDI
  runtime, new top-level destinations, new widget families without strategy
  update, App Store Connect state, and release/legal/privacy readiness claims.

## Required Acceptance

- Widgets do not invite action from stale or unavailable snapshots.
- Sensitive detail remains hidden by default.
- Widget deep links continue to use safe widget-origin routes.
- Widget projection tests cover stale/unavailable/privacy behavior.
- Build/test evidence proves the existing widget extension still compiles.
- Rendered widget gallery/device proof remains Yellow-owned, not claimed.

## Required Validation

Run:

- `git status --short`
- `git diff --check`
- focused widget/external-surface tests
- `scripts/build-local.sh`
- `scripts/cqs-privacy-security-claim-scan.sh <touched PFC14 docs/source> || true`
- `scripts/cqs-accessibility-motion-scan.sh || true`
- `scripts/cqs-performance-budget-scan.sh || true`
- `scripts/run-doc-qa.sh || true`
- `scripts/batch-train-gate-check.sh || true`

## Closeout

Close Green if scoped widget behavior is implemented and tested, build proof
passes, no forbidden files are touched, and remaining rendered/device/App Store
proof is explicitly Yellow-owned.
