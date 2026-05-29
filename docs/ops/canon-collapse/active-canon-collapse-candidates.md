# Active Canon Collapse Candidates

Status: GREEN
Generated UTC: 2026-05-29T02:35:02Z
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

- Active candidates: `72`
- Historical-only residue: `0`
- Red active candidates: `0`
- Auto-resolved candidates: `0`

### Active candidates by action

- `Expedite`: `5`
- `Merge`: `67`

### Active candidates by conflict type

- `duplicate_stable_id`: `9`
- `same_source_file_targeted_by_multiple_active_batches`: `57`
- `same_surface_multiple_active_batches`: `6`

## Next bounded action bundle

- Bundle ID: `canon-collapse-merge-overlap-bundle`
- Title: Merge or sequence overlapping active canon/work ownership
- Recommended action: `Merge`
- Candidate count: `67`
- Reason: Duplicate and overlapping active work should be merged or sequenced before implementation.

### Bundle candidate IDs

- `AMB28-duplicate_stable_id-15140139`
- `AMB28-duplicate_stable_id-2857785`
- `AMB28-duplicate_stable_id-42337306`
- `AMB28-duplicate_stable_id-55950150`
- `AMB28-duplicate_stable_id-67922238`
- `AMB28-duplicate_stable_id-85822314`
- `AMB28-duplicate_stable_id-9254712`
- `AMB28-duplicate_stable_id-94671863`
- `AMB28-duplicate_stable_id-95935632`
- `AMB28-same_source_file_targeted_by_multiple_active_batches-10772187`
- `AMB28-same_source_file_targeted_by_multiple_active_batches-11460445`
- `AMB28-same_source_file_targeted_by_multiple_active_batches-12980944`
- `AMB28-same_source_file_targeted_by_multiple_active_batches-13187650`
- `AMB28-same_source_file_targeted_by_multiple_active_batches-15166054`
- `AMB28-same_source_file_targeted_by_multiple_active_batches-16813789`
- `AMB28-same_source_file_targeted_by_multiple_active_batches-18070532`
- `AMB28-same_source_file_targeted_by_multiple_active_batches-19740197`
- `AMB28-same_source_file_targeted_by_multiple_active_batches-20313316`
- `AMB28-same_source_file_targeted_by_multiple_active_batches-23403089`
- `AMB28-same_source_file_targeted_by_multiple_active_batches-24438436`
- `AMB28-same_source_file_targeted_by_multiple_active_batches-26001342`
- `AMB28-same_source_file_targeted_by_multiple_active_batches-26268722`
- `AMB28-same_source_file_targeted_by_multiple_active_batches-29322830`
- `AMB28-same_source_file_targeted_by_multiple_active_batches-31694407`
- `AMB28-same_source_file_targeted_by_multiple_active_batches-36264026`
- `AMB28-same_source_file_targeted_by_multiple_active_batches-36349612`
- `AMB28-same_source_file_targeted_by_multiple_active_batches-39316650`
- `AMB28-same_source_file_targeted_by_multiple_active_batches-39729413`
- `AMB28-same_source_file_targeted_by_multiple_active_batches-39876285`
- `AMB28-same_source_file_targeted_by_multiple_active_batches-40878629`
- `AMB28-same_source_file_targeted_by_multiple_active_batches-43014259`
- `AMB28-same_source_file_targeted_by_multiple_active_batches-43654621`
- `AMB28-same_source_file_targeted_by_multiple_active_batches-45693093`
- `AMB28-same_source_file_targeted_by_multiple_active_batches-46269820`
- `AMB28-same_source_file_targeted_by_multiple_active_batches-49203811`
- `AMB28-same_source_file_targeted_by_multiple_active_batches-49923392`
- `AMB28-same_source_file_targeted_by_multiple_active_batches-52882976`
- `AMB28-same_source_file_targeted_by_multiple_active_batches-54582784`
- `AMB28-same_source_file_targeted_by_multiple_active_batches-57884692`
- `AMB28-same_source_file_targeted_by_multiple_active_batches-60858350`
- `AMB28-same_source_file_targeted_by_multiple_active_batches-63740124`
- `AMB28-same_source_file_targeted_by_multiple_active_batches-64051452`
- `AMB28-same_source_file_targeted_by_multiple_active_batches-644983`
- `AMB28-same_source_file_targeted_by_multiple_active_batches-66982787`
- `AMB28-same_source_file_targeted_by_multiple_active_batches-6975657`
- `AMB28-same_source_file_targeted_by_multiple_active_batches-70593123`
- `AMB28-same_source_file_targeted_by_multiple_active_batches-71599116`
- `AMB28-same_source_file_targeted_by_multiple_active_batches-73269029`
- `AMB28-same_source_file_targeted_by_multiple_active_batches-7402687`
- `AMB28-same_source_file_targeted_by_multiple_active_batches-75250300`
- `AMB28-same_source_file_targeted_by_multiple_active_batches-76523821`
- `AMB28-same_source_file_targeted_by_multiple_active_batches-80026133`
- `AMB28-same_source_file_targeted_by_multiple_active_batches-80786611`
- `AMB28-same_source_file_targeted_by_multiple_active_batches-81133443`
- `AMB28-same_source_file_targeted_by_multiple_active_batches-81406637`
- `AMB28-same_source_file_targeted_by_multiple_active_batches-82039618`
- `AMB28-same_source_file_targeted_by_multiple_active_batches-8465283`
- `AMB28-same_source_file_targeted_by_multiple_active_batches-85196815`
- `AMB28-same_source_file_targeted_by_multiple_active_batches-86570980`
- `AMB28-same_source_file_targeted_by_multiple_active_batches-88217938`
- `AMB28-same_source_file_targeted_by_multiple_active_batches-92257346`
- `AMB28-same_source_file_targeted_by_multiple_active_batches-95711181`
- `AMB28-same_source_file_targeted_by_multiple_active_batches-97024768`
- `AMB28-same_source_file_targeted_by_multiple_active_batches-97917798`
- `AMB28-same_source_file_targeted_by_multiple_active_batches-98081479`
- `AMB28-same_source_file_targeted_by_multiple_active_batches-991068`
- `AMB28-same_surface_multiple_active_batches-32360271`

### Bundle repo paths

