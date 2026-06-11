# UIQL-006 Repair Reframe Report

Status: Repair reframe completed
Program: UIQL
Issue: UIQL-006 - Time / LifeShape Field quality gate

## Why Reframe Was Required

UIQL-006 required more than three repair cycles because the first evidence pass exposed both product issues and proof issues:

- The initial Time screenshot showed the shell header as `TIME · Shape Time · Plan`, which surfaced an internal compatibility lens as visible product language.
- The initial Time screenshot showed the bottom dock/mask hiding lower first-viewport text, creating a product Yellow that UIQL cannot accept.
- The old unit contract expected the opaque bottom mask, so it had to be updated to protect the repaired clear spacing.
- The old UI workspace test still expected legacy `time.hero-card`, `time.timeline-strip`, and deeper Batch49 module assertions instead of the active LifeShape Field first-viewport object.
- Multiple UI test retries ran with stale compiled UI test bundles because the focused wrapper uses `test-without-building`; those failed logs are repair evidence only.

## Reframed Scope

The honest UIQL-006 scope is:

- Repair visible Time first-viewport framing.
- Keep Time centered on `LifeShape Field`, not generic calendar/plan/dashboard anatomy.
- Remove the dock/mask text occlusion.
- Prove the active Time route and LifeShape Field through rebuilt focused UI automation.
- Preserve deeper Time content as supporting material unless a later active issue scopes its full rework.

The scope is not:

- Full Time rewrite.
- Full Time deep-section certification.
- Release readiness.
- Owner approval.
- Full accessibility certification.
- Removal of every historical/unused Time type name from source.

## Smallest Repair

- Map the visible shell lens for Time shaping posture to `Capacity`.
- Replace the opaque bottom mask with clear safe-area spacing.
- Move the Week shape reading before the texture rows and adjust first-viewport density so text remains readable.
- Retarget the focused UI test to the active Time screen and LifeShape Field after rebuilding the UI test bundle.

## Final Evidence

- Final screenshot visually inspected: `artifacts/ui-quality-lockdown/screenshots/UIQL-006-time-lifeshape-final.png`
- Final build: `artifacts/ui-quality-lockdown/script-output/UIQL-006-build-for-testing-final-20260611T102057Z.log`
- Final UI test: `artifacts/ui-quality-lockdown/script-output/UIQL-006-time-workspace-ui-test-final-20260611T102158Z.log`
- Focused primitive test: `artifacts/ui-quality-lockdown/script-output/UIQL-006-time-object-stage-primitive-focused-test-final-20260611T094333Z.log`
- Proof packet: `artifacts/ui-quality-lockdown/UIQL-006_TIME_LIFESHAPE_FIELD_PROOF.md`

## Yellow Boundaries

- Linear issue lookup for `UIQL-006` failed; manual closeout is required.
- Xcode wrapper result-bundle extraction remains Yellow despite successful build/test footers.
- Failed stale/brittle UI test logs remain as repair evidence only.
- No owner, release, accessibility-certification, physical-device, or performance claim.

## Next Safe Action

After commit and push to `main`, update Linear manually if the connector still cannot find `UIQL-006`, then start UIQL-007 only after clean `main` preflight.
