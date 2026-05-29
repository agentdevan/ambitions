# Active Canon Collapse Candidates

Status: GREEN
Generated UTC: 2026-05-29T01:57:38Z
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

- Active candidates: `742`
- Historical-only residue: `0`
- Red active candidates: `0`
- Auto-resolved candidates: `0`

### Active candidates by action

- `Expedite`: `228`
- `Finish proof`: `19`
- `Merge`: `302`
- `Rewrite`: `193`

### Active candidates by conflict type

- `duplicate_stable_id`: `32`
- `missing_source_of_truth_reference`: `17`
- `retired_ia_or_terminology_reference`: `176`
- `same_source_file_targeted_by_multiple_active_batches`: `270`
- `same_surface_multiple_active_batches`: `6`
- `source_only_implementation_missing_proof`: `20`
- `stale_or_unknown_active_status`: `221`

## Next bounded action bundle

- Bundle ID: `canon-collapse-finish-proof-bundle`
- Title: Finish proof for active source-only / missing-proof items
- Recommended action: `Finish proof`
- Candidate count: `19`
- Reason: Source-only or missing-proof work cannot be treated as complete.

### Bundle candidate IDs

- `AMB28-source_only_implementation_missing_proof-14472031`
- `AMB28-source_only_implementation_missing_proof-26699805`
- `AMB28-source_only_implementation_missing_proof-34483658`
- `AMB28-source_only_implementation_missing_proof-34617096`
- `AMB28-source_only_implementation_missing_proof-35997276`
- `AMB28-source_only_implementation_missing_proof-39398065`
- `AMB28-source_only_implementation_missing_proof-46273463`
- `AMB28-source_only_implementation_missing_proof-47385195`
- `AMB28-source_only_implementation_missing_proof-49946222`
- `AMB28-source_only_implementation_missing_proof-61062316`
- `AMB28-source_only_implementation_missing_proof-66118124`
- `AMB28-source_only_implementation_missing_proof-68936962`
- `AMB28-source_only_implementation_missing_proof-81099119`
- `AMB28-source_only_implementation_missing_proof-85494842`
- `AMB28-source_only_implementation_missing_proof-87401422`
- `AMB28-source_only_implementation_missing_proof-88957111`
- `AMB28-source_only_implementation_missing_proof-90717781`
- `AMB28-source_only_implementation_missing_proof-91217190`
- `AMB28-source_only_implementation_missing_proof-98019040`

### Bundle repo paths

- `docs/codex/CHAMPION_MERGE_TRAIN_MANIFEST.yml`
- `docs/codex/IOS26_FLAGSHIP_EXECUTION_STATE.yml`
- `docs/codex/fixtures/ldi/ldi06-pack-registry-fixture.json`
- `docs/codex/ios26/IOS26_DEPENDENCY_GRAPH.yml`
- `docs/codex/parallel-guard-concept-registry.yml`
- `prompts/trains/ios26-flagship/TRAIN_01_IOS26_MINIMUM_MIGRATION_FOUNDATION.md`
- `prompts/trains/ios26-flagship/TRAIN_03_PRIVATE_LIFE_RUNTIME_PROOF_HARNESS.md`
- `prompts/trains/ios26-flagship/TRAIN_04_GOAL_INTENT_TO_DAY_COMPILER.md`
- `prompts/trains/ios26-flagship/TRAIN_05_TODAY_REALITY_MERIDIAN_FINAL_OBJECT.md`
- `prompts/trains/ios26-flagship/TRAIN_06_TIME_LIFESHAPE_FIELD_FINAL_OBJECT.md`
- `prompts/trains/ios26-flagship/TRAIN_07_GOALS_CONSTELLATION_ATLAS_FINAL_OBJECT.md`
- `prompts/trains/ios26-flagship/TRAIN_08_CAPTURE_ATMOSPHERE_COMPOSER_FINAL_OBJECT.md`
- `prompts/trains/ios26-flagship/TRAIN_09_YOU_USER_SYSTEM_PROFILE.md`
- `prompts/trains/ios26-flagship/TRAIN_10_PROOF_RECEIPTS_CLOSURE_RECOVERY_REPLAY.md`
- `prompts/trains/ios26-flagship/TRAIN_11_PERSISTENCE_MIGRATION_EXPORT_DELETE_APP_GROUP.md`
- `prompts/trains/ios26-flagship/TRAIN_12_EXTERNAL_SURFACES_WIDGETS_INTENTS_SHARE.md`
- `prompts/trains/ios26-flagship/TRAIN_13_ACCESSIBILITY_EQUIVALENCE.md`
- `prompts/trains/ios26-flagship/TRAIN_14_PERFORMANCE_INSTRUMENTS_POWER.md`
- `prompts/trains/ios26-flagship/TRAIN_15_REPO_HYGIENE_NAMING_DRIFT_HISTORICAL_QUARANTINE.md`

## Active candidates

### 1. Retired IA/terminology reference in AOS01_AmbitionsOS_Canon_And_Runtime_Contract_Prompt

- Candidate ID: `AMB28-retired_ia_or_terminology_reference-1018455`
- Evidence type: `retired_ia_or_terminology_reference`
- Severity: `yellow`
- Recommended action: `Rewrite`
- Linear-ready: `True`
- Auto-resolved: `False`
- Reason: Active item contains retired IA, retired terminology, or unsafe language; rewrite or retire before reuse.
- Involved active paths:
  - `AOS01_AmbitionsOS_Canon_And_Runtime_Contract_Prompt` — `docs/codex/batches/AOS01_AmbitionsOS_Canon_And_Runtime_Contract_Prompt.md` (partial_implementation; release proof)

### 2. Retired IA/terminology reference in PX17_Release_Truth_Product_Messaging_Prompt

- Candidate ID: `AMB28-retired_ia_or_terminology_reference-10397847`
- Evidence type: `retired_ia_or_terminology_reference`
- Severity: `yellow`
- Recommended action: `Rewrite`
- Linear-ready: `True`
- Auto-resolved: `False`
- Reason: Active item contains retired IA, retired terminology, or unsafe language; rewrite or retire before reuse.
- Involved active paths:
  - `PX17_Release_Truth_Product_Messaging_Prompt` — `docs/codex/batches/PX17_Release_Truth_Product_Messaging_Prompt.md` (partial_implementation; release proof)

### 3. Retired IA/terminology reference in AOS28_AmbitionsOS_Handoff_Prompt

- Candidate ID: `AMB28-retired_ia_or_terminology_reference-10857956`
- Evidence type: `retired_ia_or_terminology_reference`
- Severity: `yellow`
- Recommended action: `Rewrite`
- Linear-ready: `True`
- Auto-resolved: `False`
- Reason: Active item contains retired IA, retired terminology, or unsafe language; rewrite or retire before reuse.
- Involved active paths:
  - `AOS28_AmbitionsOS_Handoff_Prompt` — `docs/codex/batches/AOS28_AmbitionsOS_Handoff_Prompt.md` (partial_implementation; release proof)

### 4. Retired IA/terminology reference in FVQ_VISUAL_EXCELLENCE_TRAIN

- Candidate ID: `AMB28-retired_ia_or_terminology_reference-12654711`
- Evidence type: `retired_ia_or_terminology_reference`
- Severity: `yellow`
- Recommended action: `Rewrite`
- Linear-ready: `True`
- Auto-resolved: `False`
- Reason: Active item contains retired IA, retired terminology, or unsafe language; rewrite or retire before reuse.
- Involved active paths:
  - `FVQ_VISUAL_EXCELLENCE_TRAIN` — `docs/codex/visual-quality/FVQ_VISUAL_EXCELLENCE_TRAIN.md` (partial_implementation; release proof)

### 5. Retired IA/terminology reference in HISTORICAL_BASELINE_GLOBAL_TRAIN_MANIFEST

- Candidate ID: `AMB28-retired_ia_or_terminology_reference-13026724`
- Evidence type: `retired_ia_or_terminology_reference`
- Severity: `yellow`
- Recommended action: `Rewrite`
- Linear-ready: `True`
- Auto-resolved: `False`
- Reason: Active item contains retired IA, retired terminology, or unsafe language; rewrite or retire before reuse.
- Involved active paths:
  - `HISTORICAL_BASELINE_GLOBAL_TRAIN_MANIFEST` — `docs/codex/HISTORICAL_BASELINE_GLOBAL_TRAIN_MANIFEST.json` (unknown; release proof)

### 6. Retired IA/terminology reference in AOS03_Graph_Delta_Review_Projection_Store_Prompt

- Candidate ID: `AMB28-retired_ia_or_terminology_reference-13047099`
- Evidence type: `retired_ia_or_terminology_reference`
- Severity: `yellow`
- Recommended action: `Rewrite`
- Linear-ready: `True`
- Auto-resolved: `False`
- Reason: Active item contains retired IA, retired terminology, or unsafe language; rewrite or retire before reuse.
- Involved active paths:
  - `AOS03_Graph_Delta_Review_Projection_Store_Prompt` — `docs/codex/batches/AOS03_Graph_Delta_Review_Projection_Store_Prompt.md` (partial_implementation; release proof)

### 7. Retired IA/terminology reference in AOS22_Longevity_Kernel_Archive_Aging_Prompt

- Candidate ID: `AMB28-retired_ia_or_terminology_reference-13636896`
- Evidence type: `retired_ia_or_terminology_reference`
- Severity: `yellow`
- Recommended action: `Rewrite`
- Linear-ready: `True`
- Auto-resolved: `False`
- Reason: Active item contains retired IA, retired terminology, or unsafe language; rewrite or retire before reuse.
- Involved active paths:
  - `AOS22_Longevity_Kernel_Archive_Aging_Prompt` — `docs/codex/batches/AOS22_Longevity_Kernel_Archive_Aging_Prompt.md` (partial_implementation; release proof)

### 8. Retired IA/terminology reference in PD16_Schedule_Availability_And_Planning_Defaults_Depth_Prompt

- Candidate ID: `AMB28-retired_ia_or_terminology_reference-14076439`
- Evidence type: `retired_ia_or_terminology_reference`
- Severity: `yellow`
- Recommended action: `Rewrite`
- Linear-ready: `True`
- Auto-resolved: `False`
- Reason: Active item contains retired IA, retired terminology, or unsafe language; rewrite or retire before reuse.
- Involved active paths:
  - `PD16_Schedule_Availability_And_Planning_Defaults_Depth_Prompt` — `docs/codex/batches/PD16_Schedule_Availability_And_Planning_Defaults_Depth_Prompt.md` (partial_implementation; release proof)

### 9. Retired IA/terminology reference in AOS15_Local_Language_Kernel_Planning_Prompt

- Candidate ID: `AMB28-retired_ia_or_terminology_reference-14467225`
- Evidence type: `retired_ia_or_terminology_reference`
- Severity: `yellow`
- Recommended action: `Rewrite`
- Linear-ready: `True`
- Auto-resolved: `False`
- Reason: Active item contains retired IA, retired terminology, or unsafe language; rewrite or retire before reuse.
- Involved active paths:
  - `AOS15_Local_Language_Kernel_Planning_Prompt` — `docs/codex/batches/AOS15_Local_Language_Kernel_Planning_Prompt.md` (partial_implementation; release proof)

### 10. Retired IA/terminology reference in AMB-FE-BE-MOAT-SCENARIO-PROOF-98

- Candidate ID: `AMB28-retired_ia_or_terminology_reference-14771014`
- Evidence type: `retired_ia_or_terminology_reference`
- Severity: `yellow`
- Recommended action: `Rewrite`
- Linear-ready: `True`
- Auto-resolved: `False`
- Reason: Active item contains retired IA, retired terminology, or unsafe language; rewrite or retire before reuse.
- Involved active paths:
  - `AMB-FE-BE-MOAT-SCENARIO-PROOF-98` — `prompts/batches/amb-fe-be/AMB-FE-BE-MOAT-SCENARIO-PROOF-98.md` (partial_implementation; release proof)

### 11. Retired IA/terminology reference in AOS21_Interoperability_Kernel_App_Intents_EventKit_Planning_Prompt

- Candidate ID: `AMB28-retired_ia_or_terminology_reference-15462745`
- Evidence type: `retired_ia_or_terminology_reference`
- Severity: `yellow`
- Recommended action: `Rewrite`
- Linear-ready: `True`
- Auto-resolved: `False`
- Reason: Active item contains retired IA, retired terminology, or unsafe language; rewrite or retire before reuse.
- Involved active paths:
  - `AOS21_Interoperability_Kernel_App_Intents_EventKit_Planning_Prompt` — `docs/codex/batches/AOS21_Interoperability_Kernel_App_Intents_EventKit_Planning_Prompt.md` (partial_implementation; release proof)

### 12. Retired IA/terminology reference in DAV_DYNAMIC_VISUAL_SOURCE_TRUTH_AND_SURFACE_MAP

- Candidate ID: `AMB28-retired_ia_or_terminology_reference-15909831`
- Evidence type: `retired_ia_or_terminology_reference`
- Severity: `yellow`
- Recommended action: `Rewrite`
- Linear-ready: `True`
- Auto-resolved: `False`
- Reason: Active item contains retired IA, retired terminology, or unsafe language; rewrite or retire before reuse.
- Involved active paths:
  - `DAV_DYNAMIC_VISUAL_SOURCE_TRUTH_AND_SURFACE_MAP` — `docs/codex/DAV_DYNAMIC_VISUAL_SOURCE_TRUTH_AND_SURFACE_MAP.md` (partial_implementation; release proof)

### 13. Retired IA/terminology reference in FVQ03_DRILLDOWN_AND_EXTERNAL_SURFACE_VISUAL_SWEEP

- Candidate ID: `AMB28-retired_ia_or_terminology_reference-16768161`
- Evidence type: `retired_ia_or_terminology_reference`
- Severity: `yellow`
- Recommended action: `Rewrite`
- Linear-ready: `True`
- Auto-resolved: `False`
- Reason: Active item contains retired IA, retired terminology, or unsafe language; rewrite or retire before reuse.
- Involved active paths:
  - `FVQ03_DRILLDOWN_AND_EXTERNAL_SURFACE_VISUAL_SWEEP` — `docs/codex/visual-quality/FVQ03_DRILLDOWN_AND_EXTERNAL_SURFACE_VISUAL_SWEEP.md` (partial_implementation; release proof)

### 14. Retired IA/terminology reference in HPS_NEXT_ELIGIBLE_BATCH_PROMPT

- Candidate ID: `AMB28-retired_ia_or_terminology_reference-17676454`
- Evidence type: `retired_ia_or_terminology_reference`
- Severity: `yellow`
- Recommended action: `Rewrite`
- Linear-ready: `True`
- Auto-resolved: `False`
- Reason: Active item contains retired IA, retired terminology, or unsafe language; rewrite or retire before reuse.
- Involved active paths:
  - `HPS_NEXT_ELIGIBLE_BATCH_PROMPT` — `docs/codex/batches/HPS_NEXT_ELIGIBLE_BATCH_PROMPT.md` (partial_implementation; release proof)

### 15. Retired IA/terminology reference in IOS26_OBJECT_FRONTEND_BATCH_INSERTION_PLAN

- Candidate ID: `AMB28-retired_ia_or_terminology_reference-19450826`
- Evidence type: `retired_ia_or_terminology_reference`
- Severity: `yellow`
- Recommended action: `Rewrite`
- Linear-ready: `True`
- Auto-resolved: `False`
- Reason: Active item contains retired IA, retired terminology, or unsafe language; rewrite or retire before reuse.
- Involved active paths:
  - `IOS26_OBJECT_FRONTEND_BATCH_INSERTION_PLAN` — `docs/codex/frontend/IOS26_OBJECT_FRONTEND_BATCH_INSERTION_PLAN.md` (partial_implementation; release proof)

### 16. Retired IA/terminology reference in PX13_Empty_Edge_Degraded_States_Prompt

- Candidate ID: `AMB28-retired_ia_or_terminology_reference-19822772`
- Evidence type: `retired_ia_or_terminology_reference`
- Severity: `yellow`
- Recommended action: `Rewrite`
- Linear-ready: `True`
- Auto-resolved: `False`
- Reason: Active item contains retired IA, retired terminology, or unsafe language; rewrite or retire before reuse.
- Involved active paths:
  - `PX13_Empty_Edge_Degraded_States_Prompt` — `docs/codex/batches/PX13_Empty_Edge_Degraded_States_Prompt.md` (partial_implementation; release proof)

### 17. Retired IA/terminology reference in PX01_Product_Experience_OS_Canon_And_Surface_Hierarchy_Prompt

- Candidate ID: `AMB28-retired_ia_or_terminology_reference-2043138`
- Evidence type: `retired_ia_or_terminology_reference`
- Severity: `yellow`
- Recommended action: `Rewrite`
- Linear-ready: `True`
- Auto-resolved: `False`
- Reason: Active item contains retired IA, retired terminology, or unsafe language; rewrite or retire before reuse.
- Involved active paths:
  - `PX01_Product_Experience_OS_Canon_And_Surface_Hierarchy_Prompt` — `docs/codex/batches/PX01_Product_Experience_OS_Canon_And_Surface_Hierarchy_Prompt.md` (partial_implementation; release proof)

### 18. Retired IA/terminology reference in PX06_You_Personal_System_Center_Prompt

- Candidate ID: `AMB28-retired_ia_or_terminology_reference-2057558`
- Evidence type: `retired_ia_or_terminology_reference`
- Severity: `yellow`
- Recommended action: `Rewrite`
- Linear-ready: `True`
- Auto-resolved: `False`
- Reason: Active item contains retired IA, retired terminology, or unsafe language; rewrite or retire before reuse.
- Involved active paths:
  - `PX06_You_Personal_System_Center_Prompt` — `docs/codex/batches/PX06_You_Personal_System_Center_Prompt.md` (partial_implementation; release proof)

### 19. Retired IA/terminology reference in AQOS_REPAIR_BATCH_GENERATOR_PROTOCOL

- Candidate ID: `AMB28-retired_ia_or_terminology_reference-20683341`
- Evidence type: `retired_ia_or_terminology_reference`
- Severity: `yellow`
- Recommended action: `Rewrite`
- Linear-ready: `True`
- Auto-resolved: `False`
- Reason: Active item contains retired IA, retired terminology, or unsafe language; rewrite or retire before reuse.
- Involved active paths:
  - `AQOS_REPAIR_BATCH_GENERATOR_PROTOCOL` — `docs/codex/quality/AQOS_REPAIR_BATCH_GENERATOR_PROTOCOL.md` (partial_implementation; release proof)

### 20. Retired IA/terminology reference in AFI15_Founder_Acceptance_Review

- Candidate ID: `AMB28-retired_ia_or_terminology_reference-21202158`
- Evidence type: `retired_ia_or_terminology_reference`
- Severity: `yellow`
- Recommended action: `Rewrite`
- Linear-ready: `True`
- Auto-resolved: `False`
- Reason: Active item contains retired IA, retired terminology, or unsafe language; rewrite or retire before reuse.
- Involved active paths:
  - `AFI15_Founder_Acceptance_Review` — `docs/codex/batches/AFI15_Founder_Acceptance_Review.md` (partial_implementation; release proof)

### 21. Retired IA/terminology reference in PX19_PXOS_Handoff_Prompt

- Candidate ID: `AMB28-retired_ia_or_terminology_reference-21225453`
- Evidence type: `retired_ia_or_terminology_reference`
- Severity: `yellow`
- Recommended action: `Rewrite`
- Linear-ready: `True`
- Auto-resolved: `False`
- Reason: Active item contains retired IA, retired terminology, or unsafe language; rewrite or retire before reuse.
- Involved active paths:
  - `PX19_PXOS_Handoff_Prompt` — `docs/codex/batches/PX19_PXOS_Handoff_Prompt.md` (partial_implementation; release proof)

### 22. Retired IA/terminology reference in AMB-REPO-GREEN-FLAGSHIP-RESET-MASTER-01-T09-GOALS-EXTRACTION

- Candidate ID: `AMB28-retired_ia_or_terminology_reference-21554091`
- Evidence type: `retired_ia_or_terminology_reference`
- Severity: `yellow`
- Recommended action: `Rewrite`
- Linear-ready: `True`
- Auto-resolved: `False`
- Reason: Active item contains retired IA, retired terminology, or unsafe language; rewrite or retire before reuse.
- Involved active paths:
  - `AMB-REPO-GREEN-FLAGSHIP-RESET-MASTER-01-T09-GOALS-EXTRACTION` — `prompts/batches/AMB-REPO-GREEN-FLAGSHIP-RESET-MASTER-01-T09-GOALS-EXTRACTION.md` (partial_implementation; release proof)

### 23. Retired IA/terminology reference in FAANG_FRONTEND_IMPLEMENTATION_TEAM_OPERATING_SYSTEM

- Candidate ID: `AMB28-retired_ia_or_terminology_reference-21672468`
- Evidence type: `retired_ia_or_terminology_reference`
- Severity: `yellow`
- Recommended action: `Rewrite`
- Linear-ready: `True`
- Auto-resolved: `False`
- Reason: Active item contains retired IA, retired terminology, or unsafe language; rewrite or retire before reuse.
- Involved active paths:
  - `FAANG_FRONTEND_IMPLEMENTATION_TEAM_OPERATING_SYSTEM` — `docs/codex/frontend-implementation/FAANG_FRONTEND_IMPLEMENTATION_TEAM_OPERATING_SYSTEM.md` (partial_implementation; release proof)

### 24. Retired IA/terminology reference in AMB_GLOBAL_REMAINING_TRAIN_BLUEPRINT

- Candidate ID: `AMB28-retired_ia_or_terminology_reference-21796894`
- Evidence type: `retired_ia_or_terminology_reference`
- Severity: `yellow`
- Recommended action: `Rewrite`
- Linear-ready: `True`
- Auto-resolved: `False`
- Reason: Active item contains retired IA, retired terminology, or unsafe language; rewrite or retire before reuse.
- Involved active paths:
  - `AMB_GLOBAL_REMAINING_TRAIN_BLUEPRINT` — `docs/codex/AMB_GLOBAL_REMAINING_TRAIN_BLUEPRINT.json` (unknown; tests)

### 25. Retired IA/terminology reference in PX03_Goals_Mission_Control_Experience_Prompt

- Candidate ID: `AMB28-retired_ia_or_terminology_reference-22281450`
- Evidence type: `retired_ia_or_terminology_reference`
- Severity: `yellow`
- Recommended action: `Rewrite`
- Linear-ready: `True`
- Auto-resolved: `False`
- Reason: Active item contains retired IA, retired terminology, or unsafe language; rewrite or retire before reuse.
- Involved active paths:
  - `PX03_Goals_Mission_Control_Experience_Prompt` — `docs/codex/batches/PX03_Goals_Mission_Control_Experience_Prompt.md` (partial_implementation; release proof)

### 26. Retired IA/terminology reference in AOS18_Evaluation_Golden_Scenarios_Prompt

- Candidate ID: `AMB28-retired_ia_or_terminology_reference-22506337`
- Evidence type: `retired_ia_or_terminology_reference`
- Severity: `yellow`
- Recommended action: `Rewrite`
- Linear-ready: `True`
- Auto-resolved: `False`
- Reason: Active item contains retired IA, retired terminology, or unsafe language; rewrite or retire before reuse.
- Involved active paths:
  - `AOS18_Evaluation_Golden_Scenarios_Prompt` — `docs/codex/batches/AOS18_Evaluation_Golden_Scenarios_Prompt.md` (partial_implementation; release proof)

### 27. Retired IA/terminology reference in START-HERE-REALITY-RECOGNITION-01

- Candidate ID: `AMB28-retired_ia_or_terminology_reference-22720196`
- Evidence type: `retired_ia_or_terminology_reference`
- Severity: `yellow`
- Recommended action: `Rewrite`
- Linear-ready: `True`
- Auto-resolved: `False`
- Reason: Active item contains retired IA, retired terminology, or unsafe language; rewrite or retire before reuse.
- Involved active paths:
  - `START-HERE-REALITY-RECOGNITION-01` — `prompts/batches/START-HERE-REALITY-RECOGNITION-01.md` (partial_implementation; release proof)

### 28. Retired IA/terminology reference in SI01_SI18_SIGNATURE_INTERFACE_IMPLEMENTATION_TRAIN

- Candidate ID: `AMB28-retired_ia_or_terminology_reference-23200176`
- Evidence type: `retired_ia_or_terminology_reference`
- Severity: `yellow`
- Recommended action: `Rewrite`
- Linear-ready: `True`
- Auto-resolved: `False`
- Reason: Active item contains retired IA, retired terminology, or unsafe language; rewrite or retire before reuse.
- Involved active paths:
  - `SI01_SI18_SIGNATURE_INTERFACE_IMPLEMENTATION_TRAIN` — `docs/codex/batch-trains/SI01_SI18_SIGNATURE_INTERFACE_IMPLEMENTATION_TRAIN.md` (partial_implementation; release proof)

### 29. Retired IA/terminology reference in BATCH-16-canon-batch-13-shared-life-household-intelligence

- Candidate ID: `AMB28-retired_ia_or_terminology_reference-23331329`
- Evidence type: `retired_ia_or_terminology_reference`
- Severity: `yellow`
- Recommended action: `Rewrite`
- Linear-ready: `True`
- Auto-resolved: `False`
- Reason: Active item contains retired IA, retired terminology, or unsafe language; rewrite or retire before reuse.
- Involved active paths:
  - `BATCH-16-canon-batch-13-shared-life-household-intelligence` — `docs/codex/batches/BATCH-16-canon-batch-13-shared-life-household-intelligence.md` (unknown; release proof)

### 30. Retired IA/terminology reference in PX08_Trust_Proof_Receipts_Experience_Prompt

- Candidate ID: `AMB28-retired_ia_or_terminology_reference-23812799`
- Evidence type: `retired_ia_or_terminology_reference`
- Severity: `yellow`
- Recommended action: `Rewrite`
- Linear-ready: `True`
- Auto-resolved: `False`
- Reason: Active item contains retired IA, retired terminology, or unsafe language; rewrite or retire before reuse.
- Involved active paths:
  - `PX08_Trust_Proof_Receipts_Experience_Prompt` — `docs/codex/batches/PX08_Trust_Proof_Receipts_Experience_Prompt.md` (partial_implementation; release proof)

### 31. Retired IA/terminology reference in AOS11_Reality_Drift_Bounded_Reflow_Prompt

- Candidate ID: `AMB28-retired_ia_or_terminology_reference-23898376`
- Evidence type: `retired_ia_or_terminology_reference`
- Severity: `yellow`
- Recommended action: `Rewrite`
- Linear-ready: `True`
- Auto-resolved: `False`
- Reason: Active item contains retired IA, retired terminology, or unsafe language; rewrite or retire before reuse.
- Involved active paths:
  - `AOS11_Reality_Drift_Bounded_Reflow_Prompt` — `docs/codex/batches/AOS11_Reality_Drift_Bounded_Reflow_Prompt.md` (partial_implementation; release proof)

### 32. Retired IA/terminology reference in PX14_Product_Depth_Drilldown_Architecture_Prompt

- Candidate ID: `AMB28-retired_ia_or_terminology_reference-24005872`
- Evidence type: `retired_ia_or_terminology_reference`
- Severity: `yellow`
- Recommended action: `Rewrite`
- Linear-ready: `True`
- Auto-resolved: `False`
- Reason: Active item contains retired IA, retired terminology, or unsafe language; rewrite or retire before reuse.
- Involved active paths:
  - `PX14_Product_Depth_Drilldown_Architecture_Prompt` — `docs/codex/batches/PX14_Product_Depth_Drilldown_Architecture_Prompt.md` (partial_implementation; release proof)

### 33. Retired IA/terminology reference in PD10_Capture_Correction_And_Confidence_Loops_Prompt

- Candidate ID: `AMB28-retired_ia_or_terminology_reference-24641936`
- Evidence type: `retired_ia_or_terminology_reference`
- Severity: `yellow`
- Recommended action: `Rewrite`
- Linear-ready: `True`
- Auto-resolved: `False`
- Reason: Active item contains retired IA, retired terminology, or unsafe language; rewrite or retire before reuse.
- Involved active paths:
  - `PD10_Capture_Correction_And_Confidence_Loops_Prompt` — `docs/codex/batches/PD10_Capture_Correction_And_Confidence_Loops_Prompt.md` (partial_implementation; release proof)

### 34. Retired IA/terminology reference in AOS14_Recommendation_Start_Here_Kernel_Prompt

- Candidate ID: `AMB28-retired_ia_or_terminology_reference-24734364`
- Evidence type: `retired_ia_or_terminology_reference`
- Severity: `yellow`
- Recommended action: `Rewrite`
- Linear-ready: `True`
- Auto-resolved: `False`
- Reason: Active item contains retired IA, retired terminology, or unsafe language; rewrite or retire before reuse.
- Involved active paths:
  - `AOS14_Recommendation_Start_Here_Kernel_Prompt` — `docs/codex/batches/AOS14_Recommendation_Start_Here_Kernel_Prompt.md` (partial_implementation; release proof)

