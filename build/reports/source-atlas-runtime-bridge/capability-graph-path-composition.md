# IOS26-T04C-B02 Capability Graph Path Composition

Status: Yellow - source/runtime/unit-test proof Green; UI validation blocked
Date: 2026-05-23
Batch: IOS26-T04C-B02

## Scope

This artifact records the scoped B02 repair for composing Source Atlas capability paths from selected path overlays, role overlays, Life Context, and the `PersonalizationFactorLedger`.

The repair keeps Ambitions local-first and deterministic. It does not introduce cloud, LLM, analytics, hosted backend, or top-level IA changes.

## Capability Graph Proof

- `SourceAtlasRequirementProjection` extracts requirement IDs, hard/soft requirements, prerequisites, equipment, skills, proof needs, blockers, accelerators, deadline-sensitive items, and Life Context source freshness.
- `SourceAtlasCapabilityPath` records graph ID, selected nodes, selected edges, selected path overlays, selected role overlays, traversal trace, blocked nodes, stale nodes, and missing source nodes.
- Selected path overlay traversal is bounded to the selected overlay node set. Role overlays can contribute matching/scoring context, but they no longer expand a selected path overlay into a whole-graph traversal.
- Missing target nodes, stale edges/nodes, and blocked review-required nodes remain represented in traversal state instead of being silently ignored.

## Path Composition Proof

- `PersonalPathComposition` preserves all candidate path instances, the selected path, rejected paths, path tradeoffs, optional alternative path set, and explanation projection.
- `PlanSkeleton` emits milestones, phases, weekly cadence, proof moments, review moments, recovery windows, risk flags, and feasibility band.
- Life Context opportunity anchors use both anchor title and detail for path scoring, so facility access changes selected path.
- Missing equipment is detected by requiring equipment-title tokens to be covered by opportunity anchors; generic access text alone is not enough.
- `PersonalizationFactorLedger` contributes deterministic scoring and explanation inputs without demographic templates or sensitive-data logging.

## Validated Scenarios

- Same goal plus same Life Context produces deterministic composition.
- Same goal plus different Life Context changes selected path composition.
- Blocked prerequisite moves setup before execution and remains visible in traversal.
- Missing equipment creates a setup-first path.
- Facility access changes path selection.
- Eligibility pathway changes path when materially relevant.

## Validation

Verified:

- `xcodegen generate`
- `swiftc -parse Native/Ambitions/Domain/SourceAtlasPackModels.swift Native/AmbitionsTests/Domain/SourceAtlasCapabilityPathCompositionModelsTests.swift`
- `swiftc -parse Native/Ambitions/Domain/ActionClosureReceiptModels.swift`
- `swiftc -parse Native/Ambitions/Domain/GoalEngine/StepCandidateFieldModels.swift Native/Ambitions/Runtime/StepCandidateFieldGenerator.swift`
- `swiftc -parse Native/Ambitions/Features/Today/TodayStepReplacementSheet.swift Native/Ambitions/Domain/GoalEngine/StepCandidateFieldModels.swift Native/Ambitions/Runtime/StepCandidateFieldGenerator.swift`
- `git diff --check`
- `make xcode-build-for-testing BATCH=IOS26-T04C-B02`
- `make xcode-focused-test BATCH=IOS26-T04C-B02 TEST=AmbitionsTests/SourceAtlasCapabilityPathCompositionModelsTests`
- `make xcode-focused-test BATCH=IOS26-T04C-B02 TEST=AmbitionsTests/SourceAtlasIntentMatchModelsTests`
- `make xcode-focused-test BATCH=IOS26-T04C-B02 TEST=AmbitionsTests/StepCandidateFieldGeneratorTests`
- `make xcode-focused-test BATCH=IOS26-T04C-B02 TEST=AmbitionsTests/TodayViewModelTests`
- `make xcode-focused-test BATCH=IOS26-T04C-B02 TEST=AmbitionsTests/ActionClosureReceiptModelsTests`
- `make xcode-focused-test BATCH=IOS26-T04C-B02 TEST=AmbitionsTests`

Focused XCTest proof:

- Source Atlas capability path composition summary: `.codex/xcode-summaries/IOS26-T04C-B02/20260523T182113Z/focused-test-summary.json`
- Source Atlas capability path composition log: `.codex/xcode-logs/IOS26-T04C-B02/20260523T182113Z/focused-test.log`
- Source Atlas capability path composition result bundle: `.codex/xcode-results/IOS26-T04C-B02/20260523T182113Z/focused-test.xcresult`
- Raw log result: `Executed 5 tests, with 0 failures`.
- Source Atlas intent match summary: `.codex/xcode-summaries/IOS26-T04C-B02/20260523T182305Z/focused-test-summary.json`
- Step candidate field summary: `.codex/xcode-summaries/IOS26-T04C-B02/20260523T180636Z/focused-test-summary.json`
- Today view model summary: `.codex/xcode-summaries/IOS26-T04C-B02/20260523T181912Z/focused-test-summary.json`
- Action closure receipt summary: `.codex/xcode-summaries/IOS26-T04C-B02/20260523T183435Z/focused-test-summary.json`
- Full unit suite summary: `.codex/xcode-summaries/IOS26-T04C-B02/20260523T183648Z/focused-test-summary.json`
- Full unit suite log: `.codex/xcode-logs/IOS26-T04C-B02/20260523T183648Z/focused-test.log`
- Full unit suite raw log result: `Executed 1695 tests, with 0 failures`.

Failed / blocked:

- `make xcode-focused-test BATCH=IOS26-T04C-B02 TEST=AmbitionsUITests`
- Log: `.codex/xcode-logs/IOS26-T04C-B02/20260523T184044Z/focused-test.log`
- Result bundle path was started at `.codex/xcode-results/IOS26-T04C-B02/20260523T184044Z/focused-test.xcresult`.
- The UI lane hung while searching for `TodayStartHereShowAnother` / `Show another` in `AmbitionsUITests.testPreviewBootstrapTodayShowAnotherOpensReplacementSheetAndAppliesSelection`.
- The run was terminated after repeated XCTest lookup retries; no UI-test pass is claimed.

## Repair Notes

- Source Atlas invalid-pack rejection now includes the runtime-blocked reason expected by the intent matcher contract.
- Step candidate fallback validity is preserved before non-executable blocking, and lighter impact summaries include the lowercase `lighter` token required by deterministic proof.
- Today replacement sheet copy exposes `Original recommendation` and `Timeline` in aggregate state copy, and the shorter option keeps the deadline label when only approval/scope review is present.
- Action receipt changed facts now preserve builder semantic order after dedupe so primary receipt facts appear before secondary preference-learning facts.
- Personalization factor ledger repair redacts sensitive runtime reasons and removes volatile source IDs / recommendation IDs from replay fingerprints.

## Boundaries

Not claimed:

- `AmbitionsUITests` Green.
- release readiness, TestFlight readiness, App Store readiness, device proof, accessibility conformance, privacy/legal approval, performance validation, or CI proof.

No iOS 26 API changes were added by this B02 repair.

## Yellow Item

Owner: UI validation / Today UI test harness.

Reason: `AmbitionsUITests` hung in the existing Today Show Another UI lookup path after the B02 source/runtime/unit proof was repaired.

No-claim boundary: B02 may claim source/runtime model proof and broad unit-test proof, but must not claim UI-test Green or visual/accessibility verification from this pass.

Gate: Repair or isolate `AmbitionsUITests.testPreviewBootstrapTodayShowAnotherOpensReplacementSheetAndAppliesSelection` before any train-level UI validation claim.
