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
- Ambitions 4.0 is the active post-3.0 execution program, not a shipped product version. It started with 113 formal batches in global order after SI insertion: REC02-REC06, PX01-PX20, ME01-ME12, CS01-CS10, SI01-SI18, PD01-PD18, and AOS01-AOS30. REC02-REC06 are complete as Release Evidence Closure, PX01-PX20 are complete as future PXOS canon/roadmap evidence, ME01 is complete as maintainability audit evidence, ME08 is complete as shared projector/state/helper standards evidence, ME10 is complete as recurring architecture-gate evidence, ME02 is complete as behavior-preserving Goals service extraction evidence, ME03 is complete as behavior-preserving Today service extraction evidence, ME04 is complete as behavior-preserving TodayPanels extraction evidence, ME05 is complete as behavior-preserving Plan service extraction evidence, ME06 is complete as behavior-preserving You root surface extraction evidence, ME07 is complete as behavior-preserving PlanScreen extraction evidence, ME09 is complete as product-contract test evidence, ME11 is not triggered, ME12 is complete as maintainability handoff evidence, CS01 is complete as compatibility seam registry evidence, CS07 is complete as focused external compatibility proof, CS08 is complete as focused import/export/persistence compatibility proof, CS02A/CS02B are complete as internal Profile/You seam repair and proof evidence, CS03A/CS03B are complete as internal Insights seam repair and proof evidence, CS04A/CS04B are complete as internal Habits/Ritual/Plan seam repair and proof evidence, CS05A/CS05B are complete as internal ActiveFocus/TodayFocus seam repair and proof evidence, and CS06A is complete as internal Failed-Taxonomy seam repair evidence. CS05C and CS06C remain blocked/deferred. CS06B focused proof is next. Future canon remains not implemented until explicit batches produce evidence.

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
- [../canon/Ambitions_4_0_Execution_Program.md](../canon/Ambitions_4_0_Execution_Program.md)

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

Batch-train execution uses `docs/codex/AMBITIONS_3_0_BATCH_TRAIN_ORCHESTRATOR.md`, `docs/codex/batch-trains/README.md`, `.codex/reports/current-batch-train-state.md`, and the matching validation/operation packs. F03.5, F13.5, and F16.5 are complete. The F17-F30 train is complete by current train evidence. After the 2026-05-02 pre-train hardening pass and CS06A repair, Release Evidence Closure is complete through REC06; PX01-PX20 are complete as future PXOS canon/roadmap evidence; ME01 is complete as maintainability audit evidence; ME08 is complete as shared standards evidence; ME10 is complete as recurring architecture-gate evidence; ME02 is complete as behavior-preserving Goals service extraction evidence; ME03 is complete as behavior-preserving Today service extraction evidence; ME04 is complete as behavior-preserving TodayPanels extraction evidence; ME05 is complete as behavior-preserving Plan service extraction evidence; ME06 is complete as behavior-preserving You root surface extraction evidence; ME07 is complete as behavior-preserving PlanScreen extraction evidence; ME09 is complete as product-contract test evidence; ME11 is not triggered; ME12 is complete as maintainability handoff evidence; CS01 is complete as compatibility seam registry evidence; CS07 is complete as focused external compatibility proof; CS08 is complete as focused import/export/persistence compatibility proof; CS02A and CS02B are complete as Profile/You seam repair and focused proof evidence; CS03A and CS03B are complete as Insights compatibility seam repair and focused proof evidence; CS04A and CS04B are complete as Habits/Ritual/Plan compatibility seam repair and focused proof evidence; CS05A and CS05B are complete as ActiveFocus/TodayFocus seam repair and focused proof evidence; CS06A is complete as Failed-Taxonomy seam repair evidence; CS06B is next; CS02C, CS03C, CS04C, CS05C, CS06C, CS09-CS10, Signature Interface, Product Depth, and AOS remain queued/blocked under the Ambitions 4.0 Execution Program.

