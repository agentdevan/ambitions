# Today Open Continuity Field — Implementation Plan

> Execute with `superpowers:subagent-driven-development`. Each implementation
> phase receives a fresh implementer, then fresh specification and quality
> reviewers. Resolve blocking findings before the next phase.

**Goal:** Reconstruct the complete fixture-driven Today journey as Open
Continuity Field while preserving semantic truth, native behavior,
accessibility, and every authorization ceiling.

**Architecture:** Keep immutable `TodayFlagshipCalibrationContent` snapshots and
`TodayFlagshipJourneyState` as the semantic boundary. Split oversized B01 views
into journey-local composition units within `AmbitionsNativeVisualFoundry`.
`AmbitionsNativeFoundryHost` remains the only render and evidence application.

**Stack:** Swift tools 6.2 compiled with Apple Swift 6.3.3, SwiftUI/iOS 26,
SPM, XCTest/XCUITest, native Simulator, package preview browser, AVFoundation.
No new dependency.

## Constraints

- Base: B01 closeout `92048f7622b06f78ee6e5667e84facd0c4beb2f4`.
- Preserve fixture IDs, truth transitions, Still Counts, settlement, History,
  explicit return, unique revealed Start Here, and recovery effects.
- Full Day is a non-mutating read-only projection of existing fixture chronology.
- Preserve Today/Goals/Time/You and separate Search/Capture dock ownership.
- Matte content; functional glass only with opaque Reduce Transparency fallback.
- No canon, generated canon, project/package configuration, dependency, runtime,
  app entry, legacy UI, other root, final token/component authority, Figma, Code
  Connect, production baseline, merge, or push.
- Write failing behavior/accessibility tests before implementation; rendered
  native inspection remains mandatory.

## Local interfaces

| Unit | Input | Output |
| --- | --- | --- |
| `TodayOpenContinuityGrammar` | appearance and accessibility environment | local palette, type, action, material, node roles |
| `TodayOpenContinuityRoot` | content, state projection, callbacks | crown, Start Here, overview, returned continuity |
| `TodayOpenContinuityTimeline` | timeline snapshots and mode | overview anchors and Full Day chronology |
| `TodayOpenContinuityFocusedObject` | Step snapshot, truth, phase | object depth and Still Counts |
| `TodayOpenContinuityTruthFlow` | truth/proposal/receipt snapshots, phase | review, saving, settlement, History |
| existing shell views | locked commands and expanded binding | Peek, expanded dock, Adaptive Passage |
| existing public wrapper | content, state binding, commit callback | stable preview/host integration |

## Executable subagent task decomposition

Every task gets a fresh implementer. It writes
`.superpowers/sdd/b02-task-XX-report.md`. Two later fresh agents write
`.superpowers/sdd/b02-task-XX-spec-review.md` and
`.superpowers/sdd/b02-task-XX-quality-review.md`. Reviewers receive the task
brief, start/end SHAs, test output, rendered checkpoint, and diff.

### Exact path registry

- Content: `Packages/AmbitionsPresentation/Sources/AmbitionsNativeVisualFoundry/TodayFlagshipCalibrationContent.swift`
- Fixture: `Packages/AmbitionsPresentation/Sources/AmbitionsNativeVisualFoundry/TodayFlagshipCalibrationFixture.swift`
- State: `Packages/AmbitionsPresentation/Sources/AmbitionsNativeVisualFoundry/TodayFlagshipJourneyState.swift`
- Root wrapper: `Packages/AmbitionsPresentation/Sources/AmbitionsNativeVisualFoundry/TodayFlagshipCalibrationView.swift`
- Style: `Packages/AmbitionsPresentation/Sources/AmbitionsNativeVisualFoundry/TodayFlagshipCalibrationStyle.swift`
- B01 anatomy: `Packages/AmbitionsPresentation/Sources/AmbitionsNativeVisualFoundry/TodayFlagshipArticulatedAnatomy.swift`
- Navigation chrome: `Packages/AmbitionsPresentation/Sources/AmbitionsNativeVisualFoundry/TodayFlagshipNavigationChrome.swift`
- Focus: `Packages/AmbitionsPresentation/Sources/AmbitionsNativeVisualFoundry/TodayFlagshipFocusedStepView.swift`
- Review: `Packages/AmbitionsPresentation/Sources/AmbitionsNativeVisualFoundry/TodayFlagshipReviewView.swift`
- Recovery: `Packages/AmbitionsPresentation/Sources/AmbitionsNativeVisualFoundry/TodayFlagshipRecoveryReviewView.swift`
- Previews: `Packages/AmbitionsPresentation/Sources/AmbitionsNativeVisualFoundry/TodayFlagshipCalibrationPreviews.swift`
- Fixture tests: `Packages/AmbitionsPresentation/Tests/AmbitionsNativeVisualFoundryTests/TodayFlagshipCalibrationFixtureTests.swift`
- State tests: `Packages/AmbitionsPresentation/Tests/AmbitionsNativeVisualFoundryTests/TodayFlagshipJourneyStateTests.swift`
- Host: `Native/AmbitionsNativeFoundryHost/AmbitionsNativeFoundryHostApp.swift`
- UI tests: `Native/AmbitionsNativeFoundryHostUITests/TodayFlagshipCalibrationHostUITests.swift`

Every shortened noun in Tasks 01–12 resolves to this exact registry; no other
source path is implied.

### Task 01 — Provisional visual grammar

Exact files:

- Create `Packages/AmbitionsPresentation/Sources/AmbitionsNativeVisualFoundry/TodayOpenContinuityGrammar.swift`
- Create `Packages/AmbitionsPresentation/Sources/AmbitionsNativeVisualFoundry/TodayOpenContinuitySpine.swift`
- Modify `Packages/AmbitionsPresentation/Sources/AmbitionsNativeVisualFoundry/TodayFlagshipCalibrationStyle.swift`
- Modify `Packages/AmbitionsPresentation/Sources/AmbitionsNativeVisualFoundry/TodayFlagshipArticulatedAnatomy.swift`
- Modify `Packages/AmbitionsPresentation/Tests/AmbitionsNativeVisualFoundryTests/TodayFlagshipCalibrationFixtureTests.swift`

Required interfaces:

```swift
enum TodayOpenContinuityNodeKind: String, CaseIterable {
    case current, proposed, saving, settled, interrupted, protected, fixed, external, openLane
}
struct TodayOpenContinuityPalette
struct TodayOpenContinuitySpine: View
struct TodayOpenContinuityPrimaryActionStyle: ButtonStyle
```

RED adds `testB02GrammarUsesSystemTypeMatteContentAndNonColorNodes()` asserting
all node kinds have distinct shape labels; source has no custom font, content
glass, `TabView`, or production design-system import. Run:

```sh
swift test --package-path Packages/AmbitionsPresentation --filter TodayFlagshipCalibrationFixtureTests/testB02GrammarUsesSystemTypeMatteContentAndNonColorNodes
```

Expected RED: new symbols are unavailable. Minimal GREEN implements only the
listed local roles and moves the oversized B01 anatomy onto those journey-local
roles without changing behavior, then runs the same test plus the Foundry
target build. Render the grammar preview in five environments. Commit scope is
only these five files; commit
`feat(foundry): establish open continuity grammar`.

### Task 02 — Shell, crown, and dock

Exact files:

