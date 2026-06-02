<!-- AMBITIONS_RUNNER_REQUIRED: true -->
<!-- RUN_WITH: scripts/ambitions-codex-train.sh -->
<!-- DIRECT_CODEX_EXECUTION: forbidden_unless_user_explicitly_bypasses_runner -->

# AESP-018 - Living visual causality system

Linear issue: AMB-440
Project: Ambitions Experience Sovereignty Program
Milestone: M04 - Visual System, Motion, and Haptics

## Required Truth Checks

- `docs/truth/PRODUCT_MOAT_TRUTH.md`
- `docs/truth/IMPLEMENTATION_TRUTH.md`
- `docs/truth/RELEASE_TRUTH.md`
- `docs/truth/CODEX_PROCESS_TRUTH.md`

## Constraint Notes

- Visual changes must be causally tied to domain/runtime state.
- No decorative state-only motion.
- Preserve local-first deterministic runtime.

## Runtime Contract Boundary

- Preserve and expose `SourceRecord`, `Receipt`, and `ReplayTrace` continuity for any runtime-affecting change.
- Include explicit `What Ambitions Knows` / You inspection so state transitions remain explainable.

## Batch Goal

Ensure meaningful visual transitions and causal styling come from projection state and object-level runtime conditions.

## Implementation Scope

- `Native/Ambitions/Features/*`
- `Native/Ambitions/UI`
- `Native/Ambitions/App`
- `Native/Ambitions/Support`

## Required Product Outcomes

- A visible state change must map to a known object state.
- No hidden meaning in motion alone.
- Include Reduce Motion equivalents.

## Evidence Packet

Create: `build/reports/aesp/AESP-018/living-visual-causality-evidence.md`

Include source-to-visual mapping and where evidence is pending.

## Required Validation

```bash
xcodegen generate
make xcode-build-for-testing BATCH=AESP-018
make xcode-focused-test BATCH=AESP-018 TEST=AmbitionsTests/App/SignatureInterfaceVisualQAFixtureTests
make xcode-focused-test BATCH=AESP-018 TEST=AmbitionsTests/App/PanelDensitySizeDesignSystemTests
make xcode-focused-test BATCH=AESP-018 TEST=AmbitionsTests
```

