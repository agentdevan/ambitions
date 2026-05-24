# Future-Proof Context Storage

Batch: `IOS26-T04D-B04`

## Scope

Implemented the bounded future-proof capture context slice only:

- added `FutureProofContextCandidate`
- added runtime factoring candidate classification for unmatched captures
- surfaced future-proof context inside `You -> What Ambitions Knows`
- persisted future-proof context in `LifeContextBundle`
- added focused unit and repository coverage

## Files Changed

- `Native/Ambitions/Domain/FutureProofContextCandidate.swift`
- `Native/Ambitions/Domain/LifeContextModels.swift`
- `Native/Ambitions/Features/You/YouFeatureService.swift`
- `Native/AmbitionsTests/Persistence/LifeContextRepositoryTests.swift`
- `Native/AmbitionsTests/Services/SmartAttachmentServiceTests.swift`
- `Native/AmbitionsTests/You/YouFeatureServiceTests.swift`

## Behavior Implemented

- Unmatched captures now classify into deterministic local future-proof context candidates.
- The classifier covers:
  - pickleball -> activity history / fitness-social context
  - YMCA open court -> facility access
  - mountain bike trail closed -> access constraint
  - ankle hurt -> recovery constraint, review gated
  - worked late again -> schedule drift / capacity signal
  - guitar lesson weekly -> recurring commitment / skill context
- Sensitive runtime use stays off until reviewed.
- Paused or deleted context remains excluded from runtime projection.
- Future-proof context is visible in You using the existing source, freshness, runtime-use, and control patterns.

## Validation

Passed:

- `git diff --check -- Native/Ambitions/Domain/FutureProofContextCandidate.swift Native/Ambitions/Domain/LifeContextModels.swift Native/Ambitions/Features/You/YouFeatureService.swift Native/AmbitionsTests/Persistence/LifeContextRepositoryTests.swift Native/AmbitionsTests/Services/SmartAttachmentServiceTests.swift Native/AmbitionsTests/You/YouFeatureServiceTests.swift`
- `make xcode-focused-test BATCH=IOS26-T04D-B04 TEST=AmbitionsTests`

Failed:

- `make xcode-focused-test BATCH=IOS26-T04D-B04 TEST=AmbitionsUITests`
  - The UI lane failed in existing bootstrap coverage:
    - `testPreviewBootstrapExposesCanonicalFiveTabShellAndSecondarySurfaces`
    - `testPreviewBootstrapTodayShowAnotherOpensReplacementSheetAndAppliesSelection`
  - The failure surfaced at `Native/AmbitionsUITests/AmbitionsUITests.swift:160` with an `XCTAssertTrue` failure on `shell.global-entry-button`.

Not run:

- additional targeted UI repair lanes
- device or accessibility proof

## Claims

Allowed:

- future-proof context candidates persist locally
- allowed context is visible in You
- future-proof context is review-aware and runtime-gated

Forbidden:

- release readiness
- UI-suite green status
- accessibility proof
- privacy approval
- device proof

## Rollback

Rollback remains path-limited to the files listed above plus this proof note.