- `docs/codex/AMBITIONSOS_AOS_EVIDENCE_LEDGER.md`
- `docs/codex/AMBITIONS_3_0_CONTEXT_LOADING_AND_TASK_ROUTING.md`
- `docs/codex/AMB_CODEX_GOVERNANCE_SPEC.md`
- `docs/codex/AMB_CONTROL_PLANE_DIRECT_RUNBOOK.md`
- `docs/codex/AMB_CONTROL_PLANE_GATE_INDEX.md`
- `docs/codex/ANTIGRAVITY_MANIFEST_RERUN_START_HERE.md`
- `docs/codex/AUTONOMOUS_TRAIN_FASTPATH.md`
- `docs/codex/CHAMPION_MERGE_RUNBOOK.md`
- `docs/codex/CODEX_OS_ENGINE_SUPPLEMENT_2026_05_08.md`
- `docs/codex/CODEX_OS_REPAIR_SPEED_PROOF_UPGRADE_AUDIT_2026_05_08.md`
- `docs/codex/CODEX_QUALITY_SYSTEM_SCRIPT_MAP.md`
- `docs/codex/DAV_PRODUCT_EXPERIENCE_SCORECARD.md`
- `docs/codex/FLAGSHIP_COMPLETION_GATE_MATRIX.md`
- `docs/codex/FRONTEND_AUTHORITY_GLOBAL_TRAIN_HOOK.md`
- `docs/codex/FRONTEND_SHELL_BOTTOM_CHROME_OWNERSHIP_GATE.md`
- `docs/codex/GATE_RESULT_MANIFEST_SCHEMA.md`
- `docs/codex/GLOBAL_BATCH_AUTOMATED_GATE_PROTOCOL.md`
- `docs/codex/GLOBAL_PATCH_TRAIN_INTERRUPTED_RUN_RECOVERY_PROTOCOL.md`
- `docs/codex/GOAL_REALITY_COMPILER_BACKEND_MASTER_PLAN.md`
- `docs/codex/HBI_HISTORICAL_BASELINE_GLOBAL_TRAIN_INSERT.md`
- `docs/codex/HISTORICAL_BASELINE_GLOBAL_TRAIN_MANIFEST.json`
- `docs/codex/IOS26_FLAGSHIP_TRAIN_MANIFEST.yml`
- `docs/codex/LINEAR_CONTROL_PLANE.md`
- `docs/codex/MOONSHOT_PROOF_PATH_BACKEND_MASTER_PLAN.md`
- `docs/codex/OBJECT_OS_SURFACE_MAP.md`
- `docs/codex/POST_BATCH_GATE_REGISTRY.md`
- `docs/codex/PXEQ_SURFACE_BEHAVIOR_MATRIX.md`
- `docs/codex/SA28_LDI15_AOS24_MANIFEST_RERUN_DIRECTIVE.md`
- `docs/codex/SIG_DEPENDENCY_AND_TOOLING_LEDGER.md`
- `docs/codex/SIG_EMOTIONAL_DESIGN_MOMENTS_MAP.md`
- `docs/codex/SOURCE_ATLAS_CODEX_OS_UPGRADE_MAP.md`
- `docs/codex/SPEED_TRAIN_LANE_POLICY.json`
- `docs/codex/VISUAL_CANON_MOAT_IMPLEMENTATION_OVERLAY.md`
- `docs/codex/batch-prep/PK16.md`
- `docs/codex/batch-prep/README.md`
- `docs/codex/batch-trains/CQS01_CQS24_CODEX_QUALITY_SYSTEM_TRAIN.md`
- `docs/codex/batch-trains/FET01_FET12_FAANG_FRONTEND_EXCELLENCE_TRAIN.md`
- `docs/codex/batch-trains/HBI00_RRE01_HISTORICAL_BASELINE_TRAIN.md`
- `docs/codex/batch-trains/README.md`
- `docs/codex/batch-trains/SA01_SA32_SOURCE_ATLAS_FULL_MATURITY_TRAIN.md`
- `docs/codex/batch-trains/amb-fe-be/AMB-FE-BE-IMPLEMENTATION-STATUS.md`
- `docs/codex/batch-trains/amb-fe-be/README.md`
- `docs/codex/batch-trains/post-23-truth-audit/AMB-POST23-TRUTH-AUDIT-ELIGIBILITY-GATE.md`
- `docs/codex/batch-trains/post99-ui-suite/README.md`
- `docs/codex/batches/AFI05_Shell_And_Continuity_Chrome.md`
- `docs/codex/batches/AFI09_Time_LifeShape_Field.md`
- `docs/codex/batches/AFI10_You_User_System_Profile.md`
- `docs/codex/batches/AQOS_TOOLS_SKILLS_AND_SCRIPTS_PROMPT.md`
- `docs/codex/batches/BATCH-31-correction-and-teaching-loop.md`
- `docs/codex/batches/BATCH-32-explainability-and-source-audit-surfaces.md`
- `docs/codex/batches/BATCH-33-intelligence-runtime-integration.md`
- `docs/codex/batches/DAV01_Dynamic_Visual_Source_Truth_And_Surface_Map_Prompt.md`
- `docs/codex/batches/DAV02_Reusable_Living_Visual_Primitives_Implementation_Prompt.md`
- `docs/codex/batches/DAV09_TrustReceiptStack_EvidenceLabels_And_ProofPulse_Implementation_Prompt.md`
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
- `docs/codex/batches/EB19_Product_Maturity_Onboarding_Canon_Prompt.md`
- `docs/codex/batches/EB20_Value_Based_Onboarding_And_First_Week_Success_Prompt.md`
- `docs/codex/batches/EB21_Concierge_Setup_And_Planning_Defaults_Onboarding_Prompt.md`
- `docs/codex/batches/EB22_Privacy_Setup_And_Trust_Onboarding_Prompt.md`
- `docs/codex/batches/EB23_Maturity_Levels_Progressive_Disclosure_And_Life_Season_Templates_Prompt.md`
- `docs/codex/batches/EB24_Onboarding_Receipts_Skip_Later_And_Setup_Recovery_Prompt.md`
- `docs/codex/batches/EB25_Accessibility_Cognitive_Load_Canon_Prompt.md`
- `docs/codex/batches/EB26_Cognitive_Load_Modes_And_Interface_Density_Prompt.md`
- `docs/codex/batches/EB27_Dynamic_Type_VoiceOver_And_Reduce_Motion_Prompt.md`
- `docs/codex/batches/EB28_Plain_Language_Anxiety_Safe_Copy_And_Explain_This_Screen_Prompt.md`
- `docs/codex/batches/EB29_Voice_First_Operation_And_Motor_Accessibility_Prompt.md`
- `docs/codex/batches/EB30_Overloaded_Day_Adaptation_And_Low_Cognitive_Load_Flows_Prompt.md`
- `docs/codex/batches/EB31_Cross_Kernel_Primitives_And_Event_Receipts_Prompt.md`
- `docs/codex/batches/EB32_Cross_Kernel_Dependency_And_Gate_Integration_Prompt.md`
- `docs/codex/batches/EB33_External_Brain_Search_And_Context_Recall_Prompt.md`
- `docs/codex/batches/EB34_External_Brain_Command_Surface_Integration_Prompt.md`
- `docs/codex/batches/EB35_External_Brain_Preview_Fixtures_And_Scenario_Library_Prompt.md`
- `docs/codex/batches/EB36_External_Brain_QA_Regression_And_Risk_Register_Prompt.md`
- `docs/codex/batches/EB37_External_Brain_Privacy_Threat_Model_Prompt.md`
- `docs/codex/batches/EB38_External_Brain_Accessibility_Evidence_Closeout_Prompt.md`
- `docs/codex/batches/EB39_External_Brain_Handoff_And_RC_Readiness_Implications_Prompt.md`
- `docs/codex/batches/EB40_Ambitions_4_0_External_Brain_Closeout_Prompt.md`
- `docs/codex/batches/F03_5_Today_Execution_State_Contract_Hardening_Prompt.md`
- `docs/codex/batches/F16_5_SwiftUI_Architecture_State_Contract_Hardening_Prompt.md`
- `docs/codex/batches/F17_Shell_Meridian_Planning_And_Readiness_Audit_Prompt.md`
- `docs/codex/batches/F18_Feature_Flagged_Meridian_Shell_Implementation_Prompt.md`
- `docs/codex/batches/FCP05_Start_Here_Surface_Prompt.md`
- `docs/codex/batches/FCP06_Receipt_Drawer_Trust_Layer_Prompt.md`
- `docs/codex/batches/FCP07_Reality_Rail_Continuity_Prompt.md`
- `docs/codex/batches/FCP08_Ambition_Meridian_Shell_Prompt.md`
- `docs/codex/batches/FCP09_Motion_Haptics_Reduced_Motion_Proof_Prompt.md`
- `docs/codex/batches/FCP13A_Action_Closure_Diamond_Prompt.md`
- `docs/codex/batches/FCP17_Schedule_Availability_Defaults_Center_Prompt.md`
- `docs/codex/batches/FCP_REGISTRY_CONTEXT_RECONCILIATION_PROMPT.md`
- `docs/codex/batches/FET00_FAANG_FRONTEND_CODEX_OS_UPGRADE_PROMPT.md`
- `docs/codex/batches/GATE_SYSTEM_HARDENING_NEXT_PROMPT.md`
- `docs/codex/batches/HPS01_Verified_Human_Progress_OS_Category_Lock_Prompt.md`
- `docs/codex/batches/HPS07_Option_Value_Pivot_Preservation_Architecture_Prompt.md`
- `docs/codex/batches/HPS08_Living_Dream_Compiler_Upgrade_Prompt.md`
- `docs/codex/batches/HPS09_Privacy_Memory_Permission_Local_Intelligence_Adapter_Prompt.md`
- `docs/codex/batches/HPS10_AI_Governance_Evaluation_Assurance_Lab_Prompt.md`
- `docs/codex/batches/HPS11_Vertical_Expansion_Revenue_Architecture_Prompt.md`
- `docs/codex/batches/HPS12_Singular_Experience_Acquisition_Readiness_Lock_Prompt.md`
- `docs/codex/batches/PFC01_Repo_And_Build_System_Inventory_Prompt.md`
- `docs/codex/batches/PFC02_Architecture_Boundary_And_Module_Map_Prompt.md`
- `docs/codex/batches/PFC03_Dead_Code_Prompt_Artifact_Naming_Smell_Audit_Prompt.md`
- `docs/codex/batches/PFC04_Dependency_And_Supply_Chain_Policy_Enforcement_Prompt.md`
- ... 326 more in JSON

## Active candidates

### 1. Duplicate stable ID: PK16

- Candidate ID: `AMB28-duplicate_stable_id-15140139`
- Evidence type: `duplicate_stable_id`
- Severity: `yellow`
- Recommended action: `Merge`
- Linear-ready: `True`
- Auto-resolved: `False`
- Reason: Duplicate stable ID appears in active work; merge, namespace, or retire duplicate authority.
- Involved active paths:
  - `PK16` — `docs/codex/batch-prep/PK16.md` (partial_implementation; release proof)

### 2. Duplicate stable ID: README

- Candidate ID: `AMB28-duplicate_stable_id-2857785`
- Evidence type: `duplicate_stable_id`
- Severity: `yellow`
- Recommended action: `Merge`
- Linear-ready: `True`
- Auto-resolved: `False`
- Reason: Duplicate stable ID appears in active work; merge, namespace, or retire duplicate authority.
- Involved active paths:
  - `README` — `docs/codex/batch-prep/README.md` (partial_implementation; release proof)
  - `README` — `docs/codex/batch-trains/amb-fe-be/README.md` (partial_implementation; release proof)
  - `README` — `docs/codex/chatgpt/README.md` (partial_implementation; release proof)
  - `README` — `docs/codex/os/README.md` (partial_implementation; release proof)
  - `README` — `docs/codex/batch-trains/post99-ui-suite/README.md` (partial_implementation; release proof)
  - `README` — `prompts/trains/ios26-flagship/README.md` (partial_implementation; release proof)
  - `README` — `docs/codex/linear-templates/README.md` (partial_implementation; release proof)
  - `README` — `docs/codex/batch-trains/README.md` (unknown; release proof)

### 3. Duplicate stable ID: existing-code-champion-coverage

- Candidate ID: `AMB28-duplicate_stable_id-42337306`
- Evidence type: `duplicate_stable_id`
- Severity: `yellow`
- Recommended action: `Merge`
- Linear-ready: `True`
- Auto-resolved: `False`
- Reason: Duplicate stable ID appears in active work; merge, namespace, or retire duplicate authority.
- Involved active paths:
  - `existing-code-champion-coverage` — `docs/codex/existing-code-champion-coverage.yml` (unknown; release proof)

### 4. Duplicate stable ID: AMB-REPO-GREEN-FLAGSHIP-RESET-MASTER-01-T05-SOURCE-REFRACTOR-MAP

- Candidate ID: `AMB28-duplicate_stable_id-55950150`
- Evidence type: `duplicate_stable_id`
- Severity: `yellow`
- Recommended action: `Merge`
- Linear-ready: `True`
- Auto-resolved: `False`
- Reason: Duplicate stable ID appears in active work; merge, namespace, or retire duplicate authority.
- Involved active paths:
  - `AMB-REPO-GREEN-FLAGSHIP-RESET-MASTER-01-T05-SOURCE-REFRACTOR-MAP` — `prompts/batches/AMB-REPO-GREEN-FLAGSHIP-RESET-MASTER-01-T05-SOURCE-REFRACTOR-MAP.md` (partial_implementation; release proof)

### 5. Duplicate stable ID: AMB-REPO-GREEN-FLAGSHIP-RESET-MASTER-01-T17-FINAL-IA-SCAN

- Candidate ID: `AMB28-duplicate_stable_id-67922238`
- Evidence type: `duplicate_stable_id`
- Severity: `yellow`
- Recommended action: `Merge`
- Linear-ready: `True`
- Auto-resolved: `False`
- Reason: Duplicate stable ID appears in active work; merge, namespace, or retire duplicate authority.
- Involved active paths:
  - `AMB-REPO-GREEN-FLAGSHIP-RESET-MASTER-01-T17-FINAL-IA-SCAN` — `prompts/batches/AMB-REPO-GREEN-FLAGSHIP-RESET-MASTER-01-T17-FINAL-IA-SCAN.md` (partial_implementation; release proof)

### 6. Duplicate stable ID: AMB-FE-BE-PREFLIGHT-00

- Candidate ID: `AMB28-duplicate_stable_id-85822314`
- Evidence type: `duplicate_stable_id`
- Severity: `yellow`
- Recommended action: `Merge`
- Linear-ready: `True`
- Auto-resolved: `False`
- Reason: Duplicate stable ID appears in active work; merge, namespace, or retire duplicate authority.
- Involved active paths:
  - `AMB-FE-BE-PREFLIGHT-00` — `prompts/batches/amb-fe-be/AMB-FE-BE-PREFLIGHT-00.md` (partial_implementation; release proof)

### 7. Duplicate stable ID: AMB-FILE-BY-FILE-REPO-AUDIT-01

- Candidate ID: `AMB28-duplicate_stable_id-9254712`
- Evidence type: `duplicate_stable_id`
- Severity: `yellow`
- Recommended action: `Merge`
- Linear-ready: `True`
- Auto-resolved: `False`
- Reason: Duplicate stable ID appears in active work; merge, namespace, or retire duplicate authority.
- Involved active paths:
  - `AMB-FILE-BY-FILE-REPO-AUDIT-01` — `prompts/batches/AMB-FILE-BY-FILE-REPO-AUDIT-01.md` (partial_implementation; release proof)

### 8. Duplicate stable ID: AMB-REPO-GREEN-FLAGSHIP-RESET-MASTER-01

- Candidate ID: `AMB28-duplicate_stable_id-94671863`
- Evidence type: `duplicate_stable_id`
- Severity: `yellow`
- Recommended action: `Merge`
- Linear-ready: `True`
- Auto-resolved: `False`
- Reason: Duplicate stable ID appears in active work; merge, namespace, or retire duplicate authority.
- Involved active paths:
  - `AMB-REPO-GREEN-FLAGSHIP-RESET-MASTER-01` — `prompts/batches/AMB-REPO-GREEN-FLAGSHIP-RESET-MASTER-01.md` (partial_implementation; release proof)

