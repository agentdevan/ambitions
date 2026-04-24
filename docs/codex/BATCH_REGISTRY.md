# Ambitions Batch Registry

This file is the operational queue for active Ambitions work.
It tracks which batch is completed, active, or queued.
Registry batch numbers are the operational source of truth. Canon batch numbers are semantic roadmap context and must not be renumbered retroactively.

It does not replace the higher-level vision or dependency order. For Ambitions 2.0 Batch 61 onward, use the new top-level canon first:

- [../canon/Ambitions_2_0_Master_Plan.md](../canon/Ambitions_2_0_Master_Plan.md)
- [../canon/Ambitions_2_0_Product_Architecture.md](../canon/Ambitions_2_0_Product_Architecture.md)
- [../canon/Ambitions_2_0_Systems_Architecture.md](../canon/Ambitions_2_0_Systems_Architecture.md)
- [../canon/Ambitions_2_0_Visual_System.md](../canon/Ambitions_2_0_Visual_System.md)
- [../canon/Ambitions_2_0_Roadmap.md](../canon/Ambitions_2_0_Roadmap.md)
- [../canon/Ambitions_2_0_Batch_Plan.md](../canon/Ambitions_2_0_Batch_Plan.md)
- [../canon/Ambitions_2_0_Accessibility_Nutrition.md](../canon/Ambitions_2_0_Accessibility_Nutrition.md)
- [../canon/Ambitions_2_0_Decision_Log.md](../canon/Ambitions_2_0_Decision_Log.md)
- [../canon/Ambitions_2_0_Capability_Matrix.md](../canon/Ambitions_2_0_Capability_Matrix.md)

Older preserved continuity docs:

- [../canon/Ambitions_OS_Master_Roadmap.md](../canon/Ambitions_OS_Master_Roadmap.md)
- [../canon/Ambitions_Surgical_Execution_Plan.md](../canon/Ambitions_Surgical_Execution_Plan.md)
- [../canon/Ambitions_Codex_Batch_Plan.md](../canon/Ambitions_Codex_Batch_Plan.md)
- [../canon/Ambitions_Full_Frontend_Transformation_Program.md](../canon/Ambitions_Full_Frontend_Transformation_Program.md) for historical frontend transformation continuity

## Registry Rules

- Keep one active batch at a time unless the user explicitly authorizes parallel work.
- Do not start Batch N+1 while Batch N is unstable.
- Do not use this registry to override the dependency order in the canonical planning stack.
- Update status only after validation or an explicit user decision.
- Preserve historical batch truth; this file is the live queue, not the full historical ledger.
- If this registry conflicts with the canonical planning stack, the canonical planning stack wins.

## Historical Note

The earlier operational queue documented the repo through a post-2.0 hardening and frontend transformation sequence. That history is now complete for planning purposes and remains preserved below; it is not renumbered or deleted.

Per the Ambitions 2.0 canon adopted on 2026-04-24, all phases and batches before Batch 61 are complete for planning purposes. Batch 60 is treated as the completed release-candidate polish batch. The active post-Batch-60 Ambitions 2.0 execution start is Batch 61.

Use [../canon/Ambitions_2_0_Batch_Plan.md](../canon/Ambitions_2_0_Batch_Plan.md) for Batch 61 onward.

## Active Queue

