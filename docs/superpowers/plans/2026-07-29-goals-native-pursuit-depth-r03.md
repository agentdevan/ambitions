# Goals Native Pursuit Depth R03 Implementation Plan

> **For agentic workers:** REQUIRED SUB-SKILL: Use superpowers:subagent-driven-development (recommended) or superpowers:executing-plans to implement this plan task-by-task. Steps use checkbox (`- [ ]`) syntax for tracking.

**Goal:** Complete the fixture-only, non-mutating Goal-owned Path, relationship, recovery, closure, accessibility, focus-return, and native evidence slice beneath the accepted Goals NATIVE-R02 screens.

**Architecture:** Extend the existing immutable calibration content and value-semantic journey state with narrowly typed depth routes. Keep the protected root, Home, and active focused-Goal composition intact; new views consume fixture snapshots, while the host supplies entry variants and XCTest proves route/focus semantics. Standard size uses a horizontally inspectable qualitative Path; Accessibility Dynamic Type substitutes a complete ordered semantic list.

**Tech Stack:** Swift 6, SwiftUI, NavigationStack, XCTest/XCUI, XcodeGen, iOS 26.5 Simulator.

## Global Constraints

- Direction: `AVF-GOALS-S08-INT-D09-NATIVE-R03 — Pursuit Depth Completion`.
- Fixture family: `goals-flagship/home/welcome-baby-home/v1`.
- All behavior is fixture-driven, inspection-only, and non-mutating.
- Preserve accepted R02 root, Home, and active focused-Goal hierarchy and screenshots.
- No production route, mutation, adapter, persistence, app-entry, Today, Time, dependency, token, or shared component API changes.
- Proof remains user evidence, distinct from History and any production Receipt.
- Path selection never changes accepted canonical state.
- Dynamic Type replaces unsuitable horizontal Path interpretation with an ordered semantic list.
- No snapshot-testing dependency; all screenshots are evaluation evidence with `production_baseline = false`.
- Direct-device VoiceOver, haptic, edge-gesture, and dock proof remains incomplete.

---

### Task 1: Lock R03 fixture and route contracts

**Files:**
- Modify: `Packages/AmbitionsPresentation/Sources/AmbitionsNativeVisualFoundry/GoalsNativeCalibrationContent.swift`
- Modify: `Packages/AmbitionsPresentation/Sources/AmbitionsNativeVisualFoundry/GoalsNativeCalibrationFixture.swift`
- Modify: `Packages/AmbitionsPresentation/Sources/AmbitionsNativeVisualFoundry/GoalsNativeCalibrationJourneyState.swift`
- Test: `Packages/AmbitionsPresentation/Tests/AmbitionsNativeVisualFoundryTests/GoalsNativeCalibrationR03ContractTests.swift`
- Test: `Packages/AmbitionsPresentation/Tests/AmbitionsNativeVisualFoundryTests/GoalsNativeCalibrationR03JourneyTests.swift`

**Interfaces:**
- Produces stable Proof, recovery, closure, and history snapshot value types on `GoalsNativeCalibrationContent`.
- Produces route cases for Path evidence, recovery, closure, and closure history.
- Produces focus anchors for current movement, relationship entry, recovery entry, Path node, closure, and closure history.

- [ ] Write fixture tests for exact IDs, copy, eight-node order, Proof linkage, closure, and non-mutation.
- [ ] Run the new contract tests and verify compile/failure because R03 models are missing.
- [ ] Write journey tests for Path evidence return, relationship return, recovery-to-Path return, keep-unresolved, and closure-history return.
- [ ] Run the journey tests and verify compile/failure because R03 routes are missing.
- [ ] Add the smallest immutable models and route/state transitions that satisfy the tests.
- [ ] Run all Goals package tests and verify green.
- [ ] Commit the specification, contracts, and regression guards.

### Task 2: Build the Goal Path depth

**Files:**
- Modify: `Packages/AmbitionsPresentation/Sources/AmbitionsNativeVisualFoundry/GoalsNativeCalibrationPathView.swift`
- Create: `Packages/AmbitionsPresentation/Sources/AmbitionsNativeVisualFoundry/GoalsNativeCalibrationPathEvidenceView.swift`
- Test: `Packages/AmbitionsPresentation/Tests/AmbitionsNativeVisualFoundryTests/GoalsNativeCalibrationR03PathTests.swift`

**Interfaces:**
- Consumes `content.goalPath`, `content.proofMoments`, `state.selectedPathNodeID`, `state.jumpTo(_:)`, and `state.openPathEvidence()`.
- Produces `gnc-r03-path-*` and `gnc-r03-path-evidence-*` accessibility identifiers.

- [ ] Write failing presentation tests for compact jump labels, selected-node evidence, conditional uncertainty, and ordered accessibility semantics.
- [ ] Run the Path tests and verify failure against the inherited equal-button/continuous-line implementation.
- [ ] Replace the standard Path with asymmetric qualitative passages and attached selected detail; use one native Menu for Start/Now/Next/Finish.
- [ ] Add Path Proof/history inspection that returns to the same selected node.
- [ ] Add Accessibility Dynamic Type ordered semantic list with all eight identities, states, Proof, actions, and jump behavior.
- [ ] Run focused Path and all Goals package tests.
- [ ] Render standard and accessibility Path frames and inspect at device, 50%, and contact-sheet scale.
- [ ] Commit the Path depth.