### 9. Duplicate stable ID: AMB-REPO-GREEN-FLAGSHIP-RESET-MASTER-01-T03-VOCAB-LEDGER

- Candidate ID: `AMB28-duplicate_stable_id-95935632`
- Evidence type: `duplicate_stable_id`
- Severity: `yellow`
- Recommended action: `Merge`
- Linear-ready: `True`
- Auto-resolved: `False`
- Reason: Duplicate stable ID appears in active work; merge, namespace, or retire duplicate authority.
- Involved active paths:
  - `AMB-REPO-GREEN-FLAGSHIP-RESET-MASTER-01-T03-VOCAB-LEDGER` — `prompts/batches/AMB-REPO-GREEN-FLAGSHIP-RESET-MASTER-01-T03-VOCAB-LEDGER.md` (partial_implementation; release proof)

### 10. Same source file targeted by multiple active items: scripts/ai/acx_visual_packet.py

- Candidate ID: `AMB28-same_source_file_targeted_by_multiple_active_batches-10772187`
- Evidence type: `same_source_file_targeted_by_multiple_active_batches`
- Severity: `yellow`
- Recommended action: `Merge`
- Linear-ready: `True`
- Auto-resolved: `False`
- Reason: Multiple active work items target the same source file; merge or sequence ownership before implementation.
- Involved active paths:
  - `CODEX_OS_ENGINE_SUPPLEMENT_2026_05_08` — `docs/codex/CODEX_OS_ENGINE_SUPPLEMENT_2026_05_08.md` (partial_implementation; release proof)
  - `CODEX_OS_REPAIR_SPEED_PROOF_UPGRADE_AUDIT_2026_05_08` — `docs/codex/CODEX_OS_REPAIR_SPEED_PROOF_UPGRADE_AUDIT_2026_05_08.md` (partial_implementation; release proof)
  - `AFI09_Time_LifeShape_Field` — `docs/codex/batches/AFI09_Time_LifeShape_Field.md` (partial_implementation; release proof)
  - `AFI10_You_User_System_Profile` — `docs/codex/batches/AFI10_You_User_System_Profile.md` (partial_implementation; release proof)
  - `CODEX_QUALITY_SYSTEM_SCRIPT_MAP` — `docs/codex/CODEX_QUALITY_SYSTEM_SCRIPT_MAP.md` (unknown; release proof)

### 11. Same source file targeted by multiple active items: scripts/ambitions-queue-snapshot.py

- Candidate ID: `AMB28-same_source_file_targeted_by_multiple_active_batches-11460445`
- Evidence type: `same_source_file_targeted_by_multiple_active_batches`
- Severity: `yellow`
- Recommended action: `Merge`
- Linear-ready: `True`
- Auto-resolved: `False`
- Reason: Multiple active work items target the same source file; merge or sequence ownership before implementation.
- Involved active paths:
  - `AMB_CONTROL_PLANE_DIRECT_RUNBOOK` — `docs/codex/AMB_CONTROL_PLANE_DIRECT_RUNBOOK.md` (partial_implementation; release proof)
  - `AMB_CONTROL_PLANE_GATE_INDEX` — `docs/codex/AMB_CONTROL_PLANE_GATE_INDEX.md` (partial_implementation; release proof)
  - `HBI-GLOBAL-TRAIN-HANDOFF-01` — `prompts/batches/HBI-GLOBAL-TRAIN-HANDOFF-01.md` (partial_implementation; release proof)

### 12. Same source file targeted by multiple active items: scripts/si-readiness-gate.sh

- Candidate ID: `AMB28-same_source_file_targeted_by_multiple_active_batches-12980944`
- Evidence type: `same_source_file_targeted_by_multiple_active_batches`
- Severity: `yellow`
- Recommended action: `Merge`
- Linear-ready: `True`
- Auto-resolved: `False`
- Reason: Multiple active work items target the same source file; merge or sequence ownership before implementation.
- Involved active paths:
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
  - ... 7 more

### 13. Same source file targeted by multiple active items: Native/Ambitions/Domain/GoalRealityModels.swift

- Candidate ID: `AMB28-same_source_file_targeted_by_multiple_active_batches-13187650`
- Evidence type: `same_source_file_targeted_by_multiple_active_batches`
- Severity: `yellow`
- Recommended action: `Merge`
- Linear-ready: `True`
- Auto-resolved: `False`
- Reason: Multiple active work items target the same source file; merge or sequence ownership before implementation.
- Involved active paths:
  - `GOAL_REALITY_COMPILER_BACKEND_MASTER_PLAN` — `docs/codex/GOAL_REALITY_COMPILER_BACKEND_MASTER_PLAN.md` (partial_implementation; release proof)
  - `MOAT-GOAL-REALITY-FIXTURE-LAB-02` — `prompts/batches/MOAT-GOAL-REALITY-FIXTURE-LAB-02.md` (partial_implementation; release proof)
  - `MOAT-UNIVERSAL-GOAL-REALITY-COMPILER-01` — `prompts/batches/MOAT-UNIVERSAL-GOAL-REALITY-COMPILER-01.md` (partial_implementation; release proof)
  - `MOAT-GOAL-REALITY-LOCAL-PERSISTENCE-08` — `prompts/batches/MOAT-GOAL-REALITY-LOCAL-PERSISTENCE-08.md` (partial_implementation; release proof)
  - `MOAT-GOAL-REALITY-RECEIPT-CLOSURE-07` — `prompts/batches/MOAT-GOAL-REALITY-RECEIPT-CLOSURE-07.md` (partial_implementation; release proof)
  - `MOAT-GOAL-REALITY-SOURCE-PACKS-09` — `prompts/batches/MOAT-GOAL-REALITY-SOURCE-PACKS-09.md` (partial_implementation; release proof)
  - `MOAT-GOAL-REALITY-TODAY-BRIDGE-06` — `prompts/batches/MOAT-GOAL-REALITY-TODAY-BRIDGE-06.md` (partial_implementation; release proof)

### 14. Same source file targeted by multiple active items: scripts/batch-train-gate-check.sh

- Candidate ID: `AMB28-same_source_file_targeted_by_multiple_active_batches-15166054`
- Evidence type: `same_source_file_targeted_by_multiple_active_batches`
- Severity: `yellow`
- Recommended action: `Merge`
- Linear-ready: `True`
- Auto-resolved: `False`
- Reason: Multiple active work items target the same source file; merge or sequence ownership before implementation.
- Involved active paths:
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
  - ... 105 more

### 15. Same source file targeted by multiple active items: Native/AmbitionsTests/Today/TodayViewModelTests.swift

- Candidate ID: `AMB28-same_source_file_targeted_by_multiple_active_batches-16813789`
- Evidence type: `same_source_file_targeted_by_multiple_active_batches`
- Severity: `yellow`
- Recommended action: `Merge`
- Linear-ready: `True`
- Auto-resolved: `False`
- Reason: Multiple active work items target the same source file; merge or sequence ownership before implementation.
- Involved active paths:
  - `F03_5_Today_Execution_State_Contract_Hardening_Prompt` — `docs/codex/batches/F03_5_Today_Execution_State_Contract_Hardening_Prompt.md` (partial_implementation; release proof)
  - `MOONSHOT_PROOF_PATH_BACKEND_MASTER_PLAN` — `docs/codex/MOONSHOT_PROOF_PATH_BACKEND_MASTER_PLAN.md` (partial_implementation; release proof)
  - `MOAT-MOONSHOT-BACKEND-FULL-TRAIN-01` — `prompts/batches/MOAT-MOONSHOT-BACKEND-FULL-TRAIN-01.md` (partial_implementation; release proof)
  - `MOAT-MOONSHOT-PROOF-PATH-01` — `prompts/batches/MOAT-MOONSHOT-PROOF-PATH-01.md` (partial_implementation; release proof)
  - `MOAT-GOAL-REALITY-TODAY-BRIDGE-06` — `prompts/batches/MOAT-GOAL-REALITY-TODAY-BRIDGE-06.md` (partial_implementation; release proof)
  - `FCP05_Start_Here_Surface_Prompt` — `docs/codex/batches/FCP05_Start_Here_Surface_Prompt.md` (unknown; release proof)
  - `FCP07_Reality_Rail_Continuity_Prompt` — `docs/codex/batches/FCP07_Reality_Rail_Continuity_Prompt.md` (unknown; release proof)
  - `FCP13A_Action_Closure_Diamond_Prompt` — `docs/codex/batches/FCP13A_Action_Closure_Diamond_Prompt.md` (unknown; release proof)

### 16. Same source file targeted by multiple active items: Native/Ambitions/App/AppTab.swift

- Candidate ID: `AMB28-same_source_file_targeted_by_multiple_active_batches-18070532`
- Evidence type: `same_source_file_targeted_by_multiple_active_batches`
- Severity: `yellow`
- Recommended action: `Merge`
- Linear-ready: `True`
- Auto-resolved: `False`
- Reason: Multiple active work items target the same source file; merge or sequence ownership before implementation.
- Involved active paths:
  - `AMB-REPO-AUTHORITY-00-SAFETY-SNAPSHOT` — `prompts/batches/AMB-REPO-AUTHORITY-00-SAFETY-SNAPSHOT.md` (partial_implementation; release proof)
  - `AMB-REPO-AUTHORITY-02-FRONTEND-VISUAL-ENCYCLOPEDIA` — `prompts/batches/AMB-REPO-AUTHORITY-02-FRONTEND-VISUAL-ENCYCLOPEDIA.md` (partial_implementation; release proof)
  - `AMB-REPO-AUTHORITY-06-ACTIVE-DRIFT-REPAIR` — `prompts/batches/AMB-REPO-AUTHORITY-06-ACTIVE-DRIFT-REPAIR.md` (partial_implementation; release proof)
  - `ALIGN-01-NAMING` — `prompts/batches/ALIGN-01-NAMING.md` (partial_implementation; release proof)
  - `TOP-LEVEL-IA-PLAN-LEAK-REGRESSION-01` — `prompts/batches/TOP-LEVEL-IA-PLAN-LEAK-REGRESSION-01.md` (partial_implementation; release proof)
  - `AMB-POST23-01-TRUTH-AUDIT` — `docs/codex/reports/AMB-POST23-01-TRUTH-AUDIT.md` (partial_implementation; release proof)
  - `existing-code-champion-coverage` — `docs/codex/existing-code-champion-coverage.yml` (unknown; release proof)

### 17. Same source file targeted by multiple active items: Native/Ambitions/Domain/CaptureModels.swift

- Candidate ID: `AMB28-same_source_file_targeted_by_multiple_active_batches-19740197`
- Evidence type: `same_source_file_targeted_by_multiple_active_batches`
- Severity: `yellow`
- Recommended action: `Merge`
- Linear-ready: `True`
- Auto-resolved: `False`
- Reason: Multiple active work items target the same source file; merge or sequence ownership before implementation.
- Involved active paths:
  - `PK20` — `prompts/batches/PK20.md` (partial_implementation; release proof)
  - `existing-code-champion-coverage` — `docs/codex/existing-code-champion-coverage.yml` (unknown; release proof)

