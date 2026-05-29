# Active Canon Collapse Candidates

Status: GREEN
Generated UTC: 2026-05-29T00:54:14Z
Owner: CANON-COLLAPSE-002
Linear issue: AMB-286

## Purpose

This report identifies evidence-backed active canon cleanup candidates from repo truth, the batch ledger, and conflict reports.

This report does not modify canon, source code, prompts, trains, or Linear. It does not delete or archive anything.

## Required read order

- `docs/truth/README.md`
- `docs/truth/PRODUCT_DESIGN_TRUTH.md`
- `docs/truth/PRODUCT_MOAT_TRUTH.md`
- `docs/truth/IMPLEMENTATION_TRUTH.md`
- `docs/truth/RELEASE_TRUTH.md`
- `docs/truth/CODEX_PROCESS_TRUTH.md`
- `docs/truth/HISTORICAL_POLICY.md`
- `docs/ops/batch-ledger/batch-ledger.json`
- `docs/ops/batch-ledger/conflict-report.json`
- `docs/ops/batch-ledger/conflict-action-workflow.md`
- `docs/ops/change-protocol/change-request-template.md`
- `docs/ops/change-protocol/change-impact-check.md`
- `docs/ops/change-protocol/implementation-prompt-template.md`
- `docs/ops/change-protocol/post-implementation-proof-reconciliation.md`

## Summary

- Active candidates: `1407`
- Historical-only residue: `0`
- Red active candidates: `0`
- Auto-resolved candidates: `0`

### Active candidates by action

- `Expedite`: `155`
- `Merge`: `302`
- `Rewrite`: `950`

### Active candidates by conflict type

- `duplicate_stable_id`: `32`
- `missing_source_of_truth_reference`: `549`
- `retired_ia_or_terminology_reference`: `401`
- `same_source_file_targeted_by_multiple_active_batches`: `270`
- `same_surface_multiple_active_batches`: `6`
- `stale_or_unknown_active_status`: `149`

## Next bounded action bundle

- Bundle ID: `canon-collapse-merge-overlap-bundle`
- Title: Merge or sequence overlapping active canon/work ownership
- Recommended action: `Merge`
- Candidate count: `100`
- Reason: Duplicate and overlapping active work should be merged or sequenced before implementation.

### Bundle candidate IDs

- `AMB28-duplicate_stable_id-1105557`
- `AMB28-duplicate_stable_id-12589510`
- `AMB28-duplicate_stable_id-14491567`
- `AMB28-duplicate_stable_id-18972706`
- `AMB28-duplicate_stable_id-1899858`
- `AMB28-duplicate_stable_id-21293541`
- `AMB28-duplicate_stable_id-25137423`
- `AMB28-duplicate_stable_id-2753381`
- `AMB28-duplicate_stable_id-29367607`
- `AMB28-duplicate_stable_id-32886933`
- `AMB28-duplicate_stable_id-32923536`
- `AMB28-duplicate_stable_id-3537878`
- `AMB28-duplicate_stable_id-37090894`
- `AMB28-duplicate_stable_id-42546181`
- `AMB28-duplicate_stable_id-42855100`
- `AMB28-duplicate_stable_id-43194275`
- `AMB28-duplicate_stable_id-43428415`
- `AMB28-duplicate_stable_id-44298757`
- `AMB28-duplicate_stable_id-47177221`
- `AMB28-duplicate_stable_id-51794941`
- `AMB28-duplicate_stable_id-53867379`
- `AMB28-duplicate_stable_id-60231469`
- `AMB28-duplicate_stable_id-64077215`
- `AMB28-duplicate_stable_id-66828597`
- `AMB28-duplicate_stable_id-70646521`
- `AMB28-duplicate_stable_id-78009874`
- `AMB28-duplicate_stable_id-78256927`
- `AMB28-duplicate_stable_id-80677761`
- `AMB28-duplicate_stable_id-89068138`
- `AMB28-duplicate_stable_id-89653262`
- `AMB28-duplicate_stable_id-91883742`
- `AMB28-duplicate_stable_id-99576699`
- `AMB28-same_source_file_targeted_by_multiple_active_batches-10024695`
- `AMB28-same_source_file_targeted_by_multiple_active_batches-11441559`
- `AMB28-same_source_file_targeted_by_multiple_active_batches-11744591`
- `AMB28-same_source_file_targeted_by_multiple_active_batches-12510016`
- `AMB28-same_source_file_targeted_by_multiple_active_batches-12678930`
- `AMB28-same_source_file_targeted_by_multiple_active_batches-12732312`
- `AMB28-same_source_file_targeted_by_multiple_active_batches-13258853`
- `AMB28-same_source_file_targeted_by_multiple_active_batches-13366951`
- `AMB28-same_source_file_targeted_by_multiple_active_batches-13641484`
- `AMB28-same_source_file_targeted_by_multiple_active_batches-14422218`
- `AMB28-same_source_file_targeted_by_multiple_active_batches-14846146`
- `AMB28-same_source_file_targeted_by_multiple_active_batches-15166734`
- `AMB28-same_source_file_targeted_by_multiple_active_batches-15178486`
- `AMB28-same_source_file_targeted_by_multiple_active_batches-15551155`
- `AMB28-same_source_file_targeted_by_multiple_active_batches-15930853`
- `AMB28-same_source_file_targeted_by_multiple_active_batches-16299321`
- `AMB28-same_source_file_targeted_by_multiple_active_batches-16662712`
- `AMB28-same_source_file_targeted_by_multiple_active_batches-1678620`
- `AMB28-same_source_file_targeted_by_multiple_active_batches-17335520`
- `AMB28-same_source_file_targeted_by_multiple_active_batches-17436698`
- `AMB28-same_source_file_targeted_by_multiple_active_batches-18701214`
- `AMB28-same_source_file_targeted_by_multiple_active_batches-19147812`
- `AMB28-same_source_file_targeted_by_multiple_active_batches-19356985`
- `AMB28-same_source_file_targeted_by_multiple_active_batches-19535584`
- `AMB28-same_source_file_targeted_by_multiple_active_batches-19539596`
- `AMB28-same_source_file_targeted_by_multiple_active_batches-19612780`
- `AMB28-same_source_file_targeted_by_multiple_active_batches-19635144`
- `AMB28-same_source_file_targeted_by_multiple_active_batches-19691328`
- `AMB28-same_source_file_targeted_by_multiple_active_batches-19727000`
- `AMB28-same_source_file_targeted_by_multiple_active_batches-19765400`
- `AMB28-same_source_file_targeted_by_multiple_active_batches-20149357`
- `AMB28-same_source_file_targeted_by_multiple_active_batches-2088219`
- `AMB28-same_source_file_targeted_by_multiple_active_batches-21382445`
- `AMB28-same_source_file_targeted_by_multiple_active_batches-2142772`
- `AMB28-same_source_file_targeted_by_multiple_active_batches-21429932`
- `AMB28-same_source_file_targeted_by_multiple_active_batches-21500555`
- `AMB28-same_source_file_targeted_by_multiple_active_batches-21895358`
- `AMB28-same_source_file_targeted_by_multiple_active_batches-22155646`
- `AMB28-same_source_file_targeted_by_multiple_active_batches-22211844`
- `AMB28-same_source_file_targeted_by_multiple_active_batches-22513529`
- `AMB28-same_source_file_targeted_by_multiple_active_batches-22582954`
- `AMB28-same_source_file_targeted_by_multiple_active_batches-22627068`
- `AMB28-same_source_file_targeted_by_multiple_active_batches-23304107`
- `AMB28-same_source_file_targeted_by_multiple_active_batches-23925245`
- `AMB28-same_source_file_targeted_by_multiple_active_batches-24534268`
- `AMB28-same_source_file_targeted_by_multiple_active_batches-25366281`
- `AMB28-same_source_file_targeted_by_multiple_active_batches-25432004`
- `AMB28-same_source_file_targeted_by_multiple_active_batches-25847701`
- ... 20 more in JSON

### Bundle repo paths

- `docs/codex/AMBITIONSOS_AOS_EVIDENCE_LEDGER.md`
- `docs/codex/AMBITIONSOS_AOS_PRIVACY_PROJECTION_LEDGER.md`
- `docs/codex/AMBITIONSOS_AOS_SOURCE_TRUTH_CLAIM_LEDGER.md`
- `docs/codex/AMBITIONSOS_AOS_TRACEABILITY_MATRIX.md`
- `docs/codex/AMBITIONS_3_0_CONTEXT_LOADING_AND_TASK_ROUTING.md`
- `docs/codex/AMBITIONS_4_0_EXTERNAL_BRAIN_CLOSEOUT.md`
- `docs/codex/AMB_CODEX_GOVERNANCE_SPEC.md`
- `docs/codex/AMB_GLOBAL_REMAINING_TRAIN_BLUEPRINT.json`
- `docs/codex/AMB_GLOBAL_REMAINING_TRAIN_BLUEPRINT.md`
- `docs/codex/AMB_REMAINING_BATCH_REFERENCE.json`
- `docs/codex/AMB_REMAINING_BATCH_REFERENCE.md`
- `docs/codex/CODEX_BUILD_SHERIFF_PROTOCOL.md`
- `docs/codex/CODEX_OS_ENGINE_SUPPLEMENT_2026_05_08.md`
- `docs/codex/CODEX_OS_REPAIR_SPEED_PROOF_UPGRADE_AUDIT_2026_05_08.md`
- `docs/codex/CODEX_PROOF_CACHE_PROTOCOL.md`
- `docs/codex/CODEX_QUALITY_SYSTEM_SCRIPT_MAP.md`
- `docs/codex/CODEX_SPEED_ENGINE.md`
- `docs/codex/FAANG_FRONTEND_IMPLEMENTATION_OPERATING_SYSTEM.md`
- `docs/codex/FLAGSHIP_COMPLETION_FILE_BOUNDARY_MAP.md`
- `docs/codex/FLAGSHIP_COMPLETION_GATE_MATRIX.md`
- `docs/codex/FRONTEND_AUTHORITY_GLOBAL_TRAIN_HOOK.md`
- `docs/codex/GATE_RESULT_MANIFEST_SCHEMA.md`
- `docs/codex/GLOBAL_BATCH_AUTOMATED_GATE_PROTOCOL.md`
- `docs/codex/GLOBAL_PATCH_TRAIN_INTERRUPTED_RUN_RECOVERY_PROTOCOL.md`
- `docs/codex/GOAL_REALITY_COMPILER_BACKEND_MASTER_PLAN.md`
- `docs/codex/IOS26_FLAGSHIP_BACKLOG_MAP.md`
- `docs/codex/IOS26_FLAGSHIP_EXECUTION_STATE.yml`
- `docs/codex/IOS26_FLAGSHIP_TRAIN_MANIFEST.yml`
- `docs/codex/MOONSHOT_PROOF_PATH_BACKEND_MASTER_PLAN.md`
- `docs/codex/OPENAI_BUILD_SUITE_ADOPTION_MATRIX.md`
- `docs/codex/POST_PK_CLOSEOUT_CONTRACT.md`
- `docs/codex/POST_PK_SPEED_TRAIN_OPERATING_MODEL.md`
- `docs/codex/PROMPT_REPAIR_LAYER.md`
- `docs/codex/REPO_INTELLIGENCE_CONTROL_PLANE.md`
- `docs/codex/SOURCE_ATLAS_CODEX_OS_UPGRADE_MAP.md`
- `docs/codex/SPEED_TRAIN_LANE_POLICY.json`
- `docs/codex/SPEED_TRAIN_QUICKSTART.md`
- `docs/codex/TIME_REPLACES_PLAN_COMPATIBILITY_LEDGER.md`
- `docs/codex/XCODE_BUILD_LAB_PROTOCOL.md`
- `docs/codex/ambitions-hybrid-runner.md`
- `docs/codex/backlog/ios26-flagship-maturation-backlog.md`
- `docs/codex/batch-prep/PK16.md`
- `docs/codex/batch-prep/PK17.md`
- `docs/codex/batch-prep/PK18.md`
- `docs/codex/batch-prep/PK19.md`
- `docs/codex/batch-prep/PK20.md`
- `docs/codex/batch-prep/PK21.md`
- `docs/codex/batch-prep/PK22.md`
- `docs/codex/batch-prep/PK23.md`
- `docs/codex/batch-prep/PK24.md`
- `docs/codex/batch-prep/PK25.md`
- `docs/codex/batch-prep/README.md`
- `docs/codex/batch-trains/CQS01_CQS24_CODEX_QUALITY_SYSTEM_TRAIN.md`
- `docs/codex/batch-trains/FCP01_FCP30_FLAGSHIP_COMPLETION_TRAIN.md`
- `docs/codex/batch-trains/FET01_FET12_FAANG_FRONTEND_EXCELLENCE_TRAIN.md`
- `docs/codex/batch-trains/FL01_FL06_FOUND_LIFE_LAYER_TRAIN.md`
- `docs/codex/batch-trains/HPS01_HPS12_HUMAN_PROGRESS_SYSTEMS_UPGRADE_TRAIN.md`
- `docs/codex/batch-trains/PFC01_PFC40_PLATFORM_FRAMEWORK_COMPLIANCE_TRAIN.md`
- `docs/codex/batch-trains/README.md`
- `docs/codex/batch-trains/SA01_SA32_SOURCE_ATLAS_FULL_MATURITY_TRAIN.md`
- `docs/codex/batch-trains/amb-fe-be/README.md`
- `docs/codex/batch-trains/post99-ui-suite/README.md`
- `docs/codex/batches/AOS01_AmbitionsOS_Canon_And_Runtime_Contract_Prompt.md`
- `docs/codex/batches/AOS02_Life_Graph_Event_Log_Foundation_Prompt.md`
- `docs/codex/batches/AOS03_Graph_Delta_Review_Projection_Store_Prompt.md`
- `docs/codex/batches/AOS04_Control_Plane_Work_Classifier_Prompt.md`
- `docs/codex/batches/AOS05_Starting_Position_Kernel_Prompt.md`
- `docs/codex/batches/AOS06_Goal_Path_Kernel_Goal_Compiler_Prompt.md`
- `docs/codex/batches/AOS07_Local_Goal_Packs_Requirement_Slots_Prompt.md`
- `docs/codex/batches/AOS08_Alternate_Path_Kernel_Path_Portfolio_Prompt.md`
- `docs/codex/batches/AOS09_Option_Value_North_Star_Prompt.md`
- `docs/codex/batches/AOS10_Commitment_Time_Kernel_Prompt.md`
- `docs/codex/batches/AOS11_Reality_Drift_Bounded_Reflow_Prompt.md`
- `docs/codex/batches/AOS12_Proof_Trust_Closure_Receipts_Prompt.md`
- `docs/codex/batches/AOS13_Source_Truth_Claim_State_Machine_Prompt.md`
- `docs/codex/batches/AOS14_Recommendation_Start_Here_Kernel_Prompt.md`
- `docs/codex/batches/AOS15_Local_Language_Kernel_Planning_Prompt.md`
- `docs/codex/batches/AOS16_Performance_Energy_Kernel_Prompt.md`
- `docs/codex/batches/AOS17_Privacy_Safety_Kernel_Prompt.md`
- `docs/codex/batches/AOS18_Evaluation_Golden_Scenarios_Prompt.md`
- `docs/codex/batches/AOS19_Experience_Kernel_Celestial_Cognitive_Load_Prompt.md`
- `docs/codex/batches/AOS20_Adaptation_Kernel_Local_Personalization_Prompt.md`
- `docs/codex/batches/AOS21_Interoperability_Kernel_App_Intents_EventKit_Planning_Prompt.md`
- `docs/codex/batches/AOS22_Longevity_Kernel_Archive_Aging_Prompt.md`
- `docs/codex/batches/AOS23_Governance_Kernel_Registry_Prompt.md`
- `docs/codex/batches/AOS24_AmbitionsOS_UI_Integration_Prompt.md`
- `docs/codex/batches/AOS25_AmbitionsOS_Test_Fixture_Library_Prompt.md`
- `docs/codex/batches/AOS26_AmbitionsOS_Privacy_Performance_QA_Prompt.md`
- `docs/codex/batches/AOS27_AmbitionsOS_App_Store_Claim_Truth_Prompt.md`
- `docs/codex/batches/AOS28_AmbitionsOS_Handoff_Prompt.md`
- `docs/codex/batches/AOS29_AmbitionsOS_Repair_Train_Prompt.md`
- `docs/codex/batches/AOS30_AmbitionsOS_Beyond_Roadmap_Prompt.md`
- `docs/codex/batches/AQOS_AUTONOMOUS_QUALITY_CONTINUATION_PROMPT.md`
- `docs/codex/batches/AQOS_TOOLS_SKILLS_AND_SCRIPTS_PROMPT.md`
- `docs/codex/batches/BATCH-23-generalized-goal-understanding-contracts.md`
- `docs/codex/batches/BATCH-24-path-compiler-foundation.md`
- `docs/codex/batches/BATCH-25-domain-pack-framework.md`
- `docs/codex/batches/BATCH-30-contradiction-engine.md`
- `docs/codex/batches/BATCH-31-correction-and-teaching-loop.md`
- `docs/codex/batches/BATCH-33-intelligence-runtime-integration.md`
- `docs/codex/batches/DAV02_Reusable_Living_Visual_Primitives_Implementation_Prompt.md`
- `docs/codex/batches/DAV10_AdaptiveMotion_ReduceMotion_And_StateTransitions_Prompt.md`
- `docs/codex/batches/EB01_External_Brain_Source_Truth_And_Kernel_Architecture_Prompt.md`
- `docs/codex/batches/EB02_Universal_Capture_Canon_And_Domain_Model_Prompt.md`
- `docs/codex/batches/EB03_Universal_Capture_Composer_And_Routing_Prompt.md`
- `docs/codex/batches/EB04_Capture_Classification_And_Clarification_Prompt.md`
- `docs/codex/batches/EB05_Capture_Clusters_Review_Bundles_And_Open_Loops_Prompt.md`
- `docs/codex/batches/EB06_Capture_Receipts_Undo_And_Reclassification_Prompt.md`
- `docs/codex/batches/EB07_Life_Memory_Graph_Canon_And_Domain_Model_Prompt.md`
- `docs/codex/batches/EB08_Memory_Source_Confidence_And_Trust_Decay_Prompt.md`
- `docs/codex/batches/EB09_Life_Event_Decision_And_Context_Recall_Memory_Prompt.md`
- `docs/codex/batches/EB10_Personal_Operating_Manual_Prompt.md`
- `docs/codex/batches/EB11_Memory_Correction_Deletion_And_Rejection_Prompt.md`
- `docs/codex/batches/EB12_Memory_Receipts_And_Why_Remembered_This_Prompt.md`
- `docs/codex/batches/EB13_Trust_Privacy_User_Control_Canon_Prompt.md`
- `docs/codex/batches/EB14_Trust_Center_And_Data_Map_Prompt.md`
- `docs/codex/batches/EB15_Recommendation_Evidence_And_Inference_Boundaries_Prompt.md`
- `docs/codex/batches/EB16_Private_Mode_And_Sensitive_Area_Controls_Prompt.md`
- `docs/codex/batches/EB17_Undo_Correction_Audit_Trail_And_Export_Prompt.md`
- `docs/codex/batches/EB18_Source_Freshness_Privacy_Receipts_And_Non_Claims_Prompt.md`
- ... 262 more in JSON

## Active candidates

### 1. Retired IA/terminology reference in Launch_Operator_Runbook

- Candidate ID: `AMB28-retired_ia_or_terminology_reference-10553799`
- Evidence type: `retired_ia_or_terminology_reference`
- Severity: `yellow`
- Recommended action: `Rewrite`
- Linear-ready: `True`
- Auto-resolved: `False`
- Reason: Active item contains retired IA, retired terminology, or unsafe language; rewrite or retire before reuse.
- Involved active paths:
  - `Launch_Operator_Runbook` — `docs/codex/Launch_Operator_Runbook.md` (unknown; release proof)

### 2. Retired IA/terminology reference in AOS29_AmbitionsOS_Repair_Train_Prompt

- Candidate ID: `AMB28-retired_ia_or_terminology_reference-10656732`
- Evidence type: `retired_ia_or_terminology_reference`
- Severity: `yellow`
- Recommended action: `Rewrite`
- Linear-ready: `True`
- Auto-resolved: `False`
- Reason: Active item contains retired IA, retired terminology, or unsafe language; rewrite or retire before reuse.
- Involved active paths:
  - `AOS29_AmbitionsOS_Repair_Train_Prompt` — `docs/codex/batches/AOS29_AmbitionsOS_Repair_Train_Prompt.md` (partial_implementation; release proof)

### 3. Retired IA/terminology reference in AMB-REPO-GREEN-FLAGSHIP-RESET-MASTER-01-T11-TIME-EXTRACTION

- Candidate ID: `AMB28-retired_ia_or_terminology_reference-10792436`
- Evidence type: `retired_ia_or_terminology_reference`
- Severity: `yellow`
- Recommended action: `Rewrite`
- Linear-ready: `True`
- Auto-resolved: `False`
- Reason: Active item contains retired IA, retired terminology, or unsafe language; rewrite or retire before reuse.
- Involved active paths:
  - `AMB-REPO-GREEN-FLAGSHIP-RESET-MASTER-01-T11-TIME-EXTRACTION` — `prompts/batches/AMB-REPO-GREEN-FLAGSHIP-RESET-MASTER-01-T11-TIME-EXTRACTION.md` (partial_implementation; tests)

### 4. Retired IA/terminology reference in PXOS_PRODUCT_DECISION_LEDGER

- Candidate ID: `AMB28-retired_ia_or_terminology_reference-11004432`
- Evidence type: `retired_ia_or_terminology_reference`
- Severity: `yellow`
- Recommended action: `Rewrite`
- Linear-ready: `True`
- Auto-resolved: `False`
- Reason: Active item contains retired IA, retired terminology, or unsafe language; rewrite or retire before reuse.
- Involved active paths:
  - `PXOS_PRODUCT_DECISION_LEDGER` — `docs/codex/PXOS_PRODUCT_DECISION_LEDGER.md` (unknown; release proof)

### 5. Retired IA/terminology reference in GATE_RESULT_MANIFEST_SCHEMA

- Candidate ID: `AMB28-retired_ia_or_terminology_reference-11341758`
- Evidence type: `retired_ia_or_terminology_reference`
- Severity: `yellow`
- Recommended action: `Rewrite`
- Linear-ready: `True`
- Auto-resolved: `False`
- Reason: Active item contains retired IA, retired terminology, or unsafe language; rewrite or retire before reuse.
- Involved active paths:
  - `GATE_RESULT_MANIFEST_SCHEMA` — `docs/codex/GATE_RESULT_MANIFEST_SCHEMA.md` (partial_implementation; audit)

### 6. Retired IA/terminology reference in VISUAL-ENCYCLOPEDIA-100-PROOF-HARDENING-03

- Candidate ID: `AMB28-retired_ia_or_terminology_reference-11459550`
- Evidence type: `retired_ia_or_terminology_reference`
- Severity: `yellow`
- Recommended action: `Rewrite`
- Linear-ready: `True`
- Auto-resolved: `False`
- Reason: Active item contains retired IA, retired terminology, or unsafe language; rewrite or retire before reuse.
- Involved active paths:
  - `VISUAL-ENCYCLOPEDIA-100-PROOF-HARDENING-03` — `prompts/batches/VISUAL-ENCYCLOPEDIA-100-PROOF-HARDENING-03.md` (partial_implementation; release proof)

### 7. Retired IA/terminology reference in MOAT-COMPLETE-AUTONOMOUS-01

- Candidate ID: `AMB28-retired_ia_or_terminology_reference-11632274`
- Evidence type: `retired_ia_or_terminology_reference`
- Severity: `yellow`
- Recommended action: `Rewrite`
- Linear-ready: `True`
- Auto-resolved: `False`
- Reason: Active item contains retired IA, retired terminology, or unsafe language; rewrite or retire before reuse.
- Involved active paths:
  - `MOAT-COMPLETE-AUTONOMOUS-01` — `prompts/batches/MOAT-COMPLETE-AUTONOMOUS-01.md` (partial_implementation; release proof)

### 8. Retired IA/terminology reference in PX15_Cross_Surface_Continuity_Prompt

- Candidate ID: `AMB28-retired_ia_or_terminology_reference-11981020`
- Evidence type: `retired_ia_or_terminology_reference`
- Severity: `yellow`
- Recommended action: `Rewrite`
- Linear-ready: `True`
- Auto-resolved: `False`
- Reason: Active item contains retired IA, retired terminology, or unsafe language; rewrite or retire before reuse.
- Involved active paths:
  - `PX15_Cross_Surface_Continuity_Prompt` — `docs/codex/batches/PX15_Cross_Surface_Continuity_Prompt.md` (partial_implementation; release proof)

### 9. Retired IA/terminology reference in DPTG00_Physical_Device_Terminal_Gate_Lock_Prompt

- Candidate ID: `AMB28-retired_ia_or_terminology_reference-12515401`
- Evidence type: `retired_ia_or_terminology_reference`
- Severity: `yellow`
- Recommended action: `Rewrite`
- Linear-ready: `True`
- Auto-resolved: `False`
- Reason: Active item contains retired IA, retired terminology, or unsafe language; rewrite or retire before reuse.
- Involved active paths:
  - `DPTG00_Physical_Device_Terminal_Gate_Lock_Prompt` — `docs/codex/batches/DPTG00_Physical_Device_Terminal_Gate_Lock_Prompt.md` (partial_implementation; release proof)

### 10. Retired IA/terminology reference in PK35

- Candidate ID: `AMB28-retired_ia_or_terminology_reference-12521720`
- Evidence type: `retired_ia_or_terminology_reference`
- Severity: `yellow`
- Recommended action: `Rewrite`
- Linear-ready: `True`
- Auto-resolved: `False`
- Reason: Active item contains retired IA, retired terminology, or unsafe language; rewrite or retire before reuse.
- Involved active paths:
  - `PK35` — `prompts/batches/PK35.md` (partial_implementation; release proof)

### 11. Retired IA/terminology reference in AOS27

- Candidate ID: `AMB28-retired_ia_or_terminology_reference-12522697`
- Evidence type: `retired_ia_or_terminology_reference`
- Severity: `yellow`
- Recommended action: `Rewrite`
- Linear-ready: `True`
- Auto-resolved: `False`
- Reason: Active item contains retired IA, retired terminology, or unsafe language; rewrite or retire before reuse.
- Involved active paths:
  - `AOS27` — `prompts/batches/AOS27.md` (partial_implementation; release proof)

### 12. Retired IA/terminology reference in EB07_Life_Memory_Graph_Canon_And_Domain_Model_Prompt

- Candidate ID: `AMB28-retired_ia_or_terminology_reference-12602690`
- Evidence type: `retired_ia_or_terminology_reference`
- Severity: `yellow`
- Recommended action: `Rewrite`
- Linear-ready: `True`
- Auto-resolved: `False`
- Reason: Active item contains retired IA, retired terminology, or unsafe language; rewrite or retire before reuse.
- Involved active paths:
  - `EB07_Life_Memory_Graph_Canon_And_Domain_Model_Prompt` — `docs/codex/batches/EB07_Life_Memory_Graph_Canon_And_Domain_Model_Prompt.md` (partial_implementation; release proof)

### 13. Retired IA/terminology reference in AOS28_AmbitionsOS_Handoff_Prompt

