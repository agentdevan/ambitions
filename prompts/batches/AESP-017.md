<!-- AMBITIONS_RUNNER_REQUIRED: true -->
<!-- RUN_WITH: scripts/ambitions-codex-train.sh -->
<!-- DIRECT_CODEX_EXECUTION: forbidden_unless_user_explicitly_bypasses_runner -->

# AESP-017 - Semantic visual token system

Linear issue: AMB-439
Project: Ambitions Experience Sovereignty Program
Milestone: M04 - Visual System, Motion, and Haptics

## Required Truth Checks

Inspect:

- `docs/truth/PRODUCT_MOAT_TRUTH.md`
- `docs/truth/IMPLEMENTATION_TRUTH.md`
- `docs/truth/RELEASE_TRUTH.md`
- `docs/truth/CODEX_PROCESS_TRUTH.md`
- `Native/Ambitions/UI`, `Native/Ambitions/App`, `Native/Ambitions/Features`
- AGENTS.md

## Constraint Notes

- Token system must be semantic-first: meaning stays readable when colors are weakened or absent.
- Do not ship ornamental color-only state semantics.
- Do not introduce cloud analytics, trackers, or runtime dependence outside local-first scope.

## Batch Goal

Align semantic visual tokens to runtime meaning across features so they reinforce source-freshness, pressure, blocked, recovery, and completion semantics.

## Implementation Scope

- `Native/Ambitions/UI/AppCanvasView.swift`
- `Native/Ambitions/Features/*` token/state usage surfaces
- `Native/Ambitions/Support` or `Native/Ambitions/PreviewSupport` token fixtures
- `Native/AmbitionsTests/App/IconographyStatusDesignSystemTests.swift`
- `Native/AmbitionsTests/App/PanelDensitySizeDesignSystemTests.swift`

## Required Product Outcomes

- Source meaning is recoverable from token labels and pairings.
- State legibility survives reduced contrast/visibility conditions.
- Accessibility meaning remains parallel to visual style.

## Evidence Packet

Create or update:

`build/reports/aesp/AESP-017/semantic-visual-token-evidence.md`

Include command matrix, state-state mapping, accessibility/cognitive scan, screenshot status, and no-claim boundary.

## Required Validation

```bash
xcodegen generate
make xcode-build-for-testing BATCH=AESP-017
make xcode-focused-test BATCH=AESP-017 TEST=AmbitionsTests/App/IconographyStatusDesignSystemTests
make xcode-focused-test BATCH=AESP-017 TEST=AmbitionsTests/App/PanelDensitySizeDesignSystemTests
make xcode-focused-test BATCH=AESP-017 TEST=AmbitionsTests
```

## Linear Update Requirements

Track AMB-439 runner state, repair notes, test outcomes, and final commit SHA in issue updates.