### 18. Same source file targeted by multiple active items: Native/Ambitions/Features/Today/TodayExecutionProjector.swift

- Candidate ID: `AMB28-same_source_file_targeted_by_multiple_active_batches-20313316`
- Evidence type: `same_source_file_targeted_by_multiple_active_batches`
- Severity: `yellow`
- Recommended action: `Merge`
- Linear-ready: `True`
- Auto-resolved: `False`
- Reason: Multiple active work items target the same source file; merge or sequence ownership before implementation.
- Involved active paths:
  - `PK17` — `prompts/batches/PK17.md` (partial_implementation; release proof)
  - `PK37` — `prompts/batches/PK37.md` (partial_implementation; release proof)
  - `MOONSHOT_PROOF_PATH_BACKEND_MASTER_PLAN` — `docs/codex/MOONSHOT_PROOF_PATH_BACKEND_MASTER_PLAN.md` (partial_implementation; release proof)
  - `MOAT-MOONSHOT-BACKEND-FULL-TRAIN-01` — `prompts/batches/MOAT-MOONSHOT-BACKEND-FULL-TRAIN-01.md` (partial_implementation; release proof)
  - `MOAT-MOONSHOT-PROOF-PATH-01` — `prompts/batches/MOAT-MOONSHOT-PROOF-PATH-01.md` (partial_implementation; release proof)
  - `MOAT-GOAL-REALITY-TODAY-BRIDGE-06` — `prompts/batches/MOAT-GOAL-REALITY-TODAY-BRIDGE-06.md` (partial_implementation; release proof)
  - `FCP05_Start_Here_Surface_Prompt` — `docs/codex/batches/FCP05_Start_Here_Surface_Prompt.md` (unknown; release proof)
  - `FCP07_Reality_Rail_Continuity_Prompt` — `docs/codex/batches/FCP07_Reality_Rail_Continuity_Prompt.md` (unknown; release proof)

### 19. Same source file targeted by multiple active items: Native/Ambitions/PreviewSupport/PreviewGoalsScenarios.swift

- Candidate ID: `AMB28-same_source_file_targeted_by_multiple_active_batches-23403089`
- Evidence type: `same_source_file_targeted_by_multiple_active_batches`
- Severity: `yellow`
- Recommended action: `Merge`
- Linear-ready: `True`
- Auto-resolved: `False`
- Reason: Multiple active work items target the same source file; merge or sequence ownership before implementation.
- Involved active paths:
  - `repo-audit-baseline` — `docs/codex/repo-audit-baseline.md` (partial_implementation; release proof)
  - `FLAGSHIP_COMPLETION_GATE_MATRIX` — `docs/codex/FLAGSHIP_COMPLETION_GATE_MATRIX.md` (partial_implementation; release proof)

### 20. Same source file targeted by multiple active items: Native/Ambitions/PreviewSupport/PreviewFixtures.swift

- Candidate ID: `AMB28-same_source_file_targeted_by_multiple_active_batches-24438436`
- Evidence type: `same_source_file_targeted_by_multiple_active_batches`
- Severity: `yellow`
- Recommended action: `Merge`
- Linear-ready: `True`
- Auto-resolved: `False`
- Reason: Multiple active work items target the same source file; merge or sequence ownership before implementation.
- Involved active paths:
  - `repo-audit-baseline` — `docs/codex/repo-audit-baseline.md` (partial_implementation; release proof)
  - `FLAGSHIP_COMPLETION_GATE_MATRIX` — `docs/codex/FLAGSHIP_COMPLETION_GATE_MATRIX.md` (partial_implementation; release proof)

### 21. Same source file targeted by multiple active items: scripts/ambitions-vocabulary-drift-scan.py

- Candidate ID: `AMB28-same_source_file_targeted_by_multiple_active_batches-26001342`
- Evidence type: `same_source_file_targeted_by_multiple_active_batches`
- Severity: `yellow`
- Recommended action: `Merge`
- Linear-ready: `True`
- Auto-resolved: `False`
- Reason: Multiple active work items target the same source file; merge or sequence ownership before implementation.
- Involved active paths:
  - `AMB-REPO-AUTHORITY-06-ACTIVE-DRIFT-REPAIR` — `prompts/batches/AMB-REPO-AUTHORITY-06-ACTIVE-DRIFT-REPAIR.md` (partial_implementation; release proof)
  - `AMB-REPO-AUTHORITY-07-GATES-FINAL-PROOF` — `prompts/batches/AMB-REPO-AUTHORITY-07-GATES-FINAL-PROOF.md` (partial_implementation; release proof)
  - `TOP-LEVEL-IA-PLAN-LEAK-REGRESSION-01` — `prompts/batches/TOP-LEVEL-IA-PLAN-LEAK-REGRESSION-01.md` (partial_implementation; release proof)

### 22. Same source file targeted by multiple active items: Native/Ambitions/Features/Goals/GoalDetailScreen.swift

- Candidate ID: `AMB28-same_source_file_targeted_by_multiple_active_batches-26268722`
- Evidence type: `same_source_file_targeted_by_multiple_active_batches`
- Severity: `yellow`
- Recommended action: `Merge`
- Linear-ready: `True`
- Auto-resolved: `False`
- Reason: Multiple active work items target the same source file; merge or sequence ownership before implementation.
- Involved active paths:
  - `repo-audit-baseline` — `docs/codex/repo-audit-baseline.md` (partial_implementation; release proof)
  - `PK19` — `prompts/batches/PK19.md` (partial_implementation; release proof)
  - `BATCH-32-explainability-and-source-audit-surfaces` — `docs/codex/batches/BATCH-32-explainability-and-source-audit-surfaces.md` (unknown; release proof)

### 23. Same source file targeted by multiple active items: scripts/sa-source-container-coverage-scan.sh

- Candidate ID: `AMB28-same_source_file_targeted_by_multiple_active_batches-29322830`
- Evidence type: `same_source_file_targeted_by_multiple_active_batches`
- Severity: `yellow`
- Recommended action: `Merge`
- Linear-ready: `True`
- Auto-resolved: `False`
- Reason: Multiple active work items target the same source file; merge or sequence ownership before implementation.
- Involved active paths:
  - `SOURCE_ATLAS_CODEX_OS_UPGRADE_MAP` — `docs/codex/SOURCE_ATLAS_CODEX_OS_UPGRADE_MAP.md` (partial_implementation; release proof)
  - `SA01_SA32_SOURCE_ATLAS_FULL_MATURITY_TRAIN` — `docs/codex/batch-trains/SA01_SA32_SOURCE_ATLAS_FULL_MATURITY_TRAIN.md` (partial_implementation; release proof)

### 24. Same source file targeted by multiple active items: Native/Ambitions/Features/Today/TodayDayRailPanels.swift

- Candidate ID: `AMB28-same_source_file_targeted_by_multiple_active_batches-31694407`
- Evidence type: `same_source_file_targeted_by_multiple_active_batches`
- Severity: `yellow`
- Recommended action: `Merge`
- Linear-ready: `True`
- Auto-resolved: `False`
- Reason: Multiple active work items target the same source file; merge or sequence ownership before implementation.
- Involved active paths:
  - `AMB-POST23-01-TRUTH-AUDIT` — `docs/codex/reports/AMB-POST23-01-TRUTH-AUDIT.md` (partial_implementation; release proof)
  - `FCP05_Start_Here_Surface_Prompt` — `docs/codex/batches/FCP05_Start_Here_Surface_Prompt.md` (unknown; release proof)
  - `FCP07_Reality_Rail_Continuity_Prompt` — `docs/codex/batches/FCP07_Reality_Rail_Continuity_Prompt.md` (unknown; release proof)

### 25. Same source file targeted by multiple active items: scripts/fet-visual-qa-packet-check.sh

- Candidate ID: `AMB28-same_source_file_targeted_by_multiple_active_batches-36264026`
- Evidence type: `same_source_file_targeted_by_multiple_active_batches`
- Severity: `yellow`
- Recommended action: `Merge`
- Linear-ready: `True`
- Auto-resolved: `False`
- Reason: Multiple active work items target the same source file; merge or sequence ownership before implementation.
- Involved active paths:
  - `GLOBAL_BATCH_AUTOMATED_GATE_PROTOCOL` — `docs/codex/GLOBAL_BATCH_AUTOMATED_GATE_PROTOCOL.md` (partial_implementation; release proof)
  - `FET01_FET12_FAANG_FRONTEND_EXCELLENCE_TRAIN` — `docs/codex/batch-trains/FET01_FET12_FAANG_FRONTEND_EXCELLENCE_TRAIN.md` (partial_implementation; release proof)
  - `FET00_FAANG_FRONTEND_CODEX_OS_UPGRADE_PROMPT` — `docs/codex/batches/FET00_FAANG_FRONTEND_CODEX_OS_UPGRADE_PROMPT.md` (partial_implementation; release proof)

### 26. Same source file targeted by multiple active items: Native/Ambitions/App/AppMeridianShell.swift

- Candidate ID: `AMB28-same_source_file_targeted_by_multiple_active_batches-36349612`
- Evidence type: `same_source_file_targeted_by_multiple_active_batches`
- Severity: `yellow`
- Recommended action: `Merge`
- Linear-ready: `True`
- Auto-resolved: `False`
- Reason: Multiple active work items target the same source file; merge or sequence ownership before implementation.
- Involved active paths:
  - `FCP08_Ambition_Meridian_Shell_Prompt` — `docs/codex/batches/FCP08_Ambition_Meridian_Shell_Prompt.md` (unknown; release proof)
  - `AQOS_BATCH_IMPACT_CLASSIFIER` — `docs/codex/quality/AQOS_BATCH_IMPACT_CLASSIFIER.md` (unknown; release proof)
  - `existing-code-champion-coverage` — `docs/codex/existing-code-champion-coverage.yml` (unknown; release proof)

### 27. Same source file targeted by multiple active items: scripts/fet-first-viewport-budget-scan.sh

- Candidate ID: `AMB28-same_source_file_targeted_by_multiple_active_batches-39316650`
- Evidence type: `same_source_file_targeted_by_multiple_active_batches`
- Severity: `yellow`
- Recommended action: `Merge`
- Linear-ready: `True`
- Auto-resolved: `False`
- Reason: Multiple active work items target the same source file; merge or sequence ownership before implementation.
- Involved active paths:
  - `GLOBAL_BATCH_AUTOMATED_GATE_PROTOCOL` — `docs/codex/GLOBAL_BATCH_AUTOMATED_GATE_PROTOCOL.md` (partial_implementation; release proof)
  - `FET01_FET12_FAANG_FRONTEND_EXCELLENCE_TRAIN` — `docs/codex/batch-trains/FET01_FET12_FAANG_FRONTEND_EXCELLENCE_TRAIN.md` (partial_implementation; release proof)
  - `FET00_FAANG_FRONTEND_CODEX_OS_UPGRADE_PROMPT` — `docs/codex/batches/FET00_FAANG_FRONTEND_CODEX_OS_UPGRADE_PROMPT.md` (partial_implementation; release proof)

### 28. Same source file targeted by multiple active items: scripts/fet-copy-density-scan.sh

