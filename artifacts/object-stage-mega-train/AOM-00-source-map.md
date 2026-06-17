# AOM-00 Source Map

## Objective
Create a stable source and migration-boundary map for AMB-AOM-00 before any runtime edits. Scope is audit-only and confined to mapping IA, migration seams, trust inspection, tests, validators, and SwiftData touchpoints.

## Root IA and canonical shell
- Canonical top-level tabs live in `Native/Ambitions/App/AppTab.swift` as `today`, `goals`, `time`, `motion`, and `you`.
- `Native/Ambitions/App/AmbitionsRootView.swift` renders `TabView` over those five tabs and hosts the global capture action path.
- `Native/Ambitions/App/AppNavigation.swift` and `Native/Ambitions/App/AmbitionsShell.swift` own top-level route orchestration for shell/gesture flow and tab context.
- `Native/Ambitions/App/ShellCommandModels.swift` and `Native/Ambitions/App/ShellCommandRouter.swift` define command-based launching and capture-first behavior.
- `Native/Ambitions/App/AppExternalRouting.swift` maps inbound intents/deep links; capture and motion surfaces are entered via composed shell routing, not as extra tabs.

## Capture as global composer (no root tab)
- Primary global composer UI: `Native/Ambitions/Features/Capture/CaptureScreen.swift`.
- Access seam: command/context actions in `ShellCommandModels.swift` plus quick-capture route handling in `ShellCommandRouter.swift`.
- Compatibility routes that reference capture (`captures`, `capture`, `motionCapture`, etc.) are defined as compatibility seams in route marker/handler files and are not surfaced as new top-level tabs.
- `Native/Ambitions/App/AppNavigation.swift` confirms capture opens from shell overlays/actions with non-tab destination semantics.

## Motion behavior layer (not a top-level destination)
- Motion is represented as top-level tab `motion` with behavior-oriented stage entry and stage control surfaces (e.g., `Native/Ambitions/Features/Motion/MotionCurrentScreen.swift`).
- Motion behavior/state is integrated through command surfaces and object-stage transitions rather than a generic analytics/dashboard route.

## Trust / inspection / proof layer
- Trust and inspectability logic is anchored under `You` and proof repositories rather than a separate fifth shell:
  - `Native/Ambitions/Features/You/YouRootSurface.swift`
  - `Native/Ambitions/Features/You/YouCrossSurfaceProofReviewCard.swift`
  - `Native/Ambitions/Features/You/YouTrustHistoryCenterCard.swift`
  - `Native/Ambitions/Features/You/YouViewModel.swift`
- Cross-surface proof contracts are represented in the domain and persistence layers (receipts, action history, proofs, history records) and surfaced through `You` runtime bindings.

## Surface UI map (read/write boundary)
- Today: `Native/Ambitions/Features/Today/TodayScreen.swift`, `TodayRealityMeridian` flow files.
- Goals: `Native/Ambitions/Features/Goals/GoalsScreen.swift` and goal object-stage family files.
- Time: `Native/Ambitions/Features/Time/TimeScreen.swift` and LifeShape field surface files.
- Motion: `Native/Ambitions/Features/Motion/MotionCurrentScreen.swift`.
- You: `Native/Ambitions/Features/You/YouRootSurface.swift` and `You*Trust*` surface files.
- Runtime + shell contracts: `Native/Ambitions/Domain/ScreenContractModels.swift`, `Native/Ambitions/Domain/ScreenContractSnapshot.swift`, feature-level snapshots under `Native/Ambitions/Features/*/.../FeatureContractSnapshot.swift`.

## Legacy/migration boundary
- `AppTab.swift` includes `LegacyIARouteCompatibility` mappings for historical destinations (`plan`, `captures`, `pulse`, `habits`, `profile`, `review`, etc.).
- This is an explicit migration boundary: old routes are preserved for compatibility, while canonical IA remains Today/Goals/Time/Motion/You.
- The app root contract and canonical IA validator references should remain the source of truth for migration audits.

## SwiftData touchpoints
- Data model container is assembled in `Native/Ambitions/Persistence/SwiftDataStore.swift`.
- Data schema is defined in `Native/Ambitions/Persistence/SwiftDataModels.swift` with core entities used by Today/Goals/Time/Motion/You/Capture and proof history.
- Runtime injection/repository wiring is in `Native/Ambitions/App/AppContainerFactory.swift`; captures/receipts/proof repositories are wired from app bootstrap through factories and services.

## Test and validator touchpoints before edits
- Existing test families already cover top-level composition, contract guards, shell integration, and trust history.
- Representative files to validate against before edits:
  - `Native/AmbitionsTests/App/TopLevelSurfaceCompositionTests.swift`
  - `Native/AmbitionsTests/App/ScreenContractRegistryTests.swift`
  - `Native/AmbitionsTests/App/ExternalSurfaceControlContractsTests.swift`
  - `Native/AmbitionsTests/App/CaptureRoutingPrimitiveFamilyTests.swift`
  - `Native/AmbitionsTests/App/ActivationContractTests.swift`
  - `Native/AmbitionsTests/Today/TodayShellIntegrationTests.swift`
  - `Native/AmbitionsTests/Goals/GoalsShellIntegrationTests.swift`
  - `Native/AmbitionsTests/Motion/MotionCurrentScreenTests.swift`
  - `Native/AmbitionsTests/Persistence/TrustHistoryQueryRepositoryTests.swift`
  - `Native/AmbitionsTests/Domain/CaptureRouteCommandMappingTests.swift`
- Canonical guard scripts already implicated by train contract:
  - `scripts/ambitions_validate_authority_drift.py`
  - `scripts/codex/amb-master-canon-ia-validate.py`
  - `scripts/ambitions-local-first-boundary-scan.py`
  - plus existing project contract/validation tooling listed in `docs/truth/IMPLEMENTATION_TRUTH.md`.

## Risk-bearing migration seam summary
- Primary boundary to defend: preserving canonical IA while allowing legacy route compatibility.
- Secondary boundary: keeping `Capture` and `Motion` command-first/global behavior semantics intact when reviewing any source changes.
- Data boundary: ensuring SwiftData repository changes do not leak or alter user-private runtime scope outside local-first guarantees.
