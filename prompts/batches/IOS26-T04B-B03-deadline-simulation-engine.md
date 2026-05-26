<!-- AMBITIONS_RUNNER_REQUIRED: true -->
<!-- RUN_WITH: scripts/ambitions-codex-train.sh -->
<!-- DIRECT_CODEX_EXECUTION: forbidden_unless_user_explicitly_bypasses_runner -->
# IOS26-T04B-B03 - Sealed IOS26 Work Order

## Batch ID
`IOS26-T04B-B03`

## Train ID and title
`TRAIN_04B` - Step Optionality, Rejection Replanning & Simulation Proof

## Batch role in train
Batch 3 of 6 in TRAIN_04B

## Upstream dependencies
- `TRAIN_03`
- `TRAIN_04`
- `TRAIN_04A`

## Downstream dependencies
- `TRAIN_04C`
- `TRAIN_04D`
- `TRAIN_04E`
- `TRAIN_05`
- `TRAIN_06`
- `TRAIN_07`
- `TRAIN_10`

## Objective
Simulate each alternative against the same goal and deadline.

## Product/canon constraints
- Active top-level IA remains `Today / Goals / Capture / Time / You`.
- Use `Start here`, `Recommended step`, `step`, `Start now`, and `Open step` where user-facing language is touched.
- Do not reintroduce `Plan` as a user-facing top-level destination.
- Do not convert Ambitions into a task app, calendar clone, habit tracker, status board, chatbot, AI wrapper, SaaS admin panel, or ranking-based productivity framing.

## Local-first/privacy constraints
Simulation must run locally from user-owned data. Protected time, capacity, health/safety, and emotional readiness context must not leak into logs.

## Accessibility constraints
Simulation impact must be readable by VoiceOver, Dynamic Type, Increase Contrast, and Reduce Motion. Deadline pressure cannot be color-only.

## Performance constraints when relevant
Do not regress launch, scrolling, persistence, or runtime responsiveness. Do not claim performance validation without measured proof.

## Champion Merge source boundary
- Champion Merge final status is accepted Yellow, not Red; IOS26 work may proceed only inside the no-claim boundaries below.
- Before source edits, inspect `docs/codex/canonical-owner-map.yml`, `docs/codex/concept-lock-registry.yml`, and `build/reports/intelligence-consolidation/TRAIN_04L_CLOSEOUT.md`.
- Extend the canonical owner for any touched concept. Do not create a new parallel owner or revive retired duplicate object names as active source/UI terms.
- Keep unresolved Yellow concepts locked against ordinary feature claims until their follow-up gate is Green or owner-accepted.
- `private_life_runtime` owns step candidate generation, rejection learning, and simulation loops.
- `today_root` may present optionality in Today only by extending `Native/Ambitions/Features/Today`, not by creating a detached Start Here/Today owner.

## Allowed files/directories
- Add `GoalTimelineSimulation`, `StepImpactSimulation`, `DeadlinePressureDelta`, `FeasibilityBand`, `PlanRiskProjection`, `OnTrackProjection`, `DelayProjection`, `CompressionProjection`, and `RecoveryProjection`.
- Add per-candidate simulation output for staying on deadline, weekly workload, future pressure, later step needs, protected time threat, deadline review, and scope review.
- Add deterministic simulation tests and `build/reports/step-optionality/deadline-simulation.md`.

## Forbidden files/directories
- no cloud dependency
- no LLM dependency
- no opaque recommendation engine
- no "AI confidence" consumer language
- no hidden profiling
- no external analytics dependency
- no top-level IA changes
- no generic dashboard
- no sensitive context in logs
- no impossible timeline shown as fine
- no silent deadline or schedule mutation

## Exact implementation steps
1. Re-read active truth files and confirm B01/B02 proof.
2. Inspect goal compiler, Time, protected time, recommendation, and replay source.
3. Add timeline simulation domain objects and deterministic projection logic.
4. Attach simulation to each candidate.
5. Ensure lighter alternatives can increase future pressure and critical-step skips can trigger deadline warning.
6. Add copy paths such as "This keeps you on track", "This makes the deadline tighter", and "This likely delays the goal" without color-only pressure meaning.
7. Add proof artifact.

## Validation commands
```bash
make xcode-focused-test BATCH=IOS26-T04B-B03 TEST=AmbitionsTests
make xcode-focused-test BATCH=IOS26-T04B-B03 TEST=AmbitionsUITests
```

## Proof artifacts to write
- `build/reports/step-optionality/deadline-simulation.md`
- `build/reports/ios26-baseline/`
- `build/reports/ios26-migration/`
- `build/reports/ios26-shell/`
- `build/reports/private-life-runtime/`
- `build/reports/goal-intent-compiler/`
- `build/reports/life-context/`
- `build/reports/step-optionality/`
- `build/reports/source-atlas-runtime-bridge/`
- `build/reports/capture-runtime-bridge/`
- `build/reports/core-replacement-contracts/`
- `build/reports/core-life-object-store/`
- `build/reports/time-operations/`
- `build/reports/reminder-operations/`
- `build/reports/project-step-operations/`
- `build/reports/life-knowledge-operations/`
- `build/reports/life-command-search/`
- `build/reports/private-life-runtime-integration/`
- `build/reports/frontend-object-purity/`
- `build/reports/reality-meridian/`
- `build/reports/lifeshape-field/`
- `build/reports/constellation-atlas/`
- `build/reports/atmosphere-composer/`
- `build/reports/user-system-profile/`
- `build/reports/proof-receipts-replay/`
- `build/reports/data-safety/`
- `build/reports/external-surfaces/`
- `build/reports/accessibility-nutrition/`
- `build/reports/performance/`
- `build/reports/repo-hygiene/`
- `build/reports/release-candidate/`

