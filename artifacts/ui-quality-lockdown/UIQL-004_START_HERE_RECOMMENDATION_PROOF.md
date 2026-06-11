# UIQL-004 Start Here Recommendation Object Proof

Status: Green for scoped UIQL-004 Start Here recommendation object quality gate.
Program: UIQL - Flagship UI Quality Lockdown
Issue: UIQL-004
Branch: main
Date: 2026-06-11

## Claim

The Today Start Here recommendation object now presents the active recommended step with explicit recommendation framing, canonical primary/secondary action language, source/proof/receipt context, and privacy-safe kernel projection behavior.

## Scope

In scope:

- Start Here recommendation object framing on Today.
- Canonical action projection from `TodayInlineAction` into `StartHereProductKernel`.
- Visible Today meta framing for the recommended step.
- Unit proof that public and private Start Here kernel projections satisfy the product audit.
- UI automation proof through the existing stable Today UIQL preview test.
- Current screenshot visual evaluation of the Start Here object.

Out of scope:

- Full app accessibility certification.
- Full Dynamic Type, VoiceOver, Increase Contrast, Reduce Motion, or Reduce Transparency audit.
- Owner approval, App Store/TestFlight readiness, device proof, performance proof, privacy/legal signoff, or release readiness.
- PLOS runtime completeness or Source Atlas Factory release eligibility.

## Files Touched

- `Native/Ambitions/Features/Today/StartHereProductKernelProjection.swift`
- `Native/Ambitions/Features/Today/TodayDayRailPanels.swift`
- `Native/AmbitionsTests/Today/TodayViewModelTests.swift`
- `Native/AmbitionsUITests/AmbitionsUITests.swift`
- `artifacts/ui-quality-lockdown/UIQL-004_START_HERE_RECOMMENDATION_PROOF.md`
- `artifacts/ui-quality-lockdown/UIQL-004_REPAIR_REFRAME_REPORT.md`
- UIQL run-state, changelog, repair log, decisions, and proof ledger files

## Product Evidence

The current simulator screenshot was visually inspected:

- Screenshot: `artifacts/ui-quality-lockdown/screenshots/UIQL-004-start-here-recommendation-final.png`
- Visible Start Here object includes: `Start here`, `Draft the talk outline`, `Recommended step`, source/proof rows, `Start now`, `Why this?`, `Move this`, Up Next continuity, and local proof receipt copy.
- No visible Start Here generic commodity language was found: no `recommendation card`, `task card`, `dashboard card`, `task list`, `AI recommends`, `best next move`, `next best move`, or `Begin Focus`.
- The screenshot path alone is not treated as proof; the visual content above was inspected.

## Validation

Passed:

- `git diff --check`
- `bash .agents/skills/uiql-quality-lockdown/scripts/uiql-scan-banned-copy.sh`
- `bash .agents/skills/uiql-quality-lockdown/scripts/uiql-scan-card-anatomy.sh`
- `bash .agents/skills/uiql-quality-lockdown/scripts/uiql-mini-regression.sh`
- `scripts/ambitions-xcode-build-for-testing.sh --batch UIQL-004`
- `AMBITIONS_SIM_UDID=8ACCD665-4807-4102-B526-5A1AE20686A8 scripts/ambitions-xcode-test-focused.sh --batch UIQL-004 --only-testing AmbitionsUITests/AmbitionsUITests/testUIQL003TodayRealityMeridianOwnsFirstViewportWithoutGenericTaskAnatomy`
- `AMBITIONS_SIM_UDID=8ACCD665-4807-4102-B526-5A1AE20686A8 scripts/ambitions-xcode-test-focused.sh --batch UIQL-004 --only-testing AmbitionsTests/TodayViewModelTests/testUIQL004StartHereKernelProjectionBindsRecommendationObjectProof`
- `AMBITIONS_SIM_UDID=8ACCD665-4807-4102-B526-5A1AE20686A8 scripts/ambitions-xcode-test-focused.sh --batch UIQL-004 --only-testing AmbitionsTests/TodayViewModelTests/testUIQL004PrivateStartHereKernelKeepsRecommendationProofRedacted`

Final proof logs:

- `artifacts/ui-quality-lockdown/script-output/UIQL-004-build-for-testing-after-uiql003-proof-fold-20260611T074348Z.log`
- `artifacts/ui-quality-lockdown/script-output/UIQL-004-start-here-proof-via-today-ui-test-20260611T074511Z.log`
- `artifacts/ui-quality-lockdown/script-output/UIQL-004-start-here-kernel-public-focused-test-final-20260611T074834Z.log`
- `artifacts/ui-quality-lockdown/script-output/UIQL-004-start-here-kernel-private-focused-test-final-serial-20260611T075123Z.log`
- `artifacts/ui-quality-lockdown/script-output/uiql-banned-copy.log`
- `artifacts/ui-quality-lockdown/script-output/uiql-card-anatomy.log`
- `artifacts/ui-quality-lockdown/script-output/uiql-shell.log`

## Repair Reframe

Standalone UIQL-004 UI test selectors were compiled into the UI test bundle but returned intermittent zero-test discovery results under the focused wrapper. The product assertion itself was preserved by folding the UIQL-004 checks into the already-discovered Today UIQL preview selector. The final accepted UI automation evidence executed one test with zero failures and included Start Here recommendation object checks.

Details: `artifacts/ui-quality-lockdown/UIQL-004_REPAIR_REFRAME_REPORT.md`

## Linear Closeout Text

Linear issue `UIQL-004` was not found through the available connector during this run. Manual closeout text:

```text
UIQL-004 Start Here recommendation object quality gate

- Pushed to main: pending closeout push
- App source changed: yes, scoped to Today Start Here projection, Today visible recommendation framing, and focused tests
- Start Here object Green: yes, scoped
- Product Yellow: none for UIQL-004 scope
- Screenshot path alone used as proof: no
- Visual screenshot evaluated: yes
- Build/test proof: build-for-testing, focused Today UI test, public kernel unit test, private-redaction kernel unit test
- Generic task/card/dashboard copy in Start Here: no
- Owner approval claimed: no
- Release/TestFlight/App Store readiness claimed: no
- Remaining Yellow: Linear issue unavailable through connector; full accessibility/device/release proof not claimed
```

## No-Claim Boundary

This proof does not claim owner approval, full accessibility certification, device proof, performance proof, privacy/legal signoff, TestFlight readiness, App Store readiness, release readiness, or completion of UIQL-005 and later issues.
