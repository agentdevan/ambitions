# Codex Context

This folder contains operational context for future Codex runs.

Before non-trivial planning or implementation, read:

1. [CONTEXT_INDEX.md](CONTEXT_INDEX.md)
2. [../../AGENTS.md](../../AGENTS.md)
3. [../../MASTER_PRODUCT_SPEC.md](../../MASTER_PRODUCT_SPEC.md)
4. [../canon/Ambitions_OS_Master_Roadmap.md](../canon/Ambitions_OS_Master_Roadmap.md)
5. [../canon/Ambitions_Surgical_Execution_Plan.md](../canon/Ambitions_Surgical_Execution_Plan.md)
6. [../canon/Ambitions_Codex_Batch_Plan.md](../canon/Ambitions_Codex_Batch_Plan.md)
7. [../canon/Ambitions_Full_Frontend_Transformation_Program.md](../canon/Ambitions_Full_Frontend_Transformation_Program.md) for the queued post-hardening frontend transformation program
8. [../canon/design/README.md](../canon/design/README.md) for explicit future frontend design truth
9. [../canon/design/Ambitions_Frontend_Transformation_Execution_Classification.md](../canon/design/Ambitions_Frontend_Transformation_Execution_Classification.md) for frontend sequencing truth
10. [../canon/Ambitions_App_Store_Release_Compliance.md](../canon/Ambitions_App_Store_Release_Compliance.md) for final release-candidate and App Store submission gating
11. [BATCH_REGISTRY.md](BATCH_REGISTRY.md)

## Batch Execution

[BATCH_REGISTRY.md](BATCH_REGISTRY.md) is the active operational queue.
It does not override the higher-level product vision, dependency hierarchy, or batch packaging in the canonical planning stack.

Codex runs should implement only the active batch unless the user explicitly changes scope.
Use Ask mode or a brief plan before code changes for larger work.
Queued post-hardening frontend transformation batches are documented under [batches/README.md](batches/README.md) and must not be activated ahead of the registry.
The matching design-truth set for those queued batches lives under [../canon/design/README.md](../canon/design/README.md).
The matching execution-tiering truth for those queued batches lives under [../canon/design/Ambitions_Frontend_Transformation_Execution_Classification.md](../canon/design/Ambitions_Frontend_Transformation_Execution_Classification.md).
Final App Store submission gating lives under [../canon/Ambitions_App_Store_Release_Compliance.md](../canon/Ambitions_App_Store_Release_Compliance.md), with the short execution checklist in [Release_Candidate_Review_Checklist.md](Release_Candidate_Review_Checklist.md).

## Supporting Files

- [MASTER_CODEX_SYSTEM.md](MASTER_CODEX_SYSTEM.md) contains standing product-engineering behavior for Codex sessions.
- [MAC_SESSION_BOOT_PROMPT.md](MAC_SESSION_BOOT_PROMPT.md) is a short Mac session bootstrap prompt.
- [repo-audit-baseline.md](repo-audit-baseline.md) captures repo-state audit findings and is supporting context below the canonical stack.
