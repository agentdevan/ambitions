<!-- AMBITIONS_RUNNER_REQUIRED: true -->
<!-- RUN_WITH: scripts/ambitions-codex-train.sh -->
<!-- DIRECT_CODEX_EXECUTION: forbidden_unless_user_explicitly_bypasses_runner -->

# AESP-035 - Widget experience system

Linear issue: AMB-457
Project: Ambitions Experience Sovereignty Program
Milestone: M07 - Native Platform Experience Depth

## Required Truth Checks

- `docs/truth/PRODUCT_MOAT_TRUTH.md`
- `docs/truth/IMPLEMENTATION_TRUTH.md`
- `docs/truth/RELEASE_TRUTH.md`

## Runtime Contract Boundary

- Preserve and expose `SourceRecord`, `Receipt`, and `ReplayTrace` continuity for any runtime-affecting change.
- Include explicit `What Ambitions Knows` / You inspection so state transitions remain explainable.

## Batch Goal

Align widget behavior with object grammar, stale/empty states, redaction, tap-through, and accessibility/privacy boundaries.

## Implementation Scope

- `Native/AmbitionsWidgetExtension`
- `Native/Ambitions/ExternalSnapshots/ExternalWidgetProjection.swift`
- `Native/Ambitions/ExternalSnapshots/ExternalSurfaceSnapshotContracts.swift`
- `Native/Ambitions/Services/ExternalActionCommandService.swift`
- `Native/Ambitions/Services/SnapshotRefreshingServices.swift`
- `Native/Ambitions/Runtime/AmbitionsRuntimeServices.swift`
- `Native/Ambitions/Features/Today`
- `Native/AmbitionsTests/App/ExternalWidgetProjectionTests.swift`
- `Native/AmbitionsTests/App/ExternalSurfaceSnapshotTests.swift`
- `Native/AmbitionsTests/App/ExternalSurfaceVerificationChecklistTests.swift`

## Required Product Outcomes

- Widget entries remain deterministic under stale data and partial contracts.
- Sensitive sources remain redacted as configured.
- Tap-through paths preserve source/reasonability and recovery options.

## Required Evidence Packet

Create: `build/reports/aesp/AESP-035/widget-experience-system-evidence.md`

## Required Validation

```bash
xcodegen generate
make xcode-build-for-testing BATCH=AESP-035
make xcode-focused-test BATCH=AESP-035 TEST=AmbitionsTests/App/ExternalWidgetProjectionTests
make xcode-focused-test BATCH=AESP-035 TEST=AmbitionsTests/App/ExternalSurfaceSnapshotTests
make xcode-focused-test BATCH=AESP-035 TEST=AmbitionsTests/App/ExternalSurfaceVerificationChecklistTests
make xcode-focused-test BATCH=AESP-035 TEST=AmbitionsTests
```
