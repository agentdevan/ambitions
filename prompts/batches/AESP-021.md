<!-- AMBITIONS_RUNNER_REQUIRED: true -->
<!-- RUN_WITH: scripts/ambitions-codex-train.sh -->
<!-- DIRECT_CODEX_EXECUTION: forbidden_unless_user_explicitly_bypasses_runner -->

# AESP-021 - Premium iPhone compositing pass

Linear issue: AMB-443
Project: Ambitions Experience Sovereignty Program
Milestone: M04 - Visual System, Motion, and Haptics

## Required Truth Checks

- `docs/truth/PRODUCT_DESIGN_TRUTH.md`
- `docs/truth/IMPLEMENTATION_TRUTH.md`
- `docs/truth/CODEX_PROCESS_TRUTH.md`

## Constraint Notes

- Preserve local runtime projection fidelity.
- Avoid decoration-only premium treatment.
- Keep compositing bounded to object/value emphasis and not to fake activity.

## Batch Goal

Raise surface polish to premium native iPhone quality where state layers and transitions benefit inspection and trust.

## Implementation Scope

- `Native/Ambitions/UI/AppCanvasView.swift`
- `Native/Ambitions/Features/*`
- `Native/Ambitions/App/AppShellView.swift`
- `Native/AmbitionsTests/App/LiquidGlassTokenLayerTests.swift`

## Product Outcomes

- Native iOS visual quality increases without obscuring state semantics.
- Performance-conscious defaults preserved.
- No hidden mutation indicators disguised as polish.

## Evidence Packet

Create: `build/reports/aesp/AESP-021/premium-compositing-evidence.md`

## Required Validation

```bash
xcodegen generate
make xcode-build-for-testing BATCH=AESP-021
make xcode-focused-test BATCH=AESP-021 TEST=AmbitionsTests/App/LiquidGlassTokenLayerTests
make xcode-focused-test BATCH=AESP-021 TEST=AmbitionsTests/App/AppShellNavigationTests
make xcode-focused-test BATCH=AESP-021 TEST=AmbitionsTests
```

