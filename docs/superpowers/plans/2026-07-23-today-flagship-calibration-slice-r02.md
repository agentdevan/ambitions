# Today Flagship Calibration Slice R02 implementation plan

> Revision: `AVF-TODAY-S10-R02`
>
> Evidence package: `docs/qa/evidence/2026-07-23-today-flagship-calibration-slice-r02`
>
> Starting SHA: `065fa6e9c796381703e5d6f5364a1669c4b3fe7b`
>
> Branch: `codex/today-flagship-calibration-slice`

## Outcome and proof ceiling

Apply only the six owner-approved R02 corrections to the existing fixture-driven
Today calibration slice: human product language, a compressed consequential
review with secondary detail disclosure, removal of inert outcome names,
fixture-specific returned-Today de-duplication, an intentional natural-scroll
evidence offset, and genuine `ar-SA` RTL evaluation content. Preserve the R01
shell, Today, focused Step, full-screen review, saving, settlement, return,
recovery, fixture boundary, and package-backed preview workflow.

This revision remains evaluation-only. It does not connect a runtime adapter,
change the production app entry, import legacy views, authorize broad frontend
work, create a production localization system or screenshot baseline, complete
direct-device proof, merge, push, or declare `APPROVED FOR SWIFTUI`.

## R01 audit and protected primitives

- Preserve `Packages/AmbitionsPresentation` and `AmbitionsNativeVisualFoundry`
  as the production-intended presentation boundary.
- Preserve `Native/AmbitionsNativeFoundryHost` as the fixture-only executable.
- Preserve `TodayFlagshipJourneyState`, stable IDs, the Today return anchor,
  `NavigationStack`, native back, `fullScreenCover`, recovery `sheet`, one native
  `ScrollView`, Compact Semantic Crown, Crowned Edge Dock, Adaptive Navigation
  Passage, Light/Dark anatomy, and existing focus anchors.
- Keep the focused navigation title `Start Here`. Complete R01 recordings show
  it preserving Today provenance at object depth without changing root context.
- Use native `DisclosureGroup` for review details and settlement history. Keep
  disclosure collapsed by default.
- Keep `Still counts` as the only actionable outcome because no complete
  source-backed fixture path exists for the other canonical outcomes.
- Preserve R01 media and metadata byte-for-byte. Only its `owner-review.md` may
  record the narrow-revision disposition and link to R02.

## Expected R02 copy and composition

- Focused Step: `Right now`, the owner-directed current sentence, short fit and
  consequence sentences, `Before family time`, and one `Still counts` action.
- Review title: `Record this progress?`; first viewport shows Step identity,
  `Right now`, `Still counts`, `What will change`, `Also updates`, one quiet
  on-device history cue, `Record progress`, and `Not now` without scrolling.
- Review `Details` contains only source-supported evidence/History/Receipt
  mechanics and remains collapsed.
- Saving: `Recording progress` and the owner-directed unchanged-until-finished
  sentence; settlement: `Progress recorded`, the settled personal meaning,
  relationship, `View history`, and `Return to Today`.
- Recovery: `Pick up where you left off`, `Your saved progress is still here`,
  `Continue where you left off`, and `Leave this for later`, with unchanged
  fixture command IDs and effects.
- Returned Today filters the promoted `step.send-launch-brief` out of the
  supporting timeline while it owns Start Here. Its temporal relationship is
  subordinate within Start Here; the settled nursery Step retains focus and
  visibility.
- `TFCS-F03` uses a deliberate natural scroll offset where Start Here is fully
  above the viewport and the timeline leads. No snapping or custom physics.
- `TFCS-S05` uses an `ar-SA` evaluation snapshot with real Arabic script,
  localized system date/time presentation, long copy, mixed-direction `Ambitions
  S10`, RTL layout direction, and logical accessibility order.

## Architecture-sensitive assumptions

- **Snapshot adapter:** R02 may add localized presentation strings and a
  fixture projection flag/value to immutable snapshots. Fixtures remain
  adapters, not authority or production localization/runtime owners.
- **Review disclosure:** `Details` is a calibration disclosure, not final
  Receipt architecture. Review remains a full-screen native presentation.
