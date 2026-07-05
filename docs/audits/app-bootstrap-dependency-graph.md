# App Bootstrap Dependency Graph

Status: Current AMB-1675 source artifact  
Scope: App-owned dependency assembly only  
Proof ceiling: Source/architecture evidence; not release, device, visual, accessibility, privacy/legal, TestFlight, App Store, account, R2 production, or full LocalRuntimeOS completion proof.

## Authority

This artifact records the source ownership split for `Parent Feature - AppContainer De-Godding`.

Product law preserved:

```text
Intent -> Context -> Path -> Time Fit -> Reflow -> Action -> Proof -> Learning
Command -> Event -> Projection -> Receipt -> Replay
Today / Goals / Time / You; Capture global composer; Motion behavior; Trust inspection
```

## Dependency Graph

```text
AppContainerFactory
  -> PersistenceBootstrap
       -> AmbitionsPersistenceStore
       -> SwiftData repositories
       -> RuntimeEventStore
       -> ProjectionStoreSQLite
       -> SearchStoreFTS
       -> CommandJournal
       -> seed policy

  -> SystemSurfaceBootstrap.makePlatformServices
       -> SideEffectOutbox
       -> NotificationOutbox
       -> EventKitOutbox
       -> LocalNotificationFoundation
       -> EventKitIntegrationService

  -> RuntimeBootstrap
       -> AmbitionsClockFactory
       -> AmbitionsRuntimeFactory
       -> preview Today override
       -> debug protected-placement Time override

  -> SystemSurfaceBootstrap.makeServices
       -> TodayReceiptCommandService
       -> YouPreferencesCommandService
       -> DefaultExternalActionCommandService
       -> AmbitionsCommandExecutor
       -> DefaultExternalCreationImportService
       -> SourceAtlasPublicPackLifecycleRefreshService
       -> DefaultShellCommandRouter
       -> DefaultMemoryLensService
       -> RepositoryBackedOnboardingService

  -> AppContainer
       -> AppShellCapability
       -> AppRuntimeCapability
       -> AppPersistenceCapability
       -> AppPlatformCapability
       -> AppUserSystemCapability
       -> AppFeatureFactoryCapability
```

## Owner Boundaries

| Owner | File | Responsibility |
|---|---|---|
| Persistence bootstrap | `Native/Ambitions/App/Bootstrap/PersistenceBootstrap.swift` | Constructs the app persistence store, SwiftData repositories, runtime event/projection/search stores, command journal, and seed policy. |
| Runtime bootstrap | `Native/Ambitions/App/Bootstrap/RuntimeBootstrap.swift` | Selects the app clock, builds `AmbitionsRuntime`, and applies preview/debug runtime service overrides. |
| System-surface bootstrap | `Native/Ambitions/App/Bootstrap/SystemSurfaceBootstrap.swift` | Wires notification/EventKit outboxes, external adapters, shell command routing, Source Atlas lifecycle refresh, memory lens, onboarding, and launch side effects. |
| Factory orchestration | `Native/Ambitions/App/AppContainerFactory.swift` | Calls the bootstrap owners, creates navigation/external router, and assembles `AppContainer`. |

## Non-Claims

This artifact does not prove:

- build success
- simulator launch
- physical-device behavior
- UI quality
- accessibility conformance
- release readiness
- privacy/legal approval
- app-wide command-only mutation
- full LocalRuntimeOS completion

## Validation Hooks

Current focused source checks:

- `Native/AmbitionsTests/App/AppContainerFactoryTests.swift`
- `scripts/ambitions-local-runtime-proof.py`
- `scripts/ambitions-remediation-governance-check.py`
