<!-- AMBITIONS_RUNNER_REQUIRED: true -->
<!-- RUN_WITH: scripts/ambitions-codex-train.sh -->
<!-- DIRECT_CODEX_EXECUTION: forbidden_unless_user_explicitly_bypasses_runner -->

# AESP-015 - Time / LifeShape Field Experience Elevation

Linear issue: AMB-437
Project: Ambitions Experience Sovereignty Program
Milestone: M03 - Surface-by-Surface Experience Elevation

## Source-Truth Entry

Before editing, inspect the active Ambitions truth files in the AGENTS.md order:

1. `docs/truth/README.md`
2. `docs/truth/PRODUCT_DESIGN_TRUTH.md`
3. `docs/truth/PRODUCT_MOAT_TRUTH.md`
4. `docs/truth/IMPLEMENTATION_TRUTH.md`
5. `docs/truth/RELEASE_TRUTH.md`
6. `docs/truth/CODEX_PROCESS_TRUTH.md`
7. `docs/truth/HISTORICAL_POLICY.md`
8. `AGENTS.md`
9. relevant Time source, tests, evidence, scripts, and status docs

Active canon constraints:

- Top-level IA remains exactly `Today / Goals / Capture / Time / You`.
- The fourth tab is `Time`; `Plan` is not a user-facing top-level destination.
- Time primary object is `LifeShape Field`.
- Time must show what the user's life can actually hold across planning horizons.
- Time must not become a calendar grid, agenda clone, schedule control board, KPI tile surface, heatmap-first analytics page, business chart, productivity rating, or red-warning system.
- Calendar may support Time, but Calendar must not define Time.
- Use `step`, not `move`, for action items.
- Do not introduce cloud AI, hosted inference, backend, analytics, tracking SDKs, paid services, or server dependencies.
- Preserve local-first deterministic Private Life Runtime posture.
- No release, accessibility, performance, privacy, device, App Store, TestFlight, or CI claims without matching evidence.

## Champion Merge Source Boundary

- AESP-015 is a scoped owner-review elevation of the existing canonical Time/LifeShape owner.
- Extend existing `Native/Ambitions/Features/Time/` owners; do not create a parallel Time, Plan, Calendar, schedule, or analytics implementation.
- Internal `plan` compatibility seams may remain only where source truth requires them; do not surface `Plan` as top-level user-facing IA.
- Preserve existing `SourceRecord`, `Receipt`, `ReplayTrace`, and You / What Ambitions knows inspection requirements for any touched runtime-affecting path.
- Do not touch persistence schema, entitlements, privacy manifest, backend, analytics, cloud AI, hosted CI, signing, App Store, or telemetry owners.
- No-claim boundary: this batch can claim only local source/test evidence for scoped Time feature elevation.
- Follow-up gate: screenshots, manual accessibility audit, device validation, performance validation, release validation, CI validation, and legal/privacy signoff remain unclaimed unless actually produced.
- Affected canonical owner: `time_lifeshape`.

## Batch Goal

Implement AESP-015 fully enough for Green local source/test/evidence status:

Elevate Time / LifeShape Field so the surface reads as a premium native capacity field that explains what the week can hold, what is protected, what is pressurized, what source state is available, and what reflow can be previewed without silent mutation. The user should understand capacity and planning truth without Time feeling like a calendar clone, agenda, generic control board, KPI surface, or productivity rating.

## Implementation Scope

Use existing owners unless Phase 01 proves a narrower or adjacent owner is required:

- `Native/Ambitions/Features/Time/TimeScreen.swift`
- `Native/Ambitions/Features/Time/TimeLifeShapeField.swift`
- `Native/Ambitions/Features/Time/TimeFeatureModels.swift`
- `Native/Ambitions/Features/Time/TimeFeatureService.swift`
- `Native/Ambitions/Features/Time/TimeFeatureSnapshot.swift`
- `Native/Ambitions/Features/Time/TimeFoundationCards.swift`
- `Native/Ambitions/Features/Time/TimeLifeShapeDrillDownPanel.swift`
- `Native/Ambitions/Features/Time/TimeCalendarAwarenessSupport.swift`
- `Native/Ambitions/Features/Time/TimeReflowDecisionState.swift`
- `Native/Ambitions/Features/Time/TimeReflowDecisionCard.swift`
- `Native/AmbitionsTests/Time/TimeFeatureServiceTests.swift`

