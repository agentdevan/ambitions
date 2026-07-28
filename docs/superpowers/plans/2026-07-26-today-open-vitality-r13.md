# Today Open Vitality Field — R13 Implementation Plan

> Execute the approved implementation directly. Owner-directed closeout uses
> exactly one final specification review and one final combined visual-quality
> and accessibility review; no phase-by-phase review loop is required.

**Goal:** Implement the complete owner-selected R13 Today journey in the Native
Visual Foundry while preserving B02 semantics, fixture truth, native behavior,
accessibility, performance, and every authorization ceiling.

**Base:** `ac7ed07d090d65bdc469a9a2309f6899dc6135e6`

**Branch:** `codex/today-open-vitality-r13`

## Changed-path envelope

Only these areas may change:

- `Packages/AmbitionsPresentation/Sources/AmbitionsNativeVisualFoundry/`
- `Packages/AmbitionsPresentation/Tests/AmbitionsNativeVisualFoundryTests/`
- `Native/AmbitionsNativeFoundryHost/`
- `Native/AmbitionsNativeFoundryHostUITests/`
- `docs/superpowers/specs/2026-07-26-today-open-vitality-r13-design.md`
- `docs/superpowers/plans/2026-07-26-today-open-vitality-r13.md`
- `docs/qa/evidence/2026-07-26-today-open-vitality-r13/`

No canon, generated canon, production app entry, runtime, stage, legacy
frontend, dependency manifest/resolution, other root, Figma, Code Connect, or
production baseline path may change.

## Preserved interfaces

- `TodayFlagshipCalibrationContent`: immutable semantic snapshot.
- `TodayFlagshipCalibrationFixture`: deterministic fixture family.
- `TodayFlagshipJourneyState`: explicit route/phase/focus owner.
- `TodayFlagshipCalibrationView`: stable public Foundry entry.
- `TodayFlagshipNavigationChrome`: root dock/adaptive passage owner.
- Fixture host: only runnable host; production entry remains untouched.

## Planned local units

- `TodayVitalityGrammar.swift`: local colors, type roles, node shapes, actions.
- `TodayVitalityShell.swift`: crown and root-only dock adaptation.
- `TodayVitalityRootView.swift`: Start Here and returned root.
- `TodayVitalityTimelineView.swift`: overview and Full Day rail anatomy.
- `TodayVitalityFocusedStepView.swift`: stable focused object depth.
- `TodayVitalityReviewView.swift`: review, saving, and failed commit posture.
- `TodayVitalitySettlementView.swift`: settlement and returned continuity.
- `TodayVitalityRecoveryView.swift`: interruption and native recovery sheet.
- `TodayVitalityDrilldowns.swift`: Goal, Time transfer, Details, History.
- `TodayVitalityResilienceViews.swift`: offline, stale, blocked, failed, Undo.
- `TodayVitalityPreviewSupport.swift`: deterministic render variants.

Names may be combined when a file remains focused; no broad component API is
created.

## Exact local interfaces

```swift
enum TodayVitalityNodeKind: String, CaseIterable
struct TodayVitalityPalette
struct TodayVitalityNode: View
struct TodayVitalityPrimaryActionStyle: ButtonStyle
struct TodayVitalityRootView: View
struct TodayVitalityTimelineView: View
struct TodayVitalityFocusedStepView: View
struct TodayVitalityReviewView: View
struct TodayVitalitySettlementView: View
struct TodayVitalityRecoveryView: View
enum TodayFlagshipSupportingRoute: Hashable
enum TodayFlagshipCommitResult: Equatable
```

All views accept immutable `TodayFlagshipCalibrationContent` sub-snapshots and
callbacks. Only `TodayFlagshipJourneyState` owns phase/route/focus transitions.
`TodayFlagshipCalibrationView` remains the public composition wrapper, while
the fixture host chooses deterministic variants and synthetic commit results.

## Exact task path registry

