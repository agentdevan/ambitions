# Today Flagship Calibration Slice implementation plan

> Revision: `AVF-TODAY-S10-R01`
>
> Evidence package: `docs/qa/evidence/2026-07-23-today-flagship-calibration-slice-r01`
>
> Starting SHA: `f2781053d1ffcf962f112014b37d916bd677c450`
>
> Branch: `codex/today-flagship-calibration-slice`

## Outcome and proof ceiling

Build one complete, fixture-driven native Today calibration journey inside the
existing `AmbitionsNativeVisualFoundry` package and fixture-only host. The
slice proves Today orientation, a stable Step, a proposed `Still counts`
consequence, exact review, transitional saving, settled truth, explicit return,
and a separate interruption/recovery path. It does not connect LocalRuntimeOS,
change the production app entry, import legacy views, authorize broad frontend
work, create production screenshot baselines, or complete direct-device proof.

## Existing boundaries and primitives to reuse

- Keep `Packages/AmbitionsPresentation` and
  `AmbitionsNativeVisualFoundry` as the production-intended presentation
  boundary.
- Keep `Native/AmbitionsNativeFoundryHost` as the fixture-only executable host.
- Reuse the accepted bootstrap narrative and visual laws without copying any
  `Native/Ambitions/DesignSystem/ProductObjects` view code.
- Reuse native `NavigationStack`, value-driven destinations, native back and
  interactive-back behavior, `ScrollView`, `fullScreenCover`, `sheet`,
  `DisclosureGroup`, `ProgressView`, system buttons, Dynamic Type, safe areas,
  and accessibility focus.
- Reuse the existing Peek/adaptive navigation semantics and locked root/global
  command order. Liquid Glass is limited to functional Peek/expanded dock
  chrome and always has a Reduce Transparency opaque rendering.

## Architecture-sensitive choices

- **Snapshot adapter:** small immutable Sendable/Equatable fixture snapshots
  describe the Today, Step, lineage, consequence, Receipt/History, timeline,
  return, and recovery content. They own no policy and can be constructed later
  by a runtime adapter without changing view anatomy.
- **Stable Step scope:** the fixture's Step is the source-supported calibration
  vehicle only. The API does not claim that every future Start Here object is a
  Step.
- **Mutation ownership:** the Foundry state machine simulates evaluation-only
  transitions. It does not send commands or persist data; canonical mutation
  remains owned by LocalRuntimeOS.
- **Review presentation:** current navigation canon defines consequential
  review as full-screen. Use `fullScreenCover` above the focused Step so review
  has explicit cancel/commit hierarchy and cannot resemble an alert. Keep
  object-scoped recovery in a native sheet because it is a smaller, local
  choice set.
- **Settlement timing:** use one deterministic fixture-only delay in the host
  to record the saving posture. The view/state contract itself makes no runtime
  latency or persistence guarantee.
- **Receipt and History:** the fixture renders a compact recorded acknowledgment
  and secondary disclosure because the inspected source contract supports a
  local Receipt, History projection, and Proof for `Still counts`.
- **Inverse:** omit Undo. The live source classifies `Still counts` inverse as
  requiring confirmation; this fixture does not model the exact inverse
  command, revision, and dependencies.
- **Return anchor:** use stable Step identity plus a semantic Today anchor, not
  a visual offset. The settled Step remains in Today, while a new eligible Step
  becomes Start Here.
- **Post-settlement eligibility:** this one fixture moves the settled Step out
  of Start Here. It is not a universal rule.
- **Time ownership:** Today shows exact temporal context but exposes no
  chronology mutation. Any placement change remains Time-owned and absent.
- **Device ceiling:** preview and iPhone 17 Pro Simulator proof remain
  evaluation only. Physical device, real assistive-technology, one-handed,
  low-brightness, thermal, and actual persistence proof remain open.

## Expected semantic state model

The value state uses stable IDs and explicit phases:

1. `todayInitial`
2. `focusedCurrent`
3. `reviewingProposal`
4. `savingAcceptedTruth`
5. `settled`
6. `todayReturned`
7. `interrupted`
8. `recoveryReview`
9. `recoveredContinuation`

