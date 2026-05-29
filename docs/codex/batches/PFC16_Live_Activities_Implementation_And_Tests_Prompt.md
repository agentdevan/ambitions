# PFC16 Live Activities Implementation And Tests Prompt

<!-- AMB-291-CANON-HYGIENE-HEADER: BEGIN -->

> Canon hygiene status: **execution-work-order-needs-sequencing**
> AMB-291 note: This batch/prompt is a work-order artifact and must be sequenced before execution.
> Active authority: `docs/truth/*`, `docs/codex/GLOBAL_BATCH_SEQUENCE_AUTHORITY.json`, and `docs/codex/IOS26_FLAGSHIP_TRAIN_MANIFEST.yml`.
> Before using this file for implementation, run `make change-impact-check` and follow `docs/ops/change-protocol/implementation-prompt-template.md`.
> Resolution classes: authority-rewrite, merge-overlap
> Dispositions: merge-or-sequence-file-ownership, rewrite-authority-reference

<!-- AMB-291-CANON-HYGIENE-HEADER: END -->
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
