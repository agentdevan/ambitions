# Platform Kernel Module Boundary Scaffold

<!-- AMB-291-CANON-HYGIENE-REPAIR: BEGIN -->

> AMB-291 repair status: **canon-hygiene-reconciled**
> This file was reviewed as part of the actual canon content/hygiene rewrite pass.
> It is not standalone active product truth. Use `docs/truth/*` and current manifest/sequence authority before implementation.
> Conflict types reconciled: stale_or_unknown_active_status
> Prior recommended actions: Expedite
> Candidate references: AMB28-stale_or_unknown_active_status-43845058

<!-- AMB-291-CANON-HYGIENE-REPAIR: END -->

<!-- AMB-291-CANON-HYGIENE-HEADER: BEGIN -->

> Canon hygiene status: **codex-reference**
> AMB-291 note: This Codex reference supports process or execution, but active truth remains in docs/truth and current manifests.
> Active authority: `docs/truth/*`, `docs/codex/GLOBAL_BATCH_SEQUENCE_AUTHORITY.json`, and `docs/codex/IOS26_FLAGSHIP_TRAIN_MANIFEST.yml`.
> Before using this file for implementation, run `make change-impact-check` and follow `docs/ops/change-protocol/implementation-prompt-template.md`.
> Resolution classes: authority-rewrite, rewrite-authority-before-proof
> Dispositions: rewrite-authority-before-proof, rewrite-authority-reference

<!-- AMB-291-CANON-HYGIENE-HEADER: END -->

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

## Source-of-truth references

<!-- AMB-291-SOURCE-OF-TRUTH-REFERENCES: BEGIN -->

This file must not be treated as standalone active canon. Current authority must be resolved through:

- `docs/truth/README.md`
- `docs/truth/PRODUCT_DESIGN_TRUTH.md`
- `docs/truth/PRODUCT_MOAT_TRUTH.md`
- `docs/truth/IMPLEMENTATION_TRUTH.md`
- `docs/truth/RELEASE_TRUTH.md`
- `docs/truth/CODEX_PROCESS_TRUTH.md`
- `docs/truth/HISTORICAL_POLICY.md`
- `docs/codex/GLOBAL_BATCH_SEQUENCE_AUTHORITY.json`
- `docs/codex/IOS26_FLAGSHIP_TRAIN_MANIFEST.yml`
- `docs/ops/change-protocol/change-request-template.md`
- `docs/ops/change-protocol/change-impact-check.md`
- `docs/ops/change-protocol/implementation-prompt-template.md`
- `docs/ops/change-protocol/post-implementation-proof-reconciliation.md`

<!-- AMB-291-SOURCE-OF-TRUTH-REFERENCES: END -->

## Non-claims

<!-- AMB-291-NON-CLAIMS: BEGIN -->

- This file does not prove implementation.
- This file does not prove build success.
- This file does not prove test success.
- This file does not prove accessibility validation.
- This file does not prove performance validation.
- This file does not prove device validation.
- This file does not prove privacy/legal approval.
- This file does not prove TestFlight readiness.
- This file does not prove App Store readiness.
- This file does not prove release readiness.
- Linear status is not repo truth.

<!-- AMB-291-NON-CLAIMS: END -->