- Candidate ID: `AMB28-retired_ia_or_terminology_reference-12682823`
- Evidence type: `retired_ia_or_terminology_reference`
- Severity: `yellow`
- Recommended action: `Rewrite`
- Linear-ready: `True`
- Auto-resolved: `False`
- Reason: Active item contains retired IA, retired terminology, or unsafe language; rewrite or retire before reuse.
- Involved active paths:
  - `AOS28_AmbitionsOS_Handoff_Prompt` — `docs/codex/batches/AOS28_AmbitionsOS_Handoff_Prompt.md` (partial_implementation; release proof)

### 14. Retired IA/terminology reference in AMB-REPO-AUTHORITY-06-ACTIVE-DRIFT-REPAIR

- Candidate ID: `AMB28-retired_ia_or_terminology_reference-12758571`
- Evidence type: `retired_ia_or_terminology_reference`
- Severity: `yellow`
- Recommended action: `Rewrite`
- Linear-ready: `True`
- Auto-resolved: `False`
- Reason: Active item contains retired IA, retired terminology, or unsafe language; rewrite or retire before reuse.
- Involved active paths:
  - `AMB-REPO-AUTHORITY-06-ACTIVE-DRIFT-REPAIR` — `prompts/batches/AMB-REPO-AUTHORITY-06-ACTIVE-DRIFT-REPAIR.md` (partial_implementation; release proof)

### 15. Retired IA/terminology reference in SIG06_Goals_Signature_Experience_Implementation_Prompt

- Candidate ID: `AMB28-retired_ia_or_terminology_reference-13062759`
- Evidence type: `retired_ia_or_terminology_reference`
- Severity: `yellow`
- Recommended action: `Rewrite`
- Linear-ready: `True`
- Auto-resolved: `False`
- Reason: Active item contains retired IA, retired terminology, or unsafe language; rewrite or retire before reuse.
- Involved active paths:
  - `SIG06_Goals_Signature_Experience_Implementation_Prompt` — `docs/codex/batches/SIG06_Goals_Signature_Experience_Implementation_Prompt.md` (partial_implementation; source-only)

### 16. Retired IA/terminology reference in AOS21_Interoperability_Kernel_App_Intents_EventKit_Planning_Prompt

- Candidate ID: `AMB28-retired_ia_or_terminology_reference-13143779`
- Evidence type: `retired_ia_or_terminology_reference`
- Severity: `yellow`
- Recommended action: `Rewrite`
- Linear-ready: `True`
- Auto-resolved: `False`
- Reason: Active item contains retired IA, retired terminology, or unsafe language; rewrite or retire before reuse.
- Involved active paths:
  - `AOS21_Interoperability_Kernel_App_Intents_EventKit_Planning_Prompt` — `docs/codex/batches/AOS21_Interoperability_Kernel_App_Intents_EventKit_Planning_Prompt.md` (partial_implementation; release proof)

### 17. Retired IA/terminology reference in EB33_External_Brain_Search_And_Context_Recall_Prompt

- Candidate ID: `AMB28-retired_ia_or_terminology_reference-139284`
- Evidence type: `retired_ia_or_terminology_reference`
- Severity: `yellow`
- Recommended action: `Rewrite`
- Linear-ready: `True`
- Auto-resolved: `False`
- Reason: Active item contains retired IA, retired terminology, or unsafe language; rewrite or retire before reuse.
- Involved active paths:
  - `EB33_External_Brain_Search_And_Context_Recall_Prompt` — `docs/codex/batches/EB33_External_Brain_Search_And_Context_Recall_Prompt.md` (partial_implementation; release proof)

### 18. Retired IA/terminology reference in FVQ04_RECURRING_UI_BATCH_RENDERED_PROOF_PROTOCOL

- Candidate ID: `AMB28-retired_ia_or_terminology_reference-14014218`
- Evidence type: `retired_ia_or_terminology_reference`
- Severity: `yellow`
- Recommended action: `Rewrite`
- Linear-ready: `True`
- Auto-resolved: `False`
- Reason: Active item contains retired IA, retired terminology, or unsafe language; rewrite or retire before reuse.
- Involved active paths:
  - `FVQ04_RECURRING_UI_BATCH_RENDERED_PROOF_PROTOCOL` — `docs/codex/visual-quality/FVQ04_RECURRING_UI_BATCH_RENDERED_PROOF_PROTOCOL.md` (partial_implementation; release proof)

### 19. Retired IA/terminology reference in LDI15

- Candidate ID: `AMB28-retired_ia_or_terminology_reference-14446548`
- Evidence type: `retired_ia_or_terminology_reference`
- Severity: `yellow`
- Recommended action: `Rewrite`
- Linear-ready: `True`
- Auto-resolved: `False`
- Reason: Active item contains retired IA, retired terminology, or unsafe language; rewrite or retire before reuse.
- Involved active paths:
  - `LDI15` — `prompts/batches/LDI15.md` (partial_implementation; release proof)

### 20. Retired IA/terminology reference in AIR_INVENTION_PRESERVATION_MATRIX

- Candidate ID: `AMB28-retired_ia_or_terminology_reference-1451153`
- Evidence type: `retired_ia_or_terminology_reference`
- Severity: `yellow`
- Recommended action: `Rewrite`
- Linear-ready: `True`
- Auto-resolved: `False`
- Reason: Active item contains retired IA, retired terminology, or unsafe language; rewrite or retire before reuse.
- Involved active paths:
  - `AIR_INVENTION_PRESERVATION_MATRIX` — `docs/codex/AIR_INVENTION_PRESERVATION_MATRIX.md` (partial_implementation; release proof)

### 21. Retired IA/terminology reference in AOS06_Goal_Path_Kernel_Goal_Compiler_Prompt

- Candidate ID: `AMB28-retired_ia_or_terminology_reference-14743350`
- Evidence type: `retired_ia_or_terminology_reference`
- Severity: `yellow`
- Recommended action: `Rewrite`
- Linear-ready: `True`
- Auto-resolved: `False`
- Reason: Active item contains retired IA, retired terminology, or unsafe language; rewrite or retire before reuse.
- Involved active paths:
  - `AOS06_Goal_Path_Kernel_Goal_Compiler_Prompt` — `docs/codex/batches/AOS06_Goal_Path_Kernel_Goal_Compiler_Prompt.md` (partial_implementation; release proof)

### 22. Retired IA/terminology reference in SI01_SI18_SIGNATURE_INTERFACE_IMPLEMENTATION_TRAIN

- Candidate ID: `AMB28-retired_ia_or_terminology_reference-14785820`
- Evidence type: `retired_ia_or_terminology_reference`
- Severity: `yellow`
- Recommended action: `Rewrite`
- Linear-ready: `True`
- Auto-resolved: `False`
- Reason: Active item contains retired IA, retired terminology, or unsafe language; rewrite or retire before reuse.
- Involved active paths:
  - `SI01_SI18_SIGNATURE_INTERFACE_IMPLEMENTATION_TRAIN` — `docs/codex/batch-trains/SI01_SI18_SIGNATURE_INTERFACE_IMPLEMENTATION_TRAIN.md` (partial_implementation; audit)

### 23. Retired IA/terminology reference in CODEX_BUILD_SHERIFF_PROTOCOL

- Candidate ID: `AMB28-retired_ia_or_terminology_reference-15255097`
- Evidence type: `retired_ia_or_terminology_reference`
- Severity: `yellow`
- Recommended action: `Rewrite`
- Linear-ready: `True`
- Auto-resolved: `False`
- Reason: Active item contains retired IA, retired terminology, or unsafe language; rewrite or retire before reuse.
- Involved active paths:
  - `CODEX_BUILD_SHERIFF_PROTOCOL` — `docs/codex/CODEX_BUILD_SHERIFF_PROTOCOL.md` (unknown; tests)

### 24. Retired IA/terminology reference in HISTORICAL_BASELINE_GLOBAL_TRAIN_MANIFEST

- Candidate ID: `AMB28-retired_ia_or_terminology_reference-15317063`
- Evidence type: `retired_ia_or_terminology_reference`
- Severity: `yellow`
- Recommended action: `Rewrite`
- Linear-ready: `True`
- Auto-resolved: `False`
- Reason: Active item contains retired IA, retired terminology, or unsafe language; rewrite or retire before reuse.
- Involved active paths:
  - `HISTORICAL_BASELINE_GLOBAL_TRAIN_MANIFEST` — `docs/codex/HISTORICAL_BASELINE_GLOBAL_TRAIN_MANIFEST.json` (unknown; release proof)

### 25. Retired IA/terminology reference in EB06_Capture_Receipts_Undo_And_Reclassification_Prompt

- Candidate ID: `AMB28-retired_ia_or_terminology_reference-15389632`
- Evidence type: `retired_ia_or_terminology_reference`
- Severity: `yellow`
- Recommended action: `Rewrite`
- Linear-ready: `True`
- Auto-resolved: `False`
- Reason: Active item contains retired IA, retired terminology, or unsafe language; rewrite or retire before reuse.
- Involved active paths:
  - `EB06_Capture_Receipts_Undo_And_Reclassification_Prompt` — `docs/codex/batches/EB06_Capture_Receipts_Undo_And_Reclassification_Prompt.md` (partial_implementation; release proof)

### 26. Retired IA/terminology reference in AQOS_AUTONOMOUS_QUALITY_CONTINUATION_PROMPT

- Candidate ID: `AMB28-retired_ia_or_terminology_reference-15423179`
- Evidence type: `retired_ia_or_terminology_reference`
- Severity: `yellow`
- Recommended action: `Rewrite`
- Linear-ready: `True`
- Auto-resolved: `False`
- Reason: Active item contains retired IA, retired terminology, or unsafe language; rewrite or retire before reuse.
- Involved active paths:
  - `AQOS_AUTONOMOUS_QUALITY_CONTINUATION_PROMPT` — `docs/codex/batches/AQOS_AUTONOMOUS_QUALITY_CONTINUATION_PROMPT.md` (partial_implementation; release proof)

### 27. Retired IA/terminology reference in AMB-CODEX-OS-LAUNCH-BELIEVABILITY-GATE

- Candidate ID: `AMB28-retired_ia_or_terminology_reference-15850920`
- Evidence type: `retired_ia_or_terminology_reference`
- Severity: `yellow`
- Recommended action: `Rewrite`
- Linear-ready: `True`
- Auto-resolved: `False`
- Reason: Active item contains retired IA, retired terminology, or unsafe language; rewrite or retire before reuse.
- Involved active paths:
  - `AMB-CODEX-OS-LAUNCH-BELIEVABILITY-GATE` — `docs/codex/os/AMB-CODEX-OS-LAUNCH-BELIEVABILITY-GATE.md` (partial_implementation; source-only)

### 28. Retired IA/terminology reference in PFC33

- Candidate ID: `AMB28-retired_ia_or_terminology_reference-16124842`
- Evidence type: `retired_ia_or_terminology_reference`
- Severity: `yellow`
- Recommended action: `Rewrite`
- Linear-ready: `True`
- Auto-resolved: `False`
- Reason: Active item contains retired IA, retired terminology, or unsafe language; rewrite or retire before reuse.
- Involved active paths:
  - `PFC33` — `prompts/batches/PFC33.md` (partial_implementation; release proof)

### 29. Retired IA/terminology reference in frontend-gap-backlog

- Candidate ID: `AMB28-retired_ia_or_terminology_reference-1720251`
- Evidence type: `retired_ia_or_terminology_reference`
- Severity: `yellow`
- Recommended action: `Rewrite`
- Linear-ready: `True`
- Auto-resolved: `False`
- Reason: Active item contains retired IA, retired terminology, or unsafe language; rewrite or retire before reuse.
- Involved active paths:
  - `frontend-gap-backlog` — `docs/codex/frontend-gap-backlog.md` (partial_implementation; release proof)

### 30. Retired IA/terminology reference in MOAT_RUNTIME_BATCH_OVERLAY

- Candidate ID: `AMB28-retired_ia_or_terminology_reference-17287681`
- Evidence type: `retired_ia_or_terminology_reference`
- Severity: `yellow`
- Recommended action: `Rewrite`
- Linear-ready: `True`
- Auto-resolved: `False`
- Reason: Active item contains retired IA, retired terminology, or unsafe language; rewrite or retire before reuse.
- Involved active paths:
  - `MOAT_RUNTIME_BATCH_OVERLAY` — `docs/codex/MOAT_RUNTIME_BATCH_OVERLAY.json` (partial_implementation; release proof)

### 31. Retired IA/terminology reference in SA23

- Candidate ID: `AMB28-retired_ia_or_terminology_reference-17354246`
- Evidence type: `retired_ia_or_terminology_reference`
- Severity: `yellow`
- Recommended action: `Rewrite`
- Linear-ready: `True`
- Auto-resolved: `False`
- Reason: Active item contains retired IA, retired terminology, or unsafe language; rewrite or retire before reuse.
- Involved active paths:
  - `SA23` — `prompts/batches/SA23.md` (partial_implementation; release proof)

### 32. Retired IA/terminology reference in AQOS_REPAIR_BATCH_GENERATOR_PROTOCOL

- Candidate ID: `AMB28-retired_ia_or_terminology_reference-17517491`
- Evidence type: `retired_ia_or_terminology_reference`
- Severity: `yellow`
- Recommended action: `Rewrite`
- Linear-ready: `True`
- Auto-resolved: `False`
- Reason: Active item contains retired IA, retired terminology, or unsafe language; rewrite or retire before reuse.
- Involved active paths:
  - `AQOS_REPAIR_BATCH_GENERATOR_PROTOCOL` — `docs/codex/quality/AQOS_REPAIR_BATCH_GENERATOR_PROTOCOL.md` (partial_implementation; screenshot)

### 33. Retired IA/terminology reference in AOS02_Life_Graph_Event_Log_Foundation_Prompt

- Candidate ID: `AMB28-retired_ia_or_terminology_reference-17697501`
- Evidence type: `retired_ia_or_terminology_reference`
- Severity: `yellow`
- Recommended action: `Rewrite`
- Linear-ready: `True`
- Auto-resolved: `False`
- Reason: Active item contains retired IA, retired terminology, or unsafe language; rewrite or retire before reuse.
- Involved active paths:
  - `AOS02_Life_Graph_Event_Log_Foundation_Prompt` — `docs/codex/batches/AOS02_Life_Graph_Event_Log_Foundation_Prompt.md` (partial_implementation; release proof)

### 34. Retired IA/terminology reference in EB03_Universal_Capture_Composer_And_Routing_Prompt

- Candidate ID: `AMB28-retired_ia_or_terminology_reference-17830876`
- Evidence type: `retired_ia_or_terminology_reference`
- Severity: `yellow`
- Recommended action: `Rewrite`
- Linear-ready: `True`
- Auto-resolved: `False`
- Reason: Active item contains retired IA, retired terminology, or unsafe language; rewrite or retire before reuse.
- Involved active paths:
  - `EB03_Universal_Capture_Composer_And_Routing_Prompt` — `docs/codex/batches/EB03_Universal_Capture_Composer_And_Routing_Prompt.md` (partial_implementation; release proof)

### 35. Retired IA/terminology reference in FRONTEND_AUTHORITY_GLOBAL_TRAIN_HOOK

- Candidate ID: `AMB28-retired_ia_or_terminology_reference-17858973`
- Evidence type: `retired_ia_or_terminology_reference`
- Severity: `yellow`
- Recommended action: `Rewrite`
- Linear-ready: `True`
- Auto-resolved: `False`
- Reason: Active item contains retired IA, retired terminology, or unsafe language; rewrite or retire before reuse.
- Involved active paths:
  - `FRONTEND_AUTHORITY_GLOBAL_TRAIN_HOOK` — `docs/codex/FRONTEND_AUTHORITY_GLOBAL_TRAIN_HOOK.md` (unknown; release proof)

### 36. Retired IA/terminology reference in PD01_PD18_PRODUCT_DEPTH_TRAIN

- Candidate ID: `AMB28-retired_ia_or_terminology_reference-17941627`
- Evidence type: `retired_ia_or_terminology_reference`
- Severity: `yellow`
- Recommended action: `Rewrite`
- Linear-ready: `True`
- Auto-resolved: `False`
- Reason: Active item contains retired IA, retired terminology, or unsafe language; rewrite or retire before reuse.
- Involved active paths:
  - `PD01_PD18_PRODUCT_DEPTH_TRAIN` — `docs/codex/batch-trains/PD01_PD18_PRODUCT_DEPTH_TRAIN.md` (partial_implementation; release proof)

### 37. Retired IA/terminology reference in EB17_Undo_Correction_Audit_Trail_And_Export_Prompt

- Candidate ID: `AMB28-retired_ia_or_terminology_reference-18063189`
- Evidence type: `retired_ia_or_terminology_reference`
- Severity: `yellow`
- Recommended action: `Rewrite`
- Linear-ready: `True`
- Auto-resolved: `False`
- Reason: Active item contains retired IA, retired terminology, or unsafe language; rewrite or retire before reuse.
- Involved active paths:
  - `EB17_Undo_Correction_Audit_Trail_And_Export_Prompt` — `docs/codex/batches/EB17_Undo_Correction_Audit_Trail_And_Export_Prompt.md` (partial_implementation; release proof)

### 38. Retired IA/terminology reference in SIGNATURE_INTERFACE_SWIFTUI_ARCHITECTURE_MAP

- Candidate ID: `AMB28-retired_ia_or_terminology_reference-18589614`
- Evidence type: `retired_ia_or_terminology_reference`
- Severity: `yellow`
- Recommended action: `Rewrite`
- Linear-ready: `True`
- Auto-resolved: `False`
- Reason: Active item contains retired IA, retired terminology, or unsafe language; rewrite or retire before reuse.
- Involved active paths:
  - `SIGNATURE_INTERFACE_SWIFTUI_ARCHITECTURE_MAP` — `docs/codex/SIGNATURE_INTERFACE_SWIFTUI_ARCHITECTURE_MAP.md` (partial_implementation; release proof)

### 39. Retired IA/terminology reference in SOURCE_ATLAS_UI_OBJECT_LANGUAGE

- Candidate ID: `AMB28-retired_ia_or_terminology_reference-18863585`
- Evidence type: `retired_ia_or_terminology_reference`
- Severity: `yellow`
- Recommended action: `Rewrite`
- Linear-ready: `True`
- Auto-resolved: `False`
- Reason: Active item contains retired IA, retired terminology, or unsafe language; rewrite or retire before reuse.
- Involved active paths:
  - `SOURCE_ATLAS_UI_OBJECT_LANGUAGE` — `docs/codex/SOURCE_ATLAS_UI_OBJECT_LANGUAGE.md` (partial_implementation; source-only)

### 40. Retired IA/terminology reference in FVQ02_TOP_LEVEL_SURFACE_VISUAL_SWEEP

- Candidate ID: `AMB28-retired_ia_or_terminology_reference-18986139`
- Evidence type: `retired_ia_or_terminology_reference`
- Severity: `yellow`
- Recommended action: `Rewrite`
- Linear-ready: `True`
- Auto-resolved: `False`
- Reason: Active item contains retired IA, retired terminology, or unsafe language; rewrite or retire before reuse.
- Involved active paths:
  - `FVQ02_TOP_LEVEL_SURFACE_VISUAL_SWEEP` — `docs/codex/visual-quality/FVQ02_TOP_LEVEL_SURFACE_VISUAL_SWEEP.md` (unknown; release proof)

### 41. Retired IA/terminology reference in TIME-PRESSURE-LEDGER-VISUAL-01

- Candidate ID: `AMB28-retired_ia_or_terminology_reference-18992307`
- Evidence type: `retired_ia_or_terminology_reference`
- Severity: `yellow`
- Recommended action: `Rewrite`
- Linear-ready: `True`
- Auto-resolved: `False`
- Reason: Active item contains retired IA, retired terminology, or unsafe language; rewrite or retire before reuse.
- Involved active paths:
  - `TIME-PRESSURE-LEDGER-VISUAL-01` — `prompts/batches/TIME-PRESSURE-LEDGER-VISUAL-01.md` (partial_implementation; source-only)

### 42. Retired IA/terminology reference in SA07

- Candidate ID: `AMB28-retired_ia_or_terminology_reference-19479524`
- Evidence type: `retired_ia_or_terminology_reference`
- Severity: `yellow`
- Recommended action: `Rewrite`
- Linear-ready: `True`
- Auto-resolved: `False`
- Reason: Active item contains retired IA, retired terminology, or unsafe language; rewrite or retire before reuse.
- Involved active paths:
  - `SA07` — `prompts/batches/SA07.md` (partial_implementation; release proof)

### 43. Retired IA/terminology reference in EB40_Ambitions_4_0_External_Brain_Closeout_Prompt

- Candidate ID: `AMB28-retired_ia_or_terminology_reference-19822861`
- Evidence type: `retired_ia_or_terminology_reference`
- Severity: `yellow`
- Recommended action: `Rewrite`
- Linear-ready: `True`
- Auto-resolved: `False`
- Reason: Active item contains retired IA, retired terminology, or unsafe language; rewrite or retire before reuse.
- Involved active paths:
  - `EB40_Ambitions_4_0_External_Brain_Closeout_Prompt` — `docs/codex/batches/EB40_Ambitions_4_0_External_Brain_Closeout_Prompt.md` (partial_implementation; release proof)

### 44. Retired IA/terminology reference in GLOBAL-VISUAL-CANON-MOAT-INSTALL-TRAIN-01

- Candidate ID: `AMB28-retired_ia_or_terminology_reference-19825099`
- Evidence type: `retired_ia_or_terminology_reference`
- Severity: `yellow`
- Recommended action: `Rewrite`
- Linear-ready: `True`
- Auto-resolved: `False`
- Reason: Active item contains retired IA, retired terminology, or unsafe language; rewrite or retire before reuse.
- Involved active paths:
  - `GLOBAL-VISUAL-CANON-MOAT-INSTALL-TRAIN-01` — `prompts/batches/GLOBAL-VISUAL-CANON-MOAT-INSTALL-TRAIN-01.md` (partial_implementation; release proof)

### 45. Retired IA/terminology reference in PD05_Goals_Mission_Control_Detail_Architecture_Prompt

- Candidate ID: `AMB28-retired_ia_or_terminology_reference-19876108`
- Evidence type: `retired_ia_or_terminology_reference`
- Severity: `yellow`
- Recommended action: `Rewrite`
- Linear-ready: `True`
- Auto-resolved: `False`
- Reason: Active item contains retired IA, retired terminology, or unsafe language; rewrite or retire before reuse.
- Involved active paths:
  - `PD05_Goals_Mission_Control_Detail_Architecture_Prompt` — `docs/codex/batches/PD05_Goals_Mission_Control_Detail_Architecture_Prompt.md` (partial_implementation; release proof)

### 46. Retired IA/terminology reference in UI-STUDIO-10-FAANG-LEVEL-UI-RED-TEAM

- Candidate ID: `AMB28-retired_ia_or_terminology_reference-20099088`
- Evidence type: `retired_ia_or_terminology_reference`
- Severity: `yellow`
- Recommended action: `Rewrite`
- Linear-ready: `True`
- Auto-resolved: `False`
- Reason: Active item contains retired IA, retired terminology, or unsafe language; rewrite or retire before reuse.
- Involved active paths:
  - `UI-STUDIO-10-FAANG-LEVEL-UI-RED-TEAM` — `prompts/batches/ui-flagship/UI-STUDIO-10-FAANG-LEVEL-UI-RED-TEAM.md` (partial_implementation; audit)

### 47. Retired IA/terminology reference in GLOBAL_BATCH_REPAIR_LOOP_PROTOCOL

- Candidate ID: `AMB28-retired_ia_or_terminology_reference-20311311`
- Evidence type: `retired_ia_or_terminology_reference`
- Severity: `yellow`
- Recommended action: `Rewrite`
- Linear-ready: `True`
- Auto-resolved: `False`
- Reason: Active item contains retired IA, retired terminology, or unsafe language; rewrite or retire before reuse.
- Involved active paths:
  - `GLOBAL_BATCH_REPAIR_LOOP_PROTOCOL` — `docs/codex/GLOBAL_BATCH_REPAIR_LOOP_PROTOCOL.md` (partial_implementation; audit)

### 48. Retired IA/terminology reference in PK22

- Candidate ID: `AMB28-retired_ia_or_terminology_reference-20344101`
- Evidence type: `retired_ia_or_terminology_reference`
- Severity: `yellow`
- Recommended action: `Rewrite`
- Linear-ready: `True`
- Auto-resolved: `False`
- Reason: Active item contains retired IA, retired terminology, or unsafe language; rewrite or retire before reuse.
- Involved active paths:
  - `PK22` — `prompts/batches/PK22.md` (partial_implementation; release proof)

### 49. Retired IA/terminology reference in FAANG_FRONTEND_IMPLEMENTATION_TEAM_OPERATING_SYSTEM

- Candidate ID: `AMB28-retired_ia_or_terminology_reference-20387641`
- Evidence type: `retired_ia_or_terminology_reference`
- Severity: `yellow`
- Recommended action: `Rewrite`
- Linear-ready: `True`
- Auto-resolved: `False`
- Reason: Active item contains retired IA, retired terminology, or unsafe language; rewrite or retire before reuse.
- Involved active paths:
  - `FAANG_FRONTEND_IMPLEMENTATION_TEAM_OPERATING_SYSTEM` — `docs/codex/frontend-implementation/FAANG_FRONTEND_IMPLEMENTATION_TEAM_OPERATING_SYSTEM.md` (partial_implementation; tests)

### 50. Retired IA/terminology reference in PX11_Onboarding_Setup_Experience_Prompt

- Candidate ID: `AMB28-retired_ia_or_terminology_reference-20662630`
- Evidence type: `retired_ia_or_terminology_reference`
- Severity: `yellow`
- Recommended action: `Rewrite`
- Linear-ready: `True`
- Auto-resolved: `False`
- Reason: Active item contains retired IA, retired terminology, or unsafe language; rewrite or retire before reuse.
- Involved active paths:
  - `PX11_Onboarding_Setup_Experience_Prompt` — `docs/codex/batches/PX11_Onboarding_Setup_Experience_Prompt.md` (partial_implementation; release proof)

### 51. Retired IA/terminology reference in HPS_CODEX_OS_UPGRADE_MAP

- Candidate ID: `AMB28-retired_ia_or_terminology_reference-20696732`
- Evidence type: `retired_ia_or_terminology_reference`
- Severity: `yellow`
- Recommended action: `Rewrite`
- Linear-ready: `True`
- Auto-resolved: `False`
- Reason: Active item contains retired IA, retired terminology, or unsafe language; rewrite or retire before reuse.
- Involved active paths:
  - `HPS_CODEX_OS_UPGRADE_MAP` — `docs/codex/HPS_CODEX_OS_UPGRADE_MAP.md` (partial_implementation; release proof)

### 52. Retired IA/terminology reference in FLAGSHIP_COMPLETION_OBJECT_SCORECARD

- Candidate ID: `AMB28-retired_ia_or_terminology_reference-2115491`
- Evidence type: `retired_ia_or_terminology_reference`
- Severity: `yellow`
- Recommended action: `Rewrite`
- Linear-ready: `True`
- Auto-resolved: `False`
- Reason: Active item contains retired IA, retired terminology, or unsafe language; rewrite or retire before reuse.
- Involved active paths:
  - `FLAGSHIP_COMPLETION_OBJECT_SCORECARD` — `docs/codex/FLAGSHIP_COMPLETION_OBJECT_SCORECARD.md` (partial_implementation; source-only)