- Modify `Packages/AmbitionsPresentation/Sources/AmbitionsNativeVisualFoundry/TodayFlagshipCalibrationContent.swift`
- Modify `Packages/AmbitionsPresentation/Sources/AmbitionsNativeVisualFoundry/TodayFlagshipCalibrationFixture.swift`
- Modify `Packages/AmbitionsPresentation/Sources/AmbitionsNativeVisualFoundry/TodayFlagshipNavigationChrome.swift`
- Modify `Packages/AmbitionsPresentation/Sources/AmbitionsNativeVisualFoundry/TodayFlagshipCalibrationView.swift`
- Modify `Native/AmbitionsNativeFoundryHostUITests/TodayFlagshipCalibrationHostUITests.swift`

Required copy contract adds immutable crown, Today heading, root/global group,
selected-value, navigation-hint, Today/Goals/Time/You/Search/Capture titles,
Time owner title, and announcement strings. Command IDs remain unlocalized;
Arabic and long-LTR fixtures populate every field. Required view signature:

```swift
TodayFlagshipDock(copy: TodayFlagshipInterfaceCopy,
                  commands: [TodayFlagshipNavigationCommand],
                  isExpanded: Binding<Bool>)
```

RED adds `testB02CrownIsRootOnlyAndDockKeepsLockedGroups()` and
`testB02DockPeekHasIntentionalMinimumTarget()`, plus a package source guard that
rejects literal product/AX arguments in all journey views and a UI guard that
enumerates the complete Arabic label tree and permits Latin letters only inside
`Ambitions S10`. Expected failure: wordmark/Peek identifiers, exhaustive copy,
and localized command/group values are absent. GREEN implements the exact 14x52 seam in a 44x64 target and grouped expanded dock. Run focused UI tests with
`xcodebuild ... -only-testing:`. Render root/dock standard and accessibility.
Commit `feat(foundry): reconstruct crown and edge dock`.

### Task 03 — Today root and overview timeline

Exact files:

- Create `Packages/AmbitionsPresentation/Sources/AmbitionsNativeVisualFoundry/TodayOpenContinuityRoot.swift`
- Create `Packages/AmbitionsPresentation/Sources/AmbitionsNativeVisualFoundry/TodayOpenContinuityTimeline.swift`
- Modify `Packages/AmbitionsPresentation/Sources/AmbitionsNativeVisualFoundry/TodayFlagshipCalibrationContent.swift`
- Modify `Packages/AmbitionsPresentation/Sources/AmbitionsNativeVisualFoundry/TodayFlagshipCalibrationFixture.swift`
- Modify `Packages/AmbitionsPresentation/Sources/AmbitionsNativeVisualFoundry/TodayFlagshipCalibrationView.swift`
- Modify `Packages/AmbitionsPresentation/Sources/AmbitionsNativeVisualFoundry/TodayFlagshipCalibrationPreviews.swift`
- Modify `Packages/AmbitionsPresentation/Tests/AmbitionsNativeVisualFoundryTests/TodayFlagshipCalibrationFixtureTests.swift`
- Modify `Native/AmbitionsNativeFoundryHost/AmbitionsNativeFoundryHostApp.swift`
- Modify `Native/AmbitionsNativeFoundryHostUITests/TodayFlagshipCalibrationHostUITests.swift`

Required interfaces:

```swift
enum TodayOpenContinuityTimelineMode { case overview, fullDay }
func todayOverviewObjects(content: TodayFlagshipCalibrationContent,
                          visibleStartHereID: String) -> [TodayFlagshipTimelineObject]
struct TodayOpenContinuityStartHere: View
struct TodayOpenContinuityTimeline: View
```

RED asserts one Start Here accessibility group as the explicit Now anchor,
primary action first-viewport reachability, no duplicate Start Here, and
overview count `<= 4` following fixed/protected/open/remaining-ordinary order.
GREEN composes the root without nested scroll or full timeline. Render Light,
Dark, scroll, compact, and Pro Max; perform four measured source-changing warm reloads. Commit
`feat(foundry): reconstruct Today root overview`.

### Task 04 — Full Day

Exact files:

- Create `Packages/AmbitionsPresentation/Sources/AmbitionsNativeVisualFoundry/TodayOpenContinuityFullDayView.swift`
- Modify `Packages/AmbitionsPresentation/Sources/AmbitionsNativeVisualFoundry/TodayFlagshipCalibrationContent.swift`
- Modify `Packages/AmbitionsPresentation/Sources/AmbitionsNativeVisualFoundry/TodayFlagshipJourneyState.swift`
- Modify `Packages/AmbitionsPresentation/Sources/AmbitionsNativeVisualFoundry/TodayFlagshipCalibrationView.swift`
- Modify `Packages/AmbitionsPresentation/Sources/AmbitionsNativeVisualFoundry/TodayFlagshipCalibrationPreviews.swift`
- Modify `Native/AmbitionsNativeFoundryHost/AmbitionsNativeFoundryHostApp.swift`
- Modify `Packages/AmbitionsPresentation/Tests/AmbitionsNativeVisualFoundryTests/TodayFlagshipJourneyStateTests.swift`
- Modify `Packages/AmbitionsPresentation/Tests/AmbitionsNativeVisualFoundryTests/TodayFlagshipCalibrationFixtureTests.swift`
- Modify `Native/AmbitionsNativeFoundryHostUITests/TodayFlagshipCalibrationHostUITests.swift`

Required APIs are `TodayFlagshipRoute.fullDay(origin:)`, `openFullDay()`,
`openStepFromFullDay(id:)`, and `reconcileNavigationPath(_:)` exactly as the
design specification defines. RED test content asserts:

```swift
XCTAssertTrue(state.openFullDay())
XCTAssertEqual(state.navigationPath, [.fullDay(origin: .todayInitial)])
XCTAssertEqual(state.acceptedTruth, priorTruth)
XCTAssertTrue(state.openStepFromFullDay(id: content.primaryStep.id))
XCTAssertEqual(state.navigationPath, [.fullDay(origin: .todayInitial), .step(id: content.primaryStep.id)])
```

UI RED asserts Full Day exposes all fixture objects, Scroll to Now, native Back,
and no edit/grid/Open in Time. A second RED starts from `.todayReturned`, opens
Full Day with `.todayReturned` origin, rejects every Step open, preserves
settled truth/phase, asserts `nowAnchorObjectID(for: .todayReturned)` equals
`step.send-launch-brief`, asserts the revealed Start Here owns the visible Now
row while the nursery Step remains settled/subordinate/read-only, and restores
returned-Today focus on Back. GREEN implements an origin-specific
`nowAnchorObjectID(for:)`, read-only `ScrollViewReader` depth, and exact focus
restoration. Render typical, returned, dense, very dense, RTL, compact, and Accessibility 5. Commit
`feat(foundry): add read-only Today full day`.

### Task 05 — Focused Step

Exact files:

- Create `Packages/AmbitionsPresentation/Sources/AmbitionsNativeVisualFoundry/TodayOpenContinuityFocusedObject.swift`
- Modify `Packages/AmbitionsPresentation/Sources/AmbitionsNativeVisualFoundry/TodayFlagshipFocusedStepView.swift`
- Modify `Packages/AmbitionsPresentation/Sources/AmbitionsNativeVisualFoundry/TodayFlagshipCalibrationPreviews.swift`
- Modify `Native/AmbitionsNativeFoundryHost/AmbitionsNativeFoundryHostApp.swift`
- Modify `Packages/AmbitionsPresentation/Tests/AmbitionsNativeVisualFoundryTests/TodayFlagshipCalibrationFixtureTests.swift`
- Modify `Native/AmbitionsNativeFoundryHostUITests/TodayFlagshipCalibrationHostUITests.swift`

