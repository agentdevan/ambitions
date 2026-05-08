# Platform Kernel Module Boundary Scaffold

<!-- markdownlint-disable MD013 -->

Status: Active PK01 scaffold, docs-only.
Date: 2026-05-08
Owner batch: PK01 Package/Module Boundary Scaffold

## Current Build Shape

Current source truth:

- `Package.swift` defines one local Swift package named `AmbitionsDesignSystem`.
- Package products are `AmbitionsDesignSystem` from `Sources` and
  `AmbitionsWidgetUI` from `AppUI/Sources`.
- `project.yml` owns Xcode target wiring.
- `Ambitions` app target compiles `Native/Ambitions/**`.
- `AmbitionsWidgetExtension` compiles `Native/AmbitionsWidgetExtension/**` and
  selected `Native/Ambitions/ExternalSnapshots/**` files.
- `AmbitionsShareExtension` compiles `Native/AmbitionsShareExtension/**` and
  selected `Native/Ambitions/ExternalSnapshots/**` files.
- `AmbitionsTests` depends on the app target and the design-system package.
- No Platform Kernel package split has been performed by PK01.

## Future Boundary Names

PK01 names future module/package boundaries without moving code:

| Boundary | Future owner batches | Current source roots | Allowed dependencies |
| --- | --- | --- | --- |
| AmbitionsDomain | PK38 | `Native/Ambitions/Domain/**` | Foundation only, plus pure value-model helpers. No SwiftUI, SwiftData, AppIntents, EventKit, WidgetKit, or app target dependency. |
| AmbitionsPersistence | PK39 | `Native/Ambitions/Persistence/**` | Domain contracts and storage frameworks only. No feature UI. |
| AmbitionsRuntime | PK40 | `Native/Ambitions/Runtime/**`, `Native/Ambitions/Services/**` after extraction | Domain, Persistence, side-effect protocols, diagnostics, and receipt/event contracts. No direct feature UI. |
| AmbitionsFeatureEngines | PK41 | Feature-owned non-UI engines after service decomposition | Domain and Runtime protocols. No persistence writes except through UnitOfWork/repository contracts. |
| AmbitionsExternalSurfaces | Later PK25/PK40/PK41 follow-up if needed | `Native/Ambitions/ExternalSnapshots/**`, widget/share shared contracts | Domain, snapshot DTOs, SideEffectLedger once proven. No app-only UI or persistence mutation. |
| AmbitionsAppShell | App target only | `Native/Ambitions/App/**`, `Native/Ambitions/Features/**`, `Native/Ambitions/UI/**`, app resources | May depend on package products and runtime interfaces; owns SwiftUI composition and navigation. |

## Dependency Direction

Future extraction must keep dependencies one-way:

```text
DesignSystem -> no Ambitions app/domain dependency
Domain -> Foundation-only domain helpers
Persistence -> Domain
Runtime -> Domain + Persistence + side-effect/diagnostic contracts
FeatureEngines -> Domain + Runtime protocols
ExternalSurfaces -> Domain + snapshot contracts + side-effect ledger after PK25
AppShell/UI -> all public package/runtime interfaces
```

## Forbidden Until Later PK Proof

- No package/project split before PK02 scanner and a focused build/test proof.
- No persistence package move before PK07-PK13 storage, migration, backup, and
  rollback proof.
- No runtime package move before PK03-PK06 UnitOfWork and atomic flow proof.
- No side-effect surface split before PK22-PK25 SideEffectLedger proof.
- No sync/cloud package claim before PK29-PK31.
- No intelligence package claim before PK32-PK34.
- No feature-engine package move before PK17-PK21 service decomposition and
  PK38-PK41 package move owners.

## PK02 Scanner Requirements

PK02 should turn this scaffold into a repeatable scanner that detects:

- Domain importing SwiftUI, SwiftData, WidgetKit, AppIntents, EventKit, or app
  feature modules.
- Persistence importing feature UI.
- Runtime/service code importing SwiftUI feature surfaces directly.
- Feature engines writing persistence outside UnitOfWork/repository contracts.
- External snapshot paths mutating app state or bypassing SideEffectLedger once
  that ledger exists.
- New package products without owner batch, dependency map, and focused build
  evidence.

## Claim Boundary

PK01 is a boundary scaffold only. It does not claim package split completion,
module extraction, build-system refactor safety, architecture scanner coverage,
backend completion, migration safety, sync readiness, side-effect isolation,
privacy compliance, CI green, release readiness, physical-device proof, or
performance-budget proof.
