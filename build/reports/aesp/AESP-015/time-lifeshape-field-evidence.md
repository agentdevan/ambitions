# AESP-015 Evidence Packet

- Linear issue: AMB-437
- Batch: AESP-015
- Starting commit: `e3a1879c3cad1ef549ecfbce1bbe33393891b47b`
- Commit placeholder: not created yet

## Changed Files

- `Native/Ambitions/Features/Time/TimeScreen.swift`
- `Native/Ambitions/Features/Time/TimeLifeShapeField.swift`
- `Native/Ambitions/Features/Time/TimeLifeSuiteState.swift`
- `Native/Ambitions/Features/Time/TimeFeatureService.swift`
- `Native/Ambitions/Features/Time/TimeReflowDecisionState.swift`
- `Native/Ambitions/Features/Time/TimeFoundationCards.swift`
- `Native/AmbitionsTests/Runtime/StepCandidateFieldGeneratorTests.swift`
- `Native/AmbitionsTests/Time/TimeFeatureServiceTests.swift`

## Why These Files Changed

- `TimeScreen.swift`: elevated `TimeLifeShapeField` to the first loaded object after the top composition bar and removed the duplicate suite-card rendering from the primary stack.
- `TimeLifeShapeField.swift`: added compact support copy for calendar boundary, manual fallback, and trust state so the primary field stays inspectable without needing the duplicate suite card.
- `TimeLifeSuiteState.swift`: strengthened week-default LifeShape copy and support labels so the surface reads as open time, goal time, protected time, pressure, source state, and manual fallback.
- `TimeFeatureService.swift`: tightened Time copy to favor `step` language over `move` language where user-facing text changed, while keeping internal compatibility kinds intact.
- `TimeReflowDecisionState.swift`: updated the reflow decision option title and related copy from `Move later` to `Step later`.
- `TimeFoundationCards.swift`: updated timeline empty-state copy to use `step` language.
- `TimeFeatureServiceTests.swift`: added focused coverage for week-default LifeShape copy, accessibility narration, and reflow receipt/decision non-mutation language; updated existing copy assertions.
- `StepCandidateFieldGeneratorTests.swift`: repaired an existing long-running simulation gauntlet validation blocker by sharding the deterministic proof matrix into bounded XCTest methods; this was required to make the broader `AmbitionsTests` lane Green after the AESP-015 patch.

## Source Mapping

- LifeShape primacy and screen ordering: `TimeScreen.swift`
- Field-level accessibility and primary object narration: `TimeLifeShapeField.swift`
- Week-default capacity truth and manual fallback copy: `TimeLifeSuiteState.swift`
- Reflow receipt and step language: `TimeFeatureService.swift`, `TimeReflowDecisionState.swift`
- Timeline copy: `TimeFoundationCards.swift`
- Behavioral proof: `TimeFeatureServiceTests.swift`
- Validation repair: `StepCandidateFieldGeneratorTests.swift`

## Validation

### Verified

- `scripts/ambitions-xcode-benchmark.sh --status`
- `python3 scripts/ambitions-champion-coverage-check.py --batch AESP-015`
- `python3 scripts/ambitions-parallel-implementation-guard.py --phase pre --batch AESP-015 --prompt prompts/batches/AESP-015.md --batch-type source-changing --allow-yellow`
- `xcodegen generate`
- `make xcode-build-for-testing BATCH=AESP-015`
- `make xcode-focused-test BATCH=AESP-015 TEST=AmbitionsTests/TimeFeatureServiceTests`
- `make xcode-focused-test BATCH=AESP-015 TEST=AmbitionsTests/AppShellNavigationTests`
- `make xcode-focused-test BATCH=AESP-015 TEST=AmbitionsTests`
- `make xcode-focused-test BATCH=AESP-015 TEST=AmbitionsTests/StepCandidateFieldGeneratorTests`
- `python3 scripts/ambitions-parallel-implementation-guard.py --phase post --batch AESP-015 --prompt prompts/batches/AESP-015.md --changed-from e3a1879c3cad1ef549ecfbce1bbe33393891b47b --batch-type source-changing --allow-yellow`
- `git diff --check`

### Failed / Yellow

- None in the final Phase 04 validation set. Earlier broad and StepCandidate focused reruns failed because `StepCandidateFieldGeneratorTests/testSimulationGauntletCoversDeterministicScenarioMatrixAndWritesProofReport` exceeded the runner timeout. The harness was repaired by sharding the same deterministic matrix into bounded XCTest methods; latest StepCandidate and broad `AmbitionsTests` reruns passed.

### Not Verified

- Screenshots, physical device validation, release validation, TestFlight/App Store validation, legal/privacy signoff, performance proof, manual accessibility audit, and CI validation are not claimed.

### Blocked

- None in the scoped Time slice after Phase 04 validation.

### Human Follow-Up

- Screenshot review, manual accessibility audit, physical device validation, performance validation, release validation, CI validation, and privacy/legal signoff remain separate follow-up gates.

## Proof Boundary

- No release, device, TestFlight, App Store, performance, privacy, accessibility audit, or CI claim is made here.
- A StepCandidate focused failure occurred during Phase 04 and was repaired as a validation-harness blocker. This batch still makes only local source/test/evidence claims for the scoped Time/LifeShape owner plus the explicit harness repair needed to make validation Green.
- This batch preserves unrelated dirty worktree files and does not stage or modify them:
  - `.swiftpm/xcode/xcuserdata/devan.xcuserdatad/xcschemes/xcschememanagement.plist`
  - `docs/proof/amb-fe-be/moat-scenario-proof-98/same-intent-context-a.json`
  - `docs/proof/amb-fe-be/moat-scenario-proof-98/same-intent-context-b.json`
  - `prompts/batches/AESP-013.md`
  - `prompts/batches/AESP-014.md`
  - `prompts/batches/AESP-015.md`