| Task | Create | Modify/tests |
| --- | --- | --- |
| 01 | none | `TodayFlagshipJourneyState.swift`, `TodayFlagshipCalibrationContent.swift`, `TodayFlagshipCalibrationFixture.swift`, `TodayFlagshipJourneyStateTests.swift`, `TodayFlagshipCalibrationFixtureTests.swift` |
| 02 | `TodayVitalityGrammar.swift`, `TodayVitalityPreviewSupport.swift` | `TodayFlagshipCalibrationStyle.swift`, `TodayFlagshipCalibrationFixtureTests.swift` |
| 03 | `TodayVitalityShell.swift` | `TodayFlagshipNavigationChrome.swift`, `TodayFlagshipCalibrationView.swift`, `TodayFlagshipCalibrationHostUITests.swift` |
| 04 | `TodayVitalityRootView.swift`, `TodayVitalityTimelineView.swift` | `TodayFlagshipCalibrationView.swift`, `TodayFlagshipCalibrationPreviews.swift`, fixture/content/tests, host and host UI tests |
| 05 | `TodayVitalityFocusedStepView.swift` | wrapper, previews, package tests, host UI tests |
| 06 | `TodayVitalityReviewView.swift` | state, wrapper, previews, package tests, host, host UI tests |
| 07 | `TodayVitalitySettlementView.swift` | state, wrapper, previews, package tests, host UI tests |
| 08 | `TodayVitalityFullDayView.swift` | state, wrapper, previews, package tests, host UI tests |
| 09 | `TodayVitalityRecoveryView.swift` | state, wrapper, previews, package tests, host UI tests |
| 10 | `TodayVitalityDrilldowns.swift` | state, fixture/content, wrapper, previews, package tests, host UI tests |
| 11 | `TodayVitalityResilienceViews.swift` | state, fixture/content, wrapper, previews, package tests, host UI tests |
| 12 | none unless a focused helper is required | every R13 local view, navigation chrome, previews, package/UI tests |
| 13 | none | `Native/AmbitionsNativeFoundryHost/AmbitionsNativeFoundryHostApp.swift`, both host UI-test files, package tests |
| 14–15 | evidence-local validators and artifacts | `docs/qa/evidence/2026-07-26-today-open-vitality-r13/` only |

Every bare Swift filename in the table resolves under
`Packages/AmbitionsPresentation/Sources/AmbitionsNativeVisualFoundry/`; package
tests resolve under
`Packages/AmbitionsPresentation/Tests/AmbitionsNativeVisualFoundryTests/`; host
UI tests resolve under `Native/AmbitionsNativeFoundryHostUITests/`.

## Task 01 — State and fixture safety first

- [ ] Add RED tests for failed commit leaving saving, source-backed Undo gating,
  read-only Time transfer, stable focus targets, and returned de-duplication.
- [ ] Extend `TodayFlagshipJourneyState.swift` with the smallest explicit failed
  and supporting-route states. Time Transfer is not a product journey route; it
  is a host-launched evaluation-only fixture state until a source-backed Time
  route exists.
- [ ] Extend fixture snapshots with supporting Goal/Time/History/resilience data
  without making fixtures authority owners.
- [ ] Ensure `onCommitProposal() == false` renders accepted truth with recovery
  instead of trapping the presentation.
- [ ] Run focused state/fixture tests, then the whole package suite.
- [ ] Commit `test(foundry): guard R13 journey truth`.

Exact files: existing state/content/fixture and package test files only.

## Task 02 — R13 local visual grammar

- [ ] Add RED source/contract tests for system typography, matte content,
  distinct non-color nodes, action-role separation, no gradients/glow/cards,
  and chrome-only glass.
- [ ] Implement local palette, five type roles, continuity nodes, open relief,
  action styles, and Reduce Transparency/Contrast variants.
- [ ] Add Light, Dark, Increased Contrast, Differentiate Without Color, and
  Dynamic Type grammar previews.