### 35. Retired IA/terminology reference in OS-FLAGSHIP-04-VISUAL-QA-GATE

- Candidate ID: `AMB28-retired_ia_or_terminology_reference-24793238`
- Evidence type: `retired_ia_or_terminology_reference`
- Severity: `yellow`
- Recommended action: `Rewrite`
- Linear-ready: `True`
- Auto-resolved: `False`
- Reason: Active item contains retired IA, retired terminology, or unsafe language; rewrite or retire before reuse.
- Involved active paths:
  - `OS-FLAGSHIP-04-VISUAL-QA-GATE` — `prompts/batches/OS-FLAGSHIP-04-VISUAL-QA-GATE.md` (partial_implementation; release proof)

### 36. Retired IA/terminology reference in AFI06_Today_Reality_Meridian

- Candidate ID: `AMB28-retired_ia_or_terminology_reference-25030685`
- Evidence type: `retired_ia_or_terminology_reference`
- Severity: `yellow`
- Recommended action: `Rewrite`
- Linear-ready: `True`
- Auto-resolved: `False`
- Reason: Active item contains retired IA, retired terminology, or unsafe language; rewrite or retire before reuse.
- Involved active paths:
  - `AFI06_Today_Reality_Meridian` — `docs/codex/batches/AFI06_Today_Reality_Meridian.md` (partial_implementation; release proof)

### 37. Retired IA/terminology reference in PX11_Onboarding_Setup_Experience_Prompt

- Candidate ID: `AMB28-retired_ia_or_terminology_reference-26056543`
- Evidence type: `retired_ia_or_terminology_reference`
- Severity: `yellow`
- Recommended action: `Rewrite`
- Linear-ready: `True`
- Auto-resolved: `False`
- Reason: Active item contains retired IA, retired terminology, or unsafe language; rewrite or retire before reuse.
- Involved active paths:
  - `PX11_Onboarding_Setup_Experience_Prompt` — `docs/codex/batches/PX11_Onboarding_Setup_Experience_Prompt.md` (partial_implementation; release proof)

### 38. Retired IA/terminology reference in PD09_Capture_Placement_Review_Prompt

- Candidate ID: `AMB28-retired_ia_or_terminology_reference-26095368`
- Evidence type: `retired_ia_or_terminology_reference`
- Severity: `yellow`
- Recommended action: `Rewrite`
- Linear-ready: `True`
- Auto-resolved: `False`
- Reason: Active item contains retired IA, retired terminology, or unsafe language; rewrite or retire before reuse.
- Involved active paths:
  - `PD09_Capture_Placement_Review_Prompt` — `docs/codex/batches/PD09_Capture_Placement_Review_Prompt.md` (partial_implementation; release proof)

### 39. Retired IA/terminology reference in MOAT-GOAL-REALITY-GOALS-BRIDGE-05

- Candidate ID: `AMB28-retired_ia_or_terminology_reference-26251192`
- Evidence type: `retired_ia_or_terminology_reference`
- Severity: `yellow`
- Recommended action: `Rewrite`
- Linear-ready: `True`
- Auto-resolved: `False`
- Reason: Active item contains retired IA, retired terminology, or unsafe language; rewrite or retire before reuse.
- Involved active paths:
  - `MOAT-GOAL-REALITY-GOALS-BRIDGE-05` — `prompts/batches/MOAT-GOAL-REALITY-GOALS-BRIDGE-05.md` (partial_implementation; release proof)

### 40. Retired IA/terminology reference in parallel-guard-concept-registry

- Candidate ID: `AMB28-retired_ia_or_terminology_reference-26481941`
- Evidence type: `retired_ia_or_terminology_reference`
- Severity: `yellow`
- Recommended action: `Rewrite`
- Linear-ready: `True`
- Auto-resolved: `False`
- Reason: Active item contains retired IA, retired terminology, or unsafe language; rewrite or retire before reuse.
- Involved active paths:
  - `parallel-guard-concept-registry` — `docs/codex/parallel-guard-concept-registry.yml` (partial_implementation; source-only)

### 41. Retired IA/terminology reference in PD05_Goals_Mission_Control_Detail_Architecture_Prompt

- Candidate ID: `AMB28-retired_ia_or_terminology_reference-26535804`
- Evidence type: `retired_ia_or_terminology_reference`
- Severity: `yellow`
- Recommended action: `Rewrite`
- Linear-ready: `True`
- Auto-resolved: `False`
- Reason: Active item contains retired IA, retired terminology, or unsafe language; rewrite or retire before reuse.
- Involved active paths:
  - `PD05_Goals_Mission_Control_Detail_Architecture_Prompt` — `docs/codex/batches/PD05_Goals_Mission_Control_Detail_Architecture_Prompt.md` (partial_implementation; release proof)

### 42. Retired IA/terminology reference in AOS30_AmbitionsOS_Beyond_Roadmap_Prompt

- Candidate ID: `AMB28-retired_ia_or_terminology_reference-26831905`
- Evidence type: `retired_ia_or_terminology_reference`
- Severity: `yellow`
- Recommended action: `Rewrite`
- Linear-ready: `True`
- Auto-resolved: `False`
- Reason: Active item contains retired IA, retired terminology, or unsafe language; rewrite or retire before reuse.
- Involved active paths:
  - `AOS30_AmbitionsOS_Beyond_Roadmap_Prompt` — `docs/codex/batches/AOS30_AmbitionsOS_Beyond_Roadmap_Prompt.md` (partial_implementation; release proof)

### 43. Retired IA/terminology reference in SI05_Hero_Step_Panel_System_Prompt

- Candidate ID: `AMB28-retired_ia_or_terminology_reference-26933044`
- Evidence type: `retired_ia_or_terminology_reference`
- Severity: `yellow`
- Recommended action: `Rewrite`
- Linear-ready: `True`
- Auto-resolved: `False`
- Reason: Active item contains retired IA, retired terminology, or unsafe language; rewrite or retire before reuse.
- Involved active paths:
  - `SI05_Hero_Step_Panel_System_Prompt` — `docs/codex/batches/SI05_Hero_Step_Panel_System_Prompt.md` (partial_implementation; release proof)

### 44. Retired IA/terminology reference in SIG01_SIG16_SIGNATURE_EXPERIENCE_LAYER_TRAIN

- Candidate ID: `AMB28-retired_ia_or_terminology_reference-28722145`
- Evidence type: `retired_ia_or_terminology_reference`
- Severity: `yellow`
- Recommended action: `Rewrite`
- Linear-ready: `True`
- Auto-resolved: `False`
- Reason: Active item contains retired IA, retired terminology, or unsafe language; rewrite or retire before reuse.
- Involved active paths:
  - `SIG01_SIG16_SIGNATURE_EXPERIENCE_LAYER_TRAIN` — `docs/codex/batch-trains/SIG01_SIG16_SIGNATURE_EXPERIENCE_LAYER_TRAIN.md` (unknown; release proof)

### 45. Retired IA/terminology reference in SIG06_Goals_Signature_Experience_Implementation_Prompt

- Candidate ID: `AMB28-retired_ia_or_terminology_reference-30297366`
- Evidence type: `retired_ia_or_terminology_reference`
- Severity: `yellow`
- Recommended action: `Rewrite`
- Linear-ready: `True`
- Auto-resolved: `False`
- Reason: Active item contains retired IA, retired terminology, or unsafe language; rewrite or retire before reuse.
- Involved active paths:
  - `SIG06_Goals_Signature_Experience_Implementation_Prompt` — `docs/codex/batches/SIG06_Goals_Signature_Experience_Implementation_Prompt.md` (unknown; release proof)

### 46. Retired IA/terminology reference in FLAGSHIP_COMPLETION_FILE_BOUNDARY_MAP

- Candidate ID: `AMB28-retired_ia_or_terminology_reference-30522578`
- Evidence type: `retired_ia_or_terminology_reference`
- Severity: `yellow`
- Recommended action: `Rewrite`
- Linear-ready: `True`
- Auto-resolved: `False`
- Reason: Active item contains retired IA, retired terminology, or unsafe language; rewrite or retire before reuse.
- Involved active paths:
  - `FLAGSHIP_COMPLETION_FILE_BOUNDARY_MAP` — `docs/codex/FLAGSHIP_COMPLETION_FILE_BOUNDARY_MAP.md` (partial_implementation; release proof)

### 47. Retired IA/terminology reference in AOS09_Option_Value_North_Star_Prompt

- Candidate ID: `AMB28-retired_ia_or_terminology_reference-30575872`
- Evidence type: `retired_ia_or_terminology_reference`
- Severity: `yellow`
- Recommended action: `Rewrite`
- Linear-ready: `True`
- Auto-resolved: `False`
- Reason: Active item contains retired IA, retired terminology, or unsafe language; rewrite or retire before reuse.
- Involved active paths:
  - `AOS09_Option_Value_North_Star_Prompt` — `docs/codex/batches/AOS09_Option_Value_North_Star_Prompt.md` (partial_implementation; release proof)

### 48. Retired IA/terminology reference in VISUAL-ENCYCLOPEDIA-100-PROOF-HARDENING-03

- Candidate ID: `AMB28-retired_ia_or_terminology_reference-31051113`
- Evidence type: `retired_ia_or_terminology_reference`
- Severity: `yellow`
- Recommended action: `Rewrite`
- Linear-ready: `True`
- Auto-resolved: `False`
- Reason: Active item contains retired IA, retired terminology, or unsafe language; rewrite or retire before reuse.
- Involved active paths:
  - `VISUAL-ENCYCLOPEDIA-100-PROOF-HARDENING-03` — `prompts/batches/VISUAL-ENCYCLOPEDIA-100-PROOF-HARDENING-03.md` (partial_implementation; release proof)

### 49. Retired IA/terminology reference in PX16_User_Facing_AI_Trust_And_Recommendation_Copy_Prompt

- Candidate ID: `AMB28-retired_ia_or_terminology_reference-3161399`
- Evidence type: `retired_ia_or_terminology_reference`
- Severity: `yellow`
- Recommended action: `Rewrite`
- Linear-ready: `True`
- Auto-resolved: `False`
- Reason: Active item contains retired IA, retired terminology, or unsafe language; rewrite or retire before reuse.
- Involved active paths:
  - `PX16_User_Facing_AI_Trust_And_Recommendation_Copy_Prompt` — `docs/codex/batches/PX16_User_Facing_AI_Trust_And_Recommendation_Copy_Prompt.md` (partial_implementation; release proof)

### 50. Retired IA/terminology reference in TRAIN_04D_CAPTURE_RUNTIME_FACTORING_FUTURE_PROOF

- Candidate ID: `AMB28-retired_ia_or_terminology_reference-31876686`
- Evidence type: `retired_ia_or_terminology_reference`
- Severity: `yellow`
- Recommended action: `Rewrite`
- Linear-ready: `True`
- Auto-resolved: `False`
- Reason: Active item contains retired IA, retired terminology, or unsafe language; rewrite or retire before reuse.
- Involved active paths:
  - `TRAIN_04D_CAPTURE_RUNTIME_FACTORING_FUTURE_PROOF` — `prompts/trains/ios26-flagship/TRAIN_04D_CAPTURE_RUNTIME_FACTORING_FUTURE_PROOF.md` (partial_implementation; release proof)

### 51. Retired IA/terminology reference in FLAGSHIP_COMPLETION_OBJECT_SCORECARD

- Candidate ID: `AMB28-retired_ia_or_terminology_reference-32367166`
- Evidence type: `retired_ia_or_terminology_reference`
- Severity: `yellow`
- Recommended action: `Rewrite`
- Linear-ready: `True`
- Auto-resolved: `False`
- Reason: Active item contains retired IA, retired terminology, or unsafe language; rewrite or retire before reuse.
- Involved active paths:
  - `FLAGSHIP_COMPLETION_OBJECT_SCORECARD` — `docs/codex/FLAGSHIP_COMPLETION_OBJECT_SCORECARD.md` (partial_implementation; release proof)

### 52. Retired IA/terminology reference in SI17_Top_Level_Surface_Composition_Implementation_Prompt

- Candidate ID: `AMB28-retired_ia_or_terminology_reference-33102422`
- Evidence type: `retired_ia_or_terminology_reference`
- Severity: `yellow`
- Recommended action: `Rewrite`
- Linear-ready: `True`
- Auto-resolved: `False`
- Reason: Active item contains retired IA, retired terminology, or unsafe language; rewrite or retire before reuse.
- Involved active paths:
  - `SI17_Top_Level_Surface_Composition_Implementation_Prompt` — `docs/codex/batches/SI17_Top_Level_Surface_Composition_Implementation_Prompt.md` (partial_implementation; release proof)

### 53. Retired IA/terminology reference in PD13_Plan_Recovery_And_Pressure_Review_Prompt

- Candidate ID: `AMB28-retired_ia_or_terminology_reference-3579178`
- Evidence type: `retired_ia_or_terminology_reference`
- Severity: `yellow`
- Recommended action: `Rewrite`
- Linear-ready: `True`
- Auto-resolved: `False`
- Reason: Active item contains retired IA, retired terminology, or unsafe language; rewrite or retire before reuse.
- Involved active paths:
  - `PD13_Plan_Recovery_And_Pressure_Review_Prompt` — `docs/codex/batches/PD13_Plan_Recovery_And_Pressure_Review_Prompt.md` (partial_implementation; release proof)

### 54. Retired IA/terminology reference in GLOBAL_BATCH_EXECUTION_ORCHESTRATOR

- Candidate ID: `AMB28-retired_ia_or_terminology_reference-37136745`
- Evidence type: `retired_ia_or_terminology_reference`
- Severity: `yellow`
- Recommended action: `Rewrite`
- Linear-ready: `True`
- Auto-resolved: `False`
- Reason: Active item contains retired IA, retired terminology, or unsafe language; rewrite or retire before reuse.
- Involved active paths:
  - `GLOBAL_BATCH_EXECUTION_ORCHESTRATOR` — `docs/codex/GLOBAL_BATCH_EXECUTION_ORCHESTRATOR.md` (partial_implementation; release proof)

### 55. Retired IA/terminology reference in PX02_Today_Experience_Operating_Surface_Prompt

- Candidate ID: `AMB28-retired_ia_or_terminology_reference-37183599`
- Evidence type: `retired_ia_or_terminology_reference`
- Severity: `yellow`
- Recommended action: `Rewrite`
- Linear-ready: `True`
- Auto-resolved: `False`
- Reason: Active item contains retired IA, retired terminology, or unsafe language; rewrite or retire before reuse.
- Involved active paths:
  - `PX02_Today_Experience_Operating_Surface_Prompt` — `docs/codex/batches/PX02_Today_Experience_Operating_Surface_Prompt.md` (partial_implementation; release proof)

### 56. Retired IA/terminology reference in MOAT-ALIGNMENT-01

- Candidate ID: `AMB28-retired_ia_or_terminology_reference-38824517`
- Evidence type: `retired_ia_or_terminology_reference`
- Severity: `yellow`
- Recommended action: `Rewrite`
- Linear-ready: `True`
- Auto-resolved: `False`
- Reason: Active item contains retired IA, retired terminology, or unsafe language; rewrite or retire before reuse.
- Involved active paths:
  - `MOAT-ALIGNMENT-01` — `prompts/batches/MOAT-ALIGNMENT-01.md` (partial_implementation; release proof)

### 57. Retired IA/terminology reference in SIG_APPLE_AWARD_CALIBER_SCORECARD

- Candidate ID: `AMB28-retired_ia_or_terminology_reference-39123234`
- Evidence type: `retired_ia_or_terminology_reference`
- Severity: `yellow`
- Recommended action: `Rewrite`
- Linear-ready: `True`
- Auto-resolved: `False`
- Reason: Active item contains retired IA, retired terminology, or unsafe language; rewrite or retire before reuse.
- Involved active paths:
  - `SIG_APPLE_AWARD_CALIBER_SCORECARD` — `docs/codex/SIG_APPLE_AWARD_CALIBER_SCORECARD.md` (partial_implementation; release proof)

### 58. Retired IA/terminology reference in AMB-CHATGPT-REPO-OS-UPGRADE-INSTALL-01

- Candidate ID: `AMB28-retired_ia_or_terminology_reference-3940871`
- Evidence type: `retired_ia_or_terminology_reference`
- Severity: `yellow`
- Recommended action: `Rewrite`
- Linear-ready: `True`
- Auto-resolved: `False`
- Reason: Active item contains retired IA, retired terminology, or unsafe language; rewrite or retire before reuse.
- Involved active paths:
  - `AMB-CHATGPT-REPO-OS-UPGRADE-INSTALL-01` — `docs/codex/reports/AMB-CHATGPT-REPO-OS-UPGRADE-INSTALL-01.md` (partial_implementation; release proof)

### 59. Retired IA/terminology reference in GLOBAL_FUTURE_BATCH_GATE_MATRIX

- Candidate ID: `AMB28-retired_ia_or_terminology_reference-39648739`
- Evidence type: `retired_ia_or_terminology_reference`
- Severity: `yellow`
- Recommended action: `Rewrite`
- Linear-ready: `True`
- Auto-resolved: `False`
- Reason: Active item contains retired IA, retired terminology, or unsafe language; rewrite or retire before reuse.
- Involved active paths:
  - `GLOBAL_FUTURE_BATCH_GATE_MATRIX` — `docs/codex/GLOBAL_FUTURE_BATCH_GATE_MATRIX.md` (partial_implementation; release proof)

### 60. Retired IA/terminology reference in MOAT_RUNTIME_ACCEPTANCE_CRITERIA

- Candidate ID: `AMB28-retired_ia_or_terminology_reference-40217046`
- Evidence type: `retired_ia_or_terminology_reference`
- Severity: `yellow`
- Recommended action: `Rewrite`
- Linear-ready: `True`
- Auto-resolved: `False`
- Reason: Active item contains retired IA, retired terminology, or unsafe language; rewrite or retire before reuse.
- Involved active paths:
  - `MOAT_RUNTIME_ACCEPTANCE_CRITERIA` — `docs/codex/MOAT_RUNTIME_ACCEPTANCE_CRITERIA.md` (partial_implementation; release proof)

### 61. Retired IA/terminology reference in CODEX_VISUAL_QA_PROTOCOL

- Candidate ID: `AMB28-retired_ia_or_terminology_reference-40594677`
- Evidence type: `retired_ia_or_terminology_reference`
- Severity: `yellow`
- Recommended action: `Rewrite`
- Linear-ready: `True`
- Auto-resolved: `False`
- Reason: Active item contains retired IA, retired terminology, or unsafe language; rewrite or retire before reuse.
- Involved active paths:
  - `CODEX_VISUAL_QA_PROTOCOL` — `docs/codex/CODEX_VISUAL_QA_PROTOCOL.md` (unknown; release proof)

### 62. Retired IA/terminology reference in PX07_Action_Closure_Recovery_Experience_Prompt

- Candidate ID: `AMB28-retired_ia_or_terminology_reference-40688011`
- Evidence type: `retired_ia_or_terminology_reference`
- Severity: `yellow`
- Recommended action: `Rewrite`
- Linear-ready: `True`
- Auto-resolved: `False`
- Reason: Active item contains retired IA, retired terminology, or unsafe language; rewrite or retire before reuse.
- Involved active paths:
  - `PX07_Action_Closure_Recovery_Experience_Prompt` — `docs/codex/batches/PX07_Action_Closure_Recovery_Experience_Prompt.md` (partial_implementation; release proof)

### 63. Retired IA/terminology reference in FVQ01_RENDERED_VISUAL_FRESHNESS_AND_FLAGSHIP_GATE

- Candidate ID: `AMB28-retired_ia_or_terminology_reference-41499153`
- Evidence type: `retired_ia_or_terminology_reference`
- Severity: `yellow`
- Recommended action: `Rewrite`
- Linear-ready: `True`
- Auto-resolved: `False`
- Reason: Active item contains retired IA, retired terminology, or unsafe language; rewrite or retire before reuse.
- Involved active paths:
  - `FVQ01_RENDERED_VISUAL_FRESHNESS_AND_FLAGSHIP_GATE` — `docs/codex/visual-quality/FVQ01_RENDERED_VISUAL_FRESHNESS_AND_FLAGSHIP_GATE.md` (partial_implementation; release proof)

### 64. Retired IA/terminology reference in DAV03_Today_DayTimelineRail_And_HeroStepPanel_Implementation_Prompt

- Candidate ID: `AMB28-retired_ia_or_terminology_reference-42680856`
- Evidence type: `retired_ia_or_terminology_reference`
- Severity: `yellow`
- Recommended action: `Rewrite`
- Linear-ready: `True`
- Auto-resolved: `False`
- Reason: Active item contains retired IA, retired terminology, or unsafe language; rewrite or retire before reuse.
- Involved active paths:
  - `DAV03_Today_DayTimelineRail_And_HeroStepPanel_Implementation_Prompt` — `docs/codex/batches/DAV03_Today_DayTimelineRail_And_HeroStepPanel_Implementation_Prompt.md` (partial_implementation; release proof)

### 65. Retired IA/terminology reference in PXOS_PRODUCT_DECISION_LEDGER

- Candidate ID: `AMB28-retired_ia_or_terminology_reference-43006206`
- Evidence type: `retired_ia_or_terminology_reference`
- Severity: `yellow`
- Recommended action: `Rewrite`
- Linear-ready: `True`
- Auto-resolved: `False`
- Reason: Active item contains retired IA, retired terminology, or unsafe language; rewrite or retire before reuse.
- Involved active paths:
  - `PXOS_PRODUCT_DECISION_LEDGER` — `docs/codex/PXOS_PRODUCT_DECISION_LEDGER.md` (unknown; release proof)

### 66. Retired IA/terminology reference in PD14_Life_Shape_Drilldowns_Prompt

- Candidate ID: `AMB28-retired_ia_or_terminology_reference-44131272`
- Evidence type: `retired_ia_or_terminology_reference`
- Severity: `yellow`
- Recommended action: `Rewrite`
- Linear-ready: `True`
- Auto-resolved: `False`
- Reason: Active item contains retired IA, retired terminology, or unsafe language; rewrite or retire before reuse.
- Involved active paths:
  - `PD14_Life_Shape_Drilldowns_Prompt` — `docs/codex/batches/PD14_Life_Shape_Drilldowns_Prompt.md` (partial_implementation; release proof)

### 67. Retired IA/terminology reference in PX12_Accessibility_Cognitive_Load_Emotional_Safety_Prompt

- Candidate ID: `AMB28-retired_ia_or_terminology_reference-44686906`
- Evidence type: `retired_ia_or_terminology_reference`
- Severity: `yellow`
- Recommended action: `Rewrite`
- Linear-ready: `True`
- Auto-resolved: `False`
- Reason: Active item contains retired IA, retired terminology, or unsafe language; rewrite or retire before reuse.
- Involved active paths:
  - `PX12_Accessibility_Cognitive_Load_Emotional_Safety_Prompt` — `docs/codex/batches/PX12_Accessibility_Cognitive_Load_Emotional_Safety_Prompt.md` (partial_implementation; release proof)

### 68. Retired IA/terminology reference in PD04_Today_Recovery_And_Closure_Depth_Prompt

- Candidate ID: `AMB28-retired_ia_or_terminology_reference-4811542`
- Evidence type: `retired_ia_or_terminology_reference`
- Severity: `yellow`
- Recommended action: `Rewrite`
- Linear-ready: `True`
- Auto-resolved: `False`
- Reason: Active item contains retired IA, retired terminology, or unsafe language; rewrite or retire before reuse.
- Involved active paths:
  - `PD04_Today_Recovery_And_Closure_Depth_Prompt` — `docs/codex/batches/PD04_Today_Recovery_And_Closure_Depth_Prompt.md` (partial_implementation; release proof)

### 69. Retired IA/terminology reference in OBJECT_FRONTEND_GREEN_YELLOW_RED_RUBRIC

- Candidate ID: `AMB28-retired_ia_or_terminology_reference-48361765`
- Evidence type: `retired_ia_or_terminology_reference`
- Severity: `yellow`
- Recommended action: `Rewrite`
- Linear-ready: `True`
- Auto-resolved: `False`
- Reason: Active item contains retired IA, retired terminology, or unsafe language; rewrite or retire before reuse.
- Involved active paths:
  - `OBJECT_FRONTEND_GREEN_YELLOW_RED_RUBRIC` — `docs/codex/frontend/OBJECT_FRONTEND_GREEN_YELLOW_RED_RUBRIC.md` (partial_implementation; release proof)

### 70. Retired IA/terminology reference in PD01_PD18_PRODUCT_DEPTH_TRAIN

- Candidate ID: `AMB28-retired_ia_or_terminology_reference-48977404`
- Evidence type: `retired_ia_or_terminology_reference`
- Severity: `yellow`
- Recommended action: `Rewrite`
- Linear-ready: `True`
- Auto-resolved: `False`
- Reason: Active item contains retired IA, retired terminology, or unsafe language; rewrite or retire before reuse.
- Involved active paths:
  - `PD01_PD18_PRODUCT_DEPTH_TRAIN` — `docs/codex/batch-trains/PD01_PD18_PRODUCT_DEPTH_TRAIN.md` (partial_implementation; release proof)

### 71. Retired IA/terminology reference in HPS01_HPS12_HUMAN_PROGRESS_SYSTEMS_UPGRADE_TRAIN

- Candidate ID: `AMB28-retired_ia_or_terminology_reference-49165399`
- Evidence type: `retired_ia_or_terminology_reference`
- Severity: `yellow`
- Recommended action: `Rewrite`
- Linear-ready: `True`
- Auto-resolved: `False`
- Reason: Active item contains retired IA, retired terminology, or unsafe language; rewrite or retire before reuse.
- Involved active paths:
  - `HPS01_HPS12_HUMAN_PROGRESS_SYSTEMS_UPGRADE_TRAIN` — `docs/codex/batch-trains/HPS01_HPS12_HUMAN_PROGRESS_SYSTEMS_UPGRADE_TRAIN.md` (partial_implementation; release proof)

### 72. Retired IA/terminology reference in AOS16_Performance_Energy_Kernel_Prompt

- Candidate ID: `AMB28-retired_ia_or_terminology_reference-4931381`
- Evidence type: `retired_ia_or_terminology_reference`
- Severity: `yellow`
- Recommended action: `Rewrite`
- Linear-ready: `True`
- Auto-resolved: `False`
- Reason: Active item contains retired IA, retired terminology, or unsafe language; rewrite or retire before reuse.
- Involved active paths:
  - `AOS16_Performance_Energy_Kernel_Prompt` — `docs/codex/batches/AOS16_Performance_Energy_Kernel_Prompt.md` (partial_implementation; release proof)

### 73. Retired IA/terminology reference in VISUAL-CANON-MOAT-01

- Candidate ID: `AMB28-retired_ia_or_terminology_reference-49704108`
- Evidence type: `retired_ia_or_terminology_reference`
- Severity: `yellow`
- Recommended action: `Rewrite`
- Linear-ready: `True`
- Auto-resolved: `False`
- Reason: Active item contains retired IA, retired terminology, or unsafe language; rewrite or retire before reuse.
- Involved active paths:
  - `VISUAL-CANON-MOAT-01` — `prompts/batches/VISUAL-CANON-MOAT-01.md` (partial_implementation; release proof)

### 74. Retired IA/terminology reference in AOS17_Privacy_Safety_Kernel_Prompt

- Candidate ID: `AMB28-retired_ia_or_terminology_reference-49782297`
- Evidence type: `retired_ia_or_terminology_reference`
- Severity: `yellow`
- Recommended action: `Rewrite`
- Linear-ready: `True`
- Auto-resolved: `False`
- Reason: Active item contains retired IA, retired terminology, or unsafe language; rewrite or retire before reuse.
- Involved active paths:
  - `AOS17_Privacy_Safety_Kernel_Prompt` — `docs/codex/batches/AOS17_Privacy_Safety_Kernel_Prompt.md` (partial_implementation; release proof)

### 75. Retired IA/terminology reference in PD02_Today_Step_Detail_Depth_Prompt

- Candidate ID: `AMB28-retired_ia_or_terminology_reference-50558884`
- Evidence type: `retired_ia_or_terminology_reference`
- Severity: `yellow`
- Recommended action: `Rewrite`
- Linear-ready: `True`
- Auto-resolved: `False`
- Reason: Active item contains retired IA, retired terminology, or unsafe language; rewrite or retire before reuse.
- Involved active paths:
  - `PD02_Today_Step_Detail_Depth_Prompt` — `docs/codex/batches/PD02_Today_Step_Detail_Depth_Prompt.md` (partial_implementation; release proof)

### 76. Retired IA/terminology reference in AQOS_AUTONOMOUS_QUALITY_OPERATING_SYSTEM

