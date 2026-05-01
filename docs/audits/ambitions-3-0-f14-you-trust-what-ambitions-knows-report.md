# Ambitions 3.0 F14 You / Trust / What Ambitions Knows Report

Date: 2026-05-01

Result: Green

## Scope

F14 stayed inside the existing You/Profile trust-memory seam and strengthened
the `What Ambitions Knows` control plane with explicit personalization consent
state. The batch did not move Goal Mission Control ownership into You, did not
create hidden memory behavior, did not add analytics/backend/sync assumptions,
did not add dependencies, did not touch workflows, and did not make release or
handoff-readiness claims.

## Implementation

- Added `ProfilePersonalizationConsentState` to the Profile domain model.
- Added consent state to `ProfileMemoryControlState`.
- Projected deterministic consent copy from `ProfileFeatureService`:
  `Personalization consent`, `Based on local records`,
  `Sensitive memory requires approval`, `No hidden memory creation`, and
  `You are in control`.
- Rendered a consent panel inside the existing `What Ambitions Knows` / memory
  controls section on You/Profile.
- Updated Profile previews and focused Profile tests.

## Files Changed

- `Native/Ambitions/Domain/ProfileModels.swift`
- `Native/Ambitions/Features/Profile/ProfileFeatureService.swift`
- `Native/Ambitions/Features/Profile/ProfileScreen.swift`
- `Native/Ambitions/PreviewSupport/PreviewFixtures.swift`
- `Native/AmbitionsTests/Profile/ProfileFeatureServiceTests.swift`

## Validation

- Build: `scripts/build-local.sh` PASS on iPhone 17.
- Focused tests: `ProfileFeatureServiceTests` PASS, 16 tests, 0 failures.
- Architecture scan: advisory only. `ProfileFeatureService.swift` and
  `ProfileScreen.swift` remain pre-existing extraction-required files; F14 added
  70 lines total across touched files and did not change their risk class.
- Copy guard: touched-path scan found only existing/internal failure-state terms
  and the existing safe-failure receipt preview.
- Diff whitespace: `git diff --check` PASS.

## Privacy / Trust / Accessibility

- Personalization consent is visible, local-record sourced, and user-owned.
- Sensitive memory posture is explicit: sensitive memory requires approval.
- Hidden memory behavior is explicitly disclaimed.
- The consent panel uses visible text labels, grouped tags, and an accessibility
  identifier: `profile.personalization-consent`.

## Gate

F14 gate result: Green with accepted background Yellow.

F15 may proceed.