- Candidate ID: `AMB28-same_source_file_targeted_by_multiple_active_batches-39729413`
- Evidence type: `same_source_file_targeted_by_multiple_active_batches`
- Severity: `yellow`
- Recommended action: `Merge`
- Linear-ready: `True`
- Auto-resolved: `False`
- Reason: Multiple active work items target the same source file; merge or sequence ownership before implementation.
- Involved active paths:
  - `GLOBAL_BATCH_AUTOMATED_GATE_PROTOCOL` — `docs/codex/GLOBAL_BATCH_AUTOMATED_GATE_PROTOCOL.md` (partial_implementation; release proof)
  - `FET01_FET12_FAANG_FRONTEND_EXCELLENCE_TRAIN` — `docs/codex/batch-trains/FET01_FET12_FAANG_FRONTEND_EXCELLENCE_TRAIN.md` (partial_implementation; release proof)
  - `FET00_FAANG_FRONTEND_CODEX_OS_UPGRADE_PROMPT` — `docs/codex/batches/FET00_FAANG_FRONTEND_CODEX_OS_UPGRADE_PROMPT.md` (partial_implementation; release proof)

### 29. Same source file targeted by multiple active items: scripts/cqs-privacy-security-claim-scan.sh

- Candidate ID: `AMB28-same_source_file_targeted_by_multiple_active_batches-39876285`
- Evidence type: `same_source_file_targeted_by_multiple_active_batches`
- Severity: `yellow`
- Recommended action: `Merge`
- Linear-ready: `True`
- Auto-resolved: `False`
- Reason: Multiple active work items target the same source file; merge or sequence ownership before implementation.
- Involved active paths:
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
  - ... 1 more

### 30. Same source file targeted by multiple active items: Native/Ambitions/Features/Goals/GoalsFeatureService.swift

- Candidate ID: `AMB28-same_source_file_targeted_by_multiple_active_batches-40878629`
- Evidence type: `same_source_file_targeted_by_multiple_active_batches`
- Severity: `yellow`
- Recommended action: `Merge`
- Linear-ready: `True`
- Auto-resolved: `False`
- Reason: Multiple active work items target the same source file; merge or sequence ownership before implementation.
- Involved active paths:
  - `repo-audit-baseline` — `docs/codex/repo-audit-baseline.md` (partial_implementation; release proof)
  - `BATCH-33-intelligence-runtime-integration` — `docs/codex/batches/BATCH-33-intelligence-runtime-integration.md` (partial_implementation; release proof)
  - `PK19` — `prompts/batches/PK19.md` (partial_implementation; release proof)
  - `PK37` — `prompts/batches/PK37.md` (partial_implementation; release proof)

### 31. Same source file targeted by multiple active items: scripts/si-visual-qa-report.sh

- Candidate ID: `AMB28-same_source_file_targeted_by_multiple_active_batches-43014259`
- Evidence type: `same_source_file_targeted_by_multiple_active_batches`
- Severity: `yellow`
- Recommended action: `Merge`
- Linear-ready: `True`
- Auto-resolved: `False`
- Reason: Multiple active work items target the same source file; merge or sequence ownership before implementation.
- Involved active paths:
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
  - ... 5 more

### 32. Same source file targeted by multiple active items: scripts/ambitions-control-plane-check.py

- Candidate ID: `AMB28-same_source_file_targeted_by_multiple_active_batches-43654621`
- Evidence type: `same_source_file_targeted_by_multiple_active_batches`
- Severity: `yellow`
- Recommended action: `Merge`
- Linear-ready: `True`
- Auto-resolved: `False`
- Reason: Multiple active work items target the same source file; merge or sequence ownership before implementation.
- Involved active paths:
  - `AMB_CONTROL_PLANE_DIRECT_RUNBOOK` — `docs/codex/AMB_CONTROL_PLANE_DIRECT_RUNBOOK.md` (partial_implementation; release proof)
  - `AMB_CONTROL_PLANE_GATE_INDEX` — `docs/codex/AMB_CONTROL_PLANE_GATE_INDEX.md` (partial_implementation; release proof)
  - `XCODE-BUILD-SYSTEM-MAX-01-REPAIR-01` — `prompts/batches/XCODE-BUILD-SYSTEM-MAX-01-REPAIR-01.md` (partial_implementation; release proof)
  - `HBI-GLOBAL-TRAIN-HANDOFF-01` — `prompts/batches/HBI-GLOBAL-TRAIN-HANDOFF-01.md` (partial_implementation; release proof)

### 33. Same source file targeted by multiple active items: Native/Ambitions/Features/Goals/GoalsScreen.swift

- Candidate ID: `AMB28-same_source_file_targeted_by_multiple_active_batches-45693093`
- Evidence type: `same_source_file_targeted_by_multiple_active_batches`
- Severity: `yellow`
- Recommended action: `Merge`
- Linear-ready: `True`
- Auto-resolved: `False`
- Reason: Multiple active work items target the same source file; merge or sequence ownership before implementation.
- Involved active paths:
  - `repo-audit-baseline` — `docs/codex/repo-audit-baseline.md` (partial_implementation; release proof)
  - `PK19` — `prompts/batches/PK19.md` (partial_implementation; release proof)
  - `AMB-POST23-01-TRUTH-AUDIT` — `docs/codex/reports/AMB-POST23-01-TRUTH-AUDIT.md` (partial_implementation; release proof)

### 34. Same source file targeted by multiple active items: scripts/build-local.sh

- Candidate ID: `AMB28-same_source_file_targeted_by_multiple_active_batches-46269820`
- Evidence type: `same_source_file_targeted_by_multiple_active_batches`
- Severity: `yellow`
- Recommended action: `Merge`
- Linear-ready: `True`
- Auto-resolved: `False`
- Reason: Multiple active work items target the same source file; merge or sequence ownership before implementation.
- Involved active paths:
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
  - ... 50 more

### 35. Same source file targeted by multiple active items: scripts/fet-primitive-density-scan.sh

- Candidate ID: `AMB28-same_source_file_targeted_by_multiple_active_batches-49203811`
- Evidence type: `same_source_file_targeted_by_multiple_active_batches`
- Severity: `yellow`
- Recommended action: `Merge`
- Linear-ready: `True`
- Auto-resolved: `False`
- Reason: Multiple active work items target the same source file; merge or sequence ownership before implementation.
- Involved active paths:
  - `GLOBAL_BATCH_AUTOMATED_GATE_PROTOCOL` — `docs/codex/GLOBAL_BATCH_AUTOMATED_GATE_PROTOCOL.md` (partial_implementation; release proof)
  - `FET01_FET12_FAANG_FRONTEND_EXCELLENCE_TRAIN` — `docs/codex/batch-trains/FET01_FET12_FAANG_FRONTEND_EXCELLENCE_TRAIN.md` (partial_implementation; release proof)
  - `FET00_FAANG_FRONTEND_CODEX_OS_UPGRADE_PROMPT` — `docs/codex/batches/FET00_FAANG_FRONTEND_CODEX_OS_UPGRADE_PROMPT.md` (partial_implementation; release proof)

### 36. Same source file targeted by multiple active items: scripts/fet-readiness-gate.sh

- Candidate ID: `AMB28-same_source_file_targeted_by_multiple_active_batches-49923392`
- Evidence type: `same_source_file_targeted_by_multiple_active_batches`
- Severity: `yellow`
- Recommended action: `Merge`
- Linear-ready: `True`
- Auto-resolved: `False`
- Reason: Multiple active work items target the same source file; merge or sequence ownership before implementation.
- Involved active paths:
  - `GLOBAL_BATCH_AUTOMATED_GATE_PROTOCOL` — `docs/codex/GLOBAL_BATCH_AUTOMATED_GATE_PROTOCOL.md` (partial_implementation; release proof)
  - `FET01_FET12_FAANG_FRONTEND_EXCELLENCE_TRAIN` — `docs/codex/batch-trains/FET01_FET12_FAANG_FRONTEND_EXCELLENCE_TRAIN.md` (partial_implementation; release proof)
  - `FET00_FAANG_FRONTEND_CODEX_OS_UPGRADE_PROMPT` — `docs/codex/batches/FET00_FAANG_FRONTEND_CODEX_OS_UPGRADE_PROMPT.md` (partial_implementation; release proof)

### 37. Same source file targeted by multiple active items: Native/Ambitions/Features/Capture/CaptureScreen.swift

- Candidate ID: `AMB28-same_source_file_targeted_by_multiple_active_batches-52882976`
- Evidence type: `same_source_file_targeted_by_multiple_active_batches`
- Severity: `yellow`
- Recommended action: `Merge`
- Linear-ready: `True`
- Auto-resolved: `False`
- Reason: Multiple active work items target the same source file; merge or sequence ownership before implementation.
- Involved active paths:
  - `repo-audit-baseline` — `docs/codex/repo-audit-baseline.md` (partial_implementation; release proof)
  - `AMB-POST23-01-TRUTH-AUDIT` — `docs/codex/reports/AMB-POST23-01-TRUTH-AUDIT.md` (partial_implementation; release proof)

### 38. Same source file targeted by multiple active items: scripts/sa-no-claim-scan.sh

- Candidate ID: `AMB28-same_source_file_targeted_by_multiple_active_batches-54582784`
- Evidence type: `same_source_file_targeted_by_multiple_active_batches`
- Severity: `yellow`
- Recommended action: `Merge`
- Linear-ready: `True`
- Auto-resolved: `False`
- Reason: Multiple active work items target the same source file; merge or sequence ownership before implementation.
- Involved active paths:
  - `SOURCE_ATLAS_CODEX_OS_UPGRADE_MAP` — `docs/codex/SOURCE_ATLAS_CODEX_OS_UPGRADE_MAP.md` (partial_implementation; release proof)
  - `SA01_SA32_SOURCE_ATLAS_FULL_MATURITY_TRAIN` — `docs/codex/batch-trains/SA01_SA32_SOURCE_ATLAS_FULL_MATURITY_TRAIN.md` (partial_implementation; release proof)

### 39. Same source file targeted by multiple active items: scripts/swiftui-architecture-scan.sh

- Candidate ID: `AMB28-same_source_file_targeted_by_multiple_active_batches-57884692`
- Evidence type: `same_source_file_targeted_by_multiple_active_batches`
- Severity: `yellow`
- Recommended action: `Merge`
- Linear-ready: `True`
- Auto-resolved: `False`
- Reason: Multiple active work items target the same source file; merge or sequence ownership before implementation.
- Involved active paths:
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
  - ... 9 more

### 40. Same source file targeted by multiple active items: scripts/ambitions-visual-100-anti-generic-check.py

- Candidate ID: `AMB28-same_source_file_targeted_by_multiple_active_batches-60858350`
- Evidence type: `same_source_file_targeted_by_multiple_active_batches`
- Severity: `yellow`
- Recommended action: `Merge`
- Linear-ready: `True`
- Auto-resolved: `False`
- Reason: Multiple active work items target the same source file; merge or sequence ownership before implementation.
- Involved active paths:
  - `FLAGSHIP-OBJECT-SYSTEM-01` — `prompts/batches/FLAGSHIP-OBJECT-SYSTEM-01.md` (partial_implementation; release proof)
  - `AMB-FLAGSHIP-UI-CODEX-STUDIO-INSTALL-01` — `docs/codex/reports/AMB-FLAGSHIP-UI-CODEX-STUDIO-INSTALL-01.md` (partial_implementation; release proof)