Current wave status: Ambitions 2.0 post-Batch-60 canon is adopted. Batch 64 is active. Batches 61-63 are complete for planning purposes; Batches 65-86 remain queued.

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
| 22 | Ambitions 2.0 Batch 03 / Clarification and ambiguity engine | Completed | Structural clarification and ambiguity analysis now lands inside the existing goal-engine/orchestration seam with compatibility-safe projections for current draft and planner flows. |
| 23 | Ambitions 2.0 Batch 04 / Generalized goal understanding contracts | Completed | Landed the canonical post-clarification `GoalUnderstanding` contract and deterministic composition seam without path compilation, UI, runtime widening, or SwiftData schema changes. |
| 24 | Ambitions 2.0 Batch 05 / Path compiler foundation | Completed | Added the first reusable `GoalCompiledPath` compiler output from `GoalUnderstanding`, threaded it through orchestration metadata, and closed the dependency-ID correctness bug before wrap-up. |
| 25 | Ambitions 2.0 Batch 06 / Domain pack framework | Completed | Added deterministic additive domain-pack enrichment after base compile so compiled paths can carry applied packs, requirement hints, readiness criteria, placeholder-only resource hooks, and pack audit metadata without widening UI/runtime surfaces or SwiftData schema. |
| 26 | Ambitions 2.0 Batch 07 / Resource graph and source ranking | Completed | Added the first structural resource graph and deterministic source/resource ranking layer over compiled paths, optional knowledge context, and existing resource hooks without UI/runtime widening or SwiftData schema changes. |
| 27 | Ambitions 2.0 Batch 08 / Update and freshness engine | Completed | Added deterministic post-graph freshness/update metadata over resource graph outputs, preserving stale/unknown/missing/provider-unavailable states structurally without UI/runtime widening, live refresh, or SwiftData schema changes. |
| 28 | Ambitions 2.0 Batch 09 / Energy model foundation | Completed | Added canonical deterministic energy-fit domain models, a single reusable energy-fit service boundary, orchestration metadata attachment, compact planning read-through, and compatibility-safe legacy decode without ranking, UI, learning, SwiftData, or runtime-surface expansion; validated with XcodeGen generation, native app build, targeted Batch 28 tests, and full `AmbitionsTests` on `iPhone 17` after `iPhone 16` was unavailable. |
| 29 | Ambitions 2.0 Batch 10 / Energy learning and ranking | Completed | Added a canonical energy-learning layer derived on read from explicit history, replaced selector energy double-counting with bounded `-0.08...0.08` ranking adjustments, kept learning local to same-goal evidence, and validated on `iPhone 17` with targeted suites plus full `AmbitionsTests` (283 tests, 0 failures). |
| 30 | Ambitions 2.0 Batch 11 / Contradiction engine | Completed | Added a detection-only canonical contradiction engine that emits compact deterministic contradiction metadata from the existing clarification, understanding, path, resource, and energy pipeline without changing planning, ranking, blocking, or UI behavior; validated with XcodeGen generation, native simulator build, targeted contradiction/orchestration/persistence tests, and full `AmbitionsTests` on April 20, 2026. |
| 31 | Ambitions 2.0 Batch 12 / Correction and teaching loop | Completed | Added a capture/read-only correction-and-teaching layer with durable typed teaching signals, stable same-goal anchors, deterministic `applicationKey` supersession, strict explicit-manual rejection boundaries, additive standalone persistence, and portable snapshot support; validated with targeted Batch 31 tests plus full `AmbitionsTests` on April 20, 2026. |
| 32 | Ambitions 2.0 Batch 13 / Explainability and source audit surfaces | Completed | Added Goal Detail explainability and source-audit surfaces powered by a read-only canonical projector, bounded teaching-backed correction controls, compact Today why-this reuse, and validated with `xcodegen generate`, native app build, targeted explainability/correction tests, and full `AmbitionsTests` (316 tests, 0 failures). |
| 33 | Ambitions 2.0 Batch 14 / Intelligence runtime integration | Completed | Added a composition-only runtime-owned goal-intelligence seam over canonical orchestration, explainability, teaching, and optional why-now services; migrated Goals explainability/correction and Today's narrow why-this path to the live runtime seam; validated with `xcodegen generate`, native app build, and full `AmbitionsTests` on April 20, 2026 (320 tests, 0 failures). |
| 34 | Ambitions 2.0 Batch 15 / Ambitions 2.0 product shell integration | Completed | Goals overview and Today now consume compact runtime-backed shell summaries through the Batch 33 runtime seam; Goal Detail remains the only full-fidelity trust surface; validation passed with XcodeGen generation, native build, targeted runtime/shell tests, and full `AmbitionsTests`. Manual simulator UI review was not completed and remains hardening/product-audit follow-up input. |
| 35 | Post-2.0 Hardening 01 / Shell Truth, Navigation, and Plan Canon Recovery | Completed | Restored the canonical five-tab shell, recovered Plan as a first-class weekly-shaping surface, normalized legacy Captures/Habits tab truth into subordinate routes, tightened shell-aligned deep-link/payload compatibility, and validated with `xcodegen generate`, simulator build, full `AmbitionsTests` (`336`), full `AmbitionsUITests` (`4`), targeted shell/routing/Plan coverage, and manual simulator shell review. |
| 36 | Post-2.0 Hardening 02 / Trust, Extensions, and External Surface Validation | Completed | Centralized external-surface truth language, added a narrow Profile notification/trust surface, kept Share Extension explicitly unshipped, shipped navigation-only App Intents, fixed missing `ambitions://` URL registration, and validated canonical external route landing with XcodeGen generation, native build, targeted external-surface tests, full `AmbitionsTests` (`340`), full `AmbitionsUITests` (`6`), shared snapshot verification, and OS-level deep-link registration checks. Widget/Live Activity rendering, notification auth UX, and App Shortcuts visibility remain conservative in copy because full manual platform confirmation could not be completed in this environment. |
| 37 | Post-2.0 Hardening 03 / Secondary Surface Productization | Completed | Completed for planning purposes before the post-Batch-60 Ambitions 2.0 canon. |
| 38 | Post-2.0 Hardening 04 / Repo Truth, Regression, Performance, and Release Readiness | Completed | Completed for planning purposes before the post-Batch-60 Ambitions 2.0 canon. |
 