RED adds `testB02FocusedStepUsesOneNaturalDepthAndOneOutcome()` checking stable
identity, parent Goal, current truth, why/protection/time order, exactly one
Still Counts, and absence of centered Start Here navigation title/passive
outcomes. GREEN moves content to one natural scroll and anchors the action.
Render typical, dense, Accessibility 5, RTL, contrast, and long LTR; perform
four measured warm reloads. Commit `feat(foundry): reconstruct focused step`.

### Task 06 — Consequential review and saving

Exact files:

- Create `Packages/AmbitionsPresentation/Sources/AmbitionsNativeVisualFoundry/TodayOpenContinuityTruthFlow.swift`
- Modify `Packages/AmbitionsPresentation/Sources/AmbitionsNativeVisualFoundry/TodayFlagshipReviewView.swift`
- Modify `Native/AmbitionsNativeFoundryHost/AmbitionsNativeFoundryHostApp.swift`
- Modify `Packages/AmbitionsPresentation/Tests/AmbitionsNativeVisualFoundryTests/TodayFlagshipJourneyStateTests.swift`
- Modify `Native/AmbitionsNativeFoundryHostUITests/TodayFlagshipCalibrationHostUITests.swift`

Required interfaces:

```swift
struct TodayOpenContinuityTruthComparison: View
struct TodayOpenContinuityCommitBar: View
struct TodayOpenContinuitySavingSeam: View
```

RED asserts labelled current/proposed nodes, no color-only equivalence, visible
standard identity/consequence/relationship/Details/actions, vertical actions at
Accessibility 5, duplicate-commit prevention, and saving with accepted truth
still visible. GREEN preserves the full-screen cover and safe-area action
architecture. Render standard, Accessibility 5, contrast, no-color, RTL, and
Reduce Motion. Commit `feat(foundry): articulate review and saving`.

### Task 07 — Settlement and return

Exact files:

- Modify `Packages/AmbitionsPresentation/Sources/AmbitionsNativeVisualFoundry/TodayOpenContinuityTruthFlow.swift`
- Modify `Packages/AmbitionsPresentation/Sources/AmbitionsNativeVisualFoundry/TodayOpenContinuityRoot.swift`
- Modify `Packages/AmbitionsPresentation/Sources/AmbitionsNativeVisualFoundry/TodayFlagshipFocusedStepView.swift`
- Modify `Packages/AmbitionsPresentation/Sources/AmbitionsNativeVisualFoundry/TodayFlagshipCalibrationView.swift`
- Modify `Native/AmbitionsNativeFoundryHost/AmbitionsNativeFoundryHostApp.swift`
- Modify `Packages/AmbitionsPresentation/Tests/AmbitionsNativeVisualFoundryTests/TodayFlagshipJourneyStateTests.swift`
- Modify `Packages/AmbitionsPresentation/Tests/AmbitionsNativeVisualFoundryTests/TodayFlagshipCalibrationFixtureTests.swift`
- Modify `Native/AmbitionsNativeFoundryHostUITests/TodayFlagshipCalibrationHostUITests.swift`

RED asserts settled truth precedes evidence, History round trip is non-mutating,
Return is explicit, no success ceremony tokens exist, revealed Step count is
one, nursery Step remains, and focus anchor is exact. GREEN adds resolved spine,
compact evidence, explicit return, compact settled row, and updated overview.
Render settlement/history/return/low-brightness/compact/Pro Max. Commit
`feat(foundry): compose settlement and truthful return`.

### Task 08 — Recovery and resilience

Exact files:

- Modify `Packages/AmbitionsPresentation/Sources/AmbitionsNativeVisualFoundry/TodayFlagshipCalibrationContent.swift`
- Modify `Packages/AmbitionsPresentation/Sources/AmbitionsNativeVisualFoundry/TodayFlagshipCalibrationFixture.swift`
- Modify `Packages/AmbitionsPresentation/Sources/AmbitionsNativeVisualFoundry/TodayFlagshipRecoveryReviewView.swift`
- Modify `Packages/AmbitionsPresentation/Sources/AmbitionsNativeVisualFoundry/TodayOpenContinuityFocusedObject.swift`
- Modify `Packages/AmbitionsPresentation/Sources/AmbitionsNativeVisualFoundry/TodayFlagshipCalibrationPreviews.swift`
- Modify `Native/AmbitionsNativeFoundryHost/AmbitionsNativeFoundryHostApp.swift`
- Modify `Packages/AmbitionsPresentation/Tests/AmbitionsNativeVisualFoundryTests/TodayFlagshipCalibrationFixtureTests.swift`
- Modify `Native/AmbitionsNativeFoundryHostUITests/TodayFlagshipCalibrationHostUITests.swift`

Required snapshot interfaces are `TodayFlagshipTimelineRole` including `.now`,
`TodayFlagshipContextCondition`, and `TodayFlagshipContextSeamSnapshot` from the
design specification. RED asserts exact conditions/owners/copy/accessibility,
no inferred condition, no unsupported control/Undo, and unchanged recovery
effects. GREEN implements the native recovery sheet and read-only seams. Render
quiet, dense, very dense, offline, stale, conflict, recovery, and deferral.
Commit `feat(foundry): articulate recovery and resilient truth`.

### Task 09 — Motion and haptics

Exact files:

- Modify `Packages/AmbitionsPresentation/Sources/AmbitionsNativeVisualFoundry/TodayOpenContinuityGrammar.swift`
- Modify `Packages/AmbitionsPresentation/Sources/AmbitionsNativeVisualFoundry/TodayOpenContinuitySpine.swift`
- Modify `Packages/AmbitionsPresentation/Sources/AmbitionsNativeVisualFoundry/TodayOpenContinuityRoot.swift`
- Modify `Packages/AmbitionsPresentation/Sources/AmbitionsNativeVisualFoundry/TodayOpenContinuityTimeline.swift`
- Modify `Packages/AmbitionsPresentation/Sources/AmbitionsNativeVisualFoundry/TodayOpenContinuityFocusedObject.swift`
- Modify `Packages/AmbitionsPresentation/Sources/AmbitionsNativeVisualFoundry/TodayOpenContinuityTruthFlow.swift`
- Modify `Packages/AmbitionsPresentation/Sources/AmbitionsNativeVisualFoundry/TodayFlagshipCalibrationView.swift`
- Modify `Native/AmbitionsNativeFoundryHost/AmbitionsNativeFoundryHostApp.swift`
- Modify `Packages/AmbitionsPresentation/Tests/AmbitionsNativeVisualFoundryTests/TodayFlagshipCalibrationFixtureTests.swift`
- Create `docs/qa/evidence/2026-07-23-today-open-continuity-field-b02-r00/motion-and-haptics.md`

Required interface:

```swift
struct TodayOpenContinuityMotionPolicy {
    let reduceMotion: Bool
    var stateAnimation: Animation? { get }
}
```

RED asserts Reduce Motion yields no spatial/spring/blur animation and keeps
static node semantics. GREEN adds restrained `sensoryFeedback` triggers for
selection, commitment, and settlement without sole-meaning dependence. Perform
four motion/material warm reloads with all five required measurements. Render
and record normal/Reduce Motion. Commit `feat(foundry): calibrate continuity motion`.

### Task 10 — Accessibility and adaptivity

Exact files:

- Modify `Packages/AmbitionsPresentation/Sources/AmbitionsNativeVisualFoundry/TodayOpenContinuityGrammar.swift`
- Modify `Packages/AmbitionsPresentation/Sources/AmbitionsNativeVisualFoundry/TodayOpenContinuitySpine.swift`
- Modify `Packages/AmbitionsPresentation/Sources/AmbitionsNativeVisualFoundry/TodayOpenContinuityRoot.swift`
- Modify `Packages/AmbitionsPresentation/Sources/AmbitionsNativeVisualFoundry/TodayOpenContinuityTimeline.swift`
- Modify `Packages/AmbitionsPresentation/Sources/AmbitionsNativeVisualFoundry/TodayOpenContinuityFullDayView.swift`
- Modify `Packages/AmbitionsPresentation/Sources/AmbitionsNativeVisualFoundry/TodayOpenContinuityFocusedObject.swift`
- Modify `Packages/AmbitionsPresentation/Sources/AmbitionsNativeVisualFoundry/TodayOpenContinuityTruthFlow.swift`
- Modify `Packages/AmbitionsPresentation/Sources/AmbitionsNativeVisualFoundry/TodayFlagshipNavigationChrome.swift`
- Modify `Packages/AmbitionsPresentation/Sources/AmbitionsNativeVisualFoundry/TodayFlagshipRecoveryReviewView.swift`
- Modify `Packages/AmbitionsPresentation/Sources/AmbitionsNativeVisualFoundry/TodayFlagshipCalibrationPreviews.swift`
- Modify `Native/AmbitionsNativeFoundryHost/AmbitionsNativeFoundryHostApp.swift`
- Modify `Packages/AmbitionsPresentation/Tests/AmbitionsNativeVisualFoundryTests/TodayFlagshipCalibrationFixtureTests.swift`
- Modify `Native/AmbitionsNativeFoundryHostUITests/TodayFlagshipCalibrationHostUITests.swift`
- Modify `docs/qa/evidence/2026-07-23-today-open-continuity-field-b02-r00/accessibility-review.md`
- Modify `docs/qa/evidence/2026-07-23-today-open-continuity-field-b02-r00/adaptivity-review.md`
- Create `docs/qa/evidence/2026-07-23-today-open-continuity-field-b02-r00/performance-review.md`

RED covers `.accessibility5`, vertical review actions, complete Arabic copy,
logical semantic order, state announcements/focus metadata, every 44-point
target, no-color/contrast/opaque chrome, compact/Pro Max/narrow/wide widths,
native indicators, distinct Voice Control names, and long LTR. GREEN makes only
the required adaptive transformations. Commit
`feat(foundry): complete adaptive Today transformations`.

### Task 11 — Automated validation owner

Exact files:

- Modify `Packages/AmbitionsPresentation/Tests/AmbitionsNativeVisualFoundryTests/TodayBootstrapFixtureTests.swift`
- Modify `Packages/AmbitionsPresentation/Tests/AmbitionsNativeVisualFoundryTests/TodayFlagshipCalibrationFixtureTests.swift`
- Modify `Packages/AmbitionsPresentation/Tests/AmbitionsNativeVisualFoundryTests/TodayFlagshipJourneyStateTests.swift`
- Create `.superpowers/sdd/b02-task-11-report.md`

Task 11 may not modify product or Foundry source. A reproducible source defect
is returned to the named owning implementation task for a bounded repair and
fresh review. Run all 35 owner-required B02 assertions plus all R01/R02/B01
tests. Classify failures; never weaken tests. Commit only focused guards as
`test(foundry): lock open continuity behavior`.

### Task 12 — Evidence and metadata owner

Exact path:
`docs/qa/evidence/2026-07-23-today-open-continuity-field-b02-r00/` only. All
fixture-host states and accessibility launch arguments must already exist and
be committed by Tasks 02–10; Task 12 may not modify a host or Swift source file.
Capture from `AmbitionsNativeFoundryHost`, never the production app. Produce the
exact Phase 9 inventory below, validate all metadata/hashes, and commit
`docs(qa): package Today open continuity evidence`.

### Per-task RED/GREEN command map

Each command is run once before implementation with the named new assertion
expected to fail, and again after the minimal implementation with all selected
tests expected to pass.

```sh
# Task 01
swift test --package-path Packages/AmbitionsPresentation --filter TodayFlagshipCalibrationFixtureTests/testB02GrammarUsesSystemTypeMatteContentAndNonColorNodes

# Task 02
xcodebuild -project Ambitions.xcodeproj -scheme AmbitionsNativeFoundryHost -destination 'platform=iOS Simulator,id=EDE1E954-C663-47FB-855B-95F96AE2DBDD' test -only-testing:AmbitionsNativeFoundryHostUITests/TodayFlagshipCalibrationHostUITests/testB02CrownIsRootOnlyAndDockKeepsLockedGroups -only-testing:AmbitionsNativeFoundryHostUITests/TodayFlagshipCalibrationHostUITests/testB02DockPeekHasIntentionalMinimumTarget CODE_SIGNING_ALLOWED=NO

# Task 03
swift test --package-path Packages/AmbitionsPresentation --filter TodayFlagshipCalibrationFixtureTests/testB02OverviewSelectionIsDeterministicAndBounded
xcodebuild -project Ambitions.xcodeproj -scheme AmbitionsNativeFoundryHost -destination 'platform=iOS Simulator,id=EDE1E954-C663-47FB-855B-95F96AE2DBDD' test -only-testing:AmbitionsNativeFoundryHostUITests/TodayFlagshipCalibrationHostUITests/testB02RootUsesOneStartHereAndFourOverviewAnchors CODE_SIGNING_ALLOWED=NO

# Task 04
swift test --package-path Packages/AmbitionsPresentation --filter TodayFlagshipJourneyStateTests/testFullDayRoutePreservesTruthAndNestedBackContext
xcodebuild -project Ambitions.xcodeproj -scheme AmbitionsNativeFoundryHost -destination 'platform=iOS Simulator,id=EDE1E954-C663-47FB-855B-95F96AE2DBDD' test -only-testing:AmbitionsNativeFoundryHostUITests/TodayFlagshipCalibrationHostUITests/testB02FullDayIsReadOnlyCompleteAndReturnsNatively CODE_SIGNING_ALLOWED=NO

# Task 05
xcodebuild -project Ambitions.xcodeproj -scheme AmbitionsNativeFoundryHost -destination 'platform=iOS Simulator,id=EDE1E954-C663-47FB-855B-95F96AE2DBDD' test -only-testing:AmbitionsNativeFoundryHostUITests/TodayFlagshipCalibrationHostUITests/testB02FocusedStepUsesOneNaturalDepthAndOneOutcome CODE_SIGNING_ALLOWED=NO

# Task 06
xcodebuild -project Ambitions.xcodeproj -scheme AmbitionsNativeFoundryHost -destination 'platform=iOS Simulator,id=EDE1E954-C663-47FB-855B-95F96AE2DBDD' test -only-testing:AmbitionsNativeFoundryHostUITests/TodayFlagshipCalibrationHostUITests/testB02ReviewComparesTruthAndSavingPreservesIt CODE_SIGNING_ALLOWED=NO

# Task 07
swift test --package-path Packages/AmbitionsPresentation --filter TodayFlagshipJourneyStateTests/testReturnProjectsSettledStepAndNewTruthfulStartHereWithContinuityFocus
xcodebuild -project Ambitions.xcodeproj -scheme AmbitionsNativeFoundryHost -destination 'platform=iOS Simulator,id=EDE1E954-C663-47FB-855B-95F96AE2DBDD' test -only-testing:AmbitionsNativeFoundryHostUITests/TodayFlagshipCalibrationHostUITests/testB02SettlementAndReturnPreserveIdentityWithoutCeremony CODE_SIGNING_ALLOWED=NO

# Task 08
swift test --package-path Packages/AmbitionsPresentation --filter TodayFlagshipCalibrationFixtureTests/testB02ResilienceSnapshotsAreExplicitAndNonMutating
xcodebuild -project Ambitions.xcodeproj -scheme AmbitionsNativeFoundryHost -destination 'platform=iOS Simulator,id=EDE1E954-C663-47FB-855B-95F96AE2DBDD' test -only-testing:AmbitionsNativeFoundryHostUITests/TodayFlagshipCalibrationHostUITests/testB02RecoveryAndResilienceStayObjectScoped CODE_SIGNING_ALLOWED=NO

# Task 09
swift test --package-path Packages/AmbitionsPresentation --filter TodayFlagshipCalibrationFixtureTests/testB02ReduceMotionKeepsStaticStateMeaning

# Task 10
xcodebuild -project Ambitions.xcodeproj -scheme AmbitionsNativeFoundryHost -destination 'platform=iOS Simulator,id=EDE1E954-C663-47FB-855B-95F96AE2DBDD' test -only-testing:AmbitionsNativeFoundryHostUITests/TodayFlagshipCalibrationHostUITests/testB02AccessibilityAndAdaptivityMatrix CODE_SIGNING_ALLOWED=NO

# Task 11 and final GREEN
swift test --package-path Packages/AmbitionsPresentation
xcodebuild -project Ambitions.xcodeproj -scheme AmbitionsNativeFoundryHost -destination 'platform=iOS Simulator,id=EDE1E954-C663-47FB-855B-95F96AE2DBDD' test CODE_SIGNING_ALLOWED=NO
```

