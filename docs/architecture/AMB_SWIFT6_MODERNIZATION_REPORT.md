# Ambitions Swift 6 Modernization Report
<!-- markdownlint-disable MD013 -->

Status: Active architecture standard  
Date: 2026-05-13  
Owner: Ambitions Native Architecture / Codex OS  
Scope: Native iPhone app, widget extension, share extension, Swift packages, architecture gates

## Executive decision

Ambitions is standardized on Swift 6 language mode with complete strict concurrency checking as the target build posture.

The native architecture standard is:

> Swift 6 + SwiftUI + Observation + structured concurrency + strict concurrency + actor-isolated local-first SwiftData + Swift Testing for new deterministic tests + App Intents / WidgetKit / ActivityKit external surfaces + protocol-based feature services + deterministic command routing + local-first Private Life Runtime / Intelligence Kernel.

This standard exists to increase correctness, performance, accessibility, privacy, maintainability, and product quality. Novelty that adds ceremony without user value is forbidden.

## Current repo posture captured by this migration

- `project.yml` is migrated to `SWIFT_VERSION: 6.0` and `SWIFT_STRICT_CONCURRENCY: complete`.
- `Package.swift` is migrated to `// swift-tools-version: 6.0`.
- Existing code already shows the desired state pattern through `Observation`, `@Observable`, `@MainActor`, async service calls, service protocols, command routing, App Intents, and actor-isolated SwiftData persistence.
- This migration does not claim full app build success until Xcode validation is run and recorded.

## Why Swift 6 is required

Strict concurrency checking in Swift 6 language mode is an Ambitions-level correctness requirement because Ambitions owns local personal data, planning state, receipts, external surface actions, SwiftData persistence, and deterministic recommendation behavior. Data races in those systems can corrupt user trust and user data.

The migration objective is not to silence the compiler. The objective is to expose unsafe boundaries and repair them with explicit isolation, Sendable value models, actors, and clean feature/service/module seams.

## Approved primitives

### UI and app state

Use:

- SwiftUI
- Observation
- `@Observable`
- `@Bindable`
- `@State`
- `@Environment`
- `@MainActor` for UI-facing state and presentation models

Do not introduce new `ObservableObject`, `@Published`, `AnyCancellable`, or broad `import Combine` for app state.

### Concurrency

Use:

- async/await
- structured `Task` usage with cancellation awareness
- actors for shared mutable state
- immutable `Sendable` domain values
- explicit `@MainActor` only at UI boundaries

Avoid:

- unstructured concurrency as a default
- broad `Task.detached`
- broad `@unchecked Sendable`
- global mutable state
- accidental MainActor isolation inside deterministic domain/kernel/persistence engines

### Persistence

Use:

- SwiftData for local-first persistence
- actor-isolated persistence store boundaries
- explicit read/write/transaction APIs
- migration plans
- pre-migration backups
- tombstones where delete/revision history matters
- receipts for unit-of-work and side-effect proof

Do not leak raw persistence implementation details into top-level SwiftUI surfaces unless an active architecture doc explicitly allows it.

### External surfaces

Use:

- App Intents
- App Shortcuts
- WidgetKit widgets
- WidgetKit controls where available
- ActivityKit Live Activities only where product-justified
- share extension contracts
- local command routing and receipt behavior

External surfaces must route through the same deterministic local command contracts as the main app. They must not duplicate business logic or create a second app architecture.

## Rejected architecture

### VIPER

VIPER is forbidden for Ambitions SwiftUI surfaces. Do not add Presenter, Interactor, Wireframe, or VIPER-style structure unless it is historical documentation or explicitly allowlisted for external reference. Ambitions needs strong boundaries, but those boundaries are feature modules, service protocols, command routers, actors, and domain models.

### Combine-first MVVM

Combine is not the Ambitions state architecture. Combine is allowed only as an edge adapter for APIs that still expose publishers and only with an explicit allow marker and proof that async/await or Observation cannot own the boundary cleanly.

### Hummingbird inside the iPhone app

Hummingbird is a server-side Swift framework. It is not allowed inside native app, widget, share extension, or design-system targets. A future server/tooling package may evaluate Hummingbird separately, but it must not become app runtime infrastructure.

