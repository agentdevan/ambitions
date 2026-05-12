# PK20 Closeout Report

## Scope
- Batch: PK20
- Title: Capture Service Extraction
- Patch lane: Spark bounded seam extraction (Phase 02)
- Allowed files changed:
  - `Native/Ambitions/Features/Captures/CapturesViewModel.swift`
  - `Native/Ambitions/Services/CaptureService.swift`
- Additional closeout artifact:
  - `docs/audits/pk20-batch-closeout-report.md`

## Source-truth and authority files inspected
- `prompts/batches/PK20.md`
- `docs/codex/batch-trains/PK00_PK41_PLATFORM_KERNEL_TRAIN.md`
- `Native/Ambitions/Features/Captures/CapturesViewModel.swift`
- `Native/Ambitions/Services/CaptureService.swift`
- `Native/Ambitions/Services/SmartAttachmentCaptureAdapter.swift`
- Targeted tests:
  - `Native/AmbitionsTests/Captures/CapturesViewModelTests.swift`
  - `Native/AmbitionsTests/Persistence/CaptureServiceTests.swift`
  - `Native/AmbitionsTests/Domain/CaptureModelsTests.swift`

## Implemented change summary
- Extracted draft-route decision and route-preview composition out of `CapturesViewModel` into new capture-owned seam:
  - Added `CaptureDraftRouteService` to `Native/Ambitions/Services/CaptureService.swift`.
  - Updated `CapturesViewModel` to inject/use `CaptureDraftRouteService`.
  - Kept behavior/placement language and local-only route handling in service seam.
  - Preserved existing UI/UX contract inputs for preview copy and route proof/correction semantics.

## Validation
- `git status --short`
- `git diff --check`
- `make prompt-audit || true`
- `make batch-self-check`
- `xcodegen generate`
- `scripts/ambitions-xcode-validate.sh --batch PK20 --lane focused-test --test CapturesViewModelTests`
- `scripts/ambitions-xcode-validate.sh --batch PK20 --lane focused-test --test CaptureServiceTests`
- `scripts/ambitions-xcode-validate.sh --batch PK20 --lane focused-test --test CaptureModelsTests`
- `scripts/codex-forbidden-claim-scan.sh Native/Ambitions/Features/Captures/CapturesViewModel.swift Native/Ambitions/Services/CaptureService.swift 2>/dev/null || true`

## Results
- `make prompt-audit` returned **YELLOW** due template/eval prompt metadata classification, no failure path.
- `make batch-self-check` returned **GREEN**.
- `git diff --check` returned clean.
- `xcodegen generate` succeeded.
- All three focused validations reported: **`xcode validation passed`**.
- forbidden-claim scan returned: **no blocking hits**.

## Phase 03 Review Addendum
- GPT-5.5 review found one repair item: `CaptureDraftRouteService` lived in `Services` while the preview DTOs it returned were still owned by `CapturesViewModel.swift`.
- Repair applied inside the approved PK20 seam: moved `CaptureDraftRouteChoice` and `CaptureDraftRoutePreview` into `CaptureService.swift` so the extracted service owns its returned route-preview DTOs.
- Behavior and user-facing copy are unchanged.
- Validation was rerun after this repair by Phase 03.

## EFC applicability
- PK20 declares EFC proof applicability; no EFC-specific runtime assertions added in this phase.
- This patch is seam-local service extraction and does not introduce additional EFC obligations beyond existing batch scope.

## Claims not made
- No release readiness, CI green, accessibility proof, privacy/legal approval, performance, App Store, TestFlight, production, or device-signoff claims were made.

## Risks / blocked items
- No blocking issues identified in scoped validation.
- No dirty-state gate triggered in this phase.

## Rollback
- Per phase scope, revert only:
  - `Native/Ambitions/Features/Captures/CapturesViewModel.swift`
  - `Native/Ambitions/Services/CaptureService.swift`

## Next handoff
- Continue to PK21 per batch train order when owner allows continuation.
