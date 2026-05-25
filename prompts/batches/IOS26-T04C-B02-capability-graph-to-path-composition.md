<!-- AMBITIONS_RUNNER_REQUIRED: true -->
<!-- RUN_WITH: scripts/ambitions-codex-train.sh -->
<!-- DIRECT_CODEX_EXECUTION: forbidden_unless_user_explicitly_bypasses_runner -->
# IOS26-T04C-B02 - Sealed IOS26 Work Order

## Batch ID
`IOS26-T04C-B02`

## Train ID and title
`TRAIN_04C` - Source Atlas -> Runtime Compiler Bridge

## Batch role in train
Batch 2 of 6 in TRAIN_04C

## Upstream dependencies
- `TRAIN_03`
- `TRAIN_04`
- `TRAIN_04A`
- `TRAIN_04B`

## Downstream dependencies
- `TRAIN_04D`
- `TRAIN_04E`
- `TRAIN_05`
- `TRAIN_06`
- `TRAIN_07`
- `TRAIN_10`

## Objective
Traverse Source Atlas capability graphs and compose personalized paths.

## Product/canon constraints
- Active top-level IA remains `Today / Goals / Capture / Time / You`.
- Use `Start here`, `Recommended step`, `step`, `Start now`, and `Open step` where user-facing language is touched.
- Do not reintroduce `Plan` as a user-facing top-level destination.
- Do not convert Ambitions into a task app, calendar clone, habit tracker, status board, chatbot, AI wrapper, SaaS admin panel, or ranking-based productivity framing.

## Local-first/privacy constraints
Life Context and factor ledger use remains local-first, inspectable, and redacted from logs when sensitive.

## Accessibility constraints
Path tradeoffs and review-needed states must have semantic labels and non-color-only meaning where surfaced.

## Performance constraints when relevant
Do not regress launch, scrolling, persistence, or runtime responsiveness. Do not claim performance validation without measured proof.

## Champion Merge source boundary
- Champion Merge final status is accepted Yellow, not Red; IOS26 work may proceed only inside the no-claim boundaries below.
- Before source edits, inspect `docs/codex/canonical-owner-map.yml`, `docs/codex/concept-lock-registry.yml`, and `build/reports/intelligence-consolidation/TRAIN_04L_CLOSEOUT.md`.
- Extend the canonical owner for any touched concept. Do not create a new parallel owner or revive retired duplicate object names as active source/UI terms.
- Keep unresolved Yellow concepts locked against ordinary feature claims until their follow-up gate is Green or owner-accepted.
- `private_life_runtime` owns runtime compiler integration.
- `proof_receipt_replay` owns receipt/replay traces for Source Atlas runtime bridges.
- `you_root` owns inspection surfaces for what Ambitions knows.

## Allowed files/directories
- Add or connect `SourceAtlasRequirementProjection`, `SourceAtlasCapabilityPath`, `PersonalPathComposition`, and `PlanSkeleton`.
- Extract prerequisites, blockers, accelerators, equipment, proof needs, and path alternatives.
- Apply Life Context and `PersonalizationFactorLedger`.
- Preserve blocked/stale/missing source nodes.
- Add tests and `build/reports/source-atlas-runtime-bridge/capability-graph-path-composition.md`.

## Forbidden files/directories
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

## Exact implementation steps
1. Re-read active truth files and confirm B01 proof.
2. Inspect capability graph, overlay, Life Context, and factor ledger source.
3. Compose requirements and graph traversal into path alternatives.
4. Apply personal context without demographic templates.
5. Emit path composition and plan skeleton with proof/review/recovery.
6. Preserve blocked and stale nodes in trace.
7. Add proof scenarios and proof artifact.

## Validation commands
```bash
make xcode-focused-test BATCH=IOS26-T04C-B02 TEST=AmbitionsTests
make xcode-focused-test BATCH=IOS26-T04C-B02 TEST=AmbitionsUITests
```

## Proof artifacts to write
- `build/reports/source-atlas-runtime-bridge/capability-graph-path-composition.md`
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
Green: path is composed from graph/requirements/context, blocked/stale nodes are not silently used, alternatives are preserved, and plan skeleton includes phases/milestones/proof/review/recovery.
Yellow: bounded gap with owner, reason, no-claim boundary, and gate.
Red: one-pack-per-goal templates, silent stale node use, or hardcoded path behavior.

## Rollback behavior
Rollback only files touched by IOS26-T04C-B02 and preserve unrelated dirty work.

## Claims allowed
- This batch may claim only source, test, and proof outcomes directly demonstrated by current logs and artifacts.
- Docs-only or tooling-only changes must be described as docs-only or tooling-only.

## Claims forbidden
- No release readiness, TestFlight readiness, App Store readiness, CI proof, device proof, accessibility verification, performance validation, privacy/legal approval, or Private Life Runtime moat completion without matching current proof.

## Final report required fields
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

## STATUS placeholder
STATUS: <GREEN|YELLOW|RED>

## Original prompt intent retained
The original prompt text is retained below for intent preservation. The sealed sections above are the execution boundary.

----- BEGIN ORIGINAL PROMPT -----
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
----- END ORIGINAL PROMPT -----