- Candidate ID: `AMB28-retired_ia_or_terminology_reference-50900713`
- Evidence type: `retired_ia_or_terminology_reference`
- Severity: `yellow`
- Recommended action: `Rewrite`
- Linear-ready: `True`
- Auto-resolved: `False`
- Reason: Active item contains retired IA, retired terminology, or unsafe language; rewrite or retire before reuse.
- Involved active paths:
  - `AQOS_AUTONOMOUS_QUALITY_OPERATING_SYSTEM` — `docs/codex/quality/AQOS_AUTONOMOUS_QUALITY_OPERATING_SYSTEM.md` (partial_implementation; release proof)

### 77. Retired IA/terminology reference in FRONTEND_PRIMITIVE_MISUSE_AND_DENSITY_GATE

- Candidate ID: `AMB28-retired_ia_or_terminology_reference-50937006`
- Evidence type: `retired_ia_or_terminology_reference`
- Severity: `yellow`
- Recommended action: `Rewrite`
- Linear-ready: `True`
- Auto-resolved: `False`
- Reason: Active item contains retired IA, retired terminology, or unsafe language; rewrite or retire before reuse.
- Involved active paths:
  - `FRONTEND_PRIMITIVE_MISUSE_AND_DENSITY_GATE` — `docs/codex/FRONTEND_PRIMITIVE_MISUSE_AND_DENSITY_GATE.md` (unknown; release proof)

### 78. Retired IA/terminology reference in SIGNATURE-VISUAL-INSTRUMENTS-ENCYCLOPEDIA-07

- Candidate ID: `AMB28-retired_ia_or_terminology_reference-52180060`
- Evidence type: `retired_ia_or_terminology_reference`
- Severity: `yellow`
- Recommended action: `Rewrite`
- Linear-ready: `True`
- Auto-resolved: `False`
- Reason: Active item contains retired IA, retired terminology, or unsafe language; rewrite or retire before reuse.
- Involved active paths:
  - `SIGNATURE-VISUAL-INSTRUMENTS-ENCYCLOPEDIA-07` — `prompts/batches/SIGNATURE-VISUAL-INSTRUMENTS-ENCYCLOPEDIA-07.md` (partial_implementation; release proof)

### 79. Retired IA/terminology reference in AMB-POST23-02-UNDERDELIVERY-REPAIR

- Candidate ID: `AMB28-retired_ia_or_terminology_reference-52374927`
- Evidence type: `retired_ia_or_terminology_reference`
- Severity: `yellow`
- Recommended action: `Rewrite`
- Linear-ready: `True`
- Auto-resolved: `False`
- Reason: Active item contains retired IA, retired terminology, or unsafe language; rewrite or retire before reuse.
- Involved active paths:
  - `AMB-POST23-02-UNDERDELIVERY-REPAIR` — `docs/codex/reports/AMB-POST23-02-UNDERDELIVERY-REPAIR.md` (partial_implementation; release proof)

### 80. Retired IA/terminology reference in CODEX_QUALITY_SYSTEM_BATCH_REPORT_TEMPLATE

- Candidate ID: `AMB28-retired_ia_or_terminology_reference-54396187`
- Evidence type: `retired_ia_or_terminology_reference`
- Severity: `yellow`
- Recommended action: `Rewrite`
- Linear-ready: `True`
- Auto-resolved: `False`
- Reason: Active item contains retired IA, retired terminology, or unsafe language; rewrite or retire before reuse.
- Involved active paths:
  - `CODEX_QUALITY_SYSTEM_BATCH_REPORT_TEMPLATE` — `docs/codex/CODEX_QUALITY_SYSTEM_BATCH_REPORT_TEMPLATE.md` (partial_implementation; release proof)

### 81. Retired IA/terminology reference in PX04_Capture_Experience_Prompt

- Candidate ID: `AMB28-retired_ia_or_terminology_reference-54535904`
- Evidence type: `retired_ia_or_terminology_reference`
- Severity: `yellow`
- Recommended action: `Rewrite`
- Linear-ready: `True`
- Auto-resolved: `False`
- Reason: Active item contains retired IA, retired terminology, or unsafe language; rewrite or retire before reuse.
- Involved active paths:
  - `PX04_Capture_Experience_Prompt` — `docs/codex/batches/PX04_Capture_Experience_Prompt.md` (partial_implementation; release proof)

### 82. Retired IA/terminology reference in HPS_GATE_MATRIX

- Candidate ID: `AMB28-retired_ia_or_terminology_reference-54746946`
- Evidence type: `retired_ia_or_terminology_reference`
- Severity: `yellow`
- Recommended action: `Rewrite`
- Linear-ready: `True`
- Auto-resolved: `False`
- Reason: Active item contains retired IA, retired terminology, or unsafe language; rewrite or retire before reuse.
- Involved active paths:
  - `HPS_GATE_MATRIX` — `docs/codex/HPS_GATE_MATRIX.md` (partial_implementation; release proof)

### 83. Retired IA/terminology reference in PXEQ_LIVING_INTERFACE_RUBRIC

- Candidate ID: `AMB28-retired_ia_or_terminology_reference-54905393`
- Evidence type: `retired_ia_or_terminology_reference`
- Severity: `yellow`
- Recommended action: `Rewrite`
- Linear-ready: `True`
- Auto-resolved: `False`
- Reason: Active item contains retired IA, retired terminology, or unsafe language; rewrite or retire before reuse.
- Involved active paths:
  - `PXEQ_LIVING_INTERFACE_RUBRIC` — `docs/codex/PXEQ_LIVING_INTERFACE_RUBRIC.md` (partial_implementation; release proof)

### 84. Retired IA/terminology reference in AOS13_Source_Truth_Claim_State_Machine_Prompt

- Candidate ID: `AMB28-retired_ia_or_terminology_reference-5496680`
- Evidence type: `retired_ia_or_terminology_reference`
- Severity: `yellow`
- Recommended action: `Rewrite`
- Linear-ready: `True`
- Auto-resolved: `False`
- Reason: Active item contains retired IA, retired terminology, or unsafe language; rewrite or retire before reuse.
- Involved active paths:
  - `AOS13_Source_Truth_Claim_State_Machine_Prompt` — `docs/codex/batches/AOS13_Source_Truth_Claim_State_Machine_Prompt.md` (partial_implementation; release proof)

### 85. Retired IA/terminology reference in FE-07-ROOT-SURFACES

- Candidate ID: `AMB28-retired_ia_or_terminology_reference-54971450`
- Evidence type: `retired_ia_or_terminology_reference`
- Severity: `yellow`
- Recommended action: `Rewrite`
- Linear-ready: `True`
- Auto-resolved: `False`
- Reason: Active item contains retired IA, retired terminology, or unsafe language; rewrite or retire before reuse.
- Involved active paths:
  - `FE-07-ROOT-SURFACES` — `prompts/batches/amb-fe-be/FE-07-ROOT-SURFACES.md` (partial_implementation; release proof)

### 86. Retired IA/terminology reference in PX18_PXOS_Implementation_Readiness_Reorder_Prompt

- Candidate ID: `AMB28-retired_ia_or_terminology_reference-55808977`
- Evidence type: `retired_ia_or_terminology_reference`
- Severity: `yellow`
- Recommended action: `Rewrite`
- Linear-ready: `True`
- Auto-resolved: `False`
- Reason: Active item contains retired IA, retired terminology, or unsafe language; rewrite or retire before reuse.
- Involved active paths:
  - `PX18_PXOS_Implementation_Readiness_Reorder_Prompt` — `docs/codex/batches/PX18_PXOS_Implementation_Readiness_Reorder_Prompt.md` (partial_implementation; release proof)

### 87. Retired IA/terminology reference in AOS25_AmbitionsOS_Test_Fixture_Library_Prompt

- Candidate ID: `AMB28-retired_ia_or_terminology_reference-56283895`
- Evidence type: `retired_ia_or_terminology_reference`
- Severity: `yellow`
- Recommended action: `Rewrite`
- Linear-ready: `True`
- Auto-resolved: `False`
- Reason: Active item contains retired IA, retired terminology, or unsafe language; rewrite or retire before reuse.
- Involved active paths:
  - `AOS25_AmbitionsOS_Test_Fixture_Library_Prompt` — `docs/codex/batches/AOS25_AmbitionsOS_Test_Fixture_Library_Prompt.md` (partial_implementation; release proof)

### 88. Retired IA/terminology reference in AOS02_Life_Graph_Event_Log_Foundation_Prompt

- Candidate ID: `AMB28-retired_ia_or_terminology_reference-56479392`
- Evidence type: `retired_ia_or_terminology_reference`
- Severity: `yellow`
- Recommended action: `Rewrite`
- Linear-ready: `True`
- Auto-resolved: `False`
- Reason: Active item contains retired IA, retired terminology, or unsafe language; rewrite or retire before reuse.
- Involved active paths:
  - `AOS02_Life_Graph_Event_Log_Foundation_Prompt` — `docs/codex/batches/AOS02_Life_Graph_Event_Log_Foundation_Prompt.md` (partial_implementation; release proof)

### 89. Retired IA/terminology reference in AQOS_REQUIRED_EVIDENCE_MATRIX

- Candidate ID: `AMB28-retired_ia_or_terminology_reference-57430125`
- Evidence type: `retired_ia_or_terminology_reference`
- Severity: `yellow`
- Recommended action: `Rewrite`
- Linear-ready: `True`
- Auto-resolved: `False`
- Reason: Active item contains retired IA, retired terminology, or unsafe language; rewrite or retire before reuse.
- Involved active paths:
  - `AQOS_REQUIRED_EVIDENCE_MATRIX` — `docs/codex/quality/AQOS_REQUIRED_EVIDENCE_MATRIX.md` (partial_implementation; release proof)

### 90. Retired IA/terminology reference in FCP01_FCP30_FLAGSHIP_COMPLETION_TRAIN

- Candidate ID: `AMB28-retired_ia_or_terminology_reference-5784230`
- Evidence type: `retired_ia_or_terminology_reference`
- Severity: `yellow`
- Recommended action: `Rewrite`
- Linear-ready: `True`
- Auto-resolved: `False`
- Reason: Active item contains retired IA, retired terminology, or unsafe language; rewrite or retire before reuse.
- Involved active paths:
  - `FCP01_FCP30_FLAGSHIP_COMPLETION_TRAIN` — `docs/codex/batch-trains/FCP01_FCP30_FLAGSHIP_COMPLETION_TRAIN.md` (partial_implementation; release proof)

### 91. Retired IA/terminology reference in FVQ_VISUAL_EXCELLENCE_CONTINUATION_PROMPT

- Candidate ID: `AMB28-retired_ia_or_terminology_reference-57852694`
- Evidence type: `retired_ia_or_terminology_reference`
- Severity: `yellow`
- Recommended action: `Rewrite`
- Linear-ready: `True`
- Auto-resolved: `False`
- Reason: Active item contains retired IA, retired terminology, or unsafe language; rewrite or retire before reuse.
- Involved active paths:
  - `FVQ_VISUAL_EXCELLENCE_CONTINUATION_PROMPT` — `docs/codex/batches/FVQ_VISUAL_EXCELLENCE_CONTINUATION_PROMPT.md` (partial_implementation; release proof)

### 92. Retired IA/terminology reference in PXOS_GATE_MATRIX

- Candidate ID: `AMB28-retired_ia_or_terminology_reference-58172925`
- Evidence type: `retired_ia_or_terminology_reference`
- Severity: `yellow`
- Recommended action: `Rewrite`
- Linear-ready: `True`
- Auto-resolved: `False`
- Reason: Active item contains retired IA, retired terminology, or unsafe language; rewrite or retire before reuse.
- Involved active paths:
  - `PXOS_GATE_MATRIX` — `docs/codex/PXOS_GATE_MATRIX.md` (partial_implementation; release proof)

### 93. Retired IA/terminology reference in AMB-ISSUE-TEMPLATES

- Candidate ID: `AMB28-retired_ia_or_terminology_reference-58443040`
- Evidence type: `retired_ia_or_terminology_reference`
- Severity: `yellow`
- Recommended action: `Rewrite`
- Linear-ready: `True`
- Auto-resolved: `False`
- Reason: Active item contains retired IA, retired terminology, or unsafe language; rewrite or retire before reuse.
- Involved active paths:
  - `AMB-ISSUE-TEMPLATES` — `docs/codex/linear-templates/AMB-ISSUE-TEMPLATES.md` (partial_implementation; release proof)

### 94. Retired IA/terminology reference in REPO_INTELLIGENCE_CONTROL_PLANE

- Candidate ID: `AMB28-retired_ia_or_terminology_reference-59159814`
- Evidence type: `retired_ia_or_terminology_reference`
- Severity: `yellow`
- Recommended action: `Rewrite`
- Linear-ready: `True`
- Auto-resolved: `False`
- Reason: Active item contains retired IA, retired terminology, or unsafe language; rewrite or retire before reuse.
- Involved active paths:
  - `REPO_INTELLIGENCE_CONTROL_PLANE` — `docs/codex/REPO_INTELLIGENCE_CONTROL_PLANE.md` (unknown; release proof)

### 95. Retired IA/terminology reference in PX10_Visual_Interaction_System_Prompt

- Candidate ID: `AMB28-retired_ia_or_terminology_reference-59496696`
- Evidence type: `retired_ia_or_terminology_reference`
- Severity: `yellow`
- Recommended action: `Rewrite`
- Linear-ready: `True`
- Auto-resolved: `False`
- Reason: Active item contains retired IA, retired terminology, or unsafe language; rewrite or retire before reuse.
- Involved active paths:
  - `PX10_Visual_Interaction_System_Prompt` — `docs/codex/batches/PX10_Visual_Interaction_System_Prompt.md` (partial_implementation; release proof)

### 96. Retired IA/terminology reference in AMB-POST23-TRUTH-AUDIT-REPAIR-ROUTING

- Candidate ID: `AMB28-retired_ia_or_terminology_reference-59518727`
- Evidence type: `retired_ia_or_terminology_reference`
- Severity: `yellow`
- Recommended action: `Rewrite`
- Linear-ready: `True`
- Auto-resolved: `False`
- Reason: Active item contains retired IA, retired terminology, or unsafe language; rewrite or retire before reuse.
- Involved active paths:
  - `AMB-POST23-TRUTH-AUDIT-REPAIR-ROUTING` — `docs/codex/batch-trains/post-23-truth-audit/AMB-POST23-TRUTH-AUDIT-REPAIR-ROUTING.md` (partial_implementation; release proof)

### 97. Retired IA/terminology reference in PX09_Copy_Language_Explanation_System_Prompt

- Candidate ID: `AMB28-retired_ia_or_terminology_reference-59610775`
- Evidence type: `retired_ia_or_terminology_reference`
- Severity: `yellow`
- Recommended action: `Rewrite`
- Linear-ready: `True`
- Auto-resolved: `False`
- Reason: Active item contains retired IA, retired terminology, or unsafe language; rewrite or retire before reuse.
- Involved active paths:
  - `PX09_Copy_Language_Explanation_System_Prompt` — `docs/codex/batches/PX09_Copy_Language_Explanation_System_Prompt.md` (partial_implementation; release proof)

### 98. Retired IA/terminology reference in PD03_Today_Step_Session_Depth_Prompt

- Candidate ID: `AMB28-retired_ia_or_terminology_reference-60011638`
- Evidence type: `retired_ia_or_terminology_reference`
- Severity: `yellow`
- Recommended action: `Rewrite`
- Linear-ready: `True`
- Auto-resolved: `False`
- Reason: Active item contains retired IA, retired terminology, or unsafe language; rewrite or retire before reuse.
- Involved active paths:
  - `PD03_Today_Step_Session_Depth_Prompt` — `docs/codex/batches/PD03_Today_Step_Session_Depth_Prompt.md` (partial_implementation; release proof)

### 99. Retired IA/terminology reference in CODEX-OS-GOVERNANCE-FULL-AUTONOMY-INTEGRATION-01

- Candidate ID: `AMB28-retired_ia_or_terminology_reference-60162119`
- Evidence type: `retired_ia_or_terminology_reference`
- Severity: `yellow`
- Recommended action: `Rewrite`
- Linear-ready: `True`
- Auto-resolved: `False`
- Reason: Active item contains retired IA, retired terminology, or unsafe language; rewrite or retire before reuse.
- Involved active paths:
  - `CODEX-OS-GOVERNANCE-FULL-AUTONOMY-INTEGRATION-01` — `prompts/batches/CODEX-OS-GOVERNANCE-FULL-AUTONOMY-INTEGRATION-01.md` (partial_implementation; release proof)

### 100. Retired IA/terminology reference in FL01_FL06_FOUND_LIFE_LAYER_TRAIN

- Candidate ID: `AMB28-retired_ia_or_terminology_reference-60709516`
- Evidence type: `retired_ia_or_terminology_reference`
- Severity: `yellow`
- Recommended action: `Rewrite`
- Linear-ready: `True`
- Auto-resolved: `False`
- Reason: Active item contains retired IA, retired terminology, or unsafe language; rewrite or retire before reuse.
- Involved active paths:
  - `FL01_FL06_FOUND_LIFE_LAYER_TRAIN` — `docs/codex/batch-trains/FL01_FL06_FOUND_LIFE_LAYER_TRAIN.md` (partial_implementation; release proof)

### 101. Retired IA/terminology reference in AOS20_Adaptation_Kernel_Local_Personalization_Prompt

- Candidate ID: `AMB28-retired_ia_or_terminology_reference-62233019`
- Evidence type: `retired_ia_or_terminology_reference`
- Severity: `yellow`
- Recommended action: `Rewrite`
- Linear-ready: `True`
- Auto-resolved: `False`
- Reason: Active item contains retired IA, retired terminology, or unsafe language; rewrite or retire before reuse.
- Involved active paths:
  - `AOS20_Adaptation_Kernel_Local_Personalization_Prompt` — `docs/codex/batches/AOS20_Adaptation_Kernel_Local_Personalization_Prompt.md` (partial_implementation; release proof)

### 102. Retired IA/terminology reference in OBJECT_OS_NATIVE_SURFACES

- Candidate ID: `AMB28-retired_ia_or_terminology_reference-62516525`
- Evidence type: `retired_ia_or_terminology_reference`
- Severity: `yellow`
- Recommended action: `Rewrite`
- Linear-ready: `True`
- Auto-resolved: `False`
- Reason: Active item contains retired IA, retired terminology, or unsafe language; rewrite or retire before reuse.
- Involved active paths:
  - `OBJECT_OS_NATIVE_SURFACES` — `docs/codex/OBJECT_OS_NATIVE_SURFACES.md` (unknown; release proof)

### 103. Retired IA/terminology reference in IR-01-FRONTEND-RECOVERY-GATE

- Candidate ID: `AMB28-retired_ia_or_terminology_reference-6279795`
- Evidence type: `retired_ia_or_terminology_reference`
- Severity: `yellow`
- Recommended action: `Rewrite`
- Linear-ready: `True`
- Auto-resolved: `False`
- Reason: Active item contains retired IA, retired terminology, or unsafe language; rewrite or retire before reuse.
- Involved active paths:
  - `IR-01-FRONTEND-RECOVERY-GATE` — `prompts/batches/IR-01-FRONTEND-RECOVERY-GATE.md` (partial_implementation; release proof)

### 104. Retired IA/terminology reference in AOS06_Goal_Path_Kernel_Goal_Compiler_Prompt

- Candidate ID: `AMB28-retired_ia_or_terminology_reference-63080298`
- Evidence type: `retired_ia_or_terminology_reference`
- Severity: `yellow`
- Recommended action: `Rewrite`
- Linear-ready: `True`
- Auto-resolved: `False`
- Reason: Active item contains retired IA, retired terminology, or unsafe language; rewrite or retire before reuse.
- Involved active paths:
  - `AOS06_Goal_Path_Kernel_Goal_Compiler_Prompt` — `docs/codex/batches/AOS06_Goal_Path_Kernel_Goal_Compiler_Prompt.md` (partial_implementation; release proof)

### 105. Retired IA/terminology reference in AFI07_Goals_Constellation_Atlas

- Candidate ID: `AMB28-retired_ia_or_terminology_reference-63267693`
- Evidence type: `retired_ia_or_terminology_reference`
- Severity: `yellow`
- Recommended action: `Rewrite`
- Linear-ready: `True`
- Auto-resolved: `False`
- Reason: Active item contains retired IA, retired terminology, or unsafe language; rewrite or retire before reuse.
- Involved active paths:
  - `AFI07_Goals_Constellation_Atlas` — `docs/codex/batches/AFI07_Goals_Constellation_Atlas.md` (partial_implementation; release proof)

### 106. Retired IA/terminology reference in AMB-LINEAR-TEMPLATE-MANIFEST

- Candidate ID: `AMB28-retired_ia_or_terminology_reference-63531664`
- Evidence type: `retired_ia_or_terminology_reference`
- Severity: `yellow`
- Recommended action: `Rewrite`
- Linear-ready: `True`
- Auto-resolved: `False`
- Reason: Active item contains retired IA, retired terminology, or unsafe language; rewrite or retire before reuse.
- Involved active paths:
  - `AMB-LINEAR-TEMPLATE-MANIFEST` — `docs/codex/linear-templates/AMB-LINEAR-TEMPLATE-MANIFEST.yml` (partial_implementation; release proof)

### 107. Retired IA/terminology reference in PD07_Goal_Proof_And_Decision_History_Depth_Prompt

- Candidate ID: `AMB28-retired_ia_or_terminology_reference-64200904`
- Evidence type: `retired_ia_or_terminology_reference`
- Severity: `yellow`
- Recommended action: `Rewrite`
- Linear-ready: `True`
- Auto-resolved: `False`
- Reason: Active item contains retired IA, retired terminology, or unsafe language; rewrite or retire before reuse.
- Involved active paths:
  - `PD07_Goal_Proof_And_Decision_History_Depth_Prompt` — `docs/codex/batches/PD07_Goal_Proof_And_Decision_History_Depth_Prompt.md` (partial_implementation; release proof)

### 108. Retired IA/terminology reference in AQOS_AUTONOMOUS_QUALITY_COUNCIL

- Candidate ID: `AMB28-retired_ia_or_terminology_reference-64961065`
- Evidence type: `retired_ia_or_terminology_reference`
- Severity: `yellow`
- Recommended action: `Rewrite`
- Linear-ready: `True`
- Auto-resolved: `False`
- Reason: Active item contains retired IA, retired terminology, or unsafe language; rewrite or retire before reuse.
- Involved active paths:
  - `AQOS_AUTONOMOUS_QUALITY_COUNCIL` — `docs/codex/quality/AQOS_AUTONOMOUS_QUALITY_COUNCIL.md` (partial_implementation; release proof)

### 109. Retired IA/terminology reference in FVQ04_RECURRING_UI_BATCH_RENDERED_PROOF_PROTOCOL

- Candidate ID: `AMB28-retired_ia_or_terminology_reference-65049020`
- Evidence type: `retired_ia_or_terminology_reference`
- Severity: `yellow`
- Recommended action: `Rewrite`
- Linear-ready: `True`
- Auto-resolved: `False`
- Reason: Active item contains retired IA, retired terminology, or unsafe language; rewrite or retire before reuse.
- Involved active paths:
  - `FVQ04_RECURRING_UI_BATCH_RENDERED_PROOF_PROTOCOL` — `docs/codex/visual-quality/FVQ04_RECURRING_UI_BATCH_RENDERED_PROOF_PROTOCOL.md` (partial_implementation; release proof)

### 110. Retired IA/terminology reference in GLOBAL-VISUAL-CANON-MOAT-INSTALL-TRAIN-01

- Candidate ID: `AMB28-retired_ia_or_terminology_reference-65625107`
- Evidence type: `retired_ia_or_terminology_reference`
- Severity: `yellow`
- Recommended action: `Rewrite`
- Linear-ready: `True`
- Auto-resolved: `False`
- Reason: Active item contains retired IA, retired terminology, or unsafe language; rewrite or retire before reuse.
- Involved active paths:
  - `GLOBAL-VISUAL-CANON-MOAT-INSTALL-TRAIN-01` — `prompts/batches/GLOBAL-VISUAL-CANON-MOAT-INSTALL-TRAIN-01.md` (partial_implementation; release proof)

### 111. Retired IA/terminology reference in PD01_Product_Depth_Canon_Inventory_And_Ownership_Map_Prompt

- Candidate ID: `AMB28-retired_ia_or_terminology_reference-65900222`
- Evidence type: `retired_ia_or_terminology_reference`
- Severity: `yellow`
- Recommended action: `Rewrite`
- Linear-ready: `True`
- Auto-resolved: `False`
- Reason: Active item contains retired IA, retired terminology, or unsafe language; rewrite or retire before reuse.
- Involved active paths:
  - `PD01_Product_Depth_Canon_Inventory_And_Ownership_Map_Prompt` — `docs/codex/batches/PD01_Product_Depth_Canon_Inventory_And_Ownership_Map_Prompt.md` (partial_implementation; release proof)

### 112. Retired IA/terminology reference in PD06_Goal_Lifecycle_And_Path_Visualization_Prompt

- Candidate ID: `AMB28-retired_ia_or_terminology_reference-66069391`
- Evidence type: `retired_ia_or_terminology_reference`
- Severity: `yellow`
- Recommended action: `Rewrite`
- Linear-ready: `True`
- Auto-resolved: `False`
- Reason: Active item contains retired IA, retired terminology, or unsafe language; rewrite or retire before reuse.
- Involved active paths:
  - `PD06_Goal_Lifecycle_And_Path_Visualization_Prompt` — `docs/codex/batches/PD06_Goal_Lifecycle_And_Path_Visualization_Prompt.md` (partial_implementation; release proof)

### 113. Retired IA/terminology reference in FL06_Weekly_Life_Sweep_Ritual_Prompt

- Candidate ID: `AMB28-retired_ia_or_terminology_reference-66089523`
- Evidence type: `retired_ia_or_terminology_reference`
- Severity: `yellow`
- Recommended action: `Rewrite`
- Linear-ready: `True`
- Auto-resolved: `False`
- Reason: Active item contains retired IA, retired terminology, or unsafe language; rewrite or retire before reuse.
- Involved active paths:
  - `FL06_Weekly_Life_Sweep_Ritual_Prompt` — `docs/codex/batches/FL06_Weekly_Life_Sweep_Ritual_Prompt.md` (partial_implementation; release proof)

### 114. Retired IA/terminology reference in AOS04_Control_Plane_Work_Classifier_Prompt

- Candidate ID: `AMB28-retired_ia_or_terminology_reference-66492330`
- Evidence type: `retired_ia_or_terminology_reference`
- Severity: `yellow`
- Recommended action: `Rewrite`
- Linear-ready: `True`
- Auto-resolved: `False`
- Reason: Active item contains retired IA, retired terminology, or unsafe language; rewrite or retire before reuse.
- Involved active paths:
  - `AOS04_Control_Plane_Work_Classifier_Prompt` — `docs/codex/batches/AOS04_Control_Plane_Work_Classifier_Prompt.md` (partial_implementation; release proof)

### 115. Retired IA/terminology reference in PD08_Goal_Alternate_Path_And_Tradeoff_Depth_Prompt

- Candidate ID: `AMB28-retired_ia_or_terminology_reference-66748525`
- Evidence type: `retired_ia_or_terminology_reference`
- Severity: `yellow`
- Recommended action: `Rewrite`
- Linear-ready: `True`
- Auto-resolved: `False`
- Reason: Active item contains retired IA, retired terminology, or unsafe language; rewrite or retire before reuse.
- Involved active paths:
  - `PD08_Goal_Alternate_Path_And_Tradeoff_Depth_Prompt` — `docs/codex/batches/PD08_Goal_Alternate_Path_And_Tradeoff_Depth_Prompt.md` (partial_implementation; release proof)

### 116. Retired IA/terminology reference in PFC12_App_Groups_Shared_Storage_Boundary_Prompt

- Candidate ID: `AMB28-retired_ia_or_terminology_reference-66761589`
- Evidence type: `retired_ia_or_terminology_reference`
- Severity: `yellow`
- Recommended action: `Rewrite`
- Linear-ready: `True`
- Auto-resolved: `False`
- Reason: Active item contains retired IA, retired terminology, or unsafe language; rewrite or retire before reuse.
- Involved active paths:
  - `PFC12_App_Groups_Shared_Storage_Boundary_Prompt` — `docs/codex/batches/PFC12_App_Groups_Shared_Storage_Boundary_Prompt.md` (unknown; release proof)

### 117. Retired IA/terminology reference in AOS26_AmbitionsOS_Privacy_Performance_QA_Prompt

