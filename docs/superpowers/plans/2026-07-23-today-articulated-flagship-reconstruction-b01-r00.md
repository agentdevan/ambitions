# Today Articulated Flagship Reconstruction Implementation Plan

> **For agentic workers:** REQUIRED SUB-SKILL: Use superpowers:executing-plans to implement this plan task-by-task. Steps use checkbox (`- [ ]`) syntax for tracking.

**Goal:** Reconstruct the complete fixture-driven Today flagship journey as an articulated native object field while preserving R02 semantics, state transitions, fixture truth, navigation ownership, and proof ceilings.

**Architecture:** Keep `TodayFlagshipJourneyState` and the immutable `TodayFlagshipCalibrationContent` adapter as the semantic boundary. Add only Foundry-local SwiftUI composition units for object relief, relationship rows, timeline rows, truth comparison, evidence, and shell Peek; compose them into the existing root, focused Step, review, settlement, return, and recovery views without adding runtime or production entry wiring.

**Tech Stack:** Swift 6.3, SwiftUI on iOS 26, Swift Package Manager, Xcode fixture host, XCTest/XCUITest, package-backed preview browser, native Simulator capture, ImageMagick evidence composition.

## Global Constraints

- Base B01 on R02 SHA `77e818823b58ee2911e68962dd8bd8115e1d26aa`; do not modify `main`.
- Preserve fixture family `today-flagship/preparing-for-baby/still-counts/v1` and every canonical identity and state transition.
- Keep Today, Goals, Time, You in locked root order; keep Search and Capture separate and dock-owned.
- Keep the native full-screen review, native recovery sheet, natural scrolling, native back behavior, and persistent settlement.
- Use opaque matte content; Liquid Glass is limited to functional crown/dock chrome with an opaque Reduce Transparency equivalent.
- Add no dependency, runtime adapter, app-entry integration, legacy frontend import, final token system, broad component library, Figma artifact, Code Connect artifact, or production screenshot baseline.
- `APPROVED FOR SWIFTUI`, broad reconstruction, runtime integration, and legacy cutover remain false.
- Every production-intended behavior change follows red-green-refactor; rendered visual inspection is required in addition to tests.

---

### Task 1: Lock owner input, reference translation, and changed-file envelope

**Files:**
- Modify: `docs/qa/evidence/2026-07-23-today-flagship-calibration-slice-r02/owner-review.md`
- Create: `docs/qa/evidence/2026-07-23-today-articulated-flagship-reconstruction-b01-r00/README.md`
- Create: `docs/qa/evidence/2026-07-23-today-articulated-flagship-reconstruction-b01-r00/reference-translation.md`
- Create: `docs/qa/evidence/2026-07-23-today-articulated-flagship-reconstruction-b01-r00/structural-branch-contract.md`
- Create: `docs/qa/evidence/2026-07-23-today-articulated-flagship-reconstruction-b01-r00/changed-files.md`
- Create: `docs/qa/evidence/2026-07-23-today-articulated-flagship-reconstruction-b01-r00/fixture-contract.md`
- Create: `docs/qa/evidence/2026-07-23-today-articulated-flagship-reconstruction-b01-r00/reference-input-hashes.json`

**Interfaces:**
- Consumes: immutable R02 evidence, owner graphite board, active AVF/VC canon.
- Produces: exact visual translation rules and the only permitted source/test/evidence path envelope.

- [ ] **Step 1: Verify the copied owner board hash**

Run:

```sh
shasum -a 256 docs/qa/evidence/2026-07-23-today-articulated-flagship-reconstruction-b01-r00/reference-inputs/owner-intended-eight-screen-graphite-reference.jpg
```

Expected: `536377f7877411821f2c6a2827d6c4d36ed699f78b0ddeca41c5f9804841e151`.

- [ ] **Step 2: Verify R02 media remains immutable**

Run a machine comparison of every `screenshot-metadata.json` and `journey-metadata.json` path against byte size and SHA-256.

Expected: 16 PNGs and 3 MOVs match; no R02 media path changes.

- [ ] **Step 3: Commit the branch contract**

```sh
git add docs/qa/evidence/2026-07-23-today-flagship-calibration-slice-r02/owner-review.md docs/qa/evidence/2026-07-23-today-articulated-flagship-reconstruction-b01-r00 docs/superpowers/plans/2026-07-23-today-articulated-flagship-reconstruction-b01-r00.md
git commit -m "docs(qa): open Today articulated flagship branch"
```