- **Outcome absence:** omission of non-executable alternatives does not remove
  canonical outcomes. It prevents names from imitating controls.
- **Return projection:** filtering the promoted Step from the visible timeline
  is fixture-specific projection behavior, not a global eligibility law.
- **Humanized copy:** the shorter copy preserves the canonical current,
  proposed, consequence, relationship, saving, settled, and recovery meanings.
- **RTL:** `ar-SA` text is evaluation translation only and does not authorize or
  claim complete production localization.
- **Mutation and timing:** no persistence logic enters the Foundry view. The
  synthetic saving delay remains evaluation timing with no runtime guarantee.
- **Device ceiling:** Simulator evidence does not close physical VoiceOver,
  focus, Switch Control, Full Keyboard Access, Voice Control, reach, gesture,
  low-brightness, Reduce Motion/Transparency, or multi-device safe-area proof.

## Files likely to change

### Foundry package

- `TodayFlagshipCalibrationContent.swift`: narrowly add presentation/localized
  snapshot values only if the view contract requires them.
- `TodayFlagshipCalibrationFixture.swift`: humanized R02 fixture copy, returned
  projection support, recovery labels, and `ar-SA` evaluation fixture.
- `TodayFlagshipCalibrationView.swift`: returned timeline filtering, subordinate
  Start Here time relationship, and accessibility identity uniqueness.
- `TodayFlagshipFocusedStepView.swift`: human language, inert-outcome removal,
  settlement/history hierarchy, and recovery entry copy.
- `TodayFlagshipReviewView.swift`: compressed review, collapsed `Details`,
  first-viewport commit/cancel placement, and saving copy.
- `TodayFlagshipRecoveryReviewView.swift`: human recovery wording without effect
  changes.
- `TodayFlagshipCalibrationPreviews.swift`: genuine RTL stress projection.

### Tests and host

- `TodayFlagshipCalibrationFixtureTests.swift`: prohibited-copy, `ar-SA`, and
  returned-projection fixtures.
- `TodayFlagshipJourneyStateTests.swift`: preserve R01 semantics and returned
  identity/focus invariants.
- `TodayFlagshipCalibrationHostUITests.swift`: first-viewport review actions,
  non-mutation, no pseudo-actions, returned uniqueness, settled visibility,
  history round trip, RTL/accessibility order, contrast, Dynamic Type, and
  recovery semantics.
- `AmbitionsNativeFoundryHostApp.swift`: genuine RTL variant and deterministic
  R02 recording interactions, including History open/close.
- `project.yml` only if a test-target setting must change; regenerate rather
  than hand-edit the project.

### Plan and evidence

- Add this plan.
- Update only R01 `owner-review.md` with `REQUESTED_NARROW_REVISION`, revision
  target, six findings, and the R02 link.
- Add the complete R02 sibling evidence package. Do not modify R01 media,
  hashes, or metadata.

## TDD execution tasks

### Task 1 — Product-language and fixture contract

1. Add failing tests for the owner-directed visible strings, prohibited primary
   phrases/accessibility labels, absence of passive outcome names, unchanged
   fixture IDs, human recovery labels, and genuine Arabic content.
2. Run the focused fixture tests and record the expected failures.
3. Implement the smallest fixture/snapshot changes.
4. Re-run focused and all package tests green.

### Task 2 — Review density and truthful affordances

1. Add failing UI assertions that standard-size review identity, current,
   proposal, consequence, relationship/trust, `Record progress`, and `Not now`
   exist and are hittable before any scroll; cancellation remains non-mutating;
   `Details` is collapsed; pseudo-actions and `Other outcomes` are absent.
2. Add failing Accessibility Dynamic Type assertions that commit/cancel remain
   reachable through natural scrolling and unobscured.
3. Implement the compressed full-screen review with native toolbar cancellation,
   native `DisclosureGroup`, 44-point actions, and no floating custom control.
4. Re-run the focused UI tests green.

### Task 3 — Settlement, history, recovery, and returned projection

1. Add failing tests that `View history` opens and returns without changing
   settled truth; recovery labels preserve exact command semantics; returned
   Today shows the settled nursery Step and exposes the promoted Step's full
   accessibility identity exactly once with continuity focus retained.
