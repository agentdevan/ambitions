# AFEP-012 Capture Staging Packet

Batch: `AFEP-012`
Scope: Multimodal Capture staging for `text`, `voice`, `image`, `share`, `proof`, and `context`

## What changed

- Added deterministic staged-input modeling in `Native/Ambitions/Domain/CaptureModels.swift`.
- Wired staged-input projections into runtime receipt and replay models in `Native/Ambitions/Domain/CaptureRuntimeReceipt.swift`.
- Projected staged-input policies into Capture draft preview rendering in `Native/Ambitions/Services/CaptureService.swift` and `Native/Ambitions/Features/Capture/CaptureDraftRoutePreviewCard.swift`.
- Added a You-side memory lens item that explains the Capture staging boundary in `Native/Ambitions/Features/You/YouFeatureService.swift`.

## Staging model

- Input kinds are modeled as `CaptureStagedInputKind`.
- Each kind projects to a deterministic `CaptureStagedInputProjection`.
- Each projection includes provenance, policy, route candidates, privacy/export/redaction/retention labels, and an accessibility review summary.
- Supported staged kinds are `text`, `voice`, `image`, `share`, `proof`, and `context`.

## Review posture

- Root Capture remains composer-first.
- Staging details are surfaced in preview and review depth, not as a new root feed.
- Deterministic route candidates stay inspectable before save.

## Validation

- `python3 scripts/ambitions-champion-coverage-check.py --batch AFEP-012` - GREEN
- `python3 scripts/ambitions-parallel-implementation-guard.py --phase pre --batch AFEP-012 --prompt prompts/batches/AFEP-012.md --batch-type source-changing --allow-yellow` - GREEN
- `xcodegen generate` - succeeded
- `make xcode-build-for-testing BATCH=AFEP-012` - succeeded
- `make xcode-focused-test BATCH=AFEP-012 TEST=AmbitionsTests/CaptureViewModelTests` - passed
- `make xcode-focused-test BATCH=AFEP-012 TEST=AmbitionsTests/CaptureRuntimeReceiptTests` - passed
- `make xcode-focused-test BATCH=AFEP-012 TEST=AmbitionsTests/CaptureModelsTests` - passed
- `make xcode-focused-test BATCH=AFEP-012 TEST=AmbitionsTests/AFEP004ExportPolicyTests` - passed
- `make xcode-focused-test BATCH=AFEP-012 TEST=AmbitionsTests/AccessibilityNutritionChecklistTests` - passed
- `make xcode-focused-test BATCH=AFEP-012 TEST=AmbitionsTests/YouFeatureServiceTests` - failed in wrapper execution due test-host instability after restart; selected tests passed in the log
- `python3 scripts/ambitions-parallel-implementation-guard.py --phase post --batch AFEP-012 --prompt prompts/batches/AFEP-012.md --changed-from 98f01a66137e2ded4307e35b45da7909a58836f4 --batch-type source-changing --allow-yellow` - GREEN
- `git diff --check` - clean

## Proof boundary

- Screenshot proof was not captured in this phase.
- State restoration proof was not captured in this phase.
- Accessibility conformance, privacy/legal approval, device proof, CI proof, and release readiness are not claimed here.
