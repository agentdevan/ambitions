# AFEP-022 Rollback Plan

Issue: AMB-416 / AFEP-022
Date: 2026-06-01

## Primary Rollback

Restore the approved baseline by reverting the AFEP-022 source scaffold and audit docs while keeping the AFRI-035 local observability baseline available.

## Exact Revert Targets

- `Native/Ambitions/Support/ReleasePerformanceResponsivenessReport.swift`
- `Native/AmbitionsTests/App/ReleasePerformanceResponsivenessReportTests.swift`
- `docs/audits/afep022-performance-energy-observatory-report.md`
- `docs/audits/afep022-query-render-budget-report.md`
- `docs/audits/afep022-degradation-fallback-report.md`
- `docs/audits/afep022-performance-claim-boundary.md`
- `docs/audits/afep022-rollback-plan.md`

## Fallback Baseline

- `AFRI-035 local observability baseline`
- `docs/status/performance-budgets.md`

## Rollback Steps

1. Revert the AFEP-022 support source additions.
2. Revert the AFEP-022 report tests.
3. Remove the AFEP-022 audit docs and prompt.
4. Keep the AFRI-035 baseline and local performance budget contracts intact.
5. Re-run the focused validation and claim-boundary checks before closing the batch.
