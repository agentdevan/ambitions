# IOS26-T04C-B06 Source Atlas You Inspection Surface

Status: Yellow
Date: 2026-05-23

## Scope

Installed a You-owned inspection surface for Source Atlas and Goal Knowledge under:

`You -> What Ambitions Knows -> Source Atlas & Goal Knowledge`

This proof is local-first and source-inspection focused. It is not release proof, public accessibility proof, device proof, or App Store readiness proof.

## Files Changed

- `Native/Ambitions/Domain/YouModels.swift`
- `Native/Ambitions/Features/You/YouFeatureService.swift`
- `Native/Ambitions/Features/You/YouScreen.swift`
- `Native/Ambitions/PreviewSupport/PreviewFixtures.swift`
- `Native/Ambitions/Runtime/SourceAtlasStepCandidateFieldBridge.swift`
- `Native/AmbitionsTests/Domain/SourceAtlasCapabilityPathCompositionModelsTests.swift`
- `Native/AmbitionsTests/Runtime/SourceAtlasRuntimeBridgeCoverageGauntletTests.swift`
- `Native/AmbitionsTests/Runtime/SourceAtlasRuntimeBridgeReplayTests.swift`
- `Native/AmbitionsTests/You/YouFeatureServiceTests.swift`
- `Native/AmbitionsUITests/AmbitionsUITests.swift`

## Inspection Surface

The You dashboard now projects a `sourceAtlasKnowledge` state with these sections:

- Goal Knowledge Sources
- Active Source Packs
- Needs Review
- Unsupported Goal Areas
- Recent Goal Compilations
- Path Sources
- Step Sources
- Corrections
- Replay Receipts

Each row carries:

- what Ambitions used
- why it was used
- source state
- freshness state
- risk state
- runtime use state
- review-needed state
- correction path
- review path

## Runtime Repair

During B06 validation, the full unit bundle exposed a Source Atlas bridge mismatch: unsupported fallback paths were being expanded into normal candidates. The bridge now forces fallback-only expansion for fallback graph paths and empty unsupported packs.

The coverage gauntlet assertion was updated so unsupported fallback candidates can retain their explicit impossible-plan risk while supported scenarios must not produce impossible timeline risk.

## Privacy And External Surface Boundary

The new surface is You-owned and local-first. External-surface snapshot validation passed, supporting the boundary that Source Atlas/Goal Knowledge details are not exposed through external snapshots.

Sensitive values are not added to logs or external surfaces by this batch.

## Accessibility Support

The UI rows include accessibility labels that combine title, source, freshness, runtime use, and review status. Dynamic Type and Reduce Motion behavior are supported by existing SwiftUI structure, but manual accessibility verification was not performed.

## Validation

Passed:

- `scripts/ambitions-xcode-validate.sh --batch IOS26-T04C-B06 --lane build-for-testing`
  - `.codex/xcode-summaries/IOS26-T04C-B06/20260524T000555Z/build-for-testing-summary.json`
- `make xcode-focused-test BATCH=IOS26-T04C-B06 TEST=AmbitionsTests/SourceAtlasCapabilityPathCompositionModelsTests`
  - `.codex/xcode-summaries/IOS26-T04C-B06/20260523T233047Z/focused-test-summary.json`
- `make xcode-focused-test BATCH=IOS26-T04C-B06 TEST=AmbitionsTests/SourceAtlasRuntimeBridgeReplayTests`
  - `.codex/xcode-summaries/IOS26-T04C-B06/20260523T233316Z/focused-test-summary.json`
- `make xcode-focused-test BATCH=IOS26-T04C-B06 TEST=AmbitionsTests/YouFeatureServiceTests`
  - `.codex/xcode-summaries/IOS26-T04C-B06/20260524T000841Z/focused-test-summary.json`
- `make xcode-focused-test BATCH=IOS26-T04C-B06 TEST=AmbitionsTests/ExternalSurfaceSnapshotTests`
  - `.codex/xcode-summaries/IOS26-T04C-B06/20260523T233828Z/focused-test-summary.json`
- `make xcode-focused-test BATCH=IOS26-T04C-B06 TEST=AmbitionsTests/SourceAtlasRuntimeBridgeCoverageGauntletTests`
  - `.codex/xcode-summaries/IOS26-T04C-B06/20260523T235331Z/focused-test-summary.json`
- `make xcode-focused-test BATCH=IOS26-T04C-B06 TEST=AmbitionsTests`
  - `.codex/xcode-summaries/IOS26-T04C-B06/20260523T235814Z/focused-test-summary.json`

Not Green:

- `make xcode-focused-test BATCH=IOS26-T04C-B06 TEST=AmbitionsUITests` did not produce a clean current pass in this run. The attempted lane hit existing UI harness failures and then later collided when parallel wrapper runs wrote the same timestamped result path.
- Manual VoiceOver, Dynamic Type, Reduce Motion, real-device, screenshot, and release validation were not performed.

## Claims Allowed

- You contains a Source Atlas & Goal Knowledge inspection projection.
- The surface exposes source, freshness, risk, runtime-use, review, correction, and replay receipt information.
- Source Atlas unsupported fallback expansion is deterministic and unit-tested.
- Unit and external snapshot validation passed for this batch after repair.

## Claims Forbidden

- Full UITest Green.
- Public accessibility verification.
- Physical-device proof.
- Release readiness, TestFlight readiness, or App Store readiness.
- Complete production Source Atlas coverage for all real-world goal areas.

## Yellow Owner And Gate

Owner: next IOS26 UI validation owner.

Reason: source, unit, replay, gauntlet, and external-surface proof passed, but the UI harness did not produce a clean current pass and manual accessibility proof is absent.

Gate: before claiming Green for the You inspection surface, rerun the relevant `AmbitionsUITests` lane serially, capture a current screenshot or simulator proof for the You row/sheet, and record manual accessibility status separately.
