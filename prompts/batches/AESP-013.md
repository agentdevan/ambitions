<!-- AMBITIONS_RUNNER_REQUIRED: true -->
<!-- RUN_WITH: scripts/ambitions-codex-train.sh -->
<!-- DIRECT_CODEX_EXECUTION: forbidden_unless_user_explicitly_bypasses_runner -->

# AESP-013 - Goals / Constellation Atlas Experience Elevation

Linear issue: AMB-435
Linear project: Ambitions Experience Sovereignty Program
Milestone: M03 - Surface-by-Surface Experience Elevation

## Required Truth And Predecessor Checks

Read these before editing:

- `docs/truth/README.md`
- `docs/truth/PRODUCT_DESIGN_TRUTH.md`
- `docs/truth/PRODUCT_MOAT_TRUTH.md`
- `docs/truth/IMPLEMENTATION_TRUTH.md`
- `docs/truth/RELEASE_TRUTH.md`
- `docs/truth/CODEX_PROCESS_TRUTH.md`
- `docs/truth/HISTORICAL_POLICY.md`
- `AGENTS.md`
- `README.md`
- `docs/README.md`
- `project.yml`
- `Package.swift`
- relevant Goals source, previews, tests, and proof artifacts

Confirm AESP-012 is implemented and committed before source edits. Treat AESP-000 through AESP-011 as completed control-plane definitions, not implementation proof.

## Purpose

Implement the Goals / Constellation Atlas experience elevation so Goals feels like an object-first directional portfolio and proof-continuity surface, not an operations panel, ranked numeric board, generic project list, or admin console.

## Product And Architecture Boundaries

- Preserve canonical IA: `Today / Goals / Capture / Time / You`.
- Preserve Goals primary object: Constellation Atlas.
- Extend existing Goals owners; do not create a parallel Goals implementation.
- Preserve local-first deterministic behavior; do not add cloud AI, hosted inference, analytics, backend accounts, hosted planning runtime, or telemetry-driven intelligence.
- SwiftUI must render compiled local runtime/projection state; it must not fabricate intelligence.
- Preserve SourceRecord, Receipt, ReplayTrace, proof, and You / What Ambitions Knows inspection requirements for touched runtime paths.
- Do not introduce numeric pressure, ranked productivity language, shame, streaks, generic KPI tiles, generic project-list hierarchy, chatbot framing, or top-level `Plan`.
- Do not change app routes, tab raw values, persistence schema, entitlement/signing, dependency graph, hosted CI, or release configuration unless this prompt explicitly requires it. It does not.

## Implementation Scope

Implement the smallest source-backed Goals elevation that satisfies AMB-435:

1. Strengthen Goals / Constellation Atlas composition so the surface reads as equal-weight directional portfolio, proof continuity, and life-area context rather than a list of ranked tasks or KPI tiles.
2. Add or refine state fixtures for active direction, pressured/crowded, stalled, blocked/waiting, protected, archived/completed, and low-proof states.
3. Ensure Atlas cards expose reason/source/proof/receipt/replay or inspection lines where source-backed evidence exists, and clearly admit when proof is thin or unavailable.
4. Ensure priority/order language does not become numeric pressure; use direction, continuity, proof, and review language instead.
5. Ensure Dynamic Type keeps the atlas object, primary action, proof path, and recovery/review path reachable without overlap.
6. Ensure Reduce Motion has a static semantic equivalent for any motion-dependent relationship.
7. Add focused tests or snapshots for the new Goals state/projection behavior where feasible.
8. Create a current proof packet under `build/reports/aesp/AESP-013/` summarizing changed files, validation, accessibility/visual status, non-claims, Yellow items, and rollback.

Prefer these existing owners:

- `Native/Ambitions/Features/Goals/GoalsScreen.swift`
- `Native/Ambitions/Features/Goals/GoalsOverviewProjector.swift`
- `Native/Ambitions/Features/Goals/GoalsOverviewBoardProjection.swift`
- `Native/Ambitions/Features/Goals/GoalsFeatureService.swift`
- `Native/Ambitions/Features/Goals/GoalsFeatureModels.swift`
- `Native/Ambitions/Features/Goals/GoalComponents.swift`
- `Native/Ambitions/Features/Goals/GoalMissionControlLanePrimitives.swift`
- `Native/Ambitions/Features/Goals/GoalLifePathSignaturePrimitives.swift`
- `Native/AmbitionsTests/Goals/`

## Acceptance Gates

- Goals remains built around Constellation Atlas and Mission Control, not a generic operations panel or task list.
- Atlas states preserve equal-weight direction, proof continuity, life-area context, and review paths without productivity scoring.
- Non-happy states are represented: pressured/crowded, stalled, blocked/waiting, protected, archived/completed, low-proof, and empty/manual fallback where relevant.
- Dynamic Type and Reduce Motion behavior are explicitly considered in source or proof.
- No top-level IA drift, no hosted/cloud dependency, no privacy/trust regression, and no proofless release/accessibility/performance/device claims.

## Validation Commands

Run the tightest relevant commands first, then repair non-Green results:

```bash
xcodegen generate
make xcode-build-for-testing BATCH=AESP-013
make xcode-focused-test BATCH=AESP-013 TEST=AmbitionsTests/GoalsOverviewAtlasTests
make xcode-focused-test BATCH=AESP-013 TEST=AmbitionsTests/GoalsShellIntegrationTests
make xcode-focused-test BATCH=AESP-013 TEST=AmbitionsTests
```

If the broad `AmbitionsTests` lane is too slow or unavailable, run focused Goals/source tests and record broader validation as Yellow, not Green.

## Required Proof Artifacts

Create or update:

- `build/reports/aesp/AESP-013/goals-constellation-atlas-evidence.md`

The artifact must include branch, commit if available, date/time, exact validation commands, command result state, accessibility status, Dynamic Type status, Reduce Motion status, visual/screenshot status, known Yellow items, rollback notes, and non-claims.

## Green / Yellow / Red Expectations

Green: source-backed Goals elevation, focused and broad validation pass, proof packet exists, and all acceptance gates are satisfied without overclaiming.

Yellow: source/proof improves Goals but screenshot/device/manual accessibility/broad validation is incomplete, with owner, safety reason, no-claim boundary, and follow-up gate.

Red: generic operations-panel/list drift, hidden numeric pressure, detached proof paths, source/reason/receipt regression, accessibility regression, cloud/backend dependency, top-level IA drift, or release/accessibility/performance/device overclaim.

## Closeout Requirements

Closeout must include:

- Files changed
- Why the change was needed
- Truth files inspected
- Validation run and exact commands
- Validation not run and why
- Champion coverage and parallel guard status/report paths
- Proof/claim boundaries
- Risks or Yellow items
- Rollback notes
- Linear issue status recommendation for AMB-435