## Post-Batch-60 Ambitions 2.0 Queue

These rows are the active planning state for the new post-Batch-60 Ambitions 2.0 canon.

| Batch | Name | Status | Notes |
| --- | --- | --- | --- |
| 60 | Release-candidate polish batch | Completed | Marked complete for planning by explicit user instruction on 2026-04-24; existing repo docs did not independently verify implementation details during this docs-only canon update. |
| 61 | Repo Truth and Ambitions 2.0 Capability Matrix | Completed | Repo truth and capability matrix verification completed enough to allow Batch 62 shell IA work by explicit user direction. |
| 62 | Ambitions 2.0 Shell IA | Completed | Locked Today / Goals / Capture / Plan / You shell implemented per current verified state; deeper 2.0 surface work remains deferred to owning batches. |
| 63 | Rich Panel Design System | Completed | Ambitions 2.0 rich panel design-system foundation added with semantic state/accessibility hooks per current verified state; broad surface redesign remains deferred. |
| 64 | Accessibility Nutrition Layer | Active | Establish internal accessibility nutrition checklist, screen audit template, code-backed model/tests where practical, and Batch 85 handoff criteria without publishing user-facing claims. |
| 65 | Memory / Event Ledger Foundation | Queued | New Ambitions 2.0 batch; do not start until prior dependencies are complete. |
| 66 | Recommendation Explanation Model | Queued | New Ambitions 2.0 batch; do not start until prior dependencies are complete. |
| 67 | Canonical Now State | Queued | New Ambitions 2.0 batch; do not start until prior dependencies are complete. |
| 68 | Command Pipeline Foundation | Queued | New Ambitions 2.0 batch; do not start until prior dependencies are complete. |
| 69 | Capture 2.0 Core | Queued | New Ambitions 2.0 batch; do not start until prior dependencies are complete. |
| 70 | Reality Model and Calendar Read/Write | Queued | New Ambitions 2.0 batch; do not start until prior dependencies are complete. |
| 71 | Believability, Capacity, and Goal Health | Queued | New Ambitions 2.0 batch; do not start until prior dependencies are complete. |
| 72 | Execution Resilience Stack | Queued | New Ambitions 2.0 batch; do not start until prior dependencies are complete. |
| 73 | Today 2.0 Rich Execution Center | Queued | New Ambitions 2.0 batch; do not start until prior dependencies are complete. |
| 74 | Goals and Goal Detail 2.0 | Queued | New Ambitions 2.0 batch; do not start until prior dependencies are complete. |
| 75 | Plan 2.0 Calendar-Aware Believability Workspace | Queued | New Ambitions 2.0 batch; do not start until prior dependencies are complete. |
| 76 | You 2.0, Reviews, Memory, and Trust | Queued | New Ambitions 2.0 batch; do not start until prior dependencies are complete. |
| 77 | Contextual Insights and Review System | Queued | New Ambitions 2.0 batch; do not start until prior dependencies are complete. |
| 78 | Apple-First Sync and Export/Import | Queued | New Ambitions 2.0 batch; do not start until prior dependencies are complete. |
| 79 | App Intents and Shared Container | Queued | New Ambitions 2.0 batch; do not start until prior dependencies are complete. |
| 80 | Widgets and Live Activity v1 | Queued | New Ambitions 2.0 batch; do not start until Now State and Command Pipeline are stable. |
| 81 | Path Intelligence Foundation | Queued | New Ambitions 2.0 batch; do not start until prior dependencies are complete. |
| 82 | Path Builder and Long-Range Path UI | Queued | New Ambitions 2.0 batch; do not start until prior dependencies are complete. |
| 83 | Learning and Anticipation v1 | Queued | New Ambitions 2.0 batch; do not start until prior dependencies are complete. |
| 84 | Onboarding, Empty States, and Returning User Continuity | Queued | New Ambitions 2.0 batch; do not start until prior dependencies are complete. |
| 85 | Accessibility Verification and User-Facing Nutrition Facts | Queued | New Ambitions 2.0 batch; do not start until prior dependencies are complete. |
| 86 | Ambitions 2.0 Release Hardening | Queued | Final new Ambitions 2.0 release hardening batch. |

