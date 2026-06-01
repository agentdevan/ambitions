# AFRI-013 Experience Kernel App Target Wiring Proof

Issue: AMB-365 / AFRI-013
Date: 2026-05-31
Scope: Wire the installed `AmbitionsExperienceKernel` local Swift package into the real Ambitions app target.

## Summary

`AmbitionsExperienceKernel` is now declared as a local package in `project.yml` and added as a dependency of the real `Ambitions` application target. A minimal app-owned compile seam imports the package and reads canonical surface contracts, and a focused app test verifies the real app target can see the package product.

No second app shell, prototype app target, runtime route, top-level destination, network path, third-party measurement path, hosted AI path, or release claim was added.

## Source-Truth Wiring

`project.yml` now includes the local package:

```yaml
packages:
  AmbitionsPackages:
    path: .
  AmbitionsExperienceKernel:
    path: Packages/AmbitionsExperienceKernel
```

The real `Ambitions` app target now depends on the package product:

```yaml
dependencies:
  - package: AmbitionsExperienceKernel
    product: AmbitionsExperienceKernel
```

`xcodegen generate` completed after this source-truth change. It produced no versioned `Ambitions.xcodeproj/project.pbxproj` diff in this working copy.

## Compile Integration

Added `Native/Ambitions/App/AmbitionsExperienceKernelIntegration.swift`:

- imports `AmbitionsExperienceKernel`
- exposes the package product name
- reads `AmbitionsSurfaceContracts.canonical.count`
- reads the Today primary object from the package contract

Added `Native/AmbitionsTests/App/AmbitionsExperienceKernelIntegrationTests.swift`:

- verifies the app target can see `AmbitionsExperienceKernel`
- verifies the canonical surface count is `5`
- verifies the Today primary object is `realityMeridian`

## Repair Cycle

Initial Xcode validation stalled while processing `Packages/AmbitionsExperienceKernel/Resources/AmbitionsExperienceTokens.xcassets` through the package bundle. The stalled `xcodebuild`/asset-tool processes were terminated, then the package target was repaired to exclude the package `.xcassets` from SwiftPM/Xcode resource processing while preserving the token and manifest resource directories:

```swift
exclude: ["Resources/AmbitionsExperienceTokens.xcassets"],
resources: [
    .process("Resources/Tokens"),
    .process("Resources/Manifests")
]
```

The package still passes its package-local lint, repo-truth audit, and SwiftPM tests after this repair.

## Validation

Verified:

- `python3 scripts/ambitions-parallel-implementation-guard.py --phase pre --batch AMB-365 --batch-type guard-repair --prompt /tmp/AMB-365-AFRI-013-guard-prompt.md`
  - Green
  - Report: `build/reports/parallel-implementation-guard/AMB-365-pre.md`
- `xcodegen generate`
  - Green
- `python3 Scripts/ambitions_kernel_lint.py`
  - Green
- `python3 Scripts/repo_truth_audit.py .`
  - Green
- `swift test`
  - Green
  - 8 tests, 0 failures
- `xcodebuild test -project Ambitions.xcodeproj -scheme Ambitions -configuration Debug -destination id=8ACCD665-4807-4102-B526-5A1AE20686A8 -only-testing:AmbitionsTests/AmbitionsExperienceKernelIntegrationTests`
  - Green
  - 1 test, 0 failures
  - Result bundle: `/Users/devan/Library/Developer/Xcode/DerivedData/Ambitions-clensfmdeeuxsueugpmolbvkzbxq/Logs/Test/Test-Ambitions-2026.05.31_20-23-04--0400.xcresult`
  - Build log showed `Ambitions` depends on `AmbitionsExperienceKernel` and linked `AmbitionsExperienceKernel.swiftmodule`.

Pending after this packet:

- post-implementation guard
- whitespace diff check
- targeted provider/off-device, old-product-term, sensitive-key, and unsupported-claim scans

## Claim Boundary

This proof demonstrates dependency wiring and compile visibility only. It does not claim product behavior completion, visual integration, release readiness, physical-device proof, public accessibility proof, store-submission readiness, or beta-distribution readiness.
