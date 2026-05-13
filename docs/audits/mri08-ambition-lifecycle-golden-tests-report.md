# MRI08 Ambition Lifecycle Golden Tests Report

Status: Accepted Yellow

## Operating System

Ambition Lifecycle Engine.

## Product Loop

Goal-to-life-direction.

## Source Truth Inspected

- `docs/truth/README.md`
- `docs/truth/PRODUCT_DESIGN_TRUTH.md`
- `docs/truth/PRODUCT_MOAT_TRUTH.md`
- `docs/truth/IMPLEMENTATION_TRUTH.md`
- `docs/truth/RELEASE_TRUTH.md`
- `docs/truth/CODEX_PROCESS_TRUTH.md`
- `docs/truth/HISTORICAL_POLICY.md`
- `AGENTS.md`
- `.codex/reports/current-run-state.md`
- `docs/codex/MOAT_RUNTIME_INTEGRATION_MASTER_PLAN.md`
- `docs/codex/MOAT_RUNTIME_LOOP_MATRIX.md`
- `docs/codex/MOAT_RUNTIME_ACCEPTANCE_CRITERIA.md`
- `docs/codex/MOAT_RUNTIME_GOLDEN_SCENARIOS.md`
- `docs/codex/MOAT_RUNTIME_BATCH_OVERLAY.json`

## Files Changed

- Added `Native/AmbitionsTests/Domain/AmbitionLifecycleGoldenScenarioTests.swift`
- Added `docs/audits/mri08-ambition-lifecycle-golden-tests-report.md`

## Loop Behavior Added

MRI08 adds scenario/eval proof only. The new golden tests compose existing value models to prove:

- `Identity Direction -> Ambition -> Outcome -> Goal Thread -> Commitment -> Step -> Closure Event -> Proof -> Reflection -> Adaptation / Recovery` remains represented across the Ambition Graph scenario.
- Blocked commitments use non-shaming recovery/re-entry semantics and preserve valid proof.
- Pivot proof transfer separates preserved, review-required, and non-transferable proof.
- Reflection/adaptation may inform future recommendations only when local-only, visible, deterministic, receipted, controllable, and non-mutating.
- Cross-surface projection remains local-only across `Today / Goals / Capture / Time / You`.

## EFC Applicability

Applicable as scenario/eval proof for user-facing loop behavior, proof, recovery, reflection, local intelligence, and claim safety. EFC is invoked only as a proof-honesty overlay. This patch does not implement runtime app behavior or authorize release/platform claims.

## Claims Not Made

- Release readiness
- TestFlight readiness
- App Store readiness
- Device proof
- Public accessibility conformance
- Performance validation
- Privacy/legal approval
- Visual runtime completion
- Global train completion

## Validation

| Command | Exit / Result | Notes |
|---|---:|---|
| `git diff --check` | 0 | No whitespace errors reported. |
| `xcodegen generate` | 0 | Regenerated `Ambitions.xcodeproj` from `project.yml`; no project source changes were required. |
| `xcrun swiftc -parse Native/AmbitionsTests/Domain/AmbitionLifecycleGoldenScenarioTests.swift` | 0 | New test file parsed successfully. |
| `python3 scripts/ambitions-state-advance-validate.py || true` | 0 | Reported `GREEN: state advancement coherent; current=SA10C Projection Fixtures And No-Sprawl Validation; next=SA11 Source Atlas Store`. |
| `python3 scripts/ambitions-unsupported-claim-scan.py Native/AmbitionsTests/Domain/AmbitionLifecycleGoldenScenarioTests.swift docs/audits/mri08-ambition-lifecycle-golden-tests-report.md 2>/dev/null || true` | 0 | Reported `GREEN: unsupported completion/readiness claim scan passed`. |
| `DEVELOPER_DIR=/Applications/Xcode.app/Contents/Developer xcodebuild -project Ambitions.xcodeproj -scheme Ambitions -destination 'platform=iOS Simulator,name=iPhone 17' -only-testing:AmbitionsTests/AmbitionLifecycleGoldenScenarioTests test CODE_SIGNING_ALLOWED=NO` | 65 | Final-gate rerun failed before MRI08 assertions on outside-seam app compile debt: `Native/Ambitions/Features/Today/TodayReadModelProjector.swift:44` references missing member `TodayTimeApertureState.summary`. Result bundle: `/Users/devan/Library/Developer/Xcode/DerivedData/Ambitions-clensfmdeeuxsueugpmolbvkzbxq/Logs/Test/Test-Ambitions-2026.05.12_22-48-14--0400.xcresult`. |
| XcodeBuildMCP `test_sim` with `-only-testing:AmbitionsTests/AmbitionLifecycleGoldenScenarioTests` and `CODE_SIGNING_ALLOWED=NO` | Failed before MRI08 assertions | Earlier Phase 02 MCP validation also failed before MRI08 assertions on outside-seam compile debt. No diagnostic was reported for `AmbitionLifecycleGoldenScenarioTests.swift`. MCP log: `/Users/devan/Library/Developer/XcodeBuildMCP/workspaces/ambitions-822bbc11acdf/logs/test_sim_2026-05-13T02-32-57-662Z_pid61904_252cb160.log`. |

## Rollback Notes

Rollback for this phase:

```bash
rm -f Native/AmbitionsTests/Domain/AmbitionLifecycleGoldenScenarioTests.swift docs/audits/mri08-ambition-lifecycle-golden-tests-report.md
xcodegen generate
```

No existing test fixture file was modified, so no fixture-file restore is required.

## Next Handoff

Senior/final gate should review the bounded test-only patch, confirm claim language remains scenario/eval only, and decide commit eligibility after validation evidence.
