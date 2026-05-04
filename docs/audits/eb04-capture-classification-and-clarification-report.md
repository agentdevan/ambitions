# EB04 Capture Classification And Clarification Report

<!-- markdownlint-disable MD013 -->

Date: 2026-05-03

Result: PASS WITH YELLOW

Starting HEAD: `c98b6767`

Batch: EB04 Capture Classification And Clarification

Global order: 076

## Source Truth Read

- `docs/codex/batches/EB04_Capture_Classification_And_Clarification_Prompt.md`
- `docs/audits/eb03a-universal-capture-composer-routing-owner-map-report.md`
- `docs/audits/eb03b-universal-capture-composer-routing-implementation-report.md`
- `docs/canon/Ambitions_4_0_External_Brain_Foundation_Index.md`
- `docs/canon/Ambitions_4_0_External_Brain_Cross_Kernel_Primitives_And_Dependencies.md`
- `Native/Ambitions/Services/SmartAttachmentService.swift`
- `Native/AmbitionsTests/Services/SmartAttachmentServiceTests.swift`

## Implementation Summary

EB04 added one bounded classification/clarification behavior to the existing
local Smart Attachment router. When a capture has multiple local route signals
and no safer direct route should be forced, the router now saves it to Needs a
Place and asks one compact clarification question: “What should this become
first?” The choices are bounded to the already-supported route types and the
capture remains private, local, and correctable.

Proof classification still attaches directly when matching local goal evidence
exists, so the new ambiguity branch does not weaken the EB03B route-proof lane.

## Files Changed

- `Native/Ambitions/Services/SmartAttachmentService.swift`
- `Native/AmbitionsTests/Services/SmartAttachmentServiceTests.swift`
- `.codex/reports/current-run-state.md`
- `.codex/reports/current-batch-train-state.md`
- `docs/codex/BATCH_REGISTRY.md`
- `docs/codex/GLOBAL_FUTURE_BATCH_EXECUTION_ORDER.md`
- `docs/codex/batch-trains/EB01_EB40_EXTERNAL_BRAIN_FOUNDATION_TRAIN.md`
- This report.

## Boundary Proof

- App behavior changed: yes, narrowly inside Smart Attachment classification.
- Production Swift touched: yes.
- UI files touched: no.
- Routes/raw values changed: no.
- Persistence/schema changed: no.
- Top-level tabs changed: no.
- Dependencies/workflows/signing changed: no.
- Network/sync/account/cloud behavior changed: no.
- Production assets changed: no.

## Classification Proof

Focused tests prove:

- Ambiguous local route signals ask one question instead of forcing a route.
- The ambiguous capture stays `Saved to Needs a Place`.
- Clarification choices stay bounded to supported route types.
- Manual choice still maps back to the expected `CreateCaptureRequest`.
- Proof with matching local goal evidence does not ask unnecessary
  clarification.

## Privacy And Trust Evidence

The new branch uses the existing Needs a Place fallback, local route choices,
and `privacyLevel: .privateItem`. It does not create durable memory, hidden
automation, external calls, calendar writes, account behavior, or cloud/sync
behavior.

## Accessibility Evidence

No UI or accessibility identifiers changed in EB04. The one-question
clarification flows through the existing Smart Attachment clarification model
and EB03B Capture preview/accessibility lane.

Human VoiceOver review was not run and is not claimed.

## Preview Evidence

No new previews were required because EB04 did not touch UI. The existing EB03B
`Capture Needs a Place` and `Capture Manual Route` preview lanes cover the
visible fallback and route-choice surface. Screenshots were not produced.

## Validation Results

- `git diff --check`: PASS.
- Focused Smart Attachment tests:
  `xcodebuild test -project Ambitions.xcodeproj -scheme Ambitions -destination 'platform=iOS Simulator,name=iPhone 17' -only-testing:AmbitionsTests/SmartAttachmentServiceTests | xcbeautify`
  PASS, 14 tests, 0 failures.
- `swift build || true`: PASS.
- `scripts/build-local.sh`: PASS.
- `scripts/eb-active-train-integration-gate.sh || true`: PASS.
- `scripts/eb-no-unsupported-claim-scan.sh || true`: advisory existing claim-boundary hits; no EB04 unsupported claim.
- `scripts/eb-no-5-version-drift-scan.sh || true`: advisory existing backlog; no EB04 5.0 status claim.
- `scripts/no-fake-proof-gate.sh || true`: advisory existing backlog; EB04 does not claim screenshots, device proof, VoiceOver proof, Instruments, battery proof, production readiness, or release readiness.
- `scripts/canon-language-drift-scan.sh || true`: GREEN for changed-file drift candidates; existing backlog remains advisory.
- `scripts/release-claim-safety-scan.sh || true`: advisory existing backlog; no EB04 release claim.

## Yellow Advisories

- Screenshots/rendered visual proof were not produced.
- Human/device/VoiceOver review was not run.
- Existing repo-wide claim/copy/docs advisory backlog remains.

## Reds

No EB04 Red remains.

## Rollback

Revert only `Native/Ambitions/Services/SmartAttachmentService.swift`,
`Native/AmbitionsTests/Services/SmartAttachmentServiceTests.swift`, this
report, and the EB04 train-state updates.

## Next Eligible Batch

If this batch is committed and pushed, the next eligible batch is EB05 Capture
Clusters Review Bundles And Open Loops at global order 077.
