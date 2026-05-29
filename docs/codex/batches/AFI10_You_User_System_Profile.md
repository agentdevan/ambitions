# AFI10 You User System Profile

<!-- AMB-291-CANON-HYGIENE-HEADER: BEGIN -->

> Canon hygiene status: **execution-work-order-needs-sequencing**
> AMB-291 note: This batch/prompt is a work-order artifact and must be sequenced before execution.
> Active authority: `docs/truth/*`, `docs/codex/GLOBAL_BATCH_SEQUENCE_AUTHORITY.json`, and `docs/codex/IOS26_FLAGSHIP_TRAIN_MANIFEST.yml`.
> Before using this file for implementation, run `make change-impact-check` and follow `docs/ops/change-protocol/implementation-prompt-template.md`.
> Resolution classes: authority-rewrite, merge-overlap
> Dispositions: merge-or-sequence-file-ownership, merge-or-sequence-surface-ownership, rewrite-authority-reference

<!-- AMB-291-CANON-HYGIENE-HEADER: END -->

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
