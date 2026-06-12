# AMB-963 / UIQL-008 Repair Reframe Report

Status: Green after reframe
Date: 2026-06-11
Branch: main

## Trigger

AMB-963 exceeded three repair cycles during screenshot proof. The failures were not all product failures, but continuing without a reframe would have risked false Green from passing element checks and screenshot paths.

## Red / Yellow Findings

Red findings repaired:

- Selected life-area proof initially rendered `Selected` as `Sel...` in the tile.
- Proof/source screenshot initially placed proof rows behind the floating dock.
- A later proof/source screenshot exposed proof rows but pushed content under the shell header.

Yellow tooling findings retained:

- Accessibility-size screenshot attempts failed to launch the Goals screen reliably. AMB-963 closes on large Dynamic Type/text-wrap proof, not formal accessibility certification.
- Preview/manual empty-state screenshot harness failed to expose `goals.screen`; AMB-963 does not use that path as Green evidence.
- Several xcodebuild runs lingered in result-bundle diagnostics after failure and were terminated after their failure logs were preserved.

## Repair Reframe

The repair was reframed from "make the screenshot test pass" to "make the proof states visually true":

- selected life-area state must not depend on a truncatable status word;
- proof/source state must put the Orbital Lens proof rows above the dock without scroll/header collision;
- the final screenshot matrix must be visually inspected after export.

## Repairs Applied

- Replaced the visible `Selected` label with a scope icon while preserving the selected accessibility value.
- Made `proofAvailable` prioritize the Orbital Lens.
- Moved the prioritized Orbital Lens above the life-area band only for proof-priority states.
- Added a dedicated AMB-963 screenshot matrix and kept final proof in `screenshots/amb-963/rerun11/`.
- Updated focused tests and source truth from `Direction Atlas` to `Constellation Atlas + Orbital Lens` while keeping user-facing `Your Direction` and `Thread Focus`.

## Final Validation

- `git diff --check`: passed
- `bash .agents/skills/uiql-quality-lockdown/scripts/uiql-mini-regression.sh`: passed
- `AMB-963-goals-screenshot-matrix-rerun11.log`: passed, 1 UI test / 0 failures
- `AMB-963-goals-focused-unit-tests-rerun3.log`: passed, 6 tests / 0 failures
- Final screenshots visually inspected:
  - `artifacts/ui-quality-lockdown/screenshots/amb-963/rerun11/amb-963-goals-default.png`
  - `artifacts/ui-quality-lockdown/screenshots/amb-963/rerun11/amb-963-goals-selected-life-area.png`
  - `artifacts/ui-quality-lockdown/screenshots/amb-963/rerun11/amb-963-goals-proof-source-visible.png`
  - `artifacts/ui-quality-lockdown/screenshots/amb-963/rerun11/amb-963-goals-large-dynamic-type.png`

## No-Claim Boundaries

This reframe does not claim owner approval, physical-device proof, full accessibility certification, VoiceOver certification, release readiness, TestFlight readiness, App Store readiness, or completion of AMB-964 and later UIQL issues.

## Rollback Notes

If AMB-963 must be rolled back, revert the local AMB-963 commit and remove the AMB-963 proof artifacts. Do not revert AMB-962 or earlier local commits as part of this rollback.
