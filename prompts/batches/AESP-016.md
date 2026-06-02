<!-- AMBITIONS_RUNNER_REQUIRED: true -->
<!-- RUN_WITH: scripts/ambitions-codex-train.sh -->
<!-- DIRECT_CODEX_EXECUTION: forbidden_unless_user_explicitly_bypasses_runner -->

# AESP-016 - You / User System Profile experience elevation

Linear issue: AMB-438
Project: Ambitions Experience Sovereignty Program
Milestone: M03 - Surface-by-Surface Experience Elevation

## Required Truth And Predecessor Checks

Before editing, inspect:

- `docs/truth/README.md`
- `docs/truth/PRODUCT_DESIGN_TRUTH.md`
- `docs/truth/PRODUCT_MOAT_TRUTH.md`
- `docs/truth/IMPLEMENTATION_TRUTH.md`
- `docs/truth/RELEASE_TRUTH.md`
- `docs/truth/CODEX_PROCESS_TRUTH.md`
- `docs/truth/HISTORICAL_POLICY.md`
- `AGENTS.md`
- `Native/Ambitions/Features/You` and companion files before touching runtime

Confirm prior work status before scope expansion: AESP-000 through AESP-015 foundations/elevations must be treated as control-plane or implemented basis; this batch is an owner-growth surface implementation slice.

## AESP-Specific Constraint Notes

- You / User System Profile must be a Settings-style iOS quality surface:
  - Local trust center
  - planning defaults
  - learning/correction history
  - reset/delete and forget controls
  - receipts/history visibility
  - source/freshness posture reminders
- Do **not** make You a settings copy of OS admin tooling.
- Preserve local-first determinism, SourceRecord/Receipt/ReplayTrace contracts, and privacy-first controls.
- Do **not** add backend/cloud AI, hosted inference, analytics, or scoreboard language.

## Champion Merge Source Boundary

Affected canonical owner: `you_profile`.

- Extend existing You owner files only; do not create parallel You implementations.
- No persistence schema changes, entitlements, runtime architecture replacement, backend account/service changes, or release/configuration claims.
- No-claim boundary: this batch can only claim current source/test/evidence for You UI and profile-readiness gates.

## Batch Goal

Elevate the You surface to behave like a premium local settings-style profile that makes trust and correction controls understandable and source-aware without becoming social/admin profile drift.

## Implementation Scope

- `Native/Ambitions/Features/You/YouScreen.swift`
- `Native/Ambitions/Features/You/YouRootSurface.swift`
- `Native/Ambitions/Features/You/YouViewModel.swift`
- `Native/Ambitions/Features/You/YouFeatureService.swift`
- `Native/Ambitions/Features/You/YouCrossSurfaceProofReviewCard.swift`
- `Native/Ambitions/Features/You/YouTrustHistoryCenterCard.swift`
- `Native/Ambitions/Features/You/YouTrustHistoryProjector.swift`
- `Native/Ambitions/Features/You/YouPlanningDefaultsSectionCard.swift`
- `Native/Ambitions/Features/You/YouAvailabilityCenterCard.swift`
- `Native/Ambitions/Tests/You/YouFeatureServiceTests.swift` if present

## Required Product Outcomes

- Grouped profile structure with a clear trust/reason/recovery/restart posture.
- Local controls for reset/delete/forget and automation boundaries remain explicit and non-destructive.
- Learning/correction history visible as local trust intelligence, not raw user-scanning behavior.
- Source availability states (fresh/unavailable/private/denied) are explicit and honest.
- Copy stays calm, local-first, no score language, no shame framing.

## Required Tests / Coverage

- `Native/AmbitionsTests/You/YouFeatureServiceTests.swift`
- Add/adjust focused assertions in `Native/AmbitionsTests/App/GroupedNavigationListDesignSystemTests.swift` and `Native/AmbitionsTests/App/TrustReceiptLayerDesignSystemTests.swift` if they touch You-owned copy/state.

## Required Evidence Packet

Create or update:

`build/reports/aesp/AESP-016/you-system-profile-evidence.md`

Must include:

- Linear issue and commit placeholder until commit exists
- Scope map to changed source files
- Verified/Not verified/Blocked/Human follow-up
- Accessibility summary and accessibility caveats
- Screenshot/rendering evidence and why it is pending if not captured
- Exact validation commands and non-claim boundaries

## Required Validation

```bash
python3 scripts/ambitions-champion-coverage-check.py --batch AESP-016
python3 scripts/ambitions-parallel-implementation-guard.py --phase pre --batch AESP-016 --prompt prompts/batches/AESP-016.md --batch-type source-changing --allow-yellow
xcodegen generate
make xcode-build-for-testing BATCH=AESP-016
make xcode-focused-test BATCH=AESP-016 TEST=AmbitionsTests/YouFeatureServiceTests
make xcode-focused-test BATCH=AESP-016 TEST=AmbitionsTests
python3 scripts/ambitions-parallel-implementation-guard.py --phase post --batch AESP-016 --prompt prompts/batches/AESP-016.md --changed-from "$(git rev-parse HEAD)" --batch-type source-changing --allow-yellow
git diff --check
```

## Linear Update Requirements

Keep AMB-438 updated with:

- Start state and dirty boundary
- Runner status and repair findings
- Focused evidence and test result matrix
- Commit SHA once committed

