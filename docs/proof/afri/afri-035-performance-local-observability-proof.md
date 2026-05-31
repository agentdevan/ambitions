# AFRI-035 Performance And Local Observability Baseline Proof

Issue: AMB-387 / AFRI-035
Date: 2026-05-31
Commit under validation: `ce4ddb66d`

## Status

Green for local budget contracts, focused source/test evidence, and local diagnostic/redaction posture.

Yellow for broad SwiftUI performance scan review: static scan found expected render/update hotspots and does not prove measured responsiveness.

No release-grade performance claim is made.

## Authority Inspected

- `docs/truth/RELEASE_TRUTH.md`
- `docs/status/performance-budgets.md`
- `docs/architecture/performance/TODAY_RENDER_BUDGET.md`
- `docs/architecture/performance/CAPTURE_LATENCY_BUDGET.md`
- `docs/architecture/performance/TIME_LIFESHAPE_RENDER_BUDGET.md`
- `docs/architecture/performance/WIDGET_SNAPSHOT_BUDGET.md`
- `docs/architecture/performance/LOCAL_RUNTIME_COMPUTE_BUDGET.md`
- `Native/Ambitions/Support/ReleasePerformanceResponsivenessReport.swift`
- `Native/Ambitions/Domain/EventLedgerModels.swift`
- `Native/AmbitionsTests/App/ReleasePerformanceResponsivenessReportTests.swift`
- `Native/AmbitionsTests/Domain/FoundationPerformancePersistenceBudgetTests.swift`
- `Native/AmbitionsTests/Domain/EventLedgerModelsTests.swift`
- `Native/AmbitionsTests/Domain/SideEffectLedgerModelsTests.swift`

## Baseline Matrix

| Area | Evidence | Status | Boundary |
|---|---|---:|---|
| Launch-time budget | `ReleasePerformanceResponsivenessReport` app-launch check keeps startup conservative and device proof separate. | Green source/test | No cold-start timing claim |
| Repository query budget | `FoundationPerformancePersistenceBudgetTests` assert receipt summaries and event-ledger recent queries are explicitly bounded. | Green test | No persistent large-store benchmark |
| Runtime projection budget | Performance architecture files define Today, Capture, Time, Widget, and local runtime target budgets with no measured-performance claim. | Green contract | Target only until measured logs exist |
| Local diagnostic export | `DiagnosticLedgerSnapshot` derives deterministic local snapshots from event, side-effect, and privacy classifications. | Green test/source | Local diagnostic model only; no remote export |
| Redacted logging/diagnostics | Event ledger and side-effect ledger models produce deterministic diagnostic entries and support redaction/private summaries. | Green test/source | No private off-device collection |
| Visual/motion budget scan | `scripts/cqs-performance-budget-scan.sh Native/Ambitions` found SwiftUI/render/update hotspots and returned advisory success. | Yellow review | Requires review before any heavy visual/motion claim |
| Private collection absence | Provider scan over this proof slice had no matches; no SDK, network monitor, hosted event collector, or off-device reporting path added. | Green | Existing historical/docs wording is not runtime behavior |

## Validation

- Pre guard: `python3 scripts/ambitions-parallel-implementation-guard.py --phase pre --batch AMB-387 --batch-type guard-repair --prompt /tmp/AMB-387-AFRI-035-guard-prompt.md`
  - Result: Green.
- Performance budget contracts: `python3 scripts/ambitions-performance-budget-check.py`
  - Result: passed.
  - Report: `build/reports/performance-budget.json`
  - Report status: `green`, files checked: 5, issues: 0.
- Static performance scan: `bash scripts/cqs-performance-budget-scan.sh Native/Ambitions`
  - Result: advisory success with `CQS_PERFORMANCE_BUDGET_HITS=1`.
  - Meaning: review hits exist for SwiftUI render/update/background patterns; this is Yellow review evidence, not measured performance proof.
- Focused tests: `xcodebuild test -project Ambitions.xcodeproj -scheme Ambitions -configuration Debug -destination id=8ACCD665-4807-4102-B526-5A1AE20686A8 -only-testing:AmbitionsTests/ReleasePerformanceResponsivenessReportTests -only-testing:AmbitionsTests/FoundationPerformancePersistenceBudgetTests -only-testing:AmbitionsTests/EventLedgerModelsTests -only-testing:AmbitionsTests/SideEffectLedgerModelsTests`
  - Result: `** TEST SUCCEEDED **`
  - Tests: 24 executed, 0 failures.
  - Result bundle: `/Users/devan/Library/Developer/Xcode/DerivedData/Ambitions-clensfmdeeuxsueugpmolbvkzbxq/Logs/Test/Test-Ambitions-2026.05.31_19-31-12--0400.xcresult`

## Local-Only Diagnostics Boundary

- Diagnostics are source-modeled as local ledger entries and snapshots.
- Redaction support exists for event ledger entries and privacy-sensitive summaries.
- Side-effect diagnostics derive from local side-effect records and preserve confirmation/safe-failure boundaries.
- No hosted event-collection SDK, crash reporter, network monitor, or private-data reporting path is added by AFRI-035.

## Release Gate

Release Green remains blocked unless future evidence adds:

- measured launch timing with environment and device/simulator recorded
- measured heavy-surface navigation/render timing
- persistent-store volume benchmark for receipt/history/memory queries
- Instruments, memory graph, or equivalent measurement for memory/performance claims
- device/platform proof for widgets, Live Activities, notifications, shortcuts, and app-group I/O
- explicit human/device release approval where release truth requires it

## Proof Boundaries

Verified:

- Local performance budget contracts exist and validate.
- Focused tests cover release responsiveness report boundaries, bounded query behavior, deterministic diagnostic ledger snapshots, and side-effect diagnostic entries.
- Static scan identifies performance-sensitive SwiftUI/runtime patterns for review.
- This slice adds no private off-device event-collection dependency.

Not verified:

- Release-grade performance.
- Physical-device performance.
- Memory safety.
- Scroll smoothness.
- Battery/thermal behavior.
- Widget/Live Activity platform performance.
- TestFlight/App Store readiness.
- Release readiness.

## Rollback

Revert the AMB-387 commit to remove this proof packet. If future runtime/source changes touch any scan-hit surfaces, rerun the static scan and add measured evidence before making any performance claim.
