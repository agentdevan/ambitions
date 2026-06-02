<!-- AMBITIONS_RUNNER_REQUIRED: true -->
<!-- RUN_WITH: scripts/ambitions-codex-train.sh -->
<!-- DIRECT_CODEX_EXECUTION: forbidden_unless_user_explicitly_bypasses_runner -->

# AESP-024 - Capture-to-structured-action journey

Linear issue: AMB-446
Project: Ambitions Experience Sovereignty Program
Milestone: M05 - Journey-Level Experience Proof

## Required Truth Checks

- `docs/truth/PRODUCT_MOAT_TRUTH.md`
- `docs/truth/IMPLEMENTATION_TRUTH.md`

## Batch Goal

Prove Capture can move from draft to meaningful Ambitions object through route reveal without becoming chat/feed flow.

## Implementation Scope

- `Native/Ambitions/Features/Capture`
- `Native/Ambitions/Domain/CaptureRouteCommandMappingTests`
- `Native/Ambitions/Domain/CaptureModels.swift`
- `Native/AmbitionsTests/Capture/CapturePlacementReviewStateTests.swift`
- `Native/AmbitionsTests/Capture/CaptureViewModelTests.swift`

## Required Product Outcomes

- Route preview remains understandable and reversible.
- Correction and receipt are visible pre-mutation.
- Empty/inapplicable states are explicit.

## Required Evidence Packet

Create: `build/reports/aesp/AESP-024/capture-to-structured-action-journey-evidence.md`

## Required Validation

```bash
xcodegen generate
make xcode-build-for-testing BATCH=AESP-024
make xcode-focused-test BATCH=AESP-024 TEST=AmbitionsTests/Capture/CapturePlacementReviewStateTests
make xcode-focused-test BATCH=AESP-024 TEST=AmbitionsTests/Capture/CaptureViewModelTests
make xcode-focused-test BATCH=AESP-024 TEST=AmbitionsTests
```

