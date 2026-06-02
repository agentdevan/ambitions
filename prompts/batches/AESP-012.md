<!-- AMBITIONS_RUNNER_REQUIRED: true -->
<!-- RUN_WITH: scripts/ambitions-codex-train.sh -->
<!-- DIRECT_CODEX_EXECUTION: forbidden_unless_user_explicitly_bypasses_runner -->

# AESP-012 - Today / Reality Meridian Experience Elevation

Linear issue: AMB-434
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
- relevant Today source, previews, tests, and proof artifacts

Confirm AESP-000 through AESP-011 are complete as Linear control-plane definitions before source edits. Do not treat those control-plane definitions as implementation proof.

## Purpose

Implement the first source-bearing AESP slice: elevate Today around Reality Meridian and Start Here as the flagship daily decision object, not a task list, generic card stack, or detached recommendation panel.

## Product And Architecture Boundaries

- Preserve canonical IA: `Today / Goals / Capture / Time / You`.
- Preserve Today primary objects: Reality Meridian and Start Here.
- Extend the existing Today owners rather than creating a parallel Today implementation.
- Preserve local-first deterministic behavior; do not add cloud AI, hosted inference, analytics, backend accounts, hosted planning runtime, or telemetry-driven intelligence.
- SwiftUI must render compiled local runtime/projection state; it must not fabricate intelligence.
- Preserve SourceRecord, Receipt, ReplayTrace, and You / What Ambitions Knows inspection requirements for touched runtime paths.
- Use locked language: `Start here`, `Recommended step`, `step`, `Start now`, `Open step`, `Still counts`, `Receipt`, `Source`, `Why this?`.
- Do not introduce superseded recommendation phrases, focus-session labels, top-level `Plan`, shame language, pressure metrics, chatbot framing, or generic admin/productivity framing.
- Do not change app routes, tab raw values, persistence schema, entitlement/signing, dependency graph, hosted CI, or release configuration unless this prompt explicitly requires it. It does not.

## Implementation Scope

Implement the smallest source-backed Today elevation that satisfies AMB-434:

1. Strengthen `RealityMeridianView` / Today root composition so Start Here is visibly and semantically integrated with Reality Meridian rather than reading as a detached task card.
2. Add or refine state fixtures for Today happy, source-stale, blocked/waiting, recovery, low-confidence, and private/redacted states.
3. Ensure the Start Here surface exposes reason/source/proof/receipt/replay inspection lines and user correction/optionality paths without silent mutation.
4. Ensure Dynamic Type keeps the primary object, primary action, trust path, and closure/recovery path reachable without overlap.
5. Ensure Reduce Motion has a static semantic equivalent for any motion-dependent relationship.
6. Add focused tests or snapshots for the new Today state/projection behavior where feasible.
7. Create a current proof packet under `build/reports/aesp/AESP-012/` summarizing changed files, validation, accessibility/visual status, non-claims, Yellow items, and rollback.

Prefer these existing owners:

- `Native/Ambitions/Features/Today/TodayScreen.swift`
- `Native/Ambitions/Features/Today/TodayDayRailPanels.swift`
- `Native/Ambitions/Features/Today/TodayStartHereSurface.swift`
- `Native/Ambitions/Features/Today/DayRailViewState.swift`
- `Native/Ambitions/Features/Today/TodayExecutionProjector.swift`
- `Native/AmbitionsTests/`

## Acceptance Gates

- Today remains built around Reality Meridian / Start Here, not a task list or card pile.
- Start Here stays tied to the active Reality Meridian state and exposes source, reason, proof, receipt, replay/inspection, and correction/optionality controls.
- Non-happy states are represented: stale/source unavailable, blocked/waiting, recovery, low-confidence, private/redacted, and empty/manual fallback where relevant.
- Dynamic Type and Reduce Motion behavior are explicitly considered in source or proof.
- No top-level IA drift, no hosted/cloud dependency, no privacy/trust regression, and no proofless release/accessibility/performance/device claims.

## Validation Commands

Run the tightest relevant commands first, then repair non-Green results:

```bash
xcodegen generate
make xcode-build-for-testing
make xcode-focused-test BATCH=AESP-012 TEST=AmbitionsTests
```

If the broad `AmbitionsTests` lane is too slow or unavailable, run focused Today/source tests and record broader validation as Yellow, not Green.

## Required Proof Artifacts

Create or update:

- `build/reports/aesp/AESP-012/today-reality-meridian-evidence.md`

The artifact must include branch, commit if available, date/time, exact validation commands, command result state, accessibility status, Dynamic Type status, Reduce Motion status, visual/screenshot status, known Yellow items, rollback notes, and non-claims.

## Green / Yellow / Red Expectations

Green: source-backed Today elevation, focused validation passes, proof packet exists, and all acceptance gates are satisfied without overclaiming.

Yellow: source/proof improves Today but screenshot/device/manual accessibility/broad validation is incomplete, with owner, safety reason, no-claim boundary, and follow-up gate.

Red: generic task/card-surface drift, detached Start Here, hidden/silent mutation, source/reason/receipt regression, accessibility regression, cloud/backend dependency, top-level IA drift, or release/accessibility/performance/device overclaim.

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
- Linear issue status recommendation for AMB-434
