# Batch 17 — Canon Batch 14 / Runtime Separation

## Status

Completed

## Goal

Separate Ambitions intelligence from the iPhone shell so the current native app becomes one client of a broader Ambitions runtime, without breaking the current product, inventing a second persistence stack, or starting dedicated device work.

## In Scope

- audit and preserve the current app container, repositories, orchestration services, external action infrastructure, sync/trust boundary, ambient surfaces, and service wiring seams
- define a thin runtime boundary for:
  - runtime boundary contracts
  - memory/service orchestration boundaries
  - context service boundaries
  - client/surface abstraction seams
  - app-shell versus runtime ownership separation
- add or refine runtime-facing protocols/services only where immediately useful and compatibility-safe
- compose existing reusable intelligence/services through `AmbitionsRuntimeFactory` instead of duplicating them
- keep `AppContainer` as the compatibility facade for the current iPhone app
- keep the iPhone app as the canonical client of the runtime-oriented architecture
- add focused tests for runtime boundary contracts, app-shell composition safety, command routing ownership, and current product compatibility

## Out Of Scope

- dedicated device UI, hardware behavior, or engineering prototype work
- new voice runtime product surfaces
- desktop or tablet client rollout
- cloud backend expansion
- auth/account systems
- broad UI redesign
- a second persistence stack, persisted runtime snapshots, new repository families, or new storage models
- breaking the current app into microservices
- speculative infrastructure not clearly consumed by the repo today
- broad renames or replacement of existing screen-facing service protocols

## Dependency Rules

- do not skip ahead
- build on the existing app container, repository protocols, sync/trust boundary, external action infrastructure, external snapshots, and shared services
- keep the current app working as the canonical client
- prefer additive compatibility-safe boundary extraction over disruptive rewrites
- keep domain/business logic in reusable runtime-oriented services, not app-shell navigation code
- keep app navigation app-shell owned; runtime may request routes, but `AppExternalRouting` remains responsible for `AppExternalRoute` behavior
- do not start dedicated device prototype work in this batch

## Extra Constraints

- keep the runtime boundary thin and compatibility-first
- `AmbitionsRuntimeFactory` must compose and expose existing reusable intelligence/services, not duplicate them or create parallel versions
- `RuntimeMemoryServicing` and `RuntimeContextServicing` must be derived from existing repositories, sync/trust contracts, and external snapshot seams
- do not add persisted runtime snapshots, new repository families, or a second context snapshot family
- `RuntimeActionCommandExecuting` owns reusable command semantics only; app navigation remains app-shell owned
- reuse existing sync capability and external snapshot truth; do not invent a second trust model or command vocabulary
- keep `AmbitionsRuntimeClientContext` minimal and default to `.iphoneApp`
- do not add speculative client behavior for tablet, desktop, voice, or device surfaces
- `ProfileFeatureService` may consume runtime capability/status through injection, but must not become a runtime-control panel
- `PreviewAppContainer` should use the smallest compatibility-safe preview runtime/stub needed to keep previews compiling
- run full scheme validation unconditionally
- mark Batch 17 completed only if generation, build, targeted tests, full `AmbitionsTests`, and full scheme validation all pass

## Current Repo Notes

- `AppRepositories` and repository protocols already provide the durable memory boundary for goals, drafts, captures, evidence, feedback, and app state.
- `LocalOnlySyncCapability` already represents the current sync/trust truth and should remain the source for local-only status.
- `ExternalSurfaceSnapshot`, `ExternalSurfaceNowState`, `ExternalSurfaceSnapshotBuilder`, and `ExternalSurfaceSnapshotWriter` already define the ambient context snapshot seam.
- `DefaultExternalActionCommandService` already centralizes external command execution but currently adapts directly into app routing; this batch should split reusable command semantics from app-shell route dispatch.
- `AppContainerFactory` currently composes both reusable intelligence/services and iPhone app-shell routing; this batch should move reusable runtime composition into `AmbitionsRuntimeFactory`.
- `TodayServicing`, `GoalsServicing`, and `CaptureServicing` remain the current screen-facing service contracts and should not be renamed or broadly replaced.

