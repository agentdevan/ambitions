# Source Atlas Match and Pack Selection

Batch: IOS26-T04C-B01

## Scope

Added value-only Source Atlas intent match and pack selection contracts in `Native/Ambitions/Domain/SourceAtlasIntentMatchModels.swift`.
Added focused proof tests in `Native/AmbitionsTests/Domain/SourceAtlasIntentMatchModelsTests.swift`.

## Intent Match Proof

- `Make varsity football` normalizes to `make-varsity-football`.
- The matcher records sports domain, football high-school pathway, varsity skill, and athlete role signals.
- `Release 3 songs by August` normalizes to `release-3-songs-by-august`.
- The matcher records creative domain, music release pathway, songs skill, and creator role signals.
- `Pay off $5,000 debt` normalizes to `pay-off-5000-debt`.
- The matcher records financial domain context and rejects high-risk advice packs from runtime use.
- Unknown goal text degrades to `goal-scaffold` and emits a compact clarification warning.

## Pack Selection Proof

- Safe football and music packs can be selected for runtime use.
- High-risk debt advice packs are rejected.
- Stale packs are rejected.
- Unsupported packs are rejected.
- `matchTrace` preserves rejected pack IDs and compact rejection reasons.
- `SourceAtlasPackSelection.canDriveRuntime` stays false when no safe pack is available and true when a safe pack is selected.

## Validation

Verified:

- `swiftc -typecheck -module-name Ambitions Native/Ambitions/Domain/LifeGraphEventLogModels.swift Native/Ambitions/Domain/SourceAtlasStoreModels.swift Native/Ambitions/Domain/SourceAtlasPackModels.swift Native/Ambitions/Domain/SourceAtlasQueryEngineModels.swift Native/Ambitions/Domain/SourceAtlasIntentMatchModels.swift`
- `swiftc -parse Native/AmbitionsTests/Domain/SourceAtlasIntentMatchModelsTests.swift`

Attempted but blocked:

- `make xcode-focused-test BATCH=IOS26-T04C-B01 TEST=AmbitionsTests`
- `make xcode-focused-test BATCH=IOS26-T04C-B01 TEST=AmbitionsUITests`

The wrapper lane stayed silent long enough to be unusable in this session, so I stopped it rather than claiming project-level test proof that was not produced.

## Residual Gap

- Xcode wrapper-based focused tests are not proven green yet.
- The source seam typechecks, but the batch still needs a successful repo-wrapper focused test run for full green closeout.