Do not create parallel implementation surfaces. Do not add a new app route, tab, package dependency, service dependency, backend, AI dependency, or telemetry dependency.

## Required Product Outcomes

The completed slice must demonstrate:

- Week-default LifeShape Field as the primary Time object.
- Day / Week / Month scope language that reads as capacity truth, not calendar navigation sprawl.
- Clear open time, goal time, protected time, pressure, source state, and capacity truth.
- Reflow preview that explains before changing and does not imply silent mutation.
- Source unavailable, calendar denied/granted, manual-only planning, low capacity, protected block, pressure cluster, empty plan, and error/loading states remain honest where already source-backed.
- Copy and state labels aligned with Ambitions canon: quiet luxury, trust, calm language, no shame, no urgency theater, no productivity rating.
- Accessibility-aware structure: VoiceOver order, Dynamic Type resilience, non-color state meaning, and Reduce Motion compatibility considered in source and evidence boundaries.
- Visual/product quality consistent with native premium iPhone expectations, not a calendar clone, agenda, control board, heatmap, or business chart.

## Required Tests / Coverage

Add or update focused tests that prove the behavioral shape of the Time elevation. Prefer existing test owners:

- `Native/AmbitionsTests/Time/TimeFeatureServiceTests.swift`
- existing app shell/navigation tests only if required for Time tab language

At minimum, cover:

- Time remains centered on `LifeShape Field`, not calendar clone / agenda / control-board / productivity-rating language.
- Week-default capacity language exposes open time, goal time, protected time, pressure, and source state.
- Reflow preview remains inspectable and does not claim silent mutation or calendar writes.
- Manual-only / calendar unavailable source states remain understandable and local-first.
- Accessibility value/hint text carries the same nonvisual meaning as the visual LifeShape object.
- Existing Time feature behavior remains compatible.

## Required Evidence Packet

Create or update:

`build/reports/aesp/AESP-015/time-lifeshape-field-evidence.md`

The evidence packet must include:

- Linear issue and commit placeholder until commit exists.
- Source files changed and why each was touched.
- Source mapping from Time product outcomes to implementation owners.
- Tests added/updated and exact local validation commands.
- Verified/Not verified/Blocked/Human follow-up sections.
- Explicit statement that screenshots, physical device validation, release validation, TestFlight/App Store validation, legal/privacy signoff, performance proof, manual accessibility audit, and CI validation are not claimed unless actually produced.
- Dirty-worktree preservation notes for unrelated pre-existing files.

## Required Validation

Run current local validation and repair until Green or a truth-file hard stop is hit:

```bash
python3 scripts/ambitions-champion-coverage-check.py --batch AESP-015
python3 scripts/ambitions-parallel-implementation-guard.py --phase pre --batch AESP-015 --prompt prompts/batches/AESP-015.md --batch-type source-changing --allow-yellow
xcodegen generate
make xcode-build-for-testing BATCH=AESP-015
make xcode-focused-test BATCH=AESP-015 TEST=AmbitionsTests/TimeFeatureServiceTests
make xcode-focused-test BATCH=AESP-015 TEST=AmbitionsTests/AppShellNavigationTests
make xcode-focused-test BATCH=AESP-015 TEST=AmbitionsTests
python3 scripts/ambitions-parallel-implementation-guard.py --phase post --batch AESP-015 --prompt prompts/batches/AESP-015.md --changed-from e3a1879c3cad1ef549ecfbce1bbe33393891b47b --batch-type source-changing --allow-yellow
git diff --check
```

If a focused test identifier is stale, discover the current test symbol with `rg` and use the nearest current focused Time/AppShell lane. Record any substitution in the evidence packet and Linear closeout.

## Linear Update Requirements

Keep AMB-437 updated with:

- Start state and dirty-worktree boundary.
- Runner status.
- Repair findings if a repair cycle is needed.
- Final source/test/evidence summary.
- Commit SHA when committed.

Only mark AMB-437 Done after local Green evidence and commit are both complete.
