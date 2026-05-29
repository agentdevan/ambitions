# Batch 24 — Ambitions 2.0 Batch 05 / Path Compiler Foundation

<!-- AMB-291-CANON-HYGIENE-HEADER: BEGIN -->

> Canon hygiene status: **execution-work-order-needs-sequencing**
> AMB-291 note: This batch/prompt is a work-order artifact and must be sequenced before execution.
> Active authority: `docs/truth/*`, `docs/codex/GLOBAL_BATCH_SEQUENCE_AUTHORITY.json`, and `docs/codex/IOS26_FLAGSHIP_TRAIN_MANIFEST.yml`.
> Before using this file for implementation, run `make change-impact-check` and follow `docs/ops/change-protocol/implementation-prompt-template.md`.
> Resolution classes: authority-rewrite, merge-overlap, merge-overlap-before-proof, status-expedite
> Dispositions: clarify-status-before-use, merge-before-proof, merge-or-sequence-file-ownership, rewrite-authority-reference

<!-- AMB-291-CANON-HYGIENE-HEADER: END -->

## Status

Completed

## Goal

Create the first reusable path compiler that turns `GoalUnderstanding` into structural staged path candidates without turning the planner into the compiler, without reusing `LifeGraphContext` as the compiler contract, and without pretending uncertainty is fully resolved.

## What Landed

- added `GoalCompiledPath` as the first reusable compiler output built from `GoalUnderstanding`
- added foundational path compiler models in `Native/Ambitions/Domain/GoalEngine/GoalPathCompilerModels.swift`
- added deterministic local compiler service wiring in `Native/Ambitions/Services/GoalPathCompilerService.swift`
- preserved alternate interpretations structurally as separate candidates and branches instead of collapsing active ambiguity into one falsely certain path
- carried assumptions and risks forward structurally in compiled output
- kept knowledge context optional and narrow; compilation still works when no knowledge context exists
- threaded compiled path output through orchestration metadata in the existing goal-engine seam
- added backward-compatible decoding so older orchestration metadata without `compiledPath` synthesizes a legacy fallback compiled path from `GoalUnderstanding`
- kept `GoalPlan`, planner behavior, `LifeGraphContext`, UI surfaces, and SwiftData schema unchanged

## Structural Bug Fix Before Closeout

A correctness bug was found before Batch 24 closeout: stage `dependencyIDs` and emitted stage-order dependency records were using different ID formats, which made stage prerequisite references non-resolvable.

That bug was fixed in:

- `dfeb9dd9bcfb4f3cda626e1cb4d4f1b5a0756ad5`
- `fix(path-compiler): align stage dependency ids with emitted dependencies`

The fix unified dependency ID generation so stage references and emitted dependency records now come from the same canonical source of truth.

## What Did Not Land

- no domain-pack implementation
- no resource ranking or resource graph work
- no freshness engine work
- no energy logic
- no contradiction engine work
- no explanation surfaces
- no UI widening
- no runtime widening beyond orchestration metadata threading
- no SwiftData schema expansion

## Validation That Actually Ran

- `xcodegen generate`
- `xcodebuild -project Ambitions.xcodeproj -scheme Ambitions -sdk iphonesimulator -destination "generic/platform=iOS Simulator" CODE_SIGNING_ALLOWED=NO build`
- targeted Batch 24 selection:
  - `xcodebuild -project Ambitions.xcodeproj -scheme Ambitions -destination "platform=iOS Simulator,name=iPhone 17" -only-testing:AmbitionsTests/Services/GoalPathCompilerServiceTests -only-testing:AmbitionsTests/GoalEngine/GoalEngineOrchestratorTests -only-testing:AmbitionsTests/Persistence/PersistenceRepositoryTests test`
  - this was unstable in the repo and reported `0` executed tests, so it was not treated as the authoritative signal
- authoritative validation:
  - `xcodebuild -project Ambitions.xcodeproj -scheme Ambitions -destination "platform=iOS Simulator,name=iPhone 17" -only-testing:AmbitionsTests test`
  - full `AmbitionsTests` run passed with `238` tests and `0` failures

## Completion Notes

- `GoalCompiledPath` is now the first reusable path compiler output available downstream of `GoalUnderstanding`
- ambiguity, assumptions, risks, uncertainty, and optional knowledge context remain structural instead of being flattened into certainty
- orchestration metadata can safely carry compiled paths for new and legacy drafts without persistence schema changes

## Next Active Batch

Batch 25 — Ambitions 2.0 Batch 06 / Domain pack framework

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