Cancellation returns from review to `focusedCurrent` without changing accepted
truth. Dismissing recovery preserves the interrupted Step and saved progress.
Only the `settled` transition changes accepted truth in the fixture projection.

## Expected navigation and focus

- Today root uses one `NavigationStack` with a lightweight Step identity route.
- Activating Start Here pushes the focused Step and leaves the Today semantic
  anchor in state.
- `Still counts` presents a full-screen review. Cancel dismisses it unchanged;
  commit first shows saving, then dismisses to the settled focused Step.
- `Return to Today` removes the focused route, projects returned Today, and
  places accessibility focus on the settled Step's exact return anchor before
  the new Start Here.
- Interrupted fixtures enter the same focused identity, show a narrow local
  interruption seam, and use an object-scoped recovery sheet. Dismissal returns
  to the focused interrupted truth; continuation resumes from saved progress.

## Files likely to change

### Production-intended Foundry package

- Add `TodayFlagshipCalibrationContent.swift` for immutable snapshot contracts.
- Add `TodayFlagshipCalibrationFixture.swift` for one deterministic fixture
  family plus dense, long-content, and localization stress projections.
- Add `TodayFlagshipJourneyState.swift` for the fixture-only semantic state
  machine and stable return/recovery anchors.
- Add `TodayFlagshipCalibrationView.swift` for the shell/Today composition and
  native navigation orchestration.
- Add narrowly split local view files for focused Step, review/settlement,
  recovery, and functional dock/accessibility chrome only if needed to keep
  the main view compiler-friendly.
- Add `TodayFlagshipCalibrationPreviews.swift` for matched and stress previews.

### Tests and host

- Add focused fixture/state tests under
  `Packages/AmbitionsPresentation/Tests/AmbitionsNativeVisualFoundryTests`.
- Modify only
  `Native/AmbitionsNativeFoundryHost/AmbitionsNativeFoundryHostApp.swift` to
  select calibration variants and deterministic recording journeys.
- Modify `project.yml` only if a narrow fixture-host UI-test target becomes
  necessary; regenerate the project with XcodeGen if that occurs.

### Plans and evidence

- Add this plan and the complete package under
  `docs/qa/evidence/2026-07-23-today-flagship-calibration-slice-r01`.
- No canon, generated canon, authority, live app, runtime, legacy surface,
  package dependency, token, Figma, Code Connect, or baseline path will change.

## TDD execution tasks

### Task 1 — Fixture and lifecycle contract

1. Add failing tests for deterministic IDs, lineage, current/proposed/settled
   truth, timeline identity, return anchor, recovery variants, long content,
   locked navigation order, and receipt capability.
2. Run the focused test and record the expected compile/test failure.
3. Implement the smallest snapshot and fixture types.
4. Re-run the focused tests green.

### Task 2 — Journey state transitions

1. Add failing tests for non-mutating open, proposal authority, cancel,
   saving-before-settlement, duplicate commit protection, settlement,
   post-settlement eligibility/return focus, interruption, recovery dismissal,
   and recovery continuation.
2. Run the focused tests and record the expected failure.
3. Implement a small value state machine with no runtime dependency.
4. Re-run focused and all package tests green.

### Task 3 — Native journey composition

1. Add Today root composition with compact crown, Start Here, truth,
   consequence, fit, action, timeline beginning, natural scrolling, and Dock.
2. Add focused Step in canonical semantic order with native back behavior.
3. Add full-screen proposal review, saving, settled focused Step, inline receipt
   acknowledgment, Receipt/History disclosure, and explicit return.
4. Add returned Today with settled Step anchor and new truthful Start Here.
5. Add interrupted seam and object-scoped recovery sheet.
6. Add adaptive navigation, dock expansion, accessibility labels/actions,
   focus routing, Reduce Transparency/Motion and no-color distinctions.
7. Add preview variants for TFCS-F01–F10 and stress states.
8. Build and run all package tests after each coherent source group.

### Task 4 — Fixture host and recordings

1. Extend the fixture host launch contract with exact frame and journey IDs.
2. Add deterministic fixture-only playback for the three recordings without
   introducing runtime guarantees.