### 53. Retired IA/terminology reference in FE-04-PRIMITIVES

- Candidate ID: `AMB28-retired_ia_or_terminology_reference-21647288`
- Evidence type: `retired_ia_or_terminology_reference`
- Severity: `yellow`
- Recommended action: `Rewrite`
- Linear-ready: `True`
- Auto-resolved: `False`
- Reason: Active item contains retired IA, retired terminology, or unsafe language; rewrite or retire before reuse.
- Involved active paths:
  - `FE-04-PRIMITIVES` — `prompts/batches/amb-fe-be/FE-04-PRIMITIVES.md` (partial_implementation; screenshot)

### 54. Retired IA/terminology reference in GLOBAL_FUTURE_BATCH_GATE_MATRIX

- Candidate ID: `AMB28-retired_ia_or_terminology_reference-21855725`
- Evidence type: `retired_ia_or_terminology_reference`
- Severity: `yellow`
- Recommended action: `Rewrite`
- Linear-ready: `True`
- Auto-resolved: `False`
- Reason: Active item contains retired IA, retired terminology, or unsafe language; rewrite or retire before reuse.
- Involved active paths:
  - `GLOBAL_FUTURE_BATCH_GATE_MATRIX` — `docs/codex/GLOBAL_FUTURE_BATCH_GATE_MATRIX.md` (partial_implementation; release proof)

### 55. Retired IA/terminology reference in UI-STUDIO-04-START-HERE-COMMAND-OBJECT

- Candidate ID: `AMB28-retired_ia_or_terminology_reference-21876125`
- Evidence type: `retired_ia_or_terminology_reference`
- Severity: `yellow`
- Recommended action: `Rewrite`
- Linear-ready: `True`
- Auto-resolved: `False`
- Reason: Active item contains retired IA, retired terminology, or unsafe language; rewrite or retire before reuse.
- Involved active paths:
  - `UI-STUDIO-04-START-HERE-COMMAND-OBJECT` — `prompts/batches/ui-flagship/UI-STUDIO-04-START-HERE-COMMAND-OBJECT.md` (partial_implementation; audit)

### 56. Retired IA/terminology reference in AMB-LINEAR-TEMPLATE-MANIFEST

- Candidate ID: `AMB28-retired_ia_or_terminology_reference-22311333`
- Evidence type: `retired_ia_or_terminology_reference`
- Severity: `yellow`
- Recommended action: `Rewrite`
- Linear-ready: `True`
- Auto-resolved: `False`
- Reason: Active item contains retired IA, retired terminology, or unsafe language; rewrite or retire before reuse.
- Involved active paths:
  - `AMB-LINEAR-TEMPLATE-MANIFEST` — `docs/codex/linear-templates/AMB-LINEAR-TEMPLATE-MANIFEST.yml` (partial_implementation; release proof)

### 57. Retired IA/terminology reference in VISUAL_CANON_MOAT_IMPLEMENTATION_OVERLAY

- Candidate ID: `AMB28-retired_ia_or_terminology_reference-22685702`
- Evidence type: `retired_ia_or_terminology_reference`
- Severity: `yellow`
- Recommended action: `Rewrite`
- Linear-ready: `True`
- Auto-resolved: `False`
- Reason: Active item contains retired IA, retired terminology, or unsafe language; rewrite or retire before reuse.
- Involved active paths:
  - `VISUAL_CANON_MOAT_IMPLEMENTATION_OVERLAY` — `docs/codex/VISUAL_CANON_MOAT_IMPLEMENTATION_OVERLAY.md` (partial_implementation; release proof)

### 58. Retired IA/terminology reference in EB14_Trust_Center_And_Data_Map_Prompt

- Candidate ID: `AMB28-retired_ia_or_terminology_reference-22760610`
- Evidence type: `retired_ia_or_terminology_reference`
- Severity: `yellow`
- Recommended action: `Rewrite`
- Linear-ready: `True`
- Auto-resolved: `False`
- Reason: Active item contains retired IA, retired terminology, or unsafe language; rewrite or retire before reuse.
- Involved active paths:
  - `EB14_Trust_Center_And_Data_Map_Prompt` — `docs/codex/batches/EB14_Trust_Center_And_Data_Map_Prompt.md` (partial_implementation; release proof)

### 59. Retired IA/terminology reference in SOURCE_ATLAS_COMPOSITION_GOAL_PROJECTION_MODEL

- Candidate ID: `AMB28-retired_ia_or_terminology_reference-23098264`
- Evidence type: `retired_ia_or_terminology_reference`
- Severity: `yellow`
- Recommended action: `Rewrite`
- Linear-ready: `True`
- Auto-resolved: `False`
- Reason: Active item contains retired IA, retired terminology, or unsafe language; rewrite or retire before reuse.
- Involved active paths:
  - `SOURCE_ATLAS_COMPOSITION_GOAL_PROJECTION_MODEL` — `docs/codex/SOURCE_ATLAS_COMPOSITION_GOAL_PROJECTION_MODEL.md` (unknown; release proof)

### 60. Retired IA/terminology reference in AMBITIONSOS_SURFACE_ENCAPSULATION_MATRIX

- Candidate ID: `AMB28-retired_ia_or_terminology_reference-23251452`
- Evidence type: `retired_ia_or_terminology_reference`
- Severity: `yellow`
- Recommended action: `Rewrite`
- Linear-ready: `True`
- Auto-resolved: `False`
- Reason: Active item contains retired IA, retired terminology, or unsafe language; rewrite or retire before reuse.
- Involved active paths:
  - `AMBITIONSOS_SURFACE_ENCAPSULATION_MATRIX` — `docs/codex/AMBITIONSOS_SURFACE_ENCAPSULATION_MATRIX.md` (partial_implementation; audit)

### 61. Retired IA/terminology reference in AOS22_Longevity_Kernel_Archive_Aging_Prompt

- Candidate ID: `AMB28-retired_ia_or_terminology_reference-23409271`
- Evidence type: `retired_ia_or_terminology_reference`
- Severity: `yellow`
- Recommended action: `Rewrite`
- Linear-ready: `True`
- Auto-resolved: `False`
- Reason: Active item contains retired IA, retired terminology, or unsafe language; rewrite or retire before reuse.
- Involved active paths:
  - `AOS22_Longevity_Kernel_Archive_Aging_Prompt` — `docs/codex/batches/AOS22_Longevity_Kernel_Archive_Aging_Prompt.md` (partial_implementation; release proof)

### 62. Retired IA/terminology reference in LDI18

- Candidate ID: `AMB28-retired_ia_or_terminology_reference-23569999`
- Evidence type: `retired_ia_or_terminology_reference`
- Severity: `yellow`
- Recommended action: `Rewrite`
- Linear-ready: `True`
- Auto-resolved: `False`
- Reason: Active item contains retired IA, retired terminology, or unsafe language; rewrite or retire before reuse.
- Involved active paths:
  - `LDI18` — `prompts/batches/LDI18.md` (partial_implementation; release proof)

### 63. Retired IA/terminology reference in FRONTEND_TOP_LEVEL_SURFACE_COMPOSITION_GATE

- Candidate ID: `AMB28-retired_ia_or_terminology_reference-23736633`
- Evidence type: `retired_ia_or_terminology_reference`
- Severity: `yellow`
- Recommended action: `Rewrite`
- Linear-ready: `True`
- Auto-resolved: `False`
- Reason: Active item contains retired IA, retired terminology, or unsafe language; rewrite or retire before reuse.
- Involved active paths:
  - `FRONTEND_TOP_LEVEL_SURFACE_COMPOSITION_GATE` — `docs/codex/FRONTEND_TOP_LEVEL_SURFACE_COMPOSITION_GATE.md` (unknown; screenshot)

### 64. Retired IA/terminology reference in EB39_External_Brain_Handoff_And_RC_Readiness_Implications_Prompt

- Candidate ID: `AMB28-retired_ia_or_terminology_reference-23936215`
- Evidence type: `retired_ia_or_terminology_reference`
- Severity: `yellow`
- Recommended action: `Rewrite`
- Linear-ready: `True`
- Auto-resolved: `False`
- Reason: Active item contains retired IA, retired terminology, or unsafe language; rewrite or retire before reuse.
- Involved active paths:
  - `EB39_External_Brain_Handoff_And_RC_Readiness_Implications_Prompt` — `docs/codex/batches/EB39_External_Brain_Handoff_And_RC_Readiness_Implications_Prompt.md` (partial_implementation; release proof)

### 65. Retired IA/terminology reference in AOS24

- Candidate ID: `AMB28-retired_ia_or_terminology_reference-24061201`
- Evidence type: `retired_ia_or_terminology_reference`
- Severity: `yellow`
- Recommended action: `Rewrite`
- Linear-ready: `True`
- Auto-resolved: `False`
- Reason: Active item contains retired IA, retired terminology, or unsafe language; rewrite or retire before reuse.
- Involved active paths:
  - `AOS24` — `prompts/batches/AOS24.md` (partial_implementation; release proof)

### 66. Retired IA/terminology reference in CODEX_QUALITY_SYSTEM_SCRIPT_MAP

- Candidate ID: `AMB28-retired_ia_or_terminology_reference-24318114`
- Evidence type: `retired_ia_or_terminology_reference`
- Severity: `yellow`
- Recommended action: `Rewrite`
- Linear-ready: `True`
- Auto-resolved: `False`
- Reason: Active item contains retired IA, retired terminology, or unsafe language; rewrite or retire before reuse.
- Involved active paths:
  - `CODEX_QUALITY_SYSTEM_SCRIPT_MAP` — `docs/codex/CODEX_QUALITY_SYSTEM_SCRIPT_MAP.md` (unknown; release proof)

### 67. Retired IA/terminology reference in PD06_Goal_Lifecycle_And_Path_Visualization_Prompt

- Candidate ID: `AMB28-retired_ia_or_terminology_reference-24460816`
- Evidence type: `retired_ia_or_terminology_reference`
- Severity: `yellow`
- Recommended action: `Rewrite`
- Linear-ready: `True`
- Auto-resolved: `False`
- Reason: Active item contains retired IA, retired terminology, or unsafe language; rewrite or retire before reuse.
- Involved active paths:
  - `PD06_Goal_Lifecycle_And_Path_Visualization_Prompt` — `docs/codex/batches/PD06_Goal_Lifecycle_And_Path_Visualization_Prompt.md` (partial_implementation; release proof)

### 68. Retired IA/terminology reference in PX07_Action_Closure_Recovery_Experience_Prompt

- Candidate ID: `AMB28-retired_ia_or_terminology_reference-24630885`
- Evidence type: `retired_ia_or_terminology_reference`
- Severity: `yellow`
- Recommended action: `Rewrite`
- Linear-ready: `True`
- Auto-resolved: `False`
- Reason: Active item contains retired IA, retired terminology, or unsafe language; rewrite or retire before reuse.
- Involved active paths:
  - `PX07_Action_Closure_Recovery_Experience_Prompt` — `docs/codex/batches/PX07_Action_Closure_Recovery_Experience_Prompt.md` (partial_implementation; release proof)

### 69. Retired IA/terminology reference in RHC05

- Candidate ID: `AMB28-retired_ia_or_terminology_reference-24805023`
- Evidence type: `retired_ia_or_terminology_reference`
- Severity: `yellow`
- Recommended action: `Rewrite`
- Linear-ready: `True`
- Auto-resolved: `False`
- Reason: Active item contains retired IA, retired terminology, or unsafe language; rewrite or retire before reuse.
- Involved active paths:
  - `RHC05` — `prompts/batches/RHC05.md` (partial_implementation; release proof)

### 70. Retired IA/terminology reference in PX06_You_Personal_System_Center_Prompt

- Candidate ID: `AMB28-retired_ia_or_terminology_reference-24945718`
- Evidence type: `retired_ia_or_terminology_reference`
- Severity: `yellow`
- Recommended action: `Rewrite`
- Linear-ready: `True`
- Auto-resolved: `False`
- Reason: Active item contains retired IA, retired terminology, or unsafe language; rewrite or retire before reuse.
- Involved active paths:
  - `PX06_You_Personal_System_Center_Prompt` — `docs/codex/batches/PX06_You_Personal_System_Center_Prompt.md` (partial_implementation; release proof)

### 71. Retired IA/terminology reference in TRAIN_08_CAPTURE_ATMOSPHERE_COMPOSER_FINAL_OBJECT

- Candidate ID: `AMB28-retired_ia_or_terminology_reference-2500915`
- Evidence type: `retired_ia_or_terminology_reference`
- Severity: `yellow`
- Recommended action: `Rewrite`
- Linear-ready: `True`
- Auto-resolved: `False`
- Reason: Active item contains retired IA, retired terminology, or unsafe language; rewrite or retire before reuse.
- Involved active paths:
  - `TRAIN_08_CAPTURE_ATMOSPHERE_COMPOSER_FINAL_OBJECT` — `prompts/trains/ios26-flagship/TRAIN_08_CAPTURE_ATMOSPHERE_COMPOSER_FINAL_OBJECT.md` (partial_implementation; source-only)

### 72. Retired IA/terminology reference in AMB-POST23-04-NEXT-TRAIN-RECOMMENDATION

- Candidate ID: `AMB28-retired_ia_or_terminology_reference-25261733`
- Evidence type: `retired_ia_or_terminology_reference`
- Severity: `yellow`
- Recommended action: `Rewrite`
- Linear-ready: `True`
- Auto-resolved: `False`
- Reason: Active item contains retired IA, retired terminology, or unsafe language; rewrite or retire before reuse.
- Involved active paths:
  - `AMB-POST23-04-NEXT-TRAIN-RECOMMENDATION` — `docs/codex/reports/AMB-POST23-04-NEXT-TRAIN-RECOMMENDATION.md` (partial_implementation; release proof)

### 73. Retired IA/terminology reference in PX14_Product_Depth_Drilldown_Architecture_Prompt

- Candidate ID: `AMB28-retired_ia_or_terminology_reference-25340882`
- Evidence type: `retired_ia_or_terminology_reference`
- Severity: `yellow`
- Recommended action: `Rewrite`
- Linear-ready: `True`
- Auto-resolved: `False`
- Reason: Active item contains retired IA, retired terminology, or unsafe language; rewrite or retire before reuse.
- Involved active paths:
  - `PX14_Product_Depth_Drilldown_Architecture_Prompt` — `docs/codex/batches/PX14_Product_Depth_Drilldown_Architecture_Prompt.md` (partial_implementation; release proof)

### 74. Retired IA/terminology reference in OS-FLAGSHIP-04-VISUAL-QA-GATE

- Candidate ID: `AMB28-retired_ia_or_terminology_reference-25472903`
- Evidence type: `retired_ia_or_terminology_reference`
- Severity: `yellow`
- Recommended action: `Rewrite`
- Linear-ready: `True`
- Auto-resolved: `False`
- Reason: Active item contains retired IA, retired terminology, or unsafe language; rewrite or retire before reuse.
- Involved active paths:
  - `OS-FLAGSHIP-04-VISUAL-QA-GATE` — `prompts/batches/OS-FLAGSHIP-04-VISUAL-QA-GATE.md` (partial_implementation; screenshot)

### 75. Retired IA/terminology reference in OBJECT_OS_PRIMITIVES

- Candidate ID: `AMB28-retired_ia_or_terminology_reference-25520122`
- Evidence type: `retired_ia_or_terminology_reference`
- Severity: `yellow`
- Recommended action: `Rewrite`
- Linear-ready: `True`
- Auto-resolved: `False`
- Reason: Active item contains retired IA, retired terminology, or unsafe language; rewrite or retire before reuse.
- Involved active paths:
  - `OBJECT_OS_PRIMITIVES` — `docs/codex/OBJECT_OS_PRIMITIVES.md` (partial_implementation; source-only)

### 76. Retired IA/terminology reference in MOAT-GOAL-REALITY-CAPTURE-BRIDGE-04

- Candidate ID: `AMB28-retired_ia_or_terminology_reference-25595355`
- Evidence type: `retired_ia_or_terminology_reference`
- Severity: `yellow`
- Recommended action: `Rewrite`
- Linear-ready: `True`
- Auto-resolved: `False`
- Reason: Active item contains retired IA, retired terminology, or unsafe language; rewrite or retire before reuse.
- Involved active paths:
  - `MOAT-GOAL-REALITY-CAPTURE-BRIDGE-04` — `prompts/batches/MOAT-GOAL-REALITY-CAPTURE-BRIDGE-04.md` (partial_implementation; tests)

### 77. Retired IA/terminology reference in AOS27_AmbitionsOS_App_Store_Claim_Truth_Prompt

- Candidate ID: `AMB28-retired_ia_or_terminology_reference-26368427`
- Evidence type: `retired_ia_or_terminology_reference`
- Severity: `yellow`
- Recommended action: `Rewrite`
- Linear-ready: `True`
- Auto-resolved: `False`
- Reason: Active item contains retired IA, retired terminology, or unsafe language; rewrite or retire before reuse.
- Involved active paths:
  - `AOS27_AmbitionsOS_App_Store_Claim_Truth_Prompt` — `docs/codex/batches/AOS27_AmbitionsOS_App_Store_Claim_Truth_Prompt.md` (partial_implementation; release proof)

### 78. Retired IA/terminology reference in AMB-CHATGPT-UI-PROMPT-TEMPLATE

- Candidate ID: `AMB28-retired_ia_or_terminology_reference-26962063`
- Evidence type: `retired_ia_or_terminology_reference`
- Severity: `yellow`
- Recommended action: `Rewrite`
- Linear-ready: `True`
- Auto-resolved: `False`
- Reason: Active item contains retired IA, retired terminology, or unsafe language; rewrite or retire before reuse.
- Involved active paths:
  - `AMB-CHATGPT-UI-PROMPT-TEMPLATE` — `docs/codex/chatgpt/AMB-CHATGPT-UI-PROMPT-TEMPLATE.md` (unknown; screenshot)

### 79. Retired IA/terminology reference in AFI03_Flagship_Object_Silhouettes

- Candidate ID: `AMB28-retired_ia_or_terminology_reference-27001896`
- Evidence type: `retired_ia_or_terminology_reference`
- Severity: `yellow`
- Recommended action: `Rewrite`
- Linear-ready: `True`
- Auto-resolved: `False`
- Reason: Active item contains retired IA, retired terminology, or unsafe language; rewrite or retire before reuse.
- Involved active paths:
  - `AFI03_Flagship_Object_Silhouettes` — `docs/codex/batches/AFI03_Flagship_Object_Silhouettes.md` (partial_implementation; screenshot)

### 80. Retired IA/terminology reference in ambitions-hybrid-runner

- Candidate ID: `AMB28-retired_ia_or_terminology_reference-27486066`
- Evidence type: `retired_ia_or_terminology_reference`
- Severity: `yellow`
- Recommended action: `Rewrite`
- Linear-ready: `True`
- Auto-resolved: `False`
- Reason: Active item contains retired IA, retired terminology, or unsafe language; rewrite or retire before reuse.
- Involved active paths:
  - `ambitions-hybrid-runner` — `docs/codex/ambitions-hybrid-runner.md` (partial_implementation; release proof)

### 81. Retired IA/terminology reference in PFC34

- Candidate ID: `AMB28-retired_ia_or_terminology_reference-27811216`
- Evidence type: `retired_ia_or_terminology_reference`
- Severity: `yellow`
- Recommended action: `Rewrite`
- Linear-ready: `True`
- Auto-resolved: `False`
- Reason: Active item contains retired IA, retired terminology, or unsafe language; rewrite or retire before reuse.
- Involved active paths:
  - `PFC34` — `prompts/batches/PFC34.md` (partial_implementation; release proof)

### 82. Retired IA/terminology reference in AMB-CODEX-OS-VISUAL-QA-GATE

- Candidate ID: `AMB28-retired_ia_or_terminology_reference-27893096`
- Evidence type: `retired_ia_or_terminology_reference`
- Severity: `yellow`
- Recommended action: `Rewrite`
- Linear-ready: `True`
- Auto-resolved: `False`
- Reason: Active item contains retired IA, retired terminology, or unsafe language; rewrite or retire before reuse.
- Involved active paths:
  - `AMB-CODEX-OS-VISUAL-QA-GATE` — `docs/codex/os/AMB-CODEX-OS-VISUAL-QA-GATE.md` (unknown; screenshot)

### 83. Retired IA/terminology reference in REPO_INTELLIGENCE_CONTROL_PLANE

- Candidate ID: `AMB28-retired_ia_or_terminology_reference-27932432`
- Evidence type: `retired_ia_or_terminology_reference`
- Severity: `yellow`
- Recommended action: `Rewrite`
- Linear-ready: `True`
- Auto-resolved: `False`
- Reason: Active item contains retired IA, retired terminology, or unsafe language; rewrite or retire before reuse.
- Involved active paths:
  - `REPO_INTELLIGENCE_CONTROL_PLANE` — `docs/codex/REPO_INTELLIGENCE_CONTROL_PLANE.md` (unknown; release proof)

### 84. Retired IA/terminology reference in PX08_Trust_Proof_Receipts_Experience_Prompt

- Candidate ID: `AMB28-retired_ia_or_terminology_reference-27951711`
- Evidence type: `retired_ia_or_terminology_reference`
- Severity: `yellow`
- Recommended action: `Rewrite`
- Linear-ready: `True`
- Auto-resolved: `False`
- Reason: Active item contains retired IA, retired terminology, or unsafe language; rewrite or retire before reuse.
- Involved active paths:
  - `PX08_Trust_Proof_Receipts_Experience_Prompt` — `docs/codex/batches/PX08_Trust_Proof_Receipts_Experience_Prompt.md` (partial_implementation; release proof)

### 85. Retired IA/terminology reference in SA25

- Candidate ID: `AMB28-retired_ia_or_terminology_reference-28129730`
- Evidence type: `retired_ia_or_terminology_reference`
- Severity: `yellow`
- Recommended action: `Rewrite`
- Linear-ready: `True`
- Auto-resolved: `False`
- Reason: Active item contains retired IA, retired terminology, or unsafe language; rewrite or retire before reuse.
- Involved active paths:
  - `SA25` — `prompts/batches/SA25.md` (partial_implementation; release proof)

### 86. Retired IA/terminology reference in GOAL_REALITY_COMPILER_BACKEND_MASTER_PLAN

- Candidate ID: `AMB28-retired_ia_or_terminology_reference-28183717`
- Evidence type: `retired_ia_or_terminology_reference`
- Severity: `yellow`
- Recommended action: `Rewrite`
- Linear-ready: `True`
- Auto-resolved: `False`
- Reason: Active item contains retired IA, retired terminology, or unsafe language; rewrite or retire before reuse.
- Involved active paths:
  - `GOAL_REALITY_COMPILER_BACKEND_MASTER_PLAN` — `docs/codex/GOAL_REALITY_COMPILER_BACKEND_MASTER_PLAN.md` (partial_implementation; tests)

### 87. Retired IA/terminology reference in BATCH_EVIDENCE_MANIFEST_SCHEMA

- Candidate ID: `AMB28-retired_ia_or_terminology_reference-28257190`
- Evidence type: `retired_ia_or_terminology_reference`
- Severity: `yellow`
- Recommended action: `Rewrite`
- Linear-ready: `True`
- Auto-resolved: `False`
- Reason: Active item contains retired IA, retired terminology, or unsafe language; rewrite or retire before reuse.
- Involved active paths:
  - `BATCH_EVIDENCE_MANIFEST_SCHEMA` — `docs/codex/BATCH_EVIDENCE_MANIFEST_SCHEMA.md` (partial_implementation; screenshot)

### 88. Retired IA/terminology reference in SA10A

- Candidate ID: `AMB28-retired_ia_or_terminology_reference-2858458`
- Evidence type: `retired_ia_or_terminology_reference`
- Severity: `yellow`
- Recommended action: `Rewrite`
- Linear-ready: `True`
- Auto-resolved: `False`
- Reason: Active item contains retired IA, retired terminology, or unsafe language; rewrite or retire before reuse.
- Involved active paths:
  - `SA10A` — `prompts/batches/SA10A.md` (partial_implementation; release proof)

### 89. Retired IA/terminology reference in AOS12_Proof_Trust_Closure_Receipts_Prompt

- Candidate ID: `AMB28-retired_ia_or_terminology_reference-28916435`
- Evidence type: `retired_ia_or_terminology_reference`
- Severity: `yellow`
- Recommended action: `Rewrite`
- Linear-ready: `True`
- Auto-resolved: `False`
- Reason: Active item contains retired IA, retired terminology, or unsafe language; rewrite or retire before reuse.
- Involved active paths:
  - `AOS12_Proof_Trust_Closure_Receipts_Prompt` — `docs/codex/batches/AOS12_Proof_Trust_Closure_Receipts_Prompt.md` (partial_implementation; release proof)

### 90. Retired IA/terminology reference in HPS_CROSS_TRAIN_INTEGRATION_MAP

- Candidate ID: `AMB28-retired_ia_or_terminology_reference-28949043`
- Evidence type: `retired_ia_or_terminology_reference`
- Severity: `yellow`
- Recommended action: `Rewrite`
- Linear-ready: `True`
- Auto-resolved: `False`
- Reason: Active item contains retired IA, retired terminology, or unsafe language; rewrite or retire before reuse.
- Involved active paths:
  - `HPS_CROSS_TRAIN_INTEGRATION_MAP` — `docs/codex/HPS_CROSS_TRAIN_INTEGRATION_MAP.md` (partial_implementation; release proof)

### 91. Retired IA/terminology reference in HBI-09

- Candidate ID: `AMB28-retired_ia_or_terminology_reference-29021562`
- Evidence type: `retired_ia_or_terminology_reference`
- Severity: `yellow`
- Recommended action: `Rewrite`
- Linear-ready: `True`
- Auto-resolved: `False`
- Reason: Active item contains retired IA, retired terminology, or unsafe language; rewrite or retire before reuse.
- Involved active paths:
  - `HBI-09` — `prompts/batches/HBI-09.md` (partial_implementation; release proof)

### 92. Retired IA/terminology reference in AMB-FLAGSHIP-UI-CODEX-STUDIO-INSTALL-01

- Candidate ID: `AMB28-retired_ia_or_terminology_reference-2920599`
- Evidence type: `retired_ia_or_terminology_reference`
- Severity: `yellow`
- Recommended action: `Rewrite`
- Linear-ready: `True`
- Auto-resolved: `False`
- Reason: Active item contains retired IA, retired terminology, or unsafe language; rewrite or retire before reuse.
- Involved active paths:
  - `AMB-FLAGSHIP-UI-CODEX-STUDIO-INSTALL-01` — `docs/codex/review-boards/AMB-FLAGSHIP-UI-CODEX-STUDIO-INSTALL-01.md` (unknown; screenshot)

### 93. Retired IA/terminology reference in AMBITIONS_SIGNATURE_LANGUAGE_SYSTEM

- Candidate ID: `AMB28-retired_ia_or_terminology_reference-29254739`
- Evidence type: `retired_ia_or_terminology_reference`
- Severity: `yellow`
- Recommended action: `Rewrite`
- Linear-ready: `True`
- Auto-resolved: `False`
- Reason: Active item contains retired IA, retired terminology, or unsafe language; rewrite or retire before reuse.
- Involved active paths:
  - `AMBITIONS_SIGNATURE_LANGUAGE_SYSTEM` — `docs/codex/AMBITIONS_SIGNATURE_LANGUAGE_SYSTEM.md` (partial_implementation; audit)