### Task 3: Build relationship, recovery, and closure depths

**Files:**
- Modify: `Packages/AmbitionsPresentation/Sources/AmbitionsNativeVisualFoundry/GoalsNativeCalibrationRelationshipView.swift`
- Create: `Packages/AmbitionsPresentation/Sources/AmbitionsNativeVisualFoundry/GoalsNativeCalibrationRecoveryView.swift`
- Create: `Packages/AmbitionsPresentation/Sources/AmbitionsNativeVisualFoundry/GoalsNativeCalibrationClosureView.swift`
- Create: `Packages/AmbitionsPresentation/Sources/AmbitionsNativeVisualFoundry/GoalsNativeCalibrationClosureHistoryView.swift`
- Test: `Packages/AmbitionsPresentation/Tests/AmbitionsNativeVisualFoundryTests/GoalsNativeCalibrationR03DepthPresentationTests.swift`

**Interfaces:**
- Consumes immutable relationship, recovery, closure, Goal, Path, and Proof snapshots.
- Produces non-mutating route actions through the bound journey state only.

- [ ] Write failing tests for consequence-first relationship order, protected boundary, recovery retained truth, unresolved alternative, closure/open-work distinction, and retained history.
- [ ] Run and verify expected failures against the inherited relationship and missing recovery/closure views.
- [ ] Recompose relationship as a consequence-first Goal-owned field without graph anatomy or internal ownership vocabulary.
- [ ] Implement object-scoped recovery with Review current Path, Inspect possible next, Keep unresolved, and native Back.
- [ ] Implement closure with stable Goal identity, final accepted truth, attached Proof, settled Path continuity, protected result, remaining open item, history, and explicit return.
- [ ] Run focused depth and all Goals package tests.
- [ ] Render relationship, recovery, closure, and closure-history frames in Dark and inspect the complete reading order.
- [ ] Commit the depth views.

### Task 4: Integrate navigation, focus, host variants, and reduced effects

**Files:**
- Modify: `Packages/AmbitionsPresentation/Sources/AmbitionsNativeVisualFoundry/GoalsNativeCalibrationView.swift`
- Modify: `Packages/AmbitionsPresentation/Sources/AmbitionsNativeVisualFoundry/GoalsNativeCalibrationFocusedGoalView.swift`
- Modify: `Native/AmbitionsNativeFoundryHost/GoalsNativeFoundryHost.swift`
- Create: `Native/AmbitionsNativeFoundryHostUITests/GoalsNativeCalibrationR03HostUITests.swift`

**Interfaces:**
- Navigation destinations consume Task 1 route cases and Tasks 2–3 views.
- Host variants expose direct, reproducible R03 states without production wiring.

- [ ] Write UI assertions for the required actions, 44-point targets, exact return objects, non-mutation, ordered accessibility Path, reduced transparency, contrast/non-color semantics, and protected R02 screens.
- [ ] Run the focused UI suite and verify failures because variants and destinations are absent.
- [ ] Wire the new destinations and fixture-host variants.
- [ ] Add `AccessibilityFocusState` restoration at current movement, relationship, recovery, selected Path node, closure, and closure history.
- [ ] Add recovery/closure entry posture only to their dedicated fixture variants; keep accepted R02 active focused Goal unchanged.
- [ ] Verify Light/Dark, Accessibility Dynamic Type, Reduce Motion, Reduce Transparency, Increased Contrast, and Differentiate Without Color.
- [ ] Run the complete bounded Goals R03 UI suite and R02 regression suite.
- [ ] Commit accessibility and return integration.

### Task 5: Capture evidence, review performance, and validate

**Files:**
- Create/modify only under: `docs/qa/evidence/2026-07-29-goals-native-pursuit-depth-r03/`
- Create: `Native/AmbitionsNativeFoundryHostUITests/GoalsNativeCalibrationR03ScreenshotCaptureUITests.swift`
- Create: `Native/AmbitionsNativeFoundryHostUITests/GoalsNativeCalibrationR03RecordingDriverUITests.swift`

**Interfaces:**
- Produces 14 named screenshots, 3 contact sheets, 2 short recordings, metadata, hashes, comparison, validation, and owner-review status.

- [ ] Capture all named screenshots at iPhone 17 Pro / iOS 26.5 and export native attachments.
- [ ] Record the two bounded journeys while the matching UI drivers run; record duration, size, hashes, fixture, device, OS, appearance, and settings.
- [ ] Build the three contact sheets and protected R02 before/after comparison.
- [ ] Run the focused SwiftUI code-first performance audit and record whether ETTrace or memory tooling is warranted.
- [ ] Run the final package, Simulator, UI, lint, canon/compiler, boundary, direct-write, weak-implementation, Gitleaks, metadata, authority, diff, and worktree checks once from final executable source.
- [ ] Dispatch the final visual/accessibility/authority reviewer and resolve blocking findings.
- [ ] Complete evidence documentation, set `owner-review.md` to `READY_FOR_OWNER_REVIEW`, commit, and verify the worktree is clean.

## Self-review

- Spec coverage: every R03 screen, route, state, accessibility transformation, evidence artifact, recording, validation, and proof ceiling maps to a task above.
- Completeness scan: no deferred implementation stubs are present; unresolved production/device obligations are explicit scope ceilings.
- Type consistency: all depth tasks consume the immutable content and typed journey-state interfaces defined by Task 1.
