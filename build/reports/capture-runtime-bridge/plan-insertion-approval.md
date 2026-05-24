# Plan Insertion Approval

Batch: `IOS26-T04D-B03`

## Contract

- `PlanInsertionCandidate` is a local value model derived from scheduled capture text.
- It surfaces:
  - `captureID`
  - `title`
  - `proposedStart`
  - `proposedEnd`
  - `timeConfidence`
  - `scheduleImpact`
  - `conflictStatus`
  - `affectsProtectedTime`
  - `requiresCalendarPermission`
  - `requiresUserApproval`
  - `approvalOptions`
- The candidate proposes a Time item but does not apply a schedule mutation.
- Calendar writes remain explicitly gated and are not executed here.
- Approval options preserve:
  - `Decide later`
  - `Save as context`
  - `Attach to goal`
  - `Add to Time`
  - `Change time`
  - `Do not use for planning`

## Surface Notes

- The capture preview now shows the plan insertion candidate alongside the existing route review.
- The approval copy surfaces:
  - time ambiguity
  - schedule impact
  - protected-time status
  - calendar-permission status
- The UI copy stays local-first and does not claim any calendar write, sync, or mutation behavior.

## Validation

- Passed: `git diff --check -- Native/Ambitions/Domain/PlanInsertionCandidate.swift Native/Ambitions/Domain/SmartAttachmentModels.swift Native/Ambitions/Domain/SmartAttachmentPlacementPreview.swift Native/Ambitions/Services/SmartAttachmentService.swift Native/Ambitions/Services/CaptureService.swift Native/Ambitions/Features/Capture/CaptureDraftRoutePreviewCard.swift Native/Ambitions/Features/Capture/CaptureAtmosphereComposer.swift Native/AmbitionsTests/Domain/PlanInsertionCandidateTests.swift Native/AmbitionsTests/Services/SmartAttachmentServiceTests.swift Native/AmbitionsTests/Capture/CaptureViewModelTests.swift`
- Passed: `make xcode-focused-test BATCH=IOS26-T04D-B03 TEST=AmbitionsTests`
  - Summary: `.codex/xcode-summaries/IOS26-T04D-B03/20260524T022158Z/validate-summary.json`
  - Focused summary: `.codex/xcode-summaries/IOS26-T04D-B03/20260524T022202Z/focused-test-summary.json`
- Passed: `make xcode-focused-test BATCH=IOS26-T04D-B03 TEST=AmbitionsUITests`
  - Summary: `.codex/xcode-summaries/IOS26-T04D-B03/20260524T022720Z/validate-summary.json`
  - Focused summary: `.codex/xcode-summaries/IOS26-T04D-B03/20260524T022724Z/focused-test-summary.json`

## Closeout

Status: Green

Verified:
- Candidate model exists and is local-only.
- Approval-gated Time copy appears in the capture preview path.
- Focused unit and UI validation passed.

Not verified:
- Device proof.
- Accessibility proof beyond the existing focused UI harness.
- Release/TestFlight/App Store proof.
- Any real calendar write or schedule mutation.

Claims allowed:
- Scheduled capture text can produce a proposed Time candidate without committing schedule changes.
- The UI surfaces approval options and safety status before anything is applied.

Claims forbidden:
- Silent schedule or calendar mutation.
- Calendar write execution.
- Release readiness claims.