- Candidate ID: `AMB28-retired_ia_or_terminology_reference-67499145`
- Evidence type: `retired_ia_or_terminology_reference`
- Severity: `yellow`
- Recommended action: `Rewrite`
- Linear-ready: `True`
- Auto-resolved: `False`
- Reason: Active item contains retired IA, retired terminology, or unsafe language; rewrite or retire before reuse.
- Involved active paths:
  - `AOS26_AmbitionsOS_Privacy_Performance_QA_Prompt` — `docs/codex/batches/AOS26_AmbitionsOS_Privacy_Performance_QA_Prompt.md` (partial_implementation; release proof)

### 118. Retired IA/terminology reference in PX15_Cross_Surface_Continuity_Prompt

- Candidate ID: `AMB28-retired_ia_or_terminology_reference-6763694`
- Evidence type: `retired_ia_or_terminology_reference`
- Severity: `yellow`
- Recommended action: `Rewrite`
- Linear-ready: `True`
- Auto-resolved: `False`
- Reason: Active item contains retired IA, retired terminology, or unsafe language; rewrite or retire before reuse.
- Involved active paths:
  - `PX15_Cross_Surface_Continuity_Prompt` — `docs/codex/batches/PX15_Cross_Surface_Continuity_Prompt.md` (partial_implementation; release proof)

### 119. Retired IA/terminology reference in AOS19_Experience_Kernel_Celestial_Cognitive_Load_Prompt

- Candidate ID: `AMB28-retired_ia_or_terminology_reference-67832822`
- Evidence type: `retired_ia_or_terminology_reference`
- Severity: `yellow`
- Recommended action: `Rewrite`
- Linear-ready: `True`
- Auto-resolved: `False`
- Reason: Active item contains retired IA, retired terminology, or unsafe language; rewrite or retire before reuse.
- Involved active paths:
  - `AOS19_Experience_Kernel_Celestial_Cognitive_Load_Prompt` — `docs/codex/batches/AOS19_Experience_Kernel_Celestial_Cognitive_Load_Prompt.md` (partial_implementation; release proof)

### 120. Retired IA/terminology reference in MOAT_RUNTIME_BATCH_OVERLAY

- Candidate ID: `AMB28-retired_ia_or_terminology_reference-69319979`
- Evidence type: `retired_ia_or_terminology_reference`
- Severity: `yellow`
- Recommended action: `Rewrite`
- Linear-ready: `True`
- Auto-resolved: `False`
- Reason: Active item contains retired IA, retired terminology, or unsafe language; rewrite or retire before reuse.
- Involved active paths:
  - `MOAT_RUNTIME_BATCH_OVERLAY` — `docs/codex/MOAT_RUNTIME_BATCH_OVERLAY.json` (partial_implementation; release proof)

### 121. Retired IA/terminology reference in HPS_CROSS_TRAIN_INTEGRATION_MAP

- Candidate ID: `AMB28-retired_ia_or_terminology_reference-71025933`
- Evidence type: `retired_ia_or_terminology_reference`
- Severity: `yellow`
- Recommended action: `Rewrite`
- Linear-ready: `True`
- Auto-resolved: `False`
- Reason: Active item contains retired IA, retired terminology, or unsafe language; rewrite or retire before reuse.
- Involved active paths:
  - `HPS_CROSS_TRAIN_INTEGRATION_MAP` — `docs/codex/HPS_CROSS_TRAIN_INTEGRATION_MAP.md` (partial_implementation; release proof)

### 122. Retired IA/terminology reference in AQOS_AUTONOMOUS_QUALITY_CONTINUATION_PROMPT

- Candidate ID: `AMB28-retired_ia_or_terminology_reference-71287080`
- Evidence type: `retired_ia_or_terminology_reference`
- Severity: `yellow`
- Recommended action: `Rewrite`
- Linear-ready: `True`
- Auto-resolved: `False`
- Reason: Active item contains retired IA, retired terminology, or unsafe language; rewrite or retire before reuse.
- Involved active paths:
  - `AQOS_AUTONOMOUS_QUALITY_CONTINUATION_PROMPT` — `docs/codex/batches/AQOS_AUTONOMOUS_QUALITY_CONTINUATION_PROMPT.md` (partial_implementation; release proof)

### 123. Retired IA/terminology reference in PX01_PX20_PRODUCT_EXPERIENCE_OS_TRAIN

- Candidate ID: `AMB28-retired_ia_or_terminology_reference-72003197`
- Evidence type: `retired_ia_or_terminology_reference`
- Severity: `yellow`
- Recommended action: `Rewrite`
- Linear-ready: `True`
- Auto-resolved: `False`
- Reason: Active item contains retired IA, retired terminology, or unsafe language; rewrite or retire before reuse.
- Involved active paths:
  - `PX01_PX20_PRODUCT_EXPERIENCE_OS_TRAIN` — `docs/codex/batch-trains/PX01_PX20_PRODUCT_EXPERIENCE_OS_TRAIN.md` (partial_implementation; release proof)

### 124. Retired IA/terminology reference in AOS12_Proof_Trust_Closure_Receipts_Prompt

- Candidate ID: `AMB28-retired_ia_or_terminology_reference-72884380`
- Evidence type: `retired_ia_or_terminology_reference`
- Severity: `yellow`
- Recommended action: `Rewrite`
- Linear-ready: `True`
- Auto-resolved: `False`
- Reason: Active item contains retired IA, retired terminology, or unsafe language; rewrite or retire before reuse.
- Involved active paths:
  - `AOS12_Proof_Trust_Closure_Receipts_Prompt` — `docs/codex/batches/AOS12_Proof_Trust_Closure_Receipts_Prompt.md` (partial_implementation; release proof)

### 125. Retired IA/terminology reference in AMB-CODEX-OS-FLAGSHIP-UPGRADE-INSTALL-01

- Candidate ID: `AMB28-retired_ia_or_terminology_reference-73978046`
- Evidence type: `retired_ia_or_terminology_reference`
- Severity: `yellow`
- Recommended action: `Rewrite`
- Linear-ready: `True`
- Auto-resolved: `False`
- Reason: Active item contains retired IA, retired terminology, or unsafe language; rewrite or retire before reuse.
- Involved active paths:
  - `AMB-CODEX-OS-FLAGSHIP-UPGRADE-INSTALL-01` — `prompts/batches/AMB-CODEX-OS-FLAGSHIP-UPGRADE-INSTALL-01.md` (partial_implementation; release proof)

### 126. Retired IA/terminology reference in OBJECT_OS_PRIMITIVES

- Candidate ID: `AMB28-retired_ia_or_terminology_reference-7414304`
- Evidence type: `retired_ia_or_terminology_reference`
- Severity: `yellow`
- Recommended action: `Rewrite`
- Linear-ready: `True`
- Auto-resolved: `False`
- Reason: Active item contains retired IA, retired terminology, or unsafe language; rewrite or retire before reuse.
- Involved active paths:
  - `OBJECT_OS_PRIMITIVES` — `docs/codex/OBJECT_OS_PRIMITIVES.md` (partial_implementation; release proof)

### 127. Retired IA/terminology reference in DAV05_Plan_LifeShapeMap_And_CapacityVisuals_Implementation_Prompt

- Candidate ID: `AMB28-retired_ia_or_terminology_reference-74249518`
- Evidence type: `retired_ia_or_terminology_reference`
- Severity: `yellow`
- Recommended action: `Rewrite`
- Linear-ready: `True`
- Auto-resolved: `False`
- Reason: Active item contains retired IA, retired terminology, or unsafe language; rewrite or retire before reuse.
- Involved active paths:
  - `DAV05_Plan_LifeShapeMap_And_CapacityVisuals_Implementation_Prompt` — `docs/codex/batches/DAV05_Plan_LifeShapeMap_And_CapacityVisuals_Implementation_Prompt.md` (partial_implementation; release proof)

### 128. Retired IA/terminology reference in GLOBAL-BATCH-TRAIN-AUTONOMOUS-COMPLETE-01

- Candidate ID: `AMB28-retired_ia_or_terminology_reference-74875326`
- Evidence type: `retired_ia_or_terminology_reference`
- Severity: `yellow`
- Recommended action: `Rewrite`
- Linear-ready: `True`
- Auto-resolved: `False`
- Reason: Active item contains retired IA, retired terminology, or unsafe language; rewrite or retire before reuse.
- Involved active paths:
  - `GLOBAL-BATCH-TRAIN-AUTONOMOUS-COMPLETE-01` — `prompts/batches/GLOBAL-BATCH-TRAIN-AUTONOMOUS-COMPLETE-01.md` (partial_implementation; release proof)

### 129. Retired IA/terminology reference in IOS26_EXISTING_BATCH_EXPANSION_DIRECTIVES

- Candidate ID: `AMB28-retired_ia_or_terminology_reference-7495891`
- Evidence type: `retired_ia_or_terminology_reference`
- Severity: `yellow`
- Recommended action: `Rewrite`
- Linear-ready: `True`
- Auto-resolved: `False`
- Reason: Active item contains retired IA, retired terminology, or unsafe language; rewrite or retire before reuse.
- Involved active paths:
  - `IOS26_EXISTING_BATCH_EXPANSION_DIRECTIVES` — `docs/codex/frontend/IOS26_EXISTING_BATCH_EXPANSION_DIRECTIVES.md` (unknown; release proof)

### 130. Retired IA/terminology reference in CHROME-AUDIT-01

- Candidate ID: `AMB28-retired_ia_or_terminology_reference-77120008`
- Evidence type: `retired_ia_or_terminology_reference`
- Severity: `yellow`
- Recommended action: `Rewrite`
- Linear-ready: `True`
- Auto-resolved: `False`
- Reason: Active item contains retired IA, retired terminology, or unsafe language; rewrite or retire before reuse.
- Involved active paths:
  - `CHROME-AUDIT-01` — `prompts/batches/CHROME-AUDIT-01.md` (partial_implementation; release proof)

### 131. Retired IA/terminology reference in AOS23_Governance_Kernel_Registry_Prompt

- Candidate ID: `AMB28-retired_ia_or_terminology_reference-78194795`
- Evidence type: `retired_ia_or_terminology_reference`
- Severity: `yellow`
- Recommended action: `Rewrite`
- Linear-ready: `True`
- Auto-resolved: `False`
- Reason: Active item contains retired IA, retired terminology, or unsafe language; rewrite or retire before reuse.
- Involved active paths:
  - `AOS23_Governance_Kernel_Registry_Prompt` — `docs/codex/batches/AOS23_Governance_Kernel_Registry_Prompt.md` (partial_implementation; release proof)

### 132. Retired IA/terminology reference in PX20_PXOS_Beyond_Roadmap_Prompt

- Candidate ID: `AMB28-retired_ia_or_terminology_reference-78380525`
- Evidence type: `retired_ia_or_terminology_reference`
- Severity: `yellow`
- Recommended action: `Rewrite`
- Linear-ready: `True`
- Auto-resolved: `False`
- Reason: Active item contains retired IA, retired terminology, or unsafe language; rewrite or retire before reuse.
- Involved active paths:
  - `PX20_PXOS_Beyond_Roadmap_Prompt` — `docs/codex/batches/PX20_PXOS_Beyond_Roadmap_Prompt.md` (partial_implementation; release proof)

### 133. Retired IA/terminology reference in OBJECT-OS-CANON-01

- Candidate ID: `AMB28-retired_ia_or_terminology_reference-78539941`
- Evidence type: `retired_ia_or_terminology_reference`
- Severity: `yellow`
- Recommended action: `Rewrite`
- Linear-ready: `True`
- Auto-resolved: `False`
- Reason: Active item contains retired IA, retired terminology, or unsafe language; rewrite or retire before reuse.
- Involved active paths:
  - `OBJECT-OS-CANON-01` — `prompts/batches/OBJECT-OS-CANON-01.md` (partial_implementation; release proof)

### 134. Retired IA/terminology reference in MOAT-GOAL-REALITY-CAPTURE-BRIDGE-04

- Candidate ID: `AMB28-retired_ia_or_terminology_reference-78818644`
- Evidence type: `retired_ia_or_terminology_reference`
- Severity: `yellow`
- Recommended action: `Rewrite`
- Linear-ready: `True`
- Auto-resolved: `False`
- Reason: Active item contains retired IA, retired terminology, or unsafe language; rewrite or retire before reuse.
- Involved active paths:
  - `MOAT-GOAL-REALITY-CAPTURE-BRIDGE-04` — `prompts/batches/MOAT-GOAL-REALITY-CAPTURE-BRIDGE-04.md` (partial_implementation; release proof)

### 135. Retired IA/terminology reference in SIG03_Today_Signature_Experience_Implementation_Prompt

- Candidate ID: `AMB28-retired_ia_or_terminology_reference-7904994`
- Evidence type: `retired_ia_or_terminology_reference`
- Severity: `yellow`
- Recommended action: `Rewrite`
- Linear-ready: `True`
- Auto-resolved: `False`
- Reason: Active item contains retired IA, retired terminology, or unsafe language; rewrite or retire before reuse.
- Involved active paths:
  - `SIG03_Today_Signature_Experience_Implementation_Prompt` — `docs/codex/batches/SIG03_Today_Signature_Experience_Implementation_Prompt.md` (unknown; release proof)

### 136. Retired IA/terminology reference in frontend-gap-backlog

- Candidate ID: `AMB28-retired_ia_or_terminology_reference-80023145`
- Evidence type: `retired_ia_or_terminology_reference`
- Severity: `yellow`
- Recommended action: `Rewrite`
- Linear-ready: `True`
- Auto-resolved: `False`
- Reason: Active item contains retired IA, retired terminology, or unsafe language; rewrite or retire before reuse.
- Involved active paths:
  - `frontend-gap-backlog` — `docs/codex/frontend-gap-backlog.md` (partial_implementation; release proof)

### 137. Retired IA/terminology reference in AOS10_Commitment_Time_Kernel_Prompt

- Candidate ID: `AMB28-retired_ia_or_terminology_reference-80570046`
- Evidence type: `retired_ia_or_terminology_reference`
- Severity: `yellow`
- Recommended action: `Rewrite`
- Linear-ready: `True`
- Auto-resolved: `False`
- Reason: Active item contains retired IA, retired terminology, or unsafe language; rewrite or retire before reuse.
- Involved active paths:
  - `AOS10_Commitment_Time_Kernel_Prompt` — `docs/codex/batches/AOS10_Commitment_Time_Kernel_Prompt.md` (partial_implementation; release proof)

### 138. Retired IA/terminology reference in AMBITIONSOS_SURFACE_ENCAPSULATION_MATRIX

- Candidate ID: `AMB28-retired_ia_or_terminology_reference-80756898`
- Evidence type: `retired_ia_or_terminology_reference`
- Severity: `yellow`
- Recommended action: `Rewrite`
- Linear-ready: `True`
- Auto-resolved: `False`
- Reason: Active item contains retired IA, retired terminology, or unsafe language; rewrite or retire before reuse.
- Involved active paths:
  - `AMBITIONSOS_SURFACE_ENCAPSULATION_MATRIX` — `docs/codex/AMBITIONSOS_SURFACE_ENCAPSULATION_MATRIX.md` (partial_implementation; release proof)

### 139. Retired IA/terminology reference in AOS29_AmbitionsOS_Repair_Train_Prompt

- Candidate ID: `AMB28-retired_ia_or_terminology_reference-81883364`
- Evidence type: `retired_ia_or_terminology_reference`
- Severity: `yellow`
- Recommended action: `Rewrite`
- Linear-ready: `True`
- Auto-resolved: `False`
- Reason: Active item contains retired IA, retired terminology, or unsafe language; rewrite or retire before reuse.
- Involved active paths:
  - `AOS29_AmbitionsOS_Repair_Train_Prompt` — `docs/codex/batches/AOS29_AmbitionsOS_Repair_Train_Prompt.md` (partial_implementation; release proof)

### 140. Retired IA/terminology reference in IR01_FAANG_FRONTEND_INTERFACE_RECOVERY_PROMPT

- Candidate ID: `AMB28-retired_ia_or_terminology_reference-82417320`
- Evidence type: `retired_ia_or_terminology_reference`
- Severity: `yellow`
- Recommended action: `Rewrite`
- Linear-ready: `True`
- Auto-resolved: `False`
- Reason: Active item contains retired IA, retired terminology, or unsafe language; rewrite or retire before reuse.
- Involved active paths:
  - `IR01_FAANG_FRONTEND_INTERFACE_RECOVERY_PROMPT` — `docs/codex/batches/IR01_FAANG_FRONTEND_INTERFACE_RECOVERY_PROMPT.md` (partial_implementation; release proof)

### 141. Retired IA/terminology reference in AOS07_Local_Goal_Packs_Requirement_Slots_Prompt

- Candidate ID: `AMB28-retired_ia_or_terminology_reference-83860669`
- Evidence type: `retired_ia_or_terminology_reference`
- Severity: `yellow`
- Recommended action: `Rewrite`
- Linear-ready: `True`
- Auto-resolved: `False`
- Reason: Active item contains retired IA, retired terminology, or unsafe language; rewrite or retire before reuse.
- Involved active paths:
  - `AOS07_Local_Goal_Packs_Requirement_Slots_Prompt` — `docs/codex/batches/AOS07_Local_Goal_Packs_Requirement_Slots_Prompt.md` (partial_implementation; release proof)

### 142. Retired IA/terminology reference in AOS01_AOS30_AMBITIONSOS_LOCAL_INTELLIGENCE_TRAIN

- Candidate ID: `AMB28-retired_ia_or_terminology_reference-83976495`
- Evidence type: `retired_ia_or_terminology_reference`
- Severity: `yellow`
- Recommended action: `Rewrite`
- Linear-ready: `True`
- Auto-resolved: `False`
- Reason: Active item contains retired IA, retired terminology, or unsafe language; rewrite or retire before reuse.
- Involved active paths:
  - `AOS01_AOS30_AMBITIONSOS_LOCAL_INTELLIGENCE_TRAIN` — `docs/codex/batch-trains/AOS01_AOS30_AMBITIONSOS_LOCAL_INTELLIGENCE_TRAIN.md` (partial_implementation; release proof)

### 143. Retired IA/terminology reference in SIGNATURE_INTERFACE_SWIFTUI_ARCHITECTURE_MAP

- Candidate ID: `AMB28-retired_ia_or_terminology_reference-85812687`
- Evidence type: `retired_ia_or_terminology_reference`
- Severity: `yellow`
- Recommended action: `Rewrite`
- Linear-ready: `True`
- Auto-resolved: `False`
- Reason: Active item contains retired IA, retired terminology, or unsafe language; rewrite or retire before reuse.
- Involved active paths:
  - `SIGNATURE_INTERFACE_SWIFTUI_ARCHITECTURE_MAP` — `docs/codex/SIGNATURE_INTERFACE_SWIFTUI_ARCHITECTURE_MAP.md` (partial_implementation; release proof)

### 144. Retired IA/terminology reference in PD12_Plan_Reflow_Decision_Depth_Prompt

- Candidate ID: `AMB28-retired_ia_or_terminology_reference-86202332`
- Evidence type: `retired_ia_or_terminology_reference`
- Severity: `yellow`
- Recommended action: `Rewrite`
- Linear-ready: `True`
- Auto-resolved: `False`
- Reason: Active item contains retired IA, retired terminology, or unsafe language; rewrite or retire before reuse.
- Involved active paths:
  - `PD12_Plan_Reflow_Decision_Depth_Prompt` — `docs/codex/batches/PD12_Plan_Reflow_Decision_Depth_Prompt.md` (partial_implementation; release proof)

### 145. Retired IA/terminology reference in PD15_You_Trust_History_And_Receipts_Center_Prompt

- Candidate ID: `AMB28-retired_ia_or_terminology_reference-88599223`
- Evidence type: `retired_ia_or_terminology_reference`
- Severity: `yellow`
- Recommended action: `Rewrite`
- Linear-ready: `True`
- Auto-resolved: `False`
- Reason: Active item contains retired IA, retired terminology, or unsafe language; rewrite or retire before reuse.
- Involved active paths:
  - `PD15_You_Trust_History_And_Receipts_Center_Prompt` — `docs/codex/batches/PD15_You_Trust_History_And_Receipts_Center_Prompt.md` (partial_implementation; release proof)

### 146. Retired IA/terminology reference in PK00_PK41_PLATFORM_KERNEL_TRAIN

- Candidate ID: `AMB28-retired_ia_or_terminology_reference-88849434`
- Evidence type: `retired_ia_or_terminology_reference`
- Severity: `yellow`
- Recommended action: `Rewrite`
- Linear-ready: `True`
- Auto-resolved: `False`
- Reason: Active item contains retired IA, retired terminology, or unsafe language; rewrite or retire before reuse.
- Involved active paths:
  - `PK00_PK41_PLATFORM_KERNEL_TRAIN` — `docs/codex/batch-trains/PK00_PK41_PLATFORM_KERNEL_TRAIN.md` (partial_implementation; release proof)

### 147. Retired IA/terminology reference in TRAIN_08_CAPTURE_ATMOSPHERE_COMPOSER_FINAL_OBJECT

- Candidate ID: `AMB28-retired_ia_or_terminology_reference-88965637`
- Evidence type: `retired_ia_or_terminology_reference`
- Severity: `yellow`
- Recommended action: `Rewrite`
- Linear-ready: `True`
- Auto-resolved: `False`
- Reason: Active item contains retired IA, retired terminology, or unsafe language; rewrite or retire before reuse.
- Involved active paths:
  - `TRAIN_08_CAPTURE_ATMOSPHERE_COMPOSER_FINAL_OBJECT` — `prompts/trains/ios26-flagship/TRAIN_08_CAPTURE_ATMOSPHERE_COMPOSER_FINAL_OBJECT.md` (partial_implementation; source-only)

### 148. Retired IA/terminology reference in AQOS_SCRIPT_AND_TOOL_MAP

- Candidate ID: `AMB28-retired_ia_or_terminology_reference-89341282`
- Evidence type: `retired_ia_or_terminology_reference`
- Severity: `yellow`
- Recommended action: `Rewrite`
- Linear-ready: `True`
- Auto-resolved: `False`
- Reason: Active item contains retired IA, retired terminology, or unsafe language; rewrite or retire before reuse.
- Involved active paths:
  - `AQOS_SCRIPT_AND_TOOL_MAP` — `docs/codex/quality/AQOS_SCRIPT_AND_TOOL_MAP.md` (partial_implementation; release proof)

### 149. Retired IA/terminology reference in existing-code-champion-coverage

- Candidate ID: `AMB28-retired_ia_or_terminology_reference-89382656`
- Evidence type: `retired_ia_or_terminology_reference`
- Severity: `yellow`
- Recommended action: `Rewrite`
- Linear-ready: `True`
- Auto-resolved: `False`
- Reason: Active item contains retired IA, retired terminology, or unsafe language; rewrite or retire before reuse.
- Involved active paths:
  - `existing-code-champion-coverage` — `docs/codex/existing-code-champion-coverage.yml` (unknown; release proof)

### 150. Retired IA/terminology reference in GLOBAL_AUTONOMOUS_QUALITY_OVERLAY

- Candidate ID: `AMB28-retired_ia_or_terminology_reference-91229146`
- Evidence type: `retired_ia_or_terminology_reference`
- Severity: `yellow`
- Recommended action: `Rewrite`
- Linear-ready: `True`
- Auto-resolved: `False`
- Reason: Active item contains retired IA, retired terminology, or unsafe language; rewrite or retire before reuse.
- Involved active paths:
  - `GLOBAL_AUTONOMOUS_QUALITY_OVERLAY` — `docs/codex/GLOBAL_AUTONOMOUS_QUALITY_OVERLAY.md` (partial_implementation; release proof)

### 151. Retired IA/terminology reference in PX05_Plan_Life_Shape_Experience_Prompt

- Candidate ID: `AMB28-retired_ia_or_terminology_reference-9172620`
- Evidence type: `retired_ia_or_terminology_reference`
- Severity: `yellow`
- Recommended action: `Rewrite`
- Linear-ready: `True`
- Auto-resolved: `False`
- Reason: Active item contains retired IA, retired terminology, or unsafe language; rewrite or retire before reuse.
- Involved active paths:
  - `PX05_Plan_Life_Shape_Experience_Prompt` — `docs/codex/batches/PX05_Plan_Life_Shape_Experience_Prompt.md` (partial_implementation; release proof)

### 152. Retired IA/terminology reference in MOAT_RUNTIME_GOLDEN_SCENARIOS

- Candidate ID: `AMB28-retired_ia_or_terminology_reference-92225986`
- Evidence type: `retired_ia_or_terminology_reference`
- Severity: `yellow`
- Recommended action: `Rewrite`
- Linear-ready: `True`
- Auto-resolved: `False`
- Reason: Active item contains retired IA, retired terminology, or unsafe language; rewrite or retire before reuse.
- Involved active paths:
  - `MOAT_RUNTIME_GOLDEN_SCENARIOS` — `docs/codex/MOAT_RUNTIME_GOLDEN_SCENARIOS.md` (unknown; release proof)

### 153. Retired IA/terminology reference in FOUND_LIFE_LAYER_GATE_MATRIX

- Candidate ID: `AMB28-retired_ia_or_terminology_reference-92415539`
- Evidence type: `retired_ia_or_terminology_reference`
- Severity: `yellow`
- Recommended action: `Rewrite`
- Linear-ready: `True`
- Auto-resolved: `False`
- Reason: Active item contains retired IA, retired terminology, or unsafe language; rewrite or retire before reuse.
- Involved active paths:
  - `FOUND_LIFE_LAYER_GATE_MATRIX` — `docs/codex/FOUND_LIFE_LAYER_GATE_MATRIX.md` (partial_implementation; release proof)

### 154. Retired IA/terminology reference in AOS24_AmbitionsOS_UI_Integration_Prompt

- Candidate ID: `AMB28-retired_ia_or_terminology_reference-92559355`
- Evidence type: `retired_ia_or_terminology_reference`
- Severity: `yellow`
- Recommended action: `Rewrite`
- Linear-ready: `True`
- Auto-resolved: `False`
- Reason: Active item contains retired IA, retired terminology, or unsafe language; rewrite or retire before reuse.
- Involved active paths:
  - `AOS24_AmbitionsOS_UI_Integration_Prompt` — `docs/codex/batches/AOS24_AmbitionsOS_UI_Integration_Prompt.md` (partial_implementation; release proof)

### 155. Retired IA/terminology reference in DAV06_Goals_MissionControlLanes_Implementation_Prompt

- Candidate ID: `AMB28-retired_ia_or_terminology_reference-92635073`
- Evidence type: `retired_ia_or_terminology_reference`
- Severity: `yellow`
- Recommended action: `Rewrite`
- Linear-ready: `True`
- Auto-resolved: `False`
- Reason: Active item contains retired IA, retired terminology, or unsafe language; rewrite or retire before reuse.
- Involved active paths:
  - `DAV06_Goals_MissionControlLanes_Implementation_Prompt` — `docs/codex/batches/DAV06_Goals_MissionControlLanes_Implementation_Prompt.md` (partial_implementation; release proof)

### 156. Retired IA/terminology reference in SA_NEXT_ELIGIBLE_BATCH_PROMPT

- Candidate ID: `AMB28-retired_ia_or_terminology_reference-93108830`
- Evidence type: `retired_ia_or_terminology_reference`
- Severity: `yellow`
- Recommended action: `Rewrite`
- Linear-ready: `True`
- Auto-resolved: `False`
- Reason: Active item contains retired IA, retired terminology, or unsafe language; rewrite or retire before reuse.
- Involved active paths:
  - `SA_NEXT_ELIGIBLE_BATCH_PROMPT` — `docs/codex/batches/SA_NEXT_ELIGIBLE_BATCH_PROMPT.md` (partial_implementation; release proof)

### 157. Retired IA/terminology reference in AOS08_Alternate_Path_Kernel_Path_Portfolio_Prompt

- Candidate ID: `AMB28-retired_ia_or_terminology_reference-93438815`
- Evidence type: `retired_ia_or_terminology_reference`
- Severity: `yellow`
- Recommended action: `Rewrite`
- Linear-ready: `True`
- Auto-resolved: `False`
- Reason: Active item contains retired IA, retired terminology, or unsafe language; rewrite or retire before reuse.
- Involved active paths:
  - `AOS08_Alternate_Path_Kernel_Path_Portfolio_Prompt` — `docs/codex/batches/AOS08_Alternate_Path_Kernel_Path_Portfolio_Prompt.md` (partial_implementation; release proof)

### 158. Retired IA/terminology reference in FAANG_FRONTEND_IMPLEMENTATION_OPERATING_SYSTEM

- Candidate ID: `AMB28-retired_ia_or_terminology_reference-93949665`
- Evidence type: `retired_ia_or_terminology_reference`
- Severity: `yellow`
- Recommended action: `Rewrite`
- Linear-ready: `True`
- Auto-resolved: `False`
- Reason: Active item contains retired IA, retired terminology, or unsafe language; rewrite or retire before reuse.
- Involved active paths:
  - `FAANG_FRONTEND_IMPLEMENTATION_OPERATING_SYSTEM` — `docs/codex/FAANG_FRONTEND_IMPLEMENTATION_OPERATING_SYSTEM.md` (partial_implementation; release proof)

