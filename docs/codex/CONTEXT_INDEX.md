# Ambitions Codex Context Index

Ambitions 3.0 is the active source of truth. This file defines Codex read order, precedence, and where to find implementation history.

## Current Operating Truth

- Ambitions 3.0 is active for product, front-end, product language, primitive architecture, implementation sequencing, repo hygiene, dependency discipline, and handoff readiness.
- Older 1.0/2.0/v2/Waves/D/M/R material is implementation history or supporting context only where Ambitions 3.0 explicitly keeps a domain binding.
- `docs/codex/BATCH_REGISTRY.md` is implementation status truth only. It does not override Ambitions 3.0 product direction.
- The F27 FAANG handoff gate rerun is PASS after F28 repaired/rebaselined the full-suite Goal Detail trust/memory UI proof. F27.5, F29, and F30 are Green by current train evidence; the F17-F30 train is complete at the F30 closeout commit.
- F00 Current Implementation Gap Audit is complete as an audit-only traceability pass.
- F01/F02 Reality Rail work is now represented in Today state and UI evidence: Today renders a focused Reality Rail with `Start here`, `Start now`, Now/Next/Later, source/context labels, duration labels, privacy-safe projection, empty/unavailable copy, and reserved closure/proof slots.
- F03 Step Detail work is now represented as a Today-local sheet opened from the Reality Rail `Start here` card and Now/Next/Later rows, with grounded recommendation explanation, duration/source/context labels, private redaction, and stable `TodayStepDetail*` accessibility identifiers.
- F03.5 Today Execution State Contract Hardening is complete: `TodayExecutionViewState.swift` is now a small aggregate state contract, while Day Rail state, Step Detail state, projection helpers, projector logic, compatibility helpers, and screen-contract snapshot live in dedicated Today-owned files.
- F04 Step Session, F05 Action Closure / Still Counts, F06 Proof & Receipt Ledger, F07 Capture Composer cleanup, F08 Placement Resolver, F09 Capture-to-Goal / Grow into Goal, F10 Plan Life Suite foundation, F11 Day Shape / Week Shape, F12 Reflow / Recovery / Decisions, F13 Goals / Goal Mission Control, F13.5 Goals / You / Trust architecture checkpoint, F14 You / Trust / What Ambitions Knows, F15 Legacy Identifier Migration, and F16 UI Test Modernization are complete.
- F16.5 SwiftUI Architecture / State Contract Hardening checkpoint is complete. The active completion train is F17-F30 FAANG Handoff Completion Train. F17 repair, F18, F19, F20, F21/F21.5, F22, F22.5, F22.7, F23, F24, F25, F26, F27, F27.5, F28, F29, and F30 are Green by current train evidence. F27 passed after F28 rebaselined the Goal Detail trust/memory UI proof to stable owned section anchors and reran `scripts/test-local.sh` cleanly with 779 unit tests and 29 UI tests. F27.5 found no critical maintainability blocker and fixed stale active train-entry wording. F29 created the engineer handoff package. F30 created the Beyond 3.0 continuation roadmap and final train closeout.

## Required Read Order

For non-trivial work, read in this order:

1. `README.md`
2. `docs/README.md`
3. `docs/canon/Ambitions_3_0_Source_Of_Truth_Override.md`
4. `docs/canon/Ambitions_3_0_Front_End_Redesign_Index.md`
5. `docs/canon/Ambitions_3_0_Rebuild_Operating_Model.md`
6. `docs/canon/Ambitions_3_0_Documentation_System_Index.md`
7. `docs/canon/Ambitions_3_0_Primitive_Architecture.md`
8. `docs/canon/Ambitions_3_0_Product_Language_System.md`
9. Target Ambitions 3.0 primitive/surface/contract docs.
10. `docs/codex/BATCH_REGISTRY.md` for implementation status truth only.

## Precedence Model

1. Direct user instructions for the current task.
2. `AGENTS.md` and scoped repo guidance.
3. Ambitions 3.0 source docs in the required read order.
4. Target 3.0 primitive/surface/contract docs.
5. Current native SwiftUI repo evidence under `Native/Ambitions/`, `Sources/`, `AppUI/Sources/`, `project.yml`, and tests.
6. `docs/codex/BATCH_REGISTRY.md` for implementation status truth only.
7. Older canon and batch docs only where 3.0 explicitly keeps them binding or where they provide historical implementation evidence.

