# Ambitions Batch Registry

This file is the operational queue for active Ambitions work.
It tracks what batch is active, blocked, or complete.

It is not the higher-level vision source. For vision, dependency order, and batch definitions, use:

- [../canon/Ambitions_OS_Master_Roadmap.md](../canon/Ambitions_OS_Master_Roadmap.md)
- [../canon/Ambitions_Surgical_Execution_Plan.md](../canon/Ambitions_Surgical_Execution_Plan.md)
- [../canon/Ambitions_Codex_Batch_Plan.md](../canon/Ambitions_Codex_Batch_Plan.md)

## Registry Rules

- Keep one active batch at a time unless the user explicitly authorizes parallel work.
- Do not start Batch N+1 while Batch N is unstable.
- Do not use this registry to override the dependency order in the surgical execution plan.
- Update status only after validation or an explicit user decision.
- If this registry conflicts with the canonical planning stack, the canonical planning stack wins.

## Active Queue

| Batch | Name | Status | Notes |
| --- | --- | --- | --- |
| 0 | Repo truth and guardrails | Active | Canon alignment and source-of-truth cleanup. |
| 1 | Domain foundation pass | Pending | Depends on Batch 0. |
| 2 | First-class capture core | Pending | Depends on Batch 1. |
| 3 | Planning engine v2 | Pending | Depends on Batch 1. |
| 4 | Recovery engine | Pending | Depends on Batch 3. |
| 5 | Time orchestration foundation (write paths) | Pending | Depends on Batch 3. |
| 6 | Time orchestration intelligence (read paths) | Pending | Depends on Batches 4 and 5. |
| 7 | External action infrastructure | Pending | Depends on Batches 2, 3, and 4. |
| 8 | Ambient surfaces bundle | Pending | Depends on Batches 3, 4, and 7. |
| 9 | Ritual OS | Pending | Depends on Batches 4, 6, and 8. |
| 10 | Sync/trust foundation | Pending | Depends on Batch 1. |
| 11 | Apple-first sync adapter | Pending | Depends on Batch 10. |
| 12 | Life graph foundation | Pending | Depends on Batch 10. |
| 13 | Path systems | Pending | Depends on Batches 3 and 12. |
| 14 | Learning and anticipation | Pending | Depends on Batches 3, 4, 6, and 12. |
| 15 | Shared life / household intelligence | Pending | Depends on Batches 12 and 14. |
| 16 | Runtime separation | Pending | Depends on Batches 10, 12, and 14. |
| 17 | Dedicated device prototype | Pending | Depends on Batch 16. |