## Phase 0 — Research, specification, and plan

Files: B02 evidence research/contract records, design specification, this plan,
and B02 `.superpowers/sdd` progress records.

- [x] Verify/fetch repository state; close B01; create B02 from exact clean SHA.
- [x] Hash and inspect B01 and owner boards.
- [x] Run baseline Foundry target build and all 31 package tests.
- [x] Dispatch repository, reference, Apple, market, and accessibility agents.
- [x] Write reference translation, maps, branch contract, fixture inventory,
  assumptions, changed-path envelope, research, design spec, and plan.
- [x] Run fresh Phase 0 specification and quality reviews; repair blockers.
- [ ] Commit `docs(foundry): specify Today open continuity field`.

Phase check: Foundry target build, all package tests, `git diff --check`.

## Phase 1 — Test scaffold and provisional grammar

Test files:

- `Packages/AmbitionsPresentation/Tests/AmbitionsNativeVisualFoundryTests/TodayFlagshipCalibrationFixtureTests.swift`
- `Packages/AmbitionsPresentation/Tests/AmbitionsNativeVisualFoundryTests/TodayFlagshipJourneyStateTests.swift`
- `Native/AmbitionsNativeFoundryHostUITests/TodayFlagshipCalibrationHostUITests.swift`

Implementation files:

- Create `TodayOpenContinuityGrammar.swift`
- Create `TodayOpenContinuitySpine.swift`
- Refactor `TodayFlagshipCalibrationStyle.swift`
- Refactor `TodayFlagshipArticulatedAnatomy.swift`

- [ ] Add failing source/unit guards only for local semantic roles, system
  typography, matte surfaces, action roles, icon discipline, Continuity Spine,
  motion policy, non-color node distinctions, no custom font/tab bar/unsupported
  outcome, and no global design-system import.
- [ ] Record RED; preserve existing R01/R02/B01 assertions.
- [ ] Implement only the local palette/type/surface/action/icon/spine/motion
  contracts needed by the tests.
- [ ] Render grammar in Light, Dark, Increased Contrast, Differentiate Without
  Color, and Dynamic Type.
- [ ] Run two reviewers, repair, test, lint, and commit
  `feat(foundry): establish open continuity grammar`.

## Phase 2 — Crown, dock, root, overview

Files: create `Packages/AmbitionsPresentation/Sources/AmbitionsNativeVisualFoundry/TodayOpenContinuityRoot.swift`
and `Packages/AmbitionsPresentation/Sources/AmbitionsNativeVisualFoundry/TodayOpenContinuityTimeline.swift`;
modify `TodayFlagshipCalibrationContent.swift`, `TodayFlagshipCalibrationFixture.swift`,
`TodayFlagshipCalibrationView.swift`, `TodayFlagshipNavigationChrome.swift`,
`TodayFlagshipCalibrationPreviews.swift`, the fixture host, and UI/package tests.

- [ ] Add failing tests for root-only wordmark, Today accessibility heading,
  first-viewport action, overview budget at most four, no Start Here duplicate,
  four-root/global grouping, 44-point Peek, non-color selection, no bottom tabs,
  and natural scrolling with stable shell.
- [ ] Implement crown and scroll condensation without crown Search/Capture.
- [ ] Recompose Start Here into one open-plane object with current truth,
  synthesized fit/protection, time, and centered continuation.
- [ ] Implement Now/next fixed/protected/open-or-later overview anchors.
- [ ] Reconstruct Peek and expanded dock appearance only; preserve behavior.
- [ ] Run four source-changing warm reloads.
- [ ] Render Light/Dark/scroll/dock/passage/compact/Pro Max at full, half, and
  contact scale.
- [ ] Review shell/crown/dock twice, repair, test, and commit
  `feat(foundry): reconstruct crown and edge dock`.
- [ ] Review root/overview twice, repair, test, and commit
  `feat(foundry): reconstruct Today root overview`.

Phase 2 is an integration checkpoint spanning the two non-overlapping Task 02
and Task 03 commits above; it does not introduce a third combined commit or a
different file boundary.

## Phase 3 — Read-only Full Day depth

Files: create `Packages/AmbitionsPresentation/Sources/AmbitionsNativeVisualFoundry/TodayOpenContinuityFullDayView.swift`;
modify `TodayFlagshipCalibrationContent.swift`, `TodayFlagshipCalibrationFixture.swift`,
`TodayFlagshipJourneyState.swift`, `TodayFlagshipCalibrationView.swift`, previews,
host, and state/package/UI tests.

- [ ] Add failing tests for `openFullDay()`, `openStepFromFullDay(id:)`, and
  `reconcileNavigationPath(_:)`: Full Day is non-mutating; a supported Step
  retains `.fullDay` beneath it; Back Step→Full Day and Full Day→Today restores
  the correct focus; complete chronology exists only in depth; Scroll to Now
  works; initial Now is the nursery Step; returned Now is
  `step.send-launch-brief` while the nursery Step remains settled and read-only;
  no edit/calendar grid/fabricated Time route exists.
- [ ] Implement the read-only route with stable IDs, native navigation,
  `ScrollViewReader`, and the shared timeline anatomy.
- [ ] Allow navigation only for source-backed Step rows.
- [ ] Render typical/dense/very-dense/compact/RTL/Dynamic Type.
- [ ] Review twice for Today-vs-Time ownership, repair, test, and commit
  `feat(foundry): add read-only Today full day depth`.

## Phase 4 — Focused Step

Files: create `TodayOpenContinuityFocusedObject.swift`; modify focused view,
previews, host, and tests.

- [ ] Add failing tests for native Back, no centered Start Here title, stable
  identity, parent Goal, current truth, why now, protected consequence, time,
  one Still Counts action, semantic order, and first-viewport reachability.
- [ ] Remove nested scrolling and compose one natural object depth.
- [ ] Render typical/dense/Accessibility 5/Arabic RTL/contrast/long LTR.
- [ ] Run four deep warm reloads.
- [ ] Review twice, repair, test, and commit
  `feat(foundry): reconstruct focused Today step`.

## Phase 5 — Review and saving