### 94. Retired IA/terminology reference in IR01_FAANG_FRONTEND_INTERFACE_RECOVERY_PROMPT

- Candidate ID: `AMB28-retired_ia_or_terminology_reference-29446782`
- Evidence type: `retired_ia_or_terminology_reference`
- Severity: `yellow`
- Recommended action: `Rewrite`
- Linear-ready: `True`
- Auto-resolved: `False`
- Reason: Active item contains retired IA, retired terminology, or unsafe language; rewrite or retire before reuse.
- Involved active paths:
  - `IR01_FAANG_FRONTEND_INTERFACE_RECOVERY_PROMPT` — `docs/codex/batches/IR01_FAANG_FRONTEND_INTERFACE_RECOVERY_PROMPT.md` (partial_implementation; release proof)

### 95. Retired IA/terminology reference in FL06_Weekly_Life_Sweep_Ritual_Prompt

- Candidate ID: `AMB28-retired_ia_or_terminology_reference-30027506`
- Evidence type: `retired_ia_or_terminology_reference`
- Severity: `yellow`
- Recommended action: `Rewrite`
- Linear-ready: `True`
- Auto-resolved: `False`
- Reason: Active item contains retired IA, retired terminology, or unsafe language; rewrite or retire before reuse.
- Involved active paths:
  - `FL06_Weekly_Life_Sweep_Ritual_Prompt` — `docs/codex/batches/FL06_Weekly_Life_Sweep_Ritual_Prompt.md` (partial_implementation; release proof)

### 96. Retired IA/terminology reference in LDI22

- Candidate ID: `AMB28-retired_ia_or_terminology_reference-30183671`
- Evidence type: `retired_ia_or_terminology_reference`
- Severity: `yellow`
- Recommended action: `Rewrite`
- Linear-ready: `True`
- Auto-resolved: `False`
- Reason: Active item contains retired IA, retired terminology, or unsafe language; rewrite or retire before reuse.
- Involved active paths:
  - `LDI22` — `prompts/batches/LDI22.md` (partial_implementation; release proof)

### 97. Retired IA/terminology reference in RHC02

- Candidate ID: `AMB28-retired_ia_or_terminology_reference-30197142`
- Evidence type: `retired_ia_or_terminology_reference`
- Severity: `yellow`
- Recommended action: `Rewrite`
- Linear-ready: `True`
- Auto-resolved: `False`
- Reason: Active item contains retired IA, retired terminology, or unsafe language; rewrite or retire before reuse.
- Involved active paths:
  - `RHC02` — `prompts/batches/RHC02.md` (partial_implementation; release proof)

### 98. Retired IA/terminology reference in AQOS_AUTONOMOUS_QUALITY_OPERATING_SYSTEM

- Candidate ID: `AMB28-retired_ia_or_terminology_reference-30207098`
- Evidence type: `retired_ia_or_terminology_reference`
- Severity: `yellow`
- Recommended action: `Rewrite`
- Linear-ready: `True`
- Auto-resolved: `False`
- Reason: Active item contains retired IA, retired terminology, or unsafe language; rewrite or retire before reuse.
- Involved active paths:
  - `AQOS_AUTONOMOUS_QUALITY_OPERATING_SYSTEM` — `docs/codex/quality/AQOS_AUTONOMOUS_QUALITY_OPERATING_SYSTEM.md` (partial_implementation; release proof)

### 99. Retired IA/terminology reference in EB37_External_Brain_Privacy_Threat_Model_Prompt

- Candidate ID: `AMB28-retired_ia_or_terminology_reference-30215614`
- Evidence type: `retired_ia_or_terminology_reference`
- Severity: `yellow`
- Recommended action: `Rewrite`
- Linear-ready: `True`
- Auto-resolved: `False`
- Reason: Active item contains retired IA, retired terminology, or unsafe language; rewrite or retire before reuse.
- Involved active paths:
  - `EB37_External_Brain_Privacy_Threat_Model_Prompt` — `docs/codex/batches/EB37_External_Brain_Privacy_Threat_Model_Prompt.md` (partial_implementation; release proof)

### 100. Retired IA/terminology reference in AMB-CODEX-OS-FLAGSHIP-UPGRADE-INSTALL-01

- Candidate ID: `AMB28-retired_ia_or_terminology_reference-30285509`
- Evidence type: `retired_ia_or_terminology_reference`
- Severity: `yellow`
- Recommended action: `Rewrite`
- Linear-ready: `True`
- Auto-resolved: `False`
- Reason: Active item contains retired IA, retired terminology, or unsafe language; rewrite or retire before reuse.
- Involved active paths:
  - `AMB-CODEX-OS-FLAGSHIP-UPGRADE-INSTALL-01` — `prompts/batches/AMB-CODEX-OS-FLAGSHIP-UPGRADE-INSTALL-01.md` (partial_implementation; release proof)

### 101. Retired IA/terminology reference in SOURCE_ATLAS_UNIVERSAL_SOURCE_BINDER_COVERAGE_MAP

- Candidate ID: `AMB28-retired_ia_or_terminology_reference-30752894`
- Evidence type: `retired_ia_or_terminology_reference`
- Severity: `yellow`
- Recommended action: `Rewrite`
- Linear-ready: `True`
- Auto-resolved: `False`
- Reason: Active item contains retired IA, retired terminology, or unsafe language; rewrite or retire before reuse.
- Involved active paths:
  - `SOURCE_ATLAS_UNIVERSAL_SOURCE_BINDER_COVERAGE_MAP` — `docs/codex/SOURCE_ATLAS_UNIVERSAL_SOURCE_BINDER_COVERAGE_MAP.md` (partial_implementation; screenshot)

### 102. Retired IA/terminology reference in GLOBAL_AUTONOMOUS_QUALITY_OVERLAY

- Candidate ID: `AMB28-retired_ia_or_terminology_reference-31006551`
- Evidence type: `retired_ia_or_terminology_reference`
- Severity: `yellow`
- Recommended action: `Rewrite`
- Linear-ready: `True`
- Auto-resolved: `False`
- Reason: Active item contains retired IA, retired terminology, or unsafe language; rewrite or retire before reuse.
- Involved active paths:
  - `GLOBAL_AUTONOMOUS_QUALITY_OVERLAY` — `docs/codex/GLOBAL_AUTONOMOUS_QUALITY_OVERLAY.md` (partial_implementation; audit)

### 103. Retired IA/terminology reference in LDI19

- Candidate ID: `AMB28-retired_ia_or_terminology_reference-31072903`
- Evidence type: `retired_ia_or_terminology_reference`
- Severity: `yellow`
- Recommended action: `Rewrite`
- Linear-ready: `True`
- Auto-resolved: `False`
- Reason: Active item contains retired IA, retired terminology, or unsafe language; rewrite or retire before reuse.
- Involved active paths:
  - `LDI19` — `prompts/batches/LDI19.md` (partial_implementation; release proof)

### 104. Retired IA/terminology reference in MOAT-GOAL-REALITY-FIXTURE-LAB-02

- Candidate ID: `AMB28-retired_ia_or_terminology_reference-31200328`
- Evidence type: `retired_ia_or_terminology_reference`
- Severity: `yellow`
- Recommended action: `Rewrite`
- Linear-ready: `True`
- Auto-resolved: `False`
- Reason: Active item contains retired IA, retired terminology, or unsafe language; rewrite or retire before reuse.
- Involved active paths:
  - `MOAT-GOAL-REALITY-FIXTURE-LAB-02` — `prompts/batches/MOAT-GOAL-REALITY-FIXTURE-LAB-02.md` (partial_implementation; release proof)

### 105. Retired IA/terminology reference in EFC00_Flagship_Proof_Operating_Layer_Integration_Prompt

- Candidate ID: `AMB28-retired_ia_or_terminology_reference-31304300`
- Evidence type: `retired_ia_or_terminology_reference`
- Severity: `yellow`
- Recommended action: `Rewrite`
- Linear-ready: `True`
- Auto-resolved: `False`
- Reason: Active item contains retired IA, retired terminology, or unsafe language; rewrite or retire before reuse.
- Involved active paths:
  - `EFC00_Flagship_Proof_Operating_Layer_Integration_Prompt` — `docs/codex/batches/EFC00_Flagship_Proof_Operating_Layer_Integration_Prompt.md` (partial_implementation; release proof)

### 106. Retired IA/terminology reference in AOS13_Source_Truth_Claim_State_Machine_Prompt

- Candidate ID: `AMB28-retired_ia_or_terminology_reference-31812816`
- Evidence type: `retired_ia_or_terminology_reference`
- Severity: `yellow`
- Recommended action: `Rewrite`
- Linear-ready: `True`
- Auto-resolved: `False`
- Reason: Active item contains retired IA, retired terminology, or unsafe language; rewrite or retire before reuse.
- Involved active paths:
  - `AOS13_Source_Truth_Claim_State_Machine_Prompt` — `docs/codex/batches/AOS13_Source_Truth_Claim_State_Machine_Prompt.md` (partial_implementation; release proof)

### 107. Retired IA/terminology reference in SA19

- Candidate ID: `AMB28-retired_ia_or_terminology_reference-31833040`
- Evidence type: `retired_ia_or_terminology_reference`
- Severity: `yellow`
- Recommended action: `Rewrite`
- Linear-ready: `True`
- Auto-resolved: `False`
- Reason: Active item contains retired IA, retired terminology, or unsafe language; rewrite or retire before reuse.
- Involved active paths:
  - `SA19` — `prompts/batches/SA19.md` (partial_implementation; release proof)

### 108. Retired IA/terminology reference in EB29_Voice_First_Operation_And_Motor_Accessibility_Prompt

- Candidate ID: `AMB28-retired_ia_or_terminology_reference-31962415`
- Evidence type: `retired_ia_or_terminology_reference`
- Severity: `yellow`
- Recommended action: `Rewrite`
- Linear-ready: `True`
- Auto-resolved: `False`
- Reason: Active item contains retired IA, retired terminology, or unsafe language; rewrite or retire before reuse.
- Involved active paths:
  - `EB29_Voice_First_Operation_And_Motor_Accessibility_Prompt` — `docs/codex/batches/EB29_Voice_First_Operation_And_Motor_Accessibility_Prompt.md` (partial_implementation; release proof)

### 109. Retired IA/terminology reference in LDI20

- Candidate ID: `AMB28-retired_ia_or_terminology_reference-32407306`
- Evidence type: `retired_ia_or_terminology_reference`
- Severity: `yellow`
- Recommended action: `Rewrite`
- Linear-ready: `True`
- Auto-resolved: `False`
- Reason: Active item contains retired IA, retired terminology, or unsafe language; rewrite or retire before reuse.
- Involved active paths:
  - `LDI20` — `prompts/batches/LDI20.md` (partial_implementation; release proof)

### 110. Retired IA/terminology reference in SA30

- Candidate ID: `AMB28-retired_ia_or_terminology_reference-32791349`
- Evidence type: `retired_ia_or_terminology_reference`
- Severity: `yellow`
- Recommended action: `Rewrite`
- Linear-ready: `True`
- Auto-resolved: `False`
- Reason: Active item contains retired IA, retired terminology, or unsafe language; rewrite or retire before reuse.
- Involved active paths:
  - `SA30` — `prompts/batches/SA30.md` (partial_implementation; release proof)

### 111. Retired IA/terminology reference in AMB-REPO-AUTHORITY-00-SAFETY-SNAPSHOT

- Candidate ID: `AMB28-retired_ia_or_terminology_reference-32981241`
- Evidence type: `retired_ia_or_terminology_reference`
- Severity: `yellow`
- Recommended action: `Rewrite`
- Linear-ready: `True`
- Auto-resolved: `False`
- Reason: Active item contains retired IA, retired terminology, or unsafe language; rewrite or retire before reuse.
- Involved active paths:
  - `AMB-REPO-AUTHORITY-00-SAFETY-SNAPSHOT` — `prompts/batches/AMB-REPO-AUTHORITY-00-SAFETY-SNAPSHOT.md` (partial_implementation; release proof)

### 112. Retired IA/terminology reference in EB19_Product_Maturity_Onboarding_Canon_Prompt

- Candidate ID: `AMB28-retired_ia_or_terminology_reference-33546032`
- Evidence type: `retired_ia_or_terminology_reference`
- Severity: `yellow`
- Recommended action: `Rewrite`
- Linear-ready: `True`
- Auto-resolved: `False`
- Reason: Active item contains retired IA, retired terminology, or unsafe language; rewrite or retire before reuse.
- Involved active paths:
  - `EB19_Product_Maturity_Onboarding_Canon_Prompt` — `docs/codex/batches/EB19_Product_Maturity_Onboarding_Canon_Prompt.md` (partial_implementation; release proof)

### 113. Retired IA/terminology reference in GLOBAL-BATCH-TRAIN-AUTONOMOUS-COMPLETE-01

- Candidate ID: `AMB28-retired_ia_or_terminology_reference-33665004`
- Evidence type: `retired_ia_or_terminology_reference`
- Severity: `yellow`
- Recommended action: `Rewrite`
- Linear-ready: `True`
- Auto-resolved: `False`
- Reason: Active item contains retired IA, retired terminology, or unsafe language; rewrite or retire before reuse.
- Involved active paths:
  - `GLOBAL-BATCH-TRAIN-AUTONOMOUS-COMPLETE-01` — `prompts/batches/GLOBAL-BATCH-TRAIN-AUTONOMOUS-COMPLETE-01.md` (partial_implementation; release proof)

### 114. Retired IA/terminology reference in MOAT_RUNTIME_ACCEPTANCE_CRITERIA

- Candidate ID: `AMB28-retired_ia_or_terminology_reference-33946957`
- Evidence type: `retired_ia_or_terminology_reference`
- Severity: `yellow`
- Recommended action: `Rewrite`
- Linear-ready: `True`
- Auto-resolved: `False`
- Reason: Active item contains retired IA, retired terminology, or unsafe language; rewrite or retire before reuse.
- Involved active paths:
  - `MOAT_RUNTIME_ACCEPTANCE_CRITERIA` — `docs/codex/MOAT_RUNTIME_ACCEPTANCE_CRITERIA.md` (partial_implementation; audit)

### 115. Retired IA/terminology reference in EB13_Trust_Privacy_User_Control_Canon_Prompt

- Candidate ID: `AMB28-retired_ia_or_terminology_reference-34002462`
- Evidence type: `retired_ia_or_terminology_reference`
- Severity: `yellow`
- Recommended action: `Rewrite`
- Linear-ready: `True`
- Auto-resolved: `False`
- Reason: Active item contains retired IA, retired terminology, or unsafe language; rewrite or retire before reuse.
- Involved active paths:
  - `EB13_Trust_Privacy_User_Control_Canon_Prompt` — `docs/codex/batches/EB13_Trust_Privacy_User_Control_Canon_Prompt.md` (partial_implementation; release proof)

### 116. Retired IA/terminology reference in AMB-REPO-GREEN-FLAGSHIP-RESET-MASTER-01-T09-GOALS-EXTRACTION

- Candidate ID: `AMB28-retired_ia_or_terminology_reference-34029575`
- Evidence type: `retired_ia_or_terminology_reference`
- Severity: `yellow`
- Recommended action: `Rewrite`
- Linear-ready: `True`
- Auto-resolved: `False`
- Reason: Active item contains retired IA, retired terminology, or unsafe language; rewrite or retire before reuse.
- Involved active paths:
  - `AMB-REPO-GREEN-FLAGSHIP-RESET-MASTER-01-T09-GOALS-EXTRACTION` — `prompts/batches/AMB-REPO-GREEN-FLAGSHIP-RESET-MASTER-01-T09-GOALS-EXTRACTION.md` (partial_implementation; tests)

### 117. Retired IA/terminology reference in LDI16

- Candidate ID: `AMB28-retired_ia_or_terminology_reference-3488938`
- Evidence type: `retired_ia_or_terminology_reference`
- Severity: `yellow`
- Recommended action: `Rewrite`
- Linear-ready: `True`
- Auto-resolved: `False`
- Reason: Active item contains retired IA, retired terminology, or unsafe language; rewrite or retire before reuse.
- Involved active paths:
  - `LDI16` — `prompts/batches/LDI16.md` (partial_implementation; release proof)

### 118. Retired IA/terminology reference in PK39

- Candidate ID: `AMB28-retired_ia_or_terminology_reference-35277313`
- Evidence type: `retired_ia_or_terminology_reference`
- Severity: `yellow`
- Recommended action: `Rewrite`
- Linear-ready: `True`
- Auto-resolved: `False`
- Reason: Active item contains retired IA, retired terminology, or unsafe language; rewrite or retire before reuse.
- Involved active paths:
  - `PK39` — `prompts/batches/PK39.md` (partial_implementation; release proof)

### 119. Retired IA/terminology reference in AMBITIONSOS_AOS_BATCH_GATE_MATRIX

- Candidate ID: `AMB28-retired_ia_or_terminology_reference-35311309`
- Evidence type: `retired_ia_or_terminology_reference`
- Severity: `yellow`
- Recommended action: `Rewrite`
- Linear-ready: `True`
- Auto-resolved: `False`
- Reason: Active item contains retired IA, retired terminology, or unsafe language; rewrite or retire before reuse.
- Involved active paths:
  - `AMBITIONSOS_AOS_BATCH_GATE_MATRIX` — `docs/codex/AMBITIONSOS_AOS_BATCH_GATE_MATRIX.md` (partial_implementation; audit)

### 120. Retired IA/terminology reference in EB18_Source_Freshness_Privacy_Receipts_And_Non_Claims_Prompt

- Candidate ID: `AMB28-retired_ia_or_terminology_reference-35337234`
- Evidence type: `retired_ia_or_terminology_reference`
- Severity: `yellow`
- Recommended action: `Rewrite`
- Linear-ready: `True`
- Auto-resolved: `False`
- Reason: Active item contains retired IA, retired terminology, or unsafe language; rewrite or retire before reuse.
- Involved active paths:
  - `EB18_Source_Freshness_Privacy_Receipts_And_Non_Claims_Prompt` — `docs/codex/batches/EB18_Source_Freshness_Privacy_Receipts_And_Non_Claims_Prompt.md` (partial_implementation; release proof)

### 121. Retired IA/terminology reference in OBJECT_OS_NATIVE_SURFACES

- Candidate ID: `AMB28-retired_ia_or_terminology_reference-35844142`
- Evidence type: `retired_ia_or_terminology_reference`
- Severity: `yellow`
- Recommended action: `Rewrite`
- Linear-ready: `True`
- Auto-resolved: `False`
- Reason: Active item contains retired IA, retired terminology, or unsafe language; rewrite or retire before reuse.
- Involved active paths:
  - `OBJECT_OS_NATIVE_SURFACES` — `docs/codex/OBJECT_OS_NATIVE_SURFACES.md` (unknown; screenshot)

### 122. Retired IA/terminology reference in GLOBAL_BATCH_EXECUTION_ORCHESTRATOR

- Candidate ID: `AMB28-retired_ia_or_terminology_reference-3596159`
- Evidence type: `retired_ia_or_terminology_reference`
- Severity: `yellow`
- Recommended action: `Rewrite`
- Linear-ready: `True`
- Auto-resolved: `False`
- Reason: Active item contains retired IA, retired terminology, or unsafe language; rewrite or retire before reuse.
- Involved active paths:
  - `GLOBAL_BATCH_EXECUTION_ORCHESTRATOR` — `docs/codex/GLOBAL_BATCH_EXECUTION_ORCHESTRATOR.md` (partial_implementation; release proof)

### 123. Retired IA/terminology reference in AOS07_Local_Goal_Packs_Requirement_Slots_Prompt

- Candidate ID: `AMB28-retired_ia_or_terminology_reference-36348299`
- Evidence type: `retired_ia_or_terminology_reference`
- Severity: `yellow`
- Recommended action: `Rewrite`
- Linear-ready: `True`
- Auto-resolved: `False`
- Reason: Active item contains retired IA, retired terminology, or unsafe language; rewrite or retire before reuse.
- Involved active paths:
  - `AOS07_Local_Goal_Packs_Requirement_Slots_Prompt` — `docs/codex/batches/AOS07_Local_Goal_Packs_Requirement_Slots_Prompt.md` (partial_implementation; release proof)

### 124. Retired IA/terminology reference in FAANG_FRONTEND_IMPLEMENTATION_OPERATING_SYSTEM

- Candidate ID: `AMB28-retired_ia_or_terminology_reference-36363361`
- Evidence type: `retired_ia_or_terminology_reference`
- Severity: `yellow`
- Recommended action: `Rewrite`
- Linear-ready: `True`
- Auto-resolved: `False`
- Reason: Active item contains retired IA, retired terminology, or unsafe language; rewrite or retire before reuse.
- Involved active paths:
  - `FAANG_FRONTEND_IMPLEMENTATION_OPERATING_SYSTEM` — `docs/codex/FAANG_FRONTEND_IMPLEMENTATION_OPERATING_SYSTEM.md` (partial_implementation; release proof)

### 125. Retired IA/terminology reference in AMBITIONSOS_AOS_DEPENDENCY_GRAPH

- Candidate ID: `AMB28-retired_ia_or_terminology_reference-36463016`
- Evidence type: `retired_ia_or_terminology_reference`
- Severity: `yellow`
- Recommended action: `Rewrite`
- Linear-ready: `True`
- Auto-resolved: `False`
- Reason: Active item contains retired IA, retired terminology, or unsafe language; rewrite or retire before reuse.
- Involved active paths:
  - `AMBITIONSOS_AOS_DEPENDENCY_GRAPH` — `docs/codex/AMBITIONSOS_AOS_DEPENDENCY_GRAPH.md` (partial_implementation; source-only)

### 126. Retired IA/terminology reference in SA14

- Candidate ID: `AMB28-retired_ia_or_terminology_reference-36579802`
- Evidence type: `retired_ia_or_terminology_reference`
- Severity: `yellow`
- Recommended action: `Rewrite`
- Linear-ready: `True`
- Auto-resolved: `False`
- Reason: Active item contains retired IA, retired terminology, or unsafe language; rewrite or retire before reuse.
- Involved active paths:
  - `SA14` — `prompts/batches/SA14.md` (partial_implementation; release proof)

### 127. Retired IA/terminology reference in AOS28

- Candidate ID: `AMB28-retired_ia_or_terminology_reference-36600920`
- Evidence type: `retired_ia_or_terminology_reference`
- Severity: `yellow`
- Recommended action: `Rewrite`
- Linear-ready: `True`
- Auto-resolved: `False`
- Reason: Active item contains retired IA, retired terminology, or unsafe language; rewrite or retire before reuse.
- Involved active paths:
  - `AOS28` — `prompts/batches/AOS28.md` (partial_implementation; release proof)

### 128. Retired IA/terminology reference in UI-STUDIO-03-REALITY-MERIDIAN-ART-DIRECTION

- Candidate ID: `AMB28-retired_ia_or_terminology_reference-36852156`
- Evidence type: `retired_ia_or_terminology_reference`
- Severity: `yellow`
- Recommended action: `Rewrite`
- Linear-ready: `True`
- Auto-resolved: `False`
- Reason: Active item contains retired IA, retired terminology, or unsafe language; rewrite or retire before reuse.
- Involved active paths:
  - `UI-STUDIO-03-REALITY-MERIDIAN-ART-DIRECTION` — `prompts/batches/ui-flagship/UI-STUDIO-03-REALITY-MERIDIAN-ART-DIRECTION.md` (partial_implementation; audit)

### 129. Retired IA/terminology reference in FLAGSHIP_COMPLETION_FILE_BOUNDARY_MAP

- Candidate ID: `AMB28-retired_ia_or_terminology_reference-37008746`
- Evidence type: `retired_ia_or_terminology_reference`
- Severity: `yellow`
- Recommended action: `Rewrite`
- Linear-ready: `True`
- Auto-resolved: `False`
- Reason: Active item contains retired IA, retired terminology, or unsafe language; rewrite or retire before reuse.
- Involved active paths:
  - `FLAGSHIP_COMPLETION_FILE_BOUNDARY_MAP` — `docs/codex/FLAGSHIP_COMPLETION_FILE_BOUNDARY_MAP.md` (partial_implementation; tests)

### 130. Retired IA/terminology reference in SOURCE_ATLAS_GATE_MATRIX

- Candidate ID: `AMB28-retired_ia_or_terminology_reference-370291`
- Evidence type: `retired_ia_or_terminology_reference`
- Severity: `yellow`
- Recommended action: `Rewrite`
- Linear-ready: `True`
- Auto-resolved: `False`
- Reason: Active item contains retired IA, retired terminology, or unsafe language; rewrite or retire before reuse.
- Involved active paths:
  - `SOURCE_ATLAS_GATE_MATRIX` — `docs/codex/SOURCE_ATLAS_GATE_MATRIX.md` (partial_implementation; screenshot)

### 131. Retired IA/terminology reference in CHROME-AUDIT-01

- Candidate ID: `AMB28-retired_ia_or_terminology_reference-37333128`
- Evidence type: `retired_ia_or_terminology_reference`
- Severity: `yellow`
- Recommended action: `Rewrite`
- Linear-ready: `True`
- Auto-resolved: `False`
- Reason: Active item contains retired IA, retired terminology, or unsafe language; rewrite or retire before reuse.
- Involved active paths:
  - `CHROME-AUDIT-01` — `prompts/batches/CHROME-AUDIT-01.md` (partial_implementation; release proof)

### 132. Retired IA/terminology reference in EB28_Plain_Language_Anxiety_Safe_Copy_And_Explain_This_Screen_Prompt

- Candidate ID: `AMB28-retired_ia_or_terminology_reference-37360218`
- Evidence type: `retired_ia_or_terminology_reference`
- Severity: `yellow`
- Recommended action: `Rewrite`
- Linear-ready: `True`
- Auto-resolved: `False`
- Reason: Active item contains retired IA, retired terminology, or unsafe language; rewrite or retire before reuse.
- Involved active paths:
  - `EB28_Plain_Language_Anxiety_Safe_Copy_And_Explain_This_Screen_Prompt` — `docs/codex/batches/EB28_Plain_Language_Anxiety_Safe_Copy_And_Explain_This_Screen_Prompt.md` (partial_implementation; release proof)

### 133. Retired IA/terminology reference in SA32

- Candidate ID: `AMB28-retired_ia_or_terminology_reference-37376171`
- Evidence type: `retired_ia_or_terminology_reference`
- Severity: `yellow`
- Recommended action: `Rewrite`
- Linear-ready: `True`
- Auto-resolved: `False`
- Reason: Active item contains retired IA, retired terminology, or unsafe language; rewrite or retire before reuse.
- Involved active paths:
  - `SA32` — `prompts/batches/SA32.md` (partial_implementation; release proof)

### 134. Retired IA/terminology reference in MOAT-UNIVERSAL-GOAL-REALITY-COMPILER-01

- Candidate ID: `AMB28-retired_ia_or_terminology_reference-37621788`
- Evidence type: `retired_ia_or_terminology_reference`
- Severity: `yellow`
- Recommended action: `Rewrite`
- Linear-ready: `True`
- Auto-resolved: `False`
- Reason: Active item contains retired IA, retired terminology, or unsafe language; rewrite or retire before reuse.
- Involved active paths:
  - `MOAT-UNIVERSAL-GOAL-REALITY-COMPILER-01` — `prompts/batches/MOAT-UNIVERSAL-GOAL-REALITY-COMPILER-01.md` (partial_implementation; release proof)