### External/cloud LLM core dependency

External/cloud LLMs are not core Ambitions architecture. Core intelligence remains local-first and deterministic through the Private Life Runtime / Intelligence Kernel. Any future cloud/external LLM capability must be optional, user-controlled, and outside required product behavior.

## Module boundary target

Long-term target modules:

```text
AmbitionsApp
  App lifecycle, shell, navigation, composition root, permissions.

AmbitionsDesignSystem
  Typography, spacing, materials, motion tokens, visual primitives.

AmbitionsDomain
  Pure local-first value models and deterministic rules.

AmbitionsKernel
  Private Life Runtime / Intelligence Kernel orchestration.

AmbitionsPersistence
  SwiftData models, migrations, backups, receipts, tombstones, unit of work.

AmbitionsFeatures
  Today, Goals, Capture, Time, You feature surfaces and state adapters.

AmbitionsExternalSurfaces
  App Intents, widgets, controls, share extension, Live Activity contracts.

AmbitionsTestingSupport
  Fixtures, clocks, fake stores, proof builders, preview/demo state.
```

Boundary rules:

- Domain must not import SwiftUI.
- Domain must not import SwiftData unless explicitly inside persistence records/mapping scope.
- Features should not own raw SwiftData contexts.
- UI should not own kernel scheduling or scoring logic.
- External surfaces should route commands, not duplicate feature logic.
- Persistence should expose explicit transactional APIs and receipts.

## Testing standard

Existing XCTest coverage may remain. New deterministic logic should prefer Swift Testing where the local toolchain supports it.

Use Swift Testing for:

- domain rules
- scheduling/capacity math
- closure/recovery decisions
- trust history
- receipt ledgers
- command routers
- App Intent command contracts
- migration/scanner scripts where Python is not the right level

Keep XCTest for:

- UI tests
- legacy tests that are already stable
- Xcode-specific integration tests
- areas where conversion does not increase proof quality

## Guardrail scanner

This migration adds:

```text
scripts/ambitions-swift6-modernization-scan.py
```

The scanner verifies Swift 6 settings and detects architecture regressions:

- `import Combine`
- `ObservableObject`
- `@Published`
- `AnyCancellable`
- `@unchecked Sendable`
- VIPER naming
- Hummingbird native-app dependency leakage

Use:

```bash
python3 scripts/ambitions-swift6-modernization-scan.py . --strict
python3 scripts/ambitions-swift6-modernization-scan.py --self-test
python3 tools/tests/test_ambitions_swift6_modernization_scan.py
```

Allowlist marker:

```swift
// AMB_SWIFT6_ALLOW: explain exact adapter/invariant and proof path
```

Allow markers are intentionally noisy. They keep exceptions reviewable rather than hiding architecture drift.

## Validation requirements before Green

Swift 6 migration is not Green until all required local validation passes and is documented:

```bash
xcodegen generate
xcodebuild build -project Ambitions.xcodeproj -scheme Ambitions -destination 'platform=iOS Simulator,name=iPhone 17'
xcodebuild test -project Ambitions.xcodeproj -scheme Ambitions -destination 'platform=iOS Simulator,name=iPhone 17'
python3 scripts/ambitions-swift6-modernization-scan.py . --strict
python3 scripts/ambitions-swift6-modernization-scan.py --self-test
python3 tools/tests/test_ambitions_swift6_modernization_scan.py
```

If simulator naming differs locally, use the closest available current iPhone simulator and record the exact destination.

## Proof honesty

This document does not claim:

- full app build success
- full test success
- device proof
- TestFlight readiness
- App Store readiness
- accessibility proof
- privacy/legal proof
- performance proof
- complete Swift 6 repair success

Those claims require command output and/or device evidence.

## Next modernization batches

1. Repair any Swift 6 strict-concurrency compiler failures.
2. Add module-boundary gates for Domain/UI/Persistence imports.
3. Add Swift Testing for new deterministic domain/kernel tests.
4. Harden App Intent / WidgetKit control command receipt coverage.
5. Add migration dry-runs and backup validation for SwiftData schema changes.
6. Consider UI-target default MainActor isolation only after build tooling support is verified.