### 41. Same source file targeted by multiple active items: scripts/ambitions-final-report-gate.py

- Candidate ID: `AMB28-same_source_file_targeted_by_multiple_active_batches-63740124`
- Evidence type: `same_source_file_targeted_by_multiple_active_batches`
- Severity: `yellow`
- Recommended action: `Merge`
- Linear-ready: `True`
- Auto-resolved: `False`
- Reason: Multiple active work items target the same source file; merge or sequence ownership before implementation.
- Involved active paths:
  - `AMB_CONTROL_PLANE_DIRECT_RUNBOOK` — `docs/codex/AMB_CONTROL_PLANE_DIRECT_RUNBOOK.md` (partial_implementation; release proof)
  - `AMB_CONTROL_PLANE_GATE_INDEX` — `docs/codex/AMB_CONTROL_PLANE_GATE_INDEX.md` (partial_implementation; release proof)
  - `XCODE-BUILD-SYSTEM-MAX-01-REPAIR-01` — `prompts/batches/XCODE-BUILD-SYSTEM-MAX-01-REPAIR-01.md` (partial_implementation; release proof)

### 42. Same source file targeted by multiple active items: Native/Ambitions/Features/Today/DayRailViewState.swift

- Candidate ID: `AMB28-same_source_file_targeted_by_multiple_active_batches-64051452`
- Evidence type: `same_source_file_targeted_by_multiple_active_batches`
- Severity: `yellow`
- Recommended action: `Merge`
- Linear-ready: `True`
- Auto-resolved: `False`
- Reason: Multiple active work items target the same source file; merge or sequence ownership before implementation.
- Involved active paths:
  - `MOONSHOT_PROOF_PATH_BACKEND_MASTER_PLAN` — `docs/codex/MOONSHOT_PROOF_PATH_BACKEND_MASTER_PLAN.md` (partial_implementation; release proof)
  - `MOAT-MOONSHOT-BACKEND-FULL-TRAIN-01` — `prompts/batches/MOAT-MOONSHOT-BACKEND-FULL-TRAIN-01.md` (partial_implementation; release proof)
  - `MOAT-MOONSHOT-PROOF-PATH-01` — `prompts/batches/MOAT-MOONSHOT-PROOF-PATH-01.md` (partial_implementation; release proof)
  - `MOAT-GOAL-REALITY-TODAY-BRIDGE-06` — `prompts/batches/MOAT-GOAL-REALITY-TODAY-BRIDGE-06.md` (partial_implementation; release proof)
  - `FCP05_Start_Here_Surface_Prompt` — `docs/codex/batches/FCP05_Start_Here_Surface_Prompt.md` (unknown; release proof)
  - `FCP07_Reality_Rail_Continuity_Prompt` — `docs/codex/batches/FCP07_Reality_Rail_Continuity_Prompt.md` (unknown; release proof)

### 43. Same source file targeted by multiple active items: scripts/run-doc-qa.sh

- Candidate ID: `AMB28-same_source_file_targeted_by_multiple_active_batches-644983`
- Evidence type: `same_source_file_targeted_by_multiple_active_batches`
- Severity: `yellow`
- Recommended action: `Merge`
- Linear-ready: `True`
- Auto-resolved: `False`
- Reason: Multiple active work items target the same source file; merge or sequence ownership before implementation.
- Involved active paths:
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
  - ... 102 more

### 44. Same source file targeted by multiple active items: scripts/cqs-product-drift-scan.sh

- Candidate ID: `AMB28-same_source_file_targeted_by_multiple_active_batches-66982787`
- Evidence type: `same_source_file_targeted_by_multiple_active_batches`
- Severity: `yellow`
- Recommended action: `Merge`
- Linear-ready: `True`
- Auto-resolved: `False`
- Reason: Multiple active work items target the same source file; merge or sequence ownership before implementation.
- Involved active paths:
  - `CQS01_CQS24_CODEX_QUALITY_SYSTEM_TRAIN` — `docs/codex/batch-trains/CQS01_CQS24_CODEX_QUALITY_SYSTEM_TRAIN.md` (partial_implementation; release proof)
  - `PFC03_Dead_Code_Prompt_Artifact_Naming_Smell_Audit_Prompt` — `docs/codex/batches/PFC03_Dead_Code_Prompt_Artifact_Naming_Smell_Audit_Prompt.md` (partial_implementation; release proof)
  - `GATE_RESULT_MANIFEST_SCHEMA` — `docs/codex/GATE_RESULT_MANIFEST_SCHEMA.md` (partial_implementation; release proof)
  - `GATE_SYSTEM_HARDENING_NEXT_PROMPT` — `docs/codex/batches/GATE_SYSTEM_HARDENING_NEXT_PROMPT.md` (partial_implementation; release proof)
  - `MOONSHOT_PROOF_PATH_BACKEND_MASTER_PLAN` — `docs/codex/MOONSHOT_PROOF_PATH_BACKEND_MASTER_PLAN.md` (partial_implementation; release proof)
  - `MOAT-MOONSHOT-BACKEND-FULL-TRAIN-01` — `prompts/batches/MOAT-MOONSHOT-BACKEND-FULL-TRAIN-01.md` (partial_implementation; release proof)
  - `MOAT-MOONSHOT-PROOF-PATH-01` — `prompts/batches/MOAT-MOONSHOT-PROOF-PATH-01.md` (partial_implementation; release proof)
  - `MOAT-UNIVERSAL-GOAL-REALITY-COMPILER-01` — `prompts/batches/MOAT-UNIVERSAL-GOAL-REALITY-COMPILER-01.md` (partial_implementation; release proof)
  - `CODEX_QUALITY_SYSTEM_SCRIPT_MAP` — `docs/codex/CODEX_QUALITY_SYSTEM_SCRIPT_MAP.md` (unknown; release proof)

### 45. Same source file targeted by multiple active items: scripts/sa-offline-fallback-scan.sh

- Candidate ID: `AMB28-same_source_file_targeted_by_multiple_active_batches-6975657`
- Evidence type: `same_source_file_targeted_by_multiple_active_batches`
- Severity: `yellow`
- Recommended action: `Merge`
- Linear-ready: `True`
- Auto-resolved: `False`
- Reason: Multiple active work items target the same source file; merge or sequence ownership before implementation.
- Involved active paths:
  - `SOURCE_ATLAS_CODEX_OS_UPGRADE_MAP` — `docs/codex/SOURCE_ATLAS_CODEX_OS_UPGRADE_MAP.md` (partial_implementation; release proof)
  - `SA01_SA32_SOURCE_ATLAS_FULL_MATURITY_TRAIN` — `docs/codex/batch-trains/SA01_SA32_SOURCE_ATLAS_FULL_MATURITY_TRAIN.md` (partial_implementation; release proof)

### 46. Same source file targeted by multiple active items: Native/AmbitionsTests/App/AppShellNavigationTests.swift

- Candidate ID: `AMB28-same_source_file_targeted_by_multiple_active_batches-70593123`
- Evidence type: `same_source_file_targeted_by_multiple_active_batches`
- Severity: `yellow`
- Recommended action: `Merge`
- Linear-ready: `True`
- Auto-resolved: `False`
- Reason: Multiple active work items target the same source file; merge or sequence ownership before implementation.
- Involved active paths:
  - `TOP-LEVEL-IA-PLAN-LEAK-REGRESSION-01` — `prompts/batches/TOP-LEVEL-IA-PLAN-LEAK-REGRESSION-01.md` (partial_implementation; release proof)
  - `FCP08_Ambition_Meridian_Shell_Prompt` — `docs/codex/batches/FCP08_Ambition_Meridian_Shell_Prompt.md` (unknown; release proof)

### 47. Same source file targeted by multiple active items: scripts/ambitions-codex-os-validate.py

- Candidate ID: `AMB28-same_source_file_targeted_by_multiple_active_batches-71599116`
- Evidence type: `same_source_file_targeted_by_multiple_active_batches`
- Severity: `yellow`
- Recommended action: `Merge`
- Linear-ready: `True`
- Auto-resolved: `False`
- Reason: Multiple active work items target the same source file; merge or sequence ownership before implementation.
- Involved active paths:
  - `AMB-REPO-AUTHORITY-07-GATES-FINAL-PROOF` — `prompts/batches/AMB-REPO-AUTHORITY-07-GATES-FINAL-PROOF.md` (partial_implementation; release proof)
  - `AMB-CODEX-OS-FLAGSHIP-UPGRADE-INSTALL-01` — `docs/codex/reports/AMB-CODEX-OS-FLAGSHIP-UPGRADE-INSTALL-01.md` (partial_implementation; release proof)
  - `OS-FLAGSHIP-07-SKILL-REGISTRY-AND-RUNNER-INTEGRATION` — `prompts/batches/OS-FLAGSHIP-07-SKILL-REGISTRY-AND-RUNNER-INTEGRATION.md` (partial_implementation; release proof)
  - `AMB-REPO-GREEN-FLAGSHIP-RESET-MASTER-01-T01-AUDIT-CALIBRATION` — `prompts/batches/AMB-REPO-GREEN-FLAGSHIP-RESET-MASTER-01-T01-AUDIT-CALIBRATION.md` (partial_implementation; release proof)
  - `AMB-LINEAR-TEMPLATE-MANIFEST` — `docs/codex/linear-templates/AMB-LINEAR-TEMPLATE-MANIFEST.yml` (partial_implementation; release proof)

### 48. Same source file targeted by multiple active items: Native/Ambitions/Features/Today/TodayScreen.swift

- Candidate ID: `AMB28-same_source_file_targeted_by_multiple_active_batches-73269029`
- Evidence type: `same_source_file_targeted_by_multiple_active_batches`
- Severity: `yellow`
- Recommended action: `Merge`
- Linear-ready: `True`
- Auto-resolved: `False`
- Reason: Multiple active work items target the same source file; merge or sequence ownership before implementation.
- Involved active paths:
  - `repo-audit-baseline` — `docs/codex/repo-audit-baseline.md` (partial_implementation; release proof)
  - `PK17` — `prompts/batches/PK17.md` (partial_implementation; release proof)
  - `FLAGSHIP-OBJECT-SYSTEM-01` — `prompts/batches/FLAGSHIP-OBJECT-SYSTEM-01.md` (partial_implementation; release proof)
  - `AMB-POST23-01-TRUTH-AUDIT` — `docs/codex/reports/AMB-POST23-01-TRUTH-AUDIT.md` (partial_implementation; release proof)

### 49. Same source file targeted by multiple active items: Native/Ambitions/Features/Goals/GoalsFeatureModels.swift

- Candidate ID: `AMB28-same_source_file_targeted_by_multiple_active_batches-7402687`
- Evidence type: `same_source_file_targeted_by_multiple_active_batches`
- Severity: `yellow`
- Recommended action: `Merge`
- Linear-ready: `True`
- Auto-resolved: `False`
- Reason: Multiple active work items target the same source file; merge or sequence ownership before implementation.
- Involved active paths:
  - `PK19` — `prompts/batches/PK19.md` (partial_implementation; release proof)
  - `BATCH-32-explainability-and-source-audit-surfaces` — `docs/codex/batches/BATCH-32-explainability-and-source-audit-surfaces.md` (unknown; release proof)

