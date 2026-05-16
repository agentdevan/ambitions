# UI Decision Proof Contract

Decision ID: `UID-2026-05-16-start-here-product-kernel`

## Source Installation Status

Source-installed:

- `Sources/Components/StartHereProductPrimitives.swift`
- `Native/AmbitionsTests/DesignSystem/StartHereProductKernelTests.swift`
- `Native/Ambitions/Features/Today/StartHereProductKernelProjection.swift`
- `frontend/visual-encyclopedia/decisions/active/UID-2026-05-16-start-here-product-kernel.yaml`

## Proof Added

- `StartHereProductKernel` defines required Start Here structure.
- `StartHereProductFact` defines proof facts for context edge, time fit, and goal thread.
- `StartHereProductKernelAudit` blocks generic Start Here drift and non-canonical primary action copy.
- `StartHereProductProofStack` exists as a reusable proof-stack primitive.
- `StartHereProductKernelTests` covers required proof, missing proof, banned language, and primary action copy.
- `StartHereProductKernelProjection.swift` adapts `DayRailHeroStepState` into `StartHereProductKernel` with privacy-safe projection.
- The UI decision final gate checks the Start Here lane for product primitives, tests, projection, active Today markers, and banned copy.

## Required Remaining Evidence

- local Swift/Xcode compile proof
- local XCTest execution proof
- rendered preview or simulator screenshot proof
- future bounded Today integration proof if `StartHereSurface` directly consumes `StartHereProductKernel` for visible text and accessibility value

## Boundary

This proof contract confirms source files were installed in the repo. It does not claim release readiness or App Store readiness.