### Task 2: Establish B01 regression guards before visual implementation

**Files:**
- Modify: `Packages/AmbitionsPresentation/Tests/AmbitionsNativeVisualFoundryTests/TodayFlagshipCalibrationFixtureTests.swift`
- Modify: `Native/AmbitionsNativeFoundryHostUITests/TodayFlagshipCalibrationHostUITests.swift`

**Interfaces:**
- Consumes: existing fixture IDs, state phases, accessibility identifiers, and host variants.
- Produces: failing guards for one dominant Start Here group, articulated timeline semantics, shell ownership, truth comparison, saving duplication prevention, settlement ordering, return uniqueness, recovery preservation, RTL, contrast, Dynamic Type, and opaque chrome.

- [ ] **Step 1: Write package guards for preserved fixture/state contracts and prohibited shell controls**

Add assertions that root order is `Today, Goals, Time, You`, globals are `Search, Capture`, promoted Start Here remains unique, Still counts is the sole visible outcome, and source contains no `TabView`, bottom-tab label, runtime adapter, or legacy import.

- [ ] **Step 2: Write UI guards against the intended B01 accessibility anatomy**

Assert identifiers `tfcs-start-here-object`, `tfcs-timeline-row-*`, `tfcs-dock-shell-peek`, `tfcs-focused-object-field`, `tfcs-review-comparison`, `tfcs-settlement-field`, and `tfcs-recovery-progress-field`; assert action visibility, target sizes, logical order, and return focus.

- [ ] **Step 3: Run the new tests and record RED**

```sh
swift test --package-path Packages/AmbitionsPresentation --filter TodayFlagshipCalibrationFixtureTests
xcodebuild -project Ambitions.xcodeproj -scheme AmbitionsNativeFoundryHost -destination 'platform=iOS Simulator,id=EDE1E954-C663-47FB-855B-95F96AE2DBDD' test -only-testing:AmbitionsNativeFoundryHostUITests/TodayFlagshipCalibrationHostUITests
```

Expected: package guards pass where they protect existing semantics; new B01 UI identifiers fail because the articulated anatomy is not implemented.

### Task 3: Implement Foundry-local articulated anatomy

**Files:**
- Create: `Packages/AmbitionsPresentation/Sources/AmbitionsNativeVisualFoundry/TodayFlagshipArticulatedAnatomy.swift`
- Modify: `Packages/AmbitionsPresentation/Sources/AmbitionsNativeVisualFoundry/TodayFlagshipCalibrationStyle.swift`
- Modify: `Packages/AmbitionsPresentation/Sources/AmbitionsNativeVisualFoundry/TodayFlagshipNavigationChrome.swift`

**Interfaces:**
- Consumes: `TodayFlagshipPalette`, immutable Step/timeline/receipt snapshots, semantic system type, native controls.
- Produces: local `TodayFlagshipObjectField`, `TodayFlagshipRelationshipRow`, `TodayFlagshipTimelineRow`, `TodayFlagshipStateComparison`, `TodayFlagshipEvidenceRow`, and an appearance-only shell Peek.

- [ ] **Step 1: Implement semantic relief and object anatomy minimally to satisfy the failing identifiers**

Use one continuous matte plane, localized opaque relief, meaningful uneven geometry, semantic SF Symbols, no content glass, no universal card radius, and no generic token API.

- [ ] **Step 2: Preserve functional shell material and opaque fallback**

Use native iOS 26 Liquid Glass only inside the existing dock material helper; under Reduce Transparency render the authored opaque chrome with a visible boundary.

- [ ] **Step 3: Build and run focused tests GREEN**

```sh
swift build --package-path Packages/AmbitionsPresentation --target AmbitionsNativeVisualFoundry
swift test --package-path Packages/AmbitionsPresentation --filter TodayFlagshipCalibrationFixtureTests
```

Expected: build succeeds and focused package tests pass.

- [ ] **Step 4: Commit local anatomy**

```sh
git add Packages/AmbitionsPresentation/Sources/AmbitionsNativeVisualFoundry Packages/AmbitionsPresentation/Tests/AmbitionsNativeVisualFoundryTests Native/AmbitionsNativeFoundryHostUITests
git commit -m "feat(foundry): add articulated Today object anatomy"
```

