# ADR-2026-07-05: Active Package Boundary

Status: Accepted
Issue: AMB-1802
Date: 2026-07-05

## Context

Ambitions uses XcodeGen for the native app graph and a root Swift package for
shared UI package products. Current source truth is:

- `project.yml` is the Xcode target graph source of truth.
- Root `Package.swift` defines package `AmbitionsDesignSystem`.
- Root package products are `AmbitionsDesignSystem` from `Sources` and
  `AmbitionsWidgetUI` from `AppUI/Sources`.
- `AmbitionsWidgetUI` depends on `AmbitionsDesignSystem`.
- `project.yml` points `AmbitionsPackages` at `path: .` and consumes
  `AmbitionsDesignSystem` and `AmbitionsWidgetUI` from that root package.
- `Packages/` is empty at current `main`.
- `tools/mcp/ambitions_native_mcp/Package.swift` is developer tooling, not an
  app runtime/package boundary.

Older audit rows that mention `Packages/AmbitionsExperienceKernel` are stale
historical evidence unless the path exists again on current `main` and a later
ADR re-accepts it.

## Decision

The active package owners are:

| Owner | Path | Purpose | Boundary |
| --- | --- | --- | --- |
| App target graph | `project.yml` | Xcode targets, schemes, source discovery, extension embedding, package product dependencies | XcodeGen source of truth. Edit this before regenerating `Ambitions.xcodeproj`. |
| Root package manifest | `Package.swift` | Root Swift package declaration for shared UI products | No app runtime mutation, storage, receipt, replay, migration, repair, or diagnostics authority. |
| Design system package product | `Sources` | `AmbitionsDesignSystem` shared design-system primitives and tokens | UI/design-system package only. No private runtime state ownership. |
| Widget UI package product | `AppUI/Sources` | `AmbitionsWidgetUI` widget UI primitives backed by `AmbitionsDesignSystem` | Widget UI package only. No canonical app projection or mutation authority. |
| Native app source | `Native/Ambitions` | App, Stage, surfaces, design-system adoption, and LocalRuntimeOS source under the Final Architecture Tree | New runtime authority follows `Core/LocalRuntimeOS/` and the architecture tree rules. |
| Widget extension target | `Native/AmbitionsWidgetExtension` | Widget extension source selected by `project.yml` | Extension target only. Shared snapshot files are selected explicitly in XcodeGen. |
| Share extension target | `Native/AmbitionsShareExtension` | Share extension source selected by `project.yml` | Extension target only. Handoff must stay adapter-side and must not become canonical runtime authority. |
| Native MCP tooling package | `tools/mcp/ambitions_native_mcp` | Local developer tooling server | Tooling only. App/runtime source must not depend on this package. |

Package boundary changes are forbidden as cleanup theater. A future package
split, package extraction, product move, target move, or package dependency
change requires a new linked ADR that includes:

- current `Package.swift` and `project.yml` evidence,
- the exact owner being moved or created,
- why deletion/collapse is insufficient,
- dependency graph before and after,
- validation commands,
- rollback plan,
- release/proof non-claims,
- confirmation that no package boundary is being changed only to make an
  internal architecture name look cleaner.

## Consequences

- AMB-1802 does not change `Package.swift`, `project.yml`, source files, package
  products, or Xcode targets.
- The stale `Packages/AmbitionsExperienceKernel` audit rows remain historical
  context only and do not define an active owner on current `main`.
- New runtime, mutation, storage, receipt, replay, side-effect, migration,
  repair, privacy, sync, projection-materialization, or diagnostics authority
  still belongs under `Native/Ambitions/Core/LocalRuntimeOS/` unless a future
  scoped issue and ADR explicitly decide otherwise.
- Design-system package products may provide reusable UI primitives, but they do
  not own app runtime policy.
- Extension targets may adapt external surfaces, but they do not own canonical
  private runtime state.

## Non-Claims

- No package extraction was performed.
- No package split, target split, package move, or package dependency change was
  performed.
- No build, XCTest, simulator, physical-device, release, or App Store proof is
  claimed.
- No cleanup source move is authorized by this ADR.

## Rollback

Revert this ADR and its evidence packet. No project, package, or source rollback
is required because AMB-1802 is docs-only.