Files: create `TodayOpenContinuityTruthFlow.swift`; modify review view, host, and
tests.

- [ ] Add failing tests for spatial current/proposed comparison, non-color
  distinction, visible standard-size identity/consequence/relationship/actions,
  collapsed Details, no internal language, persistent saving comparison,
  duplicate-commit prevention, announcement, and no premature success styling.
- [ ] Implement comparison in the existing full-screen cover and keep native
  safe-area `Not Now`/`Record Progress` actions.
- [ ] Activate only the connector and native progress while saving.
- [ ] Add restrained selection/commit feedback and Reduce Motion equivalent.
- [ ] Render standard/Accessibility 5/contrast/no-color/Reduce Motion/RTL.
- [ ] Review twice, repair, test, and commit
  `feat(foundry): articulate review and saving continuity`.

## Phase 6 — Settlement and returned Today

Files: modify truth-flow/root/focused/calibration views, host, and tests.

- [ ] Add failing tests that settled truth leads; History is secondary and
  non-mutating; Return is explicit; no success ceremony appears; revealed Step
  appears once; nursery Step remains; focus resolves to return anchor; overview
  updates without reward-feed anatomy.
- [ ] Implement resolved spine, dominant settled truth, subordinate evidence,
  explicit Return, compact settled timeline row, and unique new Start Here.
- [ ] Render settlement/History/return/low-brightness/compact/Pro Max.
- [ ] Review twice, repair, test, and commit
  `feat(foundry): compose settlement and truthful return`.

## Phase 7 — Recovery and resilient truth

Files: modify recovery/focused views, presentation-only fixture helpers, host,
previews, and tests.

- [ ] Add failing tests for retained identity/truth/progress, exact continue and
  deferral effects, truthful dismissal/focus, and absence of unsupported Undo or
  outcome controls.
- [ ] Recompose existing native recovery sheet around the interrupted spine.
- [ ] Extend the immutable snapshot contract with explicit timeline roles and
  context-seam condition fields, then add quiet, dense, very-dense, offline
  local, stale external, and read-only conflict-transfer fixtures. Do not infer
  state from copy and do not add commands not present in the fixture contract.
- [ ] Render all states and semantic orders.
- [ ] Review twice, repair, test, and commit
  `feat(foundry): articulate recovery and resilient truth`.

## Phase 8 — Accessibility, adaptivity, motion, performance

- [ ] Verify standard and Accessibility 5, VoiceOver order/actions/announcements,
  contrast, no-color, transparency, motion, Button Shapes, Bold Text, genuine
  RTL, long LTR, compact/Pro/Pro Max, narrow/wide resizable, safe areas, and
  keyboard state only if real input exists.
- [ ] Assert every interactive control is at least 44 by 44 and Voice Control
  names are distinct.
- [ ] Verify native Back, sheet/cover dismissal, and focus handoffs.
- [ ] Run SwiftUI performance audit for observation scope, IDs, lazy containers,
  scroll work, material cost, animation invalidation, and symbols.
- [ ] Run ETTrace only for observed symptoms and Memgraph only for suspicious
  growth; document why either is skipped.
- [ ] Run cached host build and full fixture-host behavior suite.
- [ ] Review Task 09 twice, repair, test, and commit
  `feat(foundry): calibrate continuity motion`.
- [ ] Review Task 10 twice, repair, test, and commit
  `feat(foundry): complete adaptive Today transformations`.
- [ ] Review Task 11 twice, repair, run the complete scoped suite, and commit
  `test(foundry): lock open continuity behavior`.

Phase 8 is an integration checkpoint spanning those three ordered commits. It
does not replace them with a combined accessibility/performance commit.

## Phase 9 — Media, validation, handoff

- [ ] Capture 16 TFCS frames plus quiet, very dense, Full Day, low-brightness,
  Reduce Transparency, compact, Pro Max, and narrow resizable frames from the
  Foundry host only.
- [ ] Produce C01 full matrix, C02 B01 comparison, C03 owner-reference
  translation, and C04 accessibility transformations.
- [ ] Record J01 success/Full Day, J02 recovery, J03 Accessibility Dynamic Type,
  J04 dock/scroll, and J05 Reduce Motion; inspect every transition.
- [ ] Validate size/dimensions/duration/hash/SHA/fixture/device/OS/settings and
  `production_baseline=false` for every artifact.
- [ ] Record 12 source-changing warm reloads, cached host build, and host launch;
  no clean build.
- [ ] Assign the four motion/material source-changing warm runs in Phase 8 and
  record elapsed time, success, visible change, host relaunch, and clean-build
  requirement for each.
- [ ] Score all 15 quality categories; repair if any is below 4 or average below
  4.4.
- [ ] Run final specification/quality reviewers and broad code review; repair.
- [ ] Run target build, all package tests, host build/UI suite, SwiftLint, canon
  build/check/compiler tests, boundary/direct-write/weak/Gitleaks scans, metadata
  validators, reference validation, changed-path/authority audits, diff check,
  and final worktree inspection.
- [ ] Confirm main/canon/app/runtime/legacy/dependencies/Figma/Code Connect/
  baselines unchanged and branch unmerged/unpushed.
- [ ] Set owner review to `READY_FOR_OWNER_REVIEW`, commit, and leave clean.

### Exact Phase 9 evidence inventory

All paths are beneath
`docs/qa/evidence/2026-07-23-today-open-continuity-field-b02-r00/`:

- Markdown: `README.md`, `owner-input.md`, `b01-owner-decision.md`,
  `structural-branch-contract.md`, `repository-map.md`,
  `canon-ownership-map.md`, `apple-platform-research.md`,
  `market-benchmark.md`, `reference-translation.md`,
  `design-specification.md`, `implementation-plan.md`, `visual-grammar.md`,
  `typography-system.md`, `color-and-material-system.md`, `action-system.md`,
  `iconography-system.md`, `motion-and-haptics.md`,
  `accessibility-review.md`, `adaptivity-review.md`, `performance-review.md`,
  `fixture-contract.md`, `before-after.md`,
  `owner-reference-comparison.md`, `quality-scorecard.md`,
  `reviewer-findings.md`, `validation-results.md`, `benchmark-report.md`,
  `changed-files.md`, `known-limitations.md`, `owner-review.md`, and
  `command-log.md`.
- JSON: `screenshot-metadata.json`, `recording-metadata.json`,
  `comparison-metadata.json`, `reference-image-hashes.json`.
- Primary screenshots: `screenshots/TFCS-F01-today-light.png`,
  `screenshots/TFCS-F02-today-dark.png`,
  `screenshots/TFCS-F03-natural-scroll.png`,
  `screenshots/TFCS-F04-expanded-dock.png`,
  `screenshots/TFCS-F05-adaptive-navigation-passage.png`,
  `screenshots/TFCS-F06-focused-step.png`,
  `screenshots/TFCS-F07-consequential-review.png`,
  `screenshots/TFCS-F08-settlement.png`,
  `screenshots/TFCS-F09-returned-today.png`, and
  `screenshots/TFCS-F10-interrupted-recovery.png`.
- Supporting screenshots: `supporting-state/TFCS-S01-saving.png`,
  `supporting-state/TFCS-S02-cancelled-unchanged.png`,
  `supporting-state/TFCS-S03-saved-interrupted-progress.png`,
  `supporting-state/TFCS-S04-dense-today.png`,
  `supporting-state/TFCS-S05-genuine-rtl.png`, and
  `supporting-state/TFCS-S06-increased-contrast-review.png`.
