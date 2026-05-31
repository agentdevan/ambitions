# AFRI-027 You User System Profile Proof

Status: Green for scoped local proof
Issue: AMB-379 / AFRI-027
Date: 2026-05-31

## Scope

AFRI-027 strengthens the existing You surface around the active User System Profile product object. The patch does not add a top-level destination, restore Plan as user-facing IA, create a social profile, create an admin console, add hosted account infrastructure, or introduce analytics, telemetry, cloud AI, backend, or network dependencies.

The scoped implementation makes the User System Profile inspection basis explicit across planning setup, trust controls, local learning controls, reset/disable/delete/export posture, privacy boundaries, automation boundaries, and SourceRecord / Receipt / ReplayTrace vocabulary.

## Source Changes

- `Native/Ambitions/Domain/YouModels.swift`
  - Adds a `YouDashboard.userSystemProfileInspectionSummary` projection for the primary You object.
- `Native/Ambitions/Features/You/YouRootSurface.swift`
  - Exposes the User System Profile inspection summary through the root accessibility value.
- `Native/Ambitions/Features/You/YouFeatureService.swift`
  - Tightens You copy around User System Profile and SourceRecord-backed local memory controls.
- `Native/AmbitionsTests/You/YouFeatureServiceTests.swift`
  - Adds AFRI-027 coverage for inspectable planning, trust, local learning, reset, privacy, automation, SourceRecord, Receipt, and ReplayTrace boundaries.

## Proof

- Pre-implementation guard: `python3 scripts/ambitions-parallel-implementation-guard.py --phase pre --batch AMB-379 --prompt /tmp/AMB-379-AFRI-027-guard-prompt.md` passed after removing stale prompt wording.
- Focused unit validation: `xcodebuild test -project Ambitions.xcodeproj -scheme Ambitions -destination id=8ACCD665-4807-4102-B526-5A1AE20686A8 -only-testing:AmbitionsTests/YouFeatureServiceTests/testAFRI027YouProjectsInspectableUserSystemProfileControls` passed.
- You feature validation: `xcodebuild test -project Ambitions.xcodeproj -scheme Ambitions -destination id=8ACCD665-4807-4102-B526-5A1AE20686A8 -only-testing:AmbitionsTests/YouFeatureServiceTests` initially failed on two stale expectations, then passed, 36 tests, 0 failures after repair. It was rerun after guard-driven source renaming and passed again, 36 tests, 0 failures.
- You UI smoke: `xcodebuild test -project Ambitions.xcodeproj -scheme Ambitions -destination id=8ACCD665-4807-4102-B526-5A1AE20686A8 -only-testing:AmbitionsUITests/AmbitionsUITests/testPreviewBootstrapExposesCanonicalFiveTabShellAndSecondarySurfaces` passed, 1 test, 0 failures.
- Post-implementation guard: `python3 scripts/ambitions-parallel-implementation-guard.py --phase post --batch AMB-379 --prompt /tmp/AMB-379-AFRI-027-guard-prompt.md ...` passed after moving the inspection projection inside the existing You owner type, removing newly introduced deprecated wording from active source, and adding AMB-379 to the existing `proof_receipt_replay` and `you_profile_personal_runtime` concept-lock allowlists.

## Boundaries

- This is local source, unit, and simulator proof only.
- This does not claim device, signed archive, TestFlight, App Store, release, legal, privacy-review, full accessibility audit, screenshot, or CI proof.
- No new top-level IA, cloud AI, hosted backend, analytics, telemetry, network dependency, account system, or destructive memory action was added.
