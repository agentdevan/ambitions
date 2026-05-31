# AFRI-021 Today Reality Meridian Proof

Status: Green, local simulator proof only
Issue: AMB-373 / AFRI-021
Date: 2026-05-31

## Scope

AFRI-021 verifies the existing Today route as a Reality Meridian surface with Start here inside that system, rather than adding a detached recommendation stack.

The active route entry remains `AmbitionsRootView.todayNavigation()` and the root Today surface remains `TodayScreen`. The primary Today object is still the Reality Meridian rail (`RealityMeridianView`, `TodayRealityRail`, and `TodayRealityMeridianFusedRail`). This batch adds explicit replay coverage on the Start here hero state and repairs the persistence read path that was dropping goal `lifeGraph` context from normal list reads.

## Source Changes

- `Native/Ambitions/Features/Today/DayRailViewState.swift`
  - Adds `TodayStartHereReplayCoverageState`.
  - Binds Start here replay coverage to Reality Meridian, `SourceRecord`, `Receipt`, `ReplayTrace`, and You / What Ambitions knows inspection labels.
- `Native/Ambitions/Features/Today/TodayScreen.swift`
  - Applies the existing fused current-time Reality Meridian modifier to the live Today route.
- `Native/Ambitions/Features/Today/TodayDayRailPanels.swift`
  - Mounts the topology strip in the live Reality Meridian rail.
  - Keeps Start here and source-freshness identifiers on the active hero path.
- `Native/Ambitions/Features/Today/TodayRealityMeridianTopology.swift`
  - Adds stable Now, Next, and Later identifiers to the topology badges.
- `Native/AmbitionsTests/Today/TodayViewModelTests.swift`
  - Asserts the Day Rail / Reality Meridian Start here projection carries green replay coverage.
- `Native/Ambitions/Persistence/SwiftDataRepositories.swift`
  - Decodes stored goal snapshots on normal `GoalRecord` reads so scalar-backed reconstruction preserves `lifeGraph` context.
  - This keeps Today lens selection, shared-responsibility summaries, recovery posture, and outside-lens proof grounded in persisted goal context.

## Proof

Verified locally:

- Pre implementation guard:
  - `python3 scripts/ambitions-parallel-implementation-guard.py --phase pre --batch AMB-373 --prompt /tmp/AMB-373-AFRI-021-guard-prompt.md`
  - Result: Green
- Repair subset after persistence mapper fix:
  - `xcodebuild test -project Ambitions.xcodeproj -scheme Ambitions -destination id=8ACCD665-4807-4102-B526-5A1AE20686A8 -only-testing:AmbitionsTests/TodayViewModelTests/testToday2StableHeroShowsContextLensBestMoveExplanationAndCommands -only-testing:AmbitionsTests/TodayViewModelTests/testToday2RecoveryHeroProtectsHighConsequenceDeadlineAndDefersPassiveWork -only-testing:AmbitionsTests/TodayViewModelTests/testToday2OutsideLensAndWaitingStaySummarized -only-testing:AmbitionsTests/TodayViewModelTests/testRepositoryBackedServiceCanSurfaceSharedResponsibilityRitualThesis`
  - Result: Green, 4 tests, 0 failures
- Today unit lane:
  - `xcodebuild test -project Ambitions.xcodeproj -scheme Ambitions -destination id=8ACCD665-4807-4102-B526-5A1AE20686A8 -only-testing:AmbitionsTests/TodayViewModelTests`
  - Result: Green, 45 tests, 0 failures
- Today UI smoke lane:
  - `xcodebuild test -project Ambitions.xcodeproj -scheme Ambitions -destination id=8ACCD665-4807-4102-B526-5A1AE20686A8 -only-testing:AmbitionsUITests/AmbitionsUITests/testTodaySurfaceShowsDominantHeroAndPrimaryAction`
  - Result: Green, 1 test, 0 failures
- Refreshed Today unit lane after UI repairs:
  - `xcodebuild test -project Ambitions.xcodeproj -scheme Ambitions -destination id=8ACCD665-4807-4102-B526-5A1AE20686A8 -only-testing:AmbitionsTests/TodayViewModelTests`
  - Result: Green, 45 tests, 0 failures
- Post implementation guard:
  - `python3 scripts/ambitions-parallel-implementation-guard.py --phase post --batch AMB-373 --prompt /tmp/AMB-373-AFRI-021-guard-prompt.md --changed-from HEAD --changed-path Native/Ambitions/Features/Today/DayRailViewState.swift --changed-path Native/Ambitions/Features/Today/TodayScreen.swift --changed-path Native/Ambitions/Features/Today/TodayDayRailPanels.swift --changed-path Native/Ambitions/Features/Today/TodayRealityMeridianTopology.swift --changed-path Native/Ambitions/Persistence/SwiftDataRepositories.swift --changed-path Native/AmbitionsTests/Today/TodayViewModelTests.swift --changed-path docs/proof/afri/afri-021-today-reality-meridian-proof.md --changed-path docs/codex/concept-lock-registry.yml`
  - Result: Green

## Boundaries

- This is simulator proof, not device, TestFlight, App Store, release, or signed archive proof.
- This proof does not claim a new visual redesign. It hardens the existing Today / Reality Meridian route, current-time fusion, topology visibility, and Start here replay contract.
- Screenshot export proof is not claimed here. The UI smoke test verified the live simulator surface by accessibility identifiers; dedicated screenshot export hardening remains separately tracked.