## Active Codex Operating Entry Points

- [MASTER_AMBITIONS_3_0_CODEX_PROMPT.md](MASTER_AMBITIONS_3_0_CODEX_PROMPT.md)
- [AMBITIONS_3_0_CONTEXT_LOADING_AND_TASK_ROUTING.md](AMBITIONS_3_0_CONTEXT_LOADING_AND_TASK_ROUTING.md)
- [AMBITIONS_3_0_SKILL_SYSTEM_INDEX.md](AMBITIONS_3_0_SKILL_SYSTEM_INDEX.md)
- [MASTER_CODEX_SYSTEM.md](MASTER_CODEX_SYSTEM.md)
- [FREE_WORKFLOW_OPERATING_SYSTEM.md](FREE_WORKFLOW_OPERATING_SYSTEM.md)
- [MAC_CODEX_5_5_TOOLCHAIN_SETUP.md](MAC_CODEX_5_5_TOOLCHAIN_SETUP.md)
- [../canon/Ambitions_3_0_Codex_Performance_Operating_System.md](../canon/Ambitions_3_0_Codex_Performance_Operating_System.md)
- [../canon/Ambitions_3_0_FAANG_Team_Operating_Model.md](../canon/Ambitions_3_0_FAANG_Team_Operating_Model.md)
- [../canon/Ambitions_3_0_Task_Width_And_Batch_Combining_Gate.md](../canon/Ambitions_3_0_Task_Width_And_Batch_Combining_Gate.md)
- [../canon/Ambitions_3_0_UI_Test_Contract.md](../canon/Ambitions_3_0_UI_Test_Contract.md)
- [../canon/Ambitions_3_0_Local_Toolchain_Readiness_Matrix.md](../canon/Ambitions_3_0_Local_Toolchain_Readiness_Matrix.md)
- [AMBITIONS_3_0_RUN_STATE_PROTOCOL.md](AMBITIONS_3_0_RUN_STATE_PROTOCOL.md)
- [AMBITIONS_3_0_LARGE_BATCH_AND_COMPACT_RECOVERY_PROTOCOL.md](AMBITIONS_3_0_LARGE_BATCH_AND_COMPACT_RECOVERY_PROTOCOL.md)
- [AMBITIONS_3_0_PROMPT_QUALITY_RUBRIC.md](AMBITIONS_3_0_PROMPT_QUALITY_RUBRIC.md)
- [AMBITIONS_3_0_PARALLEL_CODEX_WORKTREE_PROTOCOL.md](AMBITIONS_3_0_PARALLEL_CODEX_WORKTREE_PROTOCOL.md)
- [../canon/Ambitions_3_0_Dependency_Management_Policy.md](../canon/Ambitions_3_0_Dependency_Management_Policy.md)
- [../canon/Ambitions_3_0_Current_Implementation_Gap_Audit.md](../canon/Ambitions_3_0_Current_Implementation_Gap_Audit.md)
- [../canon/Ambitions_3_0_As_Current_Baseline_Policy.md](../canon/Ambitions_3_0_As_Current_Baseline_Policy.md)
- [../canon/Ambitions_3_0_Human_Made_Codebase_Standard.md](../canon/Ambitions_3_0_Human_Made_Codebase_Standard.md)
- [../canon/Ambitions_3_0_Active_History_Archive_Policy.md](../canon/Ambitions_3_0_Active_History_Archive_Policy.md)

## Historical / Supporting Material

- [Ambitions_2_0_Codex_Execution_Guide.md](Ambitions_2_0_Codex_Execution_Guide.md) is historical/supporting only.
- [batches/README.md](batches/README.md) preserves implementation evidence and older prompts; do not run old prompts as active 3.0 work without reconciliation.
- Older roadmap and maturity docs remain useful for history/status, not active product direction when they conflict with Ambitions 3.0.

## Execution Guardrails

- Preserve `Today / Goals / Capture / Plan / You` as the canonical destination set.
- Preserve XcodeGen as the project generation system.
- Do not add runtime dependencies without dependency-policy approval.
- Do not claim implementation or readiness without evidence.
- Prefer focused validation and report known full UI failures honestly.

## Batch Train Context

