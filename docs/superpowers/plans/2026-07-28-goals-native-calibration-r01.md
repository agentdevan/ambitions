# Goals Native Calibration R01 Implementation Plan

Status: active  
Start SHA: `e4a8260b5b7a776a0190c18efc33c7da9a70ceeb`  
Branch: `codex/goals-native-calibration-r01`  
Worktree: `/Users/devan/Documents/GitHub/ambitions/.worktrees/goals-native-calibration-r01`

## Changed-path envelope

New package source:

- `Packages/AmbitionsPresentation/Sources/AmbitionsNativeVisualFoundry/GoalsNativeCalibrationContent.swift`
- `Packages/AmbitionsPresentation/Sources/AmbitionsNativeVisualFoundry/GoalsNativeCalibrationFixture.swift`
- `Packages/AmbitionsPresentation/Sources/AmbitionsNativeVisualFoundry/GoalsNativeCalibrationJourneyState.swift`
- `Packages/AmbitionsPresentation/Sources/AmbitionsNativeVisualFoundry/GoalsNativeCalibrationGrammar.swift`
- `Packages/AmbitionsPresentation/Sources/AmbitionsNativeVisualFoundry/GoalsNativeCalibrationView.swift`
- `Packages/AmbitionsPresentation/Sources/AmbitionsNativeVisualFoundry/GoalsNativeCalibrationRootView.swift`
- `Packages/AmbitionsPresentation/Sources/AmbitionsNativeVisualFoundry/GoalsNativeCalibrationFocusedGoalView.swift`
- `Packages/AmbitionsPresentation/Sources/AmbitionsNativeVisualFoundry/GoalsNativeCalibrationRelationshipView.swift`
- `Packages/AmbitionsPresentation/Sources/AmbitionsNativeVisualFoundry/GoalsNativeCalibrationPathView.swift`
- `Packages/AmbitionsPresentation/Sources/AmbitionsNativeVisualFoundry/GoalsNativeCalibrationPreviews.swift`

New package tests:

- `Packages/AmbitionsPresentation/Tests/AmbitionsNativeVisualFoundryTests/GoalsNativeCalibrationFixtureTests.swift`
- `Packages/AmbitionsPresentation/Tests/AmbitionsNativeVisualFoundryTests/GoalsNativeCalibrationJourneyStateTests.swift`
- `Packages/AmbitionsPresentation/Tests/AmbitionsNativeVisualFoundryTests/GoalsNativeCalibrationPresentationTests.swift`

Fixture host:

- modify `Native/AmbitionsNativeFoundryHost/AmbitionsNativeFoundryHostApp.swift` only to select the Goals host from process arguments;
- add `Native/AmbitionsNativeFoundryHost/GoalsNativeFoundryHost.swift`;
- add `Native/AmbitionsNativeFoundryHostUITests/GoalsNativeCalibrationHostUITests.swift`;
- add `Native/AmbitionsNativeFoundryHostUITests/GoalsNativeCalibrationScreenshotCaptureUITests.swift`.

Documentation/evidence:

- this specification and plan;
- `docs/qa/evidence/2026-07-28-goals-native-calibration-r01/` required package.

No Today source, production Goals source, runtime, app entry, canon, generated canon, dependency, `Package.swift`, or `project.yml` change is planned. `project.yml` already includes the host source/test directories and the Foundry package product.

## Task 1 — Lock fixture and state contracts with failing tests

- [ ] Add fixture tests for exact family/Goal/Life Area/relationship/Path/Proof IDs and copy.
- [ ] Add state tests for sole Home expansion, non-ranking selection, non-mutating lens/Open Goal, typed routes, Path anchors/jumps, and exact restoration.
- [ ] Assert forbidden Today vocabulary, percentages, scores, ranks, and Receipts are absent from Goals visible content.
- [ ] Run the new tests and record the expected RED result before implementation.
- [ ] Implement immutable content, fixture, and value-semantic journey state until tests pass.

Commands:

