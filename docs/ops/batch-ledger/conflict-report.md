# Batch Duplicate-Work and Conflict Report

Generated UTC: 2026-05-29T02:35:01Z
Owner: BATCH-LEDGER-001
Linear issue: AMB-28

## Status

- Validation: `green`
- Total conflicts: `517`
- Auto-resolved conflicts: `0`

## Counts by conflict type

- `duplicate_stable_id`: `31`
- `missing_source_of_truth_reference`: `17`
- `retired_ia_or_terminology_reference`: `8`
- `same_source_file_targeted_by_multiple_active_batches`: `228`
- `same_surface_multiple_active_batches`: `6`
- `source_only_implementation_missing_proof`: `20`
- `stale_or_unknown_active_status`: `207`

## Counts by recommended action

- `expedite`: `213`
- `finish`: `19`
- `merge`: `260`
- `rewrite`: `25`

## Same surface touched by multiple active batches

### 1. Same surface touched by multiple active items: Capture

- Conflict ID: `AMB28-same_surface_multiple_active_batches-34119984`
- Type: `same_surface_multiple_active_batches`
- Severity: `yellow`
- Recommended action: `expedite`
- Rationale: Many active ledger items touch the same surface; expedite sequence ownership through batch-ledger planning before running more work.
- Linear issue ready: `True`
- Auto-resolved: `False`
- Involved:
  - `repo-audit-baseline` — `docs/codex/repo-audit-baseline.md` (partial_implementation; release proof)
  - `MASTER_CODEX_SYSTEM` — `docs/codex/MASTER_CODEX_SYSTEM.md` (partial_implementation; release proof)
  - `BATCH-09-canon-batch-6-external-action-infrastructure` — `docs/codex/batches/BATCH-09-canon-batch-6-external-action-infrastructure.md` (partial_implementation; release proof)
  - `BATCH-10-canon-batch-7-ambient-surfaces-bundle` — `docs/codex/batches/BATCH-10-canon-batch-7-ambient-surfaces-bundle.md` (partial_implementation; release proof)
  - `BATCH-11-canon-batch-8-ritual-os` — `docs/codex/batches/BATCH-11-canon-batch-8-ritual-os.md` (partial_implementation; release proof)
  - `BATCH-33-intelligence-runtime-integration` — `docs/codex/batches/BATCH-33-intelligence-runtime-integration.md` (partial_implementation; release proof)
  - `Ambitions_2_0_Codex_Execution_Guide` — `docs/codex/Ambitions_2_0_Codex_Execution_Guide.md` (partial_implementation; release proof)
  - `Human_Release_Review_Handoff` — `docs/codex/Human_Release_Review_Handoff.md` (partial_implementation; release proof)
  - `AMBITIONS_3_0_CONTEXT_LOADING_AND_TASK_ROUTING` — `docs/codex/AMBITIONS_3_0_CONTEXT_LOADING_AND_TASK_ROUTING.md` (partial_implementation; release proof)
  - `AMBITIONS_3_0_PROMPT_QUALITY_RUBRIC` — `docs/codex/AMBITIONS_3_0_PROMPT_QUALITY_RUBRIC.md` (partial_implementation; release proof)
  - `BATCH_TRAIN_F04_F06_PROMPT` — `docs/codex/BATCH_TRAIN_F04_F06_PROMPT.md` (partial_implementation; release proof)
  - `BATCH_TRAIN_F07_F09_PROMPT` — `docs/codex/BATCH_TRAIN_F07_F09_PROMPT.md` (partial_implementation; release proof)
  - `F03_5_Today_Architecture_Hardening` — `docs/codex/batch-trains/F03_5_Today_Architecture_Hardening.md` (partial_implementation; release proof)
  - `F04_F06_Step_Closure_Proof_Train` — `docs/codex/batch-trains/F04_F06_Step_Closure_Proof_Train.md` (partial_implementation; release proof)
  - `F07_F09_Capture_Placement_Train` — `docs/codex/batch-trains/F07_F09_Capture_Placement_Train.md` (partial_implementation; release proof)
  - `F10_F12_Plan_Life_Suite_Train` — `docs/codex/batch-trains/F10_F12_Plan_Life_Suite_Train.md` (partial_implementation; release proof)
  - `F13_F14_Goals_You_Trust_Train` — `docs/codex/batch-trains/F13_F14_Goals_You_Trust_Train.md` (partial_implementation; release proof)
  - `F15_F16_F16_5_Legacy_UI_Architecture_Train` — `docs/codex/batch-trains/F15_F16_F16_5_Legacy_UI_Architecture_Train.md` (partial_implementation; release proof)
  - `F17_Shell_Meridian_Train` — `docs/codex/batch-trains/F17_Shell_Meridian_Train.md` (partial_implementation; release proof)
  - `F03_5_Today_Execution_State_Contract_Hardening_Prompt` — `docs/codex/batches/F03_5_Today_Execution_State_Contract_Hardening_Prompt.md` (partial_implementation; release proof)
  - `AMBITIONSOS_AOS_BATCH_GATE_MATRIX` — `docs/codex/AMBITIONSOS_AOS_BATCH_GATE_MATRIX.md` (partial_implementation; release proof)
  - `GLOBAL_BATCH_AUTOMATED_GATE_PROTOCOL` — `docs/codex/GLOBAL_BATCH_AUTOMATED_GATE_PROTOCOL.md` (partial_implementation; release proof)
  - `PXOS_HANDOFF_PACKAGE` — `docs/codex/PXOS_HANDOFF_PACKAGE.md` (partial_implementation; release proof)
  - `REC02_Human_Operator_Release_Proof_Plan` — `docs/codex/REC02_Human_Operator_Release_Proof_Plan.md` (partial_implementation; release proof)
  - `REC05_Human_Review_Packet` — `docs/codex/REC05_Human_Review_Packet.md` (partial_implementation; release proof)
  - `REC06_Release_Evidence_Closure_Handoff` — `docs/codex/REC06_Release_Evidence_Closure_Handoff.md` (partial_implementation; release proof)
  - `SI01_Signature_Interface_Canon_To_SwiftUI_Architecture_Prompt` — `docs/codex/batches/SI01_Signature_Interface_Canon_To_SwiftUI_Architecture_Prompt.md` (partial_implementation; release proof)
  - `SI02_Adaptive_Panel_Action_And_Module_Foundation_Prompt` — `docs/codex/batches/SI02_Adaptive_Panel_Action_And_Module_Foundation_Prompt.md` (partial_implementation; release proof)
  - `SI03_App_Shell_IA_And_Navigation_List_System_Prompt` — `docs/codex/batches/SI03_App_Shell_IA_And_Navigation_List_System_Prompt.md` (partial_implementation; release proof)
  - `SI04_DayTimelineRail_2_0_Prompt` — `docs/codex/batches/SI04_DayTimelineRail_2_0_Prompt.md` (partial_implementation; release proof)
  - `SI06_LifePath_Visualization_System_Prompt` — `docs/codex/batches/SI06_LifePath_Visualization_System_Prompt.md` (partial_implementation; release proof)
  - `SI07_Mission_Control_Lane_Components_Prompt` — `docs/codex/batches/SI07_Mission_Control_Lane_Components_Prompt.md` (partial_implementation; release proof)
  - `SI08_LifeShape_Time_Capacity_Map_Prompt` — `docs/codex/batches/SI08_LifeShape_Time_Capacity_Map_Prompt.md` (partial_implementation; release proof)
  - `SI09_Capture_Atmosphere_Composer_Prompt` — `docs/codex/batches/SI09_Capture_Atmosphere_Composer_Prompt.md` (partial_implementation; release proof)
  - `SI10_Trust_Receipt_Layer_Prompt` — `docs/codex/batches/SI10_Trust_Receipt_Layer_Prompt.md` (partial_implementation; release proof)
  - `SI11_Personal_System_Center_Components_Prompt` — `docs/codex/batches/SI11_Personal_System_Center_Components_Prompt.md` (partial_implementation; release proof)
  - `SI12_Interaction_Motion_Haptics_System_Prompt` — `docs/codex/batches/SI12_Interaction_Motion_Haptics_System_Prompt.md` (partial_implementation; release proof)
  - `SI13_Loading_Empty_Degraded_State_Primitives_Prompt` — `docs/codex/batches/SI13_Loading_Empty_Degraded_State_Primitives_Prompt.md` (partial_implementation; release proof)
  - `SI14_Iconography_Symbol_And_Status_Grammar_Prompt` — `docs/codex/batches/SI14_Iconography_Symbol_And_Status_Grammar_Prompt.md` (partial_implementation; release proof)
  - `SI15_Accessibility_Adaptive_Interface_Pass_Prompt` — `docs/codex/batches/SI15_Accessibility_Adaptive_Interface_Pass_Prompt.md` (partial_implementation; release proof)
  - ... 360 more

### 2. Same surface touched by multiple active items: Goals

- Conflict ID: `AMB28-same_surface_multiple_active_batches-95036910`
- Type: `same_surface_multiple_active_batches`
- Severity: `yellow`
- Recommended action: `expedite`
- Rationale: Many active ledger items touch the same surface; expedite sequence ownership through batch-ledger planning before running more work.
- Linear issue ready: `True`
- Auto-resolved: `False`
- Involved:
  - `repo-audit-baseline` — `docs/codex/repo-audit-baseline.md` (partial_implementation; release proof)
  - `MASTER_CODEX_SYSTEM` — `docs/codex/MASTER_CODEX_SYSTEM.md` (partial_implementation; release proof)
  - `BATCH-09-canon-batch-6-external-action-infrastructure` — `docs/codex/batches/BATCH-09-canon-batch-6-external-action-infrastructure.md` (partial_implementation; release proof)
  - `BATCH-11-canon-batch-8-ritual-os` — `docs/codex/batches/BATCH-11-canon-batch-8-ritual-os.md` (partial_implementation; release proof)
  - `BATCH-33-intelligence-runtime-integration` — `docs/codex/batches/BATCH-33-intelligence-runtime-integration.md` (partial_implementation; release proof)
  - `BATCH-34-product-shell-integration` — `docs/codex/batches/BATCH-34-product-shell-integration.md` (partial_implementation; release proof)
  - `BATCH-37-post-2.0-hardening-secondary-surface-productization` — `docs/codex/batches/BATCH-37-post-2.0-hardening-secondary-surface-productization.md` (partial_implementation; release proof)
  - `Ambitions_2_0_Codex_Execution_Guide` — `docs/codex/Ambitions_2_0_Codex_Execution_Guide.md` (partial_implementation; release proof)
  - `Human_Release_Review_Handoff` — `docs/codex/Human_Release_Review_Handoff.md` (partial_implementation; release proof)
  - `AMBITIONS_3_0_CONTEXT_LOADING_AND_TASK_ROUTING` — `docs/codex/AMBITIONS_3_0_CONTEXT_LOADING_AND_TASK_ROUTING.md` (partial_implementation; release proof)
  - `BATCH_F13_5_GOALS_YOU_TRUST_ARCHITECTURE_CHECKPOINT_PROMPT` — `docs/codex/BATCH_F13_5_GOALS_YOU_TRUST_ARCHITECTURE_CHECKPOINT_PROMPT.md` (partial_implementation; release proof)
  - `BATCH_TRAIN_F04_F06_PROMPT` — `docs/codex/BATCH_TRAIN_F04_F06_PROMPT.md` (partial_implementation; release proof)
  - `BATCH_TRAIN_F13_F14_PROMPT` — `docs/codex/BATCH_TRAIN_F13_F14_PROMPT.md` (partial_implementation; release proof)
  - `F03_5_Today_Architecture_Hardening` — `docs/codex/batch-trains/F03_5_Today_Architecture_Hardening.md` (partial_implementation; release proof)
  - `F04_F06_Step_Closure_Proof_Train` — `docs/codex/batch-trains/F04_F06_Step_Closure_Proof_Train.md` (partial_implementation; release proof)
  - `F07_F09_Capture_Placement_Train` — `docs/codex/batch-trains/F07_F09_Capture_Placement_Train.md` (partial_implementation; release proof)
  - `F10_F12_Plan_Life_Suite_Train` — `docs/codex/batch-trains/F10_F12_Plan_Life_Suite_Train.md` (partial_implementation; release proof)
  - `F13_F14_Goals_You_Trust_Train` — `docs/codex/batch-trains/F13_F14_Goals_You_Trust_Train.md` (partial_implementation; release proof)
  - `F15_F16_F16_5_Legacy_UI_Architecture_Train` — `docs/codex/batch-trains/F15_F16_F16_5_Legacy_UI_Architecture_Train.md` (partial_implementation; release proof)
  - `F17_Shell_Meridian_Train` — `docs/codex/batch-trains/F17_Shell_Meridian_Train.md` (partial_implementation; release proof)
  - `F03_5_Today_Execution_State_Contract_Hardening_Prompt` — `docs/codex/batches/F03_5_Today_Execution_State_Contract_Hardening_Prompt.md` (partial_implementation; release proof)
  - `F17_Shell_Meridian_Planning_And_Readiness_Audit_Prompt` — `docs/codex/batches/F17_Shell_Meridian_Planning_And_Readiness_Audit_Prompt.md` (partial_implementation; release proof)
  - `AMBITIONSOS_AOS_BATCH_GATE_MATRIX` — `docs/codex/AMBITIONSOS_AOS_BATCH_GATE_MATRIX.md` (partial_implementation; release proof)
  - `AMBITIONS_PROMPT_QUALITY_GATE` — `docs/codex/AMBITIONS_PROMPT_QUALITY_GATE.md` (partial_implementation; release proof)
  - `GLOBAL_BATCH_AUTOMATED_GATE_PROTOCOL` — `docs/codex/GLOBAL_BATCH_AUTOMATED_GATE_PROTOCOL.md` (partial_implementation; release proof)
  - `PXOS_HANDOFF_PACKAGE` — `docs/codex/PXOS_HANDOFF_PACKAGE.md` (partial_implementation; release proof)
  - `REC02_Human_Operator_Release_Proof_Plan` — `docs/codex/REC02_Human_Operator_Release_Proof_Plan.md` (partial_implementation; release proof)
  - `REC05_Human_Review_Packet` — `docs/codex/REC05_Human_Review_Packet.md` (partial_implementation; release proof)
  - `REC02_Human_Operator_Release_Proof_Plan_Prompt` — `docs/codex/batches/REC02_Human_Operator_Release_Proof_Plan_Prompt.md` (partial_implementation; release proof)
  - `REC03_Validation_Log_Ledger_Closure_Prompt` — `docs/codex/batches/REC03_Validation_Log_Ledger_Closure_Prompt.md` (partial_implementation; release proof)
  - `REC04_Release_Claim_Copy_Guard_Prompt` — `docs/codex/batches/REC04_Release_Claim_Copy_Guard_Prompt.md` (partial_implementation; release proof)
  - `REC05_Human_Review_Packet_Prompt` — `docs/codex/batches/REC05_Human_Review_Packet_Prompt.md` (partial_implementation; release proof)
  - `REC06_Release_Evidence_Closure_Handoff_Prompt` — `docs/codex/batches/REC06_Release_Evidence_Closure_Handoff_Prompt.md` (partial_implementation; release proof)
  - `SI04_DayTimelineRail_2_0_Prompt` — `docs/codex/batches/SI04_DayTimelineRail_2_0_Prompt.md` (partial_implementation; release proof)
  - `SI06_LifePath_Visualization_System_Prompt` — `docs/codex/batches/SI06_LifePath_Visualization_System_Prompt.md` (partial_implementation; release proof)
  - `SI07_Mission_Control_Lane_Components_Prompt` — `docs/codex/batches/SI07_Mission_Control_Lane_Components_Prompt.md` (partial_implementation; release proof)
  - `SI09_Capture_Atmosphere_Composer_Prompt` — `docs/codex/batches/SI09_Capture_Atmosphere_Composer_Prompt.md` (partial_implementation; release proof)
  - `DAV_PRODUCT_EXPERIENCE_SCORECARD` — `docs/codex/DAV_PRODUCT_EXPERIENCE_SCORECARD.md` (partial_implementation; release proof)
  - `EXTERNAL_BRAIN_EXECUTION_PLAYBOOK` — `docs/codex/EXTERNAL_BRAIN_EXECUTION_PLAYBOOK.md` (partial_implementation; release proof)
  - `PREVIEW_SCENARIO_COVERAGE_MATRIX` — `docs/codex/PREVIEW_SCENARIO_COVERAGE_MATRIX.md` (partial_implementation; release proof)
  - ... 346 more

### 3. Same surface touched by multiple active items: Time

- Conflict ID: `AMB28-same_surface_multiple_active_batches-31837432`
- Type: `same_surface_multiple_active_batches`
- Severity: `yellow`
- Recommended action: `expedite`
- Rationale: Many active ledger items touch the same surface; expedite sequence ownership through batch-ledger planning before running more work.
- Linear issue ready: `True`
- Auto-resolved: `False`
- Involved:
  - `repo-audit-baseline` — `docs/codex/repo-audit-baseline.md` (partial_implementation; release proof)
  - `MASTER_CODEX_SYSTEM` — `docs/codex/MASTER_CODEX_SYSTEM.md` (partial_implementation; release proof)
  - `BATCH-11-canon-batch-8-ritual-os` — `docs/codex/batches/BATCH-11-canon-batch-8-ritual-os.md` (partial_implementation; release proof)
  - `Release_Candidate_Review_Checklist` — `docs/codex/Release_Candidate_Review_Checklist.md` (partial_implementation; release proof)
  - `Ambitions_2_0_Codex_Execution_Guide` — `docs/codex/Ambitions_2_0_Codex_Execution_Guide.md` (partial_implementation; release proof)
  - `Human_Release_Review_Handoff` — `docs/codex/Human_Release_Review_Handoff.md` (partial_implementation; release proof)
  - `AMBITIONS_3_0_LARGE_BATCH_AND_COMPACT_RECOVERY_PROTOCOL` — `docs/codex/AMBITIONS_3_0_LARGE_BATCH_AND_COMPACT_RECOVERY_PROTOCOL.md` (partial_implementation; release proof)
  - `BATCH_TRAIN_F10_F12_PROMPT` — `docs/codex/BATCH_TRAIN_F10_F12_PROMPT.md` (partial_implementation; release proof)
  - `AMBITIONSOS_AOS_BATCH_GATE_MATRIX` — `docs/codex/AMBITIONSOS_AOS_BATCH_GATE_MATRIX.md` (partial_implementation; release proof)
  - `AMBITIONSOS_AOS_RELEASE_CLAIM_BOUNDARY` — `docs/codex/AMBITIONSOS_AOS_RELEASE_CLAIM_BOUNDARY.md` (partial_implementation; release proof)
  - `GLOBAL_BATCH_AUTOMATED_GATE_PROTOCOL` — `docs/codex/GLOBAL_BATCH_AUTOMATED_GATE_PROTOCOL.md` (partial_implementation; release proof)
  - `GLOBAL_BATCH_REPAIR_LOOP_PROTOCOL` — `docs/codex/GLOBAL_BATCH_REPAIR_LOOP_PROTOCOL.md` (partial_implementation; release proof)
  - `PXOS_HANDOFF_PACKAGE` — `docs/codex/PXOS_HANDOFF_PACKAGE.md` (partial_implementation; release proof)
  - `REC02_Human_Operator_Release_Proof_Plan` — `docs/codex/REC02_Human_Operator_Release_Proof_Plan.md` (partial_implementation; release proof)
  - `REC05_Human_Review_Packet` — `docs/codex/REC05_Human_Review_Packet.md` (partial_implementation; release proof)
  - `REC03_Validation_Log_Ledger_Closure_Prompt` — `docs/codex/batches/REC03_Validation_Log_Ledger_Closure_Prompt.md` (partial_implementation; release proof)
  - `SI08_LifeShape_Time_Capacity_Map_Prompt` — `docs/codex/batches/SI08_LifeShape_Time_Capacity_Map_Prompt.md` (partial_implementation; release proof)
  - `DAV_PRODUCT_EXPERIENCE_SCORECARD` — `docs/codex/DAV_PRODUCT_EXPERIENCE_SCORECARD.md` (partial_implementation; release proof)
  - `EXTERNAL_BRAIN_EXECUTION_PLAYBOOK` — `docs/codex/EXTERNAL_BRAIN_EXECUTION_PLAYBOOK.md` (partial_implementation; release proof)
  - `EXTERNAL_BRAIN_RISK_REGISTER` — `docs/codex/EXTERNAL_BRAIN_RISK_REGISTER.md` (partial_implementation; release proof)
  - `PREVIEW_SCENARIO_COVERAGE_MATRIX` — `docs/codex/PREVIEW_SCENARIO_COVERAGE_MATRIX.md` (partial_implementation; release proof)
  - `PXEQ_PRODUCT_EXPERIENCE_EQUIVALENCE_GATE` — `docs/codex/PXEQ_PRODUCT_EXPERIENCE_EQUIVALENCE_GATE.md` (partial_implementation; release proof)
  - `DAV01_DAV15_DYNAMIC_ADAPTIVE_VISUAL_SYSTEM_TRAIN` — `docs/codex/batch-trains/DAV01_DAV15_DYNAMIC_ADAPTIVE_VISUAL_SYSTEM_TRAIN.md` (partial_implementation; release proof)
  - `EB01_EB40_EXTERNAL_BRAIN_FOUNDATION_TRAIN` — `docs/codex/batch-trains/EB01_EB40_EXTERNAL_BRAIN_FOUNDATION_TRAIN.md` (partial_implementation; release proof)
  - `AMBITIONS_4_0_EXTERNAL_BRAIN_CLOSEOUT` — `docs/codex/AMBITIONS_4_0_EXTERNAL_BRAIN_CLOSEOUT.md` (partial_implementation; release proof)
  - `LDI01_LDI22_LIVING_DREAM_INTELLIGENCE_TRAIN` — `docs/codex/batch-trains/LDI01_LDI22_LIVING_DREAM_INTELLIGENCE_TRAIN.md` (partial_implementation; release proof)
  - `LDI09_Eligibility_And_Deadline_Runtime_Prompt` — `docs/codex/batches/LDI09_Eligibility_And_Deadline_Runtime_Prompt.md` (partial_implementation; release proof)
  - `LDI12_Capacity_And_Commitment_Time_Bridge_Prompt` — `docs/codex/batches/LDI12_Capacity_And_Commitment_Time_Bridge_Prompt.md` (partial_implementation; release proof)
  - `CODEX_QUALITY_SYSTEM_GATE_MATRIX` — `docs/codex/CODEX_QUALITY_SYSTEM_GATE_MATRIX.md` (partial_implementation; release proof)
  - `FLAGSHIP_COMPLETION_GATE_MATRIX` — `docs/codex/FLAGSHIP_COMPLETION_GATE_MATRIX.md` (partial_implementation; release proof)
  - `CQS01_CQS24_CODEX_QUALITY_SYSTEM_TRAIN` — `docs/codex/batch-trains/CQS01_CQS24_CODEX_QUALITY_SYSTEM_TRAIN.md` (partial_implementation; release proof)
  - `PFC01_PFC40_PLATFORM_FRAMEWORK_COMPLIANCE_TRAIN` — `docs/codex/batch-trains/PFC01_PFC40_PLATFORM_FRAMEWORK_COMPLIANCE_TRAIN.md` (partial_implementation; release proof)
  - `AQOS_GOLDEN_SCENARIO_AND_STATE_COVERAGE` — `docs/codex/quality/AQOS_GOLDEN_SCENARIO_AND_STATE_COVERAGE.md` (partial_implementation; release proof)
  - `MEG01_ADVANCED_RENDERING_ELIGIBILITY_GATE` — `docs/codex/visual-quality/MEG01_ADVANCED_RENDERING_ELIGIBILITY_GATE.md` (partial_implementation; release proof)
  - `AMBITIONSOS_AOS_EVIDENCE_LEDGER` — `docs/codex/AMBITIONSOS_AOS_EVIDENCE_LEDGER.md` (partial_implementation; release proof)
  - `AMBITIONSOS_AOS_TEST_IMPACT_MATRIX` — `docs/codex/AMBITIONSOS_AOS_TEST_IMPACT_MATRIX.md` (partial_implementation; release proof)
  - `AMBITIONSOS_AOS_TRACEABILITY_MATRIX` — `docs/codex/AMBITIONSOS_AOS_TRACEABILITY_MATRIX.md` (partial_implementation; release proof)
  - `GLOBAL_HPS_COMPLETION_ORDER_OVERLAY` — `docs/codex/GLOBAL_HPS_COMPLETION_ORDER_OVERLAY.md` (partial_implementation; release proof)
  - `SOURCE_ATLAS_CODEX_OS_UPGRADE_MAP` — `docs/codex/SOURCE_ATLAS_CODEX_OS_UPGRADE_MAP.md` (partial_implementation; release proof)
  - `SOURCE_ATLAS_GATE_MATRIX` — `docs/codex/SOURCE_ATLAS_GATE_MATRIX.md` (partial_implementation; release proof)
  - ... 307 more

### 4. Same surface touched by multiple active items: Today

- Conflict ID: `AMB28-same_surface_multiple_active_batches-99117770`
- Type: `same_surface_multiple_active_batches`
- Severity: `yellow`
- Recommended action: `expedite`
- Rationale: Many active ledger items touch the same surface; expedite sequence ownership through batch-ledger planning before running more work.
- Linear issue ready: `True`
- Auto-resolved: `False`
- Involved:
  - `repo-audit-baseline` — `docs/codex/repo-audit-baseline.md` (partial_implementation; release proof)
  - `MASTER_CODEX_SYSTEM` — `docs/codex/MASTER_CODEX_SYSTEM.md` (partial_implementation; release proof)
  - `BATCH-09-canon-batch-6-external-action-infrastructure` — `docs/codex/batches/BATCH-09-canon-batch-6-external-action-infrastructure.md` (partial_implementation; release proof)
  - `BATCH-11-canon-batch-8-ritual-os` — `docs/codex/batches/BATCH-11-canon-batch-8-ritual-os.md` (partial_implementation; release proof)
  - `BATCH-33-intelligence-runtime-integration` — `docs/codex/batches/BATCH-33-intelligence-runtime-integration.md` (partial_implementation; release proof)
  - `BATCH-34-product-shell-integration` — `docs/codex/batches/BATCH-34-product-shell-integration.md` (partial_implementation; release proof)
  - `BATCH-37-post-2.0-hardening-secondary-surface-productization` — `docs/codex/batches/BATCH-37-post-2.0-hardening-secondary-surface-productization.md` (partial_implementation; release proof)
  - `Ambitions_2_0_Codex_Execution_Guide` — `docs/codex/Ambitions_2_0_Codex_Execution_Guide.md` (partial_implementation; release proof)
  - `Human_Release_Review_Handoff` — `docs/codex/Human_Release_Review_Handoff.md` (partial_implementation; release proof)
  - `AMBITIONS_3_0_CONTEXT_LOADING_AND_TASK_ROUTING` — `docs/codex/AMBITIONS_3_0_CONTEXT_LOADING_AND_TASK_ROUTING.md` (partial_implementation; release proof)
  - `BATCH_F03_5_TODAY_ARCHITECTURE_HARDENING_PROMPT` — `docs/codex/BATCH_F03_5_TODAY_ARCHITECTURE_HARDENING_PROMPT.md` (partial_implementation; release proof)
  - `BATCH_TRAIN_F04_F06_PROMPT` — `docs/codex/BATCH_TRAIN_F04_F06_PROMPT.md` (partial_implementation; release proof)
  - `BATCH_TRAIN_F10_F12_PROMPT` — `docs/codex/BATCH_TRAIN_F10_F12_PROMPT.md` (partial_implementation; release proof)
  - `F03_5_Today_Architecture_Hardening` — `docs/codex/batch-trains/F03_5_Today_Architecture_Hardening.md` (partial_implementation; release proof)
  - `F04_F06_Step_Closure_Proof_Train` — `docs/codex/batch-trains/F04_F06_Step_Closure_Proof_Train.md` (partial_implementation; release proof)
  - `F07_F09_Capture_Placement_Train` — `docs/codex/batch-trains/F07_F09_Capture_Placement_Train.md` (partial_implementation; release proof)
  - `F10_F12_Plan_Life_Suite_Train` — `docs/codex/batch-trains/F10_F12_Plan_Life_Suite_Train.md` (partial_implementation; release proof)
  - `F13_F14_Goals_You_Trust_Train` — `docs/codex/batch-trains/F13_F14_Goals_You_Trust_Train.md` (partial_implementation; release proof)
  - `F15_F16_F16_5_Legacy_UI_Architecture_Train` — `docs/codex/batch-trains/F15_F16_F16_5_Legacy_UI_Architecture_Train.md` (partial_implementation; release proof)
  - `F17_Shell_Meridian_Train` — `docs/codex/batch-trains/F17_Shell_Meridian_Train.md` (partial_implementation; release proof)
  - `F03_5_Today_Execution_State_Contract_Hardening_Prompt` — `docs/codex/batches/F03_5_Today_Execution_State_Contract_Hardening_Prompt.md` (partial_implementation; release proof)
  - `F17_Shell_Meridian_Planning_And_Readiness_Audit_Prompt` — `docs/codex/batches/F17_Shell_Meridian_Planning_And_Readiness_Audit_Prompt.md` (partial_implementation; release proof)
  - `AMBITIONSOS_AOS_BATCH_GATE_MATRIX` — `docs/codex/AMBITIONSOS_AOS_BATCH_GATE_MATRIX.md` (partial_implementation; release proof)
  - `GLOBAL_BATCH_AUTOMATED_GATE_PROTOCOL` — `docs/codex/GLOBAL_BATCH_AUTOMATED_GATE_PROTOCOL.md` (partial_implementation; release proof)
  - `PXOS_HANDOFF_PACKAGE` — `docs/codex/PXOS_HANDOFF_PACKAGE.md` (partial_implementation; release proof)
  - `REC02_Human_Operator_Release_Proof_Plan` — `docs/codex/REC02_Human_Operator_Release_Proof_Plan.md` (partial_implementation; release proof)
  - `REC05_Human_Review_Packet` — `docs/codex/REC05_Human_Review_Packet.md` (partial_implementation; release proof)
  - `SI04_DayTimelineRail_2_0_Prompt` — `docs/codex/batches/SI04_DayTimelineRail_2_0_Prompt.md` (partial_implementation; release proof)
  - `DAV_PRODUCT_EXPERIENCE_SCORECARD` — `docs/codex/DAV_PRODUCT_EXPERIENCE_SCORECARD.md` (partial_implementation; release proof)
  - `EXTERNAL_BRAIN_EXECUTION_PLAYBOOK` — `docs/codex/EXTERNAL_BRAIN_EXECUTION_PLAYBOOK.md` (partial_implementation; release proof)
  - `PREVIEW_SCENARIO_COVERAGE_MATRIX` — `docs/codex/PREVIEW_SCENARIO_COVERAGE_MATRIX.md` (partial_implementation; release proof)
  - `PXEQ_PRODUCT_EXPERIENCE_EQUIVALENCE_GATE` — `docs/codex/PXEQ_PRODUCT_EXPERIENCE_EQUIVALENCE_GATE.md` (partial_implementation; release proof)
  - `DAV01_DAV15_DYNAMIC_ADAPTIVE_VISUAL_SYSTEM_TRAIN` — `docs/codex/batch-trains/DAV01_DAV15_DYNAMIC_ADAPTIVE_VISUAL_SYSTEM_TRAIN.md` (partial_implementation; release proof)
  - `EB01_EB40_EXTERNAL_BRAIN_FOUNDATION_TRAIN` — `docs/codex/batch-trains/EB01_EB40_EXTERNAL_BRAIN_FOUNDATION_TRAIN.md` (partial_implementation; release proof)
  - `DAV01_Dynamic_Visual_Source_Truth_And_Surface_Map_Prompt` — `docs/codex/batches/DAV01_Dynamic_Visual_Source_Truth_And_Surface_Map_Prompt.md` (partial_implementation; release proof)
  - `DAV02_Reusable_Living_Visual_Primitives_Implementation_Prompt` — `docs/codex/batches/DAV02_Reusable_Living_Visual_Primitives_Implementation_Prompt.md` (partial_implementation; release proof)
  - `EB01_External_Brain_Source_Truth_And_Kernel_Architecture_Prompt` — `docs/codex/batches/EB01_External_Brain_Source_Truth_And_Kernel_Architecture_Prompt.md` (partial_implementation; release proof)
  - `EB02_Universal_Capture_Canon_And_Domain_Model_Prompt` — `docs/codex/batches/EB02_Universal_Capture_Canon_And_Domain_Model_Prompt.md` (partial_implementation; release proof)
  - `EB03_Universal_Capture_Composer_And_Routing_Prompt` — `docs/codex/batches/EB03_Universal_Capture_Composer_And_Routing_Prompt.md` (partial_implementation; release proof)
  - `EB04_Capture_Classification_And_Clarification_Prompt` — `docs/codex/batches/EB04_Capture_Classification_And_Clarification_Prompt.md` (partial_implementation; release proof)
  - ... 323 more

### 5. Same surface touched by multiple active items: You

- Conflict ID: `AMB28-same_surface_multiple_active_batches-7805667`
- Type: `same_surface_multiple_active_batches`
- Severity: `yellow`
- Recommended action: `expedite`
- Rationale: Many active ledger items touch the same surface; expedite sequence ownership through batch-ledger planning before running more work.
- Linear issue ready: `True`
- Auto-resolved: `False`
- Involved:
  - `repo-audit-baseline` — `docs/codex/repo-audit-baseline.md` (partial_implementation; release proof)
  - `MASTER_CODEX_SYSTEM` — `docs/codex/MASTER_CODEX_SYSTEM.md` (partial_implementation; release proof)
  - `BATCH-34-product-shell-integration` — `docs/codex/batches/BATCH-34-product-shell-integration.md` (partial_implementation; release proof)
  - `BATCH-37-post-2.0-hardening-secondary-surface-productization` — `docs/codex/batches/BATCH-37-post-2.0-hardening-secondary-surface-productization.md` (partial_implementation; release proof)
  - `Ambitions_2_0_Codex_Execution_Guide` — `docs/codex/Ambitions_2_0_Codex_Execution_Guide.md` (partial_implementation; release proof)
  - `Human_Release_Review_Handoff` — `docs/codex/Human_Release_Review_Handoff.md` (partial_implementation; release proof)
  - `AMBITIONS_3_0_CONTEXT_LOADING_AND_TASK_ROUTING` — `docs/codex/AMBITIONS_3_0_CONTEXT_LOADING_AND_TASK_ROUTING.md` (partial_implementation; release proof)
  - `BATCH_F03_5_TODAY_ARCHITECTURE_HARDENING_PROMPT` — `docs/codex/BATCH_F03_5_TODAY_ARCHITECTURE_HARDENING_PROMPT.md` (partial_implementation; release proof)
  - `BATCH_F13_5_GOALS_YOU_TRUST_ARCHITECTURE_CHECKPOINT_PROMPT` — `docs/codex/BATCH_F13_5_GOALS_YOU_TRUST_ARCHITECTURE_CHECKPOINT_PROMPT.md` (partial_implementation; release proof)
  - `BATCH_F16_5_SWIFTUI_ARCHITECTURE_HARDENING_PROMPT` — `docs/codex/BATCH_F16_5_SWIFTUI_ARCHITECTURE_HARDENING_PROMPT.md` (partial_implementation; release proof)
  - `BATCH_F17_SHELL_MERIDIAN_PLANNING_PROMPT` — `docs/codex/BATCH_F17_SHELL_MERIDIAN_PLANNING_PROMPT.md` (partial_implementation; release proof)
  - `BATCH_TRAIN_F04_F06_PROMPT` — `docs/codex/BATCH_TRAIN_F04_F06_PROMPT.md` (partial_implementation; release proof)
  - `BATCH_TRAIN_F07_F09_PROMPT` — `docs/codex/BATCH_TRAIN_F07_F09_PROMPT.md` (partial_implementation; release proof)
  - `BATCH_TRAIN_F10_F12_PROMPT` — `docs/codex/BATCH_TRAIN_F10_F12_PROMPT.md` (partial_implementation; release proof)
  - `BATCH_TRAIN_F13_F14_PROMPT` — `docs/codex/BATCH_TRAIN_F13_F14_PROMPT.md` (partial_implementation; release proof)
  - `BATCH_TRAIN_F15_F16_F16_5_PROMPT` — `docs/codex/BATCH_TRAIN_F15_F16_F16_5_PROMPT.md` (partial_implementation; release proof)
  - `BATCH_TRAIN_RUNNER_PROMPT` — `docs/codex/BATCH_TRAIN_RUNNER_PROMPT.md` (partial_implementation; release proof)
  - `F03_5_Today_Architecture_Hardening` — `docs/codex/batch-trains/F03_5_Today_Architecture_Hardening.md` (partial_implementation; release proof)
  - `F04_F06_Step_Closure_Proof_Train` — `docs/codex/batch-trains/F04_F06_Step_Closure_Proof_Train.md` (partial_implementation; release proof)
  - `F07_F09_Capture_Placement_Train` — `docs/codex/batch-trains/F07_F09_Capture_Placement_Train.md` (partial_implementation; release proof)
  - `F10_F12_Plan_Life_Suite_Train` — `docs/codex/batch-trains/F10_F12_Plan_Life_Suite_Train.md` (partial_implementation; release proof)
  - `F13_F14_Goals_You_Trust_Train` — `docs/codex/batch-trains/F13_F14_Goals_You_Trust_Train.md` (partial_implementation; release proof)
  - `F15_F16_F16_5_Legacy_UI_Architecture_Train` — `docs/codex/batch-trains/F15_F16_F16_5_Legacy_UI_Architecture_Train.md` (partial_implementation; release proof)
  - `F17_Shell_Meridian_Train` — `docs/codex/batch-trains/F17_Shell_Meridian_Train.md` (partial_implementation; release proof)
  - `F03_5_Today_Execution_State_Contract_Hardening_Prompt` — `docs/codex/batches/F03_5_Today_Execution_State_Contract_Hardening_Prompt.md` (partial_implementation; release proof)
  - `F17_Shell_Meridian_Planning_And_Readiness_Audit_Prompt` — `docs/codex/batches/F17_Shell_Meridian_Planning_And_Readiness_Audit_Prompt.md` (partial_implementation; release proof)
  - `AMBITIONSOS_AOS_BATCH_GATE_MATRIX` — `docs/codex/AMBITIONSOS_AOS_BATCH_GATE_MATRIX.md` (partial_implementation; release proof)
  - `GLOBAL_BATCH_AUTOMATED_GATE_PROTOCOL` — `docs/codex/GLOBAL_BATCH_AUTOMATED_GATE_PROTOCOL.md` (partial_implementation; release proof)
  - `PXOS_HANDOFF_PACKAGE` — `docs/codex/PXOS_HANDOFF_PACKAGE.md` (partial_implementation; release proof)
  - `REC02_Human_Operator_Release_Proof_Plan` — `docs/codex/REC02_Human_Operator_Release_Proof_Plan.md` (partial_implementation; release proof)
  - `REC05_Human_Review_Packet` — `docs/codex/REC05_Human_Review_Packet.md` (partial_implementation; release proof)
  - `SI03_App_Shell_IA_And_Navigation_List_System_Prompt` — `docs/codex/batches/SI03_App_Shell_IA_And_Navigation_List_System_Prompt.md` (partial_implementation; release proof)
  - `SI04_DayTimelineRail_2_0_Prompt` — `docs/codex/batches/SI04_DayTimelineRail_2_0_Prompt.md` (partial_implementation; release proof)
  - `SI07_Mission_Control_Lane_Components_Prompt` — `docs/codex/batches/SI07_Mission_Control_Lane_Components_Prompt.md` (partial_implementation; release proof)
  - `SI11_Personal_System_Center_Components_Prompt` — `docs/codex/batches/SI11_Personal_System_Center_Components_Prompt.md` (partial_implementation; release proof)
  - `SI15_Accessibility_Adaptive_Interface_Pass_Prompt` — `docs/codex/batches/SI15_Accessibility_Adaptive_Interface_Pass_Prompt.md` (partial_implementation; release proof)
  - `CODEX_OS_PEAK_OPERATING_PROTOCOL` — `docs/codex/CODEX_OS_PEAK_OPERATING_PROTOCOL.md` (partial_implementation; release proof)
  - `DAV_PRODUCT_EXPERIENCE_SCORECARD` — `docs/codex/DAV_PRODUCT_EXPERIENCE_SCORECARD.md` (partial_implementation; release proof)
  - `EXTERNAL_BRAIN_EXECUTION_PLAYBOOK` — `docs/codex/EXTERNAL_BRAIN_EXECUTION_PLAYBOOK.md` (partial_implementation; release proof)
  - `EXTERNAL_BRAIN_RISK_REGISTER` — `docs/codex/EXTERNAL_BRAIN_RISK_REGISTER.md` (partial_implementation; release proof)
  - ... 336 more

### 6. Same surface touched by multiple active items: Pulse

- Conflict ID: `AMB28-same_surface_multiple_active_batches-32360271`
- Type: `same_surface_multiple_active_batches`
- Severity: `yellow`
- Recommended action: `merge`
- Rationale: Multiple active ledger items touch the same surface; review sequence ownership and merge overlapping work.
- Linear issue ready: `True`
- Auto-resolved: `False`
- Involved:
  - `DAV_PRODUCT_EXPERIENCE_SCORECARD` — `docs/codex/DAV_PRODUCT_EXPERIENCE_SCORECARD.md` (partial_implementation; release proof)
  - `DAV02_Reusable_Living_Visual_Primitives_Implementation_Prompt` — `docs/codex/batches/DAV02_Reusable_Living_Visual_Primitives_Implementation_Prompt.md` (partial_implementation; release proof)
  - `DAV09_TrustReceiptStack_EvidenceLabels_And_ProofPulse_Implementation_Prompt` — `docs/codex/batches/DAV09_TrustReceiptStack_EvidenceLabels_And_ProofPulse_Implementation_Prompt.md` (partial_implementation; release proof)
  - `DAV10_AdaptiveMotion_ReduceMotion_And_StateTransitions_Prompt` — `docs/codex/batches/DAV10_AdaptiveMotion_ReduceMotion_And_StateTransitions_Prompt.md` (partial_implementation; release proof)
  - `POST_BATCH_GATE_REGISTRY` — `docs/codex/POST_BATCH_GATE_REGISTRY.md` (partial_implementation; release proof)
  - `VISUAL_CANON_MOAT_IMPLEMENTATION_OVERLAY` — `docs/codex/VISUAL_CANON_MOAT_IMPLEMENTATION_OVERLAY.md` (partial_implementation; release proof)
  - `AMB-POST23-01-TRUTH-AUDIT` — `docs/codex/reports/AMB-POST23-01-TRUTH-AUDIT.md` (partial_implementation; release proof)
  - `TRAIN_04C_SOURCE_ATLAS_RUNTIME_COMPILER_BRIDGE` — `prompts/trains/ios26-flagship/TRAIN_04C_SOURCE_ATLAS_RUNTIME_COMPILER_BRIDGE.md` (partial_implementation; release proof)
  - `LINEAR_CONTROL_PLANE` — `docs/codex/LINEAR_CONTROL_PLANE.md` (partial_implementation; release proof)
  - `PXEQ_SURFACE_BEHAVIOR_MATRIX` — `docs/codex/PXEQ_SURFACE_BEHAVIOR_MATRIX.md` (unknown; release proof)
  - `SIG_EMOTIONAL_DESIGN_MOMENTS_MAP` — `docs/codex/SIG_EMOTIONAL_DESIGN_MOMENTS_MAP.md` (unknown; release proof)
  - `OBJECT_OS_SURFACE_MAP` — `docs/codex/OBJECT_OS_SURFACE_MAP.md` (unknown; release proof)


## Same source file targeted by multiple active batches

### 1. Same source file targeted by multiple active items: Native/Ambitions/App/AmbitionsRootView.swift

- Conflict ID: `AMB28-same_source_file_targeted_by_multiple_active_batches-80026133`
- Type: `same_source_file_targeted_by_multiple_active_batches`
- Severity: `yellow`
- Recommended action: `merge`
- Rationale: Multiple active ledger items reference the same source file; merge, sequence, or assign ownership before implementation.
- Linear issue ready: `True`
- Auto-resolved: `False`
- Involved:
  - `repo-audit-baseline` — `docs/codex/repo-audit-baseline.md` (partial_implementation; release proof)
  - `AMB-REPO-AUTHORITY-00-SAFETY-SNAPSHOT` — `prompts/batches/AMB-REPO-AUTHORITY-00-SAFETY-SNAPSHOT.md` (partial_implementation; release proof)
  - `AMB-REPO-AUTHORITY-02-FRONTEND-VISUAL-ENCYCLOPEDIA` — `prompts/batches/AMB-REPO-AUTHORITY-02-FRONTEND-VISUAL-ENCYCLOPEDIA.md` (partial_implementation; release proof)
  - `AMB-REPO-AUTHORITY-06-ACTIVE-DRIFT-REPAIR` — `prompts/batches/AMB-REPO-AUTHORITY-06-ACTIVE-DRIFT-REPAIR.md` (partial_implementation; release proof)
  - `ALIGN-01-NAMING` — `prompts/batches/ALIGN-01-NAMING.md` (partial_implementation; release proof)
  - `TOP-LEVEL-IA-PLAN-LEAK-REGRESSION-01` — `prompts/batches/TOP-LEVEL-IA-PLAN-LEAK-REGRESSION-01.md` (partial_implementation; release proof)
  - `AQOS_BATCH_IMPACT_CLASSIFIER` — `docs/codex/quality/AQOS_BATCH_IMPACT_CLASSIFIER.md` (unknown; release proof)
  - `FRONTEND_SHELL_BOTTOM_CHROME_OWNERSHIP_GATE` — `docs/codex/FRONTEND_SHELL_BOTTOM_CHROME_OWNERSHIP_GATE.md` (unknown; release proof)
  - `existing-code-champion-coverage` — `docs/codex/existing-code-champion-coverage.yml` (unknown; release proof)

### 2. Same source file targeted by multiple active items: Native/Ambitions/App/AppContainerFactory.swift

- Conflict ID: `AMB28-same_source_file_targeted_by_multiple_active_batches-44570005`
- Type: `same_source_file_targeted_by_multiple_active_batches`
- Severity: `yellow`
- Recommended action: `merge`
- Rationale: Multiple active ledger items reference the same source file; merge, sequence, or assign ownership before implementation.
- Linear issue ready: `True`
- Auto-resolved: `False`
- Involved:
  - `repo-audit-baseline` — `docs/codex/repo-audit-baseline.md` (partial_implementation; release proof)
  - `BACKEND-FINAL-FORM-LOCAL-FIRST-HUMAN-01` — `prompts/batches/BACKEND-FINAL-FORM-LOCAL-FIRST-HUMAN-01.md` (partial_implementation; release proof)
  - `existing-code-champion-coverage` — `docs/codex/existing-code-champion-coverage.yml` (unknown; release proof)

### 3. Same source file targeted by multiple active items: Native/Ambitions/App/AppExternalRouting.swift

- Conflict ID: `AMB28-same_source_file_targeted_by_multiple_active_batches-23753088`
- Type: `same_source_file_targeted_by_multiple_active_batches`
- Severity: `yellow`
- Recommended action: `merge`
- Rationale: Multiple active ledger items reference the same source file; merge, sequence, or assign ownership before implementation.
- Linear issue ready: `True`
- Auto-resolved: `False`
- Involved:
  - `repo-audit-baseline` — `docs/codex/repo-audit-baseline.md` (partial_implementation; release proof)
  - `PFC18_App_Intents_Shortcuts_Implementation_And_Tests_Prompt` — `docs/codex/batches/PFC18_App_Intents_Shortcuts_Implementation_And_Tests_Prompt.md` (partial_implementation; release proof)
  - `existing-code-champion-coverage` — `docs/codex/existing-code-champion-coverage.yml` (unknown; release proof)

### 4. Same source file targeted by multiple active items: Native/Ambitions/App/AppIntentLaunchRouter.swift

- Conflict ID: `AMB28-same_source_file_targeted_by_multiple_active_batches-9589878`
- Type: `same_source_file_targeted_by_multiple_active_batches`
- Severity: `yellow`
- Recommended action: `merge`
- Rationale: Multiple active ledger items reference the same source file; merge, sequence, or assign ownership before implementation.
- Linear issue ready: `True`
- Auto-resolved: `False`
- Involved:
  - `PFC18_App_Intents_Shortcuts_Implementation_And_Tests_Prompt` — `docs/codex/batches/PFC18_App_Intents_Shortcuts_Implementation_And_Tests_Prompt.md` (partial_implementation; release proof)
  - `existing-code-champion-coverage` — `docs/codex/existing-code-champion-coverage.yml` (unknown; release proof)

### 5. Same source file targeted by multiple active items: Native/Ambitions/App/AppMeridianShell.swift

- Conflict ID: `AMB28-same_source_file_targeted_by_multiple_active_batches-36349612`
- Type: `same_source_file_targeted_by_multiple_active_batches`
- Severity: `yellow`
- Recommended action: `merge`
- Rationale: Multiple active ledger items reference the same source file; merge, sequence, or assign ownership before implementation.
- Linear issue ready: `True`
- Auto-resolved: `False`
- Involved:
  - `FCP08_Ambition_Meridian_Shell_Prompt` — `docs/codex/batches/FCP08_Ambition_Meridian_Shell_Prompt.md` (unknown; release proof)
  - `AQOS_BATCH_IMPACT_CLASSIFIER` — `docs/codex/quality/AQOS_BATCH_IMPACT_CLASSIFIER.md` (unknown; release proof)
  - `existing-code-champion-coverage` — `docs/codex/existing-code-champion-coverage.yml` (unknown; release proof)

### 6. Same source file targeted by multiple active items: Native/Ambitions/App/AppNavigation.swift

- Conflict ID: `AMB28-same_source_file_targeted_by_multiple_active_batches-58069197`
- Type: `same_source_file_targeted_by_multiple_active_batches`
- Severity: `yellow`
- Recommended action: `merge`
- Rationale: Multiple active ledger items reference the same source file; merge, sequence, or assign ownership before implementation.
- Linear issue ready: `True`
- Auto-resolved: `False`
- Involved:
  - `repo-audit-baseline` — `docs/codex/repo-audit-baseline.md` (partial_implementation; release proof)
  - `existing-code-champion-coverage` — `docs/codex/existing-code-champion-coverage.yml` (unknown; release proof)

### 7. Same source file targeted by multiple active items: Native/Ambitions/App/AppShellPresentationMode.swift

- Conflict ID: `AMB28-same_source_file_targeted_by_multiple_active_batches-81406637`
- Type: `same_source_file_targeted_by_multiple_active_batches`
- Severity: `yellow`
- Recommended action: `merge`
- Rationale: Multiple active ledger items reference the same source file; merge, sequence, or assign ownership before implementation.
- Linear issue ready: `True`
- Auto-resolved: `False`
- Involved:
  - `FCP08_Ambition_Meridian_Shell_Prompt` — `docs/codex/batches/FCP08_Ambition_Meridian_Shell_Prompt.md` (unknown; release proof)
  - `existing-code-champion-coverage` — `docs/codex/existing-code-champion-coverage.yml` (unknown; release proof)

### 8. Same source file targeted by multiple active items: Native/Ambitions/App/AppTab.swift

- Conflict ID: `AMB28-same_source_file_targeted_by_multiple_active_batches-18070532`
- Type: `same_source_file_targeted_by_multiple_active_batches`
- Severity: `yellow`
- Recommended action: `merge`
- Rationale: Multiple active ledger items reference the same source file; merge, sequence, or assign ownership before implementation.
- Linear issue ready: `True`
- Auto-resolved: `False`
- Involved:
  - `AMB-REPO-AUTHORITY-00-SAFETY-SNAPSHOT` — `prompts/batches/AMB-REPO-AUTHORITY-00-SAFETY-SNAPSHOT.md` (partial_implementation; release proof)
  - `AMB-REPO-AUTHORITY-02-FRONTEND-VISUAL-ENCYCLOPEDIA` — `prompts/batches/AMB-REPO-AUTHORITY-02-FRONTEND-VISUAL-ENCYCLOPEDIA.md` (partial_implementation; release proof)
  - `AMB-REPO-AUTHORITY-06-ACTIVE-DRIFT-REPAIR` — `prompts/batches/AMB-REPO-AUTHORITY-06-ACTIVE-DRIFT-REPAIR.md` (partial_implementation; release proof)
  - `ALIGN-01-NAMING` — `prompts/batches/ALIGN-01-NAMING.md` (partial_implementation; release proof)
  - `TOP-LEVEL-IA-PLAN-LEAK-REGRESSION-01` — `prompts/batches/TOP-LEVEL-IA-PLAN-LEAK-REGRESSION-01.md` (partial_implementation; release proof)
  - `AMB-POST23-01-TRUTH-AUDIT` — `docs/codex/reports/AMB-POST23-01-TRUTH-AUDIT.md` (partial_implementation; release proof)
  - `existing-code-champion-coverage` — `docs/codex/existing-code-champion-coverage.yml` (unknown; release proof)

### 9. Same source file targeted by multiple active items: Native/Ambitions/AppIntents/OpenAmbitionsDestinationIntent.swift

- Conflict ID: `AMB28-same_source_file_targeted_by_multiple_active_batches-99373334`
- Type: `same_source_file_targeted_by_multiple_active_batches`
- Severity: `yellow`
- Recommended action: `merge`
- Rationale: Multiple active ledger items reference the same source file; merge, sequence, or assign ownership before implementation.
- Linear issue ready: `True`
- Auto-resolved: `False`
- Involved:
  - `PFC18_App_Intents_Shortcuts_Implementation_And_Tests_Prompt` — `docs/codex/batches/PFC18_App_Intents_Shortcuts_Implementation_And_Tests_Prompt.md` (partial_implementation; release proof)
  - `existing-code-champion-coverage` — `docs/codex/existing-code-champion-coverage.yml` (unknown; release proof)

### 10. Same source file targeted by multiple active items: Native/Ambitions/Domain/ActionClosureReceiptModels.swift

- Conflict ID: `AMB28-same_source_file_targeted_by_multiple_active_batches-132980`
- Type: `same_source_file_targeted_by_multiple_active_batches`
- Severity: `yellow`
- Recommended action: `merge`
- Rationale: Multiple active ledger items reference the same source file; merge, sequence, or assign ownership before implementation.
- Linear issue ready: `True`
- Auto-resolved: `False`
- Involved:
  - `PK18` — `prompts/batches/PK18.md` (partial_implementation; release proof)
  - `LDI15` — `prompts/batches/LDI15.md` (partial_implementation; release proof)
  - `MOAT-GOAL-REALITY-RECEIPT-CLOSURE-07` — `prompts/batches/MOAT-GOAL-REALITY-RECEIPT-CLOSURE-07.md` (partial_implementation; release proof)
  - `existing-code-champion-coverage` — `docs/codex/existing-code-champion-coverage.yml` (unknown; release proof)

### 11. Same source file targeted by multiple active items: Native/Ambitions/Domain/AmbitionsCommandModels.swift

- Conflict ID: `AMB28-same_source_file_targeted_by_multiple_active_batches-40241239`
- Type: `same_source_file_targeted_by_multiple_active_batches`
- Severity: `yellow`
- Recommended action: `merge`
- Rationale: Multiple active ledger items reference the same source file; merge, sequence, or assign ownership before implementation.
- Linear issue ready: `True`
- Auto-resolved: `False`
- Involved:
  - `PK18` — `prompts/batches/PK18.md` (partial_implementation; release proof)
  - `PK22` — `prompts/batches/PK22.md` (partial_implementation; release proof)
  - `existing-code-champion-coverage` — `docs/codex/existing-code-champion-coverage.yml` (unknown; release proof)

### 12. Same source file targeted by multiple active items: Native/Ambitions/Domain/AmbitionsOSAdaptationModels.swift

- Conflict ID: `AMB28-same_source_file_targeted_by_multiple_active_batches-48220309`
- Type: `same_source_file_targeted_by_multiple_active_batches`
- Severity: `yellow`
- Recommended action: `merge`
- Rationale: Multiple active ledger items reference the same source file; merge, sequence, or assign ownership before implementation.
- Linear issue ready: `True`
- Auto-resolved: `False`
- Involved:
  - `AMBITIONSOS_AOS_TRACEABILITY_MATRIX` — `docs/codex/AMBITIONSOS_AOS_TRACEABILITY_MATRIX.md` (partial_implementation; release proof)
  - `AMB-POST23-01-TRUTH-AUDIT` — `docs/codex/reports/AMB-POST23-01-TRUTH-AUDIT.md` (partial_implementation; release proof)
  - `AMBITIONSOS_AOS_PRIVACY_PROJECTION_LEDGER` — `docs/codex/AMBITIONSOS_AOS_PRIVACY_PROJECTION_LEDGER.md` (unknown; release proof)
  - `existing-code-champion-coverage` — `docs/codex/existing-code-champion-coverage.yml` (unknown; release proof)

### 13. Same source file targeted by multiple active items: Native/Ambitions/Domain/AmbitionsOSAlternatePathModels.swift

- Conflict ID: `AMB28-same_source_file_targeted_by_multiple_active_batches-84566820`
- Type: `same_source_file_targeted_by_multiple_active_batches`
- Severity: `yellow`
- Recommended action: `merge`
- Rationale: Multiple active ledger items reference the same source file; merge, sequence, or assign ownership before implementation.
- Linear issue ready: `True`
- Auto-resolved: `False`
- Involved:
  - `AMBITIONSOS_AOS_TRACEABILITY_MATRIX` — `docs/codex/AMBITIONSOS_AOS_TRACEABILITY_MATRIX.md` (partial_implementation; release proof)
  - `existing-code-champion-coverage` — `docs/codex/existing-code-champion-coverage.yml` (unknown; release proof)

### 14. Same source file targeted by multiple active items: Native/Ambitions/Domain/AmbitionsOSCommitmentTimeModels.swift

- Conflict ID: `AMB28-same_source_file_targeted_by_multiple_active_batches-22290490`
- Type: `same_source_file_targeted_by_multiple_active_batches`
- Severity: `yellow`
- Recommended action: `merge`
- Rationale: Multiple active ledger items reference the same source file; merge, sequence, or assign ownership before implementation.
- Linear issue ready: `True`
- Auto-resolved: `False`
- Involved:
  - `AMBITIONSOS_AOS_TRACEABILITY_MATRIX` — `docs/codex/AMBITIONSOS_AOS_TRACEABILITY_MATRIX.md` (partial_implementation; release proof)
  - `existing-code-champion-coverage` — `docs/codex/existing-code-champion-coverage.yml` (unknown; release proof)

### 15. Same source file targeted by multiple active items: Native/Ambitions/Domain/AmbitionsOSControlPlaneModels.swift

- Conflict ID: `AMB28-same_source_file_targeted_by_multiple_active_batches-48576491`
- Type: `same_source_file_targeted_by_multiple_active_batches`
- Severity: `yellow`
- Recommended action: `merge`
- Rationale: Multiple active ledger items reference the same source file; merge, sequence, or assign ownership before implementation.
- Linear issue ready: `True`
- Auto-resolved: `False`
- Involved:
  - `AMBITIONSOS_AOS_TRACEABILITY_MATRIX` — `docs/codex/AMBITIONSOS_AOS_TRACEABILITY_MATRIX.md` (partial_implementation; release proof)
  - `existing-code-champion-coverage` — `docs/codex/existing-code-champion-coverage.yml` (unknown; release proof)

### 16. Same source file targeted by multiple active items: Native/Ambitions/Domain/AmbitionsOSEvaluationModels.swift

- Conflict ID: `AMB28-same_source_file_targeted_by_multiple_active_batches-1290423`
- Type: `same_source_file_targeted_by_multiple_active_batches`
- Severity: `yellow`
- Recommended action: `merge`
- Rationale: Multiple active ledger items reference the same source file; merge, sequence, or assign ownership before implementation.
- Linear issue ready: `True`
- Auto-resolved: `False`
- Involved:
  - `AMBITIONSOS_AOS_TRACEABILITY_MATRIX` — `docs/codex/AMBITIONSOS_AOS_TRACEABILITY_MATRIX.md` (partial_implementation; release proof)
  - `AMBITIONSOS_AOS_PRIVACY_PROJECTION_LEDGER` — `docs/codex/AMBITIONSOS_AOS_PRIVACY_PROJECTION_LEDGER.md` (unknown; release proof)
  - `AMBITIONSOS_AOS_SOURCE_TRUTH_CLAIM_LEDGER` — `docs/codex/AMBITIONSOS_AOS_SOURCE_TRUTH_CLAIM_LEDGER.md` (unknown; release proof)
  - `existing-code-champion-coverage` — `docs/codex/existing-code-champion-coverage.yml` (unknown; release proof)

### 17. Same source file targeted by multiple active items: Native/Ambitions/Domain/AmbitionsOSExperienceModels.swift

- Conflict ID: `AMB28-same_source_file_targeted_by_multiple_active_batches-13949418`
- Type: `same_source_file_targeted_by_multiple_active_batches`
- Severity: `yellow`
- Recommended action: `merge`
- Rationale: Multiple active ledger items reference the same source file; merge, sequence, or assign ownership before implementation.
- Linear issue ready: `True`
- Auto-resolved: `False`
- Involved:
  - `AMBITIONSOS_AOS_TRACEABILITY_MATRIX` — `docs/codex/AMBITIONSOS_AOS_TRACEABILITY_MATRIX.md` (partial_implementation; release proof)
  - `AMBITIONSOS_AOS_PRIVACY_PROJECTION_LEDGER` — `docs/codex/AMBITIONSOS_AOS_PRIVACY_PROJECTION_LEDGER.md` (unknown; release proof)
  - `existing-code-champion-coverage` — `docs/codex/existing-code-champion-coverage.yml` (unknown; release proof)

### 18. Same source file targeted by multiple active items: Native/Ambitions/Domain/AmbitionsOSGoalPathCompilerModels.swift

- Conflict ID: `AMB28-same_source_file_targeted_by_multiple_active_batches-77664747`
- Type: `same_source_file_targeted_by_multiple_active_batches`
- Severity: `yellow`
- Recommended action: `merge`
- Rationale: Multiple active ledger items reference the same source file; merge, sequence, or assign ownership before implementation.
- Linear issue ready: `True`
- Auto-resolved: `False`
- Involved:
  - `AMBITIONSOS_AOS_TRACEABILITY_MATRIX` — `docs/codex/AMBITIONSOS_AOS_TRACEABILITY_MATRIX.md` (partial_implementation; release proof)
  - `existing-code-champion-coverage` — `docs/codex/existing-code-champion-coverage.yml` (unknown; release proof)

### 19. Same source file targeted by multiple active items: Native/Ambitions/Domain/AmbitionsOSInteroperabilityModels.swift

- Conflict ID: `AMB28-same_source_file_targeted_by_multiple_active_batches-68732143`
- Type: `same_source_file_targeted_by_multiple_active_batches`
- Severity: `yellow`
- Recommended action: `merge`
- Rationale: Multiple active ledger items reference the same source file; merge, sequence, or assign ownership before implementation.
- Linear issue ready: `True`
- Auto-resolved: `False`
- Involved:
  - `AMBITIONSOS_AOS_TRACEABILITY_MATRIX` — `docs/codex/AMBITIONSOS_AOS_TRACEABILITY_MATRIX.md` (partial_implementation; release proof)
  - `AMBITIONSOS_AOS_PRIVACY_PROJECTION_LEDGER` — `docs/codex/AMBITIONSOS_AOS_PRIVACY_PROJECTION_LEDGER.md` (unknown; release proof)
  - `existing-code-champion-coverage` — `docs/codex/existing-code-champion-coverage.yml` (unknown; release proof)

### 20. Same source file targeted by multiple active items: Native/Ambitions/Domain/AmbitionsOSLivingDreamCapacityBridgeModels.swift

- Conflict ID: `AMB28-same_source_file_targeted_by_multiple_active_batches-28168986`
- Type: `same_source_file_targeted_by_multiple_active_batches`
- Severity: `yellow`
- Recommended action: `merge`
- Rationale: Multiple active ledger items reference the same source file; merge, sequence, or assign ownership before implementation.
- Linear issue ready: `True`
- Auto-resolved: `False`
- Involved:
  - `MOAT-MOONSHOT-BACKEND-FULL-TRAIN-01` — `prompts/batches/MOAT-MOONSHOT-BACKEND-FULL-TRAIN-01.md` (partial_implementation; release proof)
  - `MOAT-MOONSHOT-PROOF-PATH-01` — `prompts/batches/MOAT-MOONSHOT-PROOF-PATH-01.md` (partial_implementation; release proof)
  - `MOAT-UNIVERSAL-GOAL-REALITY-COMPILER-01` — `prompts/batches/MOAT-UNIVERSAL-GOAL-REALITY-COMPILER-01.md` (partial_implementation; release proof)
  - `existing-code-champion-coverage` — `docs/codex/existing-code-champion-coverage.yml` (unknown; release proof)

### 21. Same source file targeted by multiple active items: Native/Ambitions/Domain/AmbitionsOSLivingDreamPathPortfolioModels.swift

- Conflict ID: `AMB28-same_source_file_targeted_by_multiple_active_batches-52042847`
- Type: `same_source_file_targeted_by_multiple_active_batches`
- Severity: `yellow`
- Recommended action: `merge`
- Rationale: Multiple active ledger items reference the same source file; merge, sequence, or assign ownership before implementation.
- Linear issue ready: `True`
- Auto-resolved: `False`
- Involved:
  - `MOAT-MOONSHOT-BACKEND-FULL-TRAIN-01` — `prompts/batches/MOAT-MOONSHOT-BACKEND-FULL-TRAIN-01.md` (partial_implementation; release proof)
  - `MOAT-MOONSHOT-PROOF-PATH-01` — `prompts/batches/MOAT-MOONSHOT-PROOF-PATH-01.md` (partial_implementation; release proof)
  - `MOAT-UNIVERSAL-GOAL-REALITY-COMPILER-01` — `prompts/batches/MOAT-UNIVERSAL-GOAL-REALITY-COMPILER-01.md` (partial_implementation; release proof)
  - `MOAT-GOAL-REALITY-SOURCE-PACKS-09` — `prompts/batches/MOAT-GOAL-REALITY-SOURCE-PACKS-09.md` (partial_implementation; release proof)
  - `existing-code-champion-coverage` — `docs/codex/existing-code-champion-coverage.yml` (unknown; release proof)

### 22. Same source file targeted by multiple active items: Native/Ambitions/Domain/AmbitionsOSLivingDreamSourceClaimGraphModels.swift

- Conflict ID: `AMB28-same_source_file_targeted_by_multiple_active_batches-5216122`
- Type: `same_source_file_targeted_by_multiple_active_batches`
- Severity: `yellow`
- Recommended action: `merge`
- Rationale: Multiple active ledger items reference the same source file; merge, sequence, or assign ownership before implementation.
- Linear issue ready: `True`
- Auto-resolved: `False`
- Involved:
  - `SA07` — `prompts/batches/SA07.md` (partial_implementation; release proof)
  - `SA08` — `prompts/batches/SA08.md` (partial_implementation; release proof)
  - `SA09` — `prompts/batches/SA09.md` (partial_implementation; release proof)
  - `SA10` — `prompts/batches/SA10.md` (partial_implementation; release proof)
  - `SA10A` — `prompts/batches/SA10A.md` (partial_implementation; release proof)
  - `SA10B` — `prompts/batches/SA10B.md` (partial_implementation; release proof)
  - `SA10C` — `prompts/batches/SA10C.md` (partial_implementation; release proof)
  - `SA11` — `prompts/batches/SA11.md` (partial_implementation; release proof)
  - `SA12` — `prompts/batches/SA12.md` (partial_implementation; release proof)
  - `SA13` — `prompts/batches/SA13.md` (partial_implementation; release proof)
  - `SA14` — `prompts/batches/SA14.md` (partial_implementation; release proof)
  - `SA15` — `prompts/batches/SA15.md` (partial_implementation; release proof)
  - `SA16` — `prompts/batches/SA16.md` (partial_implementation; release proof)
  - `SA17` — `prompts/batches/SA17.md` (partial_implementation; release proof)
  - `SA18` — `prompts/batches/SA18.md` (partial_implementation; release proof)
  - `SA19` — `prompts/batches/SA19.md` (partial_implementation; release proof)
  - `SA20` — `prompts/batches/SA20.md` (partial_implementation; release proof)
  - `SA21` — `prompts/batches/SA21.md` (partial_implementation; release proof)
  - `SA22` — `prompts/batches/SA22.md` (partial_implementation; release proof)
  - `SA23` — `prompts/batches/SA23.md` (partial_implementation; release proof)
  - `SA24` — `prompts/batches/SA24.md` (partial_implementation; release proof)
  - `SA25` — `prompts/batches/SA25.md` (partial_implementation; release proof)
  - `SA26` — `prompts/batches/SA26.md` (partial_implementation; release proof)
  - `SA27` — `prompts/batches/SA27.md` (partial_implementation; release proof)
  - `SA28` — `prompts/batches/SA28.md` (partial_implementation; release proof)
  - `SA29` — `prompts/batches/SA29.md` (partial_implementation; release proof)
  - `SA30` — `prompts/batches/SA30.md` (partial_implementation; release proof)
  - `SA31` — `prompts/batches/SA31.md` (partial_implementation; release proof)
  - `SA32` — `prompts/batches/SA32.md` (partial_implementation; release proof)
  - `existing-code-champion-coverage` — `docs/codex/existing-code-champion-coverage.yml` (unknown; release proof)

### 23. Same source file targeted by multiple active items: Native/Ambitions/Domain/AmbitionsOSLivingDreamStartingPositionPrivacyIntakeModels.swift

- Conflict ID: `AMB28-same_source_file_targeted_by_multiple_active_batches-52204202`
- Type: `same_source_file_targeted_by_multiple_active_batches`
- Severity: `yellow`
- Recommended action: `merge`
- Rationale: Multiple active ledger items reference the same source file; merge, sequence, or assign ownership before implementation.
- Linear issue ready: `True`
- Auto-resolved: `False`
- Involved:
  - `MOAT-MOONSHOT-BACKEND-FULL-TRAIN-01` — `prompts/batches/MOAT-MOONSHOT-BACKEND-FULL-TRAIN-01.md` (partial_implementation; release proof)
  - `MOAT-MOONSHOT-PROOF-PATH-01` — `prompts/batches/MOAT-MOONSHOT-PROOF-PATH-01.md` (partial_implementation; release proof)
  - `MOAT-UNIVERSAL-GOAL-REALITY-COMPILER-01` — `prompts/batches/MOAT-UNIVERSAL-GOAL-REALITY-COMPILER-01.md` (partial_implementation; release proof)
  - `existing-code-champion-coverage` — `docs/codex/existing-code-champion-coverage.yml` (unknown; release proof)

### 24. Same source file targeted by multiple active items: Native/Ambitions/Domain/AmbitionsOSLivingDreamTodayBridgeModels.swift

- Conflict ID: `AMB28-same_source_file_targeted_by_multiple_active_batches-7296624`
- Type: `same_source_file_targeted_by_multiple_active_batches`
- Severity: `yellow`
- Recommended action: `merge`
- Rationale: Multiple active ledger items reference the same source file; merge, sequence, or assign ownership before implementation.
- Linear issue ready: `True`
- Auto-resolved: `False`
- Involved:
  - `MOAT-MOONSHOT-BACKEND-FULL-TRAIN-01` — `prompts/batches/MOAT-MOONSHOT-BACKEND-FULL-TRAIN-01.md` (partial_implementation; release proof)
  - `MOAT-MOONSHOT-PROOF-PATH-01` — `prompts/batches/MOAT-MOONSHOT-PROOF-PATH-01.md` (partial_implementation; release proof)
  - `MOAT-UNIVERSAL-GOAL-REALITY-COMPILER-01` — `prompts/batches/MOAT-UNIVERSAL-GOAL-REALITY-COMPILER-01.md` (partial_implementation; release proof)
  - `existing-code-champion-coverage` — `docs/codex/existing-code-champion-coverage.yml` (unknown; release proof)

### 25. Same source file targeted by multiple active items: Native/Ambitions/Domain/AmbitionsOSLocalGoalPackModels.swift

- Conflict ID: `AMB28-same_source_file_targeted_by_multiple_active_batches-53850908`
- Type: `same_source_file_targeted_by_multiple_active_batches`
- Severity: `yellow`
- Recommended action: `merge`
- Rationale: Multiple active ledger items reference the same source file; merge, sequence, or assign ownership before implementation.
- Linear issue ready: `True`
- Auto-resolved: `False`
- Involved:
  - `AMBITIONSOS_AOS_TRACEABILITY_MATRIX` — `docs/codex/AMBITIONSOS_AOS_TRACEABILITY_MATRIX.md` (partial_implementation; release proof)
  - `existing-code-champion-coverage` — `docs/codex/existing-code-champion-coverage.yml` (unknown; release proof)

### 26. Same source file targeted by multiple active items: Native/Ambitions/Domain/AmbitionsOSLocalLanguageModels.swift

- Conflict ID: `AMB28-same_source_file_targeted_by_multiple_active_batches-17538116`
- Type: `same_source_file_targeted_by_multiple_active_batches`
- Severity: `yellow`
- Recommended action: `merge`
- Rationale: Multiple active ledger items reference the same source file; merge, sequence, or assign ownership before implementation.
- Linear issue ready: `True`
- Auto-resolved: `False`
- Involved:
  - `AMBITIONSOS_AOS_TRACEABILITY_MATRIX` — `docs/codex/AMBITIONSOS_AOS_TRACEABILITY_MATRIX.md` (partial_implementation; release proof)
  - `existing-code-champion-coverage` — `docs/codex/existing-code-champion-coverage.yml` (unknown; release proof)

### 27. Same source file targeted by multiple active items: Native/Ambitions/Domain/AmbitionsOSLongevityModels.swift

- Conflict ID: `AMB28-same_source_file_targeted_by_multiple_active_batches-40073290`
- Type: `same_source_file_targeted_by_multiple_active_batches`
- Severity: `yellow`
- Recommended action: `merge`
- Rationale: Multiple active ledger items reference the same source file; merge, sequence, or assign ownership before implementation.
- Linear issue ready: `True`
- Auto-resolved: `False`
- Involved:
  - `AMBITIONSOS_AOS_TRACEABILITY_MATRIX` — `docs/codex/AMBITIONSOS_AOS_TRACEABILITY_MATRIX.md` (partial_implementation; release proof)
  - `AMBITIONSOS_AOS_PRIVACY_PROJECTION_LEDGER` — `docs/codex/AMBITIONSOS_AOS_PRIVACY_PROJECTION_LEDGER.md` (unknown; release proof)
  - `existing-code-champion-coverage` — `docs/codex/existing-code-champion-coverage.yml` (unknown; release proof)

### 28. Same source file targeted by multiple active items: Native/Ambitions/Domain/AmbitionsOSOptionValueModels.swift

- Conflict ID: `AMB28-same_source_file_targeted_by_multiple_active_batches-6725922`
- Type: `same_source_file_targeted_by_multiple_active_batches`
- Severity: `yellow`
- Recommended action: `merge`
- Rationale: Multiple active ledger items reference the same source file; merge, sequence, or assign ownership before implementation.
- Linear issue ready: `True`
- Auto-resolved: `False`
- Involved:
  - `AMBITIONSOS_AOS_TRACEABILITY_MATRIX` — `docs/codex/AMBITIONSOS_AOS_TRACEABILITY_MATRIX.md` (partial_implementation; release proof)
  - `existing-code-champion-coverage` — `docs/codex/existing-code-champion-coverage.yml` (unknown; release proof)

### 29. Same source file targeted by multiple active items: Native/Ambitions/Domain/AmbitionsOSPerformanceEnergyModels.swift

- Conflict ID: `AMB28-same_source_file_targeted_by_multiple_active_batches-90864651`
- Type: `same_source_file_targeted_by_multiple_active_batches`
- Severity: `yellow`
- Recommended action: `merge`
- Rationale: Multiple active ledger items reference the same source file; merge, sequence, or assign ownership before implementation.
- Linear issue ready: `True`
- Auto-resolved: `False`
- Involved:
  - `AMBITIONSOS_AOS_TRACEABILITY_MATRIX` — `docs/codex/AMBITIONSOS_AOS_TRACEABILITY_MATRIX.md` (partial_implementation; release proof)
  - `PK36` — `prompts/batches/PK36.md` (partial_implementation; release proof)
  - `PFC36` — `prompts/batches/PFC36.md` (partial_implementation; release proof)
  - `existing-code-champion-coverage` — `docs/codex/existing-code-champion-coverage.yml` (unknown; release proof)

### 30. Same source file targeted by multiple active items: Native/Ambitions/Domain/AmbitionsOSPrivacySafetyModels.swift

- Conflict ID: `AMB28-same_source_file_targeted_by_multiple_active_batches-75588291`
- Type: `same_source_file_targeted_by_multiple_active_batches`
- Severity: `yellow`
- Recommended action: `merge`
- Rationale: Multiple active ledger items reference the same source file; merge, sequence, or assign ownership before implementation.
- Linear issue ready: `True`
- Auto-resolved: `False`
- Involved:
  - `AMBITIONSOS_AOS_TRACEABILITY_MATRIX` — `docs/codex/AMBITIONSOS_AOS_TRACEABILITY_MATRIX.md` (partial_implementation; release proof)
  - `PK26` — `prompts/batches/PK26.md` (partial_implementation; release proof)
  - `AOS27` — `prompts/batches/AOS27.md` (partial_implementation; release proof)
  - `PFC34` — `prompts/batches/PFC34.md` (partial_implementation; release proof)
  - `AMBITIONSOS_AOS_PRIVACY_PROJECTION_LEDGER` — `docs/codex/AMBITIONSOS_AOS_PRIVACY_PROJECTION_LEDGER.md` (unknown; release proof)
  - `AMBITIONSOS_AOS_SOURCE_TRUTH_CLAIM_LEDGER` — `docs/codex/AMBITIONSOS_AOS_SOURCE_TRUTH_CLAIM_LEDGER.md` (unknown; release proof)
  - `existing-code-champion-coverage` — `docs/codex/existing-code-champion-coverage.yml` (unknown; release proof)

### 31. Same source file targeted by multiple active items: Native/Ambitions/Domain/AmbitionsOSProofTrustModels.swift

- Conflict ID: `AMB28-same_source_file_targeted_by_multiple_active_batches-9052417`
- Type: `same_source_file_targeted_by_multiple_active_batches`
- Severity: `yellow`
- Recommended action: `merge`
- Rationale: Multiple active ledger items reference the same source file; merge, sequence, or assign ownership before implementation.
- Linear issue ready: `True`
- Auto-resolved: `False`
- Involved:
  - `AMBITIONSOS_AOS_TRACEABILITY_MATRIX` — `docs/codex/AMBITIONSOS_AOS_TRACEABILITY_MATRIX.md` (partial_implementation; release proof)
  - `existing-code-champion-coverage` — `docs/codex/existing-code-champion-coverage.yml` (unknown; release proof)

### 32. Same source file targeted by multiple active items: Native/Ambitions/Domain/AmbitionsOSRealityDriftModels.swift

- Conflict ID: `AMB28-same_source_file_targeted_by_multiple_active_batches-47969602`
- Type: `same_source_file_targeted_by_multiple_active_batches`
- Severity: `yellow`
- Recommended action: `merge`
- Rationale: Multiple active ledger items reference the same source file; merge, sequence, or assign ownership before implementation.
- Linear issue ready: `True`
- Auto-resolved: `False`
- Involved:
  - `AMBITIONSOS_AOS_TRACEABILITY_MATRIX` — `docs/codex/AMBITIONSOS_AOS_TRACEABILITY_MATRIX.md` (partial_implementation; release proof)
  - `existing-code-champion-coverage` — `docs/codex/existing-code-champion-coverage.yml` (unknown; release proof)

### 33. Same source file targeted by multiple active items: Native/Ambitions/Domain/AmbitionsOSRecommendationStartHereModels.swift

- Conflict ID: `AMB28-same_source_file_targeted_by_multiple_active_batches-88242614`
- Type: `same_source_file_targeted_by_multiple_active_batches`
- Severity: `yellow`
- Recommended action: `merge`
- Rationale: Multiple active ledger items reference the same source file; merge, sequence, or assign ownership before implementation.
- Linear issue ready: `True`
- Auto-resolved: `False`
- Involved:
  - `AMBITIONSOS_AOS_TRACEABILITY_MATRIX` — `docs/codex/AMBITIONSOS_AOS_TRACEABILITY_MATRIX.md` (partial_implementation; release proof)
  - `PK33` — `prompts/batches/PK33.md` (partial_implementation; release proof)
  - `MOAT-MOONSHOT-BACKEND-FULL-TRAIN-01` — `prompts/batches/MOAT-MOONSHOT-BACKEND-FULL-TRAIN-01.md` (partial_implementation; release proof)
  - `MOAT-MOONSHOT-PROOF-PATH-01` — `prompts/batches/MOAT-MOONSHOT-PROOF-PATH-01.md` (partial_implementation; release proof)
  - `MOAT-UNIVERSAL-GOAL-REALITY-COMPILER-01` — `prompts/batches/MOAT-UNIVERSAL-GOAL-REALITY-COMPILER-01.md` (partial_implementation; release proof)
  - `FLAGSHIP-OBJECT-SYSTEM-01` — `prompts/batches/FLAGSHIP-OBJECT-SYSTEM-01.md` (partial_implementation; release proof)
  - `MOAT-GOAL-REALITY-SOURCE-PACKS-09` — `prompts/batches/MOAT-GOAL-REALITY-SOURCE-PACKS-09.md` (partial_implementation; release proof)
  - `existing-code-champion-coverage` — `docs/codex/existing-code-champion-coverage.yml` (unknown; release proof)

### 34. Same source file targeted by multiple active items: Native/Ambitions/Domain/AmbitionsOSSourceTruthModels.swift

- Conflict ID: `AMB28-same_source_file_targeted_by_multiple_active_batches-177640`
- Type: `same_source_file_targeted_by_multiple_active_batches`
- Severity: `yellow`
- Recommended action: `merge`
- Rationale: Multiple active ledger items reference the same source file; merge, sequence, or assign ownership before implementation.
- Linear issue ready: `True`
- Auto-resolved: `False`
- Involved:
  - `AMBITIONSOS_AOS_TRACEABILITY_MATRIX` — `docs/codex/AMBITIONSOS_AOS_TRACEABILITY_MATRIX.md` (partial_implementation; release proof)
  - `SA07` — `prompts/batches/SA07.md` (partial_implementation; release proof)
  - `SA08` — `prompts/batches/SA08.md` (partial_implementation; release proof)
  - `SA09` — `prompts/batches/SA09.md` (partial_implementation; release proof)
  - `SA10` — `prompts/batches/SA10.md` (partial_implementation; release proof)
  - `SA10A` — `prompts/batches/SA10A.md` (partial_implementation; release proof)
  - `SA10B` — `prompts/batches/SA10B.md` (partial_implementation; release proof)
  - `SA10C` — `prompts/batches/SA10C.md` (partial_implementation; release proof)
  - `SA11` — `prompts/batches/SA11.md` (partial_implementation; release proof)
  - `SA12` — `prompts/batches/SA12.md` (partial_implementation; release proof)
  - `SA13` — `prompts/batches/SA13.md` (partial_implementation; release proof)
  - `SA14` — `prompts/batches/SA14.md` (partial_implementation; release proof)
  - `SA15` — `prompts/batches/SA15.md` (partial_implementation; release proof)
  - `SA16` — `prompts/batches/SA16.md` (partial_implementation; release proof)
  - `SA17` — `prompts/batches/SA17.md` (partial_implementation; release proof)
  - `SA18` — `prompts/batches/SA18.md` (partial_implementation; release proof)
  - `SA19` — `prompts/batches/SA19.md` (partial_implementation; release proof)
  - `SA20` — `prompts/batches/SA20.md` (partial_implementation; release proof)
  - `SA21` — `prompts/batches/SA21.md` (partial_implementation; release proof)
  - `SA22` — `prompts/batches/SA22.md` (partial_implementation; release proof)
  - `SA23` — `prompts/batches/SA23.md` (partial_implementation; release proof)
  - `SA24` — `prompts/batches/SA24.md` (partial_implementation; release proof)
  - `SA25` — `prompts/batches/SA25.md` (partial_implementation; release proof)
  - `SA26` — `prompts/batches/SA26.md` (partial_implementation; release proof)
  - `SA27` — `prompts/batches/SA27.md` (partial_implementation; release proof)
  - `SA28` — `prompts/batches/SA28.md` (partial_implementation; release proof)
  - `SA29` — `prompts/batches/SA29.md` (partial_implementation; release proof)
  - `SA30` — `prompts/batches/SA30.md` (partial_implementation; release proof)
  - `SA31` — `prompts/batches/SA31.md` (partial_implementation; release proof)
  - `SA32` — `prompts/batches/SA32.md` (partial_implementation; release proof)
  - ... 1 more

### 35. Same source file targeted by multiple active items: Native/Ambitions/Domain/AmbitionsOSStartingPositionModels.swift

- Conflict ID: `AMB28-same_source_file_targeted_by_multiple_active_batches-89574133`
- Type: `same_source_file_targeted_by_multiple_active_batches`
- Severity: `yellow`
- Recommended action: `merge`
- Rationale: Multiple active ledger items reference the same source file; merge, sequence, or assign ownership before implementation.
- Linear issue ready: `True`
- Auto-resolved: `False`
- Involved:
  - `AMBITIONSOS_AOS_TRACEABILITY_MATRIX` — `docs/codex/AMBITIONSOS_AOS_TRACEABILITY_MATRIX.md` (partial_implementation; release proof)
  - `existing-code-champion-coverage` — `docs/codex/existing-code-champion-coverage.yml` (unknown; release proof)

### 36. Same source file targeted by multiple active items: Native/Ambitions/Domain/CaptureModels.swift

- Conflict ID: `AMB28-same_source_file_targeted_by_multiple_active_batches-19740197`
- Type: `same_source_file_targeted_by_multiple_active_batches`
- Severity: `yellow`
- Recommended action: `merge`
- Rationale: Multiple active ledger items reference the same source file; merge, sequence, or assign ownership before implementation.
- Linear issue ready: `True`
- Auto-resolved: `False`
- Involved:
  - `PK20` — `prompts/batches/PK20.md` (partial_implementation; release proof)
  - `existing-code-champion-coverage` — `docs/codex/existing-code-champion-coverage.yml` (unknown; release proof)

### 37. Same source file targeted by multiple active items: Native/Ambitions/Domain/EventLedgerModels.swift

- Conflict ID: `AMB28-same_source_file_targeted_by_multiple_active_batches-24821312`
- Type: `same_source_file_targeted_by_multiple_active_batches`
- Severity: `yellow`
- Recommended action: `merge`
- Rationale: Multiple active ledger items reference the same source file; merge, sequence, or assign ownership before implementation.
- Linear issue ready: `True`
- Auto-resolved: `False`
- Involved:
  - `PK18` — `prompts/batches/PK18.md` (partial_implementation; release proof)
  - `PK22` — `prompts/batches/PK22.md` (partial_implementation; release proof)
  - `PK27` — `prompts/batches/PK27.md` (partial_implementation; release proof)
  - `existing-code-champion-coverage` — `docs/codex/existing-code-champion-coverage.yml` (unknown; release proof)

### 38. Same source file targeted by multiple active items: Native/Ambitions/Domain/GoalEngine/GoalEngineContracts.swift

- Conflict ID: `AMB28-same_source_file_targeted_by_multiple_active_batches-117719`
- Type: `same_source_file_targeted_by_multiple_active_batches`
- Severity: `yellow`
- Recommended action: `merge`
- Rationale: Multiple active ledger items reference the same source file; merge, sequence, or assign ownership before implementation.
- Linear issue ready: `True`
- Auto-resolved: `False`
- Involved:
  - `repo-audit-baseline` — `docs/codex/repo-audit-baseline.md` (partial_implementation; release proof)
  - `BATCH-23-generalized-goal-understanding-contracts` — `docs/codex/batches/BATCH-23-generalized-goal-understanding-contracts.md` (unknown; release proof)

### 39. Same source file targeted by multiple active items: Native/Ambitions/Domain/GoalEngine/GoalEngineOrchestrator.swift

- Conflict ID: `AMB28-same_source_file_targeted_by_multiple_active_batches-27632046`
- Type: `same_source_file_targeted_by_multiple_active_batches`
- Severity: `yellow`
- Recommended action: `merge`
- Rationale: Multiple active ledger items reference the same source file; merge, sequence, or assign ownership before implementation.
- Linear issue ready: `True`
- Auto-resolved: `False`
- Involved:
  - `repo-audit-baseline` — `docs/codex/repo-audit-baseline.md` (partial_implementation; release proof)
  - `BATCH-23-generalized-goal-understanding-contracts` — `docs/codex/batches/BATCH-23-generalized-goal-understanding-contracts.md` (unknown; release proof)

### 40. Same source file targeted by multiple active items: Native/Ambitions/Domain/GoalEngine/GoalPathCompilerModels.swift

- Conflict ID: `AMB28-same_source_file_targeted_by_multiple_active_batches-70039948`
- Type: `same_source_file_targeted_by_multiple_active_batches`
- Severity: `yellow`
- Recommended action: `merge`
- Rationale: Multiple active ledger items reference the same source file; merge, sequence, or assign ownership before implementation.
- Linear issue ready: `True`
- Auto-resolved: `False`
- Involved:
  - `BATCH-24-path-compiler-foundation` — `docs/codex/batches/BATCH-24-path-compiler-foundation.md` (unknown; release proof)
  - `BATCH-25-domain-pack-framework` — `docs/codex/batches/BATCH-25-domain-pack-framework.md` (unknown; release proof)

### 41. Same source file targeted by multiple active items: Native/Ambitions/Domain/GoalRealityModels.swift

- Conflict ID: `AMB28-same_source_file_targeted_by_multiple_active_batches-13187650`
- Type: `same_source_file_targeted_by_multiple_active_batches`
- Severity: `yellow`
- Recommended action: `merge`
- Rationale: Multiple active ledger items reference the same source file; merge, sequence, or assign ownership before implementation.
- Linear issue ready: `True`
- Auto-resolved: `False`
- Involved:
  - `GOAL_REALITY_COMPILER_BACKEND_MASTER_PLAN` — `docs/codex/GOAL_REALITY_COMPILER_BACKEND_MASTER_PLAN.md` (partial_implementation; release proof)
  - `MOAT-GOAL-REALITY-FIXTURE-LAB-02` — `prompts/batches/MOAT-GOAL-REALITY-FIXTURE-LAB-02.md` (partial_implementation; release proof)
  - `MOAT-UNIVERSAL-GOAL-REALITY-COMPILER-01` — `prompts/batches/MOAT-UNIVERSAL-GOAL-REALITY-COMPILER-01.md` (partial_implementation; release proof)
  - `MOAT-GOAL-REALITY-LOCAL-PERSISTENCE-08` — `prompts/batches/MOAT-GOAL-REALITY-LOCAL-PERSISTENCE-08.md` (partial_implementation; release proof)
  - `MOAT-GOAL-REALITY-RECEIPT-CLOSURE-07` — `prompts/batches/MOAT-GOAL-REALITY-RECEIPT-CLOSURE-07.md` (partial_implementation; release proof)
  - `MOAT-GOAL-REALITY-SOURCE-PACKS-09` — `prompts/batches/MOAT-GOAL-REALITY-SOURCE-PACKS-09.md` (partial_implementation; release proof)
  - `MOAT-GOAL-REALITY-TODAY-BRIDGE-06` — `prompts/batches/MOAT-GOAL-REALITY-TODAY-BRIDGE-06.md` (partial_implementation; release proof)

### 42. Same source file targeted by multiple active items: Native/Ambitions/Domain/GoalRealityProofModels.swift

- Conflict ID: `AMB28-same_source_file_targeted_by_multiple_active_batches-33993310`
- Type: `same_source_file_targeted_by_multiple_active_batches`
- Severity: `yellow`
- Recommended action: `merge`
- Rationale: Multiple active ledger items reference the same source file; merge, sequence, or assign ownership before implementation.
- Linear issue ready: `True`
- Auto-resolved: `False`
- Involved:
  - `GOAL_REALITY_COMPILER_BACKEND_MASTER_PLAN` — `docs/codex/GOAL_REALITY_COMPILER_BACKEND_MASTER_PLAN.md` (partial_implementation; release proof)
  - `MOAT-GOAL-REALITY-FIXTURE-LAB-02` — `prompts/batches/MOAT-GOAL-REALITY-FIXTURE-LAB-02.md` (partial_implementation; release proof)
  - `MOAT-UNIVERSAL-GOAL-REALITY-COMPILER-01` — `prompts/batches/MOAT-UNIVERSAL-GOAL-REALITY-COMPILER-01.md` (partial_implementation; release proof)

### 43. Same source file targeted by multiple active items: Native/Ambitions/Domain/GoalRealityReceiptModels.swift

- Conflict ID: `AMB28-same_source_file_targeted_by_multiple_active_batches-99288917`
- Type: `same_source_file_targeted_by_multiple_active_batches`
- Severity: `yellow`
- Recommended action: `merge`
- Rationale: Multiple active ledger items reference the same source file; merge, sequence, or assign ownership before implementation.
- Linear issue ready: `True`
- Auto-resolved: `False`
- Involved:
  - `GOAL_REALITY_COMPILER_BACKEND_MASTER_PLAN` — `docs/codex/GOAL_REALITY_COMPILER_BACKEND_MASTER_PLAN.md` (partial_implementation; release proof)
  - `MOAT-GOAL-REALITY-FIXTURE-LAB-02` — `prompts/batches/MOAT-GOAL-REALITY-FIXTURE-LAB-02.md` (partial_implementation; release proof)
  - `MOAT-UNIVERSAL-GOAL-REALITY-COMPILER-01` — `prompts/batches/MOAT-UNIVERSAL-GOAL-REALITY-COMPILER-01.md` (partial_implementation; release proof)
  - `MOAT-GOAL-REALITY-LOCAL-PERSISTENCE-08` — `prompts/batches/MOAT-GOAL-REALITY-LOCAL-PERSISTENCE-08.md` (partial_implementation; release proof)
  - `MOAT-GOAL-REALITY-RECEIPT-CLOSURE-07` — `prompts/batches/MOAT-GOAL-REALITY-RECEIPT-CLOSURE-07.md` (partial_implementation; release proof)

### 44. Same source file targeted by multiple active items: Native/Ambitions/Domain/GoalRealityRiskModels.swift

- Conflict ID: `AMB28-same_source_file_targeted_by_multiple_active_batches-34363752`
- Type: `same_source_file_targeted_by_multiple_active_batches`
- Severity: `yellow`
- Recommended action: `merge`
- Rationale: Multiple active ledger items reference the same source file; merge, sequence, or assign ownership before implementation.
- Linear issue ready: `True`
- Auto-resolved: `False`
- Involved:
  - `GOAL_REALITY_COMPILER_BACKEND_MASTER_PLAN` — `docs/codex/GOAL_REALITY_COMPILER_BACKEND_MASTER_PLAN.md` (partial_implementation; release proof)
  - `MOAT-GOAL-REALITY-FIXTURE-LAB-02` — `prompts/batches/MOAT-GOAL-REALITY-FIXTURE-LAB-02.md` (partial_implementation; release proof)
  - `MOAT-UNIVERSAL-GOAL-REALITY-COMPILER-01` — `prompts/batches/MOAT-UNIVERSAL-GOAL-REALITY-COMPILER-01.md` (partial_implementation; release proof)
  - `MOAT-GOAL-REALITY-SOURCE-PACKS-09` — `prompts/batches/MOAT-GOAL-REALITY-SOURCE-PACKS-09.md` (partial_implementation; release proof)

### 45. Same source file targeted by multiple active items: Native/Ambitions/Domain/MoonshotProofPathModels.swift

- Conflict ID: `AMB28-same_source_file_targeted_by_multiple_active_batches-37872165`
- Type: `same_source_file_targeted_by_multiple_active_batches`
- Severity: `yellow`
- Recommended action: `merge`
- Rationale: Multiple active ledger items reference the same source file; merge, sequence, or assign ownership before implementation.
- Linear issue ready: `True`
- Auto-resolved: `False`
- Involved:
  - `MOONSHOT_PROOF_PATH_BACKEND_MASTER_PLAN` — `docs/codex/MOONSHOT_PROOF_PATH_BACKEND_MASTER_PLAN.md` (partial_implementation; release proof)
  - `MOAT-MOONSHOT-BACKEND-FULL-TRAIN-01` — `prompts/batches/MOAT-MOONSHOT-BACKEND-FULL-TRAIN-01.md` (partial_implementation; release proof)
  - `MOAT-MOONSHOT-PROOF-PATH-01` — `prompts/batches/MOAT-MOONSHOT-PROOF-PATH-01.md` (partial_implementation; release proof)
  - `MOAT-UNIVERSAL-GOAL-REALITY-COMPILER-01` — `prompts/batches/MOAT-UNIVERSAL-GOAL-REALITY-COMPILER-01.md` (partial_implementation; release proof)

### 46. Same source file targeted by multiple active items: Native/Ambitions/Domain/Planning/PlanningDomainModels.swift

- Conflict ID: `AMB28-same_source_file_targeted_by_multiple_active_batches-77770176`
- Type: `same_source_file_targeted_by_multiple_active_batches`
- Severity: `yellow`
- Recommended action: `merge`
- Rationale: Multiple active ledger items reference the same source file; merge, sequence, or assign ownership before implementation.
- Linear issue ready: `True`
- Auto-resolved: `False`
- Involved:
  - `PK21` — `prompts/batches/PK21.md` (partial_implementation; release proof)
  - `LDI15` — `prompts/batches/LDI15.md` (partial_implementation; release proof)

### 47. Same source file targeted by multiple active items: Native/Ambitions/Domain/RecommendationExplanationModels.swift

- Conflict ID: `AMB28-same_source_file_targeted_by_multiple_active_batches-16153706`
- Type: `same_source_file_targeted_by_multiple_active_batches`
- Severity: `yellow`
- Recommended action: `merge`
- Rationale: Multiple active ledger items reference the same source file; merge, sequence, or assign ownership before implementation.
- Linear issue ready: `True`
- Auto-resolved: `False`
- Involved:
  - `PK33` — `prompts/batches/PK33.md` (partial_implementation; release proof)
  - `MOAT-GOAL-REALITY-RECEIPT-CLOSURE-07` — `prompts/batches/MOAT-GOAL-REALITY-RECEIPT-CLOSURE-07.md` (partial_implementation; release proof)

### 48. Same source file targeted by multiple active items: Native/Ambitions/Domain/SourceAtlasPackModels.swift

- Conflict ID: `AMB28-same_source_file_targeted_by_multiple_active_batches-21373019`
- Type: `same_source_file_targeted_by_multiple_active_batches`
- Severity: `yellow`
- Recommended action: `merge`
- Rationale: Multiple active ledger items reference the same source file; merge, sequence, or assign ownership before implementation.
- Linear issue ready: `True`
- Auto-resolved: `False`
- Involved:
  - `SA07` — `prompts/batches/SA07.md` (partial_implementation; release proof)
  - `SA08` — `prompts/batches/SA08.md` (partial_implementation; release proof)
  - `SA09` — `prompts/batches/SA09.md` (partial_implementation; release proof)
  - `SA10` — `prompts/batches/SA10.md` (partial_implementation; release proof)
  - `SA10A` — `prompts/batches/SA10A.md` (partial_implementation; release proof)
  - `SA10B` — `prompts/batches/SA10B.md` (partial_implementation; release proof)
  - `SA10C` — `prompts/batches/SA10C.md` (partial_implementation; release proof)
  - `SA11` — `prompts/batches/SA11.md` (partial_implementation; release proof)
  - `SA12` — `prompts/batches/SA12.md` (partial_implementation; release proof)
  - `SA13` — `prompts/batches/SA13.md` (partial_implementation; release proof)
  - `SA14` — `prompts/batches/SA14.md` (partial_implementation; release proof)
  - `SA15` — `prompts/batches/SA15.md` (partial_implementation; release proof)
  - `SA16` — `prompts/batches/SA16.md` (partial_implementation; release proof)
  - `SA17` — `prompts/batches/SA17.md` (partial_implementation; release proof)
  - `SA18` — `prompts/batches/SA18.md` (partial_implementation; release proof)
  - `SA19` — `prompts/batches/SA19.md` (partial_implementation; release proof)
  - `SA20` — `prompts/batches/SA20.md` (partial_implementation; release proof)
  - `SA21` — `prompts/batches/SA21.md` (partial_implementation; release proof)
  - `SA22` — `prompts/batches/SA22.md` (partial_implementation; release proof)
  - `SA23` — `prompts/batches/SA23.md` (partial_implementation; release proof)
  - `SA24` — `prompts/batches/SA24.md` (partial_implementation; release proof)
  - `SA25` — `prompts/batches/SA25.md` (partial_implementation; release proof)
  - `SA26` — `prompts/batches/SA26.md` (partial_implementation; release proof)
  - `SA27` — `prompts/batches/SA27.md` (partial_implementation; release proof)
  - `SA28` — `prompts/batches/SA28.md` (partial_implementation; release proof)
  - `SA29` — `prompts/batches/SA29.md` (partial_implementation; release proof)
  - `SA30` — `prompts/batches/SA30.md` (partial_implementation; release proof)
  - `SA31` — `prompts/batches/SA31.md` (partial_implementation; release proof)
  - `SA32` — `prompts/batches/SA32.md` (partial_implementation; release proof)

### 49. Same source file targeted by multiple active items: Native/Ambitions/ExternalSnapshots/ExternalWidgetProjection.swift

- Conflict ID: `AMB28-same_source_file_targeted_by_multiple_active_batches-4083977`
- Type: `same_source_file_targeted_by_multiple_active_batches`
- Severity: `yellow`
- Recommended action: `merge`
- Rationale: Multiple active ledger items reference the same source file; merge, sequence, or assign ownership before implementation.
- Linear issue ready: `True`
- Auto-resolved: `False`
- Involved:
  - `PFC14_WidgetKit_Implementation_And_Tests_Prompt` — `docs/codex/batches/PFC14_WidgetKit_Implementation_And_Tests_Prompt.md` (partial_implementation; release proof)
  - `PFC13_WidgetKit_Strategy_And_Object_Map_Prompt` — `docs/codex/batches/PFC13_WidgetKit_Strategy_And_Object_Map_Prompt.md` (unknown; release proof)

### 50. Same source file targeted by multiple active items: Native/Ambitions/ExternalSnapshots/NextStepActivityAttributes.swift

- Conflict ID: `AMB28-same_source_file_targeted_by_multiple_active_batches-76696325`
- Type: `same_source_file_targeted_by_multiple_active_batches`
- Severity: `yellow`
- Recommended action: `merge`
- Rationale: Multiple active ledger items reference the same source file; merge, sequence, or assign ownership before implementation.
- Linear issue ready: `True`
- Auto-resolved: `False`
- Involved:
  - `PFC16_Live_Activities_Implementation_And_Tests_Prompt` — `docs/codex/batches/PFC16_Live_Activities_Implementation_And_Tests_Prompt.md` (partial_implementation; release proof)
  - `PK23` — `prompts/batches/PK23.md` (partial_implementation; release proof)

### 51. Same source file targeted by multiple active items: Native/Ambitions/Features/Capture/CaptureScreen.swift

- Conflict ID: `AMB28-same_source_file_targeted_by_multiple_active_batches-52882976`
- Type: `same_source_file_targeted_by_multiple_active_batches`
- Severity: `yellow`
- Recommended action: `merge`
- Rationale: Multiple active ledger items reference the same source file; merge, sequence, or assign ownership before implementation.
- Linear issue ready: `True`
- Auto-resolved: `False`
- Involved:
  - `repo-audit-baseline` — `docs/codex/repo-audit-baseline.md` (partial_implementation; release proof)
  - `AMB-POST23-01-TRUTH-AUDIT` — `docs/codex/reports/AMB-POST23-01-TRUTH-AUDIT.md` (partial_implementation; release proof)

### 52. Same source file targeted by multiple active items: Native/Ambitions/Features/Goals/GoalDetailScreen.swift

- Conflict ID: `AMB28-same_source_file_targeted_by_multiple_active_batches-26268722`
- Type: `same_source_file_targeted_by_multiple_active_batches`
- Severity: `yellow`
- Recommended action: `merge`
- Rationale: Multiple active ledger items reference the same source file; merge, sequence, or assign ownership before implementation.
- Linear issue ready: `True`
- Auto-resolved: `False`
- Involved:
  - `repo-audit-baseline` — `docs/codex/repo-audit-baseline.md` (partial_implementation; release proof)
  - `PK19` — `prompts/batches/PK19.md` (partial_implementation; release proof)
  - `BATCH-32-explainability-and-source-audit-surfaces` — `docs/codex/batches/BATCH-32-explainability-and-source-audit-surfaces.md` (unknown; release proof)

### 53. Same source file targeted by multiple active items: Native/Ambitions/Features/Goals/GoalsFeatureModels.swift

- Conflict ID: `AMB28-same_source_file_targeted_by_multiple_active_batches-7402687`
- Type: `same_source_file_targeted_by_multiple_active_batches`
- Severity: `yellow`
- Recommended action: `merge`
- Rationale: Multiple active ledger items reference the same source file; merge, sequence, or assign ownership before implementation.
- Linear issue ready: `True`
- Auto-resolved: `False`
- Involved:
  - `PK19` — `prompts/batches/PK19.md` (partial_implementation; release proof)
  - `BATCH-32-explainability-and-source-audit-surfaces` — `docs/codex/batches/BATCH-32-explainability-and-source-audit-surfaces.md` (unknown; release proof)

### 54. Same source file targeted by multiple active items: Native/Ambitions/Features/Goals/GoalsFeatureService.swift

- Conflict ID: `AMB28-same_source_file_targeted_by_multiple_active_batches-40878629`
- Type: `same_source_file_targeted_by_multiple_active_batches`
- Severity: `yellow`
- Recommended action: `merge`
- Rationale: Multiple active ledger items reference the same source file; merge, sequence, or assign ownership before implementation.
- Linear issue ready: `True`
- Auto-resolved: `False`
- Involved:
  - `repo-audit-baseline` — `docs/codex/repo-audit-baseline.md` (partial_implementation; release proof)
  - `BATCH-33-intelligence-runtime-integration` — `docs/codex/batches/BATCH-33-intelligence-runtime-integration.md` (partial_implementation; release proof)
  - `PK19` — `prompts/batches/PK19.md` (partial_implementation; release proof)
  - `PK37` — `prompts/batches/PK37.md` (partial_implementation; release proof)

### 55. Same source file targeted by multiple active items: Native/Ambitions/Features/Goals/GoalsScreen.swift

- Conflict ID: `AMB28-same_source_file_targeted_by_multiple_active_batches-45693093`
- Type: `same_source_file_targeted_by_multiple_active_batches`
- Severity: `yellow`
- Recommended action: `merge`
- Rationale: Multiple active ledger items reference the same source file; merge, sequence, or assign ownership before implementation.
- Linear issue ready: `True`
- Auto-resolved: `False`
- Involved:
  - `repo-audit-baseline` — `docs/codex/repo-audit-baseline.md` (partial_implementation; release proof)
  - `PK19` — `prompts/batches/PK19.md` (partial_implementation; release proof)
  - `AMB-POST23-01-TRUTH-AUDIT` — `docs/codex/reports/AMB-POST23-01-TRUTH-AUDIT.md` (partial_implementation; release proof)

### 56. Same source file targeted by multiple active items: Native/Ambitions/Features/Goals/GoalsViewModels.swift

- Conflict ID: `AMB28-same_source_file_targeted_by_multiple_active_batches-39690787`
- Type: `same_source_file_targeted_by_multiple_active_batches`
- Severity: `yellow`
- Recommended action: `merge`
- Rationale: Multiple active ledger items reference the same source file; merge, sequence, or assign ownership before implementation.
- Linear issue ready: `True`
- Auto-resolved: `False`
- Involved:
  - `repo-audit-baseline` — `docs/codex/repo-audit-baseline.md` (partial_implementation; release proof)
  - `PK19` — `prompts/batches/PK19.md` (partial_implementation; release proof)

### 57. Same source file targeted by multiple active items: Native/Ambitions/Features/Plan/PlanCalendarAwarenessSupport.swift

- Conflict ID: `AMB28-same_source_file_targeted_by_multiple_active_batches-88075929`
- Type: `same_source_file_targeted_by_multiple_active_batches`
- Severity: `yellow`
- Recommended action: `merge`
- Rationale: Multiple active ledger items reference the same source file; merge, sequence, or assign ownership before implementation.
- Linear issue ready: `True`
- Auto-resolved: `False`
- Involved:
  - `PFC20_Notifications_Calendar_Reminders_Implementation_Proof_Prompt` — `docs/codex/batches/PFC20_Notifications_Calendar_Reminders_Implementation_Proof_Prompt.md` (partial_implementation; release proof)
  - `PK24` — `prompts/batches/PK24.md` (partial_implementation; release proof)

### 58. Same source file targeted by multiple active items: Native/Ambitions/Features/Plan/PlanFeatureService.swift

- Conflict ID: `AMB28-same_source_file_targeted_by_multiple_active_batches-36899920`
- Type: `same_source_file_targeted_by_multiple_active_batches`
- Severity: `yellow`
- Recommended action: `merge`
- Rationale: Multiple active ledger items reference the same source file; merge, sequence, or assign ownership before implementation.
- Linear issue ready: `True`
- Auto-resolved: `False`
- Involved:
  - `PK21` — `prompts/batches/PK21.md` (partial_implementation; release proof)
  - `PK37` — `prompts/batches/PK37.md` (partial_implementation; release proof)
  - `LDI15` — `prompts/batches/LDI15.md` (partial_implementation; release proof)

### 59. Same source file targeted by multiple active items: Native/Ambitions/Features/Plan/PlanScreen.swift

- Conflict ID: `AMB28-same_source_file_targeted_by_multiple_active_batches-97024768`
- Type: `same_source_file_targeted_by_multiple_active_batches`
- Severity: `yellow`
- Recommended action: `merge`
- Rationale: Multiple active ledger items reference the same source file; merge, sequence, or assign ownership before implementation.
- Linear issue ready: `True`
- Auto-resolved: `False`
- Involved:
  - `PK21` — `prompts/batches/PK21.md` (partial_implementation; release proof)
  - `AMB-REPO-AUTHORITY-06-ACTIVE-DRIFT-REPAIR` — `prompts/batches/AMB-REPO-AUTHORITY-06-ACTIVE-DRIFT-REPAIR.md` (partial_implementation; release proof)
  - `ALIGN-01-NAMING` — `prompts/batches/ALIGN-01-NAMING.md` (partial_implementation; release proof)

### 60. Same source file targeted by multiple active items: Native/Ambitions/Features/Profile/ProfileScreen.swift

- Conflict ID: `AMB28-same_source_file_targeted_by_multiple_active_batches-85196815`
- Type: `same_source_file_targeted_by_multiple_active_batches`
- Severity: `yellow`
- Recommended action: `merge`
- Rationale: Multiple active ledger items reference the same source file; merge, sequence, or assign ownership before implementation.
- Linear issue ready: `True`
- Auto-resolved: `False`
- Involved:
  - `ALIGN-01-NAMING` — `prompts/batches/ALIGN-01-NAMING.md` (partial_implementation; release proof)
  - `FCP17_Schedule_Availability_Defaults_Center_Prompt` — `docs/codex/batches/FCP17_Schedule_Availability_Defaults_Center_Prompt.md` (unknown; release proof)

### 61. Same source file targeted by multiple active items: Native/Ambitions/Features/Time/TimeScreen.swift

- Conflict ID: `AMB28-same_source_file_targeted_by_multiple_active_batches-9257845`
- Type: `same_source_file_targeted_by_multiple_active_batches`
- Severity: `yellow`
- Recommended action: `merge`
- Rationale: Multiple active ledger items reference the same source file; merge, sequence, or assign ownership before implementation.
- Linear issue ready: `True`
- Auto-resolved: `False`
- Involved:
  - `ALIGN-01-NAMING` — `prompts/batches/ALIGN-01-NAMING.md` (partial_implementation; release proof)
  - `AMB-POST23-01-TRUTH-AUDIT` — `docs/codex/reports/AMB-POST23-01-TRUTH-AUDIT.md` (partial_implementation; release proof)

### 62. Same source file targeted by multiple active items: Native/Ambitions/Features/Today/DayRailProjection.swift

- Conflict ID: `AMB28-same_source_file_targeted_by_multiple_active_batches-98081479`
- Type: `same_source_file_targeted_by_multiple_active_batches`
- Severity: `yellow`
- Recommended action: `merge`
- Rationale: Multiple active ledger items reference the same source file; merge, sequence, or assign ownership before implementation.
- Linear issue ready: `True`
- Auto-resolved: `False`
- Involved:
  - `FCP05_Start_Here_Surface_Prompt` — `docs/codex/batches/FCP05_Start_Here_Surface_Prompt.md` (unknown; release proof)
  - `FCP07_Reality_Rail_Continuity_Prompt` — `docs/codex/batches/FCP07_Reality_Rail_Continuity_Prompt.md` (unknown; release proof)

### 63. Same source file targeted by multiple active items: Native/Ambitions/Features/Today/DayRailViewState.swift

- Conflict ID: `AMB28-same_source_file_targeted_by_multiple_active_batches-64051452`
- Type: `same_source_file_targeted_by_multiple_active_batches`
- Severity: `yellow`
- Recommended action: `merge`
- Rationale: Multiple active ledger items reference the same source file; merge, sequence, or assign ownership before implementation.
- Linear issue ready: `True`
- Auto-resolved: `False`
- Involved:
  - `MOONSHOT_PROOF_PATH_BACKEND_MASTER_PLAN` — `docs/codex/MOONSHOT_PROOF_PATH_BACKEND_MASTER_PLAN.md` (partial_implementation; release proof)
  - `MOAT-MOONSHOT-BACKEND-FULL-TRAIN-01` — `prompts/batches/MOAT-MOONSHOT-BACKEND-FULL-TRAIN-01.md` (partial_implementation; release proof)
  - `MOAT-MOONSHOT-PROOF-PATH-01` — `prompts/batches/MOAT-MOONSHOT-PROOF-PATH-01.md` (partial_implementation; release proof)
  - `MOAT-GOAL-REALITY-TODAY-BRIDGE-06` — `prompts/batches/MOAT-GOAL-REALITY-TODAY-BRIDGE-06.md` (partial_implementation; release proof)
  - `FCP05_Start_Here_Surface_Prompt` — `docs/codex/batches/FCP05_Start_Here_Surface_Prompt.md` (unknown; release proof)
  - `FCP07_Reality_Rail_Continuity_Prompt` — `docs/codex/batches/FCP07_Reality_Rail_Continuity_Prompt.md` (unknown; release proof)

### 64. Same source file targeted by multiple active items: Native/Ambitions/Features/Today/TodayDayRailPanels.swift

- Conflict ID: `AMB28-same_source_file_targeted_by_multiple_active_batches-31694407`
- Type: `same_source_file_targeted_by_multiple_active_batches`
- Severity: `yellow`
- Recommended action: `merge`
- Rationale: Multiple active ledger items reference the same source file; merge, sequence, or assign ownership before implementation.
- Linear issue ready: `True`
- Auto-resolved: `False`
- Involved:
  - `AMB-POST23-01-TRUTH-AUDIT` — `docs/codex/reports/AMB-POST23-01-TRUTH-AUDIT.md` (partial_implementation; release proof)
  - `FCP05_Start_Here_Surface_Prompt` — `docs/codex/batches/FCP05_Start_Here_Surface_Prompt.md` (unknown; release proof)
  - `FCP07_Reality_Rail_Continuity_Prompt` — `docs/codex/batches/FCP07_Reality_Rail_Continuity_Prompt.md` (unknown; release proof)

### 65. Same source file targeted by multiple active items: Native/Ambitions/Features/Today/TodayExecutionProjector.swift

- Conflict ID: `AMB28-same_source_file_targeted_by_multiple_active_batches-20313316`
- Type: `same_source_file_targeted_by_multiple_active_batches`
- Severity: `yellow`
- Recommended action: `merge`
- Rationale: Multiple active ledger items reference the same source file; merge, sequence, or assign ownership before implementation.
- Linear issue ready: `True`
- Auto-resolved: `False`
- Involved:
  - `PK17` — `prompts/batches/PK17.md` (partial_implementation; release proof)
  - `PK37` — `prompts/batches/PK37.md` (partial_implementation; release proof)
  - `MOONSHOT_PROOF_PATH_BACKEND_MASTER_PLAN` — `docs/codex/MOONSHOT_PROOF_PATH_BACKEND_MASTER_PLAN.md` (partial_implementation; release proof)
  - `MOAT-MOONSHOT-BACKEND-FULL-TRAIN-01` — `prompts/batches/MOAT-MOONSHOT-BACKEND-FULL-TRAIN-01.md` (partial_implementation; release proof)
  - `MOAT-MOONSHOT-PROOF-PATH-01` — `prompts/batches/MOAT-MOONSHOT-PROOF-PATH-01.md` (partial_implementation; release proof)
  - `MOAT-GOAL-REALITY-TODAY-BRIDGE-06` — `prompts/batches/MOAT-GOAL-REALITY-TODAY-BRIDGE-06.md` (partial_implementation; release proof)
  - `FCP05_Start_Here_Surface_Prompt` — `docs/codex/batches/FCP05_Start_Here_Surface_Prompt.md` (unknown; release proof)
  - `FCP07_Reality_Rail_Continuity_Prompt` — `docs/codex/batches/FCP07_Reality_Rail_Continuity_Prompt.md` (unknown; release proof)

### 66. Same source file targeted by multiple active items: Native/Ambitions/Features/Today/TodayExecutionViewState.swift

- Conflict ID: `AMB28-same_source_file_targeted_by_multiple_active_batches-20665873`
- Type: `same_source_file_targeted_by_multiple_active_batches`
- Severity: `yellow`
- Recommended action: `merge`
- Rationale: Multiple active ledger items reference the same source file; merge, sequence, or assign ownership before implementation.
- Linear issue ready: `True`
- Auto-resolved: `False`
- Involved:
  - `F03_5_Today_Execution_State_Contract_Hardening_Prompt` — `docs/codex/batches/F03_5_Today_Execution_State_Contract_Hardening_Prompt.md` (partial_implementation; release proof)
  - `PK17` — `prompts/batches/PK17.md` (partial_implementation; release proof)

### 67. Same source file targeted by multiple active items: Native/Ambitions/Features/Today/TodayFeatureService.swift

- Conflict ID: `AMB28-same_source_file_targeted_by_multiple_active_batches-36934`
- Type: `same_source_file_targeted_by_multiple_active_batches`
- Severity: `yellow`
- Recommended action: `merge`
- Rationale: Multiple active ledger items reference the same source file; merge, sequence, or assign ownership before implementation.
- Linear issue ready: `True`
- Auto-resolved: `False`
- Involved:
  - `repo-audit-baseline` — `docs/codex/repo-audit-baseline.md` (partial_implementation; release proof)
  - `BATCH-33-intelligence-runtime-integration` — `docs/codex/batches/BATCH-33-intelligence-runtime-integration.md` (partial_implementation; release proof)
  - `PK17` — `prompts/batches/PK17.md` (partial_implementation; release proof)
  - `PK18` — `prompts/batches/PK18.md` (partial_implementation; release proof)
  - `MOAT-GOAL-REALITY-TODAY-BRIDGE-06` — `prompts/batches/MOAT-GOAL-REALITY-TODAY-BRIDGE-06.md` (partial_implementation; release proof)
  - `BATCH-32-explainability-and-source-audit-surfaces` — `docs/codex/batches/BATCH-32-explainability-and-source-audit-surfaces.md` (unknown; release proof)

### 68. Same source file targeted by multiple active items: Native/Ambitions/Features/Today/TodayReadModelProjector.swift

- Conflict ID: `AMB28-same_source_file_targeted_by_multiple_active_batches-71659577`
- Type: `same_source_file_targeted_by_multiple_active_batches`
- Severity: `yellow`
- Recommended action: `merge`
- Rationale: Multiple active ledger items reference the same source file; merge, sequence, or assign ownership before implementation.
- Linear issue ready: `True`
- Auto-resolved: `False`
- Involved:
  - `BACKEND-FINAL-FORM-LOCAL-FIRST-HUMAN-01` — `prompts/batches/BACKEND-FINAL-FORM-LOCAL-FIRST-HUMAN-01.md` (partial_implementation; release proof)
  - `AMB-POST23-01-TRUTH-AUDIT` — `docs/codex/reports/AMB-POST23-01-TRUTH-AUDIT.md` (partial_implementation; release proof)

### 69. Same source file targeted by multiple active items: Native/Ambitions/Features/Today/TodayScreen.swift

- Conflict ID: `AMB28-same_source_file_targeted_by_multiple_active_batches-73269029`
- Type: `same_source_file_targeted_by_multiple_active_batches`
- Severity: `yellow`
- Recommended action: `merge`
- Rationale: Multiple active ledger items reference the same source file; merge, sequence, or assign ownership before implementation.
- Linear issue ready: `True`
- Auto-resolved: `False`
- Involved:
  - `repo-audit-baseline` — `docs/codex/repo-audit-baseline.md` (partial_implementation; release proof)
  - `PK17` — `prompts/batches/PK17.md` (partial_implementation; release proof)
  - `FLAGSHIP-OBJECT-SYSTEM-01` — `prompts/batches/FLAGSHIP-OBJECT-SYSTEM-01.md` (partial_implementation; release proof)
  - `AMB-POST23-01-TRUTH-AUDIT` — `docs/codex/reports/AMB-POST23-01-TRUTH-AUDIT.md` (partial_implementation; release proof)

### 70. Same source file targeted by multiple active items: Native/Ambitions/Features/Today/TodayViewModel.swift

- Conflict ID: `AMB28-same_source_file_targeted_by_multiple_active_batches-10987269`
- Type: `same_source_file_targeted_by_multiple_active_batches`
- Severity: `yellow`
- Recommended action: `merge`
- Rationale: Multiple active ledger items reference the same source file; merge, sequence, or assign ownership before implementation.
- Linear issue ready: `True`
- Auto-resolved: `False`
- Involved:
  - `repo-audit-baseline` — `docs/codex/repo-audit-baseline.md` (partial_implementation; release proof)
  - `PK17` — `prompts/batches/PK17.md` (partial_implementation; release proof)
  - `PK18` — `prompts/batches/PK18.md` (partial_implementation; release proof)

### 71. Same source file targeted by multiple active items: Native/Ambitions/Features/You/YouScreen.swift

- Conflict ID: `AMB28-same_source_file_targeted_by_multiple_active_batches-23017460`
- Type: `same_source_file_targeted_by_multiple_active_batches`
- Severity: `yellow`
- Recommended action: `merge`
- Rationale: Multiple active ledger items reference the same source file; merge, sequence, or assign ownership before implementation.
- Linear issue ready: `True`
- Auto-resolved: `False`
- Involved:
  - `ALIGN-01-NAMING` — `prompts/batches/ALIGN-01-NAMING.md` (partial_implementation; release proof)
  - `AMB-POST23-01-TRUTH-AUDIT` — `docs/codex/reports/AMB-POST23-01-TRUTH-AUDIT.md` (partial_implementation; release proof)

### 72. Same source file targeted by multiple active items: Native/Ambitions/Integrations/CalendarReminders/EventKitIntegrationService.swift

- Conflict ID: `AMB28-same_source_file_targeted_by_multiple_active_batches-84889310`
- Type: `same_source_file_targeted_by_multiple_active_batches`
- Severity: `yellow`
- Recommended action: `merge`
- Rationale: Multiple active ledger items reference the same source file; merge, sequence, or assign ownership before implementation.
- Linear issue ready: `True`
- Auto-resolved: `False`
- Involved:
  - `PFC20_Notifications_Calendar_Reminders_Implementation_Proof_Prompt` — `docs/codex/batches/PFC20_Notifications_Calendar_Reminders_Implementation_Proof_Prompt.md` (partial_implementation; release proof)
  - `PK24` — `prompts/batches/PK24.md` (partial_implementation; release proof)

### 73. Same source file targeted by multiple active items: Native/Ambitions/Persistence/LegacyImportService.swift

- Conflict ID: `AMB28-same_source_file_targeted_by_multiple_active_batches-32354531`
- Type: `same_source_file_targeted_by_multiple_active_batches`
- Severity: `yellow`
- Recommended action: `merge`
- Rationale: Multiple active ledger items reference the same source file; merge, sequence, or assign ownership before implementation.
- Linear issue ready: `True`
- Auto-resolved: `False`
- Involved:
  - `PFC07_Migration_Ladder_And_Backward_Compatibility_Tests_Prompt` — `docs/codex/batches/PFC07_Migration_Ladder_And_Backward_Compatibility_Tests_Prompt.md` (partial_implementation; release proof)
  - `PFC08_Corruption_Recovery_Backup_Restore_Plan_Prompt` — `docs/codex/batches/PFC08_Corruption_Recovery_Backup_Restore_Plan_Prompt.md` (unknown; release proof)

### 74. Same source file targeted by multiple active items: Native/Ambitions/Persistence/PersistenceContracts.swift

- Conflict ID: `AMB28-same_source_file_targeted_by_multiple_active_batches-86570980`
- Type: `same_source_file_targeted_by_multiple_active_batches`
- Severity: `yellow`
- Recommended action: `merge`
- Rationale: Multiple active ledger items reference the same source file; merge, sequence, or assign ownership before implementation.
- Linear issue ready: `True`
- Auto-resolved: `False`
- Involved:
  - `repo-audit-baseline` — `docs/codex/repo-audit-baseline.md` (partial_implementation; release proof)
  - `PK22` — `prompts/batches/PK22.md` (partial_implementation; release proof)
  - `BACKEND-FINAL-FORM-LOCAL-FIRST-HUMAN-01` — `prompts/batches/BACKEND-FINAL-FORM-LOCAL-FIRST-HUMAN-01.md` (partial_implementation; release proof)
  - `MOAT-GOAL-REALITY-LOCAL-PERSISTENCE-08` — `prompts/batches/MOAT-GOAL-REALITY-LOCAL-PERSISTENCE-08.md` (partial_implementation; release proof)
  - `BATCH-31-correction-and-teaching-loop` — `docs/codex/batches/BATCH-31-correction-and-teaching-loop.md` (unknown; release proof)

### 75. Same source file targeted by multiple active items: Native/Ambitions/Persistence/PortableSnapshotContracts.swift

- Conflict ID: `AMB28-same_source_file_targeted_by_multiple_active_batches-10793817`
- Type: `same_source_file_targeted_by_multiple_active_batches`
- Severity: `yellow`
- Recommended action: `merge`
- Rationale: Multiple active ledger items reference the same source file; merge, sequence, or assign ownership before implementation.
- Linear issue ready: `True`
- Auto-resolved: `False`
- Involved:
  - `PFC07_Migration_Ladder_And_Backward_Compatibility_Tests_Prompt` — `docs/codex/batches/PFC07_Migration_Ladder_And_Backward_Compatibility_Tests_Prompt.md` (partial_implementation; release proof)
  - `PK30` — `prompts/batches/PK30.md` (partial_implementation; release proof)
  - `PK31` — `prompts/batches/PK31.md` (partial_implementation; release proof)
  - `BACKEND-FINAL-FORM-LOCAL-FIRST-HUMAN-01` — `prompts/batches/BACKEND-FINAL-FORM-LOCAL-FIRST-HUMAN-01.md` (partial_implementation; release proof)
  - `AMB-POST23-01-TRUTH-AUDIT` — `docs/codex/reports/AMB-POST23-01-TRUTH-AUDIT.md` (partial_implementation; release proof)
  - `PFC08_Corruption_Recovery_Backup_Restore_Plan_Prompt` — `docs/codex/batches/PFC08_Corruption_Recovery_Backup_Restore_Plan_Prompt.md` (unknown; release proof)

### 76. Same source file targeted by multiple active items: Native/Ambitions/Persistence/PortableSnapshotService.swift

- Conflict ID: `AMB28-same_source_file_targeted_by_multiple_active_batches-11264815`
- Type: `same_source_file_targeted_by_multiple_active_batches`
- Severity: `yellow`
- Recommended action: `merge`
- Rationale: Multiple active ledger items reference the same source file; merge, sequence, or assign ownership before implementation.
- Linear issue ready: `True`
- Auto-resolved: `False`
- Involved:
  - `PFC07_Migration_Ladder_And_Backward_Compatibility_Tests_Prompt` — `docs/codex/batches/PFC07_Migration_Ladder_And_Backward_Compatibility_Tests_Prompt.md` (partial_implementation; release proof)
  - `PK31` — `prompts/batches/PK31.md` (partial_implementation; release proof)
  - `BACKEND-FINAL-FORM-LOCAL-FIRST-HUMAN-01` — `prompts/batches/BACKEND-FINAL-FORM-LOCAL-FIRST-HUMAN-01.md` (partial_implementation; release proof)
  - `AMB-POST23-01-TRUTH-AUDIT` — `docs/codex/reports/AMB-POST23-01-TRUTH-AUDIT.md` (partial_implementation; release proof)
  - `PFC08_Corruption_Recovery_Backup_Restore_Plan_Prompt` — `docs/codex/batches/PFC08_Corruption_Recovery_Backup_Restore_Plan_Prompt.md` (unknown; release proof)

### 77. Same source file targeted by multiple active items: Native/Ambitions/Persistence/StorageSchemaVersionLedger.swift

- Conflict ID: `AMB28-same_source_file_targeted_by_multiple_active_batches-20947205`
- Type: `same_source_file_targeted_by_multiple_active_batches`
- Severity: `yellow`
- Recommended action: `merge`
- Rationale: Multiple active ledger items reference the same source file; merge, sequence, or assign ownership before implementation.
- Linear issue ready: `True`
- Auto-resolved: `False`
- Involved:
  - `PK22` — `prompts/batches/PK22.md` (partial_implementation; release proof)
  - `BACKEND-FINAL-FORM-LOCAL-FIRST-HUMAN-01` — `prompts/batches/BACKEND-FINAL-FORM-LOCAL-FIRST-HUMAN-01.md` (partial_implementation; release proof)
  - `AMB-POST23-01-TRUTH-AUDIT` — `docs/codex/reports/AMB-POST23-01-TRUTH-AUDIT.md` (partial_implementation; release proof)

### 78. Same source file targeted by multiple active items: Native/Ambitions/Persistence/SwiftDataModels.swift

- Conflict ID: `AMB28-same_source_file_targeted_by_multiple_active_batches-74432253`
- Type: `same_source_file_targeted_by_multiple_active_batches`
- Severity: `yellow`
- Recommended action: `merge`
- Rationale: Multiple active ledger items reference the same source file; merge, sequence, or assign ownership before implementation.
- Linear issue ready: `True`
- Auto-resolved: `False`
- Involved:
  - `repo-audit-baseline` — `docs/codex/repo-audit-baseline.md` (partial_implementation; release proof)
  - `PFC07_Migration_Ladder_And_Backward_Compatibility_Tests_Prompt` — `docs/codex/batches/PFC07_Migration_Ladder_And_Backward_Compatibility_Tests_Prompt.md` (partial_implementation; release proof)
  - `BACKEND-FINAL-FORM-LOCAL-FIRST-HUMAN-01` — `prompts/batches/BACKEND-FINAL-FORM-LOCAL-FIRST-HUMAN-01.md` (partial_implementation; release proof)
  - `MOAT-GOAL-REALITY-LOCAL-PERSISTENCE-08` — `prompts/batches/MOAT-GOAL-REALITY-LOCAL-PERSISTENCE-08.md` (partial_implementation; release proof)

### 79. Same source file targeted by multiple active items: Native/Ambitions/Persistence/SwiftDataRepositories.swift

- Conflict ID: `AMB28-same_source_file_targeted_by_multiple_active_batches-30284685`
- Type: `same_source_file_targeted_by_multiple_active_batches`
- Severity: `yellow`
- Recommended action: `merge`
- Rationale: Multiple active ledger items reference the same source file; merge, sequence, or assign ownership before implementation.
- Linear issue ready: `True`
- Auto-resolved: `False`
- Involved:
  - `repo-audit-baseline` — `docs/codex/repo-audit-baseline.md` (partial_implementation; release proof)
  - `PFC07_Migration_Ladder_And_Backward_Compatibility_Tests_Prompt` — `docs/codex/batches/PFC07_Migration_Ladder_And_Backward_Compatibility_Tests_Prompt.md` (partial_implementation; release proof)
  - `PK22` — `prompts/batches/PK22.md` (partial_implementation; release proof)
  - `BACKEND-FINAL-FORM-LOCAL-FIRST-HUMAN-01` — `prompts/batches/BACKEND-FINAL-FORM-LOCAL-FIRST-HUMAN-01.md` (partial_implementation; release proof)
  - `MOAT-GOAL-REALITY-LOCAL-PERSISTENCE-08` — `prompts/batches/MOAT-GOAL-REALITY-LOCAL-PERSISTENCE-08.md` (partial_implementation; release proof)

### 80. Same source file targeted by multiple active items: Native/Ambitions/Persistence/SwiftDataStore.swift

- Conflict ID: `AMB28-same_source_file_targeted_by_multiple_active_batches-42751276`
- Type: `same_source_file_targeted_by_multiple_active_batches`
- Severity: `yellow`
- Recommended action: `merge`
- Rationale: Multiple active ledger items reference the same source file; merge, sequence, or assign ownership before implementation.
- Linear issue ready: `True`
- Auto-resolved: `False`
- Involved:
  - `repo-audit-baseline` — `docs/codex/repo-audit-baseline.md` (partial_implementation; release proof)
  - `PFC07_Migration_Ladder_And_Backward_Compatibility_Tests_Prompt` — `docs/codex/batches/PFC07_Migration_Ladder_And_Backward_Compatibility_Tests_Prompt.md` (partial_implementation; release proof)
  - `BACKEND-FINAL-FORM-LOCAL-FIRST-HUMAN-01` — `prompts/batches/BACKEND-FINAL-FORM-LOCAL-FIRST-HUMAN-01.md` (partial_implementation; release proof)
  - `MOAT-GOAL-REALITY-LOCAL-PERSISTENCE-08` — `prompts/batches/MOAT-GOAL-REALITY-LOCAL-PERSISTENCE-08.md` (partial_implementation; release proof)
  - `PFC08_Corruption_Recovery_Backup_Restore_Plan_Prompt` — `docs/codex/batches/PFC08_Corruption_Recovery_Backup_Restore_Plan_Prompt.md` (unknown; release proof)

### 81. Same source file targeted by multiple active items: Native/Ambitions/Persistence/SyncCapabilityContracts.swift

- Conflict ID: `AMB28-same_source_file_targeted_by_multiple_active_batches-64652885`
- Type: `same_source_file_targeted_by_multiple_active_batches`
- Severity: `yellow`
- Recommended action: `merge`
- Rationale: Multiple active ledger items reference the same source file; merge, sequence, or assign ownership before implementation.
- Linear issue ready: `True`
- Auto-resolved: `False`
- Involved:
  - `PFC07_Migration_Ladder_And_Backward_Compatibility_Tests_Prompt` — `docs/codex/batches/PFC07_Migration_Ladder_And_Backward_Compatibility_Tests_Prompt.md` (partial_implementation; release proof)
  - `PK30` — `prompts/batches/PK30.md` (partial_implementation; release proof)
  - `BACKEND-FINAL-FORM-LOCAL-FIRST-HUMAN-01` — `prompts/batches/BACKEND-FINAL-FORM-LOCAL-FIRST-HUMAN-01.md` (partial_implementation; release proof)
  - `PFC08_Corruption_Recovery_Backup_Restore_Plan_Prompt` — `docs/codex/batches/PFC08_Corruption_Recovery_Backup_Restore_Plan_Prompt.md` (unknown; release proof)

### 82. Same source file targeted by multiple active items: Native/Ambitions/PreviewSupport/PreviewFixtures.swift

- Conflict ID: `AMB28-same_source_file_targeted_by_multiple_active_batches-24438436`
- Type: `same_source_file_targeted_by_multiple_active_batches`
- Severity: `yellow`
- Recommended action: `merge`
- Rationale: Multiple active ledger items reference the same source file; merge, sequence, or assign ownership before implementation.
- Linear issue ready: `True`
- Auto-resolved: `False`
- Involved:
  - `repo-audit-baseline` — `docs/codex/repo-audit-baseline.md` (partial_implementation; release proof)
  - `FLAGSHIP_COMPLETION_GATE_MATRIX` — `docs/codex/FLAGSHIP_COMPLETION_GATE_MATRIX.md` (partial_implementation; release proof)

### 83. Same source file targeted by multiple active items: Native/Ambitions/PreviewSupport/PreviewGoalsScenarios.swift

- Conflict ID: `AMB28-same_source_file_targeted_by_multiple_active_batches-23403089`
- Type: `same_source_file_targeted_by_multiple_active_batches`
- Severity: `yellow`
- Recommended action: `merge`
- Rationale: Multiple active ledger items reference the same source file; merge, sequence, or assign ownership before implementation.
- Linear issue ready: `True`
- Auto-resolved: `False`
- Involved:
  - `repo-audit-baseline` — `docs/codex/repo-audit-baseline.md` (partial_implementation; release proof)
  - `FLAGSHIP_COMPLETION_GATE_MATRIX` — `docs/codex/FLAGSHIP_COMPLETION_GATE_MATRIX.md` (partial_implementation; release proof)

### 84. Same source file targeted by multiple active items: Native/Ambitions/PreviewSupport/PreviewTodayScenarios.swift

- Conflict ID: `AMB28-same_source_file_targeted_by_multiple_active_batches-82039618`
- Type: `same_source_file_targeted_by_multiple_active_batches`
- Severity: `yellow`
- Recommended action: `merge`
- Rationale: Multiple active ledger items reference the same source file; merge, sequence, or assign ownership before implementation.
- Linear issue ready: `True`
- Auto-resolved: `False`
- Involved:
  - `repo-audit-baseline` — `docs/codex/repo-audit-baseline.md` (partial_implementation; release proof)
  - `FLAGSHIP_COMPLETION_GATE_MATRIX` — `docs/codex/FLAGSHIP_COMPLETION_GATE_MATRIX.md` (partial_implementation; release proof)
  - `MOONSHOT_PROOF_PATH_BACKEND_MASTER_PLAN` — `docs/codex/MOONSHOT_PROOF_PATH_BACKEND_MASTER_PLAN.md` (partial_implementation; release proof)
  - `MOAT-MOONSHOT-BACKEND-FULL-TRAIN-01` — `prompts/batches/MOAT-MOONSHOT-BACKEND-FULL-TRAIN-01.md` (partial_implementation; release proof)
  - `MOAT-MOONSHOT-PROOF-PATH-01` — `prompts/batches/MOAT-MOONSHOT-PROOF-PATH-01.md` (partial_implementation; release proof)
  - `MOAT-GOAL-REALITY-TODAY-BRIDGE-06` — `prompts/batches/MOAT-GOAL-REALITY-TODAY-BRIDGE-06.md` (partial_implementation; release proof)
  - `FCP05_Start_Here_Surface_Prompt` — `docs/codex/batches/FCP05_Start_Here_Surface_Prompt.md` (unknown; release proof)
  - `FCP07_Reality_Rail_Continuity_Prompt` — `docs/codex/batches/FCP07_Reality_Rail_Continuity_Prompt.md` (unknown; release proof)

### 85. Same source file targeted by multiple active items: Native/Ambitions/Runtime/AmbitionsRuntimeContracts.swift

- Conflict ID: `AMB28-same_source_file_targeted_by_multiple_active_batches-21270387`
- Type: `same_source_file_targeted_by_multiple_active_batches`
- Severity: `yellow`
- Recommended action: `merge`
- Rationale: Multiple active ledger items reference the same source file; merge, sequence, or assign ownership before implementation.
- Linear issue ready: `True`
- Auto-resolved: `False`
- Involved:
  - `BATCH-33-intelligence-runtime-integration` — `docs/codex/batches/BATCH-33-intelligence-runtime-integration.md` (partial_implementation; release proof)
  - `MOONSHOT_PROOF_PATH_BACKEND_MASTER_PLAN` — `docs/codex/MOONSHOT_PROOF_PATH_BACKEND_MASTER_PLAN.md` (partial_implementation; release proof)
  - `MOAT-MOONSHOT-BACKEND-FULL-TRAIN-01` — `prompts/batches/MOAT-MOONSHOT-BACKEND-FULL-TRAIN-01.md` (partial_implementation; release proof)
  - `MOAT-MOONSHOT-PROOF-PATH-01` — `prompts/batches/MOAT-MOONSHOT-PROOF-PATH-01.md` (partial_implementation; release proof)
  - `MOAT-UNIVERSAL-GOAL-REALITY-COMPILER-01` — `prompts/batches/MOAT-UNIVERSAL-GOAL-REALITY-COMPILER-01.md` (partial_implementation; release proof)
  - `MOAT-GOAL-REALITY-RUNTIME-SERVICE-03` — `prompts/batches/MOAT-GOAL-REALITY-RUNTIME-SERVICE-03.md` (partial_implementation; release proof)

### 86. Same source file targeted by multiple active items: Native/Ambitions/Runtime/AmbitionsRuntimeFactory.swift

- Conflict ID: `AMB28-same_source_file_targeted_by_multiple_active_batches-5995`
- Type: `same_source_file_targeted_by_multiple_active_batches`
- Severity: `yellow`
- Recommended action: `merge`
- Rationale: Multiple active ledger items reference the same source file; merge, sequence, or assign ownership before implementation.
- Linear issue ready: `True`
- Auto-resolved: `False`
- Involved:
  - `BATCH-33-intelligence-runtime-integration` — `docs/codex/batches/BATCH-33-intelligence-runtime-integration.md` (partial_implementation; release proof)
  - `MOONSHOT_PROOF_PATH_BACKEND_MASTER_PLAN` — `docs/codex/MOONSHOT_PROOF_PATH_BACKEND_MASTER_PLAN.md` (partial_implementation; release proof)
  - `MOAT-MOONSHOT-BACKEND-FULL-TRAIN-01` — `prompts/batches/MOAT-MOONSHOT-BACKEND-FULL-TRAIN-01.md` (partial_implementation; release proof)
  - `MOAT-MOONSHOT-PROOF-PATH-01` — `prompts/batches/MOAT-MOONSHOT-PROOF-PATH-01.md` (partial_implementation; release proof)
  - `MOAT-UNIVERSAL-GOAL-REALITY-COMPILER-01` — `prompts/batches/MOAT-UNIVERSAL-GOAL-REALITY-COMPILER-01.md` (partial_implementation; release proof)
  - `MOAT-GOAL-REALITY-RUNTIME-SERVICE-03` — `prompts/batches/MOAT-GOAL-REALITY-RUNTIME-SERVICE-03.md` (partial_implementation; release proof)

### 87. Same source file targeted by multiple active items: Native/Ambitions/Runtime/AmbitionsRuntimeGoalIntelligence.swift

- Conflict ID: `AMB28-same_source_file_targeted_by_multiple_active_batches-88570139`
- Type: `same_source_file_targeted_by_multiple_active_batches`
- Severity: `yellow`
- Recommended action: `merge`
- Rationale: Multiple active ledger items reference the same source file; merge, sequence, or assign ownership before implementation.
- Linear issue ready: `True`
- Auto-resolved: `False`
- Involved:
  - `BATCH-33-intelligence-runtime-integration` — `docs/codex/batches/BATCH-33-intelligence-runtime-integration.md` (partial_implementation; release proof)
  - `MOONSHOT_PROOF_PATH_BACKEND_MASTER_PLAN` — `docs/codex/MOONSHOT_PROOF_PATH_BACKEND_MASTER_PLAN.md` (partial_implementation; release proof)
  - `MOAT-MOONSHOT-BACKEND-FULL-TRAIN-01` — `prompts/batches/MOAT-MOONSHOT-BACKEND-FULL-TRAIN-01.md` (partial_implementation; release proof)
  - `MOAT-MOONSHOT-PROOF-PATH-01` — `prompts/batches/MOAT-MOONSHOT-PROOF-PATH-01.md` (partial_implementation; release proof)
  - `MOAT-UNIVERSAL-GOAL-REALITY-COMPILER-01` — `prompts/batches/MOAT-UNIVERSAL-GOAL-REALITY-COMPILER-01.md` (partial_implementation; release proof)
  - `MOAT-GOAL-REALITY-RUNTIME-SERVICE-03` — `prompts/batches/MOAT-GOAL-REALITY-RUNTIME-SERVICE-03.md` (partial_implementation; release proof)

### 88. Same source file targeted by multiple active items: Native/Ambitions/Runtime/GoalRealityCompiler.swift

- Conflict ID: `AMB28-same_source_file_targeted_by_multiple_active_batches-99325654`
- Type: `same_source_file_targeted_by_multiple_active_batches`
- Severity: `yellow`
- Recommended action: `merge`
- Rationale: Multiple active ledger items reference the same source file; merge, sequence, or assign ownership before implementation.
- Linear issue ready: `True`
- Auto-resolved: `False`
- Involved:
  - `GOAL_REALITY_COMPILER_BACKEND_MASTER_PLAN` — `docs/codex/GOAL_REALITY_COMPILER_BACKEND_MASTER_PLAN.md` (partial_implementation; release proof)
  - `MOAT-GOAL-REALITY-FIXTURE-LAB-02` — `prompts/batches/MOAT-GOAL-REALITY-FIXTURE-LAB-02.md` (partial_implementation; release proof)
  - `MOAT-UNIVERSAL-GOAL-REALITY-COMPILER-01` — `prompts/batches/MOAT-UNIVERSAL-GOAL-REALITY-COMPILER-01.md` (partial_implementation; release proof)
  - `MOAT-GOAL-REALITY-EVAL-HARNESS-10` — `prompts/batches/MOAT-GOAL-REALITY-EVAL-HARNESS-10.md` (partial_implementation; release proof)
  - `MOAT-GOAL-REALITY-RECEIPT-CLOSURE-07` — `prompts/batches/MOAT-GOAL-REALITY-RECEIPT-CLOSURE-07.md` (partial_implementation; release proof)
  - `MOAT-GOAL-REALITY-RUNTIME-SERVICE-03` — `prompts/batches/MOAT-GOAL-REALITY-RUNTIME-SERVICE-03.md` (partial_implementation; release proof)
  - `MOAT-GOAL-REALITY-SOURCE-PACKS-09` — `prompts/batches/MOAT-GOAL-REALITY-SOURCE-PACKS-09.md` (partial_implementation; release proof)

### 89. Same source file targeted by multiple active items: Native/Ambitions/Runtime/GoalRealityFixtureLab.swift

- Conflict ID: `AMB28-same_source_file_targeted_by_multiple_active_batches-4983108`
- Type: `same_source_file_targeted_by_multiple_active_batches`
- Severity: `yellow`
- Recommended action: `merge`
- Rationale: Multiple active ledger items reference the same source file; merge, sequence, or assign ownership before implementation.
- Linear issue ready: `True`
- Auto-resolved: `False`
- Involved:
  - `GOAL_REALITY_COMPILER_BACKEND_MASTER_PLAN` — `docs/codex/GOAL_REALITY_COMPILER_BACKEND_MASTER_PLAN.md` (partial_implementation; release proof)
  - `MOAT-GOAL-REALITY-FIXTURE-LAB-02` — `prompts/batches/MOAT-GOAL-REALITY-FIXTURE-LAB-02.md` (partial_implementation; release proof)
  - `MOAT-UNIVERSAL-GOAL-REALITY-COMPILER-01` — `prompts/batches/MOAT-UNIVERSAL-GOAL-REALITY-COMPILER-01.md` (partial_implementation; release proof)
  - `MOAT-GOAL-REALITY-EVAL-HARNESS-10` — `prompts/batches/MOAT-GOAL-REALITY-EVAL-HARNESS-10.md` (partial_implementation; release proof)
  - `MOAT-GOAL-REALITY-RUNTIME-SERVICE-03` — `prompts/batches/MOAT-GOAL-REALITY-RUNTIME-SERVICE-03.md` (partial_implementation; release proof)

### 90. Same source file targeted by multiple active items: Native/Ambitions/Runtime/GoalRealityReceiptClosureService.swift

- Conflict ID: `AMB28-same_source_file_targeted_by_multiple_active_batches-59713474`
- Type: `same_source_file_targeted_by_multiple_active_batches`
- Severity: `yellow`
- Recommended action: `merge`
- Rationale: Multiple active ledger items reference the same source file; merge, sequence, or assign ownership before implementation.
- Linear issue ready: `True`
- Auto-resolved: `False`
- Involved:
  - `MOAT-GOAL-REALITY-LOCAL-PERSISTENCE-08` — `prompts/batches/MOAT-GOAL-REALITY-LOCAL-PERSISTENCE-08.md` (partial_implementation; release proof)
  - `MOAT-GOAL-REALITY-RECEIPT-CLOSURE-07` — `prompts/batches/MOAT-GOAL-REALITY-RECEIPT-CLOSURE-07.md` (partial_implementation; release proof)

### 91. Same source file targeted by multiple active items: Native/Ambitions/Runtime/GoalRealityRuntimeService.swift

- Conflict ID: `AMB28-same_source_file_targeted_by_multiple_active_batches-991068`
- Type: `same_source_file_targeted_by_multiple_active_batches`
- Severity: `yellow`
- Recommended action: `merge`
- Rationale: Multiple active ledger items reference the same source file; merge, sequence, or assign ownership before implementation.
- Linear issue ready: `True`
- Auto-resolved: `False`
- Involved:
  - `GOAL_REALITY_COMPILER_BACKEND_MASTER_PLAN` — `docs/codex/GOAL_REALITY_COMPILER_BACKEND_MASTER_PLAN.md` (partial_implementation; release proof)
  - `MOAT-GOAL-REALITY-RUNTIME-SERVICE-03` — `prompts/batches/MOAT-GOAL-REALITY-RUNTIME-SERVICE-03.md` (partial_implementation; release proof)
  - `MOAT-GOAL-REALITY-TODAY-BRIDGE-06` — `prompts/batches/MOAT-GOAL-REALITY-TODAY-BRIDGE-06.md` (partial_implementation; release proof)

### 92. Same source file targeted by multiple active items: Native/Ambitions/Runtime/GoalRealitySourceBoundaryService.swift

- Conflict ID: `AMB28-same_source_file_targeted_by_multiple_active_batches-10497244`
- Type: `same_source_file_targeted_by_multiple_active_batches`
- Severity: `yellow`
- Recommended action: `merge`
- Rationale: Multiple active ledger items reference the same source file; merge, sequence, or assign ownership before implementation.
- Linear issue ready: `True`
- Auto-resolved: `False`
- Involved:
  - `MOAT-GOAL-REALITY-EVAL-HARNESS-10` — `prompts/batches/MOAT-GOAL-REALITY-EVAL-HARNESS-10.md` (partial_implementation; release proof)
  - `MOAT-GOAL-REALITY-SOURCE-PACKS-09` — `prompts/batches/MOAT-GOAL-REALITY-SOURCE-PACKS-09.md` (partial_implementation; release proof)

### 93. Same source file targeted by multiple active items: Native/Ambitions/Runtime/GoalRealityValidator.swift

- Conflict ID: `AMB28-same_source_file_targeted_by_multiple_active_batches-59823279`
- Type: `same_source_file_targeted_by_multiple_active_batches`
- Severity: `yellow`
- Recommended action: `merge`
- Rationale: Multiple active ledger items reference the same source file; merge, sequence, or assign ownership before implementation.
- Linear issue ready: `True`
- Auto-resolved: `False`
- Involved:
  - `GOAL_REALITY_COMPILER_BACKEND_MASTER_PLAN` — `docs/codex/GOAL_REALITY_COMPILER_BACKEND_MASTER_PLAN.md` (partial_implementation; release proof)
  - `MOAT-GOAL-REALITY-FIXTURE-LAB-02` — `prompts/batches/MOAT-GOAL-REALITY-FIXTURE-LAB-02.md` (partial_implementation; release proof)
  - `MOAT-UNIVERSAL-GOAL-REALITY-COMPILER-01` — `prompts/batches/MOAT-UNIVERSAL-GOAL-REALITY-COMPILER-01.md` (partial_implementation; release proof)
  - `MOAT-GOAL-REALITY-EVAL-HARNESS-10` — `prompts/batches/MOAT-GOAL-REALITY-EVAL-HARNESS-10.md` (partial_implementation; release proof)
  - `MOAT-GOAL-REALITY-RECEIPT-CLOSURE-07` — `prompts/batches/MOAT-GOAL-REALITY-RECEIPT-CLOSURE-07.md` (partial_implementation; release proof)
  - `MOAT-GOAL-REALITY-RUNTIME-SERVICE-03` — `prompts/batches/MOAT-GOAL-REALITY-RUNTIME-SERVICE-03.md` (partial_implementation; release proof)
  - `MOAT-GOAL-REALITY-SOURCE-PACKS-09` — `prompts/batches/MOAT-GOAL-REALITY-SOURCE-PACKS-09.md` (partial_implementation; release proof)

### 94. Same source file targeted by multiple active items: Native/Ambitions/Runtime/MoonshotProofPathRuntime.swift

- Conflict ID: `AMB28-same_source_file_targeted_by_multiple_active_batches-21358044`
- Type: `same_source_file_targeted_by_multiple_active_batches`
- Severity: `yellow`
- Recommended action: `merge`
- Rationale: Multiple active ledger items reference the same source file; merge, sequence, or assign ownership before implementation.
- Linear issue ready: `True`
- Auto-resolved: `False`
- Involved:
  - `MOONSHOT_PROOF_PATH_BACKEND_MASTER_PLAN` — `docs/codex/MOONSHOT_PROOF_PATH_BACKEND_MASTER_PLAN.md` (partial_implementation; release proof)
  - `MOAT-MOONSHOT-BACKEND-FULL-TRAIN-01` — `prompts/batches/MOAT-MOONSHOT-BACKEND-FULL-TRAIN-01.md` (partial_implementation; release proof)
  - `MOAT-MOONSHOT-PROOF-PATH-01` — `prompts/batches/MOAT-MOONSHOT-PROOF-PATH-01.md` (partial_implementation; release proof)
  - `MOAT-UNIVERSAL-GOAL-REALITY-COMPILER-01` — `prompts/batches/MOAT-UNIVERSAL-GOAL-REALITY-COMPILER-01.md` (partial_implementation; release proof)

### 95. Same source file targeted by multiple active items: Native/Ambitions/Services/AmbitionsCommandExecutor.swift

- Conflict ID: `AMB28-same_source_file_targeted_by_multiple_active_batches-74688732`
- Type: `same_source_file_targeted_by_multiple_active_batches`
- Severity: `yellow`
- Recommended action: `merge`
- Rationale: Multiple active ledger items reference the same source file; merge, sequence, or assign ownership before implementation.
- Linear issue ready: `True`
- Auto-resolved: `False`
- Involved:
  - `PK18` — `prompts/batches/PK18.md` (partial_implementation; release proof)
  - `PK22` — `prompts/batches/PK22.md` (partial_implementation; release proof)
  - `LDI15` — `prompts/batches/LDI15.md` (partial_implementation; release proof)
  - `LDI16` — `prompts/batches/LDI16.md` (partial_implementation; release proof)
  - `LDI17` — `prompts/batches/LDI17.md` (partial_implementation; release proof)
  - `LDI18` — `prompts/batches/LDI18.md` (partial_implementation; release proof)
  - `LDI19` — `prompts/batches/LDI19.md` (partial_implementation; release proof)
  - `LDI20` — `prompts/batches/LDI20.md` (partial_implementation; release proof)
  - `LDI21` — `prompts/batches/LDI21.md` (partial_implementation; release proof)
  - `LDI22` — `prompts/batches/LDI22.md` (partial_implementation; release proof)
  - `AMB-POST23-01-TRUTH-AUDIT` — `docs/codex/reports/AMB-POST23-01-TRUTH-AUDIT.md` (partial_implementation; release proof)

### 96. Same source file targeted by multiple active items: Native/Ambitions/Services/CaptureService.swift

- Conflict ID: `AMB28-same_source_file_targeted_by_multiple_active_batches-63545973`
- Type: `same_source_file_targeted_by_multiple_active_batches`
- Severity: `yellow`
- Recommended action: `merge`
- Rationale: Multiple active ledger items reference the same source file; merge, sequence, or assign ownership before implementation.
- Linear issue ready: `True`
- Auto-resolved: `False`
- Involved:
  - `repo-audit-baseline` — `docs/codex/repo-audit-baseline.md` (partial_implementation; release proof)
  - `PK20` — `prompts/batches/PK20.md` (partial_implementation; release proof)
  - `AMB-POST23-01-TRUTH-AUDIT` — `docs/codex/reports/AMB-POST23-01-TRUTH-AUDIT.md` (partial_implementation; release proof)

### 97. Same source file targeted by multiple active items: Native/Ambitions/Services/ExternalActionCommandService.swift

- Conflict ID: `AMB28-same_source_file_targeted_by_multiple_active_batches-94618545`
- Type: `same_source_file_targeted_by_multiple_active_batches`
- Severity: `yellow`
- Recommended action: `merge`
- Rationale: Multiple active ledger items reference the same source file; merge, sequence, or assign ownership before implementation.
- Linear issue ready: `True`
- Auto-resolved: `False`
- Involved:
  - `PFC18_App_Intents_Shortcuts_Implementation_And_Tests_Prompt` — `docs/codex/batches/PFC18_App_Intents_Shortcuts_Implementation_And_Tests_Prompt.md` (partial_implementation; release proof)
  - `PFC20_Notifications_Calendar_Reminders_Implementation_Proof_Prompt` — `docs/codex/batches/PFC20_Notifications_Calendar_Reminders_Implementation_Proof_Prompt.md` (partial_implementation; release proof)

### 98. Same source file targeted by multiple active items: Native/Ambitions/Services/GoalContradictionService.swift

- Conflict ID: `AMB28-same_source_file_targeted_by_multiple_active_batches-84460208`
- Type: `same_source_file_targeted_by_multiple_active_batches`
- Severity: `yellow`
- Recommended action: `merge`
- Rationale: Multiple active ledger items reference the same source file; merge, sequence, or assign ownership before implementation.
- Linear issue ready: `True`
- Auto-resolved: `False`
- Involved:
  - `AMB-POST23-01-TRUTH-AUDIT` — `docs/codex/reports/AMB-POST23-01-TRUTH-AUDIT.md` (partial_implementation; release proof)
  - `BATCH-30-contradiction-engine` — `docs/codex/batches/BATCH-30-contradiction-engine.md` (unknown; release proof)

### 99. Same source file targeted by multiple active items: Native/Ambitions/Services/GoalPathCompilerService.swift

- Conflict ID: `AMB28-same_source_file_targeted_by_multiple_active_batches-92305838`
- Type: `same_source_file_targeted_by_multiple_active_batches`
- Severity: `yellow`
- Recommended action: `merge`
- Rationale: Multiple active ledger items reference the same source file; merge, sequence, or assign ownership before implementation.
- Linear issue ready: `True`
- Auto-resolved: `False`
- Involved:
  - `BATCH-24-path-compiler-foundation` — `docs/codex/batches/BATCH-24-path-compiler-foundation.md` (unknown; release proof)
  - `BATCH-25-domain-pack-framework` — `docs/codex/batches/BATCH-25-domain-pack-framework.md` (unknown; release proof)

### 100. Same source file targeted by multiple active items: Native/Ambitions/Services/GoalUnderstandingService.swift

- Conflict ID: `AMB28-same_source_file_targeted_by_multiple_active_batches-87761293`
- Type: `same_source_file_targeted_by_multiple_active_batches`
- Severity: `yellow`
- Recommended action: `merge`
- Rationale: Multiple active ledger items reference the same source file; merge, sequence, or assign ownership before implementation.
- Linear issue ready: `True`
- Auto-resolved: `False`
- Involved:
  - `AMB-POST23-01-TRUTH-AUDIT` — `docs/codex/reports/AMB-POST23-01-TRUTH-AUDIT.md` (partial_implementation; release proof)
  - `BATCH-23-generalized-goal-understanding-contracts` — `docs/codex/batches/BATCH-23-generalized-goal-understanding-contracts.md` (unknown; release proof)

### 101. Same source file targeted by multiple active items: Native/Ambitions/Services/KnowledgeIngestionService.swift

- Conflict ID: `AMB28-same_source_file_targeted_by_multiple_active_batches-57423781`
- Type: `same_source_file_targeted_by_multiple_active_batches`
- Severity: `yellow`
- Recommended action: `merge`
- Rationale: Multiple active ledger items reference the same source file; merge, sequence, or assign ownership before implementation.
- Linear issue ready: `True`
- Auto-resolved: `False`
- Involved:
  - `AMB-POST23-01-TRUTH-AUDIT` — `docs/codex/reports/AMB-POST23-01-TRUTH-AUDIT.md` (partial_implementation; release proof)
  - `BATCH-21-external-knowledge-ingestion-core` — `docs/codex/batches/BATCH-21-external-knowledge-ingestion-core.md` (unknown; release proof)

### 102. Same source file targeted by multiple active items: Native/Ambitions/Services/KnowledgeProviderBoundary.swift

- Conflict ID: `AMB28-same_source_file_targeted_by_multiple_active_batches-66277544`
- Type: `same_source_file_targeted_by_multiple_active_batches`
- Severity: `yellow`
- Recommended action: `merge`
- Rationale: Multiple active ledger items reference the same source file; merge, sequence, or assign ownership before implementation.
- Linear issue ready: `True`
- Auto-resolved: `False`
- Involved:
  - `BATCH-20-knowledge-provider-boundary` — `docs/codex/batches/BATCH-20-knowledge-provider-boundary.md` (unknown; release proof)
  - `BATCH-21-external-knowledge-ingestion-core` — `docs/codex/batches/BATCH-21-external-knowledge-ingestion-core.md` (unknown; release proof)

### 103. Same source file targeted by multiple active items: Native/Ambitions/Services/SmartAttachmentService.swift

- Conflict ID: `AMB28-same_source_file_targeted_by_multiple_active_batches-17732795`
- Type: `same_source_file_targeted_by_multiple_active_batches`
- Severity: `yellow`
- Recommended action: `merge`
- Rationale: Multiple active ledger items reference the same source file; merge, sequence, or assign ownership before implementation.
- Linear issue ready: `True`
- Auto-resolved: `False`
- Involved:
  - `TRAIN_04D_CAPTURE_RUNTIME_FACTORING_FUTURE_PROOF` — `prompts/trains/ios26-flagship/TRAIN_04D_CAPTURE_RUNTIME_FACTORING_FUTURE_PROOF.md` (partial_implementation; release proof)
  - `concept-lock-registry` — `docs/codex/concept-lock-registry.yml` (partial_implementation; tests)

### 104. Same source file targeted by multiple active items: Native/Ambitions/Support/ReleasePerformanceResponsivenessReport.swift

- Conflict ID: `AMB28-same_source_file_targeted_by_multiple_active_batches-53400374`
- Type: `same_source_file_targeted_by_multiple_active_batches`
- Severity: `yellow`
- Recommended action: `merge`
- Rationale: Multiple active ledger items reference the same source file; merge, sequence, or assign ownership before implementation.
- Linear issue ready: `True`
- Auto-resolved: `False`
- Involved:
  - `PK36` — `prompts/batches/PK36.md` (partial_implementation; release proof)
  - `PFC36` — `prompts/batches/PFC36.md` (partial_implementation; release proof)

### 105. Same source file targeted by multiple active items: Native/AmbitionsTests/App/AppContainerFactoryTests.swift

- Conflict ID: `AMB28-same_source_file_targeted_by_multiple_active_batches-77166645`
- Type: `same_source_file_targeted_by_multiple_active_batches`
- Severity: `yellow`
- Recommended action: `merge`
- Rationale: Multiple active ledger items reference the same source file; merge, sequence, or assign ownership before implementation.
- Linear issue ready: `True`
- Auto-resolved: `False`
- Involved:
  - `BATCH-33-intelligence-runtime-integration` — `docs/codex/batches/BATCH-33-intelligence-runtime-integration.md` (partial_implementation; release proof)
  - `MOAT-GOAL-REALITY-RUNTIME-SERVICE-03` — `prompts/batches/MOAT-GOAL-REALITY-RUNTIME-SERVICE-03.md` (partial_implementation; release proof)

### 106. Same source file targeted by multiple active items: Native/AmbitionsTests/App/AppShellNavigationTests.swift

- Conflict ID: `AMB28-same_source_file_targeted_by_multiple_active_batches-70593123`
- Type: `same_source_file_targeted_by_multiple_active_batches`
- Severity: `yellow`
- Recommended action: `merge`
- Rationale: Multiple active ledger items reference the same source file; merge, sequence, or assign ownership before implementation.
- Linear issue ready: `True`
- Auto-resolved: `False`
- Involved:
  - `TOP-LEVEL-IA-PLAN-LEAK-REGRESSION-01` — `prompts/batches/TOP-LEVEL-IA-PLAN-LEAK-REGRESSION-01.md` (partial_implementation; release proof)
  - `FCP08_Ambition_Meridian_Shell_Prompt` — `docs/codex/batches/FCP08_Ambition_Meridian_Shell_Prompt.md` (unknown; release proof)

### 107. Same source file targeted by multiple active items: Native/AmbitionsTests/App/ExternalSurfaceSnapshotTests.swift

- Conflict ID: `AMB28-same_source_file_targeted_by_multiple_active_batches-48549367`
- Type: `same_source_file_targeted_by_multiple_active_batches`
- Severity: `yellow`
- Recommended action: `merge`
- Rationale: Multiple active ledger items reference the same source file; merge, sequence, or assign ownership before implementation.
- Linear issue ready: `True`
- Auto-resolved: `False`
- Involved:
  - `PFC14_WidgetKit_Implementation_And_Tests_Prompt` — `docs/codex/batches/PFC14_WidgetKit_Implementation_And_Tests_Prompt.md` (partial_implementation; release proof)
  - `PFC16_Live_Activities_Implementation_And_Tests_Prompt` — `docs/codex/batches/PFC16_Live_Activities_Implementation_And_Tests_Prompt.md` (partial_implementation; release proof)

### 108. Same source file targeted by multiple active items: Native/AmbitionsTests/App/ExternalWidgetProjectionTests.swift

- Conflict ID: `AMB28-same_source_file_targeted_by_multiple_active_batches-73398965`
- Type: `same_source_file_targeted_by_multiple_active_batches`
- Severity: `yellow`
- Recommended action: `merge`
- Rationale: Multiple active ledger items reference the same source file; merge, sequence, or assign ownership before implementation.
- Linear issue ready: `True`
- Auto-resolved: `False`
- Involved:
  - `PFC14_WidgetKit_Implementation_And_Tests_Prompt` — `docs/codex/batches/PFC14_WidgetKit_Implementation_And_Tests_Prompt.md` (partial_implementation; release proof)
  - `PFC13_WidgetKit_Strategy_And_Object_Map_Prompt` — `docs/codex/batches/PFC13_WidgetKit_Strategy_And_Object_Map_Prompt.md` (unknown; release proof)

### 109. Same source file targeted by multiple active items: Native/AmbitionsTests/Domain/AmbitionsOSEvaluationModelsTests.swift

- Conflict ID: `AMB28-same_source_file_targeted_by_multiple_active_batches-3393346`
- Type: `same_source_file_targeted_by_multiple_active_batches`
- Severity: `yellow`
- Recommended action: `merge`
- Rationale: Multiple active ledger items reference the same source file; merge, sequence, or assign ownership before implementation.
- Linear issue ready: `True`
- Auto-resolved: `False`
- Involved:
  - `AMBITIONSOS_AOS_PRIVACY_PROJECTION_LEDGER` — `docs/codex/AMBITIONSOS_AOS_PRIVACY_PROJECTION_LEDGER.md` (unknown; release proof)
  - `AMBITIONSOS_AOS_SOURCE_TRUTH_CLAIM_LEDGER` — `docs/codex/AMBITIONSOS_AOS_SOURCE_TRUTH_CLAIM_LEDGER.md` (unknown; release proof)

### 110. Same source file targeted by multiple active items: Native/AmbitionsTests/Domain/AmbitionsOSLivingDreamTodayBridgeModelsTests.swift

- Conflict ID: `AMB28-same_source_file_targeted_by_multiple_active_batches-51393108`
- Type: `same_source_file_targeted_by_multiple_active_batches`
- Severity: `yellow`
- Recommended action: `merge`
- Rationale: Multiple active ledger items reference the same source file; merge, sequence, or assign ownership before implementation.
- Linear issue ready: `True`
- Auto-resolved: `False`
- Involved:
  - `MOONSHOT_PROOF_PATH_BACKEND_MASTER_PLAN` — `docs/codex/MOONSHOT_PROOF_PATH_BACKEND_MASTER_PLAN.md` (partial_implementation; release proof)
  - `MOAT-MOONSHOT-BACKEND-FULL-TRAIN-01` — `prompts/batches/MOAT-MOONSHOT-BACKEND-FULL-TRAIN-01.md` (partial_implementation; release proof)
  - `MOAT-MOONSHOT-PROOF-PATH-01` — `prompts/batches/MOAT-MOONSHOT-PROOF-PATH-01.md` (partial_implementation; release proof)
  - `MOAT-UNIVERSAL-GOAL-REALITY-COMPILER-01` — `prompts/batches/MOAT-UNIVERSAL-GOAL-REALITY-COMPILER-01.md` (partial_implementation; release proof)

### 111. Same source file targeted by multiple active items: Native/AmbitionsTests/Domain/AmbitionsOSPrivacySafetyModelsTests.swift

- Conflict ID: `AMB28-same_source_file_targeted_by_multiple_active_batches-32645047`
- Type: `same_source_file_targeted_by_multiple_active_batches`
- Severity: `yellow`
- Recommended action: `merge`
- Rationale: Multiple active ledger items reference the same source file; merge, sequence, or assign ownership before implementation.
- Linear issue ready: `True`
- Auto-resolved: `False`
- Involved:
  - `AMBITIONSOS_AOS_PRIVACY_PROJECTION_LEDGER` — `docs/codex/AMBITIONSOS_AOS_PRIVACY_PROJECTION_LEDGER.md` (unknown; release proof)
  - `AMBITIONSOS_AOS_SOURCE_TRUTH_CLAIM_LEDGER` — `docs/codex/AMBITIONSOS_AOS_SOURCE_TRUTH_CLAIM_LEDGER.md` (unknown; release proof)

### 112. Same source file targeted by multiple active items: Native/AmbitionsTests/Domain/InspectableIntelligenceGoldenScenarioTests.swift

- Conflict ID: `AMB28-same_source_file_targeted_by_multiple_active_batches-8972409`
- Type: `same_source_file_targeted_by_multiple_active_batches`
- Severity: `yellow`
- Recommended action: `merge`
- Rationale: Multiple active ledger items reference the same source file; merge, sequence, or assign ownership before implementation.
- Linear issue ready: `True`
- Auto-resolved: `False`
- Involved:
  - `MOAT-MOONSHOT-BACKEND-FULL-TRAIN-01` — `prompts/batches/MOAT-MOONSHOT-BACKEND-FULL-TRAIN-01.md` (partial_implementation; release proof)
  - `MOAT-MOONSHOT-PROOF-PATH-01` — `prompts/batches/MOAT-MOONSHOT-PROOF-PATH-01.md` (partial_implementation; release proof)
  - `MOAT-UNIVERSAL-GOAL-REALITY-COMPILER-01` — `prompts/batches/MOAT-UNIVERSAL-GOAL-REALITY-COMPILER-01.md` (partial_implementation; release proof)
  - `MOAT-GOAL-REALITY-SOURCE-PACKS-09` — `prompts/batches/MOAT-GOAL-REALITY-SOURCE-PACKS-09.md` (partial_implementation; release proof)
  - `PRIVATE-LIFE-RUNTIME-GOLDEN-SCENARIO-PROOF-01` — `prompts/batches/PRIVATE-LIFE-RUNTIME-GOLDEN-SCENARIO-PROOF-01.md` (partial_implementation; release proof)

### 113. Same source file targeted by multiple active items: Native/AmbitionsTests/Domain/SafeAutomationPolicyModelsTests.swift

- Conflict ID: `AMB28-same_source_file_targeted_by_multiple_active_batches-44367225`
- Type: `same_source_file_targeted_by_multiple_active_batches`
- Severity: `yellow`
- Recommended action: `merge`
- Rationale: Multiple active ledger items reference the same source file; merge, sequence, or assign ownership before implementation.
- Linear issue ready: `True`
- Auto-resolved: `False`
- Involved:
  - `PK22` — `prompts/batches/PK22.md` (partial_implementation; release proof)
  - `BACKEND-FINAL-FORM-LOCAL-FIRST-HUMAN-01` — `prompts/batches/BACKEND-FINAL-FORM-LOCAL-FIRST-HUMAN-01.md` (partial_implementation; release proof)

### 114. Same source file targeted by multiple active items: Native/AmbitionsTests/Persistence/EventLedgerRepositoryTests.swift

- Conflict ID: `AMB28-same_source_file_targeted_by_multiple_active_batches-6159715`
- Type: `same_source_file_targeted_by_multiple_active_batches`
- Severity: `yellow`
- Recommended action: `merge`
- Rationale: Multiple active ledger items reference the same source file; merge, sequence, or assign ownership before implementation.
- Linear issue ready: `True`
- Auto-resolved: `False`
- Involved:
  - `PK22` — `prompts/batches/PK22.md` (partial_implementation; release proof)
  - `BACKEND-FINAL-FORM-LOCAL-FIRST-HUMAN-01` — `prompts/batches/BACKEND-FINAL-FORM-LOCAL-FIRST-HUMAN-01.md` (partial_implementation; release proof)

### 115. Same source file targeted by multiple active items: Native/AmbitionsTests/Persistence/PersistenceRepositoryTests.swift

- Conflict ID: `AMB28-same_source_file_targeted_by_multiple_active_batches-96150987`
- Type: `same_source_file_targeted_by_multiple_active_batches`
- Severity: `yellow`
- Recommended action: `merge`
- Rationale: Multiple active ledger items reference the same source file; merge, sequence, or assign ownership before implementation.
- Linear issue ready: `True`
- Auto-resolved: `False`
- Involved:
  - `PFC07_Migration_Ladder_And_Backward_Compatibility_Tests_Prompt` — `docs/codex/batches/PFC07_Migration_Ladder_And_Backward_Compatibility_Tests_Prompt.md` (partial_implementation; release proof)
  - `BACKEND-FINAL-FORM-LOCAL-FIRST-HUMAN-01` — `prompts/batches/BACKEND-FINAL-FORM-LOCAL-FIRST-HUMAN-01.md` (partial_implementation; release proof)
  - `PFC08_Corruption_Recovery_Backup_Restore_Plan_Prompt` — `docs/codex/batches/PFC08_Corruption_Recovery_Backup_Restore_Plan_Prompt.md` (unknown; release proof)

### 116. Same source file targeted by multiple active items: Native/AmbitionsTests/Persistence/PortableRestoreRollbackTests.swift

- Conflict ID: `AMB28-same_source_file_targeted_by_multiple_active_batches-51952368`
- Type: `same_source_file_targeted_by_multiple_active_batches`
- Severity: `yellow`
- Recommended action: `merge`
- Rationale: Multiple active ledger items reference the same source file; merge, sequence, or assign ownership before implementation.
- Linear issue ready: `True`
- Auto-resolved: `False`
- Involved:
  - `BACKEND-FINAL-FORM-LOCAL-FIRST-HUMAN-01` — `prompts/batches/BACKEND-FINAL-FORM-LOCAL-FIRST-HUMAN-01.md` (partial_implementation; release proof)
  - `MOAT-GOAL-REALITY-LOCAL-PERSISTENCE-08` — `prompts/batches/MOAT-GOAL-REALITY-LOCAL-PERSISTENCE-08.md` (partial_implementation; release proof)

### 117. Same source file targeted by multiple active items: Native/AmbitionsTests/Persistence/PortableSnapshotServiceTests.swift

- Conflict ID: `AMB28-same_source_file_targeted_by_multiple_active_batches-60604488`
- Type: `same_source_file_targeted_by_multiple_active_batches`
- Severity: `yellow`
- Recommended action: `merge`
- Rationale: Multiple active ledger items reference the same source file; merge, sequence, or assign ownership before implementation.
- Linear issue ready: `True`
- Auto-resolved: `False`
- Involved:
  - `PFC07_Migration_Ladder_And_Backward_Compatibility_Tests_Prompt` — `docs/codex/batches/PFC07_Migration_Ladder_And_Backward_Compatibility_Tests_Prompt.md` (partial_implementation; release proof)
  - `BACKEND-FINAL-FORM-LOCAL-FIRST-HUMAN-01` — `prompts/batches/BACKEND-FINAL-FORM-LOCAL-FIRST-HUMAN-01.md` (partial_implementation; release proof)
  - `PFC08_Corruption_Recovery_Backup_Restore_Plan_Prompt` — `docs/codex/batches/PFC08_Corruption_Recovery_Backup_Restore_Plan_Prompt.md` (unknown; release proof)

### 118. Same source file targeted by multiple active items: Native/AmbitionsTests/Persistence/PreMigrationBackupTests.swift

- Conflict ID: `AMB28-same_source_file_targeted_by_multiple_active_batches-15869919`
- Type: `same_source_file_targeted_by_multiple_active_batches`
- Severity: `yellow`
- Recommended action: `merge`
- Rationale: Multiple active ledger items reference the same source file; merge, sequence, or assign ownership before implementation.
- Linear issue ready: `True`
- Auto-resolved: `False`
- Involved:
  - `BACKEND-FINAL-FORM-LOCAL-FIRST-HUMAN-01` — `prompts/batches/BACKEND-FINAL-FORM-LOCAL-FIRST-HUMAN-01.md` (partial_implementation; release proof)
  - `MOAT-GOAL-REALITY-LOCAL-PERSISTENCE-08` — `prompts/batches/MOAT-GOAL-REALITY-LOCAL-PERSISTENCE-08.md` (partial_implementation; release proof)

### 119. Same source file targeted by multiple active items: Native/AmbitionsTests/Persistence/SyncCapabilityTests.swift

- Conflict ID: `AMB28-same_source_file_targeted_by_multiple_active_batches-9669053`
- Type: `same_source_file_targeted_by_multiple_active_batches`
- Severity: `yellow`
- Recommended action: `merge`
- Rationale: Multiple active ledger items reference the same source file; merge, sequence, or assign ownership before implementation.
- Linear issue ready: `True`
- Auto-resolved: `False`
- Involved:
  - `PFC07_Migration_Ladder_And_Backward_Compatibility_Tests_Prompt` — `docs/codex/batches/PFC07_Migration_Ladder_And_Backward_Compatibility_Tests_Prompt.md` (partial_implementation; release proof)
  - `BACKEND-FINAL-FORM-LOCAL-FIRST-HUMAN-01` — `prompts/batches/BACKEND-FINAL-FORM-LOCAL-FIRST-HUMAN-01.md` (partial_implementation; release proof)

### 120. Same source file targeted by multiple active items: Native/AmbitionsTests/Runtime/AmbitionsRuntimeBoundaryTests.swift

- Conflict ID: `AMB28-same_source_file_targeted_by_multiple_active_batches-74525103`
- Type: `same_source_file_targeted_by_multiple_active_batches`
- Severity: `yellow`
- Recommended action: `merge`
- Rationale: Multiple active ledger items reference the same source file; merge, sequence, or assign ownership before implementation.
- Linear issue ready: `True`
- Auto-resolved: `False`
- Involved:
  - `BATCH-33-intelligence-runtime-integration` — `docs/codex/batches/BATCH-33-intelligence-runtime-integration.md` (partial_implementation; release proof)
  - `MOAT-GOAL-REALITY-RUNTIME-SERVICE-03` — `prompts/batches/MOAT-GOAL-REALITY-RUNTIME-SERVICE-03.md` (partial_implementation; release proof)

### 121. Same source file targeted by multiple active items: Native/AmbitionsTests/Runtime/AmbitionsRuntimeGoalIntelligenceServiceTests.swift

- Conflict ID: `AMB28-same_source_file_targeted_by_multiple_active_batches-85427198`
- Type: `same_source_file_targeted_by_multiple_active_batches`
- Severity: `yellow`
- Recommended action: `merge`
- Rationale: Multiple active ledger items reference the same source file; merge, sequence, or assign ownership before implementation.
- Linear issue ready: `True`
- Auto-resolved: `False`
- Involved:
  - `BATCH-33-intelligence-runtime-integration` — `docs/codex/batches/BATCH-33-intelligence-runtime-integration.md` (partial_implementation; release proof)
  - `MOONSHOT_PROOF_PATH_BACKEND_MASTER_PLAN` — `docs/codex/MOONSHOT_PROOF_PATH_BACKEND_MASTER_PLAN.md` (partial_implementation; release proof)
  - `MOAT-MOONSHOT-BACKEND-FULL-TRAIN-01` — `prompts/batches/MOAT-MOONSHOT-BACKEND-FULL-TRAIN-01.md` (partial_implementation; release proof)
  - `MOAT-MOONSHOT-PROOF-PATH-01` — `prompts/batches/MOAT-MOONSHOT-PROOF-PATH-01.md` (partial_implementation; release proof)
  - `MOAT-UNIVERSAL-GOAL-REALITY-COMPILER-01` — `prompts/batches/MOAT-UNIVERSAL-GOAL-REALITY-COMPILER-01.md` (partial_implementation; release proof)

### 122. Same source file targeted by multiple active items: Native/AmbitionsTests/Runtime/GoalRealityCompilerCoreTests.swift

- Conflict ID: `AMB28-same_source_file_targeted_by_multiple_active_batches-49667952`
- Type: `same_source_file_targeted_by_multiple_active_batches`
- Severity: `yellow`
- Recommended action: `merge`
- Rationale: Multiple active ledger items reference the same source file; merge, sequence, or assign ownership before implementation.
- Linear issue ready: `True`
- Auto-resolved: `False`
- Involved:
  - `GOAL_REALITY_COMPILER_BACKEND_MASTER_PLAN` — `docs/codex/GOAL_REALITY_COMPILER_BACKEND_MASTER_PLAN.md` (partial_implementation; release proof)
  - `MOAT-GOAL-REALITY-FIXTURE-LAB-02` — `prompts/batches/MOAT-GOAL-REALITY-FIXTURE-LAB-02.md` (partial_implementation; release proof)
  - `MOAT-UNIVERSAL-GOAL-REALITY-COMPILER-01` — `prompts/batches/MOAT-UNIVERSAL-GOAL-REALITY-COMPILER-01.md` (partial_implementation; release proof)

### 123. Same source file targeted by multiple active items: Native/AmbitionsTests/Runtime/GoalRealityGoldenFixtureTests.swift

- Conflict ID: `AMB28-same_source_file_targeted_by_multiple_active_batches-8465283`
- Type: `same_source_file_targeted_by_multiple_active_batches`
- Severity: `yellow`
- Recommended action: `merge`
- Rationale: Multiple active ledger items reference the same source file; merge, sequence, or assign ownership before implementation.
- Linear issue ready: `True`
- Auto-resolved: `False`
- Involved:
  - `GOAL_REALITY_COMPILER_BACKEND_MASTER_PLAN` — `docs/codex/GOAL_REALITY_COMPILER_BACKEND_MASTER_PLAN.md` (partial_implementation; release proof)
  - `MOAT-GOAL-REALITY-FIXTURE-LAB-02` — `prompts/batches/MOAT-GOAL-REALITY-FIXTURE-LAB-02.md` (partial_implementation; release proof)
  - `MOAT-UNIVERSAL-GOAL-REALITY-COMPILER-01` — `prompts/batches/MOAT-UNIVERSAL-GOAL-REALITY-COMPILER-01.md` (partial_implementation; release proof)
  - `MOAT-GOAL-REALITY-EVAL-HARNESS-10` — `prompts/batches/MOAT-GOAL-REALITY-EVAL-HARNESS-10.md` (partial_implementation; release proof)
  - `MOAT-GOAL-REALITY-TODAY-BRIDGE-06` — `prompts/batches/MOAT-GOAL-REALITY-TODAY-BRIDGE-06.md` (partial_implementation; release proof)

### 124. Same source file targeted by multiple active items: Native/AmbitionsTests/Runtime/GoalRealityNegativeFixtureTests.swift

- Conflict ID: `AMB28-same_source_file_targeted_by_multiple_active_batches-35676521`
- Type: `same_source_file_targeted_by_multiple_active_batches`
- Severity: `yellow`
- Recommended action: `merge`
- Rationale: Multiple active ledger items reference the same source file; merge, sequence, or assign ownership before implementation.
- Linear issue ready: `True`
- Auto-resolved: `False`
- Involved:
  - `GOAL_REALITY_COMPILER_BACKEND_MASTER_PLAN` — `docs/codex/GOAL_REALITY_COMPILER_BACKEND_MASTER_PLAN.md` (partial_implementation; release proof)
  - `MOAT-GOAL-REALITY-FIXTURE-LAB-02` — `prompts/batches/MOAT-GOAL-REALITY-FIXTURE-LAB-02.md` (partial_implementation; release proof)
  - `MOAT-UNIVERSAL-GOAL-REALITY-COMPILER-01` — `prompts/batches/MOAT-UNIVERSAL-GOAL-REALITY-COMPILER-01.md` (partial_implementation; release proof)
  - `MOAT-GOAL-REALITY-EVAL-HARNESS-10` — `prompts/batches/MOAT-GOAL-REALITY-EVAL-HARNESS-10.md` (partial_implementation; release proof)
  - `MOAT-GOAL-REALITY-SOURCE-PACKS-09` — `prompts/batches/MOAT-GOAL-REALITY-SOURCE-PACKS-09.md` (partial_implementation; release proof)

### 125. Same source file targeted by multiple active items: Native/AmbitionsTests/Runtime/GoalRealityReceiptTests.swift

- Conflict ID: `AMB28-same_source_file_targeted_by_multiple_active_batches-64175558`
- Type: `same_source_file_targeted_by_multiple_active_batches`
- Severity: `yellow`
- Recommended action: `merge`
- Rationale: Multiple active ledger items reference the same source file; merge, sequence, or assign ownership before implementation.
- Linear issue ready: `True`
- Auto-resolved: `False`
- Involved:
  - `GOAL_REALITY_COMPILER_BACKEND_MASTER_PLAN` — `docs/codex/GOAL_REALITY_COMPILER_BACKEND_MASTER_PLAN.md` (partial_implementation; release proof)
  - `MOAT-GOAL-REALITY-FIXTURE-LAB-02` — `prompts/batches/MOAT-GOAL-REALITY-FIXTURE-LAB-02.md` (partial_implementation; release proof)
  - `MOAT-UNIVERSAL-GOAL-REALITY-COMPILER-01` — `prompts/batches/MOAT-UNIVERSAL-GOAL-REALITY-COMPILER-01.md` (partial_implementation; release proof)
  - `MOAT-GOAL-REALITY-RECEIPT-CLOSURE-07` — `prompts/batches/MOAT-GOAL-REALITY-RECEIPT-CLOSURE-07.md` (partial_implementation; release proof)

### 126. Same source file targeted by multiple active items: Native/AmbitionsTests/Runtime/GoalRealityRuntimeBoundaryTests.swift

- Conflict ID: `AMB28-same_source_file_targeted_by_multiple_active_batches-93229723`
- Type: `same_source_file_targeted_by_multiple_active_batches`
- Severity: `yellow`
- Recommended action: `merge`
- Rationale: Multiple active ledger items reference the same source file; merge, sequence, or assign ownership before implementation.
- Linear issue ready: `True`
- Auto-resolved: `False`
- Involved:
  - `GOAL_REALITY_COMPILER_BACKEND_MASTER_PLAN` — `docs/codex/GOAL_REALITY_COMPILER_BACKEND_MASTER_PLAN.md` (partial_implementation; release proof)
  - `MOAT-GOAL-REALITY-FIXTURE-LAB-02` — `prompts/batches/MOAT-GOAL-REALITY-FIXTURE-LAB-02.md` (partial_implementation; release proof)
  - `MOAT-UNIVERSAL-GOAL-REALITY-COMPILER-01` — `prompts/batches/MOAT-UNIVERSAL-GOAL-REALITY-COMPILER-01.md` (partial_implementation; release proof)
  - `MOAT-GOAL-REALITY-RUNTIME-SERVICE-03` — `prompts/batches/MOAT-GOAL-REALITY-RUNTIME-SERVICE-03.md` (partial_implementation; release proof)

### 127. Same source file targeted by multiple active items: Native/AmbitionsTests/Runtime/MoonshotProofPathRuntimeTests.swift

- Conflict ID: `AMB28-same_source_file_targeted_by_multiple_active_batches-64100878`
- Type: `same_source_file_targeted_by_multiple_active_batches`
- Severity: `yellow`
- Recommended action: `merge`
- Rationale: Multiple active ledger items reference the same source file; merge, sequence, or assign ownership before implementation.
- Linear issue ready: `True`
- Auto-resolved: `False`
- Involved:
  - `MOONSHOT_PROOF_PATH_BACKEND_MASTER_PLAN` — `docs/codex/MOONSHOT_PROOF_PATH_BACKEND_MASTER_PLAN.md` (partial_implementation; release proof)
  - `MOAT-MOONSHOT-BACKEND-FULL-TRAIN-01` — `prompts/batches/MOAT-MOONSHOT-BACKEND-FULL-TRAIN-01.md` (partial_implementation; release proof)
  - `MOAT-MOONSHOT-PROOF-PATH-01` — `prompts/batches/MOAT-MOONSHOT-PROOF-PATH-01.md` (partial_implementation; release proof)
  - `MOAT-UNIVERSAL-GOAL-REALITY-COMPILER-01` — `prompts/batches/MOAT-UNIVERSAL-GOAL-REALITY-COMPILER-01.md` (partial_implementation; release proof)

### 128. Same source file targeted by multiple active items: Native/AmbitionsTests/Services/AmbitionsCommandExecutorTests.swift

- Conflict ID: `AMB28-same_source_file_targeted_by_multiple_active_batches-39868490`
- Type: `same_source_file_targeted_by_multiple_active_batches`
- Severity: `yellow`
- Recommended action: `merge`
- Rationale: Multiple active ledger items reference the same source file; merge, sequence, or assign ownership before implementation.
- Linear issue ready: `True`
- Auto-resolved: `False`
- Involved:
  - `PK22` — `prompts/batches/PK22.md` (partial_implementation; release proof)
  - `BACKEND-FINAL-FORM-LOCAL-FIRST-HUMAN-01` — `prompts/batches/BACKEND-FINAL-FORM-LOCAL-FIRST-HUMAN-01.md` (partial_implementation; release proof)

### 129. Same source file targeted by multiple active items: Native/AmbitionsTests/Today/TodayViewModelTests.swift

- Conflict ID: `AMB28-same_source_file_targeted_by_multiple_active_batches-16813789`
- Type: `same_source_file_targeted_by_multiple_active_batches`
- Severity: `yellow`
- Recommended action: `merge`
- Rationale: Multiple active ledger items reference the same source file; merge, sequence, or assign ownership before implementation.
- Linear issue ready: `True`
- Auto-resolved: `False`
- Involved:
  - `F03_5_Today_Execution_State_Contract_Hardening_Prompt` — `docs/codex/batches/F03_5_Today_Execution_State_Contract_Hardening_Prompt.md` (partial_implementation; release proof)
  - `MOONSHOT_PROOF_PATH_BACKEND_MASTER_PLAN` — `docs/codex/MOONSHOT_PROOF_PATH_BACKEND_MASTER_PLAN.md` (partial_implementation; release proof)
  - `MOAT-MOONSHOT-BACKEND-FULL-TRAIN-01` — `prompts/batches/MOAT-MOONSHOT-BACKEND-FULL-TRAIN-01.md` (partial_implementation; release proof)
  - `MOAT-MOONSHOT-PROOF-PATH-01` — `prompts/batches/MOAT-MOONSHOT-PROOF-PATH-01.md` (partial_implementation; release proof)
  - `MOAT-GOAL-REALITY-TODAY-BRIDGE-06` — `prompts/batches/MOAT-GOAL-REALITY-TODAY-BRIDGE-06.md` (partial_implementation; release proof)
  - `FCP05_Start_Here_Surface_Prompt` — `docs/codex/batches/FCP05_Start_Here_Surface_Prompt.md` (unknown; release proof)
  - `FCP07_Reality_Rail_Continuity_Prompt` — `docs/codex/batches/FCP07_Reality_Rail_Continuity_Prompt.md` (unknown; release proof)
  - `FCP13A_Action_Closure_Diamond_Prompt` — `docs/codex/batches/FCP13A_Action_Closure_Diamond_Prompt.md` (unknown; release proof)

### 130. Same source file targeted by multiple active items: Native/AmbitionsUITests/AmbitionsUITests.swift

- Conflict ID: `AMB28-same_source_file_targeted_by_multiple_active_batches-71699222`
- Type: `same_source_file_targeted_by_multiple_active_batches`
- Severity: `yellow`
- Recommended action: `merge`
- Rationale: Multiple active ledger items reference the same source file; merge, sequence, or assign ownership before implementation.
- Linear issue ready: `True`
- Auto-resolved: `False`
- Involved:
  - `AMB-REPO-AUTHORITY-00-SAFETY-SNAPSHOT` — `prompts/batches/AMB-REPO-AUTHORITY-00-SAFETY-SNAPSHOT.md` (partial_implementation; release proof)
  - `AMB-REPO-AUTHORITY-02-FRONTEND-VISUAL-ENCYCLOPEDIA` — `prompts/batches/AMB-REPO-AUTHORITY-02-FRONTEND-VISUAL-ENCYCLOPEDIA.md` (partial_implementation; release proof)
  - `AMB-REPO-AUTHORITY-06-ACTIVE-DRIFT-REPAIR` — `prompts/batches/AMB-REPO-AUTHORITY-06-ACTIVE-DRIFT-REPAIR.md` (partial_implementation; release proof)
  - `AMB-POST23-01-TRUTH-AUDIT` — `docs/codex/reports/AMB-POST23-01-TRUTH-AUDIT.md` (partial_implementation; release proof)

### 131. Same source file targeted by multiple active items: Native/AmbitionsWidgetExtension/NextStepWidget.swift

- Conflict ID: `AMB28-same_source_file_targeted_by_multiple_active_batches-10241686`
- Type: `same_source_file_targeted_by_multiple_active_batches`
- Severity: `yellow`
- Recommended action: `merge`
- Rationale: Multiple active ledger items reference the same source file; merge, sequence, or assign ownership before implementation.
- Linear issue ready: `True`
- Auto-resolved: `False`
- Involved:
  - `PFC14_WidgetKit_Implementation_And_Tests_Prompt` — `docs/codex/batches/PFC14_WidgetKit_Implementation_And_Tests_Prompt.md` (partial_implementation; release proof)
  - `AMB-REPO-AUTHORITY-00-SAFETY-SNAPSHOT` — `prompts/batches/AMB-REPO-AUTHORITY-00-SAFETY-SNAPSHOT.md` (partial_implementation; release proof)
  - `AMB-REPO-AUTHORITY-06-ACTIVE-DRIFT-REPAIR` — `prompts/batches/AMB-REPO-AUTHORITY-06-ACTIVE-DRIFT-REPAIR.md` (partial_implementation; release proof)
  - `PFC13_WidgetKit_Strategy_And_Object_Map_Prompt` — `docs/codex/batches/PFC13_WidgetKit_Strategy_And_Object_Map_Prompt.md` (unknown; release proof)

### 132. Same source file targeted by multiple active items: scripts/ai/acx.py

- Conflict ID: `AMB28-same_source_file_targeted_by_multiple_active_batches-33299522`
- Type: `same_source_file_targeted_by_multiple_active_batches`
- Severity: `yellow`
- Recommended action: `merge`
- Rationale: Multiple active ledger items reference the same source file; merge, sequence, or assign ownership before implementation.
- Linear issue ready: `True`
- Auto-resolved: `False`
- Involved:
  - `CODEX_OS_PEAK_OPERATING_PROTOCOL` — `docs/codex/CODEX_OS_PEAK_OPERATING_PROTOCOL.md` (partial_implementation; release proof)
  - `CODEX_ACX_LOCAL_EXECUTOR` — `docs/codex/CODEX_ACX_LOCAL_EXECUTOR.md` (partial_implementation; release proof)
  - `CODEX_AGENT_PROTOCOL` — `docs/codex/CODEX_AGENT_PROTOCOL.md` (partial_implementation; release proof)
  - `CODEX_OS_UPGRADE_AUDIT_2026_05_07` — `docs/codex/CODEX_OS_UPGRADE_AUDIT_2026_05_07.md` (partial_implementation; release proof)
  - `CODEX_OS_REPAIR_SPEED_PROOF_UPGRADE_AUDIT_2026_05_08` — `docs/codex/CODEX_OS_REPAIR_SPEED_PROOF_UPGRADE_AUDIT_2026_05_08.md` (partial_implementation; release proof)
  - `CODEX_QUALITY_SYSTEM_SCRIPT_MAP` — `docs/codex/CODEX_QUALITY_SYSTEM_SCRIPT_MAP.md` (unknown; release proof)

### 133. Same source file targeted by multiple active items: scripts/ai/acx_accessibility_packet.py

- Conflict ID: `AMB28-same_source_file_targeted_by_multiple_active_batches-99953785`
- Type: `same_source_file_targeted_by_multiple_active_batches`
- Severity: `yellow`
- Recommended action: `merge`
- Rationale: Multiple active ledger items reference the same source file; merge, sequence, or assign ownership before implementation.
- Linear issue ready: `True`
- Auto-resolved: `False`
- Involved:
  - `CODEX_OS_ENGINE_SUPPLEMENT_2026_05_08` — `docs/codex/CODEX_OS_ENGINE_SUPPLEMENT_2026_05_08.md` (partial_implementation; release proof)
  - `CODEX_OS_REPAIR_SPEED_PROOF_UPGRADE_AUDIT_2026_05_08` — `docs/codex/CODEX_OS_REPAIR_SPEED_PROOF_UPGRADE_AUDIT_2026_05_08.md` (partial_implementation; release proof)
  - `AFI09_Time_LifeShape_Field` — `docs/codex/batches/AFI09_Time_LifeShape_Field.md` (partial_implementation; release proof)
  - `AFI10_You_User_System_Profile` — `docs/codex/batches/AFI10_You_User_System_Profile.md` (partial_implementation; release proof)
  - `CODEX_QUALITY_SYSTEM_SCRIPT_MAP` — `docs/codex/CODEX_QUALITY_SYSTEM_SCRIPT_MAP.md` (unknown; release proof)
  - `CODEX_ACCESSIBILITY_PROOF_PROTOCOL` — `docs/codex/CODEX_ACCESSIBILITY_PROOF_PROTOCOL.md` (unknown; release proof)

### 134. Same source file targeted by multiple active items: scripts/ai/acx_build_triage.py

- Conflict ID: `AMB28-same_source_file_targeted_by_multiple_active_batches-57907339`
- Type: `same_source_file_targeted_by_multiple_active_batches`
- Severity: `yellow`
- Recommended action: `merge`
- Rationale: Multiple active ledger items reference the same source file; merge, sequence, or assign ownership before implementation.
- Linear issue ready: `True`
- Auto-resolved: `False`
- Involved:
  - `CODEX_OS_ENGINE_SUPPLEMENT_2026_05_08` — `docs/codex/CODEX_OS_ENGINE_SUPPLEMENT_2026_05_08.md` (partial_implementation; release proof)
  - `CODEX_OS_REPAIR_SPEED_PROOF_UPGRADE_AUDIT_2026_05_08` — `docs/codex/CODEX_OS_REPAIR_SPEED_PROOF_UPGRADE_AUDIT_2026_05_08.md` (partial_implementation; release proof)
  - `CODEX_QUALITY_SYSTEM_SCRIPT_MAP` — `docs/codex/CODEX_QUALITY_SYSTEM_SCRIPT_MAP.md` (unknown; release proof)
  - `CODEX_BUILD_SHERIFF_PROTOCOL` — `docs/codex/CODEX_BUILD_SHERIFF_PROTOCOL.md` (unknown; release proof)

### 135. Same source file targeted by multiple active items: scripts/ai/acx_closeout.py

- Conflict ID: `AMB28-same_source_file_targeted_by_multiple_active_batches-56719925`
- Type: `same_source_file_targeted_by_multiple_active_batches`
- Severity: `yellow`
- Recommended action: `merge`
- Rationale: Multiple active ledger items reference the same source file; merge, sequence, or assign ownership before implementation.
- Linear issue ready: `True`
- Auto-resolved: `False`
- Involved:
  - `CODEX_OS_ENGINE_SUPPLEMENT_2026_05_08` — `docs/codex/CODEX_OS_ENGINE_SUPPLEMENT_2026_05_08.md` (partial_implementation; release proof)
  - `CODEX_OS_REPAIR_SPEED_PROOF_UPGRADE_AUDIT_2026_05_08` — `docs/codex/CODEX_OS_REPAIR_SPEED_PROOF_UPGRADE_AUDIT_2026_05_08.md` (partial_implementation; release proof)
  - `CODEX_QUALITY_SYSTEM_SCRIPT_MAP` — `docs/codex/CODEX_QUALITY_SYSTEM_SCRIPT_MAP.md` (unknown; release proof)
  - `CODEX_SPEED_ENGINE` — `docs/codex/CODEX_SPEED_ENGINE.md` (unknown; release proof)

### 136. Same source file targeted by multiple active items: scripts/ai/acx_impact.py

- Conflict ID: `AMB28-same_source_file_targeted_by_multiple_active_batches-38641919`
- Type: `same_source_file_targeted_by_multiple_active_batches`
- Severity: `yellow`
- Recommended action: `merge`
- Rationale: Multiple active ledger items reference the same source file; merge, sequence, or assign ownership before implementation.
- Linear issue ready: `True`
- Auto-resolved: `False`
- Involved:
  - `CODEX_OS_ENGINE_SUPPLEMENT_2026_05_08` — `docs/codex/CODEX_OS_ENGINE_SUPPLEMENT_2026_05_08.md` (partial_implementation; release proof)
  - `CODEX_OS_REPAIR_SPEED_PROOF_UPGRADE_AUDIT_2026_05_08` — `docs/codex/CODEX_OS_REPAIR_SPEED_PROOF_UPGRADE_AUDIT_2026_05_08.md` (partial_implementation; release proof)
  - `PK00_Current_Backend_Proof_Baseline` — `docs/codex/batches/PK00_Current_Backend_Proof_Baseline.md` (partial_implementation; release proof)
  - `PK01_Package_Module_Boundary_Scaffold` — `docs/codex/batches/PK01_Package_Module_Boundary_Scaffold.md` (partial_implementation; release proof)
  - `PK02_Architecture_Boundary_Scanner` — `docs/codex/batches/PK02_Architecture_Boundary_Scanner.md` (partial_implementation; release proof)
  - `CODEX_QUALITY_SYSTEM_SCRIPT_MAP` — `docs/codex/CODEX_QUALITY_SYSTEM_SCRIPT_MAP.md` (unknown; release proof)
  - `CODEX_SPEED_ENGINE` — `docs/codex/CODEX_SPEED_ENGINE.md` (unknown; release proof)

### 137. Same source file targeted by multiple active items: scripts/ai/acx_local.py

- Conflict ID: `AMB28-same_source_file_targeted_by_multiple_active_batches-24388575`
- Type: `same_source_file_targeted_by_multiple_active_batches`
- Severity: `yellow`
- Recommended action: `merge`
- Rationale: Multiple active ledger items reference the same source file; merge, sequence, or assign ownership before implementation.
- Linear issue ready: `True`
- Auto-resolved: `False`
- Involved:
  - `CODEX_OS_PEAK_OPERATING_PROTOCOL` — `docs/codex/CODEX_OS_PEAK_OPERATING_PROTOCOL.md` (partial_implementation; release proof)
  - `CODEX_ACX_LOCAL_EXECUTOR` — `docs/codex/CODEX_ACX_LOCAL_EXECUTOR.md` (partial_implementation; release proof)
  - `CODEX_OS_ENGINE_SUPPLEMENT_2026_05_08` — `docs/codex/CODEX_OS_ENGINE_SUPPLEMENT_2026_05_08.md` (partial_implementation; release proof)
  - `CODEX_OS_REPAIR_SPEED_PROOF_UPGRADE_AUDIT_2026_05_08` — `docs/codex/CODEX_OS_REPAIR_SPEED_PROOF_UPGRADE_AUDIT_2026_05_08.md` (partial_implementation; release proof)
  - `CODEX_PRIVACY_SECURITY_SCAN_PROTOCOL` — `docs/codex/CODEX_PRIVACY_SECURITY_SCAN_PROTOCOL.md` (partial_implementation; release proof)
  - `PK00_Current_Backend_Proof_Baseline` — `docs/codex/batches/PK00_Current_Backend_Proof_Baseline.md` (partial_implementation; release proof)
  - `PK01_Package_Module_Boundary_Scaffold` — `docs/codex/batches/PK01_Package_Module_Boundary_Scaffold.md` (partial_implementation; release proof)
  - `PK02_Architecture_Boundary_Scanner` — `docs/codex/batches/PK02_Architecture_Boundary_Scanner.md` (partial_implementation; release proof)
  - `CODEX_QUALITY_SYSTEM_SCRIPT_MAP` — `docs/codex/CODEX_QUALITY_SYSTEM_SCRIPT_MAP.md` (unknown; release proof)
  - `CODEX_SPEED_ENGINE` — `docs/codex/CODEX_SPEED_ENGINE.md` (unknown; release proof)

### 138. Same source file targeted by multiple active items: scripts/ai/acx_repair.py

- Conflict ID: `AMB28-same_source_file_targeted_by_multiple_active_batches-99091862`
- Type: `same_source_file_targeted_by_multiple_active_batches`
- Severity: `yellow`
- Recommended action: `merge`
- Rationale: Multiple active ledger items reference the same source file; merge, sequence, or assign ownership before implementation.
- Linear issue ready: `True`
- Auto-resolved: `False`
- Involved:
  - `CODEX_OS_ENGINE_SUPPLEMENT_2026_05_08` — `docs/codex/CODEX_OS_ENGINE_SUPPLEMENT_2026_05_08.md` (partial_implementation; release proof)
  - `CODEX_OS_REPAIR_SPEED_PROOF_UPGRADE_AUDIT_2026_05_08` — `docs/codex/CODEX_OS_REPAIR_SPEED_PROOF_UPGRADE_AUDIT_2026_05_08.md` (partial_implementation; release proof)
  - `PK01_Package_Module_Boundary_Scaffold` — `docs/codex/batches/PK01_Package_Module_Boundary_Scaffold.md` (partial_implementation; release proof)
  - `PK02_Architecture_Boundary_Scanner` — `docs/codex/batches/PK02_Architecture_Boundary_Scanner.md` (partial_implementation; release proof)
  - `CODEX_QUALITY_SYSTEM_SCRIPT_MAP` — `docs/codex/CODEX_QUALITY_SYSTEM_SCRIPT_MAP.md` (unknown; release proof)

### 139. Same source file targeted by multiple active items: scripts/ai/acx_sanitized_evidence.py

- Conflict ID: `AMB28-same_source_file_targeted_by_multiple_active_batches-9857002`
- Type: `same_source_file_targeted_by_multiple_active_batches`
- Severity: `yellow`
- Recommended action: `merge`
- Rationale: Multiple active ledger items reference the same source file; merge, sequence, or assign ownership before implementation.
- Linear issue ready: `True`
- Auto-resolved: `False`
- Involved:
  - `CODEX_OS_ENGINE_SUPPLEMENT_2026_05_08` — `docs/codex/CODEX_OS_ENGINE_SUPPLEMENT_2026_05_08.md` (partial_implementation; release proof)
  - `CODEX_OS_REPAIR_SPEED_PROOF_UPGRADE_AUDIT_2026_05_08` — `docs/codex/CODEX_OS_REPAIR_SPEED_PROOF_UPGRADE_AUDIT_2026_05_08.md` (partial_implementation; release proof)
  - `CODEX_QUALITY_SYSTEM_SCRIPT_MAP` — `docs/codex/CODEX_QUALITY_SYSTEM_SCRIPT_MAP.md` (unknown; release proof)
  - `CODEX_PROOF_CACHE_PROTOCOL` — `docs/codex/CODEX_PROOF_CACHE_PROTOCOL.md` (unknown; release proof)
  - `CODEX_SPEED_ENGINE` — `docs/codex/CODEX_SPEED_ENGINE.md` (unknown; release proof)

### 140. Same source file targeted by multiple active items: scripts/ai/acx_visual_packet.py

- Conflict ID: `AMB28-same_source_file_targeted_by_multiple_active_batches-10772187`
- Type: `same_source_file_targeted_by_multiple_active_batches`
- Severity: `yellow`
- Recommended action: `merge`
- Rationale: Multiple active ledger items reference the same source file; merge, sequence, or assign ownership before implementation.
- Linear issue ready: `True`
- Auto-resolved: `False`
- Involved:
  - `CODEX_OS_ENGINE_SUPPLEMENT_2026_05_08` — `docs/codex/CODEX_OS_ENGINE_SUPPLEMENT_2026_05_08.md` (partial_implementation; release proof)
  - `CODEX_OS_REPAIR_SPEED_PROOF_UPGRADE_AUDIT_2026_05_08` — `docs/codex/CODEX_OS_REPAIR_SPEED_PROOF_UPGRADE_AUDIT_2026_05_08.md` (partial_implementation; release proof)
  - `AFI09_Time_LifeShape_Field` — `docs/codex/batches/AFI09_Time_LifeShape_Field.md` (partial_implementation; release proof)
  - `AFI10_You_User_System_Profile` — `docs/codex/batches/AFI10_You_User_System_Profile.md` (partial_implementation; release proof)
  - `CODEX_QUALITY_SYSTEM_SCRIPT_MAP` — `docs/codex/CODEX_QUALITY_SYSTEM_SCRIPT_MAP.md` (unknown; release proof)

### 141. Same source file targeted by multiple active items: scripts/ambitions-advance-batch-state.py

- Conflict ID: `AMB28-same_source_file_targeted_by_multiple_active_batches-35346320`
- Type: `same_source_file_targeted_by_multiple_active_batches`
- Severity: `yellow`
- Recommended action: `merge`
- Rationale: Multiple active ledger items reference the same source file; merge, sequence, or assign ownership before implementation.
- Linear issue ready: `True`
- Auto-resolved: `False`
- Involved:
  - `POST_PK_CLOSEOUT_CONTRACT` — `docs/codex/POST_PK_CLOSEOUT_CONTRACT.md` (partial_implementation; release proof)
  - `POST_PK_SPEED_TRAIN_OPERATING_MODEL` — `docs/codex/POST_PK_SPEED_TRAIN_OPERATING_MODEL.md` (unknown; release proof)

### 142. Same source file targeted by multiple active items: scripts/ambitions-authority-supersession-check.py

- Conflict ID: `AMB28-same_source_file_targeted_by_multiple_active_batches-60741270`
- Type: `same_source_file_targeted_by_multiple_active_batches`
- Severity: `yellow`
- Recommended action: `merge`
- Rationale: Multiple active ledger items reference the same source file; merge, sequence, or assign ownership before implementation.
- Linear issue ready: `True`
- Auto-resolved: `False`
- Involved:
  - `AMB-REPO-AUTHORITY-06-ACTIVE-DRIFT-REPAIR` — `prompts/batches/AMB-REPO-AUTHORITY-06-ACTIVE-DRIFT-REPAIR.md` (partial_implementation; release proof)
  - `AMB-REPO-AUTHORITY-07-GATES-FINAL-PROOF` — `prompts/batches/AMB-REPO-AUTHORITY-07-GATES-FINAL-PROOF.md` (partial_implementation; release proof)

### 143. Same source file targeted by multiple active items: scripts/ambitions-autonomous-train-fastpath.py

- Conflict ID: `AMB28-same_source_file_targeted_by_multiple_active_batches-52333223`
- Type: `same_source_file_targeted_by_multiple_active_batches`
- Severity: `yellow`
- Recommended action: `merge`
- Rationale: Multiple active ledger items reference the same source file; merge, sequence, or assign ownership before implementation.
- Linear issue ready: `True`
- Auto-resolved: `False`
- Involved:
  - `AUTONOMOUS_TRAIN_FASTPATH` — `docs/codex/AUTONOMOUS_TRAIN_FASTPATH.md` (partial_implementation; release proof)
  - `AUTONOMOUS-TRAIN-FASTPATH-01` — `prompts/batches/AUTONOMOUS-TRAIN-FASTPATH-01.md` (partial_implementation; release proof)

### 144. Same source file targeted by multiple active items: scripts/ambitions-bundle-next-batches.py

- Conflict ID: `AMB28-same_source_file_targeted_by_multiple_active_batches-4325858`
- Type: `same_source_file_targeted_by_multiple_active_batches`
- Severity: `yellow`
- Recommended action: `merge`
- Rationale: Multiple active ledger items reference the same source file; merge, sequence, or assign ownership before implementation.
- Linear issue ready: `True`
- Auto-resolved: `False`
- Involved:
  - `POST_PK_BATCH_BUNDLES` — `docs/codex/POST_PK_BATCH_BUNDLES.md` (unknown; release proof)
  - `POST_PK_SPEED_TRAIN_OPERATING_MODEL` — `docs/codex/POST_PK_SPEED_TRAIN_OPERATING_MODEL.md` (unknown; release proof)

### 145. Same source file targeted by multiple active items: scripts/ambitions-closeout-coalesce.py

- Conflict ID: `AMB28-same_source_file_targeted_by_multiple_active_batches-11780571`
- Type: `same_source_file_targeted_by_multiple_active_batches`
- Severity: `yellow`
- Recommended action: `merge`
- Rationale: Multiple active ledger items reference the same source file; merge, sequence, or assign ownership before implementation.
- Linear issue ready: `True`
- Auto-resolved: `False`
- Involved:
  - `POST_PK_CLOSEOUT_CONTRACT` — `docs/codex/POST_PK_CLOSEOUT_CONTRACT.md` (partial_implementation; release proof)
  - `POST_PK_SPEED_TRAIN_OPERATING_MODEL` — `docs/codex/POST_PK_SPEED_TRAIN_OPERATING_MODEL.md` (unknown; release proof)

### 146. Same source file targeted by multiple active items: scripts/ambitions-codex-os-validate.py

- Conflict ID: `AMB28-same_source_file_targeted_by_multiple_active_batches-71599116`
- Type: `same_source_file_targeted_by_multiple_active_batches`
- Severity: `yellow`
- Recommended action: `merge`
- Rationale: Multiple active ledger items reference the same source file; merge, sequence, or assign ownership before implementation.
- Linear issue ready: `True`
- Auto-resolved: `False`
- Involved:
  - `AMB-REPO-AUTHORITY-07-GATES-FINAL-PROOF` — `prompts/batches/AMB-REPO-AUTHORITY-07-GATES-FINAL-PROOF.md` (partial_implementation; release proof)
  - `AMB-CODEX-OS-FLAGSHIP-UPGRADE-INSTALL-01` — `docs/codex/reports/AMB-CODEX-OS-FLAGSHIP-UPGRADE-INSTALL-01.md` (partial_implementation; release proof)
  - `OS-FLAGSHIP-07-SKILL-REGISTRY-AND-RUNNER-INTEGRATION` — `prompts/batches/OS-FLAGSHIP-07-SKILL-REGISTRY-AND-RUNNER-INTEGRATION.md` (partial_implementation; release proof)
  - `AMB-REPO-GREEN-FLAGSHIP-RESET-MASTER-01-T01-AUDIT-CALIBRATION` — `prompts/batches/AMB-REPO-GREEN-FLAGSHIP-RESET-MASTER-01-T01-AUDIT-CALIBRATION.md` (partial_implementation; release proof)
  - `AMB-LINEAR-TEMPLATE-MANIFEST` — `docs/codex/linear-templates/AMB-LINEAR-TEMPLATE-MANIFEST.yml` (partial_implementation; release proof)

### 147. Same source file targeted by multiple active items: scripts/ambitions-codex-train.sh

- Conflict ID: `AMB28-same_source_file_targeted_by_multiple_active_batches-81133443`
- Type: `same_source_file_targeted_by_multiple_active_batches`
- Severity: `yellow`
- Recommended action: `merge`
- Rationale: Multiple active ledger items reference the same source file; merge, sequence, or assign ownership before implementation.
- Linear issue ready: `True`
- Auto-resolved: `False`
- Involved:
  - `PK17` — `prompts/batches/PK17.md` (partial_implementation; release proof)
  - `PK18` — `prompts/batches/PK18.md` (partial_implementation; release proof)
  - `PK19` — `prompts/batches/PK19.md` (partial_implementation; release proof)
  - `PK20` — `prompts/batches/PK20.md` (partial_implementation; release proof)
  - `PK21` — `prompts/batches/PK21.md` (partial_implementation; release proof)
  - `PK22` — `prompts/batches/PK22.md` (partial_implementation; release proof)
  - `PK23` — `prompts/batches/PK23.md` (partial_implementation; release proof)
  - `PK24` — `prompts/batches/PK24.md` (partial_implementation; release proof)
  - `PK25` — `prompts/batches/PK25.md` (partial_implementation; release proof)
  - `PK26` — `prompts/batches/PK26.md` (partial_implementation; release proof)
  - `PK27` — `prompts/batches/PK27.md` (partial_implementation; release proof)
  - `PK28` — `prompts/batches/PK28.md` (partial_implementation; release proof)
  - `PK29` — `prompts/batches/PK29.md` (partial_implementation; release proof)
  - `PK30` — `prompts/batches/PK30.md` (partial_implementation; release proof)
  - `PK31` — `prompts/batches/PK31.md` (partial_implementation; release proof)
  - `PK32` — `prompts/batches/PK32.md` (partial_implementation; release proof)
  - `PK33` — `prompts/batches/PK33.md` (partial_implementation; release proof)
  - `PK34` — `prompts/batches/PK34.md` (partial_implementation; release proof)
  - `PK35` — `prompts/batches/PK35.md` (partial_implementation; release proof)
  - `PK36` — `prompts/batches/PK36.md` (partial_implementation; release proof)
  - `PK37` — `prompts/batches/PK37.md` (partial_implementation; release proof)
  - `PK38` — `prompts/batches/PK38.md` (partial_implementation; release proof)
  - `PK39` — `prompts/batches/PK39.md` (partial_implementation; release proof)
  - `PK40` — `prompts/batches/PK40.md` (partial_implementation; release proof)
  - `PK41` — `prompts/batches/PK41.md` (partial_implementation; release proof)
  - `QUEUE-INTEL-CODEXOS-UPGRADE-01` — `prompts/batches/QUEUE-INTEL-CODEXOS-UPGRADE-01.md` (partial_implementation; release proof)
  - `ACCESSIBILITY-VISUAL-CANON-01` — `prompts/batches/ACCESSIBILITY-VISUAL-CANON-01.md` (partial_implementation; release proof)
  - `AMBITION-GRAPH-FOUNDATION-01` — `prompts/batches/AMBITION-GRAPH-FOUNDATION-01.md` (partial_implementation; release proof)
  - `AOS24` — `prompts/batches/AOS24.md` (partial_implementation; release proof)
  - `AOS25` — `prompts/batches/AOS25.md` (partial_implementation; release proof)
  - ... 265 more

### 148. Same source file targeted by multiple active items: scripts/ambitions-control-plane-check.py

- Conflict ID: `AMB28-same_source_file_targeted_by_multiple_active_batches-43654621`
- Type: `same_source_file_targeted_by_multiple_active_batches`
- Severity: `yellow`
- Recommended action: `merge`
- Rationale: Multiple active ledger items reference the same source file; merge, sequence, or assign ownership before implementation.
- Linear issue ready: `True`
- Auto-resolved: `False`
- Involved:
  - `AMB_CONTROL_PLANE_DIRECT_RUNBOOK` — `docs/codex/AMB_CONTROL_PLANE_DIRECT_RUNBOOK.md` (partial_implementation; release proof)
  - `AMB_CONTROL_PLANE_GATE_INDEX` — `docs/codex/AMB_CONTROL_PLANE_GATE_INDEX.md` (partial_implementation; release proof)
  - `XCODE-BUILD-SYSTEM-MAX-01-REPAIR-01` — `prompts/batches/XCODE-BUILD-SYSTEM-MAX-01-REPAIR-01.md` (partial_implementation; release proof)
  - `HBI-GLOBAL-TRAIN-HANDOFF-01` — `prompts/batches/HBI-GLOBAL-TRAIN-HANDOFF-01.md` (partial_implementation; release proof)

### 149. Same source file targeted by multiple active items: scripts/ambitions-deriveddata-manager.sh

- Conflict ID: `AMB28-same_source_file_targeted_by_multiple_active_batches-11937234`
- Type: `same_source_file_targeted_by_multiple_active_batches`
- Severity: `yellow`
- Recommended action: `merge`
- Rationale: Multiple active ledger items reference the same source file; merge, sequence, or assign ownership before implementation.
- Linear issue ready: `True`
- Auto-resolved: `False`
- Involved:
  - `XCODE-PERF-RUNNER-MATURITY-01` — `prompts/batches/XCODE-PERF-RUNNER-MATURITY-01.md` (partial_implementation; release proof)
  - `XCODE_BUILD_LAB_PROTOCOL` — `docs/codex/XCODE_BUILD_LAB_PROTOCOL.md` (unknown; release proof)
  - `DERIVEDDATA_HYGIENE_PLAYBOOK` — `docs/codex/playbooks/DERIVEDDATA_HYGIENE_PLAYBOOK.md` (unknown; release proof)

### 150. Same source file targeted by multiple active items: scripts/ambitions-final-report-gate.py

- Conflict ID: `AMB28-same_source_file_targeted_by_multiple_active_batches-63740124`
- Type: `same_source_file_targeted_by_multiple_active_batches`
- Severity: `yellow`
- Recommended action: `merge`
- Rationale: Multiple active ledger items reference the same source file; merge, sequence, or assign ownership before implementation.
- Linear issue ready: `True`
- Auto-resolved: `False`
- Involved:
  - `AMB_CONTROL_PLANE_DIRECT_RUNBOOK` — `docs/codex/AMB_CONTROL_PLANE_DIRECT_RUNBOOK.md` (partial_implementation; release proof)
  - `AMB_CONTROL_PLANE_GATE_INDEX` — `docs/codex/AMB_CONTROL_PLANE_GATE_INDEX.md` (partial_implementation; release proof)
  - `XCODE-BUILD-SYSTEM-MAX-01-REPAIR-01` — `prompts/batches/XCODE-BUILD-SYSTEM-MAX-01-REPAIR-01.md` (partial_implementation; release proof)

### 151. Same source file targeted by multiple active items: scripts/ambitions-frontend-architecture-atlas-check.py

- Conflict ID: `AMB28-same_source_file_targeted_by_multiple_active_batches-15645084`
- Type: `same_source_file_targeted_by_multiple_active_batches`
- Severity: `yellow`
- Recommended action: `merge`
- Rationale: Multiple active ledger items reference the same source file; merge, sequence, or assign ownership before implementation.
- Linear issue ready: `True`
- Auto-resolved: `False`
- Involved:
  - `FRONTEND-SURFACE-RECIPE-COMPLETENESS-REVIEW-001` — `prompts/batches/FRONTEND-SURFACE-RECIPE-COMPLETENESS-REVIEW-001.md` (partial_implementation; release proof)
  - `FLAGSHIP-OBJECT-SYSTEM-01` — `prompts/batches/FLAGSHIP-OBJECT-SYSTEM-01.md` (partial_implementation; release proof)

### 152. Same source file targeted by multiple active items: scripts/ambitions-historical-baseline-train-guard.py

- Conflict ID: `AMB28-same_source_file_targeted_by_multiple_active_batches-2102671`
- Type: `same_source_file_targeted_by_multiple_active_batches`
- Severity: `yellow`
- Recommended action: `merge`
- Rationale: Multiple active ledger items reference the same source file; merge, sequence, or assign ownership before implementation.
- Linear issue ready: `True`
- Auto-resolved: `False`
- Involved:
  - `AUTONOMOUS-TRAIN-FASTPATH-01` — `prompts/batches/AUTONOMOUS-TRAIN-FASTPATH-01.md` (partial_implementation; release proof)
  - `HBI-GLOBAL-TRAIN-HANDOFF-01` — `prompts/batches/HBI-GLOBAL-TRAIN-HANDOFF-01.md` (partial_implementation; release proof)
  - `RRE-01` — `prompts/batches/RRE-01.md` (partial_implementation; release proof)

### 153. Same source file targeted by multiple active items: scripts/ambitions-moat-drift-scan.py

- Conflict ID: `AMB28-same_source_file_targeted_by_multiple_active_batches-51568556`
- Type: `same_source_file_targeted_by_multiple_active_batches`
- Severity: `yellow`
- Recommended action: `merge`
- Rationale: Multiple active ledger items reference the same source file; merge, sequence, or assign ownership before implementation.
- Linear issue ready: `True`
- Auto-resolved: `False`
- Involved:
  - `AMB-REPO-AUTHORITY-06-ACTIVE-DRIFT-REPAIR` — `prompts/batches/AMB-REPO-AUTHORITY-06-ACTIVE-DRIFT-REPAIR.md` (partial_implementation; release proof)
  - `AMB-REPO-AUTHORITY-07-GATES-FINAL-PROOF` — `prompts/batches/AMB-REPO-AUTHORITY-07-GATES-FINAL-PROOF.md` (partial_implementation; release proof)

### 154. Same source file targeted by multiple active items: scripts/ambitions-mri-materialize-prompts.py

- Conflict ID: `AMB28-same_source_file_targeted_by_multiple_active_batches-99646942`
- Type: `same_source_file_targeted_by_multiple_active_batches`
- Severity: `yellow`
- Recommended action: `merge`
- Rationale: Multiple active ledger items reference the same source file; merge, sequence, or assign ownership before implementation.
- Linear issue ready: `True`
- Auto-resolved: `False`
- Involved:
  - `MRI00-MOAT-RUNTIME-GAP-LOCK` — `prompts/batches/MRI00-MOAT-RUNTIME-GAP-LOCK.md` (partial_implementation; release proof)
  - `FRONTEND-SURFACE-RECIPE-COMPLETENESS-REVIEW-001` — `prompts/batches/FRONTEND-SURFACE-RECIPE-COMPLETENESS-REVIEW-001.md` (partial_implementation; release proof)

### 155. Same source file targeted by multiple active items: scripts/ambitions-next-batch-router.py

- Conflict ID: `AMB28-same_source_file_targeted_by_multiple_active_batches-6620639`
- Type: `same_source_file_targeted_by_multiple_active_batches`
- Severity: `yellow`
- Recommended action: `merge`
- Rationale: Multiple active ledger items reference the same source file; merge, sequence, or assign ownership before implementation.
- Linear issue ready: `True`
- Auto-resolved: `False`
- Involved:
  - `AUTONOMOUS_TRAIN_FASTPATH` — `docs/codex/AUTONOMOUS_TRAIN_FASTPATH.md` (partial_implementation; release proof)
  - `AUTONOMOUS-TRAIN-FASTPATH-01` — `prompts/batches/AUTONOMOUS-TRAIN-FASTPATH-01.md` (partial_implementation; release proof)

### 156. Same source file targeted by multiple active items: scripts/ambitions-parallel-implementation-guard.py

- Conflict ID: `AMB28-same_source_file_targeted_by_multiple_active_batches-60596293`
- Type: `same_source_file_targeted_by_multiple_active_batches`
- Severity: `yellow`
- Recommended action: `merge`
- Rationale: Multiple active ledger items reference the same source file; merge, sequence, or assign ownership before implementation.
- Linear issue ready: `True`
- Auto-resolved: `False`
- Involved:
  - `AMB-INTELLIGENCE-CONSOLIDATION-CHAMPION-MERGE-PLAN-02` — `prompts/batches/AMB-INTELLIGENCE-CONSOLIDATION-CHAMPION-MERGE-PLAN-02.md` (partial_implementation; release proof)
  - `AMB-INTELLIGENCE-CONSOLIDATION-CHAMPION-SELECTION-01` — `prompts/batches/AMB-INTELLIGENCE-CONSOLIDATION-CHAMPION-SELECTION-01.md` (partial_implementation; release proof)

### 157. Same source file targeted by multiple active items: scripts/ambitions-post-pk-speed-train.sh

- Conflict ID: `AMB28-same_source_file_targeted_by_multiple_active_batches-16727292`
- Type: `same_source_file_targeted_by_multiple_active_batches`
- Severity: `yellow`
- Recommended action: `merge`
- Rationale: Multiple active ledger items reference the same source file; merge, sequence, or assign ownership before implementation.
- Linear issue ready: `True`
- Auto-resolved: `False`
- Involved:
  - `MOAT_RUNTIME_AUTONOMOUS_ROUTING_POLICY` — `docs/codex/MOAT_RUNTIME_AUTONOMOUS_ROUTING_POLICY.md` (unknown; release proof)
  - `POST_PK_SPEED_TRAIN_OPERATING_MODEL` — `docs/codex/POST_PK_SPEED_TRAIN_OPERATING_MODEL.md` (unknown; release proof)

### 158. Same source file targeted by multiple active items: scripts/ambitions-prompt-audit.sh

- Conflict ID: `AMB28-same_source_file_targeted_by_multiple_active_batches-20712034`
- Type: `same_source_file_targeted_by_multiple_active_batches`
- Severity: `yellow`
- Recommended action: `merge`
- Rationale: Multiple active ledger items reference the same source file; merge, sequence, or assign ownership before implementation.
- Linear issue ready: `True`
- Auto-resolved: `False`
- Involved:
  - `RHC01` — `prompts/batches/RHC01.md` (partial_implementation; release proof)
  - `CODEX-RUNNER-READ-ONLY-AUDIT-MODE-01` — `prompts/batches/CODEX-RUNNER-READ-ONLY-AUDIT-MODE-01.md` (partial_implementation; release proof)

### 159. Same source file targeted by multiple active items: scripts/ambitions-prompt-queue-consistency.py

- Conflict ID: `AMB28-same_source_file_targeted_by_multiple_active_batches-10019027`
- Type: `same_source_file_targeted_by_multiple_active_batches`
- Severity: `yellow`
- Recommended action: `merge`
- Rationale: Multiple active ledger items reference the same source file; merge, sequence, or assign ownership before implementation.
- Linear issue ready: `True`
- Auto-resolved: `False`
- Involved:
  - `OBS00-OPENAI-BUILD-SUITE-INSTALL` — `prompts/batches/OBS00-OPENAI-BUILD-SUITE-INSTALL.md` (partial_implementation; release proof)
  - `OBS04-PROMPT-REPAIR-BATCH-REPORT-LAYER` — `prompts/batches/OBS04-PROMPT-REPAIR-BATCH-REPORT-LAYER.md` (partial_implementation; release proof)
  - `OBS06-SPEED-TRAIN-INTEGRATION` — `prompts/batches/OBS06-SPEED-TRAIN-INTEGRATION.md` (partial_implementation; release proof)
  - `OPENAI_BUILD_SUITE_ADOPTION_MATRIX` — `docs/codex/OPENAI_BUILD_SUITE_ADOPTION_MATRIX.md` (unknown; release proof)
  - `POST_PK_SPEED_TRAIN_OPERATING_MODEL` — `docs/codex/POST_PK_SPEED_TRAIN_OPERATING_MODEL.md` (unknown; release proof)
  - `PROMPT_REPAIR_LAYER` — `docs/codex/PROMPT_REPAIR_LAYER.md` (unknown; release proof)

### 160. Same source file targeted by multiple active items: scripts/ambitions-queue-snapshot.py

- Conflict ID: `AMB28-same_source_file_targeted_by_multiple_active_batches-11460445`
- Type: `same_source_file_targeted_by_multiple_active_batches`
- Severity: `yellow`
- Recommended action: `merge`
- Rationale: Multiple active ledger items reference the same source file; merge, sequence, or assign ownership before implementation.
- Linear issue ready: `True`
- Auto-resolved: `False`
- Involved:
  - `AMB_CONTROL_PLANE_DIRECT_RUNBOOK` — `docs/codex/AMB_CONTROL_PLANE_DIRECT_RUNBOOK.md` (partial_implementation; release proof)
  - `AMB_CONTROL_PLANE_GATE_INDEX` — `docs/codex/AMB_CONTROL_PLANE_GATE_INDEX.md` (partial_implementation; release proof)
  - `HBI-GLOBAL-TRAIN-HANDOFF-01` — `prompts/batches/HBI-GLOBAL-TRAIN-HANDOFF-01.md` (partial_implementation; release proof)

### 161. Same source file targeted by multiple active items: scripts/ambitions-repo-authority-validate.py

- Conflict ID: `AMB28-same_source_file_targeted_by_multiple_active_batches-57415442`
- Type: `same_source_file_targeted_by_multiple_active_batches`
- Severity: `yellow`
- Recommended action: `merge`
- Rationale: Multiple active ledger items reference the same source file; merge, sequence, or assign ownership before implementation.
- Linear issue ready: `True`
- Auto-resolved: `False`
- Involved:
  - `AMB-REPO-AUTHORITY-07-GATES-FINAL-PROOF` — `prompts/batches/AMB-REPO-AUTHORITY-07-GATES-FINAL-PROOF.md` (partial_implementation; release proof)
  - `README-SOURCE-TRUTH-LINK-AND-CLAIM-REPAIR-01` — `prompts/batches/README-SOURCE-TRUTH-LINK-AND-CLAIM-REPAIR-01.md` (partial_implementation; release proof)
  - `REPO-AUTHORITY-LEGACY-ACTIVE-HEADER-CLEANUP-01` — `prompts/batches/REPO-AUTHORITY-LEGACY-ACTIVE-HEADER-CLEANUP-01.md` (partial_implementation; release proof)

### 162. Same source file targeted by multiple active items: scripts/ambitions-source-atlas-title-check.py

- Conflict ID: `AMB28-same_source_file_targeted_by_multiple_active_batches-76523821`
- Type: `same_source_file_targeted_by_multiple_active_batches`
- Severity: `yellow`
- Recommended action: `merge`
- Rationale: Multiple active ledger items reference the same source file; merge, sequence, or assign ownership before implementation.
- Linear issue ready: `True`
- Auto-resolved: `False`
- Involved:
  - `AMB_CONTROL_PLANE_DIRECT_RUNBOOK` — `docs/codex/AMB_CONTROL_PLANE_DIRECT_RUNBOOK.md` (partial_implementation; release proof)
  - `AMB_CONTROL_PLANE_GATE_INDEX` — `docs/codex/AMB_CONTROL_PLANE_GATE_INDEX.md` (partial_implementation; release proof)
  - `SA07` — `prompts/batches/SA07.md` (partial_implementation; release proof)
  - `SA08` — `prompts/batches/SA08.md` (partial_implementation; release proof)
  - `SA09` — `prompts/batches/SA09.md` (partial_implementation; release proof)
  - `SA10` — `prompts/batches/SA10.md` (partial_implementation; release proof)
  - `SA10A` — `prompts/batches/SA10A.md` (partial_implementation; release proof)
  - `SA10B` — `prompts/batches/SA10B.md` (partial_implementation; release proof)
  - `SA10C` — `prompts/batches/SA10C.md` (partial_implementation; release proof)
  - `SA11` — `prompts/batches/SA11.md` (partial_implementation; release proof)
  - `SA12` — `prompts/batches/SA12.md` (partial_implementation; release proof)
  - `SA13` — `prompts/batches/SA13.md` (partial_implementation; release proof)
  - `SA14` — `prompts/batches/SA14.md` (partial_implementation; release proof)
  - `SA15` — `prompts/batches/SA15.md` (partial_implementation; release proof)
  - `SA16` — `prompts/batches/SA16.md` (partial_implementation; release proof)
  - `SA17` — `prompts/batches/SA17.md` (partial_implementation; release proof)
  - `SA18` — `prompts/batches/SA18.md` (partial_implementation; release proof)
  - `SA19` — `prompts/batches/SA19.md` (partial_implementation; release proof)
  - `SA20` — `prompts/batches/SA20.md` (partial_implementation; release proof)
  - `SA21` — `prompts/batches/SA21.md` (partial_implementation; release proof)
  - `SA22` — `prompts/batches/SA22.md` (partial_implementation; release proof)
  - `SA23` — `prompts/batches/SA23.md` (partial_implementation; release proof)
  - `SA24` — `prompts/batches/SA24.md` (partial_implementation; release proof)
  - `SA25` — `prompts/batches/SA25.md` (partial_implementation; release proof)
  - `SA26` — `prompts/batches/SA26.md` (partial_implementation; release proof)
  - `SA27` — `prompts/batches/SA27.md` (partial_implementation; release proof)
  - `SA28` — `prompts/batches/SA28.md` (partial_implementation; release proof)
  - `SA29` — `prompts/batches/SA29.md` (partial_implementation; release proof)
  - `SA30` — `prompts/batches/SA30.md` (partial_implementation; release proof)
  - `SA31` — `prompts/batches/SA31.md` (partial_implementation; release proof)
  - ... 5 more

### 163. Same source file targeted by multiple active items: scripts/ambitions-state-advance-validate.py

- Conflict ID: `AMB28-same_source_file_targeted_by_multiple_active_batches-53952518`
- Type: `same_source_file_targeted_by_multiple_active_batches`
- Severity: `yellow`
- Recommended action: `merge`
- Rationale: Multiple active ledger items reference the same source file; merge, sequence, or assign ownership before implementation.
- Linear issue ready: `True`
- Auto-resolved: `False`
- Involved:
  - `POST_PK_CLOSEOUT_CONTRACT` — `docs/codex/POST_PK_CLOSEOUT_CONTRACT.md` (partial_implementation; release proof)
  - `POST_PK_SPEED_TRAIN_OPERATING_MODEL` — `docs/codex/POST_PK_SPEED_TRAIN_OPERATING_MODEL.md` (unknown; release proof)

### 164. Same source file targeted by multiple active items: scripts/ambitions-swift6-modernization-scan.py

- Conflict ID: `AMB28-same_source_file_targeted_by_multiple_active_batches-37254367`
- Type: `same_source_file_targeted_by_multiple_active_batches`
- Severity: `yellow`
- Recommended action: `merge`
- Rationale: Multiple active ledger items reference the same source file; merge, sequence, or assign ownership before implementation.
- Linear issue ready: `True`
- Auto-resolved: `False`
- Involved:
  - `AMB-FE-BE-INTEGRATED-PROOF-99` — `prompts/batches/amb-fe-be/AMB-FE-BE-INTEGRATED-PROOF-99.md` (partial_implementation; release proof)
  - `AMB-FE-BE-PREFLIGHT-00` — `prompts/batches/amb-fe-be/AMB-FE-BE-PREFLIGHT-00.md` (partial_implementation; release proof)
  - `CODEX_QUALITY_SYSTEM_SCRIPT_MAP` — `docs/codex/CODEX_QUALITY_SYSTEM_SCRIPT_MAP.md` (unknown; release proof)

### 165. Same source file targeted by multiple active items: scripts/ambitions-throughput-plan.sh

- Conflict ID: `AMB28-same_source_file_targeted_by_multiple_active_batches-78412429`
- Type: `same_source_file_targeted_by_multiple_active_batches`
- Severity: `yellow`
- Recommended action: `merge`
- Rationale: Multiple active ledger items reference the same source file; merge, sequence, or assign ownership before implementation.
- Linear issue ready: `True`
- Auto-resolved: `False`
- Involved:
  - `PK16` — `docs/codex/batch-prep/PK16.md` (partial_implementation; release proof)
  - `PK17` — `docs/codex/batch-prep/PK17.md` (partial_implementation; release proof)
  - `PK18` — `docs/codex/batch-prep/PK18.md` (partial_implementation; release proof)
  - `PK19` — `docs/codex/batch-prep/PK19.md` (partial_implementation; release proof)
  - `PK20` — `docs/codex/batch-prep/PK20.md` (partial_implementation; release proof)
  - `PK21` — `docs/codex/batch-prep/PK21.md` (partial_implementation; release proof)
  - `PK22` — `docs/codex/batch-prep/PK22.md` (partial_implementation; release proof)
  - `PK23` — `docs/codex/batch-prep/PK23.md` (partial_implementation; release proof)
  - `PK24` — `docs/codex/batch-prep/PK24.md` (partial_implementation; release proof)
  - `PK25` — `docs/codex/batch-prep/PK25.md` (partial_implementation; release proof)
  - `README` — `docs/codex/batch-prep/README.md` (partial_implementation; release proof)

### 166. Same source file targeted by multiple active items: scripts/ambitions-unsupported-claim-scan.py

- Conflict ID: `AMB28-same_source_file_targeted_by_multiple_active_batches-75250300`
- Type: `same_source_file_targeted_by_multiple_active_batches`
- Severity: `yellow`
- Recommended action: `merge`
- Rationale: Multiple active ledger items reference the same source file; merge, sequence, or assign ownership before implementation.
- Linear issue ready: `True`
- Auto-resolved: `False`
- Involved:
  - `MRI00-MOAT-RUNTIME-GAP-LOCK` — `prompts/batches/MRI00-MOAT-RUNTIME-GAP-LOCK.md` (partial_implementation; release proof)
  - `OBS00-OPENAI-BUILD-SUITE-INSTALL` — `prompts/batches/OBS00-OPENAI-BUILD-SUITE-INSTALL.md` (partial_implementation; release proof)
  - `SPEED_TRAIN_LANE_POLICY` — `docs/codex/SPEED_TRAIN_LANE_POLICY.json` (unknown; release proof)

### 167. Same source file targeted by multiple active items: scripts/ambitions-visual-100-anti-generic-check.py

- Conflict ID: `AMB28-same_source_file_targeted_by_multiple_active_batches-60858350`
- Type: `same_source_file_targeted_by_multiple_active_batches`
- Severity: `yellow`
- Recommended action: `merge`
- Rationale: Multiple active ledger items reference the same source file; merge, sequence, or assign ownership before implementation.
- Linear issue ready: `True`
- Auto-resolved: `False`
- Involved:
  - `FLAGSHIP-OBJECT-SYSTEM-01` — `prompts/batches/FLAGSHIP-OBJECT-SYSTEM-01.md` (partial_implementation; release proof)
  - `AMB-FLAGSHIP-UI-CODEX-STUDIO-INSTALL-01` — `docs/codex/reports/AMB-FLAGSHIP-UI-CODEX-STUDIO-INSTALL-01.md` (partial_implementation; release proof)

### 168. Same source file targeted by multiple active items: scripts/ambitions-vocabulary-drift-scan.py

- Conflict ID: `AMB28-same_source_file_targeted_by_multiple_active_batches-26001342`
- Type: `same_source_file_targeted_by_multiple_active_batches`
- Severity: `yellow`
- Recommended action: `merge`
- Rationale: Multiple active ledger items reference the same source file; merge, sequence, or assign ownership before implementation.
- Linear issue ready: `True`
- Auto-resolved: `False`
- Involved:
  - `AMB-REPO-AUTHORITY-06-ACTIVE-DRIFT-REPAIR` — `prompts/batches/AMB-REPO-AUTHORITY-06-ACTIVE-DRIFT-REPAIR.md` (partial_implementation; release proof)
  - `AMB-REPO-AUTHORITY-07-GATES-FINAL-PROOF` — `prompts/batches/AMB-REPO-AUTHORITY-07-GATES-FINAL-PROOF.md` (partial_implementation; release proof)
  - `TOP-LEVEL-IA-PLAN-LEAK-REGRESSION-01` — `prompts/batches/TOP-LEVEL-IA-PLAN-LEAK-REGRESSION-01.md` (partial_implementation; release proof)

### 169. Same source file targeted by multiple active items: scripts/ambitions-xcode-benchmark.sh

- Conflict ID: `AMB28-same_source_file_targeted_by_multiple_active_batches-26155038`
- Type: `same_source_file_targeted_by_multiple_active_batches`
- Severity: `yellow`
- Recommended action: `merge`
- Rationale: Multiple active ledger items reference the same source file; merge, sequence, or assign ownership before implementation.
- Linear issue ready: `True`
- Auto-resolved: `False`
- Involved:
  - `XCODE-PERF-RUNNER-MATURITY-01` — `prompts/batches/XCODE-PERF-RUNNER-MATURITY-01.md` (partial_implementation; release proof)
  - `XCODE_BUILD_LAB_PROTOCOL` — `docs/codex/XCODE_BUILD_LAB_PROTOCOL.md` (unknown; release proof)
  - `SPEED_TRAIN_LANE_POLICY` — `docs/codex/SPEED_TRAIN_LANE_POLICY.json` (unknown; release proof)
  - `SPEED_TRAIN_QUICKSTART` — `docs/codex/SPEED_TRAIN_QUICKSTART.md` (unknown; release proof)

### 170. Same source file targeted by multiple active items: scripts/ambitions-xcode-build-for-testing.sh

- Conflict ID: `AMB28-same_source_file_targeted_by_multiple_active_batches-23592353`
- Type: `same_source_file_targeted_by_multiple_active_batches`
- Severity: `yellow`
- Recommended action: `merge`
- Rationale: Multiple active ledger items reference the same source file; merge, sequence, or assign ownership before implementation.
- Linear issue ready: `True`
- Auto-resolved: `False`
- Involved:
  - `XCODE-BUILD-SYSTEM-MAX-01-REPAIR-01` — `prompts/batches/XCODE-BUILD-SYSTEM-MAX-01-REPAIR-01.md` (partial_implementation; release proof)
  - `XCODE-PERF-RUNNER-MATURITY-01` — `prompts/batches/XCODE-PERF-RUNNER-MATURITY-01.md` (partial_implementation; release proof)

### 171. Same source file targeted by multiple active items: scripts/ambitions-xcode-sim-health.sh

- Conflict ID: `AMB28-same_source_file_targeted_by_multiple_active_batches-88961568`
- Type: `same_source_file_targeted_by_multiple_active_batches`
- Severity: `yellow`
- Recommended action: `merge`
- Rationale: Multiple active ledger items reference the same source file; merge, sequence, or assign ownership before implementation.
- Linear issue ready: `True`
- Auto-resolved: `False`
- Involved:
  - `XCODE-PERF-RUNNER-MATURITY-01` — `prompts/batches/XCODE-PERF-RUNNER-MATURITY-01.md` (partial_implementation; release proof)
  - `XCODE_BUILD_LAB_PROTOCOL` — `docs/codex/XCODE_BUILD_LAB_PROTOCOL.md` (unknown; release proof)
  - `XCODE_SICK_SIMULATOR_PLAYBOOK` — `docs/codex/playbooks/XCODE_SICK_SIMULATOR_PLAYBOOK.md` (unknown; release proof)

### 172. Same source file targeted by multiple active items: scripts/ambitions-xcode-test-focused.sh

- Conflict ID: `AMB28-same_source_file_targeted_by_multiple_active_batches-41339339`
- Type: `same_source_file_targeted_by_multiple_active_batches`
- Severity: `yellow`
- Recommended action: `merge`
- Rationale: Multiple active ledger items reference the same source file; merge, sequence, or assign ownership before implementation.
- Linear issue ready: `True`
- Auto-resolved: `False`
- Involved:
  - `XCODE-BUILD-SYSTEM-MAX-01-REPAIR-01` — `prompts/batches/XCODE-BUILD-SYSTEM-MAX-01-REPAIR-01.md` (partial_implementation; release proof)
  - `XCODE-PERF-RUNNER-MATURITY-01` — `prompts/batches/XCODE-PERF-RUNNER-MATURITY-01.md` (partial_implementation; release proof)

### 173. Same source file targeted by multiple active items: scripts/ambitions-xcode-test-plan.sh

- Conflict ID: `AMB28-same_source_file_targeted_by_multiple_active_batches-47222083`
- Type: `same_source_file_targeted_by_multiple_active_batches`
- Severity: `yellow`
- Recommended action: `merge`
- Rationale: Multiple active ledger items reference the same source file; merge, sequence, or assign ownership before implementation.
- Linear issue ready: `True`
- Auto-resolved: `False`
- Involved:
  - `XCODE-BUILD-SYSTEM-MAX-01-REPAIR-01` — `prompts/batches/XCODE-BUILD-SYSTEM-MAX-01-REPAIR-01.md` (partial_implementation; release proof)
  - `XCODE-PERF-RUNNER-MATURITY-01` — `prompts/batches/XCODE-PERF-RUNNER-MATURITY-01.md` (partial_implementation; release proof)

### 174. Same source file targeted by multiple active items: scripts/ambitions-xcode-validate.sh

- Conflict ID: `AMB28-same_source_file_targeted_by_multiple_active_batches-38332976`
- Type: `same_source_file_targeted_by_multiple_active_batches`
- Severity: `yellow`
- Recommended action: `merge`
- Rationale: Multiple active ledger items reference the same source file; merge, sequence, or assign ownership before implementation.
- Linear issue ready: `True`
- Auto-resolved: `False`
- Involved:
  - `MCP_LOCAL_PRODUCTION_OS_PLAN` — `docs/codex/MCP_LOCAL_PRODUCTION_OS_PLAN.md` (partial_implementation; release proof)
  - `PK18` — `prompts/batches/PK18.md` (partial_implementation; release proof)
  - `PK19` — `prompts/batches/PK19.md` (partial_implementation; release proof)
  - `PK20` — `prompts/batches/PK20.md` (partial_implementation; release proof)
  - `PK21` — `prompts/batches/PK21.md` (partial_implementation; release proof)
  - `PK22` — `prompts/batches/PK22.md` (partial_implementation; release proof)
  - `PK23` — `prompts/batches/PK23.md` (partial_implementation; release proof)
  - `PK24` — `prompts/batches/PK24.md` (partial_implementation; release proof)
  - `PK25` — `prompts/batches/PK25.md` (partial_implementation; release proof)
  - `PK26` — `prompts/batches/PK26.md` (partial_implementation; release proof)
  - `PK27` — `prompts/batches/PK27.md` (partial_implementation; release proof)
  - `PK28` — `prompts/batches/PK28.md` (partial_implementation; release proof)
  - `PK29` — `prompts/batches/PK29.md` (partial_implementation; release proof)
  - `PK30` — `prompts/batches/PK30.md` (partial_implementation; release proof)
  - `PK31` — `prompts/batches/PK31.md` (partial_implementation; release proof)
  - `PK32` — `prompts/batches/PK32.md` (partial_implementation; release proof)
  - `PK33` — `prompts/batches/PK33.md` (partial_implementation; release proof)
  - `PK34` — `prompts/batches/PK34.md` (partial_implementation; release proof)
  - `PK35` — `prompts/batches/PK35.md` (partial_implementation; release proof)
  - `PK36` — `prompts/batches/PK36.md` (partial_implementation; release proof)
  - `PK37` — `prompts/batches/PK37.md` (partial_implementation; release proof)
  - `PK38` — `prompts/batches/PK38.md` (partial_implementation; release proof)
  - `PK39` — `prompts/batches/PK39.md` (partial_implementation; release proof)
  - `PK40` — `prompts/batches/PK40.md` (partial_implementation; release proof)
  - `PK41` — `prompts/batches/PK41.md` (partial_implementation; release proof)
  - `XCODE-BUILD-SYSTEM-MAX-01-REPAIR-01` — `prompts/batches/XCODE-BUILD-SYSTEM-MAX-01-REPAIR-01.md` (partial_implementation; release proof)
  - `BACKEND-FINAL-FORM-LOCAL-FIRST-HUMAN-01` — `prompts/batches/BACKEND-FINAL-FORM-LOCAL-FIRST-HUMAN-01.md` (partial_implementation; release proof)
  - `XCODE-PERF-RUNNER-MATURITY-01` — `prompts/batches/XCODE-PERF-RUNNER-MATURITY-01.md` (partial_implementation; release proof)
  - `XCODE_BUILD_LAB_PROTOCOL` — `docs/codex/XCODE_BUILD_LAB_PROTOCOL.md` (unknown; release proof)
  - `XCODE_SICK_SIMULATOR_PLAYBOOK` — `docs/codex/playbooks/XCODE_SICK_SIMULATOR_PLAYBOOK.md` (unknown; release proof)
  - ... 2 more

### 175. Same source file targeted by multiple active items: scripts/ambitions_codex_os_validate.py

- Conflict ID: `AMB28-same_source_file_targeted_by_multiple_active_batches-82768422`
- Type: `same_source_file_targeted_by_multiple_active_batches`
- Severity: `yellow`
- Recommended action: `merge`
- Rationale: Multiple active ledger items reference the same source file; merge, sequence, or assign ownership before implementation.
- Linear issue ready: `True`
- Auto-resolved: `False`
- Involved:
  - `AMB-FILE-BY-FILE-REPO-AUDIT-01` — `prompts/batches/AMB-FILE-BY-FILE-REPO-AUDIT-01.md` (partial_implementation; release proof)
  - `AMB-REPO-GREEN-FLAGSHIP-RESET-MASTER-01` — `prompts/batches/AMB-REPO-GREEN-FLAGSHIP-RESET-MASTER-01.md` (partial_implementation; release proof)

### 176. Same source file targeted by multiple active items: scripts/ambitions_validate_batch_ids.py

- Conflict ID: `AMB28-same_source_file_targeted_by_multiple_active_batches-19288834`
- Type: `same_source_file_targeted_by_multiple_active_batches`
- Severity: `yellow`
- Recommended action: `merge`
- Rationale: Multiple active ledger items reference the same source file; merge, sequence, or assign ownership before implementation.
- Linear issue ready: `True`
- Auto-resolved: `False`
- Involved:
  - `AMB_CODEX_GOVERNANCE_SPEC` — `docs/codex/AMB_CODEX_GOVERNANCE_SPEC.md` (partial_implementation; release proof)
  - `AMB-FILE-BY-FILE-REPO-AUDIT-01` — `prompts/batches/AMB-FILE-BY-FILE-REPO-AUDIT-01.md` (partial_implementation; release proof)
  - `AMB-REPO-GREEN-FLAGSHIP-RESET-MASTER-01` — `prompts/batches/AMB-REPO-GREEN-FLAGSHIP-RESET-MASTER-01.md` (partial_implementation; release proof)

### 177. Same source file targeted by multiple active items: scripts/ambitions_validate_prompt_headers.py

- Conflict ID: `AMB28-same_source_file_targeted_by_multiple_active_batches-50780751`
- Type: `same_source_file_targeted_by_multiple_active_batches`
- Severity: `yellow`
- Recommended action: `merge`
- Rationale: Multiple active ledger items reference the same source file; merge, sequence, or assign ownership before implementation.
- Linear issue ready: `True`
- Auto-resolved: `False`
- Involved:
  - `AMB_CODEX_GOVERNANCE_SPEC` — `docs/codex/AMB_CODEX_GOVERNANCE_SPEC.md` (partial_implementation; release proof)
  - `AMB-FILE-BY-FILE-REPO-AUDIT-01` — `prompts/batches/AMB-FILE-BY-FILE-REPO-AUDIT-01.md` (partial_implementation; release proof)
  - `AMB-REPO-GREEN-FLAGSHIP-RESET-MASTER-01` — `prompts/batches/AMB-REPO-GREEN-FLAGSHIP-RESET-MASTER-01.md` (partial_implementation; release proof)

### 178. Same source file targeted by multiple active items: scripts/ambitions_validate_visual_proof.py

- Conflict ID: `AMB28-same_source_file_targeted_by_multiple_active_batches-37445131`
- Type: `same_source_file_targeted_by_multiple_active_batches`
- Severity: `yellow`
- Recommended action: `merge`
- Rationale: Multiple active ledger items reference the same source file; merge, sequence, or assign ownership before implementation.
- Linear issue ready: `True`
- Auto-resolved: `False`
- Involved:
  - `POST_BATCH_GATE_REGISTRY` — `docs/codex/POST_BATCH_GATE_REGISTRY.md` (partial_implementation; release proof)
  - `AMB_CODEX_GOVERNANCE_SPEC` — `docs/codex/AMB_CODEX_GOVERNANCE_SPEC.md` (partial_implementation; release proof)

### 179. Same source file targeted by multiple active items: scripts/batch-train-gate-check.sh

- Conflict ID: `AMB28-same_source_file_targeted_by_multiple_active_batches-15166054`
- Type: `same_source_file_targeted_by_multiple_active_batches`
- Severity: `yellow`
- Recommended action: `merge`
- Rationale: Multiple active ledger items reference the same source file; merge, sequence, or assign ownership before implementation.
- Linear issue ready: `True`
- Auto-resolved: `False`
- Involved:
  - `F17_Shell_Meridian_Planning_And_Readiness_Audit_Prompt` — `docs/codex/batches/F17_Shell_Meridian_Planning_And_Readiness_Audit_Prompt.md` (partial_implementation; release proof)
  - `F18_Feature_Flagged_Meridian_Shell_Implementation_Prompt` — `docs/codex/batches/F18_Feature_Flagged_Meridian_Shell_Implementation_Prompt.md` (partial_implementation; release proof)
  - `GLOBAL_BATCH_AUTOMATED_GATE_PROTOCOL` — `docs/codex/GLOBAL_BATCH_AUTOMATED_GATE_PROTOCOL.md` (partial_implementation; release proof)
  - `REC01_Release_Evidence_Truth_Inventory_Prompt` — `docs/codex/batches/REC01_Release_Evidence_Truth_Inventory_Prompt.md` (partial_implementation; release proof)
  - `REC02_Human_Operator_Release_Proof_Plan_Prompt` — `docs/codex/batches/REC02_Human_Operator_Release_Proof_Plan_Prompt.md` (partial_implementation; release proof)
  - `REC03_Validation_Log_Ledger_Closure_Prompt` — `docs/codex/batches/REC03_Validation_Log_Ledger_Closure_Prompt.md` (partial_implementation; release proof)
  - `REC04_Release_Claim_Copy_Guard_Prompt` — `docs/codex/batches/REC04_Release_Claim_Copy_Guard_Prompt.md` (partial_implementation; release proof)
  - `REC05_Human_Review_Packet_Prompt` — `docs/codex/batches/REC05_Human_Review_Packet_Prompt.md` (partial_implementation; release proof)
  - `REC06_Release_Evidence_Closure_Handoff_Prompt` — `docs/codex/batches/REC06_Release_Evidence_Closure_Handoff_Prompt.md` (partial_implementation; release proof)
  - `SI01_Signature_Interface_Canon_To_SwiftUI_Architecture_Prompt` — `docs/codex/batches/SI01_Signature_Interface_Canon_To_SwiftUI_Architecture_Prompt.md` (partial_implementation; release proof)
  - `SI02_Adaptive_Panel_Action_And_Module_Foundation_Prompt` — `docs/codex/batches/SI02_Adaptive_Panel_Action_And_Module_Foundation_Prompt.md` (partial_implementation; release proof)
  - `SI03_App_Shell_IA_And_Navigation_List_System_Prompt` — `docs/codex/batches/SI03_App_Shell_IA_And_Navigation_List_System_Prompt.md` (partial_implementation; release proof)
  - `SI04_DayTimelineRail_2_0_Prompt` — `docs/codex/batches/SI04_DayTimelineRail_2_0_Prompt.md` (partial_implementation; release proof)
  - `SI06_LifePath_Visualization_System_Prompt` — `docs/codex/batches/SI06_LifePath_Visualization_System_Prompt.md` (partial_implementation; release proof)
  - `SI07_Mission_Control_Lane_Components_Prompt` — `docs/codex/batches/SI07_Mission_Control_Lane_Components_Prompt.md` (partial_implementation; release proof)
  - `SI08_LifeShape_Time_Capacity_Map_Prompt` — `docs/codex/batches/SI08_LifeShape_Time_Capacity_Map_Prompt.md` (partial_implementation; release proof)
  - `SI09_Capture_Atmosphere_Composer_Prompt` — `docs/codex/batches/SI09_Capture_Atmosphere_Composer_Prompt.md` (partial_implementation; release proof)
  - `SI10_Trust_Receipt_Layer_Prompt` — `docs/codex/batches/SI10_Trust_Receipt_Layer_Prompt.md` (partial_implementation; release proof)
  - `SI11_Personal_System_Center_Components_Prompt` — `docs/codex/batches/SI11_Personal_System_Center_Components_Prompt.md` (partial_implementation; release proof)
  - `SI12_Interaction_Motion_Haptics_System_Prompt` — `docs/codex/batches/SI12_Interaction_Motion_Haptics_System_Prompt.md` (partial_implementation; release proof)
  - `SI13_Loading_Empty_Degraded_State_Primitives_Prompt` — `docs/codex/batches/SI13_Loading_Empty_Degraded_State_Primitives_Prompt.md` (partial_implementation; release proof)
  - `SI14_Iconography_Symbol_And_Status_Grammar_Prompt` — `docs/codex/batches/SI14_Iconography_Symbol_And_Status_Grammar_Prompt.md` (partial_implementation; release proof)
  - `SI15_Accessibility_Adaptive_Interface_Pass_Prompt` — `docs/codex/batches/SI15_Accessibility_Adaptive_Interface_Pass_Prompt.md` (partial_implementation; release proof)
  - `SI16_Preview_Fixture_And_Visual_QA_Infrastructure_Prompt` — `docs/codex/batches/SI16_Preview_Fixture_And_Visual_QA_Infrastructure_Prompt.md` (partial_implementation; release proof)
  - `SI18_Signature_Interface_Handoff_And_Product_Depth_Readiness_Prompt` — `docs/codex/batches/SI18_Signature_Interface_Handoff_And_Product_Depth_Readiness_Prompt.md` (partial_implementation; release proof)
  - `GLOBAL_PATCH_TRAIN_INTERRUPTED_RUN_RECOVERY_PROTOCOL` — `docs/codex/GLOBAL_PATCH_TRAIN_INTERRUPTED_RUN_RECOVERY_PROTOCOL.md` (partial_implementation; release proof)
  - `DAV01_Dynamic_Visual_Source_Truth_And_Surface_Map_Prompt` — `docs/codex/batches/DAV01_Dynamic_Visual_Source_Truth_And_Surface_Map_Prompt.md` (partial_implementation; release proof)
  - `EB01_External_Brain_Source_Truth_And_Kernel_Architecture_Prompt` — `docs/codex/batches/EB01_External_Brain_Source_Truth_And_Kernel_Architecture_Prompt.md` (partial_implementation; release proof)
  - `EB02_Universal_Capture_Canon_And_Domain_Model_Prompt` — `docs/codex/batches/EB02_Universal_Capture_Canon_And_Domain_Model_Prompt.md` (partial_implementation; release proof)
  - `EB03_Universal_Capture_Composer_And_Routing_Prompt` — `docs/codex/batches/EB03_Universal_Capture_Composer_And_Routing_Prompt.md` (partial_implementation; release proof)
  - ... 85 more

### 180. Same source file targeted by multiple active items: scripts/build-local.sh

- Conflict ID: `AMB28-same_source_file_targeted_by_multiple_active_batches-46269820`
- Type: `same_source_file_targeted_by_multiple_active_batches`
- Severity: `yellow`
- Recommended action: `merge`
- Rationale: Multiple active ledger items reference the same source file; merge, sequence, or assign ownership before implementation.
- Linear issue ready: `True`
- Auto-resolved: `False`
- Involved:
  - `AMBITIONS_3_0_CONTEXT_LOADING_AND_TASK_ROUTING` — `docs/codex/AMBITIONS_3_0_CONTEXT_LOADING_AND_TASK_ROUTING.md` (partial_implementation; release proof)
  - `F03_5_Today_Execution_State_Contract_Hardening_Prompt` — `docs/codex/batches/F03_5_Today_Execution_State_Contract_Hardening_Prompt.md` (partial_implementation; release proof)
  - `F17_Shell_Meridian_Planning_And_Readiness_Audit_Prompt` — `docs/codex/batches/F17_Shell_Meridian_Planning_And_Readiness_Audit_Prompt.md` (partial_implementation; release proof)
  - `F18_Feature_Flagged_Meridian_Shell_Implementation_Prompt` — `docs/codex/batches/F18_Feature_Flagged_Meridian_Shell_Implementation_Prompt.md` (partial_implementation; release proof)
  - `SI02_Adaptive_Panel_Action_And_Module_Foundation_Prompt` — `docs/codex/batches/SI02_Adaptive_Panel_Action_And_Module_Foundation_Prompt.md` (partial_implementation; release proof)
  - `SI03_App_Shell_IA_And_Navigation_List_System_Prompt` — `docs/codex/batches/SI03_App_Shell_IA_And_Navigation_List_System_Prompt.md` (partial_implementation; release proof)
  - `SI04_DayTimelineRail_2_0_Prompt` — `docs/codex/batches/SI04_DayTimelineRail_2_0_Prompt.md` (partial_implementation; release proof)
  - `SI06_LifePath_Visualization_System_Prompt` — `docs/codex/batches/SI06_LifePath_Visualization_System_Prompt.md` (partial_implementation; release proof)
  - `SI07_Mission_Control_Lane_Components_Prompt` — `docs/codex/batches/SI07_Mission_Control_Lane_Components_Prompt.md` (partial_implementation; release proof)
  - `SI08_LifeShape_Time_Capacity_Map_Prompt` — `docs/codex/batches/SI08_LifeShape_Time_Capacity_Map_Prompt.md` (partial_implementation; release proof)
  - `SI09_Capture_Atmosphere_Composer_Prompt` — `docs/codex/batches/SI09_Capture_Atmosphere_Composer_Prompt.md` (partial_implementation; release proof)
  - `SI10_Trust_Receipt_Layer_Prompt` — `docs/codex/batches/SI10_Trust_Receipt_Layer_Prompt.md` (partial_implementation; release proof)
  - `SI11_Personal_System_Center_Components_Prompt` — `docs/codex/batches/SI11_Personal_System_Center_Components_Prompt.md` (partial_implementation; release proof)
  - `SI12_Interaction_Motion_Haptics_System_Prompt` — `docs/codex/batches/SI12_Interaction_Motion_Haptics_System_Prompt.md` (partial_implementation; release proof)
  - `SI13_Loading_Empty_Degraded_State_Primitives_Prompt` — `docs/codex/batches/SI13_Loading_Empty_Degraded_State_Primitives_Prompt.md` (partial_implementation; release proof)
  - `SI14_Iconography_Symbol_And_Status_Grammar_Prompt` — `docs/codex/batches/SI14_Iconography_Symbol_And_Status_Grammar_Prompt.md` (partial_implementation; release proof)
  - `SI15_Accessibility_Adaptive_Interface_Pass_Prompt` — `docs/codex/batches/SI15_Accessibility_Adaptive_Interface_Pass_Prompt.md` (partial_implementation; release proof)
  - `SI16_Preview_Fixture_And_Visual_QA_Infrastructure_Prompt` — `docs/codex/batches/SI16_Preview_Fixture_And_Visual_QA_Infrastructure_Prompt.md` (partial_implementation; release proof)
  - `FLAGSHIP_COMPLETION_GATE_MATRIX` — `docs/codex/FLAGSHIP_COMPLETION_GATE_MATRIX.md` (partial_implementation; release proof)
  - `FCP06_Receipt_Drawer_Trust_Layer_Prompt` — `docs/codex/batches/FCP06_Receipt_Drawer_Trust_Layer_Prompt.md` (partial_implementation; release proof)
  - `PFC05_CI_Local_Toolchain_Reproducibility_Prompt` — `docs/codex/batches/PFC05_CI_Local_Toolchain_Reproducibility_Prompt.md` (partial_implementation; release proof)
  - `AMBITIONSOS_AOS_EVIDENCE_LEDGER` — `docs/codex/AMBITIONSOS_AOS_EVIDENCE_LEDGER.md` (partial_implementation; release proof)
  - `PFC14_WidgetKit_Implementation_And_Tests_Prompt` — `docs/codex/batches/PFC14_WidgetKit_Implementation_And_Tests_Prompt.md` (partial_implementation; release proof)
  - `PFC16_Live_Activities_Implementation_And_Tests_Prompt` — `docs/codex/batches/PFC16_Live_Activities_Implementation_And_Tests_Prompt.md` (partial_implementation; release proof)
  - `PFC18_App_Intents_Shortcuts_Implementation_And_Tests_Prompt` — `docs/codex/batches/PFC18_App_Intents_Shortcuts_Implementation_And_Tests_Prompt.md` (partial_implementation; release proof)
  - `PFC20_Notifications_Calendar_Reminders_Implementation_Proof_Prompt` — `docs/codex/batches/PFC20_Notifications_Calendar_Reminders_Implementation_Proof_Prompt.md` (partial_implementation; release proof)
  - `POST_BATCH_GATE_REGISTRY` — `docs/codex/POST_BATCH_GATE_REGISTRY.md` (partial_implementation; release proof)
  - `AFI05_Shell_And_Continuity_Chrome` — `docs/codex/batches/AFI05_Shell_And_Continuity_Chrome.md` (partial_implementation; release proof)
  - `AFI09_Time_LifeShape_Field` — `docs/codex/batches/AFI09_Time_LifeShape_Field.md` (partial_implementation; release proof)
  - `AFI10_You_User_System_Profile` — `docs/codex/batches/AFI10_You_User_System_Profile.md` (partial_implementation; release proof)
  - ... 30 more

### 181. Same source file targeted by multiple active items: scripts/ci-local-parity.sh

- Conflict ID: `AMB28-same_source_file_targeted_by_multiple_active_batches-77383427`
- Type: `same_source_file_targeted_by_multiple_active_batches`
- Severity: `yellow`
- Recommended action: `merge`
- Rationale: Multiple active ledger items reference the same source file; merge, sequence, or assign ownership before implementation.
- Linear issue ready: `True`
- Auto-resolved: `False`
- Involved:
  - `PFC01_PFC40_PLATFORM_FRAMEWORK_COMPLIANCE_TRAIN` — `docs/codex/batch-trains/PFC01_PFC40_PLATFORM_FRAMEWORK_COMPLIANCE_TRAIN.md` (partial_implementation; release proof)
  - `PFC05_CI_Local_Toolchain_Reproducibility_Prompt` — `docs/codex/batches/PFC05_CI_Local_Toolchain_Reproducibility_Prompt.md` (partial_implementation; release proof)

### 182. Same source file targeted by multiple active items: scripts/codex-forbidden-claim-scan.sh

- Conflict ID: `AMB28-same_source_file_targeted_by_multiple_active_batches-88217938`
- Type: `same_source_file_targeted_by_multiple_active_batches`
- Severity: `yellow`
- Recommended action: `merge`
- Rationale: Multiple active ledger items reference the same source file; merge, sequence, or assign ownership before implementation.
- Linear issue ready: `True`
- Auto-resolved: `False`
- Involved:
  - `PK17` — `prompts/batches/PK17.md` (partial_implementation; release proof)
  - `PK18` — `prompts/batches/PK18.md` (partial_implementation; release proof)
  - `PK19` — `prompts/batches/PK19.md` (partial_implementation; release proof)
  - `PK20` — `prompts/batches/PK20.md` (partial_implementation; release proof)
  - `PK21` — `prompts/batches/PK21.md` (partial_implementation; release proof)
  - `PK22` — `prompts/batches/PK22.md` (partial_implementation; release proof)
  - `PK23` — `prompts/batches/PK23.md` (partial_implementation; release proof)
  - `PK24` — `prompts/batches/PK24.md` (partial_implementation; release proof)
  - `PK25` — `prompts/batches/PK25.md` (partial_implementation; release proof)
  - `PK26` — `prompts/batches/PK26.md` (partial_implementation; release proof)
  - `PK27` — `prompts/batches/PK27.md` (partial_implementation; release proof)
  - `PK28` — `prompts/batches/PK28.md` (partial_implementation; release proof)
  - `PK29` — `prompts/batches/PK29.md` (partial_implementation; release proof)
  - `PK30` — `prompts/batches/PK30.md` (partial_implementation; release proof)
  - `PK31` — `prompts/batches/PK31.md` (partial_implementation; release proof)
  - `PK32` — `prompts/batches/PK32.md` (partial_implementation; release proof)
  - `PK33` — `prompts/batches/PK33.md` (partial_implementation; release proof)
  - `PK34` — `prompts/batches/PK34.md` (partial_implementation; release proof)
  - `PK35` — `prompts/batches/PK35.md` (partial_implementation; release proof)
  - `PK36` — `prompts/batches/PK36.md` (partial_implementation; release proof)
  - `PK37` — `prompts/batches/PK37.md` (partial_implementation; release proof)
  - `PK38` — `prompts/batches/PK38.md` (partial_implementation; release proof)
  - `PK39` — `prompts/batches/PK39.md` (partial_implementation; release proof)
  - `PK40` — `prompts/batches/PK40.md` (partial_implementation; release proof)
  - `PK41` — `prompts/batches/PK41.md` (partial_implementation; release proof)
  - `AOS24` — `prompts/batches/AOS24.md` (partial_implementation; release proof)
  - `AOS25` — `prompts/batches/AOS25.md` (partial_implementation; release proof)
  - `AOS26` — `prompts/batches/AOS26.md` (partial_implementation; release proof)
  - `AOS27` — `prompts/batches/AOS27.md` (partial_implementation; release proof)
  - `AOS28` — `prompts/batches/AOS28.md` (partial_implementation; release proof)
  - ... 67 more

### 183. Same source file targeted by multiple active items: scripts/cqs-accessibility-motion-scan.sh

- Conflict ID: `AMB28-same_source_file_targeted_by_multiple_active_batches-27362426`
- Type: `same_source_file_targeted_by_multiple_active_batches`
- Severity: `yellow`
- Recommended action: `merge`
- Rationale: Multiple active ledger items reference the same source file; merge, sequence, or assign ownership before implementation.
- Linear issue ready: `True`
- Auto-resolved: `False`
- Involved:
  - `CQS01_CQS24_CODEX_QUALITY_SYSTEM_TRAIN` — `docs/codex/batch-trains/CQS01_CQS24_CODEX_QUALITY_SYSTEM_TRAIN.md` (partial_implementation; release proof)
  - `GATE_SYSTEM_HARDENING_NEXT_PROMPT` — `docs/codex/batches/GATE_SYSTEM_HARDENING_NEXT_PROMPT.md` (partial_implementation; release proof)
  - `PFC14_WidgetKit_Implementation_And_Tests_Prompt` — `docs/codex/batches/PFC14_WidgetKit_Implementation_And_Tests_Prompt.md` (partial_implementation; release proof)
  - `CODEX_QUALITY_SYSTEM_SCRIPT_MAP` — `docs/codex/CODEX_QUALITY_SYSTEM_SCRIPT_MAP.md` (unknown; release proof)

### 184. Same source file targeted by multiple active items: scripts/cqs-architecture-boundary-scan.sh

- Conflict ID: `AMB28-same_source_file_targeted_by_multiple_active_batches-54060002`
- Type: `same_source_file_targeted_by_multiple_active_batches`
- Severity: `yellow`
- Recommended action: `merge`
- Rationale: Multiple active ledger items reference the same source file; merge, sequence, or assign ownership before implementation.
- Linear issue ready: `True`
- Auto-resolved: `False`
- Involved:
  - `CQS01_CQS24_CODEX_QUALITY_SYSTEM_TRAIN` — `docs/codex/batch-trains/CQS01_CQS24_CODEX_QUALITY_SYSTEM_TRAIN.md` (partial_implementation; release proof)
  - `PFC02_Architecture_Boundary_And_Module_Map_Prompt` — `docs/codex/batches/PFC02_Architecture_Boundary_And_Module_Map_Prompt.md` (partial_implementation; release proof)
  - `GATE_SYSTEM_HARDENING_NEXT_PROMPT` — `docs/codex/batches/GATE_SYSTEM_HARDENING_NEXT_PROMPT.md` (partial_implementation; release proof)
  - `CODEX_QUALITY_SYSTEM_SCRIPT_MAP` — `docs/codex/CODEX_QUALITY_SYSTEM_SCRIPT_MAP.md` (unknown; release proof)

### 185. Same source file targeted by multiple active items: scripts/cqs-performance-budget-scan.sh

- Conflict ID: `AMB28-same_source_file_targeted_by_multiple_active_batches-82717472`
- Type: `same_source_file_targeted_by_multiple_active_batches`
- Severity: `yellow`
- Recommended action: `merge`
- Rationale: Multiple active ledger items reference the same source file; merge, sequence, or assign ownership before implementation.
- Linear issue ready: `True`
- Auto-resolved: `False`
- Involved:
  - `CQS01_CQS24_CODEX_QUALITY_SYSTEM_TRAIN` — `docs/codex/batch-trains/CQS01_CQS24_CODEX_QUALITY_SYSTEM_TRAIN.md` (partial_implementation; release proof)
  - `GATE_SYSTEM_HARDENING_NEXT_PROMPT` — `docs/codex/batches/GATE_SYSTEM_HARDENING_NEXT_PROMPT.md` (partial_implementation; release proof)
  - `PFC14_WidgetKit_Implementation_And_Tests_Prompt` — `docs/codex/batches/PFC14_WidgetKit_Implementation_And_Tests_Prompt.md` (partial_implementation; release proof)
  - `CODEX_QUALITY_SYSTEM_SCRIPT_MAP` — `docs/codex/CODEX_QUALITY_SYSTEM_SCRIPT_MAP.md` (unknown; release proof)

### 186. Same source file targeted by multiple active items: scripts/cqs-preview-coverage-scan.sh

- Conflict ID: `AMB28-same_source_file_targeted_by_multiple_active_batches-60571268`
- Type: `same_source_file_targeted_by_multiple_active_batches`
- Severity: `yellow`
- Recommended action: `merge`
- Rationale: Multiple active ledger items reference the same source file; merge, sequence, or assign ownership before implementation.
- Linear issue ready: `True`
- Auto-resolved: `False`
- Involved:
  - `CQS01_CQS24_CODEX_QUALITY_SYSTEM_TRAIN` — `docs/codex/batch-trains/CQS01_CQS24_CODEX_QUALITY_SYSTEM_TRAIN.md` (partial_implementation; release proof)
  - `CODEX_QUALITY_SYSTEM_SCRIPT_MAP` — `docs/codex/CODEX_QUALITY_SYSTEM_SCRIPT_MAP.md` (unknown; release proof)

### 187. Same source file targeted by multiple active items: scripts/cqs-privacy-security-claim-scan.sh

- Conflict ID: `AMB28-same_source_file_targeted_by_multiple_active_batches-39876285`
- Type: `same_source_file_targeted_by_multiple_active_batches`
- Severity: `yellow`
- Recommended action: `merge`
- Rationale: Multiple active ledger items reference the same source file; merge, sequence, or assign ownership before implementation.
- Linear issue ready: `True`
- Auto-resolved: `False`
- Involved:
  - `CQS01_CQS24_CODEX_QUALITY_SYSTEM_TRAIN` — `docs/codex/batch-trains/CQS01_CQS24_CODEX_QUALITY_SYSTEM_TRAIN.md` (partial_implementation; release proof)
  - `PFC04_Dependency_And_Supply_Chain_Policy_Enforcement_Prompt` — `docs/codex/batches/PFC04_Dependency_And_Supply_Chain_Policy_Enforcement_Prompt.md` (partial_implementation; release proof)
  - `PFC07_Migration_Ladder_And_Backward_Compatibility_Tests_Prompt` — `docs/codex/batches/PFC07_Migration_Ladder_And_Backward_Compatibility_Tests_Prompt.md` (partial_implementation; release proof)
  - `GATE_SYSTEM_HARDENING_NEXT_PROMPT` — `docs/codex/batches/GATE_SYSTEM_HARDENING_NEXT_PROMPT.md` (partial_implementation; release proof)
  - `PFC14_WidgetKit_Implementation_And_Tests_Prompt` — `docs/codex/batches/PFC14_WidgetKit_Implementation_And_Tests_Prompt.md` (partial_implementation; release proof)
  - `MOONSHOT_PROOF_PATH_BACKEND_MASTER_PLAN` — `docs/codex/MOONSHOT_PROOF_PATH_BACKEND_MASTER_PLAN.md` (partial_implementation; release proof)
  - `MOAT-MOONSHOT-BACKEND-FULL-TRAIN-01` — `prompts/batches/MOAT-MOONSHOT-BACKEND-FULL-TRAIN-01.md` (partial_implementation; release proof)
  - `MOAT-MOONSHOT-PROOF-PATH-01` — `prompts/batches/MOAT-MOONSHOT-PROOF-PATH-01.md` (partial_implementation; release proof)
  - `MOAT-UNIVERSAL-GOAL-REALITY-COMPILER-01` — `prompts/batches/MOAT-UNIVERSAL-GOAL-REALITY-COMPILER-01.md` (partial_implementation; release proof)
  - `CODEX_QUALITY_SYSTEM_SCRIPT_MAP` — `docs/codex/CODEX_QUALITY_SYSTEM_SCRIPT_MAP.md` (unknown; release proof)
  - `PFC08_Corruption_Recovery_Backup_Restore_Plan_Prompt` — `docs/codex/batches/PFC08_Corruption_Recovery_Backup_Restore_Plan_Prompt.md` (unknown; release proof)

### 188. Same source file targeted by multiple active items: scripts/cqs-product-drift-scan.sh

- Conflict ID: `AMB28-same_source_file_targeted_by_multiple_active_batches-66982787`
- Type: `same_source_file_targeted_by_multiple_active_batches`
- Severity: `yellow`
- Recommended action: `merge`
- Rationale: Multiple active ledger items reference the same source file; merge, sequence, or assign ownership before implementation.
- Linear issue ready: `True`
- Auto-resolved: `False`
- Involved:
  - `CQS01_CQS24_CODEX_QUALITY_SYSTEM_TRAIN` — `docs/codex/batch-trains/CQS01_CQS24_CODEX_QUALITY_SYSTEM_TRAIN.md` (partial_implementation; release proof)
  - `PFC03_Dead_Code_Prompt_Artifact_Naming_Smell_Audit_Prompt` — `docs/codex/batches/PFC03_Dead_Code_Prompt_Artifact_Naming_Smell_Audit_Prompt.md` (partial_implementation; release proof)
  - `GATE_RESULT_MANIFEST_SCHEMA` — `docs/codex/GATE_RESULT_MANIFEST_SCHEMA.md` (partial_implementation; release proof)
  - `GATE_SYSTEM_HARDENING_NEXT_PROMPT` — `docs/codex/batches/GATE_SYSTEM_HARDENING_NEXT_PROMPT.md` (partial_implementation; release proof)
  - `MOONSHOT_PROOF_PATH_BACKEND_MASTER_PLAN` — `docs/codex/MOONSHOT_PROOF_PATH_BACKEND_MASTER_PLAN.md` (partial_implementation; release proof)
  - `MOAT-MOONSHOT-BACKEND-FULL-TRAIN-01` — `prompts/batches/MOAT-MOONSHOT-BACKEND-FULL-TRAIN-01.md` (partial_implementation; release proof)
  - `MOAT-MOONSHOT-PROOF-PATH-01` — `prompts/batches/MOAT-MOONSHOT-PROOF-PATH-01.md` (partial_implementation; release proof)
  - `MOAT-UNIVERSAL-GOAL-REALITY-COMPILER-01` — `prompts/batches/MOAT-UNIVERSAL-GOAL-REALITY-COMPILER-01.md` (partial_implementation; release proof)
  - `CODEX_QUALITY_SYSTEM_SCRIPT_MAP` — `docs/codex/CODEX_QUALITY_SYSTEM_SCRIPT_MAP.md` (unknown; release proof)

### 189. Same source file targeted by multiple active items: scripts/cqs-prompt-built-smell-scan.sh

- Conflict ID: `AMB28-same_source_file_targeted_by_multiple_active_batches-80786611`
- Type: `same_source_file_targeted_by_multiple_active_batches`
- Severity: `yellow`
- Recommended action: `merge`
- Rationale: Multiple active ledger items reference the same source file; merge, sequence, or assign ownership before implementation.
- Linear issue ready: `True`
- Auto-resolved: `False`
- Involved:
  - `CQS01_CQS24_CODEX_QUALITY_SYSTEM_TRAIN` — `docs/codex/batch-trains/CQS01_CQS24_CODEX_QUALITY_SYSTEM_TRAIN.md` (partial_implementation; release proof)
  - `PFC03_Dead_Code_Prompt_Artifact_Naming_Smell_Audit_Prompt` — `docs/codex/batches/PFC03_Dead_Code_Prompt_Artifact_Naming_Smell_Audit_Prompt.md` (partial_implementation; release proof)
  - `GATE_SYSTEM_HARDENING_NEXT_PROMPT` — `docs/codex/batches/GATE_SYSTEM_HARDENING_NEXT_PROMPT.md` (partial_implementation; release proof)
  - `MOONSHOT_PROOF_PATH_BACKEND_MASTER_PLAN` — `docs/codex/MOONSHOT_PROOF_PATH_BACKEND_MASTER_PLAN.md` (partial_implementation; release proof)
  - `MOAT-MOONSHOT-BACKEND-FULL-TRAIN-01` — `prompts/batches/MOAT-MOONSHOT-BACKEND-FULL-TRAIN-01.md` (partial_implementation; release proof)
  - `MOAT-MOONSHOT-PROOF-PATH-01` — `prompts/batches/MOAT-MOONSHOT-PROOF-PATH-01.md` (partial_implementation; release proof)
  - `MOAT-UNIVERSAL-GOAL-REALITY-COMPILER-01` — `prompts/batches/MOAT-UNIVERSAL-GOAL-REALITY-COMPILER-01.md` (partial_implementation; release proof)
  - `CODEX_QUALITY_SYSTEM_SCRIPT_MAP` — `docs/codex/CODEX_QUALITY_SYSTEM_SCRIPT_MAP.md` (unknown; release proof)

### 190. Same source file targeted by multiple active items: scripts/dav-reduce-motion-check.sh

- Conflict ID: `AMB28-same_source_file_targeted_by_multiple_active_batches-22228171`
- Type: `same_source_file_targeted_by_multiple_active_batches`
- Severity: `yellow`
- Recommended action: `merge`
- Rationale: Multiple active ledger items reference the same source file; merge, sequence, or assign ownership before implementation.
- Linear issue ready: `True`
- Auto-resolved: `False`
- Involved:
  - `DAV02_Reusable_Living_Visual_Primitives_Implementation_Prompt` — `docs/codex/batches/DAV02_Reusable_Living_Visual_Primitives_Implementation_Prompt.md` (partial_implementation; release proof)
  - `DAV10_AdaptiveMotion_ReduceMotion_And_StateTransitions_Prompt` — `docs/codex/batches/DAV10_AdaptiveMotion_ReduceMotion_And_StateTransitions_Prompt.md` (partial_implementation; release proof)
  - `ACCESSIBILITY-DYNAMIC-TYPE-REDUCE-MOTION-PROOF-01` — `prompts/batches/ACCESSIBILITY-DYNAMIC-TYPE-REDUCE-MOTION-PROOF-01.md` (partial_implementation; release proof)

### 191. Same source file targeted by multiple active items: scripts/dav-visual-primitive-inventory.sh

- Conflict ID: `AMB28-same_source_file_targeted_by_multiple_active_batches-56184376`
- Type: `same_source_file_targeted_by_multiple_active_batches`
- Severity: `yellow`
- Recommended action: `merge`
- Rationale: Multiple active ledger items reference the same source file; merge, sequence, or assign ownership before implementation.
- Linear issue ready: `True`
- Auto-resolved: `False`
- Involved:
  - `DAV01_Dynamic_Visual_Source_Truth_And_Surface_Map_Prompt` — `docs/codex/batches/DAV01_Dynamic_Visual_Source_Truth_And_Surface_Map_Prompt.md` (partial_implementation; release proof)
  - `DAV02_Reusable_Living_Visual_Primitives_Implementation_Prompt` — `docs/codex/batches/DAV02_Reusable_Living_Visual_Primitives_Implementation_Prompt.md` (partial_implementation; release proof)

### 192. Same source file targeted by multiple active items: scripts/eb-active-train-integration-gate.sh

- Conflict ID: `AMB28-same_source_file_targeted_by_multiple_active_batches-52294095`
- Type: `same_source_file_targeted_by_multiple_active_batches`
- Severity: `yellow`
- Recommended action: `merge`
- Rationale: Multiple active ledger items reference the same source file; merge, sequence, or assign ownership before implementation.
- Linear issue ready: `True`
- Auto-resolved: `False`
- Involved:
  - `EB01_External_Brain_Source_Truth_And_Kernel_Architecture_Prompt` — `docs/codex/batches/EB01_External_Brain_Source_Truth_And_Kernel_Architecture_Prompt.md` (partial_implementation; release proof)
  - `EB02_Universal_Capture_Canon_And_Domain_Model_Prompt` — `docs/codex/batches/EB02_Universal_Capture_Canon_And_Domain_Model_Prompt.md` (partial_implementation; release proof)
  - `EB03_Universal_Capture_Composer_And_Routing_Prompt` — `docs/codex/batches/EB03_Universal_Capture_Composer_And_Routing_Prompt.md` (partial_implementation; release proof)
  - `EB04_Capture_Classification_And_Clarification_Prompt` — `docs/codex/batches/EB04_Capture_Classification_And_Clarification_Prompt.md` (partial_implementation; release proof)
  - `EB05_Capture_Clusters_Review_Bundles_And_Open_Loops_Prompt` — `docs/codex/batches/EB05_Capture_Clusters_Review_Bundles_And_Open_Loops_Prompt.md` (partial_implementation; release proof)
  - `EB06_Capture_Receipts_Undo_And_Reclassification_Prompt` — `docs/codex/batches/EB06_Capture_Receipts_Undo_And_Reclassification_Prompt.md` (partial_implementation; release proof)
  - `EB07_Life_Memory_Graph_Canon_And_Domain_Model_Prompt` — `docs/codex/batches/EB07_Life_Memory_Graph_Canon_And_Domain_Model_Prompt.md` (partial_implementation; release proof)
  - `EB08_Memory_Source_Confidence_And_Trust_Decay_Prompt` — `docs/codex/batches/EB08_Memory_Source_Confidence_And_Trust_Decay_Prompt.md` (partial_implementation; release proof)
  - `EB09_Life_Event_Decision_And_Context_Recall_Memory_Prompt` — `docs/codex/batches/EB09_Life_Event_Decision_And_Context_Recall_Memory_Prompt.md` (partial_implementation; release proof)
  - `EB10_Personal_Operating_Manual_Prompt` — `docs/codex/batches/EB10_Personal_Operating_Manual_Prompt.md` (partial_implementation; release proof)
  - `EB11_Memory_Correction_Deletion_And_Rejection_Prompt` — `docs/codex/batches/EB11_Memory_Correction_Deletion_And_Rejection_Prompt.md` (partial_implementation; release proof)
  - `EB12_Memory_Receipts_And_Why_Remembered_This_Prompt` — `docs/codex/batches/EB12_Memory_Receipts_And_Why_Remembered_This_Prompt.md` (partial_implementation; release proof)
  - `EB13_Trust_Privacy_User_Control_Canon_Prompt` — `docs/codex/batches/EB13_Trust_Privacy_User_Control_Canon_Prompt.md` (partial_implementation; release proof)
  - `EB14_Trust_Center_And_Data_Map_Prompt` — `docs/codex/batches/EB14_Trust_Center_And_Data_Map_Prompt.md` (partial_implementation; release proof)
  - `EB15_Recommendation_Evidence_And_Inference_Boundaries_Prompt` — `docs/codex/batches/EB15_Recommendation_Evidence_And_Inference_Boundaries_Prompt.md` (partial_implementation; release proof)
  - `EB16_Private_Mode_And_Sensitive_Area_Controls_Prompt` — `docs/codex/batches/EB16_Private_Mode_And_Sensitive_Area_Controls_Prompt.md` (partial_implementation; release proof)
  - `EB17_Undo_Correction_Audit_Trail_And_Export_Prompt` — `docs/codex/batches/EB17_Undo_Correction_Audit_Trail_And_Export_Prompt.md` (partial_implementation; release proof)
  - `EB18_Source_Freshness_Privacy_Receipts_And_Non_Claims_Prompt` — `docs/codex/batches/EB18_Source_Freshness_Privacy_Receipts_And_Non_Claims_Prompt.md` (partial_implementation; release proof)
  - `EB19_Product_Maturity_Onboarding_Canon_Prompt` — `docs/codex/batches/EB19_Product_Maturity_Onboarding_Canon_Prompt.md` (partial_implementation; release proof)
  - `EB20_Value_Based_Onboarding_And_First_Week_Success_Prompt` — `docs/codex/batches/EB20_Value_Based_Onboarding_And_First_Week_Success_Prompt.md` (partial_implementation; release proof)
  - `EB21_Concierge_Setup_And_Planning_Defaults_Onboarding_Prompt` — `docs/codex/batches/EB21_Concierge_Setup_And_Planning_Defaults_Onboarding_Prompt.md` (partial_implementation; release proof)
  - `EB22_Privacy_Setup_And_Trust_Onboarding_Prompt` — `docs/codex/batches/EB22_Privacy_Setup_And_Trust_Onboarding_Prompt.md` (partial_implementation; release proof)
  - `EB23_Maturity_Levels_Progressive_Disclosure_And_Life_Season_Templates_Prompt` — `docs/codex/batches/EB23_Maturity_Levels_Progressive_Disclosure_And_Life_Season_Templates_Prompt.md` (partial_implementation; release proof)
  - `EB24_Onboarding_Receipts_Skip_Later_And_Setup_Recovery_Prompt` — `docs/codex/batches/EB24_Onboarding_Receipts_Skip_Later_And_Setup_Recovery_Prompt.md` (partial_implementation; release proof)
  - `EB25_Accessibility_Cognitive_Load_Canon_Prompt` — `docs/codex/batches/EB25_Accessibility_Cognitive_Load_Canon_Prompt.md` (partial_implementation; release proof)
  - `EB26_Cognitive_Load_Modes_And_Interface_Density_Prompt` — `docs/codex/batches/EB26_Cognitive_Load_Modes_And_Interface_Density_Prompt.md` (partial_implementation; release proof)
  - `EB27_Dynamic_Type_VoiceOver_And_Reduce_Motion_Prompt` — `docs/codex/batches/EB27_Dynamic_Type_VoiceOver_And_Reduce_Motion_Prompt.md` (partial_implementation; release proof)
  - `EB28_Plain_Language_Anxiety_Safe_Copy_And_Explain_This_Screen_Prompt` — `docs/codex/batches/EB28_Plain_Language_Anxiety_Safe_Copy_And_Explain_This_Screen_Prompt.md` (partial_implementation; release proof)
  - `EB29_Voice_First_Operation_And_Motor_Accessibility_Prompt` — `docs/codex/batches/EB29_Voice_First_Operation_And_Motor_Accessibility_Prompt.md` (partial_implementation; release proof)
  - `EB30_Overloaded_Day_Adaptation_And_Low_Cognitive_Load_Flows_Prompt` — `docs/codex/batches/EB30_Overloaded_Day_Adaptation_And_Low_Cognitive_Load_Flows_Prompt.md` (partial_implementation; release proof)
  - ... 10 more

### 193. Same source file targeted by multiple active items: scripts/eb-no-5-version-drift-scan.sh

- Conflict ID: `AMB28-same_source_file_targeted_by_multiple_active_batches-25270500`
- Type: `same_source_file_targeted_by_multiple_active_batches`
- Severity: `yellow`
- Recommended action: `merge`
- Rationale: Multiple active ledger items reference the same source file; merge, sequence, or assign ownership before implementation.
- Linear issue ready: `True`
- Auto-resolved: `False`
- Involved:
  - `EB01_External_Brain_Source_Truth_And_Kernel_Architecture_Prompt` — `docs/codex/batches/EB01_External_Brain_Source_Truth_And_Kernel_Architecture_Prompt.md` (partial_implementation; release proof)
  - `EB02_Universal_Capture_Canon_And_Domain_Model_Prompt` — `docs/codex/batches/EB02_Universal_Capture_Canon_And_Domain_Model_Prompt.md` (partial_implementation; release proof)
  - `EB03_Universal_Capture_Composer_And_Routing_Prompt` — `docs/codex/batches/EB03_Universal_Capture_Composer_And_Routing_Prompt.md` (partial_implementation; release proof)
  - `EB04_Capture_Classification_And_Clarification_Prompt` — `docs/codex/batches/EB04_Capture_Classification_And_Clarification_Prompt.md` (partial_implementation; release proof)
  - `EB05_Capture_Clusters_Review_Bundles_And_Open_Loops_Prompt` — `docs/codex/batches/EB05_Capture_Clusters_Review_Bundles_And_Open_Loops_Prompt.md` (partial_implementation; release proof)
  - `EB06_Capture_Receipts_Undo_And_Reclassification_Prompt` — `docs/codex/batches/EB06_Capture_Receipts_Undo_And_Reclassification_Prompt.md` (partial_implementation; release proof)
  - `EB07_Life_Memory_Graph_Canon_And_Domain_Model_Prompt` — `docs/codex/batches/EB07_Life_Memory_Graph_Canon_And_Domain_Model_Prompt.md` (partial_implementation; release proof)
  - `EB08_Memory_Source_Confidence_And_Trust_Decay_Prompt` — `docs/codex/batches/EB08_Memory_Source_Confidence_And_Trust_Decay_Prompt.md` (partial_implementation; release proof)
  - `EB09_Life_Event_Decision_And_Context_Recall_Memory_Prompt` — `docs/codex/batches/EB09_Life_Event_Decision_And_Context_Recall_Memory_Prompt.md` (partial_implementation; release proof)
  - `EB10_Personal_Operating_Manual_Prompt` — `docs/codex/batches/EB10_Personal_Operating_Manual_Prompt.md` (partial_implementation; release proof)
  - `EB11_Memory_Correction_Deletion_And_Rejection_Prompt` — `docs/codex/batches/EB11_Memory_Correction_Deletion_And_Rejection_Prompt.md` (partial_implementation; release proof)
  - `EB12_Memory_Receipts_And_Why_Remembered_This_Prompt` — `docs/codex/batches/EB12_Memory_Receipts_And_Why_Remembered_This_Prompt.md` (partial_implementation; release proof)
  - `EB13_Trust_Privacy_User_Control_Canon_Prompt` — `docs/codex/batches/EB13_Trust_Privacy_User_Control_Canon_Prompt.md` (partial_implementation; release proof)
  - `EB14_Trust_Center_And_Data_Map_Prompt` — `docs/codex/batches/EB14_Trust_Center_And_Data_Map_Prompt.md` (partial_implementation; release proof)
  - `EB15_Recommendation_Evidence_And_Inference_Boundaries_Prompt` — `docs/codex/batches/EB15_Recommendation_Evidence_And_Inference_Boundaries_Prompt.md` (partial_implementation; release proof)
  - `EB16_Private_Mode_And_Sensitive_Area_Controls_Prompt` — `docs/codex/batches/EB16_Private_Mode_And_Sensitive_Area_Controls_Prompt.md` (partial_implementation; release proof)
  - `EB17_Undo_Correction_Audit_Trail_And_Export_Prompt` — `docs/codex/batches/EB17_Undo_Correction_Audit_Trail_And_Export_Prompt.md` (partial_implementation; release proof)
  - `EB18_Source_Freshness_Privacy_Receipts_And_Non_Claims_Prompt` — `docs/codex/batches/EB18_Source_Freshness_Privacy_Receipts_And_Non_Claims_Prompt.md` (partial_implementation; release proof)
  - `EB19_Product_Maturity_Onboarding_Canon_Prompt` — `docs/codex/batches/EB19_Product_Maturity_Onboarding_Canon_Prompt.md` (partial_implementation; release proof)
  - `EB20_Value_Based_Onboarding_And_First_Week_Success_Prompt` — `docs/codex/batches/EB20_Value_Based_Onboarding_And_First_Week_Success_Prompt.md` (partial_implementation; release proof)
  - `EB21_Concierge_Setup_And_Planning_Defaults_Onboarding_Prompt` — `docs/codex/batches/EB21_Concierge_Setup_And_Planning_Defaults_Onboarding_Prompt.md` (partial_implementation; release proof)
  - `EB22_Privacy_Setup_And_Trust_Onboarding_Prompt` — `docs/codex/batches/EB22_Privacy_Setup_And_Trust_Onboarding_Prompt.md` (partial_implementation; release proof)
  - `EB23_Maturity_Levels_Progressive_Disclosure_And_Life_Season_Templates_Prompt` — `docs/codex/batches/EB23_Maturity_Levels_Progressive_Disclosure_And_Life_Season_Templates_Prompt.md` (partial_implementation; release proof)
  - `EB24_Onboarding_Receipts_Skip_Later_And_Setup_Recovery_Prompt` — `docs/codex/batches/EB24_Onboarding_Receipts_Skip_Later_And_Setup_Recovery_Prompt.md` (partial_implementation; release proof)
  - `EB25_Accessibility_Cognitive_Load_Canon_Prompt` — `docs/codex/batches/EB25_Accessibility_Cognitive_Load_Canon_Prompt.md` (partial_implementation; release proof)
  - `EB26_Cognitive_Load_Modes_And_Interface_Density_Prompt` — `docs/codex/batches/EB26_Cognitive_Load_Modes_And_Interface_Density_Prompt.md` (partial_implementation; release proof)
  - `EB27_Dynamic_Type_VoiceOver_And_Reduce_Motion_Prompt` — `docs/codex/batches/EB27_Dynamic_Type_VoiceOver_And_Reduce_Motion_Prompt.md` (partial_implementation; release proof)
  - `EB28_Plain_Language_Anxiety_Safe_Copy_And_Explain_This_Screen_Prompt` — `docs/codex/batches/EB28_Plain_Language_Anxiety_Safe_Copy_And_Explain_This_Screen_Prompt.md` (partial_implementation; release proof)
  - `EB29_Voice_First_Operation_And_Motor_Accessibility_Prompt` — `docs/codex/batches/EB29_Voice_First_Operation_And_Motor_Accessibility_Prompt.md` (partial_implementation; release proof)
  - `EB30_Overloaded_Day_Adaptation_And_Low_Cognitive_Load_Flows_Prompt` — `docs/codex/batches/EB30_Overloaded_Day_Adaptation_And_Low_Cognitive_Load_Flows_Prompt.md` (partial_implementation; release proof)
  - ... 10 more

### 194. Same source file targeted by multiple active items: scripts/eb-no-unsupported-claim-scan.sh

- Conflict ID: `AMB28-same_source_file_targeted_by_multiple_active_batches-8214087`
- Type: `same_source_file_targeted_by_multiple_active_batches`
- Severity: `yellow`
- Recommended action: `merge`
- Rationale: Multiple active ledger items reference the same source file; merge, sequence, or assign ownership before implementation.
- Linear issue ready: `True`
- Auto-resolved: `False`
- Involved:
  - `EB01_External_Brain_Source_Truth_And_Kernel_Architecture_Prompt` — `docs/codex/batches/EB01_External_Brain_Source_Truth_And_Kernel_Architecture_Prompt.md` (partial_implementation; release proof)
  - `EB02_Universal_Capture_Canon_And_Domain_Model_Prompt` — `docs/codex/batches/EB02_Universal_Capture_Canon_And_Domain_Model_Prompt.md` (partial_implementation; release proof)
  - `EB03_Universal_Capture_Composer_And_Routing_Prompt` — `docs/codex/batches/EB03_Universal_Capture_Composer_And_Routing_Prompt.md` (partial_implementation; release proof)
  - `EB04_Capture_Classification_And_Clarification_Prompt` — `docs/codex/batches/EB04_Capture_Classification_And_Clarification_Prompt.md` (partial_implementation; release proof)
  - `EB05_Capture_Clusters_Review_Bundles_And_Open_Loops_Prompt` — `docs/codex/batches/EB05_Capture_Clusters_Review_Bundles_And_Open_Loops_Prompt.md` (partial_implementation; release proof)
  - `EB06_Capture_Receipts_Undo_And_Reclassification_Prompt` — `docs/codex/batches/EB06_Capture_Receipts_Undo_And_Reclassification_Prompt.md` (partial_implementation; release proof)
  - `EB07_Life_Memory_Graph_Canon_And_Domain_Model_Prompt` — `docs/codex/batches/EB07_Life_Memory_Graph_Canon_And_Domain_Model_Prompt.md` (partial_implementation; release proof)
  - `EB08_Memory_Source_Confidence_And_Trust_Decay_Prompt` — `docs/codex/batches/EB08_Memory_Source_Confidence_And_Trust_Decay_Prompt.md` (partial_implementation; release proof)
  - `EB09_Life_Event_Decision_And_Context_Recall_Memory_Prompt` — `docs/codex/batches/EB09_Life_Event_Decision_And_Context_Recall_Memory_Prompt.md` (partial_implementation; release proof)
  - `EB10_Personal_Operating_Manual_Prompt` — `docs/codex/batches/EB10_Personal_Operating_Manual_Prompt.md` (partial_implementation; release proof)
  - `EB11_Memory_Correction_Deletion_And_Rejection_Prompt` — `docs/codex/batches/EB11_Memory_Correction_Deletion_And_Rejection_Prompt.md` (partial_implementation; release proof)
  - `EB12_Memory_Receipts_And_Why_Remembered_This_Prompt` — `docs/codex/batches/EB12_Memory_Receipts_And_Why_Remembered_This_Prompt.md` (partial_implementation; release proof)
  - `EB13_Trust_Privacy_User_Control_Canon_Prompt` — `docs/codex/batches/EB13_Trust_Privacy_User_Control_Canon_Prompt.md` (partial_implementation; release proof)
  - `EB14_Trust_Center_And_Data_Map_Prompt` — `docs/codex/batches/EB14_Trust_Center_And_Data_Map_Prompt.md` (partial_implementation; release proof)
  - `EB15_Recommendation_Evidence_And_Inference_Boundaries_Prompt` — `docs/codex/batches/EB15_Recommendation_Evidence_And_Inference_Boundaries_Prompt.md` (partial_implementation; release proof)
  - `EB16_Private_Mode_And_Sensitive_Area_Controls_Prompt` — `docs/codex/batches/EB16_Private_Mode_And_Sensitive_Area_Controls_Prompt.md` (partial_implementation; release proof)
  - `EB17_Undo_Correction_Audit_Trail_And_Export_Prompt` — `docs/codex/batches/EB17_Undo_Correction_Audit_Trail_And_Export_Prompt.md` (partial_implementation; release proof)
  - `EB18_Source_Freshness_Privacy_Receipts_And_Non_Claims_Prompt` — `docs/codex/batches/EB18_Source_Freshness_Privacy_Receipts_And_Non_Claims_Prompt.md` (partial_implementation; release proof)
  - `EB19_Product_Maturity_Onboarding_Canon_Prompt` — `docs/codex/batches/EB19_Product_Maturity_Onboarding_Canon_Prompt.md` (partial_implementation; release proof)
  - `EB20_Value_Based_Onboarding_And_First_Week_Success_Prompt` — `docs/codex/batches/EB20_Value_Based_Onboarding_And_First_Week_Success_Prompt.md` (partial_implementation; release proof)
  - `EB21_Concierge_Setup_And_Planning_Defaults_Onboarding_Prompt` — `docs/codex/batches/EB21_Concierge_Setup_And_Planning_Defaults_Onboarding_Prompt.md` (partial_implementation; release proof)
  - `EB22_Privacy_Setup_And_Trust_Onboarding_Prompt` — `docs/codex/batches/EB22_Privacy_Setup_And_Trust_Onboarding_Prompt.md` (partial_implementation; release proof)
  - `EB23_Maturity_Levels_Progressive_Disclosure_And_Life_Season_Templates_Prompt` — `docs/codex/batches/EB23_Maturity_Levels_Progressive_Disclosure_And_Life_Season_Templates_Prompt.md` (partial_implementation; release proof)
  - `EB24_Onboarding_Receipts_Skip_Later_And_Setup_Recovery_Prompt` — `docs/codex/batches/EB24_Onboarding_Receipts_Skip_Later_And_Setup_Recovery_Prompt.md` (partial_implementation; release proof)
  - `EB25_Accessibility_Cognitive_Load_Canon_Prompt` — `docs/codex/batches/EB25_Accessibility_Cognitive_Load_Canon_Prompt.md` (partial_implementation; release proof)
  - `EB26_Cognitive_Load_Modes_And_Interface_Density_Prompt` — `docs/codex/batches/EB26_Cognitive_Load_Modes_And_Interface_Density_Prompt.md` (partial_implementation; release proof)
  - `EB27_Dynamic_Type_VoiceOver_And_Reduce_Motion_Prompt` — `docs/codex/batches/EB27_Dynamic_Type_VoiceOver_And_Reduce_Motion_Prompt.md` (partial_implementation; release proof)
  - `EB28_Plain_Language_Anxiety_Safe_Copy_And_Explain_This_Screen_Prompt` — `docs/codex/batches/EB28_Plain_Language_Anxiety_Safe_Copy_And_Explain_This_Screen_Prompt.md` (partial_implementation; release proof)
  - `EB29_Voice_First_Operation_And_Motor_Accessibility_Prompt` — `docs/codex/batches/EB29_Voice_First_Operation_And_Motor_Accessibility_Prompt.md` (partial_implementation; release proof)
  - `EB30_Overloaded_Day_Adaptation_And_Low_Cognitive_Load_Flows_Prompt` — `docs/codex/batches/EB30_Overloaded_Day_Adaptation_And_Low_Cognitive_Load_Flows_Prompt.md` (partial_implementation; release proof)
  - ... 10 more

### 195. Same source file targeted by multiple active items: scripts/fet-bottom-chrome-conflict-scan.sh

- Conflict ID: `AMB28-same_source_file_targeted_by_multiple_active_batches-92257346`
- Type: `same_source_file_targeted_by_multiple_active_batches`
- Severity: `yellow`
- Recommended action: `merge`
- Rationale: Multiple active ledger items reference the same source file; merge, sequence, or assign ownership before implementation.
- Linear issue ready: `True`
- Auto-resolved: `False`
- Involved:
  - `GLOBAL_BATCH_AUTOMATED_GATE_PROTOCOL` — `docs/codex/GLOBAL_BATCH_AUTOMATED_GATE_PROTOCOL.md` (partial_implementation; release proof)
  - `FET01_FET12_FAANG_FRONTEND_EXCELLENCE_TRAIN` — `docs/codex/batch-trains/FET01_FET12_FAANG_FRONTEND_EXCELLENCE_TRAIN.md` (partial_implementation; release proof)
  - `FET00_FAANG_FRONTEND_CODEX_OS_UPGRADE_PROMPT` — `docs/codex/batches/FET00_FAANG_FRONTEND_CODEX_OS_UPGRADE_PROMPT.md` (partial_implementation; release proof)

### 196. Same source file targeted by multiple active items: scripts/fet-copy-density-scan.sh

- Conflict ID: `AMB28-same_source_file_targeted_by_multiple_active_batches-39729413`
- Type: `same_source_file_targeted_by_multiple_active_batches`
- Severity: `yellow`
- Recommended action: `merge`
- Rationale: Multiple active ledger items reference the same source file; merge, sequence, or assign ownership before implementation.
- Linear issue ready: `True`
- Auto-resolved: `False`
- Involved:
  - `GLOBAL_BATCH_AUTOMATED_GATE_PROTOCOL` — `docs/codex/GLOBAL_BATCH_AUTOMATED_GATE_PROTOCOL.md` (partial_implementation; release proof)
  - `FET01_FET12_FAANG_FRONTEND_EXCELLENCE_TRAIN` — `docs/codex/batch-trains/FET01_FET12_FAANG_FRONTEND_EXCELLENCE_TRAIN.md` (partial_implementation; release proof)
  - `FET00_FAANG_FRONTEND_CODEX_OS_UPGRADE_PROMPT` — `docs/codex/batches/FET00_FAANG_FRONTEND_CODEX_OS_UPGRADE_PROMPT.md` (partial_implementation; release proof)

### 197. Same source file targeted by multiple active items: scripts/fet-first-viewport-budget-scan.sh

- Conflict ID: `AMB28-same_source_file_targeted_by_multiple_active_batches-39316650`
- Type: `same_source_file_targeted_by_multiple_active_batches`
- Severity: `yellow`
- Recommended action: `merge`
- Rationale: Multiple active ledger items reference the same source file; merge, sequence, or assign ownership before implementation.
- Linear issue ready: `True`
- Auto-resolved: `False`
- Involved:
  - `GLOBAL_BATCH_AUTOMATED_GATE_PROTOCOL` — `docs/codex/GLOBAL_BATCH_AUTOMATED_GATE_PROTOCOL.md` (partial_implementation; release proof)
  - `FET01_FET12_FAANG_FRONTEND_EXCELLENCE_TRAIN` — `docs/codex/batch-trains/FET01_FET12_FAANG_FRONTEND_EXCELLENCE_TRAIN.md` (partial_implementation; release proof)
  - `FET00_FAANG_FRONTEND_CODEX_OS_UPGRADE_PROMPT` — `docs/codex/batches/FET00_FAANG_FRONTEND_CODEX_OS_UPGRADE_PROMPT.md` (partial_implementation; release proof)

### 198. Same source file targeted by multiple active items: scripts/fet-primitive-density-scan.sh

- Conflict ID: `AMB28-same_source_file_targeted_by_multiple_active_batches-49203811`
- Type: `same_source_file_targeted_by_multiple_active_batches`
- Severity: `yellow`
- Recommended action: `merge`
- Rationale: Multiple active ledger items reference the same source file; merge, sequence, or assign ownership before implementation.
- Linear issue ready: `True`
- Auto-resolved: `False`
- Involved:
  - `GLOBAL_BATCH_AUTOMATED_GATE_PROTOCOL` — `docs/codex/GLOBAL_BATCH_AUTOMATED_GATE_PROTOCOL.md` (partial_implementation; release proof)
  - `FET01_FET12_FAANG_FRONTEND_EXCELLENCE_TRAIN` — `docs/codex/batch-trains/FET01_FET12_FAANG_FRONTEND_EXCELLENCE_TRAIN.md` (partial_implementation; release proof)
  - `FET00_FAANG_FRONTEND_CODEX_OS_UPGRADE_PROMPT` — `docs/codex/batches/FET00_FAANG_FRONTEND_CODEX_OS_UPGRADE_PROMPT.md` (partial_implementation; release proof)

### 199. Same source file targeted by multiple active items: scripts/fet-readiness-gate.sh

- Conflict ID: `AMB28-same_source_file_targeted_by_multiple_active_batches-49923392`
- Type: `same_source_file_targeted_by_multiple_active_batches`
- Severity: `yellow`
- Recommended action: `merge`
- Rationale: Multiple active ledger items reference the same source file; merge, sequence, or assign ownership before implementation.
- Linear issue ready: `True`
- Auto-resolved: `False`
- Involved:
  - `GLOBAL_BATCH_AUTOMATED_GATE_PROTOCOL` — `docs/codex/GLOBAL_BATCH_AUTOMATED_GATE_PROTOCOL.md` (partial_implementation; release proof)
  - `FET01_FET12_FAANG_FRONTEND_EXCELLENCE_TRAIN` — `docs/codex/batch-trains/FET01_FET12_FAANG_FRONTEND_EXCELLENCE_TRAIN.md` (partial_implementation; release proof)
  - `FET00_FAANG_FRONTEND_CODEX_OS_UPGRADE_PROMPT` — `docs/codex/batches/FET00_FAANG_FRONTEND_CODEX_OS_UPGRADE_PROMPT.md` (partial_implementation; release proof)

### 200. Same source file targeted by multiple active items: scripts/fet-visual-qa-packet-check.sh

- Conflict ID: `AMB28-same_source_file_targeted_by_multiple_active_batches-36264026`
- Type: `same_source_file_targeted_by_multiple_active_batches`
- Severity: `yellow`
- Recommended action: `merge`
- Rationale: Multiple active ledger items reference the same source file; merge, sequence, or assign ownership before implementation.
- Linear issue ready: `True`
- Auto-resolved: `False`
- Involved:
  - `GLOBAL_BATCH_AUTOMATED_GATE_PROTOCOL` — `docs/codex/GLOBAL_BATCH_AUTOMATED_GATE_PROTOCOL.md` (partial_implementation; release proof)
  - `FET01_FET12_FAANG_FRONTEND_EXCELLENCE_TRAIN` — `docs/codex/batch-trains/FET01_FET12_FAANG_FRONTEND_EXCELLENCE_TRAIN.md` (partial_implementation; release proof)
  - `FET00_FAANG_FRONTEND_CODEX_OS_UPGRADE_PROMPT` — `docs/codex/batches/FET00_FAANG_FRONTEND_CODEX_OS_UPGRADE_PROMPT.md` (partial_implementation; release proof)

### 201. Same source file targeted by multiple active items: scripts/global-train-next-batch.sh

- Conflict ID: `AMB28-same_source_file_targeted_by_multiple_active_batches-55457483`
- Type: `same_source_file_targeted_by_multiple_active_batches`
- Severity: `yellow`
- Recommended action: `merge`
- Rationale: Multiple active ledger items reference the same source file; merge, sequence, or assign ownership before implementation.
- Linear issue ready: `True`
- Auto-resolved: `False`
- Involved:
  - `GLOBAL_PATCH_TRAIN_INTERRUPTED_RUN_RECOVERY_PROTOCOL` — `docs/codex/GLOBAL_PATCH_TRAIN_INTERRUPTED_RUN_RECOVERY_PROTOCOL.md` (partial_implementation; release proof)
  - `AMBITIONS_4_0_EXTERNAL_BRAIN_CLOSEOUT` — `docs/codex/AMBITIONS_4_0_EXTERNAL_BRAIN_CLOSEOUT.md` (partial_implementation; release proof)
  - `LDI01_Living_Dream_Architecture_Source_Truth_Prompt` — `docs/codex/batches/LDI01_Living_Dream_Architecture_Source_Truth_Prompt.md` (partial_implementation; release proof)
  - `LDI02_Capture_Handling_Ladder_Prompt` — `docs/codex/batches/LDI02_Capture_Handling_Ladder_Prompt.md` (partial_implementation; release proof)
  - `LDI03_Dream_Safety_Legality_Feasibility_Triage_Prompt` — `docs/codex/batches/LDI03_Dream_Safety_Legality_Feasibility_Triage_Prompt.md` (partial_implementation; release proof)
  - `LDI04_North_Star_Extraction_Prompt` — `docs/codex/batches/LDI04_North_Star_Extraction_Prompt.md` (partial_implementation; release proof)
  - `LDI05_Source_Claim_Graph_Prompt` — `docs/codex/batches/LDI05_Source_Claim_Graph_Prompt.md` (partial_implementation; release proof)
  - `LDI06_Pack_Registry_And_Pack_Compiler_Prompt` — `docs/codex/batches/LDI06_Pack_Registry_And_Pack_Compiler_Prompt.md` (partial_implementation; release proof)
  - `LDI07_Pack_Supply_Chain_Security_Prompt` — `docs/codex/batches/LDI07_Pack_Supply_Chain_Security_Prompt.md` (partial_implementation; release proof)
  - `LDI08_Requirement_Graph_Runtime_Prompt` — `docs/codex/batches/LDI08_Requirement_Graph_Runtime_Prompt.md` (partial_implementation; release proof)
  - `LDI09_Eligibility_And_Deadline_Runtime_Prompt` — `docs/codex/batches/LDI09_Eligibility_And_Deadline_Runtime_Prompt.md` (partial_implementation; release proof)
  - `LDI10_Starting_Position_And_Privacy_Intake_Prompt` — `docs/codex/batches/LDI10_Starting_Position_And_Privacy_Intake_Prompt.md` (partial_implementation; release proof)
  - `LDI11_Path_Portfolio_Runtime_Prompt` — `docs/codex/batches/LDI11_Path_Portfolio_Runtime_Prompt.md` (partial_implementation; release proof)
  - `LDI12_Capacity_And_Commitment_Time_Bridge_Prompt` — `docs/codex/batches/LDI12_Capacity_And_Commitment_Time_Bridge_Prompt.md` (partial_implementation; release proof)
  - `LDI13_Today_Bridge_And_Action_Closure_Prompt` — `docs/codex/batches/LDI13_Today_Bridge_And_Action_Closure_Prompt.md` (partial_implementation; release proof)
  - `LDI14_Trust_Review_And_Dream_Handling_Receipts_Prompt` — `docs/codex/batches/LDI14_Trust_Review_And_Dream_Handling_Receipts_Prompt.md` (partial_implementation; release proof)
  - `LDI15_Living_Plan_Recompiler_Prompt` — `docs/codex/batches/LDI15_Living_Plan_Recompiler_Prompt.md` (partial_implementation; release proof)
  - `LDI16_Mutation_Permissions_And_Impact_Levels_Prompt` — `docs/codex/batches/LDI16_Mutation_Permissions_And_Impact_Levels_Prompt.md` (partial_implementation; release proof)
  - `LDI17_Continuity_Sync_Prompt` — `docs/codex/batches/LDI17_Continuity_Sync_Prompt.md` (partial_implementation; release proof)
  - `LDI18_Archive_And_Schema_Migration_Prompt` — `docs/codex/batches/LDI18_Archive_And_Schema_Migration_Prompt.md` (partial_implementation; release proof)
  - `LDI19_Multi_Device_Merge_Ledger_Prompt` — `docs/codex/batches/LDI19_Multi_Device_Merge_Ledger_Prompt.md` (partial_implementation; release proof)
  - `LDI20_Freshness_Broker_Prompt` — `docs/codex/batches/LDI20_Freshness_Broker_Prompt.md` (partial_implementation; release proof)
  - `LDI21_Red_Team_Evaluation_Suite_Prompt` — `docs/codex/batches/LDI21_Red_Team_Evaluation_Suite_Prompt.md` (partial_implementation; release proof)
  - `LDI22_Governance_And_Maintenance_Console_Prompt` — `docs/codex/batches/LDI22_Governance_And_Maintenance_Console_Prompt.md` (partial_implementation; release proof)
  - `TIME_REPLACES_PLAN_COMPATIBILITY_LEDGER` — `docs/codex/TIME_REPLACES_PLAN_COMPATIBILITY_LEDGER.md` (partial_implementation; release proof)
  - `PK01_Package_Module_Boundary_Scaffold` — `docs/codex/batches/PK01_Package_Module_Boundary_Scaffold.md` (partial_implementation; release proof)
  - `PK02_Architecture_Boundary_Scanner` — `docs/codex/batches/PK02_Architecture_Boundary_Scanner.md` (partial_implementation; release proof)

### 202. Same source file targeted by multiple active items: scripts/global-train-status-summary.sh

- Conflict ID: `AMB28-same_source_file_targeted_by_multiple_active_batches-63203346`
- Type: `same_source_file_targeted_by_multiple_active_batches`
- Severity: `yellow`
- Recommended action: `merge`
- Rationale: Multiple active ledger items reference the same source file; merge, sequence, or assign ownership before implementation.
- Linear issue ready: `True`
- Auto-resolved: `False`
- Involved:
  - `GLOBAL_PATCH_TRAIN_INTERRUPTED_RUN_RECOVERY_PROTOCOL` — `docs/codex/GLOBAL_PATCH_TRAIN_INTERRUPTED_RUN_RECOVERY_PROTOCOL.md` (partial_implementation; release proof)
  - `TIME_REPLACES_PLAN_COMPATIBILITY_LEDGER` — `docs/codex/TIME_REPLACES_PLAN_COMPATIBILITY_LEDGER.md` (partial_implementation; release proof)

### 203. Same source file targeted by multiple active items: scripts/ios26-flagship-run-sequential.sh

- Conflict ID: `AMB28-same_source_file_targeted_by_multiple_active_batches-97917798`
- Type: `same_source_file_targeted_by_multiple_active_batches`
- Severity: `yellow`
- Recommended action: `merge`
- Rationale: Multiple active ledger items reference the same source file; merge, sequence, or assign ownership before implementation.
- Linear issue ready: `True`
- Auto-resolved: `False`
- Involved:
  - `IOS26-FLAGSHIP` — `docs/codex/IOS26_FLAGSHIP_TRAIN_MANIFEST.yml` (partial_implementation; release proof)
  - `AMB-INTELLIGENCE-CONSOLIDATION-CHAMPION-SELECTION-01` — `prompts/batches/AMB-INTELLIGENCE-CONSOLIDATION-CHAMPION-SELECTION-01.md` (partial_implementation; release proof)

### 204. Same source file targeted by multiple active items: scripts/ios26-plan-freeze.py

- Conflict ID: `AMB28-same_source_file_targeted_by_multiple_active_batches-95219888`
- Type: `same_source_file_targeted_by_multiple_active_batches`
- Severity: `yellow`
- Recommended action: `merge`
- Rationale: Multiple active ledger items reference the same source file; merge, sequence, or assign ownership before implementation.
- Linear issue ready: `True`
- Auto-resolved: `False`
- Involved:
  - `IOS26_BATCH_MATRIX` — `docs/codex/ios26/IOS26_BATCH_MATRIX.yml` (partial_implementation; release proof)
  - `IOS26_DEPENDENCY_GRAPH` — `docs/codex/ios26/IOS26_DEPENDENCY_GRAPH.yml` (partial_implementation; source-only)

### 205. Same source file targeted by multiple active items: scripts/ldi-gate-check.sh

- Conflict ID: `AMB28-same_source_file_targeted_by_multiple_active_batches-53667918`
- Type: `same_source_file_targeted_by_multiple_active_batches`
- Severity: `yellow`
- Recommended action: `merge`
- Rationale: Multiple active ledger items reference the same source file; merge, sequence, or assign ownership before implementation.
- Linear issue ready: `True`
- Auto-resolved: `False`
- Involved:
  - `LDI01_Living_Dream_Architecture_Source_Truth_Prompt` — `docs/codex/batches/LDI01_Living_Dream_Architecture_Source_Truth_Prompt.md` (partial_implementation; release proof)
  - `LDI02_Capture_Handling_Ladder_Prompt` — `docs/codex/batches/LDI02_Capture_Handling_Ladder_Prompt.md` (partial_implementation; release proof)
  - `LDI03_Dream_Safety_Legality_Feasibility_Triage_Prompt` — `docs/codex/batches/LDI03_Dream_Safety_Legality_Feasibility_Triage_Prompt.md` (partial_implementation; release proof)
  - `LDI04_North_Star_Extraction_Prompt` — `docs/codex/batches/LDI04_North_Star_Extraction_Prompt.md` (partial_implementation; release proof)
  - `LDI05_Source_Claim_Graph_Prompt` — `docs/codex/batches/LDI05_Source_Claim_Graph_Prompt.md` (partial_implementation; release proof)
  - `LDI06_Pack_Registry_And_Pack_Compiler_Prompt` — `docs/codex/batches/LDI06_Pack_Registry_And_Pack_Compiler_Prompt.md` (partial_implementation; release proof)
  - `LDI07_Pack_Supply_Chain_Security_Prompt` — `docs/codex/batches/LDI07_Pack_Supply_Chain_Security_Prompt.md` (partial_implementation; release proof)
  - `LDI08_Requirement_Graph_Runtime_Prompt` — `docs/codex/batches/LDI08_Requirement_Graph_Runtime_Prompt.md` (partial_implementation; release proof)
  - `LDI09_Eligibility_And_Deadline_Runtime_Prompt` — `docs/codex/batches/LDI09_Eligibility_And_Deadline_Runtime_Prompt.md` (partial_implementation; release proof)
  - `LDI10_Starting_Position_And_Privacy_Intake_Prompt` — `docs/codex/batches/LDI10_Starting_Position_And_Privacy_Intake_Prompt.md` (partial_implementation; release proof)
  - `LDI11_Path_Portfolio_Runtime_Prompt` — `docs/codex/batches/LDI11_Path_Portfolio_Runtime_Prompt.md` (partial_implementation; release proof)
  - `LDI12_Capacity_And_Commitment_Time_Bridge_Prompt` — `docs/codex/batches/LDI12_Capacity_And_Commitment_Time_Bridge_Prompt.md` (partial_implementation; release proof)
  - `LDI13_Today_Bridge_And_Action_Closure_Prompt` — `docs/codex/batches/LDI13_Today_Bridge_And_Action_Closure_Prompt.md` (partial_implementation; release proof)
  - `LDI14_Trust_Review_And_Dream_Handling_Receipts_Prompt` — `docs/codex/batches/LDI14_Trust_Review_And_Dream_Handling_Receipts_Prompt.md` (partial_implementation; release proof)
  - `LDI15_Living_Plan_Recompiler_Prompt` — `docs/codex/batches/LDI15_Living_Plan_Recompiler_Prompt.md` (partial_implementation; release proof)
  - `LDI16_Mutation_Permissions_And_Impact_Levels_Prompt` — `docs/codex/batches/LDI16_Mutation_Permissions_And_Impact_Levels_Prompt.md` (partial_implementation; release proof)
  - `LDI17_Continuity_Sync_Prompt` — `docs/codex/batches/LDI17_Continuity_Sync_Prompt.md` (partial_implementation; release proof)
  - `LDI18_Archive_And_Schema_Migration_Prompt` — `docs/codex/batches/LDI18_Archive_And_Schema_Migration_Prompt.md` (partial_implementation; release proof)
  - `LDI19_Multi_Device_Merge_Ledger_Prompt` — `docs/codex/batches/LDI19_Multi_Device_Merge_Ledger_Prompt.md` (partial_implementation; release proof)
  - `LDI20_Freshness_Broker_Prompt` — `docs/codex/batches/LDI20_Freshness_Broker_Prompt.md` (partial_implementation; release proof)
  - `LDI21_Red_Team_Evaluation_Suite_Prompt` — `docs/codex/batches/LDI21_Red_Team_Evaluation_Suite_Prompt.md` (partial_implementation; release proof)
  - `LDI22_Governance_And_Maintenance_Console_Prompt` — `docs/codex/batches/LDI22_Governance_And_Maintenance_Console_Prompt.md` (partial_implementation; release proof)

### 206. Same source file targeted by multiple active items: scripts/ldi-handling-lane-scan.sh

- Conflict ID: `AMB28-same_source_file_targeted_by_multiple_active_batches-59558215`
- Type: `same_source_file_targeted_by_multiple_active_batches`
- Severity: `yellow`
- Recommended action: `merge`
- Rationale: Multiple active ledger items reference the same source file; merge, sequence, or assign ownership before implementation.
- Linear issue ready: `True`
- Auto-resolved: `False`
- Involved:
  - `LDI01_Living_Dream_Architecture_Source_Truth_Prompt` — `docs/codex/batches/LDI01_Living_Dream_Architecture_Source_Truth_Prompt.md` (partial_implementation; release proof)
  - `LDI02_Capture_Handling_Ladder_Prompt` — `docs/codex/batches/LDI02_Capture_Handling_Ladder_Prompt.md` (partial_implementation; release proof)
  - `LDI03_Dream_Safety_Legality_Feasibility_Triage_Prompt` — `docs/codex/batches/LDI03_Dream_Safety_Legality_Feasibility_Triage_Prompt.md` (partial_implementation; release proof)
  - `LDI04_North_Star_Extraction_Prompt` — `docs/codex/batches/LDI04_North_Star_Extraction_Prompt.md` (partial_implementation; release proof)
  - `LDI05_Source_Claim_Graph_Prompt` — `docs/codex/batches/LDI05_Source_Claim_Graph_Prompt.md` (partial_implementation; release proof)
  - `LDI06_Pack_Registry_And_Pack_Compiler_Prompt` — `docs/codex/batches/LDI06_Pack_Registry_And_Pack_Compiler_Prompt.md` (partial_implementation; release proof)
  - `LDI07_Pack_Supply_Chain_Security_Prompt` — `docs/codex/batches/LDI07_Pack_Supply_Chain_Security_Prompt.md` (partial_implementation; release proof)
  - `LDI08_Requirement_Graph_Runtime_Prompt` — `docs/codex/batches/LDI08_Requirement_Graph_Runtime_Prompt.md` (partial_implementation; release proof)
  - `LDI09_Eligibility_And_Deadline_Runtime_Prompt` — `docs/codex/batches/LDI09_Eligibility_And_Deadline_Runtime_Prompt.md` (partial_implementation; release proof)
  - `LDI10_Starting_Position_And_Privacy_Intake_Prompt` — `docs/codex/batches/LDI10_Starting_Position_And_Privacy_Intake_Prompt.md` (partial_implementation; release proof)
  - `LDI11_Path_Portfolio_Runtime_Prompt` — `docs/codex/batches/LDI11_Path_Portfolio_Runtime_Prompt.md` (partial_implementation; release proof)
  - `LDI12_Capacity_And_Commitment_Time_Bridge_Prompt` — `docs/codex/batches/LDI12_Capacity_And_Commitment_Time_Bridge_Prompt.md` (partial_implementation; release proof)
  - `LDI13_Today_Bridge_And_Action_Closure_Prompt` — `docs/codex/batches/LDI13_Today_Bridge_And_Action_Closure_Prompt.md` (partial_implementation; release proof)
  - `LDI14_Trust_Review_And_Dream_Handling_Receipts_Prompt` — `docs/codex/batches/LDI14_Trust_Review_And_Dream_Handling_Receipts_Prompt.md` (partial_implementation; release proof)
  - `LDI15_Living_Plan_Recompiler_Prompt` — `docs/codex/batches/LDI15_Living_Plan_Recompiler_Prompt.md` (partial_implementation; release proof)
  - `LDI16_Mutation_Permissions_And_Impact_Levels_Prompt` — `docs/codex/batches/LDI16_Mutation_Permissions_And_Impact_Levels_Prompt.md` (partial_implementation; release proof)
  - `LDI17_Continuity_Sync_Prompt` — `docs/codex/batches/LDI17_Continuity_Sync_Prompt.md` (partial_implementation; release proof)
  - `LDI18_Archive_And_Schema_Migration_Prompt` — `docs/codex/batches/LDI18_Archive_And_Schema_Migration_Prompt.md` (partial_implementation; release proof)
  - `LDI19_Multi_Device_Merge_Ledger_Prompt` — `docs/codex/batches/LDI19_Multi_Device_Merge_Ledger_Prompt.md` (partial_implementation; release proof)
  - `LDI20_Freshness_Broker_Prompt` — `docs/codex/batches/LDI20_Freshness_Broker_Prompt.md` (partial_implementation; release proof)
  - `LDI21_Red_Team_Evaluation_Suite_Prompt` — `docs/codex/batches/LDI21_Red_Team_Evaluation_Suite_Prompt.md` (partial_implementation; release proof)
  - `LDI22_Governance_And_Maintenance_Console_Prompt` — `docs/codex/batches/LDI22_Governance_And_Maintenance_Console_Prompt.md` (partial_implementation; release proof)

### 207. Same source file targeted by multiple active items: scripts/ldi-pack-supply-chain-scan.py

- Conflict ID: `AMB28-same_source_file_targeted_by_multiple_active_batches-2442266`
- Type: `same_source_file_targeted_by_multiple_active_batches`
- Severity: `yellow`
- Recommended action: `merge`
- Rationale: Multiple active ledger items reference the same source file; merge, sequence, or assign ownership before implementation.
- Linear issue ready: `True`
- Auto-resolved: `False`
- Involved:
  - `LDI01_Living_Dream_Architecture_Source_Truth_Prompt` — `docs/codex/batches/LDI01_Living_Dream_Architecture_Source_Truth_Prompt.md` (partial_implementation; release proof)
  - `LDI02_Capture_Handling_Ladder_Prompt` — `docs/codex/batches/LDI02_Capture_Handling_Ladder_Prompt.md` (partial_implementation; release proof)
  - `LDI03_Dream_Safety_Legality_Feasibility_Triage_Prompt` — `docs/codex/batches/LDI03_Dream_Safety_Legality_Feasibility_Triage_Prompt.md` (partial_implementation; release proof)
  - `LDI04_North_Star_Extraction_Prompt` — `docs/codex/batches/LDI04_North_Star_Extraction_Prompt.md` (partial_implementation; release proof)
  - `LDI05_Source_Claim_Graph_Prompt` — `docs/codex/batches/LDI05_Source_Claim_Graph_Prompt.md` (partial_implementation; release proof)
  - `LDI06_Pack_Registry_And_Pack_Compiler_Prompt` — `docs/codex/batches/LDI06_Pack_Registry_And_Pack_Compiler_Prompt.md` (partial_implementation; release proof)
  - `LDI07_Pack_Supply_Chain_Security_Prompt` — `docs/codex/batches/LDI07_Pack_Supply_Chain_Security_Prompt.md` (partial_implementation; release proof)
  - `LDI08_Requirement_Graph_Runtime_Prompt` — `docs/codex/batches/LDI08_Requirement_Graph_Runtime_Prompt.md` (partial_implementation; release proof)
  - `LDI09_Eligibility_And_Deadline_Runtime_Prompt` — `docs/codex/batches/LDI09_Eligibility_And_Deadline_Runtime_Prompt.md` (partial_implementation; release proof)
  - `LDI10_Starting_Position_And_Privacy_Intake_Prompt` — `docs/codex/batches/LDI10_Starting_Position_And_Privacy_Intake_Prompt.md` (partial_implementation; release proof)
  - `LDI11_Path_Portfolio_Runtime_Prompt` — `docs/codex/batches/LDI11_Path_Portfolio_Runtime_Prompt.md` (partial_implementation; release proof)
  - `LDI12_Capacity_And_Commitment_Time_Bridge_Prompt` — `docs/codex/batches/LDI12_Capacity_And_Commitment_Time_Bridge_Prompt.md` (partial_implementation; release proof)
  - `LDI13_Today_Bridge_And_Action_Closure_Prompt` — `docs/codex/batches/LDI13_Today_Bridge_And_Action_Closure_Prompt.md` (partial_implementation; release proof)
  - `LDI14_Trust_Review_And_Dream_Handling_Receipts_Prompt` — `docs/codex/batches/LDI14_Trust_Review_And_Dream_Handling_Receipts_Prompt.md` (partial_implementation; release proof)
  - `LDI15_Living_Plan_Recompiler_Prompt` — `docs/codex/batches/LDI15_Living_Plan_Recompiler_Prompt.md` (partial_implementation; release proof)
  - `LDI16_Mutation_Permissions_And_Impact_Levels_Prompt` — `docs/codex/batches/LDI16_Mutation_Permissions_And_Impact_Levels_Prompt.md` (partial_implementation; release proof)
  - `LDI17_Continuity_Sync_Prompt` — `docs/codex/batches/LDI17_Continuity_Sync_Prompt.md` (partial_implementation; release proof)
  - `LDI18_Archive_And_Schema_Migration_Prompt` — `docs/codex/batches/LDI18_Archive_And_Schema_Migration_Prompt.md` (partial_implementation; release proof)
  - `LDI19_Multi_Device_Merge_Ledger_Prompt` — `docs/codex/batches/LDI19_Multi_Device_Merge_Ledger_Prompt.md` (partial_implementation; release proof)
  - `LDI20_Freshness_Broker_Prompt` — `docs/codex/batches/LDI20_Freshness_Broker_Prompt.md` (partial_implementation; release proof)
  - `LDI21_Red_Team_Evaluation_Suite_Prompt` — `docs/codex/batches/LDI21_Red_Team_Evaluation_Suite_Prompt.md` (partial_implementation; release proof)
  - `LDI22_Governance_And_Maintenance_Console_Prompt` — `docs/codex/batches/LDI22_Governance_And_Maintenance_Console_Prompt.md` (partial_implementation; release proof)

### 208. Same source file targeted by multiple active items: scripts/ldi-release-claim-scan.sh

- Conflict ID: `AMB28-same_source_file_targeted_by_multiple_active_batches-10409359`
- Type: `same_source_file_targeted_by_multiple_active_batches`
- Severity: `yellow`
- Recommended action: `merge`
- Rationale: Multiple active ledger items reference the same source file; merge, sequence, or assign ownership before implementation.
- Linear issue ready: `True`
- Auto-resolved: `False`
- Involved:
  - `LDI01_Living_Dream_Architecture_Source_Truth_Prompt` — `docs/codex/batches/LDI01_Living_Dream_Architecture_Source_Truth_Prompt.md` (partial_implementation; release proof)
  - `LDI02_Capture_Handling_Ladder_Prompt` — `docs/codex/batches/LDI02_Capture_Handling_Ladder_Prompt.md` (partial_implementation; release proof)
  - `LDI03_Dream_Safety_Legality_Feasibility_Triage_Prompt` — `docs/codex/batches/LDI03_Dream_Safety_Legality_Feasibility_Triage_Prompt.md` (partial_implementation; release proof)
  - `LDI04_North_Star_Extraction_Prompt` — `docs/codex/batches/LDI04_North_Star_Extraction_Prompt.md` (partial_implementation; release proof)
  - `LDI05_Source_Claim_Graph_Prompt` — `docs/codex/batches/LDI05_Source_Claim_Graph_Prompt.md` (partial_implementation; release proof)
  - `LDI06_Pack_Registry_And_Pack_Compiler_Prompt` — `docs/codex/batches/LDI06_Pack_Registry_And_Pack_Compiler_Prompt.md` (partial_implementation; release proof)
  - `LDI07_Pack_Supply_Chain_Security_Prompt` — `docs/codex/batches/LDI07_Pack_Supply_Chain_Security_Prompt.md` (partial_implementation; release proof)
  - `LDI08_Requirement_Graph_Runtime_Prompt` — `docs/codex/batches/LDI08_Requirement_Graph_Runtime_Prompt.md` (partial_implementation; release proof)
  - `LDI09_Eligibility_And_Deadline_Runtime_Prompt` — `docs/codex/batches/LDI09_Eligibility_And_Deadline_Runtime_Prompt.md` (partial_implementation; release proof)
  - `LDI10_Starting_Position_And_Privacy_Intake_Prompt` — `docs/codex/batches/LDI10_Starting_Position_And_Privacy_Intake_Prompt.md` (partial_implementation; release proof)
  - `LDI11_Path_Portfolio_Runtime_Prompt` — `docs/codex/batches/LDI11_Path_Portfolio_Runtime_Prompt.md` (partial_implementation; release proof)
  - `LDI12_Capacity_And_Commitment_Time_Bridge_Prompt` — `docs/codex/batches/LDI12_Capacity_And_Commitment_Time_Bridge_Prompt.md` (partial_implementation; release proof)
  - `LDI13_Today_Bridge_And_Action_Closure_Prompt` — `docs/codex/batches/LDI13_Today_Bridge_And_Action_Closure_Prompt.md` (partial_implementation; release proof)
  - `LDI14_Trust_Review_And_Dream_Handling_Receipts_Prompt` — `docs/codex/batches/LDI14_Trust_Review_And_Dream_Handling_Receipts_Prompt.md` (partial_implementation; release proof)
  - `LDI15_Living_Plan_Recompiler_Prompt` — `docs/codex/batches/LDI15_Living_Plan_Recompiler_Prompt.md` (partial_implementation; release proof)
  - `LDI16_Mutation_Permissions_And_Impact_Levels_Prompt` — `docs/codex/batches/LDI16_Mutation_Permissions_And_Impact_Levels_Prompt.md` (partial_implementation; release proof)
  - `LDI17_Continuity_Sync_Prompt` — `docs/codex/batches/LDI17_Continuity_Sync_Prompt.md` (partial_implementation; release proof)
  - `LDI18_Archive_And_Schema_Migration_Prompt` — `docs/codex/batches/LDI18_Archive_And_Schema_Migration_Prompt.md` (partial_implementation; release proof)
  - `LDI19_Multi_Device_Merge_Ledger_Prompt` — `docs/codex/batches/LDI19_Multi_Device_Merge_Ledger_Prompt.md` (partial_implementation; release proof)
  - `LDI20_Freshness_Broker_Prompt` — `docs/codex/batches/LDI20_Freshness_Broker_Prompt.md` (partial_implementation; release proof)
  - `LDI21_Red_Team_Evaluation_Suite_Prompt` — `docs/codex/batches/LDI21_Red_Team_Evaluation_Suite_Prompt.md` (partial_implementation; release proof)
  - `LDI22_Governance_And_Maintenance_Console_Prompt` — `docs/codex/batches/LDI22_Governance_And_Maintenance_Console_Prompt.md` (partial_implementation; release proof)

### 209. Same source file targeted by multiple active items: scripts/ldi-safety-redteam-fixture-check.py

- Conflict ID: `AMB28-same_source_file_targeted_by_multiple_active_batches-73068911`
- Type: `same_source_file_targeted_by_multiple_active_batches`
- Severity: `yellow`
- Recommended action: `merge`
- Rationale: Multiple active ledger items reference the same source file; merge, sequence, or assign ownership before implementation.
- Linear issue ready: `True`
- Auto-resolved: `False`
- Involved:
  - `LDI01_Living_Dream_Architecture_Source_Truth_Prompt` — `docs/codex/batches/LDI01_Living_Dream_Architecture_Source_Truth_Prompt.md` (partial_implementation; release proof)
  - `LDI02_Capture_Handling_Ladder_Prompt` — `docs/codex/batches/LDI02_Capture_Handling_Ladder_Prompt.md` (partial_implementation; release proof)
  - `LDI03_Dream_Safety_Legality_Feasibility_Triage_Prompt` — `docs/codex/batches/LDI03_Dream_Safety_Legality_Feasibility_Triage_Prompt.md` (partial_implementation; release proof)
  - `LDI04_North_Star_Extraction_Prompt` — `docs/codex/batches/LDI04_North_Star_Extraction_Prompt.md` (partial_implementation; release proof)
  - `LDI05_Source_Claim_Graph_Prompt` — `docs/codex/batches/LDI05_Source_Claim_Graph_Prompt.md` (partial_implementation; release proof)
  - `LDI06_Pack_Registry_And_Pack_Compiler_Prompt` — `docs/codex/batches/LDI06_Pack_Registry_And_Pack_Compiler_Prompt.md` (partial_implementation; release proof)
  - `LDI07_Pack_Supply_Chain_Security_Prompt` — `docs/codex/batches/LDI07_Pack_Supply_Chain_Security_Prompt.md` (partial_implementation; release proof)
  - `LDI08_Requirement_Graph_Runtime_Prompt` — `docs/codex/batches/LDI08_Requirement_Graph_Runtime_Prompt.md` (partial_implementation; release proof)
  - `LDI09_Eligibility_And_Deadline_Runtime_Prompt` — `docs/codex/batches/LDI09_Eligibility_And_Deadline_Runtime_Prompt.md` (partial_implementation; release proof)
  - `LDI10_Starting_Position_And_Privacy_Intake_Prompt` — `docs/codex/batches/LDI10_Starting_Position_And_Privacy_Intake_Prompt.md` (partial_implementation; release proof)
  - `LDI11_Path_Portfolio_Runtime_Prompt` — `docs/codex/batches/LDI11_Path_Portfolio_Runtime_Prompt.md` (partial_implementation; release proof)
  - `LDI12_Capacity_And_Commitment_Time_Bridge_Prompt` — `docs/codex/batches/LDI12_Capacity_And_Commitment_Time_Bridge_Prompt.md` (partial_implementation; release proof)
  - `LDI13_Today_Bridge_And_Action_Closure_Prompt` — `docs/codex/batches/LDI13_Today_Bridge_And_Action_Closure_Prompt.md` (partial_implementation; release proof)
  - `LDI14_Trust_Review_And_Dream_Handling_Receipts_Prompt` — `docs/codex/batches/LDI14_Trust_Review_And_Dream_Handling_Receipts_Prompt.md` (partial_implementation; release proof)
  - `LDI15_Living_Plan_Recompiler_Prompt` — `docs/codex/batches/LDI15_Living_Plan_Recompiler_Prompt.md` (partial_implementation; release proof)
  - `LDI16_Mutation_Permissions_And_Impact_Levels_Prompt` — `docs/codex/batches/LDI16_Mutation_Permissions_And_Impact_Levels_Prompt.md` (partial_implementation; release proof)
  - `LDI17_Continuity_Sync_Prompt` — `docs/codex/batches/LDI17_Continuity_Sync_Prompt.md` (partial_implementation; release proof)
  - `LDI18_Archive_And_Schema_Migration_Prompt` — `docs/codex/batches/LDI18_Archive_And_Schema_Migration_Prompt.md` (partial_implementation; release proof)
  - `LDI19_Multi_Device_Merge_Ledger_Prompt` — `docs/codex/batches/LDI19_Multi_Device_Merge_Ledger_Prompt.md` (partial_implementation; release proof)
  - `LDI20_Freshness_Broker_Prompt` — `docs/codex/batches/LDI20_Freshness_Broker_Prompt.md` (partial_implementation; release proof)
  - `LDI21_Red_Team_Evaluation_Suite_Prompt` — `docs/codex/batches/LDI21_Red_Team_Evaluation_Suite_Prompt.md` (partial_implementation; release proof)
  - `LDI22_Governance_And_Maintenance_Console_Prompt` — `docs/codex/batches/LDI22_Governance_And_Maintenance_Console_Prompt.md` (partial_implementation; release proof)

### 210. Same source file targeted by multiple active items: scripts/ldi-source-pack-schema-check.py

- Conflict ID: `AMB28-same_source_file_targeted_by_multiple_active_batches-27041226`
- Type: `same_source_file_targeted_by_multiple_active_batches`
- Severity: `yellow`
- Recommended action: `merge`
- Rationale: Multiple active ledger items reference the same source file; merge, sequence, or assign ownership before implementation.
- Linear issue ready: `True`
- Auto-resolved: `False`
- Involved:
  - `LDI01_Living_Dream_Architecture_Source_Truth_Prompt` — `docs/codex/batches/LDI01_Living_Dream_Architecture_Source_Truth_Prompt.md` (partial_implementation; release proof)
  - `LDI02_Capture_Handling_Ladder_Prompt` — `docs/codex/batches/LDI02_Capture_Handling_Ladder_Prompt.md` (partial_implementation; release proof)
  - `LDI03_Dream_Safety_Legality_Feasibility_Triage_Prompt` — `docs/codex/batches/LDI03_Dream_Safety_Legality_Feasibility_Triage_Prompt.md` (partial_implementation; release proof)
  - `LDI04_North_Star_Extraction_Prompt` — `docs/codex/batches/LDI04_North_Star_Extraction_Prompt.md` (partial_implementation; release proof)
  - `LDI05_Source_Claim_Graph_Prompt` — `docs/codex/batches/LDI05_Source_Claim_Graph_Prompt.md` (partial_implementation; release proof)
  - `LDI06_Pack_Registry_And_Pack_Compiler_Prompt` — `docs/codex/batches/LDI06_Pack_Registry_And_Pack_Compiler_Prompt.md` (partial_implementation; release proof)
  - `LDI07_Pack_Supply_Chain_Security_Prompt` — `docs/codex/batches/LDI07_Pack_Supply_Chain_Security_Prompt.md` (partial_implementation; release proof)
  - `LDI08_Requirement_Graph_Runtime_Prompt` — `docs/codex/batches/LDI08_Requirement_Graph_Runtime_Prompt.md` (partial_implementation; release proof)
  - `LDI09_Eligibility_And_Deadline_Runtime_Prompt` — `docs/codex/batches/LDI09_Eligibility_And_Deadline_Runtime_Prompt.md` (partial_implementation; release proof)
  - `LDI10_Starting_Position_And_Privacy_Intake_Prompt` — `docs/codex/batches/LDI10_Starting_Position_And_Privacy_Intake_Prompt.md` (partial_implementation; release proof)
  - `LDI11_Path_Portfolio_Runtime_Prompt` — `docs/codex/batches/LDI11_Path_Portfolio_Runtime_Prompt.md` (partial_implementation; release proof)
  - `LDI12_Capacity_And_Commitment_Time_Bridge_Prompt` — `docs/codex/batches/LDI12_Capacity_And_Commitment_Time_Bridge_Prompt.md` (partial_implementation; release proof)
  - `LDI13_Today_Bridge_And_Action_Closure_Prompt` — `docs/codex/batches/LDI13_Today_Bridge_And_Action_Closure_Prompt.md` (partial_implementation; release proof)
  - `LDI14_Trust_Review_And_Dream_Handling_Receipts_Prompt` — `docs/codex/batches/LDI14_Trust_Review_And_Dream_Handling_Receipts_Prompt.md` (partial_implementation; release proof)
  - `LDI15_Living_Plan_Recompiler_Prompt` — `docs/codex/batches/LDI15_Living_Plan_Recompiler_Prompt.md` (partial_implementation; release proof)
  - `LDI16_Mutation_Permissions_And_Impact_Levels_Prompt` — `docs/codex/batches/LDI16_Mutation_Permissions_And_Impact_Levels_Prompt.md` (partial_implementation; release proof)
  - `LDI17_Continuity_Sync_Prompt` — `docs/codex/batches/LDI17_Continuity_Sync_Prompt.md` (partial_implementation; release proof)
  - `LDI18_Archive_And_Schema_Migration_Prompt` — `docs/codex/batches/LDI18_Archive_And_Schema_Migration_Prompt.md` (partial_implementation; release proof)
  - `LDI19_Multi_Device_Merge_Ledger_Prompt` — `docs/codex/batches/LDI19_Multi_Device_Merge_Ledger_Prompt.md` (partial_implementation; release proof)
  - `LDI20_Freshness_Broker_Prompt` — `docs/codex/batches/LDI20_Freshness_Broker_Prompt.md` (partial_implementation; release proof)
  - `LDI21_Red_Team_Evaluation_Suite_Prompt` — `docs/codex/batches/LDI21_Red_Team_Evaluation_Suite_Prompt.md` (partial_implementation; release proof)
  - `LDI22_Governance_And_Maintenance_Console_Prompt` — `docs/codex/batches/LDI22_Governance_And_Maintenance_Console_Prompt.md` (partial_implementation; release proof)

### 211. Same source file targeted by multiple active items: scripts/openai-build-suite-dry-run.py

- Conflict ID: `AMB28-same_source_file_targeted_by_multiple_active_batches-13983220`
- Type: `same_source_file_targeted_by_multiple_active_batches`
- Severity: `yellow`
- Recommended action: `merge`
- Rationale: Multiple active ledger items reference the same source file; merge, sequence, or assign ownership before implementation.
- Linear issue ready: `True`
- Auto-resolved: `False`
- Involved:
  - `OBS00-OPENAI-BUILD-SUITE-INSTALL` — `prompts/batches/OBS00-OPENAI-BUILD-SUITE-INSTALL.md` (partial_implementation; release proof)
  - `OBS06-SPEED-TRAIN-INTEGRATION` — `prompts/batches/OBS06-SPEED-TRAIN-INTEGRATION.md` (partial_implementation; release proof)
  - `CODEX_MULTI_AGENT_BUILD_SYSTEM` — `docs/codex/CODEX_MULTI_AGENT_BUILD_SYSTEM.md` (unknown; release proof)

### 212. Same source file targeted by multiple active items: scripts/openai-build-suite-validate.py

- Conflict ID: `AMB28-same_source_file_targeted_by_multiple_active_batches-93530225`
- Type: `same_source_file_targeted_by_multiple_active_batches`
- Severity: `yellow`
- Recommended action: `merge`
- Rationale: Multiple active ledger items reference the same source file; merge, sequence, or assign ownership before implementation.
- Linear issue ready: `True`
- Auto-resolved: `False`
- Involved:
  - `OBS00-OPENAI-BUILD-SUITE-INSTALL` — `prompts/batches/OBS00-OPENAI-BUILD-SUITE-INSTALL.md` (partial_implementation; release proof)
  - `OBS01-CODEX-MULTI-AGENT-BUILD-SYSTEM` — `prompts/batches/OBS01-CODEX-MULTI-AGENT-BUILD-SYSTEM.md` (partial_implementation; release proof)
  - `OBS02-REPO-INTELLIGENCE-LAYER` — `prompts/batches/OBS02-REPO-INTELLIGENCE-LAYER.md` (partial_implementation; release proof)
  - `OBS03-OPENAI-EVAL-QA-LAYER` — `prompts/batches/OBS03-OPENAI-EVAL-QA-LAYER.md` (partial_implementation; release proof)
  - `OBS06-SPEED-TRAIN-INTEGRATION` — `prompts/batches/OBS06-SPEED-TRAIN-INTEGRATION.md` (partial_implementation; release proof)
  - `CODEX_MULTI_AGENT_BUILD_SYSTEM` — `docs/codex/CODEX_MULTI_AGENT_BUILD_SYSTEM.md` (unknown; release proof)
  - `OPENAI_BUILD_SUITE_USAGE_POLICY` — `docs/codex/OPENAI_BUILD_SUITE_USAGE_POLICY.md` (unknown; release proof)

### 213. Same source file targeted by multiple active items: scripts/run-doc-qa.sh

- Conflict ID: `AMB28-same_source_file_targeted_by_multiple_active_batches-644983`
- Type: `same_source_file_targeted_by_multiple_active_batches`
- Severity: `yellow`
- Recommended action: `merge`
- Rationale: Multiple active ledger items reference the same source file; merge, sequence, or assign ownership before implementation.
- Linear issue ready: `True`
- Auto-resolved: `False`
- Involved:
  - `AMBITIONS_3_0_CONTEXT_LOADING_AND_TASK_ROUTING` — `docs/codex/AMBITIONS_3_0_CONTEXT_LOADING_AND_TASK_ROUTING.md` (partial_implementation; release proof)
  - `GLOBAL_BATCH_AUTOMATED_GATE_PROTOCOL` — `docs/codex/GLOBAL_BATCH_AUTOMATED_GATE_PROTOCOL.md` (partial_implementation; release proof)
  - `REC01_Release_Evidence_Truth_Inventory_Prompt` — `docs/codex/batches/REC01_Release_Evidence_Truth_Inventory_Prompt.md` (partial_implementation; release proof)
  - `REC02_Human_Operator_Release_Proof_Plan_Prompt` — `docs/codex/batches/REC02_Human_Operator_Release_Proof_Plan_Prompt.md` (partial_implementation; release proof)
  - `REC03_Validation_Log_Ledger_Closure_Prompt` — `docs/codex/batches/REC03_Validation_Log_Ledger_Closure_Prompt.md` (partial_implementation; release proof)
  - `REC04_Release_Claim_Copy_Guard_Prompt` — `docs/codex/batches/REC04_Release_Claim_Copy_Guard_Prompt.md` (partial_implementation; release proof)
  - `REC05_Human_Review_Packet_Prompt` — `docs/codex/batches/REC05_Human_Review_Packet_Prompt.md` (partial_implementation; release proof)
  - `REC06_Release_Evidence_Closure_Handoff_Prompt` — `docs/codex/batches/REC06_Release_Evidence_Closure_Handoff_Prompt.md` (partial_implementation; release proof)
  - `SI01_Signature_Interface_Canon_To_SwiftUI_Architecture_Prompt` — `docs/codex/batches/SI01_Signature_Interface_Canon_To_SwiftUI_Architecture_Prompt.md` (partial_implementation; release proof)
  - `SI02_Adaptive_Panel_Action_And_Module_Foundation_Prompt` — `docs/codex/batches/SI02_Adaptive_Panel_Action_And_Module_Foundation_Prompt.md` (partial_implementation; release proof)
  - `SI03_App_Shell_IA_And_Navigation_List_System_Prompt` — `docs/codex/batches/SI03_App_Shell_IA_And_Navigation_List_System_Prompt.md` (partial_implementation; release proof)
  - `SI04_DayTimelineRail_2_0_Prompt` — `docs/codex/batches/SI04_DayTimelineRail_2_0_Prompt.md` (partial_implementation; release proof)
  - `SI06_LifePath_Visualization_System_Prompt` — `docs/codex/batches/SI06_LifePath_Visualization_System_Prompt.md` (partial_implementation; release proof)
  - `SI07_Mission_Control_Lane_Components_Prompt` — `docs/codex/batches/SI07_Mission_Control_Lane_Components_Prompt.md` (partial_implementation; release proof)
  - `SI08_LifeShape_Time_Capacity_Map_Prompt` — `docs/codex/batches/SI08_LifeShape_Time_Capacity_Map_Prompt.md` (partial_implementation; release proof)
  - `SI09_Capture_Atmosphere_Composer_Prompt` — `docs/codex/batches/SI09_Capture_Atmosphere_Composer_Prompt.md` (partial_implementation; release proof)
  - `SI10_Trust_Receipt_Layer_Prompt` — `docs/codex/batches/SI10_Trust_Receipt_Layer_Prompt.md` (partial_implementation; release proof)
  - `SI11_Personal_System_Center_Components_Prompt` — `docs/codex/batches/SI11_Personal_System_Center_Components_Prompt.md` (partial_implementation; release proof)
  - `SI12_Interaction_Motion_Haptics_System_Prompt` — `docs/codex/batches/SI12_Interaction_Motion_Haptics_System_Prompt.md` (partial_implementation; release proof)
  - `SI13_Loading_Empty_Degraded_State_Primitives_Prompt` — `docs/codex/batches/SI13_Loading_Empty_Degraded_State_Primitives_Prompt.md` (partial_implementation; release proof)
  - `SI14_Iconography_Symbol_And_Status_Grammar_Prompt` — `docs/codex/batches/SI14_Iconography_Symbol_And_Status_Grammar_Prompt.md` (partial_implementation; release proof)
  - `SI15_Accessibility_Adaptive_Interface_Pass_Prompt` — `docs/codex/batches/SI15_Accessibility_Adaptive_Interface_Pass_Prompt.md` (partial_implementation; release proof)
  - `SI16_Preview_Fixture_And_Visual_QA_Infrastructure_Prompt` — `docs/codex/batches/SI16_Preview_Fixture_And_Visual_QA_Infrastructure_Prompt.md` (partial_implementation; release proof)
  - `SI18_Signature_Interface_Handoff_And_Product_Depth_Readiness_Prompt` — `docs/codex/batches/SI18_Signature_Interface_Handoff_And_Product_Depth_Readiness_Prompt.md` (partial_implementation; release proof)
  - `EB01_External_Brain_Source_Truth_And_Kernel_Architecture_Prompt` — `docs/codex/batches/EB01_External_Brain_Source_Truth_And_Kernel_Architecture_Prompt.md` (partial_implementation; release proof)
  - `EB02_Universal_Capture_Canon_And_Domain_Model_Prompt` — `docs/codex/batches/EB02_Universal_Capture_Canon_And_Domain_Model_Prompt.md` (partial_implementation; release proof)
  - `EB03_Universal_Capture_Composer_And_Routing_Prompt` — `docs/codex/batches/EB03_Universal_Capture_Composer_And_Routing_Prompt.md` (partial_implementation; release proof)
  - `EB04_Capture_Classification_And_Clarification_Prompt` — `docs/codex/batches/EB04_Capture_Classification_And_Clarification_Prompt.md` (partial_implementation; release proof)
  - `EB05_Capture_Clusters_Review_Bundles_And_Open_Loops_Prompt` — `docs/codex/batches/EB05_Capture_Clusters_Review_Bundles_And_Open_Loops_Prompt.md` (partial_implementation; release proof)
  - `EB06_Capture_Receipts_Undo_And_Reclassification_Prompt` — `docs/codex/batches/EB06_Capture_Receipts_Undo_And_Reclassification_Prompt.md` (partial_implementation; release proof)
  - ... 82 more

### 214. Same source file targeted by multiple active items: scripts/sa-composition-projection-scan.sh

- Conflict ID: `AMB28-same_source_file_targeted_by_multiple_active_batches-43824590`
- Type: `same_source_file_targeted_by_multiple_active_batches`
- Severity: `yellow`
- Recommended action: `merge`
- Rationale: Multiple active ledger items reference the same source file; merge, sequence, or assign ownership before implementation.
- Linear issue ready: `True`
- Auto-resolved: `False`
- Involved:
  - `SOURCE_ATLAS_CODEX_OS_UPGRADE_MAP` — `docs/codex/SOURCE_ATLAS_CODEX_OS_UPGRADE_MAP.md` (partial_implementation; release proof)
  - `SA01_SA32_SOURCE_ATLAS_FULL_MATURITY_TRAIN` — `docs/codex/batch-trains/SA01_SA32_SOURCE_ATLAS_FULL_MATURITY_TRAIN.md` (partial_implementation; release proof)
  - `GATE_SYSTEM_HARDENING_NEXT_PROMPT` — `docs/codex/batches/GATE_SYSTEM_HARDENING_NEXT_PROMPT.md` (partial_implementation; release proof)
  - `SOURCE_ATLAS_RESEARCH_SEEDS_V1_IMPORT_PROMPT` — `docs/codex/batches/SOURCE_ATLAS_RESEARCH_SEEDS_V1_IMPORT_PROMPT.md` (unknown; release proof)

### 215. Same source file targeted by multiple active items: scripts/sa-generated-step-boundary-scan.sh

- Conflict ID: `AMB28-same_source_file_targeted_by_multiple_active_batches-6079058`
- Type: `same_source_file_targeted_by_multiple_active_batches`
- Severity: `yellow`
- Recommended action: `merge`
- Rationale: Multiple active ledger items reference the same source file; merge, sequence, or assign ownership before implementation.
- Linear issue ready: `True`
- Auto-resolved: `False`
- Involved:
  - `SOURCE_ATLAS_CODEX_OS_UPGRADE_MAP` — `docs/codex/SOURCE_ATLAS_CODEX_OS_UPGRADE_MAP.md` (partial_implementation; release proof)
  - `GATE_SYSTEM_HARDENING_NEXT_PROMPT` — `docs/codex/batches/GATE_SYSTEM_HARDENING_NEXT_PROMPT.md` (partial_implementation; release proof)

### 216. Same source file targeted by multiple active items: scripts/sa-no-claim-scan.sh

- Conflict ID: `AMB28-same_source_file_targeted_by_multiple_active_batches-54582784`
- Type: `same_source_file_targeted_by_multiple_active_batches`
- Severity: `yellow`
- Recommended action: `merge`
- Rationale: Multiple active ledger items reference the same source file; merge, sequence, or assign ownership before implementation.
- Linear issue ready: `True`
- Auto-resolved: `False`
- Involved:
  - `SOURCE_ATLAS_CODEX_OS_UPGRADE_MAP` — `docs/codex/SOURCE_ATLAS_CODEX_OS_UPGRADE_MAP.md` (partial_implementation; release proof)
  - `SA01_SA32_SOURCE_ATLAS_FULL_MATURITY_TRAIN` — `docs/codex/batch-trains/SA01_SA32_SOURCE_ATLAS_FULL_MATURITY_TRAIN.md` (partial_implementation; release proof)

### 217. Same source file targeted by multiple active items: scripts/sa-offline-fallback-scan.sh

- Conflict ID: `AMB28-same_source_file_targeted_by_multiple_active_batches-6975657`
- Type: `same_source_file_targeted_by_multiple_active_batches`
- Severity: `yellow`
- Recommended action: `merge`
- Rationale: Multiple active ledger items reference the same source file; merge, sequence, or assign ownership before implementation.
- Linear issue ready: `True`
- Auto-resolved: `False`
- Involved:
  - `SOURCE_ATLAS_CODEX_OS_UPGRADE_MAP` — `docs/codex/SOURCE_ATLAS_CODEX_OS_UPGRADE_MAP.md` (partial_implementation; release proof)
  - `SA01_SA32_SOURCE_ATLAS_FULL_MATURITY_TRAIN` — `docs/codex/batch-trains/SA01_SA32_SOURCE_ATLAS_FULL_MATURITY_TRAIN.md` (partial_implementation; release proof)

### 218. Same source file targeted by multiple active items: scripts/sa-pack-duplication-scan.sh

- Conflict ID: `AMB28-same_source_file_targeted_by_multiple_active_batches-70345737`
- Type: `same_source_file_targeted_by_multiple_active_batches`
- Severity: `yellow`
- Recommended action: `merge`
- Rationale: Multiple active ledger items reference the same source file; merge, sequence, or assign ownership before implementation.
- Linear issue ready: `True`
- Auto-resolved: `False`
- Involved:
  - `SOURCE_ATLAS_CODEX_OS_UPGRADE_MAP` — `docs/codex/SOURCE_ATLAS_CODEX_OS_UPGRADE_MAP.md` (partial_implementation; release proof)
  - `SA01_SA32_SOURCE_ATLAS_FULL_MATURITY_TRAIN` — `docs/codex/batch-trains/SA01_SA32_SOURCE_ATLAS_FULL_MATURITY_TRAIN.md` (partial_implementation; release proof)
  - `GATE_SYSTEM_HARDENING_NEXT_PROMPT` — `docs/codex/batches/GATE_SYSTEM_HARDENING_NEXT_PROMPT.md` (partial_implementation; release proof)
  - `SOURCE_ATLAS_RESEARCH_SEEDS_V1_IMPORT_PROMPT` — `docs/codex/batches/SOURCE_ATLAS_RESEARCH_SEEDS_V1_IMPORT_PROMPT.md` (unknown; release proof)

### 219. Same source file targeted by multiple active items: scripts/sa-pack-schema-validate.sh

- Conflict ID: `AMB28-same_source_file_targeted_by_multiple_active_batches-95711181`
- Type: `same_source_file_targeted_by_multiple_active_batches`
- Severity: `yellow`
- Recommended action: `merge`
- Rationale: Multiple active ledger items reference the same source file; merge, sequence, or assign ownership before implementation.
- Linear issue ready: `True`
- Auto-resolved: `False`
- Involved:
  - `SOURCE_ATLAS_CODEX_OS_UPGRADE_MAP` — `docs/codex/SOURCE_ATLAS_CODEX_OS_UPGRADE_MAP.md` (partial_implementation; release proof)
  - `SA01_SA32_SOURCE_ATLAS_FULL_MATURITY_TRAIN` — `docs/codex/batch-trains/SA01_SA32_SOURCE_ATLAS_FULL_MATURITY_TRAIN.md` (partial_implementation; release proof)

### 220. Same source file targeted by multiple active items: scripts/sa-projection-fixture-coverage-scan.sh

- Conflict ID: `AMB28-same_source_file_targeted_by_multiple_active_batches-17517842`
- Type: `same_source_file_targeted_by_multiple_active_batches`
- Severity: `yellow`
- Recommended action: `merge`
- Rationale: Multiple active ledger items reference the same source file; merge, sequence, or assign ownership before implementation.
- Linear issue ready: `True`
- Auto-resolved: `False`
- Involved:
  - `SOURCE_ATLAS_CODEX_OS_UPGRADE_MAP` — `docs/codex/SOURCE_ATLAS_CODEX_OS_UPGRADE_MAP.md` (partial_implementation; release proof)
  - `SA01_SA32_SOURCE_ATLAS_FULL_MATURITY_TRAIN` — `docs/codex/batch-trains/SA01_SA32_SOURCE_ATLAS_FULL_MATURITY_TRAIN.md` (partial_implementation; release proof)
  - `GATE_SYSTEM_HARDENING_NEXT_PROMPT` — `docs/codex/batches/GATE_SYSTEM_HARDENING_NEXT_PROMPT.md` (partial_implementation; release proof)
  - `SOURCE_ATLAS_RESEARCH_SEEDS_V1_IMPORT_PROMPT` — `docs/codex/batches/SOURCE_ATLAS_RESEARCH_SEEDS_V1_IMPORT_PROMPT.md` (unknown; release proof)

### 221. Same source file targeted by multiple active items: scripts/sa-research-seeds-integrity-scan.sh

- Conflict ID: `AMB28-same_source_file_targeted_by_multiple_active_batches-55049679`
- Type: `same_source_file_targeted_by_multiple_active_batches`
- Severity: `yellow`
- Recommended action: `merge`
- Rationale: Multiple active ledger items reference the same source file; merge, sequence, or assign ownership before implementation.
- Linear issue ready: `True`
- Auto-resolved: `False`
- Involved:
  - `GATE_SYSTEM_HARDENING_NEXT_PROMPT` — `docs/codex/batches/GATE_SYSTEM_HARDENING_NEXT_PROMPT.md` (partial_implementation; release proof)
  - `SOURCE_ATLAS_RESEARCH_SEEDS_V1_IMPORT_REPORT` — `docs/codex/SOURCE_ATLAS_RESEARCH_SEEDS_V1_IMPORT_REPORT.md` (unknown; release proof)
  - `SOURCE_ATLAS_RESEARCH_SEEDS_V1_IMPORT_PROMPT` — `docs/codex/batches/SOURCE_ATLAS_RESEARCH_SEEDS_V1_IMPORT_PROMPT.md` (unknown; release proof)

### 222. Same source file targeted by multiple active items: scripts/sa-source-container-coverage-scan.sh

- Conflict ID: `AMB28-same_source_file_targeted_by_multiple_active_batches-29322830`
- Type: `same_source_file_targeted_by_multiple_active_batches`
- Severity: `yellow`
- Recommended action: `merge`
- Rationale: Multiple active ledger items reference the same source file; merge, sequence, or assign ownership before implementation.
- Linear issue ready: `True`
- Auto-resolved: `False`
- Involved:
  - `SOURCE_ATLAS_CODEX_OS_UPGRADE_MAP` — `docs/codex/SOURCE_ATLAS_CODEX_OS_UPGRADE_MAP.md` (partial_implementation; release proof)
  - `SA01_SA32_SOURCE_ATLAS_FULL_MATURITY_TRAIN` — `docs/codex/batch-trains/SA01_SA32_SOURCE_ATLAS_FULL_MATURITY_TRAIN.md` (partial_implementation; release proof)

### 223. Same source file targeted by multiple active items: scripts/si-readiness-gate.sh

- Conflict ID: `AMB28-same_source_file_targeted_by_multiple_active_batches-12980944`
- Type: `same_source_file_targeted_by_multiple_active_batches`
- Severity: `yellow`
- Recommended action: `merge`
- Rationale: Multiple active ledger items reference the same source file; merge, sequence, or assign ownership before implementation.
- Linear issue ready: `True`
- Auto-resolved: `False`
- Involved:
  - `GLOBAL_BATCH_AUTOMATED_GATE_PROTOCOL` — `docs/codex/GLOBAL_BATCH_AUTOMATED_GATE_PROTOCOL.md` (partial_implementation; release proof)
  - `SI01_Signature_Interface_Canon_To_SwiftUI_Architecture_Prompt` — `docs/codex/batches/SI01_Signature_Interface_Canon_To_SwiftUI_Architecture_Prompt.md` (partial_implementation; release proof)
  - `SI02_Adaptive_Panel_Action_And_Module_Foundation_Prompt` — `docs/codex/batches/SI02_Adaptive_Panel_Action_And_Module_Foundation_Prompt.md` (partial_implementation; release proof)
  - `SI03_App_Shell_IA_And_Navigation_List_System_Prompt` — `docs/codex/batches/SI03_App_Shell_IA_And_Navigation_List_System_Prompt.md` (partial_implementation; release proof)
  - `SI04_DayTimelineRail_2_0_Prompt` — `docs/codex/batches/SI04_DayTimelineRail_2_0_Prompt.md` (partial_implementation; release proof)
  - `SI06_LifePath_Visualization_System_Prompt` — `docs/codex/batches/SI06_LifePath_Visualization_System_Prompt.md` (partial_implementation; release proof)
  - `SI07_Mission_Control_Lane_Components_Prompt` — `docs/codex/batches/SI07_Mission_Control_Lane_Components_Prompt.md` (partial_implementation; release proof)
  - `SI08_LifeShape_Time_Capacity_Map_Prompt` — `docs/codex/batches/SI08_LifeShape_Time_Capacity_Map_Prompt.md` (partial_implementation; release proof)
  - `SI09_Capture_Atmosphere_Composer_Prompt` — `docs/codex/batches/SI09_Capture_Atmosphere_Composer_Prompt.md` (partial_implementation; release proof)
  - `SI10_Trust_Receipt_Layer_Prompt` — `docs/codex/batches/SI10_Trust_Receipt_Layer_Prompt.md` (partial_implementation; release proof)
  - `SI11_Personal_System_Center_Components_Prompt` — `docs/codex/batches/SI11_Personal_System_Center_Components_Prompt.md` (partial_implementation; release proof)
  - `SI12_Interaction_Motion_Haptics_System_Prompt` — `docs/codex/batches/SI12_Interaction_Motion_Haptics_System_Prompt.md` (partial_implementation; release proof)
  - `SI13_Loading_Empty_Degraded_State_Primitives_Prompt` — `docs/codex/batches/SI13_Loading_Empty_Degraded_State_Primitives_Prompt.md` (partial_implementation; release proof)
  - `SI14_Iconography_Symbol_And_Status_Grammar_Prompt` — `docs/codex/batches/SI14_Iconography_Symbol_And_Status_Grammar_Prompt.md` (partial_implementation; release proof)
  - `SI15_Accessibility_Adaptive_Interface_Pass_Prompt` — `docs/codex/batches/SI15_Accessibility_Adaptive_Interface_Pass_Prompt.md` (partial_implementation; release proof)
  - `SI16_Preview_Fixture_And_Visual_QA_Infrastructure_Prompt` — `docs/codex/batches/SI16_Preview_Fixture_And_Visual_QA_Infrastructure_Prompt.md` (partial_implementation; release proof)
  - `SI18_Signature_Interface_Handoff_And_Product_Depth_Readiness_Prompt` — `docs/codex/batches/SI18_Signature_Interface_Handoff_And_Product_Depth_Readiness_Prompt.md` (partial_implementation; release proof)

### 224. Same source file targeted by multiple active items: scripts/si-visual-qa-report.sh

- Conflict ID: `AMB28-same_source_file_targeted_by_multiple_active_batches-43014259`
- Type: `same_source_file_targeted_by_multiple_active_batches`
- Severity: `yellow`
- Recommended action: `merge`
- Rationale: Multiple active ledger items reference the same source file; merge, sequence, or assign ownership before implementation.
- Linear issue ready: `True`
- Auto-resolved: `False`
- Involved:
  - `GLOBAL_BATCH_AUTOMATED_GATE_PROTOCOL` — `docs/codex/GLOBAL_BATCH_AUTOMATED_GATE_PROTOCOL.md` (partial_implementation; release proof)
  - `SI02_Adaptive_Panel_Action_And_Module_Foundation_Prompt` — `docs/codex/batches/SI02_Adaptive_Panel_Action_And_Module_Foundation_Prompt.md` (partial_implementation; release proof)
  - `SI03_App_Shell_IA_And_Navigation_List_System_Prompt` — `docs/codex/batches/SI03_App_Shell_IA_And_Navigation_List_System_Prompt.md` (partial_implementation; release proof)
  - `SI04_DayTimelineRail_2_0_Prompt` — `docs/codex/batches/SI04_DayTimelineRail_2_0_Prompt.md` (partial_implementation; release proof)
  - `SI06_LifePath_Visualization_System_Prompt` — `docs/codex/batches/SI06_LifePath_Visualization_System_Prompt.md` (partial_implementation; release proof)
  - `SI07_Mission_Control_Lane_Components_Prompt` — `docs/codex/batches/SI07_Mission_Control_Lane_Components_Prompt.md` (partial_implementation; release proof)
  - `SI08_LifeShape_Time_Capacity_Map_Prompt` — `docs/codex/batches/SI08_LifeShape_Time_Capacity_Map_Prompt.md` (partial_implementation; release proof)
  - `SI09_Capture_Atmosphere_Composer_Prompt` — `docs/codex/batches/SI09_Capture_Atmosphere_Composer_Prompt.md` (partial_implementation; release proof)
  - `SI10_Trust_Receipt_Layer_Prompt` — `docs/codex/batches/SI10_Trust_Receipt_Layer_Prompt.md` (partial_implementation; release proof)
  - `SI11_Personal_System_Center_Components_Prompt` — `docs/codex/batches/SI11_Personal_System_Center_Components_Prompt.md` (partial_implementation; release proof)
  - `SI12_Interaction_Motion_Haptics_System_Prompt` — `docs/codex/batches/SI12_Interaction_Motion_Haptics_System_Prompt.md` (partial_implementation; release proof)
  - `SI13_Loading_Empty_Degraded_State_Primitives_Prompt` — `docs/codex/batches/SI13_Loading_Empty_Degraded_State_Primitives_Prompt.md` (partial_implementation; release proof)
  - `SI14_Iconography_Symbol_And_Status_Grammar_Prompt` — `docs/codex/batches/SI14_Iconography_Symbol_And_Status_Grammar_Prompt.md` (partial_implementation; release proof)
  - `SI15_Accessibility_Adaptive_Interface_Pass_Prompt` — `docs/codex/batches/SI15_Accessibility_Adaptive_Interface_Pass_Prompt.md` (partial_implementation; release proof)
  - `SI16_Preview_Fixture_And_Visual_QA_Infrastructure_Prompt` — `docs/codex/batches/SI16_Preview_Fixture_And_Visual_QA_Infrastructure_Prompt.md` (partial_implementation; release proof)

### 225. Same source file targeted by multiple active items: scripts/swiftui-architecture-scan.sh

- Conflict ID: `AMB28-same_source_file_targeted_by_multiple_active_batches-57884692`
- Type: `same_source_file_targeted_by_multiple_active_batches`
- Severity: `yellow`
- Recommended action: `merge`
- Rationale: Multiple active ledger items reference the same source file; merge, sequence, or assign ownership before implementation.
- Linear issue ready: `True`
- Auto-resolved: `False`
- Involved:
  - `F03_5_Today_Execution_State_Contract_Hardening_Prompt` — `docs/codex/batches/F03_5_Today_Execution_State_Contract_Hardening_Prompt.md` (partial_implementation; release proof)
  - `F17_Shell_Meridian_Planning_And_Readiness_Audit_Prompt` — `docs/codex/batches/F17_Shell_Meridian_Planning_And_Readiness_Audit_Prompt.md` (partial_implementation; release proof)
  - `F18_Feature_Flagged_Meridian_Shell_Implementation_Prompt` — `docs/codex/batches/F18_Feature_Flagged_Meridian_Shell_Implementation_Prompt.md` (partial_implementation; release proof)
  - `SI02_Adaptive_Panel_Action_And_Module_Foundation_Prompt` — `docs/codex/batches/SI02_Adaptive_Panel_Action_And_Module_Foundation_Prompt.md` (partial_implementation; release proof)
  - `SI03_App_Shell_IA_And_Navigation_List_System_Prompt` — `docs/codex/batches/SI03_App_Shell_IA_And_Navigation_List_System_Prompt.md` (partial_implementation; release proof)
  - `SI04_DayTimelineRail_2_0_Prompt` — `docs/codex/batches/SI04_DayTimelineRail_2_0_Prompt.md` (partial_implementation; release proof)
  - `SI06_LifePath_Visualization_System_Prompt` — `docs/codex/batches/SI06_LifePath_Visualization_System_Prompt.md` (partial_implementation; release proof)
  - `SI07_Mission_Control_Lane_Components_Prompt` — `docs/codex/batches/SI07_Mission_Control_Lane_Components_Prompt.md` (partial_implementation; release proof)
  - `SI08_LifeShape_Time_Capacity_Map_Prompt` — `docs/codex/batches/SI08_LifeShape_Time_Capacity_Map_Prompt.md` (partial_implementation; release proof)
  - `SI09_Capture_Atmosphere_Composer_Prompt` — `docs/codex/batches/SI09_Capture_Atmosphere_Composer_Prompt.md` (partial_implementation; release proof)
  - `SI10_Trust_Receipt_Layer_Prompt` — `docs/codex/batches/SI10_Trust_Receipt_Layer_Prompt.md` (partial_implementation; release proof)
  - `SI11_Personal_System_Center_Components_Prompt` — `docs/codex/batches/SI11_Personal_System_Center_Components_Prompt.md` (partial_implementation; release proof)
  - `SI12_Interaction_Motion_Haptics_System_Prompt` — `docs/codex/batches/SI12_Interaction_Motion_Haptics_System_Prompt.md` (partial_implementation; release proof)
  - `SI13_Loading_Empty_Degraded_State_Primitives_Prompt` — `docs/codex/batches/SI13_Loading_Empty_Degraded_State_Primitives_Prompt.md` (partial_implementation; release proof)
  - `SI14_Iconography_Symbol_And_Status_Grammar_Prompt` — `docs/codex/batches/SI14_Iconography_Symbol_And_Status_Grammar_Prompt.md` (partial_implementation; release proof)
  - `SI15_Accessibility_Adaptive_Interface_Pass_Prompt` — `docs/codex/batches/SI15_Accessibility_Adaptive_Interface_Pass_Prompt.md` (partial_implementation; release proof)
  - `SI16_Preview_Fixture_And_Visual_QA_Infrastructure_Prompt` — `docs/codex/batches/SI16_Preview_Fixture_And_Visual_QA_Infrastructure_Prompt.md` (partial_implementation; release proof)
  - `AMBITIONSOS_AOS_EVIDENCE_LEDGER` — `docs/codex/AMBITIONSOS_AOS_EVIDENCE_LEDGER.md` (partial_implementation; release proof)
  - `F16_5_SwiftUI_Architecture_State_Contract_Hardening_Prompt` — `docs/codex/batches/F16_5_SwiftUI_Architecture_State_Contract_Hardening_Prompt.md` (unknown; release proof)

### 226. Same source file targeted by multiple active items: scripts/test-local.sh

- Conflict ID: `AMB28-same_source_file_targeted_by_multiple_active_batches-24829593`
- Type: `same_source_file_targeted_by_multiple_active_batches`
- Severity: `yellow`
- Recommended action: `merge`
- Rationale: Multiple active ledger items reference the same source file; merge, sequence, or assign ownership before implementation.
- Linear issue ready: `True`
- Auto-resolved: `False`
- Involved:
  - `AMBITIONS_3_0_CONTEXT_LOADING_AND_TASK_ROUTING` — `docs/codex/AMBITIONS_3_0_CONTEXT_LOADING_AND_TASK_ROUTING.md` (partial_implementation; release proof)
  - `F27_Final_FAANG_Handoff_Gate_Rerun_Prompt` — `docs/codex/batches/F27_Final_FAANG_Handoff_Gate_Rerun_Prompt.md` (partial_implementation; release proof)
  - `PFC05_CI_Local_Toolchain_Reproducibility_Prompt` — `docs/codex/batches/PFC05_CI_Local_Toolchain_Reproducibility_Prompt.md` (partial_implementation; release proof)
  - `F21_5_UI_Flake_Reliability_Hardening_Prompt` — `docs/codex/batches/F21_5_UI_Flake_Reliability_Hardening_Prompt.md` (unknown; release proof)

### 227. Same source file targeted by multiple active items: scripts/validate-dev-tools.sh

- Conflict ID: `AMB28-same_source_file_targeted_by_multiple_active_batches-69733426`
- Type: `same_source_file_targeted_by_multiple_active_batches`
- Severity: `yellow`
- Recommended action: `merge`
- Rationale: Multiple active ledger items reference the same source file; merge, sequence, or assign ownership before implementation.
- Linear issue ready: `True`
- Auto-resolved: `False`
- Involved:
  - `AMBITIONS_3_0_CONTEXT_LOADING_AND_TASK_ROUTING` — `docs/codex/AMBITIONS_3_0_CONTEXT_LOADING_AND_TASK_ROUTING.md` (partial_implementation; release proof)
  - `PFC01_Repo_And_Build_System_Inventory_Prompt` — `docs/codex/batches/PFC01_Repo_And_Build_System_Inventory_Prompt.md` (partial_implementation; release proof)
  - `PFC05_CI_Local_Toolchain_Reproducibility_Prompt` — `docs/codex/batches/PFC05_CI_Local_Toolchain_Reproducibility_Prompt.md` (partial_implementation; release proof)

### 228. Same source file targeted by multiple active items: scripts/validate-repo-authority.sh

- Conflict ID: `AMB28-same_source_file_targeted_by_multiple_active_batches-54604989`
- Type: `same_source_file_targeted_by_multiple_active_batches`
- Severity: `yellow`
- Recommended action: `merge`
- Rationale: Multiple active ledger items reference the same source file; merge, sequence, or assign ownership before implementation.
- Linear issue ready: `True`
- Auto-resolved: `False`
- Involved:
  - `README-SOURCE-TRUTH-LINK-AND-CLAIM-REPAIR-01` — `prompts/batches/README-SOURCE-TRUTH-LINK-AND-CLAIM-REPAIR-01.md` (partial_implementation; release proof)
  - `REPO-AUTHORITY-LEGACY-ACTIVE-HEADER-CLEANUP-01` — `prompts/batches/REPO-AUTHORITY-LEGACY-ACTIVE-HEADER-CLEANUP-01.md` (partial_implementation; release proof)
  - `TOP-LEVEL-IA-PLAN-LEAK-REGRESSION-01` — `prompts/batches/TOP-LEVEL-IA-PLAN-LEAK-REGRESSION-01.md` (partial_implementation; release proof)


## Batches referencing retired IA or terminology

### 1. Retired IA/terminology reference in AMB-LINEAR-TEMPLATE-MANIFEST

- Conflict ID: `AMB28-retired_ia_or_terminology_reference-9853639`
- Type: `retired_ia_or_terminology_reference`
- Severity: `yellow`
- Recommended action: `rewrite`
- Rationale: Retired IA or product language should be rewritten or explicitly quarantined before this work becomes active.
- Linear issue ready: `True`
- Auto-resolved: `False`
- Involved:
  - `AMB-LINEAR-TEMPLATE-MANIFEST` — `docs/codex/linear-templates/AMB-LINEAR-TEMPLATE-MANIFEST.yml` (partial_implementation; release proof)

### 2. Retired IA/terminology reference in AMB_GLOBAL_REMAINING_TRAIN_BLUEPRINT

- Conflict ID: `AMB28-retired_ia_or_terminology_reference-8626883`
- Type: `retired_ia_or_terminology_reference`
- Severity: `yellow`
- Recommended action: `rewrite`
- Rationale: Retired IA or product language should be rewritten or explicitly quarantined before this work becomes active.
- Linear issue ready: `True`
- Auto-resolved: `False`
- Involved:
  - `AMB_GLOBAL_REMAINING_TRAIN_BLUEPRINT` — `docs/codex/AMB_GLOBAL_REMAINING_TRAIN_BLUEPRINT.json` (unknown; tests)

### 3. Retired IA/terminology reference in HISTORICAL_BASELINE_GLOBAL_TRAIN_MANIFEST

- Conflict ID: `AMB28-retired_ia_or_terminology_reference-29191447`
- Type: `retired_ia_or_terminology_reference`
- Severity: `yellow`
- Recommended action: `rewrite`
- Rationale: Retired IA or product language should be rewritten or explicitly quarantined before this work becomes active.
- Linear issue ready: `True`
- Auto-resolved: `False`
- Involved:
  - `HISTORICAL_BASELINE_GLOBAL_TRAIN_MANIFEST` — `docs/codex/HISTORICAL_BASELINE_GLOBAL_TRAIN_MANIFEST.json` (unknown; release proof)

### 4. Retired IA/terminology reference in MOAT_RUNTIME_BATCH_OVERLAY

- Conflict ID: `AMB28-retired_ia_or_terminology_reference-15390859`
- Type: `retired_ia_or_terminology_reference`
- Severity: `yellow`
- Recommended action: `rewrite`
- Rationale: Retired IA or product language should be rewritten or explicitly quarantined before this work becomes active.
- Linear issue ready: `True`
- Auto-resolved: `False`
- Involved:
  - `MOAT_RUNTIME_BATCH_OVERLAY` — `docs/codex/MOAT_RUNTIME_BATCH_OVERLAY.json` (partial_implementation; release proof)

### 5. Retired IA/terminology reference in TRAIN_04D_CAPTURE_RUNTIME_FACTORING_FUTURE_PROOF

- Conflict ID: `AMB28-retired_ia_or_terminology_reference-21727402`
- Type: `retired_ia_or_terminology_reference`
- Severity: `yellow`
- Recommended action: `rewrite`
- Rationale: Retired IA or product language should be rewritten or explicitly quarantined before this work becomes active.
- Linear issue ready: `True`
- Auto-resolved: `False`
- Involved:
  - `TRAIN_04D_CAPTURE_RUNTIME_FACTORING_FUTURE_PROOF` — `prompts/trains/ios26-flagship/TRAIN_04D_CAPTURE_RUNTIME_FACTORING_FUTURE_PROOF.md` (partial_implementation; release proof)

### 6. Retired IA/terminology reference in TRAIN_08_CAPTURE_ATMOSPHERE_COMPOSER_FINAL_OBJECT

- Conflict ID: `AMB28-retired_ia_or_terminology_reference-35208523`
- Type: `retired_ia_or_terminology_reference`
- Severity: `yellow`
- Recommended action: `rewrite`
- Rationale: Retired IA or product language should be rewritten or explicitly quarantined before this work becomes active.
- Linear issue ready: `True`
- Auto-resolved: `False`
- Involved:
  - `TRAIN_08_CAPTURE_ATMOSPHERE_COMPOSER_FINAL_OBJECT` — `prompts/trains/ios26-flagship/TRAIN_08_CAPTURE_ATMOSPHERE_COMPOSER_FINAL_OBJECT.md` (partial_implementation; source-only)

### 7. Retired IA/terminology reference in existing-code-champion-coverage

- Conflict ID: `AMB28-retired_ia_or_terminology_reference-50479763`
- Type: `retired_ia_or_terminology_reference`
- Severity: `yellow`
- Recommended action: `rewrite`
- Rationale: Retired IA or product language should be rewritten or explicitly quarantined before this work becomes active.
- Linear issue ready: `True`
- Auto-resolved: `False`
- Involved:
  - `existing-code-champion-coverage` — `docs/codex/existing-code-champion-coverage.yml` (unknown; release proof)

### 8. Retired IA/terminology reference in parallel-guard-concept-registry

- Conflict ID: `AMB28-retired_ia_or_terminology_reference-29267895`
- Type: `retired_ia_or_terminology_reference`
- Severity: `yellow`
- Recommended action: `rewrite`
- Rationale: Retired IA or product language should be rewritten or explicitly quarantined before this work becomes active.
- Linear issue ready: `True`
- Auto-resolved: `False`
- Involved:
  - `parallel-guard-concept-registry` — `docs/codex/parallel-guard-concept-registry.yml` (partial_implementation; source-only)


## Batches missing source-of-truth references

### 1. Missing source-of-truth references in AMB_GLOBAL_REMAINING_TRAIN_BLUEPRINT

- Conflict ID: `AMB28-missing_source_of_truth_reference-75513218`
- Type: `missing_source_of_truth_reference`
- Severity: `yellow`
- Recommended action: `rewrite`
- Rationale: Active batch/prompt/train should cite governing truth or authority files before execution.
- Linear issue ready: `True`
- Auto-resolved: `False`
- Involved:
  - `AMB_GLOBAL_REMAINING_TRAIN_BLUEPRINT` — `docs/codex/AMB_GLOBAL_REMAINING_TRAIN_BLUEPRINT.json` (unknown; tests)

### 2. Missing source-of-truth references in AMB_REMAINING_BATCH_REFERENCE

- Conflict ID: `AMB28-missing_source_of_truth_reference-64470598`
- Type: `missing_source_of_truth_reference`
- Severity: `yellow`
- Recommended action: `rewrite`
- Rationale: Active batch/prompt/train should cite governing truth or authority files before execution.
- Linear issue ready: `True`
- Auto-resolved: `False`
- Involved:
  - `AMB_REMAINING_BATCH_REFERENCE` — `docs/codex/AMB_REMAINING_BATCH_REFERENCE.json` (partial_implementation; release proof)

### 3. Missing source-of-truth references in CHAMPION_MERGE_AND_INTELLIGENCE_CONSOLIDATION_SUPPORT

- Conflict ID: `AMB28-missing_source_of_truth_reference-5022037`
- Type: `missing_source_of_truth_reference`
- Severity: `yellow`
- Recommended action: `rewrite`
- Rationale: Active batch/prompt/train should cite governing truth or authority files before execution.
- Linear issue ready: `True`
- Auto-resolved: `False`
- Involved:
  - `CHAMPION_MERGE_AND_INTELLIGENCE_CONSOLIDATION_SUPPORT` — `prompts/trains/ios26-flagship/support/CHAMPION_MERGE_AND_INTELLIGENCE_CONSOLIDATION_SUPPORT.md` (partial_implementation; release proof)

### 4. Missing source-of-truth references in GLOBAL_QUEUE_CANONICAL_ORDER

- Conflict ID: `AMB28-missing_source_of_truth_reference-57158289`
- Type: `missing_source_of_truth_reference`
- Severity: `yellow`
- Recommended action: `rewrite`
- Rationale: Active batch/prompt/train should cite governing truth or authority files before execution.
- Linear issue ready: `True`
- Auto-resolved: `False`
- Involved:
  - `GLOBAL_QUEUE_CANONICAL_ORDER` — `docs/codex/GLOBAL_QUEUE_CANONICAL_ORDER.json` (partial_implementation; release proof)

### 5. Missing source-of-truth references in HISTORICAL_BASELINE_GLOBAL_TRAIN_MANIFEST

- Conflict ID: `AMB28-missing_source_of_truth_reference-75940984`
- Type: `missing_source_of_truth_reference`
- Severity: `yellow`
- Recommended action: `rewrite`
- Rationale: Active batch/prompt/train should cite governing truth or authority files before execution.
- Linear issue ready: `True`
- Auto-resolved: `False`
- Involved:
  - `HISTORICAL_BASELINE_GLOBAL_TRAIN_MANIFEST` — `docs/codex/HISTORICAL_BASELINE_GLOBAL_TRAIN_MANIFEST.json` (unknown; release proof)

### 6. Missing source-of-truth references in IOS26-FLAGSHIP

- Conflict ID: `AMB28-missing_source_of_truth_reference-90140917`
- Type: `missing_source_of_truth_reference`
- Severity: `yellow`
- Recommended action: `rewrite`
- Rationale: Active batch/prompt/train should cite governing truth or authority files before execution.
- Linear issue ready: `True`
- Auto-resolved: `False`
- Involved:
  - `IOS26-FLAGSHIP` — `docs/codex/IOS26_FLAGSHIP_EXECUTION_STATE.yml` (partial_implementation; source-only)

### 7. Missing source-of-truth references in IOS26_BATCH_MATRIX

- Conflict ID: `AMB28-missing_source_of_truth_reference-58629088`
- Type: `missing_source_of_truth_reference`
- Severity: `yellow`
- Recommended action: `rewrite`
- Rationale: Active batch/prompt/train should cite governing truth or authority files before execution.
- Linear issue ready: `True`
- Auto-resolved: `False`
- Involved:
  - `IOS26_BATCH_MATRIX` — `docs/codex/ios26/IOS26_BATCH_MATRIX.yml` (partial_implementation; release proof)

### 8. Missing source-of-truth references in IOS26_DEPENDENCY_GRAPH

- Conflict ID: `AMB28-missing_source_of_truth_reference-37927522`
- Type: `missing_source_of_truth_reference`
- Severity: `yellow`
- Recommended action: `rewrite`
- Rationale: Active batch/prompt/train should cite governing truth or authority files before execution.
- Linear issue ready: `True`
- Auto-resolved: `False`
- Involved:
  - `IOS26_DEPENDENCY_GRAPH` — `docs/codex/ios26/IOS26_DEPENDENCY_GRAPH.yml` (partial_implementation; source-only)

### 9. Missing source-of-truth references in IOS26_PROMPT_FREEZE_HASHES

- Conflict ID: `AMB28-missing_source_of_truth_reference-80917091`
- Type: `missing_source_of_truth_reference`
- Severity: `yellow`
- Recommended action: `rewrite`
- Rationale: Active batch/prompt/train should cite governing truth or authority files before execution.
- Linear issue ready: `True`
- Auto-resolved: `False`
- Involved:
  - `IOS26_PROMPT_FREEZE_HASHES` — `docs/codex/ios26/IOS26_PROMPT_FREEZE_HASHES.json` (partial_implementation; release proof)

### 10. Missing source-of-truth references in MOAT_RUNTIME_BATCH_OVERLAY

- Conflict ID: `AMB28-missing_source_of_truth_reference-86375008`
- Type: `missing_source_of_truth_reference`
- Severity: `yellow`
- Recommended action: `rewrite`
- Rationale: Active batch/prompt/train should cite governing truth or authority files before execution.
- Linear issue ready: `True`
- Auto-resolved: `False`
- Involved:
  - `MOAT_RUNTIME_BATCH_OVERLAY` — `docs/codex/MOAT_RUNTIME_BATCH_OVERLAY.json` (partial_implementation; release proof)

### 11. Missing source-of-truth references in SPEED_TRAIN_LANE_POLICY

- Conflict ID: `AMB28-missing_source_of_truth_reference-94408149`
- Type: `missing_source_of_truth_reference`
- Severity: `yellow`
- Recommended action: `rewrite`
- Rationale: Active batch/prompt/train should cite governing truth or authority files before execution.
- Linear issue ready: `True`
- Auto-resolved: `False`
- Involved:
  - `SPEED_TRAIN_LANE_POLICY` — `docs/codex/SPEED_TRAIN_LANE_POLICY.json` (unknown; release proof)

### 12. Missing source-of-truth references in TRAIN_04L

- Conflict ID: `AMB28-missing_source_of_truth_reference-39330082`
- Type: `missing_source_of_truth_reference`
- Severity: `yellow`
- Recommended action: `rewrite`
- Rationale: Active batch/prompt/train should cite governing truth or authority files before execution.
- Linear issue ready: `True`
- Auto-resolved: `False`
- Involved:
  - `TRAIN_04L` — `docs/codex/CHAMPION_MERGE_TRAIN_MANIFEST.yml` (partial_implementation; source-only)

### 13. Missing source-of-truth references in TRAIN_04L_OBJECT_FRONTEND_LIVING_CHROME_FOUNDATION

- Conflict ID: `AMB28-missing_source_of_truth_reference-94421696`
- Type: `missing_source_of_truth_reference`
- Severity: `yellow`
- Recommended action: `rewrite`
- Rationale: Active batch/prompt/train should cite governing truth or authority files before execution.
- Linear issue ready: `True`
- Auto-resolved: `False`
- Involved:
  - `TRAIN_04L_OBJECT_FRONTEND_LIVING_CHROME_FOUNDATION` — `prompts/trains/ios26-flagship/TRAIN_04L_OBJECT_FRONTEND_LIVING_CHROME_FOUNDATION.md` (partial_implementation; release proof)

### 14. Missing source-of-truth references in concept-lock-registry

- Conflict ID: `AMB28-missing_source_of_truth_reference-56637061`
- Type: `missing_source_of_truth_reference`
- Severity: `yellow`
- Recommended action: `rewrite`
- Rationale: Active batch/prompt/train should cite governing truth or authority files before execution.
- Linear issue ready: `True`
- Auto-resolved: `False`
- Involved:
  - `concept-lock-registry` — `docs/codex/concept-lock-registry.yml` (partial_implementation; tests)

### 15. Missing source-of-truth references in existing-code-champion-coverage

- Conflict ID: `AMB28-missing_source_of_truth_reference-74151835`
- Type: `missing_source_of_truth_reference`
- Severity: `yellow`
- Recommended action: `rewrite`
- Rationale: Active batch/prompt/train should cite governing truth or authority files before execution.
- Linear issue ready: `True`
- Auto-resolved: `False`
- Involved:
  - `existing-code-champion-coverage` — `docs/codex/existing-code-champion-coverage.yml` (unknown; release proof)

### 16. Missing source-of-truth references in ldi06-pack-registry-fixture

- Conflict ID: `AMB28-missing_source_of_truth_reference-28915663`
- Type: `missing_source_of_truth_reference`
- Severity: `yellow`
- Recommended action: `rewrite`
- Rationale: Active batch/prompt/train should cite governing truth or authority files before execution.
- Linear issue ready: `True`
- Auto-resolved: `False`
- Involved:
  - `ldi06-pack-registry-fixture` — `docs/codex/fixtures/ldi/ldi06-pack-registry-fixture.json` (partial_implementation; source-only)

### 17. Missing source-of-truth references in parallel-guard-concept-registry

- Conflict ID: `AMB28-missing_source_of_truth_reference-85534548`
- Type: `missing_source_of_truth_reference`
- Severity: `yellow`
- Recommended action: `rewrite`
- Rationale: Active batch/prompt/train should cite governing truth or authority files before execution.
- Linear issue ready: `True`
- Auto-resolved: `False`
- Involved:
  - `parallel-guard-concept-registry` — `docs/codex/parallel-guard-concept-registry.yml` (partial_implementation; source-only)


## Batches with source-only implementation and missing proof

### 1. Source-only or missing-proof implementation state: TRAIN_00_REPO_TRUTH_AUDIT_VALIDATION_BASELINE

- Conflict ID: `AMB28-source_only_implementation_missing_proof-45772600`
- Type: `source_only_implementation_missing_proof`
- Severity: `yellow`
- Recommended action: `expedite`
- Rationale: Missing or weak proof should be triaged before execution proceeds.
- Linear issue ready: `True`
- Auto-resolved: `False`
- Involved:
  - `TRAIN_00_REPO_TRUTH_AUDIT_VALIDATION_BASELINE` — `prompts/trains/ios26-flagship/TRAIN_00_REPO_TRUTH_AUDIT_VALIDATION_BASELINE.md` (partial_implementation; audit)

### 2. Source-only or missing-proof implementation state: IOS26-FLAGSHIP

- Conflict ID: `AMB28-source_only_implementation_missing_proof-60745899`
- Type: `source_only_implementation_missing_proof`
- Severity: `yellow`
- Recommended action: `finish`
- Rationale: Source-only item needs focused proof before it can be considered implemented.
- Linear issue ready: `True`
- Auto-resolved: `False`
- Involved:
  - `IOS26-FLAGSHIP` — `docs/codex/IOS26_FLAGSHIP_EXECUTION_STATE.yml` (partial_implementation; source-only)

### 3. Source-only or missing-proof implementation state: IOS26_DEPENDENCY_GRAPH

- Conflict ID: `AMB28-source_only_implementation_missing_proof-37581034`
- Type: `source_only_implementation_missing_proof`
- Severity: `yellow`
- Recommended action: `finish`
- Rationale: Source-only item needs focused proof before it can be considered implemented.
- Linear issue ready: `True`
- Auto-resolved: `False`
- Involved:
  - `IOS26_DEPENDENCY_GRAPH` — `docs/codex/ios26/IOS26_DEPENDENCY_GRAPH.yml` (partial_implementation; source-only)

### 4. Source-only or missing-proof implementation state: TRAIN_01_IOS26_MINIMUM_MIGRATION_FOUNDATION

- Conflict ID: `AMB28-source_only_implementation_missing_proof-56935980`
- Type: `source_only_implementation_missing_proof`
- Severity: `yellow`
- Recommended action: `finish`
- Rationale: Source-only item needs focused proof before it can be considered implemented.
- Linear issue ready: `True`
- Auto-resolved: `False`
- Involved:
  - `TRAIN_01_IOS26_MINIMUM_MIGRATION_FOUNDATION` — `prompts/trains/ios26-flagship/TRAIN_01_IOS26_MINIMUM_MIGRATION_FOUNDATION.md` (partial_implementation; source-only)

### 5. Source-only or missing-proof implementation state: TRAIN_03_PRIVATE_LIFE_RUNTIME_PROOF_HARNESS

- Conflict ID: `AMB28-source_only_implementation_missing_proof-87765972`
- Type: `source_only_implementation_missing_proof`
- Severity: `yellow`
- Recommended action: `finish`
- Rationale: Source-only item needs focused proof before it can be considered implemented.
- Linear issue ready: `True`
- Auto-resolved: `False`
- Involved:
  - `TRAIN_03_PRIVATE_LIFE_RUNTIME_PROOF_HARNESS` — `prompts/trains/ios26-flagship/TRAIN_03_PRIVATE_LIFE_RUNTIME_PROOF_HARNESS.md` (partial_implementation; source-only)

### 6. Source-only or missing-proof implementation state: TRAIN_04L

- Conflict ID: `AMB28-source_only_implementation_missing_proof-7338317`
- Type: `source_only_implementation_missing_proof`
- Severity: `yellow`
- Recommended action: `finish`
- Rationale: Source-only item needs focused proof before it can be considered implemented.
- Linear issue ready: `True`
- Auto-resolved: `False`
- Involved:
  - `TRAIN_04L` — `docs/codex/CHAMPION_MERGE_TRAIN_MANIFEST.yml` (partial_implementation; source-only)

### 7. Source-only or missing-proof implementation state: TRAIN_04_GOAL_INTENT_TO_DAY_COMPILER

- Conflict ID: `AMB28-source_only_implementation_missing_proof-24817012`
- Type: `source_only_implementation_missing_proof`
- Severity: `yellow`
- Recommended action: `finish`
- Rationale: Source-only item needs focused proof before it can be considered implemented.
- Linear issue ready: `True`
- Auto-resolved: `False`
- Involved:
  - `TRAIN_04_GOAL_INTENT_TO_DAY_COMPILER` — `prompts/trains/ios26-flagship/TRAIN_04_GOAL_INTENT_TO_DAY_COMPILER.md` (partial_implementation; source-only)

### 8. Source-only or missing-proof implementation state: TRAIN_05_TODAY_REALITY_MERIDIAN_FINAL_OBJECT

- Conflict ID: `AMB28-source_only_implementation_missing_proof-72493620`
- Type: `source_only_implementation_missing_proof`
- Severity: `yellow`
- Recommended action: `finish`
- Rationale: Source-only item needs focused proof before it can be considered implemented.
- Linear issue ready: `True`
- Auto-resolved: `False`
- Involved:
  - `TRAIN_05_TODAY_REALITY_MERIDIAN_FINAL_OBJECT` — `prompts/trains/ios26-flagship/TRAIN_05_TODAY_REALITY_MERIDIAN_FINAL_OBJECT.md` (partial_implementation; source-only)

### 9. Source-only or missing-proof implementation state: TRAIN_06_TIME_LIFESHAPE_FIELD_FINAL_OBJECT

- Conflict ID: `AMB28-source_only_implementation_missing_proof-10516503`
- Type: `source_only_implementation_missing_proof`
- Severity: `yellow`
- Recommended action: `finish`
- Rationale: Source-only item needs focused proof before it can be considered implemented.
- Linear issue ready: `True`
- Auto-resolved: `False`
- Involved:
  - `TRAIN_06_TIME_LIFESHAPE_FIELD_FINAL_OBJECT` — `prompts/trains/ios26-flagship/TRAIN_06_TIME_LIFESHAPE_FIELD_FINAL_OBJECT.md` (partial_implementation; source-only)

### 10. Source-only or missing-proof implementation state: TRAIN_07_GOALS_CONSTELLATION_ATLAS_FINAL_OBJECT

- Conflict ID: `AMB28-source_only_implementation_missing_proof-42512298`
- Type: `source_only_implementation_missing_proof`
- Severity: `yellow`
- Recommended action: `finish`
- Rationale: Source-only item needs focused proof before it can be considered implemented.
- Linear issue ready: `True`
- Auto-resolved: `False`
- Involved:
  - `TRAIN_07_GOALS_CONSTELLATION_ATLAS_FINAL_OBJECT` — `prompts/trains/ios26-flagship/TRAIN_07_GOALS_CONSTELLATION_ATLAS_FINAL_OBJECT.md` (partial_implementation; source-only)

### 11. Source-only or missing-proof implementation state: TRAIN_08_CAPTURE_ATMOSPHERE_COMPOSER_FINAL_OBJECT

- Conflict ID: `AMB28-source_only_implementation_missing_proof-69092564`
- Type: `source_only_implementation_missing_proof`
- Severity: `yellow`
- Recommended action: `finish`
- Rationale: Source-only item needs focused proof before it can be considered implemented.
- Linear issue ready: `True`
- Auto-resolved: `False`
- Involved:
  - `TRAIN_08_CAPTURE_ATMOSPHERE_COMPOSER_FINAL_OBJECT` — `prompts/trains/ios26-flagship/TRAIN_08_CAPTURE_ATMOSPHERE_COMPOSER_FINAL_OBJECT.md` (partial_implementation; source-only)

### 12. Source-only or missing-proof implementation state: TRAIN_09_YOU_USER_SYSTEM_PROFILE

- Conflict ID: `AMB28-source_only_implementation_missing_proof-65690246`
- Type: `source_only_implementation_missing_proof`
- Severity: `yellow`
- Recommended action: `finish`
- Rationale: Source-only item needs focused proof before it can be considered implemented.
- Linear issue ready: `True`
- Auto-resolved: `False`
- Involved:
  - `TRAIN_09_YOU_USER_SYSTEM_PROFILE` — `prompts/trains/ios26-flagship/TRAIN_09_YOU_USER_SYSTEM_PROFILE.md` (partial_implementation; source-only)

### 13. Source-only or missing-proof implementation state: TRAIN_10_PROOF_RECEIPTS_CLOSURE_RECOVERY_REPLAY

- Conflict ID: `AMB28-source_only_implementation_missing_proof-94497291`
- Type: `source_only_implementation_missing_proof`
- Severity: `yellow`
- Recommended action: `finish`
- Rationale: Source-only item needs focused proof before it can be considered implemented.
- Linear issue ready: `True`
- Auto-resolved: `False`
- Involved:
  - `TRAIN_10_PROOF_RECEIPTS_CLOSURE_RECOVERY_REPLAY` — `prompts/trains/ios26-flagship/TRAIN_10_PROOF_RECEIPTS_CLOSURE_RECOVERY_REPLAY.md` (partial_implementation; source-only)

### 14. Source-only or missing-proof implementation state: TRAIN_11_PERSISTENCE_MIGRATION_EXPORT_DELETE_APP_GROUP

- Conflict ID: `AMB28-source_only_implementation_missing_proof-18425001`
- Type: `source_only_implementation_missing_proof`
- Severity: `yellow`
- Recommended action: `finish`
- Rationale: Source-only item needs focused proof before it can be considered implemented.
- Linear issue ready: `True`
- Auto-resolved: `False`
- Involved:
  - `TRAIN_11_PERSISTENCE_MIGRATION_EXPORT_DELETE_APP_GROUP` — `prompts/trains/ios26-flagship/TRAIN_11_PERSISTENCE_MIGRATION_EXPORT_DELETE_APP_GROUP.md` (partial_implementation; source-only)

### 15. Source-only or missing-proof implementation state: TRAIN_12_EXTERNAL_SURFACES_WIDGETS_INTENTS_SHARE

- Conflict ID: `AMB28-source_only_implementation_missing_proof-76649008`
- Type: `source_only_implementation_missing_proof`
- Severity: `yellow`
- Recommended action: `finish`
- Rationale: Source-only item needs focused proof before it can be considered implemented.
- Linear issue ready: `True`
- Auto-resolved: `False`
- Involved:
  - `TRAIN_12_EXTERNAL_SURFACES_WIDGETS_INTENTS_SHARE` — `prompts/trains/ios26-flagship/TRAIN_12_EXTERNAL_SURFACES_WIDGETS_INTENTS_SHARE.md` (partial_implementation; source-only)

### 16. Source-only or missing-proof implementation state: TRAIN_13_ACCESSIBILITY_EQUIVALENCE

- Conflict ID: `AMB28-source_only_implementation_missing_proof-81810090`
- Type: `source_only_implementation_missing_proof`
- Severity: `yellow`
- Recommended action: `finish`
- Rationale: Source-only item needs focused proof before it can be considered implemented.
- Linear issue ready: `True`
- Auto-resolved: `False`
- Involved:
  - `TRAIN_13_ACCESSIBILITY_EQUIVALENCE` — `prompts/trains/ios26-flagship/TRAIN_13_ACCESSIBILITY_EQUIVALENCE.md` (partial_implementation; source-only)

### 17. Source-only or missing-proof implementation state: TRAIN_14_PERFORMANCE_INSTRUMENTS_POWER

- Conflict ID: `AMB28-source_only_implementation_missing_proof-18334128`
- Type: `source_only_implementation_missing_proof`
- Severity: `yellow`
- Recommended action: `finish`
- Rationale: Source-only item needs focused proof before it can be considered implemented.
- Linear issue ready: `True`
- Auto-resolved: `False`
- Involved:
  - `TRAIN_14_PERFORMANCE_INSTRUMENTS_POWER` — `prompts/trains/ios26-flagship/TRAIN_14_PERFORMANCE_INSTRUMENTS_POWER.md` (partial_implementation; source-only)

### 18. Source-only or missing-proof implementation state: TRAIN_15_REPO_HYGIENE_NAMING_DRIFT_HISTORICAL_QUARANTINE

- Conflict ID: `AMB28-source_only_implementation_missing_proof-22126793`
- Type: `source_only_implementation_missing_proof`
- Severity: `yellow`
- Recommended action: `finish`
- Rationale: Source-only item needs focused proof before it can be considered implemented.
- Linear issue ready: `True`
- Auto-resolved: `False`
- Involved:
  - `TRAIN_15_REPO_HYGIENE_NAMING_DRIFT_HISTORICAL_QUARANTINE` — `prompts/trains/ios26-flagship/TRAIN_15_REPO_HYGIENE_NAMING_DRIFT_HISTORICAL_QUARANTINE.md` (partial_implementation; source-only)

### 19. Source-only or missing-proof implementation state: ldi06-pack-registry-fixture

- Conflict ID: `AMB28-source_only_implementation_missing_proof-3254909`
- Type: `source_only_implementation_missing_proof`
- Severity: `yellow`
- Recommended action: `finish`
- Rationale: Source-only item needs focused proof before it can be considered implemented.
- Linear issue ready: `True`
- Auto-resolved: `False`
- Involved:
  - `ldi06-pack-registry-fixture` — `docs/codex/fixtures/ldi/ldi06-pack-registry-fixture.json` (partial_implementation; source-only)

### 20. Source-only or missing-proof implementation state: parallel-guard-concept-registry

- Conflict ID: `AMB28-source_only_implementation_missing_proof-44715285`
- Type: `source_only_implementation_missing_proof`
- Severity: `yellow`
- Recommended action: `finish`
- Rationale: Source-only item needs focused proof before it can be considered implemented.
- Linear issue ready: `True`
- Auto-resolved: `False`
- Involved:
  - `parallel-guard-concept-registry` — `docs/codex/parallel-guard-concept-registry.yml` (partial_implementation; source-only)


## Duplicate stable IDs

### 1. Duplicate stable ID: AMB-CODEX-OS-FLAGSHIP-UPGRADE-INSTALL-01

- Conflict ID: `AMB28-duplicate_stable_id-693125`
- Type: `duplicate_stable_id`
- Severity: `yellow`
- Recommended action: `merge`
- Rationale: Duplicate stable IDs must be merged, namespaced, retired, or explicitly classified before Linear sync.
- Linear issue ready: `True`
- Auto-resolved: `False`
- Involved:
  - `AMB-CODEX-OS-FLAGSHIP-UPGRADE-INSTALL-01` — `docs/codex/reports/AMB-CODEX-OS-FLAGSHIP-UPGRADE-INSTALL-01.md` (partial_implementation; release proof)
  - `AMB-CODEX-OS-FLAGSHIP-UPGRADE-INSTALL-01` — `prompts/batches/AMB-CODEX-OS-FLAGSHIP-UPGRADE-INSTALL-01.md` (retired; release proof)

### 2. Duplicate stable ID: AMB-FE-BE-PREFLIGHT-00

- Conflict ID: `AMB28-duplicate_stable_id-85822314`
- Type: `duplicate_stable_id`
- Severity: `yellow`
- Recommended action: `merge`
- Rationale: Duplicate stable IDs must be merged, namespaced, retired, or explicitly classified before Linear sync.
- Linear issue ready: `True`
- Auto-resolved: `False`
- Involved:
  - `AMB-FE-BE-PREFLIGHT-00` — `.codex/reports/AMB-FE-BE-PREFLIGHT-00.md` (partial_implementation; release proof)
  - `AMB-FE-BE-PREFLIGHT-00` — `prompts/batches/amb-fe-be/AMB-FE-BE-PREFLIGHT-00.md` (partial_implementation; release proof)

### 3. Duplicate stable ID: AMB-FILE-BY-FILE-REPO-AUDIT-01

- Conflict ID: `AMB28-duplicate_stable_id-9254712`
- Type: `duplicate_stable_id`
- Severity: `yellow`
- Recommended action: `merge`
- Rationale: Duplicate stable IDs must be merged, namespaced, retired, or explicitly classified before Linear sync.
- Linear issue ready: `True`
- Auto-resolved: `False`
- Involved:
  - `AMB-FILE-BY-FILE-REPO-AUDIT-01` — `prompts/batches/AMB-FILE-BY-FILE-REPO-AUDIT-01.md` (partial_implementation; release proof)
  - `AMB-FILE-BY-FILE-REPO-AUDIT-01` — `docs/audits/AMB-FILE-BY-FILE-REPO-AUDIT-01.md` (partial_implementation; tests)

### 4. Duplicate stable ID: AMB-FLAGSHIP-UI-CODEX-STUDIO-INSTALL-01

- Conflict ID: `AMB28-duplicate_stable_id-52000850`
- Type: `duplicate_stable_id`
- Severity: `yellow`
- Recommended action: `merge`
- Rationale: Duplicate stable IDs must be merged, namespaced, retired, or explicitly classified before Linear sync.
- Linear issue ready: `True`
- Auto-resolved: `False`
- Involved:
  - `AMB-FLAGSHIP-UI-CODEX-STUDIO-INSTALL-01` — `docs/codex/reports/AMB-FLAGSHIP-UI-CODEX-STUDIO-INSTALL-01.md` (partial_implementation; release proof)
  - `AMB-FLAGSHIP-UI-CODEX-STUDIO-INSTALL-01` — `prompts/batches/AMB-FLAGSHIP-UI-CODEX-STUDIO-INSTALL-01.md` (partial_implementation; release proof)
  - `AMB-FLAGSHIP-UI-CODEX-STUDIO-INSTALL-01` — `docs/codex/review-boards/AMB-FLAGSHIP-UI-CODEX-STUDIO-INSTALL-01.md` (unknown; release proof)

### 5. Duplicate stable ID: AMB-POST23-00-COMPLETION-SENTINEL

- Conflict ID: `AMB28-duplicate_stable_id-85016846`
- Type: `duplicate_stable_id`
- Severity: `yellow`
- Recommended action: `merge`
- Rationale: Duplicate stable IDs must be merged, namespaced, retired, or explicitly classified before Linear sync.
- Linear issue ready: `True`
- Auto-resolved: `False`
- Involved:
  - `AMB-POST23-00-COMPLETION-SENTINEL` — `prompts/batches/post-23-truth-audit/AMB-POST23-00-COMPLETION-SENTINEL.md` (partial_implementation; release proof)
  - `AMB-POST23-00-COMPLETION-SENTINEL` — `docs/codex/reports/AMB-POST23-00-COMPLETION-SENTINEL.md` (unknown; release proof)

### 6. Duplicate stable ID: AMB-POST23-01-TRUTH-AUDIT

- Conflict ID: `AMB28-duplicate_stable_id-91474688`
- Type: `duplicate_stable_id`
- Severity: `yellow`
- Recommended action: `merge`
- Rationale: Duplicate stable IDs must be merged, namespaced, retired, or explicitly classified before Linear sync.
- Linear issue ready: `True`
- Auto-resolved: `False`
- Involved:
  - `AMB-POST23-01-TRUTH-AUDIT` — `prompts/batches/post-23-truth-audit/AMB-POST23-01-TRUTH-AUDIT.md` (partial_implementation; release proof)
  - `AMB-POST23-01-TRUTH-AUDIT` — `docs/codex/reports/AMB-POST23-01-TRUTH-AUDIT.md` (partial_implementation; release proof)

### 7. Duplicate stable ID: AMB-POST23-02-UNDERDELIVERY-REPAIR

- Conflict ID: `AMB28-duplicate_stable_id-11554699`
- Type: `duplicate_stable_id`
- Severity: `yellow`
- Recommended action: `merge`
- Rationale: Duplicate stable IDs must be merged, namespaced, retired, or explicitly classified before Linear sync.
- Linear issue ready: `True`
- Auto-resolved: `False`
- Involved:
  - `AMB-POST23-02-UNDERDELIVERY-REPAIR` — `prompts/batches/post-23-truth-audit/AMB-POST23-02-UNDERDELIVERY-REPAIR.md` (partial_implementation; release proof)
  - `AMB-POST23-02-UNDERDELIVERY-REPAIR` — `docs/codex/reports/AMB-POST23-02-UNDERDELIVERY-REPAIR.md` (retired; release proof)

### 8. Duplicate stable ID: AMB-POST23-03-AUTHORITY-CLEANUP-AND-ROUTING

- Conflict ID: `AMB28-duplicate_stable_id-53475089`
- Type: `duplicate_stable_id`
- Severity: `yellow`
- Recommended action: `merge`
- Rationale: Duplicate stable IDs must be merged, namespaced, retired, or explicitly classified before Linear sync.
- Linear issue ready: `True`
- Auto-resolved: `False`
- Involved:
  - `AMB-POST23-03-AUTHORITY-CLEANUP-AND-ROUTING` — `prompts/batches/post-23-truth-audit/AMB-POST23-03-AUTHORITY-CLEANUP-AND-ROUTING.md` (partial_implementation; release proof)
  - `AMB-POST23-03-AUTHORITY-CLEANUP-AND-ROUTING` — `docs/codex/reports/AMB-POST23-03-AUTHORITY-CLEANUP-AND-ROUTING.md` (partial_implementation; release proof)

### 9. Duplicate stable ID: AMB-POST23-04-NEXT-TRAIN-RECOMMENDATION

- Conflict ID: `AMB28-duplicate_stable_id-73505155`
- Type: `duplicate_stable_id`
- Severity: `yellow`
- Recommended action: `merge`
- Rationale: Duplicate stable IDs must be merged, namespaced, retired, or explicitly classified before Linear sync.
- Linear issue ready: `True`
- Auto-resolved: `False`
- Involved:
  - `AMB-POST23-04-NEXT-TRAIN-RECOMMENDATION` — `prompts/batches/post-23-truth-audit/AMB-POST23-04-NEXT-TRAIN-RECOMMENDATION.md` (partial_implementation; release proof)
  - `AMB-POST23-04-NEXT-TRAIN-RECOMMENDATION` — `docs/codex/reports/AMB-POST23-04-NEXT-TRAIN-RECOMMENDATION.md` (partial_implementation; release proof)

### 10. Duplicate stable ID: AMB-REPO-GREEN-FLAGSHIP-RESET-MASTER-01

- Conflict ID: `AMB28-duplicate_stable_id-94671863`
- Type: `duplicate_stable_id`
- Severity: `yellow`
- Recommended action: `merge`
- Rationale: Duplicate stable IDs must be merged, namespaced, retired, or explicitly classified before Linear sync.
- Linear issue ready: `True`
- Auto-resolved: `False`
- Involved:
  - `AMB-REPO-GREEN-FLAGSHIP-RESET-MASTER-01` — `docs/audits/AMB-REPO-GREEN-FLAGSHIP-RESET-MASTER-01.md` (partial_implementation; release proof)
  - `AMB-REPO-GREEN-FLAGSHIP-RESET-MASTER-01` — `prompts/batches/AMB-REPO-GREEN-FLAGSHIP-RESET-MASTER-01.md` (partial_implementation; release proof)
  - `AMB-REPO-GREEN-FLAGSHIP-RESET-MASTER-01` — `docs/audits/AMB-REPO-GREEN-FLAGSHIP-RESET-MASTER-01.json` (unknown; release proof)

### 11. Duplicate stable ID: AMB-REPO-GREEN-FLAGSHIP-RESET-MASTER-01-T03-VOCAB-LEDGER

- Conflict ID: `AMB28-duplicate_stable_id-95935632`
- Type: `duplicate_stable_id`
- Severity: `yellow`
- Recommended action: `merge`
- Rationale: Duplicate stable IDs must be merged, namespaced, retired, or explicitly classified before Linear sync.
- Linear issue ready: `True`
- Auto-resolved: `False`
- Involved:
  - `AMB-REPO-GREEN-FLAGSHIP-RESET-MASTER-01-T03-VOCAB-LEDGER` — `prompts/batches/AMB-REPO-GREEN-FLAGSHIP-RESET-MASTER-01-T03-VOCAB-LEDGER.md` (partial_implementation; release proof)
  - `AMB-REPO-GREEN-FLAGSHIP-RESET-MASTER-01-T03-VOCAB-LEDGER` — `docs/audits/AMB-REPO-GREEN-FLAGSHIP-RESET-MASTER-01-T03-VOCAB-LEDGER.json` (retired; release proof)

### 12. Duplicate stable ID: AMB-REPO-GREEN-FLAGSHIP-RESET-MASTER-01-T05-SOURCE-REFRACTOR-MAP

- Conflict ID: `AMB28-duplicate_stable_id-55950150`
- Type: `duplicate_stable_id`
- Severity: `yellow`
- Recommended action: `merge`
- Rationale: Duplicate stable IDs must be merged, namespaced, retired, or explicitly classified before Linear sync.
- Linear issue ready: `True`
- Auto-resolved: `False`
- Involved:
  - `AMB-REPO-GREEN-FLAGSHIP-RESET-MASTER-01-T05-SOURCE-REFRACTOR-MAP` — `prompts/batches/AMB-REPO-GREEN-FLAGSHIP-RESET-MASTER-01-T05-SOURCE-REFRACTOR-MAP.md` (partial_implementation; release proof)
  - `AMB-REPO-GREEN-FLAGSHIP-RESET-MASTER-01-T05-SOURCE-REFRACTOR-MAP` — `docs/audits/AMB-REPO-GREEN-FLAGSHIP-RESET-MASTER-01-T05-SOURCE-REFRACTOR-MAP.json` (unknown; audit)

### 13. Duplicate stable ID: AMB-REPO-GREEN-FLAGSHIP-RESET-MASTER-01-T17-FINAL-IA-SCAN

- Conflict ID: `AMB28-duplicate_stable_id-67922238`
- Type: `duplicate_stable_id`
- Severity: `yellow`
- Recommended action: `merge`
- Rationale: Duplicate stable IDs must be merged, namespaced, retired, or explicitly classified before Linear sync.
- Linear issue ready: `True`
- Auto-resolved: `False`
- Involved:
  - `AMB-REPO-GREEN-FLAGSHIP-RESET-MASTER-01-T17-FINAL-IA-SCAN` — `prompts/batches/AMB-REPO-GREEN-FLAGSHIP-RESET-MASTER-01-T17-FINAL-IA-SCAN.md` (partial_implementation; release proof)
  - `AMB-REPO-GREEN-FLAGSHIP-RESET-MASTER-01-T17-FINAL-IA-SCAN` — `docs/audits/AMB-REPO-GREEN-FLAGSHIP-RESET-MASTER-01-T17-FINAL-IA-SCAN.json` (retired; audit)

### 14. Duplicate stable ID: AMB_GLOBAL_REMAINING_TRAIN_BLUEPRINT

- Conflict ID: `AMB28-duplicate_stable_id-61366374`
- Type: `duplicate_stable_id`
- Severity: `yellow`
- Recommended action: `merge`
- Rationale: Duplicate stable IDs must be merged, namespaced, retired, or explicitly classified before Linear sync.
- Linear issue ready: `True`
- Auto-resolved: `False`
- Involved:
  - `AMB_GLOBAL_REMAINING_TRAIN_BLUEPRINT` — `docs/codex/AMB_GLOBAL_REMAINING_TRAIN_BLUEPRINT.md` (unknown; release proof)
  - `AMB_GLOBAL_REMAINING_TRAIN_BLUEPRINT` — `docs/codex/AMB_GLOBAL_REMAINING_TRAIN_BLUEPRINT.json` (unknown; tests)

### 15. Duplicate stable ID: AMB_REMAINING_BATCH_REFERENCE

- Conflict ID: `AMB28-duplicate_stable_id-86045984`
- Type: `duplicate_stable_id`
- Severity: `yellow`
- Recommended action: `merge`
- Rationale: Duplicate stable IDs must be merged, namespaced, retired, or explicitly classified before Linear sync.
- Linear issue ready: `True`
- Auto-resolved: `False`
- Involved:
  - `AMB_REMAINING_BATCH_REFERENCE` — `docs/codex/AMB_REMAINING_BATCH_REFERENCE.json` (partial_implementation; release proof)
  - `AMB_REMAINING_BATCH_REFERENCE` — `docs/codex/AMB_REMAINING_BATCH_REFERENCE.md` (partial_implementation; release proof)

### 16. Duplicate stable ID: BL-00

- Conflict ID: `AMB28-duplicate_stable_id-79094643`
- Type: `duplicate_stable_id`
- Severity: `yellow`
- Recommended action: `merge`
- Rationale: Duplicate stable IDs must be merged, namespaced, retired, or explicitly classified before Linear sync.
- Linear issue ready: `True`
- Auto-resolved: `False`
- Involved:
  - `BL-00` — `docs/codex/IOS26_FLAGSHIP_BACKLOG_MAP.md` (partial_implementation; release proof)
  - `BL-00` — `docs/codex/backlog/ios26-flagship-maturation-backlog.md` (partial_implementation; release proof)

### 17. Duplicate stable ID: FE-12-CHROME-CONTRACTS-HARDENING

- Conflict ID: `AMB28-duplicate_stable_id-29712839`
- Type: `duplicate_stable_id`
- Severity: `yellow`
- Recommended action: `merge`
- Rationale: Duplicate stable IDs must be merged, namespaced, retired, or explicitly classified before Linear sync.
- Linear issue ready: `True`
- Auto-resolved: `False`
- Involved:
  - `FE-12-CHROME-CONTRACTS-HARDENING` — `prompts/batches/amb-fe-be/FE-12-CHROME-CONTRACTS-HARDENING.md` (partial_implementation; release proof)
  - `FE-12-CHROME-CONTRACTS-HARDENING` — `docs/codex/reports/FE-12-CHROME-CONTRACTS-HARDENING.md` (partial_implementation; release proof)

### 18. Duplicate stable ID: IOS26-FLAGSHIP

- Conflict ID: `AMB28-duplicate_stable_id-38402213`
- Type: `duplicate_stable_id`
- Severity: `yellow`
- Recommended action: `merge`
- Rationale: Duplicate stable IDs must be merged, namespaced, retired, or explicitly classified before Linear sync.
- Linear issue ready: `True`
- Auto-resolved: `False`
- Involved:
  - `IOS26-FLAGSHIP` — `docs/codex/IOS26_FLAGSHIP_TRAIN_MANIFEST.yml` (partial_implementation; release proof)
  - `IOS26-FLAGSHIP` — `docs/codex/IOS26_FLAGSHIP_EXECUTION_STATE.yml` (partial_implementation; source-only)

### 19. Duplicate stable ID: PK16

- Conflict ID: `AMB28-duplicate_stable_id-15140139`
- Type: `duplicate_stable_id`
- Severity: `yellow`
- Recommended action: `merge`
- Rationale: Duplicate stable IDs must be merged, namespaced, retired, or explicitly classified before Linear sync.
- Linear issue ready: `True`
- Auto-resolved: `False`
- Involved:
  - `PK16` — `docs/codex/batch-prep/PK16.md` (partial_implementation; release proof)
  - `PK16` — `prompts/batches/PK16.md` (canceled; release proof)

### 20. Duplicate stable ID: PK17

- Conflict ID: `AMB28-duplicate_stable_id-6849113`
- Type: `duplicate_stable_id`
- Severity: `yellow`
- Recommended action: `merge`
- Rationale: Duplicate stable IDs must be merged, namespaced, retired, or explicitly classified before Linear sync.
- Linear issue ready: `True`
- Auto-resolved: `False`
- Involved:
  - `PK17` — `docs/codex/batch-prep/PK17.md` (partial_implementation; release proof)
  - `PK17` — `prompts/batches/PK17.md` (partial_implementation; release proof)

### 21. Duplicate stable ID: PK18

- Conflict ID: `AMB28-duplicate_stable_id-91577919`
- Type: `duplicate_stable_id`
- Severity: `yellow`
- Recommended action: `merge`
- Rationale: Duplicate stable IDs must be merged, namespaced, retired, or explicitly classified before Linear sync.
- Linear issue ready: `True`
- Auto-resolved: `False`
- Involved:
  - `PK18` — `docs/codex/batch-prep/PK18.md` (partial_implementation; release proof)
  - `PK18` — `prompts/batches/PK18.md` (partial_implementation; release proof)

### 22. Duplicate stable ID: PK19

- Conflict ID: `AMB28-duplicate_stable_id-37000088`
- Type: `duplicate_stable_id`
- Severity: `yellow`
- Recommended action: `merge`
- Rationale: Duplicate stable IDs must be merged, namespaced, retired, or explicitly classified before Linear sync.
- Linear issue ready: `True`
- Auto-resolved: `False`
- Involved:
  - `PK19` — `docs/codex/batch-prep/PK19.md` (partial_implementation; release proof)
  - `PK19` — `prompts/batches/PK19.md` (partial_implementation; release proof)

### 23. Duplicate stable ID: PK20

- Conflict ID: `AMB28-duplicate_stable_id-3545730`
- Type: `duplicate_stable_id`
- Severity: `yellow`
- Recommended action: `merge`
- Rationale: Duplicate stable IDs must be merged, namespaced, retired, or explicitly classified before Linear sync.
- Linear issue ready: `True`
- Auto-resolved: `False`
- Involved:
  - `PK20` — `docs/codex/batch-prep/PK20.md` (partial_implementation; release proof)
  - `PK20` — `prompts/batches/PK20.md` (partial_implementation; release proof)

### 24. Duplicate stable ID: PK21

- Conflict ID: `AMB28-duplicate_stable_id-43519628`
- Type: `duplicate_stable_id`
- Severity: `yellow`
- Recommended action: `merge`
- Rationale: Duplicate stable IDs must be merged, namespaced, retired, or explicitly classified before Linear sync.
- Linear issue ready: `True`
- Auto-resolved: `False`
- Involved:
  - `PK21` — `docs/codex/batch-prep/PK21.md` (partial_implementation; release proof)
  - `PK21` — `prompts/batches/PK21.md` (partial_implementation; release proof)

### 25. Duplicate stable ID: PK22

- Conflict ID: `AMB28-duplicate_stable_id-46410121`
- Type: `duplicate_stable_id`
- Severity: `yellow`
- Recommended action: `merge`
- Rationale: Duplicate stable IDs must be merged, namespaced, retired, or explicitly classified before Linear sync.
- Linear issue ready: `True`
- Auto-resolved: `False`
- Involved:
  - `PK22` — `docs/codex/batch-prep/PK22.md` (partial_implementation; release proof)
  - `PK22` — `prompts/batches/PK22.md` (partial_implementation; release proof)

### 26. Duplicate stable ID: PK23

- Conflict ID: `AMB28-duplicate_stable_id-52760950`
- Type: `duplicate_stable_id`
- Severity: `yellow`
- Recommended action: `merge`
- Rationale: Duplicate stable IDs must be merged, namespaced, retired, or explicitly classified before Linear sync.
- Linear issue ready: `True`
- Auto-resolved: `False`
- Involved:
  - `PK23` — `docs/codex/batch-prep/PK23.md` (partial_implementation; release proof)
  - `PK23` — `prompts/batches/PK23.md` (partial_implementation; release proof)

### 27. Duplicate stable ID: PK24

- Conflict ID: `AMB28-duplicate_stable_id-97443674`
- Type: `duplicate_stable_id`
- Severity: `yellow`
- Recommended action: `merge`
- Rationale: Duplicate stable IDs must be merged, namespaced, retired, or explicitly classified before Linear sync.
- Linear issue ready: `True`
- Auto-resolved: `False`
- Involved:
  - `PK24` — `docs/codex/batch-prep/PK24.md` (partial_implementation; release proof)
  - `PK24` — `prompts/batches/PK24.md` (partial_implementation; release proof)

### 28. Duplicate stable ID: PK25

- Conflict ID: `AMB28-duplicate_stable_id-57589858`
- Type: `duplicate_stable_id`
- Severity: `yellow`
- Recommended action: `merge`
- Rationale: Duplicate stable IDs must be merged, namespaced, retired, or explicitly classified before Linear sync.
- Linear issue ready: `True`
- Auto-resolved: `False`
- Involved:
  - `PK25` — `docs/codex/batch-prep/PK25.md` (partial_implementation; release proof)
  - `PK25` — `prompts/batches/PK25.md` (partial_implementation; release proof)

### 29. Duplicate stable ID: POST99-UI-SUITE-REVIEW-IMPLEMENTATION-00

- Conflict ID: `AMB28-duplicate_stable_id-92739335`
- Type: `duplicate_stable_id`
- Severity: `yellow`
- Recommended action: `merge`
- Rationale: Duplicate stable IDs must be merged, namespaced, retired, or explicitly classified before Linear sync.
- Linear issue ready: `True`
- Auto-resolved: `False`
- Involved:
  - `POST99-UI-SUITE-REVIEW-IMPLEMENTATION-00` — `docs/codex/reports/POST99-UI-SUITE-REVIEW-IMPLEMENTATION-00.md` (partial_implementation; release proof)
  - `POST99-UI-SUITE-REVIEW-IMPLEMENTATION-00` — `prompts/batches/POST99-UI-SUITE-REVIEW-IMPLEMENTATION-00.md` (retired; release proof)

### 30. Duplicate stable ID: README

- Conflict ID: `AMB28-duplicate_stable_id-2857785`
- Type: `duplicate_stable_id`
- Severity: `yellow`
- Recommended action: `merge`
- Rationale: Duplicate stable IDs must be merged, namespaced, retired, or explicitly classified before Linear sync.
- Linear issue ready: `True`
- Auto-resolved: `False`
- Involved:
  - `README` — `build/reports/source-atlas-runtime-bridge/README.md` (implemented; release proof)
  - `README` — `build/reports/step-optionality/README.md` (implemented; release proof)
  - `README` — `docs/codex/batch-prep/README.md` (partial_implementation; release proof)
  - `README` — `docs/codex/batch-trains/amb-fe-be/README.md` (partial_implementation; release proof)
  - `README` — `docs/codex/chatgpt/README.md` (partial_implementation; release proof)
  - `README` — `docs/codex/os/README.md` (partial_implementation; release proof)
  - `README` — `docs/codex/batch-trains/post99-ui-suite/README.md` (partial_implementation; release proof)
  - `README` — `prompts/trains/ios26-flagship/README.md` (partial_implementation; release proof)
  - `README` — `docs/codex/linear-templates/README.md` (partial_implementation; release proof)
  - `README` — `.codex/README.md` (unknown; release proof)
  - `README` — `.codex/skills/README.md` (unknown; release proof)
  - `README` — `docs/codex/batch-trains/README.md` (unknown; release proof)
  - `README` — `docs/audits/README.md` (unknown; release proof)
  - `README` — `.codex/skills/ambitions/README.md` (unknown; release proof)
  - `README` — `build/reports/ios26-baseline/README.md` (unknown; release proof)
  - `README` — `build/reports/life-context/README.md` (unknown; release proof)
  - `README` — `.codex/evals/README.md` (unknown; audit)
  - `README` — `.codex/improvement/README.md` (unknown; audit)
  - `README` — `.codex/operations/README.md` (unknown; audit)
  - `README` — `.codex/checklists/README.md` (unknown; audit)
  - ... 9 more

### 31. Duplicate stable ID: existing-code-champion-coverage

- Conflict ID: `AMB28-duplicate_stable_id-42337306`
- Type: `duplicate_stable_id`
- Severity: `yellow`
- Recommended action: `merge`
- Rationale: Duplicate stable IDs must be merged, namespaced, retired, or explicitly classified before Linear sync.
- Linear issue ready: `True`
- Auto-resolved: `False`
- Involved:
  - `existing-code-champion-coverage` — `build/reports/intelligence-consolidation/existing-code-champion-coverage.json` (unknown; release proof)
  - `existing-code-champion-coverage` — `docs/codex/existing-code-champion-coverage.yml` (unknown; release proof)


## Stale or unknown active statuses

### 1. Unknown active status: AMB-CHATGPT-APP-STORE-HONESTY-PROMPT-TEMPLATE

- Conflict ID: `AMB28-stale_or_unknown_active_status-38474898`
- Type: `stale_or_unknown_active_status`
- Severity: `yellow`
- Recommended action: `expedite`
- Rationale: Unknown active batch/prompt/train status should be clarified before it blocks or duplicates future work.
- Linear issue ready: `True`
- Auto-resolved: `False`
- Involved:
  - `AMB-CHATGPT-APP-STORE-HONESTY-PROMPT-TEMPLATE` — `docs/codex/chatgpt/AMB-CHATGPT-APP-STORE-HONESTY-PROMPT-TEMPLATE.md` (unknown; release proof)

### 2. Unknown active status: AMB-CHATGPT-APPLE-CONTINUITY-PROMPT-TEMPLATE

- Conflict ID: `AMB28-stale_or_unknown_active_status-76197336`
- Type: `stale_or_unknown_active_status`
- Severity: `yellow`
- Recommended action: `expedite`
- Rationale: Unknown active batch/prompt/train status should be clarified before it blocks or duplicates future work.
- Linear issue ready: `True`
- Auto-resolved: `False`
- Involved:
  - `AMB-CHATGPT-APPLE-CONTINUITY-PROMPT-TEMPLATE` — `docs/codex/chatgpt/AMB-CHATGPT-APPLE-CONTINUITY-PROMPT-TEMPLATE.md` (unknown; release proof)

### 3. Unknown active status: AMB-CHATGPT-BACKEND-PROMPT-TEMPLATE

- Conflict ID: `AMB28-stale_or_unknown_active_status-42484670`
- Type: `stale_or_unknown_active_status`
- Severity: `yellow`
- Recommended action: `expedite`
- Rationale: Unknown active batch/prompt/train status should be clarified before it blocks or duplicates future work.
- Linear issue ready: `True`
- Auto-resolved: `False`
- Involved:
  - `AMB-CHATGPT-BACKEND-PROMPT-TEMPLATE` — `docs/codex/chatgpt/AMB-CHATGPT-BACKEND-PROMPT-TEMPLATE.md` (unknown; release proof)

### 4. Unknown active status: AMB-CHATGPT-CODEX-HANDOFF-TEMPLATE

- Conflict ID: `AMB28-stale_or_unknown_active_status-75651105`
- Type: `stale_or_unknown_active_status`
- Severity: `yellow`
- Recommended action: `expedite`
- Rationale: Unknown active batch/prompt/train status should be clarified before it blocks or duplicates future work.
- Linear issue ready: `True`
- Auto-resolved: `False`
- Involved:
  - `AMB-CHATGPT-CODEX-HANDOFF-TEMPLATE` — `docs/codex/chatgpt/AMB-CHATGPT-CODEX-HANDOFF-TEMPLATE.md` (unknown; release proof)

### 5. Unknown active status: AMB-CHATGPT-DECISION-LOG-STANDARD

- Conflict ID: `AMB28-stale_or_unknown_active_status-23787270`
- Type: `stale_or_unknown_active_status`
- Severity: `yellow`
- Recommended action: `expedite`
- Rationale: Unknown active batch/prompt/train status should be clarified before it blocks or duplicates future work.
- Linear issue ready: `True`
- Auto-resolved: `False`
- Involved:
  - `AMB-CHATGPT-DECISION-LOG-STANDARD` — `docs/codex/chatgpt/AMB-CHATGPT-DECISION-LOG-STANDARD.md` (unknown; release proof)

### 6. Unknown active status: AMB-CHATGPT-FLAGSHIP-BAR

- Conflict ID: `AMB28-stale_or_unknown_active_status-70119246`
- Type: `stale_or_unknown_active_status`
- Severity: `yellow`
- Recommended action: `expedite`
- Rationale: Unknown active batch/prompt/train status should be clarified before it blocks or duplicates future work.
- Linear issue ready: `True`
- Auto-resolved: `False`
- Involved:
  - `AMB-CHATGPT-FLAGSHIP-BAR` — `docs/codex/chatgpt/AMB-CHATGPT-FLAGSHIP-BAR.md` (unknown; release proof)

### 7. Unknown active status: AMB-CHATGPT-HANDOFF-OS

- Conflict ID: `AMB28-stale_or_unknown_active_status-93383709`
- Type: `stale_or_unknown_active_status`
- Severity: `yellow`
- Recommended action: `expedite`
- Rationale: Unknown active batch/prompt/train status should be clarified before it blocks or duplicates future work.
- Linear issue ready: `True`
- Auto-resolved: `False`
- Involved:
  - `AMB-CHATGPT-HANDOFF-OS` — `docs/codex/chatgpt/AMB-CHATGPT-HANDOFF-OS.md` (unknown; release proof)

### 8. Unknown active status: AMB-CHATGPT-LAUNCH-SCOPE-DECISIONS

- Conflict ID: `AMB28-stale_or_unknown_active_status-11434175`
- Type: `stale_or_unknown_active_status`
- Severity: `yellow`
- Recommended action: `expedite`
- Rationale: Unknown active batch/prompt/train status should be clarified before it blocks or duplicates future work.
- Linear issue ready: `True`
- Auto-resolved: `False`
- Involved:
  - `AMB-CHATGPT-LAUNCH-SCOPE-DECISIONS` — `docs/codex/chatgpt/AMB-CHATGPT-LAUNCH-SCOPE-DECISIONS.md` (unknown; release proof)

### 9. Unknown active status: AMB-CHATGPT-REPO-QUESTION-PATTERNS

- Conflict ID: `AMB28-stale_or_unknown_active_status-77548275`
- Type: `stale_or_unknown_active_status`
- Severity: `yellow`
- Recommended action: `expedite`
- Rationale: Unknown active batch/prompt/train status should be clarified before it blocks or duplicates future work.
- Linear issue ready: `True`
- Auto-resolved: `False`
- Involved:
  - `AMB-CHATGPT-REPO-QUESTION-PATTERNS` — `docs/codex/chatgpt/AMB-CHATGPT-REPO-QUESTION-PATTERNS.md` (unknown; release proof)

### 10. Unknown active status: AMB-CHATGPT-REVIEW-BOARD-STANDARD

- Conflict ID: `AMB28-stale_or_unknown_active_status-81501313`
- Type: `stale_or_unknown_active_status`
- Severity: `yellow`
- Recommended action: `expedite`
- Rationale: Unknown active batch/prompt/train status should be clarified before it blocks or duplicates future work.
- Linear issue ready: `True`
- Auto-resolved: `False`
- Involved:
  - `AMB-CHATGPT-REVIEW-BOARD-STANDARD` — `docs/codex/chatgpt/AMB-CHATGPT-REVIEW-BOARD-STANDARD.md` (unknown; release proof)

### 11. Unknown active status: AMB-CHATGPT-REVIEW-PROMPT-TEMPLATE

- Conflict ID: `AMB28-stale_or_unknown_active_status-53826811`
- Type: `stale_or_unknown_active_status`
- Severity: `yellow`
- Recommended action: `expedite`
- Rationale: Unknown active batch/prompt/train status should be clarified before it blocks or duplicates future work.
- Linear issue ready: `True`
- Auto-resolved: `False`
- Involved:
  - `AMB-CHATGPT-REVIEW-PROMPT-TEMPLATE` — `docs/codex/chatgpt/AMB-CHATGPT-REVIEW-PROMPT-TEMPLATE.md` (unknown; release proof)

### 12. Unknown active status: AMB-CHATGPT-TO-CODEX-PROMPT-STANDARD

- Conflict ID: `AMB28-stale_or_unknown_active_status-85289300`
- Type: `stale_or_unknown_active_status`
- Severity: `yellow`
- Recommended action: `expedite`
- Rationale: Unknown active batch/prompt/train status should be clarified before it blocks or duplicates future work.
- Linear issue ready: `True`
- Auto-resolved: `False`
- Involved:
  - `AMB-CHATGPT-TO-CODEX-PROMPT-STANDARD` — `docs/codex/chatgpt/AMB-CHATGPT-TO-CODEX-PROMPT-STANDARD.md` (unknown; release proof)

### 13. Unknown active status: AMB-CHATGPT-UI-PROMPT-TEMPLATE

- Conflict ID: `AMB28-stale_or_unknown_active_status-32927860`
- Type: `stale_or_unknown_active_status`
- Severity: `yellow`
- Recommended action: `expedite`
- Rationale: Unknown active batch/prompt/train status should be clarified before it blocks or duplicates future work.
- Linear issue ready: `True`
- Auto-resolved: `False`
- Involved:
  - `AMB-CHATGPT-UI-PROMPT-TEMPLATE` — `docs/codex/chatgpt/AMB-CHATGPT-UI-PROMPT-TEMPLATE.md` (unknown; release proof)

### 14. Unknown active status: AMB-CODEX-OS-APPLE-CONTINUITY-GATE

- Conflict ID: `AMB28-stale_or_unknown_active_status-85109665`
- Type: `stale_or_unknown_active_status`
- Severity: `yellow`
- Recommended action: `expedite`
- Rationale: Unknown active batch/prompt/train status should be clarified before it blocks or duplicates future work.
- Linear issue ready: `True`
- Auto-resolved: `False`
- Involved:
  - `AMB-CODEX-OS-APPLE-CONTINUITY-GATE` — `docs/codex/os/AMB-CODEX-OS-APPLE-CONTINUITY-GATE.md` (unknown; release proof)

### 15. Unknown active status: AMB-CODEX-OS-AUTHORITY-RESOLVER

- Conflict ID: `AMB28-stale_or_unknown_active_status-52398128`
- Type: `stale_or_unknown_active_status`
- Severity: `yellow`
- Recommended action: `expedite`
- Rationale: Unknown active batch/prompt/train status should be clarified before it blocks or duplicates future work.
- Linear issue ready: `True`
- Auto-resolved: `False`
- Involved:
  - `AMB-CODEX-OS-AUTHORITY-RESOLVER` — `docs/codex/os/AMB-CODEX-OS-AUTHORITY-RESOLVER.md` (unknown; release proof)

### 16. Unknown active status: AMB-CODEX-OS-LAUNCH-BELIEVABILITY-GATE

- Conflict ID: `AMB28-stale_or_unknown_active_status-47344552`
- Type: `stale_or_unknown_active_status`
- Severity: `yellow`
- Recommended action: `expedite`
- Rationale: Unknown active batch/prompt/train status should be clarified before it blocks or duplicates future work.
- Linear issue ready: `True`
- Auto-resolved: `False`
- Involved:
  - `AMB-CODEX-OS-LAUNCH-BELIEVABILITY-GATE` — `docs/codex/os/AMB-CODEX-OS-LAUNCH-BELIEVABILITY-GATE.md` (unknown; release proof)

### 17. Unknown active status: AMB-CODEX-OS-NO-SPRAWL-GUARD

- Conflict ID: `AMB28-stale_or_unknown_active_status-94517630`
- Type: `stale_or_unknown_active_status`
- Severity: `yellow`
- Recommended action: `expedite`
- Rationale: Unknown active batch/prompt/train status should be clarified before it blocks or duplicates future work.
- Linear issue ready: `True`
- Auto-resolved: `False`
- Involved:
  - `AMB-CODEX-OS-NO-SPRAWL-GUARD` — `docs/codex/os/AMB-CODEX-OS-NO-SPRAWL-GUARD.md` (unknown; release proof)

### 18. Unknown active status: AMB-CODEX-OS-PRIVACY-CLAIM-GATE

- Conflict ID: `AMB28-stale_or_unknown_active_status-97077901`
- Type: `stale_or_unknown_active_status`
- Severity: `yellow`
- Recommended action: `expedite`
- Rationale: Unknown active batch/prompt/train status should be clarified before it blocks or duplicates future work.
- Linear issue ready: `True`
- Auto-resolved: `False`
- Involved:
  - `AMB-CODEX-OS-PRIVACY-CLAIM-GATE` — `docs/codex/os/AMB-CODEX-OS-PRIVACY-CLAIM-GATE.md` (unknown; release proof)

### 19. Unknown active status: AMB-CODEX-OS-PROOF-LEDGER

- Conflict ID: `AMB28-stale_or_unknown_active_status-34129986`
- Type: `stale_or_unknown_active_status`
- Severity: `yellow`
- Recommended action: `expedite`
- Rationale: Unknown active batch/prompt/train status should be clarified before it blocks or duplicates future work.
- Linear issue ready: `True`
- Auto-resolved: `False`
- Involved:
  - `AMB-CODEX-OS-PROOF-LEDGER` — `docs/codex/os/AMB-CODEX-OS-PROOF-LEDGER.md` (unknown; release proof)

### 20. Unknown active status: AMB-CODEX-OS-VISUAL-QA-GATE

- Conflict ID: `AMB28-stale_or_unknown_active_status-79388666`
- Type: `stale_or_unknown_active_status`
- Severity: `yellow`
- Recommended action: `expedite`
- Rationale: Unknown active batch/prompt/train status should be clarified before it blocks or duplicates future work.
- Linear issue ready: `True`
- Auto-resolved: `False`
- Involved:
  - `AMB-CODEX-OS-VISUAL-QA-GATE` — `docs/codex/os/AMB-CODEX-OS-VISUAL-QA-GATE.md` (unknown; release proof)

### 21. Unknown active status: AMB-FLAGSHIP-UI-CODEX-STUDIO-INSTALL-01

- Conflict ID: `AMB28-stale_or_unknown_active_status-47418051`
- Type: `stale_or_unknown_active_status`
- Severity: `yellow`
- Recommended action: `expedite`
- Rationale: Unknown active batch/prompt/train status should be clarified before it blocks or duplicates future work.
- Linear issue ready: `True`
- Auto-resolved: `False`
- Involved:
  - `AMB-FLAGSHIP-UI-CODEX-STUDIO-INSTALL-01` — `docs/codex/review-boards/AMB-FLAGSHIP-UI-CODEX-STUDIO-INSTALL-01.md` (unknown; release proof)

### 22. Unknown active status: AMB-POST23-00-COMPLETION-SENTINEL

- Conflict ID: `AMB28-stale_or_unknown_active_status-38333297`
- Type: `stale_or_unknown_active_status`
- Severity: `yellow`
- Recommended action: `expedite`
- Rationale: Unknown active batch/prompt/train status should be clarified before it blocks or duplicates future work.
- Linear issue ready: `True`
- Auto-resolved: `False`
- Involved:
  - `AMB-POST23-00-COMPLETION-SENTINEL` — `docs/codex/reports/AMB-POST23-00-COMPLETION-SENTINEL.md` (unknown; release proof)

### 23. Unknown active status: AMBITIONSOS_AOS_FIXTURE_STRATEGY

- Conflict ID: `AMB28-stale_or_unknown_active_status-55104994`
- Type: `stale_or_unknown_active_status`
- Severity: `yellow`
- Recommended action: `expedite`
- Rationale: Unknown active batch/prompt/train status should be clarified before it blocks or duplicates future work.
- Linear issue ready: `True`
- Auto-resolved: `False`
- Involved:
  - `AMBITIONSOS_AOS_FIXTURE_STRATEGY` — `docs/codex/AMBITIONSOS_AOS_FIXTURE_STRATEGY.md` (unknown; release proof)

### 24. Unknown active status: AMBITIONSOS_AOS_MODEL_BOUNDARY_PROTOCOL

- Conflict ID: `AMB28-stale_or_unknown_active_status-6809573`
- Type: `stale_or_unknown_active_status`
- Severity: `yellow`
- Recommended action: `expedite`
- Rationale: Unknown active batch/prompt/train status should be clarified before it blocks or duplicates future work.
- Linear issue ready: `True`
- Auto-resolved: `False`
- Involved:
  - `AMBITIONSOS_AOS_MODEL_BOUNDARY_PROTOCOL` — `docs/codex/AMBITIONSOS_AOS_MODEL_BOUNDARY_PROTOCOL.md` (unknown; release proof)

### 25. Unknown active status: AMBITIONSOS_AOS_PERFORMANCE_ENERGY_BUDGET

- Conflict ID: `AMB28-stale_or_unknown_active_status-9443016`
- Type: `stale_or_unknown_active_status`
- Severity: `yellow`
- Recommended action: `expedite`
- Rationale: Unknown active batch/prompt/train status should be clarified before it blocks or duplicates future work.
- Linear issue ready: `True`
- Auto-resolved: `False`
- Involved:
  - `AMBITIONSOS_AOS_PERFORMANCE_ENERGY_BUDGET` — `docs/codex/AMBITIONSOS_AOS_PERFORMANCE_ENERGY_BUDGET.md` (unknown; release proof)

### 26. Unknown active status: AMBITIONSOS_AOS_PRIVACY_PROJECTION_LEDGER

- Conflict ID: `AMB28-stale_or_unknown_active_status-54443553`
- Type: `stale_or_unknown_active_status`
- Severity: `yellow`
- Recommended action: `expedite`
- Rationale: Unknown active batch/prompt/train status should be clarified before it blocks or duplicates future work.
- Linear issue ready: `True`
- Auto-resolved: `False`
- Involved:
  - `AMBITIONSOS_AOS_PRIVACY_PROJECTION_LEDGER` — `docs/codex/AMBITIONSOS_AOS_PRIVACY_PROJECTION_LEDGER.md` (unknown; release proof)

### 27. Unknown active status: AMBITIONSOS_AOS_RED_TEAM_PROTOCOL

- Conflict ID: `AMB28-stale_or_unknown_active_status-39687124`
- Type: `stale_or_unknown_active_status`
- Severity: `yellow`
- Recommended action: `expedite`
- Rationale: Unknown active batch/prompt/train status should be clarified before it blocks or duplicates future work.
- Linear issue ready: `True`
- Auto-resolved: `False`
- Involved:
  - `AMBITIONSOS_AOS_RED_TEAM_PROTOCOL` — `docs/codex/AMBITIONSOS_AOS_RED_TEAM_PROTOCOL.md` (unknown; release proof)

### 28. Unknown active status: AMBITIONSOS_AOS_SCHEMA_AND_MIGRATION_PROTOCOL

- Conflict ID: `AMB28-stale_or_unknown_active_status-55616240`
- Type: `stale_or_unknown_active_status`
- Severity: `yellow`
- Recommended action: `expedite`
- Rationale: Unknown active batch/prompt/train status should be clarified before it blocks or duplicates future work.
- Linear issue ready: `True`
- Auto-resolved: `False`
- Involved:
  - `AMBITIONSOS_AOS_SCHEMA_AND_MIGRATION_PROTOCOL` — `docs/codex/AMBITIONSOS_AOS_SCHEMA_AND_MIGRATION_PROTOCOL.md` (unknown; release proof)

### 29. Unknown active status: AMBITIONSOS_AOS_SIMULATION_STRATEGY

- Conflict ID: `AMB28-stale_or_unknown_active_status-72319134`
- Type: `stale_or_unknown_active_status`
- Severity: `yellow`
- Recommended action: `expedite`
- Rationale: Unknown active batch/prompt/train status should be clarified before it blocks or duplicates future work.
- Linear issue ready: `True`
- Auto-resolved: `False`
- Involved:
  - `AMBITIONSOS_AOS_SIMULATION_STRATEGY` — `docs/codex/AMBITIONSOS_AOS_SIMULATION_STRATEGY.md` (unknown; release proof)

### 30. Unknown active status: AMBITIONSOS_AOS_SOURCE_TRUTH_CLAIM_LEDGER

- Conflict ID: `AMB28-stale_or_unknown_active_status-46616803`
- Type: `stale_or_unknown_active_status`
- Severity: `yellow`
- Recommended action: `expedite`
- Rationale: Unknown active batch/prompt/train status should be clarified before it blocks or duplicates future work.
- Linear issue ready: `True`
- Auto-resolved: `False`
- Involved:
  - `AMBITIONSOS_AOS_SOURCE_TRUTH_CLAIM_LEDGER` — `docs/codex/AMBITIONSOS_AOS_SOURCE_TRUTH_CLAIM_LEDGER.md` (unknown; release proof)

### 31. Unknown active status: AMBITIONS_3_0_PARALLEL_CODEX_WORKTREE_PROTOCOL

- Conflict ID: `AMB28-stale_or_unknown_active_status-28650524`
- Type: `stale_or_unknown_active_status`
- Severity: `yellow`
- Recommended action: `expedite`
- Rationale: Unknown active batch/prompt/train status should be clarified before it blocks or duplicates future work.
- Linear issue ready: `True`
- Auto-resolved: `False`
- Involved:
  - `AMBITIONS_3_0_PARALLEL_CODEX_WORKTREE_PROTOCOL` — `docs/codex/AMBITIONS_3_0_PARALLEL_CODEX_WORKTREE_PROTOCOL.md` (unknown; release proof)

### 32. Unknown active status: AMBITIONS_3_0_RUN_STATE_PROTOCOL

- Conflict ID: `AMB28-stale_or_unknown_active_status-41801480`
- Type: `stale_or_unknown_active_status`
- Severity: `yellow`
- Recommended action: `expedite`
- Rationale: Unknown active batch/prompt/train status should be clarified before it blocks or duplicates future work.
- Linear issue ready: `True`
- Auto-resolved: `False`
- Involved:
  - `AMBITIONS_3_0_RUN_STATE_PROTOCOL` — `docs/codex/AMBITIONS_3_0_RUN_STATE_PROTOCOL.md` (unknown; release proof)

### 33. Unknown active status: AMBITIONS_3_0_SKILL_SYSTEM_INDEX

- Conflict ID: `AMB28-stale_or_unknown_active_status-37656025`
- Type: `stale_or_unknown_active_status`
- Severity: `yellow`
- Recommended action: `expedite`
- Rationale: Unknown active batch/prompt/train status should be clarified before it blocks or duplicates future work.
- Linear issue ready: `True`
- Auto-resolved: `False`
- Involved:
  - `AMBITIONS_3_0_SKILL_SYSTEM_INDEX` — `docs/codex/AMBITIONS_3_0_SKILL_SYSTEM_INDEX.md` (unknown; release proof)

### 34. Unknown active status: AMB_GLOBAL_REMAINING_TRAIN_BLUEPRINT

- Conflict ID: `AMB28-stale_or_unknown_active_status-9861856`
- Type: `stale_or_unknown_active_status`
- Severity: `yellow`
- Recommended action: `expedite`
- Rationale: Unknown active batch/prompt/train status should be clarified before it blocks or duplicates future work.
- Linear issue ready: `True`
- Auto-resolved: `False`
- Involved:
  - `AMB_GLOBAL_REMAINING_TRAIN_BLUEPRINT` — `docs/codex/AMB_GLOBAL_REMAINING_TRAIN_BLUEPRINT.md` (unknown; release proof)

### 35. Unknown active status: AMB_GLOBAL_REMAINING_TRAIN_BLUEPRINT

- Conflict ID: `AMB28-stale_or_unknown_active_status-22142219`
- Type: `stale_or_unknown_active_status`
- Severity: `yellow`
- Recommended action: `expedite`
- Rationale: Unknown active batch/prompt/train status should be clarified before it blocks or duplicates future work.
- Linear issue ready: `True`
- Auto-resolved: `False`
- Involved:
  - `AMB_GLOBAL_REMAINING_TRAIN_BLUEPRINT` — `docs/codex/AMB_GLOBAL_REMAINING_TRAIN_BLUEPRINT.json` (unknown; tests)

### 36. Unknown active status: AQOS_BATCH_IMPACT_CLASSIFIER

- Conflict ID: `AMB28-stale_or_unknown_active_status-77716034`
- Type: `stale_or_unknown_active_status`
- Severity: `yellow`
- Recommended action: `expedite`
- Rationale: Unknown active batch/prompt/train status should be clarified before it blocks or duplicates future work.
- Linear issue ready: `True`
- Auto-resolved: `False`
- Involved:
  - `AQOS_BATCH_IMPACT_CLASSIFIER` — `docs/codex/quality/AQOS_BATCH_IMPACT_CLASSIFIER.md` (unknown; release proof)

### 37. Unknown active status: AQOS_EVIDENCE_MATURITY_LEDGER

- Conflict ID: `AMB28-stale_or_unknown_active_status-71159218`
- Type: `stale_or_unknown_active_status`
- Severity: `yellow`
- Recommended action: `expedite`
- Rationale: Unknown active batch/prompt/train status should be clarified before it blocks or duplicates future work.
- Linear issue ready: `True`
- Auto-resolved: `False`
- Involved:
  - `AQOS_EVIDENCE_MATURITY_LEDGER` — `docs/codex/quality/AQOS_EVIDENCE_MATURITY_LEDGER.md` (unknown; release proof)

### 38. Unknown active status: BATCH-00-repo-operating-system

- Conflict ID: `AMB28-stale_or_unknown_active_status-14528330`
- Type: `stale_or_unknown_active_status`
- Severity: `yellow`
- Recommended action: `expedite`
- Rationale: Unknown active batch/prompt/train status should be clarified before it blocks or duplicates future work.
- Linear issue ready: `True`
- Auto-resolved: `False`
- Involved:
  - `BATCH-00-repo-operating-system` — `docs/codex/batches/BATCH-00-repo-operating-system.md` (unknown; release proof)

### 39. Unknown active status: BATCH-01-pre-phase9-cleanup-and-captures-tab

- Conflict ID: `AMB28-stale_or_unknown_active_status-59288798`
- Type: `stale_or_unknown_active_status`
- Severity: `yellow`
- Recommended action: `expedite`
- Rationale: Unknown active batch/prompt/train status should be clarified before it blocks or duplicates future work.
- Linear issue ready: `True`
- Auto-resolved: `False`
- Involved:
  - `BATCH-01-pre-phase9-cleanup-and-captures-tab` — `docs/codex/batches/BATCH-01-pre-phase9-cleanup-and-captures-tab.md` (unknown; release proof)

### 40. Unknown active status: BATCH-02-delete-legacy-typescript-runtime

- Conflict ID: `AMB28-stale_or_unknown_active_status-76635596`
- Type: `stale_or_unknown_active_status`
- Severity: `yellow`
- Recommended action: `expedite`
- Rationale: Unknown active batch/prompt/train status should be clarified before it blocks or duplicates future work.
- Linear issue ready: `True`
- Auto-resolved: `False`
- Involved:
  - `BATCH-02-delete-legacy-typescript-runtime` — `docs/codex/batches/BATCH-02-delete-legacy-typescript-runtime.md` (unknown; release proof)

### 41. Unknown active status: BATCH-03-canon-batch-1-domain-foundation

- Conflict ID: `AMB28-stale_or_unknown_active_status-66328633`
- Type: `stale_or_unknown_active_status`
- Severity: `yellow`
- Recommended action: `expedite`
- Rationale: Unknown active batch/prompt/train status should be clarified before it blocks or duplicates future work.
- Linear issue ready: `True`
- Auto-resolved: `False`
- Involved:
  - `BATCH-03-canon-batch-1-domain-foundation` — `docs/codex/batches/BATCH-03-canon-batch-1-domain-foundation.md` (unknown; release proof)

### 42. Unknown active status: BATCH-04-canon-batch-2-first-class-capture-core

- Conflict ID: `AMB28-stale_or_unknown_active_status-1931371`
- Type: `stale_or_unknown_active_status`
- Severity: `yellow`
- Recommended action: `expedite`
- Rationale: Unknown active batch/prompt/train status should be clarified before it blocks or duplicates future work.
- Linear issue ready: `True`
- Auto-resolved: `False`
- Involved:
  - `BATCH-04-canon-batch-2-first-class-capture-core` — `docs/codex/batches/BATCH-04-canon-batch-2-first-class-capture-core.md` (unknown; release proof)

### 43. Unknown active status: BATCH-05-canon-batch-3-planning-engine-v2

- Conflict ID: `AMB28-stale_or_unknown_active_status-43748577`
- Type: `stale_or_unknown_active_status`
- Severity: `yellow`
- Recommended action: `expedite`
- Rationale: Unknown active batch/prompt/train status should be clarified before it blocks or duplicates future work.
- Linear issue ready: `True`
- Auto-resolved: `False`
- Involved:
  - `BATCH-05-canon-batch-3-planning-engine-v2` — `docs/codex/batches/BATCH-05-canon-batch-3-planning-engine-v2.md` (unknown; release proof)

### 44. Unknown active status: BATCH-06-canon-batch-4-recovery-engine

- Conflict ID: `AMB28-stale_or_unknown_active_status-32262277`
- Type: `stale_or_unknown_active_status`
- Severity: `yellow`
- Recommended action: `expedite`
- Rationale: Unknown active batch/prompt/train status should be clarified before it blocks or duplicates future work.
- Linear issue ready: `True`
- Auto-resolved: `False`
- Involved:
  - `BATCH-06-canon-batch-4-recovery-engine` — `docs/codex/batches/BATCH-06-canon-batch-4-recovery-engine.md` (unknown; release proof)

### 45. Unknown active status: BATCH-07-canon-batch-5a-time-orchestration-write-paths

- Conflict ID: `AMB28-stale_or_unknown_active_status-38238011`
- Type: `stale_or_unknown_active_status`
- Severity: `yellow`
- Recommended action: `expedite`
- Rationale: Unknown active batch/prompt/train status should be clarified before it blocks or duplicates future work.
- Linear issue ready: `True`
- Auto-resolved: `False`
- Involved:
  - `BATCH-07-canon-batch-5a-time-orchestration-write-paths` — `docs/codex/batches/BATCH-07-canon-batch-5a-time-orchestration-write-paths.md` (unknown; release proof)

### 46. Unknown active status: BATCH-08-canon-batch-5b-time-orchestration-read-paths

- Conflict ID: `AMB28-stale_or_unknown_active_status-81459077`
- Type: `stale_or_unknown_active_status`
- Severity: `yellow`
- Recommended action: `expedite`
- Rationale: Unknown active batch/prompt/train status should be clarified before it blocks or duplicates future work.
- Linear issue ready: `True`
- Auto-resolved: `False`
- Involved:
  - `BATCH-08-canon-batch-5b-time-orchestration-read-paths` — `docs/codex/batches/BATCH-08-canon-batch-5b-time-orchestration-read-paths.md` (unknown; release proof)

### 47. Unknown active status: BATCH-12-canon-batch-9-sync-trust-foundation

- Conflict ID: `AMB28-stale_or_unknown_active_status-55062173`
- Type: `stale_or_unknown_active_status`
- Severity: `yellow`
- Recommended action: `expedite`
- Rationale: Unknown active batch/prompt/train status should be clarified before it blocks or duplicates future work.
- Linear issue ready: `True`
- Auto-resolved: `False`
- Involved:
  - `BATCH-12-canon-batch-9-sync-trust-foundation` — `docs/codex/batches/BATCH-12-canon-batch-9-sync-trust-foundation.md` (unknown; release proof)

### 48. Unknown active status: BATCH-13-canon-batch-10-life-graph-foundation

- Conflict ID: `AMB28-stale_or_unknown_active_status-65753535`
- Type: `stale_or_unknown_active_status`
- Severity: `yellow`
- Recommended action: `expedite`
- Rationale: Unknown active batch/prompt/train status should be clarified before it blocks or duplicates future work.
- Linear issue ready: `True`
- Auto-resolved: `False`
- Involved:
  - `BATCH-13-canon-batch-10-life-graph-foundation` — `docs/codex/batches/BATCH-13-canon-batch-10-life-graph-foundation.md` (unknown; release proof)

### 49. Unknown active status: BATCH-14-canon-batch-11-path-systems-foundation

- Conflict ID: `AMB28-stale_or_unknown_active_status-89225829`
- Type: `stale_or_unknown_active_status`
- Severity: `yellow`
- Recommended action: `expedite`
- Rationale: Unknown active batch/prompt/train status should be clarified before it blocks or duplicates future work.
- Linear issue ready: `True`
- Auto-resolved: `False`
- Involved:
  - `BATCH-14-canon-batch-11-path-systems-foundation` — `docs/codex/batches/BATCH-14-canon-batch-11-path-systems-foundation.md` (unknown; release proof)

### 50. Unknown active status: BATCH-15-canon-batch-12-learning-and-anticipation-engine

- Conflict ID: `AMB28-stale_or_unknown_active_status-79199657`
- Type: `stale_or_unknown_active_status`
- Severity: `yellow`
- Recommended action: `expedite`
- Rationale: Unknown active batch/prompt/train status should be clarified before it blocks or duplicates future work.
- Linear issue ready: `True`
- Auto-resolved: `False`
- Involved:
  - `BATCH-15-canon-batch-12-learning-and-anticipation-engine` — `docs/codex/batches/BATCH-15-canon-batch-12-learning-and-anticipation-engine.md` (unknown; release proof)

### 51. Unknown active status: BATCH-17-canon-batch-14-runtime-separation

- Conflict ID: `AMB28-stale_or_unknown_active_status-49953795`
- Type: `stale_or_unknown_active_status`
- Severity: `yellow`
- Recommended action: `expedite`
- Rationale: Unknown active batch/prompt/train status should be clarified before it blocks or duplicates future work.
- Linear issue ready: `True`
- Auto-resolved: `False`
- Involved:
  - `BATCH-17-canon-batch-14-runtime-separation` — `docs/codex/batches/BATCH-17-canon-batch-14-runtime-separation.md` (unknown; release proof)

### 52. Unknown active status: BATCH-18-canon-batch-15-dedicated-device-prototype

- Conflict ID: `AMB28-stale_or_unknown_active_status-12226774`
- Type: `stale_or_unknown_active_status`
- Severity: `yellow`
- Recommended action: `expedite`
- Rationale: Unknown active batch/prompt/train status should be clarified before it blocks or duplicates future work.
- Linear issue ready: `True`
- Auto-resolved: `False`
- Involved:
  - `BATCH-18-canon-batch-15-dedicated-device-prototype` — `docs/codex/batches/BATCH-18-canon-batch-15-dedicated-device-prototype.md` (unknown; release proof)

### 53. Unknown active status: BATCH-19-ambitions-2.0-canon-reset

- Conflict ID: `AMB28-stale_or_unknown_active_status-71266167`
- Type: `stale_or_unknown_active_status`
- Severity: `yellow`
- Recommended action: `expedite`
- Rationale: Unknown active batch/prompt/train status should be clarified before it blocks or duplicates future work.
- Linear issue ready: `True`
- Auto-resolved: `False`
- Involved:
  - `BATCH-19-ambitions-2.0-canon-reset` — `docs/codex/batches/BATCH-19-ambitions-2.0-canon-reset.md` (unknown; release proof)

### 54. Unknown active status: BATCH-20-knowledge-provider-boundary

- Conflict ID: `AMB28-stale_or_unknown_active_status-30675243`
- Type: `stale_or_unknown_active_status`
- Severity: `yellow`
- Recommended action: `expedite`
- Rationale: Unknown active batch/prompt/train status should be clarified before it blocks or duplicates future work.
- Linear issue ready: `True`
- Auto-resolved: `False`
- Involved:
  - `BATCH-20-knowledge-provider-boundary` — `docs/codex/batches/BATCH-20-knowledge-provider-boundary.md` (unknown; release proof)

### 55. Unknown active status: BATCH-21-external-knowledge-ingestion-core

- Conflict ID: `AMB28-stale_or_unknown_active_status-5248055`
- Type: `stale_or_unknown_active_status`
- Severity: `yellow`
- Recommended action: `expedite`
- Rationale: Unknown active batch/prompt/train status should be clarified before it blocks or duplicates future work.
- Linear issue ready: `True`
- Auto-resolved: `False`
- Involved:
  - `BATCH-21-external-knowledge-ingestion-core` — `docs/codex/batches/BATCH-21-external-knowledge-ingestion-core.md` (unknown; release proof)

### 56. Unknown active status: BATCH-22-clarification-and-ambiguity-engine

- Conflict ID: `AMB28-stale_or_unknown_active_status-29631955`
- Type: `stale_or_unknown_active_status`
- Severity: `yellow`
- Recommended action: `expedite`
- Rationale: Unknown active batch/prompt/train status should be clarified before it blocks or duplicates future work.
- Linear issue ready: `True`
- Auto-resolved: `False`
- Involved:
  - `BATCH-22-clarification-and-ambiguity-engine` — `docs/codex/batches/BATCH-22-clarification-and-ambiguity-engine.md` (unknown; release proof)

### 57. Unknown active status: BATCH-23-generalized-goal-understanding-contracts

- Conflict ID: `AMB28-stale_or_unknown_active_status-7578498`
- Type: `stale_or_unknown_active_status`
- Severity: `yellow`
- Recommended action: `expedite`
- Rationale: Unknown active batch/prompt/train status should be clarified before it blocks or duplicates future work.
- Linear issue ready: `True`
- Auto-resolved: `False`
- Involved:
  - `BATCH-23-generalized-goal-understanding-contracts` — `docs/codex/batches/BATCH-23-generalized-goal-understanding-contracts.md` (unknown; release proof)

### 58. Unknown active status: BATCH-24-path-compiler-foundation

- Conflict ID: `AMB28-stale_or_unknown_active_status-70239202`
- Type: `stale_or_unknown_active_status`
- Severity: `yellow`
- Recommended action: `expedite`
- Rationale: Unknown active batch/prompt/train status should be clarified before it blocks or duplicates future work.
- Linear issue ready: `True`
- Auto-resolved: `False`
- Involved:
  - `BATCH-24-path-compiler-foundation` — `docs/codex/batches/BATCH-24-path-compiler-foundation.md` (unknown; release proof)

### 59. Unknown active status: BATCH-25-domain-pack-framework

- Conflict ID: `AMB28-stale_or_unknown_active_status-15172426`
- Type: `stale_or_unknown_active_status`
- Severity: `yellow`
- Recommended action: `expedite`
- Rationale: Unknown active batch/prompt/train status should be clarified before it blocks or duplicates future work.
- Linear issue ready: `True`
- Auto-resolved: `False`
- Involved:
  - `BATCH-25-domain-pack-framework` — `docs/codex/batches/BATCH-25-domain-pack-framework.md` (unknown; release proof)

### 60. Unknown active status: BATCH-26-resource-graph-and-source-ranking

- Conflict ID: `AMB28-stale_or_unknown_active_status-59999377`
- Type: `stale_or_unknown_active_status`
- Severity: `yellow`
- Recommended action: `expedite`
- Rationale: Unknown active batch/prompt/train status should be clarified before it blocks or duplicates future work.
- Linear issue ready: `True`
- Auto-resolved: `False`
- Involved:
  - `BATCH-26-resource-graph-and-source-ranking` — `docs/codex/batches/BATCH-26-resource-graph-and-source-ranking.md` (unknown; release proof)

### 61. Unknown active status: BATCH-27-update-and-freshness-engine

- Conflict ID: `AMB28-stale_or_unknown_active_status-32653453`
- Type: `stale_or_unknown_active_status`
- Severity: `yellow`
- Recommended action: `expedite`
- Rationale: Unknown active batch/prompt/train status should be clarified before it blocks or duplicates future work.
- Linear issue ready: `True`
- Auto-resolved: `False`
- Involved:
  - `BATCH-27-update-and-freshness-engine` — `docs/codex/batches/BATCH-27-update-and-freshness-engine.md` (unknown; release proof)

### 62. Unknown active status: BATCH-28-energy-model-foundation

- Conflict ID: `AMB28-stale_or_unknown_active_status-56961998`
- Type: `stale_or_unknown_active_status`
- Severity: `yellow`
- Recommended action: `expedite`
- Rationale: Unknown active batch/prompt/train status should be clarified before it blocks or duplicates future work.
- Linear issue ready: `True`
- Auto-resolved: `False`
- Involved:
  - `BATCH-28-energy-model-foundation` — `docs/codex/batches/BATCH-28-energy-model-foundation.md` (unknown; release proof)

### 63. Unknown active status: BATCH-29-energy-learning-and-ranking

- Conflict ID: `AMB28-stale_or_unknown_active_status-34252556`
- Type: `stale_or_unknown_active_status`
- Severity: `yellow`
- Recommended action: `expedite`
- Rationale: Unknown active batch/prompt/train status should be clarified before it blocks or duplicates future work.
- Linear issue ready: `True`
- Auto-resolved: `False`
- Involved:
  - `BATCH-29-energy-learning-and-ranking` — `docs/codex/batches/BATCH-29-energy-learning-and-ranking.md` (unknown; release proof)

### 64. Unknown active status: BATCH-30-contradiction-engine

- Conflict ID: `AMB28-stale_or_unknown_active_status-53207354`
- Type: `stale_or_unknown_active_status`
- Severity: `yellow`
- Recommended action: `expedite`
- Rationale: Unknown active batch/prompt/train status should be clarified before it blocks or duplicates future work.
- Linear issue ready: `True`
- Auto-resolved: `False`
- Involved:
  - `BATCH-30-contradiction-engine` — `docs/codex/batches/BATCH-30-contradiction-engine.md` (unknown; release proof)

### 65. Unknown active status: BATCH-31-correction-and-teaching-loop

- Conflict ID: `AMB28-stale_or_unknown_active_status-75692570`
- Type: `stale_or_unknown_active_status`
- Severity: `yellow`
- Recommended action: `expedite`
- Rationale: Unknown active batch/prompt/train status should be clarified before it blocks or duplicates future work.
- Linear issue ready: `True`
- Auto-resolved: `False`
- Involved:
  - `BATCH-31-correction-and-teaching-loop` — `docs/codex/batches/BATCH-31-correction-and-teaching-loop.md` (unknown; release proof)

### 66. Unknown active status: BATCH-32-explainability-and-source-audit-surfaces

- Conflict ID: `AMB28-stale_or_unknown_active_status-58244806`
- Type: `stale_or_unknown_active_status`
- Severity: `yellow`
- Recommended action: `expedite`
- Rationale: Unknown active batch/prompt/train status should be clarified before it blocks or duplicates future work.
- Linear issue ready: `True`
- Auto-resolved: `False`
- Involved:
  - `BATCH-32-explainability-and-source-audit-surfaces` — `docs/codex/batches/BATCH-32-explainability-and-source-audit-surfaces.md` (unknown; release proof)

### 67. Unknown active status: BATCH-35-post-2.0-hardening-shell-truth-navigation-and-plan-canon-recovery

- Conflict ID: `AMB28-stale_or_unknown_active_status-35597595`
- Type: `stale_or_unknown_active_status`
- Severity: `yellow`
- Recommended action: `expedite`
- Rationale: Unknown active batch/prompt/train status should be clarified before it blocks or duplicates future work.
- Linear issue ready: `True`
- Auto-resolved: `False`
- Involved:
  - `BATCH-35-post-2.0-hardening-shell-truth-navigation-and-plan-canon-recovery` — `docs/codex/batches/BATCH-35-post-2.0-hardening-shell-truth-navigation-and-plan-canon-recovery.md` (unknown; release proof)

### 68. Unknown active status: BATCH-36-post-2.0-hardening-trust-extensions-and-external-surface-validation

- Conflict ID: `AMB28-stale_or_unknown_active_status-61940349`
- Type: `stale_or_unknown_active_status`
- Severity: `yellow`
- Recommended action: `expedite`
- Rationale: Unknown active batch/prompt/train status should be clarified before it blocks or duplicates future work.
- Linear issue ready: `True`
- Auto-resolved: `False`
- Involved:
  - `BATCH-36-post-2.0-hardening-trust-extensions-and-external-surface-validation` — `docs/codex/batches/BATCH-36-post-2.0-hardening-trust-extensions-and-external-surface-validation.md` (unknown; release proof)

### 69. Unknown active status: BATCH-38-post-2.0-hardening-repo-truth-regression-performance-and-release-readiness

- Conflict ID: `AMB28-stale_or_unknown_active_status-39399316`
- Type: `stale_or_unknown_active_status`
- Severity: `yellow`
- Recommended action: `expedite`
- Rationale: Unknown active batch/prompt/train status should be clarified before it blocks or duplicates future work.
- Linear issue ready: `True`
- Auto-resolved: `False`
- Involved:
  - `BATCH-38-post-2.0-hardening-repo-truth-regression-performance-and-release-readiness` — `docs/codex/batches/BATCH-38-post-2.0-hardening-repo-truth-regression-performance-and-release-readiness.md` (unknown; release proof)

### 70. Unknown active status: BATCH_REPORT_LAYER

- Conflict ID: `AMB28-stale_or_unknown_active_status-61885439`
- Type: `stale_or_unknown_active_status`
- Severity: `yellow`
- Recommended action: `expedite`
- Rationale: Unknown active batch/prompt/train status should be clarified before it blocks or duplicates future work.
- Linear issue ready: `True`
- Auto-resolved: `False`
- Involved:
  - `BATCH_REPORT_LAYER` — `docs/codex/BATCH_REPORT_LAYER.md` (unknown; release proof)

### 71. Unknown active status: BATCH_THROUGHPUT_OPERATING_MODEL

- Conflict ID: `AMB28-stale_or_unknown_active_status-37659965`
- Type: `stale_or_unknown_active_status`
- Severity: `yellow`
- Recommended action: `expedite`
- Rationale: Unknown active batch/prompt/train status should be clarified before it blocks or duplicates future work.
- Linear issue ready: `True`
- Auto-resolved: `False`
- Involved:
  - `BATCH_THROUGHPUT_OPERATING_MODEL` — `docs/codex/BATCH_THROUGHPUT_OPERATING_MODEL.md` (unknown; release proof)

### 72. Unknown active status: BATCH_TRAIN_AOS01_AOS30_AMBITIONSOS_PROMPT

- Conflict ID: `AMB28-stale_or_unknown_active_status-74981923`
- Type: `stale_or_unknown_active_status`
- Severity: `yellow`
- Recommended action: `expedite`
- Rationale: Unknown active batch/prompt/train status should be clarified before it blocks or duplicates future work.
- Linear issue ready: `True`
- Auto-resolved: `False`
- Involved:
  - `BATCH_TRAIN_AOS01_AOS30_AMBITIONSOS_PROMPT` — `docs/codex/BATCH_TRAIN_AOS01_AOS30_AMBITIONSOS_PROMPT.md` (unknown; release proof)

### 73. Unknown active status: BATCH_TRAIN_CS01_CS10_COMPATIBILITY_SEAM_RETIREMENT_PROMPT

- Conflict ID: `AMB28-stale_or_unknown_active_status-65543055`
- Type: `stale_or_unknown_active_status`
- Severity: `yellow`
- Recommended action: `expedite`
- Rationale: Unknown active batch/prompt/train status should be clarified before it blocks or duplicates future work.
- Linear issue ready: `True`
- Auto-resolved: `False`
- Involved:
  - `BATCH_TRAIN_CS01_CS10_COMPATIBILITY_SEAM_RETIREMENT_PROMPT` — `docs/codex/BATCH_TRAIN_CS01_CS10_COMPATIBILITY_SEAM_RETIREMENT_PROMPT.md` (unknown; release proof)

### 74. Unknown active status: BATCH_TRAIN_ME01_ME12_MAINTAINABILITY_EXTRACTION_PROMPT

- Conflict ID: `AMB28-stale_or_unknown_active_status-97258651`
- Type: `stale_or_unknown_active_status`
- Severity: `yellow`
- Recommended action: `expedite`
- Rationale: Unknown active batch/prompt/train status should be clarified before it blocks or duplicates future work.
- Linear issue ready: `True`
- Auto-resolved: `False`
- Involved:
  - `BATCH_TRAIN_ME01_ME12_MAINTAINABILITY_EXTRACTION_PROMPT` — `docs/codex/BATCH_TRAIN_ME01_ME12_MAINTAINABILITY_EXTRACTION_PROMPT.md` (unknown; release proof)

### 75. Unknown active status: CODEX_ACCESSIBILITY_PROOF_PROTOCOL

- Conflict ID: `AMB28-stale_or_unknown_active_status-51585192`
- Type: `stale_or_unknown_active_status`
- Severity: `yellow`
- Recommended action: `expedite`
- Rationale: Unknown active batch/prompt/train status should be clarified before it blocks or duplicates future work.
- Linear issue ready: `True`
- Auto-resolved: `False`
- Involved:
  - `CODEX_ACCESSIBILITY_PROOF_PROTOCOL` — `docs/codex/CODEX_ACCESSIBILITY_PROOF_PROTOCOL.md` (unknown; release proof)

### 76. Unknown active status: CODEX_BUILD_SHERIFF_PROTOCOL

- Conflict ID: `AMB28-stale_or_unknown_active_status-28267814`
- Type: `stale_or_unknown_active_status`
- Severity: `yellow`
- Recommended action: `expedite`
- Rationale: Unknown active batch/prompt/train status should be clarified before it blocks or duplicates future work.
- Linear issue ready: `True`
- Auto-resolved: `False`
- Involved:
  - `CODEX_BUILD_SHERIFF_PROTOCOL` — `docs/codex/CODEX_BUILD_SHERIFF_PROTOCOL.md` (unknown; release proof)

### 77. Unknown active status: CODEX_MULTI_AGENT_BUILD_SYSTEM

- Conflict ID: `AMB28-stale_or_unknown_active_status-88961022`
- Type: `stale_or_unknown_active_status`
- Severity: `yellow`
- Recommended action: `expedite`
- Rationale: Unknown active batch/prompt/train status should be clarified before it blocks or duplicates future work.
- Linear issue ready: `True`
- Auto-resolved: `False`
- Involved:
  - `CODEX_MULTI_AGENT_BUILD_SYSTEM` — `docs/codex/CODEX_MULTI_AGENT_BUILD_SYSTEM.md` (unknown; release proof)

### 78. Unknown active status: CODEX_OS_INDEX

- Conflict ID: `AMB28-stale_or_unknown_active_status-82023500`
- Type: `stale_or_unknown_active_status`
- Severity: `yellow`
- Recommended action: `expedite`
- Rationale: Unknown active batch/prompt/train status should be clarified before it blocks or duplicates future work.
- Linear issue ready: `True`
- Auto-resolved: `False`
- Involved:
  - `CODEX_OS_INDEX` — `docs/codex/CODEX_OS_INDEX.md` (unknown; release proof)

### 79. Unknown active status: CODEX_OS_NO_DOUBLE_WORK_PROTOCOL

- Conflict ID: `AMB28-stale_or_unknown_active_status-34874633`
- Type: `stale_or_unknown_active_status`
- Severity: `yellow`
- Recommended action: `expedite`
- Rationale: Unknown active batch/prompt/train status should be clarified before it blocks or duplicates future work.
- Linear issue ready: `True`
- Auto-resolved: `False`
- Involved:
  - `CODEX_OS_NO_DOUBLE_WORK_PROTOCOL` — `docs/codex/CODEX_OS_NO_DOUBLE_WORK_PROTOCOL.md` (unknown; release proof)

### 80. Unknown active status: CODEX_PROOF_CACHE_PROTOCOL

- Conflict ID: `AMB28-stale_or_unknown_active_status-88794314`
- Type: `stale_or_unknown_active_status`
- Severity: `yellow`
- Recommended action: `expedite`
- Rationale: Unknown active batch/prompt/train status should be clarified before it blocks or duplicates future work.
- Linear issue ready: `True`
- Auto-resolved: `False`
- Involved:
  - `CODEX_PROOF_CACHE_PROTOCOL` — `docs/codex/CODEX_PROOF_CACHE_PROTOCOL.md` (unknown; release proof)

### 81. Unknown active status: CODEX_QUALITY_SYSTEM_SCRIPT_MAP

- Conflict ID: `AMB28-stale_or_unknown_active_status-61406063`
- Type: `stale_or_unknown_active_status`
- Severity: `yellow`
- Recommended action: `expedite`
- Rationale: Unknown active batch/prompt/train status should be clarified before it blocks or duplicates future work.
- Linear issue ready: `True`
- Auto-resolved: `False`
- Involved:
  - `CODEX_QUALITY_SYSTEM_SCRIPT_MAP` — `docs/codex/CODEX_QUALITY_SYSTEM_SCRIPT_MAP.md` (unknown; release proof)

### 82. Unknown active status: CODEX_QUALITY_SYSTEM_SKILL_MAP

- Conflict ID: `AMB28-stale_or_unknown_active_status-32355478`
- Type: `stale_or_unknown_active_status`
- Severity: `yellow`
- Recommended action: `expedite`
- Rationale: Unknown active batch/prompt/train status should be clarified before it blocks or duplicates future work.
- Linear issue ready: `True`
- Auto-resolved: `False`
- Involved:
  - `CODEX_QUALITY_SYSTEM_SKILL_MAP` — `docs/codex/CODEX_QUALITY_SYSTEM_SKILL_MAP.md` (unknown; release proof)

### 83. Unknown active status: CODEX_ROUTE_CONTEXT_PROTOCOL

- Conflict ID: `AMB28-stale_or_unknown_active_status-84237739`
- Type: `stale_or_unknown_active_status`
- Severity: `yellow`
- Recommended action: `expedite`
- Rationale: Unknown active batch/prompt/train status should be clarified before it blocks or duplicates future work.
- Linear issue ready: `True`
- Auto-resolved: `False`
- Involved:
  - `CODEX_ROUTE_CONTEXT_PROTOCOL` — `docs/codex/CODEX_ROUTE_CONTEXT_PROTOCOL.md` (unknown; release proof)

### 84. Unknown active status: CODEX_SPEED_ENGINE

- Conflict ID: `AMB28-stale_or_unknown_active_status-21580498`
- Type: `stale_or_unknown_active_status`
- Severity: `yellow`
- Recommended action: `expedite`
- Rationale: Unknown active batch/prompt/train status should be clarified before it blocks or duplicates future work.
- Linear issue ready: `True`
- Auto-resolved: `False`
- Involved:
  - `CODEX_SPEED_ENGINE` — `docs/codex/CODEX_SPEED_ENGINE.md` (unknown; release proof)

### 85. Unknown active status: DAV_DYNAMIC_ADAPTIVE_VISUAL_DEPENDENCY_GRAPH

- Conflict ID: `AMB28-stale_or_unknown_active_status-91223553`
- Type: `stale_or_unknown_active_status`
- Severity: `yellow`
- Recommended action: `expedite`
- Rationale: Unknown active batch/prompt/train status should be clarified before it blocks or duplicates future work.
- Linear issue ready: `True`
- Auto-resolved: `False`
- Involved:
  - `DAV_DYNAMIC_ADAPTIVE_VISUAL_DEPENDENCY_GRAPH` — `docs/codex/DAV_DYNAMIC_ADAPTIVE_VISUAL_DEPENDENCY_GRAPH.md` (unknown; release proof)

### 86. Unknown active status: DAV_VISUAL_PRIMITIVE_DEPENDENCY_GRAPH

- Conflict ID: `AMB28-stale_or_unknown_active_status-27613818`
- Type: `stale_or_unknown_active_status`
- Severity: `yellow`
- Recommended action: `expedite`
- Rationale: Unknown active batch/prompt/train status should be clarified before it blocks or duplicates future work.
- Linear issue ready: `True`
- Auto-resolved: `False`
- Involved:
  - `DAV_VISUAL_PRIMITIVE_DEPENDENCY_GRAPH` — `docs/codex/DAV_VISUAL_PRIMITIVE_DEPENDENCY_GRAPH.md` (unknown; release proof)

### 87. Unknown active status: DERIVEDDATA_HYGIENE_PLAYBOOK

- Conflict ID: `AMB28-stale_or_unknown_active_status-55481642`
- Type: `stale_or_unknown_active_status`
- Severity: `yellow`
- Recommended action: `expedite`
- Rationale: Unknown active batch/prompt/train status should be clarified before it blocks or duplicates future work.
- Linear issue ready: `True`
- Auto-resolved: `False`
- Involved:
  - `DERIVEDDATA_HYGIENE_PLAYBOOK` — `docs/codex/playbooks/DERIVEDDATA_HYGIENE_PLAYBOOK.md` (unknown; release proof)

### 88. Unknown active status: F13_5_Goals_You_Trust_Architecture_Checkpoint_Prompt

- Conflict ID: `AMB28-stale_or_unknown_active_status-17874897`
- Type: `stale_or_unknown_active_status`
- Severity: `yellow`
- Recommended action: `expedite`
- Rationale: Unknown active batch/prompt/train status should be clarified before it blocks or duplicates future work.
- Linear issue ready: `True`
- Auto-resolved: `False`
- Involved:
  - `F13_5_Goals_You_Trust_Architecture_Checkpoint_Prompt` — `docs/codex/batches/F13_5_Goals_You_Trust_Architecture_Checkpoint_Prompt.md` (unknown; release proof)

### 89. Unknown active status: F16_5_SwiftUI_Architecture_State_Contract_Hardening_Prompt

- Conflict ID: `AMB28-stale_or_unknown_active_status-23026255`
- Type: `stale_or_unknown_active_status`
- Severity: `yellow`
- Recommended action: `expedite`
- Rationale: Unknown active batch/prompt/train status should be clarified before it blocks or duplicates future work.
- Linear issue ready: `True`
- Auto-resolved: `False`
- Involved:
  - `F16_5_SwiftUI_Architecture_State_Contract_Hardening_Prompt` — `docs/codex/batches/F16_5_SwiftUI_Architecture_State_Contract_Hardening_Prompt.md` (unknown; release proof)

### 90. Unknown active status: F18_5_Shell_Architecture_Hardening_Prompt

- Conflict ID: `AMB28-stale_or_unknown_active_status-42601125`
- Type: `stale_or_unknown_active_status`
- Severity: `yellow`
- Recommended action: `expedite`
- Rationale: Unknown active batch/prompt/train status should be clarified before it blocks or duplicates future work.
- Linear issue ready: `True`
- Auto-resolved: `False`
- Involved:
  - `F18_5_Shell_Architecture_Hardening_Prompt` — `docs/codex/batches/F18_5_Shell_Architecture_Hardening_Prompt.md` (unknown; release proof)

### 91. Unknown active status: F19_Shell_Route_Parity_Fallback_Safety_Prompt

- Conflict ID: `AMB28-stale_or_unknown_active_status-31421587`
- Type: `stale_or_unknown_active_status`
- Severity: `yellow`
- Recommended action: `expedite`
- Rationale: Unknown active batch/prompt/train status should be clarified before it blocks or duplicates future work.
- Linear issue ready: `True`
- Auto-resolved: `False`
- Involved:
  - `F19_Shell_Route_Parity_Fallback_Safety_Prompt` — `docs/codex/batches/F19_Shell_Route_Parity_Fallback_Safety_Prompt.md` (unknown; release proof)

### 92. Unknown active status: F20_External_Surface_Privacy_Projection_Prompt

- Conflict ID: `AMB28-stale_or_unknown_active_status-25910139`
- Type: `stale_or_unknown_active_status`
- Severity: `yellow`
- Recommended action: `expedite`
- Rationale: Unknown active batch/prompt/train status should be clarified before it blocks or duplicates future work.
- Linear issue ready: `True`
- Auto-resolved: `False`
- Involved:
  - `F20_External_Surface_Privacy_Projection_Prompt` — `docs/codex/batches/F20_External_Surface_Privacy_Projection_Prompt.md` (unknown; release proof)

### 93. Unknown active status: F21_5_UI_Flake_Reliability_Hardening_Prompt

- Conflict ID: `AMB28-stale_or_unknown_active_status-21244220`
- Type: `stale_or_unknown_active_status`
- Severity: `yellow`
- Recommended action: `expedite`
- Rationale: Unknown active batch/prompt/train status should be clarified before it blocks or duplicates future work.
- Linear issue ready: `True`
- Auto-resolved: `False`
- Involved:
  - `F21_5_UI_Flake_Reliability_Hardening_Prompt` — `docs/codex/batches/F21_5_UI_Flake_Reliability_Hardening_Prompt.md` (unknown; release proof)

### 94. Unknown active status: F23_Accessibility_ADHD_Dynamic_Type_VoiceOver_QA_Prompt

- Conflict ID: `AMB28-stale_or_unknown_active_status-39698852`
- Type: `stale_or_unknown_active_status`
- Severity: `yellow`
- Recommended action: `expedite`
- Rationale: Unknown active batch/prompt/train status should be clarified before it blocks or duplicates future work.
- Linear issue ready: `True`
- Auto-resolved: `False`
- Involved:
  - `F23_Accessibility_ADHD_Dynamic_Type_VoiceOver_QA_Prompt` — `docs/codex/batches/F23_Accessibility_ADHD_Dynamic_Type_VoiceOver_QA_Prompt.md` (unknown; release proof)

### 95. Unknown active status: F24_5_Privacy_Threat_Model_Closure_Prompt

- Conflict ID: `AMB28-stale_or_unknown_active_status-35883794`
- Type: `stale_or_unknown_active_status`
- Severity: `yellow`
- Recommended action: `expedite`
- Rationale: Unknown active batch/prompt/train status should be clarified before it blocks or duplicates future work.
- Linear issue ready: `True`
- Auto-resolved: `False`
- Involved:
  - `F24_5_Privacy_Threat_Model_Closure_Prompt` — `docs/codex/batches/F24_5_Privacy_Threat_Model_Closure_Prompt.md` (unknown; release proof)

### 96. Unknown active status: F24_Privacy_Trust_Local_Data_Redaction_QA_Prompt

- Conflict ID: `AMB28-stale_or_unknown_active_status-6732975`
- Type: `stale_or_unknown_active_status`
- Severity: `yellow`
- Recommended action: `expedite`
- Rationale: Unknown active batch/prompt/train status should be clarified before it blocks or duplicates future work.
- Linear issue ready: `True`
- Auto-resolved: `False`
- Involved:
  - `F24_Privacy_Trust_Local_Data_Redaction_QA_Prompt` — `docs/codex/batches/F24_Privacy_Trust_Local_Data_Redaction_QA_Prompt.md` (unknown; release proof)

### 97. Unknown active status: F25_Device_Performance_State_Restoration_Edge_Case_QA_Prompt

- Conflict ID: `AMB28-stale_or_unknown_active_status-2781544`
- Type: `stale_or_unknown_active_status`
- Severity: `yellow`
- Recommended action: `expedite`
- Rationale: Unknown active batch/prompt/train status should be clarified before it blocks or duplicates future work.
- Linear issue ready: `True`
- Auto-resolved: `False`
- Involved:
  - `F25_Device_Performance_State_Restoration_Edge_Case_QA_Prompt` — `docs/codex/batches/F25_Device_Performance_State_Restoration_Edge_Case_QA_Prompt.md` (unknown; release proof)

### 98. Unknown active status: F29_Final_Handoff_Package_And_Engineer_Onboarding_Prompt

- Conflict ID: `AMB28-stale_or_unknown_active_status-11921240`
- Type: `stale_or_unknown_active_status`
- Severity: `yellow`
- Recommended action: `expedite`
- Rationale: Unknown active batch/prompt/train status should be clarified before it blocks or duplicates future work.
- Linear issue ready: `True`
- Auto-resolved: `False`
- Involved:
  - `F29_Final_Handoff_Package_And_Engineer_Onboarding_Prompt` — `docs/codex/batches/F29_Final_Handoff_Package_And_Engineer_Onboarding_Prompt.md` (unknown; release proof)

### 99. Unknown active status: F30_Beyond_3_0_Continuation_Plan_Prompt

- Conflict ID: `AMB28-stale_or_unknown_active_status-14014993`
- Type: `stale_or_unknown_active_status`
- Severity: `yellow`
- Recommended action: `expedite`
- Rationale: Unknown active batch/prompt/train status should be clarified before it blocks or duplicates future work.
- Linear issue ready: `True`
- Auto-resolved: `False`
- Involved:
  - `F30_Beyond_3_0_Continuation_Plan_Prompt` — `docs/codex/batches/F30_Beyond_3_0_Continuation_Plan_Prompt.md` (unknown; release proof)

### 100. Unknown active status: FCP05_Start_Here_Surface_Prompt

- Conflict ID: `AMB28-stale_or_unknown_active_status-40567057`
- Type: `stale_or_unknown_active_status`
- Severity: `yellow`
- Recommended action: `expedite`
- Rationale: Unknown active batch/prompt/train status should be clarified before it blocks or duplicates future work.
- Linear issue ready: `True`
- Auto-resolved: `False`
- Involved:
  - `FCP05_Start_Here_Surface_Prompt` — `docs/codex/batches/FCP05_Start_Here_Surface_Prompt.md` (unknown; release proof)

### 101. Unknown active status: FCP07_Reality_Rail_Continuity_Prompt

- Conflict ID: `AMB28-stale_or_unknown_active_status-54928548`
- Type: `stale_or_unknown_active_status`
- Severity: `yellow`
- Recommended action: `expedite`
- Rationale: Unknown active batch/prompt/train status should be clarified before it blocks or duplicates future work.
- Linear issue ready: `True`
- Auto-resolved: `False`
- Involved:
  - `FCP07_Reality_Rail_Continuity_Prompt` — `docs/codex/batches/FCP07_Reality_Rail_Continuity_Prompt.md` (unknown; release proof)

### 102. Unknown active status: FCP08_Ambition_Meridian_Shell_Prompt

- Conflict ID: `AMB28-stale_or_unknown_active_status-92236091`
- Type: `stale_or_unknown_active_status`
- Severity: `yellow`
- Recommended action: `expedite`
- Rationale: Unknown active batch/prompt/train status should be clarified before it blocks or duplicates future work.
- Linear issue ready: `True`
- Auto-resolved: `False`
- Involved:
  - `FCP08_Ambition_Meridian_Shell_Prompt` — `docs/codex/batches/FCP08_Ambition_Meridian_Shell_Prompt.md` (unknown; release proof)

### 103. Unknown active status: FCP09_Motion_Haptics_Reduced_Motion_Proof_Prompt

- Conflict ID: `AMB28-stale_or_unknown_active_status-75567898`
- Type: `stale_or_unknown_active_status`
- Severity: `yellow`
- Recommended action: `expedite`
- Rationale: Unknown active batch/prompt/train status should be clarified before it blocks or duplicates future work.
- Linear issue ready: `True`
- Auto-resolved: `False`
- Involved:
  - `FCP09_Motion_Haptics_Reduced_Motion_Proof_Prompt` — `docs/codex/batches/FCP09_Motion_Haptics_Reduced_Motion_Proof_Prompt.md` (unknown; release proof)

### 104. Unknown active status: FCP13A_Action_Closure_Diamond_Prompt

- Conflict ID: `AMB28-stale_or_unknown_active_status-87589205`
- Type: `stale_or_unknown_active_status`
- Severity: `yellow`
- Recommended action: `expedite`
- Rationale: Unknown active batch/prompt/train status should be clarified before it blocks or duplicates future work.
- Linear issue ready: `True`
- Auto-resolved: `False`
- Involved:
  - `FCP13A_Action_Closure_Diamond_Prompt` — `docs/codex/batches/FCP13A_Action_Closure_Diamond_Prompt.md` (unknown; release proof)

### 105. Unknown active status: FCP17_Schedule_Availability_Defaults_Center_Prompt

- Conflict ID: `AMB28-stale_or_unknown_active_status-21670905`
- Type: `stale_or_unknown_active_status`
- Severity: `yellow`
- Recommended action: `expedite`
- Rationale: Unknown active batch/prompt/train status should be clarified before it blocks or duplicates future work.
- Linear issue ready: `True`
- Auto-resolved: `False`
- Involved:
  - `FCP17_Schedule_Availability_Defaults_Center_Prompt` — `docs/codex/batches/FCP17_Schedule_Availability_Defaults_Center_Prompt.md` (unknown; release proof)

### 106. Unknown active status: FL02_Life_Inventory_Object_Model_Prompt

- Conflict ID: `AMB28-stale_or_unknown_active_status-92174301`
- Type: `stale_or_unknown_active_status`
- Severity: `yellow`
- Recommended action: `expedite`
- Rationale: Unknown active batch/prompt/train status should be clarified before it blocks or duplicates future work.
- Linear issue ready: `True`
- Auto-resolved: `False`
- Involved:
  - `FL02_Life_Inventory_Object_Model_Prompt` — `docs/codex/batches/FL02_Life_Inventory_Object_Model_Prompt.md` (unknown; release proof)

### 107. Unknown active status: FL03_Commitment_Memory_Open_Loop_Registry_Prompt

- Conflict ID: `AMB28-stale_or_unknown_active_status-92058541`
- Type: `stale_or_unknown_active_status`
- Severity: `yellow`
- Recommended action: `expedite`
- Rationale: Unknown active batch/prompt/train status should be clarified before it blocks or duplicates future work.
- Linear issue ready: `True`
- Auto-resolved: `False`
- Involved:
  - `FL03_Commitment_Memory_Open_Loop_Registry_Prompt` — `docs/codex/batches/FL03_Commitment_Memory_Open_Loop_Registry_Prompt.md` (unknown; release proof)

### 108. Unknown active status: FL05_Option_Value_Pivot_Preservation_Model_Prompt

- Conflict ID: `AMB28-stale_or_unknown_active_status-27443562`
- Type: `stale_or_unknown_active_status`
- Severity: `yellow`
- Recommended action: `expedite`
- Rationale: Unknown active batch/prompt/train status should be clarified before it blocks or duplicates future work.
- Linear issue ready: `True`
- Auto-resolved: `False`
- Involved:
  - `FL05_Option_Value_Pivot_Preservation_Model_Prompt` — `docs/codex/batches/FL05_Option_Value_Pivot_Preservation_Model_Prompt.md` (unknown; release proof)

### 109. Unknown active status: FRONTEND_ACCESSIBILITY_DYNAMIC_TYPE_REDUCE_MOTION_GATE

- Conflict ID: `AMB28-stale_or_unknown_active_status-84095137`
- Type: `stale_or_unknown_active_status`
- Severity: `yellow`
- Recommended action: `expedite`
- Rationale: Unknown active batch/prompt/train status should be clarified before it blocks or duplicates future work.
- Linear issue ready: `True`
- Auto-resolved: `False`
- Involved:
  - `FRONTEND_ACCESSIBILITY_DYNAMIC_TYPE_REDUCE_MOTION_GATE` — `docs/codex/FRONTEND_ACCESSIBILITY_DYNAMIC_TYPE_REDUCE_MOTION_GATE.md` (unknown; release proof)

### 110. Unknown active status: FRONTEND_AUTHORITY_GLOBAL_TRAIN_HOOK

- Conflict ID: `AMB28-stale_or_unknown_active_status-35795957`
- Type: `stale_or_unknown_active_status`
- Severity: `yellow`
- Recommended action: `expedite`
- Rationale: Unknown active batch/prompt/train status should be clarified before it blocks or duplicates future work.
- Linear issue ready: `True`
- Auto-resolved: `False`
- Involved:
  - `FRONTEND_AUTHORITY_GLOBAL_TRAIN_HOOK` — `docs/codex/FRONTEND_AUTHORITY_GLOBAL_TRAIN_HOOK.md` (unknown; release proof)

### 111. Unknown active status: FRONTEND_COPY_COMPRESSION_PRODUCT_LANGUAGE_GATE

- Conflict ID: `AMB28-stale_or_unknown_active_status-15359531`
- Type: `stale_or_unknown_active_status`
- Severity: `yellow`
- Recommended action: `expedite`
- Rationale: Unknown active batch/prompt/train status should be clarified before it blocks or duplicates future work.
- Linear issue ready: `True`
- Auto-resolved: `False`
- Involved:
  - `FRONTEND_COPY_COMPRESSION_PRODUCT_LANGUAGE_GATE` — `docs/codex/FRONTEND_COPY_COMPRESSION_PRODUCT_LANGUAGE_GATE.md` (unknown; release proof)

### 112. Unknown active status: FRONTEND_MOTION_HAPTICS_INTERACTION_BELIEVABILITY_GATE

- Conflict ID: `AMB28-stale_or_unknown_active_status-61689189`
- Type: `stale_or_unknown_active_status`
- Severity: `yellow`
- Recommended action: `expedite`
- Rationale: Unknown active batch/prompt/train status should be clarified before it blocks or duplicates future work.
- Linear issue ready: `True`
- Auto-resolved: `False`
- Involved:
  - `FRONTEND_MOTION_HAPTICS_INTERACTION_BELIEVABILITY_GATE` — `docs/codex/FRONTEND_MOTION_HAPTICS_INTERACTION_BELIEVABILITY_GATE.md` (unknown; release proof)

### 113. Unknown active status: FRONTEND_SCREENSHOT_EVIDENCE_STANDARD

- Conflict ID: `AMB28-stale_or_unknown_active_status-25202197`
- Type: `stale_or_unknown_active_status`
- Severity: `yellow`
- Recommended action: `expedite`
- Rationale: Unknown active batch/prompt/train status should be clarified before it blocks or duplicates future work.
- Linear issue ready: `True`
- Auto-resolved: `False`
- Involved:
  - `FRONTEND_SCREENSHOT_EVIDENCE_STANDARD` — `docs/codex/FRONTEND_SCREENSHOT_EVIDENCE_STANDARD.md` (unknown; release proof)

### 114. Unknown active status: FRONTEND_SHELL_BOTTOM_CHROME_OWNERSHIP_GATE

- Conflict ID: `AMB28-stale_or_unknown_active_status-25291189`
- Type: `stale_or_unknown_active_status`
- Severity: `yellow`
- Recommended action: `expedite`
- Rationale: Unknown active batch/prompt/train status should be clarified before it blocks or duplicates future work.
- Linear issue ready: `True`
- Auto-resolved: `False`
- Involved:
  - `FRONTEND_SHELL_BOTTOM_CHROME_OWNERSHIP_GATE` — `docs/codex/FRONTEND_SHELL_BOTTOM_CHROME_OWNERSHIP_GATE.md` (unknown; release proof)

### 115. Unknown active status: FRONTEND_TOP_LEVEL_SURFACE_COMPOSITION_GATE

- Conflict ID: `AMB28-stale_or_unknown_active_status-16755707`
- Type: `stale_or_unknown_active_status`
- Severity: `yellow`
- Recommended action: `expedite`
- Rationale: Unknown active batch/prompt/train status should be clarified before it blocks or duplicates future work.
- Linear issue ready: `True`
- Auto-resolved: `False`
- Involved:
  - `FRONTEND_TOP_LEVEL_SURFACE_COMPOSITION_GATE` — `docs/codex/FRONTEND_TOP_LEVEL_SURFACE_COMPOSITION_GATE.md` (unknown; release proof)

### 116. Unknown active status: GH01_GitHub_Native_Tooling_Policy_Prompt

- Conflict ID: `AMB28-stale_or_unknown_active_status-22282136`
- Type: `stale_or_unknown_active_status`
- Severity: `yellow`
- Recommended action: `expedite`
- Rationale: Unknown active batch/prompt/train status should be clarified before it blocks or duplicates future work.
- Linear issue ready: `True`
- Auto-resolved: `False`
- Involved:
  - `GH01_GitHub_Native_Tooling_Policy_Prompt` — `docs/codex/batches/GH01_GitHub_Native_Tooling_Policy_Prompt.md` (unknown; release proof)

### 117. Unknown active status: GITHUB_NATIVE_TOOLING_POLICY

- Conflict ID: `AMB28-stale_or_unknown_active_status-91034410`
- Type: `stale_or_unknown_active_status`
- Severity: `yellow`
- Recommended action: `expedite`
- Rationale: Unknown active batch/prompt/train status should be clarified before it blocks or duplicates future work.
- Linear issue ready: `True`
- Auto-resolved: `False`
- Involved:
  - `GITHUB_NATIVE_TOOLING_POLICY` — `docs/codex/GITHUB_NATIVE_TOOLING_POLICY.md` (unknown; release proof)

### 118. Unknown active status: GLOBAL_FULL_STACK_COMPLETION_ORDER_VISUAL_CANON_MOAT_OVERLAY

- Conflict ID: `AMB28-stale_or_unknown_active_status-10465801`
- Type: `stale_or_unknown_active_status`
- Severity: `yellow`
- Recommended action: `expedite`
- Rationale: Unknown active batch/prompt/train status should be clarified before it blocks or duplicates future work.
- Linear issue ready: `True`
- Auto-resolved: `False`
- Involved:
  - `GLOBAL_FULL_STACK_COMPLETION_ORDER_VISUAL_CANON_MOAT_OVERLAY` — `docs/codex/GLOBAL_FULL_STACK_COMPLETION_ORDER_VISUAL_CANON_MOAT_OVERLAY.md` (unknown; release proof)

### 119. Unknown active status: HBI00_RRE01_HISTORICAL_BASELINE_TRAIN

- Conflict ID: `AMB28-stale_or_unknown_active_status-73790956`
- Type: `stale_or_unknown_active_status`
- Severity: `yellow`
- Recommended action: `expedite`
- Rationale: Unknown active batch/prompt/train status should be clarified before it blocks or duplicates future work.
- Linear issue ready: `True`
- Auto-resolved: `False`
- Involved:
  - `HBI00_RRE01_HISTORICAL_BASELINE_TRAIN` — `docs/codex/batch-trains/HBI00_RRE01_HISTORICAL_BASELINE_TRAIN.md` (unknown; release proof)

### 120. Unknown active status: HBI_HISTORICAL_BASELINE_GLOBAL_TRAIN_INSERT

- Conflict ID: `AMB28-stale_or_unknown_active_status-58386020`
- Type: `stale_or_unknown_active_status`
- Severity: `yellow`
- Recommended action: `expedite`
- Rationale: Unknown active batch/prompt/train status should be clarified before it blocks or duplicates future work.
- Linear issue ready: `True`
- Auto-resolved: `False`
- Involved:
  - `HBI_HISTORICAL_BASELINE_GLOBAL_TRAIN_INSERT` — `docs/codex/HBI_HISTORICAL_BASELINE_GLOBAL_TRAIN_INSERT.md` (unknown; release proof)

### 121. Unknown active status: HISTORICAL_BASELINE_GLOBAL_TRAIN_MANIFEST

- Conflict ID: `AMB28-stale_or_unknown_active_status-9304311`
- Type: `stale_or_unknown_active_status`
- Severity: `yellow`
- Recommended action: `expedite`
- Rationale: Unknown active batch/prompt/train status should be clarified before it blocks or duplicates future work.
- Linear issue ready: `True`
- Auto-resolved: `False`
- Involved:
  - `HISTORICAL_BASELINE_GLOBAL_TRAIN_MANIFEST` — `docs/codex/HISTORICAL_BASELINE_GLOBAL_TRAIN_MANIFEST.json` (unknown; release proof)

### 122. Unknown active status: HISTORICAL_BASELINE_GLOBAL_TRAIN_OVERLAY

- Conflict ID: `AMB28-stale_or_unknown_active_status-18699925`
- Type: `stale_or_unknown_active_status`
- Severity: `yellow`
- Recommended action: `expedite`
- Rationale: Unknown active batch/prompt/train status should be clarified before it blocks or duplicates future work.
- Linear issue ready: `True`
- Auto-resolved: `False`
- Involved:
  - `HISTORICAL_BASELINE_GLOBAL_TRAIN_OVERLAY` — `docs/codex/HISTORICAL_BASELINE_GLOBAL_TRAIN_OVERLAY.md` (unknown; release proof)

### 123. Unknown active status: HPS_MOAT_AND_ACQUISITION_READINESS_MAP

- Conflict ID: `AMB28-stale_or_unknown_active_status-81838505`
- Type: `stale_or_unknown_active_status`
- Severity: `yellow`
- Recommended action: `expedite`
- Rationale: Unknown active batch/prompt/train status should be clarified before it blocks or duplicates future work.
- Linear issue ready: `True`
- Auto-resolved: `False`
- Involved:
  - `HPS_MOAT_AND_ACQUISITION_READINESS_MAP` — `docs/codex/HPS_MOAT_AND_ACQUISITION_READINESS_MAP.md` (unknown; release proof)

### 124. Unknown active status: IOS26_CORE_LIFE_OPERATIONS_ARCHITECTURE

- Conflict ID: `AMB28-stale_or_unknown_active_status-95228987`
- Type: `stale_or_unknown_active_status`
- Severity: `yellow`
- Recommended action: `expedite`
- Rationale: Unknown active batch/prompt/train status should be clarified before it blocks or duplicates future work.
- Linear issue ready: `True`
- Auto-resolved: `False`
- Involved:
  - `IOS26_CORE_LIFE_OPERATIONS_ARCHITECTURE` — `docs/codex/IOS26_CORE_LIFE_OPERATIONS_ARCHITECTURE.md` (unknown; release proof)

### 125. Unknown active status: IOS26_CORE_REPLACEMENT_JOURNEY_SPEC

- Conflict ID: `AMB28-stale_or_unknown_active_status-53417882`
- Type: `stale_or_unknown_active_status`
- Severity: `yellow`
- Recommended action: `expedite`
- Rationale: Unknown active batch/prompt/train status should be clarified before it blocks or duplicates future work.
- Linear issue ready: `True`
- Auto-resolved: `False`
- Involved:
  - `IOS26_CORE_REPLACEMENT_JOURNEY_SPEC` — `docs/codex/IOS26_CORE_REPLACEMENT_JOURNEY_SPEC.md` (unknown; release proof)

### 126. Unknown active status: IOS26_MOMENTUM_REFLOW_CONTRACT_FIXTURES

- Conflict ID: `AMB28-stale_or_unknown_active_status-79974546`
- Type: `stale_or_unknown_active_status`
- Severity: `yellow`
- Recommended action: `expedite`
- Rationale: Unknown active batch/prompt/train status should be clarified before it blocks or duplicates future work.
- Linear issue ready: `True`
- Auto-resolved: `False`
- Involved:
  - `IOS26_MOMENTUM_REFLOW_CONTRACT_FIXTURES` — `docs/codex/IOS26_MOMENTUM_REFLOW_CONTRACT_FIXTURES.md` (unknown; release proof)

### 127. Unknown active status: IOS26_PLAN_FREEZE

- Conflict ID: `AMB28-stale_or_unknown_active_status-15890958`
- Type: `stale_or_unknown_active_status`
- Severity: `yellow`
- Recommended action: `expedite`
- Rationale: Unknown active batch/prompt/train status should be clarified before it blocks or duplicates future work.
- Linear issue ready: `True`
- Auto-resolved: `False`
- Involved:
  - `IOS26_PLAN_FREEZE` — `docs/codex/ios26/IOS26_PLAN_FREEZE.md` (unknown; release proof)

### 128. Unknown active status: LAUNCH_DOCUMENTATION_LAYER

- Conflict ID: `AMB28-stale_or_unknown_active_status-11930127`
- Type: `stale_or_unknown_active_status`
- Severity: `yellow`
- Recommended action: `expedite`
- Rationale: Unknown active batch/prompt/train status should be clarified before it blocks or duplicates future work.
- Linear issue ready: `True`
- Auto-resolved: `False`
- Involved:
  - `LAUNCH_DOCUMENTATION_LAYER` — `docs/codex/LAUNCH_DOCUMENTATION_LAYER.md` (unknown; release proof)

### 129. Unknown active status: LDI_INVARIANT_LEDGER

- Conflict ID: `AMB28-stale_or_unknown_active_status-21966918`
- Type: `stale_or_unknown_active_status`
- Severity: `yellow`
- Recommended action: `expedite`
- Rationale: Unknown active batch/prompt/train status should be clarified before it blocks or duplicates future work.
- Linear issue ready: `True`
- Auto-resolved: `False`
- Involved:
  - `LDI_INVARIANT_LEDGER` — `docs/codex/LDI_INVARIANT_LEDGER.md` (unknown; release proof)

### 130. Unknown active status: LDI_ROADMAP_TO_IMPLEMENTATION_REORDER_PROTOCOL

- Conflict ID: `AMB28-stale_or_unknown_active_status-63252953`
- Type: `stale_or_unknown_active_status`
- Severity: `yellow`
- Recommended action: `expedite`
- Rationale: Unknown active batch/prompt/train status should be clarified before it blocks or duplicates future work.
- Linear issue ready: `True`
- Auto-resolved: `False`
- Involved:
  - `LDI_ROADMAP_TO_IMPLEMENTATION_REORDER_PROTOCOL` — `docs/codex/LDI_ROADMAP_TO_IMPLEMENTATION_REORDER_PROTOCOL.md` (unknown; release proof)

### 131. Unknown active status: Launch_Operator_Runbook

- Conflict ID: `AMB28-stale_or_unknown_active_status-59942918`
- Type: `stale_or_unknown_active_status`
- Severity: `yellow`
- Recommended action: `expedite`
- Rationale: Unknown active batch/prompt/train status should be clarified before it blocks or duplicates future work.
- Linear issue ready: `True`
- Auto-resolved: `False`
- Involved:
  - `Launch_Operator_Runbook` — `docs/codex/Launch_Operator_Runbook.md` (unknown; release proof)

### 132. Unknown active status: MAC_SESSION_BOOT_PROMPT

- Conflict ID: `AMB28-stale_or_unknown_active_status-94907521`
- Type: `stale_or_unknown_active_status`
- Severity: `yellow`
- Recommended action: `expedite`
- Rationale: Unknown active batch/prompt/train status should be clarified before it blocks or duplicates future work.
- Linear issue ready: `True`
- Auto-resolved: `False`
- Involved:
  - `MAC_SESSION_BOOT_PROMPT` — `docs/codex/MAC_SESSION_BOOT_PROMPT.md` (unknown; release proof)

### 133. Unknown active status: MCP03_VISUAL_PROOF_MCP_PLAN

- Conflict ID: `AMB28-stale_or_unknown_active_status-24206486`
- Type: `stale_or_unknown_active_status`
- Severity: `yellow`
- Recommended action: `expedite`
- Rationale: Unknown active batch/prompt/train status should be clarified before it blocks or duplicates future work.
- Linear issue ready: `True`
- Auto-resolved: `False`
- Involved:
  - `MCP03_VISUAL_PROOF_MCP_PLAN` — `docs/codex/MCP03_VISUAL_PROOF_MCP_PLAN.md` (unknown; release proof)

### 134. Unknown active status: MCP03_Visual_Proof_MCP_Prompt

- Conflict ID: `AMB28-stale_or_unknown_active_status-56851246`
- Type: `stale_or_unknown_active_status`
- Severity: `yellow`
- Recommended action: `expedite`
- Rationale: Unknown active batch/prompt/train status should be clarified before it blocks or duplicates future work.
- Linear issue ready: `True`
- Auto-resolved: `False`
- Involved:
  - `MCP03_Visual_Proof_MCP_Prompt` — `docs/codex/batches/MCP03_Visual_Proof_MCP_Prompt.md` (unknown; release proof)

### 135. Unknown active status: MCP04_ACCESSIBILITY_SHADOW_MCP_PLAN

- Conflict ID: `AMB28-stale_or_unknown_active_status-60557908`
- Type: `stale_or_unknown_active_status`
- Severity: `yellow`
- Recommended action: `expedite`
- Rationale: Unknown active batch/prompt/train status should be clarified before it blocks or duplicates future work.
- Linear issue ready: `True`
- Auto-resolved: `False`
- Involved:
  - `MCP04_ACCESSIBILITY_SHADOW_MCP_PLAN` — `docs/codex/MCP04_ACCESSIBILITY_SHADOW_MCP_PLAN.md` (unknown; release proof)

### 136. Unknown active status: MCP04_Accessibility_Shadow_MCP_Prompt

- Conflict ID: `AMB28-stale_or_unknown_active_status-38270259`
- Type: `stale_or_unknown_active_status`
- Severity: `yellow`
- Recommended action: `expedite`
- Rationale: Unknown active batch/prompt/train status should be clarified before it blocks or duplicates future work.
- Linear issue ready: `True`
- Auto-resolved: `False`
- Involved:
  - `MCP04_Accessibility_Shadow_MCP_Prompt` — `docs/codex/batches/MCP04_Accessibility_Shadow_MCP_Prompt.md` (unknown; release proof)

### 137. Unknown active status: MCP05_Ambitions_Twin_Fixture_MCP_Prompt

- Conflict ID: `AMB28-stale_or_unknown_active_status-34868085`
- Type: `stale_or_unknown_active_status`
- Severity: `yellow`
- Recommended action: `expedite`
- Rationale: Unknown active batch/prompt/train status should be clarified before it blocks or duplicates future work.
- Linear issue ready: `True`
- Auto-resolved: `False`
- Involved:
  - `MCP05_Ambitions_Twin_Fixture_MCP_Prompt` — `docs/codex/batches/MCP05_Ambitions_Twin_Fixture_MCP_Prompt.md` (unknown; release proof)

### 138. Unknown active status: MCP06_SOURCE_ATLAS_PACK_MCP_PLAN

- Conflict ID: `AMB28-stale_or_unknown_active_status-72347269`
- Type: `stale_or_unknown_active_status`
- Severity: `yellow`
- Recommended action: `expedite`
- Rationale: Unknown active batch/prompt/train status should be clarified before it blocks or duplicates future work.
- Linear issue ready: `True`
- Auto-resolved: `False`
- Involved:
  - `MCP06_SOURCE_ATLAS_PACK_MCP_PLAN` — `docs/codex/MCP06_SOURCE_ATLAS_PACK_MCP_PLAN.md` (unknown; release proof)

### 139. Unknown active status: MCP06_Source_Atlas_Pack_MCP_Prompt

- Conflict ID: `AMB28-stale_or_unknown_active_status-56547533`
- Type: `stale_or_unknown_active_status`
- Severity: `yellow`
- Recommended action: `expedite`
- Rationale: Unknown active batch/prompt/train status should be clarified before it blocks or duplicates future work.
- Linear issue ready: `True`
- Auto-resolved: `False`
- Involved:
  - `MCP06_Source_Atlas_Pack_MCP_Prompt` — `docs/codex/batches/MCP06_Source_Atlas_Pack_MCP_Prompt.md` (unknown; release proof)

### 140. Unknown active status: MCP07_RELEASE_TRUTH_MCP_PLAN

- Conflict ID: `AMB28-stale_or_unknown_active_status-52944432`
- Type: `stale_or_unknown_active_status`
- Severity: `yellow`
- Recommended action: `expedite`
- Rationale: Unknown active batch/prompt/train status should be clarified before it blocks or duplicates future work.
- Linear issue ready: `True`
- Auto-resolved: `False`
- Involved:
  - `MCP07_RELEASE_TRUTH_MCP_PLAN` — `docs/codex/MCP07_RELEASE_TRUTH_MCP_PLAN.md` (unknown; release proof)

### 141. Unknown active status: MCP07_Release_Truth_MCP_Prompt

- Conflict ID: `AMB28-stale_or_unknown_active_status-90340476`
- Type: `stale_or_unknown_active_status`
- Severity: `yellow`
- Recommended action: `expedite`
- Rationale: Unknown active batch/prompt/train status should be clarified before it blocks or duplicates future work.
- Linear issue ready: `True`
- Auto-resolved: `False`
- Involved:
  - `MCP07_Release_Truth_MCP_Prompt` — `docs/codex/batches/MCP07_Release_Truth_MCP_Prompt.md` (unknown; release proof)

### 142. Unknown active status: MOAT_RUNTIME_AUTONOMOUS_ROUTING_POLICY

- Conflict ID: `AMB28-stale_or_unknown_active_status-18304521`
- Type: `stale_or_unknown_active_status`
- Severity: `yellow`
- Recommended action: `expedite`
- Rationale: Unknown active batch/prompt/train status should be clarified before it blocks or duplicates future work.
- Linear issue ready: `True`
- Auto-resolved: `False`
- Involved:
  - `MOAT_RUNTIME_AUTONOMOUS_ROUTING_POLICY` — `docs/codex/MOAT_RUNTIME_AUTONOMOUS_ROUTING_POLICY.md` (unknown; release proof)

### 143. Unknown active status: MOAT_RUNTIME_LOOP_MATRIX

- Conflict ID: `AMB28-stale_or_unknown_active_status-93640146`
- Type: `stale_or_unknown_active_status`
- Severity: `yellow`
- Recommended action: `expedite`
- Rationale: Unknown active batch/prompt/train status should be clarified before it blocks or duplicates future work.
- Linear issue ready: `True`
- Auto-resolved: `False`
- Involved:
  - `MOAT_RUNTIME_LOOP_MATRIX` — `docs/codex/MOAT_RUNTIME_LOOP_MATRIX.md` (unknown; release proof)

### 144. Unknown active status: OBJECT_OS_INDEX

- Conflict ID: `AMB28-stale_or_unknown_active_status-54526119`
- Type: `stale_or_unknown_active_status`
- Severity: `yellow`
- Recommended action: `expedite`
- Rationale: Unknown active batch/prompt/train status should be clarified before it blocks or duplicates future work.
- Linear issue ready: `True`
- Auto-resolved: `False`
- Involved:
  - `OBJECT_OS_INDEX` — `docs/codex/OBJECT_OS_INDEX.md` (unknown; release proof)

### 145. Unknown active status: OBJECT_OS_MOTION_GRAMMAR

- Conflict ID: `AMB28-stale_or_unknown_active_status-82914632`
- Type: `stale_or_unknown_active_status`
- Severity: `yellow`
- Recommended action: `expedite`
- Rationale: Unknown active batch/prompt/train status should be clarified before it blocks or duplicates future work.
- Linear issue ready: `True`
- Auto-resolved: `False`
- Involved:
  - `OBJECT_OS_MOTION_GRAMMAR` — `docs/codex/OBJECT_OS_MOTION_GRAMMAR.md` (unknown; release proof)

### 146. Unknown active status: OBJECT_OS_SURFACE_MAP

- Conflict ID: `AMB28-stale_or_unknown_active_status-57820683`
- Type: `stale_or_unknown_active_status`
- Severity: `yellow`
- Recommended action: `expedite`
- Rationale: Unknown active batch/prompt/train status should be clarified before it blocks or duplicates future work.
- Linear issue ready: `True`
- Auto-resolved: `False`
- Involved:
  - `OBJECT_OS_SURFACE_MAP` — `docs/codex/OBJECT_OS_SURFACE_MAP.md` (unknown; release proof)

### 147. Unknown active status: OPENAI_BUILD_SUITE_ADOPTION_MATRIX

- Conflict ID: `AMB28-stale_or_unknown_active_status-75294213`
- Type: `stale_or_unknown_active_status`
- Severity: `yellow`
- Recommended action: `expedite`
- Rationale: Unknown active batch/prompt/train status should be clarified before it blocks or duplicates future work.
- Linear issue ready: `True`
- Auto-resolved: `False`
- Involved:
  - `OPENAI_BUILD_SUITE_ADOPTION_MATRIX` — `docs/codex/OPENAI_BUILD_SUITE_ADOPTION_MATRIX.md` (unknown; release proof)

### 148. Unknown active status: OPENAI_BUILD_SUITE_USAGE_POLICY

- Conflict ID: `AMB28-stale_or_unknown_active_status-55327995`
- Type: `stale_or_unknown_active_status`
- Severity: `yellow`
- Recommended action: `expedite`
- Rationale: Unknown active batch/prompt/train status should be clarified before it blocks or duplicates future work.
- Linear issue ready: `True`
- Auto-resolved: `False`
- Involved:
  - `OPENAI_BUILD_SUITE_USAGE_POLICY` — `docs/codex/OPENAI_BUILD_SUITE_USAGE_POLICY.md` (unknown; release proof)

### 149. Unknown active status: OPENAI_EVAL_QA_LAYER

- Conflict ID: `AMB28-stale_or_unknown_active_status-67427120`
- Type: `stale_or_unknown_active_status`
- Severity: `yellow`
- Recommended action: `expedite`
- Rationale: Unknown active batch/prompt/train status should be clarified before it blocks or duplicates future work.
- Linear issue ready: `True`
- Auto-resolved: `False`
- Involved:
  - `OPENAI_EVAL_QA_LAYER` — `docs/codex/OPENAI_EVAL_QA_LAYER.md` (unknown; release proof)

### 150. Unknown active status: PFC05A_Remove_Hosted_Workflows_Local_Validation_Gate_Prompt

- Conflict ID: `AMB28-stale_or_unknown_active_status-54907282`
- Type: `stale_or_unknown_active_status`
- Severity: `yellow`
- Recommended action: `expedite`
- Rationale: Unknown active batch/prompt/train status should be clarified before it blocks or duplicates future work.
- Linear issue ready: `True`
- Auto-resolved: `False`
- Involved:
  - `PFC05A_Remove_Hosted_Workflows_Local_Validation_Gate_Prompt` — `docs/codex/batches/PFC05A_Remove_Hosted_Workflows_Local_Validation_Gate_Prompt.md` (unknown; release proof)

### 151. Unknown active status: PFC08_Corruption_Recovery_Backup_Restore_Plan_Prompt

- Conflict ID: `AMB28-stale_or_unknown_active_status-98536605`
- Type: `stale_or_unknown_active_status`
- Severity: `yellow`
- Recommended action: `expedite`
- Rationale: Unknown active batch/prompt/train status should be clarified before it blocks or duplicates future work.
- Linear issue ready: `True`
- Auto-resolved: `False`
- Involved:
  - `PFC08_Corruption_Recovery_Backup_Restore_Plan_Prompt` — `docs/codex/batches/PFC08_Corruption_Recovery_Backup_Restore_Plan_Prompt.md` (unknown; release proof)

### 152. Unknown active status: PFC13_WidgetKit_Strategy_And_Object_Map_Prompt

- Conflict ID: `AMB28-stale_or_unknown_active_status-96340854`
- Type: `stale_or_unknown_active_status`
- Severity: `yellow`
- Recommended action: `expedite`
- Rationale: Unknown active batch/prompt/train status should be clarified before it blocks or duplicates future work.
- Linear issue ready: `True`
- Auto-resolved: `False`
- Involved:
  - `PFC13_WidgetKit_Strategy_And_Object_Map_Prompt` — `docs/codex/batches/PFC13_WidgetKit_Strategy_And_Object_Map_Prompt.md` (unknown; release proof)

### 153. Unknown active status: PFC23_Paywall_Upgrade_UX_Compliance_Review_Deferral_Prompt

- Conflict ID: `AMB28-stale_or_unknown_active_status-94714737`
- Type: `stale_or_unknown_active_status`
- Severity: `yellow`
- Recommended action: `expedite`
- Rationale: Unknown active batch/prompt/train status should be clarified before it blocks or duplicates future work.
- Linear issue ready: `True`
- Auto-resolved: `False`
- Involved:
  - `PFC23_Paywall_Upgrade_UX_Compliance_Review_Deferral_Prompt` — `docs/codex/batches/PFC23_Paywall_Upgrade_UX_Compliance_Review_Deferral_Prompt.md` (unknown; release proof)

### 154. Unknown active status: POST_PK_BATCH_BUNDLES

- Conflict ID: `AMB28-stale_or_unknown_active_status-15729521`
- Type: `stale_or_unknown_active_status`
- Severity: `yellow`
- Recommended action: `expedite`
- Rationale: Unknown active batch/prompt/train status should be clarified before it blocks or duplicates future work.
- Linear issue ready: `True`
- Auto-resolved: `False`
- Involved:
  - `POST_PK_BATCH_BUNDLES` — `docs/codex/POST_PK_BATCH_BUNDLES.md` (unknown; release proof)

### 155. Unknown active status: POST_PK_SPEED_TRAIN_OPERATING_MODEL

- Conflict ID: `AMB28-stale_or_unknown_active_status-53792786`
- Type: `stale_or_unknown_active_status`
- Severity: `yellow`
- Recommended action: `expedite`
- Rationale: Unknown active batch/prompt/train status should be clarified before it blocks or duplicates future work.
- Linear issue ready: `True`
- Auto-resolved: `False`
- Involved:
  - `POST_PK_SPEED_TRAIN_OPERATING_MODEL` — `docs/codex/POST_PK_SPEED_TRAIN_OPERATING_MODEL.md` (unknown; release proof)

### 156. Unknown active status: PRIVATE_LIFE_RUNTIME_WIRING_GATE

- Conflict ID: `AMB28-stale_or_unknown_active_status-44238123`
- Type: `stale_or_unknown_active_status`
- Severity: `yellow`
- Recommended action: `expedite`
- Rationale: Unknown active batch/prompt/train status should be clarified before it blocks or duplicates future work.
- Linear issue ready: `True`
- Auto-resolved: `False`
- Involved:
  - `PRIVATE_LIFE_RUNTIME_WIRING_GATE` — `docs/codex/PRIVATE_LIFE_RUNTIME_WIRING_GATE.md` (unknown; release proof)

### 157. Unknown active status: PROMPT_REPAIR_LAYER

- Conflict ID: `AMB28-stale_or_unknown_active_status-30572560`
- Type: `stale_or_unknown_active_status`
- Severity: `yellow`
- Recommended action: `expedite`
- Rationale: Unknown active batch/prompt/train status should be clarified before it blocks or duplicates future work.
- Linear issue ready: `True`
- Auto-resolved: `False`
- Involved:
  - `PROMPT_REPAIR_LAYER` — `docs/codex/PROMPT_REPAIR_LAYER.md` (unknown; release proof)

### 158. Unknown active status: PXEQ_MINIMALISM_WITH_UTILITY_RULES

- Conflict ID: `AMB28-stale_or_unknown_active_status-64727081`
- Type: `stale_or_unknown_active_status`
- Severity: `yellow`
- Recommended action: `expedite`
- Rationale: Unknown active batch/prompt/train status should be clarified before it blocks or duplicates future work.
- Linear issue ready: `True`
- Auto-resolved: `False`
- Involved:
  - `PXEQ_MINIMALISM_WITH_UTILITY_RULES` — `docs/codex/PXEQ_MINIMALISM_WITH_UTILITY_RULES.md` (unknown; release proof)

### 159. Unknown active status: PXEQ_MOTION_AND_STATE_CHANGE_RULES

- Conflict ID: `AMB28-stale_or_unknown_active_status-90274825`
- Type: `stale_or_unknown_active_status`
- Severity: `yellow`
- Recommended action: `expedite`
- Rationale: Unknown active batch/prompt/train status should be clarified before it blocks or duplicates future work.
- Linear issue ready: `True`
- Auto-resolved: `False`
- Involved:
  - `PXEQ_MOTION_AND_STATE_CHANGE_RULES` — `docs/codex/PXEQ_MOTION_AND_STATE_CHANGE_RULES.md` (unknown; release proof)

### 160. Unknown active status: PXEQ_SURFACE_BEHAVIOR_MATRIX

- Conflict ID: `AMB28-stale_or_unknown_active_status-13258298`
- Type: `stale_or_unknown_active_status`
- Severity: `yellow`
- Recommended action: `expedite`
- Rationale: Unknown active batch/prompt/train status should be clarified before it blocks or duplicates future work.
- Linear issue ready: `True`
- Auto-resolved: `False`
- Involved:
  - `PXEQ_SURFACE_BEHAVIOR_MATRIX` — `docs/codex/PXEQ_SURFACE_BEHAVIOR_MATRIX.md` (unknown; release proof)

### 161. Unknown active status: PXEQ_VISUAL_SYSTEM_CONSERVATIVE_FUTURISM_RULES

- Conflict ID: `AMB28-stale_or_unknown_active_status-8189291`
- Type: `stale_or_unknown_active_status`
- Severity: `yellow`
- Recommended action: `expedite`
- Rationale: Unknown active batch/prompt/train status should be clarified before it blocks or duplicates future work.
- Linear issue ready: `True`
- Auto-resolved: `False`
- Involved:
  - `PXEQ_VISUAL_SYSTEM_CONSERVATIVE_FUTURISM_RULES` — `docs/codex/PXEQ_VISUAL_SYSTEM_CONSERVATIVE_FUTURISM_RULES.md` (unknown; release proof)

### 162. Unknown active status: PXOS_CODEX_OS_UPGRADE_PROTOCOL

- Conflict ID: `AMB28-stale_or_unknown_active_status-6463436`
- Type: `stale_or_unknown_active_status`
- Severity: `yellow`
- Recommended action: `expedite`
- Rationale: Unknown active batch/prompt/train status should be clarified before it blocks or duplicates future work.
- Linear issue ready: `True`
- Auto-resolved: `False`
- Involved:
  - `PXOS_CODEX_OS_UPGRADE_PROTOCOL` — `docs/codex/PXOS_CODEX_OS_UPGRADE_PROTOCOL.md` (unknown; release proof)

### 163. Unknown active status: PXOS_DEPENDENCY_GRAPH

- Conflict ID: `AMB28-stale_or_unknown_active_status-27572453`
- Type: `stale_or_unknown_active_status`
- Severity: `yellow`
- Recommended action: `expedite`
- Rationale: Unknown active batch/prompt/train status should be clarified before it blocks or duplicates future work.
- Linear issue ready: `True`
- Auto-resolved: `False`
- Involved:
  - `PXOS_DEPENDENCY_GRAPH` — `docs/codex/PXOS_DEPENDENCY_GRAPH.md` (unknown; release proof)

### 164. Unknown active status: PXOS_DRIFT_DETECTION_PROTOCOL

- Conflict ID: `AMB28-stale_or_unknown_active_status-49174855`
- Type: `stale_or_unknown_active_status`
- Severity: `yellow`
- Recommended action: `expedite`
- Rationale: Unknown active batch/prompt/train status should be clarified before it blocks or duplicates future work.
- Linear issue ready: `True`
- Auto-resolved: `False`
- Involved:
  - `PXOS_DRIFT_DETECTION_PROTOCOL` — `docs/codex/PXOS_DRIFT_DETECTION_PROTOCOL.md` (unknown; release proof)

### 165. Unknown active status: README

- Conflict ID: `AMB28-stale_or_unknown_active_status-37735978`
- Type: `stale_or_unknown_active_status`
- Severity: `yellow`
- Recommended action: `expedite`
- Rationale: Unknown active batch/prompt/train status should be clarified before it blocks or duplicates future work.
- Linear issue ready: `True`
- Auto-resolved: `False`
- Involved:
  - `README` — `docs/codex/batch-trains/README.md` (unknown; release proof)

### 166. Unknown active status: REPO_INTELLIGENCE_LAYER

- Conflict ID: `AMB28-stale_or_unknown_active_status-37603821`
- Type: `stale_or_unknown_active_status`
- Severity: `yellow`
- Recommended action: `expedite`
- Rationale: Unknown active batch/prompt/train status should be clarified before it blocks or duplicates future work.
- Linear issue ready: `True`
- Auto-resolved: `False`
- Involved:
  - `REPO_INTELLIGENCE_LAYER` — `docs/codex/REPO_INTELLIGENCE_LAYER.md` (unknown; release proof)

### 167. Unknown active status: SIG01_Signature_Experience_Source_Truth_And_Delight_Map_Prompt

- Conflict ID: `AMB28-stale_or_unknown_active_status-19499812`
- Type: `stale_or_unknown_active_status`
- Severity: `yellow`
- Recommended action: `expedite`
- Rationale: Unknown active batch/prompt/train status should be clarified before it blocks or duplicates future work.
- Linear issue ready: `True`
- Auto-resolved: `False`
- Involved:
  - `SIG01_Signature_Experience_Source_Truth_And_Delight_Map_Prompt` — `docs/codex/batches/SIG01_Signature_Experience_Source_Truth_And_Delight_Map_Prompt.md` (unknown; release proof)

### 168. Unknown active status: SIG02_Premium_Interaction_Kit_Implementation_Prompt

- Conflict ID: `AMB28-stale_or_unknown_active_status-88231401`
- Type: `stale_or_unknown_active_status`
- Severity: `yellow`
- Recommended action: `expedite`
- Rationale: Unknown active batch/prompt/train status should be clarified before it blocks or duplicates future work.
- Linear issue ready: `True`
- Auto-resolved: `False`
- Involved:
  - `SIG02_Premium_Interaction_Kit_Implementation_Prompt` — `docs/codex/batches/SIG02_Premium_Interaction_Kit_Implementation_Prompt.md` (unknown; release proof)

### 169. Unknown active status: SIG04_Capture_Signature_Experience_Implementation_Prompt

- Conflict ID: `AMB28-stale_or_unknown_active_status-58430963`
- Type: `stale_or_unknown_active_status`
- Severity: `yellow`
- Recommended action: `expedite`
- Rationale: Unknown active batch/prompt/train status should be clarified before it blocks or duplicates future work.
- Linear issue ready: `True`
- Auto-resolved: `False`
- Involved:
  - `SIG04_Capture_Signature_Experience_Implementation_Prompt` — `docs/codex/batches/SIG04_Capture_Signature_Experience_Implementation_Prompt.md` (unknown; release proof)

### 170. Unknown active status: SIG05_Plan_Signature_Experience_Implementation_Prompt

- Conflict ID: `AMB28-stale_or_unknown_active_status-87710941`
- Type: `stale_or_unknown_active_status`
- Severity: `yellow`
- Recommended action: `expedite`
- Rationale: Unknown active batch/prompt/train status should be clarified before it blocks or duplicates future work.
- Linear issue ready: `True`
- Auto-resolved: `False`
- Involved:
  - `SIG05_Plan_Signature_Experience_Implementation_Prompt` — `docs/codex/batches/SIG05_Plan_Signature_Experience_Implementation_Prompt.md` (unknown; release proof)

### 171. Unknown active status: SIG07_You_Signature_Experience_Implementation_Prompt

- Conflict ID: `AMB28-stale_or_unknown_active_status-47657702`
- Type: `stale_or_unknown_active_status`
- Severity: `yellow`
- Recommended action: `expedite`
- Rationale: Unknown active batch/prompt/train status should be clarified before it blocks or duplicates future work.
- Linear issue ready: `True`
- Auto-resolved: `False`
- Involved:
  - `SIG07_You_Signature_Experience_Implementation_Prompt` — `docs/codex/batches/SIG07_You_Signature_Experience_Implementation_Prompt.md` (unknown; release proof)

### 172. Unknown active status: SIG08_Trust_And_Memory_Signature_Experience_Implementation_Prompt

- Conflict ID: `AMB28-stale_or_unknown_active_status-50076881`
- Type: `stale_or_unknown_active_status`
- Severity: `yellow`
- Recommended action: `expedite`
- Rationale: Unknown active batch/prompt/train status should be clarified before it blocks or duplicates future work.
- Linear issue ready: `True`
- Auto-resolved: `False`
- Involved:
  - `SIG08_Trust_And_Memory_Signature_Experience_Implementation_Prompt` — `docs/codex/batches/SIG08_Trust_And_Memory_Signature_Experience_Implementation_Prompt.md` (unknown; release proof)

### 173. Unknown active status: SIG09_Step_Session_Signature_Experience_Implementation_Prompt

- Conflict ID: `AMB28-stale_or_unknown_active_status-92409042`
- Type: `stale_or_unknown_active_status`
- Severity: `yellow`
- Recommended action: `expedite`
- Rationale: Unknown active batch/prompt/train status should be clarified before it blocks or duplicates future work.
- Linear issue ready: `True`
- Auto-resolved: `False`
- Involved:
  - `SIG09_Step_Session_Signature_Experience_Implementation_Prompt` — `docs/codex/batches/SIG09_Step_Session_Signature_Experience_Implementation_Prompt.md` (unknown; release proof)

### 174. Unknown active status: SIG10_Onboarding_First_Run_Signature_Experience_Implementation_Prompt

- Conflict ID: `AMB28-stale_or_unknown_active_status-82855499`
- Type: `stale_or_unknown_active_status`
- Severity: `yellow`
- Recommended action: `expedite`
- Rationale: Unknown active batch/prompt/train status should be clarified before it blocks or duplicates future work.
- Linear issue ready: `True`
- Auto-resolved: `False`
- Involved:
  - `SIG10_Onboarding_First_Run_Signature_Experience_Implementation_Prompt` — `docs/codex/batches/SIG10_Onboarding_First_Run_Signature_Experience_Implementation_Prompt.md` (unknown; release proof)

### 175. Unknown active status: SIG11_Haptics_Tactility_And_Feedback_Implementation_Prompt

- Conflict ID: `AMB28-stale_or_unknown_active_status-32873617`
- Type: `stale_or_unknown_active_status`
- Severity: `yellow`
- Recommended action: `expedite`
- Rationale: Unknown active batch/prompt/train status should be clarified before it blocks or duplicates future work.
- Linear issue ready: `True`
- Auto-resolved: `False`
- Involved:
  - `SIG11_Haptics_Tactility_And_Feedback_Implementation_Prompt` — `docs/codex/batches/SIG11_Haptics_Tactility_And_Feedback_Implementation_Prompt.md` (unknown; release proof)

### 176. Unknown active status: SIG12_Transformative_Transitions_Surface_Wiring_Prompt

- Conflict ID: `AMB28-stale_or_unknown_active_status-57710066`
- Type: `stale_or_unknown_active_status`
- Severity: `yellow`
- Recommended action: `expedite`
- Rationale: Unknown active batch/prompt/train status should be clarified before it blocks or duplicates future work.
- Linear issue ready: `True`
- Auto-resolved: `False`
- Involved:
  - `SIG12_Transformative_Transitions_Surface_Wiring_Prompt` — `docs/codex/batches/SIG12_Transformative_Transitions_Surface_Wiring_Prompt.md` (unknown; release proof)

### 177. Unknown active status: SIG13_Signature_Preview_Gallery_And_Demo_Scenarios_Prompt

- Conflict ID: `AMB28-stale_or_unknown_active_status-42293327`
- Type: `stale_or_unknown_active_status`
- Severity: `yellow`
- Recommended action: `expedite`
- Rationale: Unknown active batch/prompt/train status should be clarified before it blocks or duplicates future work.
- Linear issue ready: `True`
- Auto-resolved: `False`
- Involved:
  - `SIG13_Signature_Preview_Gallery_And_Demo_Scenarios_Prompt` — `docs/codex/batches/SIG13_Signature_Preview_Gallery_And_Demo_Scenarios_Prompt.md` (unknown; release proof)

### 178. Unknown active status: SIG14_Interaction_Performance_And_Battery_QA_Prompt

- Conflict ID: `AMB28-stale_or_unknown_active_status-62640237`
- Type: `stale_or_unknown_active_status`
- Severity: `yellow`
- Recommended action: `expedite`
- Rationale: Unknown active batch/prompt/train status should be clarified before it blocks or duplicates future work.
- Linear issue ready: `True`
- Auto-resolved: `False`
- Involved:
  - `SIG14_Interaction_Performance_And_Battery_QA_Prompt` — `docs/codex/batches/SIG14_Interaction_Performance_And_Battery_QA_Prompt.md` (unknown; release proof)

### 179. Unknown active status: SIG15_Accessibility_Motion_And_Cognitive_Load_Closeout_Prompt

- Conflict ID: `AMB28-stale_or_unknown_active_status-67604501`
- Type: `stale_or_unknown_active_status`
- Severity: `yellow`
- Recommended action: `expedite`
- Rationale: Unknown active batch/prompt/train status should be clarified before it blocks or duplicates future work.
- Linear issue ready: `True`
- Auto-resolved: `False`
- Involved:
  - `SIG15_Accessibility_Motion_And_Cognitive_Load_Closeout_Prompt` — `docs/codex/batches/SIG15_Accessibility_Motion_And_Cognitive_Load_Closeout_Prompt.md` (unknown; release proof)

### 180. Unknown active status: SIG16_Signature_Experience_Closeout_Prompt

- Conflict ID: `AMB28-stale_or_unknown_active_status-67134249`
- Type: `stale_or_unknown_active_status`
- Severity: `yellow`
- Recommended action: `expedite`
- Rationale: Unknown active batch/prompt/train status should be clarified before it blocks or duplicates future work.
- Linear issue ready: `True`
- Auto-resolved: `False`
- Involved:
  - `SIG16_Signature_Experience_Closeout_Prompt` — `docs/codex/batches/SIG16_Signature_Experience_Closeout_Prompt.md` (unknown; release proof)

### 181. Unknown active status: SIG_DEPENDENCY_AND_TOOLING_LEDGER

- Conflict ID: `AMB28-stale_or_unknown_active_status-83021882`
- Type: `stale_or_unknown_active_status`
- Severity: `yellow`
- Recommended action: `expedite`
- Rationale: Unknown active batch/prompt/train status should be clarified before it blocks or duplicates future work.
- Linear issue ready: `True`
- Auto-resolved: `False`
- Involved:
  - `SIG_DEPENDENCY_AND_TOOLING_LEDGER` — `docs/codex/SIG_DEPENDENCY_AND_TOOLING_LEDGER.md` (unknown; release proof)

### 182. Unknown active status: SIG_EMOTIONAL_DESIGN_MOMENTS_MAP

- Conflict ID: `AMB28-stale_or_unknown_active_status-18400160`
- Type: `stale_or_unknown_active_status`
- Severity: `yellow`
- Recommended action: `expedite`
- Rationale: Unknown active batch/prompt/train status should be clarified before it blocks or duplicates future work.
- Linear issue ready: `True`
- Auto-resolved: `False`
- Involved:
  - `SIG_EMOTIONAL_DESIGN_MOMENTS_MAP` — `docs/codex/SIG_EMOTIONAL_DESIGN_MOMENTS_MAP.md` (unknown; release proof)

### 183. Unknown active status: SIG_FLUIDITY_AND_DELIGHT_PROTOCOL

- Conflict ID: `AMB28-stale_or_unknown_active_status-99205072`
- Type: `stale_or_unknown_active_status`
- Severity: `yellow`
- Recommended action: `expedite`
- Rationale: Unknown active batch/prompt/train status should be clarified before it blocks or duplicates future work.
- Linear issue ready: `True`
- Auto-resolved: `False`
- Involved:
  - `SIG_FLUIDITY_AND_DELIGHT_PROTOCOL` — `docs/codex/SIG_FLUIDITY_AND_DELIGHT_PROTOCOL.md` (unknown; release proof)

### 184. Unknown active status: SIG_PREMIUM_INTERACTION_PRINCIPLES

- Conflict ID: `AMB28-stale_or_unknown_active_status-77478953`
- Type: `stale_or_unknown_active_status`
- Severity: `yellow`
- Recommended action: `expedite`
- Rationale: Unknown active batch/prompt/train status should be clarified before it blocks or duplicates future work.
- Linear issue ready: `True`
- Auto-resolved: `False`
- Involved:
  - `SIG_PREMIUM_INTERACTION_PRINCIPLES` — `docs/codex/SIG_PREMIUM_INTERACTION_PRINCIPLES.md` (unknown; release proof)

### 185. Unknown active status: SIG_SIGNATURE_EXPERIENCE_DEPENDENCY_GRAPH

- Conflict ID: `AMB28-stale_or_unknown_active_status-33896861`
- Type: `stale_or_unknown_active_status`
- Severity: `yellow`
- Recommended action: `expedite`
- Rationale: Unknown active batch/prompt/train status should be clarified before it blocks or duplicates future work.
- Linear issue ready: `True`
- Auto-resolved: `False`
- Involved:
  - `SIG_SIGNATURE_EXPERIENCE_DEPENDENCY_GRAPH` — `docs/codex/SIG_SIGNATURE_EXPERIENCE_DEPENDENCY_GRAPH.md` (unknown; release proof)

### 186. Unknown active status: SOURCE_ATLAS_COMPOSITION_GOAL_PROJECTION_MODEL

- Conflict ID: `AMB28-stale_or_unknown_active_status-47202674`
- Type: `stale_or_unknown_active_status`
- Severity: `yellow`
- Recommended action: `expedite`
- Rationale: Unknown active batch/prompt/train status should be clarified before it blocks or duplicates future work.
- Linear issue ready: `True`
- Auto-resolved: `False`
- Involved:
  - `SOURCE_ATLAS_COMPOSITION_GOAL_PROJECTION_MODEL` — `docs/codex/SOURCE_ATLAS_COMPOSITION_GOAL_PROJECTION_MODEL.md` (unknown; release proof)

### 187. Unknown active status: SOURCE_ATLAS_HPS_AOS_LDI_INTEGRATION_MAP

- Conflict ID: `AMB28-stale_or_unknown_active_status-79694470`
- Type: `stale_or_unknown_active_status`
- Severity: `yellow`
- Recommended action: `expedite`
- Rationale: Unknown active batch/prompt/train status should be clarified before it blocks or duplicates future work.
- Linear issue ready: `True`
- Auto-resolved: `False`
- Involved:
  - `SOURCE_ATLAS_HPS_AOS_LDI_INTEGRATION_MAP` — `docs/codex/SOURCE_ATLAS_HPS_AOS_LDI_INTEGRATION_MAP.md` (unknown; release proof)

### 188. Unknown active status: SOURCE_ATLAS_OFFICIAL_ADAPTER_CONTRACTS

- Conflict ID: `AMB28-stale_or_unknown_active_status-14128183`
- Type: `stale_or_unknown_active_status`
- Severity: `yellow`
- Recommended action: `expedite`
- Rationale: Unknown active batch/prompt/train status should be clarified before it blocks or duplicates future work.
- Linear issue ready: `True`
- Auto-resolved: `False`
- Involved:
  - `SOURCE_ATLAS_OFFICIAL_ADAPTER_CONTRACTS` — `docs/codex/SOURCE_ATLAS_OFFICIAL_ADAPTER_CONTRACTS.md` (unknown; release proof)

### 189. Unknown active status: SOURCE_ATLAS_PROJECTION_QA_FIXTURE_FAMILIES

- Conflict ID: `AMB28-stale_or_unknown_active_status-48170345`
- Type: `stale_or_unknown_active_status`
- Severity: `yellow`
- Recommended action: `expedite`
- Rationale: Unknown active batch/prompt/train status should be clarified before it blocks or duplicates future work.
- Linear issue ready: `True`
- Auto-resolved: `False`
- Involved:
  - `SOURCE_ATLAS_PROJECTION_QA_FIXTURE_FAMILIES` — `docs/codex/SOURCE_ATLAS_PROJECTION_QA_FIXTURE_FAMILIES.md` (unknown; release proof)

### 190. Unknown active status: SOURCE_ATLAS_RESEARCH_SEEDS_V1_IMPORT_PROMPT

- Conflict ID: `AMB28-stale_or_unknown_active_status-5292663`
- Type: `stale_or_unknown_active_status`
- Severity: `yellow`
- Recommended action: `expedite`
- Rationale: Unknown active batch/prompt/train status should be clarified before it blocks or duplicates future work.
- Linear issue ready: `True`
- Auto-resolved: `False`
- Involved:
  - `SOURCE_ATLAS_RESEARCH_SEEDS_V1_IMPORT_PROMPT` — `docs/codex/batches/SOURCE_ATLAS_RESEARCH_SEEDS_V1_IMPORT_PROMPT.md` (unknown; release proof)

### 191. Unknown active status: SOURCE_ATLAS_RESEARCH_SEEDS_V1_IMPORT_REPORT

- Conflict ID: `AMB28-stale_or_unknown_active_status-8049311`
- Type: `stale_or_unknown_active_status`
- Severity: `yellow`
- Recommended action: `expedite`
- Rationale: Unknown active batch/prompt/train status should be clarified before it blocks or duplicates future work.
- Linear issue ready: `True`
- Auto-resolved: `False`
- Involved:
  - `SOURCE_ATLAS_RESEARCH_SEEDS_V1_IMPORT_REPORT` — `docs/codex/SOURCE_ATLAS_RESEARCH_SEEDS_V1_IMPORT_REPORT.md` (unknown; release proof)

### 192. Unknown active status: SOURCE_ATLAS_RESEARCH_SEEDS_V1_LIMITATIONS

- Conflict ID: `AMB28-stale_or_unknown_active_status-64860225`
- Type: `stale_or_unknown_active_status`
- Severity: `yellow`
- Recommended action: `expedite`
- Rationale: Unknown active batch/prompt/train status should be clarified before it blocks or duplicates future work.
- Linear issue ready: `True`
- Auto-resolved: `False`
- Involved:
  - `SOURCE_ATLAS_RESEARCH_SEEDS_V1_LIMITATIONS` — `docs/codex/SOURCE_ATLAS_RESEARCH_SEEDS_V1_LIMITATIONS.md` (unknown; release proof)

### 193. Unknown active status: SPEED_TRAIN_LANE_POLICY

- Conflict ID: `AMB28-stale_or_unknown_active_status-62491878`
- Type: `stale_or_unknown_active_status`
- Severity: `yellow`
- Recommended action: `expedite`
- Rationale: Unknown active batch/prompt/train status should be clarified before it blocks or duplicates future work.
- Linear issue ready: `True`
- Auto-resolved: `False`
- Involved:
  - `SPEED_TRAIN_LANE_POLICY` — `docs/codex/SPEED_TRAIN_LANE_POLICY.json` (unknown; release proof)

### 194. Unknown active status: SPEED_TRAIN_QUICKSTART

- Conflict ID: `AMB28-stale_or_unknown_active_status-93567994`
- Type: `stale_or_unknown_active_status`
- Severity: `yellow`
- Recommended action: `expedite`
- Rationale: Unknown active batch/prompt/train status should be clarified before it blocks or duplicates future work.
- Linear issue ready: `True`
- Auto-resolved: `False`
- Involved:
  - `SPEED_TRAIN_QUICKSTART` — `docs/codex/SPEED_TRAIN_QUICKSTART.md` (unknown; release proof)

### 195. Unknown active status: TRANSFORMATIVE_MOTION_DEPENDENCY_GRAPH

- Conflict ID: `AMB28-stale_or_unknown_active_status-86783669`
- Type: `stale_or_unknown_active_status`
- Severity: `yellow`
- Recommended action: `expedite`
- Rationale: Unknown active batch/prompt/train status should be clarified before it blocks or duplicates future work.
- Linear issue ready: `True`
- Auto-resolved: `False`
- Involved:
  - `TRANSFORMATIVE_MOTION_DEPENDENCY_GRAPH` — `docs/codex/TRANSFORMATIVE_MOTION_DEPENDENCY_GRAPH.md` (unknown; release proof)

### 196. Unknown active status: TRANSFORMATIVE_MOTION_IMPLEMENTATION_PROTOCOL

- Conflict ID: `AMB28-stale_or_unknown_active_status-73132676`
- Type: `stale_or_unknown_active_status`
- Severity: `yellow`
- Recommended action: `expedite`
- Rationale: Unknown active batch/prompt/train status should be clarified before it blocks or duplicates future work.
- Linear issue ready: `True`
- Auto-resolved: `False`
- Involved:
  - `TRANSFORMATIVE_MOTION_IMPLEMENTATION_PROTOCOL` — `docs/codex/TRANSFORMATIVE_MOTION_IMPLEMENTATION_PROTOCOL.md` (unknown; release proof)

### 197. Unknown active status: TUIST_EVALUATION_AFTER_PK41_PLAYBOOK

- Conflict ID: `AMB28-stale_or_unknown_active_status-37539013`
- Type: `stale_or_unknown_active_status`
- Severity: `yellow`
- Recommended action: `expedite`
- Rationale: Unknown active batch/prompt/train status should be clarified before it blocks or duplicates future work.
- Linear issue ready: `True`
- Auto-resolved: `False`
- Involved:
  - `TUIST_EVALUATION_AFTER_PK41_PLAYBOOK` — `docs/codex/playbooks/TUIST_EVALUATION_AFTER_PK41_PLAYBOOK.md` (unknown; release proof)

### 198. Unknown active status: VISUAL_CRITIQUE_LAYER

- Conflict ID: `AMB28-stale_or_unknown_active_status-35919995`
- Type: `stale_or_unknown_active_status`
- Severity: `yellow`
- Recommended action: `expedite`
- Rationale: Unknown active batch/prompt/train status should be clarified before it blocks or duplicates future work.
- Linear issue ready: `True`
- Auto-resolved: `False`
- Involved:
  - `VISUAL_CRITIQUE_LAYER` — `docs/codex/VISUAL_CRITIQUE_LAYER.md` (unknown; release proof)

### 199. Unknown active status: XCODE_BUILD_LAB_PROTOCOL

- Conflict ID: `AMB28-stale_or_unknown_active_status-52246889`
- Type: `stale_or_unknown_active_status`
- Severity: `yellow`
- Recommended action: `expedite`
- Rationale: Unknown active batch/prompt/train status should be clarified before it blocks or duplicates future work.
- Linear issue ready: `True`
- Auto-resolved: `False`
- Involved:
  - `XCODE_BUILD_LAB_PROTOCOL` — `docs/codex/XCODE_BUILD_LAB_PROTOCOL.md` (unknown; release proof)

### 200. Unknown active status: XCODE_FAILURE_CLASSIFICATION_PLAYBOOK

- Conflict ID: `AMB28-stale_or_unknown_active_status-25466167`
- Type: `stale_or_unknown_active_status`
- Severity: `yellow`
- Recommended action: `expedite`
- Rationale: Unknown active batch/prompt/train status should be clarified before it blocks or duplicates future work.
- Linear issue ready: `True`
- Auto-resolved: `False`
- Involved:
  - `XCODE_FAILURE_CLASSIFICATION_PLAYBOOK` — `docs/codex/playbooks/XCODE_FAILURE_CLASSIFICATION_PLAYBOOK.md` (unknown; release proof)

### 201. Unknown active status: XCODE_RESULT_BUNDLE_PROTOCOL

- Conflict ID: `AMB28-stale_or_unknown_active_status-26506364`
- Type: `stale_or_unknown_active_status`
- Severity: `yellow`
- Recommended action: `expedite`
- Rationale: Unknown active batch/prompt/train status should be clarified before it blocks or duplicates future work.
- Linear issue ready: `True`
- Auto-resolved: `False`
- Involved:
  - `XCODE_RESULT_BUNDLE_PROTOCOL` — `docs/codex/XCODE_RESULT_BUNDLE_PROTOCOL.md` (unknown; release proof)

### 202. Unknown active status: XCODE_SICK_SIMULATOR_PLAYBOOK

- Conflict ID: `AMB28-stale_or_unknown_active_status-9017758`
- Type: `stale_or_unknown_active_status`
- Severity: `yellow`
- Recommended action: `expedite`
- Rationale: Unknown active batch/prompt/train status should be clarified before it blocks or duplicates future work.
- Linear issue ready: `True`
- Auto-resolved: `False`
- Involved:
  - `XCODE_SICK_SIMULATOR_PLAYBOOK` — `docs/codex/playbooks/XCODE_SICK_SIMULATOR_PLAYBOOK.md` (unknown; release proof)

### 203. Unknown active status: XCODE_TEST_PLAN_OWNERSHIP_PLAYBOOK

- Conflict ID: `AMB28-stale_or_unknown_active_status-65544824`
- Type: `stale_or_unknown_active_status`
- Severity: `yellow`
- Recommended action: `expedite`
- Rationale: Unknown active batch/prompt/train status should be clarified before it blocks or duplicates future work.
- Linear issue ready: `True`
- Auto-resolved: `False`
- Involved:
  - `XCODE_TEST_PLAN_OWNERSHIP_PLAYBOOK` — `docs/codex/playbooks/XCODE_TEST_PLAN_OWNERSHIP_PLAYBOOK.md` (unknown; release proof)

### 204. Unknown active status: XCODE_TOOLCHAIN_PINNING

- Conflict ID: `AMB28-stale_or_unknown_active_status-50074409`
- Type: `stale_or_unknown_active_status`
- Severity: `yellow`
- Recommended action: `expedite`
- Rationale: Unknown active batch/prompt/train status should be clarified before it blocks or duplicates future work.
- Linear issue ready: `True`
- Auto-resolved: `False`
- Involved:
  - `XCODE_TOOLCHAIN_PINNING` — `docs/codex/XCODE_TOOLCHAIN_PINNING.md` (unknown; release proof)

### 205. Unknown active status: XCODE_VALIDATION_LANE_MATRIX

- Conflict ID: `AMB28-stale_or_unknown_active_status-86683476`
- Type: `stale_or_unknown_active_status`
- Severity: `yellow`
- Recommended action: `expedite`
- Rationale: Unknown active batch/prompt/train status should be clarified before it blocks or duplicates future work.
- Linear issue ready: `True`
- Auto-resolved: `False`
- Involved:
  - `XCODE_VALIDATION_LANE_MATRIX` — `docs/codex/XCODE_VALIDATION_LANE_MATRIX.md` (unknown; release proof)

### 206. Unknown active status: existing-code-champion-coverage

- Conflict ID: `AMB28-stale_or_unknown_active_status-48868931`
- Type: `stale_or_unknown_active_status`
- Severity: `yellow`
- Recommended action: `expedite`
- Rationale: Unknown active batch/prompt/train status should be clarified before it blocks or duplicates future work.
- Linear issue ready: `True`
- Auto-resolved: `False`
- Involved:
  - `existing-code-champion-coverage` — `docs/codex/existing-code-champion-coverage.yml` (unknown; release proof)

### 207. Unknown active status: platform-kernel-module-boundary-scaffold

- Conflict ID: `AMB28-stale_or_unknown_active_status-29559305`
- Type: `stale_or_unknown_active_status`
- Severity: `yellow`
- Recommended action: `expedite`
- Rationale: Unknown active batch/prompt/train status should be clarified before it blocks or duplicates future work.
- Linear issue ready: `True`
- Auto-resolved: `False`
- Involved:
  - `platform-kernel-module-boundary-scaffold` — `docs/codex/platform-kernel-module-boundary-scaffold.md` (unknown; release proof)


## Recommendation semantics

- `retire`: remove from active execution or mark historical/superseded.
- `expedite`: clarify priority/status/owner before downstream execution.
- `finish`: add missing proof or complete the partially implemented work.
- `merge`: combine duplicate or overlapping scopes into one authority/work item.
- `rewrite`: update retired language, stale IA, or missing authority references.

## Non-claims

- This report does not auto-resolve any conflict.
- Recommended actions are Linear-ready proposals, not execution.
- Linear status is not repo truth.
- This report does not prove build, tests, accessibility, performance, device, privacy, legal, TestFlight, App Store, or release readiness.