## Green / Yellow / Red gates
Green: every candidate has impact simulation, deadline pressure is honest, impossible timelines are not hidden, and proof exists.
Yellow: bounded gap with owner, reason, no-claim boundary, and gate.
Red: no deadline impact, impossible timelines shown as on track, silent schedule/deadline mutation, or fake simulation.

## Rollback behavior
Rollback only files touched by IOS26-T04B-B03 and preserve unrelated dirty work.

## Claims allowed
- This batch may claim only source, test, and proof outcomes directly demonstrated by current logs and artifacts.
- Docs-only or tooling-only changes must be described as docs-only or tooling-only.

## Claims forbidden
- No release readiness, TestFlight readiness, App Store readiness, CI proof, device proof, accessibility verification, performance validation, privacy/legal approval, or Private Life Runtime moat completion without matching current proof.

## Final report required fields
```text
Status:
Files changed:
Deadline simulation proof:
Tests run:
Validation not run:
Claims allowed:
Claims forbidden:
Yellow/Red items:
Next batch:
```

## STATUS placeholder
STATUS: <GREEN|YELLOW|RED>

## Original prompt intent retained
The original prompt text is retained below for intent preservation. The sealed sections above are the execution boundary.

----- BEGIN ORIGINAL PROMPT -----
# IOS26-T04B-B03 - Deadline simulation engine

## Objective
Simulate each alternative against the same goal and deadline.

## Why this exists
Ambitions must give the user choice without lying about consequences. If the user rejects a high-value step and chooses a lighter option, Ambitions must show whether the choice keeps the deadline, makes the deadline tighter, likely delays the goal, threatens protected time, or requires scope review.

## Dependencies
IOS26-T04B-B01, IOS26-T04B-B02, TRAIN_03, TRAIN_04, TRAIN_04A, and `docs/codex/IOS26_FLAGSHIP_TRAIN_MANIFEST.yml`.

## Truth files to read
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

## Exact source areas to inspect
- Runtime
- Recommendation engine
- Goal compiler
- Time
- Today
- Goals
- Persistence
- Receipts
- Replay
- Services
- Sources/Theme
- Native/AmbitionsTests
- Native/AmbitionsUITests
- Preview fixtures
- `build/reports/step-optionality/candidate-field.md`
- `build/reports/step-optionality/rejection-loop.md`

## Exact changes allowed
- Add `GoalTimelineSimulation`, `StepImpactSimulation`, `DeadlinePressureDelta`, `FeasibilityBand`, `PlanRiskProjection`, `OnTrackProjection`, `DelayProjection`, `CompressionProjection`, and `RecoveryProjection`.
- Add per-candidate simulation output for staying on deadline, weekly workload, future pressure, later step needs, protected time threat, deadline review, and scope review.
- Add deterministic simulation tests and `build/reports/step-optionality/deadline-simulation.md`.

## Exact changes forbidden
- no cloud dependency
- no LLM dependency
- no opaque recommendation engine
- no "AI confidence" consumer language
- no hidden profiling
- no external analytics dependency
- no top-level IA changes
- no generic dashboard
- no sensitive context in logs
- no impossible timeline shown as fine
- no silent deadline or schedule mutation

## Feasibility bands
- comfortably on track
- on track
- tight but possible
- at risk
- unrealistic without changing scope/time/capacity
- impossible under current constraints

## Implementation steps
1. Re-read active truth files and confirm B01/B02 proof.
2. Inspect goal compiler, Time, protected time, recommendation, and replay source.
3. Add timeline simulation domain objects and deterministic projection logic.
4. Attach simulation to each candidate.
5. Ensure lighter alternatives can increase future pressure and critical-step skips can trigger deadline warning.
6. Add copy paths such as "This keeps you on track", "This makes the deadline tighter", and "This likely delays the goal" without color-only pressure meaning.
7. Add proof artifact.

## Tests to add/update
- Lighter alternatives can increase future pressure.
- Skipping critical steps can trigger deadline warning.
- Equivalent alternatives can preserve timeline.
- Impossible timelines are not hidden.
- Protected time threats are surfaced.
- Replay reconstructs simulation outputs.

## Commands to run
```bash
make xcode-focused-test BATCH=IOS26-T04B-B03 TEST=AmbitionsTests
make xcode-focused-test BATCH=IOS26-T04B-B03 TEST=AmbitionsUITests
```

## Required proof artifacts
- `build/reports/step-optionality/deadline-simulation.md`

## Accessibility requirements
Simulation impact must be readable by VoiceOver, Dynamic Type, Increase Contrast, and Reduce Motion. Deadline pressure cannot be color-only.

## Privacy/local-first requirements
Simulation must run locally from user-owned data. Protected time, capacity, health/safety, and emotional readiness context must not leak into logs.

## iOS 26 API verification requirements
Any iOS 26 date, duration, charting, layout, or accessibility API usage must be verified and recorded in the proof artifact.

## Green / Yellow / Red closeout rules
Green: every candidate has impact simulation, deadline pressure is honest, impossible timelines are not hidden, and proof exists.
Yellow: bounded gap with owner, reason, no-claim boundary, and gate.
Red: no deadline impact, impossible timelines shown as on track, silent schedule/deadline mutation, or fake simulation.

## Rollback strategy
Rollback only files touched by IOS26-T04B-B03 and preserve unrelated dirty work.

## Final report format
```text
Status:
Files changed:
Deadline simulation proof:
Tests run:
Validation not run:
Claims allowed:
Claims forbidden:
Yellow/Red items:
Next batch:
```
----- END ORIGINAL PROMPT -----
