# UIQL-003 Today Reality Meridian Quality Gate

Status: Green for the scoped UIQL-003 Today / Reality Meridian first-viewport quality gate. No owner approval, full accessibility certification, release readiness, TestFlight readiness, App Store readiness, or physical-device proof is claimed.

## Scope

UIQL-003 covers the current Today first viewport and its Reality Meridian / Start here object-stage behavior. It does not cover Goals, Time, Motion, You, Capture, PLOS runtime completeness, owner approval, or release readiness.

## Current Linear State

Available Linear connector lookup returned `Issue not found` for `UIQL-003`. Manual closeout text is included below. No Linear state was updated.

## Source Findings

- Today already owns the active first-viewport object through `RealityMeridianView` / `AmbitionsDayRailView`.
- `TodayObjectStagePrimitiveContract.current` defines the Today object as `Reality Meridian / Start Here` and requires a full-bleed object stage, source/trust line order, Dynamic Type fallback, Differentiate Without Color fallback, and no visible first-viewport card structure.
- The UI surface still had Today-adjacent visible copy that used generic task/card/dashboard wording in support projections:
  - `Standalone tasks stay small.`
  - `No standalone task is pulling on Today.`
  - `Tasks are standalone One-Step Goals.`
  - `No blank dashboard`
  - `One clear step matters more than another stack of cards.`
- Existing UI automation checked that Today elements existed, but did not prove the visible first viewport was current Reality Meridian copy rather than a stale/generic Today surface.

## Changes

- `Native/Ambitions/Features/Today/TodayFeatureService.swift`
  - Replaced the stable Today subtitle with step-native non-card language: `One clear step matters more than another layer of noise.`
- `Native/Ambitions/Features/Today/TodayExecutionProjector.swift`
  - Replaced standalone-task support copy with loose-step copy.
  - Replaced `No blank dashboard` with `No false certainty`.
- `Native/Ambitions/Features/Today/TodayExecutionCompatibility.swift`
  - Matched compatibility One-Step Goal copy to the step-native wording.
- `Native/AmbitionsUITests/AmbitionsUITests.swift`
  - Added `testUIQL003TodayRealityMeridianOwnsFirstViewportWithoutGenericTaskAnatomy`.
  - Tightened Today readiness away from legacy `today.hero-card` / `TodayRealityRailHeroCard` fallback identifiers.
  - The new test proves visible `Start here`, `On-device`, `Up next`, and either the preview recommendation or empty Start here fallback appear before the native dock, and stale/generic copy is not rendered.

## Visual Evaluation

Screenshot evaluated: `artifacts/ui-quality-lockdown/screenshots/UIQL-003-today-preview-stable-final.png`

Observed current rebuilt app state:

- The first viewport is a full-bleed Reality Meridian object stage, not a stacked card/list/dashboard surface.
- `Start here`, `Draft the talk outline`, source/trust labels, `Start now`, `Why this?`, `Move this`, `Up next`, and `Proof saved` are visible.
- The source/trust line is readable and attached to the Start here decision.
- No visible `Recommended next move`, `next best move`, `Begin Focus`, `task list`, `Standalone tasks stay small`, `No standalone task is pulling on Today`, or `No blank dashboard` copy appears.
- Screenshot path alone is not treated as proof; the image was visually inspected in this run.

## Final Validation

- `git diff --check`
  - Exit: `0`
- `bash .agents/skills/uiql-quality-lockdown/scripts/uiql-scan-banned-copy.sh`
  - Exit: `0`
  - Artifact: `artifacts/ui-quality-lockdown/script-output/uiql-banned-copy.log`
- `bash .agents/skills/uiql-quality-lockdown/scripts/uiql-scan-card-anatomy.sh`
  - Exit: `0`
  - Artifact: `artifacts/ui-quality-lockdown/script-output/uiql-card-anatomy.log`
- `bash .agents/skills/uiql-quality-lockdown/scripts/uiql-mini-regression.sh`
  - Exit: `0`
  - Artifacts: `artifacts/ui-quality-lockdown/script-output/uiql-banned-copy.log`, `uiql-card-anatomy.log`, `uiql-shell.log`
- `scripts/ambitions-xcode-build-for-testing.sh --batch UIQL-003`
  - Final exit: `0`
  - Artifact: `artifacts/ui-quality-lockdown/script-output/UIQL-003-build-for-testing-after-headline-repair-20260611T065532Z.log`
- `AMBITIONS_SIM_UDID=8ACCD665-4807-4102-B526-5A1AE20686A8 scripts/ambitions-xcode-test-focused.sh --batch UIQL-003 --only-testing AmbitionsUITests/AmbitionsUITests/testUIQL003TodayRealityMeridianOwnsFirstViewportWithoutGenericTaskAnatomy`
  - Final exit: `0`
  - Artifact: `artifacts/ui-quality-lockdown/script-output/UIQL-003-focused-ui-test-after-headline-repair-20260611T065658Z.log`
  - Result: 1 UI test, 0 failures.
