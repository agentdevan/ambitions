# AMB-966 Repair Reframe Report

Issue: AMB-966 / UIQL-011 You Reconstruction
Status: repair reframe completed; scoped local Green after final matrix rerun12

## Why Reframe Was Required

AMB-966 exceeded three repair cycles. Automated passing states were not enough because visual inspection found product Reds in exported screenshots:

- The default You screenshot initially rendered only the first priority route and later let the dock gradient obscure Receipts & History.
- Large Dynamic Type root proof produced clipped/dock-covered root text.
- The Personal Runtime large Dynamic Type detail exposed a clipped sheet navigation title.
- Trust & Automation showed a truncated `Requires confir...` status pill.
- Receipts & History showed a truncated `5 guarded boun...` status pill.

## Reframed Repair Scope

The safe repair scope stayed inside You Reconstruction:

- Make the You first viewport a control surface for "How Ambitions works for me."
- Keep the User System Profile object visible.
- Render all priority You paths.
- Repair visible clipped/truncated labels in required proof paths.
- Use the Personal Runtime detail path for large Dynamic Type proof instead of claiming the root-at-rest frame proves the entire accessibility matrix.
- Preserve no-claim boundaries for system Increase Contrast, VoiceOver, full accessibility, owner approval, and release readiness.

## Final Repair

- `YouRootSurface.swift`
  - Renamed visible priority field copy from `Runtime Governance` to `How Ambitions works for me`.
  - Rendered all priority items instead of `items.prefix(1)`.
  - Tightened header and priority field typography/spacing.
- `YouScreen.swift`
  - Added `you.scroll` test anchor.
  - Removed redundant detail-sheet navigation title to prevent Dynamic Type truncation.
  - Allowed You detail status pills to use available width.
- `YouFeatureService.swift`
  - Shortened visible automation confirmation status to `Confirm first`.
- `YouTrustHistoryProjector.swift`
  - Shortened automation history status to `5 boundaries`.
- Tests
  - Added AMB-966 source contract assertions.
  - Added AMB-966 screenshot matrix covering default You, Trust & Automation, Personal Runtime, Receipts & History, large Dynamic Type, requested contrast launch, and Local Data Controls bottom-inset proof.

## Failed / Intermediate Evidence

Intermediate logs and screenshots are repair evidence only:

- `AMB-966-you-screenshot-matrix.log`
- `AMB-966-you-screenshot-matrix-rerun2.log`
- `AMB-966-you-screenshot-matrix-rerun3.log`
- `AMB-966-you-screenshot-matrix-rerun4.log`
- `AMB-966-you-screenshot-matrix-rerun5.log`
- `AMB-966-you-screenshot-matrix-rerun6.log`
- `AMB-966-you-screenshot-matrix-rerun7.log`
- `AMB-966-you-screenshot-matrix-rerun8.log`
- `AMB-966-you-screenshot-matrix-rerun9.log`
- `AMB-966-you-screenshot-matrix-rerun10.log`
- `AMB-966-you-screenshot-matrix-rerun11.log`
- Screenshot exports before `rerun12`

Only `AMB-966-you-screenshot-matrix-rerun12.log` and `screenshots/amb-966/rerun12/` are final visual proof.

## Final Evidence

- `git diff --check`: pass.
- `bash .agents/skills/uiql-quality-lockdown/scripts/uiql-mini-regression.sh`: pass.
- `AMB-966-you-source-contract-tests-rerun3.log`: pass, 1 test / 0 failures.
- `AMB-966-you-screenshot-matrix-rerun12.log`: pass, 1 test / 0 failures.
- Final screenshots visually inspected in `artifacts/ui-quality-lockdown/screenshots/amb-966/rerun12/`.

## Remaining Boundaries

- Push pending owner manual push.
- AMB-966 should remain In Progress in Linear until the local commit is pushed and visible on `origin/main`.
- Requested Increase Contrast proof is best-effort launch-argument evidence only, not certified system setting proof.
- AMB-968 owns broader accessibility variant proof.
- AMB-970 owns independent read-only red-team visual audit.
- AMB-969 owns final owner approval package and must not claim owner approval itself.