### 50. Same source file targeted by multiple active items: scripts/ambitions-unsupported-claim-scan.py

- Candidate ID: `AMB28-same_source_file_targeted_by_multiple_active_batches-75250300`
- Evidence type: `same_source_file_targeted_by_multiple_active_batches`
- Severity: `yellow`
- Recommended action: `Merge`
- Linear-ready: `True`
- Auto-resolved: `False`
- Reason: Multiple active work items target the same source file; merge or sequence ownership before implementation.
- Involved active paths:
  - `MRI00-MOAT-RUNTIME-GAP-LOCK` — `prompts/batches/MRI00-MOAT-RUNTIME-GAP-LOCK.md` (partial_implementation; release proof)
  - `OBS00-OPENAI-BUILD-SUITE-INSTALL` — `prompts/batches/OBS00-OPENAI-BUILD-SUITE-INSTALL.md` (partial_implementation; release proof)
  - `SPEED_TRAIN_LANE_POLICY` — `docs/codex/SPEED_TRAIN_LANE_POLICY.json` (unknown; release proof)

### 51. Same source file targeted by multiple active items: scripts/ambitions-source-atlas-title-check.py

- Candidate ID: `AMB28-same_source_file_targeted_by_multiple_active_batches-76523821`
- Evidence type: `same_source_file_targeted_by_multiple_active_batches`
- Severity: `yellow`
- Recommended action: `Merge`
- Linear-ready: `True`
- Auto-resolved: `False`
- Reason: Multiple active work items target the same source file; merge or sequence ownership before implementation.
- Involved active paths:
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
  - ... 25 more

### 52. Same source file targeted by multiple active items: Native/Ambitions/App/AmbitionsRootView.swift

- Candidate ID: `AMB28-same_source_file_targeted_by_multiple_active_batches-80026133`
- Evidence type: `same_source_file_targeted_by_multiple_active_batches`
- Severity: `yellow`
- Recommended action: `Merge`
- Linear-ready: `True`
- Auto-resolved: `False`
- Reason: Multiple active work items target the same source file; merge or sequence ownership before implementation.
- Involved active paths:
  - `repo-audit-baseline` — `docs/codex/repo-audit-baseline.md` (partial_implementation; release proof)
  - `AMB-REPO-AUTHORITY-00-SAFETY-SNAPSHOT` — `prompts/batches/AMB-REPO-AUTHORITY-00-SAFETY-SNAPSHOT.md` (partial_implementation; release proof)
  - `AMB-REPO-AUTHORITY-02-FRONTEND-VISUAL-ENCYCLOPEDIA` — `prompts/batches/AMB-REPO-AUTHORITY-02-FRONTEND-VISUAL-ENCYCLOPEDIA.md` (partial_implementation; release proof)
  - `AMB-REPO-AUTHORITY-06-ACTIVE-DRIFT-REPAIR` — `prompts/batches/AMB-REPO-AUTHORITY-06-ACTIVE-DRIFT-REPAIR.md` (partial_implementation; release proof)
  - `ALIGN-01-NAMING` — `prompts/batches/ALIGN-01-NAMING.md` (partial_implementation; release proof)
  - `TOP-LEVEL-IA-PLAN-LEAK-REGRESSION-01` — `prompts/batches/TOP-LEVEL-IA-PLAN-LEAK-REGRESSION-01.md` (partial_implementation; release proof)
  - `AQOS_BATCH_IMPACT_CLASSIFIER` — `docs/codex/quality/AQOS_BATCH_IMPACT_CLASSIFIER.md` (unknown; release proof)
  - `FRONTEND_SHELL_BOTTOM_CHROME_OWNERSHIP_GATE` — `docs/codex/FRONTEND_SHELL_BOTTOM_CHROME_OWNERSHIP_GATE.md` (unknown; release proof)
  - `existing-code-champion-coverage` — `docs/codex/existing-code-champion-coverage.yml` (unknown; release proof)

### 53. Same source file targeted by multiple active items: scripts/cqs-prompt-built-smell-scan.sh

- Candidate ID: `AMB28-same_source_file_targeted_by_multiple_active_batches-80786611`
- Evidence type: `same_source_file_targeted_by_multiple_active_batches`
- Severity: `yellow`
- Recommended action: `Merge`
- Linear-ready: `True`
- Auto-resolved: `False`
- Reason: Multiple active work items target the same source file; merge or sequence ownership before implementation.
- Involved active paths:
  - `CQS01_CQS24_CODEX_QUALITY_SYSTEM_TRAIN` — `docs/codex/batch-trains/CQS01_CQS24_CODEX_QUALITY_SYSTEM_TRAIN.md` (partial_implementation; release proof)
  - `PFC03_Dead_Code_Prompt_Artifact_Naming_Smell_Audit_Prompt` — `docs/codex/batches/PFC03_Dead_Code_Prompt_Artifact_Naming_Smell_Audit_Prompt.md` (partial_implementation; release proof)
  - `GATE_SYSTEM_HARDENING_NEXT_PROMPT` — `docs/codex/batches/GATE_SYSTEM_HARDENING_NEXT_PROMPT.md` (partial_implementation; release proof)
  - `MOONSHOT_PROOF_PATH_BACKEND_MASTER_PLAN` — `docs/codex/MOONSHOT_PROOF_PATH_BACKEND_MASTER_PLAN.md` (partial_implementation; release proof)
  - `MOAT-MOONSHOT-BACKEND-FULL-TRAIN-01` — `prompts/batches/MOAT-MOONSHOT-BACKEND-FULL-TRAIN-01.md` (partial_implementation; release proof)
  - `MOAT-MOONSHOT-PROOF-PATH-01` — `prompts/batches/MOAT-MOONSHOT-PROOF-PATH-01.md` (partial_implementation; release proof)
  - `MOAT-UNIVERSAL-GOAL-REALITY-COMPILER-01` — `prompts/batches/MOAT-UNIVERSAL-GOAL-REALITY-COMPILER-01.md` (partial_implementation; release proof)
  - `CODEX_QUALITY_SYSTEM_SCRIPT_MAP` — `docs/codex/CODEX_QUALITY_SYSTEM_SCRIPT_MAP.md` (unknown; release proof)

### 54. Same source file targeted by multiple active items: scripts/ambitions-codex-train.sh

- Candidate ID: `AMB28-same_source_file_targeted_by_multiple_active_batches-81133443`
- Evidence type: `same_source_file_targeted_by_multiple_active_batches`
- Severity: `yellow`
- Recommended action: `Merge`
- Linear-ready: `True`
- Auto-resolved: `False`
- Reason: Multiple active work items target the same source file; merge or sequence ownership before implementation.
- Involved active paths:
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
  - ... 285 more

### 55. Same source file targeted by multiple active items: Native/Ambitions/App/AppShellPresentationMode.swift

- Candidate ID: `AMB28-same_source_file_targeted_by_multiple_active_batches-81406637`
- Evidence type: `same_source_file_targeted_by_multiple_active_batches`
- Severity: `yellow`
- Recommended action: `Merge`
- Linear-ready: `True`
- Auto-resolved: `False`
- Reason: Multiple active work items target the same source file; merge or sequence ownership before implementation.
- Involved active paths:
  - `FCP08_Ambition_Meridian_Shell_Prompt` — `docs/codex/batches/FCP08_Ambition_Meridian_Shell_Prompt.md` (unknown; release proof)
  - `existing-code-champion-coverage` — `docs/codex/existing-code-champion-coverage.yml` (unknown; release proof)

### 56. Same source file targeted by multiple active items: Native/Ambitions/PreviewSupport/PreviewTodayScenarios.swift

- Candidate ID: `AMB28-same_source_file_targeted_by_multiple_active_batches-82039618`
- Evidence type: `same_source_file_targeted_by_multiple_active_batches`
- Severity: `yellow`
- Recommended action: `Merge`
- Linear-ready: `True`
- Auto-resolved: `False`
- Reason: Multiple active work items target the same source file; merge or sequence ownership before implementation.
- Involved active paths:
  - `repo-audit-baseline` — `docs/codex/repo-audit-baseline.md` (partial_implementation; release proof)
  - `FLAGSHIP_COMPLETION_GATE_MATRIX` — `docs/codex/FLAGSHIP_COMPLETION_GATE_MATRIX.md` (partial_implementation; release proof)
  - `MOONSHOT_PROOF_PATH_BACKEND_MASTER_PLAN` — `docs/codex/MOONSHOT_PROOF_PATH_BACKEND_MASTER_PLAN.md` (partial_implementation; release proof)
  - `MOAT-MOONSHOT-BACKEND-FULL-TRAIN-01` — `prompts/batches/MOAT-MOONSHOT-BACKEND-FULL-TRAIN-01.md` (partial_implementation; release proof)
  - `MOAT-MOONSHOT-PROOF-PATH-01` — `prompts/batches/MOAT-MOONSHOT-PROOF-PATH-01.md` (partial_implementation; release proof)
  - `MOAT-GOAL-REALITY-TODAY-BRIDGE-06` — `prompts/batches/MOAT-GOAL-REALITY-TODAY-BRIDGE-06.md` (partial_implementation; release proof)
  - `FCP05_Start_Here_Surface_Prompt` — `docs/codex/batches/FCP05_Start_Here_Surface_Prompt.md` (unknown; release proof)
  - `FCP07_Reality_Rail_Continuity_Prompt` — `docs/codex/batches/FCP07_Reality_Rail_Continuity_Prompt.md` (unknown; release proof)

### 57. Same source file targeted by multiple active items: Native/AmbitionsTests/Runtime/GoalRealityGoldenFixtureTests.swift

- Candidate ID: `AMB28-same_source_file_targeted_by_multiple_active_batches-8465283`
- Evidence type: `same_source_file_targeted_by_multiple_active_batches`
- Severity: `yellow`
- Recommended action: `Merge`
- Linear-ready: `True`
- Auto-resolved: `False`
- Reason: Multiple active work items target the same source file; merge or sequence ownership before implementation.
- Involved active paths:
  - `GOAL_REALITY_COMPILER_BACKEND_MASTER_PLAN` — `docs/codex/GOAL_REALITY_COMPILER_BACKEND_MASTER_PLAN.md` (partial_implementation; release proof)
  - `MOAT-GOAL-REALITY-FIXTURE-LAB-02` — `prompts/batches/MOAT-GOAL-REALITY-FIXTURE-LAB-02.md` (partial_implementation; release proof)
  - `MOAT-UNIVERSAL-GOAL-REALITY-COMPILER-01` — `prompts/batches/MOAT-UNIVERSAL-GOAL-REALITY-COMPILER-01.md` (partial_implementation; release proof)
  - `MOAT-GOAL-REALITY-EVAL-HARNESS-10` — `prompts/batches/MOAT-GOAL-REALITY-EVAL-HARNESS-10.md` (partial_implementation; release proof)
  - `MOAT-GOAL-REALITY-TODAY-BRIDGE-06` — `prompts/batches/MOAT-GOAL-REALITY-TODAY-BRIDGE-06.md` (partial_implementation; release proof)

### 58. Same source file targeted by multiple active items: Native/Ambitions/Features/Profile/ProfileScreen.swift