### 135. Retired IA/terminology reference in PD07_Goal_Proof_And_Decision_History_Depth_Prompt

- Candidate ID: `AMB28-retired_ia_or_terminology_reference-37640316`
- Evidence type: `retired_ia_or_terminology_reference`
- Severity: `yellow`
- Recommended action: `Rewrite`
- Linear-ready: `True`
- Auto-resolved: `False`
- Reason: Active item contains retired IA, retired terminology, or unsafe language; rewrite or retire before reuse.
- Involved active paths:
  - `PD07_Goal_Proof_And_Decision_History_Depth_Prompt` — `docs/codex/batches/PD07_Goal_Proof_And_Decision_History_Depth_Prompt.md` (partial_implementation; release proof)

### 136. Retired IA/terminology reference in OBJECT_OS_MRI25_34_UPGRADE_OVERLAY

- Candidate ID: `AMB28-retired_ia_or_terminology_reference-37815028`
- Evidence type: `retired_ia_or_terminology_reference`
- Severity: `yellow`
- Recommended action: `Rewrite`
- Linear-ready: `True`
- Auto-resolved: `False`
- Reason: Active item contains retired IA, retired terminology, or unsafe language; rewrite or retire before reuse.
- Involved active paths:
  - `OBJECT_OS_MRI25_34_UPGRADE_OVERLAY` — `docs/codex/OBJECT_OS_MRI25_34_UPGRADE_OVERLAY.md` (partial_implementation; release proof)

### 137. Retired IA/terminology reference in SI17_Top_Level_Surface_Composition_Implementation_Prompt

- Candidate ID: `AMB28-retired_ia_or_terminology_reference-38051800`
- Evidence type: `retired_ia_or_terminology_reference`
- Severity: `yellow`
- Recommended action: `Rewrite`
- Linear-ready: `True`
- Auto-resolved: `False`
- Reason: Active item contains retired IA, retired terminology, or unsafe language; rewrite or retire before reuse.
- Involved active paths:
  - `SI17_Top_Level_Surface_Composition_Implementation_Prompt` — `docs/codex/batches/SI17_Top_Level_Surface_Composition_Implementation_Prompt.md` (partial_implementation; release proof)

### 138. Retired IA/terminology reference in AMB-CHATGPT-REPO-OS-UPGRADE-INSTALL-01

- Candidate ID: `AMB28-retired_ia_or_terminology_reference-38288400`
- Evidence type: `retired_ia_or_terminology_reference`
- Severity: `yellow`
- Recommended action: `Rewrite`
- Linear-ready: `True`
- Auto-resolved: `False`
- Reason: Active item contains retired IA, retired terminology, or unsafe language; rewrite or retire before reuse.
- Involved active paths:
  - `AMB-CHATGPT-REPO-OS-UPGRADE-INSTALL-01` — `docs/codex/reports/AMB-CHATGPT-REPO-OS-UPGRADE-INSTALL-01.md` (partial_implementation; release proof)

### 139. Retired IA/terminology reference in SOURCE_ATLAS_HPS_AOS_LDI_INTEGRATION_MAP

- Candidate ID: `AMB28-retired_ia_or_terminology_reference-38330761`
- Evidence type: `retired_ia_or_terminology_reference`
- Severity: `yellow`
- Recommended action: `Rewrite`
- Linear-ready: `True`
- Auto-resolved: `False`
- Reason: Active item contains retired IA, retired terminology, or unsafe language; rewrite or retire before reuse.
- Involved active paths:
  - `SOURCE_ATLAS_HPS_AOS_LDI_INTEGRATION_MAP` — `docs/codex/SOURCE_ATLAS_HPS_AOS_LDI_INTEGRATION_MAP.md` (unknown; release proof)

### 140. Retired IA/terminology reference in EXTERNAL_BRAIN_RISK_REGISTER

- Candidate ID: `AMB28-retired_ia_or_terminology_reference-38373056`
- Evidence type: `retired_ia_or_terminology_reference`
- Severity: `yellow`
- Recommended action: `Rewrite`
- Linear-ready: `True`
- Auto-resolved: `False`
- Reason: Active item contains retired IA, retired terminology, or unsafe language; rewrite or retire before reuse.
- Involved active paths:
  - `EXTERNAL_BRAIN_RISK_REGISTER` — `docs/codex/EXTERNAL_BRAIN_RISK_REGISTER.md` (partial_implementation; release proof)

### 141. Retired IA/terminology reference in existing-code-champion-coverage

- Candidate ID: `AMB28-retired_ia_or_terminology_reference-38928933`
- Evidence type: `retired_ia_or_terminology_reference`
- Severity: `yellow`
- Recommended action: `Rewrite`
- Linear-ready: `True`
- Auto-resolved: `False`
- Reason: Active item contains retired IA, retired terminology, or unsafe language; rewrite or retire before reuse.
- Involved active paths:
  - `existing-code-champion-coverage` — `docs/codex/existing-code-champion-coverage.yml` (unknown; release proof)

### 142. Retired IA/terminology reference in SA10B

- Candidate ID: `AMB28-retired_ia_or_terminology_reference-39022166`
- Evidence type: `retired_ia_or_terminology_reference`
- Severity: `yellow`
- Recommended action: `Rewrite`
- Linear-ready: `True`
- Auto-resolved: `False`
- Reason: Active item contains retired IA, retired terminology, or unsafe language; rewrite or retire before reuse.
- Involved active paths:
  - `SA10B` — `prompts/batches/SA10B.md` (partial_implementation; release proof)

### 143. Retired IA/terminology reference in RHC03

- Candidate ID: `AMB28-retired_ia_or_terminology_reference-39280333`
- Evidence type: `retired_ia_or_terminology_reference`
- Severity: `yellow`
- Recommended action: `Rewrite`
- Linear-ready: `True`
- Auto-resolved: `False`
- Reason: Active item contains retired IA, retired terminology, or unsafe language; rewrite or retire before reuse.
- Involved active paths:
  - `RHC03` — `prompts/batches/RHC03.md` (partial_implementation; release proof)

### 144. Retired IA/terminology reference in EB21_Concierge_Setup_And_Planning_Defaults_Onboarding_Prompt

- Candidate ID: `AMB28-retired_ia_or_terminology_reference-39379693`
- Evidence type: `retired_ia_or_terminology_reference`
- Severity: `yellow`
- Recommended action: `Rewrite`
- Linear-ready: `True`
- Auto-resolved: `False`
- Reason: Active item contains retired IA, retired terminology, or unsafe language; rewrite or retire before reuse.
- Involved active paths:
  - `EB21_Concierge_Setup_And_Planning_Defaults_Onboarding_Prompt` — `docs/codex/batches/EB21_Concierge_Setup_And_Planning_Defaults_Onboarding_Prompt.md` (partial_implementation; release proof)

### 145. Retired IA/terminology reference in AOS08_Alternate_Path_Kernel_Path_Portfolio_Prompt

- Candidate ID: `AMB28-retired_ia_or_terminology_reference-39805983`
- Evidence type: `retired_ia_or_terminology_reference`
- Severity: `yellow`
- Recommended action: `Rewrite`
- Linear-ready: `True`
- Auto-resolved: `False`
- Reason: Active item contains retired IA, retired terminology, or unsafe language; rewrite or retire before reuse.
- Involved active paths:
  - `AOS08_Alternate_Path_Kernel_Path_Portfolio_Prompt` — `docs/codex/batches/AOS08_Alternate_Path_Kernel_Path_Portfolio_Prompt.md` (partial_implementation; release proof)

### 146. Retired IA/terminology reference in PK36

- Candidate ID: `AMB28-retired_ia_or_terminology_reference-40440044`
- Evidence type: `retired_ia_or_terminology_reference`
- Severity: `yellow`
- Recommended action: `Rewrite`
- Linear-ready: `True`
- Auto-resolved: `False`
- Reason: Active item contains retired IA, retired terminology, or unsafe language; rewrite or retire before reuse.
- Involved active paths:
  - `PK36` — `prompts/batches/PK36.md` (partial_implementation; release proof)

### 147. Retired IA/terminology reference in AOS09_Option_Value_North_Star_Prompt

- Candidate ID: `AMB28-retired_ia_or_terminology_reference-40642665`
- Evidence type: `retired_ia_or_terminology_reference`
- Severity: `yellow`
- Recommended action: `Rewrite`
- Linear-ready: `True`
- Auto-resolved: `False`
- Reason: Active item contains retired IA, retired terminology, or unsafe language; rewrite or retire before reuse.
- Involved active paths:
  - `AOS09_Option_Value_North_Star_Prompt` — `docs/codex/batches/AOS09_Option_Value_North_Star_Prompt.md` (partial_implementation; release proof)

### 148. Retired IA/terminology reference in PD11_Grow_Into_Goal_Flow_Prompt

- Candidate ID: `AMB28-retired_ia_or_terminology_reference-41619348`
- Evidence type: `retired_ia_or_terminology_reference`
- Severity: `yellow`
- Recommended action: `Rewrite`
- Linear-ready: `True`
- Auto-resolved: `False`
- Reason: Active item contains retired IA, retired terminology, or unsafe language; rewrite or retire before reuse.
- Involved active paths:
  - `PD11_Grow_Into_Goal_Flow_Prompt` — `docs/codex/batches/PD11_Grow_Into_Goal_Flow_Prompt.md` (partial_implementation; release proof)

### 149. Retired IA/terminology reference in AOS10_Commitment_Time_Kernel_Prompt

- Candidate ID: `AMB28-retired_ia_or_terminology_reference-41620940`
- Evidence type: `retired_ia_or_terminology_reference`
- Severity: `yellow`
- Recommended action: `Rewrite`
- Linear-ready: `True`
- Auto-resolved: `False`
- Reason: Active item contains retired IA, retired terminology, or unsafe language; rewrite or retire before reuse.
- Involved active paths:
  - `AOS10_Commitment_Time_Kernel_Prompt` — `docs/codex/batches/AOS10_Commitment_Time_Kernel_Prompt.md` (partial_implementation; release proof)

### 150. Retired IA/terminology reference in PD15_You_Trust_History_And_Receipts_Center_Prompt

- Candidate ID: `AMB28-retired_ia_or_terminology_reference-42184901`
- Evidence type: `retired_ia_or_terminology_reference`
- Severity: `yellow`
- Recommended action: `Rewrite`
- Linear-ready: `True`
- Auto-resolved: `False`
- Reason: Active item contains retired IA, retired terminology, or unsafe language; rewrite or retire before reuse.
- Involved active paths:
  - `PD15_You_Trust_History_And_Receipts_Center_Prompt` — `docs/codex/batches/PD15_You_Trust_History_And_Receipts_Center_Prompt.md` (partial_implementation; release proof)

### 151. Retired IA/terminology reference in PK29

- Candidate ID: `AMB28-retired_ia_or_terminology_reference-42561200`
- Evidence type: `retired_ia_or_terminology_reference`
- Severity: `yellow`
- Recommended action: `Rewrite`
- Linear-ready: `True`
- Auto-resolved: `False`
- Reason: Active item contains retired IA, retired terminology, or unsafe language; rewrite or retire before reuse.
- Involved active paths:
  - `PK29` — `prompts/batches/PK29.md` (partial_implementation; release proof)

### 152. Retired IA/terminology reference in PFC36

- Candidate ID: `AMB28-retired_ia_or_terminology_reference-42633325`
- Evidence type: `retired_ia_or_terminology_reference`
- Severity: `yellow`
- Recommended action: `Rewrite`
- Linear-ready: `True`
- Auto-resolved: `False`
- Reason: Active item contains retired IA, retired terminology, or unsafe language; rewrite or retire before reuse.
- Involved active paths:
  - `PFC36` — `prompts/batches/PFC36.md` (partial_implementation; release proof)

### 153. Retired IA/terminology reference in SA16

- Candidate ID: `AMB28-retired_ia_or_terminology_reference-42736118`
- Evidence type: `retired_ia_or_terminology_reference`
- Severity: `yellow`
- Recommended action: `Rewrite`
- Linear-ready: `True`
- Auto-resolved: `False`
- Reason: Active item contains retired IA, retired terminology, or unsafe language; rewrite or retire before reuse.
- Involved active paths:
  - `SA16` — `prompts/batches/SA16.md` (partial_implementation; release proof)

### 154. Retired IA/terminology reference in AMB_CODEX_GOVERNANCE_SPEC

- Candidate ID: `AMB28-retired_ia_or_terminology_reference-4322280`
- Evidence type: `retired_ia_or_terminology_reference`
- Severity: `yellow`
- Recommended action: `Rewrite`
- Linear-ready: `True`
- Auto-resolved: `False`
- Reason: Active item contains retired IA, retired terminology, or unsafe language; rewrite or retire before reuse.
- Involved active paths:
  - `AMB_CODEX_GOVERNANCE_SPEC` — `docs/codex/AMB_CODEX_GOVERNANCE_SPEC.md` (partial_implementation; release proof)

### 155. Retired IA/terminology reference in AOS26_AmbitionsOS_Privacy_Performance_QA_Prompt

- Candidate ID: `AMB28-retired_ia_or_terminology_reference-44058076`
- Evidence type: `retired_ia_or_terminology_reference`
- Severity: `yellow`
- Recommended action: `Rewrite`
- Linear-ready: `True`
- Auto-resolved: `False`
- Reason: Active item contains retired IA, retired terminology, or unsafe language; rewrite or retire before reuse.
- Involved active paths:
  - `AOS26_AmbitionsOS_Privacy_Performance_QA_Prompt` — `docs/codex/batches/AOS26_AmbitionsOS_Privacy_Performance_QA_Prompt.md` (partial_implementation; release proof)

### 156. Retired IA/terminology reference in AOS30_AmbitionsOS_Beyond_Roadmap_Prompt

- Candidate ID: `AMB28-retired_ia_or_terminology_reference-44062297`
- Evidence type: `retired_ia_or_terminology_reference`
- Severity: `yellow`
- Recommended action: `Rewrite`
- Linear-ready: `True`
- Auto-resolved: `False`
- Reason: Active item contains retired IA, retired terminology, or unsafe language; rewrite or retire before reuse.
- Involved active paths:
  - `AOS30_AmbitionsOS_Beyond_Roadmap_Prompt` — `docs/codex/batches/AOS30_AmbitionsOS_Beyond_Roadmap_Prompt.md` (partial_implementation; release proof)

### 157. Retired IA/terminology reference in PFC40

- Candidate ID: `AMB28-retired_ia_or_terminology_reference-44589820`
- Evidence type: `retired_ia_or_terminology_reference`
- Severity: `yellow`
- Recommended action: `Rewrite`
- Linear-ready: `True`
- Auto-resolved: `False`
- Reason: Active item contains retired IA, retired terminology, or unsafe language; rewrite or retire before reuse.
- Involved active paths:
  - `PFC40` — `prompts/batches/PFC40.md` (partial_implementation; release proof)

### 158. Retired IA/terminology reference in FCP01_FCP30_FLAGSHIP_COMPLETION_TRAIN

- Candidate ID: `AMB28-retired_ia_or_terminology_reference-44749986`
- Evidence type: `retired_ia_or_terminology_reference`
- Severity: `yellow`
- Recommended action: `Rewrite`
- Linear-ready: `True`
- Auto-resolved: `False`
- Reason: Active item contains retired IA, retired terminology, or unsafe language; rewrite or retire before reuse.
- Involved active paths:
  - `FCP01_FCP30_FLAGSHIP_COMPLETION_TRAIN` — `docs/codex/batch-trains/FCP01_FCP30_FLAGSHIP_COMPLETION_TRAIN.md` (partial_implementation; release proof)

### 159. Retired IA/terminology reference in PD02_Today_Step_Detail_Depth_Prompt

- Candidate ID: `AMB28-retired_ia_or_terminology_reference-44798050`
- Evidence type: `retired_ia_or_terminology_reference`
- Severity: `yellow`
- Recommended action: `Rewrite`
- Linear-ready: `True`
- Auto-resolved: `False`
- Reason: Active item contains retired IA, retired terminology, or unsafe language; rewrite or retire before reuse.
- Involved active paths:
  - `PD02_Today_Step_Detail_Depth_Prompt` — `docs/codex/batches/PD02_Today_Step_Detail_Depth_Prompt.md` (partial_implementation; release proof)

### 160. Retired IA/terminology reference in SI05_Hero_Step_Panel_System_Prompt

- Candidate ID: `AMB28-retired_ia_or_terminology_reference-45263576`
- Evidence type: `retired_ia_or_terminology_reference`
- Severity: `yellow`
- Recommended action: `Rewrite`
- Linear-ready: `True`
- Auto-resolved: `False`
- Reason: Active item contains retired IA, retired terminology, or unsafe language; rewrite or retire before reuse.
- Involved active paths:
  - `SI05_Hero_Step_Panel_System_Prompt` — `docs/codex/batches/SI05_Hero_Step_Panel_System_Prompt.md` (partial_implementation; release proof)

### 161. Retired IA/terminology reference in AMB-REPO-GREEN-FLAGSHIP-RESET-MASTER-01

- Candidate ID: `AMB28-retired_ia_or_terminology_reference-45473669`
- Evidence type: `retired_ia_or_terminology_reference`
- Severity: `yellow`
- Recommended action: `Rewrite`
- Linear-ready: `True`
- Auto-resolved: `False`
- Reason: Active item contains retired IA, retired terminology, or unsafe language; rewrite or retire before reuse.
- Involved active paths:
  - `AMB-REPO-GREEN-FLAGSHIP-RESET-MASTER-01` — `prompts/batches/AMB-REPO-GREEN-FLAGSHIP-RESET-MASTER-01.md` (partial_implementation; release proof)

### 162. Retired IA/terminology reference in DAV05_Plan_LifeShapeMap_And_CapacityVisuals_Implementation_Prompt

- Candidate ID: `AMB28-retired_ia_or_terminology_reference-46019843`
- Evidence type: `retired_ia_or_terminology_reference`
- Severity: `yellow`
- Recommended action: `Rewrite`
- Linear-ready: `True`
- Auto-resolved: `False`
- Reason: Active item contains retired IA, retired terminology, or unsafe language; rewrite or retire before reuse.
- Involved active paths:
  - `DAV05_Plan_LifeShapeMap_And_CapacityVisuals_Implementation_Prompt` — `docs/codex/batches/DAV05_Plan_LifeShapeMap_And_CapacityVisuals_Implementation_Prompt.md` (partial_implementation; source-only)

### 163. Retired IA/terminology reference in GOALS-CONSTELLATION-ATLAS-VISUAL-01

- Candidate ID: `AMB28-retired_ia_or_terminology_reference-46358055`
- Evidence type: `retired_ia_or_terminology_reference`
- Severity: `yellow`
- Recommended action: `Rewrite`
- Linear-ready: `True`
- Auto-resolved: `False`
- Reason: Active item contains retired IA, retired terminology, or unsafe language; rewrite or retire before reuse.
- Involved active paths:
  - `GOALS-CONSTELLATION-ATLAS-VISUAL-01` — `prompts/batches/GOALS-CONSTELLATION-ATLAS-VISUAL-01.md` (partial_implementation; source-only)

### 164. Retired IA/terminology reference in PFC32

- Candidate ID: `AMB28-retired_ia_or_terminology_reference-46463466`
- Evidence type: `retired_ia_or_terminology_reference`
- Severity: `yellow`
- Recommended action: `Rewrite`
- Linear-ready: `True`
- Auto-resolved: `False`
- Reason: Active item contains retired IA, retired terminology, or unsafe language; rewrite or retire before reuse.
- Involved active paths:
  - `PFC32` — `prompts/batches/PFC32.md` (partial_implementation; release proof)

### 165. Retired IA/terminology reference in EB22_Privacy_Setup_And_Trust_Onboarding_Prompt

- Candidate ID: `AMB28-retired_ia_or_terminology_reference-46473695`
- Evidence type: `retired_ia_or_terminology_reference`
- Severity: `yellow`
- Recommended action: `Rewrite`
- Linear-ready: `True`
- Auto-resolved: `False`
- Reason: Active item contains retired IA, retired terminology, or unsafe language; rewrite or retire before reuse.
- Involved active paths:
  - `EB22_Privacy_Setup_And_Trust_Onboarding_Prompt` — `docs/codex/batches/EB22_Privacy_Setup_And_Trust_Onboarding_Prompt.md` (partial_implementation; release proof)

### 166. Retired IA/terminology reference in MOAT-GOAL-REALITY-TODAY-BRIDGE-06

- Candidate ID: `AMB28-retired_ia_or_terminology_reference-46474087`
- Evidence type: `retired_ia_or_terminology_reference`
- Severity: `yellow`
- Recommended action: `Rewrite`
- Linear-ready: `True`
- Auto-resolved: `False`
- Reason: Active item contains retired IA, retired terminology, or unsafe language; rewrite or retire before reuse.
- Involved active paths:
  - `MOAT-GOAL-REALITY-TODAY-BRIDGE-06` — `prompts/batches/MOAT-GOAL-REALITY-TODAY-BRIDGE-06.md` (partial_implementation; release proof)

### 167. Retired IA/terminology reference in PD14_Life_Shape_Drilldowns_Prompt

- Candidate ID: `AMB28-retired_ia_or_terminology_reference-46664930`
- Evidence type: `retired_ia_or_terminology_reference`
- Severity: `yellow`
- Recommended action: `Rewrite`
- Linear-ready: `True`
- Auto-resolved: `False`
- Reason: Active item contains retired IA, retired terminology, or unsafe language; rewrite or retire before reuse.
- Involved active paths:
  - `PD14_Life_Shape_Drilldowns_Prompt` — `docs/codex/batches/PD14_Life_Shape_Drilldowns_Prompt.md` (partial_implementation; release proof)

### 168. Retired IA/terminology reference in EB30_Overloaded_Day_Adaptation_And_Low_Cognitive_Load_Flows_Prompt

- Candidate ID: `AMB28-retired_ia_or_terminology_reference-46908884`
- Evidence type: `retired_ia_or_terminology_reference`
- Severity: `yellow`
- Recommended action: `Rewrite`
- Linear-ready: `True`
- Auto-resolved: `False`
- Reason: Active item contains retired IA, retired terminology, or unsafe language; rewrite or retire before reuse.
- Involved active paths:
  - `EB30_Overloaded_Day_Adaptation_And_Low_Cognitive_Load_Flows_Prompt` — `docs/codex/batches/EB30_Overloaded_Day_Adaptation_And_Low_Cognitive_Load_Flows_Prompt.md` (partial_implementation; release proof)

### 169. Retired IA/terminology reference in UI-STUDIO-06-CLOSURE-RECOVERY-INTERACTIONS

- Candidate ID: `AMB28-retired_ia_or_terminology_reference-46990827`
- Evidence type: `retired_ia_or_terminology_reference`
- Severity: `yellow`
- Recommended action: `Rewrite`
- Linear-ready: `True`
- Auto-resolved: `False`
- Reason: Active item contains retired IA, retired terminology, or unsafe language; rewrite or retire before reuse.
- Involved active paths:
  - `UI-STUDIO-06-CLOSURE-RECOVERY-INTERACTIONS` — `prompts/batches/ui-flagship/UI-STUDIO-06-CLOSURE-RECOVERY-INTERACTIONS.md` (partial_implementation; audit)

### 170. Retired IA/terminology reference in AOS24_AmbitionsOS_UI_Integration_Prompt

- Candidate ID: `AMB28-retired_ia_or_terminology_reference-47075403`
- Evidence type: `retired_ia_or_terminology_reference`
- Severity: `yellow`
- Recommended action: `Rewrite`
- Linear-ready: `True`
- Auto-resolved: `False`
- Reason: Active item contains retired IA, retired terminology, or unsafe language; rewrite or retire before reuse.
- Involved active paths:
  - `AOS24_AmbitionsOS_UI_Integration_Prompt` — `docs/codex/batches/AOS24_AmbitionsOS_UI_Integration_Prompt.md` (partial_implementation; release proof)

### 171. Retired IA/terminology reference in BATCH-14-canon-batch-11-path-systems-foundation

- Candidate ID: `AMB28-retired_ia_or_terminology_reference-48586044`
- Evidence type: `retired_ia_or_terminology_reference`
- Severity: `yellow`
- Recommended action: `Rewrite`
- Linear-ready: `True`
- Auto-resolved: `False`
- Reason: Active item contains retired IA, retired terminology, or unsafe language; rewrite or retire before reuse.
- Involved active paths:
  - `BATCH-14-canon-batch-11-path-systems-foundation` — `docs/codex/batches/BATCH-14-canon-batch-11-path-systems-foundation.md` (unknown; audit)

### 172. Retired IA/terminology reference in EB32_Cross_Kernel_Dependency_And_Gate_Integration_Prompt

- Candidate ID: `AMB28-retired_ia_or_terminology_reference-48641234`
- Evidence type: `retired_ia_or_terminology_reference`
- Severity: `yellow`
- Recommended action: `Rewrite`
- Linear-ready: `True`
- Auto-resolved: `False`
- Reason: Active item contains retired IA, retired terminology, or unsafe language; rewrite or retire before reuse.
- Involved active paths:
  - `EB32_Cross_Kernel_Dependency_And_Gate_Integration_Prompt` — `docs/codex/batches/EB32_Cross_Kernel_Dependency_And_Gate_Integration_Prompt.md` (partial_implementation; release proof)

### 173. Retired IA/terminology reference in EB24_Onboarding_Receipts_Skip_Later_And_Setup_Recovery_Prompt

- Candidate ID: `AMB28-retired_ia_or_terminology_reference-48681270`
- Evidence type: `retired_ia_or_terminology_reference`
- Severity: `yellow`
- Recommended action: `Rewrite`
- Linear-ready: `True`
- Auto-resolved: `False`
- Reason: Active item contains retired IA, retired terminology, or unsafe language; rewrite or retire before reuse.
- Involved active paths:
  - `EB24_Onboarding_Receipts_Skip_Later_And_Setup_Recovery_Prompt` — `docs/codex/batches/EB24_Onboarding_Receipts_Skip_Later_And_Setup_Recovery_Prompt.md` (partial_implementation; release proof)

### 174. Retired IA/terminology reference in RHC06

- Candidate ID: `AMB28-retired_ia_or_terminology_reference-48774433`
- Evidence type: `retired_ia_or_terminology_reference`
- Severity: `yellow`
- Recommended action: `Rewrite`
- Linear-ready: `True`
- Auto-resolved: `False`
- Reason: Active item contains retired IA, retired terminology, or unsafe language; rewrite or retire before reuse.
- Involved active paths:
  - `RHC06` — `prompts/batches/RHC06.md` (partial_implementation; release proof)

### 175. Retired IA/terminology reference in MOAT_RUNTIME_GOLDEN_SCENARIOS

- Candidate ID: `AMB28-retired_ia_or_terminology_reference-48914830`
- Evidence type: `retired_ia_or_terminology_reference`
- Severity: `yellow`
- Recommended action: `Rewrite`
- Linear-ready: `True`
- Auto-resolved: `False`
- Reason: Active item contains retired IA, retired terminology, or unsafe language; rewrite or retire before reuse.
- Involved active paths:
  - `MOAT_RUNTIME_GOLDEN_SCENARIOS` — `docs/codex/MOAT_RUNTIME_GOLDEN_SCENARIOS.md` (unknown; release proof)