## Completed Historical Front-End Transformation Program

These batches are complete for planning purposes. They remain as historical context only. The new top-level Ambitions 2.0 source of truth for future work is the Batch 61-86 canon package.

| Batch | Name | Status | Notes |
| --- | --- | --- | --- |
| 39 | Front-End Transformation 00 / Program canon and shell rewrite foundation | Completed | Completed for planning purposes before the post-Batch-60 Ambitions 2.0 canon. |
| 40 | Front-End Transformation 01 / Shell reconsideration and navigation architecture | Completed | Completed for planning purposes before the post-Batch-60 Ambitions 2.0 canon. |
| 41 | Front-End Transformation 02 / Design system, materials, motion engine, and controls | Completed | Completed for planning purposes before the post-Batch-60 Ambitions 2.0 canon. |
| 42 | Front-End Transformation 03 / Global compose, search, capture, and command surface | Completed | Completed for planning purposes before the post-Batch-60 Ambitions 2.0 canon. |
| 43 | Front-End Transformation 04 / Today rebuild I - living hero, now state, and action model | Completed | Completed for planning purposes before the post-Batch-60 Ambitions 2.0 canon. |
| 44 | Front-End Transformation 05 / Today rebuild II - time aperture, recovery bloom, and day logic | Completed | Completed for planning purposes before the post-Batch-60 Ambitions 2.0 canon. |
| 45 | Front-End Transformation 06 / Goals rebuild I - direction board and horizon ladder | Completed | Completed for planning purposes before the post-Batch-60 Ambitions 2.0 canon. |
| 46 | Front-End Transformation 07 / Goal intake and Strategy Composer | Completed | Completed for planning purposes before the post-Batch-60 Ambitions 2.0 canon. |
| 47 | Front-End Transformation 08 / Goal Detail rebuild I - strategic chamber and path filmstrip | Completed | Completed for planning purposes before the post-Batch-60 Ambitions 2.0 canon. |
| 48 | Front-End Transformation 09 / Goal Detail rebuild II - trust whisper, correction, audit, and memory | Completed | Completed for planning purposes before the post-Batch-60 Ambitions 2.0 canon. |
| 49 | Front-End Transformation 10 / Plan rebuild I - elastic week and pressure scrubber | Completed | Completed for planning purposes before the post-Batch-60 Ambitions 2.0 canon. |
| 50 | Front-End Transformation 11 / Plan rebuild II - habits, captures, weekly review, and shaping logic | Completed | Completed for planning purposes before the post-Batch-60 Ambitions 2.0 canon. |
| 51 | Front-End Transformation 12 / Insights rebuild and reflection OS | Completed | Completed for planning purposes before the post-Batch-60 Ambitions 2.0 canon. |
| 52 | Front-End Transformation 13 / Profile rebuild, Appearance Studio, and Trust Center | Completed | Completed for planning purposes before the post-Batch-60 Ambitions 2.0 canon. |
| 53 | Front-End Transformation 14 / Onboarding, first-run, permissions, education, and state systems | Completed | Completed for planning purposes before the post-Batch-60 Ambitions 2.0 canon. |
| 54 | Front-End Transformation 15 / External surfaces I - widgets, Live Activities, notifications | Completed | Completed for planning purposes before the post-Batch-60 Ambitions 2.0 canon. |
| 55 | Front-End Transformation 16 / External surfaces II - share extension, App Intents, shortcuts, routing | Completed | Completed for planning purposes before the post-Batch-60 Ambitions 2.0 canon. |
| 56 | Front-End Transformation 17 / Cross-surface command, recall, and ambient coherence | Completed | Completed for planning purposes before the post-Batch-60 Ambitions 2.0 canon. |
| 57 | Front-End Transformation 18 / iPad and Mac surface architecture and first implementation | Completed | Completed for planning purposes before the post-Batch-60 Ambitions 2.0 canon. |
| 58 | Front-End Transformation 19 / Watch and Apple TV ambient surface architecture and first implementation | Completed | Completed for planning purposes before the post-Batch-60 Ambitions 2.0 canon. |
| 59 | Front-End Transformation 20 / Finish-quality pass, accessibility, performance, and release polish | Completed | Completed for planning purposes before the post-Batch-60 Ambitions 2.0 canon. |
