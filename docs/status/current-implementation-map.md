# Current Implementation Map

Status: evidence map, not product canon.

This document separates what the repo currently contains from what is scaffolded, planned, historical, or unproven. It exists to keep the root README clean and to prevent future work from treating docs-only plans as shipped behavior.

## Source hierarchy

For product and design intent, use:

1. `docs/truth/PRODUCT_DESIGN_TRUTH.md`
2. `docs/truth/README.md`
3. `docs/README.md` for current documentation index
4. `docs/AmbitionsCanon/*` only as supporting or historical canon where compatible
5. `docs/AmbitionsCanon/README.md` only when explicitly referenced for archival/design context

For current implementation evidence, use this document plus the live source tree.

For build and validation procedure, use `docs/native-build-and-release.md`.

## Active flagship target vs current compatibility seams

Active flagship top-level IA:

```text
Today / Goals / Capture / Time / You
```

`Plan` is not an active top-level destination. It remains valid only as:

- a contextual/action noun such as Adjust plan
- historical/supporting documentation language
- an internal compatibility seam in current source code, tests, routes, or folder names

Current implementation note: the live user-facing shell now exposes `Time` / `Shape Time`, while some internal owner names still use `Plan`, including `.plan`, `PlanScreen`, `planNavigation()`, and `Native/Ambitions/Features/Plan/`. Those internal names are compatibility debt, not active product language.

## Implemented repo foundations

The repo currently contains these native foundations:

| Area | Current evidence | Status |
| --- | --- | --- |
| Native app | `Native/Ambitions/`, `project.yml` app target | Implemented foundation |
| SwiftUI shell | `Native/Ambitions/App/` | Implemented foundation |
| Five user-facing destinations | Today, Goals, Capture, Time, You through app tab/shell code | Implemented foundation |
| Time compatibility owner | `.plan`, `PlanScreen`, `planNavigation()`, `Native/Ambitions/Features/Plan/` | Internal compatibility seam |
| Persistence | SwiftData-backed repositories under `Native/Ambitions/Persistence/` | Implemented foundation where wired |
| Design system package | `Sources/` / `AmbitionsDesignSystem` | Implemented foundation |
| Widget UI package | `AppUI/Sources/` / `AmbitionsWidgetUI` | Implemented foundation |
| Unit tests | `Native/AmbitionsTests/` | Implemented test target |
| UI tests | `Native/AmbitionsUITests/` | Implemented test target |
| Local build script | `scripts/build-local.sh` | Implemented local validation helper |
| Native project generation | `project.yml` with XcodeGen | Implemented project source |

## Implemented product-surface foundations

| Surface | Current evidence | Notes |
| --- | --- | --- |
| Today | `Native/Ambitions/Features/Today/` | Runtime surface exists. Latest Signature Object maturity must still be validated against current canon. |
| Goals | `Native/Ambitions/Features/Goals/` | Runtime surface exists. Some internal names and objects may still reflect older Mission Control-era implementation language. |
| Capture | `Native/Ambitions/Features/Captures/` | User-facing destination is Capture. Internal folder/name compatibility remains. Composer-first foundation exists. |
| Time | User-facing shell through `AppTab.title`, `AmbitionsRootView`, and `PlanScreen` compatibility owner | Runtime surface exists. Internal Plan naming remains compatibility debt. Current implementation is broader than the latest LifeShape Field ideal and should be treated as foundation, not final visual maturity. |
| You | `Native/Ambitions/Features/Profile/` | User-facing destination is You. Internal Profile naming is compatibility debt, not active product language. |

## Implemented capability foundations

These capabilities appear as native foundations in code, but each still needs behavior-specific validation before production or release claims:

- capture persistence
- goal creation flow
- local notification foundation
- calendar/reminder integration foundation
- external routing / deep-link translation
- widget extension foundation
- Live Activity foundation
- share extension foundation
- local snapshot/export foundation where wired
- proof, receipt, and closure domain models where wired

## Scaffolded or validation-dependent areas

| Area | Posture |
| --- | --- |
| Widgets | Foundation exists. Production behavior and rendered surfaces require manual validation. |
| Live Activities | Foundation exists. Production behavior and device behavior require manual validation. |
| Share Extension | Target/foundation exists. End-to-end behavior requires manual validation. |
| App Intents / Shortcuts | Treat as foundation/planned unless a specific source file and local run proof is cited. |
| Calendar/reminder behavior | Foundation exists. Permission flows and runtime behavior require manual validation. |
| Notifications | Foundation exists. Scheduling, actions, and platform behavior require manual validation. |
| Accessibility | Tests and labels may exist, but public accessibility conformance is not proven. |
| Performance | No device-level performance claim is active. |
| Release readiness | Not proven. |

## Explicit non-claims

The repo does not currently prove:

- hosted CI success
- signed archive correctness
- provisioning profile correctness
- TestFlight upload readiness
- App Store Connect validation
- physical-device install/runtime behavior
- public accessibility conformance
- legal/privacy compliance signoff
- production cloud sync
- account/auth backend
- human release approval

## Historical/supporting material

The repo retains Ambitions 3.0, 4.0, PXOS, Signature Interface, Product Depth, audit, handoff, batch-train, `.codex`, and `.agents` material for traceability.

Those files are not automatically current implementation truth. They are supporting or historical context unless the active canon or this implementation map explicitly points to them.

## Update rule

When implementation changes materially, update this file in the same patch if the change affects:

- current app surface status
- validation posture
- release evidence posture
- source-truth hierarchy
- scaffolded vs implemented classification
- explicit non-claims