## Exit Criteria

- a thin runtime boundary exposes client context, capabilities, derived memory, derived context, and reusable action command semantics
- runtime memory/context remain read-time derived from existing repositories, sync/trust contracts, and external snapshot seams
- `AmbitionsRuntimeFactory` composes existing reusable services once without duplicating feature services, persistence, or command vocabularies
- `AppContainer` continues to serve existing iPhone screens through the current service properties while exposing the runtime boundary
- external actions preserve existing app routing behavior through an app-shell adapter from runtime route requests to `AppExternalRoute`
- Profile reports sync/trust status through injection without becoming a runtime settings surface
- previews compile through a minimal compatibility runtime/stub
- generation, build, targeted tests, full `AmbitionsTests`, and full scheme validation all pass before status changes to completed

## Validation

- `xcodegen generate`
- `xcodebuild -project Ambitions.xcodeproj -scheme Ambitions -sdk iphonesimulator -destination "generic/platform=iOS Simulator" CODE_SIGNING_ALLOWED=NO build`
- `xcodebuild -project Ambitions.xcodeproj -scheme Ambitions -destination "platform=iOS Simulator,name=iPhone 17" -only-testing:AmbitionsTests/AmbitionsRuntimeBoundaryTests -only-testing:AmbitionsTests/AppContainerFactoryTests -only-testing:AmbitionsTests/ExternalActionCommandServiceTests -only-testing:AmbitionsTests/ProfileFeatureServiceTests -only-testing:AmbitionsTests/ExternalSurfaceSnapshotTests -only-testing:AmbitionsTests/SyncCapabilityTests test`
- `xcodebuild -project Ambitions.xcodeproj -scheme Ambitions -destination "platform=iOS Simulator,name=iPhone 17" -only-testing:AmbitionsTests test`
- `xcodebuild -project Ambitions.xcodeproj -scheme Ambitions -destination "platform=iOS Simulator,name=iPhone 17" test`

## Completion Notes

- Added a thin `AmbitionsRuntime` boundary with minimal `.iphoneApp` client context, current local runtime capabilities, derived memory/context services, runtime route requests, and reusable external action command execution.
- Added `AmbitionsRuntimeFactory` to compose existing reusable services, repositories, local-only sync capability, and external snapshot seams without adding persistence, storage models, or parallel service families.
- Kept `AppContainer` as the current iPhone compatibility facade while exposing the runtime boundary; `AppContainerFactory` now delegates reusable runtime/service composition and keeps session, bootstrap, notification, calendar, and app-shell routing ownership in the app layer.
- Preserved app-shell navigation ownership by adapting runtime route requests into existing `AppExternalRoute` dispatch inside `DefaultExternalActionCommandService`.
- Injected sync capability status into `ProfileFeatureService` without expanding Profile into runtime settings, and added a minimal preview runtime through `PreviewAppContainer`.
- Added focused runtime boundary, app container, external command, and profile tests. Validation passed on April 19, 2026:
  - `xcodegen generate`
  - `xcodebuild -project Ambitions.xcodeproj -scheme Ambitions -sdk iphonesimulator -destination "generic/platform=iOS Simulator" CODE_SIGNING_ALLOWED=NO build`
  - `xcodebuild -project Ambitions.xcodeproj -scheme Ambitions -destination "platform=iOS Simulator,name=iPhone 17" -only-testing:AmbitionsTests/AmbitionsRuntimeBoundaryTests -only-testing:AmbitionsTests/AppContainerFactoryTests -only-testing:AmbitionsTests/ExternalActionCommandServiceTests -only-testing:AmbitionsTests/ProfileFeatureServiceTests -only-testing:AmbitionsTests/ExternalSurfaceSnapshotTests -only-testing:AmbitionsTests/SyncCapabilityTests test`
  - `xcodebuild -project Ambitions.xcodeproj -scheme Ambitions -destination "platform=iOS Simulator,name=iPhone 17" -only-testing:AmbitionsTests test`
  - `xcodebuild -project Ambitions.xcodeproj -scheme Ambitions -destination "platform=iOS Simulator,name=iPhone 17" test`