- [ ] Render and inspect full/50%/contact-sheet scale.
- [ ] Commit `feat(foundry): establish R13 vitality grammar`.

## Task 03 — Crown, Dock Peek, and expanded dock

- [ ] Add RED UI tests for root-only wordmark, absent crown Search/Capture,
  locked root/global grouping, 44-point Peek target, compact-height escape, and
  opaque Reduce Transparency chrome.
- [ ] Implement English root crown and an intentional Today Peek without a
  scrollbar silhouette.
- [ ] Make expanded dock scroll/adapt when height is constrained.
- [ ] Confirm dock is absent from focused/full-screen depth.
- [ ] Render root, expanded, adaptive, compact-height, and opaque states.
- [ ] Commit `feat(foundry): calibrate R13 crown and dock`.

## Task 04 — Today Root and Later Today

- [ ] Add RED tests for one dominant Start Here group, no duplicate nursery
  Step, exact Later Today budget/order, first-viewport action reach, and English
  copy contract.
- [ ] Implement the open Start Here anatomy and leading-time continuity rail.
- [ ] Implement returned root with unique read-only revealed Start Here and the
  settled nursery Step integrated once.
- [ ] Preserve natural scrolling and dock clearance.
- [ ] Run four measured root source-change preview reloads.
- [ ] Render Light, Dark, natural scroll, quiet, dense, very dense, compact,
  Pro Max, and low-brightness states.
- [ ] Commit `feat(foundry): reconstruct R13 Today field`.

## Task 05 — Focused Step

- [ ] Add RED tests for stable identity, parent Goal, current truth, concise
  consequence/time, only Still counts, native Back, and no deep dock.
- [ ] Implement open object depth using the same title/node alignment.
- [ ] Keep action reachable across standard and accessibility sizes.
- [ ] Render typical, long English, Dynamic Type, and Contrast.
- [ ] Commit `feat(foundry): reconstruct R13 focused step`.

## Task 06 — Consequential review and saving

- [ ] Add RED tests for current/proposed distinction, visible standard-size
  actions, non-mutating cancel, disabled duplicate commit, saving announcement,
  and failed-settlement recovery.
- [ ] Implement the vertical comparison field, Details disclosure, and native
  safe-area action region.
- [ ] Keep current truth visible while commit progress replaces the enabled
  commitment control.
- [ ] Run four measured focused/review preview reloads.
- [ ] Render review, saving, failed, Increased Contrast, Differentiate Without
  Color, Reduce Motion, and accessibility size.
- [ ] Commit `feat(foundry): reconstruct R13 review and saving`.

## Task 07 — Settlement and returned continuity

- [ ] Add RED tests for changed truth priority, subordinate non-mutating History,
  explicit return, no Back regression, unique new Start Here, settled nursery
  visibility, and exact returned focus.
- [ ] Implement resolved rail, neutral History/Return navigation, and returned
  rail integration.
- [ ] Run four settlement/return preview reloads.
- [ ] Render settlement, History disclosure, and returned Today.
- [ ] Commit `feat(foundry): compose R13 settlement and return`.

## Task 08 — Full Day

- [ ] Add RED tests for complete ordered chronology, leading times, source-backed
  Now, Scroll to Now, no temporal mutation, preserved non-mutating canonical
  Step inspection, native Back, origin-specific focus, and no fabricated Time
  mutation.
- [ ] Implement lazy rail-first Full Day with origin-specific focus restoration.
- [ ] Render typical, returned, dense, compact, Pro Max, and large type.
- [ ] Commit `feat(foundry): build R13 read-only full day`.

## Task 09 — Interruption and recovery

- [ ] Add RED tests for retained accepted/saved truth, exact recovery effects,
  safe deferral/dismissal, native sheet focus, and 44-point actions.
- [ ] Implement narrow interruption seam and adaptive scrolling recovery sheet.
- [ ] Render interrupted object, sheet, large type, and Reduce Motion.
- [ ] Commit `feat(foundry): articulate R13 recovery`.

