<!-- AMBITIONS_RUNNER_REQUIRED: true -->
<!-- RUN_WITH: scripts/ambitions-codex-train.sh -->
<!-- DIRECT_CODEX_EXECUTION: forbidden_unless_user_explicitly_bypasses_runner -->
# IOS26-T04C-B02 - Capability graph to path composition

## Objective
Traverse Source Atlas capability graphs and compose personalized paths.

## Why this exists
A Source Atlas match is not enough. Ambitions must traverse capability nodes, edges, path overlays, and role overlays, then combine requirements with Life Context and factor-ledger personalization to produce composed paths instead of one-pack-per-goal templates.

## Dependencies
IOS26-T04C-B01, TRAIN_04A, TRAIN_04A-B06, TRAIN_04B, and `docs/codex/IOS26_FLAGSHIP_TRAIN_MANIFEST.yml`.

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
- `Native/Ambitions/Domain/SourceAtlasPackModels.swift`
- `Native/Ambitions/Domain/SourceAtlasPackFactoryModels.swift`
- `Native/Ambitions/Domain/SourceAtlasStoreModels.swift`
- Runtime
- Recommendation engine
- Goal compiler
- Goals
- Time
- You
- Persistence
- Receipts
- Replay
- Services
- Native/AmbitionsTests
- Native/AmbitionsUITests
- Preview fixtures
- `tools/source-atlas/`
- `docs/codex/SOURCE_ATLAS_*.md`

## Exact changes allowed
- Add or connect `SourceAtlasRequirementProjection`, `SourceAtlasCapabilityPath`, `PersonalPathComposition`, and `PlanSkeleton`.
- Extract prerequisites, blockers, accelerators, equipment, proof needs, and path alternatives.
- Apply Life Context and `PersonalizationFactorLedger`.
- Preserve blocked/stale/missing source nodes.
- Add tests and `build/reports/source-atlas-runtime-bridge/capability-graph-path-composition.md`.

## Exact changes forbidden
- no cloud dependency
- no LLM dependency
- no unsupported professional advice
- no hidden expert system claims
- no source pack overclaim
- no stale source use without review
- no demographic templates
- no top-level IA changes
- no external analytics dependency
- no sensitive data in logs
- no one-pack-per-goal template behavior

## Required runtime objects
`SourceAtlasRequirementProjection` fields: requirementIDs, hardRequirements, softRequirements, prerequisites, equipment, skills, proofNeeds, blockers, accelerators, deadlineSensitiveItems, sourceFreshnessSummary.

`SourceAtlasCapabilityPath` fields: capabilityGraphID, selectedNodeIDs, selectedEdgeIDs, selectedPathOverlayIDs, selectedRoleOverlayIDs, traversalTrace, blockedNodes, staleNodes, missingSourceNodes.

`PersonalPathComposition` fields: goalID, userContextVersion, sourceAtlasProjectionID, pathInstances, alternativePathSet, selectedPath, rejectedPaths, pathTradeoffs, explanationProjection.

`PlanSkeleton` fields: milestones, phases, weeklyCadence, proofMoments, reviewMoments, recoveryWindows, riskFlags, feasibilityBand.

## Implementation steps
1. Re-read active truth files and confirm B01 proof.
2. Inspect capability graph, overlay, Life Context, and factor ledger source.
3. Compose requirements and graph traversal into path alternatives.
4. Apply personal context without demographic templates.
5. Emit path composition and plan skeleton with proof/review/recovery.
6. Preserve blocked and stale nodes in trace.
7. Add proof scenarios and proof artifact.

## Tests to add/update
- Same goal with different life context produces different path composition.
- Same goal with same life context produces deterministic path composition.
- Blocked prerequisite changes plan order.
- Missing equipment creates setup path.
- Facility access changes path selection.
- Eligibility pathway changes path where materially relevant.

## Commands to run
```bash
make xcode-focused-test BATCH=IOS26-T04C-B02 TEST=AmbitionsTests
make xcode-focused-test BATCH=IOS26-T04C-B02 TEST=AmbitionsUITests
```

## Required proof artifacts
- `build/reports/source-atlas-runtime-bridge/capability-graph-path-composition.md`

## Accessibility requirements
Path tradeoffs and review-needed states must have semantic labels and non-color-only meaning where surfaced.

## Privacy/local-first requirements
Life Context and factor ledger use remains local-first, inspectable, and redacted from logs when sensitive.

## iOS 26 API verification requirements
Any iOS 26 API use must be verified and recorded in the proof artifact.

## Green / Yellow / Red closeout rules
Green: path is composed from graph/requirements/context, blocked/stale nodes are not silently used, alternatives are preserved, and plan skeleton includes phases/milestones/proof/review/recovery.
Yellow: bounded gap with owner, reason, no-claim boundary, and gate.
Red: one-pack-per-goal templates, silent stale node use, or hardcoded path behavior.

## Rollback strategy
Rollback only files touched by IOS26-T04C-B02 and preserve unrelated dirty work.

## Final report format
```text
Status:
Files changed:
Capability graph proof:
Path composition proof:
Tests run:
Validation not run:
Claims allowed:
Claims forbidden:
Yellow/Red items:
Next batch:
```