### 176. Retired IA/terminology reference in PD10_Capture_Correction_And_Confidence_Loops_Prompt

- Candidate ID: `AMB28-retired_ia_or_terminology_reference-49044790`
- Evidence type: `retired_ia_or_terminology_reference`
- Severity: `yellow`
- Recommended action: `Rewrite`
- Linear-ready: `True`
- Auto-resolved: `False`
- Reason: Active item contains retired IA, retired terminology, or unsafe language; rewrite or retire before reuse.
- Involved active paths:
  - `PD10_Capture_Correction_And_Confidence_Loops_Prompt` — `docs/codex/batches/PD10_Capture_Correction_And_Confidence_Loops_Prompt.md` (partial_implementation; release proof)

### 177. Retired IA/terminology reference in FVQ01_RENDERED_VISUAL_FRESHNESS_AND_FLAGSHIP_GATE

- Candidate ID: `AMB28-retired_ia_or_terminology_reference-49081777`
- Evidence type: `retired_ia_or_terminology_reference`
- Severity: `yellow`
- Recommended action: `Rewrite`
- Linear-ready: `True`
- Auto-resolved: `False`
- Reason: Active item contains retired IA, retired terminology, or unsafe language; rewrite or retire before reuse.
- Involved active paths:
  - `FVQ01_RENDERED_VISUAL_FRESHNESS_AND_FLAGSHIP_GATE` — `docs/codex/visual-quality/FVQ01_RENDERED_VISUAL_FRESHNESS_AND_FLAGSHIP_GATE.md` (partial_implementation; release proof)

### 178. Retired IA/terminology reference in ios26-toolchain-matrix

- Candidate ID: `AMB28-retired_ia_or_terminology_reference-49132237`
- Evidence type: `retired_ia_or_terminology_reference`
- Severity: `yellow`
- Recommended action: `Rewrite`
- Linear-ready: `True`
- Auto-resolved: `False`
- Reason: Active item contains retired IA, retired terminology, or unsafe language; rewrite or retire before reuse.
- Involved active paths:
  - `ios26-toolchain-matrix` — `docs/codex/ios26-toolchain-matrix.md` (partial_implementation; audit)

### 179. Retired IA/terminology reference in AMB-FE-BE-MOAT-SCENARIO-PROOF-98

- Candidate ID: `AMB28-retired_ia_or_terminology_reference-49153797`
- Evidence type: `retired_ia_or_terminology_reference`
- Severity: `yellow`
- Recommended action: `Rewrite`
- Linear-ready: `True`
- Auto-resolved: `False`
- Reason: Active item contains retired IA, retired terminology, or unsafe language; rewrite or retire before reuse.
- Involved active paths:
  - `AMB-FE-BE-MOAT-SCENARIO-PROOF-98` — `prompts/batches/amb-fe-be/AMB-FE-BE-MOAT-SCENARIO-PROOF-98.md` (partial_implementation; release proof)

### 180. Retired IA/terminology reference in F03_5_Today_Execution_State_Contract_Hardening_Prompt

- Candidate ID: `AMB28-retired_ia_or_terminology_reference-49267159`
- Evidence type: `retired_ia_or_terminology_reference`
- Severity: `yellow`
- Recommended action: `Rewrite`
- Linear-ready: `True`
- Auto-resolved: `False`
- Reason: Active item contains retired IA, retired terminology, or unsafe language; rewrite or retire before reuse.
- Involved active paths:
  - `F03_5_Today_Execution_State_Contract_Hardening_Prompt` — `docs/codex/batches/F03_5_Today_Execution_State_Contract_Hardening_Prompt.md` (partial_implementation; tests)

### 181. Retired IA/terminology reference in AQOS_SCRIPT_AND_TOOL_MAP

- Candidate ID: `AMB28-retired_ia_or_terminology_reference-49350817`
- Evidence type: `retired_ia_or_terminology_reference`
- Severity: `yellow`
- Recommended action: `Rewrite`
- Linear-ready: `True`
- Auto-resolved: `False`
- Reason: Active item contains retired IA, retired terminology, or unsafe language; rewrite or retire before reuse.
- Involved active paths:
  - `AQOS_SCRIPT_AND_TOOL_MAP` — `docs/codex/quality/AQOS_SCRIPT_AND_TOOL_MAP.md` (partial_implementation; release proof)

### 182. Retired IA/terminology reference in PK19

- Candidate ID: `AMB28-retired_ia_or_terminology_reference-49818620`
- Evidence type: `retired_ia_or_terminology_reference`
- Severity: `yellow`
- Recommended action: `Rewrite`
- Linear-ready: `True`
- Auto-resolved: `False`
- Reason: Active item contains retired IA, retired terminology, or unsafe language; rewrite or retire before reuse.
- Involved active paths:
  - `PK19` — `prompts/batches/PK19.md` (partial_implementation; release proof)

### 183. Retired IA/terminology reference in EB08_Memory_Source_Confidence_And_Trust_Decay_Prompt

- Candidate ID: `AMB28-retired_ia_or_terminology_reference-49851604`
- Evidence type: `retired_ia_or_terminology_reference`
- Severity: `yellow`
- Recommended action: `Rewrite`
- Linear-ready: `True`
- Auto-resolved: `False`
- Reason: Active item contains retired IA, retired terminology, or unsafe language; rewrite or retire before reuse.
- Involved active paths:
  - `EB08_Memory_Source_Confidence_And_Trust_Decay_Prompt` — `docs/codex/batches/EB08_Memory_Source_Confidence_And_Trust_Decay_Prompt.md` (partial_implementation; release proof)

### 184. Retired IA/terminology reference in IRQ-02

- Candidate ID: `AMB28-retired_ia_or_terminology_reference-50178970`
- Evidence type: `retired_ia_or_terminology_reference`
- Severity: `yellow`
- Recommended action: `Rewrite`
- Linear-ready: `True`
- Auto-resolved: `False`
- Reason: Active item contains retired IA, retired terminology, or unsafe language; rewrite or retire before reuse.
- Involved active paths:
  - `IRQ-02` — `prompts/batches/IRQ-02.md` (partial_implementation; release proof)

### 185. Retired IA/terminology reference in SA31

- Candidate ID: `AMB28-retired_ia_or_terminology_reference-50357326`
- Evidence type: `retired_ia_or_terminology_reference`
- Severity: `yellow`
- Recommended action: `Rewrite`
- Linear-ready: `True`
- Auto-resolved: `False`
- Reason: Active item contains retired IA, retired terminology, or unsafe language; rewrite or retire before reuse.
- Involved active paths:
  - `SA31` — `prompts/batches/SA31.md` (partial_implementation; release proof)

### 186. Retired IA/terminology reference in FE-07-ROOT-SURFACES

- Candidate ID: `AMB28-retired_ia_or_terminology_reference-50586272`
- Evidence type: `retired_ia_or_terminology_reference`
- Severity: `yellow`
- Recommended action: `Rewrite`
- Linear-ready: `True`
- Auto-resolved: `False`
- Reason: Active item contains retired IA, retired terminology, or unsafe language; rewrite or retire before reuse.
- Involved active paths:
  - `FE-07-ROOT-SURFACES` — `prompts/batches/amb-fe-be/FE-07-ROOT-SURFACES.md` (partial_implementation; tests)

### 187. Retired IA/terminology reference in START-HERE-REALITY-RECOGNITION-01

- Candidate ID: `AMB28-retired_ia_or_terminology_reference-50636335`
- Evidence type: `retired_ia_or_terminology_reference`
- Severity: `yellow`
- Recommended action: `Rewrite`
- Linear-ready: `True`
- Auto-resolved: `False`
- Reason: Active item contains retired IA, retired terminology, or unsafe language; rewrite or retire before reuse.
- Involved active paths:
  - `START-HERE-REALITY-RECOGNITION-01` — `prompts/batches/START-HERE-REALITY-RECOGNITION-01.md` (partial_implementation; release proof)

### 188. Retired IA/terminology reference in AOS01_AmbitionsOS_Canon_And_Runtime_Contract_Prompt

- Candidate ID: `AMB28-retired_ia_or_terminology_reference-51049485`
- Evidence type: `retired_ia_or_terminology_reference`
- Severity: `yellow`
- Recommended action: `Rewrite`
- Linear-ready: `True`
- Auto-resolved: `False`
- Reason: Active item contains retired IA, retired terminology, or unsafe language; rewrite or retire before reuse.
- Involved active paths:
  - `AOS01_AmbitionsOS_Canon_And_Runtime_Contract_Prompt` — `docs/codex/batches/AOS01_AmbitionsOS_Canon_And_Runtime_Contract_Prompt.md` (partial_implementation; release proof)

### 189. Retired IA/terminology reference in PK26

- Candidate ID: `AMB28-retired_ia_or_terminology_reference-51069940`
- Evidence type: `retired_ia_or_terminology_reference`
- Severity: `yellow`
- Recommended action: `Rewrite`
- Linear-ready: `True`
- Auto-resolved: `False`
- Reason: Active item contains retired IA, retired terminology, or unsafe language; rewrite or retire before reuse.
- Involved active paths:
  - `PK26` — `prompts/batches/PK26.md` (partial_implementation; release proof)

### 190. Retired IA/terminology reference in AOS20_Adaptation_Kernel_Local_Personalization_Prompt

- Candidate ID: `AMB28-retired_ia_or_terminology_reference-51083148`
- Evidence type: `retired_ia_or_terminology_reference`
- Severity: `yellow`
- Recommended action: `Rewrite`
- Linear-ready: `True`
- Auto-resolved: `False`
- Reason: Active item contains retired IA, retired terminology, or unsafe language; rewrite or retire before reuse.
- Involved active paths:
  - `AOS20_Adaptation_Kernel_Local_Personalization_Prompt` — `docs/codex/batches/AOS20_Adaptation_Kernel_Local_Personalization_Prompt.md` (partial_implementation; release proof)

### 191. Retired IA/terminology reference in PFC39

- Candidate ID: `AMB28-retired_ia_or_terminology_reference-51090568`
- Evidence type: `retired_ia_or_terminology_reference`
- Severity: `yellow`
- Recommended action: `Rewrite`
- Linear-ready: `True`
- Auto-resolved: `False`
- Reason: Active item contains retired IA, retired terminology, or unsafe language; rewrite or retire before reuse.
- Involved active paths:
  - `PFC39` — `prompts/batches/PFC39.md` (partial_implementation; release proof)

### 192. Retired IA/terminology reference in CODEX_OS_PEAK_OPERATING_PROTOCOL

- Candidate ID: `AMB28-retired_ia_or_terminology_reference-51148079`
- Evidence type: `retired_ia_or_terminology_reference`
- Severity: `yellow`
- Recommended action: `Rewrite`
- Linear-ready: `True`
- Auto-resolved: `False`
- Reason: Active item contains retired IA, retired terminology, or unsafe language; rewrite or retire before reuse.
- Involved active paths:
  - `CODEX_OS_PEAK_OPERATING_PROTOCOL` — `docs/codex/CODEX_OS_PEAK_OPERATING_PROTOCOL.md` (partial_implementation; release proof)

### 193. Retired IA/terminology reference in FCP05_Start_Here_Surface_Prompt

- Candidate ID: `AMB28-retired_ia_or_terminology_reference-5188732`
- Evidence type: `retired_ia_or_terminology_reference`
- Severity: `yellow`
- Recommended action: `Rewrite`
- Linear-ready: `True`
- Auto-resolved: `False`
- Reason: Active item contains retired IA, retired terminology, or unsafe language; rewrite or retire before reuse.
- Involved active paths:
  - `FCP05_Start_Here_Surface_Prompt` — `docs/codex/batches/FCP05_Start_Here_Surface_Prompt.md` (unknown; release proof)

### 194. Retired IA/terminology reference in EB38_External_Brain_Accessibility_Evidence_Closeout_Prompt

- Candidate ID: `AMB28-retired_ia_or_terminology_reference-52076418`
- Evidence type: `retired_ia_or_terminology_reference`
- Severity: `yellow`
- Recommended action: `Rewrite`
- Linear-ready: `True`
- Auto-resolved: `False`
- Reason: Active item contains retired IA, retired terminology, or unsafe language; rewrite or retire before reuse.
- Involved active paths:
  - `EB38_External_Brain_Accessibility_Evidence_Closeout_Prompt` — `docs/codex/batches/EB38_External_Brain_Accessibility_Evidence_Closeout_Prompt.md` (partial_implementation; release proof)

### 195. Retired IA/terminology reference in AFI15_Founder_Acceptance_Review

- Candidate ID: `AMB28-retired_ia_or_terminology_reference-52252499`
- Evidence type: `retired_ia_or_terminology_reference`
- Severity: `yellow`
- Recommended action: `Rewrite`
- Linear-ready: `True`
- Auto-resolved: `False`
- Reason: Active item contains retired IA, retired terminology, or unsafe language; rewrite or retire before reuse.
- Involved active paths:
  - `AFI15_Founder_Acceptance_Review` — `docs/codex/batches/AFI15_Founder_Acceptance_Review.md` (partial_implementation; release proof)

### 196. Retired IA/terminology reference in PX02_Today_Experience_Operating_Surface_Prompt

- Candidate ID: `AMB28-retired_ia_or_terminology_reference-52272994`
- Evidence type: `retired_ia_or_terminology_reference`
- Severity: `yellow`
- Recommended action: `Rewrite`
- Linear-ready: `True`
- Auto-resolved: `False`
- Reason: Active item contains retired IA, retired terminology, or unsafe language; rewrite or retire before reuse.
- Involved active paths:
  - `PX02_Today_Experience_Operating_Surface_Prompt` — `docs/codex/batches/PX02_Today_Experience_Operating_Surface_Prompt.md` (partial_implementation; release proof)

### 197. Retired IA/terminology reference in EB20_Value_Based_Onboarding_And_First_Week_Success_Prompt

- Candidate ID: `AMB28-retired_ia_or_terminology_reference-52336721`
- Evidence type: `retired_ia_or_terminology_reference`
- Severity: `yellow`
- Recommended action: `Rewrite`
- Linear-ready: `True`
- Auto-resolved: `False`
- Reason: Active item contains retired IA, retired terminology, or unsafe language; rewrite or retire before reuse.
- Involved active paths:
  - `EB20_Value_Based_Onboarding_And_First_Week_Success_Prompt` — `docs/codex/batches/EB20_Value_Based_Onboarding_And_First_Week_Success_Prompt.md` (partial_implementation; release proof)

### 198. Retired IA/terminology reference in PD16_Schedule_Availability_And_Planning_Defaults_Depth_Prompt

- Candidate ID: `AMB28-retired_ia_or_terminology_reference-52391287`
- Evidence type: `retired_ia_or_terminology_reference`
- Severity: `yellow`
- Recommended action: `Rewrite`
- Linear-ready: `True`
- Auto-resolved: `False`
- Reason: Active item contains retired IA, retired terminology, or unsafe language; rewrite or retire before reuse.
- Involved active paths:
  - `PD16_Schedule_Availability_And_Planning_Defaults_Depth_Prompt` — `docs/codex/batches/PD16_Schedule_Availability_And_Planning_Defaults_Depth_Prompt.md` (partial_implementation; release proof)

### 199. Retired IA/terminology reference in PXEQ_VISUAL_SYSTEM_CONSERVATIVE_FUTURISM_RULES

- Candidate ID: `AMB28-retired_ia_or_terminology_reference-52811699`
- Evidence type: `retired_ia_or_terminology_reference`
- Severity: `yellow`
- Recommended action: `Rewrite`
- Linear-ready: `True`
- Auto-resolved: `False`
- Reason: Active item contains retired IA, retired terminology, or unsafe language; rewrite or retire before reuse.
- Involved active paths:
  - `PXEQ_VISUAL_SYSTEM_CONSERVATIVE_FUTURISM_RULES` — `docs/codex/PXEQ_VISUAL_SYSTEM_CONSERVATIVE_FUTURISM_RULES.md` (partial_implementation; source-only)

### 200. Retired IA/terminology reference in AMBITIONSOS_AOS_TRACEABILITY_MATRIX

- Candidate ID: `AMB28-retired_ia_or_terminology_reference-52864019`
- Evidence type: `retired_ia_or_terminology_reference`
- Severity: `yellow`
- Recommended action: `Rewrite`
- Linear-ready: `True`
- Auto-resolved: `False`
- Reason: Active item contains retired IA, retired terminology, or unsafe language; rewrite or retire before reuse.
- Involved active paths:
  - `AMBITIONSOS_AOS_TRACEABILITY_MATRIX` — `docs/codex/AMBITIONSOS_AOS_TRACEABILITY_MATRIX.md` (partial_implementation; release proof)

### 201. Retired IA/terminology reference in PK37

- Candidate ID: `AMB28-retired_ia_or_terminology_reference-52931017`
- Evidence type: `retired_ia_or_terminology_reference`
- Severity: `yellow`
- Recommended action: `Rewrite`
- Linear-ready: `True`
- Auto-resolved: `False`
- Reason: Active item contains retired IA, retired terminology, or unsafe language; rewrite or retire before reuse.
- Involved active paths:
  - `PK37` — `prompts/batches/PK37.md` (partial_implementation; release proof)

### 202. Retired IA/terminology reference in SA08

- Candidate ID: `AMB28-retired_ia_or_terminology_reference-53023688`
- Evidence type: `retired_ia_or_terminology_reference`
- Severity: `yellow`
- Recommended action: `Rewrite`
- Linear-ready: `True`
- Auto-resolved: `False`
- Reason: Active item contains retired IA, retired terminology, or unsafe language; rewrite or retire before reuse.
- Involved active paths:
  - `SA08` — `prompts/batches/SA08.md` (partial_implementation; release proof)

### 203. Retired IA/terminology reference in FOUND_LIFE_LAYER_GATE_MATRIX

- Candidate ID: `AMB28-retired_ia_or_terminology_reference-53324565`
- Evidence type: `retired_ia_or_terminology_reference`
- Severity: `yellow`
- Recommended action: `Rewrite`
- Linear-ready: `True`
- Auto-resolved: `False`
- Reason: Active item contains retired IA, retired terminology, or unsafe language; rewrite or retire before reuse.
- Involved active paths:
  - `FOUND_LIFE_LAYER_GATE_MATRIX` — `docs/codex/FOUND_LIFE_LAYER_GATE_MATRIX.md` (partial_implementation; release proof)

### 204. Retired IA/terminology reference in EB23_Maturity_Levels_Progressive_Disclosure_And_Life_Season_Templates_Prompt

- Candidate ID: `AMB28-retired_ia_or_terminology_reference-53637452`
- Evidence type: `retired_ia_or_terminology_reference`
- Severity: `yellow`
- Recommended action: `Rewrite`
- Linear-ready: `True`
- Auto-resolved: `False`
- Reason: Active item contains retired IA, retired terminology, or unsafe language; rewrite or retire before reuse.
- Involved active paths:
  - `EB23_Maturity_Levels_Progressive_Disclosure_And_Life_Season_Templates_Prompt` — `docs/codex/batches/EB23_Maturity_Levels_Progressive_Disclosure_And_Life_Season_Templates_Prompt.md` (partial_implementation; release proof)

### 205. Retired IA/terminology reference in EB10_Personal_Operating_Manual_Prompt

- Candidate ID: `AMB28-retired_ia_or_terminology_reference-53730152`
- Evidence type: `retired_ia_or_terminology_reference`
- Severity: `yellow`
- Recommended action: `Rewrite`
- Linear-ready: `True`
- Auto-resolved: `False`
- Reason: Active item contains retired IA, retired terminology, or unsafe language; rewrite or retire before reuse.
- Involved active paths:
  - `EB10_Personal_Operating_Manual_Prompt` — `docs/codex/batches/EB10_Personal_Operating_Manual_Prompt.md` (partial_implementation; release proof)

### 206. Retired IA/terminology reference in AOS25_AmbitionsOS_Test_Fixture_Library_Prompt

- Candidate ID: `AMB28-retired_ia_or_terminology_reference-53744920`
- Evidence type: `retired_ia_or_terminology_reference`
- Severity: `yellow`
- Recommended action: `Rewrite`
- Linear-ready: `True`
- Auto-resolved: `False`
- Reason: Active item contains retired IA, retired terminology, or unsafe language; rewrite or retire before reuse.
- Involved active paths:
  - `AOS25_AmbitionsOS_Test_Fixture_Library_Prompt` — `docs/codex/batches/AOS25_AmbitionsOS_Test_Fixture_Library_Prompt.md` (partial_implementation; release proof)

### 207. Retired IA/terminology reference in AOS11_Reality_Drift_Bounded_Reflow_Prompt

- Candidate ID: `AMB28-retired_ia_or_terminology_reference-53747756`
- Evidence type: `retired_ia_or_terminology_reference`
- Severity: `yellow`
- Recommended action: `Rewrite`
- Linear-ready: `True`
- Auto-resolved: `False`
- Reason: Active item contains retired IA, retired terminology, or unsafe language; rewrite or retire before reuse.
- Involved active paths:
  - `AOS11_Reality_Drift_Bounded_Reflow_Prompt` — `docs/codex/batches/AOS11_Reality_Drift_Bounded_Reflow_Prompt.md` (partial_implementation; release proof)

### 208. Retired IA/terminology reference in AOS17_Privacy_Safety_Kernel_Prompt

- Candidate ID: `AMB28-retired_ia_or_terminology_reference-53963184`
- Evidence type: `retired_ia_or_terminology_reference`
- Severity: `yellow`
- Recommended action: `Rewrite`
- Linear-ready: `True`
- Auto-resolved: `False`
- Reason: Active item contains retired IA, retired terminology, or unsafe language; rewrite or retire before reuse.
- Involved active paths:
  - `AOS17_Privacy_Safety_Kernel_Prompt` — `docs/codex/batches/AOS17_Privacy_Safety_Kernel_Prompt.md` (partial_implementation; release proof)

### 209. Retired IA/terminology reference in DAV_PRODUCT_EXPERIENCE_SCORECARD

- Candidate ID: `AMB28-retired_ia_or_terminology_reference-54056456`
- Evidence type: `retired_ia_or_terminology_reference`
- Severity: `yellow`
- Recommended action: `Rewrite`
- Linear-ready: `True`
- Auto-resolved: `False`
- Reason: Active item contains retired IA, retired terminology, or unsafe language; rewrite or retire before reuse.
- Involved active paths:
  - `DAV_PRODUCT_EXPERIENCE_SCORECARD` — `docs/codex/DAV_PRODUCT_EXPERIENCE_SCORECARD.md` (partial_implementation; release proof)

### 210. Retired IA/terminology reference in PK32

- Candidate ID: `AMB28-retired_ia_or_terminology_reference-5426097`
- Evidence type: `retired_ia_or_terminology_reference`
- Severity: `yellow`
- Recommended action: `Rewrite`
- Linear-ready: `True`
- Auto-resolved: `False`
- Reason: Active item contains retired IA, retired terminology, or unsafe language; rewrite or retire before reuse.
- Involved active paths:
  - `PK32` — `prompts/batches/PK32.md` (partial_implementation; release proof)

### 211. Retired IA/terminology reference in HBI-10

- Candidate ID: `AMB28-retired_ia_or_terminology_reference-54457463`
- Evidence type: `retired_ia_or_terminology_reference`
- Severity: `yellow`
- Recommended action: `Rewrite`
- Linear-ready: `True`
- Auto-resolved: `False`
- Reason: Active item contains retired IA, retired terminology, or unsafe language; rewrite or retire before reuse.
- Involved active paths:
  - `HBI-10` — `prompts/batches/HBI-10.md` (partial_implementation; release proof)

### 212. Retired IA/terminology reference in PX19_PXOS_Handoff_Prompt

- Candidate ID: `AMB28-retired_ia_or_terminology_reference-55093711`
- Evidence type: `retired_ia_or_terminology_reference`
- Severity: `yellow`
- Recommended action: `Rewrite`
- Linear-ready: `True`
- Auto-resolved: `False`
- Reason: Active item contains retired IA, retired terminology, or unsafe language; rewrite or retire before reuse.
- Involved active paths:
  - `PX19_PXOS_Handoff_Prompt` — `docs/codex/batches/PX19_PXOS_Handoff_Prompt.md` (partial_implementation; release proof)

### 213. Retired IA/terminology reference in PK23

- Candidate ID: `AMB28-retired_ia_or_terminology_reference-5528428`
- Evidence type: `retired_ia_or_terminology_reference`
- Severity: `yellow`
- Recommended action: `Rewrite`
- Linear-ready: `True`
- Auto-resolved: `False`
- Reason: Active item contains retired IA, retired terminology, or unsafe language; rewrite or retire before reuse.
- Involved active paths:
  - `PK23` — `prompts/batches/PK23.md` (partial_implementation; release proof)

### 214. Retired IA/terminology reference in DAV03_Today_DayTimelineRail_And_HeroStepPanel_Implementation_Prompt

- Candidate ID: `AMB28-retired_ia_or_terminology_reference-55776172`
- Evidence type: `retired_ia_or_terminology_reference`
- Severity: `yellow`
- Recommended action: `Rewrite`
- Linear-ready: `True`
- Auto-resolved: `False`
- Reason: Active item contains retired IA, retired terminology, or unsafe language; rewrite or retire before reuse.
- Involved active paths:
  - `DAV03_Today_DayTimelineRail_And_HeroStepPanel_Implementation_Prompt` — `docs/codex/batches/DAV03_Today_DayTimelineRail_And_HeroStepPanel_Implementation_Prompt.md` (partial_implementation; source-only)

### 215. Retired IA/terminology reference in FCP06_Receipt_Drawer_Trust_Layer_Prompt

- Candidate ID: `AMB28-retired_ia_or_terminology_reference-55851109`
- Evidence type: `retired_ia_or_terminology_reference`
- Severity: `yellow`
- Recommended action: `Rewrite`
- Linear-ready: `True`
- Auto-resolved: `False`
- Reason: Active item contains retired IA, retired terminology, or unsafe language; rewrite or retire before reuse.
- Involved active paths:
  - `FCP06_Receipt_Drawer_Trust_Layer_Prompt` — `docs/codex/batches/FCP06_Receipt_Drawer_Trust_Layer_Prompt.md` (partial_implementation; tests)

### 216. Retired IA/terminology reference in TODAY-REALITY-MERIDIAN-VISUAL-01

- Candidate ID: `AMB28-retired_ia_or_terminology_reference-55910729`
- Evidence type: `retired_ia_or_terminology_reference`
- Severity: `yellow`
- Recommended action: `Rewrite`
- Linear-ready: `True`
- Auto-resolved: `False`
- Reason: Active item contains retired IA, retired terminology, or unsafe language; rewrite or retire before reuse.
- Involved active paths:
  - `TODAY-REALITY-MERIDIAN-VISUAL-01` — `prompts/batches/TODAY-REALITY-MERIDIAN-VISUAL-01.md` (partial_implementation; source-only)

### 217. Retired IA/terminology reference in PXEQ_PRODUCT_EXPERIENCE_EQUIVALENCE_GATE

- Candidate ID: `AMB28-retired_ia_or_terminology_reference-55953974`
- Evidence type: `retired_ia_or_terminology_reference`
- Severity: `yellow`
- Recommended action: `Rewrite`
- Linear-ready: `True`
- Auto-resolved: `False`
- Reason: Active item contains retired IA, retired terminology, or unsafe language; rewrite or retire before reuse.
- Involved active paths:
  - `PXEQ_PRODUCT_EXPERIENCE_EQUIVALENCE_GATE` — `docs/codex/PXEQ_PRODUCT_EXPERIENCE_EQUIVALENCE_GATE.md` (partial_implementation; source-only)

