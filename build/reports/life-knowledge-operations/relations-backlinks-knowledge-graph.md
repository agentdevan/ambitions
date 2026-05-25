# IOS26-T04I-B03 Relations Backlinks Knowledge Graph

## Batch
- Batch ID: `IOS26-T04I-B03`
- Train: `TRAIN_04I` Life Knowledge Operations / Notion Replacement
- Scope: relate notes/context to life objects with local backlink and relation-edge storage

## Implementation Summary
- Added `RelationTargetKind`, `RelationTargetReference`, `RelationEdgeReviewState`, `RelationEdge`, and `RelationBacklink` to `LifeKnowledgeOperationModels`.
- Added `relationEdgeIDs` to `ContextEntry` and `ExportSnapshot`.
- Added `relationEdges` to `Store`, plus `relationEdges(from:)` and `backlinks(to:)` lookup helpers.
- Added deterministic relation-edge normalization and export/reset handling.
- Added focused tests covering life area, goal thread, commitment, step, proof, and source backlinks plus reset/export behavior.

## Owner / Canon Boundaries
- Canonical owners extended only within the existing `private_life_runtime` and accepted-Yellow `proof_receipt_replay` seams.
- No new parallel owner was introduced.
- Active top-level IA remains `Today / Goals / Capture / Time / You`.
- `Plan` was not reintroduced as user-facing top-level IA.
- Repair pass removed the earlier `Native/Ambitions/Persistence/SwiftDataRepositories.swift` touch; this batch no longer touches the locked `persistence_external_surfaces` concept.

## Validation
- `python3 scripts/ios26-flagship-preflight.py --batch IOS26-T04I-B03` -> Green.
- `python3 scripts/ios26-core-replacement-proof-shape-check.py --batch IOS26-T04I-B03` -> Green after adding the batch proof artifact.
- `python3 scripts/ambitions-parallel-implementation-guard.py --phase pre --batch IOS26-T04I-B03 --prompt prompts/batches/IOS26-T04I-B03-relations-backlinks-and-life-knowledge-graph.md` -> Yellow, accepted lock boundary for `proof_receipt_replay`.
- `python3 scripts/ambitions-parallel-implementation-guard.py --phase post --batch IOS26-T04I-B03 --prompt prompts/batches/IOS26-T04I-B03-relations-backlinks-and-life-knowledge-graph.md --changed-from 6b39dd507ddb6509275f98a001c3d647970a6397` -> Yellow, accepted lock boundary for `proof_receipt_replay`; no blocked concept violations.
- `scripts/ambitions-xcode-validate.sh --batch IOS26-T04I-B03 --lane build-for-testing` -> no passing proof. Latest completed summary `.codex/xcode-summaries/IOS26-T04I-B03/20260525T140536Z/build-for-testing-summary.json` failed because the repository still has unrelated test-compile debt in `Native/AmbitionsTests/Domain/ProjectStepOperationModelsTests.swift` and `Native/AmbitionsTests/Persistence/ReminderRepositoryTests.swift`; later rerun log `.codex/xcode-logs/IOS26-T04I-B03/20260525T141300Z/build-for-testing.log` ended with `BUILD INTERRUPTED` and produced no summary JSON.

## Proof Boundaries
- Verified: relation-edge model types, store helpers, reset/export handling, and focused unit coverage were added.
- Verified: build-for-testing now reaches the new relation code and progresses through the target graph.
- Not verified: focused-test lane, because build-for-testing does not complete cleanly.
- Blocked: unrelated compile debt in pre-existing tests prevents a full build-for-testing pass.

## Current Status
- Relation/backlink implementation is in place.
- The Phase 03 Red guard blocker is repaired.
- Repository validation remains Yellow until the unrelated test-compile debt is cleared.