### Task 4: Reconstruct Today root, timeline, and dock presentation

**Files:**
- Modify: `Packages/AmbitionsPresentation/Sources/AmbitionsNativeVisualFoundry/TodayFlagshipCalibrationView.swift`
- Modify: `Packages/AmbitionsPresentation/Sources/AmbitionsNativeVisualFoundry/TodayFlagshipNavigationChrome.swift`
- Modify: `Packages/AmbitionsPresentation/Sources/AmbitionsNativeVisualFoundry/TodayFlagshipCalibrationPreviews.swift`

**Interfaces:**
- Consumes: Task 3 object field, relationship row, timeline row, shell Peek.
- Produces: composed first viewport, natural temporal rail, expanded dock, adaptive passage, returned root anatomy, Light/Dark parity.

- [ ] **Step 1: Replace the text-column Start Here body with one dominant articulated object field**

Preserve title, parent pursuit, current truth, fit, consequence, temporal relationship, one primary action, and the existing non-mutating `openStartHere()` call.

- [ ] **Step 2: Replace unformed timeline text with aligned temporal rows**

Keep object identity primary, time secondary but scannable, protected/fixed state explicit, and no duplicate Start Here identity.

- [ ] **Step 3: Render Light, Dark, dense, scroll, expanded dock, and adaptive passage through the package preview loop**

Run the preview browser filtered to F01/F02/F03/F04/F05 and record four source-changing root warm reloads.

- [ ] **Step 4: Run root/dock UI guards GREEN and commit**

Expected: Start Here and at least one complete supporting object share the first viewport; dock target is at least 44 points; no bottom tabs appear.

### Task 5: Reconstruct focused Step depth

**Files:**
- Modify: `Packages/AmbitionsPresentation/Sources/AmbitionsNativeVisualFoundry/TodayFlagshipFocusedStepView.swift`

**Interfaces:**
- Consumes: object field, relationship row, accepted-truth field, existing state phases.
- Produces: stable Step identity, parent pursuit, current truth, fit, consequence, time, Still counts, interruption/recovered seams, settlement entry point.

- [ ] **Step 1: Preserve focused semantics with a formed canonical object field**

Keep `NavigationStack`, native back gesture, accepted truth, and one executable `Still counts`; remove no human product copy and add no passive outcome.

- [ ] **Step 2: Verify typical, dense, Accessibility Dynamic Type, and RTL preview compositions**

Expected: meanings recompose vertically without clipped required action or tiny type.

- [ ] **Step 3: Run focused tests GREEN and commit**

### Task 6: Reconstruct review, saving, and settlement

**Files:**
- Modify: `Packages/AmbitionsPresentation/Sources/AmbitionsNativeVisualFoundry/TodayFlagshipReviewView.swift`
- Modify: `Packages/AmbitionsPresentation/Sources/AmbitionsNativeVisualFoundry/TodayFlagshipFocusedStepView.swift`

**Interfaces:**
- Consumes: state comparison, evidence row, existing full-screen review binding and commit callback.
- Produces: aligned current/proposed comparison, anchored actions, proposal-preserving saving region, composed settlement, secondary history disclosure.

- [ ] **Step 1: Build a spatial current/proposed comparison**

Keep current truth neutral, proposal labelled and shaped as proposed, consequence and relationship concise, Details collapsed, Record progress and Not now visible in the standard first viewport.

- [ ] **Step 2: Keep the same comparison visible while saving**

Disable duplicate commitment, show native progress, preserve accepted truth, and avoid success styling.

- [ ] **Step 3: Compose settlement around changed truth**

Lead with settled truth, preserve pursuit continuity, keep device history subordinate, retain View history and explicit Return to Today, and add no celebration or Undo.

- [ ] **Step 4: Run review/saving/settlement tests GREEN and commit**

### Task 7: Reconstruct returned Today and recovery

**Files:**
- Modify: `Packages/AmbitionsPresentation/Sources/AmbitionsNativeVisualFoundry/TodayFlagshipCalibrationView.swift`
- Modify: `Packages/AmbitionsPresentation/Sources/AmbitionsNativeVisualFoundry/TodayFlagshipRecoveryReviewView.swift`
- Modify: `Native/AmbitionsNativeFoundryHost/AmbitionsNativeFoundryHostApp.swift`