```sh
swift test --package-path Packages/AmbitionsPresentation \
  --filter GoalsNativeCalibrationFixtureTests
swift test --package-path Packages/AmbitionsPresentation \
  --filter GoalsNativeCalibrationJourneyStateTests
```

Commit: `add Goals calibration fixture and journey state`.

## Task 2 — Build root and Linked Goal Lens

- [ ] Add presentation tests for one selected Goal, one attached lens, Home-only expansion, selection semantics, Open Goal action, dock ownership, and F01–F04 host variants.
- [ ] Run them RED.
- [ ] Implement Goals-local palette/type/action/marker primitives without extracting a global API.
- [ ] Implement compact Goals crown, Life Area passage, selected Goal anatomy, attached Linked Goal Lens, Goals-selected shell Peek, and Light/Dark previews.
- [ ] Add host variants for `gnc-f01` through `gnc-f04`.
- [ ] Render Light/Dark/selected/lens previews and repair only specification violations.
- [ ] Run focused package and host tests GREEN.

Commands:

```sh
swift test --package-path Packages/AmbitionsPresentation \
  --filter GoalsNativeCalibrationPresentationTests
xcodebuild -project Ambitions.xcodeproj -scheme AmbitionsNativeFoundryHost \
  -destination 'platform=iOS Simulator,id=396F4B4A-2DAD-4345-B26E-ABD2EF69BF5E' \
  -derivedDataPath /tmp/ambitions-goals-r01-derived \
  -only-testing:AmbitionsNativeFoundryHostUITests/GoalsNativeCalibrationHostUITests test
```

Commit: `build Goals root and Linked Goal Lens`.

## Task 3 — Build focused Goal and relationship depth

- [ ] Add failing route/presentation assertions for stable Goal identity, Home membership, truth, thread, next movement, Proof, schedule-fit, both relationship Goals/Life Areas, ownership, non-mutation, native Back, and restoration.
- [ ] Implement focused Goal and relationship views using the existing typed path.
- [ ] Add host variants `gnc-f05` and `gnc-f06`.
- [ ] Inspect native depth for Form/card/project-dashboard drift and repair.
- [ ] Run focused package/UI tests GREEN.

Commit: `build focused Goal and relationship depth`.

## Task 4 — Build Goal Path and accessibility transformation

- [ ] Add failing assertions for exact eight nodes/states, current default anchor, Start/Now/Next/Finish selection, truthful selected detail, Proof, and accessibility ordered equivalence.
- [ ] Implement standard horizontal lazy Path with native scrolling and selected detail.
- [ ] Implement accessibility-size vertical ordered Path and authored root/Lens recomposition.
- [ ] Add host variants `gnc-f07` and `gnc-f08` with accessibility identifiers and logical traversal.
- [ ] Verify 44-point targets, no clipped actions, no dock/content overlap, and native Back.
- [ ] Run focused package/UI tests GREEN.

Commit: `build Goal Path and accessibility passage`.

## Task 5 — Warm loop, Simulator screenshots, and contact sheets

- [ ] Record one initial preview launch, four root/Lens source-changing reloads, four focused/Path source-changing reloads, and one cached host build. Do not clean.
- [ ] Capture exactly F01–F08 from the fixture host on the selected Simulator/device configuration.
- [ ] Inspect each at full size, approximately 50%, and contact-sheet scale.
- [ ] Build `GNC-C01-full-matrix.png`.
- [ ] Build `GNC-C02-r14-cross-root-transfer.png` comparing only transferable grammar and labelling composition non-transfer.
- [ ] Validate nonzero dimensions, SHA-256, IDs, fixture ID, branch SHA, appearance/content size, and `production_baseline = false` metadata.

Commit: `package Goals native calibration evidence`.

## Task 6 — Evidence package

- [ ] Create all 14 required Markdown records, screenshot/contact metadata, and exact command log under `docs/qa/evidence/2026-07-28-goals-native-calibration-r01/`.
- [ ] Set `owner-review.md` to `READY_FOR_OWNER_REVIEW`; do not self-accept.
- [ ] Record inherited decisions without duplicating Today evidence.
- [ ] Record performance review, architecture assumptions, known limitations, physical-device obligations, and proof ceiling.
- [ ] Generate `changed-files.md` from actual Git paths.

