# Source Atlas Runtime Bridge Proof

Batch: `IOS26-T04C-B03`
Date: `2026-05-23`
Status: `Yellow - accepted`

## Yellow acceptance

- Owner: `iOS UI validation lane / Today shell UI test gate`
- Reason: source/runtime bridge work and unit proof are Green, while `AmbitionsUITests` remains blocked by the existing `shell.global-entry-button` wait pattern observed before this batch.
- Safety: the changed files do not modify shell IA, UI test selectors, top-level destinations, or user-facing navigation.
- No-claim boundary: this batch may claim Source Atlas path-to-step candidate runtime bridge proof only; it may not claim UI regression proof, accessibility verification, release readiness, or full app UI validation.
- Post-batch gate: repair the shared `AmbitionsUITests` shell wait failure before using UI validation as release evidence.

## What changed

- Added `SourceAtlasStepExpansionTrace` and related trace records in `Native/Ambitions/Domain/GoalEngine/StepCandidateFieldModels.swift`.
- Threaded Source Atlas expansion trace data through `CandidateGenerationContext`, `CandidateRankingTrace`, and `StepCandidateField`.
- Added `Native/Ambitions/Runtime/SourceAtlasStepCandidateFieldBridge.swift` to expand Source Atlas path composition into synthetic compiled steps and step candidates.
- Added focused trace and provenance tests in `Native/AmbitionsTests/Domain/StepCandidateFieldModelsTests.swift`.
- Added Source Atlas bridge coverage in `Native/AmbitionsTests/Domain/SourceAtlasCapabilityPathCompositionModelsTests.swift`.
- Added generator trace propagation coverage in `Native/AmbitionsTests/Runtime/StepCandidateFieldGeneratorTests.swift`.

## Verified claims

- Source Atlas path composition can expand into multiple step candidates with preserved provenance trace data.
- Selected path nodes, requirements, proof needs, starter seeds, and milestones are mapped into candidate-producing source steps.
- Candidate provenance survives through the ranking trace and field payload.
- Duplicate and unsupported cases still collapse into safe fallback behavior rather than inventing unsupported action claims.
- Source Atlas trace payloads remain codable and preserve the expected structured fields.

## Validation run

- `xcodegen generate`
- `make xcode-focused-test BATCH=IOS26-T04C-B03 TEST=AmbitionsTests/StepCandidateFieldModelsTests`
- `make xcode-focused-test BATCH=IOS26-T04C-B03 TEST=AmbitionsTests/StepCandidateFieldGeneratorTests`
- `make xcode-focused-test BATCH=IOS26-T04C-B03 TEST=AmbitionsTests/SourceAtlasCapabilityPathCompositionModelsTests`
- `make xcode-focused-test BATCH=IOS26-T04C-B03 TEST=AmbitionsTests`
- `make xcode-focused-test BATCH=IOS26-T04C-B03 TEST=AmbitionsUITests`

## Validation results

- `AmbitionsTests/StepCandidateFieldModelsTests`: passed
- `AmbitionsTests/StepCandidateFieldGeneratorTests`: passed
- `AmbitionsTests/SourceAtlasCapabilityPathCompositionModelsTests`: passed
- `AmbitionsTests`: passed
- `AmbitionsUITests`: hit an existing UI lane failure in `AmbitionsUITests.swift:160` and the log also shows the familiar `shell.global-entry-button` wait pattern before the build was interrupted

## Claim boundaries

- No release-readiness claim.
- No accessibility proof claim.
- No device proof claim.
- No performance proof claim.
- No privacy/legal approval claim.
- No UI feature-shipped claim beyond the source/runtime bridge proof.

## Rollback note

- Roll back only the files touched by this batch if the bridge needs to be reverted:
  - `Native/Ambitions/Domain/GoalEngine/StepCandidateFieldModels.swift`
  - `Native/Ambitions/Runtime/StepCandidateFieldGenerator.swift`
  - `Native/Ambitions/Runtime/SourceAtlasStepCandidateFieldBridge.swift`
  - `Native/AmbitionsTests/Domain/StepCandidateFieldModelsTests.swift`
  - `Native/AmbitionsTests/Runtime/StepCandidateFieldGeneratorTests.swift`
  - `Native/AmbitionsTests/Domain/SourceAtlasCapabilityPathCompositionModelsTests.swift`