### 159. Retired IA/terminology reference in AMBITIONS_SIGNATURE_LANGUAGE_SYSTEM

- Candidate ID: `AMB28-retired_ia_or_terminology_reference-94115032`
- Evidence type: `retired_ia_or_terminology_reference`
- Severity: `yellow`
- Recommended action: `Rewrite`
- Linear-ready: `True`
- Auto-resolved: `False`
- Reason: Active item contains retired IA, retired terminology, or unsafe language; rewrite or retire before reuse.
- Involved active paths:
  - `AMBITIONS_SIGNATURE_LANGUAGE_SYSTEM` — `docs/codex/AMBITIONS_SIGNATURE_LANGUAGE_SYSTEM.md` (partial_implementation; release proof)

### 160. Retired IA/terminology reference in AOS27_AmbitionsOS_App_Store_Claim_Truth_Prompt

- Candidate ID: `AMB28-retired_ia_or_terminology_reference-94290133`
- Evidence type: `retired_ia_or_terminology_reference`
- Severity: `yellow`
- Recommended action: `Rewrite`
- Linear-ready: `True`
- Auto-resolved: `False`
- Reason: Active item contains retired IA, retired terminology, or unsafe language; rewrite or retire before reuse.
- Involved active paths:
  - `AOS27_AmbitionsOS_App_Store_Claim_Truth_Prompt` — `docs/codex/batches/AOS27_AmbitionsOS_App_Store_Claim_Truth_Prompt.md` (partial_implementation; release proof)

### 161. Retired IA/terminology reference in AOS05_Starting_Position_Kernel_Prompt

- Candidate ID: `AMB28-retired_ia_or_terminology_reference-94791644`
- Evidence type: `retired_ia_or_terminology_reference`
- Severity: `yellow`
- Recommended action: `Rewrite`
- Linear-ready: `True`
- Auto-resolved: `False`
- Reason: Active item contains retired IA, retired terminology, or unsafe language; rewrite or retire before reuse.
- Involved active paths:
  - `AOS05_Starting_Position_Kernel_Prompt` — `docs/codex/batches/AOS05_Starting_Position_Kernel_Prompt.md` (partial_implementation; release proof)

### 162. Retired IA/terminology reference in PD18_Product_Depth_Handoff_And_Next_Lane_Readiness_Prompt

- Candidate ID: `AMB28-retired_ia_or_terminology_reference-9568640`
- Evidence type: `retired_ia_or_terminology_reference`
- Severity: `yellow`
- Recommended action: `Rewrite`
- Linear-ready: `True`
- Auto-resolved: `False`
- Reason: Active item contains retired IA, retired terminology, or unsafe language; rewrite or retire before reuse.
- Involved active paths:
  - `PD18_Product_Depth_Handoff_And_Next_Lane_Readiness_Prompt` — `docs/codex/batches/PD18_Product_Depth_Handoff_And_Next_Lane_Readiness_Prompt.md` (partial_implementation; release proof)

### 163. Retired IA/terminology reference in AMB-REPO-GREEN-FLAGSHIP-RESET-MASTER-01-T07-UI-PRIMITIVE-ORG

- Candidate ID: `AMB28-retired_ia_or_terminology_reference-95735940`
- Evidence type: `retired_ia_or_terminology_reference`
- Severity: `yellow`
- Recommended action: `Rewrite`
- Linear-ready: `True`
- Auto-resolved: `False`
- Reason: Active item contains retired IA, retired terminology, or unsafe language; rewrite or retire before reuse.
- Involved active paths:
  - `AMB-REPO-GREEN-FLAGSHIP-RESET-MASTER-01-T07-UI-PRIMITIVE-ORG` — `prompts/batches/AMB-REPO-GREEN-FLAGSHIP-RESET-MASTER-01-T07-UI-PRIMITIVE-ORG.md` (partial_implementation; release proof)

### 164. Retired IA/terminology reference in FVQ02_TOP_LEVEL_SURFACE_VISUAL_SWEEP

- Candidate ID: `AMB28-retired_ia_or_terminology_reference-96864649`
- Evidence type: `retired_ia_or_terminology_reference`
- Severity: `yellow`
- Recommended action: `Rewrite`
- Linear-ready: `True`
- Auto-resolved: `False`
- Reason: Active item contains retired IA, retired terminology, or unsafe language; rewrite or retire before reuse.
- Involved active paths:
  - `FVQ02_TOP_LEVEL_SURFACE_VISUAL_SWEEP` — `docs/codex/visual-quality/FVQ02_TOP_LEVEL_SURFACE_VISUAL_SWEEP.md` (unknown; release proof)

### 165. Retired IA/terminology reference in MOAT-COMPLETE-AUTONOMOUS-01

- Candidate ID: `AMB28-retired_ia_or_terminology_reference-97625721`
- Evidence type: `retired_ia_or_terminology_reference`
- Severity: `yellow`
- Recommended action: `Rewrite`
- Linear-ready: `True`
- Auto-resolved: `False`
- Reason: Active item contains retired IA, retired terminology, or unsafe language; rewrite or retire before reuse.
- Involved active paths:
  - `MOAT-COMPLETE-AUTONOMOUS-01` — `prompts/batches/MOAT-COMPLETE-AUTONOMOUS-01.md` (partial_implementation; release proof)

### 166. Retired IA/terminology reference in SOURCE_ATLAS_UI_OBJECT_LANGUAGE

- Candidate ID: `AMB28-retired_ia_or_terminology_reference-97667743`
- Evidence type: `retired_ia_or_terminology_reference`
- Severity: `yellow`
- Recommended action: `Rewrite`
- Linear-ready: `True`
- Auto-resolved: `False`
- Reason: Active item contains retired IA, retired terminology, or unsafe language; rewrite or retire before reuse.
- Involved active paths:
  - `SOURCE_ATLAS_UI_OBJECT_LANGUAGE` — `docs/codex/SOURCE_ATLAS_UI_OBJECT_LANGUAGE.md` (partial_implementation; release proof)

### 167. Retired IA/terminology reference in AFI03_Flagship_Object_Silhouettes

- Candidate ID: `AMB28-retired_ia_or_terminology_reference-97708000`
- Evidence type: `retired_ia_or_terminology_reference`
- Severity: `yellow`
- Recommended action: `Rewrite`
- Linear-ready: `True`
- Auto-resolved: `False`
- Reason: Active item contains retired IA, retired terminology, or unsafe language; rewrite or retire before reuse.
- Involved active paths:
  - `AFI03_Flagship_Object_Silhouettes` — `docs/codex/batches/AFI03_Flagship_Object_Silhouettes.md` (partial_implementation; release proof)

### 168. Retired IA/terminology reference in TODAY-REALITY-MERIDIAN-VISUAL-01

- Candidate ID: `AMB28-retired_ia_or_terminology_reference-97827044`
- Evidence type: `retired_ia_or_terminology_reference`
- Severity: `yellow`
- Recommended action: `Rewrite`
- Linear-ready: `True`
- Auto-resolved: `False`
- Reason: Active item contains retired IA, retired terminology, or unsafe language; rewrite or retire before reuse.
- Involved active paths:
  - `TODAY-REALITY-MERIDIAN-VISUAL-01` — `prompts/batches/TODAY-REALITY-MERIDIAN-VISUAL-01.md` (partial_implementation; release proof)

### 169. Retired IA/terminology reference in ambitions-hybrid-runner

- Candidate ID: `AMB28-retired_ia_or_terminology_reference-97855985`
- Evidence type: `retired_ia_or_terminology_reference`
- Severity: `yellow`
- Recommended action: `Rewrite`
- Linear-ready: `True`
- Auto-resolved: `False`
- Reason: Active item contains retired IA, retired terminology, or unsafe language; rewrite or retire before reuse.
- Involved active paths:
  - `ambitions-hybrid-runner` — `docs/codex/ambitions-hybrid-runner.md` (partial_implementation; release proof)

### 170. Retired IA/terminology reference in PD17_Cross_Surface_Proof_And_Review_Integration_Prompt

- Candidate ID: `AMB28-retired_ia_or_terminology_reference-98202852`
- Evidence type: `retired_ia_or_terminology_reference`
- Severity: `yellow`
- Recommended action: `Rewrite`
- Linear-ready: `True`
- Auto-resolved: `False`
- Reason: Active item contains retired IA, retired terminology, or unsafe language; rewrite or retire before reuse.
- Involved active paths:
  - `PD17_Cross_Surface_Proof_And_Review_Integration_Prompt` — `docs/codex/batches/PD17_Cross_Surface_Proof_And_Review_Integration_Prompt.md` (partial_implementation; release proof)

### 171. Retired IA/terminology reference in IOS26_ANTI_CARD_VALIDATOR_SPEC

- Candidate ID: `AMB28-retired_ia_or_terminology_reference-98417959`
- Evidence type: `retired_ia_or_terminology_reference`
- Severity: `yellow`
- Recommended action: `Rewrite`
- Linear-ready: `True`
- Auto-resolved: `False`
- Reason: Active item contains retired IA, retired terminology, or unsafe language; rewrite or retire before reuse.
- Involved active paths:
  - `IOS26_ANTI_CARD_VALIDATOR_SPEC` — `docs/codex/frontend/IOS26_ANTI_CARD_VALIDATOR_SPEC.md` (partial_implementation; release proof)

### 172. Retired IA/terminology reference in POST99-UI-SUITE-REVIEW-IMPLEMENTATION-00

- Candidate ID: `AMB28-retired_ia_or_terminology_reference-98509272`
- Evidence type: `retired_ia_or_terminology_reference`
- Severity: `yellow`
- Recommended action: `Rewrite`
- Linear-ready: `True`
- Auto-resolved: `False`
- Reason: Active item contains retired IA, retired terminology, or unsafe language; rewrite or retire before reuse.
- Involved active paths:
  - `POST99-UI-SUITE-REVIEW-IMPLEMENTATION-00` — `prompts/batches/POST99-UI-SUITE-REVIEW-IMPLEMENTATION-00.md` (partial_implementation; release proof)

### 173. Retired IA/terminology reference in FVQ01_RENDERED_VISUAL_FRESHNESS_AND_FLAGSHIP_PROMPT

- Candidate ID: `AMB28-retired_ia_or_terminology_reference-9888299`
- Evidence type: `retired_ia_or_terminology_reference`
- Severity: `yellow`
- Recommended action: `Rewrite`
- Linear-ready: `True`
- Auto-resolved: `False`
- Reason: Active item contains retired IA, retired terminology, or unsafe language; rewrite or retire before reuse.
- Involved active paths:
  - `FVQ01_RENDERED_VISUAL_FRESHNESS_AND_FLAGSHIP_PROMPT` — `docs/codex/batches/FVQ01_RENDERED_VISUAL_FRESHNESS_AND_FLAGSHIP_PROMPT.md` (partial_implementation; release proof)

### 174. Retired IA/terminology reference in AQOS01_AQOS30_AUTONOMOUS_QUALITY_TRAIN

- Candidate ID: `AMB28-retired_ia_or_terminology_reference-9901355`
- Evidence type: `retired_ia_or_terminology_reference`
- Severity: `yellow`
- Recommended action: `Rewrite`
- Linear-ready: `True`
- Auto-resolved: `False`
- Reason: Active item contains retired IA, retired terminology, or unsafe language; rewrite or retire before reuse.
- Involved active paths:
  - `AQOS01_AQOS30_AUTONOMOUS_QUALITY_TRAIN` — `docs/codex/quality/AQOS01_AQOS30_AUTONOMOUS_QUALITY_TRAIN.md` (unknown; release proof)

### 175. Retired IA/terminology reference in FE-02-DESIGN-LANGUAGE

- Candidate ID: `AMB28-retired_ia_or_terminology_reference-99578734`
- Evidence type: `retired_ia_or_terminology_reference`
- Severity: `yellow`
- Recommended action: `Rewrite`
- Linear-ready: `True`
- Auto-resolved: `False`
- Reason: Active item contains retired IA, retired terminology, or unsafe language; rewrite or retire before reuse.
- Involved active paths:
  - `FE-02-DESIGN-LANGUAGE` — `prompts/batches/amb-fe-be/FE-02-DESIGN-LANGUAGE.md` (partial_implementation; release proof)

### 176. Retired IA/terminology reference in PD11_Grow_Into_Goal_Flow_Prompt

- Candidate ID: `AMB28-retired_ia_or_terminology_reference-99853425`
- Evidence type: `retired_ia_or_terminology_reference`
- Severity: `yellow`
- Recommended action: `Rewrite`
- Linear-ready: `True`
- Auto-resolved: `False`
- Reason: Active item contains retired IA, retired terminology, or unsafe language; rewrite or retire before reuse.
- Involved active paths:
  - `PD11_Grow_Into_Goal_Flow_Prompt` — `docs/codex/batches/PD11_Grow_Into_Goal_Flow_Prompt.md` (partial_implementation; release proof)

### 177. Missing source-of-truth references in IOS26_DEPENDENCY_GRAPH

- Candidate ID: `AMB28-missing_source_of_truth_reference-18769821`
- Evidence type: `missing_source_of_truth_reference`
- Severity: `yellow`
- Recommended action: `Rewrite`
- Linear-ready: `True`
- Auto-resolved: `False`
- Reason: Active item lacks required source-of-truth references; rewrite before implementation use.
- Involved active paths:
  - `IOS26_DEPENDENCY_GRAPH` — `docs/codex/ios26/IOS26_DEPENDENCY_GRAPH.yml` (partial_implementation; source-only)

### 178. Missing source-of-truth references in IOS26_BATCH_MATRIX

- Candidate ID: `AMB28-missing_source_of_truth_reference-20700079`
- Evidence type: `missing_source_of_truth_reference`
- Severity: `yellow`
- Recommended action: `Rewrite`
- Linear-ready: `True`
- Auto-resolved: `False`
- Reason: Active item lacks required source-of-truth references; rewrite before implementation use.
- Involved active paths:
  - `IOS26_BATCH_MATRIX` — `docs/codex/ios26/IOS26_BATCH_MATRIX.yml` (partial_implementation; release proof)

### 179. Missing source-of-truth references in GLOBAL_QUEUE_CANONICAL_ORDER

- Candidate ID: `AMB28-missing_source_of_truth_reference-21129516`
- Evidence type: `missing_source_of_truth_reference`
- Severity: `yellow`
- Recommended action: `Rewrite`
- Linear-ready: `True`
- Auto-resolved: `False`
- Reason: Active item lacks required source-of-truth references; rewrite before implementation use.
- Involved active paths:
  - `GLOBAL_QUEUE_CANONICAL_ORDER` — `docs/codex/GLOBAL_QUEUE_CANONICAL_ORDER.json` (partial_implementation; release proof)

### 180. Missing source-of-truth references in TRAIN_04L_OBJECT_FRONTEND_LIVING_CHROME_FOUNDATION

- Candidate ID: `AMB28-missing_source_of_truth_reference-4656906`
- Evidence type: `missing_source_of_truth_reference`
- Severity: `yellow`
- Recommended action: `Rewrite`
- Linear-ready: `True`
- Auto-resolved: `False`
- Reason: Active item lacks required source-of-truth references; rewrite before implementation use.
- Involved active paths:
  - `TRAIN_04L_OBJECT_FRONTEND_LIVING_CHROME_FOUNDATION` — `prompts/trains/ios26-flagship/TRAIN_04L_OBJECT_FRONTEND_LIVING_CHROME_FOUNDATION.md` (partial_implementation; release proof)

### 181. Missing source-of-truth references in MOAT_RUNTIME_BATCH_OVERLAY

- Candidate ID: `AMB28-missing_source_of_truth_reference-5980797`
- Evidence type: `missing_source_of_truth_reference`
- Severity: `yellow`
- Recommended action: `Rewrite`
- Linear-ready: `True`
- Auto-resolved: `False`
- Reason: Active item lacks required source-of-truth references; rewrite before implementation use.
- Involved active paths:
  - `MOAT_RUNTIME_BATCH_OVERLAY` — `docs/codex/MOAT_RUNTIME_BATCH_OVERLAY.json` (partial_implementation; release proof)

### 182. Missing source-of-truth references in existing-code-champion-coverage

- Candidate ID: `AMB28-missing_source_of_truth_reference-62686723`
- Evidence type: `missing_source_of_truth_reference`
- Severity: `yellow`
- Recommended action: `Rewrite`
- Linear-ready: `True`
- Auto-resolved: `False`
- Reason: Active item lacks required source-of-truth references; rewrite before implementation use.
- Involved active paths:
  - `existing-code-champion-coverage` — `docs/codex/existing-code-champion-coverage.yml` (unknown; release proof)

### 183. Missing source-of-truth references in TRAIN_04L

- Candidate ID: `AMB28-missing_source_of_truth_reference-64063414`
- Evidence type: `missing_source_of_truth_reference`
- Severity: `yellow`
- Recommended action: `Rewrite`
- Linear-ready: `True`
- Auto-resolved: `False`
- Reason: Active item lacks required source-of-truth references; rewrite before implementation use.
- Involved active paths:
  - `TRAIN_04L` — `docs/codex/CHAMPION_MERGE_TRAIN_MANIFEST.yml` (partial_implementation; source-only)

### 184. Missing source-of-truth references in concept-lock-registry

- Candidate ID: `AMB28-missing_source_of_truth_reference-64164611`
- Evidence type: `missing_source_of_truth_reference`
- Severity: `yellow`
- Recommended action: `Rewrite`
- Linear-ready: `True`
- Auto-resolved: `False`
- Reason: Active item lacks required source-of-truth references; rewrite before implementation use.
- Involved active paths:
  - `concept-lock-registry` — `docs/codex/concept-lock-registry.yml` (partial_implementation; tests)

### 185. Missing source-of-truth references in AMB_GLOBAL_REMAINING_TRAIN_BLUEPRINT

- Candidate ID: `AMB28-missing_source_of_truth_reference-65783352`
- Evidence type: `missing_source_of_truth_reference`
- Severity: `yellow`
- Recommended action: `Rewrite`
- Linear-ready: `True`
- Auto-resolved: `False`
- Reason: Active item lacks required source-of-truth references; rewrite before implementation use.
- Involved active paths:
  - `AMB_GLOBAL_REMAINING_TRAIN_BLUEPRINT` — `docs/codex/AMB_GLOBAL_REMAINING_TRAIN_BLUEPRINT.json` (unknown; tests)

### 186. Missing source-of-truth references in HISTORICAL_BASELINE_GLOBAL_TRAIN_MANIFEST

- Candidate ID: `AMB28-missing_source_of_truth_reference-67281265`
- Evidence type: `missing_source_of_truth_reference`
- Severity: `yellow`
- Recommended action: `Rewrite`
- Linear-ready: `True`
- Auto-resolved: `False`
- Reason: Active item lacks required source-of-truth references; rewrite before implementation use.
- Involved active paths:
  - `HISTORICAL_BASELINE_GLOBAL_TRAIN_MANIFEST` — `docs/codex/HISTORICAL_BASELINE_GLOBAL_TRAIN_MANIFEST.json` (unknown; release proof)

### 187. Missing source-of-truth references in IOS26-FLAGSHIP

- Candidate ID: `AMB28-missing_source_of_truth_reference-68185332`
- Evidence type: `missing_source_of_truth_reference`
- Severity: `yellow`
- Recommended action: `Rewrite`
- Linear-ready: `True`
- Auto-resolved: `False`
- Reason: Active item lacks required source-of-truth references; rewrite before implementation use.
- Involved active paths:
  - `IOS26-FLAGSHIP` — `docs/codex/IOS26_FLAGSHIP_EXECUTION_STATE.yml` (partial_implementation; source-only)

### 188. Missing source-of-truth references in AMB_REMAINING_BATCH_REFERENCE

- Candidate ID: `AMB28-missing_source_of_truth_reference-72652806`
- Evidence type: `missing_source_of_truth_reference`
- Severity: `yellow`
- Recommended action: `Rewrite`
- Linear-ready: `True`
- Auto-resolved: `False`
- Reason: Active item lacks required source-of-truth references; rewrite before implementation use.
- Involved active paths:
  - `AMB_REMAINING_BATCH_REFERENCE` — `docs/codex/AMB_REMAINING_BATCH_REFERENCE.json` (partial_implementation; release proof)

### 189. Missing source-of-truth references in SPEED_TRAIN_LANE_POLICY

- Candidate ID: `AMB28-missing_source_of_truth_reference-75330985`
- Evidence type: `missing_source_of_truth_reference`
- Severity: `yellow`
- Recommended action: `Rewrite`
- Linear-ready: `True`
- Auto-resolved: `False`
- Reason: Active item lacks required source-of-truth references; rewrite before implementation use.
- Involved active paths:
  - `SPEED_TRAIN_LANE_POLICY` — `docs/codex/SPEED_TRAIN_LANE_POLICY.json` (unknown; release proof)

### 190. Missing source-of-truth references in parallel-guard-concept-registry

- Candidate ID: `AMB28-missing_source_of_truth_reference-77407445`
- Evidence type: `missing_source_of_truth_reference`
- Severity: `yellow`
- Recommended action: `Rewrite`
- Linear-ready: `True`
- Auto-resolved: `False`
- Reason: Active item lacks required source-of-truth references; rewrite before implementation use.
- Involved active paths:
  - `parallel-guard-concept-registry` — `docs/codex/parallel-guard-concept-registry.yml` (partial_implementation; source-only)

### 191. Missing source-of-truth references in IOS26_PROMPT_FREEZE_HASHES

- Candidate ID: `AMB28-missing_source_of_truth_reference-86902937`
- Evidence type: `missing_source_of_truth_reference`
- Severity: `yellow`
- Recommended action: `Rewrite`
- Linear-ready: `True`
- Auto-resolved: `False`
- Reason: Active item lacks required source-of-truth references; rewrite before implementation use.
- Involved active paths:
  - `IOS26_PROMPT_FREEZE_HASHES` — `docs/codex/ios26/IOS26_PROMPT_FREEZE_HASHES.json` (partial_implementation; release proof)

### 192. Missing source-of-truth references in CHAMPION_MERGE_AND_INTELLIGENCE_CONSOLIDATION_SUPPORT

- Candidate ID: `AMB28-missing_source_of_truth_reference-89477271`
- Evidence type: `missing_source_of_truth_reference`
- Severity: `yellow`
- Recommended action: `Rewrite`
- Linear-ready: `True`
- Auto-resolved: `False`
- Reason: Active item lacks required source-of-truth references; rewrite before implementation use.
- Involved active paths:
  - `CHAMPION_MERGE_AND_INTELLIGENCE_CONSOLIDATION_SUPPORT` — `prompts/trains/ios26-flagship/support/CHAMPION_MERGE_AND_INTELLIGENCE_CONSOLIDATION_SUPPORT.md` (partial_implementation; release proof)

### 193. Missing source-of-truth references in ldi06-pack-registry-fixture

- Candidate ID: `AMB28-missing_source_of_truth_reference-90337606`
- Evidence type: `missing_source_of_truth_reference`
- Severity: `yellow`
- Recommended action: `Rewrite`
- Linear-ready: `True`
- Auto-resolved: `False`
- Reason: Active item lacks required source-of-truth references; rewrite before implementation use.
- Involved active paths:
  - `ldi06-pack-registry-fixture` — `docs/codex/fixtures/ldi/ldi06-pack-registry-fixture.json` (partial_implementation; source-only)

### 194. Source-only or missing-proof implementation state: TRAIN_04L

- Candidate ID: `AMB28-source_only_implementation_missing_proof-14472031`
- Evidence type: `source_only_implementation_missing_proof`
- Severity: `yellow`
- Recommended action: `Finish proof`
- Linear-ready: `True`
- Auto-resolved: `False`
- Reason: Active item is partial/source-only/missing-proof; finish proof before treating as complete.
- Involved active paths:
  - `TRAIN_04L` — `docs/codex/CHAMPION_MERGE_TRAIN_MANIFEST.yml` (partial_implementation; source-only)

### 195. Source-only or missing-proof implementation state: TRAIN_04_GOAL_INTENT_TO_DAY_COMPILER

- Candidate ID: `AMB28-source_only_implementation_missing_proof-26699805`
- Evidence type: `source_only_implementation_missing_proof`
- Severity: `yellow`
- Recommended action: `Finish proof`
- Linear-ready: `True`
- Auto-resolved: `False`
- Reason: Active item is partial/source-only/missing-proof; finish proof before treating as complete.
- Involved active paths:
  - `TRAIN_04_GOAL_INTENT_TO_DAY_COMPILER` — `prompts/trains/ios26-flagship/TRAIN_04_GOAL_INTENT_TO_DAY_COMPILER.md` (partial_implementation; source-only)

### 196. Source-only or missing-proof implementation state: IOS26-FLAGSHIP

- Candidate ID: `AMB28-source_only_implementation_missing_proof-34483658`
- Evidence type: `source_only_implementation_missing_proof`
- Severity: `yellow`
- Recommended action: `Finish proof`
- Linear-ready: `True`
- Auto-resolved: `False`
- Reason: Active item is partial/source-only/missing-proof; finish proof before treating as complete.
- Involved active paths:
  - `IOS26-FLAGSHIP` — `docs/codex/IOS26_FLAGSHIP_EXECUTION_STATE.yml` (partial_implementation; source-only)

### 197. Source-only or missing-proof implementation state: TRAIN_05_TODAY_REALITY_MERIDIAN_FINAL_OBJECT

- Candidate ID: `AMB28-source_only_implementation_missing_proof-34617096`
- Evidence type: `source_only_implementation_missing_proof`
- Severity: `yellow`
- Recommended action: `Finish proof`
- Linear-ready: `True`
- Auto-resolved: `False`
- Reason: Active item is partial/source-only/missing-proof; finish proof before treating as complete.
- Involved active paths:
  - `TRAIN_05_TODAY_REALITY_MERIDIAN_FINAL_OBJECT` — `prompts/trains/ios26-flagship/TRAIN_05_TODAY_REALITY_MERIDIAN_FINAL_OBJECT.md` (partial_implementation; source-only)

### 198. Source-only or missing-proof implementation state: TRAIN_13_ACCESSIBILITY_EQUIVALENCE

- Candidate ID: `AMB28-source_only_implementation_missing_proof-35997276`
- Evidence type: `source_only_implementation_missing_proof`
- Severity: `yellow`
- Recommended action: `Finish proof`
- Linear-ready: `True`
- Auto-resolved: `False`
- Reason: Active item is partial/source-only/missing-proof; finish proof before treating as complete.
- Involved active paths:
  - `TRAIN_13_ACCESSIBILITY_EQUIVALENCE` — `prompts/trains/ios26-flagship/TRAIN_13_ACCESSIBILITY_EQUIVALENCE.md` (partial_implementation; source-only)

### 199. Source-only or missing-proof implementation state: TRAIN_10_PROOF_RECEIPTS_CLOSURE_RECOVERY_REPLAY

- Candidate ID: `AMB28-source_only_implementation_missing_proof-39398065`
- Evidence type: `source_only_implementation_missing_proof`
- Severity: `yellow`
- Recommended action: `Finish proof`
- Linear-ready: `True`
- Auto-resolved: `False`
- Reason: Active item is partial/source-only/missing-proof; finish proof before treating as complete.
- Involved active paths:
  - `TRAIN_10_PROOF_RECEIPTS_CLOSURE_RECOVERY_REPLAY` — `prompts/trains/ios26-flagship/TRAIN_10_PROOF_RECEIPTS_CLOSURE_RECOVERY_REPLAY.md` (partial_implementation; source-only)

### 200. Source-only or missing-proof implementation state: TRAIN_01_IOS26_MINIMUM_MIGRATION_FOUNDATION

- Candidate ID: `AMB28-source_only_implementation_missing_proof-46273463`
- Evidence type: `source_only_implementation_missing_proof`
- Severity: `yellow`
- Recommended action: `Finish proof`
- Linear-ready: `True`
- Auto-resolved: `False`
- Reason: Active item is partial/source-only/missing-proof; finish proof before treating as complete.
- Involved active paths:
  - `TRAIN_01_IOS26_MINIMUM_MIGRATION_FOUNDATION` — `prompts/trains/ios26-flagship/TRAIN_01_IOS26_MINIMUM_MIGRATION_FOUNDATION.md` (partial_implementation; source-only)

### 201. Source-only or missing-proof implementation state: TRAIN_06_TIME_LIFESHAPE_FIELD_FINAL_OBJECT

- Candidate ID: `AMB28-source_only_implementation_missing_proof-47385195`
- Evidence type: `source_only_implementation_missing_proof`
- Severity: `yellow`
- Recommended action: `Finish proof`
- Linear-ready: `True`
- Auto-resolved: `False`
- Reason: Active item is partial/source-only/missing-proof; finish proof before treating as complete.
- Involved active paths:
  - `TRAIN_06_TIME_LIFESHAPE_FIELD_FINAL_OBJECT` — `prompts/trains/ios26-flagship/TRAIN_06_TIME_LIFESHAPE_FIELD_FINAL_OBJECT.md` (partial_implementation; source-only)

