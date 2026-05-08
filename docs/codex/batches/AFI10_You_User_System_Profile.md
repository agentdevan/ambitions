# AFI10 You User System Profile

<!-- markdownlint-disable MD013 -->

Status: Complete / Accepted Yellow
Date: 2026-05-08

## Purpose

Complete You as Your System / User System Profile in the active AFI lane while
preserving existing `Profile` implementation paths, models, tests, and
compatibility identifiers as internal seams.

## Source Truth

- `docs/AmbitionsCanon/03_Signature_Object_Specs.md`
- `docs/AmbitionsCanon/10_Ambitions_Flagship_Interface_Canon.md`
- `docs/AmbitionsCanon/15_AFI_Implementation_Lane.md`
- `docs/AmbitionsCanon/16_Surface_Identity_And_Signature_Moments.md`
- `docs/codex/AMBITIONS_CANON_UI_COMPLETION_INSERTION_OVERLAY.md`

## Scope

- Keep You as the fifth active top-level destination.
- Present You as Your System / User System Profile.
- Keep grouped iOS Settings-like navigation.
- Keep Trust & Automation, Privacy, Receipts & History, Planning Setup, and
  Defaults visible.
- Preserve `Profile` file paths, test names, model names, and internal
  compatibility identifiers.

## Forbidden

- Do not restore Profile as a top-level tab.
- Do not make You a social profile, admin console, account hub, AI settings
  wall, or generic settings dump.
- Do not claim account, sync, cloud, privacy/legal, accessibility, release,
  physical-device, or production readiness.
- Do not change route raw values, persistence schema, package boundaries,
  signing, entitlements, hosted workflows, sync/cloud behavior, or release
  posture.

## Validation

- `xcodegen generate`
- Focused You/contract/composition lane:
  `xcodebuild -project Ambitions.xcodeproj -scheme Ambitions -destination 'platform=iOS Simulator,name=iPhone 17' -only-testing:AmbitionsTests/ProfileFeatureServiceTests -only-testing:AmbitionsTests/PersonalSystemCenterDesignSystemTests -only-testing:AmbitionsTests/ScreenContractRegistryTests -only-testing:AmbitionsTests/LoadingDegradedStateDesignSystemTests -only-testing:AmbitionsTests/TopLevelSurfaceCompositionTests test CODE_SIGNING_ALLOWED=NO`
- `./scripts/build-local.sh`
- `python3 -m py_compile scripts/ai/acx_visual_packet.py`
- `python3 scripts/ai/acx_visual_packet.py You <changed You files>`
- `python3 scripts/ai/acx_accessibility_packet.py You <changed You files>`
- `git diff --check`

## Closeout

Result: Accepted Yellow. Focused tests and local build passed. Rendered
screenshot proof, manual accessibility traversal, full UI test suite,
physical-device proof, signed archive proof, and public accessibility
conformance remain unclaimed.