### 218. Retired IA/terminology reference in SA21

- Candidate ID: `AMB28-retired_ia_or_terminology_reference-55979330`
- Evidence type: `retired_ia_or_terminology_reference`
- Severity: `yellow`
- Recommended action: `Rewrite`
- Linear-ready: `True`
- Auto-resolved: `False`
- Reason: Active item contains retired IA, retired terminology, or unsafe language; rewrite or retire before reuse.
- Involved active paths:
  - `SA21` — `prompts/batches/SA21.md` (partial_implementation; release proof)

### 219. Retired IA/terminology reference in MOAT-ALIGNMENT-01

- Candidate ID: `AMB28-retired_ia_or_terminology_reference-56146104`
- Evidence type: `retired_ia_or_terminology_reference`
- Severity: `yellow`
- Recommended action: `Rewrite`
- Linear-ready: `True`
- Auto-resolved: `False`
- Reason: Active item contains retired IA, retired terminology, or unsafe language; rewrite or retire before reuse.
- Involved active paths:
  - `MOAT-ALIGNMENT-01` — `prompts/batches/MOAT-ALIGNMENT-01.md` (partial_implementation; release proof)

### 220. Retired IA/terminology reference in PD18_Product_Depth_Handoff_And_Next_Lane_Readiness_Prompt

- Candidate ID: `AMB28-retired_ia_or_terminology_reference-56530983`
- Evidence type: `retired_ia_or_terminology_reference`
- Severity: `yellow`
- Recommended action: `Rewrite`
- Linear-ready: `True`
- Auto-resolved: `False`
- Reason: Active item contains retired IA, retired terminology, or unsafe language; rewrite or retire before reuse.
- Involved active paths:
  - `PD18_Product_Depth_Handoff_And_Next_Lane_Readiness_Prompt` — `docs/codex/batches/PD18_Product_Depth_Handoff_And_Next_Lane_Readiness_Prompt.md` (partial_implementation; release proof)

### 221. Retired IA/terminology reference in EB12_Memory_Receipts_And_Why_Remembered_This_Prompt

- Candidate ID: `AMB28-retired_ia_or_terminology_reference-57231619`
- Evidence type: `retired_ia_or_terminology_reference`
- Severity: `yellow`
- Recommended action: `Rewrite`
- Linear-ready: `True`
- Auto-resolved: `False`
- Reason: Active item contains retired IA, retired terminology, or unsafe language; rewrite or retire before reuse.
- Involved active paths:
  - `EB12_Memory_Receipts_And_Why_Remembered_This_Prompt` — `docs/codex/batches/EB12_Memory_Receipts_And_Why_Remembered_This_Prompt.md` (partial_implementation; release proof)

### 222. Retired IA/terminology reference in LDI21

- Candidate ID: `AMB28-retired_ia_or_terminology_reference-57481644`
- Evidence type: `retired_ia_or_terminology_reference`
- Severity: `yellow`
- Recommended action: `Rewrite`
- Linear-ready: `True`
- Auto-resolved: `False`
- Reason: Active item contains retired IA, retired terminology, or unsafe language; rewrite or retire before reuse.
- Involved active paths:
  - `LDI21` — `prompts/batches/LDI21.md` (partial_implementation; release proof)

### 223. Retired IA/terminology reference in SA20

- Candidate ID: `AMB28-retired_ia_or_terminology_reference-57943936`
- Evidence type: `retired_ia_or_terminology_reference`
- Severity: `yellow`
- Recommended action: `Rewrite`
- Linear-ready: `True`
- Auto-resolved: `False`
- Reason: Active item contains retired IA, retired terminology, or unsafe language; rewrite or retire before reuse.
- Involved active paths:
  - `SA20` — `prompts/batches/SA20.md` (partial_implementation; release proof)

### 224. Retired IA/terminology reference in EB05_Capture_Clusters_Review_Bundles_And_Open_Loops_Prompt

- Candidate ID: `AMB28-retired_ia_or_terminology_reference-58138522`
- Evidence type: `retired_ia_or_terminology_reference`
- Severity: `yellow`
- Recommended action: `Rewrite`
- Linear-ready: `True`
- Auto-resolved: `False`
- Reason: Active item contains retired IA, retired terminology, or unsafe language; rewrite or retire before reuse.
- Involved active paths:
  - `EB05_Capture_Clusters_Review_Bundles_And_Open_Loops_Prompt` — `docs/codex/batches/EB05_Capture_Clusters_Review_Bundles_And_Open_Loops_Prompt.md` (partial_implementation; release proof)

### 225. Retired IA/terminology reference in PXEQ_LIVING_INTERFACE_RUBRIC

- Candidate ID: `AMB28-retired_ia_or_terminology_reference-58300853`
- Evidence type: `retired_ia_or_terminology_reference`
- Severity: `yellow`
- Recommended action: `Rewrite`
- Linear-ready: `True`
- Auto-resolved: `False`
- Reason: Active item contains retired IA, retired terminology, or unsafe language; rewrite or retire before reuse.
- Involved active paths:
  - `PXEQ_LIVING_INTERFACE_RUBRIC` — `docs/codex/PXEQ_LIVING_INTERFACE_RUBRIC.md` (partial_implementation; source-only)

### 226. Retired IA/terminology reference in FCP30

- Candidate ID: `AMB28-retired_ia_or_terminology_reference-58318554`
- Evidence type: `retired_ia_or_terminology_reference`
- Severity: `yellow`
- Recommended action: `Rewrite`
- Linear-ready: `True`
- Auto-resolved: `False`
- Reason: Active item contains retired IA, retired terminology, or unsafe language; rewrite or retire before reuse.
- Involved active paths:
  - `FCP30` — `prompts/batches/FCP30.md` (partial_implementation; release proof)

### 227. Retired IA/terminology reference in PX17_Release_Truth_Product_Messaging_Prompt

- Candidate ID: `AMB28-retired_ia_or_terminology_reference-58729585`
- Evidence type: `retired_ia_or_terminology_reference`
- Severity: `yellow`
- Recommended action: `Rewrite`
- Linear-ready: `True`
- Auto-resolved: `False`
- Reason: Active item contains retired IA, retired terminology, or unsafe language; rewrite or retire before reuse.
- Involved active paths:
  - `PX17_Release_Truth_Product_Messaging_Prompt` — `docs/codex/batches/PX17_Release_Truth_Product_Messaging_Prompt.md` (partial_implementation; release proof)

### 228. Retired IA/terminology reference in PFC12_App_Groups_Shared_Storage_Boundary_Prompt

- Candidate ID: `AMB28-retired_ia_or_terminology_reference-58750761`
- Evidence type: `retired_ia_or_terminology_reference`
- Severity: `yellow`
- Recommended action: `Rewrite`
- Linear-ready: `True`
- Auto-resolved: `False`
- Reason: Active item contains retired IA, retired terminology, or unsafe language; rewrite or retire before reuse.
- Involved active paths:
  - `PFC12_App_Groups_Shared_Storage_Boundary_Prompt` — `docs/codex/batches/PFC12_App_Groups_Shared_Storage_Boundary_Prompt.md` (unknown; release proof)

### 229. Retired IA/terminology reference in PK30

- Candidate ID: `AMB28-retired_ia_or_terminology_reference-58843216`
- Evidence type: `retired_ia_or_terminology_reference`
- Severity: `yellow`
- Recommended action: `Rewrite`
- Linear-ready: `True`
- Auto-resolved: `False`
- Reason: Active item contains retired IA, retired terminology, or unsafe language; rewrite or retire before reuse.
- Involved active paths:
  - `PK30` — `prompts/batches/PK30.md` (partial_implementation; release proof)

### 230. Retired IA/terminology reference in AOS14_Recommendation_Start_Here_Kernel_Prompt

- Candidate ID: `AMB28-retired_ia_or_terminology_reference-59048673`
- Evidence type: `retired_ia_or_terminology_reference`
- Severity: `yellow`
- Recommended action: `Rewrite`
- Linear-ready: `True`
- Auto-resolved: `False`
- Reason: Active item contains retired IA, retired terminology, or unsafe language; rewrite or retire before reuse.
- Involved active paths:
  - `AOS14_Recommendation_Start_Here_Kernel_Prompt` — `docs/codex/batches/AOS14_Recommendation_Start_Here_Kernel_Prompt.md` (partial_implementation; release proof)

### 231. Retired IA/terminology reference in EB34_External_Brain_Command_Surface_Integration_Prompt

- Candidate ID: `AMB28-retired_ia_or_terminology_reference-59589229`
- Evidence type: `retired_ia_or_terminology_reference`
- Severity: `yellow`
- Recommended action: `Rewrite`
- Linear-ready: `True`
- Auto-resolved: `False`
- Reason: Active item contains retired IA, retired terminology, or unsafe language; rewrite or retire before reuse.
- Involved active paths:
  - `EB34_External_Brain_Command_Surface_Integration_Prompt` — `docs/codex/batches/EB34_External_Brain_Command_Surface_Integration_Prompt.md` (partial_implementation; release proof)

### 232. Retired IA/terminology reference in LDI17

- Candidate ID: `AMB28-retired_ia_or_terminology_reference-59655315`
- Evidence type: `retired_ia_or_terminology_reference`
- Severity: `yellow`
- Recommended action: `Rewrite`
- Linear-ready: `True`
- Auto-resolved: `False`
- Reason: Active item contains retired IA, retired terminology, or unsafe language; rewrite or retire before reuse.
- Involved active paths:
  - `LDI17` — `prompts/batches/LDI17.md` (partial_implementation; release proof)

### 233. Retired IA/terminology reference in SA13

- Candidate ID: `AMB28-retired_ia_or_terminology_reference-59656994`
- Evidence type: `retired_ia_or_terminology_reference`
- Severity: `yellow`
- Recommended action: `Rewrite`
- Linear-ready: `True`
- Auto-resolved: `False`
- Reason: Active item contains retired IA, retired terminology, or unsafe language; rewrite or retire before reuse.
- Involved active paths:
  - `SA13` — `prompts/batches/SA13.md` (partial_implementation; release proof)

### 234. Retired IA/terminology reference in AOS05_Starting_Position_Kernel_Prompt

- Candidate ID: `AMB28-retired_ia_or_terminology_reference-59788611`
- Evidence type: `retired_ia_or_terminology_reference`
- Severity: `yellow`
- Recommended action: `Rewrite`
- Linear-ready: `True`
- Auto-resolved: `False`
- Reason: Active item contains retired IA, retired terminology, or unsafe language; rewrite or retire before reuse.
- Involved active paths:
  - `AOS05_Starting_Position_Kernel_Prompt` — `docs/codex/batches/AOS05_Starting_Position_Kernel_Prompt.md` (partial_implementation; release proof)

### 235. Retired IA/terminology reference in SA28_LDI15_AOS24_MANIFEST_RERUN_DIRECTIVE

- Candidate ID: `AMB28-retired_ia_or_terminology_reference-59925218`
- Evidence type: `retired_ia_or_terminology_reference`
- Severity: `yellow`
- Recommended action: `Rewrite`
- Linear-ready: `True`
- Auto-resolved: `False`
- Reason: Active item contains retired IA, retired terminology, or unsafe language; rewrite or retire before reuse.
- Involved active paths:
  - `SA28_LDI15_AOS24_MANIFEST_RERUN_DIRECTIVE` — `docs/codex/SA28_LDI15_AOS24_MANIFEST_RERUN_DIRECTIVE.md` (partial_implementation; release proof)

### 236. Retired IA/terminology reference in SA28

- Candidate ID: `AMB28-retired_ia_or_terminology_reference-60019069`
- Evidence type: `retired_ia_or_terminology_reference`
- Severity: `yellow`
- Recommended action: `Rewrite`
- Linear-ready: `True`
- Auto-resolved: `False`
- Reason: Active item contains retired IA, retired terminology, or unsafe language; rewrite or retire before reuse.
- Involved active paths:
  - `SA28` — `prompts/batches/SA28.md` (partial_implementation; release proof)

### 237. Retired IA/terminology reference in AMB-POST23-TRUTH-AUDIT-REPAIR-ROUTING

- Candidate ID: `AMB28-retired_ia_or_terminology_reference-60248807`
- Evidence type: `retired_ia_or_terminology_reference`
- Severity: `yellow`
- Recommended action: `Rewrite`
- Linear-ready: `True`
- Auto-resolved: `False`
- Reason: Active item contains retired IA, retired terminology, or unsafe language; rewrite or retire before reuse.
- Involved active paths:
  - `AMB-POST23-TRUTH-AUDIT-REPAIR-ROUTING` — `docs/codex/batch-trains/post-23-truth-audit/AMB-POST23-TRUTH-AUDIT-REPAIR-ROUTING.md` (partial_implementation; release proof)

### 238. Retired IA/terminology reference in FL02_Life_Inventory_Object_Model_Prompt

- Candidate ID: `AMB28-retired_ia_or_terminology_reference-60389030`
- Evidence type: `retired_ia_or_terminology_reference`
- Severity: `yellow`
- Recommended action: `Rewrite`
- Linear-ready: `True`
- Auto-resolved: `False`
- Reason: Active item contains retired IA, retired terminology, or unsafe language; rewrite or retire before reuse.
- Involved active paths:
  - `FL02_Life_Inventory_Object_Model_Prompt` — `docs/codex/batches/FL02_Life_Inventory_Object_Model_Prompt.md` (unknown; audit)

### 239. Retired IA/terminology reference in PX01_PX20_PRODUCT_EXPERIENCE_OS_TRAIN

- Candidate ID: `AMB28-retired_ia_or_terminology_reference-60597020`
- Evidence type: `retired_ia_or_terminology_reference`
- Severity: `yellow`
- Recommended action: `Rewrite`
- Linear-ready: `True`
- Auto-resolved: `False`
- Reason: Active item contains retired IA, retired terminology, or unsafe language; rewrite or retire before reuse.
- Involved active paths:
  - `PX01_PX20_PRODUCT_EXPERIENCE_OS_TRAIN` — `docs/codex/batch-trains/PX01_PX20_PRODUCT_EXPERIENCE_OS_TRAIN.md` (partial_implementation; release proof)

### 240. Retired IA/terminology reference in BATCH-13-canon-batch-10-life-graph-foundation

- Candidate ID: `AMB28-retired_ia_or_terminology_reference-6071006`
- Evidence type: `retired_ia_or_terminology_reference`
- Severity: `yellow`
- Recommended action: `Rewrite`
- Linear-ready: `True`
- Auto-resolved: `False`
- Reason: Active item contains retired IA, retired terminology, or unsafe language; rewrite or retire before reuse.
- Involved active paths:
  - `BATCH-13-canon-batch-10-life-graph-foundation` — `docs/codex/batches/BATCH-13-canon-batch-10-life-graph-foundation.md` (unknown; audit)

### 241. Retired IA/terminology reference in SA12

- Candidate ID: `AMB28-retired_ia_or_terminology_reference-61026368`
- Evidence type: `retired_ia_or_terminology_reference`
- Severity: `yellow`
- Recommended action: `Rewrite`
- Linear-ready: `True`
- Auto-resolved: `False`
- Reason: Active item contains retired IA, retired terminology, or unsafe language; rewrite or retire before reuse.
- Involved active paths:
  - `SA12` — `prompts/batches/SA12.md` (partial_implementation; release proof)

### 242. Retired IA/terminology reference in AQOS01_AQOS30_AUTONOMOUS_QUALITY_TRAIN

- Candidate ID: `AMB28-retired_ia_or_terminology_reference-62169114`
- Evidence type: `retired_ia_or_terminology_reference`
- Severity: `yellow`
- Recommended action: `Rewrite`
- Linear-ready: `True`
- Auto-resolved: `False`
- Reason: Active item contains retired IA, retired terminology, or unsafe language; rewrite or retire before reuse.
- Involved active paths:
  - `AQOS01_AQOS30_AUTONOMOUS_QUALITY_TRAIN` — `docs/codex/quality/AQOS01_AQOS30_AUTONOMOUS_QUALITY_TRAIN.md` (unknown; release proof)

### 243. Retired IA/terminology reference in MOAT-MOONSHOT-PROOF-PATH-01

- Candidate ID: `AMB28-retired_ia_or_terminology_reference-62392571`
- Evidence type: `retired_ia_or_terminology_reference`
- Severity: `yellow`
- Recommended action: `Rewrite`
- Linear-ready: `True`
- Auto-resolved: `False`
- Reason: Active item contains retired IA, retired terminology, or unsafe language; rewrite or retire before reuse.
- Involved active paths:
  - `MOAT-MOONSHOT-PROOF-PATH-01` — `prompts/batches/MOAT-MOONSHOT-PROOF-PATH-01.md` (partial_implementation; release proof)

### 244. Retired IA/terminology reference in AOS25

- Candidate ID: `AMB28-retired_ia_or_terminology_reference-62580931`
- Evidence type: `retired_ia_or_terminology_reference`
- Severity: `yellow`
- Recommended action: `Rewrite`
- Linear-ready: `True`
- Auto-resolved: `False`
- Reason: Active item contains retired IA, retired terminology, or unsafe language; rewrite or retire before reuse.
- Involved active paths:
  - `AOS25` — `prompts/batches/AOS25.md` (partial_implementation; release proof)

### 245. Retired IA/terminology reference in MOAT-GOAL-REALITY-GOALS-BRIDGE-05

- Candidate ID: `AMB28-retired_ia_or_terminology_reference-63186130`
- Evidence type: `retired_ia_or_terminology_reference`
- Severity: `yellow`
- Recommended action: `Rewrite`
- Linear-ready: `True`
- Auto-resolved: `False`
- Reason: Active item contains retired IA, retired terminology, or unsafe language; rewrite or retire before reuse.
- Involved active paths:
  - `MOAT-GOAL-REALITY-GOALS-BRIDGE-05` — `prompts/batches/MOAT-GOAL-REALITY-GOALS-BRIDGE-05.md` (partial_implementation; release proof)

### 246. Retired IA/terminology reference in DAV_DYNAMIC_VISUAL_SOURCE_TRUTH_AND_SURFACE_MAP

- Candidate ID: `AMB28-retired_ia_or_terminology_reference-63264072`
- Evidence type: `retired_ia_or_terminology_reference`
- Severity: `yellow`
- Recommended action: `Rewrite`
- Linear-ready: `True`
- Auto-resolved: `False`
- Reason: Active item contains retired IA, retired terminology, or unsafe language; rewrite or retire before reuse.
- Involved active paths:
  - `DAV_DYNAMIC_VISUAL_SOURCE_TRUTH_AND_SURFACE_MAP` — `docs/codex/DAV_DYNAMIC_VISUAL_SOURCE_TRUTH_AND_SURFACE_MAP.md` (partial_implementation; release proof)

### 247. Retired IA/terminology reference in OBJECT_FRONTEND_GREEN_YELLOW_RED_RUBRIC

- Candidate ID: `AMB28-retired_ia_or_terminology_reference-6343109`
- Evidence type: `retired_ia_or_terminology_reference`
- Severity: `yellow`
- Recommended action: `Rewrite`
- Linear-ready: `True`
- Auto-resolved: `False`
- Reason: Active item contains retired IA, retired terminology, or unsafe language; rewrite or retire before reuse.
- Involved active paths:
  - `OBJECT_FRONTEND_GREEN_YELLOW_RED_RUBRIC` — `docs/codex/frontend/OBJECT_FRONTEND_GREEN_YELLOW_RED_RUBRIC.md` (partial_implementation; screenshot)

### 248. Retired IA/terminology reference in PK20

- Candidate ID: `AMB28-retired_ia_or_terminology_reference-63800692`
- Evidence type: `retired_ia_or_terminology_reference`
- Severity: `yellow`
- Recommended action: `Rewrite`
- Linear-ready: `True`
- Auto-resolved: `False`
- Reason: Active item contains retired IA, retired terminology, or unsafe language; rewrite or retire before reuse.
- Involved active paths:
  - `PK20` — `prompts/batches/PK20.md` (partial_implementation; release proof)

### 249. Retired IA/terminology reference in FRONTEND_EXCELLENCE_GATE_MATRIX

- Candidate ID: `AMB28-retired_ia_or_terminology_reference-63853217`
- Evidence type: `retired_ia_or_terminology_reference`
- Severity: `yellow`
- Recommended action: `Rewrite`
- Linear-ready: `True`
- Auto-resolved: `False`
- Reason: Active item contains retired IA, retired terminology, or unsafe language; rewrite or retire before reuse.
- Involved active paths:
  - `FRONTEND_EXCELLENCE_GATE_MATRIX` — `docs/codex/FRONTEND_EXCELLENCE_GATE_MATRIX.md` (partial_implementation; release proof)

### 250. Retired IA/terminology reference in PK27

- Candidate ID: `AMB28-retired_ia_or_terminology_reference-64467659`
- Evidence type: `retired_ia_or_terminology_reference`
- Severity: `yellow`
- Recommended action: `Rewrite`
- Linear-ready: `True`
- Auto-resolved: `False`
- Reason: Active item contains retired IA, retired terminology, or unsafe language; rewrite or retire before reuse.
- Involved active paths:
  - `PK27` — `prompts/batches/PK27.md` (partial_implementation; release proof)

### 251. Retired IA/terminology reference in SA18

- Candidate ID: `AMB28-retired_ia_or_terminology_reference-6488913`
- Evidence type: `retired_ia_or_terminology_reference`
- Severity: `yellow`
- Recommended action: `Rewrite`
- Linear-ready: `True`
- Auto-resolved: `False`
- Reason: Active item contains retired IA, retired terminology, or unsafe language; rewrite or retire before reuse.
- Involved active paths:
  - `SA18` — `prompts/batches/SA18.md` (partial_implementation; release proof)

### 252. Retired IA/terminology reference in PX16_User_Facing_AI_Trust_And_Recommendation_Copy_Prompt

- Candidate ID: `AMB28-retired_ia_or_terminology_reference-65305827`
- Evidence type: `retired_ia_or_terminology_reference`
- Severity: `yellow`
- Recommended action: `Rewrite`
- Linear-ready: `True`
- Auto-resolved: `False`
- Reason: Active item contains retired IA, retired terminology, or unsafe language; rewrite or retire before reuse.
- Involved active paths:
  - `PX16_User_Facing_AI_Trust_And_Recommendation_Copy_Prompt` — `docs/codex/batches/PX16_User_Facing_AI_Trust_And_Recommendation_Copy_Prompt.md` (partial_implementation; release proof)

### 253. Retired IA/terminology reference in OBJECT-OS-CANON-01

- Candidate ID: `AMB28-retired_ia_or_terminology_reference-65583902`
- Evidence type: `retired_ia_or_terminology_reference`
- Severity: `yellow`
- Recommended action: `Rewrite`
- Linear-ready: `True`
- Auto-resolved: `False`
- Reason: Active item contains retired IA, retired terminology, or unsafe language; rewrite or retire before reuse.
- Involved active paths:
  - `OBJECT-OS-CANON-01` — `prompts/batches/OBJECT-OS-CANON-01.md` (partial_implementation; release proof)

### 254. Retired IA/terminology reference in FCP08_Ambition_Meridian_Shell_Prompt

- Candidate ID: `AMB28-retired_ia_or_terminology_reference-6564901`
- Evidence type: `retired_ia_or_terminology_reference`
- Severity: `yellow`
- Recommended action: `Rewrite`
- Linear-ready: `True`
- Auto-resolved: `False`
- Reason: Active item contains retired IA, retired terminology, or unsafe language; rewrite or retire before reuse.
- Involved active paths:
  - `FCP08_Ambition_Meridian_Shell_Prompt` — `docs/codex/batches/FCP08_Ambition_Meridian_Shell_Prompt.md` (unknown; tests)

### 255. Retired IA/terminology reference in MEG01_ADVANCED_RENDERING_ELIGIBILITY_GATE

- Candidate ID: `AMB28-retired_ia_or_terminology_reference-65922487`
- Evidence type: `retired_ia_or_terminology_reference`
- Severity: `yellow`
- Recommended action: `Rewrite`
- Linear-ready: `True`
- Auto-resolved: `False`
- Reason: Active item contains retired IA, retired terminology, or unsafe language; rewrite or retire before reuse.
- Involved active paths:
  - `MEG01_ADVANCED_RENDERING_ELIGIBILITY_GATE` — `docs/codex/visual-quality/MEG01_ADVANCED_RENDERING_ELIGIBILITY_GATE.md` (partial_implementation; release proof)

### 256. Retired IA/terminology reference in EB35_External_Brain_Preview_Fixtures_And_Scenario_Library_Prompt

- Candidate ID: `AMB28-retired_ia_or_terminology_reference-66909160`
- Evidence type: `retired_ia_or_terminology_reference`
- Severity: `yellow`
- Recommended action: `Rewrite`
- Linear-ready: `True`
- Auto-resolved: `False`
- Reason: Active item contains retired IA, retired terminology, or unsafe language; rewrite or retire before reuse.
- Involved active paths:
  - `EB35_External_Brain_Preview_Fixtures_And_Scenario_Library_Prompt` — `docs/codex/batches/EB35_External_Brain_Preview_Fixtures_And_Scenario_Library_Prompt.md` (partial_implementation; release proof)

### 257. Retired IA/terminology reference in SA27

- Candidate ID: `AMB28-retired_ia_or_terminology_reference-66974132`
- Evidence type: `retired_ia_or_terminology_reference`
- Severity: `yellow`
- Recommended action: `Rewrite`
- Linear-ready: `True`
- Auto-resolved: `False`
- Reason: Active item contains retired IA, retired terminology, or unsafe language; rewrite or retire before reuse.
- Involved active paths:
  - `SA27` — `prompts/batches/SA27.md` (partial_implementation; release proof)

### 258. Retired IA/terminology reference in BATCH-16-canon-batch-13-shared-life-household-intelligence

- Candidate ID: `AMB28-retired_ia_or_terminology_reference-67708500`
- Evidence type: `retired_ia_or_terminology_reference`
- Severity: `yellow`
- Recommended action: `Rewrite`
- Linear-ready: `True`
- Auto-resolved: `False`
- Reason: Active item contains retired IA, retired terminology, or unsafe language; rewrite or retire before reuse.
- Involved active paths:
  - `BATCH-16-canon-batch-13-shared-life-household-intelligence` — `docs/codex/batches/BATCH-16-canon-batch-13-shared-life-household-intelligence.md` (unknown; audit)

### 259. Retired IA/terminology reference in SA29

- Candidate ID: `AMB28-retired_ia_or_terminology_reference-67775648`
- Evidence type: `retired_ia_or_terminology_reference`
- Severity: `yellow`
- Recommended action: `Rewrite`
- Linear-ready: `True`
- Auto-resolved: `False`
- Reason: Active item contains retired IA, retired terminology, or unsafe language; rewrite or retire before reuse.
- Involved active paths:
  - `SA29` — `prompts/batches/SA29.md` (partial_implementation; release proof)

### 260. Retired IA/terminology reference in PXOS_DRIFT_DETECTION_PROTOCOL

