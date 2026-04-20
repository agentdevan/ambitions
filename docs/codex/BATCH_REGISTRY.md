# Ambitions Batch Registry

This file is the operational queue for active Ambitions work.
It tracks which batch is completed, active, or queued.
Registry batch numbers are the operational source of truth. Canon batch numbers are semantic roadmap context and must not be renumbered retroactively.

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
| 10 | Canon Batch 7 / Ambient surfaces bundle | Completed | Ambient surfaces now consume shared privacy-safe payload/URL helpers and canonical Now State adapters; notification/widget payloads forward through the canonical executor, widget/Live Activity surfaces prefer Now State with `nextAction` fallback, and XcodeGen generation, simulator build, targeted tests, and full `AmbitionsTests` validation passed. |
| 11 | Canon Batch 8 / Ritual OS | Completed | Computed Ritual OS loops, Today integration, privacy-safe ambient cues, and focused tests passed XcodeGen generation, simulator build, targeted tests, and full `AmbitionsTests` validation. |
| 12 | Canon Batch 9 / Sync-trust foundation | Completed | Portable native backup/restore, conservative conflict contracts, explicit local-only trust posture, and a protocol-backed sync capability boundary landed without backend commitment; XcodeGen generation, simulator build, targeted tests, full `AmbitionsTests`, and scheme UI tests passed. |
| 13 | Canon Batch 10 / Life graph foundation | Completed | Additive `LifeGraphContext` metadata now threads through goal blueprints, drafts, goals, intake/planner inference, snapshot-backed persistence, and shared structural resolvers without creating a parallel model stack; XcodeGen generation, simulator build, corrected focused tests, full `AmbitionsTests` validation, and full scheme UI tests all passed. |
| 14 | Canon Batch 11 / Path systems foundation | Completed | Path-system metadata now extends `LifeGraphContext` and `LifeGraphResolver` with additive stage, prerequisite, readiness, and progression summaries; XcodeGen generation, simulator build, targeted tests, isolated UI-test stabilization for preview goal creation, and full scheme validation all passed. |
| 15 | Canon Batch 12 / Learning and anticipation engine | Completed | A fully derived, read-time learning layer now summarizes observed fit, drift, underrepresentation, timeline risk, and concise why-now reasons from existing evidence, feedback, timing, and life/path context; shared ranking, recovery, ritual, Today, and Goals consumers use the same scorer, and XcodeGen generation, simulator build, targeted tests, full `AmbitionsTests`, and full scheme UI tests all passed. |
| 16 | Canon Batch 13 / Shared life / household intelligence | Completed | Added additive shared-life metadata under `LifeGraphContext` plus a read-time `SharedLifeCoordinationService` so support goals, care responsibilities, household logistics, and compact shared timing context can inform planning, recovery, learning, ritual, and Today without creating a second domain, persistence stack, or sync model; verified with `xcodegen generate`, simulator build, targeted shared-life tests, and full scheme validation on April 19, 2026. |
| 17 | Canon Batch 14 / Runtime separation | Completed | Added a thin compatibility-first `AmbitionsRuntime` boundary over existing repositories, local-only sync/trust, external snapshots, reusable command semantics, and composed intelligence/services while preserving `AppContainer` as the iPhone compatibility facade; verified with `xcodegen generate`, simulator build, targeted runtime/composition tests, full `AmbitionsTests`, and full scheme validation on April 19, 2026. |
| 18 | Canon Batch 15 / Dedicated device prototype | Completed | Added a runtime-only bedside ritual companion projection over existing runtime context, external snapshot truth, ritual cues, command descriptors, and app-owned fallback routes without new targets, hardware layers, voice/audio, production UI, transport, persistence, or payload widening; verified with `xcodegen generate`, simulator build, targeted tests, full `AmbitionsTests`, and full scheme validation on April 19, 2026. |
| 19 | Ambitions 2.0 Batch 00 / Canon reset | Completed | Docs/canon/control-file alignment completed and validated: Ambitions 2.0 is established as the active canon program while preserving Ambitions 1.0 completion history through Batch 18. |
| 20 | Ambitions 2.0 Batch 01 / Knowledge provider boundary | Completed | Landed contract-first provider/provenance/freshness/trust/uncertainty boundaries with local-only degradation behavior and no real retrieval, networking, provider integration, or persisted knowledge storage. |
| 21 | Ambitions 2.0 Batch 02 / External knowledge ingestion core | Completed | Landed deterministic in-memory provider-input normalization into auditable claims/source records with structural conflict and degradation preservation, without live search, external APIs, persistence, runtime output widening, or product UI. |
| 22 | Ambitions 2.0 Batch 03 / Clarification and ambiguity engine | Active | Detect ambiguity in life goals and produce structured clarification needs. |
| 23 | Ambitions 2.0 Batch 04 / Generalized goal understanding contracts | Queued | Stabilize interpreted goal outputs for domains, constraints, readiness, risk, and missing information. |
| 24 | Ambitions 2.0 Batch 05 / Path compiler foundation | Queued | Compile understood goals into staged path candidates with dependencies, assumptions, risks, and fallback branches. |
| 25 | Ambitions 2.0 Batch 06 / Domain pack framework | Queued | Add modular domain intelligence packs for compiler requirements, resources, risks, and readiness criteria. |
| 26 | Ambitions 2.0 Batch 07 / Resource graph and source ranking | Queued | Connect path stages to ranked resources and source entities with auditable trust/provenance signals. |
| 27 | Ambitions 2.0 Batch 08 / Update and freshness engine | Queued | Detect stale knowledge/resource chains and propagate freshness into rankings and explanations. |
| 28 | Ambitions 2.0 Batch 09 / Energy model foundation | Queued | Define energy and capacity as effort fit, focus fit, recovery state, and sustainable pacing. |
| 29 | Ambitions 2.0 Batch 10 / Energy learning and ranking | Queued | Learn fit from behavior and feedback, then rank recommendations by sustainable execution fit. |
| 30 | Ambitions 2.0 Batch 11 / Contradiction engine | Queued | Detect conflicts between goals, behavior, retrieved requirements, plans, and system assumptions. |
| 31 | Ambitions 2.0 Batch 12 / Correction and teaching loop | Queued | Capture user corrections as durable teaching signals for future interpretation and ranking. |
| 32 | Ambitions 2.0 Batch 13 / Explainability and source audit surfaces | Queued | Expose why-this, source audit, freshness, confidence, and correction controls. |
| 33 | Ambitions 2.0 Batch 14 / Intelligence runtime integration | Queued | Integrate 2.0 intelligence services behind stable runtime contracts. |
| 34 | Ambitions 2.0 Batch 15 / Ambitions 2.0 product shell integration | Queued | Integrate path, resource, energy, correction, and explanation experiences into the product shell after services exist. |
