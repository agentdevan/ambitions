# UIQL-005 Repair Reframe Report

Status: Closed as scoped Green after repair reframe
Issue: UIQL-005
Created: 2026-06-11

## Why Reframe Was Required

UIQL-005 exceeded three repair/evidence cycles:

- Initial Goals copy repair passed unit/UI checks but screenshots revealed loading-state `Constellation Atlas` copy.
- Overlay repair attempts reduced but did not eliminate dock/content obstruction.
- A rebuilt screenshot proved the stale loading copy repair, but direct screenshots could run against a previously installed app when the app was not reinstalled.
- Proof-mode screenshots showed `Thread Focus`, but complete expanded rows pushed Source/Why under the dock.

Continuing without reframe would risk a false Green based on passing identifiers while the actual bitmap still showed stale or obscured product text.

## Reframed Scope

UIQL-005 is not a full Goals redesign. The closeable scope is:

- visible root framing uses `Your Direction`
- visible inspection framing uses `Thread Focus`
- proof/source/why evidence can be shown without clipped text
- stale atlas/lens labels are not visible in the scoped first-screen proof path
- internal compatibility identifiers may remain when tests and source still depend on them

## Repairs Made

- Loading/degraded Goals object title now uses `Your Direction`.
- Loading copy now says direction object, recommended steps, and thread detail instead of atlas shape, next steps, and PM-board.
- First-screen screen contract now requires `Your Direction` and `Thread Focus`.
- Root object no longer paints secondary lane grid rows under the shell dock.
- Bottom Goals screen inset no longer paints an opaque mask over content.
- `orbital-lens-expanded` screenshot proof mode now shows only Proof, Source, and Why rows so those proof rows are visible together.

## Evidence Kept As Repair-Only

- Zero-test selector logs from early focused test attempts.
- The broad `ScreenContractRegistryTests` run with existing Capture/Motion failure.
- Initial screenshots showing the system URL prompt, stale loading copy, and dock obstruction.

These artifacts explain the repair path but are not used as final Green evidence.

## Final Green Evidence

Final Green relies on:

- clean diff/check and UIQL scans
- successful build-for-testing with wrapper Yellow noted
- serial focused Goals model/projection tests
- serial focused screen-contract language test
- serial focused Goals UI test
- visually inspected final proof-mode screenshot showing readable `Your Direction`, equal-weight Life Areas, `Thread Focus`, Proof, Source, and Why rows

## Remaining Yellow

- Linear `UIQL-005` was unavailable through the connector.
- Xcode wrapper reports missing result bundles despite pass/build success footers.
- Existing broad screen-contract Capture/Motion drift remains outside UIQL-005.

## Non-Claims

This reframe does not claim owner approval, full accessibility certification, device proof, performance proof, release readiness, TestFlight readiness, App Store readiness, or PLOS runtime completeness.