## Task 10 — Goal, Time, Details, and History

- [ ] Add RED tests for bounded Goal context, truthful unavailable Time transfer,
  exact consequence Details, local History entry, native filters, and no root
  reconstruction or fake route.
- [ ] Implement source-backed supporting drill-downs using native
  navigation/sheets. Time Transfer is host-only evaluation content and is
  absent from the product journey UI.
- [ ] Render every drill-down and verify round-trip focus/non-mutation.
- [ ] Commit `feat(foundry): add R13 supporting depth`.

## Task 11 — Resilience states

- [ ] Add RED tests for offline local truth and source-supported local closure,
  stale external context, conflict transfer, failed
  settlement, cancelled unchanged, and exact inverse gating.
- [ ] Implement only fixture/source-supported seams and actions.
- [ ] Render offline, stale, failed, cancelled, and Undo available. Record the
  blocked-consequence frame as omitted because the fixture has no supported path.
- [ ] Commit `feat(foundry): prove R13 resilience`.

## Task 12 — Accessibility, adaptivity, motion, and performance

- [ ] Replace proxy focus anchors with actual semantic elements and test exact
  focus restoration.
- [ ] Verify Dynamic Type, VoiceOver order/actions, Contrast, Differentiate
  Without Color, Reduce Transparency, Reduce Motion, Bold Text, Button Shapes,
  long English, target geometry, compact/Pro Max/narrow widths, and
  expanded status areas.
- [ ] Keep all R13 UI and evidence English; record localization and RTL proof as
  deferred by owner.
- [ ] Implement calm native transitions/haptic intent without ambient animation.
- [ ] Run SwiftUI performance audit; use ETTrace/memgraph only for observed
  symptoms.
- [ ] Measure the initial package-preview launch, then run four material/motion
  source-changing reloads and one cached host build/launch.
- [ ] Commit `perf(foundry): harden R13 accessibility and rendering`.

## Task 13 — Host interactions and complete automated proof

- [ ] Add deterministic host variants for every evidence state.
- [ ] Add/repair UI tests for all R13 assertions and full successful/recovery
  journeys.
- [ ] Preserve all existing B02 semantic tests after intentional assertion
  updates.
- [ ] Run target build, full package tests, host build, and complete UI suite.
- [ ] Commit `test(foundry): cover R13 interactions`.

## Task 14 — Evidence capture

- [ ] Capture R13-F01–F13, R13-D01–D11, quiet/dense/very-dense, accessibility,
  long English, contrast, differentiate, transparency,
  low-brightness, compact, Pro Max, and narrow-width frames.
- [ ] Create full matrix, B02 comparison, reference translation, and
  accessibility contact sheets.
- [ ] Record source SHA, fixture, device/OS, settings, byte size/hash, and
  `production_baseline = false` in machine metadata.
- [ ] Inspect every artifact at full, 50%, and contact-sheet scale.
- [ ] Commit `docs(foundry): add R13 native evidence`.

## Final evidence-file inventory

The evidence directory may consolidate overlapping prose. It must preserve a
README, owner selection and direction contract, repository/canon and fixture
boundaries, reference manifest/translation, implementation and architecture
summary, visual/accessibility/adaptivity/performance review, comparisons, final
reviewer findings, validation outcomes, benchmark, changed files, known
limitations, owner review, command log, reference hashes,
screenshot/comparison metadata, a checked-in `validate-evidence.py`, all
screenshots, and contact sheets. Do not create recordings, recording metadata,
or recording validation.

## Task 15 — Final independent review and validation

- [ ] Run exactly one final specification review and one final combined
  visual-quality/accessibility review. Resolve every Critical/Important finding.
- [ ] Complete the 20-category scorecard; no category below 4 and average at
  least 4.5.
- [ ] Run all validation below and write exact outcomes, commands, changed files,
  architecture assumptions, direct-device obligations, and known limitations.
