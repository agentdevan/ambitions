# Batch 26 — Ambitions 2.0 Batch 07 / Resource Graph and Source Ranking

## Status

Completed

## Goal

Create the first reusable resource graph and source-ranking layer that connects compiled path stages and domain-pack resource hooks to structured resource entities, narrowed source projections, deterministic ranking metadata, and machine-usable audit lineage.

This batch stayed graph-and-ranking infrastructure only. It did not add live web search, external API integration, freshness propagation behavior, contradiction logic, energy logic, explanation surfaces, UI work, runtime surface widening, or SwiftData schema changes.

## What Landed

- added `GoalResourceGraph` as the first structural resource graph output downstream of `GoalCompiledPath`
- added deterministic source/resource ranking metadata for resources derived from compiled path candidates and resource hooks
- added resource graph models in `Native/Ambitions/Domain/GoalEngine/GoalResourceGraphModels.swift`
- added the thin graph-building service seam in `Native/Ambitions/Services/GoalResourceGraphService.swift`
- kept the graph as a consumer of existing contracts instead of creating a second source system
- built graph output from:
  - `GoalCompiledPath`
  - optional `GoalUnderstandingKnowledgeContext`
  - existing domain-pack `resourceHooks`
- preserved source identity through `GoalResourceSourceEntity` as a narrowed projection over existing source record identity and provider identity
- normalized source projections from existing knowledge context sources and claim-embedded source records
- represented concrete, inferred, placeholder-only, and unresolved resource states structurally
- kept placeholder-only hooks as auditable graph entities instead of omitting them when no concrete resource exists
- carried provenance, trust, freshness, uncertainty, optionality, and missing-resource state structurally on resource entities
- added deterministic selection-group and ranking behavior that does not depend on hash iteration or incidental array order
- kept audit metadata lineage-focused and machine-usable rather than user-facing explanation prose
- minimally extended `GoalCompiledPathResourceHook` with:
  - `summary`
  - explicit `optionality`
- updated proof domain packs to populate hook summary and optionality deterministically
- threaded `resourceGraph` through existing orchestration metadata
- added backward-compatible decoding so older metadata without `resourceGraph` can rebuild a fallback graph from compiled path and optional knowledge context
- added focused model/service/orchestration/persistence tests for graph shape, placeholder handling, source linkage, ranking determinism, hook compatibility, and metadata round-tripping

## What Did Not Land

- no live web search
- no external API integration
- no freshness propagation behavior
- no contradiction engine logic
- no energy model logic
- no LLM integration
- no user-facing explanation surfaces
- no UI work
- no runtime surface widening beyond existing orchestration metadata
- no SwiftData schema expansion
- no separate source system parallel to existing knowledge/source/provenance contracts

## Validation That Actually Ran

- `xcodegen generate`
- `xcodebuild -project Ambitions.xcodeproj -scheme Ambitions -sdk iphonesimulator -destination "generic/platform=iOS Simulator" CODE_SIGNING_ALLOWED=NO build`
- targeted Batch 26 selection:
  - `xcodebuild -project Ambitions.xcodeproj -scheme Ambitions -destination "platform=iOS Simulator,name=iPhone 17" -only-testing:AmbitionsTests/GoalResourceGraphModelsTests -only-testing:AmbitionsTests/GoalResourceGraphServiceTests -only-testing:AmbitionsTests/GoalDomainPackServiceTests -only-testing:AmbitionsTests/GoalEngineOrchestratorTests -only-testing:AmbitionsTests/PersistenceRepositoryTests -only-testing:AmbitionsTests/GoalPathCompilerModelsTests -only-testing:AmbitionsTests/GoalDomainPackModelsTests test`
- authoritative validation:
  - `xcodebuild -project Ambitions.xcodeproj -scheme Ambitions -destination "platform=iOS Simulator,name=iPhone 17" -only-testing:AmbitionsTests test`
  - full `AmbitionsTests` run passed with `253` tests and `0` failures
- checked-out branch remained `main`

## Completion Notes

- `GoalResourceGraph` now provides a reusable structural layer for later freshness, contradiction, explainability, and runtime batches.
- `GoalResourceSourceEntity` remains a narrowed projection over existing source/provider identity and is not a replacement source model.
- Resource hooks now carry enough structural summary and optionality to support downstream ranking without turning `GoalCompiledPath` into a resolved-resource layer.
- Orchestration metadata is the persistence path for the graph; no SwiftData columns were added.

## Next Active Batch

Batch 27 — Ambitions 2.0 Batch 08 / Update and freshness engine
