# Ambitions Codex Context Index

This file defines the standing source-of-truth hierarchy for future Ambitions work.
Use it before planning or implementing any non-trivial task.

Ambitions 1.0 foundation work is complete through registry Batch 18.
Ambitions 2.0 is now the active canon program, beginning with Batch 19 while preserving the prior operational numbering history.

## Required Read Order

For non-trivial work, read these in order before planning:

1. [AGENTS.md](../../AGENTS.md) and any more-specific scoped `AGENTS.md`.
2. [MASTER_PRODUCT_SPEC.md](../../MASTER_PRODUCT_SPEC.md).
3. [Ambitions_OS_Master_Roadmap.md](../canon/Ambitions_OS_Master_Roadmap.md).
4. [Ambitions_Surgical_Execution_Plan.md](../canon/Ambitions_Surgical_Execution_Plan.md).
5. [Ambitions_Codex_Batch_Plan.md](../canon/Ambitions_Codex_Batch_Plan.md).
6. [Ambitions_Full_Frontend_Transformation_Program.md](../canon/Ambitions_Full_Frontend_Transformation_Program.md) when the task involves the queued post-hardening frontend transformation program.
7. [design/README.md](../canon/design/README.md) when the task needs explicit frontend design truth for the queued transformation program.
8. [Ambitions_Frontend_Transformation_Execution_Classification.md](../canon/design/Ambitions_Frontend_Transformation_Execution_Classification.md) when the task needs explicit frontend sequencing truth.
9. [Ambitions_App_Store_Release_Compliance.md](../canon/Ambitions_App_Store_Release_Compliance.md) when the task involves release-candidate or App Store submission gating.
10. [BATCH_REGISTRY.md](BATCH_REGISTRY.md).
11. Supporting docs linked from [docs/README.md](../README.md).

## Minimal Read Set For Active Batch Execution

Do not reread the full repo canon blindly on every pass.
For active-batch work, use the narrowest truthful read set:

### Plan Pass

Read:

1. [AGENTS.md](../../AGENTS.md)
2. [MASTER_PRODUCT_SPEC.md](../../MASTER_PRODUCT_SPEC.md)
3. the relevant canon roadmap/program files for the active wave
4. the active batch doc
5. [BATCH_REGISTRY.md](BATCH_REGISTRY.md)
6. the relevant operation docs in [../../.codex/operations/](../../.codex/operations/README.md)

### Implementation Pass

Reread only:

1. [AGENTS.md](../../AGENTS.md)
2. [BATCH_REGISTRY.md](BATCH_REGISTRY.md)
3. the active batch doc
4. the specific design/canon files directly governing the touched surface
5. the relevant operation docs

### Closeout Pass

Reread only:

1. [BATCH_REGISTRY.md](BATCH_REGISTRY.md)
2. the active batch doc
3. touched program/control docs
4. the relevant validation/signoff/flake operations docs

If no scope or control-truth changed since the prior pass, do not restart from the full canonical stack.

## Precedence Model

When sources conflict, use this precedence:

1. Direct user task instructions.
2. Root [AGENTS.md](../../AGENTS.md) and any more-specific scoped `AGENTS.md`.
3. [MASTER_PRODUCT_SPEC.md](../../MASTER_PRODUCT_SPEC.md) for current shipping product truth.
4. [Ambitions_OS_Master_Roadmap.md](../canon/Ambitions_OS_Master_Roadmap.md) for platform and endgame vision.
5. [Ambitions_Surgical_Execution_Plan.md](../canon/Ambitions_Surgical_Execution_Plan.md) for execution order and dependency hierarchy.
6. [Ambitions_Codex_Batch_Plan.md](../canon/Ambitions_Codex_Batch_Plan.md) for batching and work packaging.
7. [Ambitions_Full_Frontend_Transformation_Program.md](../canon/Ambitions_Full_Frontend_Transformation_Program.md) for queued post-hardening frontend transformation scope and batch intent.
8. [design/README.md](../canon/design/README.md) for explicit future frontend design truth.
9. [Ambitions_Frontend_Transformation_Execution_Classification.md](../canon/design/Ambitions_Frontend_Transformation_Execution_Classification.md) for explicit future frontend execution tiering.
10. [Ambitions_App_Store_Release_Compliance.md](../canon/Ambitions_App_Store_Release_Compliance.md) for final release-candidate and App Store submission gating.
11. [BATCH_REGISTRY.md](BATCH_REGISTRY.md) for active work status.
12. Supporting docs.

Supporting canon docs that clarify the post-Batch-48 direction without replacing the canonical stack:

- [../canon/Ambitions_Product_Addendum_Continuity_Reality_Execution.md](../canon/Ambitions_Product_Addendum_Continuity_Reality_Execution.md)
- [../canon/Ambitions_Frontend_Batches_49_60_Revised.md](../canon/Ambitions_Frontend_Batches_49_60_Revised.md)

Use these as clarifying shorthand only.
Do not let them override live status from `BATCH_REGISTRY.md` or queue scope from `Ambitions_Full_Frontend_Transformation_Program.md`.

## Canonical Planning Stack

These files are permanent canonical context and must stay in repo:

- [../canon/Ambitions_OS_Master_Roadmap.md](../canon/Ambitions_OS_Master_Roadmap.md)
- [../canon/Ambitions_Surgical_Execution_Plan.md](../canon/Ambitions_Surgical_Execution_Plan.md)
- [../canon/Ambitions_Codex_Batch_Plan.md](../canon/Ambitions_Codex_Batch_Plan.md)
- [../canon/Ambitions_Full_Frontend_Transformation_Program.md](../canon/Ambitions_Full_Frontend_Transformation_Program.md)
- [../canon/Ambitions_App_Store_Release_Compliance.md](../canon/Ambitions_App_Store_Release_Compliance.md)
- [../canon/design/README.md](../canon/design/README.md)
- [../canon/design/Ambitions_Frontend_Transformation_Execution_Classification.md](../canon/design/Ambitions_Frontend_Transformation_Execution_Classification.md)

Do not replace these with external copies or duplicate canon locations.

## Execution Guardrails

- Work on `main` only unless the user explicitly requests branch-based work.
- Do not create, switch to, or suggest branches for normal Ambitions execution.
- Do not skip ahead of the execution order in [Ambitions_Surgical_Execution_Plan.md](../canon/Ambitions_Surgical_Execution_Plan.md).
- Do not build surfaces before engines or services exist.
- Do not build extension-heavy features before shared container and data boundaries exist.
- Do not build sync backend logic before sync boundary, export/import, and conflict policy are defined.
- Do not begin device work before runtime separation exists.
- Implement only the active batch from [Ambitions_Codex_Batch_Plan.md](../canon/Ambitions_Codex_Batch_Plan.md) and [BATCH_REGISTRY.md](BATCH_REGISTRY.md) unless explicitly told otherwise.
- Treat [Ambitions_Full_Frontend_Transformation_Program.md](../canon/Ambitions_Full_Frontend_Transformation_Program.md) as queued future-program truth only; it does not activate any post-hardening UI batch ahead of the registry.
- Treat [design/README.md](../canon/design/README.md) as explicit future design truth for those queued frontend batches only; it does not override current shipping behavior before the relevant batch is active.
- Treat [Ambitions_Frontend_Transformation_Execution_Classification.md](../canon/design/Ambitions_Frontend_Transformation_Execution_Classification.md) as the single source for what is early core, later core, and advanced later core inside the queued frontend program.

## Older Docs

Older roadmap, backlog, audit, release, or implementation notes are supporting context only.
If they conflict with the canonical planning stack, demote them in place and follow the precedence model above.