- [ ] Set owner review to `READY_FOR_OWNER_REVIEW`; never mark accepted.
- [ ] Confirm clean branch, unmerged/unpushed, and unchanged `main`.
- [ ] Commit `docs(foundry): finalize R13 validation`.

## Validation commands

```sh
swift build --package-path Packages/AmbitionsPresentation --target AmbitionsNativeVisualFoundry
swift test --package-path Packages/AmbitionsPresentation
xcodegen generate
xcodebuild -project Ambitions.xcodeproj -scheme AmbitionsNativeFoundryHost \
  -destination 'platform=iOS Simulator,id=396F4B4A-2DAD-4345-B26E-ABD2EF69BF5E' \
  build CODE_SIGNING_ALLOWED=NO
xcodebuild -project Ambitions.xcodeproj -scheme AmbitionsNativeFoundryHost \
  -destination 'platform=iOS Simulator,id=396F4B4A-2DAD-4345-B26E-ABD2EF69BF5E' \
  test CODE_SIGNING_ALLOWED=NO
git diff --name-only ac7ed07d090d65bdc469a9a2309f6899dc6135e6..HEAD -- '*.swift' \
  | xargs swiftlint lint --strict
python3 scripts/ambitions-canon.py build
python3 scripts/ambitions-canon.py check
python3 -m pytest -q tests/canon/test_ambitions_canon.py tests/canon/test_visual_authority_compiler.py
python3 scripts/ambitions-local-first-boundary-scan.py
python3 scripts/ambitions-runtime-direct-write-audit.py
python3 scripts/ci/ambitions-no-weak-implementation-scan.py
gitleaks detect --source . --no-git --redact
gitleaks git --log-opts 'ac7ed07d090d65bdc469a9a2309f6899dc6135e6..HEAD' --redact
python3 docs/qa/evidence/2026-07-26-today-open-vitality-r13/validate-evidence.py \
  --screenshots docs/qa/evidence/2026-07-26-today-open-vitality-r13/screenshot-metadata.json \
  --comparisons docs/qa/evidence/2026-07-26-today-open-vitality-r13/comparison-metadata.json \
  --references docs/qa/evidence/2026-07-26-today-open-vitality-r13/visual-reference-manifest.json
git diff --name-only ac7ed07d090d65bdc469a9a2309f6899dc6135e6..HEAD > /tmp/r13-changed-paths.txt
! rg -n '^(Native/Ambitions/App|Native/Ambitions/Runtime|frontend/|docs/canon/|Packages/.*/Package.resolved)' /tmp/r13-changed-paths.txt
python3 -c 'import json; d=json.load(open("docs/canon/generated/visual-authority-manifest.json")); a=d["authority_state"]; assert a["approved_for_swiftui"] is False and a["broad_frontend_reconstruction"] is False and a["broad_production_implementation"] is False and a["implementation"] is False and a["figma"] is False; v=d["vc_14_native_matched_closure"]; assert all(x=="CLOSED" for x in v["package_statuses"].values()); assert v["direct_device_proof"]["required"] is True and v["direct_device_proof"]["complete"] is False'
test "$(git rev-parse main)" = 5670f24fb82adefd27cffee5ddf8fb70676ed049
test "$(git rev-parse origin/main)" = 5670f24fb82adefd27cffee5ddf8fb70676ed049
git diff --check
git status --short --branch
```

The checked-in evidence validator verifies file existence, SHA-256, byte size,
dimensions, fixture IDs, device/OS, settings, repository SHA, primary/supporting
role, and `production_baseline = false`.

## Stop-loss risks

Stop rather than improvise if any task requires changing root IA, bottom tabs,
moving Search/Capture into the crown, changing fixture truth/Step/Still counts,
temporal editing inside Today, live runtime, production entry/mutation,
legacy code, other-root reconstruction, shared production design-system work,
new dependency, final tokens/components, production localization/baselines,
merge/push, accessibility degradation, screenshot coordinates, image-backed UI,
or unsupported controls. A required change outside the Foundry boundary is an
architectural blocker.
