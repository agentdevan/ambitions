<!-- AMBITIONS_RUNNER_REQUIRED: true -->
<!-- RUN_WITH: scripts/ambitions-codex-train.sh -->
<!-- DIRECT_CODEX_EXECUTION: forbidden_unless_user_explicitly_bypasses_runner -->
# TRAIN_04C - Source Atlas -> Runtime Compiler Bridge

## Objective
Install the runtime bridge that connects Source Atlas validated knowledge packs to the Private Life Runtime goal compiler, step candidate field, timeline simulation, receipts, replay, and inspection surfaces.

## Why this exists
Ambitions has a Source Atlas substrate and a Private Life Runtime direction, but product truth is incomplete until the app can prove the bridge from raw goal intent to source/freshness/risk-gated knowledge, capability graph traversal, path composition, step candidate expansion, simulation, Start Here recommendation, and receipt/replay proof.

Core product truth:

```text
Ambitions must not only store Source Atlas packs. It must use them to turn user goals into personalized paths, plans, and steps inside the Private Life Runtime.
```

This train makes "virtually unlimited goal/path/plan/step composition" an installed product truth only when proven. Until Green proof exists, that claim remains forbidden.

## Dependencies
See `docs/codex/IOS26_FLAGSHIP_TRAIN_MANIFEST.yml`. This train depends on TRAIN_03, TRAIN_04, TRAIN_04A, and TRAIN_04B and sits after TRAIN_04B and before TRAIN_05.

Downstream dependency updates:
- TRAIN_05 depends on TRAIN_04C.
- TRAIN_06 depends on TRAIN_04C.
- TRAIN_07 depends on TRAIN_04C.
- TRAIN_08 depends on TRAIN_04C where captures promote into goals.
- TRAIN_09 depends on TRAIN_04C for inspection controls.
- TRAIN_10 depends on TRAIN_04C for receipts/replay.
- TRAIN_16 depends on TRAIN_04C through the full train chain.

## Required pipeline
The final executed train must prove this end-to-end pipeline:

```text
UserGoalIntent
-> SourceAtlasIntentMatch
-> SourceAtlasPackSelection
-> SourceAtlasRequirementProjection
-> SourceAtlasCapabilityPath
-> PersonalPathComposition
-> PlanSkeleton
-> StepCandidateSeedExpansion
-> StepCandidateField
-> StepImpactSimulation
-> StartHereRecommendation
-> RecommendationReceipt
-> ReplayTrace
```

## Required runtime objects
Future implementation must install or connect:
- `SourceAtlasIntentMatch`
- `SourceAtlasPackSelection`
- `SourceAtlasRequirementProjection`
- `SourceAtlasCapabilityPath`
- `PersonalPathComposition`
- `PlanSkeleton`
- `SourceAtlasStepExpansionTrace`

Required object fields are defined in the mapped batch prompts.

## Batch list
- IOS26-T04C-B01
- IOS26-T04C-B02
- IOS26-T04C-B03
- IOS26-T04C-B04
- IOS26-T04C-B05
- IOS26-T04C-B06

## Source scope
See the exact source areas in each mapped batch prompt. Future implementation must inspect Source Atlas pack models, factory/store models, Runtime, Recommendation engine, Goal compiler, Today, Goals, Time, You, Capture promotion, Persistence, Receipts, Replay, Services, tests, UI tests, preview fixtures, `tools/source-atlas/`, and `docs/codex/SOURCE_ATLAS_*.md`.

## Proof artifacts
Use `build/reports/source-atlas-runtime-bridge/` and the specific batch prompt.

## Train-level acceptance gate
Create `build/reports/source-atlas-runtime-bridge/TRAIN_04C_CLOSEOUT.md` when the train is executed.

The closeout must include: Status, Batches completed, Files changed, Intent match proof, Pack selection proof, Capability graph traversal proof, Path composition proof, Step candidate expansion proof, Simulation proof, Receipt/replay proof, Coverage gauntlet proof, You inspection proof, Privacy/local-first proof, Accessibility support status, Known gaps, Claims allowed, Claims forbidden, Next eligible train.

## Claims allowed only if Green
- "Ambitions can bridge Source Atlas packs into runtime recommendations."
- "Source Atlas can help compose paths and step candidates."
- "Source/freshness/risk gates determine whether knowledge can drive recommendations."
- "Unsupported goals degrade to a safe scaffold with receipts."
- "Recommendations can be replayed back to Source Atlas inputs."

## Claims forbidden unless proven
- "Virtually unlimited goals"
- "Complete goal coverage"
- "Perfect plan generation"
- "Professionally accurate advice"
- "Medical/legal/financial/recruiting advice"
- "Fully autonomous expert planning"
- "App Store-ready Source Atlas runtime"

## Red conditions
- Source Atlas remains disconnected from runtime.
- Source packs are decoded but never used for recommendations.
- One-pack-per-goal template behavior.
- Unsupported/stale/high-risk packs drive current recommendations silently.
- No candidate provenance.
- No bridge receipts.
- No deterministic replay.
- No coverage gauntlet.
- Sensitive source/context data appears in logs.
- Start Here recommendations cannot trace back to Source Atlas or explicit fallback.

## Red/Yellow/Green closeout rules
Green requires evidence. Yellow requires owner, reason, no-claim boundary, and gate. Red stops.

## Rollback strategy
Rollback only touched files. Preserve unrelated dirty work.

## Sequential commands for that train
```bash
scripts/ambitions-codex-train.sh IOS26-T04C-B01 prompts/batches/IOS26-T04C-B01-source-atlas-match-and-pack-selection.md
scripts/ambitions-codex-train.sh IOS26-T04C-B02 prompts/batches/IOS26-T04C-B02-capability-graph-to-path-composition.md
scripts/ambitions-codex-train.sh IOS26-T04C-B03 prompts/batches/IOS26-T04C-B03-path-to-step-candidate-expansion.md
scripts/ambitions-codex-train.sh IOS26-T04C-B04 prompts/batches/IOS26-T04C-B04-runtime-compiler-receipts-replay.md
scripts/ambitions-codex-train.sh IOS26-T04C-B05 prompts/batches/IOS26-T04C-B05-source-atlas-coverage-gauntlet.md
scripts/ambitions-codex-train.sh IOS26-T04C-B06 prompts/batches/IOS26-T04C-B06-source-atlas-you-inspection-surface.md
```

## Batch summaries
- IOS26-T04C-B01: `prompts/batches/IOS26-T04C-B01-source-atlas-match-and-pack-selection.md`
- IOS26-T04C-B02: `prompts/batches/IOS26-T04C-B02-capability-graph-to-path-composition.md`
- IOS26-T04C-B03: `prompts/batches/IOS26-T04C-B03-path-to-step-candidate-expansion.md`
- IOS26-T04C-B04: `prompts/batches/IOS26-T04C-B04-runtime-compiler-receipts-replay.md`
- IOS26-T04C-B05: `prompts/batches/IOS26-T04C-B05-source-atlas-coverage-gauntlet.md`
- IOS26-T04C-B06: `prompts/batches/IOS26-T04C-B06-source-atlas-you-inspection-surface.md`

## Post-batch gates
Record accepted Yellow gates in `docs/codex/POST_BATCH_GATE_REGISTRY.md`.
