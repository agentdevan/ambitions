# AMB-967 / UIQL-012 Repair Reframe Report

Date: 2026-06-12
Program: UIQL
Issue: AMB-967 / UIQL-012 Capture + Create Goal Reconstruction
Status: repair cycle exceeded three attempts; completed with narrowed selector/deeplink/product-copy repair

## Trigger

The AMB-967 screenshot matrix required more than three repair cycles:

- `AMB-967-capture-create-goal-screenshot-matrix-rerun1.log`: failed because the new compact route buttons used the existing `.correction` identifiers while the test expected base route identifiers.
- `AMB-967-capture-create-goal-screenshot-matrix-rerun2.log`: Capture states rendered and screenshots were attached; Create Goal opening failed because the helper selected an offscreen header Capture button.
- `AMB-967-capture-create-goal-screenshot-matrix-rerun3.log`: Capture states rendered and screenshots were attached; Create Goal opening failed because `ambitions://create-goal` is not the supported overlay deep link in this bootstrap path.
- `AMB-967-capture-create-goal-screenshot-matrix-rerun4.log`: automation passed, but visual inspection found clipped Capture route labels/source-trust copy while the keyboard was present.
- `AMB-967-capture-create-goal-screenshot-matrix-rerun5.log`: Capture visual Red was repaired, but Create Goal first-path preview still exposed card-like clipped seed-review anatomy.
- `AMB-967-capture-create-goal-screenshot-matrix-rerun6.log`: build failed because the first Create Goal repair left an extra brace.
- `AMB-967-capture-create-goal-screenshot-matrix-rerun7.log`: build failed on a non-existent theme color token, and the concurrent source-contract lane hit an Xcode build database lock.
- `AMB-967-capture-create-goal-screenshot-matrix-rerun8.log`: automation passed and visual structure improved, but screenshot inspection found active `Smallest Next Move` copy.
- `AMB-967-capture-create-goal-screenshot-matrix-rerun9.log`: final automation passed after the planner copy repair; exported screenshots were visually inspected and accepted for scoped AMB-967 local Green.

## Reframe

The product repair remains scoped and safe:

- Keep the activated Capture seam route reveal in the seam body only after text exists.
- Keep the four required route labels as compact correction buttons.
- Keep Create Goal language and source contract repair.
- Use the repo-supported overlay URL `ambitions://overlay/create-goal` for Create Goal screenshot proof.
- Reorder Create Goal so `Goal to path` appears before the seed review.
- Render the first-path preview as an in-flow object section instead of a generic card shell.
- Replace active `move` language in the starter path with `step` language.

## Not a Product Green Yet

AMB-967 could not close until:

- The screenshot matrix passes or a Red blocker is recorded.
- Exported screenshots are visually inspected.
- Focused source contract remains Green.
- UIQL scans and preflight are Green from the final dirty/clean boundary.

Final local closeout uses `AMB-967-capture-create-goal-source-contract-final.log`, `AMB-967-capture-create-goal-screenshot-matrix-rerun9.log`, and screenshots under `artifacts/ui-quality-lockdown/screenshots/amb-967/rerun9/`.

## No-Claim Boundary

This report does not claim owner approval, release readiness, TestFlight readiness, App Store readiness, full accessibility certification, VoiceOver certification, physical-device proof, or AMB-968 accessibility proof.
