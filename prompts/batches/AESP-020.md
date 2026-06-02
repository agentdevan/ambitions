<!-- AMBITIONS_RUNNER_REQUIRED: true -->
<!-- RUN_WITH: scripts/ambitions-codex-train.sh -->
<!-- DIRECT_CODEX_EXECUTION: forbidden_unless_user_explicitly_bypasses_runner -->

# AESP-020 - Haptic grammar

Linear issue: AMB-442
Project: Ambitions Experience Sovereignty Program
Milestone: M04 - Visual System, Motion, and Haptics

## Required Truth Checks

- `docs/truth/PRODUCT_MOAT_TRUTH.md`
- `docs/truth/IMPLEMENTATION_TRUTH.md`
- `docs/truth/RELEASE_TRUTH.md`
- `docs/truth/CODEX_PROCESS_TRUTH.md`

## Constraint Notes

- Haptics must support state transitions, not replace visibility, language, or receipts.
- No silent mutation and no platform lock-in dependency changes.

## Runtime Contract Boundary

- Preserve and expose `SourceRecord`, `Receipt`, and `ReplayTrace` continuity for any runtime-affecting change.
- Include explicit `What Ambitions Knows` / You inspection so state transitions remain explainable.

## Batch Goal

Define and verify a consistent haptic profile for commit, confirmation, error, and boundary behaviors with non-haptic alternatives documented.

## Implementation Scope

- `Native/Ambitions/App`
- `Native/Ambitions/Features/*`
- `Native/Ambitions/Tests`

## Required Product Outcomes

- Confirm haptic events for key interactions only.
- Provide visual/state alternatives for every confirmatory action.
- Keep haptics as enhancement, never primary communication.

## Evidence Packet

Create: `build/reports/aesp/AESP-020/haptic-grammar-evidence.md`

## Required Validation

```bash
xcodegen generate
make xcode-build-for-testing BATCH=AESP-020
make xcode-focused-test BATCH=AESP-020 TEST=AmbitionsTests/App/InteractionMotionHapticsDesignSystemTests
make xcode-focused-test BATCH=AESP-020 TEST=AmbitionsTests/App/AppShellNavigationTests
make xcode-focused-test BATCH=AESP-020 TEST=AmbitionsTests
```

