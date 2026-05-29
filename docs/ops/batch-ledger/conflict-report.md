# Batch Duplicate-Work and Conflict Report

Generated UTC: 2026-05-29T01:57:38Z
Owner: BATCH-LEDGER-001
Linear issue: AMB-28

## Status

- Validation: `green`
- Total conflicts: `742`
- Auto-resolved conflicts: `0`

## Counts by conflict type

- `duplicate_stable_id`: `32`
- `missing_source_of_truth_reference`: `17`
- `retired_ia_or_terminology_reference`: `176`
- `same_source_file_targeted_by_multiple_active_batches`: `270`
- `same_surface_multiple_active_batches`: `6`
- `source_only_implementation_missing_proof`: `20`
- `stale_or_unknown_active_status`: `221`

## Counts by recommended action

- `expedite`: `228`
- `finish`: `19`
- `merge`: `302`
- `rewrite`: `193`

## Same surface touched by multiple active batches

### 1. Same surface touched by multiple active items: Capture

- Conflict ID: `AMB28-same_surface_multiple_active_batches-96568748`
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
  - `GLOBAL_FUTURE_BATCH_GATE_MATRIX` — `docs/codex/GLOBAL_FUTURE_BATCH_GATE_MATRIX.md` (partial_implementation; release proof)
  - `PXOS_GATE_MATRIX` — `docs/codex/PXOS_GATE_MATRIX.md` (partial_implementation; release proof)
  - `PXOS_HANDOFF_PACKAGE` — `docs/codex/PXOS_HANDOFF_PACKAGE.md` (partial_implementation; release proof)
  - `REC02_Human_Operator_Release_Proof_Plan` — `docs/codex/REC02_Human_Operator_Release_Proof_Plan.md` (partial_implementation; release proof)
  - `REC05_Human_Review_Packet` — `docs/codex/REC05_Human_Review_Packet.md` (partial_implementation; release proof)
  - `REC06_Release_Evidence_Closure_Handoff` — `docs/codex/REC06_Release_Evidence_Closure_Handoff.md` (partial_implementation; release proof)
  - `AOS01_AOS30_AMBITIONSOS_LOCAL_INTELLIGENCE_TRAIN` — `docs/codex/batch-trains/AOS01_AOS30_AMBITIONSOS_LOCAL_INTELLIGENCE_TRAIN.md` (partial_implementation; release proof)
  - `PD01_PD18_PRODUCT_DEPTH_TRAIN` — `docs/codex/batch-trains/PD01_PD18_PRODUCT_DEPTH_TRAIN.md` (partial_implementation; release proof)
  - `PX01_PX20_PRODUCT_EXPERIENCE_OS_TRAIN` — `docs/codex/batch-trains/PX01_PX20_PRODUCT_EXPERIENCE_OS_TRAIN.md` (partial_implementation; release proof)
  - `SI01_SI18_SIGNATURE_INTERFACE_IMPLEMENTATION_TRAIN` — `docs/codex/batch-trains/SI01_SI18_SIGNATURE_INTERFACE_IMPLEMENTATION_TRAIN.md` (partial_implementation; release proof)
  - `AOS01_AmbitionsOS_Canon_And_Runtime_Contract_Prompt` — `docs/codex/batches/AOS01_AmbitionsOS_Canon_And_Runtime_Contract_Prompt.md` (partial_implementation; release proof)
  - `AOS02_Life_Graph_Event_Log_Foundation_Prompt` — `docs/codex/batches/AOS02_Life_Graph_Event_Log_Foundation_Prompt.md` (partial_implementation; release proof)
  - `AOS03_Graph_Delta_Review_Projection_Store_Prompt` — `docs/codex/batches/AOS03_Graph_Delta_Review_Projection_Store_Prompt.md` (partial_implementation; release proof)
  - `AOS04_Control_Plane_Work_Classifier_Prompt` — `docs/codex/batches/AOS04_Control_Plane_Work_Classifier_Prompt.md` (partial_implementation; release proof)
  - `AOS05_Starting_Position_Kernel_Prompt` — `docs/codex/batches/AOS05_Starting_Position_Kernel_Prompt.md` (partial_implementation; release proof)
  - `AOS06_Goal_Path_Kernel_Goal_Compiler_Prompt` — `docs/codex/batches/AOS06_Goal_Path_Kernel_Goal_Compiler_Prompt.md` (partial_implementation; release proof)
  - `AOS07_Local_Goal_Packs_Requirement_Slots_Prompt` — `docs/codex/batches/AOS07_Local_Goal_Packs_Requirement_Slots_Prompt.md` (partial_implementation; release proof)
  - `AOS08_Alternate_Path_Kernel_Path_Portfolio_Prompt` — `docs/codex/batches/AOS08_Alternate_Path_Kernel_Path_Portfolio_Prompt.md` (partial_implementation; release proof)
  - ... 466 more

### 2. Same surface touched by multiple active items: Goals

- Conflict ID: `AMB28-same_surface_multiple_active_batches-26899932`
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
  - `GLOBAL_FUTURE_BATCH_GATE_MATRIX` — `docs/codex/GLOBAL_FUTURE_BATCH_GATE_MATRIX.md` (partial_implementation; release proof)
  - `PXOS_GATE_MATRIX` — `docs/codex/PXOS_GATE_MATRIX.md` (partial_implementation; release proof)
  - `PXOS_HANDOFF_PACKAGE` — `docs/codex/PXOS_HANDOFF_PACKAGE.md` (partial_implementation; release proof)
  - `REC02_Human_Operator_Release_Proof_Plan` — `docs/codex/REC02_Human_Operator_Release_Proof_Plan.md` (partial_implementation; release proof)
  - `REC05_Human_Review_Packet` — `docs/codex/REC05_Human_Review_Packet.md` (partial_implementation; release proof)
  - `AOS01_AOS30_AMBITIONSOS_LOCAL_INTELLIGENCE_TRAIN` — `docs/codex/batch-trains/AOS01_AOS30_AMBITIONSOS_LOCAL_INTELLIGENCE_TRAIN.md` (partial_implementation; release proof)
  - `PD01_PD18_PRODUCT_DEPTH_TRAIN` — `docs/codex/batch-trains/PD01_PD18_PRODUCT_DEPTH_TRAIN.md` (partial_implementation; release proof)
  - `PX01_PX20_PRODUCT_EXPERIENCE_OS_TRAIN` — `docs/codex/batch-trains/PX01_PX20_PRODUCT_EXPERIENCE_OS_TRAIN.md` (partial_implementation; release proof)
  - `SI01_SI18_SIGNATURE_INTERFACE_IMPLEMENTATION_TRAIN` — `docs/codex/batch-trains/SI01_SI18_SIGNATURE_INTERFACE_IMPLEMENTATION_TRAIN.md` (partial_implementation; release proof)
  - `AOS01_AmbitionsOS_Canon_And_Runtime_Contract_Prompt` — `docs/codex/batches/AOS01_AmbitionsOS_Canon_And_Runtime_Contract_Prompt.md` (partial_implementation; release proof)
  - `AOS02_Life_Graph_Event_Log_Foundation_Prompt` — `docs/codex/batches/AOS02_Life_Graph_Event_Log_Foundation_Prompt.md` (partial_implementation; release proof)
  - `AOS03_Graph_Delta_Review_Projection_Store_Prompt` — `docs/codex/batches/AOS03_Graph_Delta_Review_Projection_Store_Prompt.md` (partial_implementation; release proof)
  - `AOS04_Control_Plane_Work_Classifier_Prompt` — `docs/codex/batches/AOS04_Control_Plane_Work_Classifier_Prompt.md` (partial_implementation; release proof)
  - `AOS05_Starting_Position_Kernel_Prompt` — `docs/codex/batches/AOS05_Starting_Position_Kernel_Prompt.md` (partial_implementation; release proof)
  - `AOS06_Goal_Path_Kernel_Goal_Compiler_Prompt` — `docs/codex/batches/AOS06_Goal_Path_Kernel_Goal_Compiler_Prompt.md` (partial_implementation; release proof)
  - ... 475 more

### 3. Same surface touched by multiple active items: Pulse

- Conflict ID: `AMB28-same_surface_multiple_active_batches-62616276`
- Type: `same_surface_multiple_active_batches`
- Severity: `yellow`
- Recommended action: `expedite`
- Rationale: Many active ledger items touch the same surface; expedite sequence ownership through batch-ledger planning before running more work.
- Linear issue ready: `True`
- Auto-resolved: `False`
- Involved:
  - `PX08_Trust_Proof_Receipts_Experience_Prompt` — `docs/codex/batches/PX08_Trust_Proof_Receipts_Experience_Prompt.md` (partial_implementation; release proof)
  - `DAV_PRODUCT_EXPERIENCE_SCORECARD` — `docs/codex/DAV_PRODUCT_EXPERIENCE_SCORECARD.md` (partial_implementation; release proof)
  - `DAV02_Reusable_Living_Visual_Primitives_Implementation_Prompt` — `docs/codex/batches/DAV02_Reusable_Living_Visual_Primitives_Implementation_Prompt.md` (partial_implementation; release proof)
  - `DAV06_Goals_MissionControlLanes_Implementation_Prompt` — `docs/codex/batches/DAV06_Goals_MissionControlLanes_Implementation_Prompt.md` (partial_implementation; release proof)
  - `DAV09_TrustReceiptStack_EvidenceLabels_And_ProofPulse_Implementation_Prompt` — `docs/codex/batches/DAV09_TrustReceiptStack_EvidenceLabels_And_ProofPulse_Implementation_Prompt.md` (partial_implementation; release proof)
  - `DAV10_AdaptiveMotion_ReduceMotion_And_StateTransitions_Prompt` — `docs/codex/batches/DAV10_AdaptiveMotion_ReduceMotion_And_StateTransitions_Prompt.md` (partial_implementation; release proof)
  - `AQOS_SCRIPT_AND_TOOL_MAP` — `docs/codex/quality/AQOS_SCRIPT_AND_TOOL_MAP.md` (partial_implementation; release proof)
  - `POST_BATCH_GATE_REGISTRY` — `docs/codex/POST_BATCH_GATE_REGISTRY.md` (partial_implementation; release proof)
  - `VISUAL_CANON_MOAT_IMPLEMENTATION_OVERLAY` — `docs/codex/VISUAL_CANON_MOAT_IMPLEMENTATION_OVERLAY.md` (partial_implementation; release proof)
  - `VISUAL-ENCYCLOPEDIA-100-PROOF-HARDENING-03` — `prompts/batches/VISUAL-ENCYCLOPEDIA-100-PROOF-HARDENING-03.md` (partial_implementation; release proof)
  - `AMB-POST23-01-TRUTH-AUDIT` — `docs/codex/reports/AMB-POST23-01-TRUTH-AUDIT.md` (partial_implementation; release proof)
  - `TRAIN_04C_SOURCE_ATLAS_RUNTIME_COMPILER_BRIDGE` — `prompts/trains/ios26-flagship/TRAIN_04C_SOURCE_ATLAS_RUNTIME_COMPILER_BRIDGE.md` (partial_implementation; release proof)
  - `LINEAR_CONTROL_PLANE` — `docs/codex/LINEAR_CONTROL_PLANE.md` (partial_implementation; release proof)
  - `PXEQ_SURFACE_BEHAVIOR_MATRIX` — `docs/codex/PXEQ_SURFACE_BEHAVIOR_MATRIX.md` (unknown; release proof)
  - `SIG_EMOTIONAL_DESIGN_MOMENTS_MAP` — `docs/codex/SIG_EMOTIONAL_DESIGN_MOMENTS_MAP.md` (unknown; release proof)
  - `OBJECT_OS_SURFACE_MAP` — `docs/codex/OBJECT_OS_SURFACE_MAP.md` (unknown; release proof)

### 4. Same surface touched by multiple active items: Time

- Conflict ID: `AMB28-same_surface_multiple_active_batches-66075429`
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
  - `GLOBAL_BATCH_EXECUTION_ORCHESTRATOR` — `docs/codex/GLOBAL_BATCH_EXECUTION_ORCHESTRATOR.md` (partial_implementation; release proof)
  - `GLOBAL_BATCH_REPAIR_LOOP_PROTOCOL` — `docs/codex/GLOBAL_BATCH_REPAIR_LOOP_PROTOCOL.md` (partial_implementation; release proof)
  - `GLOBAL_FUTURE_BATCH_GATE_MATRIX` — `docs/codex/GLOBAL_FUTURE_BATCH_GATE_MATRIX.md` (partial_implementation; release proof)
  - `PXOS_HANDOFF_PACKAGE` — `docs/codex/PXOS_HANDOFF_PACKAGE.md` (partial_implementation; release proof)
  - `REC02_Human_Operator_Release_Proof_Plan` — `docs/codex/REC02_Human_Operator_Release_Proof_Plan.md` (partial_implementation; release proof)
  - `REC05_Human_Review_Packet` — `docs/codex/REC05_Human_Review_Packet.md` (partial_implementation; release proof)
  - `AOS01_AOS30_AMBITIONSOS_LOCAL_INTELLIGENCE_TRAIN` — `docs/codex/batch-trains/AOS01_AOS30_AMBITIONSOS_LOCAL_INTELLIGENCE_TRAIN.md` (partial_implementation; release proof)
  - `PD01_PD18_PRODUCT_DEPTH_TRAIN` — `docs/codex/batch-trains/PD01_PD18_PRODUCT_DEPTH_TRAIN.md` (partial_implementation; release proof)
  - `PX01_PX20_PRODUCT_EXPERIENCE_OS_TRAIN` — `docs/codex/batch-trains/PX01_PX20_PRODUCT_EXPERIENCE_OS_TRAIN.md` (partial_implementation; release proof)
  - `SI01_SI18_SIGNATURE_INTERFACE_IMPLEMENTATION_TRAIN` — `docs/codex/batch-trains/SI01_SI18_SIGNATURE_INTERFACE_IMPLEMENTATION_TRAIN.md` (partial_implementation; release proof)
  - `AOS01_AmbitionsOS_Canon_And_Runtime_Contract_Prompt` — `docs/codex/batches/AOS01_AmbitionsOS_Canon_And_Runtime_Contract_Prompt.md` (partial_implementation; release proof)
  - `AOS02_Life_Graph_Event_Log_Foundation_Prompt` — `docs/codex/batches/AOS02_Life_Graph_Event_Log_Foundation_Prompt.md` (partial_implementation; release proof)
  - `AOS03_Graph_Delta_Review_Projection_Store_Prompt` — `docs/codex/batches/AOS03_Graph_Delta_Review_Projection_Store_Prompt.md` (partial_implementation; release proof)
  - `AOS04_Control_Plane_Work_Classifier_Prompt` — `docs/codex/batches/AOS04_Control_Plane_Work_Classifier_Prompt.md` (partial_implementation; release proof)
  - `AOS05_Starting_Position_Kernel_Prompt` — `docs/codex/batches/AOS05_Starting_Position_Kernel_Prompt.md` (partial_implementation; release proof)
  - `AOS06_Goal_Path_Kernel_Goal_Compiler_Prompt` — `docs/codex/batches/AOS06_Goal_Path_Kernel_Goal_Compiler_Prompt.md` (partial_implementation; release proof)
  - `AOS07_Local_Goal_Packs_Requirement_Slots_Prompt` — `docs/codex/batches/AOS07_Local_Goal_Packs_Requirement_Slots_Prompt.md` (partial_implementation; release proof)
  - `AOS08_Alternate_Path_Kernel_Path_Portfolio_Prompt` — `docs/codex/batches/AOS08_Alternate_Path_Kernel_Path_Portfolio_Prompt.md` (partial_implementation; release proof)
  - `AOS09_Option_Value_North_Star_Prompt` — `docs/codex/batches/AOS09_Option_Value_North_Star_Prompt.md` (partial_implementation; release proof)
  - `AOS10_Commitment_Time_Kernel_Prompt` — `docs/codex/batches/AOS10_Commitment_Time_Kernel_Prompt.md` (partial_implementation; release proof)
  - `AOS11_Reality_Drift_Bounded_Reflow_Prompt` — `docs/codex/batches/AOS11_Reality_Drift_Bounded_Reflow_Prompt.md` (partial_implementation; release proof)
  - `AOS12_Proof_Trust_Closure_Receipts_Prompt` — `docs/codex/batches/AOS12_Proof_Trust_Closure_Receipts_Prompt.md` (partial_implementation; release proof)
  - `AOS13_Source_Truth_Claim_State_Machine_Prompt` — `docs/codex/batches/AOS13_Source_Truth_Claim_State_Machine_Prompt.md` (partial_implementation; release proof)
  - `AOS14_Recommendation_Start_Here_Kernel_Prompt` — `docs/codex/batches/AOS14_Recommendation_Start_Here_Kernel_Prompt.md` (partial_implementation; release proof)
  - `AOS15_Local_Language_Kernel_Planning_Prompt` — `docs/codex/batches/AOS15_Local_Language_Kernel_Planning_Prompt.md` (partial_implementation; release proof)
  - `AOS16_Performance_Energy_Kernel_Prompt` — `docs/codex/batches/AOS16_Performance_Energy_Kernel_Prompt.md` (partial_implementation; release proof)
  - `AOS17_Privacy_Safety_Kernel_Prompt` — `docs/codex/batches/AOS17_Privacy_Safety_Kernel_Prompt.md` (partial_implementation; release proof)
  - `AOS18_Evaluation_Golden_Scenarios_Prompt` — `docs/codex/batches/AOS18_Evaluation_Golden_Scenarios_Prompt.md` (partial_implementation; release proof)
  - `AOS19_Experience_Kernel_Celestial_Cognitive_Load_Prompt` — `docs/codex/batches/AOS19_Experience_Kernel_Celestial_Cognitive_Load_Prompt.md` (partial_implementation; release proof)
  - ... 432 more

### 5. Same surface touched by multiple active items: Today

- Conflict ID: `AMB28-same_surface_multiple_active_batches-34058953`
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
  - `GLOBAL_FUTURE_BATCH_GATE_MATRIX` — `docs/codex/GLOBAL_FUTURE_BATCH_GATE_MATRIX.md` (partial_implementation; release proof)
  - `PXOS_GATE_MATRIX` — `docs/codex/PXOS_GATE_MATRIX.md` (partial_implementation; release proof)
  - `PXOS_HANDOFF_PACKAGE` — `docs/codex/PXOS_HANDOFF_PACKAGE.md` (partial_implementation; release proof)
  - `REC02_Human_Operator_Release_Proof_Plan` — `docs/codex/REC02_Human_Operator_Release_Proof_Plan.md` (partial_implementation; release proof)
  - `REC05_Human_Review_Packet` — `docs/codex/REC05_Human_Review_Packet.md` (partial_implementation; release proof)
  - `AOS01_AOS30_AMBITIONSOS_LOCAL_INTELLIGENCE_TRAIN` — `docs/codex/batch-trains/AOS01_AOS30_AMBITIONSOS_LOCAL_INTELLIGENCE_TRAIN.md` (partial_implementation; release proof)
  - `PD01_PD18_PRODUCT_DEPTH_TRAIN` — `docs/codex/batch-trains/PD01_PD18_PRODUCT_DEPTH_TRAIN.md` (partial_implementation; release proof)
  - `PX01_PX20_PRODUCT_EXPERIENCE_OS_TRAIN` — `docs/codex/batch-trains/PX01_PX20_PRODUCT_EXPERIENCE_OS_TRAIN.md` (partial_implementation; release proof)
  - `SI01_SI18_SIGNATURE_INTERFACE_IMPLEMENTATION_TRAIN` — `docs/codex/batch-trains/SI01_SI18_SIGNATURE_INTERFACE_IMPLEMENTATION_TRAIN.md` (partial_implementation; release proof)
  - `AOS01_AmbitionsOS_Canon_And_Runtime_Contract_Prompt` — `docs/codex/batches/AOS01_AmbitionsOS_Canon_And_Runtime_Contract_Prompt.md` (partial_implementation; release proof)
  - `AOS02_Life_Graph_Event_Log_Foundation_Prompt` — `docs/codex/batches/AOS02_Life_Graph_Event_Log_Foundation_Prompt.md` (partial_implementation; release proof)
  - `AOS03_Graph_Delta_Review_Projection_Store_Prompt` — `docs/codex/batches/AOS03_Graph_Delta_Review_Projection_Store_Prompt.md` (partial_implementation; release proof)
  - `AOS04_Control_Plane_Work_Classifier_Prompt` — `docs/codex/batches/AOS04_Control_Plane_Work_Classifier_Prompt.md` (partial_implementation; release proof)
  - `AOS05_Starting_Position_Kernel_Prompt` — `docs/codex/batches/AOS05_Starting_Position_Kernel_Prompt.md` (partial_implementation; release proof)
  - `AOS06_Goal_Path_Kernel_Goal_Compiler_Prompt` — `docs/codex/batches/AOS06_Goal_Path_Kernel_Goal_Compiler_Prompt.md` (partial_implementation; release proof)
  - `AOS07_Local_Goal_Packs_Requirement_Slots_Prompt` — `docs/codex/batches/AOS07_Local_Goal_Packs_Requirement_Slots_Prompt.md` (partial_implementation; release proof)
  - ... 452 more

### 6. Same surface touched by multiple active items: You

- Conflict ID: `AMB28-same_surface_multiple_active_batches-13212827`
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
  - `GLOBAL_FUTURE_BATCH_GATE_MATRIX` — `docs/codex/GLOBAL_FUTURE_BATCH_GATE_MATRIX.md` (partial_implementation; release proof)
  - `PXOS_GATE_MATRIX` — `docs/codex/PXOS_GATE_MATRIX.md` (partial_implementation; release proof)
  - `PXOS_HANDOFF_PACKAGE` — `docs/codex/PXOS_HANDOFF_PACKAGE.md` (partial_implementation; release proof)
  - `REC02_Human_Operator_Release_Proof_Plan` — `docs/codex/REC02_Human_Operator_Release_Proof_Plan.md` (partial_implementation; release proof)
  - `REC05_Human_Review_Packet` — `docs/codex/REC05_Human_Review_Packet.md` (partial_implementation; release proof)
  - `AOS01_AOS30_AMBITIONSOS_LOCAL_INTELLIGENCE_TRAIN` — `docs/codex/batch-trains/AOS01_AOS30_AMBITIONSOS_LOCAL_INTELLIGENCE_TRAIN.md` (partial_implementation; release proof)
  - `PD01_PD18_PRODUCT_DEPTH_TRAIN` — `docs/codex/batch-trains/PD01_PD18_PRODUCT_DEPTH_TRAIN.md` (partial_implementation; release proof)
  - `PX01_PX20_PRODUCT_EXPERIENCE_OS_TRAIN` — `docs/codex/batch-trains/PX01_PX20_PRODUCT_EXPERIENCE_OS_TRAIN.md` (partial_implementation; release proof)
  - `SI01_SI18_SIGNATURE_INTERFACE_IMPLEMENTATION_TRAIN` — `docs/codex/batch-trains/SI01_SI18_SIGNATURE_INTERFACE_IMPLEMENTATION_TRAIN.md` (partial_implementation; release proof)
  - `AOS01_AmbitionsOS_Canon_And_Runtime_Contract_Prompt` — `docs/codex/batches/AOS01_AmbitionsOS_Canon_And_Runtime_Contract_Prompt.md` (partial_implementation; release proof)
  - `AOS02_Life_Graph_Event_Log_Foundation_Prompt` — `docs/codex/batches/AOS02_Life_Graph_Event_Log_Foundation_Prompt.md` (partial_implementation; release proof)
  - `AOS03_Graph_Delta_Review_Projection_Store_Prompt` — `docs/codex/batches/AOS03_Graph_Delta_Review_Projection_Store_Prompt.md` (partial_implementation; release proof)
  - ... 466 more


## Same source file targeted by multiple active batches

### 1. Same source file targeted by multiple active items: Native/Ambitions/App/AmbitionsRootView.swift

- Conflict ID: `AMB28-same_source_file_targeted_by_multiple_active_batches-50973887`
- Type: `same_source_file_targeted_by_multiple_active_batches`
- Severity: `yellow`
- Recommended action: `merge`
- Rationale: Multiple active ledger items reference the same source file; merge, sequence, or assign ownership before implementation.
- Linear issue ready: `True`
- Auto-resolved: `False`
- Involved:
  - `repo-audit-baseline` — `docs/codex/repo-audit-baseline.md` (partial_implementation; release proof)
  - `IR01_FAANG_FRONTEND_INTERFACE_RECOVERY_PROMPT` — `docs/codex/batches/IR01_FAANG_FRONTEND_INTERFACE_RECOVERY_PROMPT.md` (partial_implementation; release proof)
  - `AMB-REPO-AUTHORITY-00-SAFETY-SNAPSHOT` — `prompts/batches/AMB-REPO-AUTHORITY-00-SAFETY-SNAPSHOT.md` (partial_implementation; release proof)
  - `AMB-REPO-AUTHORITY-02-FRONTEND-VISUAL-ENCYCLOPEDIA` — `prompts/batches/AMB-REPO-AUTHORITY-02-FRONTEND-VISUAL-ENCYCLOPEDIA.md` (partial_implementation; release proof)
  - `AMB-REPO-AUTHORITY-06-ACTIVE-DRIFT-REPAIR` — `prompts/batches/AMB-REPO-AUTHORITY-06-ACTIVE-DRIFT-REPAIR.md` (partial_implementation; release proof)
  - `ALIGN-01-NAMING` — `prompts/batches/ALIGN-01-NAMING.md` (partial_implementation; release proof)
  - `CHROME-AUDIT-01` — `prompts/batches/CHROME-AUDIT-01.md` (partial_implementation; release proof)
  - `START-HERE-REALITY-RECOGNITION-01` — `prompts/batches/START-HERE-REALITY-RECOGNITION-01.md` (partial_implementation; release proof)
  - `TOP-LEVEL-IA-PLAN-LEAK-REGRESSION-01` — `prompts/batches/TOP-LEVEL-IA-PLAN-LEAK-REGRESSION-01.md` (partial_implementation; release proof)
  - `AQOS_BATCH_IMPACT_CLASSIFIER` — `docs/codex/quality/AQOS_BATCH_IMPACT_CLASSIFIER.md` (unknown; release proof)
  - `FRONTEND_SHELL_BOTTOM_CHROME_OWNERSHIP_GATE` — `docs/codex/FRONTEND_SHELL_BOTTOM_CHROME_OWNERSHIP_GATE.md` (unknown; release proof)
  - `existing-code-champion-coverage` — `docs/codex/existing-code-champion-coverage.yml` (unknown; release proof)

### 2. Same source file targeted by multiple active items: Native/Ambitions/App/AppContainerFactory.swift

- Conflict ID: `AMB28-same_source_file_targeted_by_multiple_active_batches-97526860`
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

- Conflict ID: `AMB28-same_source_file_targeted_by_multiple_active_batches-50387371`
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

- Conflict ID: `AMB28-same_source_file_targeted_by_multiple_active_batches-7658313`
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

- Conflict ID: `AMB28-same_source_file_targeted_by_multiple_active_batches-78130534`
- Type: `same_source_file_targeted_by_multiple_active_batches`
- Severity: `yellow`
- Recommended action: `merge`
- Rationale: Multiple active ledger items reference the same source file; merge, sequence, or assign ownership before implementation.
- Linear issue ready: `True`
- Auto-resolved: `False`
- Involved:
  - `FVQ01_RENDERED_VISUAL_FRESHNESS_AND_FLAGSHIP_PROMPT` — `docs/codex/batches/FVQ01_RENDERED_VISUAL_FRESHNESS_AND_FLAGSHIP_PROMPT.md` (partial_implementation; release proof)
  - `FCP08_Ambition_Meridian_Shell_Prompt` — `docs/codex/batches/FCP08_Ambition_Meridian_Shell_Prompt.md` (unknown; release proof)
  - `AQOS_BATCH_IMPACT_CLASSIFIER` — `docs/codex/quality/AQOS_BATCH_IMPACT_CLASSIFIER.md` (unknown; release proof)
  - `existing-code-champion-coverage` — `docs/codex/existing-code-champion-coverage.yml` (unknown; release proof)

### 6. Same source file targeted by multiple active items: Native/Ambitions/App/AppNavigation.swift

- Conflict ID: `AMB28-same_source_file_targeted_by_multiple_active_batches-36452683`
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

- Conflict ID: `AMB28-same_source_file_targeted_by_multiple_active_batches-64094379`
- Type: `same_source_file_targeted_by_multiple_active_batches`
- Severity: `yellow`
- Recommended action: `merge`
- Rationale: Multiple active ledger items reference the same source file; merge, sequence, or assign ownership before implementation.
- Linear issue ready: `True`
- Auto-resolved: `False`
- Involved:
  - `FVQ01_RENDERED_VISUAL_FRESHNESS_AND_FLAGSHIP_PROMPT` — `docs/codex/batches/FVQ01_RENDERED_VISUAL_FRESHNESS_AND_FLAGSHIP_PROMPT.md` (partial_implementation; release proof)
  - `IR01_FAANG_FRONTEND_INTERFACE_RECOVERY_PROMPT` — `docs/codex/batches/IR01_FAANG_FRONTEND_INTERFACE_RECOVERY_PROMPT.md` (partial_implementation; release proof)
  - `FCP08_Ambition_Meridian_Shell_Prompt` — `docs/codex/batches/FCP08_Ambition_Meridian_Shell_Prompt.md` (unknown; release proof)
  - `existing-code-champion-coverage` — `docs/codex/existing-code-champion-coverage.yml` (unknown; release proof)

### 8. Same source file targeted by multiple active items: Native/Ambitions/App/AppShellView.swift

- Conflict ID: `AMB28-same_source_file_targeted_by_multiple_active_batches-51750267`
- Type: `same_source_file_targeted_by_multiple_active_batches`
- Severity: `yellow`
- Recommended action: `merge`
- Rationale: Multiple active ledger items reference the same source file; merge, sequence, or assign ownership before implementation.
- Linear issue ready: `True`
- Auto-resolved: `False`
- Involved:
  - `FLAGSHIP_COMPLETION_FILE_BOUNDARY_MAP` — `docs/codex/FLAGSHIP_COMPLETION_FILE_BOUNDARY_MAP.md` (partial_implementation; release proof)
  - `existing-code-champion-coverage` — `docs/codex/existing-code-champion-coverage.yml` (unknown; release proof)

### 9. Same source file targeted by multiple active items: Native/Ambitions/App/AppTab.swift

- Conflict ID: `AMB28-same_source_file_targeted_by_multiple_active_batches-3188896`
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
  - `CHROME-AUDIT-01` — `prompts/batches/CHROME-AUDIT-01.md` (partial_implementation; release proof)
  - `START-HERE-REALITY-RECOGNITION-01` — `prompts/batches/START-HERE-REALITY-RECOGNITION-01.md` (partial_implementation; release proof)
  - `TOP-LEVEL-IA-PLAN-LEAK-REGRESSION-01` — `prompts/batches/TOP-LEVEL-IA-PLAN-LEAK-REGRESSION-01.md` (partial_implementation; release proof)
  - `AMB-POST23-01-TRUTH-AUDIT` — `docs/codex/reports/AMB-POST23-01-TRUTH-AUDIT.md` (partial_implementation; release proof)
  - `existing-code-champion-coverage` — `docs/codex/existing-code-champion-coverage.yml` (unknown; release proof)

### 10. Same source file targeted by multiple active items: Native/Ambitions/AppIntents/OpenAmbitionsDestinationIntent.swift

- Conflict ID: `AMB28-same_source_file_targeted_by_multiple_active_batches-38780476`
- Type: `same_source_file_targeted_by_multiple_active_batches`
- Severity: `yellow`
- Recommended action: `merge`
- Rationale: Multiple active ledger items reference the same source file; merge, sequence, or assign ownership before implementation.
- Linear issue ready: `True`
- Auto-resolved: `False`
- Involved:
  - `PFC18_App_Intents_Shortcuts_Implementation_And_Tests_Prompt` — `docs/codex/batches/PFC18_App_Intents_Shortcuts_Implementation_And_Tests_Prompt.md` (partial_implementation; release proof)
  - `existing-code-champion-coverage` — `docs/codex/existing-code-champion-coverage.yml` (unknown; release proof)

### 11. Same source file targeted by multiple active items: Native/Ambitions/Domain/ActionClosureReceiptModels.swift

- Conflict ID: `AMB28-same_source_file_targeted_by_multiple_active_batches-8524854`
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

### 12. Same source file targeted by multiple active items: Native/Ambitions/Domain/AmbitionGraphModels.swift

- Conflict ID: `AMB28-same_source_file_targeted_by_multiple_active_batches-32022500`
- Type: `same_source_file_targeted_by_multiple_active_batches`
- Severity: `yellow`
- Recommended action: `merge`
- Rationale: Multiple active ledger items reference the same source file; merge, sequence, or assign ownership before implementation.
- Linear issue ready: `True`
- Auto-resolved: `False`
- Involved:
  - `MOAT-COMPLETE-AUTONOMOUS-01` — `prompts/batches/MOAT-COMPLETE-AUTONOMOUS-01.md` (partial_implementation; release proof)
  - `existing-code-champion-coverage` — `docs/codex/existing-code-champion-coverage.yml` (unknown; release proof)

### 13. Same source file targeted by multiple active items: Native/Ambitions/Domain/AmbitionsCommandModels.swift

- Conflict ID: `AMB28-same_source_file_targeted_by_multiple_active_batches-2406460`
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

### 14. Same source file targeted by multiple active items: Native/Ambitions/Domain/AmbitionsOSAdaptationModels.swift

- Conflict ID: `AMB28-same_source_file_targeted_by_multiple_active_batches-13979485`
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

### 15. Same source file targeted by multiple active items: Native/Ambitions/Domain/AmbitionsOSAlternatePathModels.swift

- Conflict ID: `AMB28-same_source_file_targeted_by_multiple_active_batches-88549404`
- Type: `same_source_file_targeted_by_multiple_active_batches`
- Severity: `yellow`
- Recommended action: `merge`
- Rationale: Multiple active ledger items reference the same source file; merge, sequence, or assign ownership before implementation.
- Linear issue ready: `True`
- Auto-resolved: `False`
- Involved:
  - `AMBITIONSOS_AOS_TRACEABILITY_MATRIX` — `docs/codex/AMBITIONSOS_AOS_TRACEABILITY_MATRIX.md` (partial_implementation; release proof)
  - `existing-code-champion-coverage` — `docs/codex/existing-code-champion-coverage.yml` (unknown; release proof)

### 16. Same source file targeted by multiple active items: Native/Ambitions/Domain/AmbitionsOSCommitmentTimeModels.swift

- Conflict ID: `AMB28-same_source_file_targeted_by_multiple_active_batches-74397341`
- Type: `same_source_file_targeted_by_multiple_active_batches`
- Severity: `yellow`
- Recommended action: `merge`
- Rationale: Multiple active ledger items reference the same source file; merge, sequence, or assign ownership before implementation.
- Linear issue ready: `True`
- Auto-resolved: `False`
- Involved:
  - `AMBITIONSOS_AOS_TRACEABILITY_MATRIX` — `docs/codex/AMBITIONSOS_AOS_TRACEABILITY_MATRIX.md` (partial_implementation; release proof)
  - `existing-code-champion-coverage` — `docs/codex/existing-code-champion-coverage.yml` (unknown; release proof)

### 17. Same source file targeted by multiple active items: Native/Ambitions/Domain/AmbitionsOSControlPlaneModels.swift

- Conflict ID: `AMB28-same_source_file_targeted_by_multiple_active_batches-24808952`
- Type: `same_source_file_targeted_by_multiple_active_batches`
- Severity: `yellow`
- Recommended action: `merge`
- Rationale: Multiple active ledger items reference the same source file; merge, sequence, or assign ownership before implementation.
- Linear issue ready: `True`
- Auto-resolved: `False`
- Involved:
  - `AMBITIONSOS_AOS_TRACEABILITY_MATRIX` — `docs/codex/AMBITIONSOS_AOS_TRACEABILITY_MATRIX.md` (partial_implementation; release proof)
  - `existing-code-champion-coverage` — `docs/codex/existing-code-champion-coverage.yml` (unknown; release proof)

### 18. Same source file targeted by multiple active items: Native/Ambitions/Domain/AmbitionsOSEvaluationModels.swift

- Conflict ID: `AMB28-same_source_file_targeted_by_multiple_active_batches-85822832`
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

### 19. Same source file targeted by multiple active items: Native/Ambitions/Domain/AmbitionsOSExperienceModels.swift

- Conflict ID: `AMB28-same_source_file_targeted_by_multiple_active_batches-63536412`
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

### 20. Same source file targeted by multiple active items: Native/Ambitions/Domain/AmbitionsOSGoalPathCompilerModels.swift

- Conflict ID: `AMB28-same_source_file_targeted_by_multiple_active_batches-81382480`
- Type: `same_source_file_targeted_by_multiple_active_batches`
- Severity: `yellow`
- Recommended action: `merge`
- Rationale: Multiple active ledger items reference the same source file; merge, sequence, or assign ownership before implementation.
- Linear issue ready: `True`
- Auto-resolved: `False`
- Involved:
  - `AMBITIONSOS_AOS_TRACEABILITY_MATRIX` — `docs/codex/AMBITIONSOS_AOS_TRACEABILITY_MATRIX.md` (partial_implementation; release proof)
  - `existing-code-champion-coverage` — `docs/codex/existing-code-champion-coverage.yml` (unknown; release proof)

### 21. Same source file targeted by multiple active items: Native/Ambitions/Domain/AmbitionsOSInteroperabilityModels.swift

- Conflict ID: `AMB28-same_source_file_targeted_by_multiple_active_batches-34545254`
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

### 22. Same source file targeted by multiple active items: Native/Ambitions/Domain/AmbitionsOSLivingDreamCapacityBridgeModels.swift

- Conflict ID: `AMB28-same_source_file_targeted_by_multiple_active_batches-29168866`
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

### 23. Same source file targeted by multiple active items: Native/Ambitions/Domain/AmbitionsOSLivingDreamPathPortfolioModels.swift

- Conflict ID: `AMB28-same_source_file_targeted_by_multiple_active_batches-43487967`
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

### 24. Same source file targeted by multiple active items: Native/Ambitions/Domain/AmbitionsOSLivingDreamSourceClaimGraphModels.swift

- Conflict ID: `AMB28-same_source_file_targeted_by_multiple_active_batches-34685618`
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

### 25. Same source file targeted by multiple active items: Native/Ambitions/Domain/AmbitionsOSLivingDreamStartingPositionPrivacyIntakeModels.swift

- Conflict ID: `AMB28-same_source_file_targeted_by_multiple_active_batches-53599448`
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

### 26. Same source file targeted by multiple active items: Native/Ambitions/Domain/AmbitionsOSLivingDreamTodayBridgeModels.swift

- Conflict ID: `AMB28-same_source_file_targeted_by_multiple_active_batches-80165262`
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

### 27. Same source file targeted by multiple active items: Native/Ambitions/Domain/AmbitionsOSLocalGoalPackModels.swift

- Conflict ID: `AMB28-same_source_file_targeted_by_multiple_active_batches-72734645`
- Type: `same_source_file_targeted_by_multiple_active_batches`
- Severity: `yellow`
- Recommended action: `merge`
- Rationale: Multiple active ledger items reference the same source file; merge, sequence, or assign ownership before implementation.
- Linear issue ready: `True`
- Auto-resolved: `False`
- Involved:
  - `AMBITIONSOS_AOS_TRACEABILITY_MATRIX` — `docs/codex/AMBITIONSOS_AOS_TRACEABILITY_MATRIX.md` (partial_implementation; release proof)
  - `existing-code-champion-coverage` — `docs/codex/existing-code-champion-coverage.yml` (unknown; release proof)

### 28. Same source file targeted by multiple active items: Native/Ambitions/Domain/AmbitionsOSLocalLanguageModels.swift

- Conflict ID: `AMB28-same_source_file_targeted_by_multiple_active_batches-61990415`
- Type: `same_source_file_targeted_by_multiple_active_batches`
- Severity: `yellow`
- Recommended action: `merge`
- Rationale: Multiple active ledger items reference the same source file; merge, sequence, or assign ownership before implementation.
- Linear issue ready: `True`
- Auto-resolved: `False`
- Involved:
  - `AMBITIONSOS_AOS_TRACEABILITY_MATRIX` — `docs/codex/AMBITIONSOS_AOS_TRACEABILITY_MATRIX.md` (partial_implementation; release proof)
  - `existing-code-champion-coverage` — `docs/codex/existing-code-champion-coverage.yml` (unknown; release proof)

### 29. Same source file targeted by multiple active items: Native/Ambitions/Domain/AmbitionsOSLongevityModels.swift

- Conflict ID: `AMB28-same_source_file_targeted_by_multiple_active_batches-45012385`
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

### 30. Same source file targeted by multiple active items: Native/Ambitions/Domain/AmbitionsOSOptionValueModels.swift

- Conflict ID: `AMB28-same_source_file_targeted_by_multiple_active_batches-97933704`
- Type: `same_source_file_targeted_by_multiple_active_batches`
- Severity: `yellow`
- Recommended action: `merge`
- Rationale: Multiple active ledger items reference the same source file; merge, sequence, or assign ownership before implementation.
- Linear issue ready: `True`
- Auto-resolved: `False`
- Involved:
  - `AMBITIONSOS_AOS_TRACEABILITY_MATRIX` — `docs/codex/AMBITIONSOS_AOS_TRACEABILITY_MATRIX.md` (partial_implementation; release proof)
  - `existing-code-champion-coverage` — `docs/codex/existing-code-champion-coverage.yml` (unknown; release proof)

### 31. Same source file targeted by multiple active items: Native/Ambitions/Domain/AmbitionsOSPerformanceEnergyModels.swift

- Conflict ID: `AMB28-same_source_file_targeted_by_multiple_active_batches-45209227`
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

### 32. Same source file targeted by multiple active items: Native/Ambitions/Domain/AmbitionsOSPrivacySafetyModels.swift

- Conflict ID: `AMB28-same_source_file_targeted_by_multiple_active_batches-99698953`
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

### 33. Same source file targeted by multiple active items: Native/Ambitions/Domain/AmbitionsOSProofTrustModels.swift

- Conflict ID: `AMB28-same_source_file_targeted_by_multiple_active_batches-31321020`
- Type: `same_source_file_targeted_by_multiple_active_batches`
- Severity: `yellow`
- Recommended action: `merge`
- Rationale: Multiple active ledger items reference the same source file; merge, sequence, or assign ownership before implementation.
- Linear issue ready: `True`
- Auto-resolved: `False`
- Involved:
  - `AMBITIONSOS_AOS_TRACEABILITY_MATRIX` — `docs/codex/AMBITIONSOS_AOS_TRACEABILITY_MATRIX.md` (partial_implementation; release proof)
  - `existing-code-champion-coverage` — `docs/codex/existing-code-champion-coverage.yml` (unknown; release proof)

### 34. Same source file targeted by multiple active items: Native/Ambitions/Domain/AmbitionsOSRealityDriftModels.swift

- Conflict ID: `AMB28-same_source_file_targeted_by_multiple_active_batches-71066550`
- Type: `same_source_file_targeted_by_multiple_active_batches`
- Severity: `yellow`
- Recommended action: `merge`
- Rationale: Multiple active ledger items reference the same source file; merge, sequence, or assign ownership before implementation.
- Linear issue ready: `True`
- Auto-resolved: `False`
- Involved:
  - `AMBITIONSOS_AOS_TRACEABILITY_MATRIX` — `docs/codex/AMBITIONSOS_AOS_TRACEABILITY_MATRIX.md` (partial_implementation; release proof)
  - `existing-code-champion-coverage` — `docs/codex/existing-code-champion-coverage.yml` (unknown; release proof)

### 35. Same source file targeted by multiple active items: Native/Ambitions/Domain/AmbitionsOSRecommendationStartHereModels.swift

- Conflict ID: `AMB28-same_source_file_targeted_by_multiple_active_batches-72395313`
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

### 36. Same source file targeted by multiple active items: Native/Ambitions/Domain/AmbitionsOSSourceTruthModels.swift

- Conflict ID: `AMB28-same_source_file_targeted_by_multiple_active_batches-1231612`
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

### 37. Same source file targeted by multiple active items: Native/Ambitions/Domain/AmbitionsOSStartingPositionModels.swift

- Conflict ID: `AMB28-same_source_file_targeted_by_multiple_active_batches-74535484`
- Type: `same_source_file_targeted_by_multiple_active_batches`
- Severity: `yellow`
- Recommended action: `merge`
- Rationale: Multiple active ledger items reference the same source file; merge, sequence, or assign ownership before implementation.
- Linear issue ready: `True`
- Auto-resolved: `False`
- Involved:
  - `AMBITIONSOS_AOS_TRACEABILITY_MATRIX` — `docs/codex/AMBITIONSOS_AOS_TRACEABILITY_MATRIX.md` (partial_implementation; release proof)
  - `existing-code-champion-coverage` — `docs/codex/existing-code-champion-coverage.yml` (unknown; release proof)

### 38. Same source file targeted by multiple active items: Native/Ambitions/Domain/CaptureModels.swift

- Conflict ID: `AMB28-same_source_file_targeted_by_multiple_active_batches-15996512`
- Type: `same_source_file_targeted_by_multiple_active_batches`
- Severity: `yellow`
- Recommended action: `merge`
- Rationale: Multiple active ledger items reference the same source file; merge, sequence, or assign ownership before implementation.
- Linear issue ready: `True`
- Auto-resolved: `False`
- Involved:
  - `PK20` — `prompts/batches/PK20.md` (partial_implementation; release proof)
  - `MOAT-COMPLETE-AUTONOMOUS-01` — `prompts/batches/MOAT-COMPLETE-AUTONOMOUS-01.md` (partial_implementation; release proof)
  - `existing-code-champion-coverage` — `docs/codex/existing-code-champion-coverage.yml` (unknown; release proof)

### 39. Same source file targeted by multiple active items: Native/Ambitions/Domain/EventLedgerModels.swift

- Conflict ID: `AMB28-same_source_file_targeted_by_multiple_active_batches-55737458`
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

### 40. Same source file targeted by multiple active items: Native/Ambitions/Domain/GoalEngine/GoalEngineContracts.swift

- Conflict ID: `AMB28-same_source_file_targeted_by_multiple_active_batches-42702652`
- Type: `same_source_file_targeted_by_multiple_active_batches`
- Severity: `yellow`
- Recommended action: `merge`
- Rationale: Multiple active ledger items reference the same source file; merge, sequence, or assign ownership before implementation.
- Linear issue ready: `True`
- Auto-resolved: `False`
- Involved:
  - `repo-audit-baseline` — `docs/codex/repo-audit-baseline.md` (partial_implementation; release proof)
  - `BATCH-23-generalized-goal-understanding-contracts` — `docs/codex/batches/BATCH-23-generalized-goal-understanding-contracts.md` (unknown; release proof)

### 41. Same source file targeted by multiple active items: Native/Ambitions/Domain/GoalEngine/GoalEngineIntake.swift

- Conflict ID: `AMB28-same_source_file_targeted_by_multiple_active_batches-64754668`
- Type: `same_source_file_targeted_by_multiple_active_batches`
- Severity: `yellow`
- Recommended action: `merge`
- Rationale: Multiple active ledger items reference the same source file; merge, sequence, or assign ownership before implementation.
- Linear issue ready: `True`
- Auto-resolved: `False`
- Involved:
  - `repo-audit-baseline` — `docs/codex/repo-audit-baseline.md` (partial_implementation; release proof)
  - `FLAGSHIP_COMPLETION_FILE_BOUNDARY_MAP` — `docs/codex/FLAGSHIP_COMPLETION_FILE_BOUNDARY_MAP.md` (partial_implementation; release proof)

### 42. Same source file targeted by multiple active items: Native/Ambitions/Domain/GoalEngine/GoalEngineOrchestrator.swift

- Conflict ID: `AMB28-same_source_file_targeted_by_multiple_active_batches-77446341`
- Type: `same_source_file_targeted_by_multiple_active_batches`
- Severity: `yellow`
- Recommended action: `merge`
- Rationale: Multiple active ledger items reference the same source file; merge, sequence, or assign ownership before implementation.
- Linear issue ready: `True`
- Auto-resolved: `False`
- Involved:
  - `repo-audit-baseline` — `docs/codex/repo-audit-baseline.md` (partial_implementation; release proof)
  - `BATCH-23-generalized-goal-understanding-contracts` — `docs/codex/batches/BATCH-23-generalized-goal-understanding-contracts.md` (unknown; release proof)

### 43. Same source file targeted by multiple active items: Native/Ambitions/Domain/GoalEngine/GoalPathCompilerModels.swift

- Conflict ID: `AMB28-same_source_file_targeted_by_multiple_active_batches-95496487`
- Type: `same_source_file_targeted_by_multiple_active_batches`
- Severity: `yellow`
- Recommended action: `merge`
- Rationale: Multiple active ledger items reference the same source file; merge, sequence, or assign ownership before implementation.
- Linear issue ready: `True`
- Auto-resolved: `False`
- Involved:
  - `BATCH-24-path-compiler-foundation` — `docs/codex/batches/BATCH-24-path-compiler-foundation.md` (unknown; release proof)
  - `BATCH-25-domain-pack-framework` — `docs/codex/batches/BATCH-25-domain-pack-framework.md` (unknown; release proof)

### 44. Same source file targeted by multiple active items: Native/Ambitions/Domain/GoalRealityModels.swift

- Conflict ID: `AMB28-same_source_file_targeted_by_multiple_active_batches-44395706`
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
  - `MOAT-GOAL-REALITY-CAPTURE-BRIDGE-04` — `prompts/batches/MOAT-GOAL-REALITY-CAPTURE-BRIDGE-04.md` (partial_implementation; release proof)
  - `MOAT-GOAL-REALITY-GOALS-BRIDGE-05` — `prompts/batches/MOAT-GOAL-REALITY-GOALS-BRIDGE-05.md` (partial_implementation; release proof)
  - `MOAT-GOAL-REALITY-LOCAL-PERSISTENCE-08` — `prompts/batches/MOAT-GOAL-REALITY-LOCAL-PERSISTENCE-08.md` (partial_implementation; release proof)
  - `MOAT-GOAL-REALITY-RECEIPT-CLOSURE-07` — `prompts/batches/MOAT-GOAL-REALITY-RECEIPT-CLOSURE-07.md` (partial_implementation; release proof)
  - `MOAT-GOAL-REALITY-SOURCE-PACKS-09` — `prompts/batches/MOAT-GOAL-REALITY-SOURCE-PACKS-09.md` (partial_implementation; release proof)
  - `MOAT-GOAL-REALITY-TODAY-BRIDGE-06` — `prompts/batches/MOAT-GOAL-REALITY-TODAY-BRIDGE-06.md` (partial_implementation; release proof)

### 45. Same source file targeted by multiple active items: Native/Ambitions/Domain/GoalRealityProofModels.swift

- Conflict ID: `AMB28-same_source_file_targeted_by_multiple_active_batches-58020965`
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

### 46. Same source file targeted by multiple active items: Native/Ambitions/Domain/GoalRealityReceiptModels.swift

- Conflict ID: `AMB28-same_source_file_targeted_by_multiple_active_batches-69806409`
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

### 47. Same source file targeted by multiple active items: Native/Ambitions/Domain/GoalRealityRiskModels.swift

- Conflict ID: `AMB28-same_source_file_targeted_by_multiple_active_batches-87574059`
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

### 48. Same source file targeted by multiple active items: Native/Ambitions/Domain/MoonshotProofPathModels.swift

- Conflict ID: `AMB28-same_source_file_targeted_by_multiple_active_batches-86997326`
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

### 49. Same source file targeted by multiple active items: Native/Ambitions/Domain/Planning/DeterministicGoalPlanner.swift

- Conflict ID: `AMB28-same_source_file_targeted_by_multiple_active_batches-51876941`
- Type: `same_source_file_targeted_by_multiple_active_batches`
- Severity: `yellow`
- Recommended action: `merge`
- Rationale: Multiple active ledger items reference the same source file; merge, sequence, or assign ownership before implementation.
- Linear issue ready: `True`
- Auto-resolved: `False`
- Involved:
  - `FLAGSHIP_COMPLETION_FILE_BOUNDARY_MAP` — `docs/codex/FLAGSHIP_COMPLETION_FILE_BOUNDARY_MAP.md` (partial_implementation; release proof)
  - `LDI15` — `prompts/batches/LDI15.md` (partial_implementation; release proof)

### 50. Same source file targeted by multiple active items: Native/Ambitions/Domain/Planning/PlanningDomainModels.swift

- Conflict ID: `AMB28-same_source_file_targeted_by_multiple_active_batches-7078968`
- Type: `same_source_file_targeted_by_multiple_active_batches`
- Severity: `yellow`
- Recommended action: `merge`
- Rationale: Multiple active ledger items reference the same source file; merge, sequence, or assign ownership before implementation.
- Linear issue ready: `True`
- Auto-resolved: `False`
- Involved:
  - `PK21` — `prompts/batches/PK21.md` (partial_implementation; release proof)
  - `LDI15` — `prompts/batches/LDI15.md` (partial_implementation; release proof)

### 51. Same source file targeted by multiple active items: Native/Ambitions/Domain/RecommendationExplanationModels.swift

- Conflict ID: `AMB28-same_source_file_targeted_by_multiple_active_batches-97343169`
- Type: `same_source_file_targeted_by_multiple_active_batches`
- Severity: `yellow`
- Recommended action: `merge`
- Rationale: Multiple active ledger items reference the same source file; merge, sequence, or assign ownership before implementation.
- Linear issue ready: `True`
- Auto-resolved: `False`
- Involved:
  - `PK33` — `prompts/batches/PK33.md` (partial_implementation; release proof)
  - `MOAT-GOAL-REALITY-RECEIPT-CLOSURE-07` — `prompts/batches/MOAT-GOAL-REALITY-RECEIPT-CLOSURE-07.md` (partial_implementation; release proof)

### 52. Same source file targeted by multiple active items: Native/Ambitions/Domain/SourceAtlasPackModels.swift

- Conflict ID: `AMB28-same_source_file_targeted_by_multiple_active_batches-64219411`
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

### 53. Same source file targeted by multiple active items: Native/Ambitions/ExternalSnapshots/ExternalCreationContracts.swift

- Conflict ID: `AMB28-same_source_file_targeted_by_multiple_active_batches-42908187`
- Type: `same_source_file_targeted_by_multiple_active_batches`
- Severity: `yellow`
- Recommended action: `merge`
- Rationale: Multiple active ledger items reference the same source file; merge, sequence, or assign ownership before implementation.
- Linear issue ready: `True`
- Auto-resolved: `False`
- Involved:
  - `PFC18_App_Intents_Shortcuts_Implementation_And_Tests_Prompt` — `docs/codex/batches/PFC18_App_Intents_Shortcuts_Implementation_And_Tests_Prompt.md` (partial_implementation; release proof)
  - `PFC12_App_Groups_Shared_Storage_Boundary_Prompt` — `docs/codex/batches/PFC12_App_Groups_Shared_Storage_Boundary_Prompt.md` (unknown; release proof)

### 54. Same source file targeted by multiple active items: Native/Ambitions/ExternalSnapshots/ExternalSurfaceContractModels.swift

- Conflict ID: `AMB28-same_source_file_targeted_by_multiple_active_batches-20437527`
- Type: `same_source_file_targeted_by_multiple_active_batches`
- Severity: `yellow`
- Recommended action: `merge`
- Rationale: Multiple active ledger items reference the same source file; merge, sequence, or assign ownership before implementation.
- Linear issue ready: `True`
- Auto-resolved: `False`
- Involved:
  - `PFC12_App_Groups_Shared_Storage_Boundary_Prompt` — `docs/codex/batches/PFC12_App_Groups_Shared_Storage_Boundary_Prompt.md` (unknown; release proof)
  - `PFC13_WidgetKit_Strategy_And_Object_Map_Prompt` — `docs/codex/batches/PFC13_WidgetKit_Strategy_And_Object_Map_Prompt.md` (unknown; release proof)

### 55. Same source file targeted by multiple active items: Native/Ambitions/ExternalSnapshots/ExternalWidgetProjection.swift

- Conflict ID: `AMB28-same_source_file_targeted_by_multiple_active_batches-19861959`
- Type: `same_source_file_targeted_by_multiple_active_batches`
- Severity: `yellow`
- Recommended action: `merge`
- Rationale: Multiple active ledger items reference the same source file; merge, sequence, or assign ownership before implementation.
- Linear issue ready: `True`
- Auto-resolved: `False`
- Involved:
  - `PFC14_WidgetKit_Implementation_And_Tests_Prompt` — `docs/codex/batches/PFC14_WidgetKit_Implementation_And_Tests_Prompt.md` (partial_implementation; release proof)
  - `PFC13_WidgetKit_Strategy_And_Object_Map_Prompt` — `docs/codex/batches/PFC13_WidgetKit_Strategy_And_Object_Map_Prompt.md` (unknown; release proof)

### 56. Same source file targeted by multiple active items: Native/Ambitions/ExternalSnapshots/NextStepActivityAttributes.swift

- Conflict ID: `AMB28-same_source_file_targeted_by_multiple_active_batches-85777428`
- Type: `same_source_file_targeted_by_multiple_active_batches`
- Severity: `yellow`
- Recommended action: `merge`
- Rationale: Multiple active ledger items reference the same source file; merge, sequence, or assign ownership before implementation.
- Linear issue ready: `True`
- Auto-resolved: `False`
- Involved:
  - `PFC16_Live_Activities_Implementation_And_Tests_Prompt` — `docs/codex/batches/PFC16_Live_Activities_Implementation_And_Tests_Prompt.md` (partial_implementation; release proof)
  - `PK23` — `prompts/batches/PK23.md` (partial_implementation; release proof)

### 57. Same source file targeted by multiple active items: Native/Ambitions/Features/Capture/CaptureAtmosphereComposer.swift

- Conflict ID: `AMB28-same_source_file_targeted_by_multiple_active_batches-84680863`
- Type: `same_source_file_targeted_by_multiple_active_batches`
- Severity: `yellow`
- Recommended action: `merge`
- Rationale: Multiple active ledger items reference the same source file; merge, sequence, or assign ownership before implementation.
- Linear issue ready: `True`
- Auto-resolved: `False`
- Involved:
  - `FLAGSHIP_COMPLETION_FILE_BOUNDARY_MAP` — `docs/codex/FLAGSHIP_COMPLETION_FILE_BOUNDARY_MAP.md` (partial_implementation; release proof)
  - `AMB-POST23-01-TRUTH-AUDIT` — `docs/codex/reports/AMB-POST23-01-TRUTH-AUDIT.md` (partial_implementation; release proof)

### 58. Same source file targeted by multiple active items: Native/Ambitions/Features/Capture/CaptureScreen.swift

- Conflict ID: `AMB28-same_source_file_targeted_by_multiple_active_batches-76280643`
- Type: `same_source_file_targeted_by_multiple_active_batches`
- Severity: `yellow`
- Recommended action: `merge`
- Rationale: Multiple active ledger items reference the same source file; merge, sequence, or assign ownership before implementation.
- Linear issue ready: `True`
- Auto-resolved: `False`
- Involved:
  - `repo-audit-baseline` — `docs/codex/repo-audit-baseline.md` (partial_implementation; release proof)
  - `FLAGSHIP_COMPLETION_FILE_BOUNDARY_MAP` — `docs/codex/FLAGSHIP_COMPLETION_FILE_BOUNDARY_MAP.md` (partial_implementation; release proof)
  - `AMB-POST23-01-TRUTH-AUDIT` — `docs/codex/reports/AMB-POST23-01-TRUTH-AUDIT.md` (partial_implementation; release proof)

### 59. Same source file targeted by multiple active items: Native/Ambitions/Features/Goals/GoalComponents.swift

- Conflict ID: `AMB28-same_source_file_targeted_by_multiple_active_batches-48058863`
- Type: `same_source_file_targeted_by_multiple_active_batches`
- Severity: `yellow`
- Recommended action: `merge`
- Rationale: Multiple active ledger items reference the same source file; merge, sequence, or assign ownership before implementation.
- Linear issue ready: `True`
- Auto-resolved: `False`
- Involved:
  - `FLAGSHIP_COMPLETION_FILE_BOUNDARY_MAP` — `docs/codex/FLAGSHIP_COMPLETION_FILE_BOUNDARY_MAP.md` (partial_implementation; release proof)
  - `AMB-POST23-01-TRUTH-AUDIT` — `docs/codex/reports/AMB-POST23-01-TRUTH-AUDIT.md` (partial_implementation; release proof)

### 60. Same source file targeted by multiple active items: Native/Ambitions/Features/Goals/GoalDetailScreen.swift

- Conflict ID: `AMB28-same_source_file_targeted_by_multiple_active_batches-86144905`
- Type: `same_source_file_targeted_by_multiple_active_batches`
- Severity: `yellow`
- Recommended action: `merge`
- Rationale: Multiple active ledger items reference the same source file; merge, sequence, or assign ownership before implementation.
- Linear issue ready: `True`
- Auto-resolved: `False`
- Involved:
  - `repo-audit-baseline` — `docs/codex/repo-audit-baseline.md` (partial_implementation; release proof)
  - `FLAGSHIP_COMPLETION_FILE_BOUNDARY_MAP` — `docs/codex/FLAGSHIP_COMPLETION_FILE_BOUNDARY_MAP.md` (partial_implementation; release proof)
  - `PK19` — `prompts/batches/PK19.md` (partial_implementation; release proof)
  - `BATCH-32-explainability-and-source-audit-surfaces` — `docs/codex/batches/BATCH-32-explainability-and-source-audit-surfaces.md` (unknown; release proof)

### 61. Same source file targeted by multiple active items: Native/Ambitions/Features/Goals/GoalsFeatureModels.swift

- Conflict ID: `AMB28-same_source_file_targeted_by_multiple_active_batches-62500064`
- Type: `same_source_file_targeted_by_multiple_active_batches`
- Severity: `yellow`
- Recommended action: `merge`
- Rationale: Multiple active ledger items reference the same source file; merge, sequence, or assign ownership before implementation.
- Linear issue ready: `True`
- Auto-resolved: `False`
- Involved:
  - `FLAGSHIP_COMPLETION_FILE_BOUNDARY_MAP` — `docs/codex/FLAGSHIP_COMPLETION_FILE_BOUNDARY_MAP.md` (partial_implementation; release proof)
  - `PK19` — `prompts/batches/PK19.md` (partial_implementation; release proof)
  - `BATCH-32-explainability-and-source-audit-surfaces` — `docs/codex/batches/BATCH-32-explainability-and-source-audit-surfaces.md` (unknown; release proof)

### 62. Same source file targeted by multiple active items: Native/Ambitions/Features/Goals/GoalsFeatureService.swift

- Conflict ID: `AMB28-same_source_file_targeted_by_multiple_active_batches-21600714`
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
  - `MOAT-GOAL-REALITY-GOALS-BRIDGE-05` — `prompts/batches/MOAT-GOAL-REALITY-GOALS-BRIDGE-05.md` (partial_implementation; release proof)

### 63. Same source file targeted by multiple active items: Native/Ambitions/Features/Goals/GoalsScreen.swift

- Conflict ID: `AMB28-same_source_file_targeted_by_multiple_active_batches-86984218`
- Type: `same_source_file_targeted_by_multiple_active_batches`
- Severity: `yellow`
- Recommended action: `merge`
- Rationale: Multiple active ledger items reference the same source file; merge, sequence, or assign ownership before implementation.
- Linear issue ready: `True`
- Auto-resolved: `False`
- Involved:
  - `repo-audit-baseline` — `docs/codex/repo-audit-baseline.md` (partial_implementation; release proof)
  - `FLAGSHIP_COMPLETION_FILE_BOUNDARY_MAP` — `docs/codex/FLAGSHIP_COMPLETION_FILE_BOUNDARY_MAP.md` (partial_implementation; release proof)
  - `PK19` — `prompts/batches/PK19.md` (partial_implementation; release proof)
  - `AMB-POST23-01-TRUTH-AUDIT` — `docs/codex/reports/AMB-POST23-01-TRUTH-AUDIT.md` (partial_implementation; release proof)

### 64. Same source file targeted by multiple active items: Native/Ambitions/Features/Goals/GoalsViewModels.swift

- Conflict ID: `AMB28-same_source_file_targeted_by_multiple_active_batches-67379699`
- Type: `same_source_file_targeted_by_multiple_active_batches`
- Severity: `yellow`
- Recommended action: `merge`
- Rationale: Multiple active ledger items reference the same source file; merge, sequence, or assign ownership before implementation.
- Linear issue ready: `True`
- Auto-resolved: `False`
- Involved:
  - `repo-audit-baseline` — `docs/codex/repo-audit-baseline.md` (partial_implementation; release proof)
  - `PK19` — `prompts/batches/PK19.md` (partial_implementation; release proof)

### 65. Same source file targeted by multiple active items: Native/Ambitions/Features/Plan/PlanCalendarAwarenessSupport.swift

- Conflict ID: `AMB28-same_source_file_targeted_by_multiple_active_batches-84343528`
- Type: `same_source_file_targeted_by_multiple_active_batches`
- Severity: `yellow`
- Recommended action: `merge`
- Rationale: Multiple active ledger items reference the same source file; merge, sequence, or assign ownership before implementation.
- Linear issue ready: `True`
- Auto-resolved: `False`
- Involved:
  - `PFC20_Notifications_Calendar_Reminders_Implementation_Proof_Prompt` — `docs/codex/batches/PFC20_Notifications_Calendar_Reminders_Implementation_Proof_Prompt.md` (partial_implementation; release proof)
  - `PK24` — `prompts/batches/PK24.md` (partial_implementation; release proof)

### 66. Same source file targeted by multiple active items: Native/Ambitions/Features/Plan/PlanFeatureService.swift

- Conflict ID: `AMB28-same_source_file_targeted_by_multiple_active_batches-64993456`
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

### 67. Same source file targeted by multiple active items: Native/Ambitions/Features/Plan/PlanLifeShapeTimeCapacityMap.swift

- Conflict ID: `AMB28-same_source_file_targeted_by_multiple_active_batches-74980807`
- Type: `same_source_file_targeted_by_multiple_active_batches`
- Severity: `yellow`
- Recommended action: `merge`
- Rationale: Multiple active ledger items reference the same source file; merge, sequence, or assign ownership before implementation.
- Linear issue ready: `True`
- Auto-resolved: `False`
- Involved:
  - `FLAGSHIP_COMPLETION_FILE_BOUNDARY_MAP` — `docs/codex/FLAGSHIP_COMPLETION_FILE_BOUNDARY_MAP.md` (partial_implementation; release proof)
  - `PK21` — `prompts/batches/PK21.md` (partial_implementation; release proof)

### 68. Same source file targeted by multiple active items: Native/Ambitions/Features/Plan/PlanScreen.swift

- Conflict ID: `AMB28-same_source_file_targeted_by_multiple_active_batches-45470381`
- Type: `same_source_file_targeted_by_multiple_active_batches`
- Severity: `yellow`
- Recommended action: `merge`
- Rationale: Multiple active ledger items reference the same source file; merge, sequence, or assign ownership before implementation.
- Linear issue ready: `True`
- Auto-resolved: `False`
- Involved:
  - `FLAGSHIP_COMPLETION_FILE_BOUNDARY_MAP` — `docs/codex/FLAGSHIP_COMPLETION_FILE_BOUNDARY_MAP.md` (partial_implementation; release proof)
  - `PK21` — `prompts/batches/PK21.md` (partial_implementation; release proof)
  - `AMB-REPO-AUTHORITY-06-ACTIVE-DRIFT-REPAIR` — `prompts/batches/AMB-REPO-AUTHORITY-06-ACTIVE-DRIFT-REPAIR.md` (partial_implementation; release proof)
  - `ALIGN-01-NAMING` — `prompts/batches/ALIGN-01-NAMING.md` (partial_implementation; release proof)

### 69. Same source file targeted by multiple active items: Native/Ambitions/Features/Profile/ProfileScreen.swift

- Conflict ID: `AMB28-same_source_file_targeted_by_multiple_active_batches-30605542`
- Type: `same_source_file_targeted_by_multiple_active_batches`
- Severity: `yellow`
- Recommended action: `merge`
- Rationale: Multiple active ledger items reference the same source file; merge, sequence, or assign ownership before implementation.
- Linear issue ready: `True`
- Auto-resolved: `False`
- Involved:
  - `FLAGSHIP_COMPLETION_FILE_BOUNDARY_MAP` — `docs/codex/FLAGSHIP_COMPLETION_FILE_BOUNDARY_MAP.md` (partial_implementation; release proof)
  - `ALIGN-01-NAMING` — `prompts/batches/ALIGN-01-NAMING.md` (partial_implementation; release proof)
  - `FCP17_Schedule_Availability_Defaults_Center_Prompt` — `docs/codex/batches/FCP17_Schedule_Availability_Defaults_Center_Prompt.md` (unknown; release proof)

### 70. Same source file targeted by multiple active items: Native/Ambitions/Features/Time/TimeScreen.swift

- Conflict ID: `AMB28-same_source_file_targeted_by_multiple_active_batches-87992580`
- Type: `same_source_file_targeted_by_multiple_active_batches`
- Severity: `yellow`
- Recommended action: `merge`
- Rationale: Multiple active ledger items reference the same source file; merge, sequence, or assign ownership before implementation.
- Linear issue ready: `True`
- Auto-resolved: `False`
- Involved:
  - `ALIGN-01-NAMING` — `prompts/batches/ALIGN-01-NAMING.md` (partial_implementation; release proof)
  - `AMB-POST23-01-TRUTH-AUDIT` — `docs/codex/reports/AMB-POST23-01-TRUTH-AUDIT.md` (partial_implementation; release proof)

### 71. Same source file targeted by multiple active items: Native/Ambitions/Features/Today/DayRailProjection.swift

- Conflict ID: `AMB28-same_source_file_targeted_by_multiple_active_batches-52093959`
- Type: `same_source_file_targeted_by_multiple_active_batches`
- Severity: `yellow`
- Recommended action: `merge`
- Rationale: Multiple active ledger items reference the same source file; merge, sequence, or assign ownership before implementation.
- Linear issue ready: `True`
- Auto-resolved: `False`
- Involved:
  - `FLAGSHIP_COMPLETION_FILE_BOUNDARY_MAP` — `docs/codex/FLAGSHIP_COMPLETION_FILE_BOUNDARY_MAP.md` (partial_implementation; release proof)
  - `FCP05_Start_Here_Surface_Prompt` — `docs/codex/batches/FCP05_Start_Here_Surface_Prompt.md` (unknown; release proof)
  - `FCP07_Reality_Rail_Continuity_Prompt` — `docs/codex/batches/FCP07_Reality_Rail_Continuity_Prompt.md` (unknown; release proof)

### 72. Same source file targeted by multiple active items: Native/Ambitions/Features/Today/DayRailViewState.swift

- Conflict ID: `AMB28-same_source_file_targeted_by_multiple_active_batches-23326226`
- Type: `same_source_file_targeted_by_multiple_active_batches`
- Severity: `yellow`
- Recommended action: `merge`
- Rationale: Multiple active ledger items reference the same source file; merge, sequence, or assign ownership before implementation.
- Linear issue ready: `True`
- Auto-resolved: `False`
- Involved:
  - `FLAGSHIP_COMPLETION_FILE_BOUNDARY_MAP` — `docs/codex/FLAGSHIP_COMPLETION_FILE_BOUNDARY_MAP.md` (partial_implementation; release proof)
  - `MOONSHOT_PROOF_PATH_BACKEND_MASTER_PLAN` — `docs/codex/MOONSHOT_PROOF_PATH_BACKEND_MASTER_PLAN.md` (partial_implementation; release proof)
  - `MOAT-MOONSHOT-BACKEND-FULL-TRAIN-01` — `prompts/batches/MOAT-MOONSHOT-BACKEND-FULL-TRAIN-01.md` (partial_implementation; release proof)
  - `MOAT-MOONSHOT-PROOF-PATH-01` — `prompts/batches/MOAT-MOONSHOT-PROOF-PATH-01.md` (partial_implementation; release proof)
  - `MOAT-GOAL-REALITY-TODAY-BRIDGE-06` — `prompts/batches/MOAT-GOAL-REALITY-TODAY-BRIDGE-06.md` (partial_implementation; release proof)
  - `FCP05_Start_Here_Surface_Prompt` — `docs/codex/batches/FCP05_Start_Here_Surface_Prompt.md` (unknown; release proof)
  - `FCP07_Reality_Rail_Continuity_Prompt` — `docs/codex/batches/FCP07_Reality_Rail_Continuity_Prompt.md` (unknown; release proof)

### 73. Same source file targeted by multiple active items: Native/Ambitions/Features/Today/SomeFile.swift

- Conflict ID: `AMB28-same_source_file_targeted_by_multiple_active_batches-37243017`
- Type: `same_source_file_targeted_by_multiple_active_batches`
- Severity: `yellow`
- Recommended action: `merge`
- Rationale: Multiple active ledger items reference the same source file; merge, sequence, or assign ownership before implementation.
- Linear issue ready: `True`
- Auto-resolved: `False`
- Involved:
  - `CODEX_ACCESSIBILITY_PROOF_PROTOCOL` — `docs/codex/CODEX_ACCESSIBILITY_PROOF_PROTOCOL.md` (unknown; release proof)
  - `CODEX_VISUAL_QA_PROTOCOL` — `docs/codex/CODEX_VISUAL_QA_PROTOCOL.md` (unknown; release proof)

### 74. Same source file targeted by multiple active items: Native/Ambitions/Features/Today/TodayActionClosureSheet.swift

- Conflict ID: `AMB28-same_source_file_targeted_by_multiple_active_batches-96792833`
- Type: `same_source_file_targeted_by_multiple_active_batches`
- Severity: `yellow`
- Recommended action: `merge`
- Rationale: Multiple active ledger items reference the same source file; merge, sequence, or assign ownership before implementation.
- Linear issue ready: `True`
- Auto-resolved: `False`
- Involved:
  - `FLAGSHIP_COMPLETION_FILE_BOUNDARY_MAP` — `docs/codex/FLAGSHIP_COMPLETION_FILE_BOUNDARY_MAP.md` (partial_implementation; release proof)
  - `FCP13A_Action_Closure_Diamond_Prompt` — `docs/codex/batches/FCP13A_Action_Closure_Diamond_Prompt.md` (unknown; release proof)

### 75. Same source file targeted by multiple active items: Native/Ambitions/Features/Today/TodayActionClosureSheetState.swift

- Conflict ID: `AMB28-same_source_file_targeted_by_multiple_active_batches-93582028`
- Type: `same_source_file_targeted_by_multiple_active_batches`
- Severity: `yellow`
- Recommended action: `merge`
- Rationale: Multiple active ledger items reference the same source file; merge, sequence, or assign ownership before implementation.
- Linear issue ready: `True`
- Auto-resolved: `False`
- Involved:
  - `FLAGSHIP_COMPLETION_FILE_BOUNDARY_MAP` — `docs/codex/FLAGSHIP_COMPLETION_FILE_BOUNDARY_MAP.md` (partial_implementation; release proof)
  - `FCP13A_Action_Closure_Diamond_Prompt` — `docs/codex/batches/FCP13A_Action_Closure_Diamond_Prompt.md` (unknown; release proof)

### 76. Same source file targeted by multiple active items: Native/Ambitions/Features/Today/TodayDayRailPanels.swift

- Conflict ID: `AMB28-same_source_file_targeted_by_multiple_active_batches-38550372`
- Type: `same_source_file_targeted_by_multiple_active_batches`
- Severity: `yellow`
- Recommended action: `merge`
- Rationale: Multiple active ledger items reference the same source file; merge, sequence, or assign ownership before implementation.
- Linear issue ready: `True`
- Auto-resolved: `False`
- Involved:
  - `FLAGSHIP_COMPLETION_FILE_BOUNDARY_MAP` — `docs/codex/FLAGSHIP_COMPLETION_FILE_BOUNDARY_MAP.md` (partial_implementation; release proof)
  - `AMB-POST23-01-TRUTH-AUDIT` — `docs/codex/reports/AMB-POST23-01-TRUTH-AUDIT.md` (partial_implementation; release proof)
  - `FCP05_Start_Here_Surface_Prompt` — `docs/codex/batches/FCP05_Start_Here_Surface_Prompt.md` (unknown; release proof)
  - `FCP07_Reality_Rail_Continuity_Prompt` — `docs/codex/batches/FCP07_Reality_Rail_Continuity_Prompt.md` (unknown; release proof)

### 77. Same source file targeted by multiple active items: Native/Ambitions/Features/Today/TodayExecutionProjector.swift

- Conflict ID: `AMB28-same_source_file_targeted_by_multiple_active_batches-37886007`
- Type: `same_source_file_targeted_by_multiple_active_batches`
- Severity: `yellow`
- Recommended action: `merge`
- Rationale: Multiple active ledger items reference the same source file; merge, sequence, or assign ownership before implementation.
- Linear issue ready: `True`
- Auto-resolved: `False`
- Involved:
  - `FLAGSHIP_COMPLETION_FILE_BOUNDARY_MAP` — `docs/codex/FLAGSHIP_COMPLETION_FILE_BOUNDARY_MAP.md` (partial_implementation; release proof)
  - `PK17` — `prompts/batches/PK17.md` (partial_implementation; release proof)
  - `PK37` — `prompts/batches/PK37.md` (partial_implementation; release proof)
  - `MOONSHOT_PROOF_PATH_BACKEND_MASTER_PLAN` — `docs/codex/MOONSHOT_PROOF_PATH_BACKEND_MASTER_PLAN.md` (partial_implementation; release proof)
  - `MOAT-MOONSHOT-BACKEND-FULL-TRAIN-01` — `prompts/batches/MOAT-MOONSHOT-BACKEND-FULL-TRAIN-01.md` (partial_implementation; release proof)
  - `MOAT-MOONSHOT-PROOF-PATH-01` — `prompts/batches/MOAT-MOONSHOT-PROOF-PATH-01.md` (partial_implementation; release proof)
  - `MOAT-GOAL-REALITY-TODAY-BRIDGE-06` — `prompts/batches/MOAT-GOAL-REALITY-TODAY-BRIDGE-06.md` (partial_implementation; release proof)
  - `FCP05_Start_Here_Surface_Prompt` — `docs/codex/batches/FCP05_Start_Here_Surface_Prompt.md` (unknown; release proof)
  - `FCP07_Reality_Rail_Continuity_Prompt` — `docs/codex/batches/FCP07_Reality_Rail_Continuity_Prompt.md` (unknown; release proof)

### 78. Same source file targeted by multiple active items: Native/Ambitions/Features/Today/TodayExecutionViewState.swift

- Conflict ID: `AMB28-same_source_file_targeted_by_multiple_active_batches-9587393`
- Type: `same_source_file_targeted_by_multiple_active_batches`
- Severity: `yellow`
- Recommended action: `merge`
- Rationale: Multiple active ledger items reference the same source file; merge, sequence, or assign ownership before implementation.
- Linear issue ready: `True`
- Auto-resolved: `False`
- Involved:
  - `F03_5_Today_Execution_State_Contract_Hardening_Prompt` — `docs/codex/batches/F03_5_Today_Execution_State_Contract_Hardening_Prompt.md` (partial_implementation; release proof)
  - `PK17` — `prompts/batches/PK17.md` (partial_implementation; release proof)

### 79. Same source file targeted by multiple active items: Native/Ambitions/Features/Today/TodayFeatureService.swift

- Conflict ID: `AMB28-same_source_file_targeted_by_multiple_active_batches-23423927`
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

### 80. Same source file targeted by multiple active items: Native/Ambitions/Features/Today/TodayReadModelProjector.swift

- Conflict ID: `AMB28-same_source_file_targeted_by_multiple_active_batches-60239115`
- Type: `same_source_file_targeted_by_multiple_active_batches`
- Severity: `yellow`
- Recommended action: `merge`
- Rationale: Multiple active ledger items reference the same source file; merge, sequence, or assign ownership before implementation.
- Linear issue ready: `True`
- Auto-resolved: `False`
- Involved:
  - `BACKEND-FINAL-FORM-LOCAL-FIRST-HUMAN-01` — `prompts/batches/BACKEND-FINAL-FORM-LOCAL-FIRST-HUMAN-01.md` (partial_implementation; release proof)
  - `AMB-POST23-01-TRUTH-AUDIT` — `docs/codex/reports/AMB-POST23-01-TRUTH-AUDIT.md` (partial_implementation; release proof)

### 81. Same source file targeted by multiple active items: Native/Ambitions/Features/Today/TodayScreen.swift

- Conflict ID: `AMB28-same_source_file_targeted_by_multiple_active_batches-15005348`
- Type: `same_source_file_targeted_by_multiple_active_batches`
- Severity: `yellow`
- Recommended action: `merge`
- Rationale: Multiple active ledger items reference the same source file; merge, sequence, or assign ownership before implementation.
- Linear issue ready: `True`
- Auto-resolved: `False`
- Involved:
  - `repo-audit-baseline` — `docs/codex/repo-audit-baseline.md` (partial_implementation; release proof)
  - `FLAGSHIP_COMPLETION_FILE_BOUNDARY_MAP` — `docs/codex/FLAGSHIP_COMPLETION_FILE_BOUNDARY_MAP.md` (partial_implementation; release proof)
  - `PK17` — `prompts/batches/PK17.md` (partial_implementation; release proof)
  - `FLAGSHIP-OBJECT-SYSTEM-01` — `prompts/batches/FLAGSHIP-OBJECT-SYSTEM-01.md` (partial_implementation; release proof)
  - `AMB-POST23-01-TRUTH-AUDIT` — `docs/codex/reports/AMB-POST23-01-TRUTH-AUDIT.md` (partial_implementation; release proof)

### 82. Same source file targeted by multiple active items: Native/Ambitions/Features/Today/TodayViewModel.swift

- Conflict ID: `AMB28-same_source_file_targeted_by_multiple_active_batches-9076833`
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

### 83. Same source file targeted by multiple active items: Native/Ambitions/Features/You/YouScreen.swift

- Conflict ID: `AMB28-same_source_file_targeted_by_multiple_active_batches-9378605`
- Type: `same_source_file_targeted_by_multiple_active_batches`
- Severity: `yellow`
- Recommended action: `merge`
- Rationale: Multiple active ledger items reference the same source file; merge, sequence, or assign ownership before implementation.
- Linear issue ready: `True`
- Auto-resolved: `False`
- Involved:
  - `ALIGN-01-NAMING` — `prompts/batches/ALIGN-01-NAMING.md` (partial_implementation; release proof)
  - `AMB-POST23-01-TRUTH-AUDIT` — `docs/codex/reports/AMB-POST23-01-TRUTH-AUDIT.md` (partial_implementation; release proof)

### 84. Same source file targeted by multiple active items: Native/Ambitions/Integrations/CalendarReminders/EventKitIntegrationService.swift

- Conflict ID: `AMB28-same_source_file_targeted_by_multiple_active_batches-32999289`
- Type: `same_source_file_targeted_by_multiple_active_batches`
- Severity: `yellow`
- Recommended action: `merge`
- Rationale: Multiple active ledger items reference the same source file; merge, sequence, or assign ownership before implementation.
- Linear issue ready: `True`
- Auto-resolved: `False`
- Involved:
  - `PFC20_Notifications_Calendar_Reminders_Implementation_Proof_Prompt` — `docs/codex/batches/PFC20_Notifications_Calendar_Reminders_Implementation_Proof_Prompt.md` (partial_implementation; release proof)
  - `PK24` — `prompts/batches/PK24.md` (partial_implementation; release proof)

### 85. Same source file targeted by multiple active items: Native/Ambitions/Persistence/LegacyImportService.swift

- Conflict ID: `AMB28-same_source_file_targeted_by_multiple_active_batches-80144227`
- Type: `same_source_file_targeted_by_multiple_active_batches`
- Severity: `yellow`
- Recommended action: `merge`
- Rationale: Multiple active ledger items reference the same source file; merge, sequence, or assign ownership before implementation.
- Linear issue ready: `True`
- Auto-resolved: `False`
- Involved:
  - `PFC07_Migration_Ladder_And_Backward_Compatibility_Tests_Prompt` — `docs/codex/batches/PFC07_Migration_Ladder_And_Backward_Compatibility_Tests_Prompt.md` (partial_implementation; release proof)
  - `PFC08_Corruption_Recovery_Backup_Restore_Plan_Prompt` — `docs/codex/batches/PFC08_Corruption_Recovery_Backup_Restore_Plan_Prompt.md` (unknown; release proof)

### 86. Same source file targeted by multiple active items: Native/Ambitions/Persistence/PersistenceContracts.swift

- Conflict ID: `AMB28-same_source_file_targeted_by_multiple_active_batches-41370782`
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
  - `MOAT-GOAL-REALITY-CAPTURE-BRIDGE-04` — `prompts/batches/MOAT-GOAL-REALITY-CAPTURE-BRIDGE-04.md` (partial_implementation; release proof)
  - `MOAT-GOAL-REALITY-LOCAL-PERSISTENCE-08` — `prompts/batches/MOAT-GOAL-REALITY-LOCAL-PERSISTENCE-08.md` (partial_implementation; release proof)
  - `BATCH-31-correction-and-teaching-loop` — `docs/codex/batches/BATCH-31-correction-and-teaching-loop.md` (unknown; release proof)

### 87. Same source file targeted by multiple active items: Native/Ambitions/Persistence/PortableSnapshotContracts.swift

- Conflict ID: `AMB28-same_source_file_targeted_by_multiple_active_batches-62818670`
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

### 88. Same source file targeted by multiple active items: Native/Ambitions/Persistence/PortableSnapshotService.swift

- Conflict ID: `AMB28-same_source_file_targeted_by_multiple_active_batches-12077061`
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

### 89. Same source file targeted by multiple active items: Native/Ambitions/Persistence/StorageSchemaVersionLedger.swift

- Conflict ID: `AMB28-same_source_file_targeted_by_multiple_active_batches-2563443`
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

### 90. Same source file targeted by multiple active items: Native/Ambitions/Persistence/SwiftDataModels.swift

- Conflict ID: `AMB28-same_source_file_targeted_by_multiple_active_batches-1300009`
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

### 91. Same source file targeted by multiple active items: Native/Ambitions/Persistence/SwiftDataRepositories.swift

- Conflict ID: `AMB28-same_source_file_targeted_by_multiple_active_batches-14217122`
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

### 92. Same source file targeted by multiple active items: Native/Ambitions/Persistence/SwiftDataStore.swift

- Conflict ID: `AMB28-same_source_file_targeted_by_multiple_active_batches-62616890`
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

### 93. Same source file targeted by multiple active items: Native/Ambitions/Persistence/SyncCapabilityContracts.swift

- Conflict ID: `AMB28-same_source_file_targeted_by_multiple_active_batches-67521408`
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

### 94. Same source file targeted by multiple active items: Native/Ambitions/PreviewSupport/PreviewFixtures.swift

- Conflict ID: `AMB28-same_source_file_targeted_by_multiple_active_batches-2188280`
- Type: `same_source_file_targeted_by_multiple_active_batches`
- Severity: `yellow`
- Recommended action: `merge`
- Rationale: Multiple active ledger items reference the same source file; merge, sequence, or assign ownership before implementation.
- Linear issue ready: `True`
- Auto-resolved: `False`
- Involved:
  - `repo-audit-baseline` — `docs/codex/repo-audit-baseline.md` (partial_implementation; release proof)
  - `FLAGSHIP_COMPLETION_FILE_BOUNDARY_MAP` — `docs/codex/FLAGSHIP_COMPLETION_FILE_BOUNDARY_MAP.md` (partial_implementation; release proof)
  - `FLAGSHIP_COMPLETION_GATE_MATRIX` — `docs/codex/FLAGSHIP_COMPLETION_GATE_MATRIX.md` (partial_implementation; release proof)

### 95. Same source file targeted by multiple active items: Native/Ambitions/PreviewSupport/PreviewGoalsScenarios.swift

- Conflict ID: `AMB28-same_source_file_targeted_by_multiple_active_batches-96307869`
- Type: `same_source_file_targeted_by_multiple_active_batches`
- Severity: `yellow`
- Recommended action: `merge`
- Rationale: Multiple active ledger items reference the same source file; merge, sequence, or assign ownership before implementation.
- Linear issue ready: `True`
- Auto-resolved: `False`
- Involved:
  - `repo-audit-baseline` — `docs/codex/repo-audit-baseline.md` (partial_implementation; release proof)
  - `FLAGSHIP_COMPLETION_FILE_BOUNDARY_MAP` — `docs/codex/FLAGSHIP_COMPLETION_FILE_BOUNDARY_MAP.md` (partial_implementation; release proof)
  - `FLAGSHIP_COMPLETION_GATE_MATRIX` — `docs/codex/FLAGSHIP_COMPLETION_GATE_MATRIX.md` (partial_implementation; release proof)

### 96. Same source file targeted by multiple active items: Native/Ambitions/PreviewSupport/PreviewPlanScenarios.swift

- Conflict ID: `AMB28-same_source_file_targeted_by_multiple_active_batches-48673126`
- Type: `same_source_file_targeted_by_multiple_active_batches`
- Severity: `yellow`
- Recommended action: `merge`
- Rationale: Multiple active ledger items reference the same source file; merge, sequence, or assign ownership before implementation.
- Linear issue ready: `True`
- Auto-resolved: `False`
- Involved:
  - `FLAGSHIP_COMPLETION_FILE_BOUNDARY_MAP` — `docs/codex/FLAGSHIP_COMPLETION_FILE_BOUNDARY_MAP.md` (partial_implementation; release proof)
  - `FLAGSHIP_COMPLETION_GATE_MATRIX` — `docs/codex/FLAGSHIP_COMPLETION_GATE_MATRIX.md` (partial_implementation; release proof)

### 97. Same source file targeted by multiple active items: Native/Ambitions/PreviewSupport/PreviewTodayScenarios.swift

- Conflict ID: `AMB28-same_source_file_targeted_by_multiple_active_batches-77426110`
- Type: `same_source_file_targeted_by_multiple_active_batches`
- Severity: `yellow`
- Recommended action: `merge`
- Rationale: Multiple active ledger items reference the same source file; merge, sequence, or assign ownership before implementation.
- Linear issue ready: `True`
- Auto-resolved: `False`
- Involved:
  - `repo-audit-baseline` — `docs/codex/repo-audit-baseline.md` (partial_implementation; release proof)
  - `FLAGSHIP_COMPLETION_FILE_BOUNDARY_MAP` — `docs/codex/FLAGSHIP_COMPLETION_FILE_BOUNDARY_MAP.md` (partial_implementation; release proof)
  - `FLAGSHIP_COMPLETION_GATE_MATRIX` — `docs/codex/FLAGSHIP_COMPLETION_GATE_MATRIX.md` (partial_implementation; release proof)
  - `MOONSHOT_PROOF_PATH_BACKEND_MASTER_PLAN` — `docs/codex/MOONSHOT_PROOF_PATH_BACKEND_MASTER_PLAN.md` (partial_implementation; release proof)
  - `MOAT-MOONSHOT-BACKEND-FULL-TRAIN-01` — `prompts/batches/MOAT-MOONSHOT-BACKEND-FULL-TRAIN-01.md` (partial_implementation; release proof)
  - `MOAT-MOONSHOT-PROOF-PATH-01` — `prompts/batches/MOAT-MOONSHOT-PROOF-PATH-01.md` (partial_implementation; release proof)
  - `MOAT-GOAL-REALITY-TODAY-BRIDGE-06` — `prompts/batches/MOAT-GOAL-REALITY-TODAY-BRIDGE-06.md` (partial_implementation; release proof)
  - `FCP05_Start_Here_Surface_Prompt` — `docs/codex/batches/FCP05_Start_Here_Surface_Prompt.md` (unknown; release proof)
  - `FCP07_Reality_Rail_Continuity_Prompt` — `docs/codex/batches/FCP07_Reality_Rail_Continuity_Prompt.md` (unknown; release proof)

### 98. Same source file targeted by multiple active items: Native/Ambitions/Runtime/AmbitionsRuntimeContracts.swift

- Conflict ID: `AMB28-same_source_file_targeted_by_multiple_active_batches-85327957`
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

### 99. Same source file targeted by multiple active items: Native/Ambitions/Runtime/AmbitionsRuntimeFactory.swift

- Conflict ID: `AMB28-same_source_file_targeted_by_multiple_active_batches-97805658`
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

### 100. Same source file targeted by multiple active items: Native/Ambitions/Runtime/AmbitionsRuntimeGoalIntelligence.swift

- Conflict ID: `AMB28-same_source_file_targeted_by_multiple_active_batches-41488053`
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

### 101. Same source file targeted by multiple active items: Native/Ambitions/Runtime/GoalRealityCompiler.swift

- Conflict ID: `AMB28-same_source_file_targeted_by_multiple_active_batches-72778890`
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
  - `MOAT-GOAL-REALITY-CAPTURE-BRIDGE-04` — `prompts/batches/MOAT-GOAL-REALITY-CAPTURE-BRIDGE-04.md` (partial_implementation; release proof)
  - `MOAT-GOAL-REALITY-EVAL-HARNESS-10` — `prompts/batches/MOAT-GOAL-REALITY-EVAL-HARNESS-10.md` (partial_implementation; release proof)
  - `MOAT-GOAL-REALITY-RECEIPT-CLOSURE-07` — `prompts/batches/MOAT-GOAL-REALITY-RECEIPT-CLOSURE-07.md` (partial_implementation; release proof)
  - `MOAT-GOAL-REALITY-RUNTIME-SERVICE-03` — `prompts/batches/MOAT-GOAL-REALITY-RUNTIME-SERVICE-03.md` (partial_implementation; release proof)
  - `MOAT-GOAL-REALITY-SOURCE-PACKS-09` — `prompts/batches/MOAT-GOAL-REALITY-SOURCE-PACKS-09.md` (partial_implementation; release proof)

### 102. Same source file targeted by multiple active items: Native/Ambitions/Runtime/GoalRealityFixtureLab.swift

- Conflict ID: `AMB28-same_source_file_targeted_by_multiple_active_batches-31687043`
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

### 103. Same source file targeted by multiple active items: Native/Ambitions/Runtime/GoalRealityReceiptClosureService.swift

- Conflict ID: `AMB28-same_source_file_targeted_by_multiple_active_batches-49529893`
- Type: `same_source_file_targeted_by_multiple_active_batches`
- Severity: `yellow`
- Recommended action: `merge`
- Rationale: Multiple active ledger items reference the same source file; merge, sequence, or assign ownership before implementation.
- Linear issue ready: `True`
- Auto-resolved: `False`
- Involved:
  - `MOAT-GOAL-REALITY-LOCAL-PERSISTENCE-08` — `prompts/batches/MOAT-GOAL-REALITY-LOCAL-PERSISTENCE-08.md` (partial_implementation; release proof)
  - `MOAT-GOAL-REALITY-RECEIPT-CLOSURE-07` — `prompts/batches/MOAT-GOAL-REALITY-RECEIPT-CLOSURE-07.md` (partial_implementation; release proof)

### 104. Same source file targeted by multiple active items: Native/Ambitions/Runtime/GoalRealityRuntimeService.swift

- Conflict ID: `AMB28-same_source_file_targeted_by_multiple_active_batches-8484318`
- Type: `same_source_file_targeted_by_multiple_active_batches`
- Severity: `yellow`
- Recommended action: `merge`
- Rationale: Multiple active ledger items reference the same source file; merge, sequence, or assign ownership before implementation.
- Linear issue ready: `True`
- Auto-resolved: `False`
- Involved:
  - `GOAL_REALITY_COMPILER_BACKEND_MASTER_PLAN` — `docs/codex/GOAL_REALITY_COMPILER_BACKEND_MASTER_PLAN.md` (partial_implementation; release proof)
  - `MOAT-GOAL-REALITY-CAPTURE-BRIDGE-04` — `prompts/batches/MOAT-GOAL-REALITY-CAPTURE-BRIDGE-04.md` (partial_implementation; release proof)
  - `MOAT-GOAL-REALITY-GOALS-BRIDGE-05` — `prompts/batches/MOAT-GOAL-REALITY-GOALS-BRIDGE-05.md` (partial_implementation; release proof)
  - `MOAT-GOAL-REALITY-RUNTIME-SERVICE-03` — `prompts/batches/MOAT-GOAL-REALITY-RUNTIME-SERVICE-03.md` (partial_implementation; release proof)
  - `MOAT-GOAL-REALITY-TODAY-BRIDGE-06` — `prompts/batches/MOAT-GOAL-REALITY-TODAY-BRIDGE-06.md` (partial_implementation; release proof)

### 105. Same source file targeted by multiple active items: Native/Ambitions/Runtime/GoalRealitySourceBoundaryService.swift

- Conflict ID: `AMB28-same_source_file_targeted_by_multiple_active_batches-25124030`
- Type: `same_source_file_targeted_by_multiple_active_batches`
- Severity: `yellow`
- Recommended action: `merge`
- Rationale: Multiple active ledger items reference the same source file; merge, sequence, or assign ownership before implementation.
- Linear issue ready: `True`
- Auto-resolved: `False`
- Involved:
  - `MOAT-GOAL-REALITY-EVAL-HARNESS-10` — `prompts/batches/MOAT-GOAL-REALITY-EVAL-HARNESS-10.md` (partial_implementation; release proof)
  - `MOAT-GOAL-REALITY-SOURCE-PACKS-09` — `prompts/batches/MOAT-GOAL-REALITY-SOURCE-PACKS-09.md` (partial_implementation; release proof)

### 106. Same source file targeted by multiple active items: Native/Ambitions/Runtime/GoalRealityValidator.swift

- Conflict ID: `AMB28-same_source_file_targeted_by_multiple_active_batches-80494176`
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

### 107. Same source file targeted by multiple active items: Native/Ambitions/Runtime/MoonshotProofPathRuntime.swift

- Conflict ID: `AMB28-same_source_file_targeted_by_multiple_active_batches-40595983`
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

### 108. Same source file targeted by multiple active items: Native/Ambitions/Services/AmbitionsCommandExecutor.swift

- Conflict ID: `AMB28-same_source_file_targeted_by_multiple_active_batches-15052784`
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

### 109. Same source file targeted by multiple active items: Native/Ambitions/Services/CaptureService.swift

- Conflict ID: `AMB28-same_source_file_targeted_by_multiple_active_batches-8571553`
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

### 110. Same source file targeted by multiple active items: Native/Ambitions/Services/ExternalActionCommandService.swift

- Conflict ID: `AMB28-same_source_file_targeted_by_multiple_active_batches-86062281`
- Type: `same_source_file_targeted_by_multiple_active_batches`
- Severity: `yellow`
- Recommended action: `merge`
- Rationale: Multiple active ledger items reference the same source file; merge, sequence, or assign ownership before implementation.
- Linear issue ready: `True`
- Auto-resolved: `False`
- Involved:
  - `PFC18_App_Intents_Shortcuts_Implementation_And_Tests_Prompt` — `docs/codex/batches/PFC18_App_Intents_Shortcuts_Implementation_And_Tests_Prompt.md` (partial_implementation; release proof)
  - `PFC20_Notifications_Calendar_Reminders_Implementation_Proof_Prompt` — `docs/codex/batches/PFC20_Notifications_Calendar_Reminders_Implementation_Proof_Prompt.md` (partial_implementation; release proof)

### 111. Same source file targeted by multiple active items: Native/Ambitions/Services/GoalContradictionService.swift

- Conflict ID: `AMB28-same_source_file_targeted_by_multiple_active_batches-94672703`
- Type: `same_source_file_targeted_by_multiple_active_batches`
- Severity: `yellow`
- Recommended action: `merge`
- Rationale: Multiple active ledger items reference the same source file; merge, sequence, or assign ownership before implementation.
- Linear issue ready: `True`
- Auto-resolved: `False`
- Involved:
  - `AMB-POST23-01-TRUTH-AUDIT` — `docs/codex/reports/AMB-POST23-01-TRUTH-AUDIT.md` (partial_implementation; release proof)
  - `BATCH-30-contradiction-engine` — `docs/codex/batches/BATCH-30-contradiction-engine.md` (unknown; release proof)

### 112. Same source file targeted by multiple active items: Native/Ambitions/Services/GoalPathCompilerService.swift

- Conflict ID: `AMB28-same_source_file_targeted_by_multiple_active_batches-384126`
- Type: `same_source_file_targeted_by_multiple_active_batches`
- Severity: `yellow`
- Recommended action: `merge`
- Rationale: Multiple active ledger items reference the same source file; merge, sequence, or assign ownership before implementation.
- Linear issue ready: `True`
- Auto-resolved: `False`
- Involved:
  - `BATCH-24-path-compiler-foundation` — `docs/codex/batches/BATCH-24-path-compiler-foundation.md` (unknown; release proof)
  - `BATCH-25-domain-pack-framework` — `docs/codex/batches/BATCH-25-domain-pack-framework.md` (unknown; release proof)

### 113. Same source file targeted by multiple active items: Native/Ambitions/Services/GoalUnderstandingService.swift

- Conflict ID: `AMB28-same_source_file_targeted_by_multiple_active_batches-90658273`
- Type: `same_source_file_targeted_by_multiple_active_batches`
- Severity: `yellow`
- Recommended action: `merge`
- Rationale: Multiple active ledger items reference the same source file; merge, sequence, or assign ownership before implementation.
- Linear issue ready: `True`
- Auto-resolved: `False`
- Involved:
  - `AMB-POST23-01-TRUTH-AUDIT` — `docs/codex/reports/AMB-POST23-01-TRUTH-AUDIT.md` (partial_implementation; release proof)
  - `BATCH-23-generalized-goal-understanding-contracts` — `docs/codex/batches/BATCH-23-generalized-goal-understanding-contracts.md` (unknown; release proof)

### 114. Same source file targeted by multiple active items: Native/Ambitions/Services/KnowledgeIngestionService.swift

- Conflict ID: `AMB28-same_source_file_targeted_by_multiple_active_batches-77036421`
- Type: `same_source_file_targeted_by_multiple_active_batches`
- Severity: `yellow`
- Recommended action: `merge`
- Rationale: Multiple active ledger items reference the same source file; merge, sequence, or assign ownership before implementation.
- Linear issue ready: `True`
- Auto-resolved: `False`
- Involved:
  - `AMB-POST23-01-TRUTH-AUDIT` — `docs/codex/reports/AMB-POST23-01-TRUTH-AUDIT.md` (partial_implementation; release proof)
  - `BATCH-21-external-knowledge-ingestion-core` — `docs/codex/batches/BATCH-21-external-knowledge-ingestion-core.md` (unknown; release proof)

### 115. Same source file targeted by multiple active items: Native/Ambitions/Services/KnowledgeProviderBoundary.swift

- Conflict ID: `AMB28-same_source_file_targeted_by_multiple_active_batches-31467468`
- Type: `same_source_file_targeted_by_multiple_active_batches`
- Severity: `yellow`
- Recommended action: `merge`
- Rationale: Multiple active ledger items reference the same source file; merge, sequence, or assign ownership before implementation.
- Linear issue ready: `True`
- Auto-resolved: `False`
- Involved:
  - `BATCH-20-knowledge-provider-boundary` — `docs/codex/batches/BATCH-20-knowledge-provider-boundary.md` (unknown; release proof)
  - `BATCH-21-external-knowledge-ingestion-core` — `docs/codex/batches/BATCH-21-external-knowledge-ingestion-core.md` (unknown; release proof)

### 116. Same source file targeted by multiple active items: Native/Ambitions/Services/SmartAttachmentService.swift

- Conflict ID: `AMB28-same_source_file_targeted_by_multiple_active_batches-23876220`
- Type: `same_source_file_targeted_by_multiple_active_batches`
- Severity: `yellow`
- Recommended action: `merge`
- Rationale: Multiple active ledger items reference the same source file; merge, sequence, or assign ownership before implementation.
- Linear issue ready: `True`
- Auto-resolved: `False`
- Involved:
  - `TRAIN_04D_CAPTURE_RUNTIME_FACTORING_FUTURE_PROOF` — `prompts/trains/ios26-flagship/TRAIN_04D_CAPTURE_RUNTIME_FACTORING_FUTURE_PROOF.md` (partial_implementation; release proof)
  - `concept-lock-registry` — `docs/codex/concept-lock-registry.yml` (partial_implementation; tests)

### 117. Same source file targeted by multiple active items: Native/Ambitions/Support/ReleasePerformanceResponsivenessReport.swift

- Conflict ID: `AMB28-same_source_file_targeted_by_multiple_active_batches-88258536`
- Type: `same_source_file_targeted_by_multiple_active_batches`
- Severity: `yellow`
- Recommended action: `merge`
- Rationale: Multiple active ledger items reference the same source file; merge, sequence, or assign ownership before implementation.
- Linear issue ready: `True`
- Auto-resolved: `False`
- Involved:
  - `PK36` — `prompts/batches/PK36.md` (partial_implementation; release proof)
  - `PFC36` — `prompts/batches/PFC36.md` (partial_implementation; release proof)

### 118. Same source file targeted by multiple active items: Native/AmbitionsTests/App/AppContainerFactoryTests.swift

- Conflict ID: `AMB28-same_source_file_targeted_by_multiple_active_batches-98301428`
- Type: `same_source_file_targeted_by_multiple_active_batches`
- Severity: `yellow`
- Recommended action: `merge`
- Rationale: Multiple active ledger items reference the same source file; merge, sequence, or assign ownership before implementation.
- Linear issue ready: `True`
- Auto-resolved: `False`
- Involved:
  - `BATCH-33-intelligence-runtime-integration` — `docs/codex/batches/BATCH-33-intelligence-runtime-integration.md` (partial_implementation; release proof)
  - `MOAT-GOAL-REALITY-RUNTIME-SERVICE-03` — `prompts/batches/MOAT-GOAL-REALITY-RUNTIME-SERVICE-03.md` (partial_implementation; release proof)

### 119. Same source file targeted by multiple active items: Native/AmbitionsTests/App/AppShellNavigationTests.swift

- Conflict ID: `AMB28-same_source_file_targeted_by_multiple_active_batches-23731427`
- Type: `same_source_file_targeted_by_multiple_active_batches`
- Severity: `yellow`
- Recommended action: `merge`
- Rationale: Multiple active ledger items reference the same source file; merge, sequence, or assign ownership before implementation.
- Linear issue ready: `True`
- Auto-resolved: `False`
- Involved:
  - `FLAGSHIP_COMPLETION_FILE_BOUNDARY_MAP` — `docs/codex/FLAGSHIP_COMPLETION_FILE_BOUNDARY_MAP.md` (partial_implementation; release proof)
  - `TOP-LEVEL-IA-PLAN-LEAK-REGRESSION-01` — `prompts/batches/TOP-LEVEL-IA-PLAN-LEAK-REGRESSION-01.md` (partial_implementation; release proof)
  - `FCP08_Ambition_Meridian_Shell_Prompt` — `docs/codex/batches/FCP08_Ambition_Meridian_Shell_Prompt.md` (unknown; release proof)

### 120. Same source file targeted by multiple active items: Native/AmbitionsTests/App/ExternalSurfaceSnapshotTests.swift

- Conflict ID: `AMB28-same_source_file_targeted_by_multiple_active_batches-67536968`
- Type: `same_source_file_targeted_by_multiple_active_batches`
- Severity: `yellow`
- Recommended action: `merge`
- Rationale: Multiple active ledger items reference the same source file; merge, sequence, or assign ownership before implementation.
- Linear issue ready: `True`
- Auto-resolved: `False`
- Involved:
  - `PFC14_WidgetKit_Implementation_And_Tests_Prompt` — `docs/codex/batches/PFC14_WidgetKit_Implementation_And_Tests_Prompt.md` (partial_implementation; release proof)
  - `PFC16_Live_Activities_Implementation_And_Tests_Prompt` — `docs/codex/batches/PFC16_Live_Activities_Implementation_And_Tests_Prompt.md` (partial_implementation; release proof)

### 121. Same source file targeted by multiple active items: Native/AmbitionsTests/App/ExternalWidgetProjectionTests.swift

- Conflict ID: `AMB28-same_source_file_targeted_by_multiple_active_batches-5105350`
- Type: `same_source_file_targeted_by_multiple_active_batches`
- Severity: `yellow`
- Recommended action: `merge`
- Rationale: Multiple active ledger items reference the same source file; merge, sequence, or assign ownership before implementation.
- Linear issue ready: `True`
- Auto-resolved: `False`
- Involved:
  - `PFC14_WidgetKit_Implementation_And_Tests_Prompt` — `docs/codex/batches/PFC14_WidgetKit_Implementation_And_Tests_Prompt.md` (partial_implementation; release proof)
  - `PFC13_WidgetKit_Strategy_And_Object_Map_Prompt` — `docs/codex/batches/PFC13_WidgetKit_Strategy_And_Object_Map_Prompt.md` (unknown; release proof)

### 122. Same source file targeted by multiple active items: Native/AmbitionsTests/App/TrustReceiptLayerDesignSystemTests.swift

- Conflict ID: `AMB28-same_source_file_targeted_by_multiple_active_batches-26131842`
- Type: `same_source_file_targeted_by_multiple_active_batches`
- Severity: `yellow`
- Recommended action: `merge`
- Rationale: Multiple active ledger items reference the same source file; merge, sequence, or assign ownership before implementation.
- Linear issue ready: `True`
- Auto-resolved: `False`
- Involved:
  - `FLAGSHIP_COMPLETION_FILE_BOUNDARY_MAP` — `docs/codex/FLAGSHIP_COMPLETION_FILE_BOUNDARY_MAP.md` (partial_implementation; release proof)
  - `FCP06_Receipt_Drawer_Trust_Layer_Prompt` — `docs/codex/batches/FCP06_Receipt_Drawer_Trust_Layer_Prompt.md` (partial_implementation; release proof)

### 123. Same source file targeted by multiple active items: Native/AmbitionsTests/Domain/AmbitionsOSEvaluationModelsTests.swift

- Conflict ID: `AMB28-same_source_file_targeted_by_multiple_active_batches-54654689`
- Type: `same_source_file_targeted_by_multiple_active_batches`
- Severity: `yellow`
- Recommended action: `merge`
- Rationale: Multiple active ledger items reference the same source file; merge, sequence, or assign ownership before implementation.
- Linear issue ready: `True`
- Auto-resolved: `False`
- Involved:
  - `AMBITIONSOS_AOS_PRIVACY_PROJECTION_LEDGER` — `docs/codex/AMBITIONSOS_AOS_PRIVACY_PROJECTION_LEDGER.md` (unknown; release proof)
  - `AMBITIONSOS_AOS_SOURCE_TRUTH_CLAIM_LEDGER` — `docs/codex/AMBITIONSOS_AOS_SOURCE_TRUTH_CLAIM_LEDGER.md` (unknown; release proof)

### 124. Same source file targeted by multiple active items: Native/AmbitionsTests/Domain/AmbitionsOSLivingDreamTodayBridgeModelsTests.swift

- Conflict ID: `AMB28-same_source_file_targeted_by_multiple_active_batches-72282518`
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

### 125. Same source file targeted by multiple active items: Native/AmbitionsTests/Domain/AmbitionsOSPrivacySafetyModelsTests.swift

- Conflict ID: `AMB28-same_source_file_targeted_by_multiple_active_batches-16965779`
- Type: `same_source_file_targeted_by_multiple_active_batches`
- Severity: `yellow`
- Recommended action: `merge`
- Rationale: Multiple active ledger items reference the same source file; merge, sequence, or assign ownership before implementation.
- Linear issue ready: `True`
- Auto-resolved: `False`
- Involved:
  - `AMBITIONSOS_AOS_PRIVACY_PROJECTION_LEDGER` — `docs/codex/AMBITIONSOS_AOS_PRIVACY_PROJECTION_LEDGER.md` (unknown; release proof)
  - `AMBITIONSOS_AOS_SOURCE_TRUTH_CLAIM_LEDGER` — `docs/codex/AMBITIONSOS_AOS_SOURCE_TRUTH_CLAIM_LEDGER.md` (unknown; release proof)

### 126. Same source file targeted by multiple active items: Native/AmbitionsTests/Domain/InspectableIntelligenceGoldenScenarioTests.swift

- Conflict ID: `AMB28-same_source_file_targeted_by_multiple_active_batches-31211961`
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

### 127. Same source file targeted by multiple active items: Native/AmbitionsTests/Domain/SafeAutomationPolicyModelsTests.swift

- Conflict ID: `AMB28-same_source_file_targeted_by_multiple_active_batches-33594616`
- Type: `same_source_file_targeted_by_multiple_active_batches`
- Severity: `yellow`
- Recommended action: `merge`
- Rationale: Multiple active ledger items reference the same source file; merge, sequence, or assign ownership before implementation.
- Linear issue ready: `True`
- Auto-resolved: `False`
- Involved:
  - `PK22` — `prompts/batches/PK22.md` (partial_implementation; release proof)
  - `BACKEND-FINAL-FORM-LOCAL-FIRST-HUMAN-01` — `prompts/batches/BACKEND-FINAL-FORM-LOCAL-FIRST-HUMAN-01.md` (partial_implementation; release proof)

### 128. Same source file targeted by multiple active items: Native/AmbitionsTests/Persistence/EventLedgerRepositoryTests.swift

- Conflict ID: `AMB28-same_source_file_targeted_by_multiple_active_batches-11898774`
- Type: `same_source_file_targeted_by_multiple_active_batches`
- Severity: `yellow`
- Recommended action: `merge`
- Rationale: Multiple active ledger items reference the same source file; merge, sequence, or assign ownership before implementation.
- Linear issue ready: `True`
- Auto-resolved: `False`
- Involved:
  - `PK22` — `prompts/batches/PK22.md` (partial_implementation; release proof)
  - `BACKEND-FINAL-FORM-LOCAL-FIRST-HUMAN-01` — `prompts/batches/BACKEND-FINAL-FORM-LOCAL-FIRST-HUMAN-01.md` (partial_implementation; release proof)

### 129. Same source file targeted by multiple active items: Native/AmbitionsTests/Persistence/PersistenceRepositoryTests.swift

- Conflict ID: `AMB28-same_source_file_targeted_by_multiple_active_batches-20949965`
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

### 130. Same source file targeted by multiple active items: Native/AmbitionsTests/Persistence/PortableRestoreRollbackTests.swift

- Conflict ID: `AMB28-same_source_file_targeted_by_multiple_active_batches-43735803`
- Type: `same_source_file_targeted_by_multiple_active_batches`
- Severity: `yellow`
- Recommended action: `merge`
- Rationale: Multiple active ledger items reference the same source file; merge, sequence, or assign ownership before implementation.
- Linear issue ready: `True`
- Auto-resolved: `False`
- Involved:
  - `BACKEND-FINAL-FORM-LOCAL-FIRST-HUMAN-01` — `prompts/batches/BACKEND-FINAL-FORM-LOCAL-FIRST-HUMAN-01.md` (partial_implementation; release proof)
  - `MOAT-GOAL-REALITY-LOCAL-PERSISTENCE-08` — `prompts/batches/MOAT-GOAL-REALITY-LOCAL-PERSISTENCE-08.md` (partial_implementation; release proof)

### 131. Same source file targeted by multiple active items: Native/AmbitionsTests/Persistence/PortableSnapshotServiceTests.swift

- Conflict ID: `AMB28-same_source_file_targeted_by_multiple_active_batches-91043473`
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

### 132. Same source file targeted by multiple active items: Native/AmbitionsTests/Persistence/PreMigrationBackupTests.swift

- Conflict ID: `AMB28-same_source_file_targeted_by_multiple_active_batches-24962709`
- Type: `same_source_file_targeted_by_multiple_active_batches`
- Severity: `yellow`
- Recommended action: `merge`
- Rationale: Multiple active ledger items reference the same source file; merge, sequence, or assign ownership before implementation.
- Linear issue ready: `True`
- Auto-resolved: `False`
- Involved:
  - `BACKEND-FINAL-FORM-LOCAL-FIRST-HUMAN-01` — `prompts/batches/BACKEND-FINAL-FORM-LOCAL-FIRST-HUMAN-01.md` (partial_implementation; release proof)
  - `MOAT-GOAL-REALITY-LOCAL-PERSISTENCE-08` — `prompts/batches/MOAT-GOAL-REALITY-LOCAL-PERSISTENCE-08.md` (partial_implementation; release proof)

### 133. Same source file targeted by multiple active items: Native/AmbitionsTests/Persistence/SyncCapabilityTests.swift

- Conflict ID: `AMB28-same_source_file_targeted_by_multiple_active_batches-56748301`
- Type: `same_source_file_targeted_by_multiple_active_batches`
- Severity: `yellow`
- Recommended action: `merge`
- Rationale: Multiple active ledger items reference the same source file; merge, sequence, or assign ownership before implementation.
- Linear issue ready: `True`
- Auto-resolved: `False`
- Involved:
  - `PFC07_Migration_Ladder_And_Backward_Compatibility_Tests_Prompt` — `docs/codex/batches/PFC07_Migration_Ladder_And_Backward_Compatibility_Tests_Prompt.md` (partial_implementation; release proof)
  - `BACKEND-FINAL-FORM-LOCAL-FIRST-HUMAN-01` — `prompts/batches/BACKEND-FINAL-FORM-LOCAL-FIRST-HUMAN-01.md` (partial_implementation; release proof)

### 134. Same source file targeted by multiple active items: Native/AmbitionsTests/Profile/ProfileFeatureServiceTests.swift

- Conflict ID: `AMB28-same_source_file_targeted_by_multiple_active_batches-36057412`
- Type: `same_source_file_targeted_by_multiple_active_batches`
- Severity: `yellow`
- Recommended action: `merge`
- Rationale: Multiple active ledger items reference the same source file; merge, sequence, or assign ownership before implementation.
- Linear issue ready: `True`
- Auto-resolved: `False`
- Involved:
  - `FLAGSHIP_COMPLETION_FILE_BOUNDARY_MAP` — `docs/codex/FLAGSHIP_COMPLETION_FILE_BOUNDARY_MAP.md` (partial_implementation; release proof)
  - `FCP17_Schedule_Availability_Defaults_Center_Prompt` — `docs/codex/batches/FCP17_Schedule_Availability_Defaults_Center_Prompt.md` (unknown; release proof)

### 135. Same source file targeted by multiple active items: Native/AmbitionsTests/Runtime/AmbitionsRuntimeBoundaryTests.swift

- Conflict ID: `AMB28-same_source_file_targeted_by_multiple_active_batches-50843547`
- Type: `same_source_file_targeted_by_multiple_active_batches`
- Severity: `yellow`
- Recommended action: `merge`
- Rationale: Multiple active ledger items reference the same source file; merge, sequence, or assign ownership before implementation.
- Linear issue ready: `True`
- Auto-resolved: `False`
- Involved:
  - `BATCH-33-intelligence-runtime-integration` — `docs/codex/batches/BATCH-33-intelligence-runtime-integration.md` (partial_implementation; release proof)
  - `MOAT-GOAL-REALITY-RUNTIME-SERVICE-03` — `prompts/batches/MOAT-GOAL-REALITY-RUNTIME-SERVICE-03.md` (partial_implementation; release proof)

### 136. Same source file targeted by multiple active items: Native/AmbitionsTests/Runtime/AmbitionsRuntimeGoalIntelligenceServiceTests.swift

- Conflict ID: `AMB28-same_source_file_targeted_by_multiple_active_batches-87116582`
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

### 137. Same source file targeted by multiple active items: Native/AmbitionsTests/Runtime/GoalRealityCompilerCoreTests.swift

- Conflict ID: `AMB28-same_source_file_targeted_by_multiple_active_batches-75259388`
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

### 138. Same source file targeted by multiple active items: Native/AmbitionsTests/Runtime/GoalRealityGoldenFixtureTests.swift

- Conflict ID: `AMB28-same_source_file_targeted_by_multiple_active_batches-60951933`
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
  - `MOAT-GOAL-REALITY-GOALS-BRIDGE-05` — `prompts/batches/MOAT-GOAL-REALITY-GOALS-BRIDGE-05.md` (partial_implementation; release proof)
  - `MOAT-GOAL-REALITY-TODAY-BRIDGE-06` — `prompts/batches/MOAT-GOAL-REALITY-TODAY-BRIDGE-06.md` (partial_implementation; release proof)

### 139. Same source file targeted by multiple active items: Native/AmbitionsTests/Runtime/GoalRealityNegativeFixtureTests.swift

- Conflict ID: `AMB28-same_source_file_targeted_by_multiple_active_batches-11630089`
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

### 140. Same source file targeted by multiple active items: Native/AmbitionsTests/Runtime/GoalRealityReceiptTests.swift

- Conflict ID: `AMB28-same_source_file_targeted_by_multiple_active_batches-12898856`
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

### 141. Same source file targeted by multiple active items: Native/AmbitionsTests/Runtime/GoalRealityRuntimeBoundaryTests.swift

- Conflict ID: `AMB28-same_source_file_targeted_by_multiple_active_batches-72416313`
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

### 142. Same source file targeted by multiple active items: Native/AmbitionsTests/Runtime/GoalRealityRuntimeServiceTests.swift

- Conflict ID: `AMB28-same_source_file_targeted_by_multiple_active_batches-27167925`
- Type: `same_source_file_targeted_by_multiple_active_batches`
- Severity: `yellow`
- Recommended action: `merge`
- Rationale: Multiple active ledger items reference the same source file; merge, sequence, or assign ownership before implementation.
- Linear issue ready: `True`
- Auto-resolved: `False`
- Involved:
  - `MOAT-GOAL-REALITY-CAPTURE-BRIDGE-04` — `prompts/batches/MOAT-GOAL-REALITY-CAPTURE-BRIDGE-04.md` (partial_implementation; release proof)
  - `MOAT-GOAL-REALITY-RUNTIME-SERVICE-03` — `prompts/batches/MOAT-GOAL-REALITY-RUNTIME-SERVICE-03.md` (partial_implementation; release proof)

### 143. Same source file targeted by multiple active items: Native/AmbitionsTests/Runtime/MoonshotProofPathRuntimeTests.swift

- Conflict ID: `AMB28-same_source_file_targeted_by_multiple_active_batches-54846811`
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

### 144. Same source file targeted by multiple active items: Native/AmbitionsTests/Services/AmbitionsCommandExecutorTests.swift

- Conflict ID: `AMB28-same_source_file_targeted_by_multiple_active_batches-7768050`
- Type: `same_source_file_targeted_by_multiple_active_batches`
- Severity: `yellow`
- Recommended action: `merge`
- Rationale: Multiple active ledger items reference the same source file; merge, sequence, or assign ownership before implementation.
- Linear issue ready: `True`
- Auto-resolved: `False`
- Involved:
  - `PK22` — `prompts/batches/PK22.md` (partial_implementation; release proof)
  - `BACKEND-FINAL-FORM-LOCAL-FIRST-HUMAN-01` — `prompts/batches/BACKEND-FINAL-FORM-LOCAL-FIRST-HUMAN-01.md` (partial_implementation; release proof)

### 145. Same source file targeted by multiple active items: Native/AmbitionsTests/Today/TodayViewModelTests.swift

- Conflict ID: `AMB28-same_source_file_targeted_by_multiple_active_batches-3247698`
- Type: `same_source_file_targeted_by_multiple_active_batches`
- Severity: `yellow`
- Recommended action: `merge`
- Rationale: Multiple active ledger items reference the same source file; merge, sequence, or assign ownership before implementation.
- Linear issue ready: `True`
- Auto-resolved: `False`
- Involved:
  - `F03_5_Today_Execution_State_Contract_Hardening_Prompt` — `docs/codex/batches/F03_5_Today_Execution_State_Contract_Hardening_Prompt.md` (partial_implementation; release proof)
  - `FLAGSHIP_COMPLETION_FILE_BOUNDARY_MAP` — `docs/codex/FLAGSHIP_COMPLETION_FILE_BOUNDARY_MAP.md` (partial_implementation; release proof)
  - `MOONSHOT_PROOF_PATH_BACKEND_MASTER_PLAN` — `docs/codex/MOONSHOT_PROOF_PATH_BACKEND_MASTER_PLAN.md` (partial_implementation; release proof)
  - `MOAT-MOONSHOT-BACKEND-FULL-TRAIN-01` — `prompts/batches/MOAT-MOONSHOT-BACKEND-FULL-TRAIN-01.md` (partial_implementation; release proof)
  - `MOAT-MOONSHOT-PROOF-PATH-01` — `prompts/batches/MOAT-MOONSHOT-PROOF-PATH-01.md` (partial_implementation; release proof)
  - `MOAT-GOAL-REALITY-TODAY-BRIDGE-06` — `prompts/batches/MOAT-GOAL-REALITY-TODAY-BRIDGE-06.md` (partial_implementation; release proof)
  - `FCP05_Start_Here_Surface_Prompt` — `docs/codex/batches/FCP05_Start_Here_Surface_Prompt.md` (unknown; release proof)
  - `FCP07_Reality_Rail_Continuity_Prompt` — `docs/codex/batches/FCP07_Reality_Rail_Continuity_Prompt.md` (unknown; release proof)
  - `FCP13A_Action_Closure_Diamond_Prompt` — `docs/codex/batches/FCP13A_Action_Closure_Diamond_Prompt.md` (unknown; release proof)

### 146. Same source file targeted by multiple active items: Native/AmbitionsUITests/AmbitionsUITests.swift

- Conflict ID: `AMB28-same_source_file_targeted_by_multiple_active_batches-8527029`
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

### 147. Same source file targeted by multiple active items: Native/AmbitionsWidgetExtension/NextStepWidget.swift

- Conflict ID: `AMB28-same_source_file_targeted_by_multiple_active_batches-97959044`
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

### 148. Same source file targeted by multiple active items: scripts/ai/acx.py

- Conflict ID: `AMB28-same_source_file_targeted_by_multiple_active_batches-28141868`
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

### 149. Same source file targeted by multiple active items: scripts/ai/acx_accessibility_packet.py

- Conflict ID: `AMB28-same_source_file_targeted_by_multiple_active_batches-19756138`
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

### 150. Same source file targeted by multiple active items: scripts/ai/acx_build_triage.py

- Conflict ID: `AMB28-same_source_file_targeted_by_multiple_active_batches-13671442`
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

### 151. Same source file targeted by multiple active items: scripts/ai/acx_closeout.py

- Conflict ID: `AMB28-same_source_file_targeted_by_multiple_active_batches-17730920`
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

### 152. Same source file targeted by multiple active items: scripts/ai/acx_impact.py

- Conflict ID: `AMB28-same_source_file_targeted_by_multiple_active_batches-27024816`
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

### 153. Same source file targeted by multiple active items: scripts/ai/acx_local.py

- Conflict ID: `AMB28-same_source_file_targeted_by_multiple_active_batches-32243448`
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

### 154. Same source file targeted by multiple active items: scripts/ai/acx_repair.py

- Conflict ID: `AMB28-same_source_file_targeted_by_multiple_active_batches-21802874`
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

### 155. Same source file targeted by multiple active items: scripts/ai/acx_sanitized_evidence.py

- Conflict ID: `AMB28-same_source_file_targeted_by_multiple_active_batches-19661963`
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

### 156. Same source file targeted by multiple active items: scripts/ai/acx_visual_packet.py

- Conflict ID: `AMB28-same_source_file_targeted_by_multiple_active_batches-69194013`
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
  - `CODEX_VISUAL_QA_PROTOCOL` — `docs/codex/CODEX_VISUAL_QA_PROTOCOL.md` (unknown; release proof)

### 157. Same source file targeted by multiple active items: scripts/ambitions-advance-batch-state.py

- Conflict ID: `AMB28-same_source_file_targeted_by_multiple_active_batches-31555995`
- Type: `same_source_file_targeted_by_multiple_active_batches`
- Severity: `yellow`
- Recommended action: `merge`
- Rationale: Multiple active ledger items reference the same source file; merge, sequence, or assign ownership before implementation.
- Linear issue ready: `True`
- Auto-resolved: `False`
- Involved:
  - `POST_PK_CLOSEOUT_CONTRACT` — `docs/codex/POST_PK_CLOSEOUT_CONTRACT.md` (partial_implementation; release proof)
  - `POST_PK_SPEED_TRAIN_OPERATING_MODEL` — `docs/codex/POST_PK_SPEED_TRAIN_OPERATING_MODEL.md` (unknown; release proof)

### 158. Same source file targeted by multiple active items: scripts/ambitions-authority-supersession-check.py

- Conflict ID: `AMB28-same_source_file_targeted_by_multiple_active_batches-62524090`
- Type: `same_source_file_targeted_by_multiple_active_batches`
- Severity: `yellow`
- Recommended action: `merge`
- Rationale: Multiple active ledger items reference the same source file; merge, sequence, or assign ownership before implementation.
- Linear issue ready: `True`
- Auto-resolved: `False`
- Involved:
  - `AMB-REPO-AUTHORITY-06-ACTIVE-DRIFT-REPAIR` — `prompts/batches/AMB-REPO-AUTHORITY-06-ACTIVE-DRIFT-REPAIR.md` (partial_implementation; release proof)
  - `AMB-REPO-AUTHORITY-07-GATES-FINAL-PROOF` — `prompts/batches/AMB-REPO-AUTHORITY-07-GATES-FINAL-PROOF.md` (partial_implementation; release proof)

### 159. Same source file targeted by multiple active items: scripts/ambitions-autonomous-train-fastpath.py

- Conflict ID: `AMB28-same_source_file_targeted_by_multiple_active_batches-22344920`
- Type: `same_source_file_targeted_by_multiple_active_batches`
- Severity: `yellow`
- Recommended action: `merge`
- Rationale: Multiple active ledger items reference the same source file; merge, sequence, or assign ownership before implementation.
- Linear issue ready: `True`
- Auto-resolved: `False`
- Involved:
  - `AUTONOMOUS_TRAIN_FASTPATH` — `docs/codex/AUTONOMOUS_TRAIN_FASTPATH.md` (partial_implementation; release proof)
  - `AUTONOMOUS-TRAIN-FASTPATH-01` — `prompts/batches/AUTONOMOUS-TRAIN-FASTPATH-01.md` (partial_implementation; release proof)

### 160. Same source file targeted by multiple active items: scripts/ambitions-autonomous-train.sh

- Conflict ID: `AMB28-same_source_file_targeted_by_multiple_active_batches-71092207`
- Type: `same_source_file_targeted_by_multiple_active_batches`
- Severity: `yellow`
- Recommended action: `merge`
- Rationale: Multiple active ledger items reference the same source file; merge, sequence, or assign ownership before implementation.
- Linear issue ready: `True`
- Auto-resolved: `False`
- Involved:
  - `ambitions-hybrid-runner` — `docs/codex/ambitions-hybrid-runner.md` (partial_implementation; release proof)
  - `XCODE-PERF-RUNNER-MATURITY-01` — `prompts/batches/XCODE-PERF-RUNNER-MATURITY-01.md` (partial_implementation; release proof)

### 161. Same source file targeted by multiple active items: scripts/ambitions-bundle-next-batches.py

- Conflict ID: `AMB28-same_source_file_targeted_by_multiple_active_batches-38335713`
- Type: `same_source_file_targeted_by_multiple_active_batches`
- Severity: `yellow`
- Recommended action: `merge`
- Rationale: Multiple active ledger items reference the same source file; merge, sequence, or assign ownership before implementation.
- Linear issue ready: `True`
- Auto-resolved: `False`
- Involved:
  - `POST_PK_BATCH_BUNDLES` — `docs/codex/POST_PK_BATCH_BUNDLES.md` (unknown; release proof)
  - `POST_PK_SPEED_TRAIN_OPERATING_MODEL` — `docs/codex/POST_PK_SPEED_TRAIN_OPERATING_MODEL.md` (unknown; release proof)

### 162. Same source file targeted by multiple active items: scripts/ambitions-closeout-coalesce.py

- Conflict ID: `AMB28-same_source_file_targeted_by_multiple_active_batches-47534655`
- Type: `same_source_file_targeted_by_multiple_active_batches`
- Severity: `yellow`
- Recommended action: `merge`
- Rationale: Multiple active ledger items reference the same source file; merge, sequence, or assign ownership before implementation.
- Linear issue ready: `True`
- Auto-resolved: `False`
- Involved:
  - `POST_PK_CLOSEOUT_CONTRACT` — `docs/codex/POST_PK_CLOSEOUT_CONTRACT.md` (partial_implementation; release proof)
  - `POST_PK_SPEED_TRAIN_OPERATING_MODEL` — `docs/codex/POST_PK_SPEED_TRAIN_OPERATING_MODEL.md` (unknown; release proof)

### 163. Same source file targeted by multiple active items: scripts/ambitions-codex-os-validate.py

- Conflict ID: `AMB28-same_source_file_targeted_by_multiple_active_batches-83525689`
- Type: `same_source_file_targeted_by_multiple_active_batches`
- Severity: `yellow`
- Recommended action: `merge`
- Rationale: Multiple active ledger items reference the same source file; merge, sequence, or assign ownership before implementation.
- Linear issue ready: `True`
- Auto-resolved: `False`
- Involved:
  - `MOAT-COMPLETE-AUTONOMOUS-01` — `prompts/batches/MOAT-COMPLETE-AUTONOMOUS-01.md` (partial_implementation; release proof)
  - `AMB-REPO-AUTHORITY-07-GATES-FINAL-PROOF` — `prompts/batches/AMB-REPO-AUTHORITY-07-GATES-FINAL-PROOF.md` (partial_implementation; release proof)
  - `AMB-CHATGPT-REPO-OS-UPGRADE-INSTALL-01` — `docs/codex/reports/AMB-CHATGPT-REPO-OS-UPGRADE-INSTALL-01.md` (partial_implementation; release proof)
  - `AMB-CODEX-OS-FLAGSHIP-UPGRADE-INSTALL-01` — `docs/codex/reports/AMB-CODEX-OS-FLAGSHIP-UPGRADE-INSTALL-01.md` (partial_implementation; release proof)
  - `AMB-CODEX-OS-FLAGSHIP-UPGRADE-INSTALL-01` — `prompts/batches/AMB-CODEX-OS-FLAGSHIP-UPGRADE-INSTALL-01.md` (partial_implementation; release proof)
  - `OS-FLAGSHIP-07-SKILL-REGISTRY-AND-RUNNER-INTEGRATION` — `prompts/batches/OS-FLAGSHIP-07-SKILL-REGISTRY-AND-RUNNER-INTEGRATION.md` (partial_implementation; release proof)
  - `AMB-REPO-GREEN-FLAGSHIP-RESET-MASTER-01-T01-AUDIT-CALIBRATION` — `prompts/batches/AMB-REPO-GREEN-FLAGSHIP-RESET-MASTER-01-T01-AUDIT-CALIBRATION.md` (partial_implementation; release proof)
  - `AMB-ISSUE-TEMPLATES` — `docs/codex/linear-templates/AMB-ISSUE-TEMPLATES.md` (partial_implementation; release proof)
  - `AMB-LINEAR-TEMPLATE-MANIFEST` — `docs/codex/linear-templates/AMB-LINEAR-TEMPLATE-MANIFEST.yml` (partial_implementation; release proof)

### 164. Same source file targeted by multiple active items: scripts/ambitions-codex-train.sh

- Conflict ID: `AMB28-same_source_file_targeted_by_multiple_active_batches-19279448`
- Type: `same_source_file_targeted_by_multiple_active_batches`
- Severity: `yellow`
- Recommended action: `merge`
- Rationale: Multiple active ledger items reference the same source file; merge, sequence, or assign ownership before implementation.
- Linear issue ready: `True`
- Auto-resolved: `False`
- Involved:
  - `ambitions-hybrid-runner` — `docs/codex/ambitions-hybrid-runner.md` (partial_implementation; release proof)
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
  - ... 290 more

### 165. Same source file targeted by multiple active items: scripts/ambitions-control-plane-check.py

- Conflict ID: `AMB28-same_source_file_targeted_by_multiple_active_batches-72454456`
- Type: `same_source_file_targeted_by_multiple_active_batches`
- Severity: `yellow`
- Recommended action: `merge`
- Rationale: Multiple active ledger items reference the same source file; merge, sequence, or assign ownership before implementation.
- Linear issue ready: `True`
- Auto-resolved: `False`
- Involved:
  - `AMB_CONTROL_PLANE_DIRECT_RUNBOOK` — `docs/codex/AMB_CONTROL_PLANE_DIRECT_RUNBOOK.md` (partial_implementation; release proof)
  - `AMB_CONTROL_PLANE_GATE_INDEX` — `docs/codex/AMB_CONTROL_PLANE_GATE_INDEX.md` (partial_implementation; release proof)
  - `GLOBAL-BATCH-TRAIN-AUTONOMOUS-COMPLETE-01` — `prompts/batches/GLOBAL-BATCH-TRAIN-AUTONOMOUS-COMPLETE-01.md` (partial_implementation; release proof)
  - `GLOBAL-VISUAL-CANON-MOAT-INSTALL-TRAIN-01` — `prompts/batches/GLOBAL-VISUAL-CANON-MOAT-INSTALL-TRAIN-01.md` (partial_implementation; release proof)
  - `MOAT-ALIGNMENT-01` — `prompts/batches/MOAT-ALIGNMENT-01.md` (partial_implementation; release proof)
  - `MOAT-COMPLETE-AUTONOMOUS-01` — `prompts/batches/MOAT-COMPLETE-AUTONOMOUS-01.md` (partial_implementation; release proof)
  - `VISUAL-CANON-MOAT-01` — `prompts/batches/VISUAL-CANON-MOAT-01.md` (partial_implementation; release proof)
  - `XCODE-BUILD-SYSTEM-MAX-01-REPAIR-01` — `prompts/batches/XCODE-BUILD-SYSTEM-MAX-01-REPAIR-01.md` (partial_implementation; release proof)
  - `HBI-GLOBAL-TRAIN-HANDOFF-01` — `prompts/batches/HBI-GLOBAL-TRAIN-HANDOFF-01.md` (partial_implementation; release proof)

### 166. Same source file targeted by multiple active items: scripts/ambitions-deriveddata-manager.sh

- Conflict ID: `AMB28-same_source_file_targeted_by_multiple_active_batches-85996553`
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

### 167. Same source file targeted by multiple active items: scripts/ambitions-encyclopedia-to-frontend-os-final-gate.py

- Conflict ID: `AMB28-same_source_file_targeted_by_multiple_active_batches-88403236`
- Type: `same_source_file_targeted_by_multiple_active_batches`
- Severity: `yellow`
- Recommended action: `merge`
- Rationale: Multiple active ledger items reference the same source file; merge, sequence, or assign ownership before implementation.
- Linear issue ready: `True`
- Auto-resolved: `False`
- Involved:
  - `SIGNATURE-VISUAL-INSTRUMENTS-ENCYCLOPEDIA-07` — `prompts/batches/SIGNATURE-VISUAL-INSTRUMENTS-ENCYCLOPEDIA-07.md` (partial_implementation; release proof)
  - `AMB-POST23-02-UNDERDELIVERY-REPAIR` — `docs/codex/reports/AMB-POST23-02-UNDERDELIVERY-REPAIR.md` (partial_implementation; release proof)

### 168. Same source file targeted by multiple active items: scripts/ambitions-final-report-gate.py

- Conflict ID: `AMB28-same_source_file_targeted_by_multiple_active_batches-42995888`
- Type: `same_source_file_targeted_by_multiple_active_batches`
- Severity: `yellow`
- Recommended action: `merge`
- Rationale: Multiple active ledger items reference the same source file; merge, sequence, or assign ownership before implementation.
- Linear issue ready: `True`
- Auto-resolved: `False`
- Involved:
  - `AMB_CONTROL_PLANE_DIRECT_RUNBOOK` — `docs/codex/AMB_CONTROL_PLANE_DIRECT_RUNBOOK.md` (partial_implementation; release proof)
  - `AMB_CONTROL_PLANE_GATE_INDEX` — `docs/codex/AMB_CONTROL_PLANE_GATE_INDEX.md` (partial_implementation; release proof)
  - `MOAT-ALIGNMENT-01` — `prompts/batches/MOAT-ALIGNMENT-01.md` (partial_implementation; release proof)
  - `XCODE-BUILD-SYSTEM-MAX-01-REPAIR-01` — `prompts/batches/XCODE-BUILD-SYSTEM-MAX-01-REPAIR-01.md` (partial_implementation; release proof)

### 169. Same source file targeted by multiple active items: scripts/ambitions-frontend-architecture-atlas-check.py

- Conflict ID: `AMB28-same_source_file_targeted_by_multiple_active_batches-75316636`
- Type: `same_source_file_targeted_by_multiple_active_batches`
- Severity: `yellow`
- Recommended action: `merge`
- Rationale: Multiple active ledger items reference the same source file; merge, sequence, or assign ownership before implementation.
- Linear issue ready: `True`
- Auto-resolved: `False`
- Involved:
  - `FRONTEND-SURFACE-RECIPE-COMPLETENESS-REVIEW-001` — `prompts/batches/FRONTEND-SURFACE-RECIPE-COMPLETENESS-REVIEW-001.md` (partial_implementation; release proof)
  - `FLAGSHIP-OBJECT-SYSTEM-01` — `prompts/batches/FLAGSHIP-OBJECT-SYSTEM-01.md` (partial_implementation; release proof)

### 170. Same source file targeted by multiple active items: scripts/ambitions-frontend-authority-packet.py

- Conflict ID: `AMB28-same_source_file_targeted_by_multiple_active_batches-12391598`
- Type: `same_source_file_targeted_by_multiple_active_batches`
- Severity: `yellow`
- Recommended action: `merge`
- Rationale: Multiple active ledger items reference the same source file; merge, sequence, or assign ownership before implementation.
- Linear issue ready: `True`
- Auto-resolved: `False`
- Involved:
  - `SIGNATURE-VISUAL-INSTRUMENTS-ENCYCLOPEDIA-07` — `prompts/batches/SIGNATURE-VISUAL-INSTRUMENTS-ENCYCLOPEDIA-07.md` (partial_implementation; release proof)
  - `AMB-POST23-02-UNDERDELIVERY-REPAIR` — `docs/codex/reports/AMB-POST23-02-UNDERDELIVERY-REPAIR.md` (partial_implementation; release proof)

### 171. Same source file targeted by multiple active items: scripts/ambitions-frontend-drift-check.py

- Conflict ID: `AMB28-same_source_file_targeted_by_multiple_active_batches-40232383`
- Type: `same_source_file_targeted_by_multiple_active_batches`
- Severity: `yellow`
- Recommended action: `merge`
- Rationale: Multiple active ledger items reference the same source file; merge, sequence, or assign ownership before implementation.
- Linear issue ready: `True`
- Auto-resolved: `False`
- Involved:
  - `SIGNATURE-VISUAL-INSTRUMENTS-ENCYCLOPEDIA-07` — `prompts/batches/SIGNATURE-VISUAL-INSTRUMENTS-ENCYCLOPEDIA-07.md` (partial_implementation; release proof)
  - `AMB-FLAGSHIP-UI-CODEX-STUDIO-INSTALL-01` — `docs/codex/reports/AMB-FLAGSHIP-UI-CODEX-STUDIO-INSTALL-01.md` (partial_implementation; release proof)
  - `AMB-POST23-02-UNDERDELIVERY-REPAIR` — `docs/codex/reports/AMB-POST23-02-UNDERDELIVERY-REPAIR.md` (partial_implementation; release proof)

### 172. Same source file targeted by multiple active items: scripts/ambitions-frontend-implementation-dashboard.py

- Conflict ID: `AMB28-same_source_file_targeted_by_multiple_active_batches-28403787`
- Type: `same_source_file_targeted_by_multiple_active_batches`
- Severity: `yellow`
- Recommended action: `merge`
- Rationale: Multiple active ledger items reference the same source file; merge, sequence, or assign ownership before implementation.
- Linear issue ready: `True`
- Auto-resolved: `False`
- Involved:
  - `SIGNATURE-VISUAL-INSTRUMENTS-ENCYCLOPEDIA-07` — `prompts/batches/SIGNATURE-VISUAL-INSTRUMENTS-ENCYCLOPEDIA-07.md` (partial_implementation; release proof)
  - `AMB-POST23-02-UNDERDELIVERY-REPAIR` — `docs/codex/reports/AMB-POST23-02-UNDERDELIVERY-REPAIR.md` (partial_implementation; release proof)

### 173. Same source file targeted by multiple active items: scripts/ambitions-frontend-implementation-prompt.py

- Conflict ID: `AMB28-same_source_file_targeted_by_multiple_active_batches-83843232`
- Type: `same_source_file_targeted_by_multiple_active_batches`
- Severity: `yellow`
- Recommended action: `merge`
- Rationale: Multiple active ledger items reference the same source file; merge, sequence, or assign ownership before implementation.
- Linear issue ready: `True`
- Auto-resolved: `False`
- Involved:
  - `SIGNATURE-VISUAL-INSTRUMENTS-ENCYCLOPEDIA-07` — `prompts/batches/SIGNATURE-VISUAL-INSTRUMENTS-ENCYCLOPEDIA-07.md` (partial_implementation; release proof)
  - `AMB-POST23-02-UNDERDELIVERY-REPAIR` — `docs/codex/reports/AMB-POST23-02-UNDERDELIVERY-REPAIR.md` (partial_implementation; release proof)

### 174. Same source file targeted by multiple active items: scripts/ambitions-frontend-next-surface-queue.py

- Conflict ID: `AMB28-same_source_file_targeted_by_multiple_active_batches-15674448`
- Type: `same_source_file_targeted_by_multiple_active_batches`
- Severity: `yellow`
- Recommended action: `merge`
- Rationale: Multiple active ledger items reference the same source file; merge, sequence, or assign ownership before implementation.
- Linear issue ready: `True`
- Auto-resolved: `False`
- Involved:
  - `SIGNATURE-VISUAL-INSTRUMENTS-ENCYCLOPEDIA-07` — `prompts/batches/SIGNATURE-VISUAL-INSTRUMENTS-ENCYCLOPEDIA-07.md` (partial_implementation; release proof)
  - `AMB-POST23-02-UNDERDELIVERY-REPAIR` — `docs/codex/reports/AMB-POST23-02-UNDERDELIVERY-REPAIR.md` (partial_implementation; release proof)

### 175. Same source file targeted by multiple active items: scripts/ambitions-frontend-proof-contract-check.py

- Conflict ID: `AMB28-same_source_file_targeted_by_multiple_active_batches-19186256`
- Type: `same_source_file_targeted_by_multiple_active_batches`
- Severity: `yellow`
- Recommended action: `merge`
- Rationale: Multiple active ledger items reference the same source file; merge, sequence, or assign ownership before implementation.
- Linear issue ready: `True`
- Auto-resolved: `False`
- Involved:
  - `AMB-FLAGSHIP-UI-CODEX-STUDIO-INSTALL-01` — `docs/codex/reports/AMB-FLAGSHIP-UI-CODEX-STUDIO-INSTALL-01.md` (partial_implementation; release proof)
  - `AMB-POST23-02-UNDERDELIVERY-REPAIR` — `docs/codex/reports/AMB-POST23-02-UNDERDELIVERY-REPAIR.md` (partial_implementation; release proof)

### 176. Same source file targeted by multiple active items: scripts/ambitions-frontend-receipt-check.py

- Conflict ID: `AMB28-same_source_file_targeted_by_multiple_active_batches-28870643`
- Type: `same_source_file_targeted_by_multiple_active_batches`
- Severity: `yellow`
- Recommended action: `merge`
- Rationale: Multiple active ledger items reference the same source file; merge, sequence, or assign ownership before implementation.
- Linear issue ready: `True`
- Auto-resolved: `False`
- Involved:
  - `AMB-POST23-02-UNDERDELIVERY-REPAIR` — `docs/codex/reports/AMB-POST23-02-UNDERDELIVERY-REPAIR.md` (partial_implementation; release proof)
  - `frontend-gap-backlog` — `docs/codex/frontend-gap-backlog.md` (partial_implementation; release proof)

### 177. Same source file targeted by multiple active items: scripts/ambitions-frontend-source-bindings.py

- Conflict ID: `AMB28-same_source_file_targeted_by_multiple_active_batches-76775145`
- Type: `same_source_file_targeted_by_multiple_active_batches`
- Severity: `yellow`
- Recommended action: `merge`
- Rationale: Multiple active ledger items reference the same source file; merge, sequence, or assign ownership before implementation.
- Linear issue ready: `True`
- Auto-resolved: `False`
- Involved:
  - `SIGNATURE-VISUAL-INSTRUMENTS-ENCYCLOPEDIA-07` — `prompts/batches/SIGNATURE-VISUAL-INSTRUMENTS-ENCYCLOPEDIA-07.md` (partial_implementation; release proof)
  - `AMB-FLAGSHIP-UI-CODEX-STUDIO-INSTALL-01` — `docs/codex/reports/AMB-FLAGSHIP-UI-CODEX-STUDIO-INSTALL-01.md` (partial_implementation; release proof)
  - `AMB-POST23-02-UNDERDELIVERY-REPAIR` — `docs/codex/reports/AMB-POST23-02-UNDERDELIVERY-REPAIR.md` (partial_implementation; release proof)

### 178. Same source file targeted by multiple active items: scripts/ambitions-global-train-frontend-authority-check.py

- Conflict ID: `AMB28-same_source_file_targeted_by_multiple_active_batches-96511390`
- Type: `same_source_file_targeted_by_multiple_active_batches`
- Severity: `yellow`
- Recommended action: `merge`
- Rationale: Multiple active ledger items reference the same source file; merge, sequence, or assign ownership before implementation.
- Linear issue ready: `True`
- Auto-resolved: `False`
- Involved:
  - `AMB-POST23-02-UNDERDELIVERY-REPAIR` — `docs/codex/reports/AMB-POST23-02-UNDERDELIVERY-REPAIR.md` (partial_implementation; release proof)
  - `FRONTEND_AUTHORITY_GLOBAL_TRAIN_HOOK` — `docs/codex/FRONTEND_AUTHORITY_GLOBAL_TRAIN_HOOK.md` (unknown; release proof)

### 179. Same source file targeted by multiple active items: scripts/ambitions-global-train-supervisor.sh

- Conflict ID: `AMB28-same_source_file_targeted_by_multiple_active_batches-10542241`
- Type: `same_source_file_targeted_by_multiple_active_batches`
- Severity: `yellow`
- Recommended action: `merge`
- Rationale: Multiple active ledger items reference the same source file; merge, sequence, or assign ownership before implementation.
- Linear issue ready: `True`
- Auto-resolved: `False`
- Involved:
  - `global-train-supervisor` — `docs/codex/global-train-supervisor.md` (partial_implementation; release proof)
  - `CODEX-OS-GOVERNANCE-FULL-AUTONOMY-INTEGRATION-01` — `prompts/batches/CODEX-OS-GOVERNANCE-FULL-AUTONOMY-INTEGRATION-01.md` (partial_implementation; release proof)

### 180. Same source file targeted by multiple active items: scripts/ambitions-historical-baseline-train-guard.py

- Conflict ID: `AMB28-same_source_file_targeted_by_multiple_active_batches-93809881`
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

### 181. Same source file targeted by multiple active items: scripts/ambitions-local-first-boundary-scan.py

- Conflict ID: `AMB28-same_source_file_targeted_by_multiple_active_batches-87716319`
- Type: `same_source_file_targeted_by_multiple_active_batches`
- Severity: `yellow`
- Recommended action: `merge`
- Rationale: Multiple active ledger items reference the same source file; merge, sequence, or assign ownership before implementation.
- Linear issue ready: `True`
- Auto-resolved: `False`
- Involved:
  - `GLOBAL-BATCH-TRAIN-AUTONOMOUS-COMPLETE-01` — `prompts/batches/GLOBAL-BATCH-TRAIN-AUTONOMOUS-COMPLETE-01.md` (partial_implementation; release proof)
  - `GLOBAL-VISUAL-CANON-MOAT-INSTALL-TRAIN-01` — `prompts/batches/GLOBAL-VISUAL-CANON-MOAT-INSTALL-TRAIN-01.md` (partial_implementation; release proof)
  - `MOAT-ALIGNMENT-01` — `prompts/batches/MOAT-ALIGNMENT-01.md` (partial_implementation; release proof)
  - `MOAT-COMPLETE-AUTONOMOUS-01` — `prompts/batches/MOAT-COMPLETE-AUTONOMOUS-01.md` (partial_implementation; release proof)
  - `VISUAL-CANON-MOAT-01` — `prompts/batches/VISUAL-CANON-MOAT-01.md` (partial_implementation; release proof)

### 182. Same source file targeted by multiple active items: scripts/ambitions-moat-drift-scan.py

- Conflict ID: `AMB28-same_source_file_targeted_by_multiple_active_batches-5843157`
- Type: `same_source_file_targeted_by_multiple_active_batches`
- Severity: `yellow`
- Recommended action: `merge`
- Rationale: Multiple active ledger items reference the same source file; merge, sequence, or assign ownership before implementation.
- Linear issue ready: `True`
- Auto-resolved: `False`
- Involved:
  - `GLOBAL-BATCH-TRAIN-AUTONOMOUS-COMPLETE-01` — `prompts/batches/GLOBAL-BATCH-TRAIN-AUTONOMOUS-COMPLETE-01.md` (partial_implementation; release proof)
  - `GLOBAL-VISUAL-CANON-MOAT-INSTALL-TRAIN-01` — `prompts/batches/GLOBAL-VISUAL-CANON-MOAT-INSTALL-TRAIN-01.md` (partial_implementation; release proof)
  - `MOAT-ALIGNMENT-01` — `prompts/batches/MOAT-ALIGNMENT-01.md` (partial_implementation; release proof)
  - `MOAT-COMPLETE-AUTONOMOUS-01` — `prompts/batches/MOAT-COMPLETE-AUTONOMOUS-01.md` (partial_implementation; release proof)
  - `VISUAL-CANON-MOAT-01` — `prompts/batches/VISUAL-CANON-MOAT-01.md` (partial_implementation; release proof)
  - `AMB-REPO-AUTHORITY-06-ACTIVE-DRIFT-REPAIR` — `prompts/batches/AMB-REPO-AUTHORITY-06-ACTIVE-DRIFT-REPAIR.md` (partial_implementation; release proof)
  - `AMB-REPO-AUTHORITY-07-GATES-FINAL-PROOF` — `prompts/batches/AMB-REPO-AUTHORITY-07-GATES-FINAL-PROOF.md` (partial_implementation; release proof)

### 183. Same source file targeted by multiple active items: scripts/ambitions-mri-materialize-prompts.py

- Conflict ID: `AMB28-same_source_file_targeted_by_multiple_active_batches-99092786`
- Type: `same_source_file_targeted_by_multiple_active_batches`
- Severity: `yellow`
- Recommended action: `merge`
- Rationale: Multiple active ledger items reference the same source file; merge, sequence, or assign ownership before implementation.
- Linear issue ready: `True`
- Auto-resolved: `False`
- Involved:
  - `MRI00-MOAT-RUNTIME-GAP-LOCK` — `prompts/batches/MRI00-MOAT-RUNTIME-GAP-LOCK.md` (partial_implementation; release proof)
  - `FRONTEND-SURFACE-RECIPE-COMPLETENESS-REVIEW-001` — `prompts/batches/FRONTEND-SURFACE-RECIPE-COMPLETENESS-REVIEW-001.md` (partial_implementation; release proof)

### 184. Same source file targeted by multiple active items: scripts/ambitions-next-batch-router.py

- Conflict ID: `AMB28-same_source_file_targeted_by_multiple_active_batches-61140987`
- Type: `same_source_file_targeted_by_multiple_active_batches`
- Severity: `yellow`
- Recommended action: `merge`
- Rationale: Multiple active ledger items reference the same source file; merge, sequence, or assign ownership before implementation.
- Linear issue ready: `True`
- Auto-resolved: `False`
- Involved:
  - `AUTONOMOUS_TRAIN_FASTPATH` — `docs/codex/AUTONOMOUS_TRAIN_FASTPATH.md` (partial_implementation; release proof)
  - `AUTONOMOUS-TRAIN-FASTPATH-01` — `prompts/batches/AUTONOMOUS-TRAIN-FASTPATH-01.md` (partial_implementation; release proof)

### 185. Same source file targeted by multiple active items: scripts/ambitions-parallel-implementation-guard.py

- Conflict ID: `AMB28-same_source_file_targeted_by_multiple_active_batches-26224126`
- Type: `same_source_file_targeted_by_multiple_active_batches`
- Severity: `yellow`
- Recommended action: `merge`
- Rationale: Multiple active ledger items reference the same source file; merge, sequence, or assign ownership before implementation.
- Linear issue ready: `True`
- Auto-resolved: `False`
- Involved:
  - `AMB-INTELLIGENCE-CONSOLIDATION-CHAMPION-MERGE-PLAN-02` — `prompts/batches/AMB-INTELLIGENCE-CONSOLIDATION-CHAMPION-MERGE-PLAN-02.md` (partial_implementation; release proof)
  - `AMB-INTELLIGENCE-CONSOLIDATION-CHAMPION-SELECTION-01` — `prompts/batches/AMB-INTELLIGENCE-CONSOLIDATION-CHAMPION-SELECTION-01.md` (partial_implementation; release proof)

### 186. Same source file targeted by multiple active items: scripts/ambitions-post-pk-speed-train.sh

- Conflict ID: `AMB28-same_source_file_targeted_by_multiple_active_batches-79183457`
- Type: `same_source_file_targeted_by_multiple_active_batches`
- Severity: `yellow`
- Recommended action: `merge`
- Rationale: Multiple active ledger items reference the same source file; merge, sequence, or assign ownership before implementation.
- Linear issue ready: `True`
- Auto-resolved: `False`
- Involved:
  - `MOAT_RUNTIME_AUTONOMOUS_ROUTING_POLICY` — `docs/codex/MOAT_RUNTIME_AUTONOMOUS_ROUTING_POLICY.md` (unknown; release proof)
  - `POST_PK_SPEED_TRAIN_OPERATING_MODEL` — `docs/codex/POST_PK_SPEED_TRAIN_OPERATING_MODEL.md` (unknown; release proof)

### 187. Same source file targeted by multiple active items: scripts/ambitions-prompt-audit.sh

- Conflict ID: `AMB28-same_source_file_targeted_by_multiple_active_batches-27756224`
- Type: `same_source_file_targeted_by_multiple_active_batches`
- Severity: `yellow`
- Recommended action: `merge`
- Rationale: Multiple active ledger items reference the same source file; merge, sequence, or assign ownership before implementation.
- Linear issue ready: `True`
- Auto-resolved: `False`
- Involved:
  - `RHC01` — `prompts/batches/RHC01.md` (partial_implementation; release proof)
  - `CODEX-RUNNER-READ-ONLY-AUDIT-MODE-01` — `prompts/batches/CODEX-RUNNER-READ-ONLY-AUDIT-MODE-01.md` (partial_implementation; release proof)

### 188. Same source file targeted by multiple active items: scripts/ambitions-prompt-queue-consistency.py

- Conflict ID: `AMB28-same_source_file_targeted_by_multiple_active_batches-81554362`
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

### 189. Same source file targeted by multiple active items: scripts/ambitions-queue-snapshot.py

- Conflict ID: `AMB28-same_source_file_targeted_by_multiple_active_batches-1350962`
- Type: `same_source_file_targeted_by_multiple_active_batches`
- Severity: `yellow`
- Recommended action: `merge`
- Rationale: Multiple active ledger items reference the same source file; merge, sequence, or assign ownership before implementation.
- Linear issue ready: `True`
- Auto-resolved: `False`
- Involved:
  - `AMB_CONTROL_PLANE_DIRECT_RUNBOOK` — `docs/codex/AMB_CONTROL_PLANE_DIRECT_RUNBOOK.md` (partial_implementation; release proof)
  - `AMB_CONTROL_PLANE_GATE_INDEX` — `docs/codex/AMB_CONTROL_PLANE_GATE_INDEX.md` (partial_implementation; release proof)
  - `MOAT-ALIGNMENT-01` — `prompts/batches/MOAT-ALIGNMENT-01.md` (partial_implementation; release proof)
  - `HBI-GLOBAL-TRAIN-HANDOFF-01` — `prompts/batches/HBI-GLOBAL-TRAIN-HANDOFF-01.md` (partial_implementation; release proof)

### 190. Same source file targeted by multiple active items: scripts/ambitions-repo-authority-validate.py

- Conflict ID: `AMB28-same_source_file_targeted_by_multiple_active_batches-90731231`
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

### 191. Same source file targeted by multiple active items: scripts/ambitions-signature-object-gate.py

- Conflict ID: `AMB28-same_source_file_targeted_by_multiple_active_batches-67473140`
- Type: `same_source_file_targeted_by_multiple_active_batches`
- Severity: `yellow`
- Recommended action: `merge`
- Rationale: Multiple active ledger items reference the same source file; merge, sequence, or assign ownership before implementation.
- Linear issue ready: `True`
- Auto-resolved: `False`
- Involved:
  - `GLOBAL-BATCH-TRAIN-AUTONOMOUS-COMPLETE-01` — `prompts/batches/GLOBAL-BATCH-TRAIN-AUTONOMOUS-COMPLETE-01.md` (partial_implementation; release proof)
  - `GLOBAL-VISUAL-CANON-MOAT-INSTALL-TRAIN-01` — `prompts/batches/GLOBAL-VISUAL-CANON-MOAT-INSTALL-TRAIN-01.md` (partial_implementation; release proof)
  - `MOAT-ALIGNMENT-01` — `prompts/batches/MOAT-ALIGNMENT-01.md` (partial_implementation; release proof)
  - `MOAT-COMPLETE-AUTONOMOUS-01` — `prompts/batches/MOAT-COMPLETE-AUTONOMOUS-01.md` (partial_implementation; release proof)
  - `VISUAL-CANON-MOAT-01` — `prompts/batches/VISUAL-CANON-MOAT-01.md` (partial_implementation; release proof)

### 192. Same source file targeted by multiple active items: scripts/ambitions-source-atlas-title-check.py

- Conflict ID: `AMB28-same_source_file_targeted_by_multiple_active_batches-46654715`
- Type: `same_source_file_targeted_by_multiple_active_batches`
- Severity: `yellow`
- Recommended action: `merge`
- Rationale: Multiple active ledger items reference the same source file; merge, sequence, or assign ownership before implementation.
- Linear issue ready: `True`
- Auto-resolved: `False`
- Involved:
  - `AMB_CONTROL_PLANE_DIRECT_RUNBOOK` — `docs/codex/AMB_CONTROL_PLANE_DIRECT_RUNBOOK.md` (partial_implementation; release proof)
  - `AMB_CONTROL_PLANE_GATE_INDEX` — `docs/codex/AMB_CONTROL_PLANE_GATE_INDEX.md` (partial_implementation; release proof)
  - `MOAT-ALIGNMENT-01` — `prompts/batches/MOAT-ALIGNMENT-01.md` (partial_implementation; release proof)
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
  - ... 6 more

### 193. Same source file targeted by multiple active items: scripts/ambitions-speed-train.sh

- Conflict ID: `AMB28-same_source_file_targeted_by_multiple_active_batches-7699744`
- Type: `same_source_file_targeted_by_multiple_active_batches`
- Severity: `yellow`
- Recommended action: `merge`
- Rationale: Multiple active ledger items reference the same source file; merge, sequence, or assign ownership before implementation.
- Linear issue ready: `True`
- Auto-resolved: `False`
- Involved:
  - `ambitions-hybrid-runner` — `docs/codex/ambitions-hybrid-runner.md` (partial_implementation; release proof)
  - `XCODE-PERF-RUNNER-MATURITY-01` — `prompts/batches/XCODE-PERF-RUNNER-MATURITY-01.md` (partial_implementation; release proof)

### 194. Same source file targeted by multiple active items: scripts/ambitions-state-advance-validate.py

- Conflict ID: `AMB28-same_source_file_targeted_by_multiple_active_batches-24109853`
- Type: `same_source_file_targeted_by_multiple_active_batches`
- Severity: `yellow`
- Recommended action: `merge`
- Rationale: Multiple active ledger items reference the same source file; merge, sequence, or assign ownership before implementation.
- Linear issue ready: `True`
- Auto-resolved: `False`
- Involved:
  - `POST_PK_CLOSEOUT_CONTRACT` — `docs/codex/POST_PK_CLOSEOUT_CONTRACT.md` (partial_implementation; release proof)
  - `POST_PK_SPEED_TRAIN_OPERATING_MODEL` — `docs/codex/POST_PK_SPEED_TRAIN_OPERATING_MODEL.md` (unknown; release proof)

### 195. Same source file targeted by multiple active items: scripts/ambitions-surface-recipe-coverage-check.py

- Conflict ID: `AMB28-same_source_file_targeted_by_multiple_active_batches-84471632`
- Type: `same_source_file_targeted_by_multiple_active_batches`
- Severity: `yellow`
- Recommended action: `merge`
- Rationale: Multiple active ledger items reference the same source file; merge, sequence, or assign ownership before implementation.
- Linear issue ready: `True`
- Auto-resolved: `False`
- Involved:
  - `FRONTEND-SURFACE-RECIPE-COMPLETENESS-REVIEW-001` — `prompts/batches/FRONTEND-SURFACE-RECIPE-COMPLETENESS-REVIEW-001.md` (partial_implementation; release proof)
  - `VISUAL-ENCYCLOPEDIA-100-PROOF-HARDENING-03` — `prompts/batches/VISUAL-ENCYCLOPEDIA-100-PROOF-HARDENING-03.md` (partial_implementation; release proof)

### 196. Same source file targeted by multiple active items: scripts/ambitions-surface-recipe-inventory-check.py

- Conflict ID: `AMB28-same_source_file_targeted_by_multiple_active_batches-43923252`
- Type: `same_source_file_targeted_by_multiple_active_batches`
- Severity: `yellow`
- Recommended action: `merge`
- Rationale: Multiple active ledger items reference the same source file; merge, sequence, or assign ownership before implementation.
- Linear issue ready: `True`
- Auto-resolved: `False`
- Involved:
  - `FRONTEND-SURFACE-RECIPE-COMPLETENESS-REVIEW-001` — `prompts/batches/FRONTEND-SURFACE-RECIPE-COMPLETENESS-REVIEW-001.md` (partial_implementation; release proof)
  - `VISUAL-ENCYCLOPEDIA-100-PROOF-HARDENING-03` — `prompts/batches/VISUAL-ENCYCLOPEDIA-100-PROOF-HARDENING-03.md` (partial_implementation; release proof)
  - `CHROME-AUDIT-01` — `prompts/batches/CHROME-AUDIT-01.md` (partial_implementation; release proof)

### 197. Same source file targeted by multiple active items: scripts/ambitions-swift6-modernization-scan.py

- Conflict ID: `AMB28-same_source_file_targeted_by_multiple_active_batches-38999459`
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

### 198. Same source file targeted by multiple active items: scripts/ambitions-throughput-plan.sh

- Conflict ID: `AMB28-same_source_file_targeted_by_multiple_active_batches-11797012`
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

### 199. Same source file targeted by multiple active items: scripts/ambitions-unsupported-claim-scan.py

- Conflict ID: `AMB28-same_source_file_targeted_by_multiple_active_batches-87239827`
- Type: `same_source_file_targeted_by_multiple_active_batches`
- Severity: `yellow`
- Recommended action: `merge`
- Rationale: Multiple active ledger items reference the same source file; merge, sequence, or assign ownership before implementation.
- Linear issue ready: `True`
- Auto-resolved: `False`
- Involved:
  - `MRI00-MOAT-RUNTIME-GAP-LOCK` — `prompts/batches/MRI00-MOAT-RUNTIME-GAP-LOCK.md` (partial_implementation; release proof)
  - `OBJECT-OS-CANON-01` — `prompts/batches/OBJECT-OS-CANON-01.md` (partial_implementation; release proof)
  - `OBS00-OPENAI-BUILD-SUITE-INSTALL` — `prompts/batches/OBS00-OPENAI-BUILD-SUITE-INSTALL.md` (partial_implementation; release proof)
  - `SPEED_TRAIN_LANE_POLICY` — `docs/codex/SPEED_TRAIN_LANE_POLICY.json` (unknown; release proof)

### 200. Same source file targeted by multiple active items: scripts/ambitions-visual-100-accessibility-adhd-check.py

- Conflict ID: `AMB28-same_source_file_targeted_by_multiple_active_batches-53949085`
- Type: `same_source_file_targeted_by_multiple_active_batches`
- Severity: `yellow`
- Recommended action: `merge`
- Rationale: Multiple active ledger items reference the same source file; merge, sequence, or assign ownership before implementation.
- Linear issue ready: `True`
- Auto-resolved: `False`
- Involved:
  - `VISUAL-ENCYCLOPEDIA-100-PROOF-HARDENING-03` — `prompts/batches/VISUAL-ENCYCLOPEDIA-100-PROOF-HARDENING-03.md` (partial_implementation; release proof)
  - `AMB-FLAGSHIP-UI-CODEX-STUDIO-INSTALL-01` — `docs/codex/reports/AMB-FLAGSHIP-UI-CODEX-STUDIO-INSTALL-01.md` (partial_implementation; release proof)

### 201. Same source file targeted by multiple active items: scripts/ambitions-visual-100-anti-generic-check.py

- Conflict ID: `AMB28-same_source_file_targeted_by_multiple_active_batches-87676223`
- Type: `same_source_file_targeted_by_multiple_active_batches`
- Severity: `yellow`
- Recommended action: `merge`
- Rationale: Multiple active ledger items reference the same source file; merge, sequence, or assign ownership before implementation.
- Linear issue ready: `True`
- Auto-resolved: `False`
- Involved:
  - `VISUAL-ENCYCLOPEDIA-100-PROOF-HARDENING-03` — `prompts/batches/VISUAL-ENCYCLOPEDIA-100-PROOF-HARDENING-03.md` (partial_implementation; release proof)
  - `FLAGSHIP-OBJECT-SYSTEM-01` — `prompts/batches/FLAGSHIP-OBJECT-SYSTEM-01.md` (partial_implementation; release proof)
  - `AMB-FLAGSHIP-UI-CODEX-STUDIO-INSTALL-01` — `docs/codex/reports/AMB-FLAGSHIP-UI-CODEX-STUDIO-INSTALL-01.md` (partial_implementation; release proof)

### 202. Same source file targeted by multiple active items: scripts/ambitions-visual-100-gate-check.py

- Conflict ID: `AMB28-same_source_file_targeted_by_multiple_active_batches-74259102`
- Type: `same_source_file_targeted_by_multiple_active_batches`
- Severity: `yellow`
- Recommended action: `merge`
- Rationale: Multiple active ledger items reference the same source file; merge, sequence, or assign ownership before implementation.
- Linear issue ready: `True`
- Auto-resolved: `False`
- Involved:
  - `VISUAL-ENCYCLOPEDIA-100-PROOF-HARDENING-03` — `prompts/batches/VISUAL-ENCYCLOPEDIA-100-PROOF-HARDENING-03.md` (partial_implementation; release proof)
  - `AMB-FLAGSHIP-UI-CODEX-STUDIO-INSTALL-01` — `docs/codex/reports/AMB-FLAGSHIP-UI-CODEX-STUDIO-INSTALL-01.md` (partial_implementation; release proof)

### 203. Same source file targeted by multiple active items: scripts/ambitions-visual-100-object-depth-check.py

- Conflict ID: `AMB28-same_source_file_targeted_by_multiple_active_batches-25523626`
- Type: `same_source_file_targeted_by_multiple_active_batches`
- Severity: `yellow`
- Recommended action: `merge`
- Rationale: Multiple active ledger items reference the same source file; merge, sequence, or assign ownership before implementation.
- Linear issue ready: `True`
- Auto-resolved: `False`
- Involved:
  - `VISUAL-ENCYCLOPEDIA-100-PROOF-HARDENING-03` — `prompts/batches/VISUAL-ENCYCLOPEDIA-100-PROOF-HARDENING-03.md` (partial_implementation; release proof)
  - `FLAGSHIP-OBJECT-SYSTEM-01` — `prompts/batches/FLAGSHIP-OBJECT-SYSTEM-01.md` (partial_implementation; release proof)

### 204. Same source file targeted by multiple active items: scripts/ambitions-vocabulary-drift-scan.py

- Conflict ID: `AMB28-same_source_file_targeted_by_multiple_active_batches-62868623`
- Type: `same_source_file_targeted_by_multiple_active_batches`
- Severity: `yellow`
- Recommended action: `merge`
- Rationale: Multiple active ledger items reference the same source file; merge, sequence, or assign ownership before implementation.
- Linear issue ready: `True`
- Auto-resolved: `False`
- Involved:
  - `GLOBAL-BATCH-TRAIN-AUTONOMOUS-COMPLETE-01` — `prompts/batches/GLOBAL-BATCH-TRAIN-AUTONOMOUS-COMPLETE-01.md` (partial_implementation; release proof)
  - `GLOBAL-VISUAL-CANON-MOAT-INSTALL-TRAIN-01` — `prompts/batches/GLOBAL-VISUAL-CANON-MOAT-INSTALL-TRAIN-01.md` (partial_implementation; release proof)
  - `MOAT-ALIGNMENT-01` — `prompts/batches/MOAT-ALIGNMENT-01.md` (partial_implementation; release proof)
  - `MOAT-COMPLETE-AUTONOMOUS-01` — `prompts/batches/MOAT-COMPLETE-AUTONOMOUS-01.md` (partial_implementation; release proof)
  - `VISUAL-CANON-MOAT-01` — `prompts/batches/VISUAL-CANON-MOAT-01.md` (partial_implementation; release proof)
  - `AMB-REPO-AUTHORITY-06-ACTIVE-DRIFT-REPAIR` — `prompts/batches/AMB-REPO-AUTHORITY-06-ACTIVE-DRIFT-REPAIR.md` (partial_implementation; release proof)
  - `AMB-REPO-AUTHORITY-07-GATES-FINAL-PROOF` — `prompts/batches/AMB-REPO-AUTHORITY-07-GATES-FINAL-PROOF.md` (partial_implementation; release proof)
  - `TOP-LEVEL-IA-PLAN-LEAK-REGRESSION-01` — `prompts/batches/TOP-LEVEL-IA-PLAN-LEAK-REGRESSION-01.md` (partial_implementation; release proof)

### 205. Same source file targeted by multiple active items: scripts/ambitions-xcode-benchmark.sh

- Conflict ID: `AMB28-same_source_file_targeted_by_multiple_active_batches-90109444`
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

### 206. Same source file targeted by multiple active items: scripts/ambitions-xcode-build-for-testing.sh

- Conflict ID: `AMB28-same_source_file_targeted_by_multiple_active_batches-87399844`
- Type: `same_source_file_targeted_by_multiple_active_batches`
- Severity: `yellow`
- Recommended action: `merge`
- Rationale: Multiple active ledger items reference the same source file; merge, sequence, or assign ownership before implementation.
- Linear issue ready: `True`
- Auto-resolved: `False`
- Involved:
  - `XCODE-BUILD-SYSTEM-MAX-01-REPAIR-01` — `prompts/batches/XCODE-BUILD-SYSTEM-MAX-01-REPAIR-01.md` (partial_implementation; release proof)
  - `XCODE-PERF-RUNNER-MATURITY-01` — `prompts/batches/XCODE-PERF-RUNNER-MATURITY-01.md` (partial_implementation; release proof)

### 207. Same source file targeted by multiple active items: scripts/ambitions-xcode-sim-health.sh

- Conflict ID: `AMB28-same_source_file_targeted_by_multiple_active_batches-66021487`
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

### 208. Same source file targeted by multiple active items: scripts/ambitions-xcode-test-focused.sh

- Conflict ID: `AMB28-same_source_file_targeted_by_multiple_active_batches-24456535`
- Type: `same_source_file_targeted_by_multiple_active_batches`
- Severity: `yellow`
- Recommended action: `merge`
- Rationale: Multiple active ledger items reference the same source file; merge, sequence, or assign ownership before implementation.
- Linear issue ready: `True`
- Auto-resolved: `False`
- Involved:
  - `XCODE-BUILD-SYSTEM-MAX-01-REPAIR-01` — `prompts/batches/XCODE-BUILD-SYSTEM-MAX-01-REPAIR-01.md` (partial_implementation; release proof)
  - `XCODE-PERF-RUNNER-MATURITY-01` — `prompts/batches/XCODE-PERF-RUNNER-MATURITY-01.md` (partial_implementation; release proof)

### 209. Same source file targeted by multiple active items: scripts/ambitions-xcode-test-plan.sh

- Conflict ID: `AMB28-same_source_file_targeted_by_multiple_active_batches-27329804`
- Type: `same_source_file_targeted_by_multiple_active_batches`
- Severity: `yellow`
- Recommended action: `merge`
- Rationale: Multiple active ledger items reference the same source file; merge, sequence, or assign ownership before implementation.
- Linear issue ready: `True`
- Auto-resolved: `False`
- Involved:
  - `XCODE-BUILD-SYSTEM-MAX-01-REPAIR-01` — `prompts/batches/XCODE-BUILD-SYSTEM-MAX-01-REPAIR-01.md` (partial_implementation; release proof)
  - `XCODE-PERF-RUNNER-MATURITY-01` — `prompts/batches/XCODE-PERF-RUNNER-MATURITY-01.md` (partial_implementation; release proof)

### 210. Same source file targeted by multiple active items: scripts/ambitions-xcode-validate.sh

- Conflict ID: `AMB28-same_source_file_targeted_by_multiple_active_batches-25147666`
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

### 211. Same source file targeted by multiple active items: scripts/ambitions_codex_os_validate.py

- Conflict ID: `AMB28-same_source_file_targeted_by_multiple_active_batches-11451796`
- Type: `same_source_file_targeted_by_multiple_active_batches`
- Severity: `yellow`
- Recommended action: `merge`
- Rationale: Multiple active ledger items reference the same source file; merge, sequence, or assign ownership before implementation.
- Linear issue ready: `True`
- Auto-resolved: `False`
- Involved:
  - `AMB-FILE-BY-FILE-REPO-AUDIT-01` — `prompts/batches/AMB-FILE-BY-FILE-REPO-AUDIT-01.md` (partial_implementation; release proof)
  - `AMB-REPO-GREEN-FLAGSHIP-RESET-MASTER-01` — `prompts/batches/AMB-REPO-GREEN-FLAGSHIP-RESET-MASTER-01.md` (partial_implementation; release proof)

### 212. Same source file targeted by multiple active items: scripts/ambitions_validate_batch_ids.py

- Conflict ID: `AMB28-same_source_file_targeted_by_multiple_active_batches-81952898`
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

### 213. Same source file targeted by multiple active items: scripts/ambitions_validate_prompt_headers.py

- Conflict ID: `AMB28-same_source_file_targeted_by_multiple_active_batches-35842317`
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

### 214. Same source file targeted by multiple active items: scripts/ambitions_validate_visual_proof.py

- Conflict ID: `AMB28-same_source_file_targeted_by_multiple_active_batches-14805951`
- Type: `same_source_file_targeted_by_multiple_active_batches`
- Severity: `yellow`
- Recommended action: `merge`
- Rationale: Multiple active ledger items reference the same source file; merge, sequence, or assign ownership before implementation.
- Linear issue ready: `True`
- Auto-resolved: `False`
- Involved:
  - `POST_BATCH_GATE_REGISTRY` — `docs/codex/POST_BATCH_GATE_REGISTRY.md` (partial_implementation; release proof)
  - `AMB_CODEX_GOVERNANCE_SPEC` — `docs/codex/AMB_CODEX_GOVERNANCE_SPEC.md` (partial_implementation; release proof)

### 215. Same source file targeted by multiple active items: scripts/aqos-run-all-advisory.sh

- Conflict ID: `AMB28-same_source_file_targeted_by_multiple_active_batches-29087703`
- Type: `same_source_file_targeted_by_multiple_active_batches`
- Severity: `yellow`
- Recommended action: `merge`
- Rationale: Multiple active ledger items reference the same source file; merge, sequence, or assign ownership before implementation.
- Linear issue ready: `True`
- Auto-resolved: `False`
- Involved:
  - `AQOS_TOOLS_SKILLS_AND_SCRIPTS_PROMPT` — `docs/codex/batches/AQOS_TOOLS_SKILLS_AND_SCRIPTS_PROMPT.md` (partial_implementation; release proof)
  - `AQOS_SCRIPT_AND_TOOL_MAP` — `docs/codex/quality/AQOS_SCRIPT_AND_TOOL_MAP.md` (partial_implementation; release proof)

### 216. Same source file targeted by multiple active items: scripts/batch-train-gate-check.sh

- Conflict ID: `AMB28-same_source_file_targeted_by_multiple_active_batches-22647572`
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
  - `AOS01_AmbitionsOS_Canon_And_Runtime_Contract_Prompt` — `docs/codex/batches/AOS01_AmbitionsOS_Canon_And_Runtime_Contract_Prompt.md` (partial_implementation; release proof)
  - `AOS02_Life_Graph_Event_Log_Foundation_Prompt` — `docs/codex/batches/AOS02_Life_Graph_Event_Log_Foundation_Prompt.md` (partial_implementation; release proof)
  - `AOS03_Graph_Delta_Review_Projection_Store_Prompt` — `docs/codex/batches/AOS03_Graph_Delta_Review_Projection_Store_Prompt.md` (partial_implementation; release proof)
  - `AOS04_Control_Plane_Work_Classifier_Prompt` — `docs/codex/batches/AOS04_Control_Plane_Work_Classifier_Prompt.md` (partial_implementation; release proof)
  - `AOS05_Starting_Position_Kernel_Prompt` — `docs/codex/batches/AOS05_Starting_Position_Kernel_Prompt.md` (partial_implementation; release proof)
  - `AOS06_Goal_Path_Kernel_Goal_Compiler_Prompt` — `docs/codex/batches/AOS06_Goal_Path_Kernel_Goal_Compiler_Prompt.md` (partial_implementation; release proof)
  - `AOS07_Local_Goal_Packs_Requirement_Slots_Prompt` — `docs/codex/batches/AOS07_Local_Goal_Packs_Requirement_Slots_Prompt.md` (partial_implementation; release proof)
  - `AOS08_Alternate_Path_Kernel_Path_Portfolio_Prompt` — `docs/codex/batches/AOS08_Alternate_Path_Kernel_Path_Portfolio_Prompt.md` (partial_implementation; release proof)
  - `AOS09_Option_Value_North_Star_Prompt` — `docs/codex/batches/AOS09_Option_Value_North_Star_Prompt.md` (partial_implementation; release proof)
  - `AOS10_Commitment_Time_Kernel_Prompt` — `docs/codex/batches/AOS10_Commitment_Time_Kernel_Prompt.md` (partial_implementation; release proof)
  - `AOS11_Reality_Drift_Bounded_Reflow_Prompt` — `docs/codex/batches/AOS11_Reality_Drift_Bounded_Reflow_Prompt.md` (partial_implementation; release proof)
  - `AOS12_Proof_Trust_Closure_Receipts_Prompt` — `docs/codex/batches/AOS12_Proof_Trust_Closure_Receipts_Prompt.md` (partial_implementation; release proof)
  - `AOS13_Source_Truth_Claim_State_Machine_Prompt` — `docs/codex/batches/AOS13_Source_Truth_Claim_State_Machine_Prompt.md` (partial_implementation; release proof)
  - `AOS14_Recommendation_Start_Here_Kernel_Prompt` — `docs/codex/batches/AOS14_Recommendation_Start_Here_Kernel_Prompt.md` (partial_implementation; release proof)
  - `AOS15_Local_Language_Kernel_Planning_Prompt` — `docs/codex/batches/AOS15_Local_Language_Kernel_Planning_Prompt.md` (partial_implementation; release proof)
  - `AOS16_Performance_Energy_Kernel_Prompt` — `docs/codex/batches/AOS16_Performance_Energy_Kernel_Prompt.md` (partial_implementation; release proof)
  - `AOS17_Privacy_Safety_Kernel_Prompt` — `docs/codex/batches/AOS17_Privacy_Safety_Kernel_Prompt.md` (partial_implementation; release proof)
  - `AOS18_Evaluation_Golden_Scenarios_Prompt` — `docs/codex/batches/AOS18_Evaluation_Golden_Scenarios_Prompt.md` (partial_implementation; release proof)
  - `AOS19_Experience_Kernel_Celestial_Cognitive_Load_Prompt` — `docs/codex/batches/AOS19_Experience_Kernel_Celestial_Cognitive_Load_Prompt.md` (partial_implementation; release proof)
  - `AOS20_Adaptation_Kernel_Local_Personalization_Prompt` — `docs/codex/batches/AOS20_Adaptation_Kernel_Local_Personalization_Prompt.md` (partial_implementation; release proof)
  - `AOS21_Interoperability_Kernel_App_Intents_EventKit_Planning_Prompt` — `docs/codex/batches/AOS21_Interoperability_Kernel_App_Intents_EventKit_Planning_Prompt.md` (partial_implementation; release proof)
  - `AOS22_Longevity_Kernel_Archive_Aging_Prompt` — `docs/codex/batches/AOS22_Longevity_Kernel_Archive_Aging_Prompt.md` (partial_implementation; release proof)
  - `AOS23_Governance_Kernel_Registry_Prompt` — `docs/codex/batches/AOS23_Governance_Kernel_Registry_Prompt.md` (partial_implementation; release proof)
  - `AOS24_AmbitionsOS_UI_Integration_Prompt` — `docs/codex/batches/AOS24_AmbitionsOS_UI_Integration_Prompt.md` (partial_implementation; release proof)
  - `AOS25_AmbitionsOS_Test_Fixture_Library_Prompt` — `docs/codex/batches/AOS25_AmbitionsOS_Test_Fixture_Library_Prompt.md` (partial_implementation; release proof)
  - `AOS26_AmbitionsOS_Privacy_Performance_QA_Prompt` — `docs/codex/batches/AOS26_AmbitionsOS_Privacy_Performance_QA_Prompt.md` (partial_implementation; release proof)
  - `AOS27_AmbitionsOS_App_Store_Claim_Truth_Prompt` — `docs/codex/batches/AOS27_AmbitionsOS_App_Store_Claim_Truth_Prompt.md` (partial_implementation; release proof)
  - ... 164 more

### 217. Same source file targeted by multiple active items: scripts/build-local.sh

- Conflict ID: `AMB28-same_source_file_targeted_by_multiple_active_batches-83544260`
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
  - `AOS01_AmbitionsOS_Canon_And_Runtime_Contract_Prompt` — `docs/codex/batches/AOS01_AmbitionsOS_Canon_And_Runtime_Contract_Prompt.md` (partial_implementation; release proof)
  - `AOS02_Life_Graph_Event_Log_Foundation_Prompt` — `docs/codex/batches/AOS02_Life_Graph_Event_Log_Foundation_Prompt.md` (partial_implementation; release proof)
  - `AOS03_Graph_Delta_Review_Projection_Store_Prompt` — `docs/codex/batches/AOS03_Graph_Delta_Review_Projection_Store_Prompt.md` (partial_implementation; release proof)
  - `AOS04_Control_Plane_Work_Classifier_Prompt` — `docs/codex/batches/AOS04_Control_Plane_Work_Classifier_Prompt.md` (partial_implementation; release proof)
  - `AOS05_Starting_Position_Kernel_Prompt` — `docs/codex/batches/AOS05_Starting_Position_Kernel_Prompt.md` (partial_implementation; release proof)
  - `AOS06_Goal_Path_Kernel_Goal_Compiler_Prompt` — `docs/codex/batches/AOS06_Goal_Path_Kernel_Goal_Compiler_Prompt.md` (partial_implementation; release proof)
  - `AOS07_Local_Goal_Packs_Requirement_Slots_Prompt` — `docs/codex/batches/AOS07_Local_Goal_Packs_Requirement_Slots_Prompt.md` (partial_implementation; release proof)
  - `AOS08_Alternate_Path_Kernel_Path_Portfolio_Prompt` — `docs/codex/batches/AOS08_Alternate_Path_Kernel_Path_Portfolio_Prompt.md` (partial_implementation; release proof)
  - `AOS09_Option_Value_North_Star_Prompt` — `docs/codex/batches/AOS09_Option_Value_North_Star_Prompt.md` (partial_implementation; release proof)
  - `AOS10_Commitment_Time_Kernel_Prompt` — `docs/codex/batches/AOS10_Commitment_Time_Kernel_Prompt.md` (partial_implementation; release proof)
  - `AOS11_Reality_Drift_Bounded_Reflow_Prompt` — `docs/codex/batches/AOS11_Reality_Drift_Bounded_Reflow_Prompt.md` (partial_implementation; release proof)
  - `AOS12_Proof_Trust_Closure_Receipts_Prompt` — `docs/codex/batches/AOS12_Proof_Trust_Closure_Receipts_Prompt.md` (partial_implementation; release proof)
  - `AOS13_Source_Truth_Claim_State_Machine_Prompt` — `docs/codex/batches/AOS13_Source_Truth_Claim_State_Machine_Prompt.md` (partial_implementation; release proof)
  - `AOS14_Recommendation_Start_Here_Kernel_Prompt` — `docs/codex/batches/AOS14_Recommendation_Start_Here_Kernel_Prompt.md` (partial_implementation; release proof)
  - `AOS15_Local_Language_Kernel_Planning_Prompt` — `docs/codex/batches/AOS15_Local_Language_Kernel_Planning_Prompt.md` (partial_implementation; release proof)
  - `AOS16_Performance_Energy_Kernel_Prompt` — `docs/codex/batches/AOS16_Performance_Energy_Kernel_Prompt.md` (partial_implementation; release proof)
  - `AOS17_Privacy_Safety_Kernel_Prompt` — `docs/codex/batches/AOS17_Privacy_Safety_Kernel_Prompt.md` (partial_implementation; release proof)
  - `AOS18_Evaluation_Golden_Scenarios_Prompt` — `docs/codex/batches/AOS18_Evaluation_Golden_Scenarios_Prompt.md` (partial_implementation; release proof)
  - `AOS19_Experience_Kernel_Celestial_Cognitive_Load_Prompt` — `docs/codex/batches/AOS19_Experience_Kernel_Celestial_Cognitive_Load_Prompt.md` (partial_implementation; release proof)
  - `AOS20_Adaptation_Kernel_Local_Personalization_Prompt` — `docs/codex/batches/AOS20_Adaptation_Kernel_Local_Personalization_Prompt.md` (partial_implementation; release proof)
  - `AOS21_Interoperability_Kernel_App_Intents_EventKit_Planning_Prompt` — `docs/codex/batches/AOS21_Interoperability_Kernel_App_Intents_EventKit_Planning_Prompt.md` (partial_implementation; release proof)
  - `AOS22_Longevity_Kernel_Archive_Aging_Prompt` — `docs/codex/batches/AOS22_Longevity_Kernel_Archive_Aging_Prompt.md` (partial_implementation; release proof)
  - `AOS23_Governance_Kernel_Registry_Prompt` — `docs/codex/batches/AOS23_Governance_Kernel_Registry_Prompt.md` (partial_implementation; release proof)
  - `AOS24_AmbitionsOS_UI_Integration_Prompt` — `docs/codex/batches/AOS24_AmbitionsOS_UI_Integration_Prompt.md` (partial_implementation; release proof)
  - `AOS25_AmbitionsOS_Test_Fixture_Library_Prompt` — `docs/codex/batches/AOS25_AmbitionsOS_Test_Fixture_Library_Prompt.md` (partial_implementation; release proof)
  - `AOS26_AmbitionsOS_Privacy_Performance_QA_Prompt` — `docs/codex/batches/AOS26_AmbitionsOS_Privacy_Performance_QA_Prompt.md` (partial_implementation; release proof)
  - ... 68 more

### 218. Same source file targeted by multiple active items: scripts/ci-local-parity.sh

- Conflict ID: `AMB28-same_source_file_targeted_by_multiple_active_batches-48308891`
- Type: `same_source_file_targeted_by_multiple_active_batches`
- Severity: `yellow`
- Recommended action: `merge`
- Rationale: Multiple active ledger items reference the same source file; merge, sequence, or assign ownership before implementation.
- Linear issue ready: `True`
- Auto-resolved: `False`
- Involved:
  - `PFC01_PFC40_PLATFORM_FRAMEWORK_COMPLIANCE_TRAIN` — `docs/codex/batch-trains/PFC01_PFC40_PLATFORM_FRAMEWORK_COMPLIANCE_TRAIN.md` (partial_implementation; release proof)
  - `PFC05_CI_Local_Toolchain_Reproducibility_Prompt` — `docs/codex/batches/PFC05_CI_Local_Toolchain_Reproducibility_Prompt.md` (partial_implementation; release proof)

### 219. Same source file targeted by multiple active items: scripts/codex-forbidden-claim-scan.sh

- Conflict ID: `AMB28-same_source_file_targeted_by_multiple_active_batches-19490901`
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
  - ... 68 more

### 220. Same source file targeted by multiple active items: scripts/cqs-accessibility-motion-scan.sh

- Conflict ID: `AMB28-same_source_file_targeted_by_multiple_active_batches-53091603`
- Type: `same_source_file_targeted_by_multiple_active_batches`
- Severity: `yellow`
- Recommended action: `merge`
- Rationale: Multiple active ledger items reference the same source file; merge, sequence, or assign ownership before implementation.
- Linear issue ready: `True`
- Auto-resolved: `False`
- Involved:
  - `CQS01_CQS24_CODEX_QUALITY_SYSTEM_TRAIN` — `docs/codex/batch-trains/CQS01_CQS24_CODEX_QUALITY_SYSTEM_TRAIN.md` (partial_implementation; release proof)
  - `FVQ01_RENDERED_VISUAL_FRESHNESS_AND_FLAGSHIP_PROMPT` — `docs/codex/batches/FVQ01_RENDERED_VISUAL_FRESHNESS_AND_FLAGSHIP_PROMPT.md` (partial_implementation; release proof)
  - `GATE_SYSTEM_HARDENING_NEXT_PROMPT` — `docs/codex/batches/GATE_SYSTEM_HARDENING_NEXT_PROMPT.md` (partial_implementation; release proof)
  - `PFC14_WidgetKit_Implementation_And_Tests_Prompt` — `docs/codex/batches/PFC14_WidgetKit_Implementation_And_Tests_Prompt.md` (partial_implementation; release proof)
  - `CODEX_QUALITY_SYSTEM_SCRIPT_MAP` — `docs/codex/CODEX_QUALITY_SYSTEM_SCRIPT_MAP.md` (unknown; release proof)

### 221. Same source file targeted by multiple active items: scripts/cqs-architecture-boundary-scan.sh

- Conflict ID: `AMB28-same_source_file_targeted_by_multiple_active_batches-66311469`
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

### 222. Same source file targeted by multiple active items: scripts/cqs-performance-budget-scan.sh

- Conflict ID: `AMB28-same_source_file_targeted_by_multiple_active_batches-10983828`
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

### 223. Same source file targeted by multiple active items: scripts/cqs-preview-coverage-scan.sh

- Conflict ID: `AMB28-same_source_file_targeted_by_multiple_active_batches-65413798`
- Type: `same_source_file_targeted_by_multiple_active_batches`
- Severity: `yellow`
- Recommended action: `merge`
- Rationale: Multiple active ledger items reference the same source file; merge, sequence, or assign ownership before implementation.
- Linear issue ready: `True`
- Auto-resolved: `False`
- Involved:
  - `CQS01_CQS24_CODEX_QUALITY_SYSTEM_TRAIN` — `docs/codex/batch-trains/CQS01_CQS24_CODEX_QUALITY_SYSTEM_TRAIN.md` (partial_implementation; release proof)
  - `CODEX_QUALITY_SYSTEM_SCRIPT_MAP` — `docs/codex/CODEX_QUALITY_SYSTEM_SCRIPT_MAP.md` (unknown; release proof)

### 224. Same source file targeted by multiple active items: scripts/cqs-privacy-security-claim-scan.sh

- Conflict ID: `AMB28-same_source_file_targeted_by_multiple_active_batches-73720386`
- Type: `same_source_file_targeted_by_multiple_active_batches`
- Severity: `yellow`
- Recommended action: `merge`
- Rationale: Multiple active ledger items reference the same source file; merge, sequence, or assign ownership before implementation.
- Linear issue ready: `True`
- Auto-resolved: `False`
- Involved:
  - `CQS01_CQS24_CODEX_QUALITY_SYSTEM_TRAIN` — `docs/codex/batch-trains/CQS01_CQS24_CODEX_QUALITY_SYSTEM_TRAIN.md` (partial_implementation; release proof)
  - `FL06_Weekly_Life_Sweep_Ritual_Prompt` — `docs/codex/batches/FL06_Weekly_Life_Sweep_Ritual_Prompt.md` (partial_implementation; release proof)
  - `FVQ01_RENDERED_VISUAL_FRESHNESS_AND_FLAGSHIP_PROMPT` — `docs/codex/batches/FVQ01_RENDERED_VISUAL_FRESHNESS_AND_FLAGSHIP_PROMPT.md` (partial_implementation; release proof)
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
  - `PFC12_App_Groups_Shared_Storage_Boundary_Prompt` — `docs/codex/batches/PFC12_App_Groups_Shared_Storage_Boundary_Prompt.md` (unknown; release proof)

### 225. Same source file targeted by multiple active items: scripts/cqs-product-drift-scan.sh

- Conflict ID: `AMB28-same_source_file_targeted_by_multiple_active_batches-70637776`
- Type: `same_source_file_targeted_by_multiple_active_batches`
- Severity: `yellow`
- Recommended action: `merge`
- Rationale: Multiple active ledger items reference the same source file; merge, sequence, or assign ownership before implementation.
- Linear issue ready: `True`
- Auto-resolved: `False`
- Involved:
  - `CQS01_CQS24_CODEX_QUALITY_SYSTEM_TRAIN` — `docs/codex/batch-trains/CQS01_CQS24_CODEX_QUALITY_SYSTEM_TRAIN.md` (partial_implementation; release proof)
  - `FVQ01_RENDERED_VISUAL_FRESHNESS_AND_FLAGSHIP_PROMPT` — `docs/codex/batches/FVQ01_RENDERED_VISUAL_FRESHNESS_AND_FLAGSHIP_PROMPT.md` (partial_implementation; release proof)
  - `PFC03_Dead_Code_Prompt_Artifact_Naming_Smell_Audit_Prompt` — `docs/codex/batches/PFC03_Dead_Code_Prompt_Artifact_Naming_Smell_Audit_Prompt.md` (partial_implementation; release proof)
  - `GATE_RESULT_MANIFEST_SCHEMA` — `docs/codex/GATE_RESULT_MANIFEST_SCHEMA.md` (partial_implementation; release proof)
  - `GATE_SYSTEM_HARDENING_NEXT_PROMPT` — `docs/codex/batches/GATE_SYSTEM_HARDENING_NEXT_PROMPT.md` (partial_implementation; release proof)
  - `MOONSHOT_PROOF_PATH_BACKEND_MASTER_PLAN` — `docs/codex/MOONSHOT_PROOF_PATH_BACKEND_MASTER_PLAN.md` (partial_implementation; release proof)
  - `MOAT-MOONSHOT-BACKEND-FULL-TRAIN-01` — `prompts/batches/MOAT-MOONSHOT-BACKEND-FULL-TRAIN-01.md` (partial_implementation; release proof)
  - `MOAT-MOONSHOT-PROOF-PATH-01` — `prompts/batches/MOAT-MOONSHOT-PROOF-PATH-01.md` (partial_implementation; release proof)
  - `MOAT-UNIVERSAL-GOAL-REALITY-COMPILER-01` — `prompts/batches/MOAT-UNIVERSAL-GOAL-REALITY-COMPILER-01.md` (partial_implementation; release proof)
  - `CODEX_QUALITY_SYSTEM_SCRIPT_MAP` — `docs/codex/CODEX_QUALITY_SYSTEM_SCRIPT_MAP.md` (unknown; release proof)

### 226. Same source file targeted by multiple active items: scripts/cqs-prompt-built-smell-scan.sh

- Conflict ID: `AMB28-same_source_file_targeted_by_multiple_active_batches-94129696`
- Type: `same_source_file_targeted_by_multiple_active_batches`
- Severity: `yellow`
- Recommended action: `merge`
- Rationale: Multiple active ledger items reference the same source file; merge, sequence, or assign ownership before implementation.
- Linear issue ready: `True`
- Auto-resolved: `False`
- Involved:
  - `CQS01_CQS24_CODEX_QUALITY_SYSTEM_TRAIN` — `docs/codex/batch-trains/CQS01_CQS24_CODEX_QUALITY_SYSTEM_TRAIN.md` (partial_implementation; release proof)
  - `FVQ01_RENDERED_VISUAL_FRESHNESS_AND_FLAGSHIP_PROMPT` — `docs/codex/batches/FVQ01_RENDERED_VISUAL_FRESHNESS_AND_FLAGSHIP_PROMPT.md` (partial_implementation; release proof)
  - `PFC03_Dead_Code_Prompt_Artifact_Naming_Smell_Audit_Prompt` — `docs/codex/batches/PFC03_Dead_Code_Prompt_Artifact_Naming_Smell_Audit_Prompt.md` (partial_implementation; release proof)
  - `GATE_SYSTEM_HARDENING_NEXT_PROMPT` — `docs/codex/batches/GATE_SYSTEM_HARDENING_NEXT_PROMPT.md` (partial_implementation; release proof)
  - `MOONSHOT_PROOF_PATH_BACKEND_MASTER_PLAN` — `docs/codex/MOONSHOT_PROOF_PATH_BACKEND_MASTER_PLAN.md` (partial_implementation; release proof)
  - `MOAT-MOONSHOT-BACKEND-FULL-TRAIN-01` — `prompts/batches/MOAT-MOONSHOT-BACKEND-FULL-TRAIN-01.md` (partial_implementation; release proof)
  - `MOAT-MOONSHOT-PROOF-PATH-01` — `prompts/batches/MOAT-MOONSHOT-PROOF-PATH-01.md` (partial_implementation; release proof)
  - `MOAT-UNIVERSAL-GOAL-REALITY-COMPILER-01` — `prompts/batches/MOAT-UNIVERSAL-GOAL-REALITY-COMPILER-01.md` (partial_implementation; release proof)
  - `CODEX_QUALITY_SYSTEM_SCRIPT_MAP` — `docs/codex/CODEX_QUALITY_SYSTEM_SCRIPT_MAP.md` (unknown; release proof)

### 227. Same source file targeted by multiple active items: scripts/dav-reduce-motion-check.sh

- Conflict ID: `AMB28-same_source_file_targeted_by_multiple_active_batches-58973986`
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

### 228. Same source file targeted by multiple active items: scripts/dav-visual-primitive-inventory.sh

- Conflict ID: `AMB28-same_source_file_targeted_by_multiple_active_batches-32178151`
- Type: `same_source_file_targeted_by_multiple_active_batches`
- Severity: `yellow`
- Recommended action: `merge`
- Rationale: Multiple active ledger items reference the same source file; merge, sequence, or assign ownership before implementation.
- Linear issue ready: `True`
- Auto-resolved: `False`
- Involved:
  - `DAV01_Dynamic_Visual_Source_Truth_And_Surface_Map_Prompt` — `docs/codex/batches/DAV01_Dynamic_Visual_Source_Truth_And_Surface_Map_Prompt.md` (partial_implementation; release proof)
  - `DAV02_Reusable_Living_Visual_Primitives_Implementation_Prompt` — `docs/codex/batches/DAV02_Reusable_Living_Visual_Primitives_Implementation_Prompt.md` (partial_implementation; release proof)

### 229. Same source file targeted by multiple active items: scripts/eb-active-train-integration-gate.sh

- Conflict ID: `AMB28-same_source_file_targeted_by_multiple_active_batches-88591668`
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

### 230. Same source file targeted by multiple active items: scripts/eb-no-5-version-drift-scan.sh

- Conflict ID: `AMB28-same_source_file_targeted_by_multiple_active_batches-75801563`
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

### 231. Same source file targeted by multiple active items: scripts/eb-no-unsupported-claim-scan.sh

- Conflict ID: `AMB28-same_source_file_targeted_by_multiple_active_batches-33436045`
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

### 232. Same source file targeted by multiple active items: scripts/fet-bottom-chrome-conflict-scan.sh

- Conflict ID: `AMB28-same_source_file_targeted_by_multiple_active_batches-15187566`
- Type: `same_source_file_targeted_by_multiple_active_batches`
- Severity: `yellow`
- Recommended action: `merge`
- Rationale: Multiple active ledger items reference the same source file; merge, sequence, or assign ownership before implementation.
- Linear issue ready: `True`
- Auto-resolved: `False`
- Involved:
  - `GLOBAL_BATCH_AUTOMATED_GATE_PROTOCOL` — `docs/codex/GLOBAL_BATCH_AUTOMATED_GATE_PROTOCOL.md` (partial_implementation; release proof)
  - `FAANG_FRONTEND_IMPLEMENTATION_OPERATING_SYSTEM` — `docs/codex/FAANG_FRONTEND_IMPLEMENTATION_OPERATING_SYSTEM.md` (partial_implementation; release proof)
  - `FET01_FET12_FAANG_FRONTEND_EXCELLENCE_TRAIN` — `docs/codex/batch-trains/FET01_FET12_FAANG_FRONTEND_EXCELLENCE_TRAIN.md` (partial_implementation; release proof)
  - `FET00_FAANG_FRONTEND_CODEX_OS_UPGRADE_PROMPT` — `docs/codex/batches/FET00_FAANG_FRONTEND_CODEX_OS_UPGRADE_PROMPT.md` (partial_implementation; release proof)

### 233. Same source file targeted by multiple active items: scripts/fet-copy-density-scan.sh

- Conflict ID: `AMB28-same_source_file_targeted_by_multiple_active_batches-42900710`
- Type: `same_source_file_targeted_by_multiple_active_batches`
- Severity: `yellow`
- Recommended action: `merge`
- Rationale: Multiple active ledger items reference the same source file; merge, sequence, or assign ownership before implementation.
- Linear issue ready: `True`
- Auto-resolved: `False`
- Involved:
  - `GLOBAL_BATCH_AUTOMATED_GATE_PROTOCOL` — `docs/codex/GLOBAL_BATCH_AUTOMATED_GATE_PROTOCOL.md` (partial_implementation; release proof)
  - `FAANG_FRONTEND_IMPLEMENTATION_OPERATING_SYSTEM` — `docs/codex/FAANG_FRONTEND_IMPLEMENTATION_OPERATING_SYSTEM.md` (partial_implementation; release proof)
  - `FET01_FET12_FAANG_FRONTEND_EXCELLENCE_TRAIN` — `docs/codex/batch-trains/FET01_FET12_FAANG_FRONTEND_EXCELLENCE_TRAIN.md` (partial_implementation; release proof)
  - `FET00_FAANG_FRONTEND_CODEX_OS_UPGRADE_PROMPT` — `docs/codex/batches/FET00_FAANG_FRONTEND_CODEX_OS_UPGRADE_PROMPT.md` (partial_implementation; release proof)

### 234. Same source file targeted by multiple active items: scripts/fet-first-viewport-budget-scan.sh

- Conflict ID: `AMB28-same_source_file_targeted_by_multiple_active_batches-62910670`
- Type: `same_source_file_targeted_by_multiple_active_batches`
- Severity: `yellow`
- Recommended action: `merge`
- Rationale: Multiple active ledger items reference the same source file; merge, sequence, or assign ownership before implementation.
- Linear issue ready: `True`
- Auto-resolved: `False`
- Involved:
  - `GLOBAL_BATCH_AUTOMATED_GATE_PROTOCOL` — `docs/codex/GLOBAL_BATCH_AUTOMATED_GATE_PROTOCOL.md` (partial_implementation; release proof)
  - `FAANG_FRONTEND_IMPLEMENTATION_OPERATING_SYSTEM` — `docs/codex/FAANG_FRONTEND_IMPLEMENTATION_OPERATING_SYSTEM.md` (partial_implementation; release proof)
  - `FET01_FET12_FAANG_FRONTEND_EXCELLENCE_TRAIN` — `docs/codex/batch-trains/FET01_FET12_FAANG_FRONTEND_EXCELLENCE_TRAIN.md` (partial_implementation; release proof)
  - `FET00_FAANG_FRONTEND_CODEX_OS_UPGRADE_PROMPT` — `docs/codex/batches/FET00_FAANG_FRONTEND_CODEX_OS_UPGRADE_PROMPT.md` (partial_implementation; release proof)

### 235. Same source file targeted by multiple active items: scripts/fet-primitive-density-scan.sh

- Conflict ID: `AMB28-same_source_file_targeted_by_multiple_active_batches-21604483`
- Type: `same_source_file_targeted_by_multiple_active_batches`
- Severity: `yellow`
- Recommended action: `merge`
- Rationale: Multiple active ledger items reference the same source file; merge, sequence, or assign ownership before implementation.
- Linear issue ready: `True`
- Auto-resolved: `False`
- Involved:
  - `GLOBAL_BATCH_AUTOMATED_GATE_PROTOCOL` — `docs/codex/GLOBAL_BATCH_AUTOMATED_GATE_PROTOCOL.md` (partial_implementation; release proof)
  - `FAANG_FRONTEND_IMPLEMENTATION_OPERATING_SYSTEM` — `docs/codex/FAANG_FRONTEND_IMPLEMENTATION_OPERATING_SYSTEM.md` (partial_implementation; release proof)
  - `FET01_FET12_FAANG_FRONTEND_EXCELLENCE_TRAIN` — `docs/codex/batch-trains/FET01_FET12_FAANG_FRONTEND_EXCELLENCE_TRAIN.md` (partial_implementation; release proof)
  - `FET00_FAANG_FRONTEND_CODEX_OS_UPGRADE_PROMPT` — `docs/codex/batches/FET00_FAANG_FRONTEND_CODEX_OS_UPGRADE_PROMPT.md` (partial_implementation; release proof)

### 236. Same source file targeted by multiple active items: scripts/fet-readiness-gate.sh

- Conflict ID: `AMB28-same_source_file_targeted_by_multiple_active_batches-63479679`
- Type: `same_source_file_targeted_by_multiple_active_batches`
- Severity: `yellow`
- Recommended action: `merge`
- Rationale: Multiple active ledger items reference the same source file; merge, sequence, or assign ownership before implementation.
- Linear issue ready: `True`
- Auto-resolved: `False`
- Involved:
  - `GLOBAL_BATCH_AUTOMATED_GATE_PROTOCOL` — `docs/codex/GLOBAL_BATCH_AUTOMATED_GATE_PROTOCOL.md` (partial_implementation; release proof)
  - `FAANG_FRONTEND_IMPLEMENTATION_OPERATING_SYSTEM` — `docs/codex/FAANG_FRONTEND_IMPLEMENTATION_OPERATING_SYSTEM.md` (partial_implementation; release proof)
  - `FET01_FET12_FAANG_FRONTEND_EXCELLENCE_TRAIN` — `docs/codex/batch-trains/FET01_FET12_FAANG_FRONTEND_EXCELLENCE_TRAIN.md` (partial_implementation; release proof)
  - `FET00_FAANG_FRONTEND_CODEX_OS_UPGRADE_PROMPT` — `docs/codex/batches/FET00_FAANG_FRONTEND_CODEX_OS_UPGRADE_PROMPT.md` (partial_implementation; release proof)

### 237. Same source file targeted by multiple active items: scripts/fet-visual-qa-packet-check.sh

- Conflict ID: `AMB28-same_source_file_targeted_by_multiple_active_batches-46969109`
- Type: `same_source_file_targeted_by_multiple_active_batches`
- Severity: `yellow`
- Recommended action: `merge`
- Rationale: Multiple active ledger items reference the same source file; merge, sequence, or assign ownership before implementation.
- Linear issue ready: `True`
- Auto-resolved: `False`
- Involved:
  - `GLOBAL_BATCH_AUTOMATED_GATE_PROTOCOL` — `docs/codex/GLOBAL_BATCH_AUTOMATED_GATE_PROTOCOL.md` (partial_implementation; release proof)
  - `FAANG_FRONTEND_IMPLEMENTATION_OPERATING_SYSTEM` — `docs/codex/FAANG_FRONTEND_IMPLEMENTATION_OPERATING_SYSTEM.md` (partial_implementation; release proof)
  - `FET01_FET12_FAANG_FRONTEND_EXCELLENCE_TRAIN` — `docs/codex/batch-trains/FET01_FET12_FAANG_FRONTEND_EXCELLENCE_TRAIN.md` (partial_implementation; release proof)
  - `FET00_FAANG_FRONTEND_CODEX_OS_UPGRADE_PROMPT` — `docs/codex/batches/FET00_FAANG_FRONTEND_CODEX_OS_UPGRADE_PROMPT.md` (partial_implementation; release proof)

### 238. Same source file targeted by multiple active items: scripts/global-train-next-batch.sh

- Conflict ID: `AMB28-same_source_file_targeted_by_multiple_active_batches-65738276`
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

### 239. Same source file targeted by multiple active items: scripts/global-train-status-summary.sh

- Conflict ID: `AMB28-same_source_file_targeted_by_multiple_active_batches-24813387`
- Type: `same_source_file_targeted_by_multiple_active_batches`
- Severity: `yellow`
- Recommended action: `merge`
- Rationale: Multiple active ledger items reference the same source file; merge, sequence, or assign ownership before implementation.
- Linear issue ready: `True`
- Auto-resolved: `False`
- Involved:
  - `GLOBAL_PATCH_TRAIN_INTERRUPTED_RUN_RECOVERY_PROTOCOL` — `docs/codex/GLOBAL_PATCH_TRAIN_INTERRUPTED_RUN_RECOVERY_PROTOCOL.md` (partial_implementation; release proof)
  - `TIME_REPLACES_PLAN_COMPATIBILITY_LEDGER` — `docs/codex/TIME_REPLACES_PLAN_COMPATIBILITY_LEDGER.md` (partial_implementation; release proof)

### 240. Same source file targeted by multiple active items: scripts/hps-claim-boundary-scan.sh

- Conflict ID: `AMB28-same_source_file_targeted_by_multiple_active_batches-46653020`
- Type: `same_source_file_targeted_by_multiple_active_batches`
- Severity: `yellow`
- Recommended action: `merge`
- Rationale: Multiple active ledger items reference the same source file; merge, sequence, or assign ownership before implementation.
- Linear issue ready: `True`
- Auto-resolved: `False`
- Involved:
  - `HPS_CODEX_OS_UPGRADE_MAP` — `docs/codex/HPS_CODEX_OS_UPGRADE_MAP.md` (partial_implementation; release proof)
  - `HPS01_HPS12_HUMAN_PROGRESS_SYSTEMS_UPGRADE_TRAIN` — `docs/codex/batch-trains/HPS01_HPS12_HUMAN_PROGRESS_SYSTEMS_UPGRADE_TRAIN.md` (partial_implementation; release proof)
  - `HPS_NEXT_ELIGIBLE_BATCH_PROMPT` — `docs/codex/batches/HPS_NEXT_ELIGIBLE_BATCH_PROMPT.md` (partial_implementation; release proof)

### 241. Same source file targeted by multiple active items: scripts/hps-moat-coverage-scan.sh

- Conflict ID: `AMB28-same_source_file_targeted_by_multiple_active_batches-39578144`
- Type: `same_source_file_targeted_by_multiple_active_batches`
- Severity: `yellow`
- Recommended action: `merge`
- Rationale: Multiple active ledger items reference the same source file; merge, sequence, or assign ownership before implementation.
- Linear issue ready: `True`
- Auto-resolved: `False`
- Involved:
  - `HPS_CODEX_OS_UPGRADE_MAP` — `docs/codex/HPS_CODEX_OS_UPGRADE_MAP.md` (partial_implementation; release proof)
  - `HPS01_HPS12_HUMAN_PROGRESS_SYSTEMS_UPGRADE_TRAIN` — `docs/codex/batch-trains/HPS01_HPS12_HUMAN_PROGRESS_SYSTEMS_UPGRADE_TRAIN.md` (partial_implementation; release proof)
  - `HPS_NEXT_ELIGIBLE_BATCH_PROMPT` — `docs/codex/batches/HPS_NEXT_ELIGIBLE_BATCH_PROMPT.md` (partial_implementation; release proof)

### 242. Same source file targeted by multiple active items: scripts/hps-no-sprawl-scan.sh

- Conflict ID: `AMB28-same_source_file_targeted_by_multiple_active_batches-60383215`
- Type: `same_source_file_targeted_by_multiple_active_batches`
- Severity: `yellow`
- Recommended action: `merge`
- Rationale: Multiple active ledger items reference the same source file; merge, sequence, or assign ownership before implementation.
- Linear issue ready: `True`
- Auto-resolved: `False`
- Involved:
  - `HPS_CODEX_OS_UPGRADE_MAP` — `docs/codex/HPS_CODEX_OS_UPGRADE_MAP.md` (partial_implementation; release proof)
  - `HPS01_HPS12_HUMAN_PROGRESS_SYSTEMS_UPGRADE_TRAIN` — `docs/codex/batch-trains/HPS01_HPS12_HUMAN_PROGRESS_SYSTEMS_UPGRADE_TRAIN.md` (partial_implementation; release proof)
  - `HPS_NEXT_ELIGIBLE_BATCH_PROMPT` — `docs/codex/batches/HPS_NEXT_ELIGIBLE_BATCH_PROMPT.md` (partial_implementation; release proof)

### 243. Same source file targeted by multiple active items: scripts/ios26-anti-card-check.py

- Conflict ID: `AMB28-same_source_file_targeted_by_multiple_active_batches-73637881`
- Type: `same_source_file_targeted_by_multiple_active_batches`
- Severity: `yellow`
- Recommended action: `merge`
- Rationale: Multiple active ledger items reference the same source file; merge, sequence, or assign ownership before implementation.
- Linear issue ready: `True`
- Auto-resolved: `False`
- Involved:
  - `IOS26_ANTI_CARD_VALIDATOR_SPEC` — `docs/codex/frontend/IOS26_ANTI_CARD_VALIDATOR_SPEC.md` (partial_implementation; release proof)
  - `IOS26_OBJECT_FRONTEND_BATCH_INSERTION_PLAN` — `docs/codex/frontend/IOS26_OBJECT_FRONTEND_BATCH_INSERTION_PLAN.md` (partial_implementation; release proof)
  - `OBJECT_FRONTEND_GREEN_YELLOW_RED_RUBRIC` — `docs/codex/frontend/OBJECT_FRONTEND_GREEN_YELLOW_RED_RUBRIC.md` (partial_implementation; release proof)
  - `IOS26_EXISTING_BATCH_EXPANSION_DIRECTIVES` — `docs/codex/frontend/IOS26_EXISTING_BATCH_EXPANSION_DIRECTIVES.md` (unknown; release proof)

### 244. Same source file targeted by multiple active items: scripts/ios26-flagship-run-sequential.sh

- Conflict ID: `AMB28-same_source_file_targeted_by_multiple_active_batches-69734110`
- Type: `same_source_file_targeted_by_multiple_active_batches`
- Severity: `yellow`
- Recommended action: `merge`
- Rationale: Multiple active ledger items reference the same source file; merge, sequence, or assign ownership before implementation.
- Linear issue ready: `True`
- Auto-resolved: `False`
- Involved:
  - `IOS26-FLAGSHIP` — `docs/codex/IOS26_FLAGSHIP_TRAIN_MANIFEST.yml` (partial_implementation; release proof)
  - `AMB-INTELLIGENCE-CONSOLIDATION-CHAMPION-SELECTION-01` — `prompts/batches/AMB-INTELLIGENCE-CONSOLIDATION-CHAMPION-SELECTION-01.md` (partial_implementation; release proof)
  - `REPO_INTELLIGENCE_CONTROL_PLANE` — `docs/codex/REPO_INTELLIGENCE_CONTROL_PLANE.md` (unknown; release proof)

### 245. Same source file targeted by multiple active items: scripts/ios26-plan-freeze.py

- Conflict ID: `AMB28-same_source_file_targeted_by_multiple_active_batches-42646312`
- Type: `same_source_file_targeted_by_multiple_active_batches`
- Severity: `yellow`
- Recommended action: `merge`
- Rationale: Multiple active ledger items reference the same source file; merge, sequence, or assign ownership before implementation.
- Linear issue ready: `True`
- Auto-resolved: `False`
- Involved:
  - `IOS26_BATCH_MATRIX` — `docs/codex/ios26/IOS26_BATCH_MATRIX.yml` (partial_implementation; release proof)
  - `IOS26_DEPENDENCY_GRAPH` — `docs/codex/ios26/IOS26_DEPENDENCY_GRAPH.yml` (partial_implementation; source-only)

### 246. Same source file targeted by multiple active items: scripts/ldi-gate-check.sh

- Conflict ID: `AMB28-same_source_file_targeted_by_multiple_active_batches-91424747`
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

### 247. Same source file targeted by multiple active items: scripts/ldi-handling-lane-scan.sh

- Conflict ID: `AMB28-same_source_file_targeted_by_multiple_active_batches-90872127`
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

### 248. Same source file targeted by multiple active items: scripts/ldi-pack-supply-chain-scan.py

- Conflict ID: `AMB28-same_source_file_targeted_by_multiple_active_batches-55112340`
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

### 249. Same source file targeted by multiple active items: scripts/ldi-release-claim-scan.sh

- Conflict ID: `AMB28-same_source_file_targeted_by_multiple_active_batches-69341060`
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

### 250. Same source file targeted by multiple active items: scripts/ldi-safety-redteam-fixture-check.py

- Conflict ID: `AMB28-same_source_file_targeted_by_multiple_active_batches-24100554`
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

### 251. Same source file targeted by multiple active items: scripts/ldi-source-pack-schema-check.py

- Conflict ID: `AMB28-same_source_file_targeted_by_multiple_active_batches-98560090`
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

### 252. Same source file targeted by multiple active items: scripts/openai-build-suite-dry-run.py

- Conflict ID: `AMB28-same_source_file_targeted_by_multiple_active_batches-24854560`
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

### 253. Same source file targeted by multiple active items: scripts/openai-build-suite-validate.py

- Conflict ID: `AMB28-same_source_file_targeted_by_multiple_active_batches-82439366`
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

### 254. Same source file targeted by multiple active items: scripts/run-doc-qa.sh

- Conflict ID: `AMB28-same_source_file_targeted_by_multiple_active_batches-65376188`
- Type: `same_source_file_targeted_by_multiple_active_batches`
- Severity: `yellow`
- Recommended action: `merge`
- Rationale: Multiple active ledger items reference the same source file; merge, sequence, or assign ownership before implementation.
- Linear issue ready: `True`
- Auto-resolved: `False`
- Involved:
  - `AMBITIONS_3_0_CONTEXT_LOADING_AND_TASK_ROUTING` — `docs/codex/AMBITIONS_3_0_CONTEXT_LOADING_AND_TASK_ROUTING.md` (partial_implementation; release proof)
  - `GLOBAL_BATCH_AUTOMATED_GATE_PROTOCOL` — `docs/codex/GLOBAL_BATCH_AUTOMATED_GATE_PROTOCOL.md` (partial_implementation; release proof)
  - `AOS01_AmbitionsOS_Canon_And_Runtime_Contract_Prompt` — `docs/codex/batches/AOS01_AmbitionsOS_Canon_And_Runtime_Contract_Prompt.md` (partial_implementation; release proof)
  - `AOS02_Life_Graph_Event_Log_Foundation_Prompt` — `docs/codex/batches/AOS02_Life_Graph_Event_Log_Foundation_Prompt.md` (partial_implementation; release proof)
  - `AOS03_Graph_Delta_Review_Projection_Store_Prompt` — `docs/codex/batches/AOS03_Graph_Delta_Review_Projection_Store_Prompt.md` (partial_implementation; release proof)
  - `AOS04_Control_Plane_Work_Classifier_Prompt` — `docs/codex/batches/AOS04_Control_Plane_Work_Classifier_Prompt.md` (partial_implementation; release proof)
  - `AOS05_Starting_Position_Kernel_Prompt` — `docs/codex/batches/AOS05_Starting_Position_Kernel_Prompt.md` (partial_implementation; release proof)
  - `AOS06_Goal_Path_Kernel_Goal_Compiler_Prompt` — `docs/codex/batches/AOS06_Goal_Path_Kernel_Goal_Compiler_Prompt.md` (partial_implementation; release proof)
  - `AOS07_Local_Goal_Packs_Requirement_Slots_Prompt` — `docs/codex/batches/AOS07_Local_Goal_Packs_Requirement_Slots_Prompt.md` (partial_implementation; release proof)
  - `AOS08_Alternate_Path_Kernel_Path_Portfolio_Prompt` — `docs/codex/batches/AOS08_Alternate_Path_Kernel_Path_Portfolio_Prompt.md` (partial_implementation; release proof)
  - `AOS09_Option_Value_North_Star_Prompt` — `docs/codex/batches/AOS09_Option_Value_North_Star_Prompt.md` (partial_implementation; release proof)
  - `AOS10_Commitment_Time_Kernel_Prompt` — `docs/codex/batches/AOS10_Commitment_Time_Kernel_Prompt.md` (partial_implementation; release proof)
  - `AOS11_Reality_Drift_Bounded_Reflow_Prompt` — `docs/codex/batches/AOS11_Reality_Drift_Bounded_Reflow_Prompt.md` (partial_implementation; release proof)
  - `AOS12_Proof_Trust_Closure_Receipts_Prompt` — `docs/codex/batches/AOS12_Proof_Trust_Closure_Receipts_Prompt.md` (partial_implementation; release proof)
  - `AOS13_Source_Truth_Claim_State_Machine_Prompt` — `docs/codex/batches/AOS13_Source_Truth_Claim_State_Machine_Prompt.md` (partial_implementation; release proof)
  - `AOS14_Recommendation_Start_Here_Kernel_Prompt` — `docs/codex/batches/AOS14_Recommendation_Start_Here_Kernel_Prompt.md` (partial_implementation; release proof)
  - `AOS15_Local_Language_Kernel_Planning_Prompt` — `docs/codex/batches/AOS15_Local_Language_Kernel_Planning_Prompt.md` (partial_implementation; release proof)
  - `AOS16_Performance_Energy_Kernel_Prompt` — `docs/codex/batches/AOS16_Performance_Energy_Kernel_Prompt.md` (partial_implementation; release proof)
  - `AOS17_Privacy_Safety_Kernel_Prompt` — `docs/codex/batches/AOS17_Privacy_Safety_Kernel_Prompt.md` (partial_implementation; release proof)
  - `AOS18_Evaluation_Golden_Scenarios_Prompt` — `docs/codex/batches/AOS18_Evaluation_Golden_Scenarios_Prompt.md` (partial_implementation; release proof)
  - `AOS19_Experience_Kernel_Celestial_Cognitive_Load_Prompt` — `docs/codex/batches/AOS19_Experience_Kernel_Celestial_Cognitive_Load_Prompt.md` (partial_implementation; release proof)
  - `AOS20_Adaptation_Kernel_Local_Personalization_Prompt` — `docs/codex/batches/AOS20_Adaptation_Kernel_Local_Personalization_Prompt.md` (partial_implementation; release proof)
  - `AOS21_Interoperability_Kernel_App_Intents_EventKit_Planning_Prompt` — `docs/codex/batches/AOS21_Interoperability_Kernel_App_Intents_EventKit_Planning_Prompt.md` (partial_implementation; release proof)
  - `AOS22_Longevity_Kernel_Archive_Aging_Prompt` — `docs/codex/batches/AOS22_Longevity_Kernel_Archive_Aging_Prompt.md` (partial_implementation; release proof)
  - `AOS23_Governance_Kernel_Registry_Prompt` — `docs/codex/batches/AOS23_Governance_Kernel_Registry_Prompt.md` (partial_implementation; release proof)
  - `AOS24_AmbitionsOS_UI_Integration_Prompt` — `docs/codex/batches/AOS24_AmbitionsOS_UI_Integration_Prompt.md` (partial_implementation; release proof)
  - `AOS25_AmbitionsOS_Test_Fixture_Library_Prompt` — `docs/codex/batches/AOS25_AmbitionsOS_Test_Fixture_Library_Prompt.md` (partial_implementation; release proof)
  - `AOS26_AmbitionsOS_Privacy_Performance_QA_Prompt` — `docs/codex/batches/AOS26_AmbitionsOS_Privacy_Performance_QA_Prompt.md` (partial_implementation; release proof)
  - `AOS27_AmbitionsOS_App_Store_Claim_Truth_Prompt` — `docs/codex/batches/AOS27_AmbitionsOS_App_Store_Claim_Truth_Prompt.md` (partial_implementation; release proof)
  - `AOS28_AmbitionsOS_Handoff_Prompt` — `docs/codex/batches/AOS28_AmbitionsOS_Handoff_Prompt.md` (partial_implementation; release proof)
  - ... 161 more

### 255. Same source file targeted by multiple active items: scripts/sa-composition-projection-scan.sh

- Conflict ID: `AMB28-same_source_file_targeted_by_multiple_active_batches-57517626`
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

### 256. Same source file targeted by multiple active items: scripts/sa-generated-step-boundary-scan.sh

- Conflict ID: `AMB28-same_source_file_targeted_by_multiple_active_batches-26774985`
- Type: `same_source_file_targeted_by_multiple_active_batches`
- Severity: `yellow`
- Recommended action: `merge`
- Rationale: Multiple active ledger items reference the same source file; merge, sequence, or assign ownership before implementation.
- Linear issue ready: `True`
- Auto-resolved: `False`
- Involved:
  - `SOURCE_ATLAS_CODEX_OS_UPGRADE_MAP` — `docs/codex/SOURCE_ATLAS_CODEX_OS_UPGRADE_MAP.md` (partial_implementation; release proof)
  - `GATE_SYSTEM_HARDENING_NEXT_PROMPT` — `docs/codex/batches/GATE_SYSTEM_HARDENING_NEXT_PROMPT.md` (partial_implementation; release proof)

### 257. Same source file targeted by multiple active items: scripts/sa-no-claim-scan.sh

- Conflict ID: `AMB28-same_source_file_targeted_by_multiple_active_batches-12644284`
- Type: `same_source_file_targeted_by_multiple_active_batches`
- Severity: `yellow`
- Recommended action: `merge`
- Rationale: Multiple active ledger items reference the same source file; merge, sequence, or assign ownership before implementation.
- Linear issue ready: `True`
- Auto-resolved: `False`
- Involved:
  - `SOURCE_ATLAS_CODEX_OS_UPGRADE_MAP` — `docs/codex/SOURCE_ATLAS_CODEX_OS_UPGRADE_MAP.md` (partial_implementation; release proof)
  - `SA01_SA32_SOURCE_ATLAS_FULL_MATURITY_TRAIN` — `docs/codex/batch-trains/SA01_SA32_SOURCE_ATLAS_FULL_MATURITY_TRAIN.md` (partial_implementation; release proof)
  - `SA_NEXT_ELIGIBLE_BATCH_PROMPT` — `docs/codex/batches/SA_NEXT_ELIGIBLE_BATCH_PROMPT.md` (partial_implementation; release proof)

### 258. Same source file targeted by multiple active items: scripts/sa-offline-fallback-scan.sh

- Conflict ID: `AMB28-same_source_file_targeted_by_multiple_active_batches-86054496`
- Type: `same_source_file_targeted_by_multiple_active_batches`
- Severity: `yellow`
- Recommended action: `merge`
- Rationale: Multiple active ledger items reference the same source file; merge, sequence, or assign ownership before implementation.
- Linear issue ready: `True`
- Auto-resolved: `False`
- Involved:
  - `SOURCE_ATLAS_CODEX_OS_UPGRADE_MAP` — `docs/codex/SOURCE_ATLAS_CODEX_OS_UPGRADE_MAP.md` (partial_implementation; release proof)
  - `SA01_SA32_SOURCE_ATLAS_FULL_MATURITY_TRAIN` — `docs/codex/batch-trains/SA01_SA32_SOURCE_ATLAS_FULL_MATURITY_TRAIN.md` (partial_implementation; release proof)
  - `SA_NEXT_ELIGIBLE_BATCH_PROMPT` — `docs/codex/batches/SA_NEXT_ELIGIBLE_BATCH_PROMPT.md` (partial_implementation; release proof)

### 259. Same source file targeted by multiple active items: scripts/sa-pack-duplication-scan.sh

- Conflict ID: `AMB28-same_source_file_targeted_by_multiple_active_batches-42833998`
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

### 260. Same source file targeted by multiple active items: scripts/sa-pack-schema-validate.sh

- Conflict ID: `AMB28-same_source_file_targeted_by_multiple_active_batches-52105410`
- Type: `same_source_file_targeted_by_multiple_active_batches`
- Severity: `yellow`
- Recommended action: `merge`
- Rationale: Multiple active ledger items reference the same source file; merge, sequence, or assign ownership before implementation.
- Linear issue ready: `True`
- Auto-resolved: `False`
- Involved:
  - `SOURCE_ATLAS_CODEX_OS_UPGRADE_MAP` — `docs/codex/SOURCE_ATLAS_CODEX_OS_UPGRADE_MAP.md` (partial_implementation; release proof)
  - `SA01_SA32_SOURCE_ATLAS_FULL_MATURITY_TRAIN` — `docs/codex/batch-trains/SA01_SA32_SOURCE_ATLAS_FULL_MATURITY_TRAIN.md` (partial_implementation; release proof)
  - `SA_NEXT_ELIGIBLE_BATCH_PROMPT` — `docs/codex/batches/SA_NEXT_ELIGIBLE_BATCH_PROMPT.md` (partial_implementation; release proof)

### 261. Same source file targeted by multiple active items: scripts/sa-projection-fixture-coverage-scan.sh

- Conflict ID: `AMB28-same_source_file_targeted_by_multiple_active_batches-21433652`
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

### 262. Same source file targeted by multiple active items: scripts/sa-research-seeds-integrity-scan.sh

- Conflict ID: `AMB28-same_source_file_targeted_by_multiple_active_batches-95827206`
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

### 263. Same source file targeted by multiple active items: scripts/sa-source-container-coverage-scan.sh

- Conflict ID: `AMB28-same_source_file_targeted_by_multiple_active_batches-80089837`
- Type: `same_source_file_targeted_by_multiple_active_batches`
- Severity: `yellow`
- Recommended action: `merge`
- Rationale: Multiple active ledger items reference the same source file; merge, sequence, or assign ownership before implementation.
- Linear issue ready: `True`
- Auto-resolved: `False`
- Involved:
  - `SOURCE_ATLAS_CODEX_OS_UPGRADE_MAP` — `docs/codex/SOURCE_ATLAS_CODEX_OS_UPGRADE_MAP.md` (partial_implementation; release proof)
  - `SA01_SA32_SOURCE_ATLAS_FULL_MATURITY_TRAIN` — `docs/codex/batch-trains/SA01_SA32_SOURCE_ATLAS_FULL_MATURITY_TRAIN.md` (partial_implementation; release proof)
  - `SA_NEXT_ELIGIBLE_BATCH_PROMPT` — `docs/codex/batches/SA_NEXT_ELIGIBLE_BATCH_PROMPT.md` (partial_implementation; release proof)

### 264. Same source file targeted by multiple active items: scripts/si-readiness-gate.sh

- Conflict ID: `AMB28-same_source_file_targeted_by_multiple_active_batches-73705370`
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
  - `SI05_Hero_Step_Panel_System_Prompt` — `docs/codex/batches/SI05_Hero_Step_Panel_System_Prompt.md` (partial_implementation; release proof)
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
  - `SI17_Top_Level_Surface_Composition_Implementation_Prompt` — `docs/codex/batches/SI17_Top_Level_Surface_Composition_Implementation_Prompt.md` (partial_implementation; release proof)
  - `SI18_Signature_Interface_Handoff_And_Product_Depth_Readiness_Prompt` — `docs/codex/batches/SI18_Signature_Interface_Handoff_And_Product_Depth_Readiness_Prompt.md` (partial_implementation; release proof)

### 265. Same source file targeted by multiple active items: scripts/si-visual-qa-report.sh

- Conflict ID: `AMB28-same_source_file_targeted_by_multiple_active_batches-46411209`
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
  - `SI05_Hero_Step_Panel_System_Prompt` — `docs/codex/batches/SI05_Hero_Step_Panel_System_Prompt.md` (partial_implementation; release proof)
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
  - `SI17_Top_Level_Surface_Composition_Implementation_Prompt` — `docs/codex/batches/SI17_Top_Level_Surface_Composition_Implementation_Prompt.md` (partial_implementation; release proof)

### 266. Same source file targeted by multiple active items: scripts/swiftui-architecture-scan.sh

- Conflict ID: `AMB28-same_source_file_targeted_by_multiple_active_batches-54089190`
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
  - `AOS01_AmbitionsOS_Canon_And_Runtime_Contract_Prompt` — `docs/codex/batches/AOS01_AmbitionsOS_Canon_And_Runtime_Contract_Prompt.md` (partial_implementation; release proof)
  - `AOS02_Life_Graph_Event_Log_Foundation_Prompt` — `docs/codex/batches/AOS02_Life_Graph_Event_Log_Foundation_Prompt.md` (partial_implementation; release proof)
  - `AOS03_Graph_Delta_Review_Projection_Store_Prompt` — `docs/codex/batches/AOS03_Graph_Delta_Review_Projection_Store_Prompt.md` (partial_implementation; release proof)
  - `AOS04_Control_Plane_Work_Classifier_Prompt` — `docs/codex/batches/AOS04_Control_Plane_Work_Classifier_Prompt.md` (partial_implementation; release proof)
  - `AOS05_Starting_Position_Kernel_Prompt` — `docs/codex/batches/AOS05_Starting_Position_Kernel_Prompt.md` (partial_implementation; release proof)
  - `AOS06_Goal_Path_Kernel_Goal_Compiler_Prompt` — `docs/codex/batches/AOS06_Goal_Path_Kernel_Goal_Compiler_Prompt.md` (partial_implementation; release proof)
  - `AOS07_Local_Goal_Packs_Requirement_Slots_Prompt` — `docs/codex/batches/AOS07_Local_Goal_Packs_Requirement_Slots_Prompt.md` (partial_implementation; release proof)
  - `AOS08_Alternate_Path_Kernel_Path_Portfolio_Prompt` — `docs/codex/batches/AOS08_Alternate_Path_Kernel_Path_Portfolio_Prompt.md` (partial_implementation; release proof)
  - `AOS09_Option_Value_North_Star_Prompt` — `docs/codex/batches/AOS09_Option_Value_North_Star_Prompt.md` (partial_implementation; release proof)
  - `AOS10_Commitment_Time_Kernel_Prompt` — `docs/codex/batches/AOS10_Commitment_Time_Kernel_Prompt.md` (partial_implementation; release proof)
  - `AOS11_Reality_Drift_Bounded_Reflow_Prompt` — `docs/codex/batches/AOS11_Reality_Drift_Bounded_Reflow_Prompt.md` (partial_implementation; release proof)
  - `AOS12_Proof_Trust_Closure_Receipts_Prompt` — `docs/codex/batches/AOS12_Proof_Trust_Closure_Receipts_Prompt.md` (partial_implementation; release proof)
  - `AOS13_Source_Truth_Claim_State_Machine_Prompt` — `docs/codex/batches/AOS13_Source_Truth_Claim_State_Machine_Prompt.md` (partial_implementation; release proof)
  - `AOS14_Recommendation_Start_Here_Kernel_Prompt` — `docs/codex/batches/AOS14_Recommendation_Start_Here_Kernel_Prompt.md` (partial_implementation; release proof)
  - `AOS15_Local_Language_Kernel_Planning_Prompt` — `docs/codex/batches/AOS15_Local_Language_Kernel_Planning_Prompt.md` (partial_implementation; release proof)
  - `AOS16_Performance_Energy_Kernel_Prompt` — `docs/codex/batches/AOS16_Performance_Energy_Kernel_Prompt.md` (partial_implementation; release proof)
  - `AOS17_Privacy_Safety_Kernel_Prompt` — `docs/codex/batches/AOS17_Privacy_Safety_Kernel_Prompt.md` (partial_implementation; release proof)
  - `AOS18_Evaluation_Golden_Scenarios_Prompt` — `docs/codex/batches/AOS18_Evaluation_Golden_Scenarios_Prompt.md` (partial_implementation; release proof)
  - `AOS19_Experience_Kernel_Celestial_Cognitive_Load_Prompt` — `docs/codex/batches/AOS19_Experience_Kernel_Celestial_Cognitive_Load_Prompt.md` (partial_implementation; release proof)
  - `AOS20_Adaptation_Kernel_Local_Personalization_Prompt` — `docs/codex/batches/AOS20_Adaptation_Kernel_Local_Personalization_Prompt.md` (partial_implementation; release proof)
  - `AOS21_Interoperability_Kernel_App_Intents_EventKit_Planning_Prompt` — `docs/codex/batches/AOS21_Interoperability_Kernel_App_Intents_EventKit_Planning_Prompt.md` (partial_implementation; release proof)
  - `AOS22_Longevity_Kernel_Archive_Aging_Prompt` — `docs/codex/batches/AOS22_Longevity_Kernel_Archive_Aging_Prompt.md` (partial_implementation; release proof)
  - `AOS23_Governance_Kernel_Registry_Prompt` — `docs/codex/batches/AOS23_Governance_Kernel_Registry_Prompt.md` (partial_implementation; release proof)
  - `AOS24_AmbitionsOS_UI_Integration_Prompt` — `docs/codex/batches/AOS24_AmbitionsOS_UI_Integration_Prompt.md` (partial_implementation; release proof)
  - `AOS25_AmbitionsOS_Test_Fixture_Library_Prompt` — `docs/codex/batches/AOS25_AmbitionsOS_Test_Fixture_Library_Prompt.md` (partial_implementation; release proof)
  - `AOS26_AmbitionsOS_Privacy_Performance_QA_Prompt` — `docs/codex/batches/AOS26_AmbitionsOS_Privacy_Performance_QA_Prompt.md` (partial_implementation; release proof)
  - `AOS27_AmbitionsOS_App_Store_Claim_Truth_Prompt` — `docs/codex/batches/AOS27_AmbitionsOS_App_Store_Claim_Truth_Prompt.md` (partial_implementation; release proof)
  - ... 21 more

### 267. Same source file targeted by multiple active items: scripts/test-local.sh

- Conflict ID: `AMB28-same_source_file_targeted_by_multiple_active_batches-56479248`
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

### 268. Same source file targeted by multiple active items: scripts/validate-dev-tools.sh

- Conflict ID: `AMB28-same_source_file_targeted_by_multiple_active_batches-39578311`
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

### 269. Same source file targeted by multiple active items: scripts/validate-gate-result-manifest.py

- Conflict ID: `AMB28-same_source_file_targeted_by_multiple_active_batches-26740420`
- Type: `same_source_file_targeted_by_multiple_active_batches`
- Severity: `yellow`
- Recommended action: `merge`
- Rationale: Multiple active ledger items reference the same source file; merge, sequence, or assign ownership before implementation.
- Linear issue ready: `True`
- Auto-resolved: `False`
- Involved:
  - `CODEX_QUALITY_SYSTEM_BATCH_REPORT_TEMPLATE` — `docs/codex/CODEX_QUALITY_SYSTEM_BATCH_REPORT_TEMPLATE.md` (partial_implementation; release proof)
  - `GATE_SYSTEM_HARDENING_NEXT_PROMPT` — `docs/codex/batches/GATE_SYSTEM_HARDENING_NEXT_PROMPT.md` (partial_implementation; release proof)

### 270. Same source file targeted by multiple active items: scripts/validate-repo-authority.sh

- Conflict ID: `AMB28-same_source_file_targeted_by_multiple_active_batches-86629836`
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

### 1. Retired IA/terminology reference in AFI03_Flagship_Object_Silhouettes

- Conflict ID: `AMB28-retired_ia_or_terminology_reference-97708000`
- Type: `retired_ia_or_terminology_reference`
- Severity: `yellow`
- Recommended action: `rewrite`
- Rationale: Retired IA or product language should be rewritten or explicitly quarantined before this work becomes active.
- Linear issue ready: `True`
- Auto-resolved: `False`
- Involved:
  - `AFI03_Flagship_Object_Silhouettes` — `docs/codex/batches/AFI03_Flagship_Object_Silhouettes.md` (partial_implementation; release proof)

### 2. Retired IA/terminology reference in AFI06_Today_Reality_Meridian

- Conflict ID: `AMB28-retired_ia_or_terminology_reference-25030685`
- Type: `retired_ia_or_terminology_reference`
- Severity: `yellow`
- Recommended action: `rewrite`
- Rationale: Retired IA or product language should be rewritten or explicitly quarantined before this work becomes active.
- Linear issue ready: `True`
- Auto-resolved: `False`
- Involved:
  - `AFI06_Today_Reality_Meridian` — `docs/codex/batches/AFI06_Today_Reality_Meridian.md` (partial_implementation; release proof)

### 3. Retired IA/terminology reference in AFI07_Goals_Constellation_Atlas

- Conflict ID: `AMB28-retired_ia_or_terminology_reference-63267693`
- Type: `retired_ia_or_terminology_reference`
- Severity: `yellow`
- Recommended action: `rewrite`
- Rationale: Retired IA or product language should be rewritten or explicitly quarantined before this work becomes active.
- Linear issue ready: `True`
- Auto-resolved: `False`
- Involved:
  - `AFI07_Goals_Constellation_Atlas` — `docs/codex/batches/AFI07_Goals_Constellation_Atlas.md` (partial_implementation; release proof)

### 4. Retired IA/terminology reference in AFI15_Founder_Acceptance_Review

- Conflict ID: `AMB28-retired_ia_or_terminology_reference-21202158`
- Type: `retired_ia_or_terminology_reference`
- Severity: `yellow`
- Recommended action: `rewrite`
- Rationale: Retired IA or product language should be rewritten or explicitly quarantined before this work becomes active.
- Linear issue ready: `True`
- Auto-resolved: `False`
- Involved:
  - `AFI15_Founder_Acceptance_Review` — `docs/codex/batches/AFI15_Founder_Acceptance_Review.md` (partial_implementation; release proof)

### 5. Retired IA/terminology reference in AMB-CHATGPT-REPO-OS-UPGRADE-INSTALL-01

- Conflict ID: `AMB28-retired_ia_or_terminology_reference-3940871`
- Type: `retired_ia_or_terminology_reference`
- Severity: `yellow`
- Recommended action: `rewrite`
- Rationale: Retired IA or product language should be rewritten or explicitly quarantined before this work becomes active.
- Linear issue ready: `True`
- Auto-resolved: `False`
- Involved:
  - `AMB-CHATGPT-REPO-OS-UPGRADE-INSTALL-01` — `docs/codex/reports/AMB-CHATGPT-REPO-OS-UPGRADE-INSTALL-01.md` (partial_implementation; release proof)

### 6. Retired IA/terminology reference in AMB-CODEX-OS-FLAGSHIP-UPGRADE-INSTALL-01

- Conflict ID: `AMB28-retired_ia_or_terminology_reference-73978046`
- Type: `retired_ia_or_terminology_reference`
- Severity: `yellow`
- Recommended action: `rewrite`
- Rationale: Retired IA or product language should be rewritten or explicitly quarantined before this work becomes active.
- Linear issue ready: `True`
- Auto-resolved: `False`
- Involved:
  - `AMB-CODEX-OS-FLAGSHIP-UPGRADE-INSTALL-01` — `prompts/batches/AMB-CODEX-OS-FLAGSHIP-UPGRADE-INSTALL-01.md` (partial_implementation; release proof)

### 7. Retired IA/terminology reference in AMB-FE-BE-MOAT-SCENARIO-PROOF-98

- Conflict ID: `AMB28-retired_ia_or_terminology_reference-14771014`
- Type: `retired_ia_or_terminology_reference`
- Severity: `yellow`
- Recommended action: `rewrite`
- Rationale: Retired IA or product language should be rewritten or explicitly quarantined before this work becomes active.
- Linear issue ready: `True`
- Auto-resolved: `False`
- Involved:
  - `AMB-FE-BE-MOAT-SCENARIO-PROOF-98` — `prompts/batches/amb-fe-be/AMB-FE-BE-MOAT-SCENARIO-PROOF-98.md` (partial_implementation; release proof)

### 8. Retired IA/terminology reference in AMB-ISSUE-TEMPLATES

- Conflict ID: `AMB28-retired_ia_or_terminology_reference-58443040`
- Type: `retired_ia_or_terminology_reference`
- Severity: `yellow`
- Recommended action: `rewrite`
- Rationale: Retired IA or product language should be rewritten or explicitly quarantined before this work becomes active.
- Linear issue ready: `True`
- Auto-resolved: `False`
- Involved:
  - `AMB-ISSUE-TEMPLATES` — `docs/codex/linear-templates/AMB-ISSUE-TEMPLATES.md` (partial_implementation; release proof)

### 9. Retired IA/terminology reference in AMB-LINEAR-TEMPLATE-MANIFEST

- Conflict ID: `AMB28-retired_ia_or_terminology_reference-63531664`
- Type: `retired_ia_or_terminology_reference`
- Severity: `yellow`
- Recommended action: `rewrite`
- Rationale: Retired IA or product language should be rewritten or explicitly quarantined before this work becomes active.
- Linear issue ready: `True`
- Auto-resolved: `False`
- Involved:
  - `AMB-LINEAR-TEMPLATE-MANIFEST` — `docs/codex/linear-templates/AMB-LINEAR-TEMPLATE-MANIFEST.yml` (partial_implementation; release proof)

### 10. Retired IA/terminology reference in AMB-POST23-02-UNDERDELIVERY-REPAIR

- Conflict ID: `AMB28-retired_ia_or_terminology_reference-52374927`
- Type: `retired_ia_or_terminology_reference`
- Severity: `yellow`
- Recommended action: `rewrite`
- Rationale: Retired IA or product language should be rewritten or explicitly quarantined before this work becomes active.
- Linear issue ready: `True`
- Auto-resolved: `False`
- Involved:
  - `AMB-POST23-02-UNDERDELIVERY-REPAIR` — `docs/codex/reports/AMB-POST23-02-UNDERDELIVERY-REPAIR.md` (partial_implementation; release proof)

### 11. Retired IA/terminology reference in AMB-POST23-TRUTH-AUDIT-REPAIR-ROUTING

- Conflict ID: `AMB28-retired_ia_or_terminology_reference-59518727`
- Type: `retired_ia_or_terminology_reference`
- Severity: `yellow`
- Recommended action: `rewrite`
- Rationale: Retired IA or product language should be rewritten or explicitly quarantined before this work becomes active.
- Linear issue ready: `True`
- Auto-resolved: `False`
- Involved:
  - `AMB-POST23-TRUTH-AUDIT-REPAIR-ROUTING` — `docs/codex/batch-trains/post-23-truth-audit/AMB-POST23-TRUTH-AUDIT-REPAIR-ROUTING.md` (partial_implementation; release proof)

### 12. Retired IA/terminology reference in AMB-REPO-GREEN-FLAGSHIP-RESET-MASTER-01-T07-UI-PRIMITIVE-ORG

- Conflict ID: `AMB28-retired_ia_or_terminology_reference-95735940`
- Type: `retired_ia_or_terminology_reference`
- Severity: `yellow`
- Recommended action: `rewrite`
- Rationale: Retired IA or product language should be rewritten or explicitly quarantined before this work becomes active.
- Linear issue ready: `True`
- Auto-resolved: `False`
- Involved:
  - `AMB-REPO-GREEN-FLAGSHIP-RESET-MASTER-01-T07-UI-PRIMITIVE-ORG` — `prompts/batches/AMB-REPO-GREEN-FLAGSHIP-RESET-MASTER-01-T07-UI-PRIMITIVE-ORG.md` (partial_implementation; release proof)

### 13. Retired IA/terminology reference in AMB-REPO-GREEN-FLAGSHIP-RESET-MASTER-01-T09-GOALS-EXTRACTION

- Conflict ID: `AMB28-retired_ia_or_terminology_reference-21554091`
- Type: `retired_ia_or_terminology_reference`
- Severity: `yellow`
- Recommended action: `rewrite`
- Rationale: Retired IA or product language should be rewritten or explicitly quarantined before this work becomes active.
- Linear issue ready: `True`
- Auto-resolved: `False`
- Involved:
  - `AMB-REPO-GREEN-FLAGSHIP-RESET-MASTER-01-T09-GOALS-EXTRACTION` — `prompts/batches/AMB-REPO-GREEN-FLAGSHIP-RESET-MASTER-01-T09-GOALS-EXTRACTION.md` (partial_implementation; release proof)

### 14. Retired IA/terminology reference in AMBITIONSOS_SURFACE_ENCAPSULATION_MATRIX

- Conflict ID: `AMB28-retired_ia_or_terminology_reference-80756898`
- Type: `retired_ia_or_terminology_reference`
- Severity: `yellow`
- Recommended action: `rewrite`
- Rationale: Retired IA or product language should be rewritten or explicitly quarantined before this work becomes active.
- Linear issue ready: `True`
- Auto-resolved: `False`
- Involved:
  - `AMBITIONSOS_SURFACE_ENCAPSULATION_MATRIX` — `docs/codex/AMBITIONSOS_SURFACE_ENCAPSULATION_MATRIX.md` (partial_implementation; release proof)

### 15. Retired IA/terminology reference in AMBITIONS_SIGNATURE_LANGUAGE_SYSTEM

- Conflict ID: `AMB28-retired_ia_or_terminology_reference-94115032`
- Type: `retired_ia_or_terminology_reference`
- Severity: `yellow`
- Recommended action: `rewrite`
- Rationale: Retired IA or product language should be rewritten or explicitly quarantined before this work becomes active.
- Linear issue ready: `True`
- Auto-resolved: `False`
- Involved:
  - `AMBITIONS_SIGNATURE_LANGUAGE_SYSTEM` — `docs/codex/AMBITIONS_SIGNATURE_LANGUAGE_SYSTEM.md` (partial_implementation; release proof)

### 16. Retired IA/terminology reference in AMB_GLOBAL_REMAINING_TRAIN_BLUEPRINT

- Conflict ID: `AMB28-retired_ia_or_terminology_reference-21796894`
- Type: `retired_ia_or_terminology_reference`
- Severity: `yellow`
- Recommended action: `rewrite`
- Rationale: Retired IA or product language should be rewritten or explicitly quarantined before this work becomes active.
- Linear issue ready: `True`
- Auto-resolved: `False`
- Involved:
  - `AMB_GLOBAL_REMAINING_TRAIN_BLUEPRINT` — `docs/codex/AMB_GLOBAL_REMAINING_TRAIN_BLUEPRINT.json` (unknown; tests)

### 17. Retired IA/terminology reference in AOS01_AOS30_AMBITIONSOS_LOCAL_INTELLIGENCE_TRAIN

- Conflict ID: `AMB28-retired_ia_or_terminology_reference-83976495`
- Type: `retired_ia_or_terminology_reference`
- Severity: `yellow`
- Recommended action: `rewrite`
- Rationale: Retired IA or product language should be rewritten or explicitly quarantined before this work becomes active.
- Linear issue ready: `True`
- Auto-resolved: `False`
- Involved:
  - `AOS01_AOS30_AMBITIONSOS_LOCAL_INTELLIGENCE_TRAIN` — `docs/codex/batch-trains/AOS01_AOS30_AMBITIONSOS_LOCAL_INTELLIGENCE_TRAIN.md` (partial_implementation; release proof)

### 18. Retired IA/terminology reference in AOS01_AmbitionsOS_Canon_And_Runtime_Contract_Prompt

- Conflict ID: `AMB28-retired_ia_or_terminology_reference-1018455`
- Type: `retired_ia_or_terminology_reference`
- Severity: `yellow`
- Recommended action: `rewrite`
- Rationale: Retired IA or product language should be rewritten or explicitly quarantined before this work becomes active.
- Linear issue ready: `True`
- Auto-resolved: `False`
- Involved:
  - `AOS01_AmbitionsOS_Canon_And_Runtime_Contract_Prompt` — `docs/codex/batches/AOS01_AmbitionsOS_Canon_And_Runtime_Contract_Prompt.md` (partial_implementation; release proof)

### 19. Retired IA/terminology reference in AOS02_Life_Graph_Event_Log_Foundation_Prompt

- Conflict ID: `AMB28-retired_ia_or_terminology_reference-56479392`
- Type: `retired_ia_or_terminology_reference`
- Severity: `yellow`
- Recommended action: `rewrite`
- Rationale: Retired IA or product language should be rewritten or explicitly quarantined before this work becomes active.
- Linear issue ready: `True`
- Auto-resolved: `False`
- Involved:
  - `AOS02_Life_Graph_Event_Log_Foundation_Prompt` — `docs/codex/batches/AOS02_Life_Graph_Event_Log_Foundation_Prompt.md` (partial_implementation; release proof)

### 20. Retired IA/terminology reference in AOS03_Graph_Delta_Review_Projection_Store_Prompt

- Conflict ID: `AMB28-retired_ia_or_terminology_reference-13047099`
- Type: `retired_ia_or_terminology_reference`
- Severity: `yellow`
- Recommended action: `rewrite`
- Rationale: Retired IA or product language should be rewritten or explicitly quarantined before this work becomes active.
- Linear issue ready: `True`
- Auto-resolved: `False`
- Involved:
  - `AOS03_Graph_Delta_Review_Projection_Store_Prompt` — `docs/codex/batches/AOS03_Graph_Delta_Review_Projection_Store_Prompt.md` (partial_implementation; release proof)

### 21. Retired IA/terminology reference in AOS04_Control_Plane_Work_Classifier_Prompt

- Conflict ID: `AMB28-retired_ia_or_terminology_reference-66492330`
- Type: `retired_ia_or_terminology_reference`
- Severity: `yellow`
- Recommended action: `rewrite`
- Rationale: Retired IA or product language should be rewritten or explicitly quarantined before this work becomes active.
- Linear issue ready: `True`
- Auto-resolved: `False`
- Involved:
  - `AOS04_Control_Plane_Work_Classifier_Prompt` — `docs/codex/batches/AOS04_Control_Plane_Work_Classifier_Prompt.md` (partial_implementation; release proof)

### 22. Retired IA/terminology reference in AOS05_Starting_Position_Kernel_Prompt

- Conflict ID: `AMB28-retired_ia_or_terminology_reference-94791644`
- Type: `retired_ia_or_terminology_reference`
- Severity: `yellow`
- Recommended action: `rewrite`
- Rationale: Retired IA or product language should be rewritten or explicitly quarantined before this work becomes active.
- Linear issue ready: `True`
- Auto-resolved: `False`
- Involved:
  - `AOS05_Starting_Position_Kernel_Prompt` — `docs/codex/batches/AOS05_Starting_Position_Kernel_Prompt.md` (partial_implementation; release proof)

### 23. Retired IA/terminology reference in AOS06_Goal_Path_Kernel_Goal_Compiler_Prompt

- Conflict ID: `AMB28-retired_ia_or_terminology_reference-63080298`
- Type: `retired_ia_or_terminology_reference`
- Severity: `yellow`
- Recommended action: `rewrite`
- Rationale: Retired IA or product language should be rewritten or explicitly quarantined before this work becomes active.
- Linear issue ready: `True`
- Auto-resolved: `False`
- Involved:
  - `AOS06_Goal_Path_Kernel_Goal_Compiler_Prompt` — `docs/codex/batches/AOS06_Goal_Path_Kernel_Goal_Compiler_Prompt.md` (partial_implementation; release proof)

### 24. Retired IA/terminology reference in AOS07_Local_Goal_Packs_Requirement_Slots_Prompt

- Conflict ID: `AMB28-retired_ia_or_terminology_reference-83860669`
- Type: `retired_ia_or_terminology_reference`
- Severity: `yellow`
- Recommended action: `rewrite`
- Rationale: Retired IA or product language should be rewritten or explicitly quarantined before this work becomes active.
- Linear issue ready: `True`
- Auto-resolved: `False`
- Involved:
  - `AOS07_Local_Goal_Packs_Requirement_Slots_Prompt` — `docs/codex/batches/AOS07_Local_Goal_Packs_Requirement_Slots_Prompt.md` (partial_implementation; release proof)

### 25. Retired IA/terminology reference in AOS08_Alternate_Path_Kernel_Path_Portfolio_Prompt

- Conflict ID: `AMB28-retired_ia_or_terminology_reference-93438815`
- Type: `retired_ia_or_terminology_reference`
- Severity: `yellow`
- Recommended action: `rewrite`
- Rationale: Retired IA or product language should be rewritten or explicitly quarantined before this work becomes active.
- Linear issue ready: `True`
- Auto-resolved: `False`
- Involved:
  - `AOS08_Alternate_Path_Kernel_Path_Portfolio_Prompt` — `docs/codex/batches/AOS08_Alternate_Path_Kernel_Path_Portfolio_Prompt.md` (partial_implementation; release proof)

### 26. Retired IA/terminology reference in AOS09_Option_Value_North_Star_Prompt

- Conflict ID: `AMB28-retired_ia_or_terminology_reference-30575872`
- Type: `retired_ia_or_terminology_reference`
- Severity: `yellow`
- Recommended action: `rewrite`
- Rationale: Retired IA or product language should be rewritten or explicitly quarantined before this work becomes active.
- Linear issue ready: `True`
- Auto-resolved: `False`
- Involved:
  - `AOS09_Option_Value_North_Star_Prompt` — `docs/codex/batches/AOS09_Option_Value_North_Star_Prompt.md` (partial_implementation; release proof)

### 27. Retired IA/terminology reference in AOS10_Commitment_Time_Kernel_Prompt

- Conflict ID: `AMB28-retired_ia_or_terminology_reference-80570046`
- Type: `retired_ia_or_terminology_reference`
- Severity: `yellow`
- Recommended action: `rewrite`
- Rationale: Retired IA or product language should be rewritten or explicitly quarantined before this work becomes active.
- Linear issue ready: `True`
- Auto-resolved: `False`
- Involved:
  - `AOS10_Commitment_Time_Kernel_Prompt` — `docs/codex/batches/AOS10_Commitment_Time_Kernel_Prompt.md` (partial_implementation; release proof)

### 28. Retired IA/terminology reference in AOS11_Reality_Drift_Bounded_Reflow_Prompt

- Conflict ID: `AMB28-retired_ia_or_terminology_reference-23898376`
- Type: `retired_ia_or_terminology_reference`
- Severity: `yellow`
- Recommended action: `rewrite`
- Rationale: Retired IA or product language should be rewritten or explicitly quarantined before this work becomes active.
- Linear issue ready: `True`
- Auto-resolved: `False`
- Involved:
  - `AOS11_Reality_Drift_Bounded_Reflow_Prompt` — `docs/codex/batches/AOS11_Reality_Drift_Bounded_Reflow_Prompt.md` (partial_implementation; release proof)

### 29. Retired IA/terminology reference in AOS12_Proof_Trust_Closure_Receipts_Prompt

- Conflict ID: `AMB28-retired_ia_or_terminology_reference-72884380`
- Type: `retired_ia_or_terminology_reference`
- Severity: `yellow`
- Recommended action: `rewrite`
- Rationale: Retired IA or product language should be rewritten or explicitly quarantined before this work becomes active.
- Linear issue ready: `True`
- Auto-resolved: `False`
- Involved:
  - `AOS12_Proof_Trust_Closure_Receipts_Prompt` — `docs/codex/batches/AOS12_Proof_Trust_Closure_Receipts_Prompt.md` (partial_implementation; release proof)

### 30. Retired IA/terminology reference in AOS13_Source_Truth_Claim_State_Machine_Prompt

- Conflict ID: `AMB28-retired_ia_or_terminology_reference-5496680`
- Type: `retired_ia_or_terminology_reference`
- Severity: `yellow`
- Recommended action: `rewrite`
- Rationale: Retired IA or product language should be rewritten or explicitly quarantined before this work becomes active.
- Linear issue ready: `True`
- Auto-resolved: `False`
- Involved:
  - `AOS13_Source_Truth_Claim_State_Machine_Prompt` — `docs/codex/batches/AOS13_Source_Truth_Claim_State_Machine_Prompt.md` (partial_implementation; release proof)

### 31. Retired IA/terminology reference in AOS14_Recommendation_Start_Here_Kernel_Prompt

- Conflict ID: `AMB28-retired_ia_or_terminology_reference-24734364`
- Type: `retired_ia_or_terminology_reference`
- Severity: `yellow`
- Recommended action: `rewrite`
- Rationale: Retired IA or product language should be rewritten or explicitly quarantined before this work becomes active.
- Linear issue ready: `True`
- Auto-resolved: `False`
- Involved:
  - `AOS14_Recommendation_Start_Here_Kernel_Prompt` — `docs/codex/batches/AOS14_Recommendation_Start_Here_Kernel_Prompt.md` (partial_implementation; release proof)

### 32. Retired IA/terminology reference in AOS15_Local_Language_Kernel_Planning_Prompt

- Conflict ID: `AMB28-retired_ia_or_terminology_reference-14467225`
- Type: `retired_ia_or_terminology_reference`
- Severity: `yellow`
- Recommended action: `rewrite`
- Rationale: Retired IA or product language should be rewritten or explicitly quarantined before this work becomes active.
- Linear issue ready: `True`
- Auto-resolved: `False`
- Involved:
  - `AOS15_Local_Language_Kernel_Planning_Prompt` — `docs/codex/batches/AOS15_Local_Language_Kernel_Planning_Prompt.md` (partial_implementation; release proof)

### 33. Retired IA/terminology reference in AOS16_Performance_Energy_Kernel_Prompt

- Conflict ID: `AMB28-retired_ia_or_terminology_reference-4931381`
- Type: `retired_ia_or_terminology_reference`
- Severity: `yellow`
- Recommended action: `rewrite`
- Rationale: Retired IA or product language should be rewritten or explicitly quarantined before this work becomes active.
- Linear issue ready: `True`
- Auto-resolved: `False`
- Involved:
  - `AOS16_Performance_Energy_Kernel_Prompt` — `docs/codex/batches/AOS16_Performance_Energy_Kernel_Prompt.md` (partial_implementation; release proof)

### 34. Retired IA/terminology reference in AOS17_Privacy_Safety_Kernel_Prompt

- Conflict ID: `AMB28-retired_ia_or_terminology_reference-49782297`
- Type: `retired_ia_or_terminology_reference`
- Severity: `yellow`
- Recommended action: `rewrite`
- Rationale: Retired IA or product language should be rewritten or explicitly quarantined before this work becomes active.
- Linear issue ready: `True`
- Auto-resolved: `False`
- Involved:
  - `AOS17_Privacy_Safety_Kernel_Prompt` — `docs/codex/batches/AOS17_Privacy_Safety_Kernel_Prompt.md` (partial_implementation; release proof)

### 35. Retired IA/terminology reference in AOS18_Evaluation_Golden_Scenarios_Prompt

- Conflict ID: `AMB28-retired_ia_or_terminology_reference-22506337`
- Type: `retired_ia_or_terminology_reference`
- Severity: `yellow`
- Recommended action: `rewrite`
- Rationale: Retired IA or product language should be rewritten or explicitly quarantined before this work becomes active.
- Linear issue ready: `True`
- Auto-resolved: `False`
- Involved:
  - `AOS18_Evaluation_Golden_Scenarios_Prompt` — `docs/codex/batches/AOS18_Evaluation_Golden_Scenarios_Prompt.md` (partial_implementation; release proof)

### 36. Retired IA/terminology reference in AOS19_Experience_Kernel_Celestial_Cognitive_Load_Prompt

- Conflict ID: `AMB28-retired_ia_or_terminology_reference-67832822`
- Type: `retired_ia_or_terminology_reference`
- Severity: `yellow`
- Recommended action: `rewrite`
- Rationale: Retired IA or product language should be rewritten or explicitly quarantined before this work becomes active.
- Linear issue ready: `True`
- Auto-resolved: `False`
- Involved:
  - `AOS19_Experience_Kernel_Celestial_Cognitive_Load_Prompt` — `docs/codex/batches/AOS19_Experience_Kernel_Celestial_Cognitive_Load_Prompt.md` (partial_implementation; release proof)

### 37. Retired IA/terminology reference in AOS20_Adaptation_Kernel_Local_Personalization_Prompt

- Conflict ID: `AMB28-retired_ia_or_terminology_reference-62233019`
- Type: `retired_ia_or_terminology_reference`
- Severity: `yellow`
- Recommended action: `rewrite`
- Rationale: Retired IA or product language should be rewritten or explicitly quarantined before this work becomes active.
- Linear issue ready: `True`
- Auto-resolved: `False`
- Involved:
  - `AOS20_Adaptation_Kernel_Local_Personalization_Prompt` — `docs/codex/batches/AOS20_Adaptation_Kernel_Local_Personalization_Prompt.md` (partial_implementation; release proof)

### 38. Retired IA/terminology reference in AOS21_Interoperability_Kernel_App_Intents_EventKit_Planning_Prompt

- Conflict ID: `AMB28-retired_ia_or_terminology_reference-15462745`
- Type: `retired_ia_or_terminology_reference`
- Severity: `yellow`
- Recommended action: `rewrite`
- Rationale: Retired IA or product language should be rewritten or explicitly quarantined before this work becomes active.
- Linear issue ready: `True`
- Auto-resolved: `False`
- Involved:
  - `AOS21_Interoperability_Kernel_App_Intents_EventKit_Planning_Prompt` — `docs/codex/batches/AOS21_Interoperability_Kernel_App_Intents_EventKit_Planning_Prompt.md` (partial_implementation; release proof)

### 39. Retired IA/terminology reference in AOS22_Longevity_Kernel_Archive_Aging_Prompt

- Conflict ID: `AMB28-retired_ia_or_terminology_reference-13636896`
- Type: `retired_ia_or_terminology_reference`
- Severity: `yellow`
- Recommended action: `rewrite`
- Rationale: Retired IA or product language should be rewritten or explicitly quarantined before this work becomes active.
- Linear issue ready: `True`
- Auto-resolved: `False`
- Involved:
  - `AOS22_Longevity_Kernel_Archive_Aging_Prompt` — `docs/codex/batches/AOS22_Longevity_Kernel_Archive_Aging_Prompt.md` (partial_implementation; release proof)

### 40. Retired IA/terminology reference in AOS23_Governance_Kernel_Registry_Prompt

- Conflict ID: `AMB28-retired_ia_or_terminology_reference-78194795`
- Type: `retired_ia_or_terminology_reference`
- Severity: `yellow`
- Recommended action: `rewrite`
- Rationale: Retired IA or product language should be rewritten or explicitly quarantined before this work becomes active.
- Linear issue ready: `True`
- Auto-resolved: `False`
- Involved:
  - `AOS23_Governance_Kernel_Registry_Prompt` — `docs/codex/batches/AOS23_Governance_Kernel_Registry_Prompt.md` (partial_implementation; release proof)

### 41. Retired IA/terminology reference in AOS24_AmbitionsOS_UI_Integration_Prompt

- Conflict ID: `AMB28-retired_ia_or_terminology_reference-92559355`
- Type: `retired_ia_or_terminology_reference`
- Severity: `yellow`
- Recommended action: `rewrite`
- Rationale: Retired IA or product language should be rewritten or explicitly quarantined before this work becomes active.
- Linear issue ready: `True`
- Auto-resolved: `False`
- Involved:
  - `AOS24_AmbitionsOS_UI_Integration_Prompt` — `docs/codex/batches/AOS24_AmbitionsOS_UI_Integration_Prompt.md` (partial_implementation; release proof)

### 42. Retired IA/terminology reference in AOS25_AmbitionsOS_Test_Fixture_Library_Prompt

- Conflict ID: `AMB28-retired_ia_or_terminology_reference-56283895`
- Type: `retired_ia_or_terminology_reference`
- Severity: `yellow`
- Recommended action: `rewrite`
- Rationale: Retired IA or product language should be rewritten or explicitly quarantined before this work becomes active.
- Linear issue ready: `True`
- Auto-resolved: `False`
- Involved:
  - `AOS25_AmbitionsOS_Test_Fixture_Library_Prompt` — `docs/codex/batches/AOS25_AmbitionsOS_Test_Fixture_Library_Prompt.md` (partial_implementation; release proof)

### 43. Retired IA/terminology reference in AOS26_AmbitionsOS_Privacy_Performance_QA_Prompt

- Conflict ID: `AMB28-retired_ia_or_terminology_reference-67499145`
- Type: `retired_ia_or_terminology_reference`
- Severity: `yellow`
- Recommended action: `rewrite`
- Rationale: Retired IA or product language should be rewritten or explicitly quarantined before this work becomes active.
- Linear issue ready: `True`
- Auto-resolved: `False`
- Involved:
  - `AOS26_AmbitionsOS_Privacy_Performance_QA_Prompt` — `docs/codex/batches/AOS26_AmbitionsOS_Privacy_Performance_QA_Prompt.md` (partial_implementation; release proof)

### 44. Retired IA/terminology reference in AOS27_AmbitionsOS_App_Store_Claim_Truth_Prompt

- Conflict ID: `AMB28-retired_ia_or_terminology_reference-94290133`
- Type: `retired_ia_or_terminology_reference`
- Severity: `yellow`
- Recommended action: `rewrite`
- Rationale: Retired IA or product language should be rewritten or explicitly quarantined before this work becomes active.
- Linear issue ready: `True`
- Auto-resolved: `False`
- Involved:
  - `AOS27_AmbitionsOS_App_Store_Claim_Truth_Prompt` — `docs/codex/batches/AOS27_AmbitionsOS_App_Store_Claim_Truth_Prompt.md` (partial_implementation; release proof)

### 45. Retired IA/terminology reference in AOS28_AmbitionsOS_Handoff_Prompt

- Conflict ID: `AMB28-retired_ia_or_terminology_reference-10857956`
- Type: `retired_ia_or_terminology_reference`
- Severity: `yellow`
- Recommended action: `rewrite`
- Rationale: Retired IA or product language should be rewritten or explicitly quarantined before this work becomes active.
- Linear issue ready: `True`
- Auto-resolved: `False`
- Involved:
  - `AOS28_AmbitionsOS_Handoff_Prompt` — `docs/codex/batches/AOS28_AmbitionsOS_Handoff_Prompt.md` (partial_implementation; release proof)

### 46. Retired IA/terminology reference in AOS29_AmbitionsOS_Repair_Train_Prompt

- Conflict ID: `AMB28-retired_ia_or_terminology_reference-81883364`
- Type: `retired_ia_or_terminology_reference`
- Severity: `yellow`
- Recommended action: `rewrite`
- Rationale: Retired IA or product language should be rewritten or explicitly quarantined before this work becomes active.
- Linear issue ready: `True`
- Auto-resolved: `False`
- Involved:
  - `AOS29_AmbitionsOS_Repair_Train_Prompt` — `docs/codex/batches/AOS29_AmbitionsOS_Repair_Train_Prompt.md` (partial_implementation; release proof)

### 47. Retired IA/terminology reference in AOS30_AmbitionsOS_Beyond_Roadmap_Prompt

- Conflict ID: `AMB28-retired_ia_or_terminology_reference-26831905`
- Type: `retired_ia_or_terminology_reference`
- Severity: `yellow`
- Recommended action: `rewrite`
- Rationale: Retired IA or product language should be rewritten or explicitly quarantined before this work becomes active.
- Linear issue ready: `True`
- Auto-resolved: `False`
- Involved:
  - `AOS30_AmbitionsOS_Beyond_Roadmap_Prompt` — `docs/codex/batches/AOS30_AmbitionsOS_Beyond_Roadmap_Prompt.md` (partial_implementation; release proof)

### 48. Retired IA/terminology reference in AQOS01_AQOS30_AUTONOMOUS_QUALITY_TRAIN

- Conflict ID: `AMB28-retired_ia_or_terminology_reference-9901355`
- Type: `retired_ia_or_terminology_reference`
- Severity: `yellow`
- Recommended action: `rewrite`
- Rationale: Retired IA or product language should be rewritten or explicitly quarantined before this work becomes active.
- Linear issue ready: `True`
- Auto-resolved: `False`
- Involved:
  - `AQOS01_AQOS30_AUTONOMOUS_QUALITY_TRAIN` — `docs/codex/quality/AQOS01_AQOS30_AUTONOMOUS_QUALITY_TRAIN.md` (unknown; release proof)

### 49. Retired IA/terminology reference in AQOS_AUTONOMOUS_QUALITY_CONTINUATION_PROMPT

- Conflict ID: `AMB28-retired_ia_or_terminology_reference-71287080`
- Type: `retired_ia_or_terminology_reference`
- Severity: `yellow`
- Recommended action: `rewrite`
- Rationale: Retired IA or product language should be rewritten or explicitly quarantined before this work becomes active.
- Linear issue ready: `True`
- Auto-resolved: `False`
- Involved:
  - `AQOS_AUTONOMOUS_QUALITY_CONTINUATION_PROMPT` — `docs/codex/batches/AQOS_AUTONOMOUS_QUALITY_CONTINUATION_PROMPT.md` (partial_implementation; release proof)

### 50. Retired IA/terminology reference in AQOS_AUTONOMOUS_QUALITY_COUNCIL

- Conflict ID: `AMB28-retired_ia_or_terminology_reference-64961065`
- Type: `retired_ia_or_terminology_reference`
- Severity: `yellow`
- Recommended action: `rewrite`
- Rationale: Retired IA or product language should be rewritten or explicitly quarantined before this work becomes active.
- Linear issue ready: `True`
- Auto-resolved: `False`
- Involved:
  - `AQOS_AUTONOMOUS_QUALITY_COUNCIL` — `docs/codex/quality/AQOS_AUTONOMOUS_QUALITY_COUNCIL.md` (partial_implementation; release proof)

### 51. Retired IA/terminology reference in AQOS_AUTONOMOUS_QUALITY_OPERATING_SYSTEM

- Conflict ID: `AMB28-retired_ia_or_terminology_reference-50900713`
- Type: `retired_ia_or_terminology_reference`
- Severity: `yellow`
- Recommended action: `rewrite`
- Rationale: Retired IA or product language should be rewritten or explicitly quarantined before this work becomes active.
- Linear issue ready: `True`
- Auto-resolved: `False`
- Involved:
  - `AQOS_AUTONOMOUS_QUALITY_OPERATING_SYSTEM` — `docs/codex/quality/AQOS_AUTONOMOUS_QUALITY_OPERATING_SYSTEM.md` (partial_implementation; release proof)

### 52. Retired IA/terminology reference in AQOS_REPAIR_BATCH_GENERATOR_PROTOCOL

- Conflict ID: `AMB28-retired_ia_or_terminology_reference-20683341`
- Type: `retired_ia_or_terminology_reference`
- Severity: `yellow`
- Recommended action: `rewrite`
- Rationale: Retired IA or product language should be rewritten or explicitly quarantined before this work becomes active.
- Linear issue ready: `True`
- Auto-resolved: `False`
- Involved:
  - `AQOS_REPAIR_BATCH_GENERATOR_PROTOCOL` — `docs/codex/quality/AQOS_REPAIR_BATCH_GENERATOR_PROTOCOL.md` (partial_implementation; release proof)

### 53. Retired IA/terminology reference in AQOS_REQUIRED_EVIDENCE_MATRIX

- Conflict ID: `AMB28-retired_ia_or_terminology_reference-57430125`
- Type: `retired_ia_or_terminology_reference`
- Severity: `yellow`
- Recommended action: `rewrite`
- Rationale: Retired IA or product language should be rewritten or explicitly quarantined before this work becomes active.
- Linear issue ready: `True`
- Auto-resolved: `False`
- Involved:
  - `AQOS_REQUIRED_EVIDENCE_MATRIX` — `docs/codex/quality/AQOS_REQUIRED_EVIDENCE_MATRIX.md` (partial_implementation; release proof)

### 54. Retired IA/terminology reference in AQOS_SCRIPT_AND_TOOL_MAP

- Conflict ID: `AMB28-retired_ia_or_terminology_reference-89341282`
- Type: `retired_ia_or_terminology_reference`
- Severity: `yellow`
- Recommended action: `rewrite`
- Rationale: Retired IA or product language should be rewritten or explicitly quarantined before this work becomes active.
- Linear issue ready: `True`
- Auto-resolved: `False`
- Involved:
  - `AQOS_SCRIPT_AND_TOOL_MAP` — `docs/codex/quality/AQOS_SCRIPT_AND_TOOL_MAP.md` (partial_implementation; release proof)

### 55. Retired IA/terminology reference in BATCH-16-canon-batch-13-shared-life-household-intelligence

- Conflict ID: `AMB28-retired_ia_or_terminology_reference-23331329`
- Type: `retired_ia_or_terminology_reference`
- Severity: `yellow`
- Recommended action: `rewrite`
- Rationale: Retired IA or product language should be rewritten or explicitly quarantined before this work becomes active.
- Linear issue ready: `True`
- Auto-resolved: `False`
- Involved:
  - `BATCH-16-canon-batch-13-shared-life-household-intelligence` — `docs/codex/batches/BATCH-16-canon-batch-13-shared-life-household-intelligence.md` (unknown; release proof)

### 56. Retired IA/terminology reference in CHROME-AUDIT-01

- Conflict ID: `AMB28-retired_ia_or_terminology_reference-77120008`
- Type: `retired_ia_or_terminology_reference`
- Severity: `yellow`
- Recommended action: `rewrite`
- Rationale: Retired IA or product language should be rewritten or explicitly quarantined before this work becomes active.
- Linear issue ready: `True`
- Auto-resolved: `False`
- Involved:
  - `CHROME-AUDIT-01` — `prompts/batches/CHROME-AUDIT-01.md` (partial_implementation; release proof)

### 57. Retired IA/terminology reference in CODEX-OS-GOVERNANCE-FULL-AUTONOMY-INTEGRATION-01

- Conflict ID: `AMB28-retired_ia_or_terminology_reference-60162119`
- Type: `retired_ia_or_terminology_reference`
- Severity: `yellow`
- Recommended action: `rewrite`
- Rationale: Retired IA or product language should be rewritten or explicitly quarantined before this work becomes active.
- Linear issue ready: `True`
- Auto-resolved: `False`
- Involved:
  - `CODEX-OS-GOVERNANCE-FULL-AUTONOMY-INTEGRATION-01` — `prompts/batches/CODEX-OS-GOVERNANCE-FULL-AUTONOMY-INTEGRATION-01.md` (partial_implementation; release proof)

### 58. Retired IA/terminology reference in CODEX_QUALITY_SYSTEM_BATCH_REPORT_TEMPLATE

- Conflict ID: `AMB28-retired_ia_or_terminology_reference-54396187`
- Type: `retired_ia_or_terminology_reference`
- Severity: `yellow`
- Recommended action: `rewrite`
- Rationale: Retired IA or product language should be rewritten or explicitly quarantined before this work becomes active.
- Linear issue ready: `True`
- Auto-resolved: `False`
- Involved:
  - `CODEX_QUALITY_SYSTEM_BATCH_REPORT_TEMPLATE` — `docs/codex/CODEX_QUALITY_SYSTEM_BATCH_REPORT_TEMPLATE.md` (partial_implementation; release proof)

### 59. Retired IA/terminology reference in CODEX_VISUAL_QA_PROTOCOL

- Conflict ID: `AMB28-retired_ia_or_terminology_reference-40594677`
- Type: `retired_ia_or_terminology_reference`
- Severity: `yellow`
- Recommended action: `rewrite`
- Rationale: Retired IA or product language should be rewritten or explicitly quarantined before this work becomes active.
- Linear issue ready: `True`
- Auto-resolved: `False`
- Involved:
  - `CODEX_VISUAL_QA_PROTOCOL` — `docs/codex/CODEX_VISUAL_QA_PROTOCOL.md` (unknown; release proof)

### 60. Retired IA/terminology reference in DAV03_Today_DayTimelineRail_And_HeroStepPanel_Implementation_Prompt

- Conflict ID: `AMB28-retired_ia_or_terminology_reference-42680856`
- Type: `retired_ia_or_terminology_reference`
- Severity: `yellow`
- Recommended action: `rewrite`
- Rationale: Retired IA or product language should be rewritten or explicitly quarantined before this work becomes active.
- Linear issue ready: `True`
- Auto-resolved: `False`
- Involved:
  - `DAV03_Today_DayTimelineRail_And_HeroStepPanel_Implementation_Prompt` — `docs/codex/batches/DAV03_Today_DayTimelineRail_And_HeroStepPanel_Implementation_Prompt.md` (partial_implementation; release proof)

### 61. Retired IA/terminology reference in DAV05_Plan_LifeShapeMap_And_CapacityVisuals_Implementation_Prompt

- Conflict ID: `AMB28-retired_ia_or_terminology_reference-74249518`
- Type: `retired_ia_or_terminology_reference`
- Severity: `yellow`
- Recommended action: `rewrite`
- Rationale: Retired IA or product language should be rewritten or explicitly quarantined before this work becomes active.
- Linear issue ready: `True`
- Auto-resolved: `False`
- Involved:
  - `DAV05_Plan_LifeShapeMap_And_CapacityVisuals_Implementation_Prompt` — `docs/codex/batches/DAV05_Plan_LifeShapeMap_And_CapacityVisuals_Implementation_Prompt.md` (partial_implementation; release proof)

### 62. Retired IA/terminology reference in DAV06_Goals_MissionControlLanes_Implementation_Prompt

- Conflict ID: `AMB28-retired_ia_or_terminology_reference-92635073`
- Type: `retired_ia_or_terminology_reference`
- Severity: `yellow`
- Recommended action: `rewrite`
- Rationale: Retired IA or product language should be rewritten or explicitly quarantined before this work becomes active.
- Linear issue ready: `True`
- Auto-resolved: `False`
- Involved:
  - `DAV06_Goals_MissionControlLanes_Implementation_Prompt` — `docs/codex/batches/DAV06_Goals_MissionControlLanes_Implementation_Prompt.md` (partial_implementation; release proof)

### 63. Retired IA/terminology reference in DAV_DYNAMIC_VISUAL_SOURCE_TRUTH_AND_SURFACE_MAP

- Conflict ID: `AMB28-retired_ia_or_terminology_reference-15909831`
- Type: `retired_ia_or_terminology_reference`
- Severity: `yellow`
- Recommended action: `rewrite`
- Rationale: Retired IA or product language should be rewritten or explicitly quarantined before this work becomes active.
- Linear issue ready: `True`
- Auto-resolved: `False`
- Involved:
  - `DAV_DYNAMIC_VISUAL_SOURCE_TRUTH_AND_SURFACE_MAP` — `docs/codex/DAV_DYNAMIC_VISUAL_SOURCE_TRUTH_AND_SURFACE_MAP.md` (partial_implementation; release proof)

### 64. Retired IA/terminology reference in FAANG_FRONTEND_IMPLEMENTATION_OPERATING_SYSTEM

- Conflict ID: `AMB28-retired_ia_or_terminology_reference-93949665`
- Type: `retired_ia_or_terminology_reference`
- Severity: `yellow`
- Recommended action: `rewrite`
- Rationale: Retired IA or product language should be rewritten or explicitly quarantined before this work becomes active.
- Linear issue ready: `True`
- Auto-resolved: `False`
- Involved:
  - `FAANG_FRONTEND_IMPLEMENTATION_OPERATING_SYSTEM` — `docs/codex/FAANG_FRONTEND_IMPLEMENTATION_OPERATING_SYSTEM.md` (partial_implementation; release proof)

### 65. Retired IA/terminology reference in FAANG_FRONTEND_IMPLEMENTATION_TEAM_OPERATING_SYSTEM

- Conflict ID: `AMB28-retired_ia_or_terminology_reference-21672468`
- Type: `retired_ia_or_terminology_reference`
- Severity: `yellow`
- Recommended action: `rewrite`
- Rationale: Retired IA or product language should be rewritten or explicitly quarantined before this work becomes active.
- Linear issue ready: `True`
- Auto-resolved: `False`
- Involved:
  - `FAANG_FRONTEND_IMPLEMENTATION_TEAM_OPERATING_SYSTEM` — `docs/codex/frontend-implementation/FAANG_FRONTEND_IMPLEMENTATION_TEAM_OPERATING_SYSTEM.md` (partial_implementation; release proof)

### 66. Retired IA/terminology reference in FCP01_FCP30_FLAGSHIP_COMPLETION_TRAIN

- Conflict ID: `AMB28-retired_ia_or_terminology_reference-5784230`
- Type: `retired_ia_or_terminology_reference`
- Severity: `yellow`
- Recommended action: `rewrite`
- Rationale: Retired IA or product language should be rewritten or explicitly quarantined before this work becomes active.
- Linear issue ready: `True`
- Auto-resolved: `False`
- Involved:
  - `FCP01_FCP30_FLAGSHIP_COMPLETION_TRAIN` — `docs/codex/batch-trains/FCP01_FCP30_FLAGSHIP_COMPLETION_TRAIN.md` (partial_implementation; release proof)

### 67. Retired IA/terminology reference in FE-02-DESIGN-LANGUAGE

- Conflict ID: `AMB28-retired_ia_or_terminology_reference-99578734`
- Type: `retired_ia_or_terminology_reference`
- Severity: `yellow`
- Recommended action: `rewrite`
- Rationale: Retired IA or product language should be rewritten or explicitly quarantined before this work becomes active.
- Linear issue ready: `True`
- Auto-resolved: `False`
- Involved:
  - `FE-02-DESIGN-LANGUAGE` — `prompts/batches/amb-fe-be/FE-02-DESIGN-LANGUAGE.md` (partial_implementation; release proof)

### 68. Retired IA/terminology reference in FE-07-ROOT-SURFACES

- Conflict ID: `AMB28-retired_ia_or_terminology_reference-54971450`
- Type: `retired_ia_or_terminology_reference`
- Severity: `yellow`
- Recommended action: `rewrite`
- Rationale: Retired IA or product language should be rewritten or explicitly quarantined before this work becomes active.
- Linear issue ready: `True`
- Auto-resolved: `False`
- Involved:
  - `FE-07-ROOT-SURFACES` — `prompts/batches/amb-fe-be/FE-07-ROOT-SURFACES.md` (partial_implementation; release proof)

### 69. Retired IA/terminology reference in FL01_FL06_FOUND_LIFE_LAYER_TRAIN

- Conflict ID: `AMB28-retired_ia_or_terminology_reference-60709516`
- Type: `retired_ia_or_terminology_reference`
- Severity: `yellow`
- Recommended action: `rewrite`
- Rationale: Retired IA or product language should be rewritten or explicitly quarantined before this work becomes active.
- Linear issue ready: `True`
- Auto-resolved: `False`
- Involved:
  - `FL01_FL06_FOUND_LIFE_LAYER_TRAIN` — `docs/codex/batch-trains/FL01_FL06_FOUND_LIFE_LAYER_TRAIN.md` (partial_implementation; release proof)

### 70. Retired IA/terminology reference in FL06_Weekly_Life_Sweep_Ritual_Prompt

- Conflict ID: `AMB28-retired_ia_or_terminology_reference-66089523`
- Type: `retired_ia_or_terminology_reference`
- Severity: `yellow`
- Recommended action: `rewrite`
- Rationale: Retired IA or product language should be rewritten or explicitly quarantined before this work becomes active.
- Linear issue ready: `True`
- Auto-resolved: `False`
- Involved:
  - `FL06_Weekly_Life_Sweep_Ritual_Prompt` — `docs/codex/batches/FL06_Weekly_Life_Sweep_Ritual_Prompt.md` (partial_implementation; release proof)

### 71. Retired IA/terminology reference in FLAGSHIP_COMPLETION_FILE_BOUNDARY_MAP

- Conflict ID: `AMB28-retired_ia_or_terminology_reference-30522578`
- Type: `retired_ia_or_terminology_reference`
- Severity: `yellow`
- Recommended action: `rewrite`
- Rationale: Retired IA or product language should be rewritten or explicitly quarantined before this work becomes active.
- Linear issue ready: `True`
- Auto-resolved: `False`
- Involved:
  - `FLAGSHIP_COMPLETION_FILE_BOUNDARY_MAP` — `docs/codex/FLAGSHIP_COMPLETION_FILE_BOUNDARY_MAP.md` (partial_implementation; release proof)

### 72. Retired IA/terminology reference in FLAGSHIP_COMPLETION_OBJECT_SCORECARD

- Conflict ID: `AMB28-retired_ia_or_terminology_reference-32367166`
- Type: `retired_ia_or_terminology_reference`
- Severity: `yellow`
- Recommended action: `rewrite`
- Rationale: Retired IA or product language should be rewritten or explicitly quarantined before this work becomes active.
- Linear issue ready: `True`
- Auto-resolved: `False`
- Involved:
  - `FLAGSHIP_COMPLETION_OBJECT_SCORECARD` — `docs/codex/FLAGSHIP_COMPLETION_OBJECT_SCORECARD.md` (partial_implementation; release proof)

### 73. Retired IA/terminology reference in FOUND_LIFE_LAYER_GATE_MATRIX

- Conflict ID: `AMB28-retired_ia_or_terminology_reference-92415539`
- Type: `retired_ia_or_terminology_reference`
- Severity: `yellow`
- Recommended action: `rewrite`
- Rationale: Retired IA or product language should be rewritten or explicitly quarantined before this work becomes active.
- Linear issue ready: `True`
- Auto-resolved: `False`
- Involved:
  - `FOUND_LIFE_LAYER_GATE_MATRIX` — `docs/codex/FOUND_LIFE_LAYER_GATE_MATRIX.md` (partial_implementation; release proof)

### 74. Retired IA/terminology reference in FRONTEND_PRIMITIVE_MISUSE_AND_DENSITY_GATE

- Conflict ID: `AMB28-retired_ia_or_terminology_reference-50937006`
- Type: `retired_ia_or_terminology_reference`
- Severity: `yellow`
- Recommended action: `rewrite`
- Rationale: Retired IA or product language should be rewritten or explicitly quarantined before this work becomes active.
- Linear issue ready: `True`
- Auto-resolved: `False`
- Involved:
  - `FRONTEND_PRIMITIVE_MISUSE_AND_DENSITY_GATE` — `docs/codex/FRONTEND_PRIMITIVE_MISUSE_AND_DENSITY_GATE.md` (unknown; release proof)

### 75. Retired IA/terminology reference in FVQ01_RENDERED_VISUAL_FRESHNESS_AND_FLAGSHIP_GATE

- Conflict ID: `AMB28-retired_ia_or_terminology_reference-41499153`
- Type: `retired_ia_or_terminology_reference`
- Severity: `yellow`
- Recommended action: `rewrite`
- Rationale: Retired IA or product language should be rewritten or explicitly quarantined before this work becomes active.
- Linear issue ready: `True`
- Auto-resolved: `False`
- Involved:
  - `FVQ01_RENDERED_VISUAL_FRESHNESS_AND_FLAGSHIP_GATE` — `docs/codex/visual-quality/FVQ01_RENDERED_VISUAL_FRESHNESS_AND_FLAGSHIP_GATE.md` (partial_implementation; release proof)

### 76. Retired IA/terminology reference in FVQ01_RENDERED_VISUAL_FRESHNESS_AND_FLAGSHIP_PROMPT

- Conflict ID: `AMB28-retired_ia_or_terminology_reference-9888299`
- Type: `retired_ia_or_terminology_reference`
- Severity: `yellow`
- Recommended action: `rewrite`
- Rationale: Retired IA or product language should be rewritten or explicitly quarantined before this work becomes active.
- Linear issue ready: `True`
- Auto-resolved: `False`
- Involved:
  - `FVQ01_RENDERED_VISUAL_FRESHNESS_AND_FLAGSHIP_PROMPT` — `docs/codex/batches/FVQ01_RENDERED_VISUAL_FRESHNESS_AND_FLAGSHIP_PROMPT.md` (partial_implementation; release proof)

### 77. Retired IA/terminology reference in FVQ02_TOP_LEVEL_SURFACE_VISUAL_SWEEP

- Conflict ID: `AMB28-retired_ia_or_terminology_reference-96864649`
- Type: `retired_ia_or_terminology_reference`
- Severity: `yellow`
- Recommended action: `rewrite`
- Rationale: Retired IA or product language should be rewritten or explicitly quarantined before this work becomes active.
- Linear issue ready: `True`
- Auto-resolved: `False`
- Involved:
  - `FVQ02_TOP_LEVEL_SURFACE_VISUAL_SWEEP` — `docs/codex/visual-quality/FVQ02_TOP_LEVEL_SURFACE_VISUAL_SWEEP.md` (unknown; release proof)

### 78. Retired IA/terminology reference in FVQ03_DRILLDOWN_AND_EXTERNAL_SURFACE_VISUAL_SWEEP

- Conflict ID: `AMB28-retired_ia_or_terminology_reference-16768161`
- Type: `retired_ia_or_terminology_reference`
- Severity: `yellow`
- Recommended action: `rewrite`
- Rationale: Retired IA or product language should be rewritten or explicitly quarantined before this work becomes active.
- Linear issue ready: `True`
- Auto-resolved: `False`
- Involved:
  - `FVQ03_DRILLDOWN_AND_EXTERNAL_SURFACE_VISUAL_SWEEP` — `docs/codex/visual-quality/FVQ03_DRILLDOWN_AND_EXTERNAL_SURFACE_VISUAL_SWEEP.md` (partial_implementation; release proof)

### 79. Retired IA/terminology reference in FVQ04_RECURRING_UI_BATCH_RENDERED_PROOF_PROTOCOL

- Conflict ID: `AMB28-retired_ia_or_terminology_reference-65049020`
- Type: `retired_ia_or_terminology_reference`
- Severity: `yellow`
- Recommended action: `rewrite`
- Rationale: Retired IA or product language should be rewritten or explicitly quarantined before this work becomes active.
- Linear issue ready: `True`
- Auto-resolved: `False`
- Involved:
  - `FVQ04_RECURRING_UI_BATCH_RENDERED_PROOF_PROTOCOL` — `docs/codex/visual-quality/FVQ04_RECURRING_UI_BATCH_RENDERED_PROOF_PROTOCOL.md` (partial_implementation; release proof)

### 80. Retired IA/terminology reference in FVQ_VISUAL_EXCELLENCE_CONTINUATION_PROMPT

- Conflict ID: `AMB28-retired_ia_or_terminology_reference-57852694`
- Type: `retired_ia_or_terminology_reference`
- Severity: `yellow`
- Recommended action: `rewrite`
- Rationale: Retired IA or product language should be rewritten or explicitly quarantined before this work becomes active.
- Linear issue ready: `True`
- Auto-resolved: `False`
- Involved:
  - `FVQ_VISUAL_EXCELLENCE_CONTINUATION_PROMPT` — `docs/codex/batches/FVQ_VISUAL_EXCELLENCE_CONTINUATION_PROMPT.md` (partial_implementation; release proof)

### 81. Retired IA/terminology reference in FVQ_VISUAL_EXCELLENCE_TRAIN

- Conflict ID: `AMB28-retired_ia_or_terminology_reference-12654711`
- Type: `retired_ia_or_terminology_reference`
- Severity: `yellow`
- Recommended action: `rewrite`
- Rationale: Retired IA or product language should be rewritten or explicitly quarantined before this work becomes active.
- Linear issue ready: `True`
- Auto-resolved: `False`
- Involved:
  - `FVQ_VISUAL_EXCELLENCE_TRAIN` — `docs/codex/visual-quality/FVQ_VISUAL_EXCELLENCE_TRAIN.md` (partial_implementation; release proof)

### 82. Retired IA/terminology reference in GLOBAL-BATCH-TRAIN-AUTONOMOUS-COMPLETE-01

- Conflict ID: `AMB28-retired_ia_or_terminology_reference-74875326`
- Type: `retired_ia_or_terminology_reference`
- Severity: `yellow`
- Recommended action: `rewrite`
- Rationale: Retired IA or product language should be rewritten or explicitly quarantined before this work becomes active.
- Linear issue ready: `True`
- Auto-resolved: `False`
- Involved:
  - `GLOBAL-BATCH-TRAIN-AUTONOMOUS-COMPLETE-01` — `prompts/batches/GLOBAL-BATCH-TRAIN-AUTONOMOUS-COMPLETE-01.md` (partial_implementation; release proof)

### 83. Retired IA/terminology reference in GLOBAL-VISUAL-CANON-MOAT-INSTALL-TRAIN-01

- Conflict ID: `AMB28-retired_ia_or_terminology_reference-65625107`
- Type: `retired_ia_or_terminology_reference`
- Severity: `yellow`
- Recommended action: `rewrite`
- Rationale: Retired IA or product language should be rewritten or explicitly quarantined before this work becomes active.
- Linear issue ready: `True`
- Auto-resolved: `False`
- Involved:
  - `GLOBAL-VISUAL-CANON-MOAT-INSTALL-TRAIN-01` — `prompts/batches/GLOBAL-VISUAL-CANON-MOAT-INSTALL-TRAIN-01.md` (partial_implementation; release proof)

### 84. Retired IA/terminology reference in GLOBAL_AUTONOMOUS_QUALITY_OVERLAY

- Conflict ID: `AMB28-retired_ia_or_terminology_reference-91229146`
- Type: `retired_ia_or_terminology_reference`
- Severity: `yellow`
- Recommended action: `rewrite`
- Rationale: Retired IA or product language should be rewritten or explicitly quarantined before this work becomes active.
- Linear issue ready: `True`
- Auto-resolved: `False`
- Involved:
  - `GLOBAL_AUTONOMOUS_QUALITY_OVERLAY` — `docs/codex/GLOBAL_AUTONOMOUS_QUALITY_OVERLAY.md` (partial_implementation; release proof)

### 85. Retired IA/terminology reference in GLOBAL_BATCH_EXECUTION_ORCHESTRATOR

- Conflict ID: `AMB28-retired_ia_or_terminology_reference-37136745`
- Type: `retired_ia_or_terminology_reference`
- Severity: `yellow`
- Recommended action: `rewrite`
- Rationale: Retired IA or product language should be rewritten or explicitly quarantined before this work becomes active.
- Linear issue ready: `True`
- Auto-resolved: `False`
- Involved:
  - `GLOBAL_BATCH_EXECUTION_ORCHESTRATOR` — `docs/codex/GLOBAL_BATCH_EXECUTION_ORCHESTRATOR.md` (partial_implementation; release proof)

### 86. Retired IA/terminology reference in GLOBAL_FUTURE_BATCH_GATE_MATRIX

- Conflict ID: `AMB28-retired_ia_or_terminology_reference-39648739`
- Type: `retired_ia_or_terminology_reference`
- Severity: `yellow`
- Recommended action: `rewrite`
- Rationale: Retired IA or product language should be rewritten or explicitly quarantined before this work becomes active.
- Linear issue ready: `True`
- Auto-resolved: `False`
- Involved:
  - `GLOBAL_FUTURE_BATCH_GATE_MATRIX` — `docs/codex/GLOBAL_FUTURE_BATCH_GATE_MATRIX.md` (partial_implementation; release proof)

### 87. Retired IA/terminology reference in HISTORICAL_BASELINE_GLOBAL_TRAIN_MANIFEST

- Conflict ID: `AMB28-retired_ia_or_terminology_reference-13026724`
- Type: `retired_ia_or_terminology_reference`
- Severity: `yellow`
- Recommended action: `rewrite`
- Rationale: Retired IA or product language should be rewritten or explicitly quarantined before this work becomes active.
- Linear issue ready: `True`
- Auto-resolved: `False`
- Involved:
  - `HISTORICAL_BASELINE_GLOBAL_TRAIN_MANIFEST` — `docs/codex/HISTORICAL_BASELINE_GLOBAL_TRAIN_MANIFEST.json` (unknown; release proof)

### 88. Retired IA/terminology reference in HPS01_HPS12_HUMAN_PROGRESS_SYSTEMS_UPGRADE_TRAIN

- Conflict ID: `AMB28-retired_ia_or_terminology_reference-49165399`
- Type: `retired_ia_or_terminology_reference`
- Severity: `yellow`
- Recommended action: `rewrite`
- Rationale: Retired IA or product language should be rewritten or explicitly quarantined before this work becomes active.
- Linear issue ready: `True`
- Auto-resolved: `False`
- Involved:
  - `HPS01_HPS12_HUMAN_PROGRESS_SYSTEMS_UPGRADE_TRAIN` — `docs/codex/batch-trains/HPS01_HPS12_HUMAN_PROGRESS_SYSTEMS_UPGRADE_TRAIN.md` (partial_implementation; release proof)

### 89. Retired IA/terminology reference in HPS_CROSS_TRAIN_INTEGRATION_MAP

- Conflict ID: `AMB28-retired_ia_or_terminology_reference-71025933`
- Type: `retired_ia_or_terminology_reference`
- Severity: `yellow`
- Recommended action: `rewrite`
- Rationale: Retired IA or product language should be rewritten or explicitly quarantined before this work becomes active.
- Linear issue ready: `True`
- Auto-resolved: `False`
- Involved:
  - `HPS_CROSS_TRAIN_INTEGRATION_MAP` — `docs/codex/HPS_CROSS_TRAIN_INTEGRATION_MAP.md` (partial_implementation; release proof)

### 90. Retired IA/terminology reference in HPS_GATE_MATRIX

- Conflict ID: `AMB28-retired_ia_or_terminology_reference-54746946`
- Type: `retired_ia_or_terminology_reference`
- Severity: `yellow`
- Recommended action: `rewrite`
- Rationale: Retired IA or product language should be rewritten or explicitly quarantined before this work becomes active.
- Linear issue ready: `True`
- Auto-resolved: `False`
- Involved:
  - `HPS_GATE_MATRIX` — `docs/codex/HPS_GATE_MATRIX.md` (partial_implementation; release proof)

### 91. Retired IA/terminology reference in HPS_NEXT_ELIGIBLE_BATCH_PROMPT

- Conflict ID: `AMB28-retired_ia_or_terminology_reference-17676454`
- Type: `retired_ia_or_terminology_reference`
- Severity: `yellow`
- Recommended action: `rewrite`
- Rationale: Retired IA or product language should be rewritten or explicitly quarantined before this work becomes active.
- Linear issue ready: `True`
- Auto-resolved: `False`
- Involved:
  - `HPS_NEXT_ELIGIBLE_BATCH_PROMPT` — `docs/codex/batches/HPS_NEXT_ELIGIBLE_BATCH_PROMPT.md` (partial_implementation; release proof)

### 92. Retired IA/terminology reference in IOS26_ANTI_CARD_VALIDATOR_SPEC

- Conflict ID: `AMB28-retired_ia_or_terminology_reference-98417959`
- Type: `retired_ia_or_terminology_reference`
- Severity: `yellow`
- Recommended action: `rewrite`
- Rationale: Retired IA or product language should be rewritten or explicitly quarantined before this work becomes active.
- Linear issue ready: `True`
- Auto-resolved: `False`
- Involved:
  - `IOS26_ANTI_CARD_VALIDATOR_SPEC` — `docs/codex/frontend/IOS26_ANTI_CARD_VALIDATOR_SPEC.md` (partial_implementation; release proof)

### 93. Retired IA/terminology reference in IOS26_EXISTING_BATCH_EXPANSION_DIRECTIVES

- Conflict ID: `AMB28-retired_ia_or_terminology_reference-7495891`
- Type: `retired_ia_or_terminology_reference`
- Severity: `yellow`
- Recommended action: `rewrite`
- Rationale: Retired IA or product language should be rewritten or explicitly quarantined before this work becomes active.
- Linear issue ready: `True`
- Auto-resolved: `False`
- Involved:
  - `IOS26_EXISTING_BATCH_EXPANSION_DIRECTIVES` — `docs/codex/frontend/IOS26_EXISTING_BATCH_EXPANSION_DIRECTIVES.md` (unknown; release proof)

### 94. Retired IA/terminology reference in IOS26_OBJECT_FRONTEND_BATCH_INSERTION_PLAN

- Conflict ID: `AMB28-retired_ia_or_terminology_reference-19450826`
- Type: `retired_ia_or_terminology_reference`
- Severity: `yellow`
- Recommended action: `rewrite`
- Rationale: Retired IA or product language should be rewritten or explicitly quarantined before this work becomes active.
- Linear issue ready: `True`
- Auto-resolved: `False`
- Involved:
  - `IOS26_OBJECT_FRONTEND_BATCH_INSERTION_PLAN` — `docs/codex/frontend/IOS26_OBJECT_FRONTEND_BATCH_INSERTION_PLAN.md` (partial_implementation; release proof)

### 95. Retired IA/terminology reference in IR-01-FRONTEND-RECOVERY-GATE

- Conflict ID: `AMB28-retired_ia_or_terminology_reference-6279795`
- Type: `retired_ia_or_terminology_reference`
- Severity: `yellow`
- Recommended action: `rewrite`
- Rationale: Retired IA or product language should be rewritten or explicitly quarantined before this work becomes active.
- Linear issue ready: `True`
- Auto-resolved: `False`
- Involved:
  - `IR-01-FRONTEND-RECOVERY-GATE` — `prompts/batches/IR-01-FRONTEND-RECOVERY-GATE.md` (partial_implementation; release proof)

### 96. Retired IA/terminology reference in IR01_FAANG_FRONTEND_INTERFACE_RECOVERY_PROMPT

- Conflict ID: `AMB28-retired_ia_or_terminology_reference-82417320`
- Type: `retired_ia_or_terminology_reference`
- Severity: `yellow`
- Recommended action: `rewrite`
- Rationale: Retired IA or product language should be rewritten or explicitly quarantined before this work becomes active.
- Linear issue ready: `True`
- Auto-resolved: `False`
- Involved:
  - `IR01_FAANG_FRONTEND_INTERFACE_RECOVERY_PROMPT` — `docs/codex/batches/IR01_FAANG_FRONTEND_INTERFACE_RECOVERY_PROMPT.md` (partial_implementation; release proof)

### 97. Retired IA/terminology reference in MOAT-ALIGNMENT-01

- Conflict ID: `AMB28-retired_ia_or_terminology_reference-38824517`
- Type: `retired_ia_or_terminology_reference`
- Severity: `yellow`
- Recommended action: `rewrite`
- Rationale: Retired IA or product language should be rewritten or explicitly quarantined before this work becomes active.
- Linear issue ready: `True`
- Auto-resolved: `False`
- Involved:
  - `MOAT-ALIGNMENT-01` — `prompts/batches/MOAT-ALIGNMENT-01.md` (partial_implementation; release proof)

### 98. Retired IA/terminology reference in MOAT-COMPLETE-AUTONOMOUS-01

- Conflict ID: `AMB28-retired_ia_or_terminology_reference-97625721`
- Type: `retired_ia_or_terminology_reference`
- Severity: `yellow`
- Recommended action: `rewrite`
- Rationale: Retired IA or product language should be rewritten or explicitly quarantined before this work becomes active.
- Linear issue ready: `True`
- Auto-resolved: `False`
- Involved:
  - `MOAT-COMPLETE-AUTONOMOUS-01` — `prompts/batches/MOAT-COMPLETE-AUTONOMOUS-01.md` (partial_implementation; release proof)

### 99. Retired IA/terminology reference in MOAT-GOAL-REALITY-CAPTURE-BRIDGE-04

- Conflict ID: `AMB28-retired_ia_or_terminology_reference-78818644`
- Type: `retired_ia_or_terminology_reference`
- Severity: `yellow`
- Recommended action: `rewrite`
- Rationale: Retired IA or product language should be rewritten or explicitly quarantined before this work becomes active.
- Linear issue ready: `True`
- Auto-resolved: `False`
- Involved:
  - `MOAT-GOAL-REALITY-CAPTURE-BRIDGE-04` — `prompts/batches/MOAT-GOAL-REALITY-CAPTURE-BRIDGE-04.md` (partial_implementation; release proof)

### 100. Retired IA/terminology reference in MOAT-GOAL-REALITY-GOALS-BRIDGE-05

- Conflict ID: `AMB28-retired_ia_or_terminology_reference-26251192`
- Type: `retired_ia_or_terminology_reference`
- Severity: `yellow`
- Recommended action: `rewrite`
- Rationale: Retired IA or product language should be rewritten or explicitly quarantined before this work becomes active.
- Linear issue ready: `True`
- Auto-resolved: `False`
- Involved:
  - `MOAT-GOAL-REALITY-GOALS-BRIDGE-05` — `prompts/batches/MOAT-GOAL-REALITY-GOALS-BRIDGE-05.md` (partial_implementation; release proof)

### 101. Retired IA/terminology reference in MOAT_RUNTIME_ACCEPTANCE_CRITERIA

- Conflict ID: `AMB28-retired_ia_or_terminology_reference-40217046`
- Type: `retired_ia_or_terminology_reference`
- Severity: `yellow`
- Recommended action: `rewrite`
- Rationale: Retired IA or product language should be rewritten or explicitly quarantined before this work becomes active.
- Linear issue ready: `True`
- Auto-resolved: `False`
- Involved:
  - `MOAT_RUNTIME_ACCEPTANCE_CRITERIA` — `docs/codex/MOAT_RUNTIME_ACCEPTANCE_CRITERIA.md` (partial_implementation; release proof)

### 102. Retired IA/terminology reference in MOAT_RUNTIME_BATCH_OVERLAY

- Conflict ID: `AMB28-retired_ia_or_terminology_reference-69319979`
- Type: `retired_ia_or_terminology_reference`
- Severity: `yellow`
- Recommended action: `rewrite`
- Rationale: Retired IA or product language should be rewritten or explicitly quarantined before this work becomes active.
- Linear issue ready: `True`
- Auto-resolved: `False`
- Involved:
  - `MOAT_RUNTIME_BATCH_OVERLAY` — `docs/codex/MOAT_RUNTIME_BATCH_OVERLAY.json` (partial_implementation; release proof)

### 103. Retired IA/terminology reference in MOAT_RUNTIME_GOLDEN_SCENARIOS

- Conflict ID: `AMB28-retired_ia_or_terminology_reference-92225986`
- Type: `retired_ia_or_terminology_reference`
- Severity: `yellow`
- Recommended action: `rewrite`
- Rationale: Retired IA or product language should be rewritten or explicitly quarantined before this work becomes active.
- Linear issue ready: `True`
- Auto-resolved: `False`
- Involved:
  - `MOAT_RUNTIME_GOLDEN_SCENARIOS` — `docs/codex/MOAT_RUNTIME_GOLDEN_SCENARIOS.md` (unknown; release proof)

### 104. Retired IA/terminology reference in OBJECT-OS-CANON-01

- Conflict ID: `AMB28-retired_ia_or_terminology_reference-78539941`
- Type: `retired_ia_or_terminology_reference`
- Severity: `yellow`
- Recommended action: `rewrite`
- Rationale: Retired IA or product language should be rewritten or explicitly quarantined before this work becomes active.
- Linear issue ready: `True`
- Auto-resolved: `False`
- Involved:
  - `OBJECT-OS-CANON-01` — `prompts/batches/OBJECT-OS-CANON-01.md` (partial_implementation; release proof)

### 105. Retired IA/terminology reference in OBJECT_FRONTEND_GREEN_YELLOW_RED_RUBRIC

- Conflict ID: `AMB28-retired_ia_or_terminology_reference-48361765`
- Type: `retired_ia_or_terminology_reference`
- Severity: `yellow`
- Recommended action: `rewrite`
- Rationale: Retired IA or product language should be rewritten or explicitly quarantined before this work becomes active.
- Linear issue ready: `True`
- Auto-resolved: `False`
- Involved:
  - `OBJECT_FRONTEND_GREEN_YELLOW_RED_RUBRIC` — `docs/codex/frontend/OBJECT_FRONTEND_GREEN_YELLOW_RED_RUBRIC.md` (partial_implementation; release proof)

### 106. Retired IA/terminology reference in OBJECT_OS_NATIVE_SURFACES

- Conflict ID: `AMB28-retired_ia_or_terminology_reference-62516525`
- Type: `retired_ia_or_terminology_reference`
- Severity: `yellow`
- Recommended action: `rewrite`
- Rationale: Retired IA or product language should be rewritten or explicitly quarantined before this work becomes active.
- Linear issue ready: `True`
- Auto-resolved: `False`
- Involved:
  - `OBJECT_OS_NATIVE_SURFACES` — `docs/codex/OBJECT_OS_NATIVE_SURFACES.md` (unknown; release proof)

### 107. Retired IA/terminology reference in OBJECT_OS_PRIMITIVES

- Conflict ID: `AMB28-retired_ia_or_terminology_reference-7414304`
- Type: `retired_ia_or_terminology_reference`
- Severity: `yellow`
- Recommended action: `rewrite`
- Rationale: Retired IA or product language should be rewritten or explicitly quarantined before this work becomes active.
- Linear issue ready: `True`
- Auto-resolved: `False`
- Involved:
  - `OBJECT_OS_PRIMITIVES` — `docs/codex/OBJECT_OS_PRIMITIVES.md` (partial_implementation; release proof)

### 108. Retired IA/terminology reference in OS-FLAGSHIP-04-VISUAL-QA-GATE

- Conflict ID: `AMB28-retired_ia_or_terminology_reference-24793238`
- Type: `retired_ia_or_terminology_reference`
- Severity: `yellow`
- Recommended action: `rewrite`
- Rationale: Retired IA or product language should be rewritten or explicitly quarantined before this work becomes active.
- Linear issue ready: `True`
- Auto-resolved: `False`
- Involved:
  - `OS-FLAGSHIP-04-VISUAL-QA-GATE` — `prompts/batches/OS-FLAGSHIP-04-VISUAL-QA-GATE.md` (partial_implementation; release proof)

### 109. Retired IA/terminology reference in PD01_PD18_PRODUCT_DEPTH_TRAIN

- Conflict ID: `AMB28-retired_ia_or_terminology_reference-48977404`
- Type: `retired_ia_or_terminology_reference`
- Severity: `yellow`
- Recommended action: `rewrite`
- Rationale: Retired IA or product language should be rewritten or explicitly quarantined before this work becomes active.
- Linear issue ready: `True`
- Auto-resolved: `False`
- Involved:
  - `PD01_PD18_PRODUCT_DEPTH_TRAIN` — `docs/codex/batch-trains/PD01_PD18_PRODUCT_DEPTH_TRAIN.md` (partial_implementation; release proof)

### 110. Retired IA/terminology reference in PD01_Product_Depth_Canon_Inventory_And_Ownership_Map_Prompt

- Conflict ID: `AMB28-retired_ia_or_terminology_reference-65900222`
- Type: `retired_ia_or_terminology_reference`
- Severity: `yellow`
- Recommended action: `rewrite`
- Rationale: Retired IA or product language should be rewritten or explicitly quarantined before this work becomes active.
- Linear issue ready: `True`
- Auto-resolved: `False`
- Involved:
  - `PD01_Product_Depth_Canon_Inventory_And_Ownership_Map_Prompt` — `docs/codex/batches/PD01_Product_Depth_Canon_Inventory_And_Ownership_Map_Prompt.md` (partial_implementation; release proof)

### 111. Retired IA/terminology reference in PD02_Today_Step_Detail_Depth_Prompt

- Conflict ID: `AMB28-retired_ia_or_terminology_reference-50558884`
- Type: `retired_ia_or_terminology_reference`
- Severity: `yellow`
- Recommended action: `rewrite`
- Rationale: Retired IA or product language should be rewritten or explicitly quarantined before this work becomes active.
- Linear issue ready: `True`
- Auto-resolved: `False`
- Involved:
  - `PD02_Today_Step_Detail_Depth_Prompt` — `docs/codex/batches/PD02_Today_Step_Detail_Depth_Prompt.md` (partial_implementation; release proof)

### 112. Retired IA/terminology reference in PD03_Today_Step_Session_Depth_Prompt

- Conflict ID: `AMB28-retired_ia_or_terminology_reference-60011638`
- Type: `retired_ia_or_terminology_reference`
- Severity: `yellow`
- Recommended action: `rewrite`
- Rationale: Retired IA or product language should be rewritten or explicitly quarantined before this work becomes active.
- Linear issue ready: `True`
- Auto-resolved: `False`
- Involved:
  - `PD03_Today_Step_Session_Depth_Prompt` — `docs/codex/batches/PD03_Today_Step_Session_Depth_Prompt.md` (partial_implementation; release proof)

### 113. Retired IA/terminology reference in PD04_Today_Recovery_And_Closure_Depth_Prompt

- Conflict ID: `AMB28-retired_ia_or_terminology_reference-4811542`
- Type: `retired_ia_or_terminology_reference`
- Severity: `yellow`
- Recommended action: `rewrite`
- Rationale: Retired IA or product language should be rewritten or explicitly quarantined before this work becomes active.
- Linear issue ready: `True`
- Auto-resolved: `False`
- Involved:
  - `PD04_Today_Recovery_And_Closure_Depth_Prompt` — `docs/codex/batches/PD04_Today_Recovery_And_Closure_Depth_Prompt.md` (partial_implementation; release proof)

### 114. Retired IA/terminology reference in PD05_Goals_Mission_Control_Detail_Architecture_Prompt

- Conflict ID: `AMB28-retired_ia_or_terminology_reference-26535804`
- Type: `retired_ia_or_terminology_reference`
- Severity: `yellow`
- Recommended action: `rewrite`
- Rationale: Retired IA or product language should be rewritten or explicitly quarantined before this work becomes active.
- Linear issue ready: `True`
- Auto-resolved: `False`
- Involved:
  - `PD05_Goals_Mission_Control_Detail_Architecture_Prompt` — `docs/codex/batches/PD05_Goals_Mission_Control_Detail_Architecture_Prompt.md` (partial_implementation; release proof)

### 115. Retired IA/terminology reference in PD06_Goal_Lifecycle_And_Path_Visualization_Prompt

- Conflict ID: `AMB28-retired_ia_or_terminology_reference-66069391`
- Type: `retired_ia_or_terminology_reference`
- Severity: `yellow`
- Recommended action: `rewrite`
- Rationale: Retired IA or product language should be rewritten or explicitly quarantined before this work becomes active.
- Linear issue ready: `True`
- Auto-resolved: `False`
- Involved:
  - `PD06_Goal_Lifecycle_And_Path_Visualization_Prompt` — `docs/codex/batches/PD06_Goal_Lifecycle_And_Path_Visualization_Prompt.md` (partial_implementation; release proof)

### 116. Retired IA/terminology reference in PD07_Goal_Proof_And_Decision_History_Depth_Prompt

- Conflict ID: `AMB28-retired_ia_or_terminology_reference-64200904`
- Type: `retired_ia_or_terminology_reference`
- Severity: `yellow`
- Recommended action: `rewrite`
- Rationale: Retired IA or product language should be rewritten or explicitly quarantined before this work becomes active.
- Linear issue ready: `True`
- Auto-resolved: `False`
- Involved:
  - `PD07_Goal_Proof_And_Decision_History_Depth_Prompt` — `docs/codex/batches/PD07_Goal_Proof_And_Decision_History_Depth_Prompt.md` (partial_implementation; release proof)

### 117. Retired IA/terminology reference in PD08_Goal_Alternate_Path_And_Tradeoff_Depth_Prompt

- Conflict ID: `AMB28-retired_ia_or_terminology_reference-66748525`
- Type: `retired_ia_or_terminology_reference`
- Severity: `yellow`
- Recommended action: `rewrite`
- Rationale: Retired IA or product language should be rewritten or explicitly quarantined before this work becomes active.
- Linear issue ready: `True`
- Auto-resolved: `False`
- Involved:
  - `PD08_Goal_Alternate_Path_And_Tradeoff_Depth_Prompt` — `docs/codex/batches/PD08_Goal_Alternate_Path_And_Tradeoff_Depth_Prompt.md` (partial_implementation; release proof)

### 118. Retired IA/terminology reference in PD09_Capture_Placement_Review_Prompt

- Conflict ID: `AMB28-retired_ia_or_terminology_reference-26095368`
- Type: `retired_ia_or_terminology_reference`
- Severity: `yellow`
- Recommended action: `rewrite`
- Rationale: Retired IA or product language should be rewritten or explicitly quarantined before this work becomes active.
- Linear issue ready: `True`
- Auto-resolved: `False`
- Involved:
  - `PD09_Capture_Placement_Review_Prompt` — `docs/codex/batches/PD09_Capture_Placement_Review_Prompt.md` (partial_implementation; release proof)

### 119. Retired IA/terminology reference in PD10_Capture_Correction_And_Confidence_Loops_Prompt

- Conflict ID: `AMB28-retired_ia_or_terminology_reference-24641936`
- Type: `retired_ia_or_terminology_reference`
- Severity: `yellow`
- Recommended action: `rewrite`
- Rationale: Retired IA or product language should be rewritten or explicitly quarantined before this work becomes active.
- Linear issue ready: `True`
- Auto-resolved: `False`
- Involved:
  - `PD10_Capture_Correction_And_Confidence_Loops_Prompt` — `docs/codex/batches/PD10_Capture_Correction_And_Confidence_Loops_Prompt.md` (partial_implementation; release proof)

### 120. Retired IA/terminology reference in PD11_Grow_Into_Goal_Flow_Prompt

- Conflict ID: `AMB28-retired_ia_or_terminology_reference-99853425`
- Type: `retired_ia_or_terminology_reference`
- Severity: `yellow`
- Recommended action: `rewrite`
- Rationale: Retired IA or product language should be rewritten or explicitly quarantined before this work becomes active.
- Linear issue ready: `True`
- Auto-resolved: `False`
- Involved:
  - `PD11_Grow_Into_Goal_Flow_Prompt` — `docs/codex/batches/PD11_Grow_Into_Goal_Flow_Prompt.md` (partial_implementation; release proof)

### 121. Retired IA/terminology reference in PD12_Plan_Reflow_Decision_Depth_Prompt

- Conflict ID: `AMB28-retired_ia_or_terminology_reference-86202332`
- Type: `retired_ia_or_terminology_reference`
- Severity: `yellow`
- Recommended action: `rewrite`
- Rationale: Retired IA or product language should be rewritten or explicitly quarantined before this work becomes active.
- Linear issue ready: `True`
- Auto-resolved: `False`
- Involved:
  - `PD12_Plan_Reflow_Decision_Depth_Prompt` — `docs/codex/batches/PD12_Plan_Reflow_Decision_Depth_Prompt.md` (partial_implementation; release proof)

### 122. Retired IA/terminology reference in PD13_Plan_Recovery_And_Pressure_Review_Prompt

- Conflict ID: `AMB28-retired_ia_or_terminology_reference-3579178`
- Type: `retired_ia_or_terminology_reference`
- Severity: `yellow`
- Recommended action: `rewrite`
- Rationale: Retired IA or product language should be rewritten or explicitly quarantined before this work becomes active.
- Linear issue ready: `True`
- Auto-resolved: `False`
- Involved:
  - `PD13_Plan_Recovery_And_Pressure_Review_Prompt` — `docs/codex/batches/PD13_Plan_Recovery_And_Pressure_Review_Prompt.md` (partial_implementation; release proof)

### 123. Retired IA/terminology reference in PD14_Life_Shape_Drilldowns_Prompt

- Conflict ID: `AMB28-retired_ia_or_terminology_reference-44131272`
- Type: `retired_ia_or_terminology_reference`
- Severity: `yellow`
- Recommended action: `rewrite`
- Rationale: Retired IA or product language should be rewritten or explicitly quarantined before this work becomes active.
- Linear issue ready: `True`
- Auto-resolved: `False`
- Involved:
  - `PD14_Life_Shape_Drilldowns_Prompt` — `docs/codex/batches/PD14_Life_Shape_Drilldowns_Prompt.md` (partial_implementation; release proof)

### 124. Retired IA/terminology reference in PD15_You_Trust_History_And_Receipts_Center_Prompt

- Conflict ID: `AMB28-retired_ia_or_terminology_reference-88599223`
- Type: `retired_ia_or_terminology_reference`
- Severity: `yellow`
- Recommended action: `rewrite`
- Rationale: Retired IA or product language should be rewritten or explicitly quarantined before this work becomes active.
- Linear issue ready: `True`
- Auto-resolved: `False`
- Involved:
  - `PD15_You_Trust_History_And_Receipts_Center_Prompt` — `docs/codex/batches/PD15_You_Trust_History_And_Receipts_Center_Prompt.md` (partial_implementation; release proof)

### 125. Retired IA/terminology reference in PD16_Schedule_Availability_And_Planning_Defaults_Depth_Prompt

- Conflict ID: `AMB28-retired_ia_or_terminology_reference-14076439`
- Type: `retired_ia_or_terminology_reference`
- Severity: `yellow`
- Recommended action: `rewrite`
- Rationale: Retired IA or product language should be rewritten or explicitly quarantined before this work becomes active.
- Linear issue ready: `True`
- Auto-resolved: `False`
- Involved:
  - `PD16_Schedule_Availability_And_Planning_Defaults_Depth_Prompt` — `docs/codex/batches/PD16_Schedule_Availability_And_Planning_Defaults_Depth_Prompt.md` (partial_implementation; release proof)

### 126. Retired IA/terminology reference in PD17_Cross_Surface_Proof_And_Review_Integration_Prompt

- Conflict ID: `AMB28-retired_ia_or_terminology_reference-98202852`
- Type: `retired_ia_or_terminology_reference`
- Severity: `yellow`
- Recommended action: `rewrite`
- Rationale: Retired IA or product language should be rewritten or explicitly quarantined before this work becomes active.
- Linear issue ready: `True`
- Auto-resolved: `False`
- Involved:
  - `PD17_Cross_Surface_Proof_And_Review_Integration_Prompt` — `docs/codex/batches/PD17_Cross_Surface_Proof_And_Review_Integration_Prompt.md` (partial_implementation; release proof)

### 127. Retired IA/terminology reference in PD18_Product_Depth_Handoff_And_Next_Lane_Readiness_Prompt

- Conflict ID: `AMB28-retired_ia_or_terminology_reference-9568640`
- Type: `retired_ia_or_terminology_reference`
- Severity: `yellow`
- Recommended action: `rewrite`
- Rationale: Retired IA or product language should be rewritten or explicitly quarantined before this work becomes active.
- Linear issue ready: `True`
- Auto-resolved: `False`
- Involved:
  - `PD18_Product_Depth_Handoff_And_Next_Lane_Readiness_Prompt` — `docs/codex/batches/PD18_Product_Depth_Handoff_And_Next_Lane_Readiness_Prompt.md` (partial_implementation; release proof)

### 128. Retired IA/terminology reference in PFC12_App_Groups_Shared_Storage_Boundary_Prompt

- Conflict ID: `AMB28-retired_ia_or_terminology_reference-66761589`
- Type: `retired_ia_or_terminology_reference`
- Severity: `yellow`
- Recommended action: `rewrite`
- Rationale: Retired IA or product language should be rewritten or explicitly quarantined before this work becomes active.
- Linear issue ready: `True`
- Auto-resolved: `False`
- Involved:
  - `PFC12_App_Groups_Shared_Storage_Boundary_Prompt` — `docs/codex/batches/PFC12_App_Groups_Shared_Storage_Boundary_Prompt.md` (unknown; release proof)

### 129. Retired IA/terminology reference in PK00_PK41_PLATFORM_KERNEL_TRAIN

- Conflict ID: `AMB28-retired_ia_or_terminology_reference-88849434`
- Type: `retired_ia_or_terminology_reference`
- Severity: `yellow`
- Recommended action: `rewrite`
- Rationale: Retired IA or product language should be rewritten or explicitly quarantined before this work becomes active.
- Linear issue ready: `True`
- Auto-resolved: `False`
- Involved:
  - `PK00_PK41_PLATFORM_KERNEL_TRAIN` — `docs/codex/batch-trains/PK00_PK41_PLATFORM_KERNEL_TRAIN.md` (partial_implementation; release proof)

### 130. Retired IA/terminology reference in POST99-UI-SUITE-REVIEW-IMPLEMENTATION-00

- Conflict ID: `AMB28-retired_ia_or_terminology_reference-98509272`
- Type: `retired_ia_or_terminology_reference`
- Severity: `yellow`
- Recommended action: `rewrite`
- Rationale: Retired IA or product language should be rewritten or explicitly quarantined before this work becomes active.
- Linear issue ready: `True`
- Auto-resolved: `False`
- Involved:
  - `POST99-UI-SUITE-REVIEW-IMPLEMENTATION-00` — `prompts/batches/POST99-UI-SUITE-REVIEW-IMPLEMENTATION-00.md` (partial_implementation; release proof)

### 131. Retired IA/terminology reference in PX01_PX20_PRODUCT_EXPERIENCE_OS_TRAIN

- Conflict ID: `AMB28-retired_ia_or_terminology_reference-72003197`
- Type: `retired_ia_or_terminology_reference`
- Severity: `yellow`
- Recommended action: `rewrite`
- Rationale: Retired IA or product language should be rewritten or explicitly quarantined before this work becomes active.
- Linear issue ready: `True`
- Auto-resolved: `False`
- Involved:
  - `PX01_PX20_PRODUCT_EXPERIENCE_OS_TRAIN` — `docs/codex/batch-trains/PX01_PX20_PRODUCT_EXPERIENCE_OS_TRAIN.md` (partial_implementation; release proof)

### 132. Retired IA/terminology reference in PX01_Product_Experience_OS_Canon_And_Surface_Hierarchy_Prompt

- Conflict ID: `AMB28-retired_ia_or_terminology_reference-2043138`
- Type: `retired_ia_or_terminology_reference`
- Severity: `yellow`
- Recommended action: `rewrite`
- Rationale: Retired IA or product language should be rewritten or explicitly quarantined before this work becomes active.
- Linear issue ready: `True`
- Auto-resolved: `False`
- Involved:
  - `PX01_Product_Experience_OS_Canon_And_Surface_Hierarchy_Prompt` — `docs/codex/batches/PX01_Product_Experience_OS_Canon_And_Surface_Hierarchy_Prompt.md` (partial_implementation; release proof)

### 133. Retired IA/terminology reference in PX02_Today_Experience_Operating_Surface_Prompt

- Conflict ID: `AMB28-retired_ia_or_terminology_reference-37183599`
- Type: `retired_ia_or_terminology_reference`
- Severity: `yellow`
- Recommended action: `rewrite`
- Rationale: Retired IA or product language should be rewritten or explicitly quarantined before this work becomes active.
- Linear issue ready: `True`
- Auto-resolved: `False`
- Involved:
  - `PX02_Today_Experience_Operating_Surface_Prompt` — `docs/codex/batches/PX02_Today_Experience_Operating_Surface_Prompt.md` (partial_implementation; release proof)

### 134. Retired IA/terminology reference in PX03_Goals_Mission_Control_Experience_Prompt

- Conflict ID: `AMB28-retired_ia_or_terminology_reference-22281450`
- Type: `retired_ia_or_terminology_reference`
- Severity: `yellow`
- Recommended action: `rewrite`
- Rationale: Retired IA or product language should be rewritten or explicitly quarantined before this work becomes active.
- Linear issue ready: `True`
- Auto-resolved: `False`
- Involved:
  - `PX03_Goals_Mission_Control_Experience_Prompt` — `docs/codex/batches/PX03_Goals_Mission_Control_Experience_Prompt.md` (partial_implementation; release proof)

### 135. Retired IA/terminology reference in PX04_Capture_Experience_Prompt

- Conflict ID: `AMB28-retired_ia_or_terminology_reference-54535904`
- Type: `retired_ia_or_terminology_reference`
- Severity: `yellow`
- Recommended action: `rewrite`
- Rationale: Retired IA or product language should be rewritten or explicitly quarantined before this work becomes active.
- Linear issue ready: `True`
- Auto-resolved: `False`
- Involved:
  - `PX04_Capture_Experience_Prompt` — `docs/codex/batches/PX04_Capture_Experience_Prompt.md` (partial_implementation; release proof)

### 136. Retired IA/terminology reference in PX05_Plan_Life_Shape_Experience_Prompt

- Conflict ID: `AMB28-retired_ia_or_terminology_reference-9172620`
- Type: `retired_ia_or_terminology_reference`
- Severity: `yellow`
- Recommended action: `rewrite`
- Rationale: Retired IA or product language should be rewritten or explicitly quarantined before this work becomes active.
- Linear issue ready: `True`
- Auto-resolved: `False`
- Involved:
  - `PX05_Plan_Life_Shape_Experience_Prompt` — `docs/codex/batches/PX05_Plan_Life_Shape_Experience_Prompt.md` (partial_implementation; release proof)

### 137. Retired IA/terminology reference in PX06_You_Personal_System_Center_Prompt

- Conflict ID: `AMB28-retired_ia_or_terminology_reference-2057558`
- Type: `retired_ia_or_terminology_reference`
- Severity: `yellow`
- Recommended action: `rewrite`
- Rationale: Retired IA or product language should be rewritten or explicitly quarantined before this work becomes active.
- Linear issue ready: `True`
- Auto-resolved: `False`
- Involved:
  - `PX06_You_Personal_System_Center_Prompt` — `docs/codex/batches/PX06_You_Personal_System_Center_Prompt.md` (partial_implementation; release proof)

### 138. Retired IA/terminology reference in PX07_Action_Closure_Recovery_Experience_Prompt

- Conflict ID: `AMB28-retired_ia_or_terminology_reference-40688011`
- Type: `retired_ia_or_terminology_reference`
- Severity: `yellow`
- Recommended action: `rewrite`
- Rationale: Retired IA or product language should be rewritten or explicitly quarantined before this work becomes active.
- Linear issue ready: `True`
- Auto-resolved: `False`
- Involved:
  - `PX07_Action_Closure_Recovery_Experience_Prompt` — `docs/codex/batches/PX07_Action_Closure_Recovery_Experience_Prompt.md` (partial_implementation; release proof)

### 139. Retired IA/terminology reference in PX08_Trust_Proof_Receipts_Experience_Prompt

- Conflict ID: `AMB28-retired_ia_or_terminology_reference-23812799`
- Type: `retired_ia_or_terminology_reference`
- Severity: `yellow`
- Recommended action: `rewrite`
- Rationale: Retired IA or product language should be rewritten or explicitly quarantined before this work becomes active.
- Linear issue ready: `True`
- Auto-resolved: `False`
- Involved:
  - `PX08_Trust_Proof_Receipts_Experience_Prompt` — `docs/codex/batches/PX08_Trust_Proof_Receipts_Experience_Prompt.md` (partial_implementation; release proof)

### 140. Retired IA/terminology reference in PX09_Copy_Language_Explanation_System_Prompt

- Conflict ID: `AMB28-retired_ia_or_terminology_reference-59610775`
- Type: `retired_ia_or_terminology_reference`
- Severity: `yellow`
- Recommended action: `rewrite`
- Rationale: Retired IA or product language should be rewritten or explicitly quarantined before this work becomes active.
- Linear issue ready: `True`
- Auto-resolved: `False`
- Involved:
  - `PX09_Copy_Language_Explanation_System_Prompt` — `docs/codex/batches/PX09_Copy_Language_Explanation_System_Prompt.md` (partial_implementation; release proof)

### 141. Retired IA/terminology reference in PX10_Visual_Interaction_System_Prompt

- Conflict ID: `AMB28-retired_ia_or_terminology_reference-59496696`
- Type: `retired_ia_or_terminology_reference`
- Severity: `yellow`
- Recommended action: `rewrite`
- Rationale: Retired IA or product language should be rewritten or explicitly quarantined before this work becomes active.
- Linear issue ready: `True`
- Auto-resolved: `False`
- Involved:
  - `PX10_Visual_Interaction_System_Prompt` — `docs/codex/batches/PX10_Visual_Interaction_System_Prompt.md` (partial_implementation; release proof)

### 142. Retired IA/terminology reference in PX11_Onboarding_Setup_Experience_Prompt

- Conflict ID: `AMB28-retired_ia_or_terminology_reference-26056543`
- Type: `retired_ia_or_terminology_reference`
- Severity: `yellow`
- Recommended action: `rewrite`
- Rationale: Retired IA or product language should be rewritten or explicitly quarantined before this work becomes active.
- Linear issue ready: `True`
- Auto-resolved: `False`
- Involved:
  - `PX11_Onboarding_Setup_Experience_Prompt` — `docs/codex/batches/PX11_Onboarding_Setup_Experience_Prompt.md` (partial_implementation; release proof)

### 143. Retired IA/terminology reference in PX12_Accessibility_Cognitive_Load_Emotional_Safety_Prompt

- Conflict ID: `AMB28-retired_ia_or_terminology_reference-44686906`
- Type: `retired_ia_or_terminology_reference`
- Severity: `yellow`
- Recommended action: `rewrite`
- Rationale: Retired IA or product language should be rewritten or explicitly quarantined before this work becomes active.
- Linear issue ready: `True`
- Auto-resolved: `False`
- Involved:
  - `PX12_Accessibility_Cognitive_Load_Emotional_Safety_Prompt` — `docs/codex/batches/PX12_Accessibility_Cognitive_Load_Emotional_Safety_Prompt.md` (partial_implementation; release proof)

### 144. Retired IA/terminology reference in PX13_Empty_Edge_Degraded_States_Prompt

- Conflict ID: `AMB28-retired_ia_or_terminology_reference-19822772`
- Type: `retired_ia_or_terminology_reference`
- Severity: `yellow`
- Recommended action: `rewrite`
- Rationale: Retired IA or product language should be rewritten or explicitly quarantined before this work becomes active.
- Linear issue ready: `True`
- Auto-resolved: `False`
- Involved:
  - `PX13_Empty_Edge_Degraded_States_Prompt` — `docs/codex/batches/PX13_Empty_Edge_Degraded_States_Prompt.md` (partial_implementation; release proof)

### 145. Retired IA/terminology reference in PX14_Product_Depth_Drilldown_Architecture_Prompt

- Conflict ID: `AMB28-retired_ia_or_terminology_reference-24005872`
- Type: `retired_ia_or_terminology_reference`
- Severity: `yellow`
- Recommended action: `rewrite`
- Rationale: Retired IA or product language should be rewritten or explicitly quarantined before this work becomes active.
- Linear issue ready: `True`
- Auto-resolved: `False`
- Involved:
  - `PX14_Product_Depth_Drilldown_Architecture_Prompt` — `docs/codex/batches/PX14_Product_Depth_Drilldown_Architecture_Prompt.md` (partial_implementation; release proof)

### 146. Retired IA/terminology reference in PX15_Cross_Surface_Continuity_Prompt

- Conflict ID: `AMB28-retired_ia_or_terminology_reference-6763694`
- Type: `retired_ia_or_terminology_reference`
- Severity: `yellow`
- Recommended action: `rewrite`
- Rationale: Retired IA or product language should be rewritten or explicitly quarantined before this work becomes active.
- Linear issue ready: `True`
- Auto-resolved: `False`
- Involved:
  - `PX15_Cross_Surface_Continuity_Prompt` — `docs/codex/batches/PX15_Cross_Surface_Continuity_Prompt.md` (partial_implementation; release proof)

### 147. Retired IA/terminology reference in PX16_User_Facing_AI_Trust_And_Recommendation_Copy_Prompt

- Conflict ID: `AMB28-retired_ia_or_terminology_reference-3161399`
- Type: `retired_ia_or_terminology_reference`
- Severity: `yellow`
- Recommended action: `rewrite`
- Rationale: Retired IA or product language should be rewritten or explicitly quarantined before this work becomes active.
- Linear issue ready: `True`
- Auto-resolved: `False`
- Involved:
  - `PX16_User_Facing_AI_Trust_And_Recommendation_Copy_Prompt` — `docs/codex/batches/PX16_User_Facing_AI_Trust_And_Recommendation_Copy_Prompt.md` (partial_implementation; release proof)

### 148. Retired IA/terminology reference in PX17_Release_Truth_Product_Messaging_Prompt

- Conflict ID: `AMB28-retired_ia_or_terminology_reference-10397847`
- Type: `retired_ia_or_terminology_reference`
- Severity: `yellow`
- Recommended action: `rewrite`
- Rationale: Retired IA or product language should be rewritten or explicitly quarantined before this work becomes active.
- Linear issue ready: `True`
- Auto-resolved: `False`
- Involved:
  - `PX17_Release_Truth_Product_Messaging_Prompt` — `docs/codex/batches/PX17_Release_Truth_Product_Messaging_Prompt.md` (partial_implementation; release proof)

### 149. Retired IA/terminology reference in PX18_PXOS_Implementation_Readiness_Reorder_Prompt

- Conflict ID: `AMB28-retired_ia_or_terminology_reference-55808977`
- Type: `retired_ia_or_terminology_reference`
- Severity: `yellow`
- Recommended action: `rewrite`
- Rationale: Retired IA or product language should be rewritten or explicitly quarantined before this work becomes active.
- Linear issue ready: `True`
- Auto-resolved: `False`
- Involved:
  - `PX18_PXOS_Implementation_Readiness_Reorder_Prompt` — `docs/codex/batches/PX18_PXOS_Implementation_Readiness_Reorder_Prompt.md` (partial_implementation; release proof)

### 150. Retired IA/terminology reference in PX19_PXOS_Handoff_Prompt

- Conflict ID: `AMB28-retired_ia_or_terminology_reference-21225453`
- Type: `retired_ia_or_terminology_reference`
- Severity: `yellow`
- Recommended action: `rewrite`
- Rationale: Retired IA or product language should be rewritten or explicitly quarantined before this work becomes active.
- Linear issue ready: `True`
- Auto-resolved: `False`
- Involved:
  - `PX19_PXOS_Handoff_Prompt` — `docs/codex/batches/PX19_PXOS_Handoff_Prompt.md` (partial_implementation; release proof)

### 151. Retired IA/terminology reference in PX20_PXOS_Beyond_Roadmap_Prompt

- Conflict ID: `AMB28-retired_ia_or_terminology_reference-78380525`
- Type: `retired_ia_or_terminology_reference`
- Severity: `yellow`
- Recommended action: `rewrite`
- Rationale: Retired IA or product language should be rewritten or explicitly quarantined before this work becomes active.
- Linear issue ready: `True`
- Auto-resolved: `False`
- Involved:
  - `PX20_PXOS_Beyond_Roadmap_Prompt` — `docs/codex/batches/PX20_PXOS_Beyond_Roadmap_Prompt.md` (partial_implementation; release proof)

### 152. Retired IA/terminology reference in PXEQ_LIVING_INTERFACE_RUBRIC

- Conflict ID: `AMB28-retired_ia_or_terminology_reference-54905393`
- Type: `retired_ia_or_terminology_reference`
- Severity: `yellow`
- Recommended action: `rewrite`
- Rationale: Retired IA or product language should be rewritten or explicitly quarantined before this work becomes active.
- Linear issue ready: `True`
- Auto-resolved: `False`
- Involved:
  - `PXEQ_LIVING_INTERFACE_RUBRIC` — `docs/codex/PXEQ_LIVING_INTERFACE_RUBRIC.md` (partial_implementation; release proof)

### 153. Retired IA/terminology reference in PXOS_GATE_MATRIX

- Conflict ID: `AMB28-retired_ia_or_terminology_reference-58172925`
- Type: `retired_ia_or_terminology_reference`
- Severity: `yellow`
- Recommended action: `rewrite`
- Rationale: Retired IA or product language should be rewritten or explicitly quarantined before this work becomes active.
- Linear issue ready: `True`
- Auto-resolved: `False`
- Involved:
  - `PXOS_GATE_MATRIX` — `docs/codex/PXOS_GATE_MATRIX.md` (partial_implementation; release proof)

### 154. Retired IA/terminology reference in PXOS_PRODUCT_DECISION_LEDGER

- Conflict ID: `AMB28-retired_ia_or_terminology_reference-43006206`
- Type: `retired_ia_or_terminology_reference`
- Severity: `yellow`
- Recommended action: `rewrite`
- Rationale: Retired IA or product language should be rewritten or explicitly quarantined before this work becomes active.
- Linear issue ready: `True`
- Auto-resolved: `False`
- Involved:
  - `PXOS_PRODUCT_DECISION_LEDGER` — `docs/codex/PXOS_PRODUCT_DECISION_LEDGER.md` (unknown; release proof)

### 155. Retired IA/terminology reference in REPO_INTELLIGENCE_CONTROL_PLANE

- Conflict ID: `AMB28-retired_ia_or_terminology_reference-59159814`
- Type: `retired_ia_or_terminology_reference`
- Severity: `yellow`
- Recommended action: `rewrite`
- Rationale: Retired IA or product language should be rewritten or explicitly quarantined before this work becomes active.
- Linear issue ready: `True`
- Auto-resolved: `False`
- Involved:
  - `REPO_INTELLIGENCE_CONTROL_PLANE` — `docs/codex/REPO_INTELLIGENCE_CONTROL_PLANE.md` (unknown; release proof)

### 156. Retired IA/terminology reference in SA_NEXT_ELIGIBLE_BATCH_PROMPT

- Conflict ID: `AMB28-retired_ia_or_terminology_reference-93108830`
- Type: `retired_ia_or_terminology_reference`
- Severity: `yellow`
- Recommended action: `rewrite`
- Rationale: Retired IA or product language should be rewritten or explicitly quarantined before this work becomes active.
- Linear issue ready: `True`
- Auto-resolved: `False`
- Involved:
  - `SA_NEXT_ELIGIBLE_BATCH_PROMPT` — `docs/codex/batches/SA_NEXT_ELIGIBLE_BATCH_PROMPT.md` (partial_implementation; release proof)

### 157. Retired IA/terminology reference in SI01_SI18_SIGNATURE_INTERFACE_IMPLEMENTATION_TRAIN

- Conflict ID: `AMB28-retired_ia_or_terminology_reference-23200176`
- Type: `retired_ia_or_terminology_reference`
- Severity: `yellow`
- Recommended action: `rewrite`
- Rationale: Retired IA or product language should be rewritten or explicitly quarantined before this work becomes active.
- Linear issue ready: `True`
- Auto-resolved: `False`
- Involved:
  - `SI01_SI18_SIGNATURE_INTERFACE_IMPLEMENTATION_TRAIN` — `docs/codex/batch-trains/SI01_SI18_SIGNATURE_INTERFACE_IMPLEMENTATION_TRAIN.md` (partial_implementation; release proof)

### 158. Retired IA/terminology reference in SI05_Hero_Step_Panel_System_Prompt

- Conflict ID: `AMB28-retired_ia_or_terminology_reference-26933044`
- Type: `retired_ia_or_terminology_reference`
- Severity: `yellow`
- Recommended action: `rewrite`
- Rationale: Retired IA or product language should be rewritten or explicitly quarantined before this work becomes active.
- Linear issue ready: `True`
- Auto-resolved: `False`
- Involved:
  - `SI05_Hero_Step_Panel_System_Prompt` — `docs/codex/batches/SI05_Hero_Step_Panel_System_Prompt.md` (partial_implementation; release proof)

### 159. Retired IA/terminology reference in SI17_Top_Level_Surface_Composition_Implementation_Prompt

- Conflict ID: `AMB28-retired_ia_or_terminology_reference-33102422`
- Type: `retired_ia_or_terminology_reference`
- Severity: `yellow`
- Recommended action: `rewrite`
- Rationale: Retired IA or product language should be rewritten or explicitly quarantined before this work becomes active.
- Linear issue ready: `True`
- Auto-resolved: `False`
- Involved:
  - `SI17_Top_Level_Surface_Composition_Implementation_Prompt` — `docs/codex/batches/SI17_Top_Level_Surface_Composition_Implementation_Prompt.md` (partial_implementation; release proof)

### 160. Retired IA/terminology reference in SIG01_SIG16_SIGNATURE_EXPERIENCE_LAYER_TRAIN

- Conflict ID: `AMB28-retired_ia_or_terminology_reference-28722145`
- Type: `retired_ia_or_terminology_reference`
- Severity: `yellow`
- Recommended action: `rewrite`
- Rationale: Retired IA or product language should be rewritten or explicitly quarantined before this work becomes active.
- Linear issue ready: `True`
- Auto-resolved: `False`
- Involved:
  - `SIG01_SIG16_SIGNATURE_EXPERIENCE_LAYER_TRAIN` — `docs/codex/batch-trains/SIG01_SIG16_SIGNATURE_EXPERIENCE_LAYER_TRAIN.md` (unknown; release proof)

### 161. Retired IA/terminology reference in SIG03_Today_Signature_Experience_Implementation_Prompt

- Conflict ID: `AMB28-retired_ia_or_terminology_reference-7904994`
- Type: `retired_ia_or_terminology_reference`
- Severity: `yellow`
- Recommended action: `rewrite`
- Rationale: Retired IA or product language should be rewritten or explicitly quarantined before this work becomes active.
- Linear issue ready: `True`
- Auto-resolved: `False`
- Involved:
  - `SIG03_Today_Signature_Experience_Implementation_Prompt` — `docs/codex/batches/SIG03_Today_Signature_Experience_Implementation_Prompt.md` (unknown; release proof)

### 162. Retired IA/terminology reference in SIG06_Goals_Signature_Experience_Implementation_Prompt

- Conflict ID: `AMB28-retired_ia_or_terminology_reference-30297366`
- Type: `retired_ia_or_terminology_reference`
- Severity: `yellow`
- Recommended action: `rewrite`
- Rationale: Retired IA or product language should be rewritten or explicitly quarantined before this work becomes active.
- Linear issue ready: `True`
- Auto-resolved: `False`
- Involved:
  - `SIG06_Goals_Signature_Experience_Implementation_Prompt` — `docs/codex/batches/SIG06_Goals_Signature_Experience_Implementation_Prompt.md` (unknown; release proof)

### 163. Retired IA/terminology reference in SIGNATURE-VISUAL-INSTRUMENTS-ENCYCLOPEDIA-07

- Conflict ID: `AMB28-retired_ia_or_terminology_reference-52180060`
- Type: `retired_ia_or_terminology_reference`
- Severity: `yellow`
- Recommended action: `rewrite`
- Rationale: Retired IA or product language should be rewritten or explicitly quarantined before this work becomes active.
- Linear issue ready: `True`
- Auto-resolved: `False`
- Involved:
  - `SIGNATURE-VISUAL-INSTRUMENTS-ENCYCLOPEDIA-07` — `prompts/batches/SIGNATURE-VISUAL-INSTRUMENTS-ENCYCLOPEDIA-07.md` (partial_implementation; release proof)

### 164. Retired IA/terminology reference in SIGNATURE_INTERFACE_SWIFTUI_ARCHITECTURE_MAP

- Conflict ID: `AMB28-retired_ia_or_terminology_reference-85812687`
- Type: `retired_ia_or_terminology_reference`
- Severity: `yellow`
- Recommended action: `rewrite`
- Rationale: Retired IA or product language should be rewritten or explicitly quarantined before this work becomes active.
- Linear issue ready: `True`
- Auto-resolved: `False`
- Involved:
  - `SIGNATURE_INTERFACE_SWIFTUI_ARCHITECTURE_MAP` — `docs/codex/SIGNATURE_INTERFACE_SWIFTUI_ARCHITECTURE_MAP.md` (partial_implementation; release proof)

### 165. Retired IA/terminology reference in SIG_APPLE_AWARD_CALIBER_SCORECARD

- Conflict ID: `AMB28-retired_ia_or_terminology_reference-39123234`
- Type: `retired_ia_or_terminology_reference`
- Severity: `yellow`
- Recommended action: `rewrite`
- Rationale: Retired IA or product language should be rewritten or explicitly quarantined before this work becomes active.
- Linear issue ready: `True`
- Auto-resolved: `False`
- Involved:
  - `SIG_APPLE_AWARD_CALIBER_SCORECARD` — `docs/codex/SIG_APPLE_AWARD_CALIBER_SCORECARD.md` (partial_implementation; release proof)

### 166. Retired IA/terminology reference in SOURCE_ATLAS_UI_OBJECT_LANGUAGE

- Conflict ID: `AMB28-retired_ia_or_terminology_reference-97667743`
- Type: `retired_ia_or_terminology_reference`
- Severity: `yellow`
- Recommended action: `rewrite`
- Rationale: Retired IA or product language should be rewritten or explicitly quarantined before this work becomes active.
- Linear issue ready: `True`
- Auto-resolved: `False`
- Involved:
  - `SOURCE_ATLAS_UI_OBJECT_LANGUAGE` — `docs/codex/SOURCE_ATLAS_UI_OBJECT_LANGUAGE.md` (partial_implementation; release proof)

### 167. Retired IA/terminology reference in START-HERE-REALITY-RECOGNITION-01

- Conflict ID: `AMB28-retired_ia_or_terminology_reference-22720196`
- Type: `retired_ia_or_terminology_reference`
- Severity: `yellow`
- Recommended action: `rewrite`
- Rationale: Retired IA or product language should be rewritten or explicitly quarantined before this work becomes active.
- Linear issue ready: `True`
- Auto-resolved: `False`
- Involved:
  - `START-HERE-REALITY-RECOGNITION-01` — `prompts/batches/START-HERE-REALITY-RECOGNITION-01.md` (partial_implementation; release proof)

### 168. Retired IA/terminology reference in TODAY-REALITY-MERIDIAN-VISUAL-01

- Conflict ID: `AMB28-retired_ia_or_terminology_reference-97827044`
- Type: `retired_ia_or_terminology_reference`
- Severity: `yellow`
- Recommended action: `rewrite`
- Rationale: Retired IA or product language should be rewritten or explicitly quarantined before this work becomes active.
- Linear issue ready: `True`
- Auto-resolved: `False`
- Involved:
  - `TODAY-REALITY-MERIDIAN-VISUAL-01` — `prompts/batches/TODAY-REALITY-MERIDIAN-VISUAL-01.md` (partial_implementation; release proof)

### 169. Retired IA/terminology reference in TRAIN_04D_CAPTURE_RUNTIME_FACTORING_FUTURE_PROOF

- Conflict ID: `AMB28-retired_ia_or_terminology_reference-31876686`
- Type: `retired_ia_or_terminology_reference`
- Severity: `yellow`
- Recommended action: `rewrite`
- Rationale: Retired IA or product language should be rewritten or explicitly quarantined before this work becomes active.
- Linear issue ready: `True`
- Auto-resolved: `False`
- Involved:
  - `TRAIN_04D_CAPTURE_RUNTIME_FACTORING_FUTURE_PROOF` — `prompts/trains/ios26-flagship/TRAIN_04D_CAPTURE_RUNTIME_FACTORING_FUTURE_PROOF.md` (partial_implementation; release proof)

### 170. Retired IA/terminology reference in TRAIN_08_CAPTURE_ATMOSPHERE_COMPOSER_FINAL_OBJECT

- Conflict ID: `AMB28-retired_ia_or_terminology_reference-88965637`
- Type: `retired_ia_or_terminology_reference`
- Severity: `yellow`
- Recommended action: `rewrite`
- Rationale: Retired IA or product language should be rewritten or explicitly quarantined before this work becomes active.
- Linear issue ready: `True`
- Auto-resolved: `False`
- Involved:
  - `TRAIN_08_CAPTURE_ATMOSPHERE_COMPOSER_FINAL_OBJECT` — `prompts/trains/ios26-flagship/TRAIN_08_CAPTURE_ATMOSPHERE_COMPOSER_FINAL_OBJECT.md` (partial_implementation; source-only)

### 171. Retired IA/terminology reference in VISUAL-CANON-MOAT-01

- Conflict ID: `AMB28-retired_ia_or_terminology_reference-49704108`
- Type: `retired_ia_or_terminology_reference`
- Severity: `yellow`
- Recommended action: `rewrite`
- Rationale: Retired IA or product language should be rewritten or explicitly quarantined before this work becomes active.
- Linear issue ready: `True`
- Auto-resolved: `False`
- Involved:
  - `VISUAL-CANON-MOAT-01` — `prompts/batches/VISUAL-CANON-MOAT-01.md` (partial_implementation; release proof)

### 172. Retired IA/terminology reference in VISUAL-ENCYCLOPEDIA-100-PROOF-HARDENING-03

- Conflict ID: `AMB28-retired_ia_or_terminology_reference-31051113`
- Type: `retired_ia_or_terminology_reference`
- Severity: `yellow`
- Recommended action: `rewrite`
- Rationale: Retired IA or product language should be rewritten or explicitly quarantined before this work becomes active.
- Linear issue ready: `True`
- Auto-resolved: `False`
- Involved:
  - `VISUAL-ENCYCLOPEDIA-100-PROOF-HARDENING-03` — `prompts/batches/VISUAL-ENCYCLOPEDIA-100-PROOF-HARDENING-03.md` (partial_implementation; release proof)

### 173. Retired IA/terminology reference in ambitions-hybrid-runner

- Conflict ID: `AMB28-retired_ia_or_terminology_reference-97855985`
- Type: `retired_ia_or_terminology_reference`
- Severity: `yellow`
- Recommended action: `rewrite`
- Rationale: Retired IA or product language should be rewritten or explicitly quarantined before this work becomes active.
- Linear issue ready: `True`
- Auto-resolved: `False`
- Involved:
  - `ambitions-hybrid-runner` — `docs/codex/ambitions-hybrid-runner.md` (partial_implementation; release proof)

### 174. Retired IA/terminology reference in existing-code-champion-coverage

- Conflict ID: `AMB28-retired_ia_or_terminology_reference-89382656`
- Type: `retired_ia_or_terminology_reference`
- Severity: `yellow`
- Recommended action: `rewrite`
- Rationale: Retired IA or product language should be rewritten or explicitly quarantined before this work becomes active.
- Linear issue ready: `True`
- Auto-resolved: `False`
- Involved:
  - `existing-code-champion-coverage` — `docs/codex/existing-code-champion-coverage.yml` (unknown; release proof)

### 175. Retired IA/terminology reference in frontend-gap-backlog

- Conflict ID: `AMB28-retired_ia_or_terminology_reference-80023145`
- Type: `retired_ia_or_terminology_reference`
- Severity: `yellow`
- Recommended action: `rewrite`
- Rationale: Retired IA or product language should be rewritten or explicitly quarantined before this work becomes active.
- Linear issue ready: `True`
- Auto-resolved: `False`
- Involved:
  - `frontend-gap-backlog` — `docs/codex/frontend-gap-backlog.md` (partial_implementation; release proof)

### 176. Retired IA/terminology reference in parallel-guard-concept-registry

- Conflict ID: `AMB28-retired_ia_or_terminology_reference-26481941`
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

- Conflict ID: `AMB28-missing_source_of_truth_reference-65783352`
- Type: `missing_source_of_truth_reference`
- Severity: `yellow`
- Recommended action: `rewrite`
- Rationale: Active batch/prompt/train should cite governing truth or authority files before execution.
- Linear issue ready: `True`
- Auto-resolved: `False`
- Involved:
  - `AMB_GLOBAL_REMAINING_TRAIN_BLUEPRINT` — `docs/codex/AMB_GLOBAL_REMAINING_TRAIN_BLUEPRINT.json` (unknown; tests)

### 2. Missing source-of-truth references in AMB_REMAINING_BATCH_REFERENCE

- Conflict ID: `AMB28-missing_source_of_truth_reference-72652806`
- Type: `missing_source_of_truth_reference`
- Severity: `yellow`
- Recommended action: `rewrite`
- Rationale: Active batch/prompt/train should cite governing truth or authority files before execution.
- Linear issue ready: `True`
- Auto-resolved: `False`
- Involved:
  - `AMB_REMAINING_BATCH_REFERENCE` — `docs/codex/AMB_REMAINING_BATCH_REFERENCE.json` (partial_implementation; release proof)

### 3. Missing source-of-truth references in CHAMPION_MERGE_AND_INTELLIGENCE_CONSOLIDATION_SUPPORT

- Conflict ID: `AMB28-missing_source_of_truth_reference-89477271`
- Type: `missing_source_of_truth_reference`
- Severity: `yellow`
- Recommended action: `rewrite`
- Rationale: Active batch/prompt/train should cite governing truth or authority files before execution.
- Linear issue ready: `True`
- Auto-resolved: `False`
- Involved:
  - `CHAMPION_MERGE_AND_INTELLIGENCE_CONSOLIDATION_SUPPORT` — `prompts/trains/ios26-flagship/support/CHAMPION_MERGE_AND_INTELLIGENCE_CONSOLIDATION_SUPPORT.md` (partial_implementation; release proof)

### 4. Missing source-of-truth references in GLOBAL_QUEUE_CANONICAL_ORDER

- Conflict ID: `AMB28-missing_source_of_truth_reference-21129516`
- Type: `missing_source_of_truth_reference`
- Severity: `yellow`
- Recommended action: `rewrite`
- Rationale: Active batch/prompt/train should cite governing truth or authority files before execution.
- Linear issue ready: `True`
- Auto-resolved: `False`
- Involved:
  - `GLOBAL_QUEUE_CANONICAL_ORDER` — `docs/codex/GLOBAL_QUEUE_CANONICAL_ORDER.json` (partial_implementation; release proof)

### 5. Missing source-of-truth references in HISTORICAL_BASELINE_GLOBAL_TRAIN_MANIFEST

- Conflict ID: `AMB28-missing_source_of_truth_reference-67281265`
- Type: `missing_source_of_truth_reference`
- Severity: `yellow`
- Recommended action: `rewrite`
- Rationale: Active batch/prompt/train should cite governing truth or authority files before execution.
- Linear issue ready: `True`
- Auto-resolved: `False`
- Involved:
  - `HISTORICAL_BASELINE_GLOBAL_TRAIN_MANIFEST` — `docs/codex/HISTORICAL_BASELINE_GLOBAL_TRAIN_MANIFEST.json` (unknown; release proof)

### 6. Missing source-of-truth references in IOS26-FLAGSHIP

- Conflict ID: `AMB28-missing_source_of_truth_reference-68185332`
- Type: `missing_source_of_truth_reference`
- Severity: `yellow`
- Recommended action: `rewrite`
- Rationale: Active batch/prompt/train should cite governing truth or authority files before execution.
- Linear issue ready: `True`
- Auto-resolved: `False`
- Involved:
  - `IOS26-FLAGSHIP` — `docs/codex/IOS26_FLAGSHIP_EXECUTION_STATE.yml` (partial_implementation; source-only)

### 7. Missing source-of-truth references in IOS26_BATCH_MATRIX

- Conflict ID: `AMB28-missing_source_of_truth_reference-20700079`
- Type: `missing_source_of_truth_reference`
- Severity: `yellow`
- Recommended action: `rewrite`
- Rationale: Active batch/prompt/train should cite governing truth or authority files before execution.
- Linear issue ready: `True`
- Auto-resolved: `False`
- Involved:
  - `IOS26_BATCH_MATRIX` — `docs/codex/ios26/IOS26_BATCH_MATRIX.yml` (partial_implementation; release proof)

### 8. Missing source-of-truth references in IOS26_DEPENDENCY_GRAPH

- Conflict ID: `AMB28-missing_source_of_truth_reference-18769821`
- Type: `missing_source_of_truth_reference`
- Severity: `yellow`
- Recommended action: `rewrite`
- Rationale: Active batch/prompt/train should cite governing truth or authority files before execution.
- Linear issue ready: `True`
- Auto-resolved: `False`
- Involved:
  - `IOS26_DEPENDENCY_GRAPH` — `docs/codex/ios26/IOS26_DEPENDENCY_GRAPH.yml` (partial_implementation; source-only)

### 9. Missing source-of-truth references in IOS26_PROMPT_FREEZE_HASHES

- Conflict ID: `AMB28-missing_source_of_truth_reference-86902937`
- Type: `missing_source_of_truth_reference`
- Severity: `yellow`
- Recommended action: `rewrite`
- Rationale: Active batch/prompt/train should cite governing truth or authority files before execution.
- Linear issue ready: `True`
- Auto-resolved: `False`
- Involved:
  - `IOS26_PROMPT_FREEZE_HASHES` — `docs/codex/ios26/IOS26_PROMPT_FREEZE_HASHES.json` (partial_implementation; release proof)

### 10. Missing source-of-truth references in MOAT_RUNTIME_BATCH_OVERLAY

- Conflict ID: `AMB28-missing_source_of_truth_reference-5980797`
- Type: `missing_source_of_truth_reference`
- Severity: `yellow`
- Recommended action: `rewrite`
- Rationale: Active batch/prompt/train should cite governing truth or authority files before execution.
- Linear issue ready: `True`
- Auto-resolved: `False`
- Involved:
  - `MOAT_RUNTIME_BATCH_OVERLAY` — `docs/codex/MOAT_RUNTIME_BATCH_OVERLAY.json` (partial_implementation; release proof)

### 11. Missing source-of-truth references in SPEED_TRAIN_LANE_POLICY

- Conflict ID: `AMB28-missing_source_of_truth_reference-75330985`
- Type: `missing_source_of_truth_reference`
- Severity: `yellow`
- Recommended action: `rewrite`
- Rationale: Active batch/prompt/train should cite governing truth or authority files before execution.
- Linear issue ready: `True`
- Auto-resolved: `False`
- Involved:
  - `SPEED_TRAIN_LANE_POLICY` — `docs/codex/SPEED_TRAIN_LANE_POLICY.json` (unknown; release proof)

### 12. Missing source-of-truth references in TRAIN_04L

- Conflict ID: `AMB28-missing_source_of_truth_reference-64063414`
- Type: `missing_source_of_truth_reference`
- Severity: `yellow`
- Recommended action: `rewrite`
- Rationale: Active batch/prompt/train should cite governing truth or authority files before execution.
- Linear issue ready: `True`
- Auto-resolved: `False`
- Involved:
  - `TRAIN_04L` — `docs/codex/CHAMPION_MERGE_TRAIN_MANIFEST.yml` (partial_implementation; source-only)

### 13. Missing source-of-truth references in TRAIN_04L_OBJECT_FRONTEND_LIVING_CHROME_FOUNDATION

- Conflict ID: `AMB28-missing_source_of_truth_reference-4656906`
- Type: `missing_source_of_truth_reference`
- Severity: `yellow`
- Recommended action: `rewrite`
- Rationale: Active batch/prompt/train should cite governing truth or authority files before execution.
- Linear issue ready: `True`
- Auto-resolved: `False`
- Involved:
  - `TRAIN_04L_OBJECT_FRONTEND_LIVING_CHROME_FOUNDATION` — `prompts/trains/ios26-flagship/TRAIN_04L_OBJECT_FRONTEND_LIVING_CHROME_FOUNDATION.md` (partial_implementation; release proof)

### 14. Missing source-of-truth references in concept-lock-registry

- Conflict ID: `AMB28-missing_source_of_truth_reference-64164611`
- Type: `missing_source_of_truth_reference`
- Severity: `yellow`
- Recommended action: `rewrite`
- Rationale: Active batch/prompt/train should cite governing truth or authority files before execution.
- Linear issue ready: `True`
- Auto-resolved: `False`
- Involved:
  - `concept-lock-registry` — `docs/codex/concept-lock-registry.yml` (partial_implementation; tests)

### 15. Missing source-of-truth references in existing-code-champion-coverage

- Conflict ID: `AMB28-missing_source_of_truth_reference-62686723`
- Type: `missing_source_of_truth_reference`
- Severity: `yellow`
- Recommended action: `rewrite`
- Rationale: Active batch/prompt/train should cite governing truth or authority files before execution.
- Linear issue ready: `True`
- Auto-resolved: `False`
- Involved:
  - `existing-code-champion-coverage` — `docs/codex/existing-code-champion-coverage.yml` (unknown; release proof)

### 16. Missing source-of-truth references in ldi06-pack-registry-fixture

- Conflict ID: `AMB28-missing_source_of_truth_reference-90337606`
- Type: `missing_source_of_truth_reference`
- Severity: `yellow`
- Recommended action: `rewrite`
- Rationale: Active batch/prompt/train should cite governing truth or authority files before execution.
- Linear issue ready: `True`
- Auto-resolved: `False`
- Involved:
  - `ldi06-pack-registry-fixture` — `docs/codex/fixtures/ldi/ldi06-pack-registry-fixture.json` (partial_implementation; source-only)

### 17. Missing source-of-truth references in parallel-guard-concept-registry

- Conflict ID: `AMB28-missing_source_of_truth_reference-77407445`
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

- Conflict ID: `AMB28-source_only_implementation_missing_proof-22167719`
- Type: `source_only_implementation_missing_proof`
- Severity: `yellow`
- Recommended action: `expedite`
- Rationale: Missing or weak proof should be triaged before execution proceeds.
- Linear issue ready: `True`
- Auto-resolved: `False`
- Involved:
  - `TRAIN_00_REPO_TRUTH_AUDIT_VALIDATION_BASELINE` — `prompts/trains/ios26-flagship/TRAIN_00_REPO_TRUTH_AUDIT_VALIDATION_BASELINE.md` (partial_implementation; audit)

### 2. Source-only or missing-proof implementation state: IOS26-FLAGSHIP

- Conflict ID: `AMB28-source_only_implementation_missing_proof-34483658`
- Type: `source_only_implementation_missing_proof`
- Severity: `yellow`
- Recommended action: `finish`
- Rationale: Source-only item needs focused proof before it can be considered implemented.
- Linear issue ready: `True`
- Auto-resolved: `False`
- Involved:
  - `IOS26-FLAGSHIP` — `docs/codex/IOS26_FLAGSHIP_EXECUTION_STATE.yml` (partial_implementation; source-only)

### 3. Source-only or missing-proof implementation state: IOS26_DEPENDENCY_GRAPH

- Conflict ID: `AMB28-source_only_implementation_missing_proof-98019040`
- Type: `source_only_implementation_missing_proof`
- Severity: `yellow`
- Recommended action: `finish`
- Rationale: Source-only item needs focused proof before it can be considered implemented.
- Linear issue ready: `True`
- Auto-resolved: `False`
- Involved:
  - `IOS26_DEPENDENCY_GRAPH` — `docs/codex/ios26/IOS26_DEPENDENCY_GRAPH.yml` (partial_implementation; source-only)

### 4. Source-only or missing-proof implementation state: TRAIN_01_IOS26_MINIMUM_MIGRATION_FOUNDATION

- Conflict ID: `AMB28-source_only_implementation_missing_proof-46273463`
- Type: `source_only_implementation_missing_proof`
- Severity: `yellow`
- Recommended action: `finish`
- Rationale: Source-only item needs focused proof before it can be considered implemented.
- Linear issue ready: `True`
- Auto-resolved: `False`
- Involved:
  - `TRAIN_01_IOS26_MINIMUM_MIGRATION_FOUNDATION` — `prompts/trains/ios26-flagship/TRAIN_01_IOS26_MINIMUM_MIGRATION_FOUNDATION.md` (partial_implementation; source-only)

### 5. Source-only or missing-proof implementation state: TRAIN_03_PRIVATE_LIFE_RUNTIME_PROOF_HARNESS

- Conflict ID: `AMB28-source_only_implementation_missing_proof-88957111`
- Type: `source_only_implementation_missing_proof`
- Severity: `yellow`
- Recommended action: `finish`
- Rationale: Source-only item needs focused proof before it can be considered implemented.
- Linear issue ready: `True`
- Auto-resolved: `False`
- Involved:
  - `TRAIN_03_PRIVATE_LIFE_RUNTIME_PROOF_HARNESS` — `prompts/trains/ios26-flagship/TRAIN_03_PRIVATE_LIFE_RUNTIME_PROOF_HARNESS.md` (partial_implementation; source-only)

### 6. Source-only or missing-proof implementation state: TRAIN_04L

- Conflict ID: `AMB28-source_only_implementation_missing_proof-14472031`
- Type: `source_only_implementation_missing_proof`
- Severity: `yellow`
- Recommended action: `finish`
- Rationale: Source-only item needs focused proof before it can be considered implemented.
- Linear issue ready: `True`
- Auto-resolved: `False`
- Involved:
  - `TRAIN_04L` — `docs/codex/CHAMPION_MERGE_TRAIN_MANIFEST.yml` (partial_implementation; source-only)

### 7. Source-only or missing-proof implementation state: TRAIN_04_GOAL_INTENT_TO_DAY_COMPILER

- Conflict ID: `AMB28-source_only_implementation_missing_proof-26699805`
- Type: `source_only_implementation_missing_proof`
- Severity: `yellow`
- Recommended action: `finish`
- Rationale: Source-only item needs focused proof before it can be considered implemented.
- Linear issue ready: `True`
- Auto-resolved: `False`
- Involved:
  - `TRAIN_04_GOAL_INTENT_TO_DAY_COMPILER` — `prompts/trains/ios26-flagship/TRAIN_04_GOAL_INTENT_TO_DAY_COMPILER.md` (partial_implementation; source-only)

### 8. Source-only or missing-proof implementation state: TRAIN_05_TODAY_REALITY_MERIDIAN_FINAL_OBJECT

- Conflict ID: `AMB28-source_only_implementation_missing_proof-34617096`
- Type: `source_only_implementation_missing_proof`
- Severity: `yellow`
- Recommended action: `finish`
- Rationale: Source-only item needs focused proof before it can be considered implemented.
- Linear issue ready: `True`
- Auto-resolved: `False`
- Involved:
  - `TRAIN_05_TODAY_REALITY_MERIDIAN_FINAL_OBJECT` — `prompts/trains/ios26-flagship/TRAIN_05_TODAY_REALITY_MERIDIAN_FINAL_OBJECT.md` (partial_implementation; source-only)

### 9. Source-only or missing-proof implementation state: TRAIN_06_TIME_LIFESHAPE_FIELD_FINAL_OBJECT

- Conflict ID: `AMB28-source_only_implementation_missing_proof-47385195`
- Type: `source_only_implementation_missing_proof`
- Severity: `yellow`
- Recommended action: `finish`
- Rationale: Source-only item needs focused proof before it can be considered implemented.
- Linear issue ready: `True`
- Auto-resolved: `False`
- Involved:
  - `TRAIN_06_TIME_LIFESHAPE_FIELD_FINAL_OBJECT` — `prompts/trains/ios26-flagship/TRAIN_06_TIME_LIFESHAPE_FIELD_FINAL_OBJECT.md` (partial_implementation; source-only)

### 10. Source-only or missing-proof implementation state: TRAIN_07_GOALS_CONSTELLATION_ATLAS_FINAL_OBJECT

- Conflict ID: `AMB28-source_only_implementation_missing_proof-81099119`
- Type: `source_only_implementation_missing_proof`
- Severity: `yellow`
- Recommended action: `finish`
- Rationale: Source-only item needs focused proof before it can be considered implemented.
- Linear issue ready: `True`
- Auto-resolved: `False`
- Involved:
  - `TRAIN_07_GOALS_CONSTELLATION_ATLAS_FINAL_OBJECT` — `prompts/trains/ios26-flagship/TRAIN_07_GOALS_CONSTELLATION_ATLAS_FINAL_OBJECT.md` (partial_implementation; source-only)

### 11. Source-only or missing-proof implementation state: TRAIN_08_CAPTURE_ATMOSPHERE_COMPOSER_FINAL_OBJECT

- Conflict ID: `AMB28-source_only_implementation_missing_proof-90717781`
- Type: `source_only_implementation_missing_proof`
- Severity: `yellow`
- Recommended action: `finish`
- Rationale: Source-only item needs focused proof before it can be considered implemented.
- Linear issue ready: `True`
- Auto-resolved: `False`
- Involved:
  - `TRAIN_08_CAPTURE_ATMOSPHERE_COMPOSER_FINAL_OBJECT` — `prompts/trains/ios26-flagship/TRAIN_08_CAPTURE_ATMOSPHERE_COMPOSER_FINAL_OBJECT.md` (partial_implementation; source-only)

### 12. Source-only or missing-proof implementation state: TRAIN_09_YOU_USER_SYSTEM_PROFILE

- Conflict ID: `AMB28-source_only_implementation_missing_proof-91217190`
- Type: `source_only_implementation_missing_proof`
- Severity: `yellow`
- Recommended action: `finish`
- Rationale: Source-only item needs focused proof before it can be considered implemented.
- Linear issue ready: `True`
- Auto-resolved: `False`
- Involved:
  - `TRAIN_09_YOU_USER_SYSTEM_PROFILE` — `prompts/trains/ios26-flagship/TRAIN_09_YOU_USER_SYSTEM_PROFILE.md` (partial_implementation; source-only)

### 13. Source-only or missing-proof implementation state: TRAIN_10_PROOF_RECEIPTS_CLOSURE_RECOVERY_REPLAY

- Conflict ID: `AMB28-source_only_implementation_missing_proof-39398065`
- Type: `source_only_implementation_missing_proof`
- Severity: `yellow`
- Recommended action: `finish`
- Rationale: Source-only item needs focused proof before it can be considered implemented.
- Linear issue ready: `True`
- Auto-resolved: `False`
- Involved:
  - `TRAIN_10_PROOF_RECEIPTS_CLOSURE_RECOVERY_REPLAY` — `prompts/trains/ios26-flagship/TRAIN_10_PROOF_RECEIPTS_CLOSURE_RECOVERY_REPLAY.md` (partial_implementation; source-only)

### 14. Source-only or missing-proof implementation state: TRAIN_11_PERSISTENCE_MIGRATION_EXPORT_DELETE_APP_GROUP

- Conflict ID: `AMB28-source_only_implementation_missing_proof-68936962`
- Type: `source_only_implementation_missing_proof`
- Severity: `yellow`
- Recommended action: `finish`
- Rationale: Source-only item needs focused proof before it can be considered implemented.
- Linear issue ready: `True`
- Auto-resolved: `False`
- Involved:
  - `TRAIN_11_PERSISTENCE_MIGRATION_EXPORT_DELETE_APP_GROUP` — `prompts/trains/ios26-flagship/TRAIN_11_PERSISTENCE_MIGRATION_EXPORT_DELETE_APP_GROUP.md` (partial_implementation; source-only)

### 15. Source-only or missing-proof implementation state: TRAIN_12_EXTERNAL_SURFACES_WIDGETS_INTENTS_SHARE

- Conflict ID: `AMB28-source_only_implementation_missing_proof-61062316`
- Type: `source_only_implementation_missing_proof`
- Severity: `yellow`
- Recommended action: `finish`
- Rationale: Source-only item needs focused proof before it can be considered implemented.
- Linear issue ready: `True`
- Auto-resolved: `False`
- Involved:
  - `TRAIN_12_EXTERNAL_SURFACES_WIDGETS_INTENTS_SHARE` — `prompts/trains/ios26-flagship/TRAIN_12_EXTERNAL_SURFACES_WIDGETS_INTENTS_SHARE.md` (partial_implementation; source-only)

### 16. Source-only or missing-proof implementation state: TRAIN_13_ACCESSIBILITY_EQUIVALENCE

- Conflict ID: `AMB28-source_only_implementation_missing_proof-35997276`
- Type: `source_only_implementation_missing_proof`
- Severity: `yellow`
- Recommended action: `finish`
- Rationale: Source-only item needs focused proof before it can be considered implemented.
- Linear issue ready: `True`
- Auto-resolved: `False`
- Involved:
  - `TRAIN_13_ACCESSIBILITY_EQUIVALENCE` — `prompts/trains/ios26-flagship/TRAIN_13_ACCESSIBILITY_EQUIVALENCE.md` (partial_implementation; source-only)

### 17. Source-only or missing-proof implementation state: TRAIN_14_PERFORMANCE_INSTRUMENTS_POWER

- Conflict ID: `AMB28-source_only_implementation_missing_proof-66118124`
- Type: `source_only_implementation_missing_proof`
- Severity: `yellow`
- Recommended action: `finish`
- Rationale: Source-only item needs focused proof before it can be considered implemented.
- Linear issue ready: `True`
- Auto-resolved: `False`
- Involved:
  - `TRAIN_14_PERFORMANCE_INSTRUMENTS_POWER` — `prompts/trains/ios26-flagship/TRAIN_14_PERFORMANCE_INSTRUMENTS_POWER.md` (partial_implementation; source-only)

### 18. Source-only or missing-proof implementation state: TRAIN_15_REPO_HYGIENE_NAMING_DRIFT_HISTORICAL_QUARANTINE

- Conflict ID: `AMB28-source_only_implementation_missing_proof-85494842`
- Type: `source_only_implementation_missing_proof`
- Severity: `yellow`
- Recommended action: `finish`
- Rationale: Source-only item needs focused proof before it can be considered implemented.
- Linear issue ready: `True`
- Auto-resolved: `False`
- Involved:
  - `TRAIN_15_REPO_HYGIENE_NAMING_DRIFT_HISTORICAL_QUARANTINE` — `prompts/trains/ios26-flagship/TRAIN_15_REPO_HYGIENE_NAMING_DRIFT_HISTORICAL_QUARANTINE.md` (partial_implementation; source-only)

### 19. Source-only or missing-proof implementation state: ldi06-pack-registry-fixture

- Conflict ID: `AMB28-source_only_implementation_missing_proof-49946222`
- Type: `source_only_implementation_missing_proof`
- Severity: `yellow`
- Recommended action: `finish`
- Rationale: Source-only item needs focused proof before it can be considered implemented.
- Linear issue ready: `True`
- Auto-resolved: `False`
- Involved:
  - `ldi06-pack-registry-fixture` — `docs/codex/fixtures/ldi/ldi06-pack-registry-fixture.json` (partial_implementation; source-only)

### 20. Source-only or missing-proof implementation state: parallel-guard-concept-registry

- Conflict ID: `AMB28-source_only_implementation_missing_proof-87401422`
- Type: `source_only_implementation_missing_proof`
- Severity: `yellow`
- Recommended action: `finish`
- Rationale: Source-only item needs focused proof before it can be considered implemented.
- Linear issue ready: `True`
- Auto-resolved: `False`
- Involved:
  - `parallel-guard-concept-registry` — `docs/codex/parallel-guard-concept-registry.yml` (partial_implementation; source-only)


## Duplicate stable IDs

### 1. Duplicate stable ID: AMB-CHATGPT-REPO-OS-UPGRADE-INSTALL-01

- Conflict ID: `AMB28-duplicate_stable_id-30694637`
- Type: `duplicate_stable_id`
- Severity: `yellow`
- Recommended action: `merge`
- Rationale: Duplicate stable IDs must be merged, namespaced, retired, or explicitly classified before Linear sync.
- Linear issue ready: `True`
- Auto-resolved: `False`
- Involved:
  - `AMB-CHATGPT-REPO-OS-UPGRADE-INSTALL-01` — `docs/codex/reports/AMB-CHATGPT-REPO-OS-UPGRADE-INSTALL-01.md` (partial_implementation; release proof)
  - `AMB-CHATGPT-REPO-OS-UPGRADE-INSTALL-01` — `prompts/batches/AMB-CHATGPT-REPO-OS-UPGRADE-INSTALL-01.md` (canceled; release proof)

### 2. Duplicate stable ID: AMB-CODEX-OS-FLAGSHIP-UPGRADE-INSTALL-01

- Conflict ID: `AMB28-duplicate_stable_id-84016860`
- Type: `duplicate_stable_id`
- Severity: `yellow`
- Recommended action: `merge`
- Rationale: Duplicate stable IDs must be merged, namespaced, retired, or explicitly classified before Linear sync.
- Linear issue ready: `True`
- Auto-resolved: `False`
- Involved:
  - `AMB-CODEX-OS-FLAGSHIP-UPGRADE-INSTALL-01` — `docs/codex/reports/AMB-CODEX-OS-FLAGSHIP-UPGRADE-INSTALL-01.md` (partial_implementation; release proof)
  - `AMB-CODEX-OS-FLAGSHIP-UPGRADE-INSTALL-01` — `prompts/batches/AMB-CODEX-OS-FLAGSHIP-UPGRADE-INSTALL-01.md` (partial_implementation; release proof)

### 3. Duplicate stable ID: AMB-FE-BE-PREFLIGHT-00

- Conflict ID: `AMB28-duplicate_stable_id-91382211`
- Type: `duplicate_stable_id`
- Severity: `yellow`
- Recommended action: `merge`
- Rationale: Duplicate stable IDs must be merged, namespaced, retired, or explicitly classified before Linear sync.
- Linear issue ready: `True`
- Auto-resolved: `False`
- Involved:
  - `AMB-FE-BE-PREFLIGHT-00` — `.codex/reports/AMB-FE-BE-PREFLIGHT-00.md` (partial_implementation; release proof)
  - `AMB-FE-BE-PREFLIGHT-00` — `prompts/batches/amb-fe-be/AMB-FE-BE-PREFLIGHT-00.md` (partial_implementation; release proof)

### 4. Duplicate stable ID: AMB-FILE-BY-FILE-REPO-AUDIT-01

- Conflict ID: `AMB28-duplicate_stable_id-46473867`
- Type: `duplicate_stable_id`
- Severity: `yellow`
- Recommended action: `merge`
- Rationale: Duplicate stable IDs must be merged, namespaced, retired, or explicitly classified before Linear sync.
- Linear issue ready: `True`
- Auto-resolved: `False`
- Involved:
  - `AMB-FILE-BY-FILE-REPO-AUDIT-01` — `prompts/batches/AMB-FILE-BY-FILE-REPO-AUDIT-01.md` (partial_implementation; release proof)
  - `AMB-FILE-BY-FILE-REPO-AUDIT-01` — `docs/audits/AMB-FILE-BY-FILE-REPO-AUDIT-01.md` (partial_implementation; tests)

### 5. Duplicate stable ID: AMB-FLAGSHIP-UI-CODEX-STUDIO-INSTALL-01

- Conflict ID: `AMB28-duplicate_stable_id-99080861`
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

### 6. Duplicate stable ID: AMB-POST23-00-COMPLETION-SENTINEL

- Conflict ID: `AMB28-duplicate_stable_id-85236679`
- Type: `duplicate_stable_id`
- Severity: `yellow`
- Recommended action: `merge`
- Rationale: Duplicate stable IDs must be merged, namespaced, retired, or explicitly classified before Linear sync.
- Linear issue ready: `True`
- Auto-resolved: `False`
- Involved:
  - `AMB-POST23-00-COMPLETION-SENTINEL` — `prompts/batches/post-23-truth-audit/AMB-POST23-00-COMPLETION-SENTINEL.md` (partial_implementation; release proof)
  - `AMB-POST23-00-COMPLETION-SENTINEL` — `docs/codex/reports/AMB-POST23-00-COMPLETION-SENTINEL.md` (unknown; release proof)

### 7. Duplicate stable ID: AMB-POST23-01-TRUTH-AUDIT

- Conflict ID: `AMB28-duplicate_stable_id-39248513`
- Type: `duplicate_stable_id`
- Severity: `yellow`
- Recommended action: `merge`
- Rationale: Duplicate stable IDs must be merged, namespaced, retired, or explicitly classified before Linear sync.
- Linear issue ready: `True`
- Auto-resolved: `False`
- Involved:
  - `AMB-POST23-01-TRUTH-AUDIT` — `prompts/batches/post-23-truth-audit/AMB-POST23-01-TRUTH-AUDIT.md` (partial_implementation; release proof)
  - `AMB-POST23-01-TRUTH-AUDIT` — `docs/codex/reports/AMB-POST23-01-TRUTH-AUDIT.md` (partial_implementation; release proof)

### 8. Duplicate stable ID: AMB-POST23-02-UNDERDELIVERY-REPAIR

- Conflict ID: `AMB28-duplicate_stable_id-91770692`
- Type: `duplicate_stable_id`
- Severity: `yellow`
- Recommended action: `merge`
- Rationale: Duplicate stable IDs must be merged, namespaced, retired, or explicitly classified before Linear sync.
- Linear issue ready: `True`
- Auto-resolved: `False`
- Involved:
  - `AMB-POST23-02-UNDERDELIVERY-REPAIR` — `prompts/batches/post-23-truth-audit/AMB-POST23-02-UNDERDELIVERY-REPAIR.md` (partial_implementation; release proof)
  - `AMB-POST23-02-UNDERDELIVERY-REPAIR` — `docs/codex/reports/AMB-POST23-02-UNDERDELIVERY-REPAIR.md` (partial_implementation; release proof)

### 9. Duplicate stable ID: AMB-POST23-03-AUTHORITY-CLEANUP-AND-ROUTING

- Conflict ID: `AMB28-duplicate_stable_id-21981227`
- Type: `duplicate_stable_id`
- Severity: `yellow`
- Recommended action: `merge`
- Rationale: Duplicate stable IDs must be merged, namespaced, retired, or explicitly classified before Linear sync.
- Linear issue ready: `True`
- Auto-resolved: `False`
- Involved:
  - `AMB-POST23-03-AUTHORITY-CLEANUP-AND-ROUTING` — `prompts/batches/post-23-truth-audit/AMB-POST23-03-AUTHORITY-CLEANUP-AND-ROUTING.md` (partial_implementation; release proof)
  - `AMB-POST23-03-AUTHORITY-CLEANUP-AND-ROUTING` — `docs/codex/reports/AMB-POST23-03-AUTHORITY-CLEANUP-AND-ROUTING.md` (partial_implementation; release proof)

### 10. Duplicate stable ID: AMB-POST23-04-NEXT-TRAIN-RECOMMENDATION

- Conflict ID: `AMB28-duplicate_stable_id-64467505`
- Type: `duplicate_stable_id`
- Severity: `yellow`
- Recommended action: `merge`
- Rationale: Duplicate stable IDs must be merged, namespaced, retired, or explicitly classified before Linear sync.
- Linear issue ready: `True`
- Auto-resolved: `False`
- Involved:
  - `AMB-POST23-04-NEXT-TRAIN-RECOMMENDATION` — `prompts/batches/post-23-truth-audit/AMB-POST23-04-NEXT-TRAIN-RECOMMENDATION.md` (partial_implementation; release proof)
  - `AMB-POST23-04-NEXT-TRAIN-RECOMMENDATION` — `docs/codex/reports/AMB-POST23-04-NEXT-TRAIN-RECOMMENDATION.md` (partial_implementation; release proof)

### 11. Duplicate stable ID: AMB-REPO-GREEN-FLAGSHIP-RESET-MASTER-01

- Conflict ID: `AMB28-duplicate_stable_id-50777356`
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

### 12. Duplicate stable ID: AMB-REPO-GREEN-FLAGSHIP-RESET-MASTER-01-T03-VOCAB-LEDGER

- Conflict ID: `AMB28-duplicate_stable_id-42029111`
- Type: `duplicate_stable_id`
- Severity: `yellow`
- Recommended action: `merge`
- Rationale: Duplicate stable IDs must be merged, namespaced, retired, or explicitly classified before Linear sync.
- Linear issue ready: `True`
- Auto-resolved: `False`
- Involved:
  - `AMB-REPO-GREEN-FLAGSHIP-RESET-MASTER-01-T03-VOCAB-LEDGER` — `prompts/batches/AMB-REPO-GREEN-FLAGSHIP-RESET-MASTER-01-T03-VOCAB-LEDGER.md` (partial_implementation; release proof)
  - `AMB-REPO-GREEN-FLAGSHIP-RESET-MASTER-01-T03-VOCAB-LEDGER` — `docs/audits/AMB-REPO-GREEN-FLAGSHIP-RESET-MASTER-01-T03-VOCAB-LEDGER.json` (retired; release proof)

### 13. Duplicate stable ID: AMB-REPO-GREEN-FLAGSHIP-RESET-MASTER-01-T05-SOURCE-REFRACTOR-MAP

- Conflict ID: `AMB28-duplicate_stable_id-5337332`
- Type: `duplicate_stable_id`
- Severity: `yellow`
- Recommended action: `merge`
- Rationale: Duplicate stable IDs must be merged, namespaced, retired, or explicitly classified before Linear sync.
- Linear issue ready: `True`
- Auto-resolved: `False`
- Involved:
  - `AMB-REPO-GREEN-FLAGSHIP-RESET-MASTER-01-T05-SOURCE-REFRACTOR-MAP` — `prompts/batches/AMB-REPO-GREEN-FLAGSHIP-RESET-MASTER-01-T05-SOURCE-REFRACTOR-MAP.md` (partial_implementation; release proof)
  - `AMB-REPO-GREEN-FLAGSHIP-RESET-MASTER-01-T05-SOURCE-REFRACTOR-MAP` — `docs/audits/AMB-REPO-GREEN-FLAGSHIP-RESET-MASTER-01-T05-SOURCE-REFRACTOR-MAP.json` (unknown; audit)

### 14. Duplicate stable ID: AMB-REPO-GREEN-FLAGSHIP-RESET-MASTER-01-T17-FINAL-IA-SCAN

- Conflict ID: `AMB28-duplicate_stable_id-17786025`
- Type: `duplicate_stable_id`
- Severity: `yellow`
- Recommended action: `merge`
- Rationale: Duplicate stable IDs must be merged, namespaced, retired, or explicitly classified before Linear sync.
- Linear issue ready: `True`
- Auto-resolved: `False`
- Involved:
  - `AMB-REPO-GREEN-FLAGSHIP-RESET-MASTER-01-T17-FINAL-IA-SCAN` — `prompts/batches/AMB-REPO-GREEN-FLAGSHIP-RESET-MASTER-01-T17-FINAL-IA-SCAN.md` (partial_implementation; release proof)
  - `AMB-REPO-GREEN-FLAGSHIP-RESET-MASTER-01-T17-FINAL-IA-SCAN` — `docs/audits/AMB-REPO-GREEN-FLAGSHIP-RESET-MASTER-01-T17-FINAL-IA-SCAN.json` (retired; audit)

### 15. Duplicate stable ID: AMB_GLOBAL_REMAINING_TRAIN_BLUEPRINT

- Conflict ID: `AMB28-duplicate_stable_id-59026402`
- Type: `duplicate_stable_id`
- Severity: `yellow`
- Recommended action: `merge`
- Rationale: Duplicate stable IDs must be merged, namespaced, retired, or explicitly classified before Linear sync.
- Linear issue ready: `True`
- Auto-resolved: `False`
- Involved:
  - `AMB_GLOBAL_REMAINING_TRAIN_BLUEPRINT` — `docs/codex/AMB_GLOBAL_REMAINING_TRAIN_BLUEPRINT.md` (unknown; release proof)
  - `AMB_GLOBAL_REMAINING_TRAIN_BLUEPRINT` — `docs/codex/AMB_GLOBAL_REMAINING_TRAIN_BLUEPRINT.json` (unknown; tests)

### 16. Duplicate stable ID: AMB_REMAINING_BATCH_REFERENCE

- Conflict ID: `AMB28-duplicate_stable_id-76451605`
- Type: `duplicate_stable_id`
- Severity: `yellow`
- Recommended action: `merge`
- Rationale: Duplicate stable IDs must be merged, namespaced, retired, or explicitly classified before Linear sync.
- Linear issue ready: `True`
- Auto-resolved: `False`
- Involved:
  - `AMB_REMAINING_BATCH_REFERENCE` — `docs/codex/AMB_REMAINING_BATCH_REFERENCE.json` (partial_implementation; release proof)
  - `AMB_REMAINING_BATCH_REFERENCE` — `docs/codex/AMB_REMAINING_BATCH_REFERENCE.md` (partial_implementation; release proof)

### 17. Duplicate stable ID: BL-00

- Conflict ID: `AMB28-duplicate_stable_id-21645156`
- Type: `duplicate_stable_id`
- Severity: `yellow`
- Recommended action: `merge`
- Rationale: Duplicate stable IDs must be merged, namespaced, retired, or explicitly classified before Linear sync.
- Linear issue ready: `True`
- Auto-resolved: `False`
- Involved:
  - `BL-00` — `docs/codex/IOS26_FLAGSHIP_BACKLOG_MAP.md` (partial_implementation; release proof)
  - `BL-00` — `docs/codex/backlog/ios26-flagship-maturation-backlog.md` (partial_implementation; release proof)

### 18. Duplicate stable ID: FE-12-CHROME-CONTRACTS-HARDENING

- Conflict ID: `AMB28-duplicate_stable_id-9737119`
- Type: `duplicate_stable_id`
- Severity: `yellow`
- Recommended action: `merge`
- Rationale: Duplicate stable IDs must be merged, namespaced, retired, or explicitly classified before Linear sync.
- Linear issue ready: `True`
- Auto-resolved: `False`
- Involved:
  - `FE-12-CHROME-CONTRACTS-HARDENING` — `prompts/batches/amb-fe-be/FE-12-CHROME-CONTRACTS-HARDENING.md` (partial_implementation; release proof)
  - `FE-12-CHROME-CONTRACTS-HARDENING` — `docs/codex/reports/FE-12-CHROME-CONTRACTS-HARDENING.md` (partial_implementation; release proof)

### 19. Duplicate stable ID: IOS26-FLAGSHIP

- Conflict ID: `AMB28-duplicate_stable_id-48252112`
- Type: `duplicate_stable_id`
- Severity: `yellow`
- Recommended action: `merge`
- Rationale: Duplicate stable IDs must be merged, namespaced, retired, or explicitly classified before Linear sync.
- Linear issue ready: `True`
- Auto-resolved: `False`
- Involved:
  - `IOS26-FLAGSHIP` — `docs/codex/IOS26_FLAGSHIP_TRAIN_MANIFEST.yml` (partial_implementation; release proof)
  - `IOS26-FLAGSHIP` — `docs/codex/IOS26_FLAGSHIP_EXECUTION_STATE.yml` (partial_implementation; source-only)

### 20. Duplicate stable ID: PK16

- Conflict ID: `AMB28-duplicate_stable_id-18834981`
- Type: `duplicate_stable_id`
- Severity: `yellow`
- Recommended action: `merge`
- Rationale: Duplicate stable IDs must be merged, namespaced, retired, or explicitly classified before Linear sync.
- Linear issue ready: `True`
- Auto-resolved: `False`
- Involved:
  - `PK16` — `docs/codex/batch-prep/PK16.md` (partial_implementation; release proof)
  - `PK16` — `prompts/batches/PK16.md` (canceled; release proof)

### 21. Duplicate stable ID: PK17

- Conflict ID: `AMB28-duplicate_stable_id-46144548`
- Type: `duplicate_stable_id`
- Severity: `yellow`
- Recommended action: `merge`
- Rationale: Duplicate stable IDs must be merged, namespaced, retired, or explicitly classified before Linear sync.
- Linear issue ready: `True`
- Auto-resolved: `False`
- Involved:
  - `PK17` — `docs/codex/batch-prep/PK17.md` (partial_implementation; release proof)
  - `PK17` — `prompts/batches/PK17.md` (partial_implementation; release proof)

### 22. Duplicate stable ID: PK18

- Conflict ID: `AMB28-duplicate_stable_id-79314070`
- Type: `duplicate_stable_id`
- Severity: `yellow`
- Recommended action: `merge`
- Rationale: Duplicate stable IDs must be merged, namespaced, retired, or explicitly classified before Linear sync.
- Linear issue ready: `True`
- Auto-resolved: `False`
- Involved:
  - `PK18` — `docs/codex/batch-prep/PK18.md` (partial_implementation; release proof)
  - `PK18` — `prompts/batches/PK18.md` (partial_implementation; release proof)

### 23. Duplicate stable ID: PK19

- Conflict ID: `AMB28-duplicate_stable_id-65626219`
- Type: `duplicate_stable_id`
- Severity: `yellow`
- Recommended action: `merge`
- Rationale: Duplicate stable IDs must be merged, namespaced, retired, or explicitly classified before Linear sync.
- Linear issue ready: `True`
- Auto-resolved: `False`
- Involved:
  - `PK19` — `docs/codex/batch-prep/PK19.md` (partial_implementation; release proof)
  - `PK19` — `prompts/batches/PK19.md` (partial_implementation; release proof)

### 24. Duplicate stable ID: PK20

- Conflict ID: `AMB28-duplicate_stable_id-93204349`
- Type: `duplicate_stable_id`
- Severity: `yellow`
- Recommended action: `merge`
- Rationale: Duplicate stable IDs must be merged, namespaced, retired, or explicitly classified before Linear sync.
- Linear issue ready: `True`
- Auto-resolved: `False`
- Involved:
  - `PK20` — `docs/codex/batch-prep/PK20.md` (partial_implementation; release proof)
  - `PK20` — `prompts/batches/PK20.md` (partial_implementation; release proof)

### 25. Duplicate stable ID: PK21

- Conflict ID: `AMB28-duplicate_stable_id-95460349`
- Type: `duplicate_stable_id`
- Severity: `yellow`
- Recommended action: `merge`
- Rationale: Duplicate stable IDs must be merged, namespaced, retired, or explicitly classified before Linear sync.
- Linear issue ready: `True`
- Auto-resolved: `False`
- Involved:
  - `PK21` — `docs/codex/batch-prep/PK21.md` (partial_implementation; release proof)
  - `PK21` — `prompts/batches/PK21.md` (partial_implementation; release proof)

### 26. Duplicate stable ID: PK22

- Conflict ID: `AMB28-duplicate_stable_id-61672752`
- Type: `duplicate_stable_id`
- Severity: `yellow`
- Recommended action: `merge`
- Rationale: Duplicate stable IDs must be merged, namespaced, retired, or explicitly classified before Linear sync.
- Linear issue ready: `True`
- Auto-resolved: `False`
- Involved:
  - `PK22` — `docs/codex/batch-prep/PK22.md` (partial_implementation; release proof)
  - `PK22` — `prompts/batches/PK22.md` (partial_implementation; release proof)

### 27. Duplicate stable ID: PK23

- Conflict ID: `AMB28-duplicate_stable_id-30606407`
- Type: `duplicate_stable_id`
- Severity: `yellow`
- Recommended action: `merge`
- Rationale: Duplicate stable IDs must be merged, namespaced, retired, or explicitly classified before Linear sync.
- Linear issue ready: `True`
- Auto-resolved: `False`
- Involved:
  - `PK23` — `docs/codex/batch-prep/PK23.md` (partial_implementation; release proof)
  - `PK23` — `prompts/batches/PK23.md` (partial_implementation; release proof)

### 28. Duplicate stable ID: PK24

- Conflict ID: `AMB28-duplicate_stable_id-30073337`
- Type: `duplicate_stable_id`
- Severity: `yellow`
- Recommended action: `merge`
- Rationale: Duplicate stable IDs must be merged, namespaced, retired, or explicitly classified before Linear sync.
- Linear issue ready: `True`
- Auto-resolved: `False`
- Involved:
  - `PK24` — `docs/codex/batch-prep/PK24.md` (partial_implementation; release proof)
  - `PK24` — `prompts/batches/PK24.md` (partial_implementation; release proof)

### 29. Duplicate stable ID: PK25

- Conflict ID: `AMB28-duplicate_stable_id-68169654`
- Type: `duplicate_stable_id`
- Severity: `yellow`
- Recommended action: `merge`
- Rationale: Duplicate stable IDs must be merged, namespaced, retired, or explicitly classified before Linear sync.
- Linear issue ready: `True`
- Auto-resolved: `False`
- Involved:
  - `PK25` — `docs/codex/batch-prep/PK25.md` (partial_implementation; release proof)
  - `PK25` — `prompts/batches/PK25.md` (partial_implementation; release proof)

### 30. Duplicate stable ID: POST99-UI-SUITE-REVIEW-IMPLEMENTATION-00

- Conflict ID: `AMB28-duplicate_stable_id-27437331`
- Type: `duplicate_stable_id`
- Severity: `yellow`
- Recommended action: `merge`
- Rationale: Duplicate stable IDs must be merged, namespaced, retired, or explicitly classified before Linear sync.
- Linear issue ready: `True`
- Auto-resolved: `False`
- Involved:
  - `POST99-UI-SUITE-REVIEW-IMPLEMENTATION-00` — `docs/codex/reports/POST99-UI-SUITE-REVIEW-IMPLEMENTATION-00.md` (partial_implementation; release proof)
  - `POST99-UI-SUITE-REVIEW-IMPLEMENTATION-00` — `prompts/batches/POST99-UI-SUITE-REVIEW-IMPLEMENTATION-00.md` (partial_implementation; release proof)

### 31. Duplicate stable ID: README

- Conflict ID: `AMB28-duplicate_stable_id-71725698`
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

### 32. Duplicate stable ID: existing-code-champion-coverage

- Conflict ID: `AMB28-duplicate_stable_id-37020014`
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

- Conflict ID: `AMB28-stale_or_unknown_active_status-47827619`
- Type: `stale_or_unknown_active_status`
- Severity: `yellow`
- Recommended action: `expedite`
- Rationale: Unknown active batch/prompt/train status should be clarified before it blocks or duplicates future work.
- Linear issue ready: `True`
- Auto-resolved: `False`
- Involved:
  - `AMB-CHATGPT-APP-STORE-HONESTY-PROMPT-TEMPLATE` — `docs/codex/chatgpt/AMB-CHATGPT-APP-STORE-HONESTY-PROMPT-TEMPLATE.md` (unknown; release proof)

### 2. Unknown active status: AMB-CHATGPT-APPLE-CONTINUITY-PROMPT-TEMPLATE

- Conflict ID: `AMB28-stale_or_unknown_active_status-12521143`
- Type: `stale_or_unknown_active_status`
- Severity: `yellow`
- Recommended action: `expedite`
- Rationale: Unknown active batch/prompt/train status should be clarified before it blocks or duplicates future work.
- Linear issue ready: `True`
- Auto-resolved: `False`
- Involved:
  - `AMB-CHATGPT-APPLE-CONTINUITY-PROMPT-TEMPLATE` — `docs/codex/chatgpt/AMB-CHATGPT-APPLE-CONTINUITY-PROMPT-TEMPLATE.md` (unknown; release proof)

### 3. Unknown active status: AMB-CHATGPT-BACKEND-PROMPT-TEMPLATE

- Conflict ID: `AMB28-stale_or_unknown_active_status-57211982`
- Type: `stale_or_unknown_active_status`
- Severity: `yellow`
- Recommended action: `expedite`
- Rationale: Unknown active batch/prompt/train status should be clarified before it blocks or duplicates future work.
- Linear issue ready: `True`
- Auto-resolved: `False`
- Involved:
  - `AMB-CHATGPT-BACKEND-PROMPT-TEMPLATE` — `docs/codex/chatgpt/AMB-CHATGPT-BACKEND-PROMPT-TEMPLATE.md` (unknown; release proof)

### 4. Unknown active status: AMB-CHATGPT-CODEX-HANDOFF-TEMPLATE

- Conflict ID: `AMB28-stale_or_unknown_active_status-55136091`
- Type: `stale_or_unknown_active_status`
- Severity: `yellow`
- Recommended action: `expedite`
- Rationale: Unknown active batch/prompt/train status should be clarified before it blocks or duplicates future work.
- Linear issue ready: `True`
- Auto-resolved: `False`
- Involved:
  - `AMB-CHATGPT-CODEX-HANDOFF-TEMPLATE` — `docs/codex/chatgpt/AMB-CHATGPT-CODEX-HANDOFF-TEMPLATE.md` (unknown; release proof)

### 5. Unknown active status: AMB-CHATGPT-DECISION-LOG-STANDARD

- Conflict ID: `AMB28-stale_or_unknown_active_status-85192910`
- Type: `stale_or_unknown_active_status`
- Severity: `yellow`
- Recommended action: `expedite`
- Rationale: Unknown active batch/prompt/train status should be clarified before it blocks or duplicates future work.
- Linear issue ready: `True`
- Auto-resolved: `False`
- Involved:
  - `AMB-CHATGPT-DECISION-LOG-STANDARD` — `docs/codex/chatgpt/AMB-CHATGPT-DECISION-LOG-STANDARD.md` (unknown; release proof)

### 6. Unknown active status: AMB-CHATGPT-FLAGSHIP-BAR

- Conflict ID: `AMB28-stale_or_unknown_active_status-56311009`
- Type: `stale_or_unknown_active_status`
- Severity: `yellow`
- Recommended action: `expedite`
- Rationale: Unknown active batch/prompt/train status should be clarified before it blocks or duplicates future work.
- Linear issue ready: `True`
- Auto-resolved: `False`
- Involved:
  - `AMB-CHATGPT-FLAGSHIP-BAR` — `docs/codex/chatgpt/AMB-CHATGPT-FLAGSHIP-BAR.md` (unknown; release proof)

### 7. Unknown active status: AMB-CHATGPT-HANDOFF-OS

- Conflict ID: `AMB28-stale_or_unknown_active_status-46610266`
- Type: `stale_or_unknown_active_status`
- Severity: `yellow`
- Recommended action: `expedite`
- Rationale: Unknown active batch/prompt/train status should be clarified before it blocks or duplicates future work.
- Linear issue ready: `True`
- Auto-resolved: `False`
- Involved:
  - `AMB-CHATGPT-HANDOFF-OS` — `docs/codex/chatgpt/AMB-CHATGPT-HANDOFF-OS.md` (unknown; release proof)

### 8. Unknown active status: AMB-CHATGPT-LAUNCH-SCOPE-DECISIONS

- Conflict ID: `AMB28-stale_or_unknown_active_status-84437434`
- Type: `stale_or_unknown_active_status`
- Severity: `yellow`
- Recommended action: `expedite`
- Rationale: Unknown active batch/prompt/train status should be clarified before it blocks or duplicates future work.
- Linear issue ready: `True`
- Auto-resolved: `False`
- Involved:
  - `AMB-CHATGPT-LAUNCH-SCOPE-DECISIONS` — `docs/codex/chatgpt/AMB-CHATGPT-LAUNCH-SCOPE-DECISIONS.md` (unknown; release proof)

### 9. Unknown active status: AMB-CHATGPT-REPO-QUESTION-PATTERNS

- Conflict ID: `AMB28-stale_or_unknown_active_status-46678073`
- Type: `stale_or_unknown_active_status`
- Severity: `yellow`
- Recommended action: `expedite`
- Rationale: Unknown active batch/prompt/train status should be clarified before it blocks or duplicates future work.
- Linear issue ready: `True`
- Auto-resolved: `False`
- Involved:
  - `AMB-CHATGPT-REPO-QUESTION-PATTERNS` — `docs/codex/chatgpt/AMB-CHATGPT-REPO-QUESTION-PATTERNS.md` (unknown; release proof)

### 10. Unknown active status: AMB-CHATGPT-REVIEW-BOARD-STANDARD

- Conflict ID: `AMB28-stale_or_unknown_active_status-98267778`
- Type: `stale_or_unknown_active_status`
- Severity: `yellow`
- Recommended action: `expedite`
- Rationale: Unknown active batch/prompt/train status should be clarified before it blocks or duplicates future work.
- Linear issue ready: `True`
- Auto-resolved: `False`
- Involved:
  - `AMB-CHATGPT-REVIEW-BOARD-STANDARD` — `docs/codex/chatgpt/AMB-CHATGPT-REVIEW-BOARD-STANDARD.md` (unknown; release proof)

### 11. Unknown active status: AMB-CHATGPT-REVIEW-PROMPT-TEMPLATE

- Conflict ID: `AMB28-stale_or_unknown_active_status-99346839`
- Type: `stale_or_unknown_active_status`
- Severity: `yellow`
- Recommended action: `expedite`
- Rationale: Unknown active batch/prompt/train status should be clarified before it blocks or duplicates future work.
- Linear issue ready: `True`
- Auto-resolved: `False`
- Involved:
  - `AMB-CHATGPT-REVIEW-PROMPT-TEMPLATE` — `docs/codex/chatgpt/AMB-CHATGPT-REVIEW-PROMPT-TEMPLATE.md` (unknown; release proof)

### 12. Unknown active status: AMB-CHATGPT-TO-CODEX-PROMPT-STANDARD

- Conflict ID: `AMB28-stale_or_unknown_active_status-57856508`
- Type: `stale_or_unknown_active_status`
- Severity: `yellow`
- Recommended action: `expedite`
- Rationale: Unknown active batch/prompt/train status should be clarified before it blocks or duplicates future work.
- Linear issue ready: `True`
- Auto-resolved: `False`
- Involved:
  - `AMB-CHATGPT-TO-CODEX-PROMPT-STANDARD` — `docs/codex/chatgpt/AMB-CHATGPT-TO-CODEX-PROMPT-STANDARD.md` (unknown; release proof)

### 13. Unknown active status: AMB-CHATGPT-UI-PROMPT-TEMPLATE

- Conflict ID: `AMB28-stale_or_unknown_active_status-35190342`
- Type: `stale_or_unknown_active_status`
- Severity: `yellow`
- Recommended action: `expedite`
- Rationale: Unknown active batch/prompt/train status should be clarified before it blocks or duplicates future work.
- Linear issue ready: `True`
- Auto-resolved: `False`
- Involved:
  - `AMB-CHATGPT-UI-PROMPT-TEMPLATE` — `docs/codex/chatgpt/AMB-CHATGPT-UI-PROMPT-TEMPLATE.md` (unknown; release proof)

### 14. Unknown active status: AMB-CODEX-OS-APPLE-CONTINUITY-GATE

- Conflict ID: `AMB28-stale_or_unknown_active_status-83807902`
- Type: `stale_or_unknown_active_status`
- Severity: `yellow`
- Recommended action: `expedite`
- Rationale: Unknown active batch/prompt/train status should be clarified before it blocks or duplicates future work.
- Linear issue ready: `True`
- Auto-resolved: `False`
- Involved:
  - `AMB-CODEX-OS-APPLE-CONTINUITY-GATE` — `docs/codex/os/AMB-CODEX-OS-APPLE-CONTINUITY-GATE.md` (unknown; release proof)

### 15. Unknown active status: AMB-CODEX-OS-AUTHORITY-RESOLVER

- Conflict ID: `AMB28-stale_or_unknown_active_status-43578398`
- Type: `stale_or_unknown_active_status`
- Severity: `yellow`
- Recommended action: `expedite`
- Rationale: Unknown active batch/prompt/train status should be clarified before it blocks or duplicates future work.
- Linear issue ready: `True`
- Auto-resolved: `False`
- Involved:
  - `AMB-CODEX-OS-AUTHORITY-RESOLVER` — `docs/codex/os/AMB-CODEX-OS-AUTHORITY-RESOLVER.md` (unknown; release proof)

### 16. Unknown active status: AMB-CODEX-OS-LAUNCH-BELIEVABILITY-GATE

- Conflict ID: `AMB28-stale_or_unknown_active_status-54868655`
- Type: `stale_or_unknown_active_status`
- Severity: `yellow`
- Recommended action: `expedite`
- Rationale: Unknown active batch/prompt/train status should be clarified before it blocks or duplicates future work.
- Linear issue ready: `True`
- Auto-resolved: `False`
- Involved:
  - `AMB-CODEX-OS-LAUNCH-BELIEVABILITY-GATE` — `docs/codex/os/AMB-CODEX-OS-LAUNCH-BELIEVABILITY-GATE.md` (unknown; release proof)

### 17. Unknown active status: AMB-CODEX-OS-NO-SPRAWL-GUARD

- Conflict ID: `AMB28-stale_or_unknown_active_status-12310806`
- Type: `stale_or_unknown_active_status`
- Severity: `yellow`
- Recommended action: `expedite`
- Rationale: Unknown active batch/prompt/train status should be clarified before it blocks or duplicates future work.
- Linear issue ready: `True`
- Auto-resolved: `False`
- Involved:
  - `AMB-CODEX-OS-NO-SPRAWL-GUARD` — `docs/codex/os/AMB-CODEX-OS-NO-SPRAWL-GUARD.md` (unknown; release proof)

### 18. Unknown active status: AMB-CODEX-OS-PRIVACY-CLAIM-GATE

- Conflict ID: `AMB28-stale_or_unknown_active_status-40724664`
- Type: `stale_or_unknown_active_status`
- Severity: `yellow`
- Recommended action: `expedite`
- Rationale: Unknown active batch/prompt/train status should be clarified before it blocks or duplicates future work.
- Linear issue ready: `True`
- Auto-resolved: `False`
- Involved:
  - `AMB-CODEX-OS-PRIVACY-CLAIM-GATE` — `docs/codex/os/AMB-CODEX-OS-PRIVACY-CLAIM-GATE.md` (unknown; release proof)

### 19. Unknown active status: AMB-CODEX-OS-PROOF-LEDGER

- Conflict ID: `AMB28-stale_or_unknown_active_status-83902248`
- Type: `stale_or_unknown_active_status`
- Severity: `yellow`
- Recommended action: `expedite`
- Rationale: Unknown active batch/prompt/train status should be clarified before it blocks or duplicates future work.
- Linear issue ready: `True`
- Auto-resolved: `False`
- Involved:
  - `AMB-CODEX-OS-PROOF-LEDGER` — `docs/codex/os/AMB-CODEX-OS-PROOF-LEDGER.md` (unknown; release proof)

### 20. Unknown active status: AMB-CODEX-OS-VISUAL-QA-GATE

- Conflict ID: `AMB28-stale_or_unknown_active_status-79504270`
- Type: `stale_or_unknown_active_status`
- Severity: `yellow`
- Recommended action: `expedite`
- Rationale: Unknown active batch/prompt/train status should be clarified before it blocks or duplicates future work.
- Linear issue ready: `True`
- Auto-resolved: `False`
- Involved:
  - `AMB-CODEX-OS-VISUAL-QA-GATE` — `docs/codex/os/AMB-CODEX-OS-VISUAL-QA-GATE.md` (unknown; release proof)

### 21. Unknown active status: AMB-FLAGSHIP-UI-CODEX-STUDIO-INSTALL-01

- Conflict ID: `AMB28-stale_or_unknown_active_status-84945191`
- Type: `stale_or_unknown_active_status`
- Severity: `yellow`
- Recommended action: `expedite`
- Rationale: Unknown active batch/prompt/train status should be clarified before it blocks or duplicates future work.
- Linear issue ready: `True`
- Auto-resolved: `False`
- Involved:
  - `AMB-FLAGSHIP-UI-CODEX-STUDIO-INSTALL-01` — `docs/codex/review-boards/AMB-FLAGSHIP-UI-CODEX-STUDIO-INSTALL-01.md` (unknown; release proof)

### 22. Unknown active status: AMB-POST23-00-COMPLETION-SENTINEL

- Conflict ID: `AMB28-stale_or_unknown_active_status-83179250`
- Type: `stale_or_unknown_active_status`
- Severity: `yellow`
- Recommended action: `expedite`
- Rationale: Unknown active batch/prompt/train status should be clarified before it blocks or duplicates future work.
- Linear issue ready: `True`
- Auto-resolved: `False`
- Involved:
  - `AMB-POST23-00-COMPLETION-SENTINEL` — `docs/codex/reports/AMB-POST23-00-COMPLETION-SENTINEL.md` (unknown; release proof)

### 23. Unknown active status: AMBITIONSOS_AOS_FIXTURE_STRATEGY

- Conflict ID: `AMB28-stale_or_unknown_active_status-86054390`
- Type: `stale_or_unknown_active_status`
- Severity: `yellow`
- Recommended action: `expedite`
- Rationale: Unknown active batch/prompt/train status should be clarified before it blocks or duplicates future work.
- Linear issue ready: `True`
- Auto-resolved: `False`
- Involved:
  - `AMBITIONSOS_AOS_FIXTURE_STRATEGY` — `docs/codex/AMBITIONSOS_AOS_FIXTURE_STRATEGY.md` (unknown; release proof)

### 24. Unknown active status: AMBITIONSOS_AOS_MODEL_BOUNDARY_PROTOCOL

- Conflict ID: `AMB28-stale_or_unknown_active_status-3198648`
- Type: `stale_or_unknown_active_status`
- Severity: `yellow`
- Recommended action: `expedite`
- Rationale: Unknown active batch/prompt/train status should be clarified before it blocks or duplicates future work.
- Linear issue ready: `True`
- Auto-resolved: `False`
- Involved:
  - `AMBITIONSOS_AOS_MODEL_BOUNDARY_PROTOCOL` — `docs/codex/AMBITIONSOS_AOS_MODEL_BOUNDARY_PROTOCOL.md` (unknown; release proof)

### 25. Unknown active status: AMBITIONSOS_AOS_PERFORMANCE_ENERGY_BUDGET

- Conflict ID: `AMB28-stale_or_unknown_active_status-27333674`
- Type: `stale_or_unknown_active_status`
- Severity: `yellow`
- Recommended action: `expedite`
- Rationale: Unknown active batch/prompt/train status should be clarified before it blocks or duplicates future work.
- Linear issue ready: `True`
- Auto-resolved: `False`
- Involved:
  - `AMBITIONSOS_AOS_PERFORMANCE_ENERGY_BUDGET` — `docs/codex/AMBITIONSOS_AOS_PERFORMANCE_ENERGY_BUDGET.md` (unknown; release proof)

### 26. Unknown active status: AMBITIONSOS_AOS_PRIVACY_PROJECTION_LEDGER

- Conflict ID: `AMB28-stale_or_unknown_active_status-91643916`
- Type: `stale_or_unknown_active_status`
- Severity: `yellow`
- Recommended action: `expedite`
- Rationale: Unknown active batch/prompt/train status should be clarified before it blocks or duplicates future work.
- Linear issue ready: `True`
- Auto-resolved: `False`
- Involved:
  - `AMBITIONSOS_AOS_PRIVACY_PROJECTION_LEDGER` — `docs/codex/AMBITIONSOS_AOS_PRIVACY_PROJECTION_LEDGER.md` (unknown; release proof)

### 27. Unknown active status: AMBITIONSOS_AOS_RED_TEAM_PROTOCOL

- Conflict ID: `AMB28-stale_or_unknown_active_status-23264266`
- Type: `stale_or_unknown_active_status`
- Severity: `yellow`
- Recommended action: `expedite`
- Rationale: Unknown active batch/prompt/train status should be clarified before it blocks or duplicates future work.
- Linear issue ready: `True`
- Auto-resolved: `False`
- Involved:
  - `AMBITIONSOS_AOS_RED_TEAM_PROTOCOL` — `docs/codex/AMBITIONSOS_AOS_RED_TEAM_PROTOCOL.md` (unknown; release proof)

### 28. Unknown active status: AMBITIONSOS_AOS_SCHEMA_AND_MIGRATION_PROTOCOL

- Conflict ID: `AMB28-stale_or_unknown_active_status-68591815`
- Type: `stale_or_unknown_active_status`
- Severity: `yellow`
- Recommended action: `expedite`
- Rationale: Unknown active batch/prompt/train status should be clarified before it blocks or duplicates future work.
- Linear issue ready: `True`
- Auto-resolved: `False`
- Involved:
  - `AMBITIONSOS_AOS_SCHEMA_AND_MIGRATION_PROTOCOL` — `docs/codex/AMBITIONSOS_AOS_SCHEMA_AND_MIGRATION_PROTOCOL.md` (unknown; release proof)

### 29. Unknown active status: AMBITIONSOS_AOS_SIMULATION_STRATEGY

- Conflict ID: `AMB28-stale_or_unknown_active_status-96286590`
- Type: `stale_or_unknown_active_status`
- Severity: `yellow`
- Recommended action: `expedite`
- Rationale: Unknown active batch/prompt/train status should be clarified before it blocks or duplicates future work.
- Linear issue ready: `True`
- Auto-resolved: `False`
- Involved:
  - `AMBITIONSOS_AOS_SIMULATION_STRATEGY` — `docs/codex/AMBITIONSOS_AOS_SIMULATION_STRATEGY.md` (unknown; release proof)

### 30. Unknown active status: AMBITIONSOS_AOS_SOURCE_TRUTH_CLAIM_LEDGER

- Conflict ID: `AMB28-stale_or_unknown_active_status-60613117`
- Type: `stale_or_unknown_active_status`
- Severity: `yellow`
- Recommended action: `expedite`
- Rationale: Unknown active batch/prompt/train status should be clarified before it blocks or duplicates future work.
- Linear issue ready: `True`
- Auto-resolved: `False`
- Involved:
  - `AMBITIONSOS_AOS_SOURCE_TRUTH_CLAIM_LEDGER` — `docs/codex/AMBITIONSOS_AOS_SOURCE_TRUTH_CLAIM_LEDGER.md` (unknown; release proof)

### 31. Unknown active status: AMBITIONS_3_0_PARALLEL_CODEX_WORKTREE_PROTOCOL

- Conflict ID: `AMB28-stale_or_unknown_active_status-80610024`
- Type: `stale_or_unknown_active_status`
- Severity: `yellow`
- Recommended action: `expedite`
- Rationale: Unknown active batch/prompt/train status should be clarified before it blocks or duplicates future work.
- Linear issue ready: `True`
- Auto-resolved: `False`
- Involved:
  - `AMBITIONS_3_0_PARALLEL_CODEX_WORKTREE_PROTOCOL` — `docs/codex/AMBITIONS_3_0_PARALLEL_CODEX_WORKTREE_PROTOCOL.md` (unknown; release proof)

### 32. Unknown active status: AMBITIONS_3_0_RUN_STATE_PROTOCOL

- Conflict ID: `AMB28-stale_or_unknown_active_status-60232025`
- Type: `stale_or_unknown_active_status`
- Severity: `yellow`
- Recommended action: `expedite`
- Rationale: Unknown active batch/prompt/train status should be clarified before it blocks or duplicates future work.
- Linear issue ready: `True`
- Auto-resolved: `False`
- Involved:
  - `AMBITIONS_3_0_RUN_STATE_PROTOCOL` — `docs/codex/AMBITIONS_3_0_RUN_STATE_PROTOCOL.md` (unknown; release proof)

### 33. Unknown active status: AMBITIONS_3_0_SKILL_SYSTEM_INDEX

- Conflict ID: `AMB28-stale_or_unknown_active_status-56226999`
- Type: `stale_or_unknown_active_status`
- Severity: `yellow`
- Recommended action: `expedite`
- Rationale: Unknown active batch/prompt/train status should be clarified before it blocks or duplicates future work.
- Linear issue ready: `True`
- Auto-resolved: `False`
- Involved:
  - `AMBITIONS_3_0_SKILL_SYSTEM_INDEX` — `docs/codex/AMBITIONS_3_0_SKILL_SYSTEM_INDEX.md` (unknown; release proof)

### 34. Unknown active status: AMB_GLOBAL_REMAINING_TRAIN_BLUEPRINT

- Conflict ID: `AMB28-stale_or_unknown_active_status-41970536`
- Type: `stale_or_unknown_active_status`
- Severity: `yellow`
- Recommended action: `expedite`
- Rationale: Unknown active batch/prompt/train status should be clarified before it blocks or duplicates future work.
- Linear issue ready: `True`
- Auto-resolved: `False`
- Involved:
  - `AMB_GLOBAL_REMAINING_TRAIN_BLUEPRINT` — `docs/codex/AMB_GLOBAL_REMAINING_TRAIN_BLUEPRINT.md` (unknown; release proof)

### 35. Unknown active status: AMB_GLOBAL_REMAINING_TRAIN_BLUEPRINT

- Conflict ID: `AMB28-stale_or_unknown_active_status-82143988`
- Type: `stale_or_unknown_active_status`
- Severity: `yellow`
- Recommended action: `expedite`
- Rationale: Unknown active batch/prompt/train status should be clarified before it blocks or duplicates future work.
- Linear issue ready: `True`
- Auto-resolved: `False`
- Involved:
  - `AMB_GLOBAL_REMAINING_TRAIN_BLUEPRINT` — `docs/codex/AMB_GLOBAL_REMAINING_TRAIN_BLUEPRINT.json` (unknown; tests)

### 36. Unknown active status: AQOS01_AQOS30_AUTONOMOUS_QUALITY_TRAIN

- Conflict ID: `AMB28-stale_or_unknown_active_status-71811251`
- Type: `stale_or_unknown_active_status`
- Severity: `yellow`
- Recommended action: `expedite`
- Rationale: Unknown active batch/prompt/train status should be clarified before it blocks or duplicates future work.
- Linear issue ready: `True`
- Auto-resolved: `False`
- Involved:
  - `AQOS01_AQOS30_AUTONOMOUS_QUALITY_TRAIN` — `docs/codex/quality/AQOS01_AQOS30_AUTONOMOUS_QUALITY_TRAIN.md` (unknown; release proof)

### 37. Unknown active status: AQOS_BATCH_IMPACT_CLASSIFIER

- Conflict ID: `AMB28-stale_or_unknown_active_status-5113371`
- Type: `stale_or_unknown_active_status`
- Severity: `yellow`
- Recommended action: `expedite`
- Rationale: Unknown active batch/prompt/train status should be clarified before it blocks or duplicates future work.
- Linear issue ready: `True`
- Auto-resolved: `False`
- Involved:
  - `AQOS_BATCH_IMPACT_CLASSIFIER` — `docs/codex/quality/AQOS_BATCH_IMPACT_CLASSIFIER.md` (unknown; release proof)

### 38. Unknown active status: AQOS_EVIDENCE_MATURITY_LEDGER

- Conflict ID: `AMB28-stale_or_unknown_active_status-29406112`
- Type: `stale_or_unknown_active_status`
- Severity: `yellow`
- Recommended action: `expedite`
- Rationale: Unknown active batch/prompt/train status should be clarified before it blocks or duplicates future work.
- Linear issue ready: `True`
- Auto-resolved: `False`
- Involved:
  - `AQOS_EVIDENCE_MATURITY_LEDGER` — `docs/codex/quality/AQOS_EVIDENCE_MATURITY_LEDGER.md` (unknown; release proof)

### 39. Unknown active status: BATCH-00-repo-operating-system

- Conflict ID: `AMB28-stale_or_unknown_active_status-53071610`
- Type: `stale_or_unknown_active_status`
- Severity: `yellow`
- Recommended action: `expedite`
- Rationale: Unknown active batch/prompt/train status should be clarified before it blocks or duplicates future work.
- Linear issue ready: `True`
- Auto-resolved: `False`
- Involved:
  - `BATCH-00-repo-operating-system` — `docs/codex/batches/BATCH-00-repo-operating-system.md` (unknown; release proof)

### 40. Unknown active status: BATCH-01-pre-phase9-cleanup-and-captures-tab

- Conflict ID: `AMB28-stale_or_unknown_active_status-41538008`
- Type: `stale_or_unknown_active_status`
- Severity: `yellow`
- Recommended action: `expedite`
- Rationale: Unknown active batch/prompt/train status should be clarified before it blocks or duplicates future work.
- Linear issue ready: `True`
- Auto-resolved: `False`
- Involved:
  - `BATCH-01-pre-phase9-cleanup-and-captures-tab` — `docs/codex/batches/BATCH-01-pre-phase9-cleanup-and-captures-tab.md` (unknown; release proof)

### 41. Unknown active status: BATCH-02-delete-legacy-typescript-runtime

- Conflict ID: `AMB28-stale_or_unknown_active_status-42981412`
- Type: `stale_or_unknown_active_status`
- Severity: `yellow`
- Recommended action: `expedite`
- Rationale: Unknown active batch/prompt/train status should be clarified before it blocks or duplicates future work.
- Linear issue ready: `True`
- Auto-resolved: `False`
- Involved:
  - `BATCH-02-delete-legacy-typescript-runtime` — `docs/codex/batches/BATCH-02-delete-legacy-typescript-runtime.md` (unknown; release proof)

### 42. Unknown active status: BATCH-03-canon-batch-1-domain-foundation

- Conflict ID: `AMB28-stale_or_unknown_active_status-60153866`
- Type: `stale_or_unknown_active_status`
- Severity: `yellow`
- Recommended action: `expedite`
- Rationale: Unknown active batch/prompt/train status should be clarified before it blocks or duplicates future work.
- Linear issue ready: `True`
- Auto-resolved: `False`
- Involved:
  - `BATCH-03-canon-batch-1-domain-foundation` — `docs/codex/batches/BATCH-03-canon-batch-1-domain-foundation.md` (unknown; release proof)

### 43. Unknown active status: BATCH-04-canon-batch-2-first-class-capture-core

- Conflict ID: `AMB28-stale_or_unknown_active_status-48393668`
- Type: `stale_or_unknown_active_status`
- Severity: `yellow`
- Recommended action: `expedite`
- Rationale: Unknown active batch/prompt/train status should be clarified before it blocks or duplicates future work.
- Linear issue ready: `True`
- Auto-resolved: `False`
- Involved:
  - `BATCH-04-canon-batch-2-first-class-capture-core` — `docs/codex/batches/BATCH-04-canon-batch-2-first-class-capture-core.md` (unknown; release proof)

### 44. Unknown active status: BATCH-05-canon-batch-3-planning-engine-v2

- Conflict ID: `AMB28-stale_or_unknown_active_status-66891157`
- Type: `stale_or_unknown_active_status`
- Severity: `yellow`
- Recommended action: `expedite`
- Rationale: Unknown active batch/prompt/train status should be clarified before it blocks or duplicates future work.
- Linear issue ready: `True`
- Auto-resolved: `False`
- Involved:
  - `BATCH-05-canon-batch-3-planning-engine-v2` — `docs/codex/batches/BATCH-05-canon-batch-3-planning-engine-v2.md` (unknown; release proof)

### 45. Unknown active status: BATCH-06-canon-batch-4-recovery-engine

- Conflict ID: `AMB28-stale_or_unknown_active_status-28533518`
- Type: `stale_or_unknown_active_status`
- Severity: `yellow`
- Recommended action: `expedite`
- Rationale: Unknown active batch/prompt/train status should be clarified before it blocks or duplicates future work.
- Linear issue ready: `True`
- Auto-resolved: `False`
- Involved:
  - `BATCH-06-canon-batch-4-recovery-engine` — `docs/codex/batches/BATCH-06-canon-batch-4-recovery-engine.md` (unknown; release proof)

### 46. Unknown active status: BATCH-07-canon-batch-5a-time-orchestration-write-paths

- Conflict ID: `AMB28-stale_or_unknown_active_status-57796227`
- Type: `stale_or_unknown_active_status`
- Severity: `yellow`
- Recommended action: `expedite`
- Rationale: Unknown active batch/prompt/train status should be clarified before it blocks or duplicates future work.
- Linear issue ready: `True`
- Auto-resolved: `False`
- Involved:
  - `BATCH-07-canon-batch-5a-time-orchestration-write-paths` — `docs/codex/batches/BATCH-07-canon-batch-5a-time-orchestration-write-paths.md` (unknown; release proof)

### 47. Unknown active status: BATCH-08-canon-batch-5b-time-orchestration-read-paths

- Conflict ID: `AMB28-stale_or_unknown_active_status-58325678`
- Type: `stale_or_unknown_active_status`
- Severity: `yellow`
- Recommended action: `expedite`
- Rationale: Unknown active batch/prompt/train status should be clarified before it blocks or duplicates future work.
- Linear issue ready: `True`
- Auto-resolved: `False`
- Involved:
  - `BATCH-08-canon-batch-5b-time-orchestration-read-paths` — `docs/codex/batches/BATCH-08-canon-batch-5b-time-orchestration-read-paths.md` (unknown; release proof)

### 48. Unknown active status: BATCH-12-canon-batch-9-sync-trust-foundation

- Conflict ID: `AMB28-stale_or_unknown_active_status-34770445`
- Type: `stale_or_unknown_active_status`
- Severity: `yellow`
- Recommended action: `expedite`
- Rationale: Unknown active batch/prompt/train status should be clarified before it blocks or duplicates future work.
- Linear issue ready: `True`
- Auto-resolved: `False`
- Involved:
  - `BATCH-12-canon-batch-9-sync-trust-foundation` — `docs/codex/batches/BATCH-12-canon-batch-9-sync-trust-foundation.md` (unknown; release proof)

### 49. Unknown active status: BATCH-13-canon-batch-10-life-graph-foundation

- Conflict ID: `AMB28-stale_or_unknown_active_status-59313847`
- Type: `stale_or_unknown_active_status`
- Severity: `yellow`
- Recommended action: `expedite`
- Rationale: Unknown active batch/prompt/train status should be clarified before it blocks or duplicates future work.
- Linear issue ready: `True`
- Auto-resolved: `False`
- Involved:
  - `BATCH-13-canon-batch-10-life-graph-foundation` — `docs/codex/batches/BATCH-13-canon-batch-10-life-graph-foundation.md` (unknown; release proof)

### 50. Unknown active status: BATCH-14-canon-batch-11-path-systems-foundation

- Conflict ID: `AMB28-stale_or_unknown_active_status-62145118`
- Type: `stale_or_unknown_active_status`
- Severity: `yellow`
- Recommended action: `expedite`
- Rationale: Unknown active batch/prompt/train status should be clarified before it blocks or duplicates future work.
- Linear issue ready: `True`
- Auto-resolved: `False`
- Involved:
  - `BATCH-14-canon-batch-11-path-systems-foundation` — `docs/codex/batches/BATCH-14-canon-batch-11-path-systems-foundation.md` (unknown; release proof)

### 51. Unknown active status: BATCH-15-canon-batch-12-learning-and-anticipation-engine

- Conflict ID: `AMB28-stale_or_unknown_active_status-50849145`
- Type: `stale_or_unknown_active_status`
- Severity: `yellow`
- Recommended action: `expedite`
- Rationale: Unknown active batch/prompt/train status should be clarified before it blocks or duplicates future work.
- Linear issue ready: `True`
- Auto-resolved: `False`
- Involved:
  - `BATCH-15-canon-batch-12-learning-and-anticipation-engine` — `docs/codex/batches/BATCH-15-canon-batch-12-learning-and-anticipation-engine.md` (unknown; release proof)

### 52. Unknown active status: BATCH-16-canon-batch-13-shared-life-household-intelligence

- Conflict ID: `AMB28-stale_or_unknown_active_status-67798670`
- Type: `stale_or_unknown_active_status`
- Severity: `yellow`
- Recommended action: `expedite`
- Rationale: Unknown active batch/prompt/train status should be clarified before it blocks or duplicates future work.
- Linear issue ready: `True`
- Auto-resolved: `False`
- Involved:
  - `BATCH-16-canon-batch-13-shared-life-household-intelligence` — `docs/codex/batches/BATCH-16-canon-batch-13-shared-life-household-intelligence.md` (unknown; release proof)

### 53. Unknown active status: BATCH-17-canon-batch-14-runtime-separation

- Conflict ID: `AMB28-stale_or_unknown_active_status-55571121`
- Type: `stale_or_unknown_active_status`
- Severity: `yellow`
- Recommended action: `expedite`
- Rationale: Unknown active batch/prompt/train status should be clarified before it blocks or duplicates future work.
- Linear issue ready: `True`
- Auto-resolved: `False`
- Involved:
  - `BATCH-17-canon-batch-14-runtime-separation` — `docs/codex/batches/BATCH-17-canon-batch-14-runtime-separation.md` (unknown; release proof)

### 54. Unknown active status: BATCH-18-canon-batch-15-dedicated-device-prototype

- Conflict ID: `AMB28-stale_or_unknown_active_status-40408759`
- Type: `stale_or_unknown_active_status`
- Severity: `yellow`
- Recommended action: `expedite`
- Rationale: Unknown active batch/prompt/train status should be clarified before it blocks or duplicates future work.
- Linear issue ready: `True`
- Auto-resolved: `False`
- Involved:
  - `BATCH-18-canon-batch-15-dedicated-device-prototype` — `docs/codex/batches/BATCH-18-canon-batch-15-dedicated-device-prototype.md` (unknown; release proof)

### 55. Unknown active status: BATCH-19-ambitions-2.0-canon-reset

- Conflict ID: `AMB28-stale_or_unknown_active_status-26132174`
- Type: `stale_or_unknown_active_status`
- Severity: `yellow`
- Recommended action: `expedite`
- Rationale: Unknown active batch/prompt/train status should be clarified before it blocks or duplicates future work.
- Linear issue ready: `True`
- Auto-resolved: `False`
- Involved:
  - `BATCH-19-ambitions-2.0-canon-reset` — `docs/codex/batches/BATCH-19-ambitions-2.0-canon-reset.md` (unknown; release proof)

### 56. Unknown active status: BATCH-20-knowledge-provider-boundary

- Conflict ID: `AMB28-stale_or_unknown_active_status-12261737`
- Type: `stale_or_unknown_active_status`
- Severity: `yellow`
- Recommended action: `expedite`
- Rationale: Unknown active batch/prompt/train status should be clarified before it blocks or duplicates future work.
- Linear issue ready: `True`
- Auto-resolved: `False`
- Involved:
  - `BATCH-20-knowledge-provider-boundary` — `docs/codex/batches/BATCH-20-knowledge-provider-boundary.md` (unknown; release proof)

### 57. Unknown active status: BATCH-21-external-knowledge-ingestion-core

- Conflict ID: `AMB28-stale_or_unknown_active_status-35489656`
- Type: `stale_or_unknown_active_status`
- Severity: `yellow`
- Recommended action: `expedite`
- Rationale: Unknown active batch/prompt/train status should be clarified before it blocks or duplicates future work.
- Linear issue ready: `True`
- Auto-resolved: `False`
- Involved:
  - `BATCH-21-external-knowledge-ingestion-core` — `docs/codex/batches/BATCH-21-external-knowledge-ingestion-core.md` (unknown; release proof)

### 58. Unknown active status: BATCH-22-clarification-and-ambiguity-engine

- Conflict ID: `AMB28-stale_or_unknown_active_status-50477708`
- Type: `stale_or_unknown_active_status`
- Severity: `yellow`
- Recommended action: `expedite`
- Rationale: Unknown active batch/prompt/train status should be clarified before it blocks or duplicates future work.
- Linear issue ready: `True`
- Auto-resolved: `False`
- Involved:
  - `BATCH-22-clarification-and-ambiguity-engine` — `docs/codex/batches/BATCH-22-clarification-and-ambiguity-engine.md` (unknown; release proof)

### 59. Unknown active status: BATCH-23-generalized-goal-understanding-contracts

- Conflict ID: `AMB28-stale_or_unknown_active_status-82534873`
- Type: `stale_or_unknown_active_status`
- Severity: `yellow`
- Recommended action: `expedite`
- Rationale: Unknown active batch/prompt/train status should be clarified before it blocks or duplicates future work.
- Linear issue ready: `True`
- Auto-resolved: `False`
- Involved:
  - `BATCH-23-generalized-goal-understanding-contracts` — `docs/codex/batches/BATCH-23-generalized-goal-understanding-contracts.md` (unknown; release proof)

### 60. Unknown active status: BATCH-24-path-compiler-foundation

- Conflict ID: `AMB28-stale_or_unknown_active_status-54375992`
- Type: `stale_or_unknown_active_status`
- Severity: `yellow`
- Recommended action: `expedite`
- Rationale: Unknown active batch/prompt/train status should be clarified before it blocks or duplicates future work.
- Linear issue ready: `True`
- Auto-resolved: `False`
- Involved:
  - `BATCH-24-path-compiler-foundation` — `docs/codex/batches/BATCH-24-path-compiler-foundation.md` (unknown; release proof)

### 61. Unknown active status: BATCH-25-domain-pack-framework

- Conflict ID: `AMB28-stale_or_unknown_active_status-30324456`
- Type: `stale_or_unknown_active_status`
- Severity: `yellow`
- Recommended action: `expedite`
- Rationale: Unknown active batch/prompt/train status should be clarified before it blocks or duplicates future work.
- Linear issue ready: `True`
- Auto-resolved: `False`
- Involved:
  - `BATCH-25-domain-pack-framework` — `docs/codex/batches/BATCH-25-domain-pack-framework.md` (unknown; release proof)

### 62. Unknown active status: BATCH-26-resource-graph-and-source-ranking

- Conflict ID: `AMB28-stale_or_unknown_active_status-8253336`
- Type: `stale_or_unknown_active_status`
- Severity: `yellow`
- Recommended action: `expedite`
- Rationale: Unknown active batch/prompt/train status should be clarified before it blocks or duplicates future work.
- Linear issue ready: `True`
- Auto-resolved: `False`
- Involved:
  - `BATCH-26-resource-graph-and-source-ranking` — `docs/codex/batches/BATCH-26-resource-graph-and-source-ranking.md` (unknown; release proof)

### 63. Unknown active status: BATCH-27-update-and-freshness-engine

- Conflict ID: `AMB28-stale_or_unknown_active_status-67904375`
- Type: `stale_or_unknown_active_status`
- Severity: `yellow`
- Recommended action: `expedite`
- Rationale: Unknown active batch/prompt/train status should be clarified before it blocks or duplicates future work.
- Linear issue ready: `True`
- Auto-resolved: `False`
- Involved:
  - `BATCH-27-update-and-freshness-engine` — `docs/codex/batches/BATCH-27-update-and-freshness-engine.md` (unknown; release proof)

### 64. Unknown active status: BATCH-28-energy-model-foundation

- Conflict ID: `AMB28-stale_or_unknown_active_status-91976799`
- Type: `stale_or_unknown_active_status`
- Severity: `yellow`
- Recommended action: `expedite`
- Rationale: Unknown active batch/prompt/train status should be clarified before it blocks or duplicates future work.
- Linear issue ready: `True`
- Auto-resolved: `False`
- Involved:
  - `BATCH-28-energy-model-foundation` — `docs/codex/batches/BATCH-28-energy-model-foundation.md` (unknown; release proof)

### 65. Unknown active status: BATCH-29-energy-learning-and-ranking

- Conflict ID: `AMB28-stale_or_unknown_active_status-93824196`
- Type: `stale_or_unknown_active_status`
- Severity: `yellow`
- Recommended action: `expedite`
- Rationale: Unknown active batch/prompt/train status should be clarified before it blocks or duplicates future work.
- Linear issue ready: `True`
- Auto-resolved: `False`
- Involved:
  - `BATCH-29-energy-learning-and-ranking` — `docs/codex/batches/BATCH-29-energy-learning-and-ranking.md` (unknown; release proof)

### 66. Unknown active status: BATCH-30-contradiction-engine

- Conflict ID: `AMB28-stale_or_unknown_active_status-32509722`
- Type: `stale_or_unknown_active_status`
- Severity: `yellow`
- Recommended action: `expedite`
- Rationale: Unknown active batch/prompt/train status should be clarified before it blocks or duplicates future work.
- Linear issue ready: `True`
- Auto-resolved: `False`
- Involved:
  - `BATCH-30-contradiction-engine` — `docs/codex/batches/BATCH-30-contradiction-engine.md` (unknown; release proof)

### 67. Unknown active status: BATCH-31-correction-and-teaching-loop

- Conflict ID: `AMB28-stale_or_unknown_active_status-81781980`
- Type: `stale_or_unknown_active_status`
- Severity: `yellow`
- Recommended action: `expedite`
- Rationale: Unknown active batch/prompt/train status should be clarified before it blocks or duplicates future work.
- Linear issue ready: `True`
- Auto-resolved: `False`
- Involved:
  - `BATCH-31-correction-and-teaching-loop` — `docs/codex/batches/BATCH-31-correction-and-teaching-loop.md` (unknown; release proof)

### 68. Unknown active status: BATCH-32-explainability-and-source-audit-surfaces

- Conflict ID: `AMB28-stale_or_unknown_active_status-33592849`
- Type: `stale_or_unknown_active_status`
- Severity: `yellow`
- Recommended action: `expedite`
- Rationale: Unknown active batch/prompt/train status should be clarified before it blocks or duplicates future work.
- Linear issue ready: `True`
- Auto-resolved: `False`
- Involved:
  - `BATCH-32-explainability-and-source-audit-surfaces` — `docs/codex/batches/BATCH-32-explainability-and-source-audit-surfaces.md` (unknown; release proof)

### 69. Unknown active status: BATCH-35-post-2.0-hardening-shell-truth-navigation-and-plan-canon-recovery

- Conflict ID: `AMB28-stale_or_unknown_active_status-38140583`
- Type: `stale_or_unknown_active_status`
- Severity: `yellow`
- Recommended action: `expedite`
- Rationale: Unknown active batch/prompt/train status should be clarified before it blocks or duplicates future work.
- Linear issue ready: `True`
- Auto-resolved: `False`
- Involved:
  - `BATCH-35-post-2.0-hardening-shell-truth-navigation-and-plan-canon-recovery` — `docs/codex/batches/BATCH-35-post-2.0-hardening-shell-truth-navigation-and-plan-canon-recovery.md` (unknown; release proof)

### 70. Unknown active status: BATCH-36-post-2.0-hardening-trust-extensions-and-external-surface-validation

- Conflict ID: `AMB28-stale_or_unknown_active_status-47370957`
- Type: `stale_or_unknown_active_status`
- Severity: `yellow`
- Recommended action: `expedite`
- Rationale: Unknown active batch/prompt/train status should be clarified before it blocks or duplicates future work.
- Linear issue ready: `True`
- Auto-resolved: `False`
- Involved:
  - `BATCH-36-post-2.0-hardening-trust-extensions-and-external-surface-validation` — `docs/codex/batches/BATCH-36-post-2.0-hardening-trust-extensions-and-external-surface-validation.md` (unknown; release proof)

### 71. Unknown active status: BATCH-38-post-2.0-hardening-repo-truth-regression-performance-and-release-readiness

- Conflict ID: `AMB28-stale_or_unknown_active_status-33242065`
- Type: `stale_or_unknown_active_status`
- Severity: `yellow`
- Recommended action: `expedite`
- Rationale: Unknown active batch/prompt/train status should be clarified before it blocks or duplicates future work.
- Linear issue ready: `True`
- Auto-resolved: `False`
- Involved:
  - `BATCH-38-post-2.0-hardening-repo-truth-regression-performance-and-release-readiness` — `docs/codex/batches/BATCH-38-post-2.0-hardening-repo-truth-regression-performance-and-release-readiness.md` (unknown; release proof)

### 72. Unknown active status: BATCH_REPORT_LAYER

- Conflict ID: `AMB28-stale_or_unknown_active_status-89109986`
- Type: `stale_or_unknown_active_status`
- Severity: `yellow`
- Recommended action: `expedite`
- Rationale: Unknown active batch/prompt/train status should be clarified before it blocks or duplicates future work.
- Linear issue ready: `True`
- Auto-resolved: `False`
- Involved:
  - `BATCH_REPORT_LAYER` — `docs/codex/BATCH_REPORT_LAYER.md` (unknown; release proof)

### 73. Unknown active status: BATCH_THROUGHPUT_OPERATING_MODEL

- Conflict ID: `AMB28-stale_or_unknown_active_status-35218620`
- Type: `stale_or_unknown_active_status`
- Severity: `yellow`
- Recommended action: `expedite`
- Rationale: Unknown active batch/prompt/train status should be clarified before it blocks or duplicates future work.
- Linear issue ready: `True`
- Auto-resolved: `False`
- Involved:
  - `BATCH_THROUGHPUT_OPERATING_MODEL` — `docs/codex/BATCH_THROUGHPUT_OPERATING_MODEL.md` (unknown; release proof)

### 74. Unknown active status: BATCH_TRAIN_AOS01_AOS30_AMBITIONSOS_PROMPT

- Conflict ID: `AMB28-stale_or_unknown_active_status-1549858`
- Type: `stale_or_unknown_active_status`
- Severity: `yellow`
- Recommended action: `expedite`
- Rationale: Unknown active batch/prompt/train status should be clarified before it blocks or duplicates future work.
- Linear issue ready: `True`
- Auto-resolved: `False`
- Involved:
  - `BATCH_TRAIN_AOS01_AOS30_AMBITIONSOS_PROMPT` — `docs/codex/BATCH_TRAIN_AOS01_AOS30_AMBITIONSOS_PROMPT.md` (unknown; release proof)

### 75. Unknown active status: BATCH_TRAIN_CS01_CS10_COMPATIBILITY_SEAM_RETIREMENT_PROMPT

- Conflict ID: `AMB28-stale_or_unknown_active_status-14334550`
- Type: `stale_or_unknown_active_status`
- Severity: `yellow`
- Recommended action: `expedite`
- Rationale: Unknown active batch/prompt/train status should be clarified before it blocks or duplicates future work.
- Linear issue ready: `True`
- Auto-resolved: `False`
- Involved:
  - `BATCH_TRAIN_CS01_CS10_COMPATIBILITY_SEAM_RETIREMENT_PROMPT` — `docs/codex/BATCH_TRAIN_CS01_CS10_COMPATIBILITY_SEAM_RETIREMENT_PROMPT.md` (unknown; release proof)

### 76. Unknown active status: BATCH_TRAIN_ME01_ME12_MAINTAINABILITY_EXTRACTION_PROMPT

- Conflict ID: `AMB28-stale_or_unknown_active_status-80885294`
- Type: `stale_or_unknown_active_status`
- Severity: `yellow`
- Recommended action: `expedite`
- Rationale: Unknown active batch/prompt/train status should be clarified before it blocks or duplicates future work.
- Linear issue ready: `True`
- Auto-resolved: `False`
- Involved:
  - `BATCH_TRAIN_ME01_ME12_MAINTAINABILITY_EXTRACTION_PROMPT` — `docs/codex/BATCH_TRAIN_ME01_ME12_MAINTAINABILITY_EXTRACTION_PROMPT.md` (unknown; release proof)

### 77. Unknown active status: CODEX_ACCESSIBILITY_PROOF_PROTOCOL

- Conflict ID: `AMB28-stale_or_unknown_active_status-71437038`
- Type: `stale_or_unknown_active_status`
- Severity: `yellow`
- Recommended action: `expedite`
- Rationale: Unknown active batch/prompt/train status should be clarified before it blocks or duplicates future work.
- Linear issue ready: `True`
- Auto-resolved: `False`
- Involved:
  - `CODEX_ACCESSIBILITY_PROOF_PROTOCOL` — `docs/codex/CODEX_ACCESSIBILITY_PROOF_PROTOCOL.md` (unknown; release proof)

### 78. Unknown active status: CODEX_BUILD_SHERIFF_PROTOCOL

- Conflict ID: `AMB28-stale_or_unknown_active_status-55211394`
- Type: `stale_or_unknown_active_status`
- Severity: `yellow`
- Recommended action: `expedite`
- Rationale: Unknown active batch/prompt/train status should be clarified before it blocks or duplicates future work.
- Linear issue ready: `True`
- Auto-resolved: `False`
- Involved:
  - `CODEX_BUILD_SHERIFF_PROTOCOL` — `docs/codex/CODEX_BUILD_SHERIFF_PROTOCOL.md` (unknown; release proof)

### 79. Unknown active status: CODEX_MULTI_AGENT_BUILD_SYSTEM

- Conflict ID: `AMB28-stale_or_unknown_active_status-9552117`
- Type: `stale_or_unknown_active_status`
- Severity: `yellow`
- Recommended action: `expedite`
- Rationale: Unknown active batch/prompt/train status should be clarified before it blocks or duplicates future work.
- Linear issue ready: `True`
- Auto-resolved: `False`
- Involved:
  - `CODEX_MULTI_AGENT_BUILD_SYSTEM` — `docs/codex/CODEX_MULTI_AGENT_BUILD_SYSTEM.md` (unknown; release proof)

### 80. Unknown active status: CODEX_OS_INDEX

- Conflict ID: `AMB28-stale_or_unknown_active_status-85320384`
- Type: `stale_or_unknown_active_status`
- Severity: `yellow`
- Recommended action: `expedite`
- Rationale: Unknown active batch/prompt/train status should be clarified before it blocks or duplicates future work.
- Linear issue ready: `True`
- Auto-resolved: `False`
- Involved:
  - `CODEX_OS_INDEX` — `docs/codex/CODEX_OS_INDEX.md` (unknown; release proof)

### 81. Unknown active status: CODEX_OS_NO_DOUBLE_WORK_PROTOCOL

- Conflict ID: `AMB28-stale_or_unknown_active_status-120350`
- Type: `stale_or_unknown_active_status`
- Severity: `yellow`
- Recommended action: `expedite`
- Rationale: Unknown active batch/prompt/train status should be clarified before it blocks or duplicates future work.
- Linear issue ready: `True`
- Auto-resolved: `False`
- Involved:
  - `CODEX_OS_NO_DOUBLE_WORK_PROTOCOL` — `docs/codex/CODEX_OS_NO_DOUBLE_WORK_PROTOCOL.md` (unknown; release proof)

### 82. Unknown active status: CODEX_PROOF_CACHE_PROTOCOL

- Conflict ID: `AMB28-stale_or_unknown_active_status-66719567`
- Type: `stale_or_unknown_active_status`
- Severity: `yellow`
- Recommended action: `expedite`
- Rationale: Unknown active batch/prompt/train status should be clarified before it blocks or duplicates future work.
- Linear issue ready: `True`
- Auto-resolved: `False`
- Involved:
  - `CODEX_PROOF_CACHE_PROTOCOL` — `docs/codex/CODEX_PROOF_CACHE_PROTOCOL.md` (unknown; release proof)

### 83. Unknown active status: CODEX_QUALITY_SYSTEM_SCRIPT_MAP

- Conflict ID: `AMB28-stale_or_unknown_active_status-57247053`
- Type: `stale_or_unknown_active_status`
- Severity: `yellow`
- Recommended action: `expedite`
- Rationale: Unknown active batch/prompt/train status should be clarified before it blocks or duplicates future work.
- Linear issue ready: `True`
- Auto-resolved: `False`
- Involved:
  - `CODEX_QUALITY_SYSTEM_SCRIPT_MAP` — `docs/codex/CODEX_QUALITY_SYSTEM_SCRIPT_MAP.md` (unknown; release proof)

### 84. Unknown active status: CODEX_QUALITY_SYSTEM_SKILL_MAP

- Conflict ID: `AMB28-stale_or_unknown_active_status-67721141`
- Type: `stale_or_unknown_active_status`
- Severity: `yellow`
- Recommended action: `expedite`
- Rationale: Unknown active batch/prompt/train status should be clarified before it blocks or duplicates future work.
- Linear issue ready: `True`
- Auto-resolved: `False`
- Involved:
  - `CODEX_QUALITY_SYSTEM_SKILL_MAP` — `docs/codex/CODEX_QUALITY_SYSTEM_SKILL_MAP.md` (unknown; release proof)

### 85. Unknown active status: CODEX_ROUTE_CONTEXT_PROTOCOL

- Conflict ID: `AMB28-stale_or_unknown_active_status-7206341`
- Type: `stale_or_unknown_active_status`
- Severity: `yellow`
- Recommended action: `expedite`
- Rationale: Unknown active batch/prompt/train status should be clarified before it blocks or duplicates future work.
- Linear issue ready: `True`
- Auto-resolved: `False`
- Involved:
  - `CODEX_ROUTE_CONTEXT_PROTOCOL` — `docs/codex/CODEX_ROUTE_CONTEXT_PROTOCOL.md` (unknown; release proof)

### 86. Unknown active status: CODEX_SPEED_ENGINE

- Conflict ID: `AMB28-stale_or_unknown_active_status-95226087`
- Type: `stale_or_unknown_active_status`
- Severity: `yellow`
- Recommended action: `expedite`
- Rationale: Unknown active batch/prompt/train status should be clarified before it blocks or duplicates future work.
- Linear issue ready: `True`
- Auto-resolved: `False`
- Involved:
  - `CODEX_SPEED_ENGINE` — `docs/codex/CODEX_SPEED_ENGINE.md` (unknown; release proof)

### 87. Unknown active status: CODEX_VISUAL_QA_PROTOCOL

- Conflict ID: `AMB28-stale_or_unknown_active_status-96355953`
- Type: `stale_or_unknown_active_status`
- Severity: `yellow`
- Recommended action: `expedite`
- Rationale: Unknown active batch/prompt/train status should be clarified before it blocks or duplicates future work.
- Linear issue ready: `True`
- Auto-resolved: `False`
- Involved:
  - `CODEX_VISUAL_QA_PROTOCOL` — `docs/codex/CODEX_VISUAL_QA_PROTOCOL.md` (unknown; release proof)

### 88. Unknown active status: DAV_DYNAMIC_ADAPTIVE_VISUAL_DEPENDENCY_GRAPH

- Conflict ID: `AMB28-stale_or_unknown_active_status-43194311`
- Type: `stale_or_unknown_active_status`
- Severity: `yellow`
- Recommended action: `expedite`
- Rationale: Unknown active batch/prompt/train status should be clarified before it blocks or duplicates future work.
- Linear issue ready: `True`
- Auto-resolved: `False`
- Involved:
  - `DAV_DYNAMIC_ADAPTIVE_VISUAL_DEPENDENCY_GRAPH` — `docs/codex/DAV_DYNAMIC_ADAPTIVE_VISUAL_DEPENDENCY_GRAPH.md` (unknown; release proof)

### 89. Unknown active status: DAV_VISUAL_PRIMITIVE_DEPENDENCY_GRAPH

- Conflict ID: `AMB28-stale_or_unknown_active_status-36993669`
- Type: `stale_or_unknown_active_status`
- Severity: `yellow`
- Recommended action: `expedite`
- Rationale: Unknown active batch/prompt/train status should be clarified before it blocks or duplicates future work.
- Linear issue ready: `True`
- Auto-resolved: `False`
- Involved:
  - `DAV_VISUAL_PRIMITIVE_DEPENDENCY_GRAPH` — `docs/codex/DAV_VISUAL_PRIMITIVE_DEPENDENCY_GRAPH.md` (unknown; release proof)

### 90. Unknown active status: DERIVEDDATA_HYGIENE_PLAYBOOK

- Conflict ID: `AMB28-stale_or_unknown_active_status-41272394`
- Type: `stale_or_unknown_active_status`
- Severity: `yellow`
- Recommended action: `expedite`
- Rationale: Unknown active batch/prompt/train status should be clarified before it blocks or duplicates future work.
- Linear issue ready: `True`
- Auto-resolved: `False`
- Involved:
  - `DERIVEDDATA_HYGIENE_PLAYBOOK` — `docs/codex/playbooks/DERIVEDDATA_HYGIENE_PLAYBOOK.md` (unknown; release proof)

### 91. Unknown active status: F13_5_Goals_You_Trust_Architecture_Checkpoint_Prompt

- Conflict ID: `AMB28-stale_or_unknown_active_status-60720777`
- Type: `stale_or_unknown_active_status`
- Severity: `yellow`
- Recommended action: `expedite`
- Rationale: Unknown active batch/prompt/train status should be clarified before it blocks or duplicates future work.
- Linear issue ready: `True`
- Auto-resolved: `False`
- Involved:
  - `F13_5_Goals_You_Trust_Architecture_Checkpoint_Prompt` — `docs/codex/batches/F13_5_Goals_You_Trust_Architecture_Checkpoint_Prompt.md` (unknown; release proof)

### 92. Unknown active status: F16_5_SwiftUI_Architecture_State_Contract_Hardening_Prompt

- Conflict ID: `AMB28-stale_or_unknown_active_status-20960128`
- Type: `stale_or_unknown_active_status`
- Severity: `yellow`
- Recommended action: `expedite`
- Rationale: Unknown active batch/prompt/train status should be clarified before it blocks or duplicates future work.
- Linear issue ready: `True`
- Auto-resolved: `False`
- Involved:
  - `F16_5_SwiftUI_Architecture_State_Contract_Hardening_Prompt` — `docs/codex/batches/F16_5_SwiftUI_Architecture_State_Contract_Hardening_Prompt.md` (unknown; release proof)

### 93. Unknown active status: F18_5_Shell_Architecture_Hardening_Prompt

- Conflict ID: `AMB28-stale_or_unknown_active_status-70178578`
- Type: `stale_or_unknown_active_status`
- Severity: `yellow`
- Recommended action: `expedite`
- Rationale: Unknown active batch/prompt/train status should be clarified before it blocks or duplicates future work.
- Linear issue ready: `True`
- Auto-resolved: `False`
- Involved:
  - `F18_5_Shell_Architecture_Hardening_Prompt` — `docs/codex/batches/F18_5_Shell_Architecture_Hardening_Prompt.md` (unknown; release proof)

### 94. Unknown active status: F19_Shell_Route_Parity_Fallback_Safety_Prompt

- Conflict ID: `AMB28-stale_or_unknown_active_status-40890871`
- Type: `stale_or_unknown_active_status`
- Severity: `yellow`
- Recommended action: `expedite`
- Rationale: Unknown active batch/prompt/train status should be clarified before it blocks or duplicates future work.
- Linear issue ready: `True`
- Auto-resolved: `False`
- Involved:
  - `F19_Shell_Route_Parity_Fallback_Safety_Prompt` — `docs/codex/batches/F19_Shell_Route_Parity_Fallback_Safety_Prompt.md` (unknown; release proof)

### 95. Unknown active status: F20_External_Surface_Privacy_Projection_Prompt

- Conflict ID: `AMB28-stale_or_unknown_active_status-63636252`
- Type: `stale_or_unknown_active_status`
- Severity: `yellow`
- Recommended action: `expedite`
- Rationale: Unknown active batch/prompt/train status should be clarified before it blocks or duplicates future work.
- Linear issue ready: `True`
- Auto-resolved: `False`
- Involved:
  - `F20_External_Surface_Privacy_Projection_Prompt` — `docs/codex/batches/F20_External_Surface_Privacy_Projection_Prompt.md` (unknown; release proof)

### 96. Unknown active status: F21_5_UI_Flake_Reliability_Hardening_Prompt

- Conflict ID: `AMB28-stale_or_unknown_active_status-34803897`
- Type: `stale_or_unknown_active_status`
- Severity: `yellow`
- Recommended action: `expedite`
- Rationale: Unknown active batch/prompt/train status should be clarified before it blocks or duplicates future work.
- Linear issue ready: `True`
- Auto-resolved: `False`
- Involved:
  - `F21_5_UI_Flake_Reliability_Hardening_Prompt` — `docs/codex/batches/F21_5_UI_Flake_Reliability_Hardening_Prompt.md` (unknown; release proof)

### 97. Unknown active status: F23_Accessibility_ADHD_Dynamic_Type_VoiceOver_QA_Prompt

- Conflict ID: `AMB28-stale_or_unknown_active_status-93898913`
- Type: `stale_or_unknown_active_status`
- Severity: `yellow`
- Recommended action: `expedite`
- Rationale: Unknown active batch/prompt/train status should be clarified before it blocks or duplicates future work.
- Linear issue ready: `True`
- Auto-resolved: `False`
- Involved:
  - `F23_Accessibility_ADHD_Dynamic_Type_VoiceOver_QA_Prompt` — `docs/codex/batches/F23_Accessibility_ADHD_Dynamic_Type_VoiceOver_QA_Prompt.md` (unknown; release proof)

### 98. Unknown active status: F24_5_Privacy_Threat_Model_Closure_Prompt

- Conflict ID: `AMB28-stale_or_unknown_active_status-14356301`
- Type: `stale_or_unknown_active_status`
- Severity: `yellow`
- Recommended action: `expedite`
- Rationale: Unknown active batch/prompt/train status should be clarified before it blocks or duplicates future work.
- Linear issue ready: `True`
- Auto-resolved: `False`
- Involved:
  - `F24_5_Privacy_Threat_Model_Closure_Prompt` — `docs/codex/batches/F24_5_Privacy_Threat_Model_Closure_Prompt.md` (unknown; release proof)

### 99. Unknown active status: F24_Privacy_Trust_Local_Data_Redaction_QA_Prompt

- Conflict ID: `AMB28-stale_or_unknown_active_status-27831626`
- Type: `stale_or_unknown_active_status`
- Severity: `yellow`
- Recommended action: `expedite`
- Rationale: Unknown active batch/prompt/train status should be clarified before it blocks or duplicates future work.
- Linear issue ready: `True`
- Auto-resolved: `False`
- Involved:
  - `F24_Privacy_Trust_Local_Data_Redaction_QA_Prompt` — `docs/codex/batches/F24_Privacy_Trust_Local_Data_Redaction_QA_Prompt.md` (unknown; release proof)

### 100. Unknown active status: F25_Device_Performance_State_Restoration_Edge_Case_QA_Prompt

- Conflict ID: `AMB28-stale_or_unknown_active_status-2609675`
- Type: `stale_or_unknown_active_status`
- Severity: `yellow`
- Recommended action: `expedite`
- Rationale: Unknown active batch/prompt/train status should be clarified before it blocks or duplicates future work.
- Linear issue ready: `True`
- Auto-resolved: `False`
- Involved:
  - `F25_Device_Performance_State_Restoration_Edge_Case_QA_Prompt` — `docs/codex/batches/F25_Device_Performance_State_Restoration_Edge_Case_QA_Prompt.md` (unknown; release proof)

### 101. Unknown active status: F29_Final_Handoff_Package_And_Engineer_Onboarding_Prompt

- Conflict ID: `AMB28-stale_or_unknown_active_status-39471881`
- Type: `stale_or_unknown_active_status`
- Severity: `yellow`
- Recommended action: `expedite`
- Rationale: Unknown active batch/prompt/train status should be clarified before it blocks or duplicates future work.
- Linear issue ready: `True`
- Auto-resolved: `False`
- Involved:
  - `F29_Final_Handoff_Package_And_Engineer_Onboarding_Prompt` — `docs/codex/batches/F29_Final_Handoff_Package_And_Engineer_Onboarding_Prompt.md` (unknown; release proof)

### 102. Unknown active status: F30_Beyond_3_0_Continuation_Plan_Prompt

- Conflict ID: `AMB28-stale_or_unknown_active_status-60862733`
- Type: `stale_or_unknown_active_status`
- Severity: `yellow`
- Recommended action: `expedite`
- Rationale: Unknown active batch/prompt/train status should be clarified before it blocks or duplicates future work.
- Linear issue ready: `True`
- Auto-resolved: `False`
- Involved:
  - `F30_Beyond_3_0_Continuation_Plan_Prompt` — `docs/codex/batches/F30_Beyond_3_0_Continuation_Plan_Prompt.md` (unknown; release proof)

### 103. Unknown active status: FCP05_Start_Here_Surface_Prompt

- Conflict ID: `AMB28-stale_or_unknown_active_status-985987`
- Type: `stale_or_unknown_active_status`
- Severity: `yellow`
- Recommended action: `expedite`
- Rationale: Unknown active batch/prompt/train status should be clarified before it blocks or duplicates future work.
- Linear issue ready: `True`
- Auto-resolved: `False`
- Involved:
  - `FCP05_Start_Here_Surface_Prompt` — `docs/codex/batches/FCP05_Start_Here_Surface_Prompt.md` (unknown; release proof)

### 104. Unknown active status: FCP07_Reality_Rail_Continuity_Prompt

- Conflict ID: `AMB28-stale_or_unknown_active_status-36632560`
- Type: `stale_or_unknown_active_status`
- Severity: `yellow`
- Recommended action: `expedite`
- Rationale: Unknown active batch/prompt/train status should be clarified before it blocks or duplicates future work.
- Linear issue ready: `True`
- Auto-resolved: `False`
- Involved:
  - `FCP07_Reality_Rail_Continuity_Prompt` — `docs/codex/batches/FCP07_Reality_Rail_Continuity_Prompt.md` (unknown; release proof)

### 105. Unknown active status: FCP08_Ambition_Meridian_Shell_Prompt

- Conflict ID: `AMB28-stale_or_unknown_active_status-66425070`
- Type: `stale_or_unknown_active_status`
- Severity: `yellow`
- Recommended action: `expedite`
- Rationale: Unknown active batch/prompt/train status should be clarified before it blocks or duplicates future work.
- Linear issue ready: `True`
- Auto-resolved: `False`
- Involved:
  - `FCP08_Ambition_Meridian_Shell_Prompt` — `docs/codex/batches/FCP08_Ambition_Meridian_Shell_Prompt.md` (unknown; release proof)

### 106. Unknown active status: FCP09_Motion_Haptics_Reduced_Motion_Proof_Prompt

- Conflict ID: `AMB28-stale_or_unknown_active_status-72879121`
- Type: `stale_or_unknown_active_status`
- Severity: `yellow`
- Recommended action: `expedite`
- Rationale: Unknown active batch/prompt/train status should be clarified before it blocks or duplicates future work.
- Linear issue ready: `True`
- Auto-resolved: `False`
- Involved:
  - `FCP09_Motion_Haptics_Reduced_Motion_Proof_Prompt` — `docs/codex/batches/FCP09_Motion_Haptics_Reduced_Motion_Proof_Prompt.md` (unknown; release proof)

### 107. Unknown active status: FCP13A_Action_Closure_Diamond_Prompt

- Conflict ID: `AMB28-stale_or_unknown_active_status-612355`
- Type: `stale_or_unknown_active_status`
- Severity: `yellow`
- Recommended action: `expedite`
- Rationale: Unknown active batch/prompt/train status should be clarified before it blocks or duplicates future work.
- Linear issue ready: `True`
- Auto-resolved: `False`
- Involved:
  - `FCP13A_Action_Closure_Diamond_Prompt` — `docs/codex/batches/FCP13A_Action_Closure_Diamond_Prompt.md` (unknown; release proof)

### 108. Unknown active status: FCP17_Schedule_Availability_Defaults_Center_Prompt

- Conflict ID: `AMB28-stale_or_unknown_active_status-62452480`
- Type: `stale_or_unknown_active_status`
- Severity: `yellow`
- Recommended action: `expedite`
- Rationale: Unknown active batch/prompt/train status should be clarified before it blocks or duplicates future work.
- Linear issue ready: `True`
- Auto-resolved: `False`
- Involved:
  - `FCP17_Schedule_Availability_Defaults_Center_Prompt` — `docs/codex/batches/FCP17_Schedule_Availability_Defaults_Center_Prompt.md` (unknown; release proof)

### 109. Unknown active status: FL02_Life_Inventory_Object_Model_Prompt

- Conflict ID: `AMB28-stale_or_unknown_active_status-92271023`
- Type: `stale_or_unknown_active_status`
- Severity: `yellow`
- Recommended action: `expedite`
- Rationale: Unknown active batch/prompt/train status should be clarified before it blocks or duplicates future work.
- Linear issue ready: `True`
- Auto-resolved: `False`
- Involved:
  - `FL02_Life_Inventory_Object_Model_Prompt` — `docs/codex/batches/FL02_Life_Inventory_Object_Model_Prompt.md` (unknown; release proof)

### 110. Unknown active status: FL03_Commitment_Memory_Open_Loop_Registry_Prompt

- Conflict ID: `AMB28-stale_or_unknown_active_status-1569488`
- Type: `stale_or_unknown_active_status`
- Severity: `yellow`
- Recommended action: `expedite`
- Rationale: Unknown active batch/prompt/train status should be clarified before it blocks or duplicates future work.
- Linear issue ready: `True`
- Auto-resolved: `False`
- Involved:
  - `FL03_Commitment_Memory_Open_Loop_Registry_Prompt` — `docs/codex/batches/FL03_Commitment_Memory_Open_Loop_Registry_Prompt.md` (unknown; release proof)

### 111. Unknown active status: FL05_Option_Value_Pivot_Preservation_Model_Prompt

- Conflict ID: `AMB28-stale_or_unknown_active_status-32376459`
- Type: `stale_or_unknown_active_status`
- Severity: `yellow`
- Recommended action: `expedite`
- Rationale: Unknown active batch/prompt/train status should be clarified before it blocks or duplicates future work.
- Linear issue ready: `True`
- Auto-resolved: `False`
- Involved:
  - `FL05_Option_Value_Pivot_Preservation_Model_Prompt` — `docs/codex/batches/FL05_Option_Value_Pivot_Preservation_Model_Prompt.md` (unknown; release proof)

### 112. Unknown active status: FRONTEND_ACCESSIBILITY_DYNAMIC_TYPE_REDUCE_MOTION_GATE

- Conflict ID: `AMB28-stale_or_unknown_active_status-31490490`
- Type: `stale_or_unknown_active_status`
- Severity: `yellow`
- Recommended action: `expedite`
- Rationale: Unknown active batch/prompt/train status should be clarified before it blocks or duplicates future work.
- Linear issue ready: `True`
- Auto-resolved: `False`
- Involved:
  - `FRONTEND_ACCESSIBILITY_DYNAMIC_TYPE_REDUCE_MOTION_GATE` — `docs/codex/FRONTEND_ACCESSIBILITY_DYNAMIC_TYPE_REDUCE_MOTION_GATE.md` (unknown; release proof)

### 113. Unknown active status: FRONTEND_AUTHORITY_GLOBAL_TRAIN_HOOK

- Conflict ID: `AMB28-stale_or_unknown_active_status-61926913`
- Type: `stale_or_unknown_active_status`
- Severity: `yellow`
- Recommended action: `expedite`
- Rationale: Unknown active batch/prompt/train status should be clarified before it blocks or duplicates future work.
- Linear issue ready: `True`
- Auto-resolved: `False`
- Involved:
  - `FRONTEND_AUTHORITY_GLOBAL_TRAIN_HOOK` — `docs/codex/FRONTEND_AUTHORITY_GLOBAL_TRAIN_HOOK.md` (unknown; release proof)

### 114. Unknown active status: FRONTEND_COPY_COMPRESSION_PRODUCT_LANGUAGE_GATE

- Conflict ID: `AMB28-stale_or_unknown_active_status-78579582`
- Type: `stale_or_unknown_active_status`
- Severity: `yellow`
- Recommended action: `expedite`
- Rationale: Unknown active batch/prompt/train status should be clarified before it blocks or duplicates future work.
- Linear issue ready: `True`
- Auto-resolved: `False`
- Involved:
  - `FRONTEND_COPY_COMPRESSION_PRODUCT_LANGUAGE_GATE` — `docs/codex/FRONTEND_COPY_COMPRESSION_PRODUCT_LANGUAGE_GATE.md` (unknown; release proof)

### 115. Unknown active status: FRONTEND_MOTION_HAPTICS_INTERACTION_BELIEVABILITY_GATE

- Conflict ID: `AMB28-stale_or_unknown_active_status-94034882`
- Type: `stale_or_unknown_active_status`
- Severity: `yellow`
- Recommended action: `expedite`
- Rationale: Unknown active batch/prompt/train status should be clarified before it blocks or duplicates future work.
- Linear issue ready: `True`
- Auto-resolved: `False`
- Involved:
  - `FRONTEND_MOTION_HAPTICS_INTERACTION_BELIEVABILITY_GATE` — `docs/codex/FRONTEND_MOTION_HAPTICS_INTERACTION_BELIEVABILITY_GATE.md` (unknown; release proof)

### 116. Unknown active status: FRONTEND_PRIMITIVE_MISUSE_AND_DENSITY_GATE

- Conflict ID: `AMB28-stale_or_unknown_active_status-86174671`
- Type: `stale_or_unknown_active_status`
- Severity: `yellow`
- Recommended action: `expedite`
- Rationale: Unknown active batch/prompt/train status should be clarified before it blocks or duplicates future work.
- Linear issue ready: `True`
- Auto-resolved: `False`
- Involved:
  - `FRONTEND_PRIMITIVE_MISUSE_AND_DENSITY_GATE` — `docs/codex/FRONTEND_PRIMITIVE_MISUSE_AND_DENSITY_GATE.md` (unknown; release proof)

### 117. Unknown active status: FRONTEND_SCREENSHOT_EVIDENCE_STANDARD

- Conflict ID: `AMB28-stale_or_unknown_active_status-22713673`
- Type: `stale_or_unknown_active_status`
- Severity: `yellow`
- Recommended action: `expedite`
- Rationale: Unknown active batch/prompt/train status should be clarified before it blocks or duplicates future work.
- Linear issue ready: `True`
- Auto-resolved: `False`
- Involved:
  - `FRONTEND_SCREENSHOT_EVIDENCE_STANDARD` — `docs/codex/FRONTEND_SCREENSHOT_EVIDENCE_STANDARD.md` (unknown; release proof)

### 118. Unknown active status: FRONTEND_SHELL_BOTTOM_CHROME_OWNERSHIP_GATE

- Conflict ID: `AMB28-stale_or_unknown_active_status-62958972`
- Type: `stale_or_unknown_active_status`
- Severity: `yellow`
- Recommended action: `expedite`
- Rationale: Unknown active batch/prompt/train status should be clarified before it blocks or duplicates future work.
- Linear issue ready: `True`
- Auto-resolved: `False`
- Involved:
  - `FRONTEND_SHELL_BOTTOM_CHROME_OWNERSHIP_GATE` — `docs/codex/FRONTEND_SHELL_BOTTOM_CHROME_OWNERSHIP_GATE.md` (unknown; release proof)

### 119. Unknown active status: FRONTEND_TOP_LEVEL_SURFACE_COMPOSITION_GATE

- Conflict ID: `AMB28-stale_or_unknown_active_status-10851670`
- Type: `stale_or_unknown_active_status`
- Severity: `yellow`
- Recommended action: `expedite`
- Rationale: Unknown active batch/prompt/train status should be clarified before it blocks or duplicates future work.
- Linear issue ready: `True`
- Auto-resolved: `False`
- Involved:
  - `FRONTEND_TOP_LEVEL_SURFACE_COMPOSITION_GATE` — `docs/codex/FRONTEND_TOP_LEVEL_SURFACE_COMPOSITION_GATE.md` (unknown; release proof)

### 120. Unknown active status: FVQ02_TOP_LEVEL_SURFACE_VISUAL_SWEEP

- Conflict ID: `AMB28-stale_or_unknown_active_status-49156184`
- Type: `stale_or_unknown_active_status`
- Severity: `yellow`
- Recommended action: `expedite`
- Rationale: Unknown active batch/prompt/train status should be clarified before it blocks or duplicates future work.
- Linear issue ready: `True`
- Auto-resolved: `False`
- Involved:
  - `FVQ02_TOP_LEVEL_SURFACE_VISUAL_SWEEP` — `docs/codex/visual-quality/FVQ02_TOP_LEVEL_SURFACE_VISUAL_SWEEP.md` (unknown; release proof)

### 121. Unknown active status: GH01_GitHub_Native_Tooling_Policy_Prompt

- Conflict ID: `AMB28-stale_or_unknown_active_status-45481311`
- Type: `stale_or_unknown_active_status`
- Severity: `yellow`
- Recommended action: `expedite`
- Rationale: Unknown active batch/prompt/train status should be clarified before it blocks or duplicates future work.
- Linear issue ready: `True`
- Auto-resolved: `False`
- Involved:
  - `GH01_GitHub_Native_Tooling_Policy_Prompt` — `docs/codex/batches/GH01_GitHub_Native_Tooling_Policy_Prompt.md` (unknown; release proof)

### 122. Unknown active status: GITHUB_NATIVE_TOOLING_POLICY

- Conflict ID: `AMB28-stale_or_unknown_active_status-71473900`
- Type: `stale_or_unknown_active_status`
- Severity: `yellow`
- Recommended action: `expedite`
- Rationale: Unknown active batch/prompt/train status should be clarified before it blocks or duplicates future work.
- Linear issue ready: `True`
- Auto-resolved: `False`
- Involved:
  - `GITHUB_NATIVE_TOOLING_POLICY` — `docs/codex/GITHUB_NATIVE_TOOLING_POLICY.md` (unknown; release proof)

### 123. Unknown active status: GLOBAL_FULL_STACK_COMPLETION_ORDER_VISUAL_CANON_MOAT_OVERLAY

- Conflict ID: `AMB28-stale_or_unknown_active_status-13395403`
- Type: `stale_or_unknown_active_status`
- Severity: `yellow`
- Recommended action: `expedite`
- Rationale: Unknown active batch/prompt/train status should be clarified before it blocks or duplicates future work.
- Linear issue ready: `True`
- Auto-resolved: `False`
- Involved:
  - `GLOBAL_FULL_STACK_COMPLETION_ORDER_VISUAL_CANON_MOAT_OVERLAY` — `docs/codex/GLOBAL_FULL_STACK_COMPLETION_ORDER_VISUAL_CANON_MOAT_OVERLAY.md` (unknown; release proof)

### 124. Unknown active status: HBI00_RRE01_HISTORICAL_BASELINE_TRAIN

- Conflict ID: `AMB28-stale_or_unknown_active_status-39855467`
- Type: `stale_or_unknown_active_status`
- Severity: `yellow`
- Recommended action: `expedite`
- Rationale: Unknown active batch/prompt/train status should be clarified before it blocks or duplicates future work.
- Linear issue ready: `True`
- Auto-resolved: `False`
- Involved:
  - `HBI00_RRE01_HISTORICAL_BASELINE_TRAIN` — `docs/codex/batch-trains/HBI00_RRE01_HISTORICAL_BASELINE_TRAIN.md` (unknown; release proof)

### 125. Unknown active status: HBI_HISTORICAL_BASELINE_GLOBAL_TRAIN_INSERT

- Conflict ID: `AMB28-stale_or_unknown_active_status-60586850`
- Type: `stale_or_unknown_active_status`
- Severity: `yellow`
- Recommended action: `expedite`
- Rationale: Unknown active batch/prompt/train status should be clarified before it blocks or duplicates future work.
- Linear issue ready: `True`
- Auto-resolved: `False`
- Involved:
  - `HBI_HISTORICAL_BASELINE_GLOBAL_TRAIN_INSERT` — `docs/codex/HBI_HISTORICAL_BASELINE_GLOBAL_TRAIN_INSERT.md` (unknown; release proof)

### 126. Unknown active status: HISTORICAL_BASELINE_GLOBAL_TRAIN_MANIFEST

- Conflict ID: `AMB28-stale_or_unknown_active_status-37857654`
- Type: `stale_or_unknown_active_status`
- Severity: `yellow`
- Recommended action: `expedite`
- Rationale: Unknown active batch/prompt/train status should be clarified before it blocks or duplicates future work.
- Linear issue ready: `True`
- Auto-resolved: `False`
- Involved:
  - `HISTORICAL_BASELINE_GLOBAL_TRAIN_MANIFEST` — `docs/codex/HISTORICAL_BASELINE_GLOBAL_TRAIN_MANIFEST.json` (unknown; release proof)

### 127. Unknown active status: HISTORICAL_BASELINE_GLOBAL_TRAIN_OVERLAY

- Conflict ID: `AMB28-stale_or_unknown_active_status-1130835`
- Type: `stale_or_unknown_active_status`
- Severity: `yellow`
- Recommended action: `expedite`
- Rationale: Unknown active batch/prompt/train status should be clarified before it blocks or duplicates future work.
- Linear issue ready: `True`
- Auto-resolved: `False`
- Involved:
  - `HISTORICAL_BASELINE_GLOBAL_TRAIN_OVERLAY` — `docs/codex/HISTORICAL_BASELINE_GLOBAL_TRAIN_OVERLAY.md` (unknown; release proof)

### 128. Unknown active status: HPS_MOAT_AND_ACQUISITION_READINESS_MAP

- Conflict ID: `AMB28-stale_or_unknown_active_status-84798761`
- Type: `stale_or_unknown_active_status`
- Severity: `yellow`
- Recommended action: `expedite`
- Rationale: Unknown active batch/prompt/train status should be clarified before it blocks or duplicates future work.
- Linear issue ready: `True`
- Auto-resolved: `False`
- Involved:
  - `HPS_MOAT_AND_ACQUISITION_READINESS_MAP` — `docs/codex/HPS_MOAT_AND_ACQUISITION_READINESS_MAP.md` (unknown; release proof)

### 129. Unknown active status: IOS26_CORE_LIFE_OPERATIONS_ARCHITECTURE

- Conflict ID: `AMB28-stale_or_unknown_active_status-39306879`
- Type: `stale_or_unknown_active_status`
- Severity: `yellow`
- Recommended action: `expedite`
- Rationale: Unknown active batch/prompt/train status should be clarified before it blocks or duplicates future work.
- Linear issue ready: `True`
- Auto-resolved: `False`
- Involved:
  - `IOS26_CORE_LIFE_OPERATIONS_ARCHITECTURE` — `docs/codex/IOS26_CORE_LIFE_OPERATIONS_ARCHITECTURE.md` (unknown; release proof)

### 130. Unknown active status: IOS26_CORE_REPLACEMENT_JOURNEY_SPEC

- Conflict ID: `AMB28-stale_or_unknown_active_status-39194473`
- Type: `stale_or_unknown_active_status`
- Severity: `yellow`
- Recommended action: `expedite`
- Rationale: Unknown active batch/prompt/train status should be clarified before it blocks or duplicates future work.
- Linear issue ready: `True`
- Auto-resolved: `False`
- Involved:
  - `IOS26_CORE_REPLACEMENT_JOURNEY_SPEC` — `docs/codex/IOS26_CORE_REPLACEMENT_JOURNEY_SPEC.md` (unknown; release proof)

### 131. Unknown active status: IOS26_EXISTING_BATCH_EXPANSION_DIRECTIVES

- Conflict ID: `AMB28-stale_or_unknown_active_status-75169321`
- Type: `stale_or_unknown_active_status`
- Severity: `yellow`
- Recommended action: `expedite`
- Rationale: Unknown active batch/prompt/train status should be clarified before it blocks or duplicates future work.
- Linear issue ready: `True`
- Auto-resolved: `False`
- Involved:
  - `IOS26_EXISTING_BATCH_EXPANSION_DIRECTIVES` — `docs/codex/frontend/IOS26_EXISTING_BATCH_EXPANSION_DIRECTIVES.md` (unknown; release proof)

### 132. Unknown active status: IOS26_MOMENTUM_REFLOW_CONTRACT_FIXTURES

- Conflict ID: `AMB28-stale_or_unknown_active_status-59463862`
- Type: `stale_or_unknown_active_status`
- Severity: `yellow`
- Recommended action: `expedite`
- Rationale: Unknown active batch/prompt/train status should be clarified before it blocks or duplicates future work.
- Linear issue ready: `True`
- Auto-resolved: `False`
- Involved:
  - `IOS26_MOMENTUM_REFLOW_CONTRACT_FIXTURES` — `docs/codex/IOS26_MOMENTUM_REFLOW_CONTRACT_FIXTURES.md` (unknown; release proof)

### 133. Unknown active status: IOS26_PLAN_FREEZE

- Conflict ID: `AMB28-stale_or_unknown_active_status-90059877`
- Type: `stale_or_unknown_active_status`
- Severity: `yellow`
- Recommended action: `expedite`
- Rationale: Unknown active batch/prompt/train status should be clarified before it blocks or duplicates future work.
- Linear issue ready: `True`
- Auto-resolved: `False`
- Involved:
  - `IOS26_PLAN_FREEZE` — `docs/codex/ios26/IOS26_PLAN_FREEZE.md` (unknown; release proof)

### 134. Unknown active status: LAUNCH_DOCUMENTATION_LAYER

- Conflict ID: `AMB28-stale_or_unknown_active_status-85270930`
- Type: `stale_or_unknown_active_status`
- Severity: `yellow`
- Recommended action: `expedite`
- Rationale: Unknown active batch/prompt/train status should be clarified before it blocks or duplicates future work.
- Linear issue ready: `True`
- Auto-resolved: `False`
- Involved:
  - `LAUNCH_DOCUMENTATION_LAYER` — `docs/codex/LAUNCH_DOCUMENTATION_LAYER.md` (unknown; release proof)

### 135. Unknown active status: LDI_INVARIANT_LEDGER

- Conflict ID: `AMB28-stale_or_unknown_active_status-87032878`
- Type: `stale_or_unknown_active_status`
- Severity: `yellow`
- Recommended action: `expedite`
- Rationale: Unknown active batch/prompt/train status should be clarified before it blocks or duplicates future work.
- Linear issue ready: `True`
- Auto-resolved: `False`
- Involved:
  - `LDI_INVARIANT_LEDGER` — `docs/codex/LDI_INVARIANT_LEDGER.md` (unknown; release proof)

### 136. Unknown active status: LDI_ROADMAP_TO_IMPLEMENTATION_REORDER_PROTOCOL

- Conflict ID: `AMB28-stale_or_unknown_active_status-55370991`
- Type: `stale_or_unknown_active_status`
- Severity: `yellow`
- Recommended action: `expedite`
- Rationale: Unknown active batch/prompt/train status should be clarified before it blocks or duplicates future work.
- Linear issue ready: `True`
- Auto-resolved: `False`
- Involved:
  - `LDI_ROADMAP_TO_IMPLEMENTATION_REORDER_PROTOCOL` — `docs/codex/LDI_ROADMAP_TO_IMPLEMENTATION_REORDER_PROTOCOL.md` (unknown; release proof)

### 137. Unknown active status: Launch_Operator_Runbook

- Conflict ID: `AMB28-stale_or_unknown_active_status-69523549`
- Type: `stale_or_unknown_active_status`
- Severity: `yellow`
- Recommended action: `expedite`
- Rationale: Unknown active batch/prompt/train status should be clarified before it blocks or duplicates future work.
- Linear issue ready: `True`
- Auto-resolved: `False`
- Involved:
  - `Launch_Operator_Runbook` — `docs/codex/Launch_Operator_Runbook.md` (unknown; release proof)

### 138. Unknown active status: MAC_SESSION_BOOT_PROMPT

- Conflict ID: `AMB28-stale_or_unknown_active_status-10307373`
- Type: `stale_or_unknown_active_status`
- Severity: `yellow`
- Recommended action: `expedite`
- Rationale: Unknown active batch/prompt/train status should be clarified before it blocks or duplicates future work.
- Linear issue ready: `True`
- Auto-resolved: `False`
- Involved:
  - `MAC_SESSION_BOOT_PROMPT` — `docs/codex/MAC_SESSION_BOOT_PROMPT.md` (unknown; release proof)

### 139. Unknown active status: MCP03_VISUAL_PROOF_MCP_PLAN

- Conflict ID: `AMB28-stale_or_unknown_active_status-560595`
- Type: `stale_or_unknown_active_status`
- Severity: `yellow`
- Recommended action: `expedite`
- Rationale: Unknown active batch/prompt/train status should be clarified before it blocks or duplicates future work.
- Linear issue ready: `True`
- Auto-resolved: `False`
- Involved:
  - `MCP03_VISUAL_PROOF_MCP_PLAN` — `docs/codex/MCP03_VISUAL_PROOF_MCP_PLAN.md` (unknown; release proof)

### 140. Unknown active status: MCP03_Visual_Proof_MCP_Prompt

- Conflict ID: `AMB28-stale_or_unknown_active_status-56719757`
- Type: `stale_or_unknown_active_status`
- Severity: `yellow`
- Recommended action: `expedite`
- Rationale: Unknown active batch/prompt/train status should be clarified before it blocks or duplicates future work.
- Linear issue ready: `True`
- Auto-resolved: `False`
- Involved:
  - `MCP03_Visual_Proof_MCP_Prompt` — `docs/codex/batches/MCP03_Visual_Proof_MCP_Prompt.md` (unknown; release proof)

### 141. Unknown active status: MCP04_ACCESSIBILITY_SHADOW_MCP_PLAN

- Conflict ID: `AMB28-stale_or_unknown_active_status-12105859`
- Type: `stale_or_unknown_active_status`
- Severity: `yellow`
- Recommended action: `expedite`
- Rationale: Unknown active batch/prompt/train status should be clarified before it blocks or duplicates future work.
- Linear issue ready: `True`
- Auto-resolved: `False`
- Involved:
  - `MCP04_ACCESSIBILITY_SHADOW_MCP_PLAN` — `docs/codex/MCP04_ACCESSIBILITY_SHADOW_MCP_PLAN.md` (unknown; release proof)

### 142. Unknown active status: MCP04_Accessibility_Shadow_MCP_Prompt

- Conflict ID: `AMB28-stale_or_unknown_active_status-86629652`
- Type: `stale_or_unknown_active_status`
- Severity: `yellow`
- Recommended action: `expedite`
- Rationale: Unknown active batch/prompt/train status should be clarified before it blocks or duplicates future work.
- Linear issue ready: `True`
- Auto-resolved: `False`
- Involved:
  - `MCP04_Accessibility_Shadow_MCP_Prompt` — `docs/codex/batches/MCP04_Accessibility_Shadow_MCP_Prompt.md` (unknown; release proof)

### 143. Unknown active status: MCP05_Ambitions_Twin_Fixture_MCP_Prompt

- Conflict ID: `AMB28-stale_or_unknown_active_status-43913329`
- Type: `stale_or_unknown_active_status`
- Severity: `yellow`
- Recommended action: `expedite`
- Rationale: Unknown active batch/prompt/train status should be clarified before it blocks or duplicates future work.
- Linear issue ready: `True`
- Auto-resolved: `False`
- Involved:
  - `MCP05_Ambitions_Twin_Fixture_MCP_Prompt` — `docs/codex/batches/MCP05_Ambitions_Twin_Fixture_MCP_Prompt.md` (unknown; release proof)

### 144. Unknown active status: MCP06_SOURCE_ATLAS_PACK_MCP_PLAN

- Conflict ID: `AMB28-stale_or_unknown_active_status-68267772`
- Type: `stale_or_unknown_active_status`
- Severity: `yellow`
- Recommended action: `expedite`
- Rationale: Unknown active batch/prompt/train status should be clarified before it blocks or duplicates future work.
- Linear issue ready: `True`
- Auto-resolved: `False`
- Involved:
  - `MCP06_SOURCE_ATLAS_PACK_MCP_PLAN` — `docs/codex/MCP06_SOURCE_ATLAS_PACK_MCP_PLAN.md` (unknown; release proof)

### 145. Unknown active status: MCP06_Source_Atlas_Pack_MCP_Prompt

- Conflict ID: `AMB28-stale_or_unknown_active_status-50723218`
- Type: `stale_or_unknown_active_status`
- Severity: `yellow`
- Recommended action: `expedite`
- Rationale: Unknown active batch/prompt/train status should be clarified before it blocks or duplicates future work.
- Linear issue ready: `True`
- Auto-resolved: `False`
- Involved:
  - `MCP06_Source_Atlas_Pack_MCP_Prompt` — `docs/codex/batches/MCP06_Source_Atlas_Pack_MCP_Prompt.md` (unknown; release proof)

### 146. Unknown active status: MCP07_RELEASE_TRUTH_MCP_PLAN

- Conflict ID: `AMB28-stale_or_unknown_active_status-19112259`
- Type: `stale_or_unknown_active_status`
- Severity: `yellow`
- Recommended action: `expedite`
- Rationale: Unknown active batch/prompt/train status should be clarified before it blocks or duplicates future work.
- Linear issue ready: `True`
- Auto-resolved: `False`
- Involved:
  - `MCP07_RELEASE_TRUTH_MCP_PLAN` — `docs/codex/MCP07_RELEASE_TRUTH_MCP_PLAN.md` (unknown; release proof)

### 147. Unknown active status: MCP07_Release_Truth_MCP_Prompt

- Conflict ID: `AMB28-stale_or_unknown_active_status-26420817`
- Type: `stale_or_unknown_active_status`
- Severity: `yellow`
- Recommended action: `expedite`
- Rationale: Unknown active batch/prompt/train status should be clarified before it blocks or duplicates future work.
- Linear issue ready: `True`
- Auto-resolved: `False`
- Involved:
  - `MCP07_Release_Truth_MCP_Prompt` — `docs/codex/batches/MCP07_Release_Truth_MCP_Prompt.md` (unknown; release proof)

### 148. Unknown active status: MOAT_RUNTIME_AUTONOMOUS_ROUTING_POLICY

- Conflict ID: `AMB28-stale_or_unknown_active_status-38730954`
- Type: `stale_or_unknown_active_status`
- Severity: `yellow`
- Recommended action: `expedite`
- Rationale: Unknown active batch/prompt/train status should be clarified before it blocks or duplicates future work.
- Linear issue ready: `True`
- Auto-resolved: `False`
- Involved:
  - `MOAT_RUNTIME_AUTONOMOUS_ROUTING_POLICY` — `docs/codex/MOAT_RUNTIME_AUTONOMOUS_ROUTING_POLICY.md` (unknown; release proof)

### 149. Unknown active status: MOAT_RUNTIME_GOLDEN_SCENARIOS

- Conflict ID: `AMB28-stale_or_unknown_active_status-4683724`
- Type: `stale_or_unknown_active_status`
- Severity: `yellow`
- Recommended action: `expedite`
- Rationale: Unknown active batch/prompt/train status should be clarified before it blocks or duplicates future work.
- Linear issue ready: `True`
- Auto-resolved: `False`
- Involved:
  - `MOAT_RUNTIME_GOLDEN_SCENARIOS` — `docs/codex/MOAT_RUNTIME_GOLDEN_SCENARIOS.md` (unknown; release proof)

### 150. Unknown active status: MOAT_RUNTIME_LOOP_MATRIX

- Conflict ID: `AMB28-stale_or_unknown_active_status-79120370`
- Type: `stale_or_unknown_active_status`
- Severity: `yellow`
- Recommended action: `expedite`
- Rationale: Unknown active batch/prompt/train status should be clarified before it blocks or duplicates future work.
- Linear issue ready: `True`
- Auto-resolved: `False`
- Involved:
  - `MOAT_RUNTIME_LOOP_MATRIX` — `docs/codex/MOAT_RUNTIME_LOOP_MATRIX.md` (unknown; release proof)

### 151. Unknown active status: OBJECT_OS_INDEX

- Conflict ID: `AMB28-stale_or_unknown_active_status-69540009`
- Type: `stale_or_unknown_active_status`
- Severity: `yellow`
- Recommended action: `expedite`
- Rationale: Unknown active batch/prompt/train status should be clarified before it blocks or duplicates future work.
- Linear issue ready: `True`
- Auto-resolved: `False`
- Involved:
  - `OBJECT_OS_INDEX` — `docs/codex/OBJECT_OS_INDEX.md` (unknown; release proof)

### 152. Unknown active status: OBJECT_OS_MOTION_GRAMMAR

- Conflict ID: `AMB28-stale_or_unknown_active_status-63928367`
- Type: `stale_or_unknown_active_status`
- Severity: `yellow`
- Recommended action: `expedite`
- Rationale: Unknown active batch/prompt/train status should be clarified before it blocks or duplicates future work.
- Linear issue ready: `True`
- Auto-resolved: `False`
- Involved:
  - `OBJECT_OS_MOTION_GRAMMAR` — `docs/codex/OBJECT_OS_MOTION_GRAMMAR.md` (unknown; release proof)

### 153. Unknown active status: OBJECT_OS_NATIVE_SURFACES

- Conflict ID: `AMB28-stale_or_unknown_active_status-94879291`
- Type: `stale_or_unknown_active_status`
- Severity: `yellow`
- Recommended action: `expedite`
- Rationale: Unknown active batch/prompt/train status should be clarified before it blocks or duplicates future work.
- Linear issue ready: `True`
- Auto-resolved: `False`
- Involved:
  - `OBJECT_OS_NATIVE_SURFACES` — `docs/codex/OBJECT_OS_NATIVE_SURFACES.md` (unknown; release proof)

### 154. Unknown active status: OBJECT_OS_SURFACE_MAP

- Conflict ID: `AMB28-stale_or_unknown_active_status-4088648`
- Type: `stale_or_unknown_active_status`
- Severity: `yellow`
- Recommended action: `expedite`
- Rationale: Unknown active batch/prompt/train status should be clarified before it blocks or duplicates future work.
- Linear issue ready: `True`
- Auto-resolved: `False`
- Involved:
  - `OBJECT_OS_SURFACE_MAP` — `docs/codex/OBJECT_OS_SURFACE_MAP.md` (unknown; release proof)

### 155. Unknown active status: OPENAI_BUILD_SUITE_ADOPTION_MATRIX

- Conflict ID: `AMB28-stale_or_unknown_active_status-45753994`
- Type: `stale_or_unknown_active_status`
- Severity: `yellow`
- Recommended action: `expedite`
- Rationale: Unknown active batch/prompt/train status should be clarified before it blocks or duplicates future work.
- Linear issue ready: `True`
- Auto-resolved: `False`
- Involved:
  - `OPENAI_BUILD_SUITE_ADOPTION_MATRIX` — `docs/codex/OPENAI_BUILD_SUITE_ADOPTION_MATRIX.md` (unknown; release proof)

### 156. Unknown active status: OPENAI_BUILD_SUITE_USAGE_POLICY

- Conflict ID: `AMB28-stale_or_unknown_active_status-21513953`
- Type: `stale_or_unknown_active_status`
- Severity: `yellow`
- Recommended action: `expedite`
- Rationale: Unknown active batch/prompt/train status should be clarified before it blocks or duplicates future work.
- Linear issue ready: `True`
- Auto-resolved: `False`
- Involved:
  - `OPENAI_BUILD_SUITE_USAGE_POLICY` — `docs/codex/OPENAI_BUILD_SUITE_USAGE_POLICY.md` (unknown; release proof)

### 157. Unknown active status: OPENAI_EVAL_QA_LAYER

- Conflict ID: `AMB28-stale_or_unknown_active_status-86391199`
- Type: `stale_or_unknown_active_status`
- Severity: `yellow`
- Recommended action: `expedite`
- Rationale: Unknown active batch/prompt/train status should be clarified before it blocks or duplicates future work.
- Linear issue ready: `True`
- Auto-resolved: `False`
- Involved:
  - `OPENAI_EVAL_QA_LAYER` — `docs/codex/OPENAI_EVAL_QA_LAYER.md` (unknown; release proof)

### 158. Unknown active status: PFC05A_Remove_Hosted_Workflows_Local_Validation_Gate_Prompt

- Conflict ID: `AMB28-stale_or_unknown_active_status-89066938`
- Type: `stale_or_unknown_active_status`
- Severity: `yellow`
- Recommended action: `expedite`
- Rationale: Unknown active batch/prompt/train status should be clarified before it blocks or duplicates future work.
- Linear issue ready: `True`
- Auto-resolved: `False`
- Involved:
  - `PFC05A_Remove_Hosted_Workflows_Local_Validation_Gate_Prompt` — `docs/codex/batches/PFC05A_Remove_Hosted_Workflows_Local_Validation_Gate_Prompt.md` (unknown; release proof)

### 159. Unknown active status: PFC08_Corruption_Recovery_Backup_Restore_Plan_Prompt

- Conflict ID: `AMB28-stale_or_unknown_active_status-59363950`
- Type: `stale_or_unknown_active_status`
- Severity: `yellow`
- Recommended action: `expedite`
- Rationale: Unknown active batch/prompt/train status should be clarified before it blocks or duplicates future work.
- Linear issue ready: `True`
- Auto-resolved: `False`
- Involved:
  - `PFC08_Corruption_Recovery_Backup_Restore_Plan_Prompt` — `docs/codex/batches/PFC08_Corruption_Recovery_Backup_Restore_Plan_Prompt.md` (unknown; release proof)

### 160. Unknown active status: PFC12_App_Groups_Shared_Storage_Boundary_Prompt

- Conflict ID: `AMB28-stale_or_unknown_active_status-65651334`
- Type: `stale_or_unknown_active_status`
- Severity: `yellow`
- Recommended action: `expedite`
- Rationale: Unknown active batch/prompt/train status should be clarified before it blocks or duplicates future work.
- Linear issue ready: `True`
- Auto-resolved: `False`
- Involved:
  - `PFC12_App_Groups_Shared_Storage_Boundary_Prompt` — `docs/codex/batches/PFC12_App_Groups_Shared_Storage_Boundary_Prompt.md` (unknown; release proof)

### 161. Unknown active status: PFC13_WidgetKit_Strategy_And_Object_Map_Prompt

- Conflict ID: `AMB28-stale_or_unknown_active_status-82064528`
- Type: `stale_or_unknown_active_status`
- Severity: `yellow`
- Recommended action: `expedite`
- Rationale: Unknown active batch/prompt/train status should be clarified before it blocks or duplicates future work.
- Linear issue ready: `True`
- Auto-resolved: `False`
- Involved:
  - `PFC13_WidgetKit_Strategy_And_Object_Map_Prompt` — `docs/codex/batches/PFC13_WidgetKit_Strategy_And_Object_Map_Prompt.md` (unknown; release proof)

### 162. Unknown active status: PFC23_Paywall_Upgrade_UX_Compliance_Review_Deferral_Prompt

- Conflict ID: `AMB28-stale_or_unknown_active_status-79657001`
- Type: `stale_or_unknown_active_status`
- Severity: `yellow`
- Recommended action: `expedite`
- Rationale: Unknown active batch/prompt/train status should be clarified before it blocks or duplicates future work.
- Linear issue ready: `True`
- Auto-resolved: `False`
- Involved:
  - `PFC23_Paywall_Upgrade_UX_Compliance_Review_Deferral_Prompt` — `docs/codex/batches/PFC23_Paywall_Upgrade_UX_Compliance_Review_Deferral_Prompt.md` (unknown; release proof)

### 163. Unknown active status: POST_PK_BATCH_BUNDLES

- Conflict ID: `AMB28-stale_or_unknown_active_status-83340150`
- Type: `stale_or_unknown_active_status`
- Severity: `yellow`
- Recommended action: `expedite`
- Rationale: Unknown active batch/prompt/train status should be clarified before it blocks or duplicates future work.
- Linear issue ready: `True`
- Auto-resolved: `False`
- Involved:
  - `POST_PK_BATCH_BUNDLES` — `docs/codex/POST_PK_BATCH_BUNDLES.md` (unknown; release proof)

### 164. Unknown active status: POST_PK_SPEED_TRAIN_OPERATING_MODEL

- Conflict ID: `AMB28-stale_or_unknown_active_status-24387072`
- Type: `stale_or_unknown_active_status`
- Severity: `yellow`
- Recommended action: `expedite`
- Rationale: Unknown active batch/prompt/train status should be clarified before it blocks or duplicates future work.
- Linear issue ready: `True`
- Auto-resolved: `False`
- Involved:
  - `POST_PK_SPEED_TRAIN_OPERATING_MODEL` — `docs/codex/POST_PK_SPEED_TRAIN_OPERATING_MODEL.md` (unknown; release proof)

### 165. Unknown active status: PRIVATE_LIFE_RUNTIME_WIRING_GATE

- Conflict ID: `AMB28-stale_or_unknown_active_status-4424479`
- Type: `stale_or_unknown_active_status`
- Severity: `yellow`
- Recommended action: `expedite`
- Rationale: Unknown active batch/prompt/train status should be clarified before it blocks or duplicates future work.
- Linear issue ready: `True`
- Auto-resolved: `False`
- Involved:
  - `PRIVATE_LIFE_RUNTIME_WIRING_GATE` — `docs/codex/PRIVATE_LIFE_RUNTIME_WIRING_GATE.md` (unknown; release proof)

### 166. Unknown active status: PROMPT_REPAIR_LAYER

- Conflict ID: `AMB28-stale_or_unknown_active_status-17577286`
- Type: `stale_or_unknown_active_status`
- Severity: `yellow`
- Recommended action: `expedite`
- Rationale: Unknown active batch/prompt/train status should be clarified before it blocks or duplicates future work.
- Linear issue ready: `True`
- Auto-resolved: `False`
- Involved:
  - `PROMPT_REPAIR_LAYER` — `docs/codex/PROMPT_REPAIR_LAYER.md` (unknown; release proof)

### 167. Unknown active status: PXEQ_MINIMALISM_WITH_UTILITY_RULES

- Conflict ID: `AMB28-stale_or_unknown_active_status-87297654`
- Type: `stale_or_unknown_active_status`
- Severity: `yellow`
- Recommended action: `expedite`
- Rationale: Unknown active batch/prompt/train status should be clarified before it blocks or duplicates future work.
- Linear issue ready: `True`
- Auto-resolved: `False`
- Involved:
  - `PXEQ_MINIMALISM_WITH_UTILITY_RULES` — `docs/codex/PXEQ_MINIMALISM_WITH_UTILITY_RULES.md` (unknown; release proof)

### 168. Unknown active status: PXEQ_MOTION_AND_STATE_CHANGE_RULES

- Conflict ID: `AMB28-stale_or_unknown_active_status-65347115`
- Type: `stale_or_unknown_active_status`
- Severity: `yellow`
- Recommended action: `expedite`
- Rationale: Unknown active batch/prompt/train status should be clarified before it blocks or duplicates future work.
- Linear issue ready: `True`
- Auto-resolved: `False`
- Involved:
  - `PXEQ_MOTION_AND_STATE_CHANGE_RULES` — `docs/codex/PXEQ_MOTION_AND_STATE_CHANGE_RULES.md` (unknown; release proof)

### 169. Unknown active status: PXEQ_SURFACE_BEHAVIOR_MATRIX

- Conflict ID: `AMB28-stale_or_unknown_active_status-14153647`
- Type: `stale_or_unknown_active_status`
- Severity: `yellow`
- Recommended action: `expedite`
- Rationale: Unknown active batch/prompt/train status should be clarified before it blocks or duplicates future work.
- Linear issue ready: `True`
- Auto-resolved: `False`
- Involved:
  - `PXEQ_SURFACE_BEHAVIOR_MATRIX` — `docs/codex/PXEQ_SURFACE_BEHAVIOR_MATRIX.md` (unknown; release proof)

### 170. Unknown active status: PXEQ_VISUAL_SYSTEM_CONSERVATIVE_FUTURISM_RULES

- Conflict ID: `AMB28-stale_or_unknown_active_status-4697141`
- Type: `stale_or_unknown_active_status`
- Severity: `yellow`
- Recommended action: `expedite`
- Rationale: Unknown active batch/prompt/train status should be clarified before it blocks or duplicates future work.
- Linear issue ready: `True`
- Auto-resolved: `False`
- Involved:
  - `PXEQ_VISUAL_SYSTEM_CONSERVATIVE_FUTURISM_RULES` — `docs/codex/PXEQ_VISUAL_SYSTEM_CONSERVATIVE_FUTURISM_RULES.md` (unknown; release proof)

### 171. Unknown active status: PXOS_CODEX_OS_UPGRADE_PROTOCOL

- Conflict ID: `AMB28-stale_or_unknown_active_status-29079027`
- Type: `stale_or_unknown_active_status`
- Severity: `yellow`
- Recommended action: `expedite`
- Rationale: Unknown active batch/prompt/train status should be clarified before it blocks or duplicates future work.
- Linear issue ready: `True`
- Auto-resolved: `False`
- Involved:
  - `PXOS_CODEX_OS_UPGRADE_PROTOCOL` — `docs/codex/PXOS_CODEX_OS_UPGRADE_PROTOCOL.md` (unknown; release proof)

### 172. Unknown active status: PXOS_DEPENDENCY_GRAPH

- Conflict ID: `AMB28-stale_or_unknown_active_status-88037592`
- Type: `stale_or_unknown_active_status`
- Severity: `yellow`
- Recommended action: `expedite`
- Rationale: Unknown active batch/prompt/train status should be clarified before it blocks or duplicates future work.
- Linear issue ready: `True`
- Auto-resolved: `False`
- Involved:
  - `PXOS_DEPENDENCY_GRAPH` — `docs/codex/PXOS_DEPENDENCY_GRAPH.md` (unknown; release proof)

### 173. Unknown active status: PXOS_DRIFT_DETECTION_PROTOCOL

- Conflict ID: `AMB28-stale_or_unknown_active_status-56364296`
- Type: `stale_or_unknown_active_status`
- Severity: `yellow`
- Recommended action: `expedite`
- Rationale: Unknown active batch/prompt/train status should be clarified before it blocks or duplicates future work.
- Linear issue ready: `True`
- Auto-resolved: `False`
- Involved:
  - `PXOS_DRIFT_DETECTION_PROTOCOL` — `docs/codex/PXOS_DRIFT_DETECTION_PROTOCOL.md` (unknown; release proof)

### 174. Unknown active status: PXOS_PRODUCT_DECISION_LEDGER

- Conflict ID: `AMB28-stale_or_unknown_active_status-27333441`
- Type: `stale_or_unknown_active_status`
- Severity: `yellow`
- Recommended action: `expedite`
- Rationale: Unknown active batch/prompt/train status should be clarified before it blocks or duplicates future work.
- Linear issue ready: `True`
- Auto-resolved: `False`
- Involved:
  - `PXOS_PRODUCT_DECISION_LEDGER` — `docs/codex/PXOS_PRODUCT_DECISION_LEDGER.md` (unknown; release proof)

### 175. Unknown active status: README

- Conflict ID: `AMB28-stale_or_unknown_active_status-51458599`
- Type: `stale_or_unknown_active_status`
- Severity: `yellow`
- Recommended action: `expedite`
- Rationale: Unknown active batch/prompt/train status should be clarified before it blocks or duplicates future work.
- Linear issue ready: `True`
- Auto-resolved: `False`
- Involved:
  - `README` — `docs/codex/batch-trains/README.md` (unknown; release proof)

### 176. Unknown active status: REPO_INTELLIGENCE_CONTROL_PLANE

- Conflict ID: `AMB28-stale_or_unknown_active_status-70208158`
- Type: `stale_or_unknown_active_status`
- Severity: `yellow`
- Recommended action: `expedite`
- Rationale: Unknown active batch/prompt/train status should be clarified before it blocks or duplicates future work.
- Linear issue ready: `True`
- Auto-resolved: `False`
- Involved:
  - `REPO_INTELLIGENCE_CONTROL_PLANE` — `docs/codex/REPO_INTELLIGENCE_CONTROL_PLANE.md` (unknown; release proof)

### 177. Unknown active status: REPO_INTELLIGENCE_LAYER

- Conflict ID: `AMB28-stale_or_unknown_active_status-77961695`
- Type: `stale_or_unknown_active_status`
- Severity: `yellow`
- Recommended action: `expedite`
- Rationale: Unknown active batch/prompt/train status should be clarified before it blocks or duplicates future work.
- Linear issue ready: `True`
- Auto-resolved: `False`
- Involved:
  - `REPO_INTELLIGENCE_LAYER` — `docs/codex/REPO_INTELLIGENCE_LAYER.md` (unknown; release proof)

### 178. Unknown active status: SIG01_SIG16_SIGNATURE_EXPERIENCE_LAYER_TRAIN

- Conflict ID: `AMB28-stale_or_unknown_active_status-26240730`
- Type: `stale_or_unknown_active_status`
- Severity: `yellow`
- Recommended action: `expedite`
- Rationale: Unknown active batch/prompt/train status should be clarified before it blocks or duplicates future work.
- Linear issue ready: `True`
- Auto-resolved: `False`
- Involved:
  - `SIG01_SIG16_SIGNATURE_EXPERIENCE_LAYER_TRAIN` — `docs/codex/batch-trains/SIG01_SIG16_SIGNATURE_EXPERIENCE_LAYER_TRAIN.md` (unknown; release proof)

### 179. Unknown active status: SIG01_Signature_Experience_Source_Truth_And_Delight_Map_Prompt

- Conflict ID: `AMB28-stale_or_unknown_active_status-6033241`
- Type: `stale_or_unknown_active_status`
- Severity: `yellow`
- Recommended action: `expedite`
- Rationale: Unknown active batch/prompt/train status should be clarified before it blocks or duplicates future work.
- Linear issue ready: `True`
- Auto-resolved: `False`
- Involved:
  - `SIG01_Signature_Experience_Source_Truth_And_Delight_Map_Prompt` — `docs/codex/batches/SIG01_Signature_Experience_Source_Truth_And_Delight_Map_Prompt.md` (unknown; release proof)

### 180. Unknown active status: SIG02_Premium_Interaction_Kit_Implementation_Prompt

- Conflict ID: `AMB28-stale_or_unknown_active_status-92957723`
- Type: `stale_or_unknown_active_status`
- Severity: `yellow`
- Recommended action: `expedite`
- Rationale: Unknown active batch/prompt/train status should be clarified before it blocks or duplicates future work.
- Linear issue ready: `True`
- Auto-resolved: `False`
- Involved:
  - `SIG02_Premium_Interaction_Kit_Implementation_Prompt` — `docs/codex/batches/SIG02_Premium_Interaction_Kit_Implementation_Prompt.md` (unknown; release proof)

### 181. Unknown active status: SIG03_Today_Signature_Experience_Implementation_Prompt

- Conflict ID: `AMB28-stale_or_unknown_active_status-24678895`
- Type: `stale_or_unknown_active_status`
- Severity: `yellow`
- Recommended action: `expedite`
- Rationale: Unknown active batch/prompt/train status should be clarified before it blocks or duplicates future work.
- Linear issue ready: `True`
- Auto-resolved: `False`
- Involved:
  - `SIG03_Today_Signature_Experience_Implementation_Prompt` — `docs/codex/batches/SIG03_Today_Signature_Experience_Implementation_Prompt.md` (unknown; release proof)

### 182. Unknown active status: SIG04_Capture_Signature_Experience_Implementation_Prompt

- Conflict ID: `AMB28-stale_or_unknown_active_status-14411759`
- Type: `stale_or_unknown_active_status`
- Severity: `yellow`
- Recommended action: `expedite`
- Rationale: Unknown active batch/prompt/train status should be clarified before it blocks or duplicates future work.
- Linear issue ready: `True`
- Auto-resolved: `False`
- Involved:
  - `SIG04_Capture_Signature_Experience_Implementation_Prompt` — `docs/codex/batches/SIG04_Capture_Signature_Experience_Implementation_Prompt.md` (unknown; release proof)

### 183. Unknown active status: SIG05_Plan_Signature_Experience_Implementation_Prompt

- Conflict ID: `AMB28-stale_or_unknown_active_status-82126411`
- Type: `stale_or_unknown_active_status`
- Severity: `yellow`
- Recommended action: `expedite`
- Rationale: Unknown active batch/prompt/train status should be clarified before it blocks or duplicates future work.
- Linear issue ready: `True`
- Auto-resolved: `False`
- Involved:
  - `SIG05_Plan_Signature_Experience_Implementation_Prompt` — `docs/codex/batches/SIG05_Plan_Signature_Experience_Implementation_Prompt.md` (unknown; release proof)

### 184. Unknown active status: SIG06_Goals_Signature_Experience_Implementation_Prompt

- Conflict ID: `AMB28-stale_or_unknown_active_status-19693910`
- Type: `stale_or_unknown_active_status`
- Severity: `yellow`
- Recommended action: `expedite`
- Rationale: Unknown active batch/prompt/train status should be clarified before it blocks or duplicates future work.
- Linear issue ready: `True`
- Auto-resolved: `False`
- Involved:
  - `SIG06_Goals_Signature_Experience_Implementation_Prompt` — `docs/codex/batches/SIG06_Goals_Signature_Experience_Implementation_Prompt.md` (unknown; release proof)

### 185. Unknown active status: SIG07_You_Signature_Experience_Implementation_Prompt

- Conflict ID: `AMB28-stale_or_unknown_active_status-5934995`
- Type: `stale_or_unknown_active_status`
- Severity: `yellow`
- Recommended action: `expedite`
- Rationale: Unknown active batch/prompt/train status should be clarified before it blocks or duplicates future work.
- Linear issue ready: `True`
- Auto-resolved: `False`
- Involved:
  - `SIG07_You_Signature_Experience_Implementation_Prompt` — `docs/codex/batches/SIG07_You_Signature_Experience_Implementation_Prompt.md` (unknown; release proof)

### 186. Unknown active status: SIG08_Trust_And_Memory_Signature_Experience_Implementation_Prompt

- Conflict ID: `AMB28-stale_or_unknown_active_status-13876401`
- Type: `stale_or_unknown_active_status`
- Severity: `yellow`
- Recommended action: `expedite`
- Rationale: Unknown active batch/prompt/train status should be clarified before it blocks or duplicates future work.
- Linear issue ready: `True`
- Auto-resolved: `False`
- Involved:
  - `SIG08_Trust_And_Memory_Signature_Experience_Implementation_Prompt` — `docs/codex/batches/SIG08_Trust_And_Memory_Signature_Experience_Implementation_Prompt.md` (unknown; release proof)

### 187. Unknown active status: SIG09_Step_Session_Signature_Experience_Implementation_Prompt

- Conflict ID: `AMB28-stale_or_unknown_active_status-30613881`
- Type: `stale_or_unknown_active_status`
- Severity: `yellow`
- Recommended action: `expedite`
- Rationale: Unknown active batch/prompt/train status should be clarified before it blocks or duplicates future work.
- Linear issue ready: `True`
- Auto-resolved: `False`
- Involved:
  - `SIG09_Step_Session_Signature_Experience_Implementation_Prompt` — `docs/codex/batches/SIG09_Step_Session_Signature_Experience_Implementation_Prompt.md` (unknown; release proof)

### 188. Unknown active status: SIG10_Onboarding_First_Run_Signature_Experience_Implementation_Prompt

- Conflict ID: `AMB28-stale_or_unknown_active_status-90434473`
- Type: `stale_or_unknown_active_status`
- Severity: `yellow`
- Recommended action: `expedite`
- Rationale: Unknown active batch/prompt/train status should be clarified before it blocks or duplicates future work.
- Linear issue ready: `True`
- Auto-resolved: `False`
- Involved:
  - `SIG10_Onboarding_First_Run_Signature_Experience_Implementation_Prompt` — `docs/codex/batches/SIG10_Onboarding_First_Run_Signature_Experience_Implementation_Prompt.md` (unknown; release proof)

### 189. Unknown active status: SIG11_Haptics_Tactility_And_Feedback_Implementation_Prompt

- Conflict ID: `AMB28-stale_or_unknown_active_status-71742586`
- Type: `stale_or_unknown_active_status`
- Severity: `yellow`
- Recommended action: `expedite`
- Rationale: Unknown active batch/prompt/train status should be clarified before it blocks or duplicates future work.
- Linear issue ready: `True`
- Auto-resolved: `False`
- Involved:
  - `SIG11_Haptics_Tactility_And_Feedback_Implementation_Prompt` — `docs/codex/batches/SIG11_Haptics_Tactility_And_Feedback_Implementation_Prompt.md` (unknown; release proof)

### 190. Unknown active status: SIG12_Transformative_Transitions_Surface_Wiring_Prompt

- Conflict ID: `AMB28-stale_or_unknown_active_status-79653838`
- Type: `stale_or_unknown_active_status`
- Severity: `yellow`
- Recommended action: `expedite`
- Rationale: Unknown active batch/prompt/train status should be clarified before it blocks or duplicates future work.
- Linear issue ready: `True`
- Auto-resolved: `False`
- Involved:
  - `SIG12_Transformative_Transitions_Surface_Wiring_Prompt` — `docs/codex/batches/SIG12_Transformative_Transitions_Surface_Wiring_Prompt.md` (unknown; release proof)

### 191. Unknown active status: SIG13_Signature_Preview_Gallery_And_Demo_Scenarios_Prompt

- Conflict ID: `AMB28-stale_or_unknown_active_status-9821869`
- Type: `stale_or_unknown_active_status`
- Severity: `yellow`
- Recommended action: `expedite`
- Rationale: Unknown active batch/prompt/train status should be clarified before it blocks or duplicates future work.
- Linear issue ready: `True`
- Auto-resolved: `False`
- Involved:
  - `SIG13_Signature_Preview_Gallery_And_Demo_Scenarios_Prompt` — `docs/codex/batches/SIG13_Signature_Preview_Gallery_And_Demo_Scenarios_Prompt.md` (unknown; release proof)

### 192. Unknown active status: SIG14_Interaction_Performance_And_Battery_QA_Prompt

- Conflict ID: `AMB28-stale_or_unknown_active_status-32831961`
- Type: `stale_or_unknown_active_status`
- Severity: `yellow`
- Recommended action: `expedite`
- Rationale: Unknown active batch/prompt/train status should be clarified before it blocks or duplicates future work.
- Linear issue ready: `True`
- Auto-resolved: `False`
- Involved:
  - `SIG14_Interaction_Performance_And_Battery_QA_Prompt` — `docs/codex/batches/SIG14_Interaction_Performance_And_Battery_QA_Prompt.md` (unknown; release proof)

### 193. Unknown active status: SIG15_Accessibility_Motion_And_Cognitive_Load_Closeout_Prompt

- Conflict ID: `AMB28-stale_or_unknown_active_status-23551848`
- Type: `stale_or_unknown_active_status`
- Severity: `yellow`
- Recommended action: `expedite`
- Rationale: Unknown active batch/prompt/train status should be clarified before it blocks or duplicates future work.
- Linear issue ready: `True`
- Auto-resolved: `False`
- Involved:
  - `SIG15_Accessibility_Motion_And_Cognitive_Load_Closeout_Prompt` — `docs/codex/batches/SIG15_Accessibility_Motion_And_Cognitive_Load_Closeout_Prompt.md` (unknown; release proof)

### 194. Unknown active status: SIG16_Signature_Experience_Closeout_Prompt

- Conflict ID: `AMB28-stale_or_unknown_active_status-2835190`
- Type: `stale_or_unknown_active_status`
- Severity: `yellow`
- Recommended action: `expedite`
- Rationale: Unknown active batch/prompt/train status should be clarified before it blocks or duplicates future work.
- Linear issue ready: `True`
- Auto-resolved: `False`
- Involved:
  - `SIG16_Signature_Experience_Closeout_Prompt` — `docs/codex/batches/SIG16_Signature_Experience_Closeout_Prompt.md` (unknown; release proof)

### 195. Unknown active status: SIG_DEPENDENCY_AND_TOOLING_LEDGER

- Conflict ID: `AMB28-stale_or_unknown_active_status-82495327`
- Type: `stale_or_unknown_active_status`
- Severity: `yellow`
- Recommended action: `expedite`
- Rationale: Unknown active batch/prompt/train status should be clarified before it blocks or duplicates future work.
- Linear issue ready: `True`
- Auto-resolved: `False`
- Involved:
  - `SIG_DEPENDENCY_AND_TOOLING_LEDGER` — `docs/codex/SIG_DEPENDENCY_AND_TOOLING_LEDGER.md` (unknown; release proof)

### 196. Unknown active status: SIG_EMOTIONAL_DESIGN_MOMENTS_MAP

- Conflict ID: `AMB28-stale_or_unknown_active_status-3642087`
- Type: `stale_or_unknown_active_status`
- Severity: `yellow`
- Recommended action: `expedite`
- Rationale: Unknown active batch/prompt/train status should be clarified before it blocks or duplicates future work.
- Linear issue ready: `True`
- Auto-resolved: `False`
- Involved:
  - `SIG_EMOTIONAL_DESIGN_MOMENTS_MAP` — `docs/codex/SIG_EMOTIONAL_DESIGN_MOMENTS_MAP.md` (unknown; release proof)

### 197. Unknown active status: SIG_FLUIDITY_AND_DELIGHT_PROTOCOL

- Conflict ID: `AMB28-stale_or_unknown_active_status-46469336`
- Type: `stale_or_unknown_active_status`
- Severity: `yellow`
- Recommended action: `expedite`
- Rationale: Unknown active batch/prompt/train status should be clarified before it blocks or duplicates future work.
- Linear issue ready: `True`
- Auto-resolved: `False`
- Involved:
  - `SIG_FLUIDITY_AND_DELIGHT_PROTOCOL` — `docs/codex/SIG_FLUIDITY_AND_DELIGHT_PROTOCOL.md` (unknown; release proof)

### 198. Unknown active status: SIG_PREMIUM_INTERACTION_PRINCIPLES

- Conflict ID: `AMB28-stale_or_unknown_active_status-82370504`
- Type: `stale_or_unknown_active_status`
- Severity: `yellow`
- Recommended action: `expedite`
- Rationale: Unknown active batch/prompt/train status should be clarified before it blocks or duplicates future work.
- Linear issue ready: `True`
- Auto-resolved: `False`
- Involved:
  - `SIG_PREMIUM_INTERACTION_PRINCIPLES` — `docs/codex/SIG_PREMIUM_INTERACTION_PRINCIPLES.md` (unknown; release proof)

### 199. Unknown active status: SIG_SIGNATURE_EXPERIENCE_DEPENDENCY_GRAPH

- Conflict ID: `AMB28-stale_or_unknown_active_status-73757516`
- Type: `stale_or_unknown_active_status`
- Severity: `yellow`
- Recommended action: `expedite`
- Rationale: Unknown active batch/prompt/train status should be clarified before it blocks or duplicates future work.
- Linear issue ready: `True`
- Auto-resolved: `False`
- Involved:
  - `SIG_SIGNATURE_EXPERIENCE_DEPENDENCY_GRAPH` — `docs/codex/SIG_SIGNATURE_EXPERIENCE_DEPENDENCY_GRAPH.md` (unknown; release proof)

### 200. Unknown active status: SOURCE_ATLAS_COMPOSITION_GOAL_PROJECTION_MODEL

- Conflict ID: `AMB28-stale_or_unknown_active_status-40375966`
- Type: `stale_or_unknown_active_status`
- Severity: `yellow`
- Recommended action: `expedite`
- Rationale: Unknown active batch/prompt/train status should be clarified before it blocks or duplicates future work.
- Linear issue ready: `True`
- Auto-resolved: `False`
- Involved:
  - `SOURCE_ATLAS_COMPOSITION_GOAL_PROJECTION_MODEL` — `docs/codex/SOURCE_ATLAS_COMPOSITION_GOAL_PROJECTION_MODEL.md` (unknown; release proof)

### 201. Unknown active status: SOURCE_ATLAS_HPS_AOS_LDI_INTEGRATION_MAP

- Conflict ID: `AMB28-stale_or_unknown_active_status-59261457`
- Type: `stale_or_unknown_active_status`
- Severity: `yellow`
- Recommended action: `expedite`
- Rationale: Unknown active batch/prompt/train status should be clarified before it blocks or duplicates future work.
- Linear issue ready: `True`
- Auto-resolved: `False`
- Involved:
  - `SOURCE_ATLAS_HPS_AOS_LDI_INTEGRATION_MAP` — `docs/codex/SOURCE_ATLAS_HPS_AOS_LDI_INTEGRATION_MAP.md` (unknown; release proof)

### 202. Unknown active status: SOURCE_ATLAS_OFFICIAL_ADAPTER_CONTRACTS

- Conflict ID: `AMB28-stale_or_unknown_active_status-26242079`
- Type: `stale_or_unknown_active_status`
- Severity: `yellow`
- Recommended action: `expedite`
- Rationale: Unknown active batch/prompt/train status should be clarified before it blocks or duplicates future work.
- Linear issue ready: `True`
- Auto-resolved: `False`
- Involved:
  - `SOURCE_ATLAS_OFFICIAL_ADAPTER_CONTRACTS` — `docs/codex/SOURCE_ATLAS_OFFICIAL_ADAPTER_CONTRACTS.md` (unknown; release proof)

### 203. Unknown active status: SOURCE_ATLAS_PROJECTION_QA_FIXTURE_FAMILIES

- Conflict ID: `AMB28-stale_or_unknown_active_status-60042845`
- Type: `stale_or_unknown_active_status`
- Severity: `yellow`
- Recommended action: `expedite`
- Rationale: Unknown active batch/prompt/train status should be clarified before it blocks or duplicates future work.
- Linear issue ready: `True`
- Auto-resolved: `False`
- Involved:
  - `SOURCE_ATLAS_PROJECTION_QA_FIXTURE_FAMILIES` — `docs/codex/SOURCE_ATLAS_PROJECTION_QA_FIXTURE_FAMILIES.md` (unknown; release proof)

### 204. Unknown active status: SOURCE_ATLAS_RESEARCH_SEEDS_V1_IMPORT_PROMPT

- Conflict ID: `AMB28-stale_or_unknown_active_status-8702757`
- Type: `stale_or_unknown_active_status`
- Severity: `yellow`
- Recommended action: `expedite`
- Rationale: Unknown active batch/prompt/train status should be clarified before it blocks or duplicates future work.
- Linear issue ready: `True`
- Auto-resolved: `False`
- Involved:
  - `SOURCE_ATLAS_RESEARCH_SEEDS_V1_IMPORT_PROMPT` — `docs/codex/batches/SOURCE_ATLAS_RESEARCH_SEEDS_V1_IMPORT_PROMPT.md` (unknown; release proof)

### 205. Unknown active status: SOURCE_ATLAS_RESEARCH_SEEDS_V1_IMPORT_REPORT

- Conflict ID: `AMB28-stale_or_unknown_active_status-46640950`
- Type: `stale_or_unknown_active_status`
- Severity: `yellow`
- Recommended action: `expedite`
- Rationale: Unknown active batch/prompt/train status should be clarified before it blocks or duplicates future work.
- Linear issue ready: `True`
- Auto-resolved: `False`
- Involved:
  - `SOURCE_ATLAS_RESEARCH_SEEDS_V1_IMPORT_REPORT` — `docs/codex/SOURCE_ATLAS_RESEARCH_SEEDS_V1_IMPORT_REPORT.md` (unknown; release proof)

### 206. Unknown active status: SOURCE_ATLAS_RESEARCH_SEEDS_V1_LIMITATIONS

- Conflict ID: `AMB28-stale_or_unknown_active_status-1826410`
- Type: `stale_or_unknown_active_status`
- Severity: `yellow`
- Recommended action: `expedite`
- Rationale: Unknown active batch/prompt/train status should be clarified before it blocks or duplicates future work.
- Linear issue ready: `True`
- Auto-resolved: `False`
- Involved:
  - `SOURCE_ATLAS_RESEARCH_SEEDS_V1_LIMITATIONS` — `docs/codex/SOURCE_ATLAS_RESEARCH_SEEDS_V1_LIMITATIONS.md` (unknown; release proof)

### 207. Unknown active status: SPEED_TRAIN_LANE_POLICY

- Conflict ID: `AMB28-stale_or_unknown_active_status-86364455`
- Type: `stale_or_unknown_active_status`
- Severity: `yellow`
- Recommended action: `expedite`
- Rationale: Unknown active batch/prompt/train status should be clarified before it blocks or duplicates future work.
- Linear issue ready: `True`
- Auto-resolved: `False`
- Involved:
  - `SPEED_TRAIN_LANE_POLICY` — `docs/codex/SPEED_TRAIN_LANE_POLICY.json` (unknown; release proof)

### 208. Unknown active status: SPEED_TRAIN_QUICKSTART

- Conflict ID: `AMB28-stale_or_unknown_active_status-52846953`
- Type: `stale_or_unknown_active_status`
- Severity: `yellow`
- Recommended action: `expedite`
- Rationale: Unknown active batch/prompt/train status should be clarified before it blocks or duplicates future work.
- Linear issue ready: `True`
- Auto-resolved: `False`
- Involved:
  - `SPEED_TRAIN_QUICKSTART` — `docs/codex/SPEED_TRAIN_QUICKSTART.md` (unknown; release proof)

### 209. Unknown active status: TRANSFORMATIVE_MOTION_DEPENDENCY_GRAPH

- Conflict ID: `AMB28-stale_or_unknown_active_status-2030663`
- Type: `stale_or_unknown_active_status`
- Severity: `yellow`
- Recommended action: `expedite`
- Rationale: Unknown active batch/prompt/train status should be clarified before it blocks or duplicates future work.
- Linear issue ready: `True`
- Auto-resolved: `False`
- Involved:
  - `TRANSFORMATIVE_MOTION_DEPENDENCY_GRAPH` — `docs/codex/TRANSFORMATIVE_MOTION_DEPENDENCY_GRAPH.md` (unknown; release proof)

### 210. Unknown active status: TRANSFORMATIVE_MOTION_IMPLEMENTATION_PROTOCOL

- Conflict ID: `AMB28-stale_or_unknown_active_status-69143055`
- Type: `stale_or_unknown_active_status`
- Severity: `yellow`
- Recommended action: `expedite`
- Rationale: Unknown active batch/prompt/train status should be clarified before it blocks or duplicates future work.
- Linear issue ready: `True`
- Auto-resolved: `False`
- Involved:
  - `TRANSFORMATIVE_MOTION_IMPLEMENTATION_PROTOCOL` — `docs/codex/TRANSFORMATIVE_MOTION_IMPLEMENTATION_PROTOCOL.md` (unknown; release proof)

### 211. Unknown active status: TUIST_EVALUATION_AFTER_PK41_PLAYBOOK

- Conflict ID: `AMB28-stale_or_unknown_active_status-89439470`
- Type: `stale_or_unknown_active_status`
- Severity: `yellow`
- Recommended action: `expedite`
- Rationale: Unknown active batch/prompt/train status should be clarified before it blocks or duplicates future work.
- Linear issue ready: `True`
- Auto-resolved: `False`
- Involved:
  - `TUIST_EVALUATION_AFTER_PK41_PLAYBOOK` — `docs/codex/playbooks/TUIST_EVALUATION_AFTER_PK41_PLAYBOOK.md` (unknown; release proof)

### 212. Unknown active status: VISUAL_CRITIQUE_LAYER

- Conflict ID: `AMB28-stale_or_unknown_active_status-22004131`
- Type: `stale_or_unknown_active_status`
- Severity: `yellow`
- Recommended action: `expedite`
- Rationale: Unknown active batch/prompt/train status should be clarified before it blocks or duplicates future work.
- Linear issue ready: `True`
- Auto-resolved: `False`
- Involved:
  - `VISUAL_CRITIQUE_LAYER` — `docs/codex/VISUAL_CRITIQUE_LAYER.md` (unknown; release proof)

### 213. Unknown active status: XCODE_BUILD_LAB_PROTOCOL

- Conflict ID: `AMB28-stale_or_unknown_active_status-22409046`
- Type: `stale_or_unknown_active_status`
- Severity: `yellow`
- Recommended action: `expedite`
- Rationale: Unknown active batch/prompt/train status should be clarified before it blocks or duplicates future work.
- Linear issue ready: `True`
- Auto-resolved: `False`
- Involved:
  - `XCODE_BUILD_LAB_PROTOCOL` — `docs/codex/XCODE_BUILD_LAB_PROTOCOL.md` (unknown; release proof)

### 214. Unknown active status: XCODE_FAILURE_CLASSIFICATION_PLAYBOOK

- Conflict ID: `AMB28-stale_or_unknown_active_status-98390148`
- Type: `stale_or_unknown_active_status`
- Severity: `yellow`
- Recommended action: `expedite`
- Rationale: Unknown active batch/prompt/train status should be clarified before it blocks or duplicates future work.
- Linear issue ready: `True`
- Auto-resolved: `False`
- Involved:
  - `XCODE_FAILURE_CLASSIFICATION_PLAYBOOK` — `docs/codex/playbooks/XCODE_FAILURE_CLASSIFICATION_PLAYBOOK.md` (unknown; release proof)

### 215. Unknown active status: XCODE_RESULT_BUNDLE_PROTOCOL

- Conflict ID: `AMB28-stale_or_unknown_active_status-31501320`
- Type: `stale_or_unknown_active_status`
- Severity: `yellow`
- Recommended action: `expedite`
- Rationale: Unknown active batch/prompt/train status should be clarified before it blocks or duplicates future work.
- Linear issue ready: `True`
- Auto-resolved: `False`
- Involved:
  - `XCODE_RESULT_BUNDLE_PROTOCOL` — `docs/codex/XCODE_RESULT_BUNDLE_PROTOCOL.md` (unknown; release proof)

### 216. Unknown active status: XCODE_SICK_SIMULATOR_PLAYBOOK

- Conflict ID: `AMB28-stale_or_unknown_active_status-24937988`
- Type: `stale_or_unknown_active_status`
- Severity: `yellow`
- Recommended action: `expedite`
- Rationale: Unknown active batch/prompt/train status should be clarified before it blocks or duplicates future work.
- Linear issue ready: `True`
- Auto-resolved: `False`
- Involved:
  - `XCODE_SICK_SIMULATOR_PLAYBOOK` — `docs/codex/playbooks/XCODE_SICK_SIMULATOR_PLAYBOOK.md` (unknown; release proof)

### 217. Unknown active status: XCODE_TEST_PLAN_OWNERSHIP_PLAYBOOK

- Conflict ID: `AMB28-stale_or_unknown_active_status-72095455`
- Type: `stale_or_unknown_active_status`
- Severity: `yellow`
- Recommended action: `expedite`
- Rationale: Unknown active batch/prompt/train status should be clarified before it blocks or duplicates future work.
- Linear issue ready: `True`
- Auto-resolved: `False`
- Involved:
  - `XCODE_TEST_PLAN_OWNERSHIP_PLAYBOOK` — `docs/codex/playbooks/XCODE_TEST_PLAN_OWNERSHIP_PLAYBOOK.md` (unknown; release proof)

### 218. Unknown active status: XCODE_TOOLCHAIN_PINNING

- Conflict ID: `AMB28-stale_or_unknown_active_status-7418868`
- Type: `stale_or_unknown_active_status`
- Severity: `yellow`
- Recommended action: `expedite`
- Rationale: Unknown active batch/prompt/train status should be clarified before it blocks or duplicates future work.
- Linear issue ready: `True`
- Auto-resolved: `False`
- Involved:
  - `XCODE_TOOLCHAIN_PINNING` — `docs/codex/XCODE_TOOLCHAIN_PINNING.md` (unknown; release proof)

### 219. Unknown active status: XCODE_VALIDATION_LANE_MATRIX

- Conflict ID: `AMB28-stale_or_unknown_active_status-39854993`
- Type: `stale_or_unknown_active_status`
- Severity: `yellow`
- Recommended action: `expedite`
- Rationale: Unknown active batch/prompt/train status should be clarified before it blocks or duplicates future work.
- Linear issue ready: `True`
- Auto-resolved: `False`
- Involved:
  - `XCODE_VALIDATION_LANE_MATRIX` — `docs/codex/XCODE_VALIDATION_LANE_MATRIX.md` (unknown; release proof)

### 220. Unknown active status: existing-code-champion-coverage

- Conflict ID: `AMB28-stale_or_unknown_active_status-50159668`
- Type: `stale_or_unknown_active_status`
- Severity: `yellow`
- Recommended action: `expedite`
- Rationale: Unknown active batch/prompt/train status should be clarified before it blocks or duplicates future work.
- Linear issue ready: `True`
- Auto-resolved: `False`
- Involved:
  - `existing-code-champion-coverage` — `docs/codex/existing-code-champion-coverage.yml` (unknown; release proof)

### 221. Unknown active status: platform-kernel-module-boundary-scaffold

- Conflict ID: `AMB28-stale_or_unknown_active_status-43845058`
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