- `AMBITIONS_SIM_UDID=8ACCD665-4807-4102-B526-5A1AE20686A8 scripts/ambitions-xcode-test-focused.sh --batch UIQL-003 --only-testing AmbitionsTests/TodayViewModelTests/testF02RealityRailVisibleCopyAvoidsForbiddenTerms`
  - Exit: `0`
  - Artifact: `artifacts/ui-quality-lockdown/script-output/UIQL-003-focused-unit-visible-copy-booted-20260611T070244Z.log`
- `AMBITIONS_SIM_UDID=8ACCD665-4807-4102-B526-5A1AE20686A8 scripts/ambitions-xcode-test-focused.sh --batch UIQL-003 --only-testing AmbitionsTests/TodayRealityMeridianExperienceElevationTests`
  - Exit: `0`
  - Artifact: `artifacts/ui-quality-lockdown/script-output/UIQL-003-focused-unit-object-stage-booted-20260611T070425Z.log`

## Failed Evidence Kept

Failed or interrupted logs are retained because they explain the repair path and prevent false Green:

- `artifacts/ui-quality-lockdown/script-output/UIQL-003-focused-ui-test-20260611T062433Z.log`
- `artifacts/ui-quality-lockdown/script-output/UIQL-003-focused-ui-test-after-test-bootstrap-repair-20260611T063508Z.log`
- `artifacts/ui-quality-lockdown/script-output/UIQL-003-focused-ui-test-booted-sim-20260611T064354Z.log`
- `artifacts/ui-quality-lockdown/script-output/UIQL-003-focused-ui-test-after-visible-proof-repair-20260611T065157Z.log`
- Empty/terminated parallel unit logs from the abandoned concurrent run:
  - `artifacts/ui-quality-lockdown/script-output/UIQL-003-focused-unit-visible-copy-20260611T065914Z.log`
  - `artifacts/ui-quality-lockdown/script-output/UIQL-003-focused-unit-object-stage-20260611T065914Z.log`

## Repair Cycles

UIQL-003 used three repair cycles:

1. Initial UI test assumed identifier readiness and failed before geometry assertions.
2. Test bootstrap was pinned to preview-stable and booted simulator, but readiness still depended on identifiers unavailable to the UI automation snapshot.
3. Final repair validated visible product labels and accepted either the preview recommendation headline or empty Start here fallback. Final focused UI test passed.

No repair reframe report is required because the final Green occurred on cycle 3, not after more than three cycles.

## Gate Status

- Green: Today first viewport renders Reality Meridian / Start here as the dominant object stage in current screenshot evaluation.
- Green: visible source/trust, Start now, Up next, and proof/receipt copy are present and readable in the evaluated screenshot.
- Green: forbidden stale/generic Today copy was removed from touched Today source paths and guarded by UI/unit tests.
- Green: focused UIQL-003 UI test passes after rebuild.
- Green: Today visible-copy unit test and Today Reality Meridian object-stage unit suite pass.
- Yellow: Linear issue update is manual because `UIQL-003` was not found by the available connector.
- Yellow: full accessibility certification, physical-device proof, owner approval, release readiness, TestFlight readiness, and App Store readiness are not in scope and are not claimed.
- Red: none remaining for UIQL-003 scope.

## Non-Claims

This does not prove full accessibility conformance, Dynamic Type certification beyond existing object-stage unit contracts and current visual inspection, VoiceOver audit, Reduce Motion audit, Increase Contrast audit, physical-device behavior, performance, privacy/legal approval, owner approval, release readiness, TestFlight readiness, App Store readiness, PLOS runtime completeness, or UIQL-004+ gates.

## Manual Linear Closeout

```text
UIQL-003 Today / Reality Meridian quality gate

- Pushed to main: pending this commit
- App source changed: yes, Today copy only
- UI test source changed: yes, UIQL-003 first-viewport visible-object proof
- New top-level tabs: no
- Capture top-level tab: no
- Validation:
  - git diff --check: pass
  - uiql-scan-banned-copy: exit 0
  - uiql-scan-card-anatomy: exit 0
  - uiql-mini-regression: exit 0
  - build-for-testing after final fix: exit 0
  - UIQL-003 focused UI test: 1 test, 0 failures
  - Today visible-copy unit test: exit 0
  - Today Reality Meridian object-stage unit suite: exit 0
  - screenshot visually evaluated: artifacts/ui-quality-lockdown/screenshots/UIQL-003-today-preview-stable-final.png
- Red blockers: none for UIQL-003 scope
- Yellow: Linear issue not found; full accessibility/device/owner/release approval not claimed
- Owner approval claimed: no
- Release/TestFlight/App Store readiness claimed: no
- Next: UIQL-004
```