- Additional required screenshots: `stress/B02-Q01-quiet-day.png`,
  `stress/B02-D01-very-dense-day.png`, `stress/B02-T01-full-day.png`,
  `stress/B02-L01-low-brightness-dark.png`,
  `stress/B02-A01-reduce-transparency.png`,
  `stress/B02-CI01-compact-iphone.png`,
  `stress/B02-PM01-pro-max.png`,
  `stress/B02-RS01-narrow-resizable.png`.
- Diagnostic accessibility screenshots required for C04:
  `stress/B02-A02-differentiate-without-color.png` and
  `stress/B02-A03-long-localization.png`.
- Recordings: `recordings/TFCS-J01-success-full-day.mov`,
  `recordings/TFCS-J02-recovery.mov`,
  `recordings/TFCS-J03-accessibility-dynamic-type.mov`,
  `recordings/TFCS-J04-dock-and-scroll.mov`, and
  `recordings/TFCS-J05-reduce-motion.mov`.
- Contact sheets: `contact-sheets/B02-C01-full-matrix.png`,
  `contact-sheets/B02-C02-b01-comparison.png`,
  `contact-sheets/B02-C03-owner-reference-translation.png`, and
  `contact-sheets/B02-C04-accessibility-transformations.png`.

Every media metadata row includes ID, relative path, bytes, SHA-256, repository
SHA, fixture ID, device, OS, appearance, content size, accessibility settings,
duration where applicable, and `production_baseline: false`.

### Exact validation command appendix

```sh
swift build --package-path Packages/AmbitionsPresentation --target AmbitionsNativeVisualFoundry
swift test --package-path Packages/AmbitionsPresentation
xcodegen generate
xcodebuild -project Ambitions.xcodeproj -scheme AmbitionsNativeFoundryHost -destination 'platform=iOS Simulator,id=EDE1E954-C663-47FB-855B-95F96AE2DBDD' build CODE_SIGNING_ALLOWED=NO
xcodebuild -project Ambitions.xcodeproj -scheme AmbitionsNativeFoundryHost -destination 'platform=iOS Simulator,id=EDE1E954-C663-47FB-855B-95F96AE2DBDD' test CODE_SIGNING_ALLOWED=NO
git diff --name-only 92048f7622b06f78ee6e5667e84facd0c4beb2f4 HEAD -- '*.swift' | xargs swiftlint lint --strict
python3 scripts/ambitions-canon.py build
python3 scripts/ambitions-canon.py check
python3 -m unittest discover -s tools/tests -p 'test_ambitions_canon_compiler.py'
python3 scripts/ambitions-local-first-boundary-scan.py
python3 scripts/ambitions-runtime-direct-write-audit.py
python3 scripts/ci/ambitions-no-weak-implementation-scan.py
bash scripts/ci/ambitions-gitleaks-scan.sh
GITHUB_BASE_SHA=92048f7622b06f78ee6e5667e84facd0c4beb2f4 bash scripts/ci/ambitions-gitleaks-scan.sh --range-only
jq -e --argjson expected '["TFCS-F01","TFCS-F02","TFCS-F03","TFCS-F04","TFCS-F05","TFCS-F06","TFCS-F07","TFCS-F08","TFCS-F09","TFCS-F10","TFCS-S01","TFCS-S02","TFCS-S03","TFCS-S04","TFCS-S05","TFCS-S06","B02-Q01","B02-D01","B02-T01","B02-L01","B02-A01","B02-CI01","B02-PM01","B02-RS01","B02-A02","B02-A03"]' '. as $m | ($m.production_baseline == false) and ($m.render_source_sha | test("^[0-9a-f]{40}$")) and ([.screenshots[].id] | sort == ($expected | sort)) and ([.screenshots[].id] | unique | length == 26) and ([.screenshots[].path] | unique | length == 26) and all(.screenshots[]; .production_baseline == false and (.path | type == "string" and length > 0) and (.bytes | type == "number") and .bytes > 0 and (.sha256 | test("^[0-9a-f]{64}$")) and (.width | type == "number") and .width > 0 and (.height | type == "number") and .height > 0 and .repository_sha == $m.render_source_sha and .fixture_id == "today-flagship/preparing-for-baby/still-counts/v1" and (.device | type == "string" and length > 0) and (.os | type == "string" and length > 0) and (.appearance | type == "string" and length > 0) and (.content_size | type == "string" and length > 0) and (.accessibility_settings | type == "object"))' docs/qa/evidence/2026-07-23-today-open-continuity-field-b02-r00/screenshot-metadata.json
jq -e --argjson expected '["TFCS-J01","TFCS-J02","TFCS-J03","TFCS-J04","TFCS-J05"]' '. as $m | ($m.production_baseline == false) and ($m.render_source_sha | test("^[0-9a-f]{40}$")) and ([.recordings[].id] | sort == ($expected | sort)) and ([.recordings[].id] | unique | length == 5) and ([.recordings[].path] | unique | length == 5) and all(.recordings[]; .production_baseline == false and (.path | type == "string" and length > 0) and (.bytes | type == "number") and .bytes > 0 and (.sha256 | test("^[0-9a-f]{64}$")) and (.duration_seconds | type == "number") and .duration_seconds > 0 and .repository_sha == $m.render_source_sha and .fixture_id == "today-flagship/preparing-for-baby/still-counts/v1" and (.device | type == "string" and length > 0) and (.os | type == "string" and length > 0) and (.appearance | type == "string" and length > 0) and (.content_size | type == "string" and length > 0) and (.accessibility_settings | type == "object"))' docs/qa/evidence/2026-07-23-today-open-continuity-field-b02-r00/recording-metadata.json
jq -e --argjson expected '["B02-C01","B02-C02","B02-C03","B02-C04"]' '. as $m | ($m.render_source_sha | test("^[0-9a-f]{40}$")) and ([.comparisons[].id] | sort == ($expected | sort)) and ([.comparisons[].id] | unique | length == 4) and ([.comparisons[].path] | unique | length == 4) and all(.comparisons[]; .production_baseline == false and (.path | type == "string" and length > 0) and (.bytes | type == "number") and .bytes > 0 and (.sha256 | test("^[0-9a-f]{64}$")) and (.width | type == "number") and .width > 0 and (.height | type == "number") and .height > 0 and .repository_sha == $m.render_source_sha and .fixture_id == "today-flagship/preparing-for-baby/still-counts/v1")' docs/qa/evidence/2026-07-23-today-open-continuity-field-b02-r00/comparison-metadata.json
jq -s -e '([.[0].screenshots[].path, .[1].recordings[].path, .[2].comparisons[].path] | flatten) as $paths | ($paths | length) == ($paths | unique | length)' docs/qa/evidence/2026-07-23-today-open-continuity-field-b02-r00/screenshot-metadata.json docs/qa/evidence/2026-07-23-today-open-continuity-field-b02-r00/recording-metadata.json docs/qa/evidence/2026-07-23-today-open-continuity-field-b02-r00/comparison-metadata.json
python3 - <<'PY'
import json
from pathlib import Path

root = Path("docs/qa/evidence/2026-07-23-today-open-continuity-field-b02-r00").resolve()
expected = {
    "screenshot-metadata.json": {
        "TFCS-F01": "screenshots/TFCS-F01-today-light.png",
        "TFCS-F02": "screenshots/TFCS-F02-today-dark.png",
        "TFCS-F03": "screenshots/TFCS-F03-natural-scroll.png",
        "TFCS-F04": "screenshots/TFCS-F04-expanded-dock.png",
        "TFCS-F05": "screenshots/TFCS-F05-adaptive-navigation-passage.png",
        "TFCS-F06": "screenshots/TFCS-F06-focused-step.png",
        "TFCS-F07": "screenshots/TFCS-F07-consequential-review.png",
        "TFCS-F08": "screenshots/TFCS-F08-settlement.png",
        "TFCS-F09": "screenshots/TFCS-F09-returned-today.png",
        "TFCS-F10": "screenshots/TFCS-F10-interrupted-recovery.png",
        "TFCS-S01": "supporting-state/TFCS-S01-saving.png",
        "TFCS-S02": "supporting-state/TFCS-S02-cancelled-unchanged.png",
        "TFCS-S03": "supporting-state/TFCS-S03-saved-interrupted-progress.png",
        "TFCS-S04": "supporting-state/TFCS-S04-dense-today.png",
        "TFCS-S05": "supporting-state/TFCS-S05-genuine-rtl.png",
        "TFCS-S06": "supporting-state/TFCS-S06-increased-contrast-review.png",
        "B02-Q01": "stress/B02-Q01-quiet-day.png",
        "B02-D01": "stress/B02-D01-very-dense-day.png",
        "B02-T01": "stress/B02-T01-full-day.png",
        "B02-L01": "stress/B02-L01-low-brightness-dark.png",
        "B02-A01": "stress/B02-A01-reduce-transparency.png",
        "B02-CI01": "stress/B02-CI01-compact-iphone.png",
        "B02-PM01": "stress/B02-PM01-pro-max.png",
        "B02-RS01": "stress/B02-RS01-narrow-resizable.png",
        "B02-A02": "stress/B02-A02-differentiate-without-color.png",
        "B02-A03": "stress/B02-A03-long-localization.png",
    },
    "recording-metadata.json": {
        "TFCS-J01": "recordings/TFCS-J01-success-full-day.mov",
        "TFCS-J02": "recordings/TFCS-J02-recovery.mov",
        "TFCS-J03": "recordings/TFCS-J03-accessibility-dynamic-type.mov",
        "TFCS-J04": "recordings/TFCS-J04-dock-and-scroll.mov",
        "TFCS-J05": "recordings/TFCS-J05-reduce-motion.mov",
    },
    "comparison-metadata.json": {
        "B02-C01": "contact-sheets/B02-C01-full-matrix.png",
        "B02-C02": "contact-sheets/B02-C02-b01-comparison.png",
        "B02-C03": "contact-sheets/B02-C03-owner-reference-translation.png",
        "B02-C04": "contact-sheets/B02-C04-accessibility-transformations.png",
    },
}
collections = {
    "screenshot-metadata.json": "screenshots",
    "recording-metadata.json": "recordings",
    "comparison-metadata.json": "comparisons",
}
for filename, paths in expected.items():
    payload = json.loads((root / filename).read_text())
    rows = payload[collections[filename]]
    actual = {row["id"]: row["path"] for row in rows}
    assert actual == paths, (filename, actual, paths)
    for relative in actual.values():
        candidate = (root / relative).resolve()
        assert not Path(relative).is_absolute()
        assert candidate.is_relative_to(root), (relative, candidate)
PY
shasum -a 256 -c docs/qa/evidence/2026-07-23-today-open-continuity-field-b02-r00/reference-hash-checks.txt
git diff --check 92048f7622b06f78ee6e5667e84facd0c4beb2f4 HEAD
git status --short --branch
git rev-parse main origin/main HEAD
```

