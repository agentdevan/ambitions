# Ambitions 3.0 F25 Device / Performance / State Restoration / Edge Case QA Report

Date: 2026-05-01

Status: Green

## Scope

F25 reviewed the release train's device, performance, state restoration, and edge-case evidence without making new physical-device claims. The pass focused on cold launch/build evidence, first-run and returning-user paths, empty and dense data posture, permission-denied fallbacks, recovery scenarios, portable restore, external-surface limits, and performance/readiness claim boundaries.

## Evidence Commands

- `xcodebuild test -project Ambitions.xcodeproj -scheme Ambitions -destination 'platform=iOS Simulator,name=iPhone 17' -only-testing:AmbitionsTests/ReleaseDeviceQAReadinessReportTests -only-testing:AmbitionsTests/ReleasePerformanceResponsivenessReportTests -only-testing:AmbitionsTests/FoundationPerformancePersistenceBudgetTests -only-testing:AmbitionsTests/ActivationContractTests -only-testing:AmbitionsTests/PlanFeatureServiceTests -only-testing:AmbitionsTests/TodayViewModelTests -only-testing:AmbitionsTests/DedicatedDevicePrototypeRuntimeTests -only-testing:AmbitionsTests/PortableSnapshotServiceTests`
- `scripts/build-local.sh`

## Validation Results

| Gate | Result | Evidence |
| --- | --- | --- |
| Focused edge/device/performance tests | Pass | 94 selected tests passed with 0 failures. Log: `output/logs/f25-device-performance-tests-20260501-153533.log`. Result bundle: `Test-Ambitions-2026.05.01_15-35-40--0400.xcresult`. |
| Local simulator build | Pass | `scripts/build-local.sh` generated `Ambitions.xcodeproj` and built for `platform=iOS Simulator,name=iPhone 17`. Log: `output/logs/build-local-20260501-153730.log`. |
| Physical-device proof | Not verified | No physical iPhone execution was available in this environment. No device, TestFlight, lock-screen, or platform-rendered external-surface readiness claim is made. |

## Edge-Case Coverage

| Area | Current Evidence | F25 Classification |
| --- | --- | --- |
| Cold launch | Local simulator build passes; release performance report keeps cold-start timing gated on device proof. | Green for simulator/build evidence; physical-device timing unverified. |
| State restoration / returning user | Release device QA report covers returning-user local data paths; portable snapshot tests cover fresh-store restore, merge preservation, malformed package safety, and unsupported schema rejection. | Green for source/simulator evidence. |
| Empty states / no goals | Activation contract tests cover first-run moments and canonical tab empty-state rules without unbuilt export, sync, or planning-engine claims. | Green. |
| Too many goals / dense local state | Foundation performance tests cover bounded projections, receipt summaries, and recent event-ledger queries; release reports keep high-volume physical scrolling unclaimed. | Green for bounded source budgets; device-volume review remains open. |
| 100 captures / large capture pressure | Covered indirectly by bounded projection and portable snapshot evidence; no physical-device large-list scroll proof was run. | Green with limitation documented. |
| Impossible plan / overloaded day | Plan feature tests cover overloaded plan, no recovery margin, believability, recovery, waiting/blocked posture, and suggestion-only reflow. | Green. |
| Vacation / away / disrupted week | Release device QA report includes the recovery-week scenario as source-fixture evidence; Today/Plan tests cover recovery posture. | Green for source/simulator evidence. |
| Low-energy day / day already over | Plan and Today recovery tests cover recovery options, small adjustments, and non-shaming fallback posture. | Green. |
| Blocked / waiting | Plan tests cover blocked and waiting reality reasons plus conflict/recovery boundaries. | Green. |
| Early completion / closure boundaries | Today tests cover Step Session and Close the Loop surfaces without claiming unsupported proof-ledger persistence. | Green. |
| External surfaces | Dedicated-device and release reports verify privacy-safe fallback/source contracts; platform rendering remains device-required. | Green for contract evidence; platform proof unverified. |

## Device And Performance Truth

- Simulator/source evidence is sufficient for F25 Green because all required automated checks passed and the report does not claim physical-device readiness.
- Physical-device smoke remains required before TestFlight or real-device validation can be claimed.
- Large-data responsiveness on real hardware remains unverified.
- Widget gallery, Lock Screen/Dynamic Island lifecycle, Shortcuts/Siri invocation, notification delivery, and app-group I/O remain platform/device proof items.

## F25 Green Criteria

- Build passes: Green.
- Focused edge-case tests/previews pass where available: Green.
- Performance/device claims evidence-labeled: Green.
- No false physical-device claim if no physical-device proof exists: Green.

## Next Gate

F26 App Store / Marketing / Demo Truth may begin. F26 must keep every public claim mapped to implemented, tested, or canon evidence and must not imply TestFlight, App Store, physical-device, accessibility, privacy, ADHD, or release readiness beyond the evidence recorded here and in prior gates.
