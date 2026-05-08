# AFI09 Time LifeShape Field

<!-- markdownlint-disable MD013 -->

Status: Complete / Accepted Yellow
Date: 2026-05-08

## Purpose

Complete Time as Shape Time / LifeShape Field in the active AFI lane while
preserving the existing internal `.plan` route and Plan implementation seams as
compatibility-only names.

## Source Truth

- `docs/AmbitionsCanon/03_Signature_Object_Specs.md`
- `docs/AmbitionsCanon/10_Ambitions_Flagship_Interface_Canon.md`
- `docs/AmbitionsCanon/15_AFI_Implementation_Lane.md`
- `docs/AmbitionsCanon/16_Surface_Identity_And_Signature_Moments.md`
- `docs/codex/AMBITIONS_CANON_UI_COMPLETION_INSERTION_OVERLAY.md`

## Scope

- Keep Time as the fourth active top-level destination.
- Present the Time surface as Shape Time / LifeShape Field.
- Show open time, goal time, protected time, pressure, and capacity truth.
- Keep Calendar permission/request posture explicit and manual; Time must work
  without Calendar access.
- Preserve `.plan`, Plan file paths, Plan route targets, and legacy deep-link
  compatibility as internal implementation seams.

## Forbidden

- Do not restore Plan as a top-level destination.
- Do not turn Time into a calendar clone, agenda, schedule dashboard, analytics
  dashboard, or red-alert pressure surface.
- Do not silently schedule, write calendar/reminder data, mutate goals, or hide
  manual fallback controls.
- Do not change route raw values, persistence schema, package boundaries,
  signing, entitlements, hosted workflows, sync/cloud behavior, or release
  posture.

## Validation

- `xcodegen generate`
- Focused Time/contract/reality lane:
  `xcodebuild -project Ambitions.xcodeproj -scheme Ambitions -destination 'platform=iOS Simulator,name=iPhone 17' -only-testing:AmbitionsTests/PlanFeatureServiceTests -only-testing:AmbitionsTests/ScreenContractRegistryTests -only-testing:AmbitionsTests/TopLevelSurfaceCompositionTests -only-testing:AmbitionsTests/LoadingDegradedStateDesignSystemTests -only-testing:AmbitionsTests/InteractionMotionHapticsDesignSystemTests -only-testing:AmbitionsTests/CalendarRealityServiceTests -only-testing:AmbitionsTests/RealityModelsTests -only-testing:AmbitionsTests/RealityIntegrationAdaptersTests -only-testing:AmbitionsTests/CalendarReminderActionFlowTests test CODE_SIGNING_ALLOWED=NO`
- `./scripts/build-local.sh`
- `python3 -m py_compile scripts/ai/acx_visual_packet.py`
- `python3 scripts/ai/acx_visual_packet.py Time <changed Time files>`
- `python3 scripts/ai/acx_accessibility_packet.py Time <changed Time files>`
- `git diff --check`

## Closeout

Result: Accepted Yellow. Focused tests and local build passed. Rendered
screenshot proof, manual accessibility traversal, full UI test suite,
physical-device proof, signed archive proof, and public accessibility
conformance remain unclaimed.
