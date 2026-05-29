# Batch 26 — Ambitions 2.0 Batch 07 / Resource Graph and Source Ranking

<!-- AMB-291-CANON-HYGIENE-REPAIR: BEGIN -->

> AMB-291 repair status: **canon-hygiene-reconciled**
> This file was reviewed as part of the actual canon content/hygiene rewrite pass.
> It is not standalone active product truth. Use `docs/truth/*` and current manifest/sequence authority before implementation.
> Conflict types reconciled: stale_or_unknown_active_status
> Prior recommended actions: Expedite
> Candidate references: AMB28-stale_or_unknown_active_status-8253336

<!-- AMB-291-CANON-HYGIENE-REPAIR: END -->

<!-- AMB-291-CANON-HYGIENE-HEADER: BEGIN -->

> Canon hygiene status: **execution-work-order-needs-authority-check**
> AMB-291 note: This batch/prompt is not standalone authority and must read the listed source-of-truth files before use.
> Active authority: `docs/truth/*`, `docs/codex/GLOBAL_BATCH_SEQUENCE_AUTHORITY.json`, and `docs/codex/IOS26_FLAGSHIP_TRAIN_MANIFEST.yml`.
> Before using this file for implementation, run `make change-impact-check` and follow `docs/ops/change-protocol/implementation-prompt-template.md`.
> Resolution classes: authority-rewrite, finish-real-source-proof, status-expedite
> Dispositions: clarify-status-before-use, proof-readiness, rewrite-authority-reference

<!-- AMB-291-CANON-HYGIENE-HEADER: END -->

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

## Source-of-truth references

<!-- AMB-291-SOURCE-OF-TRUTH-REFERENCES: BEGIN -->

This file must not be treated as standalone active canon. Current authority must be resolved through:

- `docs/truth/README.md`
- `docs/truth/PRODUCT_DESIGN_TRUTH.md`
- `docs/truth/PRODUCT_MOAT_TRUTH.md`
- `docs/truth/IMPLEMENTATION_TRUTH.md`
- `docs/truth/RELEASE_TRUTH.md`
- `docs/truth/CODEX_PROCESS_TRUTH.md`
- `docs/truth/HISTORICAL_POLICY.md`
- `docs/codex/GLOBAL_BATCH_SEQUENCE_AUTHORITY.json`
- `docs/codex/IOS26_FLAGSHIP_TRAIN_MANIFEST.yml`
- `docs/ops/change-protocol/change-request-template.md`
- `docs/ops/change-protocol/change-impact-check.md`
- `docs/ops/change-protocol/implementation-prompt-template.md`
- `docs/ops/change-protocol/post-implementation-proof-reconciliation.md`

<!-- AMB-291-SOURCE-OF-TRUTH-REFERENCES: END -->

## Non-claims

<!-- AMB-291-NON-CLAIMS: BEGIN -->

- This file does not prove implementation.
- This file does not prove build success.
- This file does not prove test success.
- This file does not prove accessibility validation.
- This file does not prove performance validation.
- This file does not prove device validation.
- This file does not prove privacy/legal approval.
- This file does not prove TestFlight readiness.
- This file does not prove App Store readiness.
- This file does not prove release readiness.
- Linear status is not repo truth.

<!-- AMB-291-NON-CLAIMS: END -->
