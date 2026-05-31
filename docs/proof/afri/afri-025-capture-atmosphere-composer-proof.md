# AFRI-025 Capture Atmosphere Composer Proof

Status: Green with Yellow UI-smoke boundary
Issue: AMB-377 / AFRI-025
Date: 2026-05-31

## Scope

AFRI-025 strengthens the existing Capture surface around the active Atmosphere Composer product object. The patch does not add a new top-level destination, redesign Capture into an inbox, or introduce cloud, analytics, telemetry, hosted routing, or external intelligence.

The scoped implementation adds an inspectable route basis to the post-input composer preview so route reveal remains tied to local SourceRecord input, a local receipt seam, a ReplayTrace-style explanation, and You / What Ambitions knows inspection before saving.

## Source Changes

- `Native/Ambitions/Services/CaptureService.swift`
  - Adds derived Atmosphere Composer inspection summaries to `CaptureDraftRoutePreview`.
  - Keeps the summary computed from existing local-source, receipt, and resolver labels.
- `Native/Ambitions/Features/Capture/CaptureAtmosphereComposer.swift`
  - Surfaces a compact inspection line inside the existing route reveal strip.
  - Includes the full inspection basis in the route reveal accessibility value.
- `Native/AmbitionsTests/Capture/CaptureViewModelTests.swift`
  - Extends existing Atmosphere Composer route-preview coverage for SourceRecord, Receipt, ReplayTrace, You inspection, and compact visible summary.
  - Repairs the existing EB03B route-proof expectation to the current deterministic existing-goal evidence label.
- `docs/codex/concept-lock-registry.yml`
  - Adds AMB-377 as a narrow allowed batch for the existing `capture_routing` and `proof_receipt_replay` locks because the migrated issue explicitly requires Capture route reveal and inspectability.
  - Does not create a new canonical owner or weaken the existing no-claim boundaries.

## Proof

- Pre implementation guard:
  - `python3 scripts/ambitions-parallel-implementation-guard.py --phase pre --batch AMB-377 --prompt /tmp/AMB-377-AFRI-025-guard-prompt.md`
  - Result: Green after repairing the guard prompt to state SourceRecord, Receipt, ReplayTrace, and You inspection boundaries.
- Focused unit:
  - `xcodebuild test -project Ambitions.xcodeproj -scheme Ambitions -destination id=8ACCD665-4807-4102-B526-5A1AE20686A8 -only-testing:AmbitionsTests/CaptureViewModelTests/testF07ComposerPreviewUsesPlacementLanguageWithoutInboxFraming`
  - Result: Green, 1 test, 0 failures.
- Capture unit suite:
  - `xcodebuild test -project Ambitions.xcodeproj -scheme Ambitions -destination id=8ACCD665-4807-4102-B526-5A1AE20686A8 -only-testing:AmbitionsTests/CaptureViewModelTests`
  - Initial result: Red on stale EB03B expectation for existing goal-label proof text.
  - Repair: updated the existing assertion from token-list proof detail to the current deterministic existing-goal label.
  - Final result: Green, 19 tests, 0 failures.
- Capture UI smoke:
  - `xcodebuild test -project Ambitions.xcodeproj -scheme Ambitions -destination id=8ACCD665-4807-4102-B526-5A1AE20686A8 -only-testing:AmbitionsUITests/AmbitionsUITests/testPreviewBootstrapCaptureReviewSurfaceSurfacesPlacementApprovalAndFallback`
  - Result: Yellow. The test reaches `capture.screen`, but the existing `capture.quick-input` field is absent from the XCTest accessibility tree before the AFRI-025 route inspection assertion can run. A bounded selector and direct-route repair attempt did not resolve the lane and was reverted.
- Post implementation guard:
  - `python3 scripts/ambitions-parallel-implementation-guard.py --phase post --batch AMB-377 --prompt /tmp/AMB-377-AFRI-025-guard-prompt.md --changed-from HEAD --changed-path Native/Ambitions/Services/CaptureService.swift --changed-path Native/Ambitions/Features/Capture/CaptureAtmosphereComposer.swift --changed-path Native/AmbitionsTests/Capture/CaptureViewModelTests.swift --changed-path docs/proof/afri/afri-025-capture-atmosphere-composer-proof.md --changed-path docs/codex/concept-lock-registry.yml`
  - Initial result: Red because AMB-377 was not yet listed as an allowed batch for the existing `capture_routing` and `proof_receipt_replay` locks.
  - Repair: added AMB-377 as a narrow allowed batch for those existing locks.
  - Final result: Green.
- Hygiene:
  - `git diff --check`
  - Result: clean.
  - Static no-network scan matched existing privacy-boundary copy and proof-boundary text only; no new dependency was added.

## Boundaries

- This is local source, unit, and simulator proof only.
- This does not claim device, signed archive, TestFlight, App Store, release, legal, privacy-review, full accessibility audit, or CI proof.
- No new top-level IA, cloud AI, hosted backend, analytics, telemetry, or network dependency was added.
- The Capture UI smoke remains Yellow and does not provide route-reveal screenshot proof for AFRI-025.
