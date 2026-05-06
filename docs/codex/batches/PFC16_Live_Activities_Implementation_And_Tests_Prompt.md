# PFC16 Live Activities Implementation And Tests Prompt
<!-- markdownlint-disable MD013 -->

Status: Complete / Green as bounded Live Activity source hardening and tests.
Date: 2026-05-06
Train: PFC01-PFC40 Platform / Framework / Compliance Completion Train
Owner: Live Activities / Platform / Privacy

## Purpose

Implement or repair the existing ActivityKit surface so the allowed `Active Step
Focus Window` candidate stays bounded, privacy-safe, source-testable, and
honest about proof limits.

PFC16 does not approve new Live Activity candidates, entitlements, signing,
project wiring, release readiness, App Store readiness, TestFlight readiness,
physical-device proof, public accessibility conformance, legal/privacy
compliance, or final privacy-label truth.

## Source Truth

Read before execution:

- `docs/canon/Ambitions_Live_Activities_ActivityKit_Strategy.md`
- `docs/audits/pfc15-live-activities-activitykit-strategy-report.md`
- `docs/canon/design/external-surfaces-contract.md`
- `docs/widget-live-activity-manual-testing.md`
- `Native/Ambitions/ExternalSnapshots/NextStepActivityAttributes.swift`
- `Native/Ambitions/Notifications/NextStepLiveActivityService.swift`
- `Native/AmbitionsWidgetExtension/NextStepLiveActivityWidget.swift`
- `Native/AmbitionsTests/App/ExternalSurfaceSnapshotTests.swift`

## Allowed Files

- `Native/Ambitions/ExternalSnapshots/NextStepActivityAttributes.swift`
- `Native/Ambitions/Notifications/NextStepLiveActivityService.swift`
- `Native/AmbitionsWidgetExtension/NextStepLiveActivityWidget.swift`
- `Native/AmbitionsTests/App/ExternalSurfaceSnapshotTests.swift`
- PFC16 prompt/report and train-state docs

## Forbidden Files

- Entitlements, signing, provisioning, project files, workflows, dependencies,
  persistence schema, sync/account/backend runtime, AI/LDI runtime, new
  top-level destinations, new Live Activity candidates, App Store Connect state,
  release/legal/privacy readiness claims, and physical-device/public
  accessibility claims.

## Required Acceptance

- Live Activity state ends when no concrete goal/step reference exists.
- Stale or unavailable state cannot render private ambient title/detail copy.
- Spoken/accessibility summary uses the same redacted state as visible content.
- Deep links stay on `origin=live_activity` safe routes.
- Build/test evidence proves the existing ActivityKit code still compiles.
- Rendered Lock Screen / Dynamic Island and device proof remain Yellow-owned.

## Required Validation

Run:

- `git status --short`
- `git diff --check`
- focused Live Activity / external-surface tests
- `scripts/build-local.sh`
- relevant CQS scans `|| true`
- `scripts/run-doc-qa.sh || true`
- `scripts/batch-train-gate-check.sh || true`

## Closeout

Close Green if scoped source behavior is implemented and tested, build proof
passes, no forbidden files are touched, and remaining rendered/device/App Store
proof is explicitly Yellow-owned.