### 202. Source-only or missing-proof implementation state: ldi06-pack-registry-fixture

- Candidate ID: `AMB28-source_only_implementation_missing_proof-49946222`
- Evidence type: `source_only_implementation_missing_proof`
- Severity: `yellow`
- Recommended action: `Finish proof`
- Linear-ready: `True`
- Auto-resolved: `False`
- Reason: Active item is partial/source-only/missing-proof; finish proof before treating as complete.
- Involved active paths:
  - `ldi06-pack-registry-fixture` — `docs/codex/fixtures/ldi/ldi06-pack-registry-fixture.json` (partial_implementation; source-only)

### 203. Source-only or missing-proof implementation state: TRAIN_12_EXTERNAL_SURFACES_WIDGETS_INTENTS_SHARE

- Candidate ID: `AMB28-source_only_implementation_missing_proof-61062316`
- Evidence type: `source_only_implementation_missing_proof`
- Severity: `yellow`
- Recommended action: `Finish proof`
- Linear-ready: `True`
- Auto-resolved: `False`
- Reason: Active item is partial/source-only/missing-proof; finish proof before treating as complete.
- Involved active paths:
  - `TRAIN_12_EXTERNAL_SURFACES_WIDGETS_INTENTS_SHARE` — `prompts/trains/ios26-flagship/TRAIN_12_EXTERNAL_SURFACES_WIDGETS_INTENTS_SHARE.md` (partial_implementation; source-only)

### 204. Source-only or missing-proof implementation state: TRAIN_14_PERFORMANCE_INSTRUMENTS_POWER

- Candidate ID: `AMB28-source_only_implementation_missing_proof-66118124`
- Evidence type: `source_only_implementation_missing_proof`
- Severity: `yellow`
- Recommended action: `Finish proof`
- Linear-ready: `True`
- Auto-resolved: `False`
- Reason: Active item is partial/source-only/missing-proof; finish proof before treating as complete.
- Involved active paths:
  - `TRAIN_14_PERFORMANCE_INSTRUMENTS_POWER` — `prompts/trains/ios26-flagship/TRAIN_14_PERFORMANCE_INSTRUMENTS_POWER.md` (partial_implementation; source-only)

### 205. Source-only or missing-proof implementation state: TRAIN_11_PERSISTENCE_MIGRATION_EXPORT_DELETE_APP_GROUP

- Candidate ID: `AMB28-source_only_implementation_missing_proof-68936962`
- Evidence type: `source_only_implementation_missing_proof`
- Severity: `yellow`
- Recommended action: `Finish proof`
- Linear-ready: `True`
- Auto-resolved: `False`
- Reason: Active item is partial/source-only/missing-proof; finish proof before treating as complete.
- Involved active paths:
  - `TRAIN_11_PERSISTENCE_MIGRATION_EXPORT_DELETE_APP_GROUP` — `prompts/trains/ios26-flagship/TRAIN_11_PERSISTENCE_MIGRATION_EXPORT_DELETE_APP_GROUP.md` (partial_implementation; source-only)

### 206. Source-only or missing-proof implementation state: TRAIN_07_GOALS_CONSTELLATION_ATLAS_FINAL_OBJECT

- Candidate ID: `AMB28-source_only_implementation_missing_proof-81099119`
- Evidence type: `source_only_implementation_missing_proof`
- Severity: `yellow`
- Recommended action: `Finish proof`
- Linear-ready: `True`
- Auto-resolved: `False`
- Reason: Active item is partial/source-only/missing-proof; finish proof before treating as complete.
- Involved active paths:
  - `TRAIN_07_GOALS_CONSTELLATION_ATLAS_FINAL_OBJECT` — `prompts/trains/ios26-flagship/TRAIN_07_GOALS_CONSTELLATION_ATLAS_FINAL_OBJECT.md` (partial_implementation; source-only)

### 207. Source-only or missing-proof implementation state: TRAIN_15_REPO_HYGIENE_NAMING_DRIFT_HISTORICAL_QUARANTINE

- Candidate ID: `AMB28-source_only_implementation_missing_proof-85494842`
- Evidence type: `source_only_implementation_missing_proof`
- Severity: `yellow`
- Recommended action: `Finish proof`
- Linear-ready: `True`
- Auto-resolved: `False`
- Reason: Active item is partial/source-only/missing-proof; finish proof before treating as complete.
- Involved active paths:
  - `TRAIN_15_REPO_HYGIENE_NAMING_DRIFT_HISTORICAL_QUARANTINE` — `prompts/trains/ios26-flagship/TRAIN_15_REPO_HYGIENE_NAMING_DRIFT_HISTORICAL_QUARANTINE.md` (partial_implementation; source-only)

### 208. Source-only or missing-proof implementation state: parallel-guard-concept-registry

- Candidate ID: `AMB28-source_only_implementation_missing_proof-87401422`
- Evidence type: `source_only_implementation_missing_proof`
- Severity: `yellow`
- Recommended action: `Finish proof`
- Linear-ready: `True`
- Auto-resolved: `False`
- Reason: Active item is partial/source-only/missing-proof; finish proof before treating as complete.
- Involved active paths:
  - `parallel-guard-concept-registry` — `docs/codex/parallel-guard-concept-registry.yml` (partial_implementation; source-only)

### 209. Source-only or missing-proof implementation state: TRAIN_03_PRIVATE_LIFE_RUNTIME_PROOF_HARNESS

- Candidate ID: `AMB28-source_only_implementation_missing_proof-88957111`
- Evidence type: `source_only_implementation_missing_proof`
- Severity: `yellow`
- Recommended action: `Finish proof`
- Linear-ready: `True`
- Auto-resolved: `False`
- Reason: Active item is partial/source-only/missing-proof; finish proof before treating as complete.
- Involved active paths:
  - `TRAIN_03_PRIVATE_LIFE_RUNTIME_PROOF_HARNESS` — `prompts/trains/ios26-flagship/TRAIN_03_PRIVATE_LIFE_RUNTIME_PROOF_HARNESS.md` (partial_implementation; source-only)

### 210. Source-only or missing-proof implementation state: TRAIN_08_CAPTURE_ATMOSPHERE_COMPOSER_FINAL_OBJECT

- Candidate ID: `AMB28-source_only_implementation_missing_proof-90717781`
- Evidence type: `source_only_implementation_missing_proof`
- Severity: `yellow`
- Recommended action: `Finish proof`
- Linear-ready: `True`
- Auto-resolved: `False`
- Reason: Active item is partial/source-only/missing-proof; finish proof before treating as complete.
- Involved active paths:
  - `TRAIN_08_CAPTURE_ATMOSPHERE_COMPOSER_FINAL_OBJECT` — `prompts/trains/ios26-flagship/TRAIN_08_CAPTURE_ATMOSPHERE_COMPOSER_FINAL_OBJECT.md` (partial_implementation; source-only)

### 211. Source-only or missing-proof implementation state: TRAIN_09_YOU_USER_SYSTEM_PROFILE

- Candidate ID: `AMB28-source_only_implementation_missing_proof-91217190`
- Evidence type: `source_only_implementation_missing_proof`
- Severity: `yellow`
- Recommended action: `Finish proof`
- Linear-ready: `True`
- Auto-resolved: `False`
- Reason: Active item is partial/source-only/missing-proof; finish proof before treating as complete.
- Involved active paths:
  - `TRAIN_09_YOU_USER_SYSTEM_PROFILE` — `prompts/trains/ios26-flagship/TRAIN_09_YOU_USER_SYSTEM_PROFILE.md` (partial_implementation; source-only)

### 212. Source-only or missing-proof implementation state: IOS26_DEPENDENCY_GRAPH

- Candidate ID: `AMB28-source_only_implementation_missing_proof-98019040`
- Evidence type: `source_only_implementation_missing_proof`
- Severity: `yellow`
- Recommended action: `Finish proof`
- Linear-ready: `True`
- Auto-resolved: `False`
- Reason: Active item is partial/source-only/missing-proof; finish proof before treating as complete.
- Involved active paths:
  - `IOS26_DEPENDENCY_GRAPH` — `docs/codex/ios26/IOS26_DEPENDENCY_GRAPH.yml` (partial_implementation; source-only)

### 213. Duplicate stable ID: AMB-REPO-GREEN-FLAGSHIP-RESET-MASTER-01-T17-FINAL-IA-SCAN

- Candidate ID: `AMB28-duplicate_stable_id-17786025`
- Evidence type: `duplicate_stable_id`
- Severity: `yellow`
- Recommended action: `Merge`
- Linear-ready: `True`
- Auto-resolved: `False`
- Reason: Duplicate stable ID appears in active work; merge, namespace, or retire duplicate authority.
- Involved active paths:
  - `AMB-REPO-GREEN-FLAGSHIP-RESET-MASTER-01-T17-FINAL-IA-SCAN` — `prompts/batches/AMB-REPO-GREEN-FLAGSHIP-RESET-MASTER-01-T17-FINAL-IA-SCAN.md` (partial_implementation; release proof)

### 214. Duplicate stable ID: PK16

- Candidate ID: `AMB28-duplicate_stable_id-18834981`
- Evidence type: `duplicate_stable_id`
- Severity: `yellow`
- Recommended action: `Merge`
- Linear-ready: `True`
- Auto-resolved: `False`
- Reason: Duplicate stable ID appears in active work; merge, namespace, or retire duplicate authority.
- Involved active paths:
  - `PK16` — `docs/codex/batch-prep/PK16.md` (partial_implementation; release proof)

### 215. Duplicate stable ID: BL-00

- Candidate ID: `AMB28-duplicate_stable_id-21645156`
- Evidence type: `duplicate_stable_id`
- Severity: `yellow`
- Recommended action: `Merge`
- Linear-ready: `True`
- Auto-resolved: `False`
- Reason: Duplicate stable ID appears in active work; merge, namespace, or retire duplicate authority.
- Involved active paths:
  - `BL-00` — `docs/codex/IOS26_FLAGSHIP_BACKLOG_MAP.md` (partial_implementation; release proof)
  - `BL-00` — `docs/codex/backlog/ios26-flagship-maturation-backlog.md` (partial_implementation; release proof)

### 216. Duplicate stable ID: AMB-POST23-03-AUTHORITY-CLEANUP-AND-ROUTING

- Candidate ID: `AMB28-duplicate_stable_id-21981227`
- Evidence type: `duplicate_stable_id`
- Severity: `yellow`
- Recommended action: `Merge`
- Linear-ready: `True`
- Auto-resolved: `False`
- Reason: Duplicate stable ID appears in active work; merge, namespace, or retire duplicate authority.
- Involved active paths:
  - `AMB-POST23-03-AUTHORITY-CLEANUP-AND-ROUTING` — `prompts/batches/post-23-truth-audit/AMB-POST23-03-AUTHORITY-CLEANUP-AND-ROUTING.md` (partial_implementation; release proof)
  - `AMB-POST23-03-AUTHORITY-CLEANUP-AND-ROUTING` — `docs/codex/reports/AMB-POST23-03-AUTHORITY-CLEANUP-AND-ROUTING.md` (partial_implementation; release proof)

### 217. Duplicate stable ID: POST99-UI-SUITE-REVIEW-IMPLEMENTATION-00

- Candidate ID: `AMB28-duplicate_stable_id-27437331`
- Evidence type: `duplicate_stable_id`
- Severity: `yellow`
- Recommended action: `Merge`
- Linear-ready: `True`
- Auto-resolved: `False`
- Reason: Duplicate stable ID appears in active work; merge, namespace, or retire duplicate authority.
- Involved active paths:
  - `POST99-UI-SUITE-REVIEW-IMPLEMENTATION-00` — `docs/codex/reports/POST99-UI-SUITE-REVIEW-IMPLEMENTATION-00.md` (partial_implementation; release proof)
  - `POST99-UI-SUITE-REVIEW-IMPLEMENTATION-00` — `prompts/batches/POST99-UI-SUITE-REVIEW-IMPLEMENTATION-00.md` (partial_implementation; release proof)

### 218. Duplicate stable ID: PK24

- Candidate ID: `AMB28-duplicate_stable_id-30073337`
- Evidence type: `duplicate_stable_id`
- Severity: `yellow`
- Recommended action: `Merge`
- Linear-ready: `True`
- Auto-resolved: `False`
- Reason: Duplicate stable ID appears in active work; merge, namespace, or retire duplicate authority.
- Involved active paths:
  - `PK24` — `docs/codex/batch-prep/PK24.md` (partial_implementation; release proof)
  - `PK24` — `prompts/batches/PK24.md` (partial_implementation; release proof)

### 219. Duplicate stable ID: PK23

- Candidate ID: `AMB28-duplicate_stable_id-30606407`
- Evidence type: `duplicate_stable_id`
- Severity: `yellow`
- Recommended action: `Merge`
- Linear-ready: `True`
- Auto-resolved: `False`
- Reason: Duplicate stable ID appears in active work; merge, namespace, or retire duplicate authority.
- Involved active paths:
  - `PK23` — `docs/codex/batch-prep/PK23.md` (partial_implementation; release proof)
  - `PK23` — `prompts/batches/PK23.md` (partial_implementation; release proof)

### 220. Duplicate stable ID: AMB-CHATGPT-REPO-OS-UPGRADE-INSTALL-01

- Candidate ID: `AMB28-duplicate_stable_id-30694637`
- Evidence type: `duplicate_stable_id`
- Severity: `yellow`
- Recommended action: `Merge`
- Linear-ready: `True`
- Auto-resolved: `False`
- Reason: Duplicate stable ID appears in active work; merge, namespace, or retire duplicate authority.
- Involved active paths:
  - `AMB-CHATGPT-REPO-OS-UPGRADE-INSTALL-01` — `docs/codex/reports/AMB-CHATGPT-REPO-OS-UPGRADE-INSTALL-01.md` (partial_implementation; release proof)

### 221. Duplicate stable ID: existing-code-champion-coverage

- Candidate ID: `AMB28-duplicate_stable_id-37020014`
- Evidence type: `duplicate_stable_id`
- Severity: `yellow`
- Recommended action: `Merge`
- Linear-ready: `True`
- Auto-resolved: `False`
- Reason: Duplicate stable ID appears in active work; merge, namespace, or retire duplicate authority.
- Involved active paths:
  - `existing-code-champion-coverage` — `docs/codex/existing-code-champion-coverage.yml` (unknown; release proof)

### 222. Duplicate stable ID: AMB-POST23-01-TRUTH-AUDIT

- Candidate ID: `AMB28-duplicate_stable_id-39248513`
- Evidence type: `duplicate_stable_id`
- Severity: `yellow`
- Recommended action: `Merge`
- Linear-ready: `True`
- Auto-resolved: `False`
- Reason: Duplicate stable ID appears in active work; merge, namespace, or retire duplicate authority.
- Involved active paths:
  - `AMB-POST23-01-TRUTH-AUDIT` — `prompts/batches/post-23-truth-audit/AMB-POST23-01-TRUTH-AUDIT.md` (partial_implementation; release proof)
  - `AMB-POST23-01-TRUTH-AUDIT` — `docs/codex/reports/AMB-POST23-01-TRUTH-AUDIT.md` (partial_implementation; release proof)

### 223. Duplicate stable ID: AMB-REPO-GREEN-FLAGSHIP-RESET-MASTER-01-T03-VOCAB-LEDGER

- Candidate ID: `AMB28-duplicate_stable_id-42029111`
- Evidence type: `duplicate_stable_id`
- Severity: `yellow`
- Recommended action: `Merge`
- Linear-ready: `True`
- Auto-resolved: `False`
- Reason: Duplicate stable ID appears in active work; merge, namespace, or retire duplicate authority.
- Involved active paths:
  - `AMB-REPO-GREEN-FLAGSHIP-RESET-MASTER-01-T03-VOCAB-LEDGER` — `prompts/batches/AMB-REPO-GREEN-FLAGSHIP-RESET-MASTER-01-T03-VOCAB-LEDGER.md` (partial_implementation; release proof)

### 224. Duplicate stable ID: PK17

- Candidate ID: `AMB28-duplicate_stable_id-46144548`
- Evidence type: `duplicate_stable_id`
- Severity: `yellow`
- Recommended action: `Merge`
- Linear-ready: `True`
- Auto-resolved: `False`
- Reason: Duplicate stable ID appears in active work; merge, namespace, or retire duplicate authority.
- Involved active paths:
  - `PK17` — `docs/codex/batch-prep/PK17.md` (partial_implementation; release proof)
  - `PK17` — `prompts/batches/PK17.md` (partial_implementation; release proof)

### 225. Duplicate stable ID: AMB-FILE-BY-FILE-REPO-AUDIT-01

- Candidate ID: `AMB28-duplicate_stable_id-46473867`
- Evidence type: `duplicate_stable_id`
- Severity: `yellow`
- Recommended action: `Merge`
- Linear-ready: `True`
- Auto-resolved: `False`
- Reason: Duplicate stable ID appears in active work; merge, namespace, or retire duplicate authority.
- Involved active paths:
  - `AMB-FILE-BY-FILE-REPO-AUDIT-01` — `prompts/batches/AMB-FILE-BY-FILE-REPO-AUDIT-01.md` (partial_implementation; release proof)

### 226. Duplicate stable ID: IOS26-FLAGSHIP

- Candidate ID: `AMB28-duplicate_stable_id-48252112`
- Evidence type: `duplicate_stable_id`
- Severity: `yellow`
- Recommended action: `Merge`
- Linear-ready: `True`
- Auto-resolved: `False`
- Reason: Duplicate stable ID appears in active work; merge, namespace, or retire duplicate authority.
- Involved active paths:
  - `IOS26-FLAGSHIP` — `docs/codex/IOS26_FLAGSHIP_TRAIN_MANIFEST.yml` (partial_implementation; release proof)
  - `IOS26-FLAGSHIP` — `docs/codex/IOS26_FLAGSHIP_EXECUTION_STATE.yml` (partial_implementation; source-only)

### 227. Duplicate stable ID: AMB-REPO-GREEN-FLAGSHIP-RESET-MASTER-01

- Candidate ID: `AMB28-duplicate_stable_id-50777356`
- Evidence type: `duplicate_stable_id`
- Severity: `yellow`
- Recommended action: `Merge`
- Linear-ready: `True`
- Auto-resolved: `False`
- Reason: Duplicate stable ID appears in active work; merge, namespace, or retire duplicate authority.
- Involved active paths:
  - `AMB-REPO-GREEN-FLAGSHIP-RESET-MASTER-01` — `prompts/batches/AMB-REPO-GREEN-FLAGSHIP-RESET-MASTER-01.md` (partial_implementation; release proof)

### 228. Duplicate stable ID: AMB-REPO-GREEN-FLAGSHIP-RESET-MASTER-01-T05-SOURCE-REFRACTOR-MAP

- Candidate ID: `AMB28-duplicate_stable_id-5337332`
- Evidence type: `duplicate_stable_id`
- Severity: `yellow`
- Recommended action: `Merge`
- Linear-ready: `True`
- Auto-resolved: `False`
- Reason: Duplicate stable ID appears in active work; merge, namespace, or retire duplicate authority.
- Involved active paths:
  - `AMB-REPO-GREEN-FLAGSHIP-RESET-MASTER-01-T05-SOURCE-REFRACTOR-MAP` — `prompts/batches/AMB-REPO-GREEN-FLAGSHIP-RESET-MASTER-01-T05-SOURCE-REFRACTOR-MAP.md` (partial_implementation; release proof)

### 229. Duplicate stable ID: AMB_GLOBAL_REMAINING_TRAIN_BLUEPRINT

- Candidate ID: `AMB28-duplicate_stable_id-59026402`
- Evidence type: `duplicate_stable_id`
- Severity: `yellow`
- Recommended action: `Merge`
- Linear-ready: `True`
- Auto-resolved: `False`
- Reason: Duplicate stable ID appears in active work; merge, namespace, or retire duplicate authority.
- Involved active paths:
  - `AMB_GLOBAL_REMAINING_TRAIN_BLUEPRINT` — `docs/codex/AMB_GLOBAL_REMAINING_TRAIN_BLUEPRINT.md` (unknown; release proof)
  - `AMB_GLOBAL_REMAINING_TRAIN_BLUEPRINT` — `docs/codex/AMB_GLOBAL_REMAINING_TRAIN_BLUEPRINT.json` (unknown; tests)

### 230. Duplicate stable ID: PK22

- Candidate ID: `AMB28-duplicate_stable_id-61672752`
- Evidence type: `duplicate_stable_id`
- Severity: `yellow`
- Recommended action: `Merge`
- Linear-ready: `True`
- Auto-resolved: `False`
- Reason: Duplicate stable ID appears in active work; merge, namespace, or retire duplicate authority.
- Involved active paths:
  - `PK22` — `docs/codex/batch-prep/PK22.md` (partial_implementation; release proof)
  - `PK22` — `prompts/batches/PK22.md` (partial_implementation; release proof)

### 231. Duplicate stable ID: AMB-POST23-04-NEXT-TRAIN-RECOMMENDATION

- Candidate ID: `AMB28-duplicate_stable_id-64467505`
- Evidence type: `duplicate_stable_id`
- Severity: `yellow`
- Recommended action: `Merge`
- Linear-ready: `True`
- Auto-resolved: `False`
- Reason: Duplicate stable ID appears in active work; merge, namespace, or retire duplicate authority.
- Involved active paths:
  - `AMB-POST23-04-NEXT-TRAIN-RECOMMENDATION` — `prompts/batches/post-23-truth-audit/AMB-POST23-04-NEXT-TRAIN-RECOMMENDATION.md` (partial_implementation; release proof)
  - `AMB-POST23-04-NEXT-TRAIN-RECOMMENDATION` — `docs/codex/reports/AMB-POST23-04-NEXT-TRAIN-RECOMMENDATION.md` (partial_implementation; release proof)

### 232. Duplicate stable ID: PK19

- Candidate ID: `AMB28-duplicate_stable_id-65626219`
- Evidence type: `duplicate_stable_id`
- Severity: `yellow`
- Recommended action: `Merge`
- Linear-ready: `True`
- Auto-resolved: `False`
- Reason: Duplicate stable ID appears in active work; merge, namespace, or retire duplicate authority.
- Involved active paths:
  - `PK19` — `docs/codex/batch-prep/PK19.md` (partial_implementation; release proof)
  - `PK19` — `prompts/batches/PK19.md` (partial_implementation; release proof)

### 233. Duplicate stable ID: PK25

- Candidate ID: `AMB28-duplicate_stable_id-68169654`
- Evidence type: `duplicate_stable_id`
- Severity: `yellow`
- Recommended action: `Merge`
- Linear-ready: `True`
- Auto-resolved: `False`
- Reason: Duplicate stable ID appears in active work; merge, namespace, or retire duplicate authority.
- Involved active paths:
  - `PK25` — `docs/codex/batch-prep/PK25.md` (partial_implementation; release proof)
  - `PK25` — `prompts/batches/PK25.md` (partial_implementation; release proof)

### 234. Duplicate stable ID: README

- Candidate ID: `AMB28-duplicate_stable_id-71725698`
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

### 235. Duplicate stable ID: AMB_REMAINING_BATCH_REFERENCE

- Candidate ID: `AMB28-duplicate_stable_id-76451605`
- Evidence type: `duplicate_stable_id`
- Severity: `yellow`
- Recommended action: `Merge`
- Linear-ready: `True`
- Auto-resolved: `False`
- Reason: Duplicate stable ID appears in active work; merge, namespace, or retire duplicate authority.
- Involved active paths:
  - `AMB_REMAINING_BATCH_REFERENCE` — `docs/codex/AMB_REMAINING_BATCH_REFERENCE.json` (partial_implementation; release proof)
  - `AMB_REMAINING_BATCH_REFERENCE` — `docs/codex/AMB_REMAINING_BATCH_REFERENCE.md` (partial_implementation; release proof)

### 236. Duplicate stable ID: PK18

- Candidate ID: `AMB28-duplicate_stable_id-79314070`
- Evidence type: `duplicate_stable_id`
- Severity: `yellow`
- Recommended action: `Merge`
- Linear-ready: `True`
- Auto-resolved: `False`
- Reason: Duplicate stable ID appears in active work; merge, namespace, or retire duplicate authority.
- Involved active paths:
  - `PK18` — `docs/codex/batch-prep/PK18.md` (partial_implementation; release proof)
  - `PK18` — `prompts/batches/PK18.md` (partial_implementation; release proof)

### 237. Duplicate stable ID: AMB-CODEX-OS-FLAGSHIP-UPGRADE-INSTALL-01

- Candidate ID: `AMB28-duplicate_stable_id-84016860`
- Evidence type: `duplicate_stable_id`
- Severity: `yellow`
- Recommended action: `Merge`
- Linear-ready: `True`
- Auto-resolved: `False`
- Reason: Duplicate stable ID appears in active work; merge, namespace, or retire duplicate authority.
- Involved active paths:
  - `AMB-CODEX-OS-FLAGSHIP-UPGRADE-INSTALL-01` — `docs/codex/reports/AMB-CODEX-OS-FLAGSHIP-UPGRADE-INSTALL-01.md` (partial_implementation; release proof)
  - `AMB-CODEX-OS-FLAGSHIP-UPGRADE-INSTALL-01` — `prompts/batches/AMB-CODEX-OS-FLAGSHIP-UPGRADE-INSTALL-01.md` (partial_implementation; release proof)

### 238. Duplicate stable ID: AMB-POST23-00-COMPLETION-SENTINEL

- Candidate ID: `AMB28-duplicate_stable_id-85236679`
- Evidence type: `duplicate_stable_id`
- Severity: `yellow`
- Recommended action: `Merge`
- Linear-ready: `True`
- Auto-resolved: `False`
- Reason: Duplicate stable ID appears in active work; merge, namespace, or retire duplicate authority.
- Involved active paths:
  - `AMB-POST23-00-COMPLETION-SENTINEL` — `prompts/batches/post-23-truth-audit/AMB-POST23-00-COMPLETION-SENTINEL.md` (partial_implementation; release proof)
  - `AMB-POST23-00-COMPLETION-SENTINEL` — `docs/codex/reports/AMB-POST23-00-COMPLETION-SENTINEL.md` (unknown; release proof)

### 239. Duplicate stable ID: AMB-FE-BE-PREFLIGHT-00

- Candidate ID: `AMB28-duplicate_stable_id-91382211`
- Evidence type: `duplicate_stable_id`
- Severity: `yellow`
- Recommended action: `Merge`
- Linear-ready: `True`
- Auto-resolved: `False`
- Reason: Duplicate stable ID appears in active work; merge, namespace, or retire duplicate authority.
- Involved active paths:
  - `AMB-FE-BE-PREFLIGHT-00` — `prompts/batches/amb-fe-be/AMB-FE-BE-PREFLIGHT-00.md` (partial_implementation; release proof)

### 240. Duplicate stable ID: AMB-POST23-02-UNDERDELIVERY-REPAIR

- Candidate ID: `AMB28-duplicate_stable_id-91770692`
- Evidence type: `duplicate_stable_id`
- Severity: `yellow`
- Recommended action: `Merge`
- Linear-ready: `True`
- Auto-resolved: `False`
- Reason: Duplicate stable ID appears in active work; merge, namespace, or retire duplicate authority.
- Involved active paths:
  - `AMB-POST23-02-UNDERDELIVERY-REPAIR` — `prompts/batches/post-23-truth-audit/AMB-POST23-02-UNDERDELIVERY-REPAIR.md` (partial_implementation; release proof)
  - `AMB-POST23-02-UNDERDELIVERY-REPAIR` — `docs/codex/reports/AMB-POST23-02-UNDERDELIVERY-REPAIR.md` (partial_implementation; release proof)

### 241. Duplicate stable ID: PK20

- Candidate ID: `AMB28-duplicate_stable_id-93204349`
- Evidence type: `duplicate_stable_id`
- Severity: `yellow`
- Recommended action: `Merge`
- Linear-ready: `True`
- Auto-resolved: `False`
- Reason: Duplicate stable ID appears in active work; merge, namespace, or retire duplicate authority.
- Involved active paths:
  - `PK20` — `docs/codex/batch-prep/PK20.md` (partial_implementation; release proof)
  - `PK20` — `prompts/batches/PK20.md` (partial_implementation; release proof)

### 242. Duplicate stable ID: PK21

- Candidate ID: `AMB28-duplicate_stable_id-95460349`
- Evidence type: `duplicate_stable_id`
- Severity: `yellow`
- Recommended action: `Merge`
- Linear-ready: `True`
- Auto-resolved: `False`
- Reason: Duplicate stable ID appears in active work; merge, namespace, or retire duplicate authority.
- Involved active paths:
  - `PK21` — `docs/codex/batch-prep/PK21.md` (partial_implementation; release proof)
  - `PK21` — `prompts/batches/PK21.md` (partial_implementation; release proof)

