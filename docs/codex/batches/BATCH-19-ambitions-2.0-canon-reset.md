# Batch 19 — Ambitions 2.0 Batch 00 / Canon Reset

## Status

Active

## Goal

Establish Ambitions 2.0 as the active canon program while preserving Ambitions 1.0 completion history exactly as completed foundation work through registry Batch 18.

This batch is docs/canon/control-file alignment only. It must not start product/runtime implementation.

## In Scope

- update `AGENTS.md` for Ambitions 1.0 completion, Ambitions 2.0 active canon, unchanged canonical file paths, and main-only execution
- update `docs/codex/CONTEXT_INDEX.md` for the same source-of-truth posture
- reset `docs/canon/Ambitions_OS_Master_Roadmap.md` to the Ambitions 2.0 roadmap
- reset `docs/canon/Ambitions_Surgical_Execution_Plan.md` to the Ambitions 2.0 dependency order
- reset `docs/canon/Ambitions_Codex_Batch_Plan.md` to the Ambitions 2.0 batch program
- update `docs/codex/BATCH_REGISTRY.md` so Batch 00-18 remain completed, Batch 19 is active, and Batch 20-34 are queued
- create this active Batch 19 control file
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
- make Batch 19 the only active batch
- keep Batch 20 through Batch 34 queued
- do not start Batch 20 implementation
- keep the canonical planning stack at the existing file paths
- work on `main` only unless the user explicitly requests branch-based work

## Repo Notes

- Ambitions 1.0 foundation is complete through registry Batch 18.
- Ambitions 2.0 is the next major program, not a minor patch line.
- The new 2.0 program is retrieval-backed, path-compiling, energy-aware, explainable, and correctable.
- This batch updates control files only so future implementation batches can proceed one at a time.

## Exit Criteria

- `docs/canon/Ambitions_OS_Master_Roadmap.md` states Ambitions 1.0 completion and Ambitions 2.0 roadmap phases A-H.
- `docs/canon/Ambitions_Surgical_Execution_Plan.md` states the Ambitions 2.0 dependency order and explicit forbiddance rules.
- `docs/canon/Ambitions_Codex_Batch_Plan.md` separates Ambitions 1.0 completed foundation from Ambitions 2.0 forward batches 19-34.
- `docs/codex/BATCH_REGISTRY.md` preserves Batch 00-18 as completed, marks Batch 19 active, and queues Batch 20-34.
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

Batch 19 may be marked completed only after the Ambitions 2.0 canon stack is coherent, the registry preserves Ambitions 1.0 history and seeds Ambitions 2.0 correctly, this Batch 19 file exists and remains truthful, validation passes, and the checked-out branch remains `main`.
