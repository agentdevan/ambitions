# Ambitions Codex Context Index

This file defines the standing source-of-truth hierarchy for future Ambitions work.
Use it before planning or implementing any non-trivial task.

## Required Read Order

For non-trivial work, read these in order before planning:

1. [AGENTS.md](../../AGENTS.md) and any more-specific scoped `AGENTS.md`.
2. [MASTER_PRODUCT_SPEC.md](../../MASTER_PRODUCT_SPEC.md).
3. [Ambitions_OS_Master_Roadmap.md](../canon/Ambitions_OS_Master_Roadmap.md).
4. [Ambitions_Surgical_Execution_Plan.md](../canon/Ambitions_Surgical_Execution_Plan.md).
5. [Ambitions_Codex_Batch_Plan.md](../canon/Ambitions_Codex_Batch_Plan.md).
6. [BATCH_REGISTRY.md](BATCH_REGISTRY.md).
7. Supporting docs linked from [docs/README.md](../README.md).

## Precedence Model

When sources conflict, use this precedence:

1. Direct user task instructions.
2. Root [AGENTS.md](../../AGENTS.md) and any more-specific scoped `AGENTS.md`.
3. [MASTER_PRODUCT_SPEC.md](../../MASTER_PRODUCT_SPEC.md) for current shipping product truth.
4. [Ambitions_OS_Master_Roadmap.md](../canon/Ambitions_OS_Master_Roadmap.md) for platform and endgame vision.
5. [Ambitions_Surgical_Execution_Plan.md](../canon/Ambitions_Surgical_Execution_Plan.md) for execution order and dependency hierarchy.
6. [Ambitions_Codex_Batch_Plan.md](../canon/Ambitions_Codex_Batch_Plan.md) for batching and work packaging.
7. [BATCH_REGISTRY.md](BATCH_REGISTRY.md) for active work status.
8. Supporting docs.

## Canonical Planning Stack

These files are permanent canonical context and must stay in repo:

- [../canon/Ambitions_OS_Master_Roadmap.md](../canon/Ambitions_OS_Master_Roadmap.md)
- [../canon/Ambitions_Surgical_Execution_Plan.md](../canon/Ambitions_Surgical_Execution_Plan.md)
- [../canon/Ambitions_Codex_Batch_Plan.md](../canon/Ambitions_Codex_Batch_Plan.md)

Do not replace these with external copies or duplicate canon locations.

## Execution Guardrails

- Do not skip ahead of the execution order in [Ambitions_Surgical_Execution_Plan.md](../canon/Ambitions_Surgical_Execution_Plan.md).
- Do not build surfaces before engines or services exist.
- Do not build extension-heavy features before shared container and data boundaries exist.
- Do not build sync backend logic before sync boundary, export/import, and conflict policy are defined.
- Do not begin device work before runtime separation exists.
- Implement only the active batch from [Ambitions_Codex_Batch_Plan.md](../canon/Ambitions_Codex_Batch_Plan.md) and [BATCH_REGISTRY.md](BATCH_REGISTRY.md) unless explicitly told otherwise.

## Older Docs

Older roadmap, backlog, audit, release, or implementation notes are supporting context only.
If they conflict with the canonical planning stack, demote them in place and follow the precedence model above.
