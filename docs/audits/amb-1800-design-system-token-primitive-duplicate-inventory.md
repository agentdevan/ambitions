# AMB-1800 Design System Token And Primitive Duplicate Inventory

Date: 2026-07-05

Scope: inventory duplicated app-local/package design-system token and primitive
authority, then remove one low-risk duplicate set.

## Current Inventory

| Area | Package owner | App-local owner | Status |
| --- | --- | --- | --- |
| Theme colors, material, depth, typography, spacing, motion, haptics | `Sources/Theme/AmbitionTheme*.swift`, generated token files, and semantic token catalog files | `Native/Ambitions/DesignSystem/Foundations/AmbitionsColor.swift`, `AmbitionsTypography.swift`, `AmbitionsSpacing.swift`, `AmbitionsMaterial.swift`, `AmbitionsDepth.swift`, `AmbitionsMotion.swift`, `AmbitionsHaptics.swift` | Duplicated wrapper authority remains but is still used by product-object source. Keep as Yellow until each wrapper is collapsed into the package theme or removed with focused source proof. |
| Lighting | `Sources/Theme/SemanticDesignTokenCatalog.swift` and `Sources/Theme/SemanticDesignTokenCatalog+02-AmbitionFlagshipSemanticFoundationContract.swift` define canonical lighting roles such as `graphiteFocus` and `proofGlow`. | `Native/Ambitions/DesignSystem/Foundations/AmbitionsLighting.swift` | Removed in AMB-1800. The wrapper was only used by `TodayStartHereSurface`; the surface now consumes theme color/material directly and package semantic lighting remains the canonical inventory. |
| Surface/card primitives | `Sources/Components/SurfacePrimitives.swift` owns package primitives such as `AppCard`, `WidgetCard`, and `HeroCard`. | App-local product objects under `Native/Ambitions/DesignSystem/ProductObjects/**` | Product objects are domain-specific and remain app-local; no low-risk duplicate deletion selected in this slice. |
| Accessibility primitives | `Sources/Accessibility/**` owns package-level accessibility audit contracts. | `Native/Ambitions/DesignSystem/Accessibility/**` owns app-local policy structs used by product objects. | Duplicated policy surface remains Yellow; no deletion selected in this slice. |
| Widget primitives | `AppUI/Sources/**` owns `AmbitionsWidgetUI`. | `Native/AmbitionsWidgetExtension/**` and selected `Projection/ExternalSnapshots` files are extension target source. | No duplicate deletion selected in this slice. |

## Removed Duplicate Set

Deleted:

- `Native/Ambitions/DesignSystem/Foundations/AmbitionsLighting.swift`

Updated:

- `Native/Ambitions/DesignSystem/ProductObjects/TodayStartHereSurface.swift`
- `Native/AmbitionsTests/DesignSystemFoundationsCanonicalOwnershipTests.swift`
- `docs/truth/PRODUCT_DESIGN_TRUTH.md`

Reason:

- `AmbitionsLighting` was a thin app-local wrapper over package theme/semantic
  lighting values.
- It had one production consumer, `TodayStartHereSurface`.
- Its unused `proofGlow` value duplicated package semantic lighting role
  inventory without source consumption.
- Removing it deletes one wrapper authority without changing package boundaries
  or product-object ownership.
- The Final Architecture Tree required-file list was updated so
  `AmbitionsLighting.swift` is no longer a canonical required owner.

## Non-Claims

- No full design-system consolidation.
- No Visual Green.
- No accessibility conformance claim.
- No package split, package extraction, or package dependency change.
- No XCTest/build/simulator/device/release proof.

## Follow-Up

- Collapse or move the remaining app-local foundation wrappers only with focused
  source proof, because they are still consumed by product-object source.
- Keep package `Sources/Theme/**` as the canonical semantic token inventory.
