# Codex Context

This folder contains operational context for future Codex runs.

Before non-trivial planning or implementation, read:

1. [CONTEXT_INDEX.md](CONTEXT_INDEX.md)
2. [../../AGENTS.md](../../AGENTS.md)
3. [../../MASTER_PRODUCT_SPEC.md](../../MASTER_PRODUCT_SPEC.md)
4. [../canon/design/Ambitions_Design_Constitution.md](../canon/design/Ambitions_Design_Constitution.md)
5. [../canon/Ambitions_2_0_Master_Plan.md](../canon/Ambitions_2_0_Master_Plan.md)
6. [../canon/Ambitions_2_0_Roadmap.md](../canon/Ambitions_2_0_Roadmap.md)
7. [../canon/Ambitions_2_0_Batch_Plan.md](../canon/Ambitions_2_0_Batch_Plan.md)
8. [../canon/Ambitions_2_0_Implementation_Gap_Audit.md](../canon/Ambitions_2_0_Implementation_Gap_Audit.md)
9. [BATCH_REGISTRY.md](BATCH_REGISTRY.md)

## Batch Execution

[BATCH_REGISTRY.md](BATCH_REGISTRY.md) is the active operational queue.
It does not override the higher-level product vision, dependency hierarchy, or batch packaging in the canonical planning stack.

Codex runs should implement only the active batch unless the user explicitly changes scope.
Use Ask mode or a brief plan before code changes for larger work.
Historical post-hardening frontend transformation batches are documented under [batches/README.md](batches/README.md). For active work, use the Ambitions 2.0 canon and the D01-D26 delta/alignment backlog.
Archived frontend transformation design docs live under [../archive/README.md](../archive/README.md) and are historical only.

## Supporting Files

- [MASTER_CODEX_SYSTEM.md](MASTER_CODEX_SYSTEM.md) contains standing product-engineering behavior for Codex sessions.
- [MAC_SESSION_BOOT_PROMPT.md](MAC_SESSION_BOOT_PROMPT.md) is a short Mac session bootstrap prompt.
- [repo-audit-baseline.md](repo-audit-baseline.md) captures repo-state audit findings and is supporting context below the canonical stack.
