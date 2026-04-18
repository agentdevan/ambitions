# Codex Context

This folder contains operational context for future Codex runs.

Before non-trivial planning or implementation, read:

1. [CONTEXT_INDEX.md](CONTEXT_INDEX.md)
2. [../../AGENTS.md](../../AGENTS.md)
3. [../../MASTER_PRODUCT_SPEC.md](../../MASTER_PRODUCT_SPEC.md)
4. [../canon/Ambitions_OS_Master_Roadmap.md](../canon/Ambitions_OS_Master_Roadmap.md)
5. [../canon/Ambitions_Surgical_Execution_Plan.md](../canon/Ambitions_Surgical_Execution_Plan.md)
6. [../canon/Ambitions_Codex_Batch_Plan.md](../canon/Ambitions_Codex_Batch_Plan.md)
7. [BATCH_REGISTRY.md](BATCH_REGISTRY.md)

## Batch Execution

[BATCH_REGISTRY.md](BATCH_REGISTRY.md) is the active operational queue.
It does not override the higher-level product vision, dependency hierarchy, or batch packaging in the canonical planning stack.

Codex runs should implement only the active batch unless the user explicitly changes scope.
Use Ask mode or a brief plan before code changes for larger work.

## Supporting Files

- [MASTER_CODEX_SYSTEM.md](MASTER_CODEX_SYSTEM.md) contains standing product-engineering behavior for Codex sessions.
- [MAC_SESSION_BOOT_PROMPT.md](MAC_SESSION_BOOT_PROMPT.md) is a short Mac session bootstrap prompt.
- [repo-audit-baseline.md](repo-audit-baseline.md) captures repo-state audit findings and is supporting context below the canonical stack.