## Ambitions 4.0 Global Batch Execution Context

Use this context before selecting any queued cross-train batch after REC01:

- `GLOBAL_FUTURE_BATCH_EXECUTION_ORDER.md`
- `GLOBAL_FUTURE_BATCH_DEPENDENCY_GRAPH.md`
- `GLOBAL_FUTURE_BATCH_GATE_MATRIX.md`
- `GLOBAL_BATCH_EXECUTION_ORCHESTRATOR.md`
- `GLOBAL_BATCH_AUTOMATED_GATE_PROTOCOL.md`
- `GLOBAL_BATCH_REPAIR_LOOP_PROTOCOL.md`
- `GLOBAL_BATCH_CONTINUATION_PROTOCOL.md`
- `GLOBAL_BATCH_FAANG_QUALITY_BAR.md`
- `../audits/global-future-batch-sequencing-report.md`

These files define Ambitions 4.0 order, gates, repair loops, continuation, validation strength, and quality bars only. They do not start REC05, PXOS, ME, CS, SI, AOS, Product Depth, app implementation, release readiness, or human-proof work.

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
ME01 is complete as maintainability audit evidence. ME08 is complete as shared projector/state/helper standards evidence. ME10 is complete as recurring architecture-gate evidence. ME02 is complete as behavior-preserving Goals service extraction evidence. ME03 is complete as behavior-preserving Today service extraction evidence. ME04 is complete as behavior-preserving TodayPanels extraction evidence. ME05 is complete as behavior-preserving Plan service extraction evidence. ME06 is complete as behavior-preserving You root surface extraction evidence. ME07 is complete as behavior-preserving PlanScreen extraction evidence. ME09 is complete as product-contract test evidence. ME11 is not triggered. ME12 is complete as maintainability handoff evidence. CS01 is complete as compatibility seam registry evidence. CS07 is complete as focused external compatibility proof. CS08 is complete as focused import/export/persistence compatibility proof. CS02A and CS02B are complete as Profile/You seam repair and proof evidence. CS03A and CS03B are complete as Insights compatibility seam repair and proof evidence. CS04A and CS04B are complete as Habits/Ritual/Plan compatibility seam repair and proof evidence. CS05A and CS05B are complete as ActiveFocus/TodayFocus compatibility seam repair and proof evidence.


## Release Evidence Closure Context

Use this context when the active train is REC01-REC06 Release Evidence Closure:

- `docs/codex/batch-trains/REC01_REC06_RELEASE_EVIDENCE_CLOSURE_TRAIN.md`
- `docs/codex/batches/REC01_Release_Evidence_Truth_Inventory_Prompt.md`
- `docs/codex/batches/REC02_Human_Operator_Release_Proof_Plan_Prompt.md`
- `docs/codex/batches/REC03_Validation_Log_Ledger_Closure_Prompt.md`
- `docs/codex/batches/REC04_Release_Claim_Copy_Guard_Prompt.md`
- `docs/codex/batches/REC05_Human_Review_Packet_Prompt.md`
- `docs/codex/batches/REC06_Release_Evidence_Closure_Handoff_Prompt.md`
- `docs/audits/rec01-release-evidence-truth-inventory-report.md`
- `docs/codex/REC02_Human_Operator_Release_Proof_Plan.md`
- `docs/codex/REC03_Validation_Log_Ledger.md`
- `docs/audits/rec04-release-claim-copy-guard-report.md`

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

PXOS is future canon for user-facing experience, not current app implementation. PX01-PX20 are complete as future canon/roadmap evidence. REC02-REC06 are complete as Release Evidence Closure; ME01-ME12 are complete or not triggered by their documented gates; CS01 is complete as compatibility seam registry evidence; CS07 is complete as focused external compatibility proof; CS08 is complete as focused import/export/persistence compatibility proof; CS02A and CS02B are complete as Profile/You seam repair and proof evidence; CS03A and CS03B are complete as Insights compatibility seam repair and proof evidence; CS04A and CS04B are complete as Habits/Ritual/Plan seam repair and proof evidence; CS05A and CS05B are complete as ActiveFocus/TodayFocus seam repair and proof evidence; CS06A is complete as Failed-Taxonomy seam repair evidence. CS02C, CS03C, CS04C, CS05C, CS06B, CS06C, CS09-CS10, SI, Product Depth, AOS, and PXOS implementation remain queued/blocked until their gates allow execution.