Batch-train execution uses `docs/codex/AMBITIONS_3_0_BATCH_TRAIN_ORCHESTRATOR.md`, `docs/codex/batch-trains/README.md`, `.codex/reports/current-batch-train-state.md`, and the matching validation/operation packs. F03.5, F13.5, and F16.5 are complete. The active train manifest is `docs/codex/batch-trains/F17_F30_FAANG_HANDOFF_COMPLETION_TRAIN.md`; F27, F27.5, F28, F29, and F30 are Green. The train stops after the F30 closeout push. After the 2026-05-02 pre-train hardening pass, Release Evidence Closure is the first active post-3.0 train; AOS, ME, CS, and Product Depth remain future/not started.

## Global Future Batch Execution Context

Use this context before selecting any future cross-train batch after REC01:

- `GLOBAL_FUTURE_BATCH_EXECUTION_ORDER.md`
- `GLOBAL_FUTURE_BATCH_DEPENDENCY_GRAPH.md`
- `GLOBAL_FUTURE_BATCH_GATE_MATRIX.md`
- `GLOBAL_BATCH_EXECUTION_ORCHESTRATOR.md`
- `GLOBAL_BATCH_AUTOMATED_GATE_PROTOCOL.md`
- `GLOBAL_BATCH_REPAIR_LOOP_PROTOCOL.md`
- `GLOBAL_BATCH_CONTINUATION_PROTOCOL.md`
- `GLOBAL_BATCH_FAANG_QUALITY_BAR.md`
- `../audits/global-future-batch-sequencing-report.md`

These files define order, gates, repair loops, continuation, validation strength, and quality bars only. They do not start REC02, PXOS, ME, CS, AOS, Product Depth, app implementation, release readiness, or human-proof work.

## Handoff Package

- `../handoff/Ambitions_3_0_FAANG_Engineer_Handoff.md`
- `../handoff/Ambitions_3_0_Architecture_Map.md`
- `../handoff/Ambitions_3_0_Testing_And_Release_Proof.md`
- `../canon/Ambitions_Beyond_3_0_Roadmap.md`

## F-Series Audit Reports

- `docs/audits/ambitions-3-0-f00-current-implementation-gap-audit-report.md`
- `docs/audits/ambitions-3-0-f02-reality-rail-visual-states-report.md`
- `docs/audits/ambitions-3-0-f03-step-detail-recommendation-explanation-report.md`
- `docs/audits/ambitions-3-0-f03-5-today-state-contract-hardening-report.md`
- `docs/audits/ambitions-3-0-batch-train-orchestrator-report.md`
- `docs/audits/ambitions-3-0-f10-plan-life-suite-foundation-report.md`
- `docs/audits/ambitions-3-0-f11-day-week-shape-report.md`
- `docs/audits/ambitions-3-0-f12-architecture-clarity-report.md`
- `docs/audits/ambitions-3-0-f12-reflow-recovery-decisions-report.md`
- `docs/audits/ambitions-3-0-f13-goal-mission-control-report.md`
- `docs/audits/ambitions-3-0-f13-5-goals-you-trust-architecture-checkpoint-report.md`
- `docs/audits/ambitions-3-0-f14-you-trust-what-ambitions-knows-report.md`
- `docs/audits/ambitions-3-0-f15-legacy-identifier-migration-report.md`
- `docs/audits/ambitions-3-0-f16-ui-test-modernization-report.md`
- `docs/audits/ambitions-3-0-f16-5-swiftui-architecture-state-contract-hardening-report.md`
- `docs/audits/ambitions-3-0-auto-batch-train-f12-through-f16-5-report.md`
- `docs/audits/ambitions-3-0-f17-f30-faang-handoff-completion-train-setup-report.md`
- `docs/audits/ambitions-3-0-f17-shell-meridian-readiness-report.md`
- `docs/audits/ambitions-3-0-f17-shell-meridian-ownership-decision.md`
- `docs/audits/ambitions-3-0-f18-feature-flagged-meridian-shell-report.md`
- `docs/audits/ambitions-3-0-f19-shell-route-parity-fallback-safety-report.md`
- `docs/audits/ambitions-3-0-f20-external-surfaces-privacy-projection-report.md`
- `docs/audits/ambitions-3-0-f21-full-ui-smoke-stabilization-report.md`
- `docs/audits/ambitions-3-0-f17-repair-and-handoff-train-resume-report.md`
- `docs/audits/ambitions-3-0-f21-5-ui-failure-classification.md`
- `docs/audits/ambitions-3-0-f21-5-ui-flake-reliability-hardening-report.md`
- `docs/audits/ambitions-3-0-f22-product-language-baseline-reset-report.md`
- `docs/audits/ambitions-3-0-f22-5-doc-qa-backlog-closure-report.md`
- `docs/audits/ambitions-3-0-f22-7-human-made-active-repo-hygiene-report.md`
- `docs/audits/ambitions-3-0-f23-accessibility-adhd-qa-report.md`
- `docs/audits/ambitions-3-0-f24-privacy-trust-qa-report.md`
- `docs/audits/ambitions-3-0-f25-device-performance-edge-case-qa-report.md`
- `docs/audits/ambitions-3-0-f26-app-store-demo-truth-report.md`
- `docs/audits/ambitions-3-0-final-faang-handoff-readiness-report.md`
- `docs/audits/ambitions-3-0-f27-5-human-made-codebase-maintainability-audit.md`
- `docs/audits/ambitions-3-0-f28-faang-handoff-repair-report.md`
- `docs/audits/ambitions-3-0-f29-final-handoff-package-engineer-onboarding-report.md`
- `docs/audits/ambitions-3-0-final-train-closeout-report.md`

