# Batch 19 — Ambitions 2.0 Batch 00 / Canon Reset

<!-- AMB-291-CANON-HYGIENE-HEADER: BEGIN -->

> Canon hygiene status: **execution-work-order-needs-sequencing**
> AMB-291 note: This batch/prompt is a work-order artifact and must be sequenced before execution.
> Active authority: `docs/truth/*`, `docs/codex/GLOBAL_BATCH_SEQUENCE_AUTHORITY.json`, and `docs/codex/IOS26_FLAGSHIP_TRAIN_MANIFEST.yml`.
> Before using this file for implementation, run `make change-impact-check` and follow `docs/ops/change-protocol/implementation-prompt-template.md`.
> Resolution classes: merge-overlap, merge-overlap-before-proof
> Dispositions: merge-before-proof, merge-or-sequence-surface-ownership

<!-- AMB-291-CANON-HYGIENE-HEADER: END -->

## Status

Completed

## Goal

Establish Ambitions 2.0 as the active canon program while preserving Ambitions 1.0 completion history exactly as completed foundation work through registry Batch 18.

This batch is docs/canon/control-file alignment only. It does not start product/runtime implementation.

That canon reset work has now been executed and validated: the Ambitions 2.0 planning stack is aligned in place, Ambitions 1.0 history remains preserved through Batch 18, and the registry has been advanced into the next execution state.

## In Scope

- update `AGENTS.md` for Ambitions 1.0 completion, Ambitions 2.0 active canon, unchanged canonical file paths, and main-only execution
- update `docs/codex/CONTEXT_INDEX.md` for the same source-of-truth posture
- reset `docs/canon/Ambitions_OS_Master_Roadmap.md` to the Ambitions 2.0 roadmap
- reset `docs/canon/Ambitions_Surgical_Execution_Plan.md` to the Ambitions 2.0 dependency order
- reset `docs/canon/Ambitions_Codex_Batch_Plan.md` to the Ambitions 2.0 batch program
- update `docs/codex/BATCH_REGISTRY.md` so Batch 00-18 remain completed, Batch 19 can be closed truthfully, and Batch 20-34 can proceed from the correct queued/active state
- create and then preserve this Batch 19 control file as the completion record for the canon reset
- run docs-focused validation

## Out Of Scope

- product/runtime Swift code
- persistence, service, domain, routing, target, entitlement, or XcodeGen changes
- starting Batch 20 work
- retrieval/provider implementation
- knowledge ingestion
- clarification engine implementation
- path compiler implementation
- product shell UI
- branch creation or branch switching
- renumbering, erasing, or rewriting Ambitions 1.0 completed history
- creating parallel canon docs or moving canonical file paths

## Dependency Rules

- preserve operational registry numbering
- keep Batch 00 through Batch 18 completed
- make Batch 19 the only active batch until validation is complete and control files are ready to advance
- keep Batch 20 through Batch 34 queued
- do not start Batch 20 implementation
- keep the canonical planning stack at the existing file paths
- work on `main` only unless the user explicitly requests branch-based work

## Repo Notes

- Ambitions 1.0 foundation is complete through registry Batch 18.
- Ambitions 2.0 is the next major program, not a minor patch line.
- The new 2.0 program is retrieval-backed, path-compiling, energy-aware, explainable, and correctable.
- This batch updated control files only so future implementation batches can proceed one at a time.

## Exit Criteria

- `docs/canon/Ambitions_OS_Master_Roadmap.md` states Ambitions 1.0 completion and Ambitions 2.0 roadmap phases A-H.
- `docs/canon/Ambitions_Surgical_Execution_Plan.md` states the Ambitions 2.0 dependency order and explicit forbiddance rules.
- `docs/canon/Ambitions_Codex_Batch_Plan.md` separates Ambitions 1.0 completed foundation from Ambitions 2.0 forward batches 19-34.
- `docs/codex/BATCH_REGISTRY.md` preserves Batch 00-18 as completed, closes Batch 19 truthfully, activates Batch 20, and keeps Batch 21-34 queued.
- `AGENTS.md` and `docs/codex/CONTEXT_INDEX.md` truthfully describe the active canon posture and main-only execution rule.
- No product/runtime Swift code is changed.
- Validation passes before this batch is marked completed.

## Validation

- markdown link/path verification for touched docs
- `git diff --check`
- `rg` checks for stale active-batch/program wording
- `git branch --show-current`
- `git status --short`

No Xcode generation, build, or tests are required for this docs-only batch unless later edits touch product/runtime code.

## Completion Rule

Batch 19 is complete only when the Ambitions 2.0 canon stack is coherent, the registry preserves Ambitions 1.0 history and advances Ambitions 2.0 into the correct next execution state, this Batch 19 file remains truthful as the completion record, validation passes, and the checked-out branch remains `main`.

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
