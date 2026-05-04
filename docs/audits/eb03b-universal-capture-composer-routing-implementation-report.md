# EB03B Universal Capture Composer Routing Implementation Report

<!-- markdownlint-disable MD013 -->

Date: 2026-05-03

Result: PASS WITH YELLOW

Starting HEAD: `96f37b85848081d6d28d93e36ba64791d0e7ee29`

Batch: EB03B Universal Capture Composer Routing Implementation

Global order: 075B

## Source Truth Read

- `docs/audits/eb03a-universal-capture-composer-routing-owner-map-report.md`
- `docs/audits/eb03-universal-capture-composer-routing-blocked-report.md`
- `docs/canon/Ambitions_4_0_External_Brain_Foundation_Index.md`
- `docs/canon/Ambitions_4_0_External_Brain_Cross_Kernel_Primitives_And_Dependencies.md`
- `Native/Ambitions/Features/Captures/CapturesScreen.swift`
- `Native/Ambitions/Features/Captures/CapturesViewModel.swift`
- `Native/Ambitions/Features/Captures/CaptureDraftRoutePreviewCard.swift`
- `Native/Ambitions/Services/SmartAttachmentCaptureAdapter.swift`
- Focused Capture and Smart Attachment tests.

## Implementation Summary

EB03B implemented the first scoped Universal Capture composer/routing pass inside
the EB03A owner map. The Capture route preview now shows a compact local route
proof line that explains whether the route is evidence-backed, chosen by the
user, or still safely unplaced. The route proof is visible in the composer
preview card, included in preview visible-copy tests, and surfaced through the
Smart Attachment accessibility value when evidence exists.

The batch also added named Capture preview scenarios for Needs a Place, manual
route correction, high Dynamic Type, and a Reduce Motion review lane. The Reduce
Motion preview is named but does not override the system Reduce Motion
environment because that key is read-only in SwiftUI previews.

## Files Changed

- `Native/Ambitions/Features/Captures/CapturesViewModel.swift`
- `Native/Ambitions/Features/Captures/CaptureDraftRoutePreviewCard.swift`
- `Native/Ambitions/Features/Captures/CapturesScreen.swift`
- `Native/Ambitions/Services/SmartAttachmentCaptureAdapter.swift`
- `Native/AmbitionsTests/Captures/CapturesViewModelTests.swift`
- `Native/AmbitionsTests/Services/SmartAttachmentServiceTests.swift`
- `.codex/reports/current-run-state.md`
- `.codex/reports/current-batch-train-state.md`
- `docs/codex/BATCH_REGISTRY.md`
- `docs/codex/GLOBAL_FUTURE_BATCH_EXECUTION_ORDER.md`
- `docs/codex/batch-trains/EB01_EB40_EXTERNAL_BRAIN_FOUNDATION_TRAIN.md`
- This report.

## Boundary Proof

- App behavior changed: yes, narrowly inside Capture route-preview
  presentation and Smart Attachment accessibility value.
- Production Swift touched: yes.
- Routes/raw values changed: no.
- Persistence/schema changed: no.
- Top-level tabs changed: no.
- Dependencies/workflows/signing changed: no.
- Network/sync/account/cloud behavior changed: no.
- Production assets changed: no.

## Route Proof

Focused tests prove:

- Task route remains `Saved as Task · Today`.
- Weak input remains Needs a Place / Needs a Decision.
- Manual Task route is user-chosen and remains changeable.
- Proof attachment to a matching local goal includes local route evidence.
- Route proof avoids AI/confidence/cloud wording.

## Raw Representation Proof

EB03B did not change `CaptureKind`, `CaptureRoute`, `CaptureTriageStatus`, or
`SmartAttachmentRouteType` raw values. Existing focused tests for Capture
taxonomy and Smart Attachment model labels were preserved.

## Persistence Proof

EB03B did not change persistence schema, `CaptureRecord`, SwiftData mapping, or
repository behavior. Focused `CaptureServiceTests` and
`PersistenceRepositoryTests` passed after the Swift changes.

## Accessibility Evidence

