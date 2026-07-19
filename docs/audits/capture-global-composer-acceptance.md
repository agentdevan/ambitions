# AMB-1736 Capture Global Composer Acceptance

Status: Implemented Yellow / source-route and mutation-path acceptance
Date: 2026-07-05
Scope: AMB-1736
Baseline SHA: `5d08099531dc08570362cabd9c83a886b1463aea`

## Purpose

AMB-1736 accepts the current Capture-to-Today usable-flow source spine before
frontend polish and screenshot proof continue.

This is a parent synthesis artifact. It does not implement UI, run the app,
produce screenshots, prove VoiceOver, prove keyboard behavior, prove device
behavior, or close AMB-1479.

## Current Acceptance Result

| Acceptance area | Current source result | Proof ceiling |
| --- | --- | --- |
| Global reachability | `AppShellContextualToolbarCatalog.actions(for:)` adds a Capture action for every canonical surface: Today, Goals, Time, You. | Source-present Yellow; not runtime-tapped here. |
| Surface source mapping | `AppShellCaptureAccessModel.source(for:)` maps Today/Goals/Time/You to surface-specific Capture sources. | Source-present Yellow; not UI-proven here. |
| Full-screen composer seam | `QuietCommandCaptureOverlay` redirects quick Capture to `presentGlobalCaptureComposer`; `AmbitionsStage` renders `AppShellActivatedCaptureSeam` for activated Capture overlays. | Source-present Yellow; no screenshot or keyboard proof. |
| Save path | `AppShellActivatedCaptureSeam.saveCapture()` calls `DefaultShellCommandRouter.execute(.quickCapture)` with raw text and selected route. | Source-present Yellow; not executed here. |
| Approved local mutation path | `DefaultShellCommandRouter.execute(.quickCapture)` builds an `AmbitionsCommand` and routes through `AmbitionsCommandExecutor`; `executeQuickCapture` calls `captureService.createCapture`. | Source-present Yellow; no focused runtime test here. |
| Local persistence | `DefaultCaptureService.createCapture` validates non-empty text, prepares routing, creates local Capture state, saves through the repository, and appends capture events. | Source-present Yellow; no store/runtime proof in this pass. |
| Confirmation / receipt | Save success updates visible `saveState`; command routing records a shell route receipt and pipeline trace. `CaptureComposerSurface` renders `captureReceiptPreview` from `CaptureActionMessage`. | Source-present Yellow; no rendered receipt proof. |
| Today resurfacing | `TodayFeatureSnapshot` loads captures; `TodayReadModelProjector` includes captures in Today reality/believability/Now State; `TodayExecutionProjector.capturePanel` exposes capture pressure/open Capture action. | Source-present Yellow; no current Today screenshot or mutation proof. |
| Find again | `MemoryLensService` loads captures; `makeCaptureResults` returns local Capture results that open Capture or linked goal. | Source-present Yellow; no current search journey proof. |
| Attach / route / park | `CaptureViewModel` exposes attach-to-goal, route-to-Time, waiting, optional-someday, archive, and deliverable-seed actions. | Source-present Yellow; not exercised here. |
| Failure/offline | Empty text is blocked; command failure returns a user-facing message and no mutation. Offline/no-account source is local, but no failure walkthrough was run here. | Partial Yellow; needs AMB-1767 and screenshot/accessibility proof. |

## No-Fake-Yellow Decision

AMB-1736 can close as Implemented Yellow because the current source is not only
a composer shell:

- the composer can reach a save action
- save routes through the shared command executor
- command execution creates local Capture records through `DefaultCaptureService`
- Capture records are read by Today projection and Memory Lens search
- visible confirmation and receipt surfaces are source-present

It must not close Green because none of that behavior was executed in this pass.

## Evidence Chain

Primary source evidence:

- `Native/Ambitions/Stage/Chrome/AppShellContextualToolbarCatalog.swift`
- `Native/Ambitions/Stage/Overlays/QuietCommandCaptureOverlay.swift`
- `Native/Ambitions/Stage/AmbitionsStage.swift`
- `Native/Ambitions/App/AppShellActivatedCaptureSeam.swift`
- `Native/Ambitions/App/ShellCommandRouter.swift`
- `Native/Ambitions/Composer/Capture/CaptureComposerSurface.swift`
- `Native/Ambitions/Composer/Capture/CaptureViewModel.swift`
- `Native/Ambitions/Core/LocalRuntimeOS/Commands/AmbitionsCommandExecutor+CaptureCommands.swift`
- `Native/Ambitions/Core/LocalRuntimeOS/CaptureRouting/DefaultCaptureService.swift`
- `Native/Ambitions/Surfaces/Today/Projection/TodayFeatureSnapshot.swift`
- `Native/Ambitions/Surfaces/Today/Projection/TodayReadModelProjector.swift`
- `Native/Ambitions/Surfaces/Today/Projection/TodayExecutionProjector+02-TodayExecutionProjector+Projector03-deeperSections.swift`
- `Native/Ambitions/Core/LocalRuntimeOS/Search/MemoryLensService+SearchResults.swift`

Supporting audit artifacts:

- `docs/audits/root-ia-stage-shell-acceptance.md`
- `docs/audits/frontend-screen-route-registry.md`
- `docs/audits/frontend-journey-registry.md`
- `docs/audits/frontend-missing-screen-audit.md`
- `docs/audits/frontend-product-law-drift-scan.md`

## Remaining Yellow Debt

- AMB-1479 still blocks visual-authority Green and broad UI implementation
  claims.
- No XCTest, UI journey, simulator, screenshot, or device run was performed for
  this acceptance.
- Composer empty/composing/confirmation/receipt/failure screenshots are missing.
- Today resurfacing screenshot and current mutation proof are missing.
- VoiceOver label order, focus restoration, keyboard clearance, Dynamic Type,
  Reduce Motion, and hit target proof are missing.
- Offline/no-account walkthrough and failure-state proof are missing.
- Attach-to-goal, schedule/Time, waiting, optional-someday, archive, and
  deliverable-seed journeys are source-present but not executed here.
- Label drift remains: AMB-1768 classifies `surface:capture` as misleading
  taxonomy until label cleanup happens.

## Follow-Up Routing

| Follow-up | Owner | Reason |
| --- | --- | --- |
| AMB-1479 | Visual specification authority | Blocks Visual Green and broad UI implementation authority. |
| AMB-1770 | Capture full-screen composer proof | Needs screenshot, accessibility, dismissal, rollback, and keyboard proof. |
| AMB-1767 | Offline / no-account frontend acceptance | Needs no-account and airplane-mode walkthrough proof. |
| AMB-1765 / AMB-1775 | Screenshot and shell matrix | Needs current Capture and shell screenshots. |
| AMB-1766 / AMB-1743 | Accessibility acceptance | Needs VoiceOver, Dynamic Type, Reduce Motion, hit-target proof. |
| AMB-1764 / AMB-1771 | Search acceptance | Needs find-again and local-only handoff proof. |

## Proof Ceiling

Claim status for AMB-1736: Implemented Yellow.

Allowed claim:

- Current source supports a global Capture composer with a local command-save
  path, local persistence source, Today capture projection, and Memory Lens
  find-again source.

Forbidden claims from this packet:

- Capture Green
- rendered composer proof
- successful runtime save proof
- screenshot proof
- accessibility conformance
- keyboard behavior proof
- offline/no-account proof
- device proof
- release readiness
- App Store readiness
- AMB-1479 closure

## Rollback

This packet adds docs only. Roll back by reverting the AMB-1736 audit artifact.
If future source changes regress Capture save/resurface behavior, use this
source evidence chain and AMB-1751 registry files as the comparison baseline.