## Task 7 — One final independent review

- [ ] Dispatch the fifth and final fresh subagent after implementation/evidence is complete.
- [ ] Review specification conformance, visual quality, native behavior, accessibility, authority, and Today-composition leakage.
- [ ] Resolve every blocker; do not begin another review cycle unless a factual contradiction remains.
- [ ] Record findings in evidence.

## Task 8 — Final validation

- [ ] Foundry build and all package tests.
- [ ] Goals fixture and journey tests.
- [ ] Fixture-host Simulator build.
- [ ] Goals-specific UI suite and focused shell smoke.
- [ ] SwiftLint on changed Swift files.
- [ ] Canon build/check and focused compiler tests.
- [ ] Flagship/local-first boundary and direct-write audits.
- [ ] Weak-implementation scan.
- [ ] Introduced-range Gitleaks scan from `e4a8260b5b7a776a0190c18efc33c7da9a70ceeb`.
- [ ] Screenshot/contact metadata validation.
- [ ] Changed-path and authority audits.
- [ ] `git diff --check` and final clean worktree inspection.
- [ ] Commit final validation record and leave branch clean, unmerged, and unpushed.

Commands:

```sh
swift build --package-path Packages/AmbitionsPresentation --target AmbitionsNativeVisualFoundry
swift test --package-path Packages/AmbitionsPresentation
xcodebuild -quiet -project Ambitions.xcodeproj -scheme AmbitionsNativeFoundryHost \
  -destination 'platform=iOS Simulator,id=396F4B4A-2DAD-4345-B26E-ABD2EF69BF5E' \
  -derivedDataPath /tmp/ambitions-goals-r01-final-derived build-for-testing
xcodebuild -quiet -project Ambitions.xcodeproj -scheme AmbitionsNativeFoundryHost \
  -destination 'platform=iOS Simulator,id=396F4B4A-2DAD-4345-B26E-ABD2EF69BF5E' \
  -derivedDataPath /tmp/ambitions-goals-r01-final-derived \
  -only-testing:AmbitionsNativeFoundryHostUITests/GoalsNativeCalibrationHostUITests test-without-building
swiftlint lint --strict $(git diff --name-only e4a8260b5b7a776a0190c18efc33c7da9a70ceeb...HEAD -- '*.swift')
python3 scripts/ambitions-canon.py build
python3 scripts/ambitions-canon.py check
python3 scripts/ambitions-flagship-boundary-audit.py
python3 scripts/ambitions-local-first-boundary-scan.py
python3 scripts/ambitions-runtime-direct-write-audit.py
python3 scripts/ci/ambitions-no-weak-implementation-scan.py
GITHUB_BASE_SHA=e4a8260b5b7a776a0190c18efc33c7da9a70ceeb \
  scripts/ci/ambitions-gitleaks-scan.sh --range-only
scripts/changed-file-boundary-check.sh
git diff --check
git status --short
```

If a listed script requires different arguments in the current repository, record and use its actual help contract rather than weakening the check. The complete historical Today UI suite stays out of scope because no shared Today/shell source may change.

## Architecture-sensitive risks and stop-loss

- Production Goals types are not visual authority and will not be imported into the Foundry target.
- The Goals-local grammar must not become a generic cross-root component system.
- The Path is a fixture/read-only native calibration and must not imply generation or mutation.
- Relationship and schedule fit remain inspection only.
- Shell is provisional; any required shared behavior change stops this packet.
- Direct-device proof, production restoration, persistence, and focus architecture remain open.

## Explicit non-goals

No production Goals implementation, runtime adapter, mutation, activation, path generation, Proof mutation, schedule mutation, Receipt, Undo, app-entry work, Today change, other root, shell redesign/freeze, dependency, global token/component API, Figma, Code Connect, production baseline, merge, push, or `APPROVED FOR SWIFTUI`.
