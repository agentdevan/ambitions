# Train 6 Closure Refraction Closeout

Date: 2026-06-18
Branch: main
Status: Yellow
Train: 6, with repair subtrain 6.1
Commit SHA: recorded by the pushed Train 6 commit after this closeout is committed.

## Outcome

Train 6 replaced Today closure preview anatomy with a real closure-stage mutation path aligned to the final architecture tree:

- Runtime policy owner: `Native/Ambitions/Core/Runtime/ClosureEngine.swift`
- Projection mutation owner: `Native/Ambitions/Projection/Mutations/StageMutation.swift`
- Closure projection owner: `Native/Ambitions/Projection/Mutations/ClosureStageMutation.swift`
- Today feature owner: Today applies projected closure mutation to the visible Reality Meridian rail; it does not own closure consequence policy.

The user concern about architecture enforcement was valid. The repair moved closure policy and mutation shape out of Today feature-only code and added an architecture gate to the Goal Mode plan.

## Files Changed

Created:

- `Native/Ambitions/Core/Runtime/ClosureEngine.swift`
- `Native/Ambitions/Projection/Mutations/StageMutation.swift`
- `Native/Ambitions/Projection/Mutations/ClosureStageMutation.swift`
- `docs/superpowers/plans/2026-06-18-design-truth-refraction-trains-6-completion.md`
- `docs/validation/train_6_closure_refraction_closeout.md`

Modified:

- `Native/Ambitions/Features/Today/DayRailViewState.swift`
- `Native/Ambitions/Features/Today/TodayActionClosureSheet.swift`
- `Native/Ambitions/Features/Today/TodayActionClosureSheetState.swift`
- `Native/Ambitions/Features/Today/TodayClosureRecord.swift`
- `Native/Ambitions/Features/Today/TodayDayRailPanels.swift`
- `Native/Ambitions/Features/Today/TodayExecutionCompatibility.swift`
- `Native/Ambitions/Features/Today/TodayFeatureModels.swift`
- `Native/Ambitions/Features/Today/TodayFeatureSnapshot.swift`
- `Native/Ambitions/Features/Today/TodayProofReceiptLedgerState.swift`
- `Native/Ambitions/Features/Today/TodayViewModel.swift`
- `Native/AmbitionsTests/Today/TodayViewModelTests.swift`

Deleted: none.

## Validation

Passed:

- `xcodegen generate`
- `git diff --check`
- `python3 scripts/ambitions-copy-contract-lint.py --include-components`
- `scripts/canon-language-drift-scan.sh`
  - Green for changed-file canon language drift.
  - Existing backlog remains outside this source slice.
- `scripts/release-claim-safety-scan.sh`
- `python3 scripts/ambitions-unsupported-claim-scan.py Native/Ambitions/Core/Runtime Native/Ambitions/Projection/Mutations Native/Ambitions/Features/Today Native/AmbitionsTests/Today docs/superpowers/plans/2026-06-18-design-truth-refraction-trains-6-completion.md`
- `scripts/ambitions-xcode-test-focused.sh --batch DESIGN_TRUTH_TRAIN_06_1 --test AmbitionsTests/TodayViewModelTests --timeout 15m --kill-after 60s`
  - Result: passed, 51 tests executed, 0 failures.
  - Result bundle: `.codex/xcode-results/DESIGN_TRUTH_TRAIN_06_1/20260619T005144Z-AmbitionsTests-TodayViewModelTests-23027-9551/focused-test.xcresult`
- `scripts/ambitions-xcode-build-for-testing.sh --batch DESIGN_TRUTH_TRAIN_06_1 --timeout 30m --kill-after 60s`
  - Result: Test Build Succeeded.
  - Summary: `.codex/xcode-summaries/DESIGN_TRUTH_TRAIN_06_1/20260619T005342Z/extract/summary.json`

Failed:

- `scripts/ambitions-run-ui-screenshot-matrix.sh --batch DESIGN_TRUTH_TRAIN_06 --timeout 20m --kill-after 60s`
  - Result: failed in AMB-962 `receipt-visible`.
  - Failure: required closure copy `Waiting` was not visible before the XCTest 4 minute allowance.
  - Result bundle: `.codex/xcode-results/DESIGN_TRUTH_TRAIN_06/20260619T003933Z-AMB962.xcresult`
  - Extract: `.codex/xcode-summaries/DESIGN_TRUTH_TRAIN_06/20260619T003933Z-AMB962/extract/summary.json`

Not rerun:

- AMB-962 was not rerun after the 6.1 repair because the plan authorizes one timeout retry only. Current closure-sheet visual proof is therefore absent.

## Screenshots And Accessibility

Screenshots visually reviewed: not claimed for the repaired closure sheet.

Reason: AMB-962 failed before the `receipt-visible` screenshot capture point, then exhausted the retry budget. The source repair makes `Waiting` first-layer visible through a compact closure outcome picker, but that repaired state does not have current screenshot proof.

Accessibility notes:

- First-layer closure outcomes now expose button labels, values, hints, and stable accessibility identifiers.
- `Waiting` is no longer hidden behind collapsed disclosure.
- Focused tests cover closure receipt, mutation completeness, visible Today mutation, proof artifact label, undo availability, and accessibility announcement.
- Full VoiceOver, Dynamic Type screenshot, and human visual review for the repaired closure sheet remain unproven in this train.

## Mutation Proof

Every saved closure response now carries a `ClosureStageMutation` built from:

- Runtime mutation id
- Before and after closure snapshots
- Target surface `.today`
- Affected step and closure ids
- User-visible mutation summary
- Motion event
- Accessibility announcement
- Haptic intent
- Undo availability
- Proof artifact label
- Safe fallback

`TodayViewModel` refreshes the Today state and applies the projected closure mutation to the loaded Day Rail view state, producing visible Today mutation without making Today own the runtime policy.

## Known Risks

- AMB-962 visual proof is Yellow until a future train or approved repair run captures and visually reviews the repaired closure sheet.
- Existing Swift warning remains in `Native/Ambitions/App/AmbitionsRootView.swift` about calling `routeStageMotionAction(_:source:)` from a synchronous nonisolated context. It was not introduced by Train 6 and build-for-testing still passed.
- Canon-language scan continues to report existing backlog hits outside this source slice.

## Rollback Plan

Revert the Train 6 commit(s) from `main`. This restores the prior Today closure sheet and removes the new runtime/projection mutation files. No `docs/truth/*` canon files were changed.