3. Build the host on the iPhone 17 Pro Simulator.
4. Verify the native rendered frame, navigation, review, saving, settlement,
   return, recovery, scrolling, and accessibility recomposition.

### Task 5 — Visual/stress evidence and self-review

1. Warm the package-backed loop and measure a representative revision latency
   without `clean`; repeat the apparently fastest path twice.
2. Capture TFCS-F01–F10 as real native 1206 × 2622 Simulator frames, including
   an actual scrolled frame.
3. Record TFCS-J01–J03 continuously.
4. Capture or document dense, cancel, saving, recovery review, long copy, RTL,
   Increased Contrast, Differentiate Without Color, Reduce Transparency, and
   Reduce Motion states.
5. Inspect each full-resolution artifact against product identity, hierarchy,
   truth grammar, settlement, return, recovery, native behavior, and
   accessibility gates. Repair only demonstrated issues within this slice.

### Task 6 — Evidence package and fresh validation

1. Complete the required evidence README, design/fixture/architecture/revision
   contracts, accessibility/visual reviews, known limitations, undecided owner
   review, command log, validation, metadata, comparison, and benchmark files.
2. Validate screenshot/recording file hashes, dimensions, durations, IDs, and
   production-baseline false status.
3. Run package build/tests, fixture tests, fixture-host Simulator build,
   SwiftLint, canon build/check, focused compiler tests, boundary scan,
   direct-write scan, weak-implementation scan, Gitleaks, metadata validators,
   `git diff --check`, and changed-path audit.
4. Verify AVF direction/VC closure/auth flags are unchanged; app entry/runtime/
   legacy/dependencies/Figma/Code Connect/baselines are untouched.
5. Commit coherent reviewable slices on the feature branch. Do not merge or
   push. Leave the branch clean and ready for owner review.

## Evidence outputs

- Matched screenshots `TFCS-F01` through `TFCS-F10`.
- Continuous recordings `TFCS-J01` through `TFCS-J03`.
- Machine-readable screenshot and journey metadata with exact fixture ID,
  simulator ID/model/OS, appearance, Dynamic Type, accessibility settings,
  hashes, dimensions/durations, and evaluation-only status.
- Before/after comparison against the accepted Revision-02 bootstrap where
  semantically comparable.
- Warm-loop benchmark, exact commands, validation results, changed paths,
  implementation ending SHA, and explicit direct-device obligations.

## Validation commands

```sh
swift build --package-path Packages/AmbitionsPresentation \
  --target AmbitionsNativeVisualFoundry
swift test --package-path Packages/AmbitionsPresentation
xcodegen generate
xcodebuild -project Ambitions.xcodeproj \
  -scheme AmbitionsNativeFoundryHost \
  -destination 'platform=iOS Simulator,id=EDE1E954-C663-47FB-855B-95F96AE2DBDD' \
  CODE_SIGNING_ALLOWED=NO build
swiftlint lint --strict --reporter xcode <changed Swift files>
python3 scripts/ambitions-canon.py build --check
python3 scripts/ambitions-canon.py check
python3 -m unittest discover -s tools/tests -p 'test_ambitions_canon_compiler.py'
python3 scripts/ambitions-local-first-boundary-scan.py
python3 scripts/ambitions-runtime-direct-write-audit.py
python3 scripts/ci/ambitions-no-weak-implementation-scan.py
bash scripts/ci/ambitions-gitleaks-scan.sh --range-only
git diff --check f2781053d1ffcf962f112014b37d916bd677c450
git status --short
```

## Explicit non-goals and stop-loss

- No change to VC-01–VC-14 or active AVF directions.
- No production `Native/Ambitions/App`, runtime adapter, live mutation,
  persistence, legacy frontend, other root, Search, Capture, app entry, cutover,
  broad design system, final tokens, dependencies, Figma, Code Connect, MCP,
  CLI, injection, snapshot testing, or screenshot baseline work.
- No unsupported control, generic task/dashboard/agenda anatomy, hidden
  architectural defect, or claim beyond fixture/Simulator evidence.
- Stop and report rather than bypassing any requirement that crosses this
  boundary.

