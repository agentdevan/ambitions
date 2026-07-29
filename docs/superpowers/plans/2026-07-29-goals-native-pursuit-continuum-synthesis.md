# Goals Native Pursuit Continuum Synthesis Implementation Plan

> **For agentic workers:** REQUIRED SUB-SKILL: Use superpowers:subagent-driven-development (recommended) or superpowers:executing-plans to implement this plan task-by-task. Steps use checkbox (`- [ ]`) syntax for tracking.

**Goal:** Build a fixture-driven native prototype of the Goals root, Home Life Area, and focused `Welcome our baby home` Goal using the selected D09-R02 structural family.

**Architecture:** Extend the existing value-based Goals Foundry journey with one typed Life Area route and use a single `NavigationStack` for native push and Back ownership. Replace the rejected root and focused compositions, add a focused Home view, and reuse the existing read-only Path and relationship destinations without changing fixture truth.

**Tech Stack:** Swift 6.2, SwiftUI on iOS 26, Swift Package Manager, XCTest, XCUITest, XcodeGen fixture host.

## Global Constraints

- Foundry-only, fixture-driven, inspection-only, and non-mutating.
- Do not modify production Goals, runtime adapters, app entry, canon, final tokens, or shared component APIs.
- Preserve fixture family `goals-flagship/home/welcome-baby-home/v1` and all stable identities.
- Goals root exposes Life Areas only; Home and Goal are separate native depths.
- Use framework Back, interactive Back, natural scrolling, system typography, and adaptive layouts.
- Liquid Glass is functional dock chrome only and has an opaque Reduce Transparency equivalent.
- Evaluation screenshots use `production_baseline = false`.
- `APPROVED_FOR_SWIFTUI` remains false.

---

### Task 1: Typed canonical route hierarchy

**Files:**
- Modify: `Packages/AmbitionsPresentation/Tests/AmbitionsNativeVisualFoundryTests/GoalsNativeCalibrationJourneyStateTests.swift`
- Modify: `Packages/AmbitionsPresentation/Sources/AmbitionsNativeVisualFoundry/GoalsNativeCalibrationJourneyState.swift`

**Interfaces:**
- Produces: `GoalsNativeCalibrationRoute.lifeArea(id:)`
- Produces: validated root → Life Area → Goal → supporting-depth paths
- Produces: non-mutating Back restoration through `reconcileNavigationPath(_:)`

- [ ] Add tests asserting the strict three-depth path, invalid-ID rejection, Back restoration, and unchanged fixture content.
- [ ] Run `swift test --package-path Packages/AmbitionsPresentation --filter GoalsNativeCalibrationJourneyStateTests` and verify the new assertions fail because `.lifeArea` and canonical parent paths do not exist.
- [ ] Implement the minimum typed route validation and restoration state.
- [ ] Rerun the filtered suite and verify it passes.

### Task 2: Strict Goals root and Home pursuit passages

**Files:**
- Modify: `Packages/AmbitionsPresentation/Tests/AmbitionsNativeVisualFoundryTests/GoalsNativeCalibrationPresentationTests.swift`
- Modify: `Native/AmbitionsNativeFoundryHostUITests/GoalsNativeCalibrationHostUITests.swift`
- Modify: `Packages/AmbitionsPresentation/Sources/AmbitionsNativeVisualFoundry/GoalsNativeCalibrationRootView.swift`
- Create: `Packages/AmbitionsPresentation/Sources/AmbitionsNativeVisualFoundry/GoalsNativeCalibrationHomeView.swift`
- Modify: `Packages/AmbitionsPresentation/Sources/AmbitionsNativeVisualFoundry/GoalsNativeCalibrationView.swift`

**Interfaces:**
- Consumes: `.lifeArea(id:)` and `.focusedGoal(id:)`
- Produces: root-only `GoalsNativeCalibrationRootPresentation`
- Produces: `GoalsNativeCalibrationHomePresentation`
- Produces: row-wide native links with stable accessibility identifiers

- [ ] Add package assertions that root presentation contains no Goal identity and Home contains each fixture Goal exactly once.
- [ ] Add UI assertions for root-only Life Areas, row-wide Home navigation, native Back, and selected Goal restoration.
- [ ] Run the filtered package tests and verify the new presentation types/assertions fail.
- [ ] Implement the strict root and new Home view with native `NavigationLink(value:)` targets.
- [ ] Rerun the filtered package tests and build the Foundry target.

### Task 3: Operational focused pursuit continuum

**Files:**
- Modify: `Packages/AmbitionsPresentation/Tests/AmbitionsNativeVisualFoundryTests/GoalsNativeCalibrationPresentationTests.swift`
- Modify: `Packages/AmbitionsPresentation/Sources/AmbitionsNativeVisualFoundry/GoalsNativeCalibrationFocusedGoalView.swift`
- Modify: `Packages/AmbitionsPresentation/Sources/AmbitionsNativeVisualFoundry/GoalsNativeCalibrationGrammar.swift`

**Interfaces:**
- Consumes: the primary Goal, linked lens, Path, and relationship fixture values
- Produces: truth-owned Proof disclosure, current-movement Path link, future disclosure, and relationship inspection link

- [ ] Add assertions for accepted truth, attached Proof, current movement, three certainty postures, and protected relationship.
- [ ] Run the filtered presentation suite and verify missing future/provenance presentation fails.
- [ ] Implement the shared material seam, disclosures, and supporting navigation links.
- [ ] Rerun filtered tests and the Foundry target build.

### Task 4: Host states and accessibility behavior

**Files:**
- Modify: `Packages/AmbitionsPresentation/Sources/AmbitionsNativeVisualFoundry/GoalsNativeCalibrationPreviews.swift`
- Modify: `Native/AmbitionsNativeFoundryHost/GoalsNativeFoundryHost.swift`
- Modify: `Native/AmbitionsNativeFoundryHostUITests/GoalsNativeCalibrationHostUITests.swift`
- Modify: `Native/AmbitionsNativeFoundryHostUITests/GoalsNativeCalibrationScreenshotCaptureUITests.swift`

**Interfaces:**
- Produces: deterministic root, Home, focused, Light, Dark, Accessibility Dynamic Type, Reduce Motion, and Reduce Transparency variants

- [ ] Add UI assertions for Proof/future disclosures, Path/relationship entry, interactive Back restoration, 44-point targets, and accessibility recomposition.
- [ ] Build-for-testing, run focused UI tests, and confirm failing assertions before host/view implementation completes.
- [ ] Add only the required fixture-host variants and accessibility environment wiring.
- [ ] Rerun the focused UI suite until it passes without weakening assertions.

### Task 5: Native evidence and final verification

**Files:**
- Create: `docs/qa/evidence/2026-07-29-goals-native-pursuit-continuum-synthesis-r01/`
- Modify: `docs/qa/native-foundry/goals-world-class-intervention/owner-review.md`

**Interfaces:**
- Produces: screenshot metadata, native frames, validation outcomes, known limitations, and owner-review status

- [ ] Capture the approved screen/state matrix from one final fixture-host HEAD.
- [ ] Inspect every frame at full-device and contact-sheet scale and correct only concrete contract violations.
- [ ] Run the full presentation package suite, fixture-host build, focused UI suite, SwiftLint on changed Swift, canon check, Gitleaks range scan, `git diff --check`, and changed-path audit.
- [ ] Record exact commands, results, device/OS, appearance, content size, accessibility settings, hashes, and `production_baseline = false`.
- [ ] Commit the coherent Foundry prototype and evidence, then verify a clean worktree.