## Signature Interface Queued Train Context

Use this context when SI is selected by global order or explicit phrase:

- `docs/canon/Ambitions_Signature_Interface_System.md`
- `docs/codex/batch-trains/SI01_SI18_SIGNATURE_INTERFACE_IMPLEMENTATION_TRAIN.md`
- `.codex/review-boards/signature-interface-review-board.md`
- `.codex/skills/signature-interface-creative-director.md`

SI starts only through global dry-run selection or `Start Signature Interface Train`. SI remains queued/blocked and not implemented.

## Product Depth Queued Train Context

Use this context when the user explicitly chooses Product Depth after the
required PXOS, ME, CS, AOS-if-needed, and REC claim gates:

- `docs/canon/Ambitions_Product_Depth_Plan.md`
- `docs/canon/PXOS_Product_Depth_And_Drilldown_Rules.md`
- `docs/codex/batch-trains/PD01_PD18_PRODUCT_DEPTH_TRAIN.md`
- `docs/codex/batches/PD01_Product_Depth_Canon_Inventory_And_Ownership_Map_Prompt.md`
- `docs/codex/batches/PD02_Today_Step_Detail_Depth_Prompt.md`
- `docs/codex/batches/PD03_Today_Step_Session_Depth_Prompt.md`
- `docs/codex/batches/PD04_Today_Recovery_And_Closure_Depth_Prompt.md`
- `docs/codex/batches/PD05_Goals_Mission_Control_Detail_Architecture_Prompt.md`
- `docs/codex/batches/PD06_Goal_Lifecycle_And_Path_Visualization_Prompt.md`
- `docs/codex/batches/PD07_Goal_Proof_And_Decision_History_Depth_Prompt.md`
- `docs/codex/batches/PD08_Goal_Alternate_Path_And_Tradeoff_Depth_Prompt.md`
- `docs/codex/batches/PD09_Capture_Placement_Review_Prompt.md`
- `docs/codex/batches/PD10_Capture_Correction_And_Confidence_Loops_Prompt.md`
- `docs/codex/batches/PD11_Grow_Into_Goal_Flow_Prompt.md`
- `docs/codex/batches/PD12_Plan_Reflow_Decision_Depth_Prompt.md`
- `docs/codex/batches/PD13_Plan_Recovery_And_Pressure_Review_Prompt.md`
- `docs/codex/batches/PD14_Life_Shape_Drilldowns_Prompt.md`
- `docs/codex/batches/PD15_You_Trust_History_And_Receipts_Center_Prompt.md`
- `docs/codex/batches/PD16_Schedule_Availability_And_Planning_Defaults_Depth_Prompt.md`
- `docs/codex/batches/PD17_Cross_Surface_Proof_And_Review_Integration_Prompt.md`
- `docs/codex/batches/PD18_Product_Depth_Handoff_And_Next_Lane_Readiness_Prompt.md`
- `docs/codex/GLOBAL_FUTURE_BATCH_EXECUTION_ORDER.md`
- `docs/codex/GLOBAL_FUTURE_BATCH_GATE_MATRIX.md`

Product Depth starts only if the user says exactly
`Start Product Depth Train`. PD01-PD18 remain queued/blocked and not started. Product Depth
must deepen Today, Goals, Capture, Plan, and You; it must not add new top-level
tabs, generic dashboards, stacked-card top-level screens, habit tracker modes,
calendar clones, chatbot-first AI surfaces, inbox/notes modes, or enterprise
project-management systems.