2. Implement humanized settlement/recovery copy, secondary history disclosure,
   fixture-specific timeline filtering, and subordinate promoted-Step time.
3. Re-run package and focused UI tests green.

### Task 4 — Genuine RTL and evidence controls

1. Add failing fixture/UI tests for `ar-SA`, real Arabic strings, mixed-direction
   content, system-formatted date/time, RTL direction, and logical accessibility
   inspection order.
2. Implement the evaluation-only Arabic snapshot and select it for `TFCS-S05`.
3. Keep the optional mirrored-English projection out of accepted RTL evidence.
4. Add an evidence capture action/launch posture for the intentional F03 scroll
   offset without changing scroll physics.

### Task 5 — Warm loop, full media, and self-review

1. Warm Path A and record one first plus three source-changing warm swaps. Do
   not clean; restore intended source after every benchmark mutation.
2. Run one cached incremental fixture-host build.
3. Capture all 16 R02 frames at 1206 × 2622 on the same iPhone 17 Pro Simulator;
   capture F03 at a coherent timeline-leading natural offset.
4. Record J01–J03 continuously, including review, saving, settlement, History
   disclosure round trip, returned uniqueness, recovery, and Accessibility
   Dynamic Type.
5. Inspect full-resolution frames and complete recordings. Repair only named R02
   defects or direct regressions.

### Task 6 — R02 evidence and fresh verification

1. Add all required R02 documents, metadata, before/after manifest, media,
   benchmark, command log, and undecided owner review.
2. Validate copy inventory, screenshot dimensions/hashes/settings, recording
   duration/hash/settings, fixture IDs, and `production_baseline: false`.
3. Run package build/tests, fixture-host build/UI suite, changed-file SwiftLint,
   canon build/check and focused compiler tests, boundary/direct-write/weak
   scans, full and range Gitleaks, metadata validators, changed-path/authority
   audits, `git diff --check`, and working-tree inspection.
4. Verify R01 media integrity and all stop-loss boundaries.
5. Commit coherent R02 groups without rewriting R01 commits. Do not merge or
   push. Leave the branch clean for owner review.

## Validation commands

```sh
swift build --package-path Packages/AmbitionsPresentation \
  --target AmbitionsNativeVisualFoundry
swift test --package-path Packages/AmbitionsPresentation
xcodegen generate
xcodebuild -project Ambitions.xcodeproj \
  -scheme AmbitionsNativeFoundryHost \
  -destination 'platform=iOS Simulator,id=EDE1E954-C663-47FB-855B-95F96AE2DBDD' build
xcodebuild -project Ambitions.xcodeproj \
  -scheme AmbitionsNativeFoundryHost \
  -destination 'platform=iOS Simulator,id=EDE1E954-C663-47FB-855B-95F96AE2DBDD' \
  -only-testing:AmbitionsNativeFoundryHostUITests test
swiftlint lint --strict <changed Swift files>
python3 scripts/ambitions-canon.py build
python3 scripts/ambitions-canon.py check
python3 -m unittest discover -s tools/tests -p 'test_ambitions_canon_compiler.py'
python3 scripts/ambitions-local-first-boundary-scan.py
python3 scripts/ambitions-runtime-direct-write-audit.py
python3 scripts/ci/ambitions-no-weak-implementation-scan.py
bash scripts/ci/ambitions-gitleaks-scan.sh
GITHUB_BASE_SHA=065fa6e9c796381703e5d6f5364a1669c4b3fe7b \
  bash scripts/ci/ambitions-gitleaks-scan.sh
git diff --check 065fa6e9c796381703e5d6f5364a1669c4b3fe7b HEAD
git status --short --branch
```

## Explicit non-goals and stop-loss

- No new Today structure, root IA, shell/crown/dock/Start Here redesign, primary
  object/outcome change, review presentation change, recovery presentation
  change, other-root work, live runtime, production app entry, legacy surface,
  broad component/design-system/token extraction, dependency, localization
  infrastructure, Figma, Code Connect, snapshot library, production baseline,
  merge, push, or `APPROVED FOR SWIFTUI` claim.
- No alternative outcome journey or generic outcome framework is added.
- Stop and report if a correction requires crossing any boundary above or if
  the package hot-reload loop regresses past the owner-defined stop-loss.
