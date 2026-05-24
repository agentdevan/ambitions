# Goal Relevance Scanner

Batch: `IOS26-T04D-B02`

## Contract

- `GoalRelevanceScan` is a deterministic local value model for capture-to-goal relevance.
- It records:
  - `captureID`
  - `scannedGoalIDs`
  - `highConfidenceMatches`
  - `mediumConfidenceMatches`
  - `weakMatches`
  - `rejectedMatches`
  - `relevanceReasons`
  - `noMatchReason`
  - `forcedAttachmentBlocked`
- High-confidence matches are suggested, but automatic attachment is blocked until explicit user approval.
- Medium-confidence matches stay standalone and expose a suggestion.
- Weak matches stay standalone and are treated as future context.
- No-match captures keep an explanation so the capture remains useful.

## Inputs Used

- `CaptureSemanticExtraction.goalDomainHints`
- activity classification
- proof / blocker / recovery signals
- capture object text
- local goal candidates from Smart Attachment
- optional correction input for testable ranking changes

## Notes

- This batch keeps the scanner local-only.
- No cloud, analytics, or hidden profiling behavior was added.
- The current proof is source and test based only; it is not device, accessibility, or release proof.

## Validation

- Passed: `git diff --check -- Native/Ambitions/Domain/GoalRelevanceScan.swift Native/Ambitions/Domain/SmartAttachmentModels.swift Native/Ambitions/Domain/SmartAttachmentPlacementPreview.swift Native/Ambitions/Services/CaptureService.swift Native/Ambitions/Services/SmartAttachmentCaptureAdapter.swift Native/Ambitions/Services/SmartAttachmentService.swift Native/AmbitionsTests/Capture/CaptureViewModelTests.swift Native/AmbitionsTests/Domain/GoalRelevanceScanTests.swift Native/AmbitionsTests/Services/SmartAttachmentServiceTests.swift build/reports/capture-runtime-bridge/goal-relevance-scanner.md`
- Passed: `make xcode-focused-test BATCH=IOS26-T04D-B02 TEST=AmbitionsTests`
  - Summary: `.codex/xcode-summaries/IOS26-T04D-B02/20260524T013204Z/validate-summary.json`
  - Focused summary: `.codex/xcode-summaries/IOS26-T04D-B02/20260524T013208Z/focused-test-summary.json`
- Yellow: `make xcode-focused-test BATCH=IOS26-T04D-B02 TEST=AmbitionsUITests`
  - Log: `.codex/xcode-logs/IOS26-T04D-B02/20260524T013748Z/focused-test.log`
  - Observed existing UI suite failures:
    - `AmbitionsUITests.swift:536` in `testCapturePromotionOpensComposerWithSeededText`
    - `AmbitionsUITests.swift:405` in `testDemoGoalsAtlasLoadsCoreModules`
  - Owner: iOS UI harness / existing UI suite stability.
  - Safety reason: this batch changed deterministic domain/service routing and unit-tested Capture presentation copy; no top-level IA, persistence, cloud, analytics, or user-data migration changes were made.
  - No-claim boundary: this proof does not claim UI automation coverage, device proof, accessibility verification, release readiness, or App Store readiness.

## Closeout

Status: Yellow

Accepted Yellow rationale: deterministic source and unit-test proof passed for the goal relevance scanner, explicit approval gate, no-match explanation, and nil linked-goal behavior for suggested proof attachments. UI automation remains unproven because the focused UI lane failed in pre-existing shell/Goals/Capture test paths outside the scanner seam.

Claims allowed:
- Ambitions has a local deterministic goal relevance scan model for Capture routing.
- High-confidence proof-to-goal matches are suggested but not automatically linked in the `CreateCaptureRequest`.
- No-match scans preserve a visible explanation.

Claims forbidden:
- UI automation coverage for this batch.
- Device, accessibility, release, TestFlight, or App Store readiness.
- Automatic plan insertion or silent goal attachment.
