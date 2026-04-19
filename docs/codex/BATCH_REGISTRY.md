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
| 02 | Delete legacy TypeScript runtime | Completed | Legacy TS / Expo runtime artifacts are absent from the live repo, and active docs now describe the project as Swift-native and XcodeGen-driven. |
| 03 | Canon Batch 1 / Domain foundation | Completed | Shared domain primitives, history/event seam refinements, recovery/orchestration service boundaries, and focused contract tests passed the intended validation set. |
| 04 | Canon Batch 2 / First-class capture core | Completed | Canonical capture states, transitions, goal binding, minimal triage/revisit metadata, and focused tests passed build, targeted tests, and full AmbitionsTests validation. |
| 05 | Canon Batch 3 / Planning engine v2 | Completed | Planning feasibility, confidence, fragility, pressure, effort posture, canonical goal creation, and shared next-step selection passed generation, build, targeted tests, and full AmbitionsTests validation. |
| 06 | Canon Batch 4 / Recovery engine | Completed | Recovery decisions, drift classification, smaller-step fallback, and dependency-aware next-step behavior passed XcodeGen generation, simulator build, targeted tests, and full `AmbitionsTests` validation. |
| 07 | Canon Batch 5A / Time orchestration foundation (write paths) | Completed | EventKit calendar/reminder write paths were narrowed to truthful creation-only flows, deferred read/conflict behavior was quarantined for later work, and generation, build, targeted tests, and full `AmbitionsTests` validation passed. |
| 08 | Canon Batch 5B / Time orchestration intelligence (read paths) | Completed | Calendar-read conflict detection, nearby room awareness, and compact schedule pressure were restored on the existing EventKit seam, and generation, build, targeted tests, and full `AmbitionsTests` validation passed. |
| 09 | Canon Batch 6 / External action infrastructure | Completed | App-side canonical command execution, deterministic route/payload normalization, privacy-safe additive Now State snapshot fields, and notification forwarding through the shared executor passed XcodeGen generation, simulator build, targeted tests, and full `AmbitionsTests` validation. |
