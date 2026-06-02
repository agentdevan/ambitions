<!-- AMBITIONS_RUNNER_REQUIRED: true -->
<!-- RUN_WITH: scripts/ambitions-codex-train.sh -->
<!-- DIRECT_CODEX_EXECUTION: forbidden_unless_user_explicitly_bypasses_runner -->

# AESP-040 - Frontend performance budget

Linear issue: AMB-462
Project: Ambitions Experience Sovereignty Program
Milestone: M08 - Frontend Proof, Screenshot Diffing, and Release Authority

## Required Truth Checks

- `docs/truth/PRODUCT_MOAT_TRUTH.md`
- `docs/truth/IMPLEMENTATION_TRUTH.md`
- `docs/truth/RELEASE_TRUTH.md`

## Runtime Contract Boundary

- Preserve and expose `SourceRecord`, `Receipt`, and `ReplayTrace` continuity for any runtime-affecting change.
- Include explicit `What Ambitions Knows` / You inspection so state transitions remain explainable.

## Batch Goal

Define and measure frontend performance thresholds for launch, interaction latency, animation smoothness, memory behavior, and fallback degradation.

## Implementation Scope

- `Native/Ambitions/Features`
- `Native/Ambitions/UI`
- `Native/Ambitions/App`
- `Native/Ambitions/Tests` (performance-critical instrumentation points)
- `scripts/cqs-performance-budget-scan.sh`
- `scripts/cqs-visual-performance-risk-scan.sh`
- `scripts/ambitions-performance-budget-check.py`
- `Native/AmbitionsTests/App/ReleasePerformanceResponsivenessReportTests.swift`
- `Native/AmbitionsTests/App/AppShellNavigationTests.swift`

## Required Product Outcomes

- Launch and interaction budgets are established and measured.
- Regressions are visible through baseline-aware checks.
- Degradation behavior under load is preserved and user-safe.

## Required Evidence Packet

Create: `build/reports/aesp/AESP-040/frontend-performance-budget-evidence.md`

## Required Validation

```bash
xcodegen generate
make xcode-build-for-testing BATCH=AESP-040
make xcode-focused-test BATCH=AESP-040 TEST=AmbitionsTests/App/ReleasePerformanceResponsivenessReportTests
make xcode-focused-test BATCH=AESP-040 TEST=AmbitionsTests/App/AppShellNavigationTests
./scripts/cqs-performance-budget-scan.sh
./scripts/ambitions-performance-budget-check.py
```