### 243. Duplicate stable ID: FE-12-CHROME-CONTRACTS-HARDENING

- Candidate ID: `AMB28-duplicate_stable_id-9737119`
- Evidence type: `duplicate_stable_id`
- Severity: `yellow`
- Recommended action: `Merge`
- Linear-ready: `True`
- Auto-resolved: `False`
- Reason: Duplicate stable ID appears in active work; merge, namespace, or retire duplicate authority.
- Involved active paths:
  - `FE-12-CHROME-CONTRACTS-HARDENING` — `prompts/batches/amb-fe-be/FE-12-CHROME-CONTRACTS-HARDENING.md` (partial_implementation; release proof)
  - `FE-12-CHROME-CONTRACTS-HARDENING` — `docs/codex/reports/FE-12-CHROME-CONTRACTS-HARDENING.md` (partial_implementation; release proof)

### 244. Duplicate stable ID: AMB-FLAGSHIP-UI-CODEX-STUDIO-INSTALL-01

- Candidate ID: `AMB28-duplicate_stable_id-99080861`
- Evidence type: `duplicate_stable_id`
- Severity: `yellow`
- Recommended action: `Merge`
- Linear-ready: `True`
- Auto-resolved: `False`
- Reason: Duplicate stable ID appears in active work; merge, namespace, or retire duplicate authority.
- Involved active paths:
  - `AMB-FLAGSHIP-UI-CODEX-STUDIO-INSTALL-01` — `docs/codex/reports/AMB-FLAGSHIP-UI-CODEX-STUDIO-INSTALL-01.md` (partial_implementation; release proof)
  - `AMB-FLAGSHIP-UI-CODEX-STUDIO-INSTALL-01` — `prompts/batches/AMB-FLAGSHIP-UI-CODEX-STUDIO-INSTALL-01.md` (partial_implementation; release proof)
  - `AMB-FLAGSHIP-UI-CODEX-STUDIO-INSTALL-01` — `docs/codex/review-boards/AMB-FLAGSHIP-UI-CODEX-STUDIO-INSTALL-01.md` (unknown; release proof)

### 245. Same source file targeted by multiple active items: scripts/ambitions-global-train-supervisor.sh

- Candidate ID: `AMB28-same_source_file_targeted_by_multiple_active_batches-10542241`
- Evidence type: `same_source_file_targeted_by_multiple_active_batches`
- Severity: `yellow`
- Recommended action: `Merge`
- Linear-ready: `True`
- Auto-resolved: `False`
- Reason: Multiple active work items target the same source file; merge or sequence ownership before implementation.
- Involved active paths:
  - `global-train-supervisor` — `docs/codex/global-train-supervisor.md` (partial_implementation; release proof)
  - `CODEX-OS-GOVERNANCE-FULL-AUTONOMY-INTEGRATION-01` — `prompts/batches/CODEX-OS-GOVERNANCE-FULL-AUTONOMY-INTEGRATION-01.md` (partial_implementation; release proof)

### 246. Same source file targeted by multiple active items: scripts/cqs-performance-budget-scan.sh

- Candidate ID: `AMB28-same_source_file_targeted_by_multiple_active_batches-10983828`
- Evidence type: `same_source_file_targeted_by_multiple_active_batches`
- Severity: `yellow`
- Recommended action: `Merge`
- Linear-ready: `True`
- Auto-resolved: `False`
- Reason: Multiple active work items target the same source file; merge or sequence ownership before implementation.
- Involved active paths:
  - `CQS01_CQS24_CODEX_QUALITY_SYSTEM_TRAIN` — `docs/codex/batch-trains/CQS01_CQS24_CODEX_QUALITY_SYSTEM_TRAIN.md` (partial_implementation; release proof)
  - `GATE_SYSTEM_HARDENING_NEXT_PROMPT` — `docs/codex/batches/GATE_SYSTEM_HARDENING_NEXT_PROMPT.md` (partial_implementation; release proof)
  - `PFC14_WidgetKit_Implementation_And_Tests_Prompt` — `docs/codex/batches/PFC14_WidgetKit_Implementation_And_Tests_Prompt.md` (partial_implementation; release proof)
  - `CODEX_QUALITY_SYSTEM_SCRIPT_MAP` — `docs/codex/CODEX_QUALITY_SYSTEM_SCRIPT_MAP.md` (unknown; release proof)

### 247. Same source file targeted by multiple active items: scripts/ambitions_codex_os_validate.py

- Candidate ID: `AMB28-same_source_file_targeted_by_multiple_active_batches-11451796`
- Evidence type: `same_source_file_targeted_by_multiple_active_batches`
- Severity: `yellow`
- Recommended action: `Merge`
- Linear-ready: `True`
- Auto-resolved: `False`
- Reason: Multiple active work items target the same source file; merge or sequence ownership before implementation.
- Involved active paths:
  - `AMB-FILE-BY-FILE-REPO-AUDIT-01` — `prompts/batches/AMB-FILE-BY-FILE-REPO-AUDIT-01.md` (partial_implementation; release proof)
  - `AMB-REPO-GREEN-FLAGSHIP-RESET-MASTER-01` — `prompts/batches/AMB-REPO-GREEN-FLAGSHIP-RESET-MASTER-01.md` (partial_implementation; release proof)

### 248. Same source file targeted by multiple active items: Native/AmbitionsTests/Runtime/GoalRealityNegativeFixtureTests.swift

- Candidate ID: `AMB28-same_source_file_targeted_by_multiple_active_batches-11630089`
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
  - `MOAT-GOAL-REALITY-SOURCE-PACKS-09` — `prompts/batches/MOAT-GOAL-REALITY-SOURCE-PACKS-09.md` (partial_implementation; release proof)

### 249. Same source file targeted by multiple active items: scripts/ambitions-throughput-plan.sh

- Candidate ID: `AMB28-same_source_file_targeted_by_multiple_active_batches-11797012`
- Evidence type: `same_source_file_targeted_by_multiple_active_batches`
- Severity: `yellow`
- Recommended action: `Merge`
- Linear-ready: `True`
- Auto-resolved: `False`
- Reason: Multiple active work items target the same source file; merge or sequence ownership before implementation.
- Involved active paths:
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
  - ... 1 more

### 250. Same source file targeted by multiple active items: Native/AmbitionsTests/Persistence/EventLedgerRepositoryTests.swift

- Candidate ID: `AMB28-same_source_file_targeted_by_multiple_active_batches-11898774`
- Evidence type: `same_source_file_targeted_by_multiple_active_batches`
- Severity: `yellow`
- Recommended action: `Merge`
- Linear-ready: `True`
- Auto-resolved: `False`
- Reason: Multiple active work items target the same source file; merge or sequence ownership before implementation.
- Involved active paths:
  - `PK22` — `prompts/batches/PK22.md` (partial_implementation; release proof)
  - `BACKEND-FINAL-FORM-LOCAL-FIRST-HUMAN-01` — `prompts/batches/BACKEND-FINAL-FORM-LOCAL-FIRST-HUMAN-01.md` (partial_implementation; release proof)

### 251. Same source file targeted by multiple active items: Native/Ambitions/Persistence/PortableSnapshotService.swift

- Candidate ID: `AMB28-same_source_file_targeted_by_multiple_active_batches-12077061`
- Evidence type: `same_source_file_targeted_by_multiple_active_batches`
- Severity: `yellow`
- Recommended action: `Merge`
- Linear-ready: `True`
- Auto-resolved: `False`
- Reason: Multiple active work items target the same source file; merge or sequence ownership before implementation.
- Involved active paths:
  - `PFC07_Migration_Ladder_And_Backward_Compatibility_Tests_Prompt` — `docs/codex/batches/PFC07_Migration_Ladder_And_Backward_Compatibility_Tests_Prompt.md` (partial_implementation; release proof)
  - `PK31` — `prompts/batches/PK31.md` (partial_implementation; release proof)
  - `BACKEND-FINAL-FORM-LOCAL-FIRST-HUMAN-01` — `prompts/batches/BACKEND-FINAL-FORM-LOCAL-FIRST-HUMAN-01.md` (partial_implementation; release proof)
  - `AMB-POST23-01-TRUTH-AUDIT` — `docs/codex/reports/AMB-POST23-01-TRUTH-AUDIT.md` (partial_implementation; release proof)
  - `PFC08_Corruption_Recovery_Backup_Restore_Plan_Prompt` — `docs/codex/batches/PFC08_Corruption_Recovery_Backup_Restore_Plan_Prompt.md` (unknown; release proof)

### 252. Same source file targeted by multiple active items: Native/Ambitions/Domain/AmbitionsOSSourceTruthModels.swift

- Candidate ID: `AMB28-same_source_file_targeted_by_multiple_active_batches-1231612`
- Evidence type: `same_source_file_targeted_by_multiple_active_batches`
- Severity: `yellow`
- Recommended action: `Merge`
- Linear-ready: `True`
- Auto-resolved: `False`
- Reason: Multiple active work items target the same source file; merge or sequence ownership before implementation.
- Involved active paths:
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
  - ... 21 more

### 253. Same source file targeted by multiple active items: scripts/ambitions-frontend-authority-packet.py

- Candidate ID: `AMB28-same_source_file_targeted_by_multiple_active_batches-12391598`
- Evidence type: `same_source_file_targeted_by_multiple_active_batches`
- Severity: `yellow`
- Recommended action: `Merge`
- Linear-ready: `True`
- Auto-resolved: `False`
- Reason: Multiple active work items target the same source file; merge or sequence ownership before implementation.
- Involved active paths:
  - `SIGNATURE-VISUAL-INSTRUMENTS-ENCYCLOPEDIA-07` — `prompts/batches/SIGNATURE-VISUAL-INSTRUMENTS-ENCYCLOPEDIA-07.md` (partial_implementation; release proof)
  - `AMB-POST23-02-UNDERDELIVERY-REPAIR` — `docs/codex/reports/AMB-POST23-02-UNDERDELIVERY-REPAIR.md` (partial_implementation; release proof)

### 254. Same source file targeted by multiple active items: scripts/sa-no-claim-scan.sh

- Candidate ID: `AMB28-same_source_file_targeted_by_multiple_active_batches-12644284`
- Evidence type: `same_source_file_targeted_by_multiple_active_batches`
- Severity: `yellow`
- Recommended action: `Merge`
- Linear-ready: `True`
- Auto-resolved: `False`
- Reason: Multiple active work items target the same source file; merge or sequence ownership before implementation.
- Involved active paths:
  - `SOURCE_ATLAS_CODEX_OS_UPGRADE_MAP` — `docs/codex/SOURCE_ATLAS_CODEX_OS_UPGRADE_MAP.md` (partial_implementation; release proof)
  - `SA01_SA32_SOURCE_ATLAS_FULL_MATURITY_TRAIN` — `docs/codex/batch-trains/SA01_SA32_SOURCE_ATLAS_FULL_MATURITY_TRAIN.md` (partial_implementation; release proof)
  - `SA_NEXT_ELIGIBLE_BATCH_PROMPT` — `docs/codex/batches/SA_NEXT_ELIGIBLE_BATCH_PROMPT.md` (partial_implementation; release proof)

### 255. Same source file targeted by multiple active items: Native/AmbitionsTests/Runtime/GoalRealityReceiptTests.swift

- Candidate ID: `AMB28-same_source_file_targeted_by_multiple_active_batches-12898856`
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
  - `MOAT-GOAL-REALITY-RECEIPT-CLOSURE-07` — `prompts/batches/MOAT-GOAL-REALITY-RECEIPT-CLOSURE-07.md` (partial_implementation; release proof)

### 256. Same source file targeted by multiple active items: Native/Ambitions/Persistence/SwiftDataModels.swift

- Candidate ID: `AMB28-same_source_file_targeted_by_multiple_active_batches-1300009`
- Evidence type: `same_source_file_targeted_by_multiple_active_batches`
- Severity: `yellow`
- Recommended action: `Merge`
- Linear-ready: `True`
- Auto-resolved: `False`
- Reason: Multiple active work items target the same source file; merge or sequence ownership before implementation.
- Involved active paths:
  - `repo-audit-baseline` — `docs/codex/repo-audit-baseline.md` (partial_implementation; release proof)
  - `PFC07_Migration_Ladder_And_Backward_Compatibility_Tests_Prompt` — `docs/codex/batches/PFC07_Migration_Ladder_And_Backward_Compatibility_Tests_Prompt.md` (partial_implementation; release proof)
  - `BACKEND-FINAL-FORM-LOCAL-FIRST-HUMAN-01` — `prompts/batches/BACKEND-FINAL-FORM-LOCAL-FIRST-HUMAN-01.md` (partial_implementation; release proof)
  - `MOAT-GOAL-REALITY-LOCAL-PERSISTENCE-08` — `prompts/batches/MOAT-GOAL-REALITY-LOCAL-PERSISTENCE-08.md` (partial_implementation; release proof)

### 257. Same source file targeted by multiple active items: scripts/ambitions-queue-snapshot.py

- Candidate ID: `AMB28-same_source_file_targeted_by_multiple_active_batches-1350962`
- Evidence type: `same_source_file_targeted_by_multiple_active_batches`
- Severity: `yellow`
- Recommended action: `Merge`
- Linear-ready: `True`
- Auto-resolved: `False`
- Reason: Multiple active work items target the same source file; merge or sequence ownership before implementation.
- Involved active paths:
  - `AMB_CONTROL_PLANE_DIRECT_RUNBOOK` — `docs/codex/AMB_CONTROL_PLANE_DIRECT_RUNBOOK.md` (partial_implementation; release proof)
  - `AMB_CONTROL_PLANE_GATE_INDEX` — `docs/codex/AMB_CONTROL_PLANE_GATE_INDEX.md` (partial_implementation; release proof)
  - `MOAT-ALIGNMENT-01` — `prompts/batches/MOAT-ALIGNMENT-01.md` (partial_implementation; release proof)
  - `HBI-GLOBAL-TRAIN-HANDOFF-01` — `prompts/batches/HBI-GLOBAL-TRAIN-HANDOFF-01.md` (partial_implementation; release proof)

### 258. Same source file targeted by multiple active items: scripts/ai/acx_build_triage.py

- Candidate ID: `AMB28-same_source_file_targeted_by_multiple_active_batches-13671442`
- Evidence type: `same_source_file_targeted_by_multiple_active_batches`
- Severity: `yellow`
- Recommended action: `Merge`
- Linear-ready: `True`
- Auto-resolved: `False`
- Reason: Multiple active work items target the same source file; merge or sequence ownership before implementation.
- Involved active paths:
  - `CODEX_OS_ENGINE_SUPPLEMENT_2026_05_08` — `docs/codex/CODEX_OS_ENGINE_SUPPLEMENT_2026_05_08.md` (partial_implementation; release proof)
  - `CODEX_OS_REPAIR_SPEED_PROOF_UPGRADE_AUDIT_2026_05_08` — `docs/codex/CODEX_OS_REPAIR_SPEED_PROOF_UPGRADE_AUDIT_2026_05_08.md` (partial_implementation; release proof)
  - `CODEX_QUALITY_SYSTEM_SCRIPT_MAP` — `docs/codex/CODEX_QUALITY_SYSTEM_SCRIPT_MAP.md` (unknown; release proof)
  - `CODEX_BUILD_SHERIFF_PROTOCOL` — `docs/codex/CODEX_BUILD_SHERIFF_PROTOCOL.md` (unknown; release proof)

### 259. Same source file targeted by multiple active items: Native/Ambitions/Domain/AmbitionsOSAdaptationModels.swift

- Candidate ID: `AMB28-same_source_file_targeted_by_multiple_active_batches-13979485`
- Evidence type: `same_source_file_targeted_by_multiple_active_batches`
- Severity: `yellow`
- Recommended action: `Merge`
- Linear-ready: `True`
- Auto-resolved: `False`
- Reason: Multiple active work items target the same source file; merge or sequence ownership before implementation.
- Involved active paths:
  - `AMBITIONSOS_AOS_TRACEABILITY_MATRIX` — `docs/codex/AMBITIONSOS_AOS_TRACEABILITY_MATRIX.md` (partial_implementation; release proof)
  - `AMB-POST23-01-TRUTH-AUDIT` — `docs/codex/reports/AMB-POST23-01-TRUTH-AUDIT.md` (partial_implementation; release proof)
  - `AMBITIONSOS_AOS_PRIVACY_PROJECTION_LEDGER` — `docs/codex/AMBITIONSOS_AOS_PRIVACY_PROJECTION_LEDGER.md` (unknown; release proof)
  - `existing-code-champion-coverage` — `docs/codex/existing-code-champion-coverage.yml` (unknown; release proof)

### 260. Same source file targeted by multiple active items: Native/Ambitions/Persistence/SwiftDataRepositories.swift

- Candidate ID: `AMB28-same_source_file_targeted_by_multiple_active_batches-14217122`
- Evidence type: `same_source_file_targeted_by_multiple_active_batches`
- Severity: `yellow`
- Recommended action: `Merge`
- Linear-ready: `True`
- Auto-resolved: `False`
- Reason: Multiple active work items target the same source file; merge or sequence ownership before implementation.
- Involved active paths:
  - `repo-audit-baseline` — `docs/codex/repo-audit-baseline.md` (partial_implementation; release proof)
  - `PFC07_Migration_Ladder_And_Backward_Compatibility_Tests_Prompt` — `docs/codex/batches/PFC07_Migration_Ladder_And_Backward_Compatibility_Tests_Prompt.md` (partial_implementation; release proof)
  - `PK22` — `prompts/batches/PK22.md` (partial_implementation; release proof)
  - `BACKEND-FINAL-FORM-LOCAL-FIRST-HUMAN-01` — `prompts/batches/BACKEND-FINAL-FORM-LOCAL-FIRST-HUMAN-01.md` (partial_implementation; release proof)
  - `MOAT-GOAL-REALITY-LOCAL-PERSISTENCE-08` — `prompts/batches/MOAT-GOAL-REALITY-LOCAL-PERSISTENCE-08.md` (partial_implementation; release proof)

### 261. Same source file targeted by multiple active items: scripts/ambitions_validate_visual_proof.py

- Candidate ID: `AMB28-same_source_file_targeted_by_multiple_active_batches-14805951`
- Evidence type: `same_source_file_targeted_by_multiple_active_batches`
- Severity: `yellow`
- Recommended action: `Merge`
- Linear-ready: `True`
- Auto-resolved: `False`
- Reason: Multiple active work items target the same source file; merge or sequence ownership before implementation.
- Involved active paths:
  - `POST_BATCH_GATE_REGISTRY` — `docs/codex/POST_BATCH_GATE_REGISTRY.md` (partial_implementation; release proof)
  - `AMB_CODEX_GOVERNANCE_SPEC` — `docs/codex/AMB_CODEX_GOVERNANCE_SPEC.md` (partial_implementation; release proof)

### 262. Same source file targeted by multiple active items: Native/Ambitions/Features/Today/TodayScreen.swift

- Candidate ID: `AMB28-same_source_file_targeted_by_multiple_active_batches-15005348`
- Evidence type: `same_source_file_targeted_by_multiple_active_batches`
- Severity: `yellow`
- Recommended action: `Merge`
- Linear-ready: `True`
- Auto-resolved: `False`
- Reason: Multiple active work items target the same source file; merge or sequence ownership before implementation.
- Involved active paths:
  - `repo-audit-baseline` — `docs/codex/repo-audit-baseline.md` (partial_implementation; release proof)
  - `FLAGSHIP_COMPLETION_FILE_BOUNDARY_MAP` — `docs/codex/FLAGSHIP_COMPLETION_FILE_BOUNDARY_MAP.md` (partial_implementation; release proof)
  - `PK17` — `prompts/batches/PK17.md` (partial_implementation; release proof)
  - `FLAGSHIP-OBJECT-SYSTEM-01` — `prompts/batches/FLAGSHIP-OBJECT-SYSTEM-01.md` (partial_implementation; release proof)
  - `AMB-POST23-01-TRUTH-AUDIT` — `docs/codex/reports/AMB-POST23-01-TRUTH-AUDIT.md` (partial_implementation; release proof)

### 263. Same source file targeted by multiple active items: Native/Ambitions/Services/AmbitionsCommandExecutor.swift

- Candidate ID: `AMB28-same_source_file_targeted_by_multiple_active_batches-15052784`
- Evidence type: `same_source_file_targeted_by_multiple_active_batches`
- Severity: `yellow`
- Recommended action: `Merge`
- Linear-ready: `True`
- Auto-resolved: `False`
- Reason: Multiple active work items target the same source file; merge or sequence ownership before implementation.
- Involved active paths:
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
  - ... 1 more

### 264. Same source file targeted by multiple active items: scripts/fet-bottom-chrome-conflict-scan.sh

- Candidate ID: `AMB28-same_source_file_targeted_by_multiple_active_batches-15187566`
- Evidence type: `same_source_file_targeted_by_multiple_active_batches`
- Severity: `yellow`
- Recommended action: `Merge`
- Linear-ready: `True`
- Auto-resolved: `False`
- Reason: Multiple active work items target the same source file; merge or sequence ownership before implementation.
- Involved active paths:
  - `GLOBAL_BATCH_AUTOMATED_GATE_PROTOCOL` — `docs/codex/GLOBAL_BATCH_AUTOMATED_GATE_PROTOCOL.md` (partial_implementation; release proof)
  - `FAANG_FRONTEND_IMPLEMENTATION_OPERATING_SYSTEM` — `docs/codex/FAANG_FRONTEND_IMPLEMENTATION_OPERATING_SYSTEM.md` (partial_implementation; release proof)
  - `FET01_FET12_FAANG_FRONTEND_EXCELLENCE_TRAIN` — `docs/codex/batch-trains/FET01_FET12_FAANG_FRONTEND_EXCELLENCE_TRAIN.md` (partial_implementation; release proof)
  - `FET00_FAANG_FRONTEND_CODEX_OS_UPGRADE_PROMPT` — `docs/codex/batches/FET00_FAANG_FRONTEND_CODEX_OS_UPGRADE_PROMPT.md` (partial_implementation; release proof)

### 265. Same source file targeted by multiple active items: scripts/ambitions-frontend-next-surface-queue.py

- Candidate ID: `AMB28-same_source_file_targeted_by_multiple_active_batches-15674448`
- Evidence type: `same_source_file_targeted_by_multiple_active_batches`
- Severity: `yellow`
- Recommended action: `Merge`
- Linear-ready: `True`
- Auto-resolved: `False`
- Reason: Multiple active work items target the same source file; merge or sequence ownership before implementation.
- Involved active paths:
  - `SIGNATURE-VISUAL-INSTRUMENTS-ENCYCLOPEDIA-07` — `prompts/batches/SIGNATURE-VISUAL-INSTRUMENTS-ENCYCLOPEDIA-07.md` (partial_implementation; release proof)
  - `AMB-POST23-02-UNDERDELIVERY-REPAIR` — `docs/codex/reports/AMB-POST23-02-UNDERDELIVERY-REPAIR.md` (partial_implementation; release proof)

### 266. Same source file targeted by multiple active items: Native/Ambitions/Domain/CaptureModels.swift

- Candidate ID: `AMB28-same_source_file_targeted_by_multiple_active_batches-15996512`
- Evidence type: `same_source_file_targeted_by_multiple_active_batches`
- Severity: `yellow`
- Recommended action: `Merge`
- Linear-ready: `True`
- Auto-resolved: `False`
- Reason: Multiple active work items target the same source file; merge or sequence ownership before implementation.
- Involved active paths:
  - `PK20` — `prompts/batches/PK20.md` (partial_implementation; release proof)
  - `MOAT-COMPLETE-AUTONOMOUS-01` — `prompts/batches/MOAT-COMPLETE-AUTONOMOUS-01.md` (partial_implementation; release proof)
  - `existing-code-champion-coverage` — `docs/codex/existing-code-champion-coverage.yml` (unknown; release proof)

### 267. Same source file targeted by multiple active items: Native/AmbitionsTests/Domain/AmbitionsOSPrivacySafetyModelsTests.swift

- Candidate ID: `AMB28-same_source_file_targeted_by_multiple_active_batches-16965779`
- Evidence type: `same_source_file_targeted_by_multiple_active_batches`
- Severity: `yellow`
- Recommended action: `Merge`
- Linear-ready: `True`
- Auto-resolved: `False`
- Reason: Multiple active work items target the same source file; merge or sequence ownership before implementation.
- Involved active paths:
  - `AMBITIONSOS_AOS_PRIVACY_PROJECTION_LEDGER` — `docs/codex/AMBITIONSOS_AOS_PRIVACY_PROJECTION_LEDGER.md` (unknown; release proof)
  - `AMBITIONSOS_AOS_SOURCE_TRUTH_CLAIM_LEDGER` — `docs/codex/AMBITIONSOS_AOS_SOURCE_TRUTH_CLAIM_LEDGER.md` (unknown; release proof)

### 268. Same source file targeted by multiple active items: scripts/ai/acx_closeout.py

- Candidate ID: `AMB28-same_source_file_targeted_by_multiple_active_batches-17730920`
- Evidence type: `same_source_file_targeted_by_multiple_active_batches`
- Severity: `yellow`
- Recommended action: `Merge`
- Linear-ready: `True`
- Auto-resolved: `False`
- Reason: Multiple active work items target the same source file; merge or sequence ownership before implementation.
- Involved active paths:
  - `CODEX_OS_ENGINE_SUPPLEMENT_2026_05_08` — `docs/codex/CODEX_OS_ENGINE_SUPPLEMENT_2026_05_08.md` (partial_implementation; release proof)
  - `CODEX_OS_REPAIR_SPEED_PROOF_UPGRADE_AUDIT_2026_05_08` — `docs/codex/CODEX_OS_REPAIR_SPEED_PROOF_UPGRADE_AUDIT_2026_05_08.md` (partial_implementation; release proof)
  - `CODEX_QUALITY_SYSTEM_SCRIPT_MAP` — `docs/codex/CODEX_QUALITY_SYSTEM_SCRIPT_MAP.md` (unknown; release proof)
  - `CODEX_SPEED_ENGINE` — `docs/codex/CODEX_SPEED_ENGINE.md` (unknown; release proof)

### 269. Same source file targeted by multiple active items: scripts/ambitions-frontend-proof-contract-check.py

- Candidate ID: `AMB28-same_source_file_targeted_by_multiple_active_batches-19186256`
- Evidence type: `same_source_file_targeted_by_multiple_active_batches`
- Severity: `yellow`
- Recommended action: `Merge`
- Linear-ready: `True`
- Auto-resolved: `False`
- Reason: Multiple active work items target the same source file; merge or sequence ownership before implementation.
- Involved active paths:
  - `AMB-FLAGSHIP-UI-CODEX-STUDIO-INSTALL-01` — `docs/codex/reports/AMB-FLAGSHIP-UI-CODEX-STUDIO-INSTALL-01.md` (partial_implementation; release proof)
  - `AMB-POST23-02-UNDERDELIVERY-REPAIR` — `docs/codex/reports/AMB-POST23-02-UNDERDELIVERY-REPAIR.md` (partial_implementation; release proof)

### 270. Same source file targeted by multiple active items: scripts/ambitions-codex-train.sh

- Candidate ID: `AMB28-same_source_file_targeted_by_multiple_active_batches-19279448`
- Evidence type: `same_source_file_targeted_by_multiple_active_batches`
- Severity: `yellow`
- Recommended action: `Merge`
- Linear-ready: `True`
- Auto-resolved: `False`
- Reason: Multiple active work items target the same source file; merge or sequence ownership before implementation.
- Involved active paths:
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
  - ... 310 more

### 271. Same source file targeted by multiple active items: scripts/codex-forbidden-claim-scan.sh

- Candidate ID: `AMB28-same_source_file_targeted_by_multiple_active_batches-19490901`
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
  - ... 88 more

### 272. Same source file targeted by multiple active items: scripts/ai/acx_sanitized_evidence.py

- Candidate ID: `AMB28-same_source_file_targeted_by_multiple_active_batches-19661963`
- Evidence type: `same_source_file_targeted_by_multiple_active_batches`
- Severity: `yellow`
- Recommended action: `Merge`
- Linear-ready: `True`
- Auto-resolved: `False`
- Reason: Multiple active work items target the same source file; merge or sequence ownership before implementation.
- Involved active paths:
  - `CODEX_OS_ENGINE_SUPPLEMENT_2026_05_08` — `docs/codex/CODEX_OS_ENGINE_SUPPLEMENT_2026_05_08.md` (partial_implementation; release proof)
  - `CODEX_OS_REPAIR_SPEED_PROOF_UPGRADE_AUDIT_2026_05_08` — `docs/codex/CODEX_OS_REPAIR_SPEED_PROOF_UPGRADE_AUDIT_2026_05_08.md` (partial_implementation; release proof)
  - `CODEX_QUALITY_SYSTEM_SCRIPT_MAP` — `docs/codex/CODEX_QUALITY_SYSTEM_SCRIPT_MAP.md` (unknown; release proof)
  - `CODEX_PROOF_CACHE_PROTOCOL` — `docs/codex/CODEX_PROOF_CACHE_PROTOCOL.md` (unknown; release proof)
  - `CODEX_SPEED_ENGINE` — `docs/codex/CODEX_SPEED_ENGINE.md` (unknown; release proof)

