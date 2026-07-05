# AMB-1673 Stage Thinness Inventory

Status: source remediation proof for AMB-1673.

This inventory is not rendered UI proof, manual VoiceOver proof, device proof, or release proof. It records current source ownership after the AMB-1673 rehome so Stage remains the shell and cross-surface presentation owner, not a surface-specific composition or projection owner.

## Stage-Owned Responsibilities

| Category | Current owner files | Thinness boundary |
|---|---|---|
| Routing | `Native/Ambitions/Stage/StageRoute.swift`, `Native/Ambitions/Stage/StageStore.swift`, `Native/Ambitions/Stage/StagePathStore.swift`, `Native/Ambitions/Stage/StageReducer.swift`, `Native/Ambitions/Stage/StageEffectRunner.swift` | Stage may select the current persistent surface, preserve route restoration, and dispatch deep link routes. It must not construct domain projections or mutate canonical state. |
| Overlays | `Native/Ambitions/Stage/Overlays/AppShellOverlayView.swift`, `Native/Ambitions/Stage/Overlays/CapturePresentationRoute.swift`, `Native/Ambitions/Stage/Overlays/QuietCommandCaptureOverlay.swift`, `Native/Ambitions/Stage/Overlays/QuietCommandMemoryLensOverlay.swift`, `Native/Ambitions/Stage/Overlays/QuietCommandSheetView.swift`, `Native/Ambitions/Stage/Overlays/ShellOverlayState.swift` | Stage may present shell overlays and route Capture/search entry. Surface-specific sheets and overlay projection contracts belong to their product owners. |
| Chrome | `Native/Ambitions/Stage/Chrome/`, `Native/Ambitions/Stage/StageChrome.swift`, `Native/Ambitions/Stage/StageSafeAreaPolicy.swift` | Stage may own root dock/header/safe area shell policy. It must not expose Stage or architecture language as product depth. |
| Animation | `Native/Ambitions/Stage/Motion/`, `Native/Ambitions/Stage/StageMorphCoordinator.swift`, `Native/Ambitions/Stage/StageTransitionSpec.swift`, `Native/Ambitions/Stage/StageMutationAnimator.swift` | Stage owns motion coordination, haptics boundaries, and reduced motion fallback behavior. Runtime mutation authority remains outside Stage. |
| Focus | `Native/Ambitions/Stage/StageFocusCoordinator.swift` | Stage may restore shell focus after route and overlay changes. Surface-specific VoiceOver semantics remain in the surface/projection contracts. |
| Mutation | `Native/Ambitions/Stage/StageAction.swift`, `Native/Ambitions/Stage/StageEffect.swift`, `Native/Ambitions/Stage/StageMutationAnimator.swift` | Stage actions/effects are shell presentation events only. Canonical data mutation remains under `Core/LocalRuntimeOS/` and command/event/projection/receipt/replay law. |
| Projection | `Native/Ambitions/Projection/Contracts/OverlayProjectionContracts.swift` | Stage no longer owns `Stage/Overlays/Projection`. Search projection is under `Surfaces/You/Projection`; closure projection is under `Surfaces/Today/Projection`; Capture and Trust stay under their canonical owners. |
| Domain leakage | No domain model, persistence, LocalRuntimeOS, or surface-specific projection source remains under `Native/Ambitions/Stage/Overlays/`. | Any future Stage file that builds Today, Goals, Time, You, Capture, Trust, Search, closure, persistence, or runtime projection state is a regression. |
| Custom navigation | `Native/Ambitions/Stage/StageStore.swift` and `Native/Ambitions/Stage/StagePathStore.swift` are retained only for shell root/drilldown/overlay state and SwiftUI route dispatch. | Stage must continue using native SwiftUI navigation behavior for drilldowns and avoid becoming a generic navigation framework. |

## Rehomed Owners

| Moved responsibility | Canonical owner |
|---|---|
| Today closure, rejection, detail, and replacement sheets | `Native/Ambitions/Surfaces/Today/Overlays/` |
| Closure overlay lens and Stage scene projection contracts | `Native/Ambitions/Surfaces/Today/Projection/` |
| Search overlay lens and Stage scene projection contracts | `Native/Ambitions/Surfaces/You/Projection/` |

## Current Automated Coverage

| Required AMB-1673 proof area | Current coverage |
|---|---|
| Reduced motion | `Native/AmbitionsTests/App/StageMotionRoutingTests.swift` and `Native/AmbitionsTests/App/StageThinnessOwnershipTests.swift` assert reduced motion disables ambient movement and keeps semantic queries static. |
| VoiceOver/source accessibility semantics | `Native/AmbitionsTests/Projection/OverlayScenesCanonicalOwnershipTests.swift` and `Native/AmbitionsTests/App/StageThinnessOwnershipTests.swift` assert overlay scene semantic mirrors carry accessibility boundaries. |
| Deep link routing | `Native/AmbitionsTests/App/ExternalRoutingTests.swift` and `Native/AmbitionsTests/App/StageThinnessOwnershipTests.swift` assert external deep links dispatch through Stage shell routes and overlays without adding a new surface owner. |

## Nonclaims

- No manual VoiceOver walkthrough is claimed.
- No rendered screenshot, visual Green, device Green, TestFlight, App Store, privacy/legal, or release readiness claim is made.
- `Stage/Chrome/TodayViewportSafety.swift` remains a Stage chrome/safe-area policy file by current source naming. It is not projection or domain authority, but it should be revisited if a future train splits Today-specific viewport policy into `Surfaces/Today`.
