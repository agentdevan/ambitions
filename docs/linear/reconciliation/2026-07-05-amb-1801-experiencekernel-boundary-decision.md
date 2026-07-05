# AMB-1801 ExperienceKernel Boundary Decision

Status: Linear source remediation proof packet
Date: 2026-07-05
Baseline main SHA: `7bebf7a6c289e52d9078c98e373a89293060afd3`
Project: Architecture Simplification + Flagship Readiness Remediation (`59c3917f-f662-4ca3-b412-b532613f3a7a`)
Issue: `AMB-1801` ExperienceKernel Leaf - Live import and boundary decision

## Scope

This packet records the bounded package-boundary decision for
`Packages/AmbitionsExperienceKernel`.

Decision: delete `AmbitionsExperienceKernel`.

The package had no live production product role beyond an app-side keep-alive
integration enum and a keep-alive unit test. Its package docs and contracts also
carried stale experience-kernel language that conflicts with the current
four-surface canon and the remediation rule to delete duplicate authority before
preserving names.

This leaf does not decide every package boundary in the repo. It closes only the
`AmbitionsExperienceKernel` live-import and boundary question.

## Live Inputs Inspected

- `AGENTS.md`
- `docs/truth/README.md`
- `docs/truth/CODEX_START_HERE.md`
- `docs/truth/PRIVATE_LIFE_ORCHESTRATION_TRUTH.md`
- `docs/truth/PRODUCT_DESIGN_TRUTH.md`
- `docs/truth/PRODUCT_ORIGIN_TRUTH.md`
- `docs/truth/PRODUCT_MOAT_TRUTH.md`
- `docs/truth/PRODUCT_EXPERIENCE_CANON.md`
- `docs/truth/IMPLEMENTATION_TRUTH.md`
- `docs/truth/IMPLEMENTATION_ACCEPTANCE_TRUTH.md`
- `docs/truth/RELEASE_TRUTH.md`
- `docs/truth/CODEX_PROCESS_TRUTH.md`
- `docs/truth/HISTORICAL_POLICY.md`
- `.agents/skills/README.md`
- `.agents/skills/ambitions-source-truth-authority/SKILL.md`
- `.agents/skills/ambitions-architecture-tree-enforcement/SKILL.md`
- `.agents/skills/ambitions-ios-quality-gate/SKILL.md`
- `.agents/skills/ambitions-release-proof-honesty/SKILL.md`
- `.agents/skills/ambitions-runtime-contract-engineering/SKILL.md`
- Live Linear state for `AMB-1801`
- Live Linear parent state for `AMB-1679`

## Import and Boundary Evidence

Pre-delete build graph:

- `project.yml` declared the local package at `Packages/AmbitionsExperienceKernel`.
- The `Ambitions` app target depended on the package product
  `AmbitionsExperienceKernel`.
- `.swiftlint.yml` excluded only the package-local `.build` directory.

Pre-delete live app references:

- `Native/Ambitions/App/AmbitionsExperienceKernelIntegration.swift` imported
  `AmbitionsExperienceKernel` and exposed only `packageProductName`,
  `canonicalSurfaceCount`, and `todayPrimaryObjectName`.
- `Native/AmbitionsTests/App/AmbitionsExperienceKernelIntegrationTests.swift`
  asserted only that the app target could see the package and expected
  `canonicalSurfaceCount == 5`.
- `Packages/AmbitionsExperienceKernel/Sources/AmbitionsExperienceKernel/AmbitionsDomain.swift`
  defined four root surfaces: `today`, `goals`, `time`, and `you`.
- `Packages/AmbitionsExperienceKernel/Docs/RepoIntegration.md` still listed
  `Capture / Atmosphere Composer` as a migration-order surface, even though
  active canon makes Capture a global composer/action layer, not a tab or root
  surface.

Reference scan:

- `rg -n "AmbitionsExperienceKernel|ExperienceKernel|import AmbitionsExperienceKernel|Packages/AmbitionsExperienceKernel" Native Sources AppUI Package.swift project.yml .swiftlint.yml Ambitions.xcodeproj`
  returned no post-delete live app/source/project references.
- `test ! -e Packages/AmbitionsExperienceKernel` passed after deleting the
  tracked package and untracked package-local build residue.

No absorb action was taken because the scanned app dependency was a keep-alive
seam, not unique production behavior.

## Source Changes

Removed stale package authority:

- `Packages/AmbitionsExperienceKernel/**`

Removed app-side keep-alive references:

- `Native/Ambitions/App/AmbitionsExperienceKernelIntegration.swift`
- `Native/AmbitionsTests/App/AmbitionsExperienceKernelIntegrationTests.swift`

Updated build/tooling configuration:

- `project.yml`
  - removed the `AmbitionsExperienceKernel` package declaration
  - removed the app target dependency on product `AmbitionsExperienceKernel`
- `.swiftlint.yml`
  - removed the deleted package-local `.build` exclusion

Regenerated the XcodeGen project after updating `project.yml`.

## Architecture Closeout

- Final Architecture Tree inspected: yes.
- Canonical owners touched:
  - `project.yml` build graph
  - `.swiftlint.yml` lint configuration
  - `Native/Ambitions/App` removal only
  - `Native/AmbitionsTests/App` removal only
  - `docs/linear/reconciliation`
- Files moved or created:
  - `docs/linear/reconciliation/2026-07-05-amb-1801-experiencekernel-boundary-decision.md`
- Old/non-canonical paths removed:
  - `Packages/AmbitionsExperienceKernel/**`
  - `Native/Ambitions/App/AmbitionsExperienceKernelIntegration.swift`
  - `Native/AmbitionsTests/App/AmbitionsExperienceKernelIntegrationTests.swift`
- Compatibility shims left behind: none.
- New `+02`, `+03`, or `+04` split files added: none.
- New broad `Models.swift` files added: none.
- New production runtime, persistence, projection, receipt, or mutation authority
  added: none.
- No alternate folder/path interpretation was used.

Remaining Yellow architecture debt:

- Other package boundaries are not made Green by this leaf.
- Parent package-boundary remediation must still treat any remaining package
  decisions as separate scoped evidence unless Linear explicitly accepts this
  deletion as sufficient for the parent package floor.

Next repair train:

- Continue with the next Ready For Codex package or boundary child after this
  leaf is validated and reconciled.

## Validation

Completed before closeout:

- `xcodegen generate`: passed.
- Post-delete reference scan: no live app/source/project references remained.
- `test ! -e Packages/AmbitionsExperienceKernel`: passed.
- `gtimeout 20s xcrun simctl list devices available`: passed and listed the
  iOS 26.5 `iPhone 17 Pro Max`
  `0F5F5AC4-4303-47C8-9BDC-EB5F57A0F79E`.
- `scripts/ambitions-bounded-xcodebuild.sh --timeout 10m --kill-after 60s --log .codex/xcode-logs/AMB-1801-experiencekernel-boundary/resolve-package-dependencies.log -- xcodebuild -project Ambitions.xcodeproj -scheme Ambitions -resolvePackageDependencies`:
  passed. Resolved source packages listed only `AmbitionsDesignSystem` from the
  repo root; `AmbitionsExperienceKernel` was absent from package resolution.
- `scripts/ambitions-bounded-xcodebuild.sh --timeout 20m --kill-after 60s --log .codex/xcode-logs/AMB-1801-experiencekernel-boundary/simulator-build.log -- xcodebuild -project Ambitions.xcodeproj -scheme Ambitions -sdk iphonesimulator -destination 'platform=iOS Simulator,id=0F5F5AC4-4303-47C8-9BDC-EB5F57A0F79E' -derivedDataPath .codex/DerivedData/Ambitions-AMB-1801 build CODE_SIGNING_ALLOWED=NO CODE_SIGNING_REQUIRED=NO COMPILER_INDEX_STORE_ENABLE=NO ONLY_ACTIVE_ARCH=YES`:
  passed with `** BUILD SUCCEEDED **`.
- `git diff --check`: passed.
- `python3 scripts/ambitions-remediation-governance-check.py --allow-package-boundary`:
  Green remediation governance guard passed.
- `python3 scripts/ambitions-accepted-yellow-misuse-audit.py`: valid, zero
  invalid Accepted Yellow issues.
- `python3 scripts/ambitions-quality-gate.py`: Green all strict quality gates
  passed.

`scripts/ambitions-xcodegen-needed.sh` reports
`XCODEGEN_NEEDED=1` with reason
`source/resource changed: Native/Ambitions/App/AmbitionsExperienceKernelIntegration.swift`
because the script treats changed Swift/resource paths as build graph inputs in
the working tree. `xcodegen generate` was run after the `project.yml` edit; the
project and package resolve/build checks are the drift proof for this deletion.

## Non-Claims

- No full package-boundary Green is claimed beyond
  `Packages/AmbitionsExperienceKernel`.
- No M02 Runtime Strangler Green is claimed.
- No production runtime behavior changed in this AMB-1801 leaf.
- No visual acceptance, accessibility acceptance, physical device proof,
  privacy/legal approval, TestFlight/App Store readiness, R2 readiness, or
  release readiness is claimed.

## Rollback

Revert this packet and the source/configuration changes from the AMB-1801 commit
to restore `Packages/AmbitionsExperienceKernel`, the app integration seam, the
integration test, the package dependency in `project.yml`, and the SwiftLint
package-local build exclusion.