- Candidate ID: `AMB28-same_source_file_targeted_by_multiple_active_batches-85196815`
- Evidence type: `same_source_file_targeted_by_multiple_active_batches`
- Severity: `yellow`
- Recommended action: `Merge`
- Linear-ready: `True`
- Auto-resolved: `False`
- Reason: Multiple active work items target the same source file; merge or sequence ownership before implementation.
- Involved active paths:
  - `ALIGN-01-NAMING` — `prompts/batches/ALIGN-01-NAMING.md` (partial_implementation; release proof)
  - `FCP17_Schedule_Availability_Defaults_Center_Prompt` — `docs/codex/batches/FCP17_Schedule_Availability_Defaults_Center_Prompt.md` (unknown; release proof)

### 59. Same source file targeted by multiple active items: Native/Ambitions/Persistence/PersistenceContracts.swift

- Candidate ID: `AMB28-same_source_file_targeted_by_multiple_active_batches-86570980`
- Evidence type: `same_source_file_targeted_by_multiple_active_batches`
- Severity: `yellow`
- Recommended action: `Merge`
- Linear-ready: `True`
- Auto-resolved: `False`
- Reason: Multiple active work items target the same source file; merge or sequence ownership before implementation.
- Involved active paths:
  - `repo-audit-baseline` — `docs/codex/repo-audit-baseline.md` (partial_implementation; release proof)
  - `PK22` — `prompts/batches/PK22.md` (partial_implementation; release proof)
  - `BACKEND-FINAL-FORM-LOCAL-FIRST-HUMAN-01` — `prompts/batches/BACKEND-FINAL-FORM-LOCAL-FIRST-HUMAN-01.md` (partial_implementation; release proof)
  - `MOAT-GOAL-REALITY-LOCAL-PERSISTENCE-08` — `prompts/batches/MOAT-GOAL-REALITY-LOCAL-PERSISTENCE-08.md` (partial_implementation; release proof)
  - `BATCH-31-correction-and-teaching-loop` — `docs/codex/batches/BATCH-31-correction-and-teaching-loop.md` (unknown; release proof)

### 60. Same source file targeted by multiple active items: scripts/codex-forbidden-claim-scan.sh

- Candidate ID: `AMB28-same_source_file_targeted_by_multiple_active_batches-88217938`
- Evidence type: `same_source_file_targeted_by_multiple_active_batches`
- Severity: `yellow`
- Recommended action: `Merge`
- Linear-ready: `True`
- Auto-resolved: `False`
- Reason: Multiple active work items target the same source file; merge or sequence ownership before implementation.
- Involved active paths:
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
  - ... 87 more

### 61. Same source file targeted by multiple active items: scripts/fet-bottom-chrome-conflict-scan.sh

- Candidate ID: `AMB28-same_source_file_targeted_by_multiple_active_batches-92257346`
- Evidence type: `same_source_file_targeted_by_multiple_active_batches`
- Severity: `yellow`
- Recommended action: `Merge`
- Linear-ready: `True`
- Auto-resolved: `False`
- Reason: Multiple active work items target the same source file; merge or sequence ownership before implementation.
- Involved active paths:
  - `GLOBAL_BATCH_AUTOMATED_GATE_PROTOCOL` — `docs/codex/GLOBAL_BATCH_AUTOMATED_GATE_PROTOCOL.md` (partial_implementation; release proof)
  - `FET01_FET12_FAANG_FRONTEND_EXCELLENCE_TRAIN` — `docs/codex/batch-trains/FET01_FET12_FAANG_FRONTEND_EXCELLENCE_TRAIN.md` (partial_implementation; release proof)
  - `FET00_FAANG_FRONTEND_CODEX_OS_UPGRADE_PROMPT` — `docs/codex/batches/FET00_FAANG_FRONTEND_CODEX_OS_UPGRADE_PROMPT.md` (partial_implementation; release proof)

### 62. Same source file targeted by multiple active items: scripts/sa-pack-schema-validate.sh

- Candidate ID: `AMB28-same_source_file_targeted_by_multiple_active_batches-95711181`
- Evidence type: `same_source_file_targeted_by_multiple_active_batches`
- Severity: `yellow`
- Recommended action: `Merge`
- Linear-ready: `True`
- Auto-resolved: `False`
- Reason: Multiple active work items target the same source file; merge or sequence ownership before implementation.
- Involved active paths:
  - `SOURCE_ATLAS_CODEX_OS_UPGRADE_MAP` — `docs/codex/SOURCE_ATLAS_CODEX_OS_UPGRADE_MAP.md` (partial_implementation; release proof)
  - `SA01_SA32_SOURCE_ATLAS_FULL_MATURITY_TRAIN` — `docs/codex/batch-trains/SA01_SA32_SOURCE_ATLAS_FULL_MATURITY_TRAIN.md` (partial_implementation; release proof)

### 63. Same source file targeted by multiple active items: Native/Ambitions/Features/Plan/PlanScreen.swift

- Candidate ID: `AMB28-same_source_file_targeted_by_multiple_active_batches-97024768`
- Evidence type: `same_source_file_targeted_by_multiple_active_batches`
- Severity: `yellow`
- Recommended action: `Merge`
- Linear-ready: `True`
- Auto-resolved: `False`
- Reason: Multiple active work items target the same source file; merge or sequence ownership before implementation.
- Involved active paths:
  - `PK21` — `prompts/batches/PK21.md` (partial_implementation; release proof)
  - `AMB-REPO-AUTHORITY-06-ACTIVE-DRIFT-REPAIR` — `prompts/batches/AMB-REPO-AUTHORITY-06-ACTIVE-DRIFT-REPAIR.md` (partial_implementation; release proof)
  - `ALIGN-01-NAMING` — `prompts/batches/ALIGN-01-NAMING.md` (partial_implementation; release proof)

### 64. Same source file targeted by multiple active items: scripts/ios26-flagship-run-sequential.sh

- Candidate ID: `AMB28-same_source_file_targeted_by_multiple_active_batches-97917798`
- Evidence type: `same_source_file_targeted_by_multiple_active_batches`
- Severity: `yellow`
- Recommended action: `Merge`
- Linear-ready: `True`
- Auto-resolved: `False`
- Reason: Multiple active work items target the same source file; merge or sequence ownership before implementation.
- Involved active paths:
  - `IOS26-FLAGSHIP` — `docs/codex/IOS26_FLAGSHIP_TRAIN_MANIFEST.yml` (partial_implementation; release proof)
  - `AMB-INTELLIGENCE-CONSOLIDATION-CHAMPION-SELECTION-01` — `prompts/batches/AMB-INTELLIGENCE-CONSOLIDATION-CHAMPION-SELECTION-01.md` (partial_implementation; release proof)

### 65. Same source file targeted by multiple active items: Native/Ambitions/Features/Today/DayRailProjection.swift

- Candidate ID: `AMB28-same_source_file_targeted_by_multiple_active_batches-98081479`
- Evidence type: `same_source_file_targeted_by_multiple_active_batches`
- Severity: `yellow`
- Recommended action: `Merge`
- Linear-ready: `True`
- Auto-resolved: `False`
- Reason: Multiple active work items target the same source file; merge or sequence ownership before implementation.
- Involved active paths:
  - `FCP05_Start_Here_Surface_Prompt` — `docs/codex/batches/FCP05_Start_Here_Surface_Prompt.md` (unknown; release proof)
  - `FCP07_Reality_Rail_Continuity_Prompt` — `docs/codex/batches/FCP07_Reality_Rail_Continuity_Prompt.md` (unknown; release proof)

### 66. Same source file targeted by multiple active items: Native/Ambitions/Runtime/GoalRealityRuntimeService.swift

- Candidate ID: `AMB28-same_source_file_targeted_by_multiple_active_batches-991068`
- Evidence type: `same_source_file_targeted_by_multiple_active_batches`
- Severity: `yellow`
- Recommended action: `Merge`
- Linear-ready: `True`
- Auto-resolved: `False`
- Reason: Multiple active work items target the same source file; merge or sequence ownership before implementation.
- Involved active paths:
  - `GOAL_REALITY_COMPILER_BACKEND_MASTER_PLAN` — `docs/codex/GOAL_REALITY_COMPILER_BACKEND_MASTER_PLAN.md` (partial_implementation; release proof)
  - `MOAT-GOAL-REALITY-RUNTIME-SERVICE-03` — `prompts/batches/MOAT-GOAL-REALITY-RUNTIME-SERVICE-03.md` (partial_implementation; release proof)
  - `MOAT-GOAL-REALITY-TODAY-BRIDGE-06` — `prompts/batches/MOAT-GOAL-REALITY-TODAY-BRIDGE-06.md` (partial_implementation; release proof)

### 67. Same surface touched by multiple active items: Pulse

- Candidate ID: `AMB28-same_surface_multiple_active_batches-32360271`
- Evidence type: `same_surface_multiple_active_batches`
- Severity: `yellow`
- Recommended action: `Merge`
- Linear-ready: `True`
- Auto-resolved: `False`
- Reason: Multiple active work items target the same surface; expedite owner/sequence decision before more work.
- Involved active paths:
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
  - ... 2 more

### 68. Same surface touched by multiple active items: Time

- Candidate ID: `AMB28-same_surface_multiple_active_batches-31837432`
- Evidence type: `same_surface_multiple_active_batches`
- Severity: `yellow`
- Recommended action: `Expedite`
- Linear-ready: `True`
- Auto-resolved: `False`
- Reason: Multiple active work items target the same surface; expedite owner/sequence decision before more work.
- Involved active paths:
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
  - ... 337 more

### 69. Same surface touched by multiple active items: Capture

- Candidate ID: `AMB28-same_surface_multiple_active_batches-34119984`
- Evidence type: `same_surface_multiple_active_batches`
- Severity: `yellow`
- Recommended action: `Expedite`
- Linear-ready: `True`
- Auto-resolved: `False`
- Reason: Multiple active work items target the same surface; expedite owner/sequence decision before more work.
- Involved active paths:
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
  - ... 390 more

### 70. Same surface touched by multiple active items: You

- Candidate ID: `AMB28-same_surface_multiple_active_batches-7805667`
- Evidence type: `same_surface_multiple_active_batches`
- Severity: `yellow`
- Recommended action: `Expedite`
- Linear-ready: `True`
- Auto-resolved: `False`
- Reason: Multiple active work items target the same surface; expedite owner/sequence decision before more work.
- Involved active paths:
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
  - ... 366 more

### 71. Same surface touched by multiple active items: Goals

- Candidate ID: `AMB28-same_surface_multiple_active_batches-95036910`
- Evidence type: `same_surface_multiple_active_batches`
- Severity: `yellow`
- Recommended action: `Expedite`
- Linear-ready: `True`
- Auto-resolved: `False`
- Reason: Multiple active work items target the same surface; expedite owner/sequence decision before more work.
- Involved active paths:
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
  - ... 376 more

### 72. Same surface touched by multiple active items: Today

- Candidate ID: `AMB28-same_surface_multiple_active_batches-99117770`
- Evidence type: `same_surface_multiple_active_batches`
- Severity: `yellow`
- Recommended action: `Expedite`
- Linear-ready: `True`
- Auto-resolved: `False`
- Reason: Multiple active work items target the same surface; expedite owner/sequence decision before more work.
- Involved active paths:
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
  - ... 353 more


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