The evidence owner then validates each screenshot row exactly:

```sh
set -euo pipefail
EVIDENCE_ROOT=docs/qa/evidence/2026-07-23-today-open-continuity-field-b02-r00
jq -r '.screenshots[] | [.path,.bytes,.sha256,.width,.height] | @tsv' "$EVIDENCE_ROOT/screenshot-metadata.json" | while IFS=$'\t' read -r path bytes sha width height; do file="$EVIDENCE_ROOT/$path"; test -f "$file" || exit 1; test "$(stat -f %z "$file")" = "$bytes" || exit 1; test "$(shasum -a 256 "$file" | awk '{print $1}')" = "$sha" || exit 1; test "$(sips -g pixelWidth "$file" | awk '/pixelWidth/{print $2}')" = "$width" || exit 1; test "$(sips -g pixelHeight "$file" | awk '/pixelHeight/{print $2}')" = "$height" || exit 1; done
jq -r '.recordings[] | [.path,.bytes,.sha256,.duration_seconds] | @tsv' "$EVIDENCE_ROOT/recording-metadata.json" | while IFS=$'\t' read -r path bytes sha duration; do file="$EVIDENCE_ROOT/$path"; test -f "$file" || exit 1; test "$(stat -f %z "$file")" = "$bytes" || exit 1; test "$(shasum -a 256 "$file" | awk '{print $1}')" = "$sha" || exit 1; actual="$(mdls -raw -name kMDItemDurationSeconds "$file")"; awk -v a="$actual" -v e="$duration" 'BEGIN{d=a-e;if(d<0)d=-d;exit(d<=0.05?0:1)}' || exit 1; done
jq -r '.comparisons[] | [.path,.bytes,.sha256,.width,.height] | @tsv' "$EVIDENCE_ROOT/comparison-metadata.json" | while IFS=$'\t' read -r path bytes sha width height; do file="$EVIDENCE_ROOT/$path"; test -f "$file" || exit 1; test "$(stat -f %z "$file")" = "$bytes" || exit 1; test "$(shasum -a 256 "$file" | awk '{print $1}')" = "$sha" || exit 1; test "$(sips -g pixelWidth "$file" | awk '/pixelWidth/{print $2}')" = "$width" || exit 1; test "$(sips -g pixelHeight "$file" | awk '/pixelHeight/{print $2}')" = "$height" || exit 1; done
```

Any command exits nonzero on the first mismatch. The changed-path audit compares
`git diff --name-only 92048f... HEAD` against `changed-files.md`; the authority
audit queries generated authority and asserts VC-01 through VC-14 remain closed
while all broad/global implementation authorizations remain false.

Media cannot truthfully name the evidence commit that contains its own metadata
because that commit SHA is self-referential. Each row therefore names the exact
`render_source_sha` used by the host. Final validation runs:

```sh
RENDER_SHA="$(jq -r .render_source_sha "$EVIDENCE_ROOT/screenshot-metadata.json")"
test "$RENDER_SHA" = "$(jq -r .render_source_sha "$EVIDENCE_ROOT/recording-metadata.json")"
test "$RENDER_SHA" = "$(jq -r .render_source_sha "$EVIDENCE_ROOT/comparison-metadata.json")"
git merge-base --is-ancestor "$RENDER_SHA" HEAD
git diff --quiet "$RENDER_SHA" HEAD -- Packages/AmbitionsPresentation/Sources/AmbitionsNativeVisualFoundry Native/AmbitionsNativeFoundryHost Native/AmbitionsNativeFoundryHostUITests Packages/AmbitionsPresentation/Tests/AmbitionsNativeVisualFoundryTests
```

Thus every artifact is bound to one exact render source, and final evidence-only
commits are proven not to alter the rendered Swift source. The final B02 HEAD is
recorded separately in `validation-results.md` and the owner handoff.

## Stop loss

Stop rather than improvise if work requires root IA change, bottom tabs,
Search/Capture in crown, temporal editing in Today, fixture truth/Step/Still
Counts replacement, live runtime, production mutation, app entry, legacy UI,
another root, global design-system/component authority, dependency/custom font,
Figma/Code Connect, production localization/baseline, weakened accessibility,
fixed screenshot coordinates, unsupported controls, merge/push, or a shared
architectural change outside the Foundry boundary.