- Candidate ID: `AMB28-retired_ia_or_terminology_reference-68008036`
- Evidence type: `retired_ia_or_terminology_reference`
- Severity: `yellow`
- Recommended action: `Rewrite`
- Linear-ready: `True`
- Auto-resolved: `False`
- Reason: Active item contains retired IA, retired terminology, or unsafe language; rewrite or retire before reuse.
- Involved active paths:
  - `PXOS_DRIFT_DETECTION_PROTOCOL` — `docs/codex/PXOS_DRIFT_DETECTION_PROTOCOL.md` (unknown; release proof)

### 261. Retired IA/terminology reference in AMB-POST23-TRUTH-AUDIT-MANIFEST

- Candidate ID: `AMB28-retired_ia_or_terminology_reference-6816093`
- Evidence type: `retired_ia_or_terminology_reference`
- Severity: `yellow`
- Recommended action: `Rewrite`
- Linear-ready: `True`
- Auto-resolved: `False`
- Reason: Active item contains retired IA, retired terminology, or unsafe language; rewrite or retire before reuse.
- Involved active paths:
  - `AMB-POST23-TRUTH-AUDIT-MANIFEST` — `docs/codex/batch-trains/post-23-truth-audit/AMB-POST23-TRUTH-AUDIT-MANIFEST.md` (partial_implementation; release proof)

### 262. Retired IA/terminology reference in AQOS_REQUIRED_EVIDENCE_MATRIX

- Candidate ID: `AMB28-retired_ia_or_terminology_reference-68240898`
- Evidence type: `retired_ia_or_terminology_reference`
- Severity: `yellow`
- Recommended action: `Rewrite`
- Linear-ready: `True`
- Auto-resolved: `False`
- Reason: Active item contains retired IA, retired terminology, or unsafe language; rewrite or retire before reuse.
- Involved active paths:
  - `AQOS_REQUIRED_EVIDENCE_MATRIX` — `docs/codex/quality/AQOS_REQUIRED_EVIDENCE_MATRIX.md` (partial_implementation; release proof)

### 263. Retired IA/terminology reference in SA26

- Candidate ID: `AMB28-retired_ia_or_terminology_reference-68542956`
- Evidence type: `retired_ia_or_terminology_reference`
- Severity: `yellow`
- Recommended action: `Rewrite`
- Linear-ready: `True`
- Auto-resolved: `False`
- Reason: Active item contains retired IA, retired terminology, or unsafe language; rewrite or retire before reuse.
- Involved active paths:
  - `SA26` — `prompts/batches/SA26.md` (partial_implementation; release proof)

### 264. Retired IA/terminology reference in AMB-ISSUE-TEMPLATES

- Candidate ID: `AMB28-retired_ia_or_terminology_reference-68736622`
- Evidence type: `retired_ia_or_terminology_reference`
- Severity: `yellow`
- Recommended action: `Rewrite`
- Linear-ready: `True`
- Auto-resolved: `False`
- Reason: Active item contains retired IA, retired terminology, or unsafe language; rewrite or retire before reuse.
- Involved active paths:
  - `AMB-ISSUE-TEMPLATES` — `docs/codex/linear-templates/AMB-ISSUE-TEMPLATES.md` (partial_implementation; release proof)

### 265. Retired IA/terminology reference in PK41

- Candidate ID: `AMB28-retired_ia_or_terminology_reference-68794137`
- Evidence type: `retired_ia_or_terminology_reference`
- Severity: `yellow`
- Recommended action: `Rewrite`
- Linear-ready: `True`
- Auto-resolved: `False`
- Reason: Active item contains retired IA, retired terminology, or unsafe language; rewrite or retire before reuse.
- Involved active paths:
  - `PK41` — `prompts/batches/PK41.md` (partial_implementation; release proof)

### 266. Retired IA/terminology reference in AMB-FILE-BY-FILE-REPO-AUDIT-01

- Candidate ID: `AMB28-retired_ia_or_terminology_reference-69422194`
- Evidence type: `retired_ia_or_terminology_reference`
- Severity: `yellow`
- Recommended action: `Rewrite`
- Linear-ready: `True`
- Auto-resolved: `False`
- Reason: Active item contains retired IA, retired terminology, or unsafe language; rewrite or retire before reuse.
- Involved active paths:
  - `AMB-FILE-BY-FILE-REPO-AUDIT-01` — `prompts/batches/AMB-FILE-BY-FILE-REPO-AUDIT-01.md` (partial_implementation; release proof)

### 267. Retired IA/terminology reference in AMBITIONS_OBJECT_OS_CANON

- Candidate ID: `AMB28-retired_ia_or_terminology_reference-6967424`
- Evidence type: `retired_ia_or_terminology_reference`
- Severity: `yellow`
- Recommended action: `Rewrite`
- Linear-ready: `True`
- Auto-resolved: `False`
- Reason: Active item contains retired IA, retired terminology, or unsafe language; rewrite or retire before reuse.
- Involved active paths:
  - `AMBITIONS_OBJECT_OS_CANON` — `docs/codex/AMBITIONS_OBJECT_OS_CANON.md` (partial_implementation; release proof)

### 268. Retired IA/terminology reference in PX05_Plan_Life_Shape_Experience_Prompt

- Candidate ID: `AMB28-retired_ia_or_terminology_reference-70102959`
- Evidence type: `retired_ia_or_terminology_reference`
- Severity: `yellow`
- Recommended action: `Rewrite`
- Linear-ready: `True`
- Auto-resolved: `False`
- Reason: Active item contains retired IA, retired terminology, or unsafe language; rewrite or retire before reuse.
- Involved active paths:
  - `PX05_Plan_Life_Shape_Experience_Prompt` — `docs/codex/batches/PX05_Plan_Life_Shape_Experience_Prompt.md` (partial_implementation; release proof)

### 269. Retired IA/terminology reference in PK00_PK41_PLATFORM_KERNEL_TRAIN

- Candidate ID: `AMB28-retired_ia_or_terminology_reference-70257033`
- Evidence type: `retired_ia_or_terminology_reference`
- Severity: `yellow`
- Recommended action: `Rewrite`
- Linear-ready: `True`
- Auto-resolved: `False`
- Reason: Active item contains retired IA, retired terminology, or unsafe language; rewrite or retire before reuse.
- Involved active paths:
  - `PK00_PK41_PLATFORM_KERNEL_TRAIN` — `docs/codex/batch-trains/PK00_PK41_PLATFORM_KERNEL_TRAIN.md` (partial_implementation; release proof)

### 270. Retired IA/terminology reference in SIG_SIGNATURE_EXPERIENCE_RUNBOOK

- Candidate ID: `AMB28-retired_ia_or_terminology_reference-70581243`
- Evidence type: `retired_ia_or_terminology_reference`
- Severity: `yellow`
- Recommended action: `Rewrite`
- Linear-ready: `True`
- Auto-resolved: `False`
- Reason: Active item contains retired IA, retired terminology, or unsafe language; rewrite or retire before reuse.
- Involved active paths:
  - `SIG_SIGNATURE_EXPERIENCE_RUNBOOK` — `docs/codex/SIG_SIGNATURE_EXPERIENCE_RUNBOOK.md` (partial_implementation; source-only)

### 271. Retired IA/terminology reference in AFI09_Time_LifeShape_Field

- Candidate ID: `AMB28-retired_ia_or_terminology_reference-70657282`
- Evidence type: `retired_ia_or_terminology_reference`
- Severity: `yellow`
- Recommended action: `Rewrite`
- Linear-ready: `True`
- Auto-resolved: `False`
- Reason: Active item contains retired IA, retired terminology, or unsafe language; rewrite or retire before reuse.
- Involved active paths:
  - `AFI09_Time_LifeShape_Field` — `docs/codex/batches/AFI09_Time_LifeShape_Field.md` (partial_implementation; release proof)

### 272. Retired IA/terminology reference in EB16_Private_Mode_And_Sensitive_Area_Controls_Prompt

- Candidate ID: `AMB28-retired_ia_or_terminology_reference-7096295`
- Evidence type: `retired_ia_or_terminology_reference`
- Severity: `yellow`
- Recommended action: `Rewrite`
- Linear-ready: `True`
- Auto-resolved: `False`
- Reason: Active item contains retired IA, retired terminology, or unsafe language; rewrite or retire before reuse.
- Involved active paths:
  - `EB16_Private_Mode_And_Sensitive_Area_Controls_Prompt` — `docs/codex/batches/EB16_Private_Mode_And_Sensitive_Area_Controls_Prompt.md` (partial_implementation; release proof)

### 273. Retired IA/terminology reference in OBJECT_OS_MOTION_GRAMMAR

- Candidate ID: `AMB28-retired_ia_or_terminology_reference-7252148`
- Evidence type: `retired_ia_or_terminology_reference`
- Severity: `yellow`
- Recommended action: `Rewrite`
- Linear-ready: `True`
- Auto-resolved: `False`
- Reason: Active item contains retired IA, retired terminology, or unsafe language; rewrite or retire before reuse.
- Involved active paths:
  - `OBJECT_OS_MOTION_GRAMMAR` — `docs/codex/OBJECT_OS_MOTION_GRAMMAR.md` (partial_implementation; source-only)

### 274. Retired IA/terminology reference in PD01_Product_Depth_Canon_Inventory_And_Ownership_Map_Prompt

- Candidate ID: `AMB28-retired_ia_or_terminology_reference-72536117`
- Evidence type: `retired_ia_or_terminology_reference`
- Severity: `yellow`
- Recommended action: `Rewrite`
- Linear-ready: `True`
- Auto-resolved: `False`
- Reason: Active item contains retired IA, retired terminology, or unsafe language; rewrite or retire before reuse.
- Involved active paths:
  - `PD01_Product_Depth_Canon_Inventory_And_Ownership_Map_Prompt` — `docs/codex/batches/PD01_Product_Depth_Canon_Inventory_And_Ownership_Map_Prompt.md` (partial_implementation; release proof)

### 275. Retired IA/terminology reference in AFI06_Today_Reality_Meridian

- Candidate ID: `AMB28-retired_ia_or_terminology_reference-72736148`
- Evidence type: `retired_ia_or_terminology_reference`
- Severity: `yellow`
- Recommended action: `Rewrite`
- Linear-ready: `True`
- Auto-resolved: `False`
- Reason: Active item contains retired IA, retired terminology, or unsafe language; rewrite or retire before reuse.
- Involved active paths:
  - `AFI06_Today_Reality_Meridian` — `docs/codex/batches/AFI06_Today_Reality_Meridian.md` (partial_implementation; tests)

### 276. Retired IA/terminology reference in PFC37

- Candidate ID: `AMB28-retired_ia_or_terminology_reference-72798018`
- Evidence type: `retired_ia_or_terminology_reference`
- Severity: `yellow`
- Recommended action: `Rewrite`
- Linear-ready: `True`
- Auto-resolved: `False`
- Reason: Active item contains retired IA, retired terminology, or unsafe language; rewrite or retire before reuse.
- Involved active paths:
  - `PFC37` — `prompts/batches/PFC37.md` (partial_implementation; release proof)

### 277. Retired IA/terminology reference in PK33

- Candidate ID: `AMB28-retired_ia_or_terminology_reference-73709779`
- Evidence type: `retired_ia_or_terminology_reference`
- Severity: `yellow`
- Recommended action: `Rewrite`
- Linear-ready: `True`
- Auto-resolved: `False`
- Reason: Active item contains retired IA, retired terminology, or unsafe language; rewrite or retire before reuse.
- Involved active paths:
  - `PK33` — `prompts/batches/PK33.md` (partial_implementation; release proof)

### 278. Retired IA/terminology reference in FVQ_VISUAL_EXCELLENCE_TRAIN

- Candidate ID: `AMB28-retired_ia_or_terminology_reference-74112838`
- Evidence type: `retired_ia_or_terminology_reference`
- Severity: `yellow`
- Recommended action: `Rewrite`
- Linear-ready: `True`
- Auto-resolved: `False`
- Reason: Active item contains retired IA, retired terminology, or unsafe language; rewrite or retire before reuse.
- Involved active paths:
  - `FVQ_VISUAL_EXCELLENCE_TRAIN` — `docs/codex/visual-quality/FVQ_VISUAL_EXCELLENCE_TRAIN.md` (partial_implementation; release proof)

### 279. Retired IA/terminology reference in FL03_Commitment_Memory_Open_Loop_Registry_Prompt

- Candidate ID: `AMB28-retired_ia_or_terminology_reference-74199705`
- Evidence type: `retired_ia_or_terminology_reference`
- Severity: `yellow`
- Recommended action: `Rewrite`
- Linear-ready: `True`
- Auto-resolved: `False`
- Reason: Active item contains retired IA, retired terminology, or unsafe language; rewrite or retire before reuse.
- Involved active paths:
  - `FL03_Commitment_Memory_Open_Loop_Registry_Prompt` — `docs/codex/batches/FL03_Commitment_Memory_Open_Loop_Registry_Prompt.md` (unknown; audit)

### 280. Retired IA/terminology reference in FVQ03_DRILLDOWN_AND_EXTERNAL_SURFACE_VISUAL_SWEEP

- Candidate ID: `AMB28-retired_ia_or_terminology_reference-74487272`
- Evidence type: `retired_ia_or_terminology_reference`
- Severity: `yellow`
- Recommended action: `Rewrite`
- Linear-ready: `True`
- Auto-resolved: `False`
- Reason: Active item contains retired IA, retired terminology, or unsafe language; rewrite or retire before reuse.
- Involved active paths:
  - `FVQ03_DRILLDOWN_AND_EXTERNAL_SURFACE_VISUAL_SWEEP` — `docs/codex/visual-quality/FVQ03_DRILLDOWN_AND_EXTERNAL_SURFACE_VISUAL_SWEEP.md` (partial_implementation; release proof)

### 281. Retired IA/terminology reference in MODEL_TIER_EXECUTION_POLICY

- Candidate ID: `AMB28-retired_ia_or_terminology_reference-74581580`
- Evidence type: `retired_ia_or_terminology_reference`
- Severity: `yellow`
- Recommended action: `Rewrite`
- Linear-ready: `True`
- Auto-resolved: `False`
- Reason: Active item contains retired IA, retired terminology, or unsafe language; rewrite or retire before reuse.
- Involved active paths:
  - `MODEL_TIER_EXECUTION_POLICY` — `docs/codex/MODEL_TIER_EXECUTION_POLICY.md` (partial_implementation; release proof)

### 282. Retired IA/terminology reference in AOS23_Governance_Kernel_Registry_Prompt

- Candidate ID: `AMB28-retired_ia_or_terminology_reference-74854749`
- Evidence type: `retired_ia_or_terminology_reference`
- Severity: `yellow`
- Recommended action: `Rewrite`
- Linear-ready: `True`
- Auto-resolved: `False`
- Reason: Active item contains retired IA, retired terminology, or unsafe language; rewrite or retire before reuse.
- Involved active paths:
  - `AOS23_Governance_Kernel_Registry_Prompt` — `docs/codex/batches/AOS23_Governance_Kernel_Registry_Prompt.md` (partial_implementation; release proof)

### 283. Retired IA/terminology reference in AQOS_AUTONOMOUS_QUALITY_COUNCIL

- Candidate ID: `AMB28-retired_ia_or_terminology_reference-74910771`
- Evidence type: `retired_ia_or_terminology_reference`
- Severity: `yellow`
- Recommended action: `Rewrite`
- Linear-ready: `True`
- Auto-resolved: `False`
- Reason: Active item contains retired IA, retired terminology, or unsafe language; rewrite or retire before reuse.
- Involved active paths:
  - `AQOS_AUTONOMOUS_QUALITY_COUNCIL` — `docs/codex/quality/AQOS_AUTONOMOUS_QUALITY_COUNCIL.md` (partial_implementation; release proof)

### 284. Retired IA/terminology reference in UI-STUDIO-01-SURFACE-BRIEF-SYSTEM

- Candidate ID: `AMB28-retired_ia_or_terminology_reference-74964919`
- Evidence type: `retired_ia_or_terminology_reference`
- Severity: `yellow`
- Recommended action: `Rewrite`
- Linear-ready: `True`
- Auto-resolved: `False`
- Reason: Active item contains retired IA, retired terminology, or unsafe language; rewrite or retire before reuse.
- Involved active paths:
  - `UI-STUDIO-01-SURFACE-BRIEF-SYSTEM` — `prompts/batches/ui-flagship/UI-STUDIO-01-SURFACE-BRIEF-SYSTEM.md` (partial_implementation; release proof)

### 285. Retired IA/terminology reference in EB25_Accessibility_Cognitive_Load_Canon_Prompt

- Candidate ID: `AMB28-retired_ia_or_terminology_reference-75123266`
- Evidence type: `retired_ia_or_terminology_reference`
- Severity: `yellow`
- Recommended action: `Rewrite`
- Linear-ready: `True`
- Auto-resolved: `False`
- Reason: Active item contains retired IA, retired terminology, or unsafe language; rewrite or retire before reuse.
- Involved active paths:
  - `EB25_Accessibility_Cognitive_Load_Canon_Prompt` — `docs/codex/batches/EB25_Accessibility_Cognitive_Load_Canon_Prompt.md` (partial_implementation; release proof)

### 286. Retired IA/terminology reference in EB01_External_Brain_Source_Truth_And_Kernel_Architecture_Prompt

- Candidate ID: `AMB28-retired_ia_or_terminology_reference-75236592`
- Evidence type: `retired_ia_or_terminology_reference`
- Severity: `yellow`
- Recommended action: `Rewrite`
- Linear-ready: `True`
- Auto-resolved: `False`
- Reason: Active item contains retired IA, retired terminology, or unsafe language; rewrite or retire before reuse.
- Involved active paths:
  - `EB01_External_Brain_Source_Truth_And_Kernel_Architecture_Prompt` — `docs/codex/batches/EB01_External_Brain_Source_Truth_And_Kernel_Architecture_Prompt.md` (partial_implementation; release proof)

### 287. Retired IA/terminology reference in AMB-POST23-02-UNDERDELIVERY-REPAIR

- Candidate ID: `AMB28-retired_ia_or_terminology_reference-75353950`
- Evidence type: `retired_ia_or_terminology_reference`
- Severity: `yellow`
- Recommended action: `Rewrite`
- Linear-ready: `True`
- Auto-resolved: `False`
- Reason: Active item contains retired IA, retired terminology, or unsafe language; rewrite or retire before reuse.
- Involved active paths:
  - `AMB-POST23-02-UNDERDELIVERY-REPAIR` — `docs/codex/reports/AMB-POST23-02-UNDERDELIVERY-REPAIR.md` (partial_implementation; release proof)

### 288. Retired IA/terminology reference in PFC35

- Candidate ID: `AMB28-retired_ia_or_terminology_reference-75580675`
- Evidence type: `retired_ia_or_terminology_reference`
- Severity: `yellow`
- Recommended action: `Rewrite`
- Linear-ready: `True`
- Auto-resolved: `False`
- Reason: Active item contains retired IA, retired terminology, or unsafe language; rewrite or retire before reuse.
- Involved active paths:
  - `PFC35` — `prompts/batches/PFC35.md` (partial_implementation; release proof)

### 289. Retired IA/terminology reference in PX03_Goals_Mission_Control_Experience_Prompt

- Candidate ID: `AMB28-retired_ia_or_terminology_reference-75609888`
- Evidence type: `retired_ia_or_terminology_reference`
- Severity: `yellow`
- Recommended action: `Rewrite`
- Linear-ready: `True`
- Auto-resolved: `False`
- Reason: Active item contains retired IA, retired terminology, or unsafe language; rewrite or retire before reuse.
- Involved active paths:
  - `PX03_Goals_Mission_Control_Experience_Prompt` — `docs/codex/batches/PX03_Goals_Mission_Control_Experience_Prompt.md` (partial_implementation; release proof)

### 290. Retired IA/terminology reference in EB31_Cross_Kernel_Primitives_And_Event_Receipts_Prompt

- Candidate ID: `AMB28-retired_ia_or_terminology_reference-75842560`
- Evidence type: `retired_ia_or_terminology_reference`
- Severity: `yellow`
- Recommended action: `Rewrite`
- Linear-ready: `True`
- Auto-resolved: `False`
- Reason: Active item contains retired IA, retired terminology, or unsafe language; rewrite or retire before reuse.
- Involved active paths:
  - `EB31_Cross_Kernel_Primitives_And_Event_Receipts_Prompt` — `docs/codex/batches/EB31_Cross_Kernel_Primitives_And_Event_Receipts_Prompt.md` (partial_implementation; release proof)

### 291. Retired IA/terminology reference in MASTER_CODEX_SYSTEM

- Candidate ID: `AMB28-retired_ia_or_terminology_reference-76329342`
- Evidence type: `retired_ia_or_terminology_reference`
- Severity: `yellow`
- Recommended action: `Rewrite`
- Linear-ready: `True`
- Auto-resolved: `False`
- Reason: Active item contains retired IA, retired terminology, or unsafe language; rewrite or retire before reuse.
- Involved active paths:
  - `MASTER_CODEX_SYSTEM` — `docs/codex/MASTER_CODEX_SYSTEM.md` (partial_implementation; release proof)

### 292. Retired IA/terminology reference in CODEX_QUALITY_SYSTEM_GATE_MATRIX

- Candidate ID: `AMB28-retired_ia_or_terminology_reference-76466484`
- Evidence type: `retired_ia_or_terminology_reference`
- Severity: `yellow`
- Recommended action: `Rewrite`
- Linear-ready: `True`
- Auto-resolved: `False`
- Reason: Active item contains retired IA, retired terminology, or unsafe language; rewrite or retire before reuse.
- Involved active paths:
  - `CODEX_QUALITY_SYSTEM_GATE_MATRIX` — `docs/codex/CODEX_QUALITY_SYSTEM_GATE_MATRIX.md` (partial_implementation; release proof)

### 293. Retired IA/terminology reference in EB36_External_Brain_QA_Regression_And_Risk_Register_Prompt

- Candidate ID: `AMB28-retired_ia_or_terminology_reference-76986589`
- Evidence type: `retired_ia_or_terminology_reference`
- Severity: `yellow`
- Recommended action: `Rewrite`
- Linear-ready: `True`
- Auto-resolved: `False`
- Reason: Active item contains retired IA, retired terminology, or unsafe language; rewrite or retire before reuse.
- Involved active paths:
  - `EB36_External_Brain_QA_Regression_And_Risk_Register_Prompt` — `docs/codex/batches/EB36_External_Brain_QA_Regression_And_Risk_Register_Prompt.md` (partial_implementation; release proof)

### 294. Retired IA/terminology reference in IOS26_EXISTING_BATCH_EXPANSION_DIRECTIVES

- Candidate ID: `AMB28-retired_ia_or_terminology_reference-77400576`
- Evidence type: `retired_ia_or_terminology_reference`
- Severity: `yellow`
- Recommended action: `Rewrite`
- Linear-ready: `True`
- Auto-resolved: `False`
- Reason: Active item contains retired IA, retired terminology, or unsafe language; rewrite or retire before reuse.
- Involved active paths:
  - `IOS26_EXISTING_BATCH_EXPANSION_DIRECTIVES` — `docs/codex/frontend/IOS26_EXISTING_BATCH_EXPANSION_DIRECTIVES.md` (unknown; audit)

### 295. Retired IA/terminology reference in AOS15_Local_Language_Kernel_Planning_Prompt

- Candidate ID: `AMB28-retired_ia_or_terminology_reference-77449437`
- Evidence type: `retired_ia_or_terminology_reference`
- Severity: `yellow`
- Recommended action: `Rewrite`
- Linear-ready: `True`
- Auto-resolved: `False`
- Reason: Active item contains retired IA, retired terminology, or unsafe language; rewrite or retire before reuse.
- Involved active paths:
  - `AOS15_Local_Language_Kernel_Planning_Prompt` — `docs/codex/batches/AOS15_Local_Language_Kernel_Planning_Prompt.md` (partial_implementation; release proof)

### 296. Retired IA/terminology reference in SA22

- Candidate ID: `AMB28-retired_ia_or_terminology_reference-77623764`
- Evidence type: `retired_ia_or_terminology_reference`
- Severity: `yellow`
- Recommended action: `Rewrite`
- Linear-ready: `True`
- Auto-resolved: `False`
- Reason: Active item contains retired IA, retired terminology, or unsafe language; rewrite or retire before reuse.
- Involved active paths:
  - `SA22` — `prompts/batches/SA22.md` (partial_implementation; release proof)

### 297. Retired IA/terminology reference in FL01_FL06_FOUND_LIFE_LAYER_TRAIN

- Candidate ID: `AMB28-retired_ia_or_terminology_reference-77804287`
- Evidence type: `retired_ia_or_terminology_reference`
- Severity: `yellow`
- Recommended action: `Rewrite`
- Linear-ready: `True`
- Auto-resolved: `False`
- Reason: Active item contains retired IA, retired terminology, or unsafe language; rewrite or retire before reuse.
- Involved active paths:
  - `FL01_FL06_FOUND_LIFE_LAYER_TRAIN` — `docs/codex/batch-trains/FL01_FL06_FOUND_LIFE_LAYER_TRAIN.md` (partial_implementation; audit)

### 298. Retired IA/terminology reference in VISUAL-CANON-MOAT-01

- Candidate ID: `AMB28-retired_ia_or_terminology_reference-77962124`
- Evidence type: `retired_ia_or_terminology_reference`
- Severity: `yellow`
- Recommended action: `Rewrite`
- Linear-ready: `True`
- Auto-resolved: `False`
- Reason: Active item contains retired IA, retired terminology, or unsafe language; rewrite or retire before reuse.
- Involved active paths:
  - `VISUAL-CANON-MOAT-01` — `prompts/batches/VISUAL-CANON-MOAT-01.md` (partial_implementation; release proof)

### 299. Retired IA/terminology reference in HPS_NEXT_ELIGIBLE_BATCH_PROMPT

- Candidate ID: `AMB28-retired_ia_or_terminology_reference-78416645`
- Evidence type: `retired_ia_or_terminology_reference`
- Severity: `yellow`
- Recommended action: `Rewrite`
- Linear-ready: `True`
- Auto-resolved: `False`
- Reason: Active item contains retired IA, retired terminology, or unsafe language; rewrite or retire before reuse.
- Involved active paths:
  - `HPS_NEXT_ELIGIBLE_BATCH_PROMPT` — `docs/codex/batches/HPS_NEXT_ELIGIBLE_BATCH_PROMPT.md` (partial_implementation; release proof)

### 300. Retired IA/terminology reference in HBI00_RRE01_HISTORICAL_BASELINE_TRAIN

- Candidate ID: `AMB28-retired_ia_or_terminology_reference-79267186`
- Evidence type: `retired_ia_or_terminology_reference`
- Severity: `yellow`
- Recommended action: `Rewrite`
- Linear-ready: `True`
- Auto-resolved: `False`
- Reason: Active item contains retired IA, retired terminology, or unsafe language; rewrite or retire before reuse.
- Involved active paths:
  - `HBI00_RRE01_HISTORICAL_BASELINE_TRAIN` — `docs/codex/batch-trains/HBI00_RRE01_HISTORICAL_BASELINE_TRAIN.md` (unknown; release proof)

- ... 1107 more active candidates in JSON

## Historical-only residue

Historical-only residue is retained for traceability and must not become active by default.


## Non-claims

- This report does not modify canon.
- This report does not modify source code.
- This report does not modify prompts or trains.
- This report does not delete or archive anything.
- This report does not create one issue per candidate.
- This report does not prove implementation, build, tests, accessibility, performance, device, privacy, legal, TestFlight, App Store, or release readiness.
- Linear status is not repo truth.
