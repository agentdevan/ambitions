# Ambitions Batch Registry

This file is the operational queue for active Ambitions work.
It tracks which batch is completed, active, or queued.

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
| 00 | Repo operating system / canon alignment | Completed | Repo truth and control-file alignment completed enough to move Batch 01 into the active slot. |
| 01 | Pre-Phase-9 cleanup and Captures tab | Completed | Runtime truth cleanup, capture source normalization, captures-tab wiring verification, routing, and targeted tests are completed. |
| 02 | Delete legacy TypeScript runtime | Active | Remove any remaining legacy TS / Expo / React Native runtime artifacts and stale backend/runtime docs so repo truth becomes fully Swift-native. |