- `CaptureDraftRoutePreviewCard` continues to combine children and expose an
  accessibility label, value, and hint.
- `SmartAttachmentCaptureDecision.accessibilityValue` now includes route
  evidence when evidence exists.
- The composer and route-choice accessibility identifiers remain unchanged.
- Human VoiceOver review was not run and is not claimed.

## Preview Evidence

Named Capture previews now include:

- `Capture Empty`
- `Capture Route Suggestions`
- `Capture Needs a Place`
- `Capture Manual Route`
- `Capture Dynamic Type`
- `Capture Reduce Motion`
- `Capture Receipt`
- `Capture Light`

Screenshots were not produced in EB03B.

## Reduce Motion Evidence

The Capture screen still reads `accessibilityReduceMotion` and uses
`theme.motion.animation(reduceMotion:emphasis:)` plus `DAVMotionPreset` for
composer state changes. A named Reduce Motion preview lane was added, but no
system Reduce Motion override is claimed because SwiftUI does not expose that
environment key as writable in this preview context.

## Dynamic Type Evidence

The route preview card keeps one-line route choice labels with
`minimumScaleFactor(0.8)`, multi-line route evidence uses text rows, and a named
`Capture Dynamic Type` preview sets `.dynamicTypeSize(.accessibility2)`.

## Validation Results

- `git diff --check`: PASS.
- Focused route/view-model tests:
  `xcodebuild test -project Ambitions.xcodeproj -scheme Ambitions -destination 'platform=iOS Simulator,name=iPhone 17' -only-testing:AmbitionsTests/SmartAttachmentServiceTests -only-testing:AmbitionsTests/CapturesViewModelTests | xcbeautify`
  PASS, 23 tests, 0 failures.
- Focused service/persistence tests:
  `xcodebuild test -project Ambitions.xcodeproj -scheme Ambitions -destination 'platform=iOS Simulator,name=iPhone 17' -only-testing:AmbitionsTests/CaptureServiceTests -only-testing:AmbitionsTests/PersistenceRepositoryTests | xcbeautify`
  PASS, 26 tests, 0 failures.
- `swift build || true`: PASS.
- `scripts/build-local.sh`: PASS.
- `scripts/eb-active-train-integration-gate.sh || true`: PASS.
- `scripts/eb-no-unsupported-claim-scan.sh || true`: advisory existing
  claim-boundary hits; no EB03B unsupported claim.
- `scripts/eb-no-5-version-drift-scan.sh || true`: advisory existing backlog;
  no EB03B 5.0 status claim.
- `scripts/no-fake-proof-gate.sh || true`: advisory existing backlog; EB03B
  does not claim screenshots, device proof, VoiceOver proof, Instruments,
  battery proof, production readiness, or release readiness.
- `scripts/canon-language-drift-scan.sh || true`: Yellow for the touched test
  guard string `AI confidence`; accepted because it is a negative assertion,
  not user-facing copy.
- `scripts/release-claim-safety-scan.sh || true`: advisory existing backlog;
  no EB03B release claim.
- `scripts/batch-train-gate-check.sh || true`: PASS with expected working-tree
  Yellow during validation.

## Reds Repaired

- Compile Red: attempted to set the read-only SwiftUI
  `accessibilityReduceMotion` preview environment key. Repaired by keeping the
  named Reduce Motion preview lane without overriding the read-only key.
- Test Red: Needs a Place route proof showed the internal evidence label before
  the safer explanatory detail. Repaired by prioritizing the safe Needs a Place
  explanation.

## Yellow Advisories

- Screenshots/rendered visual proof were not produced.
- Human/device/VoiceOver review was not run.
- Existing repo-wide claim/copy/docs advisory backlog remains.
- The touched `AI confidence` string is a negative test guard, not visible
  product copy.

## Rollback

If EB03B must be reverted, revert only the touched Capture UI files, the Smart
Attachment capture adapter, the two focused test files, this report, and the
EB03B train-state updates. Do not revert EB03A or unrelated completed DAV/EB
history.

## Next Eligible Batch

If this batch is committed and pushed, the next eligible batch is EB04 Capture
Classification And Clarification at global order 076.