**Interfaces:**
- Consumes: `returnedTodayTimeline`, semantic return anchor, recovery choices, native sheet.
- Produces: settled continuity field, unique new Start Here, object-scoped recovery composition, reliable evidence journey driver.

- [ ] **Step 1: Compose returned Today without duplicate promoted object**

Focus remains on `today.settled.step.nursery-ready-for-crib`; `step.send-launch-brief` appears once as Start Here with subordinate 2:00 PM context.

- [ ] **Step 2: Articulate saved progress inside the native recovery sheet**

Keep exact recovery command IDs and effects; continue restores saved progress, deferral mutates nothing, dismissal remains truthful.

- [ ] **Step 3: Make fixture-host recording transitions observable and deterministic**

Drive native presentation state with sufficient transition waits and confirm each expected accessibility identifier before advancing; do not imply runtime timing.

- [ ] **Step 4: Run all package and UI tests GREEN and commit**

### Task 8: Regenerate B01 native evidence and benchmark

**Files:**
- Create: `docs/qa/evidence/2026-07-23-today-articulated-flagship-reconstruction-b01-r00/screenshots/*.png`
- Create: `docs/qa/evidence/2026-07-23-today-articulated-flagship-reconstruction-b01-r00/supporting-state/*.png`
- Create: `docs/qa/evidence/2026-07-23-today-articulated-flagship-reconstruction-b01-r00/recordings/*.mov`
- Create: `docs/qa/evidence/2026-07-23-today-articulated-flagship-reconstruction-b01-r00/contact-sheets/*`
- Create: evidence metadata and review Markdown listed in `changed-files.md`.

**Interfaces:**
- Consumes: final fixture-host views and R02/reference inputs.
- Produces: 16 frames, J01/J02/J03, C01/C02/C03, SHA/size/duration metadata, warm-loop report, owner-review record.

- [ ] **Step 1: Capture all 16 frames on the same iPhone 17 Pro Simulator**

Use real fixture-host renderings; keep `production_baseline=false` and record device/OS/appearance/Dynamic Type/accessibility settings.

- [ ] **Step 2: Record all three continuous journeys**

Inspect every second of each recording and verify root → focus → review → saving → settlement → history → return, interruption → recovery → truthful result, and Accessibility Dynamic Type recomposition.

- [ ] **Step 3: Create C01, C02, and C03**

C01 contains all 16 B01 frames; C02 pairs R02/B01 F01/F02/F06/F07/F08/F09/F10; C03 pairs owner-reference crops with B01 translations and rejected obsolete elements.

- [ ] **Step 4: Run four root and four deep source-changing warm reloads plus cached host build**

Expected: no clean build and no injection dependency; each visual mutation appears in the package preview host.

### Task 9: Fresh verification, self-review, and clean handoff

**Files:**
- Create/modify: final B01 validation, accessibility, visual, material, comparison, benchmark, limitations, command, changed-files, and owner-review records.

**Interfaces:**
- Consumes: complete B01 branch and media.
- Produces: reviewable clean branch at `READY_FOR_OWNER_REVIEW` without acceptance claim.

- [ ] **Step 1: Run the full required validation matrix**

Run Foundry build/tests, fixture tests, host build/UI suite, SwiftLint, canon build/check, 44 focused compiler tests, boundary scan, direct-write audit, weak scan, full and R02-to-B01 Gitleaks, metadata validators, changed-path/authority audits, and `git diff --check`.

- [ ] **Step 2: Inspect every frame and every second of recordings at full-device, 50%, and contact-sheet scale**

Reject handoff if any named root/focus/review/settlement/return/recovery structural defect remains.

- [ ] **Step 3: Commit evidence and final validation**

```sh
git add docs/qa/evidence/2026-07-23-today-articulated-flagship-reconstruction-b01-r00
git commit -m "docs(qa): package Today articulated flagship evidence"
```

- [ ] **Step 4: Verify clean unmerged/unpushed handoff**

```sh
git status --short
git branch --merged main --format='%(refname:short)'
git ls-remote --heads origin codex/today-articulated-flagship-reconstruction
```

Expected: clean status, B01 absent from merged branches, and no remote B01 branch.
