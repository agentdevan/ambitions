# Ambitions Global Train Consolidation and Modification Plan

Date: 2026-05-11


## Safe consolidations

- Shared execution standard and handoff templates.
- Shared queue snapshot / control-plane scripts.
- Shared final-report schema checks.
- Shared source-atlas title normalization audits.
- Shared prompt coverage and duplicate detector.

## Unsafe consolidations

- Do not collapse PK17-PK41 into one executable block.
- Do not convert EFC into standalone feature stream.
- Do not run AIR as standalone batch.
- Do not run RHC tail before the appropriate non-blocked precondition set.
- Do not mark DPTG00 as non-terminal.
- Do not introduce top-level `Plan` route changes in this governance pass.

## Additions to implement

- Create `docs/codex/AMB_GLOBAL_REMAINING_TRAIN_BLUEPRINT.json` and `docs/codex/AMB_GLOBAL_REMAINING_TRAIN_BLUEPRINT.md` from canonical queue and reference.
- Add `docs/codex/AMB_GLOBAL_TRAIN_CONSOLIDATION_AND_MODIFICATION_PLAN.md` and `docs/codex/AMB_GLOBAL_TRAIN_CODEX_IMPLEMENTATION_INSTRUCTIONS.md` for deterministic continuation.
- Add missing queue/plane validator scripts under `scripts/` for bounded governance checks.
- Keep `.codex/reports/current-run-state.md`, `.codex/reports/current-batch-train-state.md`, and `.codex/state/active-batch.yml` aligned from active-state only changes.

## Modifications by train

- PK: tighten implementation instructions, preserve PK17-PK41 sequence, and keep dependency preconditions explicit.
- SA: add source-atlas title and freshness/forking checks; avoid changing canonical titles without manifest mapping.
- LDI/AOS/PD/PFC/FCP: keep scoped handoff and proof gates explicit with no app-source changes in this phase.
- RHC: keep terminal owner and preserve historical evidence during hygiene pass.
- EFC: fold proof into owning batches; only standalone when no owning batch can own proof.
- CS conditional: keep trigger-only entries as historical placeholders with no auto-run.

## Modifications deferred

- Per-batch canonical prompt rewrites are deferred to batch execution cycles for owned batch authorship.
- Full source-atlas title normalization beyond proven canonical IDs is deferred.

## Removal / Archive candidates

- Do not delete historical prompt material. Mark and isolate as do-not-run in continuation prompts when runnable surfaces appear.