### 273. Same source file targeted by multiple active items: scripts/ai/acx_accessibility_packet.py

- Candidate ID: `AMB28-same_source_file_targeted_by_multiple_active_batches-19756138`
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
  - `CODEX_ACCESSIBILITY_PROOF_PROTOCOL` — `docs/codex/CODEX_ACCESSIBILITY_PROOF_PROTOCOL.md` (unknown; release proof)

### 274. Same source file targeted by multiple active items: Native/Ambitions/ExternalSnapshots/ExternalWidgetProjection.swift

- Candidate ID: `AMB28-same_source_file_targeted_by_multiple_active_batches-19861959`
- Evidence type: `same_source_file_targeted_by_multiple_active_batches`
- Severity: `yellow`
- Recommended action: `Merge`
- Linear-ready: `True`
- Auto-resolved: `False`
- Reason: Multiple active work items target the same source file; merge or sequence ownership before implementation.
- Involved active paths:
  - `PFC14_WidgetKit_Implementation_And_Tests_Prompt` — `docs/codex/batches/PFC14_WidgetKit_Implementation_And_Tests_Prompt.md` (partial_implementation; release proof)
  - `PFC13_WidgetKit_Strategy_And_Object_Map_Prompt` — `docs/codex/batches/PFC13_WidgetKit_Strategy_And_Object_Map_Prompt.md` (unknown; release proof)

### 275. Same source file targeted by multiple active items: Native/Ambitions/ExternalSnapshots/ExternalSurfaceContractModels.swift

- Candidate ID: `AMB28-same_source_file_targeted_by_multiple_active_batches-20437527`
- Evidence type: `same_source_file_targeted_by_multiple_active_batches`
- Severity: `yellow`
- Recommended action: `Merge`
- Linear-ready: `True`
- Auto-resolved: `False`
- Reason: Multiple active work items target the same source file; merge or sequence ownership before implementation.
- Involved active paths:
  - `PFC12_App_Groups_Shared_Storage_Boundary_Prompt` — `docs/codex/batches/PFC12_App_Groups_Shared_Storage_Boundary_Prompt.md` (unknown; release proof)
  - `PFC13_WidgetKit_Strategy_And_Object_Map_Prompt` — `docs/codex/batches/PFC13_WidgetKit_Strategy_And_Object_Map_Prompt.md` (unknown; release proof)

### 276. Same source file targeted by multiple active items: Native/AmbitionsTests/Persistence/PersistenceRepositoryTests.swift

- Candidate ID: `AMB28-same_source_file_targeted_by_multiple_active_batches-20949965`
- Evidence type: `same_source_file_targeted_by_multiple_active_batches`
- Severity: `yellow`
- Recommended action: `Merge`
- Linear-ready: `True`
- Auto-resolved: `False`
- Reason: Multiple active work items target the same source file; merge or sequence ownership before implementation.
- Involved active paths:
  - `PFC07_Migration_Ladder_And_Backward_Compatibility_Tests_Prompt` — `docs/codex/batches/PFC07_Migration_Ladder_And_Backward_Compatibility_Tests_Prompt.md` (partial_implementation; release proof)
  - `BACKEND-FINAL-FORM-LOCAL-FIRST-HUMAN-01` — `prompts/batches/BACKEND-FINAL-FORM-LOCAL-FIRST-HUMAN-01.md` (partial_implementation; release proof)
  - `PFC08_Corruption_Recovery_Backup_Restore_Plan_Prompt` — `docs/codex/batches/PFC08_Corruption_Recovery_Backup_Restore_Plan_Prompt.md` (unknown; release proof)

### 277. Same source file targeted by multiple active items: scripts/sa-projection-fixture-coverage-scan.sh

- Candidate ID: `AMB28-same_source_file_targeted_by_multiple_active_batches-21433652`
- Evidence type: `same_source_file_targeted_by_multiple_active_batches`
- Severity: `yellow`
- Recommended action: `Merge`
- Linear-ready: `True`
- Auto-resolved: `False`
- Reason: Multiple active work items target the same source file; merge or sequence ownership before implementation.
- Involved active paths:
  - `SOURCE_ATLAS_CODEX_OS_UPGRADE_MAP` — `docs/codex/SOURCE_ATLAS_CODEX_OS_UPGRADE_MAP.md` (partial_implementation; release proof)
  - `SA01_SA32_SOURCE_ATLAS_FULL_MATURITY_TRAIN` — `docs/codex/batch-trains/SA01_SA32_SOURCE_ATLAS_FULL_MATURITY_TRAIN.md` (partial_implementation; release proof)
  - `GATE_SYSTEM_HARDENING_NEXT_PROMPT` — `docs/codex/batches/GATE_SYSTEM_HARDENING_NEXT_PROMPT.md` (partial_implementation; release proof)
  - `SOURCE_ATLAS_RESEARCH_SEEDS_V1_IMPORT_PROMPT` — `docs/codex/batches/SOURCE_ATLAS_RESEARCH_SEEDS_V1_IMPORT_PROMPT.md` (unknown; release proof)

### 278. Same source file targeted by multiple active items: Native/Ambitions/Features/Goals/GoalsFeatureService.swift

- Candidate ID: `AMB28-same_source_file_targeted_by_multiple_active_batches-21600714`
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
  - `MOAT-GOAL-REALITY-GOALS-BRIDGE-05` — `prompts/batches/MOAT-GOAL-REALITY-GOALS-BRIDGE-05.md` (partial_implementation; release proof)

### 279. Same source file targeted by multiple active items: scripts/fet-primitive-density-scan.sh

- Candidate ID: `AMB28-same_source_file_targeted_by_multiple_active_batches-21604483`
- Evidence type: `same_source_file_targeted_by_multiple_active_batches`
- Severity: `yellow`
- Recommended action: `Merge`
- Linear-ready: `True`
- Auto-resolved: `False`
- Reason: Multiple active work items target the same source file; merge or sequence ownership before implementation.
- Involved active paths:
  - `GLOBAL_BATCH_AUTOMATED_GATE_PROTOCOL` — `docs/codex/GLOBAL_BATCH_AUTOMATED_GATE_PROTOCOL.md` (partial_implementation; release proof)
  - `FAANG_FRONTEND_IMPLEMENTATION_OPERATING_SYSTEM` — `docs/codex/FAANG_FRONTEND_IMPLEMENTATION_OPERATING_SYSTEM.md` (partial_implementation; release proof)
  - `FET01_FET12_FAANG_FRONTEND_EXCELLENCE_TRAIN` — `docs/codex/batch-trains/FET01_FET12_FAANG_FRONTEND_EXCELLENCE_TRAIN.md` (partial_implementation; release proof)
  - `FET00_FAANG_FRONTEND_CODEX_OS_UPGRADE_PROMPT` — `docs/codex/batches/FET00_FAANG_FRONTEND_CODEX_OS_UPGRADE_PROMPT.md` (partial_implementation; release proof)

### 280. Same source file targeted by multiple active items: scripts/ai/acx_repair.py

- Candidate ID: `AMB28-same_source_file_targeted_by_multiple_active_batches-21802874`
- Evidence type: `same_source_file_targeted_by_multiple_active_batches`
- Severity: `yellow`
- Recommended action: `Merge`
- Linear-ready: `True`
- Auto-resolved: `False`
- Reason: Multiple active work items target the same source file; merge or sequence ownership before implementation.
- Involved active paths:
  - `CODEX_OS_ENGINE_SUPPLEMENT_2026_05_08` — `docs/codex/CODEX_OS_ENGINE_SUPPLEMENT_2026_05_08.md` (partial_implementation; release proof)
  - `CODEX_OS_REPAIR_SPEED_PROOF_UPGRADE_AUDIT_2026_05_08` — `docs/codex/CODEX_OS_REPAIR_SPEED_PROOF_UPGRADE_AUDIT_2026_05_08.md` (partial_implementation; release proof)
  - `PK01_Package_Module_Boundary_Scaffold` — `docs/codex/batches/PK01_Package_Module_Boundary_Scaffold.md` (partial_implementation; release proof)
  - `PK02_Architecture_Boundary_Scanner` — `docs/codex/batches/PK02_Architecture_Boundary_Scanner.md` (partial_implementation; release proof)
  - `CODEX_QUALITY_SYSTEM_SCRIPT_MAP` — `docs/codex/CODEX_QUALITY_SYSTEM_SCRIPT_MAP.md` (unknown; release proof)

### 281. Same source file targeted by multiple active items: Native/Ambitions/PreviewSupport/PreviewFixtures.swift

- Candidate ID: `AMB28-same_source_file_targeted_by_multiple_active_batches-2188280`
- Evidence type: `same_source_file_targeted_by_multiple_active_batches`
- Severity: `yellow`
- Recommended action: `Merge`
- Linear-ready: `True`
- Auto-resolved: `False`
- Reason: Multiple active work items target the same source file; merge or sequence ownership before implementation.
- Involved active paths:
  - `repo-audit-baseline` — `docs/codex/repo-audit-baseline.md` (partial_implementation; release proof)
  - `FLAGSHIP_COMPLETION_FILE_BOUNDARY_MAP` — `docs/codex/FLAGSHIP_COMPLETION_FILE_BOUNDARY_MAP.md` (partial_implementation; release proof)
  - `FLAGSHIP_COMPLETION_GATE_MATRIX` — `docs/codex/FLAGSHIP_COMPLETION_GATE_MATRIX.md` (partial_implementation; release proof)

### 282. Same source file targeted by multiple active items: scripts/ambitions-autonomous-train-fastpath.py

- Candidate ID: `AMB28-same_source_file_targeted_by_multiple_active_batches-22344920`
- Evidence type: `same_source_file_targeted_by_multiple_active_batches`
- Severity: `yellow`
- Recommended action: `Merge`
- Linear-ready: `True`
- Auto-resolved: `False`
- Reason: Multiple active work items target the same source file; merge or sequence ownership before implementation.
- Involved active paths:
  - `AUTONOMOUS_TRAIN_FASTPATH` — `docs/codex/AUTONOMOUS_TRAIN_FASTPATH.md` (partial_implementation; release proof)
  - `AUTONOMOUS-TRAIN-FASTPATH-01` — `prompts/batches/AUTONOMOUS-TRAIN-FASTPATH-01.md` (partial_implementation; release proof)

### 283. Same source file targeted by multiple active items: scripts/batch-train-gate-check.sh

- Candidate ID: `AMB28-same_source_file_targeted_by_multiple_active_batches-22647572`
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
  - `AOS01_AmbitionsOS_Canon_And_Runtime_Contract_Prompt` — `docs/codex/batches/AOS01_AmbitionsOS_Canon_And_Runtime_Contract_Prompt.md` (partial_implementation; release proof)
  - `AOS02_Life_Graph_Event_Log_Foundation_Prompt` — `docs/codex/batches/AOS02_Life_Graph_Event_Log_Foundation_Prompt.md` (partial_implementation; release proof)
  - `AOS03_Graph_Delta_Review_Projection_Store_Prompt` — `docs/codex/batches/AOS03_Graph_Delta_Review_Projection_Store_Prompt.md` (partial_implementation; release proof)
  - `AOS04_Control_Plane_Work_Classifier_Prompt` — `docs/codex/batches/AOS04_Control_Plane_Work_Classifier_Prompt.md` (partial_implementation; release proof)
  - `AOS05_Starting_Position_Kernel_Prompt` — `docs/codex/batches/AOS05_Starting_Position_Kernel_Prompt.md` (partial_implementation; release proof)
  - `AOS06_Goal_Path_Kernel_Goal_Compiler_Prompt` — `docs/codex/batches/AOS06_Goal_Path_Kernel_Goal_Compiler_Prompt.md` (partial_implementation; release proof)
  - `AOS07_Local_Goal_Packs_Requirement_Slots_Prompt` — `docs/codex/batches/AOS07_Local_Goal_Packs_Requirement_Slots_Prompt.md` (partial_implementation; release proof)
  - ... 184 more

### 284. Same source file targeted by multiple active items: Native/Ambitions/Features/Today/DayRailViewState.swift

- Candidate ID: `AMB28-same_source_file_targeted_by_multiple_active_batches-23326226`
- Evidence type: `same_source_file_targeted_by_multiple_active_batches`
- Severity: `yellow`
- Recommended action: `Merge`
- Linear-ready: `True`
- Auto-resolved: `False`
- Reason: Multiple active work items target the same source file; merge or sequence ownership before implementation.
- Involved active paths:
  - `FLAGSHIP_COMPLETION_FILE_BOUNDARY_MAP` — `docs/codex/FLAGSHIP_COMPLETION_FILE_BOUNDARY_MAP.md` (partial_implementation; release proof)
  - `MOONSHOT_PROOF_PATH_BACKEND_MASTER_PLAN` — `docs/codex/MOONSHOT_PROOF_PATH_BACKEND_MASTER_PLAN.md` (partial_implementation; release proof)
  - `MOAT-MOONSHOT-BACKEND-FULL-TRAIN-01` — `prompts/batches/MOAT-MOONSHOT-BACKEND-FULL-TRAIN-01.md` (partial_implementation; release proof)
  - `MOAT-MOONSHOT-PROOF-PATH-01` — `prompts/batches/MOAT-MOONSHOT-PROOF-PATH-01.md` (partial_implementation; release proof)
  - `MOAT-GOAL-REALITY-TODAY-BRIDGE-06` — `prompts/batches/MOAT-GOAL-REALITY-TODAY-BRIDGE-06.md` (partial_implementation; release proof)
  - `FCP05_Start_Here_Surface_Prompt` — `docs/codex/batches/FCP05_Start_Here_Surface_Prompt.md` (unknown; release proof)
  - `FCP07_Reality_Rail_Continuity_Prompt` — `docs/codex/batches/FCP07_Reality_Rail_Continuity_Prompt.md` (unknown; release proof)

### 285. Same source file targeted by multiple active items: Native/Ambitions/Features/Today/TodayFeatureService.swift

- Candidate ID: `AMB28-same_source_file_targeted_by_multiple_active_batches-23423927`
- Evidence type: `same_source_file_targeted_by_multiple_active_batches`
- Severity: `yellow`
- Recommended action: `Merge`
- Linear-ready: `True`
- Auto-resolved: `False`
- Reason: Multiple active work items target the same source file; merge or sequence ownership before implementation.
- Involved active paths:
  - `repo-audit-baseline` — `docs/codex/repo-audit-baseline.md` (partial_implementation; release proof)
  - `BATCH-33-intelligence-runtime-integration` — `docs/codex/batches/BATCH-33-intelligence-runtime-integration.md` (partial_implementation; release proof)
  - `PK17` — `prompts/batches/PK17.md` (partial_implementation; release proof)
  - `PK18` — `prompts/batches/PK18.md` (partial_implementation; release proof)
  - `MOAT-GOAL-REALITY-TODAY-BRIDGE-06` — `prompts/batches/MOAT-GOAL-REALITY-TODAY-BRIDGE-06.md` (partial_implementation; release proof)
  - `BATCH-32-explainability-and-source-audit-surfaces` — `docs/codex/batches/BATCH-32-explainability-and-source-audit-surfaces.md` (unknown; release proof)

### 286. Same source file targeted by multiple active items: Native/AmbitionsTests/App/AppShellNavigationTests.swift

- Candidate ID: `AMB28-same_source_file_targeted_by_multiple_active_batches-23731427`
- Evidence type: `same_source_file_targeted_by_multiple_active_batches`
- Severity: `yellow`
- Recommended action: `Merge`
- Linear-ready: `True`
- Auto-resolved: `False`
- Reason: Multiple active work items target the same source file; merge or sequence ownership before implementation.
- Involved active paths:
  - `FLAGSHIP_COMPLETION_FILE_BOUNDARY_MAP` — `docs/codex/FLAGSHIP_COMPLETION_FILE_BOUNDARY_MAP.md` (partial_implementation; release proof)
  - `TOP-LEVEL-IA-PLAN-LEAK-REGRESSION-01` — `prompts/batches/TOP-LEVEL-IA-PLAN-LEAK-REGRESSION-01.md` (partial_implementation; release proof)
  - `FCP08_Ambition_Meridian_Shell_Prompt` — `docs/codex/batches/FCP08_Ambition_Meridian_Shell_Prompt.md` (unknown; release proof)

### 287. Same source file targeted by multiple active items: Native/Ambitions/Services/SmartAttachmentService.swift

- Candidate ID: `AMB28-same_source_file_targeted_by_multiple_active_batches-23876220`
- Evidence type: `same_source_file_targeted_by_multiple_active_batches`
- Severity: `yellow`
- Recommended action: `Merge`
- Linear-ready: `True`
- Auto-resolved: `False`
- Reason: Multiple active work items target the same source file; merge or sequence ownership before implementation.
- Involved active paths:
  - `TRAIN_04D_CAPTURE_RUNTIME_FACTORING_FUTURE_PROOF` — `prompts/trains/ios26-flagship/TRAIN_04D_CAPTURE_RUNTIME_FACTORING_FUTURE_PROOF.md` (partial_implementation; release proof)
  - `concept-lock-registry` — `docs/codex/concept-lock-registry.yml` (partial_implementation; tests)

### 288. Same source file targeted by multiple active items: Native/Ambitions/Domain/AmbitionsCommandModels.swift

- Candidate ID: `AMB28-same_source_file_targeted_by_multiple_active_batches-2406460`
- Evidence type: `same_source_file_targeted_by_multiple_active_batches`
- Severity: `yellow`
- Recommended action: `Merge`
- Linear-ready: `True`
- Auto-resolved: `False`
- Reason: Multiple active work items target the same source file; merge or sequence ownership before implementation.
- Involved active paths:
  - `PK18` — `prompts/batches/PK18.md` (partial_implementation; release proof)
  - `PK22` — `prompts/batches/PK22.md` (partial_implementation; release proof)
  - `existing-code-champion-coverage` — `docs/codex/existing-code-champion-coverage.yml` (unknown; release proof)

### 289. Same source file targeted by multiple active items: scripts/ldi-safety-redteam-fixture-check.py

- Candidate ID: `AMB28-same_source_file_targeted_by_multiple_active_batches-24100554`
- Evidence type: `same_source_file_targeted_by_multiple_active_batches`
- Severity: `yellow`
- Recommended action: `Merge`
- Linear-ready: `True`
- Auto-resolved: `False`
- Reason: Multiple active work items target the same source file; merge or sequence ownership before implementation.
- Involved active paths:
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
  - ... 12 more

### 290. Same source file targeted by multiple active items: scripts/ambitions-state-advance-validate.py

- Candidate ID: `AMB28-same_source_file_targeted_by_multiple_active_batches-24109853`
- Evidence type: `same_source_file_targeted_by_multiple_active_batches`
- Severity: `yellow`
- Recommended action: `Merge`
- Linear-ready: `True`
- Auto-resolved: `False`
- Reason: Multiple active work items target the same source file; merge or sequence ownership before implementation.
- Involved active paths:
  - `POST_PK_CLOSEOUT_CONTRACT` — `docs/codex/POST_PK_CLOSEOUT_CONTRACT.md` (partial_implementation; release proof)
  - `POST_PK_SPEED_TRAIN_OPERATING_MODEL` — `docs/codex/POST_PK_SPEED_TRAIN_OPERATING_MODEL.md` (unknown; release proof)

### 291. Same source file targeted by multiple active items: scripts/ambitions-xcode-test-focused.sh

- Candidate ID: `AMB28-same_source_file_targeted_by_multiple_active_batches-24456535`
- Evidence type: `same_source_file_targeted_by_multiple_active_batches`
- Severity: `yellow`
- Recommended action: `Merge`
- Linear-ready: `True`
- Auto-resolved: `False`
- Reason: Multiple active work items target the same source file; merge or sequence ownership before implementation.
- Involved active paths:
  - `XCODE-BUILD-SYSTEM-MAX-01-REPAIR-01` — `prompts/batches/XCODE-BUILD-SYSTEM-MAX-01-REPAIR-01.md` (partial_implementation; release proof)
  - `XCODE-PERF-RUNNER-MATURITY-01` — `prompts/batches/XCODE-PERF-RUNNER-MATURITY-01.md` (partial_implementation; release proof)

### 292. Same source file targeted by multiple active items: Native/Ambitions/Domain/AmbitionsOSControlPlaneModels.swift

- Candidate ID: `AMB28-same_source_file_targeted_by_multiple_active_batches-24808952`
- Evidence type: `same_source_file_targeted_by_multiple_active_batches`
- Severity: `yellow`
- Recommended action: `Merge`
- Linear-ready: `True`
- Auto-resolved: `False`
- Reason: Multiple active work items target the same source file; merge or sequence ownership before implementation.
- Involved active paths:
  - `AMBITIONSOS_AOS_TRACEABILITY_MATRIX` — `docs/codex/AMBITIONSOS_AOS_TRACEABILITY_MATRIX.md` (partial_implementation; release proof)
  - `existing-code-champion-coverage` — `docs/codex/existing-code-champion-coverage.yml` (unknown; release proof)

### 293. Same source file targeted by multiple active items: scripts/global-train-status-summary.sh

- Candidate ID: `AMB28-same_source_file_targeted_by_multiple_active_batches-24813387`
- Evidence type: `same_source_file_targeted_by_multiple_active_batches`
- Severity: `yellow`
- Recommended action: `Merge`
- Linear-ready: `True`
- Auto-resolved: `False`
- Reason: Multiple active work items target the same source file; merge or sequence ownership before implementation.
- Involved active paths:
  - `GLOBAL_PATCH_TRAIN_INTERRUPTED_RUN_RECOVERY_PROTOCOL` — `docs/codex/GLOBAL_PATCH_TRAIN_INTERRUPTED_RUN_RECOVERY_PROTOCOL.md` (partial_implementation; release proof)
  - `TIME_REPLACES_PLAN_COMPATIBILITY_LEDGER` — `docs/codex/TIME_REPLACES_PLAN_COMPATIBILITY_LEDGER.md` (partial_implementation; release proof)

### 294. Same source file targeted by multiple active items: scripts/openai-build-suite-dry-run.py

- Candidate ID: `AMB28-same_source_file_targeted_by_multiple_active_batches-24854560`
- Evidence type: `same_source_file_targeted_by_multiple_active_batches`
- Severity: `yellow`
- Recommended action: `Merge`
- Linear-ready: `True`
- Auto-resolved: `False`
- Reason: Multiple active work items target the same source file; merge or sequence ownership before implementation.
- Involved active paths:
  - `OBS00-OPENAI-BUILD-SUITE-INSTALL` — `prompts/batches/OBS00-OPENAI-BUILD-SUITE-INSTALL.md` (partial_implementation; release proof)
  - `OBS06-SPEED-TRAIN-INTEGRATION` — `prompts/batches/OBS06-SPEED-TRAIN-INTEGRATION.md` (partial_implementation; release proof)
  - `CODEX_MULTI_AGENT_BUILD_SYSTEM` — `docs/codex/CODEX_MULTI_AGENT_BUILD_SYSTEM.md` (unknown; release proof)

### 295. Same source file targeted by multiple active items: Native/AmbitionsTests/Persistence/PreMigrationBackupTests.swift

- Candidate ID: `AMB28-same_source_file_targeted_by_multiple_active_batches-24962709`
- Evidence type: `same_source_file_targeted_by_multiple_active_batches`
- Severity: `yellow`
- Recommended action: `Merge`
- Linear-ready: `True`
- Auto-resolved: `False`
- Reason: Multiple active work items target the same source file; merge or sequence ownership before implementation.
- Involved active paths:
  - `BACKEND-FINAL-FORM-LOCAL-FIRST-HUMAN-01` — `prompts/batches/BACKEND-FINAL-FORM-LOCAL-FIRST-HUMAN-01.md` (partial_implementation; release proof)
  - `MOAT-GOAL-REALITY-LOCAL-PERSISTENCE-08` — `prompts/batches/MOAT-GOAL-REALITY-LOCAL-PERSISTENCE-08.md` (partial_implementation; release proof)

### 296. Same source file targeted by multiple active items: Native/Ambitions/Runtime/GoalRealitySourceBoundaryService.swift

- Candidate ID: `AMB28-same_source_file_targeted_by_multiple_active_batches-25124030`
- Evidence type: `same_source_file_targeted_by_multiple_active_batches`
- Severity: `yellow`
- Recommended action: `Merge`
- Linear-ready: `True`
- Auto-resolved: `False`
- Reason: Multiple active work items target the same source file; merge or sequence ownership before implementation.
- Involved active paths:
  - `MOAT-GOAL-REALITY-EVAL-HARNESS-10` — `prompts/batches/MOAT-GOAL-REALITY-EVAL-HARNESS-10.md` (partial_implementation; release proof)
  - `MOAT-GOAL-REALITY-SOURCE-PACKS-09` — `prompts/batches/MOAT-GOAL-REALITY-SOURCE-PACKS-09.md` (partial_implementation; release proof)

### 297. Same source file targeted by multiple active items: scripts/ambitions-xcode-validate.sh

- Candidate ID: `AMB28-same_source_file_targeted_by_multiple_active_batches-25147666`
- Evidence type: `same_source_file_targeted_by_multiple_active_batches`
- Severity: `yellow`
- Recommended action: `Merge`
- Linear-ready: `True`
- Auto-resolved: `False`
- Reason: Multiple active work items target the same source file; merge or sequence ownership before implementation.
- Involved active paths:
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
  - ... 22 more

### 298. Same source file targeted by multiple active items: scripts/ambitions-visual-100-object-depth-check.py

- Candidate ID: `AMB28-same_source_file_targeted_by_multiple_active_batches-25523626`
- Evidence type: `same_source_file_targeted_by_multiple_active_batches`
- Severity: `yellow`
- Recommended action: `Merge`
- Linear-ready: `True`
- Auto-resolved: `False`
- Reason: Multiple active work items target the same source file; merge or sequence ownership before implementation.
- Involved active paths:
  - `VISUAL-ENCYCLOPEDIA-100-PROOF-HARDENING-03` — `prompts/batches/VISUAL-ENCYCLOPEDIA-100-PROOF-HARDENING-03.md` (partial_implementation; release proof)
  - `FLAGSHIP-OBJECT-SYSTEM-01` — `prompts/batches/FLAGSHIP-OBJECT-SYSTEM-01.md` (partial_implementation; release proof)

### 299. Same source file targeted by multiple active items: Native/Ambitions/Persistence/StorageSchemaVersionLedger.swift

- Candidate ID: `AMB28-same_source_file_targeted_by_multiple_active_batches-2563443`
- Evidence type: `same_source_file_targeted_by_multiple_active_batches`
- Severity: `yellow`
- Recommended action: `Merge`
- Linear-ready: `True`
- Auto-resolved: `False`
- Reason: Multiple active work items target the same source file; merge or sequence ownership before implementation.
- Involved active paths:
  - `PK22` — `prompts/batches/PK22.md` (partial_implementation; release proof)
  - `BACKEND-FINAL-FORM-LOCAL-FIRST-HUMAN-01` — `prompts/batches/BACKEND-FINAL-FORM-LOCAL-FIRST-HUMAN-01.md` (partial_implementation; release proof)
  - `AMB-POST23-01-TRUTH-AUDIT` — `docs/codex/reports/AMB-POST23-01-TRUTH-AUDIT.md` (partial_implementation; release proof)

### 300. Same source file targeted by multiple active items: Native/AmbitionsTests/App/TrustReceiptLayerDesignSystemTests.swift

- Candidate ID: `AMB28-same_source_file_targeted_by_multiple_active_batches-26131842`
- Evidence type: `same_source_file_targeted_by_multiple_active_batches`
- Severity: `yellow`
- Recommended action: `Merge`
- Linear-ready: `True`
- Auto-resolved: `False`
- Reason: Multiple active work items target the same source file; merge or sequence ownership before implementation.
- Involved active paths:
  - `FLAGSHIP_COMPLETION_FILE_BOUNDARY_MAP` — `docs/codex/FLAGSHIP_COMPLETION_FILE_BOUNDARY_MAP.md` (partial_implementation; release proof)
  - `FCP06_Receipt_Drawer_Trust_Layer_Prompt` — `docs/codex/batches/FCP06_Receipt_Drawer_Trust_Layer_Prompt.md` (partial_implementation; release proof)

- ... 442 more active candidates in JSON

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
