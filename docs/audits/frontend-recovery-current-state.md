# Frontend Recovery Current State

Status: Current-main evidence pass / Implemented Yellow
Date: 2026-07-05
Scope: AMB-1751, current-main frontend registry evidence pass
Baseline SHA: `9885e8fbd32089c872376b47ff2aa8ab9b338afd`

## Purpose

This audit records the current route, screen, and journey evidence on `main`
before frontend implementation work is promoted to Codex execution.

This is an evidence and registry pass only. It does not implement product UI,
run XCTest/UI journeys, produce new screenshots, prove Visual Green, prove
accessibility conformance, prove device behavior, prove TestFlight readiness,
prove App Store readiness, or prove Release Green.

## Authority Inputs

Required inputs inspected for this pass:

- `AGENTS.md`
- `docs/truth/CODEX_START_HERE.md`
- `docs/truth/PRODUCT_DESIGN_TRUTH.md`
- `docs/truth/IMPLEMENTATION_TRUTH.md`
- `docs/truth/RELEASE_TRUTH.md`
- `project.yml`
- `Native/Ambitions/`
- `Native/AmbitionsTests/`
- `Native/AmbitionsUITests/`
- `docs/qa/`
- `docs/audits/`
- screenshot and visual QA evidence directories under `docs/qa/evidence/`

Current controlling product law:

- Persistent Stage surfaces are exactly Today, Goals, Time, You.
- Capture is the global composer/action layer, not a tab.
- Motion is Stage/Motion behavior, not a destination.
- Proof, Source, Privacy, History, and Receipts are contextual inspection
  details, not root surfaces.
- Source and route evidence can support current-main registry findings, but
  rendered frontend quality and release readiness require separate current
  proof artifacts.

## Current Route Posture

| Area | Current-main finding | Classification | Evidence |
| --- | --- | --- | --- |
| App entry | `AmbitionsApp` instantiates `AmbitionsRootScene`; `AmbitionsRootScene` hosts `LaunchGateView` in a `WindowGroup` and registers Source Atlas app refresh. | implemented-source-present | `Native/Ambitions/App/AmbitionsApp.swift:3`, `Native/Ambitions/App/AmbitionsRootScene.swift:8` |
| Stage host | `AmbitionsStageHost` wraps `AmbitionsStage` with app dependencies and accessibility identity. | implemented-source-present | `Native/Ambitions/App/AmbitionsStageHost.swift:5` |
| Root shell | `AmbitionsRootStageSurfaceHost` switches only Today, Goals, Time, You. `AmbitionsSurface.allCases` is exactly those four surfaces. | implemented-source-present | `Native/Ambitions/App/AmbitionsRootStageSurfaceHost.swift:11`, `Native/Ambitions/Stage/AmbitionsSurface.swift:3` |
| Root dock | `StageDockDestination.all` derives from `AmbitionsSurface.allCases`; no Capture, Motion, Plan, Pulse, Profile, or Captures dock entry is source-present. | implemented-source-present | `Native/Ambitions/Stage/StageChrome.swift:23` |
| Capture | `SurfaceOwnershipRegistry.globalComposer` has no canonical tab and route policy `Overlay/global composer only`; active Capture routes use shell overlay/seam state. | implemented-source-present / no root route | `Native/Ambitions/Stage/SurfaceOwnershipRegistry.swift:33`, `Native/Ambitions/Stage/AmbitionsStage.swift:161` |
| Search | `ShellOverlayState.memoryLens` and `AmbitionsStage.shellSearchSeam` render Search as overlay state with local result routing. | implemented-source-present / overlay | `Native/Ambitions/Stage/Overlays/ShellOverlayState.swift:75`, `Native/Ambitions/Stage/AmbitionsStage.swift:125` |
| Trust inspection | Trust kinds exist for Proof, Source, Privacy, History, Receipts. Inspection remains contextual under You/history/source/privacy routes. | partial-source-present | `Native/Ambitions/Trust/TrustDisclosureLevel.swift:3`, `Native/Ambitions/Trust/InspectionSurface.swift:4`, `Native/Ambitions/App/AmbitionsRootStageSurfaceHost.swift:126` |
| External routes | Deep links, notifications, widgets, app intents, Spotlight, handoff, and relaunch route into the same StageStore graph. | partial-source-present | `Native/Ambitions/App/AppDeepLinkRegistry.swift:57`, `Native/Ambitions/App/AppExternalRouting.swift:37` |
| Screenshot evidence | Prior screenshot and VSP/Figma packages exist, but this pass did not create current rendered screenshots. | docs-only for this pass | `docs/qa/evidence/2026-06-22-device-review/screenshot-index.md`, `docs/audits/amb-1749-frontend-evidence-harness.md` |

## Current Classification Terms

| Classification | Meaning in this packet |
| --- | --- |
| implemented-source-present | Active production source route/screen exists in an active target and is reachable from the current route graph. This is not Visual Green. |
| partial-source-present | Active production source exists, but route coverage is contextual, proof-limited, or not enough for a complete frontend journey claim. |
| prototype | Design/VSP/Figma artifact or exploratory package, not current SwiftUI runtime proof. |
| docs-only | Documentation or evidence record without active runtime source in this pass. |
| dead route | Active route source points to a destination that cannot open or violates current IA. No dead canonical root route was found in this pass. |
| preview-only | Preview support, development asset, or `#Preview` surface that is not a production route. |
| test-only | Unit/UI test code or fixtures only. Existing tests were inspected but not executed in this pass. |
| fake fixture | Demo/fixture state that can support previews or tests but must not be claimed as live runtime data. |
| unknown | Current source evidence was not sufficient to classify. |

## Proof Ceiling

Allowed claim from AMB-1751:

- Current `main` has a source-grounded frontend route, screen, journey, missing
  screen, and deletion/quarantine registry for the inspected app graph.

Forbidden claims from AMB-1751:

- Visual Green
- accessibility conformance
- current rendered screenshot coverage
- current physical-device behavior
- TestFlight readiness
- App Store readiness
- Release Green
- completion of frontend recovery parents