## AmbitionsOS Future Canon Context

Use this context when the user explicitly chooses AmbitionsOS, AOS, Maintainability Extraction, Compatibility Seam Retirement, or Codex OS Continuity after F30:

- `docs/canon/AmbitionsOS_Index.md`
- `docs/canon/AmbitionsOS_Core_Architecture.md`
- `docs/canon/AmbitionsOS_Runtime_Contract.md`
- `docs/canon/Ambitions_Beyond_3_0_Maintainability_Extraction_Plan.md`
- `docs/canon/Ambitions_Beyond_3_0_Compatibility_Seam_Retirement_Plan.md`
- `docs/codex/AMBITIONSOS_AOS_TRAIN_CONTROL_SYSTEM.md`
- `docs/codex/batch-trains/AOS01_AOS30_AMBITIONSOS_LOCAL_INTELLIGENCE_TRAIN.md`
- `docs/codex/batch-trains/ME01_ME12_MAINTAINABILITY_EXTRACTION_TRAIN.md`
- `docs/codex/batch-trains/CS01_CS10_COMPATIBILITY_SEAM_RETIREMENT_TRAIN.md`

AmbitionsOS is future canon, not current app implementation truth. Do not start future trains automatically.


## Release Evidence Closure Context

Use this context when the active train is REC01-REC06 Release Evidence Closure:

- `docs/codex/batch-trains/REC01_REC06_RELEASE_EVIDENCE_CLOSURE_TRAIN.md`
- `docs/codex/batches/REC01_Release_Evidence_Truth_Inventory_Prompt.md`
- `docs/audits/rec01-release-evidence-truth-inventory-report.md`

Release Evidence Closure is evidence/status/release-truth focused. It does not implement app features and does not claim App Store readiness, TestFlight readiness, final RC lock, physical-device verification, public accessibility conformance, signed archive validation, App Store Connect validation, rendered external-platform proof, or AmbitionsOS implementation.


## PXOS Future Canon Context

Use this context when the user explicitly chooses PXOS or future user-facing product-experience canon after F30:

- `docs/canon/Ambitions_Product_Experience_OS_Index.md`
- `docs/canon/PXOS_Product_Promise_And_Experience_Principles.md`
- `docs/canon/PXOS_Surface_Hierarchy_And_Navigation.md`
- `docs/codex/PXOS_TRAIN_CONTROL_SYSTEM.md`
- `docs/codex/PXOS_GATE_MATRIX.md`
- `docs/codex/PXOS_PRODUCT_DECISION_LEDGER.md`
- `docs/codex/batch-trains/PX01_PX20_PRODUCT_EXPERIENCE_OS_TRAIN.md`

PXOS is future canon for user-facing experience, not current app implementation. PXOS train starts only if the user says exactly `Start PXOS Future-Canon Train`. REC01 remains active; REC02, AOS, ME, CS, Product Depth, and PXOS implementation remain unstarted until explicitly approved by their gates.
