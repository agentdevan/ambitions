# AFI10 You User System Profile Report

<!-- markdownlint-disable MD013 -->

Date: 2026-05-08
Status: Accepted Yellow
Batch: AFI10 You User System Profile

## Result

AFI10 aligned the You surface with active AFI source truth: Your System / User
System Profile. The pass updated touched visible You copy, screen contracts,
composition primitives, degraded-state object names, preview fixtures, and
focused tests while preserving `Profile` as an internal implementation and
compatibility seam.

## Files Changed

- `Native/Ambitions/Domain/ScreenContractModels.swift`
- `Native/Ambitions/Features/Profile/ProfileFeatureService.swift`
- `Native/Ambitions/Features/Profile/ProfileRootSurface.swift`
- `Native/Ambitions/Features/Shared/DegradedStateOrchestrator.swift`
- `Sources/Components/TopLevelSurfaceCompositionPrimitives.swift`
- `Sources/Previews/SignatureInterfaceVisualQAFixtures.swift`
- `scripts/ai/acx_visual_packet.py`
- focused You/profile/contract/composition tests
- batch/state/report docs

## Behavior Changed

The visible You root now presents as Your System, with User System Profile as
the primary object language. The grouped navigation keeps Planning Setup,
Trust & Automation, Privacy, Receipts & History, and Defaults visible, while
older Profile labels are kept out of the touched top-level visible You copy.

Internal `Profile` feature paths, model names, test names, and route
compatibility names remain unchanged.

## Tests Run

- `xcodegen generate`
- Focused You/contract/composition lane:
  `xcodebuild -project Ambitions.xcodeproj -scheme Ambitions -destination 'platform=iOS Simulator,name=iPhone 17' -only-testing:AmbitionsTests/ProfileFeatureServiceTests -only-testing:AmbitionsTests/PersonalSystemCenterDesignSystemTests -only-testing:AmbitionsTests/ScreenContractRegistryTests -only-testing:AmbitionsTests/LoadingDegradedStateDesignSystemTests -only-testing:AmbitionsTests/TopLevelSurfaceCompositionTests test CODE_SIGNING_ALLOWED=NO`
  passed with 50 selected tests, 0 failures. Raw log:
  `.codex/logs/2026-05-08T15-afi10-focused-tests-rerun.raw.log`.
- `./scripts/build-local.sh` passed. Raw log:
  `output/logs/build-local-20260508-140304.log`.
- `python3 -m py_compile scripts/ai/acx_visual_packet.py`
- `python3 -m py_compile scripts/ai/acx.py scripts/ai/acx_local.py scripts/ai/acx_impact.py scripts/ai/acx_closeout.py scripts/ai/acx_repair.py scripts/ai/acx_visual_packet.py scripts/ai/acx_accessibility_packet.py`
- `python3 scripts/ai/acx_visual_packet.py You Native/Ambitions/Features/Profile/ProfileScreen.swift Native/Ambitions/Features/Profile/ProfileRootSurface.swift Native/Ambitions/Features/Profile/ProfileFeatureService.swift Native/Ambitions/Domain/ScreenContractModels.swift`
- `python3 scripts/ai/acx_accessibility_packet.py You Native/Ambitions/Features/Profile/ProfileScreen.swift Native/Ambitions/Features/Profile/ProfileRootSurface.swift Native/Ambitions/Features/Profile/ProfileFeatureService.swift Native/Ambitions/Domain/ScreenContractModels.swift`
- `python3 scripts/ai/acx_local.py bundle quick`
- `python3 scripts/ai/acx_local.py bundle batch-closeout`
- `python3 scripts/ai/acx_local.py bundle codex-os`
- `python3 scripts/ai/acx_repair.py diagnose` returned Yellow
  `NoActiveRepairEvidence`; no repair state was dirtied.
- `scripts/batch-train-gate-check.sh || true` returned expected dirty-tree
  Yellow before commit.
- `git diff --check`
- `scripts/global-train-next-batch.sh`

## Tests Not Run

- Rendered grouped-navigation screenshot proof.
- Manual accessibility traversal for trust/privacy controls.
- Full UI test suite.
- Physical-device validation.
- Signed archive validation.

## Known Risks

- The focused simulator test run emitted unsigned simulator app-group warnings;
  selected tests still passed.
- Historical docs and internal compatibility seams still contain Profile or
  Personal System Center identifiers. They were not treated as active top-level
  IA source truth.
- `scripts/ai/acx_visual_packet.py` now reports You as Your System / User
  System Profile for active AFI proof routing.
- Rendered screenshot and manual accessibility proof remain Yellow.
- The preserved stash remains Yellow evidence and was not applied.

## Claims

The touched You/Profile surface, screen-contract, degraded-state, composition,
preview-fixture, and focused-test seams now respect active AFI Your System /
User System Profile language while preserving internal compatibility seams.

## Non-Claims

No top-level Profile tab, route/raw-value rename, persistence/schema migration,
account behavior, cloud/sync behavior, production readiness, release readiness,
App Store readiness, TestFlight readiness, physical-device proof, public
accessibility conformance, privacy/legal approval, migration safety, backend
completion, or CI green status is claimed.

## Next Eligible Batch

AFI11 Trust Seam And Receipts.
