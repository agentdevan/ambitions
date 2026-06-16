# Release Recovery Train 001

Status: Yellow

This train starts the direct repository implementation of the release-red recovery program. It intentionally avoids broad UI rewrites because this execution environment cannot run local Xcode builds, simulator screenshots, or screenshot diffing. Changes are limited to compile-safe canon correction, copy centralization, design-system staging primitives, and regression guards.

## Changed files

- `Native/Ambitions/App/AppTab.swift`
  - Repaired canonical Goals object name from Direction Atlas to Constellation Atlas.
  - Repaired You object name from Personal Runtime to User System Profile.

- `Native/Ambitions/Copy/ProductCopy.swift`
  - Added product-facing copy catalog for Today, Capture, Goals, Time, Motion, You, and inspection-only language.
  - Establishes release-recovery labels such as Start here, Recommended step, Start now, Open step, Constellation Atlas, Atmosphere Composer, LifeShape Field, Motion Current, and User System Profile.

- `Sources/Components/FlagshipObjectStagePrimitives.swift`
  - Added `FlagshipObjectStage` for full-bleed object-stage surfaces.
  - Added `FlagshipSettingsGroup` for native grouped You/settings surfaces.
  - Added `FlagshipInspectionDisclosure` for source/proof/privacy detail after primary meaning is clear.
  - Added `FlagshipStepToken` for display-only recommended step tokens.

- `Sources/Components/SurfacePrimitives.swift`
  - Restored the original shared surface primitives after a connector write fault during this train.

- `scripts/ambitions-release-red-guard.py`
  - Added guard for known release-red regressions: hardcoded Today time, fake Up Next rows, empty production buttons, internal Capture route copy, Time implementation copy, debug labels, and undefined Today source language.

- `scripts/ambitions-copy-contract-lint.py`
  - Added copy contract lint to keep implementation vocabulary out of production Swift strings.

- `scripts/ambitions-empty-action-lint.py`
  - Added production inert button/action detection.

- `scripts/ambitions-first-viewport-card-lint.py`
  - Added generic card-stack dominance lint for top-level surfaces.

## Known remaining Red blockers

The following are not fixed by this train and remain required for Green:

- Today still needs direct reconstruction in `TodayDayRailPanels.swift`, `TodayScreen.swift`, `DayRailViewState.swift`, and `TodayExecutionProjector.swift`.
- Capture still needs direct reconstruction in `AppShellView.swift`, `CaptureScreen.swift`, and `CaptureViewModel.swift`.
- Closure still needs persistence-backed mutation through `TodayViewModel.swift`, `AppServices.swift`, and the repository-backed Today service.
- Time still needs direct reconstruction in `TimeLifeShapeField.swift`, `TimeScreen.swift`, and `TimeLifeSuiteState.swift`.
- Motion still needs production action wiring and runtime-backed state in `MotionCurrentScreen.swift` plus a new `MotionViewModel`/service.
- You still needs direct root/settings reconstruction in `YouRootSurface.swift`, `YouScreen.swift`, `YouFeatureService.swift`, and detail card files.

## Required validation

Run locally on main:

```bash
git status --short --branch
python3 scripts/ambitions-release-red-guard.py
python3 scripts/ambitions-copy-contract-lint.py
python3 scripts/ambitions-empty-action-lint.py
python3 scripts/ambitions-first-viewport-card-lint.py
swift test
xcodebuild -scheme Ambitions -destination 'platform=iOS Simulator,name=iPhone 17 Pro' test
```

Expected current result: the new guards should fail until the remaining release-red source strings and inert actions are removed. That is intentional; the guards now expose the work that must be made Green.

## Rollback note

If any issue appears from Train 001, the safest rollback target is the commit immediately before `Repair canonical Goals surface contract`, then re-apply only `AppTab.swift` after local build verification.
