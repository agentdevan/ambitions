# Active Canon Collapse Candidates

Status: GREEN
Generated UTC: 2026-05-28T23:32:01Z
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

- Active candidates: `1736`
- Historical-only residue: `0`
- Red active candidates: `9`
- Auto-resolved candidates: `0`

### Active candidates by action

- `Expedite`: `310`
- `Finish proof`: `166`
- `Merge`: `302`
- `Rewrite`: `958`

### Active candidates by conflict type

- `duplicate_stable_id`: `32`
- `missing_source_of_truth_reference`: `549`
- `retired_ia_or_terminology_reference`: `409`
- `same_source_file_targeted_by_multiple_active_batches`: `270`
- `same_surface_multiple_active_batches`: `6`
- `source_only_implementation_missing_proof`: `321`
- `stale_or_unknown_active_status`: `149`

## Next bounded action bundle

- Bundle ID: `canon-collapse-red-rewrite-bundle`
- Title: Rewrite active Red retired IA / terminology references
- Recommended action: `Rewrite`
- Candidate count: `9`
- Reason: Red retired IA/terminology references should be resolved before broader canon cleanup.

### Bundle candidate IDs

- `AMB28-retired_ia_or_terminology_reference-13863842`
- `AMB28-retired_ia_or_terminology_reference-17888445`
- `AMB28-retired_ia_or_terminology_reference-19737023`
- `AMB28-retired_ia_or_terminology_reference-22316819`
- `AMB28-retired_ia_or_terminology_reference-23384468`
- `AMB28-retired_ia_or_terminology_reference-60941764`
- `AMB28-retired_ia_or_terminology_reference-73887307`
- `AMB28-retired_ia_or_terminology_reference-76790714`
- `AMB28-retired_ia_or_terminology_reference-8000313`

### Bundle repo paths

- `docs/codex/batches/BATCH-01-pre-phase9-cleanup-and-captures-tab.md`
- `docs/codex/batches/BATCH-04-canon-batch-2-first-class-capture-core.md`
- `docs/codex/batches/BATCH-35-post-2.0-hardening-shell-truth-navigation-and-plan-canon-recovery.md`
- `docs/codex/repo-audit-baseline.md`
- `prompts/batches/FRONTEND-SURFACE-RECIPE-COMPLETENESS-REVIEW-001.md`
- `prompts/batches/IR-01-FRONTEND-RECOVERY-GATE.md`
- `prompts/batches/SHELL-CONTINUITY-DOCK-MATERIALS-01.md`
- `prompts/batches/TOP-LEVEL-IA-PLAN-LEAK-REGRESSION-01.md`
- `prompts/batches/amb-fe-be/FE-06-SHELL-MIGRATION.md`

## Active candidates

### 1. Retired IA/terminology reference in BATCH-35-post-2.0-hardening-shell-truth-navigation-and-plan-canon-recovery

- Candidate ID: `AMB28-retired_ia_or_terminology_reference-13863842`
- Evidence type: `retired_ia_or_terminology_reference`
- Severity: `red`
- Recommended action: `Rewrite`
- Linear-ready: `True`
- Auto-resolved: `False`
- Reason: Active item contains retired IA, retired terminology, or unsafe language; rewrite or retire before reuse.
- Involved active paths:
  - `BATCH-35-post-2.0-hardening-shell-truth-navigation-and-plan-canon-recovery` — `docs/codex/batches/BATCH-35-post-2.0-hardening-shell-truth-navigation-and-plan-canon-recovery.md` (unknown; audit)

### 2. Retired IA/terminology reference in FE-06-SHELL-MIGRATION

- Candidate ID: `AMB28-retired_ia_or_terminology_reference-17888445`
- Evidence type: `retired_ia_or_terminology_reference`
- Severity: `red`
- Recommended action: `Rewrite`
- Linear-ready: `True`
- Auto-resolved: `False`
- Reason: Active item contains retired IA, retired terminology, or unsafe language; rewrite or retire before reuse.
- Involved active paths:
  - `FE-06-SHELL-MIGRATION` — `prompts/batches/amb-fe-be/FE-06-SHELL-MIGRATION.md` (partial_implementation; screenshot)

### 3. Retired IA/terminology reference in BATCH-01-pre-phase9-cleanup-and-captures-tab

- Candidate ID: `AMB28-retired_ia_or_terminology_reference-19737023`
- Evidence type: `retired_ia_or_terminology_reference`
- Severity: `red`
- Recommended action: `Rewrite`
- Linear-ready: `True`
- Auto-resolved: `False`
- Reason: Active item contains retired IA, retired terminology, or unsafe language; rewrite or retire before reuse.
- Involved active paths:
  - `BATCH-01-pre-phase9-cleanup-and-captures-tab` — `docs/codex/batches/BATCH-01-pre-phase9-cleanup-and-captures-tab.md` (partial_implementation; source-only)

### 4. Retired IA/terminology reference in BATCH-04-canon-batch-2-first-class-capture-core

- Candidate ID: `AMB28-retired_ia_or_terminology_reference-22316819`
- Evidence type: `retired_ia_or_terminology_reference`
- Severity: `red`
- Recommended action: `Rewrite`
- Linear-ready: `True`
- Auto-resolved: `False`
- Reason: Active item contains retired IA, retired terminology, or unsafe language; rewrite or retire before reuse.
- Involved active paths:
  - `BATCH-04-canon-batch-2-first-class-capture-core` — `docs/codex/batches/BATCH-04-canon-batch-2-first-class-capture-core.md` (unknown; audit)

### 5. Retired IA/terminology reference in repo-audit-baseline

- Candidate ID: `AMB28-retired_ia_or_terminology_reference-23384468`
- Evidence type: `retired_ia_or_terminology_reference`
- Severity: `red`
- Recommended action: `Rewrite`
- Linear-ready: `True`
- Auto-resolved: `False`
- Reason: Active item contains retired IA, retired terminology, or unsafe language; rewrite or retire before reuse.
- Involved active paths:
  - `repo-audit-baseline` — `docs/codex/repo-audit-baseline.md` (partial_implementation; audit)

### 6. Retired IA/terminology reference in TOP-LEVEL-IA-PLAN-LEAK-REGRESSION-01

- Candidate ID: `AMB28-retired_ia_or_terminology_reference-60941764`
- Evidence type: `retired_ia_or_terminology_reference`
- Severity: `red`
- Recommended action: `Rewrite`
- Linear-ready: `True`
- Auto-resolved: `False`
- Reason: Active item contains retired IA, retired terminology, or unsafe language; rewrite or retire before reuse.
- Involved active paths:
  - `TOP-LEVEL-IA-PLAN-LEAK-REGRESSION-01` — `prompts/batches/TOP-LEVEL-IA-PLAN-LEAK-REGRESSION-01.md` (partial_implementation; tests)

### 7. Retired IA/terminology reference in IR-01-FRONTEND-RECOVERY-GATE

- Candidate ID: `AMB28-retired_ia_or_terminology_reference-73887307`
- Evidence type: `retired_ia_or_terminology_reference`
- Severity: `red`
- Recommended action: `Rewrite`
- Linear-ready: `True`
- Auto-resolved: `False`
- Reason: Active item contains retired IA, retired terminology, or unsafe language; rewrite or retire before reuse.
- Involved active paths:
  - `IR-01-FRONTEND-RECOVERY-GATE` — `prompts/batches/IR-01-FRONTEND-RECOVERY-GATE.md` (partial_implementation; release proof)

### 8. Retired IA/terminology reference in FRONTEND-SURFACE-RECIPE-COMPLETENESS-REVIEW-001

- Candidate ID: `AMB28-retired_ia_or_terminology_reference-76790714`
- Evidence type: `retired_ia_or_terminology_reference`
- Severity: `red`
- Recommended action: `Rewrite`
- Linear-ready: `True`
- Auto-resolved: `False`
- Reason: Active item contains retired IA, retired terminology, or unsafe language; rewrite or retire before reuse.
- Involved active paths:
  - `FRONTEND-SURFACE-RECIPE-COMPLETENESS-REVIEW-001` — `prompts/batches/FRONTEND-SURFACE-RECIPE-COMPLETENESS-REVIEW-001.md` (partial_implementation; release proof)

### 9. Retired IA/terminology reference in SHELL-CONTINUITY-DOCK-MATERIALS-01

- Candidate ID: `AMB28-retired_ia_or_terminology_reference-8000313`
- Evidence type: `retired_ia_or_terminology_reference`
- Severity: `red`
- Recommended action: `Rewrite`
- Linear-ready: `True`
- Auto-resolved: `False`
- Reason: Active item contains retired IA, retired terminology, or unsafe language; rewrite or retire before reuse.
- Involved active paths:
  - `SHELL-CONTINUITY-DOCK-MATERIALS-01` — `prompts/batches/SHELL-CONTINUITY-DOCK-MATERIALS-01.md` (partial_implementation; source-only)

### 10. Retired IA/terminology reference in SOURCE_ATLAS_HPS_AOS_LDI_INTEGRATION_MAP

- Candidate ID: `AMB28-retired_ia_or_terminology_reference-1034979`
- Evidence type: `retired_ia_or_terminology_reference`
- Severity: `yellow`
- Recommended action: `Rewrite`
- Linear-ready: `True`
- Auto-resolved: `False`
- Reason: Active item contains retired IA, retired terminology, or unsafe language; rewrite or retire before reuse.
- Involved active paths:
  - `SOURCE_ATLAS_HPS_AOS_LDI_INTEGRATION_MAP` — `docs/codex/SOURCE_ATLAS_HPS_AOS_LDI_INTEGRATION_MAP.md` (unknown; release proof)

### 11. Retired IA/terminology reference in AOS16_Performance_Energy_Kernel_Prompt

- Candidate ID: `AMB28-retired_ia_or_terminology_reference-10357279`
- Evidence type: `retired_ia_or_terminology_reference`
- Severity: `yellow`
- Recommended action: `Rewrite`
- Linear-ready: `True`
- Auto-resolved: `False`
- Reason: Active item contains retired IA, retired terminology, or unsafe language; rewrite or retire before reuse.
- Involved active paths:
  - `AOS16_Performance_Energy_Kernel_Prompt` — `docs/codex/batches/AOS16_Performance_Energy_Kernel_Prompt.md` (partial_implementation; release proof)

### 12. Retired IA/terminology reference in PD14_Life_Shape_Drilldowns_Prompt

- Candidate ID: `AMB28-retired_ia_or_terminology_reference-10534679`
- Evidence type: `retired_ia_or_terminology_reference`
- Severity: `yellow`
- Recommended action: `Rewrite`
- Linear-ready: `True`
- Auto-resolved: `False`
- Reason: Active item contains retired IA, retired terminology, or unsafe language; rewrite or retire before reuse.
- Involved active paths:
  - `PD14_Life_Shape_Drilldowns_Prompt` — `docs/codex/batches/PD14_Life_Shape_Drilldowns_Prompt.md` (partial_implementation; release proof)

### 13. Retired IA/terminology reference in AOS21_Interoperability_Kernel_App_Intents_EventKit_Planning_Prompt

- Candidate ID: `AMB28-retired_ia_or_terminology_reference-10569272`
- Evidence type: `retired_ia_or_terminology_reference`
- Severity: `yellow`
- Recommended action: `Rewrite`
- Linear-ready: `True`
- Auto-resolved: `False`
- Reason: Active item contains retired IA, retired terminology, or unsafe language; rewrite or retire before reuse.
- Involved active paths:
  - `AOS21_Interoperability_Kernel_App_Intents_EventKit_Planning_Prompt` — `docs/codex/batches/AOS21_Interoperability_Kernel_App_Intents_EventKit_Planning_Prompt.md` (partial_implementation; release proof)

### 14. Retired IA/terminology reference in parallel-guard-concept-registry

- Candidate ID: `AMB28-retired_ia_or_terminology_reference-11207138`
- Evidence type: `retired_ia_or_terminology_reference`
- Severity: `yellow`
- Recommended action: `Rewrite`
- Linear-ready: `True`
- Auto-resolved: `False`
- Reason: Active item contains retired IA, retired terminology, or unsafe language; rewrite or retire before reuse.
- Involved active paths:
  - `parallel-guard-concept-registry` — `docs/codex/parallel-guard-concept-registry.yml` (partial_implementation; source-only)

### 15. Retired IA/terminology reference in LDI22

- Candidate ID: `AMB28-retired_ia_or_terminology_reference-11294046`
- Evidence type: `retired_ia_or_terminology_reference`
- Severity: `yellow`
- Recommended action: `Rewrite`
- Linear-ready: `True`
- Auto-resolved: `False`
- Reason: Active item contains retired IA, retired terminology, or unsafe language; rewrite or retire before reuse.
- Involved active paths:
  - `LDI22` — `prompts/batches/LDI22.md` (partial_implementation; release proof)

### 16. Retired IA/terminology reference in PD12_Plan_Reflow_Decision_Depth_Prompt

- Candidate ID: `AMB28-retired_ia_or_terminology_reference-12033540`
- Evidence type: `retired_ia_or_terminology_reference`
- Severity: `yellow`
- Recommended action: `Rewrite`
- Linear-ready: `True`
- Auto-resolved: `False`
- Reason: Active item contains retired IA, retired terminology, or unsafe language; rewrite or retire before reuse.
- Involved active paths:
  - `PD12_Plan_Reflow_Decision_Depth_Prompt` — `docs/codex/batches/PD12_Plan_Reflow_Decision_Depth_Prompt.md` (partial_implementation; release proof)

### 17. Retired IA/terminology reference in PK36

- Candidate ID: `AMB28-retired_ia_or_terminology_reference-12483270`
- Evidence type: `retired_ia_or_terminology_reference`
- Severity: `yellow`
- Recommended action: `Rewrite`
- Linear-ready: `True`
- Auto-resolved: `False`
- Reason: Active item contains retired IA, retired terminology, or unsafe language; rewrite or retire before reuse.
- Involved active paths:
  - `PK36` — `prompts/batches/PK36.md` (partial_implementation; release proof)

### 18. Retired IA/terminology reference in PD11_Grow_Into_Goal_Flow_Prompt

- Candidate ID: `AMB28-retired_ia_or_terminology_reference-12496465`
- Evidence type: `retired_ia_or_terminology_reference`
- Severity: `yellow`
- Recommended action: `Rewrite`
- Linear-ready: `True`
- Auto-resolved: `False`
- Reason: Active item contains retired IA, retired terminology, or unsafe language; rewrite or retire before reuse.
- Involved active paths:
  - `PD11_Grow_Into_Goal_Flow_Prompt` — `docs/codex/batches/PD11_Grow_Into_Goal_Flow_Prompt.md` (partial_implementation; release proof)

### 19. Retired IA/terminology reference in PFC35

- Candidate ID: `AMB28-retired_ia_or_terminology_reference-1268172`
- Evidence type: `retired_ia_or_terminology_reference`
- Severity: `yellow`
- Recommended action: `Rewrite`
- Linear-ready: `True`
- Auto-resolved: `False`
- Reason: Active item contains retired IA, retired terminology, or unsafe language; rewrite or retire before reuse.
- Involved active paths:
  - `PFC35` — `prompts/batches/PFC35.md` (partial_implementation; release proof)

### 20. Retired IA/terminology reference in SA23

- Candidate ID: `AMB28-retired_ia_or_terminology_reference-12814656`
- Evidence type: `retired_ia_or_terminology_reference`
- Severity: `yellow`
- Recommended action: `Rewrite`
- Linear-ready: `True`
- Auto-resolved: `False`
- Reason: Active item contains retired IA, retired terminology, or unsafe language; rewrite or retire before reuse.
- Involved active paths:
  - `SA23` — `prompts/batches/SA23.md` (partial_implementation; release proof)

### 21. Retired IA/terminology reference in FCP05_Start_Here_Surface_Prompt

- Candidate ID: `AMB28-retired_ia_or_terminology_reference-12918610`
- Evidence type: `retired_ia_or_terminology_reference`
- Severity: `yellow`
- Recommended action: `Rewrite`
- Linear-ready: `True`
- Auto-resolved: `False`
- Reason: Active item contains retired IA, retired terminology, or unsafe language; rewrite or retire before reuse.
- Involved active paths:
  - `FCP05_Start_Here_Surface_Prompt` — `docs/codex/batches/FCP05_Start_Here_Surface_Prompt.md` (unknown; release proof)

### 22. Retired IA/terminology reference in FRONTEND_TOP_LEVEL_SURFACE_COMPOSITION_GATE

- Candidate ID: `AMB28-retired_ia_or_terminology_reference-12933031`
- Evidence type: `retired_ia_or_terminology_reference`
- Severity: `yellow`
- Recommended action: `Rewrite`
- Linear-ready: `True`
- Auto-resolved: `False`
- Reason: Active item contains retired IA, retired terminology, or unsafe language; rewrite or retire before reuse.
- Involved active paths:
  - `FRONTEND_TOP_LEVEL_SURFACE_COMPOSITION_GATE` — `docs/codex/FRONTEND_TOP_LEVEL_SURFACE_COMPOSITION_GATE.md` (unknown; screenshot)

### 23. Retired IA/terminology reference in OS-FLAGSHIP-04-VISUAL-QA-GATE

- Candidate ID: `AMB28-retired_ia_or_terminology_reference-12983646`
- Evidence type: `retired_ia_or_terminology_reference`
- Severity: `yellow`
- Recommended action: `Rewrite`
- Linear-ready: `True`
- Auto-resolved: `False`
- Reason: Active item contains retired IA, retired terminology, or unsafe language; rewrite or retire before reuse.
- Involved active paths:
  - `OS-FLAGSHIP-04-VISUAL-QA-GATE` — `prompts/batches/OS-FLAGSHIP-04-VISUAL-QA-GATE.md` (partial_implementation; screenshot)

### 24. Retired IA/terminology reference in EB30_Overloaded_Day_Adaptation_And_Low_Cognitive_Load_Flows_Prompt

- Candidate ID: `AMB28-retired_ia_or_terminology_reference-13000781`
- Evidence type: `retired_ia_or_terminology_reference`
- Severity: `yellow`
- Recommended action: `Rewrite`
- Linear-ready: `True`
- Auto-resolved: `False`
- Reason: Active item contains retired IA, retired terminology, or unsafe language; rewrite or retire before reuse.
- Involved active paths:
  - `EB30_Overloaded_Day_Adaptation_And_Low_Cognitive_Load_Flows_Prompt` — `docs/codex/batches/EB30_Overloaded_Day_Adaptation_And_Low_Cognitive_Load_Flows_Prompt.md` (partial_implementation; release proof)

### 25. Retired IA/terminology reference in HPS01_HPS12_HUMAN_PROGRESS_SYSTEMS_UPGRADE_TRAIN

- Candidate ID: `AMB28-retired_ia_or_terminology_reference-1302258`
- Evidence type: `retired_ia_or_terminology_reference`
- Severity: `yellow`
- Recommended action: `Rewrite`
- Linear-ready: `True`
- Auto-resolved: `False`
- Reason: Active item contains retired IA, retired terminology, or unsafe language; rewrite or retire before reuse.
- Involved active paths:
  - `HPS01_HPS12_HUMAN_PROGRESS_SYSTEMS_UPGRADE_TRAIN` — `docs/codex/batch-trains/HPS01_HPS12_HUMAN_PROGRESS_SYSTEMS_UPGRADE_TRAIN.md` (partial_implementation; audit)

### 26. Retired IA/terminology reference in PD15_You_Trust_History_And_Receipts_Center_Prompt

- Candidate ID: `AMB28-retired_ia_or_terminology_reference-13296087`
- Evidence type: `retired_ia_or_terminology_reference`
- Severity: `yellow`
- Recommended action: `Rewrite`
- Linear-ready: `True`
- Auto-resolved: `False`
- Reason: Active item contains retired IA, retired terminology, or unsafe language; rewrite or retire before reuse.
- Involved active paths:
  - `PD15_You_Trust_History_And_Receipts_Center_Prompt` — `docs/codex/batches/PD15_You_Trust_History_And_Receipts_Center_Prompt.md` (partial_implementation; release proof)

### 27. Retired IA/terminology reference in PD02_Today_Step_Detail_Depth_Prompt

- Candidate ID: `AMB28-retired_ia_or_terminology_reference-13301918`
- Evidence type: `retired_ia_or_terminology_reference`
- Severity: `yellow`
- Recommended action: `Rewrite`
- Linear-ready: `True`
- Auto-resolved: `False`
- Reason: Active item contains retired IA, retired terminology, or unsafe language; rewrite or retire before reuse.
- Involved active paths:
  - `PD02_Today_Step_Detail_Depth_Prompt` — `docs/codex/batches/PD02_Today_Step_Detail_Depth_Prompt.md` (partial_implementation; release proof)

### 28. Retired IA/terminology reference in MOAT-MOONSHOT-BACKEND-FULL-TRAIN-01

- Candidate ID: `AMB28-retired_ia_or_terminology_reference-13571798`
- Evidence type: `retired_ia_or_terminology_reference`
- Severity: `yellow`
- Recommended action: `Rewrite`
- Linear-ready: `True`
- Auto-resolved: `False`
- Reason: Active item contains retired IA, retired terminology, or unsafe language; rewrite or retire before reuse.
- Involved active paths:
  - `MOAT-MOONSHOT-BACKEND-FULL-TRAIN-01` — `prompts/batches/MOAT-MOONSHOT-BACKEND-FULL-TRAIN-01.md` (partial_implementation; release proof)

### 29. Retired IA/terminology reference in OBJECT_OS_PRIMITIVES

- Candidate ID: `AMB28-retired_ia_or_terminology_reference-13773400`
- Evidence type: `retired_ia_or_terminology_reference`
- Severity: `yellow`
- Recommended action: `Rewrite`
- Linear-ready: `True`
- Auto-resolved: `False`
- Reason: Active item contains retired IA, retired terminology, or unsafe language; rewrite or retire before reuse.
- Involved active paths:
  - `OBJECT_OS_PRIMITIVES` — `docs/codex/OBJECT_OS_PRIMITIVES.md` (partial_implementation; source-only)

### 30. Retired IA/terminology reference in LDI20

- Candidate ID: `AMB28-retired_ia_or_terminology_reference-13852412`
- Evidence type: `retired_ia_or_terminology_reference`
- Severity: `yellow`
- Recommended action: `Rewrite`
- Linear-ready: `True`
- Auto-resolved: `False`
- Reason: Active item contains retired IA, retired terminology, or unsafe language; rewrite or retire before reuse.
- Involved active paths:
  - `LDI20` — `prompts/batches/LDI20.md` (partial_implementation; release proof)

### 31. Retired IA/terminology reference in RHC01

- Candidate ID: `AMB28-retired_ia_or_terminology_reference-14035831`
- Evidence type: `retired_ia_or_terminology_reference`
- Severity: `yellow`
- Recommended action: `Rewrite`
- Linear-ready: `True`
- Auto-resolved: `False`
- Reason: Active item contains retired IA, retired terminology, or unsafe language; rewrite or retire before reuse.
- Involved active paths:
  - `RHC01` — `prompts/batches/RHC01.md` (partial_implementation; release proof)

### 32. Retired IA/terminology reference in CODEX_OS_PEAK_OPERATING_PROTOCOL

- Candidate ID: `AMB28-retired_ia_or_terminology_reference-14280243`
- Evidence type: `retired_ia_or_terminology_reference`
- Severity: `yellow`
- Recommended action: `Rewrite`
- Linear-ready: `True`
- Auto-resolved: `False`
- Reason: Active item contains retired IA, retired terminology, or unsafe language; rewrite or retire before reuse.
- Involved active paths:
  - `CODEX_OS_PEAK_OPERATING_PROTOCOL` — `docs/codex/CODEX_OS_PEAK_OPERATING_PROTOCOL.md` (partial_implementation; release proof)

### 33. Retired IA/terminology reference in AMB-CODEX-OS-FLAGSHIP-UPGRADE-INSTALL-01

- Candidate ID: `AMB28-retired_ia_or_terminology_reference-14380356`
- Evidence type: `retired_ia_or_terminology_reference`
- Severity: `yellow`
- Recommended action: `Rewrite`
- Linear-ready: `True`
- Auto-resolved: `False`
- Reason: Active item contains retired IA, retired terminology, or unsafe language; rewrite or retire before reuse.
- Involved active paths:
  - `AMB-CODEX-OS-FLAGSHIP-UPGRADE-INSTALL-01` — `prompts/batches/AMB-CODEX-OS-FLAGSHIP-UPGRADE-INSTALL-01.md` (partial_implementation; release proof)

### 34. Retired IA/terminology reference in EB31_Cross_Kernel_Primitives_And_Event_Receipts_Prompt

- Candidate ID: `AMB28-retired_ia_or_terminology_reference-14548371`
- Evidence type: `retired_ia_or_terminology_reference`
- Severity: `yellow`
- Recommended action: `Rewrite`
- Linear-ready: `True`
- Auto-resolved: `False`
- Reason: Active item contains retired IA, retired terminology, or unsafe language; rewrite or retire before reuse.
- Involved active paths:
  - `EB31_Cross_Kernel_Primitives_And_Event_Receipts_Prompt` — `docs/codex/batches/EB31_Cross_Kernel_Primitives_And_Event_Receipts_Prompt.md` (partial_implementation; release proof)

### 35. Retired IA/terminology reference in VISUAL_CANON_MOAT_IMPLEMENTATION_OVERLAY

- Candidate ID: `AMB28-retired_ia_or_terminology_reference-14568441`
- Evidence type: `retired_ia_or_terminology_reference`
- Severity: `yellow`
- Recommended action: `Rewrite`
- Linear-ready: `True`
- Auto-resolved: `False`
- Reason: Active item contains retired IA, retired terminology, or unsafe language; rewrite or retire before reuse.
- Involved active paths:
  - `VISUAL_CANON_MOAT_IMPLEMENTATION_OVERLAY` — `docs/codex/VISUAL_CANON_MOAT_IMPLEMENTATION_OVERLAY.md` (partial_implementation; release proof)

### 36. Retired IA/terminology reference in PX02_Today_Experience_Operating_Surface_Prompt

- Candidate ID: `AMB28-retired_ia_or_terminology_reference-14836161`
- Evidence type: `retired_ia_or_terminology_reference`
- Severity: `yellow`
- Recommended action: `Rewrite`
- Linear-ready: `True`
- Auto-resolved: `False`
- Reason: Active item contains retired IA, retired terminology, or unsafe language; rewrite or retire before reuse.
- Involved active paths:
  - `PX02_Today_Experience_Operating_Surface_Prompt` — `docs/codex/batches/PX02_Today_Experience_Operating_Surface_Prompt.md` (partial_implementation; release proof)

### 37. Retired IA/terminology reference in AMBITIONSOS_AOS_GOVERNANCE_KERNEL_REGISTRY

- Candidate ID: `AMB28-retired_ia_or_terminology_reference-15039223`
- Evidence type: `retired_ia_or_terminology_reference`
- Severity: `yellow`
- Recommended action: `Rewrite`
- Linear-ready: `True`
- Auto-resolved: `False`
- Reason: Active item contains retired IA, retired terminology, or unsafe language; rewrite or retire before reuse.
- Involved active paths:
  - `AMBITIONSOS_AOS_GOVERNANCE_KERNEL_REGISTRY` — `docs/codex/AMBITIONSOS_AOS_GOVERNANCE_KERNEL_REGISTRY.md` (partial_implementation; release proof)

### 38. Retired IA/terminology reference in LDI17

- Candidate ID: `AMB28-retired_ia_or_terminology_reference-15409882`
- Evidence type: `retired_ia_or_terminology_reference`
- Severity: `yellow`
- Recommended action: `Rewrite`
- Linear-ready: `True`
- Auto-resolved: `False`
- Reason: Active item contains retired IA, retired terminology, or unsafe language; rewrite or retire before reuse.
- Involved active paths:
  - `LDI17` — `prompts/batches/LDI17.md` (partial_implementation; release proof)

### 39. Retired IA/terminology reference in MASTER_CODEX_SYSTEM

- Candidate ID: `AMB28-retired_ia_or_terminology_reference-15801087`
- Evidence type: `retired_ia_or_terminology_reference`
- Severity: `yellow`
- Recommended action: `Rewrite`
- Linear-ready: `True`
- Auto-resolved: `False`
- Reason: Active item contains retired IA, retired terminology, or unsafe language; rewrite or retire before reuse.
- Involved active paths:
  - `MASTER_CODEX_SYSTEM` — `docs/codex/MASTER_CODEX_SYSTEM.md` (partial_implementation; release proof)

### 40. Retired IA/terminology reference in PK18

- Candidate ID: `AMB28-retired_ia_or_terminology_reference-15845704`
- Evidence type: `retired_ia_or_terminology_reference`
- Severity: `yellow`
- Recommended action: `Rewrite`
- Linear-ready: `True`
- Auto-resolved: `False`
- Reason: Active item contains retired IA, retired terminology, or unsafe language; rewrite or retire before reuse.
- Involved active paths:
  - `PK18` — `prompts/batches/PK18.md` (partial_implementation; release proof)

### 41. Retired IA/terminology reference in FVQ_VISUAL_EXCELLENCE_CONTINUATION_PROMPT

- Candidate ID: `AMB28-retired_ia_or_terminology_reference-16201348`
- Evidence type: `retired_ia_or_terminology_reference`
- Severity: `yellow`
- Recommended action: `Rewrite`
- Linear-ready: `True`
- Auto-resolved: `False`
- Reason: Active item contains retired IA, retired terminology, or unsafe language; rewrite or retire before reuse.
- Involved active paths:
  - `FVQ_VISUAL_EXCELLENCE_CONTINUATION_PROMPT` — `docs/codex/batches/FVQ_VISUAL_EXCELLENCE_CONTINUATION_PROMPT.md` (partial_implementation; release proof)

### 42. Retired IA/terminology reference in OBJECT_FRONTEND_GREEN_YELLOW_RED_RUBRIC

- Candidate ID: `AMB28-retired_ia_or_terminology_reference-16449959`
- Evidence type: `retired_ia_or_terminology_reference`
- Severity: `yellow`
- Recommended action: `Rewrite`
- Linear-ready: `True`
- Auto-resolved: `False`
- Reason: Active item contains retired IA, retired terminology, or unsafe language; rewrite or retire before reuse.
- Involved active paths:
  - `OBJECT_FRONTEND_GREEN_YELLOW_RED_RUBRIC` — `docs/codex/frontend/OBJECT_FRONTEND_GREEN_YELLOW_RED_RUBRIC.md` (partial_implementation; screenshot)

### 43. Retired IA/terminology reference in AMBITIONS_OBJECT_OS_CANON

- Candidate ID: `AMB28-retired_ia_or_terminology_reference-16656341`
- Evidence type: `retired_ia_or_terminology_reference`
- Severity: `yellow`
- Recommended action: `Rewrite`
- Linear-ready: `True`
- Auto-resolved: `False`
- Reason: Active item contains retired IA, retired terminology, or unsafe language; rewrite or retire before reuse.
- Involved active paths:
  - `AMBITIONS_OBJECT_OS_CANON` — `docs/codex/AMBITIONS_OBJECT_OS_CANON.md` (partial_implementation; release proof)

### 44. Retired IA/terminology reference in PX01_PX20_PRODUCT_EXPERIENCE_OS_TRAIN

- Candidate ID: `AMB28-retired_ia_or_terminology_reference-1684400`
- Evidence type: `retired_ia_or_terminology_reference`
- Severity: `yellow`
- Recommended action: `Rewrite`
- Linear-ready: `True`
- Auto-resolved: `False`
- Reason: Active item contains retired IA, retired terminology, or unsafe language; rewrite or retire before reuse.
- Involved active paths:
  - `PX01_PX20_PRODUCT_EXPERIENCE_OS_TRAIN` — `docs/codex/batch-trains/PX01_PX20_PRODUCT_EXPERIENCE_OS_TRAIN.md` (partial_implementation; release proof)

### 45. Retired IA/terminology reference in MODEL_TIER_EXECUTION_POLICY

- Candidate ID: `AMB28-retired_ia_or_terminology_reference-16929114`
- Evidence type: `retired_ia_or_terminology_reference`
- Severity: `yellow`
- Recommended action: `Rewrite`
- Linear-ready: `True`
- Auto-resolved: `False`
- Reason: Active item contains retired IA, retired terminology, or unsafe language; rewrite or retire before reuse.
- Involved active paths:
  - `MODEL_TIER_EXECUTION_POLICY` — `docs/codex/MODEL_TIER_EXECUTION_POLICY.md` (partial_implementation; release proof)

### 46. Retired IA/terminology reference in PD06_Goal_Lifecycle_And_Path_Visualization_Prompt

- Candidate ID: `AMB28-retired_ia_or_terminology_reference-17048159`
- Evidence type: `retired_ia_or_terminology_reference`
- Severity: `yellow`
- Recommended action: `Rewrite`
- Linear-ready: `True`
- Auto-resolved: `False`
- Reason: Active item contains retired IA, retired terminology, or unsafe language; rewrite or retire before reuse.
- Involved active paths:
  - `PD06_Goal_Lifecycle_And_Path_Visualization_Prompt` — `docs/codex/batches/PD06_Goal_Lifecycle_And_Path_Visualization_Prompt.md` (partial_implementation; release proof)

### 47. Retired IA/terminology reference in PX08_Trust_Proof_Receipts_Experience_Prompt

- Candidate ID: `AMB28-retired_ia_or_terminology_reference-17238458`
- Evidence type: `retired_ia_or_terminology_reference`
- Severity: `yellow`
- Recommended action: `Rewrite`
- Linear-ready: `True`
- Auto-resolved: `False`
- Reason: Active item contains retired IA, retired terminology, or unsafe language; rewrite or retire before reuse.
- Involved active paths:
  - `PX08_Trust_Proof_Receipts_Experience_Prompt` — `docs/codex/batches/PX08_Trust_Proof_Receipts_Experience_Prompt.md` (partial_implementation; release proof)

### 48. Retired IA/terminology reference in EB25_Accessibility_Cognitive_Load_Canon_Prompt

- Candidate ID: `AMB28-retired_ia_or_terminology_reference-17400961`
- Evidence type: `retired_ia_or_terminology_reference`
- Severity: `yellow`
- Recommended action: `Rewrite`
- Linear-ready: `True`
- Auto-resolved: `False`
- Reason: Active item contains retired IA, retired terminology, or unsafe language; rewrite or retire before reuse.
- Involved active paths:
  - `EB25_Accessibility_Cognitive_Load_Canon_Prompt` — `docs/codex/batches/EB25_Accessibility_Cognitive_Load_Canon_Prompt.md` (partial_implementation; release proof)

### 49. Retired IA/terminology reference in PXEQ_LIVING_INTERFACE_RUBRIC

- Candidate ID: `AMB28-retired_ia_or_terminology_reference-17565959`
- Evidence type: `retired_ia_or_terminology_reference`
- Severity: `yellow`
- Recommended action: `Rewrite`
- Linear-ready: `True`
- Auto-resolved: `False`
- Reason: Active item contains retired IA, retired terminology, or unsafe language; rewrite or retire before reuse.
- Involved active paths:
  - `PXEQ_LIVING_INTERFACE_RUBRIC` — `docs/codex/PXEQ_LIVING_INTERFACE_RUBRIC.md` (partial_implementation; source-only)

### 50. Retired IA/terminology reference in AOS01_AmbitionsOS_Canon_And_Runtime_Contract_Prompt

- Candidate ID: `AMB28-retired_ia_or_terminology_reference-17624074`
- Evidence type: `retired_ia_or_terminology_reference`
- Severity: `yellow`
- Recommended action: `Rewrite`
- Linear-ready: `True`
- Auto-resolved: `False`
- Reason: Active item contains retired IA, retired terminology, or unsafe language; rewrite or retire before reuse.
- Involved active paths:
  - `AOS01_AmbitionsOS_Canon_And_Runtime_Contract_Prompt` — `docs/codex/batches/AOS01_AmbitionsOS_Canon_And_Runtime_Contract_Prompt.md` (partial_implementation; release proof)

### 51. Retired IA/terminology reference in AFI07_Goals_Constellation_Atlas

- Candidate ID: `AMB28-retired_ia_or_terminology_reference-17825817`
- Evidence type: `retired_ia_or_terminology_reference`
- Severity: `yellow`
- Recommended action: `Rewrite`
- Linear-ready: `True`
- Auto-resolved: `False`
- Reason: Active item contains retired IA, retired terminology, or unsafe language; rewrite or retire before reuse.
- Involved active paths:
  - `AFI07_Goals_Constellation_Atlas` — `docs/codex/batches/AFI07_Goals_Constellation_Atlas.md` (partial_implementation; tests)

### 52. Retired IA/terminology reference in SA10

- Candidate ID: `AMB28-retired_ia_or_terminology_reference-18305020`
- Evidence type: `retired_ia_or_terminology_reference`
- Severity: `yellow`
- Recommended action: `Rewrite`
- Linear-ready: `True`
- Auto-resolved: `False`
- Reason: Active item contains retired IA, retired terminology, or unsafe language; rewrite or retire before reuse.
- Involved active paths:
  - `SA10` — `prompts/batches/SA10.md` (partial_implementation; release proof)

### 53. Retired IA/terminology reference in SI05_Hero_Step_Panel_System_Prompt

- Candidate ID: `AMB28-retired_ia_or_terminology_reference-1868304`
- Evidence type: `retired_ia_or_terminology_reference`
- Severity: `yellow`
- Recommended action: `Rewrite`
- Linear-ready: `True`
- Auto-resolved: `False`
- Reason: Active item contains retired IA, retired terminology, or unsafe language; rewrite or retire before reuse.
- Involved active paths:
  - `SI05_Hero_Step_Panel_System_Prompt` — `docs/codex/batches/SI05_Hero_Step_Panel_System_Prompt.md` (partial_implementation; release proof)

### 54. Retired IA/terminology reference in LDI_INVARIANT_LEDGER

- Candidate ID: `AMB28-retired_ia_or_terminology_reference-18740806`
- Evidence type: `retired_ia_or_terminology_reference`
- Severity: `yellow`
- Recommended action: `Rewrite`
- Linear-ready: `True`
- Auto-resolved: `False`
- Reason: Active item contains retired IA, retired terminology, or unsafe language; rewrite or retire before reuse.
- Involved active paths:
  - `LDI_INVARIANT_LEDGER` — `docs/codex/LDI_INVARIANT_LEDGER.md` (partial_implementation; source-only)

### 55. Retired IA/terminology reference in PK32

- Candidate ID: `AMB28-retired_ia_or_terminology_reference-19094101`
- Evidence type: `retired_ia_or_terminology_reference`
- Severity: `yellow`
- Recommended action: `Rewrite`
- Linear-ready: `True`
- Auto-resolved: `False`
- Reason: Active item contains retired IA, retired terminology, or unsafe language; rewrite or retire before reuse.
- Involved active paths:
  - `PK32` — `prompts/batches/PK32.md` (partial_implementation; release proof)

### 56. Retired IA/terminology reference in existing-code-champion-coverage

- Candidate ID: `AMB28-retired_ia_or_terminology_reference-19109748`
- Evidence type: `retired_ia_or_terminology_reference`
- Severity: `yellow`
- Recommended action: `Rewrite`
- Linear-ready: `True`
- Auto-resolved: `False`
- Reason: Active item contains retired IA, retired terminology, or unsafe language; rewrite or retire before reuse.
- Involved active paths:
  - `existing-code-champion-coverage` — `docs/codex/existing-code-champion-coverage.yml` (unknown; release proof)

### 57. Retired IA/terminology reference in EB23_Maturity_Levels_Progressive_Disclosure_And_Life_Season_Templates_Prompt

- Candidate ID: `AMB28-retired_ia_or_terminology_reference-19185629`
- Evidence type: `retired_ia_or_terminology_reference`
- Severity: `yellow`
- Recommended action: `Rewrite`
- Linear-ready: `True`
- Auto-resolved: `False`
- Reason: Active item contains retired IA, retired terminology, or unsafe language; rewrite or retire before reuse.
- Involved active paths:
  - `EB23_Maturity_Levels_Progressive_Disclosure_And_Life_Season_Templates_Prompt` — `docs/codex/batches/EB23_Maturity_Levels_Progressive_Disclosure_And_Life_Season_Templates_Prompt.md` (partial_implementation; release proof)

### 58. Retired IA/terminology reference in AOS22_Longevity_Kernel_Archive_Aging_Prompt

- Candidate ID: `AMB28-retired_ia_or_terminology_reference-193320`
- Evidence type: `retired_ia_or_terminology_reference`
- Severity: `yellow`
- Recommended action: `Rewrite`
- Linear-ready: `True`
- Auto-resolved: `False`
- Reason: Active item contains retired IA, retired terminology, or unsafe language; rewrite or retire before reuse.
- Involved active paths:
  - `AOS22_Longevity_Kernel_Archive_Aging_Prompt` — `docs/codex/batches/AOS22_Longevity_Kernel_Archive_Aging_Prompt.md` (partial_implementation; release proof)

### 59. Retired IA/terminology reference in FL03_Commitment_Memory_Open_Loop_Registry_Prompt

- Candidate ID: `AMB28-retired_ia_or_terminology_reference-19400657`
- Evidence type: `retired_ia_or_terminology_reference`
- Severity: `yellow`
- Recommended action: `Rewrite`
- Linear-ready: `True`
- Auto-resolved: `False`
- Reason: Active item contains retired IA, retired terminology, or unsafe language; rewrite or retire before reuse.
- Involved active paths:
  - `FL03_Commitment_Memory_Open_Loop_Registry_Prompt` — `docs/codex/batches/FL03_Commitment_Memory_Open_Loop_Registry_Prompt.md` (unknown; audit)

### 60. Retired IA/terminology reference in FCP27

- Candidate ID: `AMB28-retired_ia_or_terminology_reference-19511677`
- Evidence type: `retired_ia_or_terminology_reference`
- Severity: `yellow`
- Recommended action: `Rewrite`
- Linear-ready: `True`
- Auto-resolved: `False`
- Reason: Active item contains retired IA, retired terminology, or unsafe language; rewrite or retire before reuse.
- Involved active paths:
  - `FCP27` — `prompts/batches/FCP27.md` (partial_implementation; release proof)

### 61. Retired IA/terminology reference in FCP30

- Candidate ID: `AMB28-retired_ia_or_terminology_reference-19834592`
- Evidence type: `retired_ia_or_terminology_reference`
- Severity: `yellow`
- Recommended action: `Rewrite`
- Linear-ready: `True`
- Auto-resolved: `False`
- Reason: Active item contains retired IA, retired terminology, or unsafe language; rewrite or retire before reuse.
- Involved active paths:
  - `FCP30` — `prompts/batches/FCP30.md` (partial_implementation; release proof)

### 62. Retired IA/terminology reference in FVQ_VISUAL_EXCELLENCE_TRAIN

- Candidate ID: `AMB28-retired_ia_or_terminology_reference-20053664`
- Evidence type: `retired_ia_or_terminology_reference`
- Severity: `yellow`
- Recommended action: `Rewrite`
- Linear-ready: `True`
- Auto-resolved: `False`
- Reason: Active item contains retired IA, retired terminology, or unsafe language; rewrite or retire before reuse.
- Involved active paths:
  - `FVQ_VISUAL_EXCELLENCE_TRAIN` — `docs/codex/visual-quality/FVQ_VISUAL_EXCELLENCE_TRAIN.md` (partial_implementation; release proof)

### 63. Retired IA/terminology reference in PD16_Schedule_Availability_And_Planning_Defaults_Depth_Prompt

- Candidate ID: `AMB28-retired_ia_or_terminology_reference-20366313`
- Evidence type: `retired_ia_or_terminology_reference`
- Severity: `yellow`
- Recommended action: `Rewrite`
- Linear-ready: `True`
- Auto-resolved: `False`
- Reason: Active item contains retired IA, retired terminology, or unsafe language; rewrite or retire before reuse.
- Involved active paths:
  - `PD16_Schedule_Availability_And_Planning_Defaults_Depth_Prompt` — `docs/codex/batches/PD16_Schedule_Availability_And_Planning_Defaults_Depth_Prompt.md` (partial_implementation; release proof)

### 64. Retired IA/terminology reference in GOAL_REALITY_COMPILER_BACKEND_MASTER_PLAN

- Candidate ID: `AMB28-retired_ia_or_terminology_reference-20384811`
- Evidence type: `retired_ia_or_terminology_reference`
- Severity: `yellow`
- Recommended action: `Rewrite`
- Linear-ready: `True`
- Auto-resolved: `False`
- Reason: Active item contains retired IA, retired terminology, or unsafe language; rewrite or retire before reuse.
- Involved active paths:
  - `GOAL_REALITY_COMPILER_BACKEND_MASTER_PLAN` — `docs/codex/GOAL_REALITY_COMPILER_BACKEND_MASTER_PLAN.md` (partial_implementation; tests)

### 65. Retired IA/terminology reference in SIG01_SIG16_SIGNATURE_EXPERIENCE_LAYER_TRAIN

- Candidate ID: `AMB28-retired_ia_or_terminology_reference-20974700`
- Evidence type: `retired_ia_or_terminology_reference`
- Severity: `yellow`
- Recommended action: `Rewrite`
- Linear-ready: `True`
- Auto-resolved: `False`
- Reason: Active item contains retired IA, retired terminology, or unsafe language; rewrite or retire before reuse.
- Involved active paths:
  - `SIG01_SIG16_SIGNATURE_EXPERIENCE_LAYER_TRAIN` — `docs/codex/batch-trains/SIG01_SIG16_SIGNATURE_EXPERIENCE_LAYER_TRAIN.md` (unknown; release proof)

### 66. Retired IA/terminology reference in PK22

- Candidate ID: `AMB28-retired_ia_or_terminology_reference-21451679`
- Evidence type: `retired_ia_or_terminology_reference`
- Severity: `yellow`
- Recommended action: `Rewrite`
- Linear-ready: `True`
- Auto-resolved: `False`
- Reason: Active item contains retired IA, retired terminology, or unsafe language; rewrite or retire before reuse.
- Involved active paths:
  - `PK22` — `prompts/batches/PK22.md` (partial_implementation; release proof)

### 67. Retired IA/terminology reference in SOURCE_ATLAS_COMPOSITION_GOAL_PROJECTION_MODEL

- Candidate ID: `AMB28-retired_ia_or_terminology_reference-22109933`
- Evidence type: `retired_ia_or_terminology_reference`
- Severity: `yellow`
- Recommended action: `Rewrite`
- Linear-ready: `True`
- Auto-resolved: `False`
- Reason: Active item contains retired IA, retired terminology, or unsafe language; rewrite or retire before reuse.
- Involved active paths:
  - `SOURCE_ATLAS_COMPOSITION_GOAL_PROJECTION_MODEL` — `docs/codex/SOURCE_ATLAS_COMPOSITION_GOAL_PROJECTION_MODEL.md` (unknown; release proof)

### 68. Retired IA/terminology reference in LDI01_LDI22_LIVING_DREAM_INTELLIGENCE_TRAIN

- Candidate ID: `AMB28-retired_ia_or_terminology_reference-22370153`
- Evidence type: `retired_ia_or_terminology_reference`
- Severity: `yellow`
- Recommended action: `Rewrite`
- Linear-ready: `True`
- Auto-resolved: `False`
- Reason: Active item contains retired IA, retired terminology, or unsafe language; rewrite or retire before reuse.
- Involved active paths:
  - `LDI01_LDI22_LIVING_DREAM_INTELLIGENCE_TRAIN` — `docs/codex/batch-trains/LDI01_LDI22_LIVING_DREAM_INTELLIGENCE_TRAIN.md` (partial_implementation; release proof)

### 69. Retired IA/terminology reference in FVQ04_RECURRING_UI_BATCH_RENDERED_PROOF_PROTOCOL

- Candidate ID: `AMB28-retired_ia_or_terminology_reference-2261207`
- Evidence type: `retired_ia_or_terminology_reference`
- Severity: `yellow`
- Recommended action: `Rewrite`
- Linear-ready: `True`
- Auto-resolved: `False`
- Reason: Active item contains retired IA, retired terminology, or unsafe language; rewrite or retire before reuse.
- Involved active paths:
  - `FVQ04_RECURRING_UI_BATCH_RENDERED_PROOF_PROTOCOL` — `docs/codex/visual-quality/FVQ04_RECURRING_UI_BATCH_RENDERED_PROOF_PROTOCOL.md` (partial_implementation; release proof)

### 70. Retired IA/terminology reference in AIR_INVENTION_PRESERVATION_MATRIX

- Candidate ID: `AMB28-retired_ia_or_terminology_reference-23045180`
- Evidence type: `retired_ia_or_terminology_reference`
- Severity: `yellow`
- Recommended action: `Rewrite`
- Linear-ready: `True`
- Auto-resolved: `False`
- Reason: Active item contains retired IA, retired terminology, or unsafe language; rewrite or retire before reuse.
- Involved active paths:
  - `AIR_INVENTION_PRESERVATION_MATRIX` — `docs/codex/AIR_INVENTION_PRESERVATION_MATRIX.md` (partial_implementation; release proof)

### 71. Retired IA/terminology reference in AOS29

- Candidate ID: `AMB28-retired_ia_or_terminology_reference-23128155`
- Evidence type: `retired_ia_or_terminology_reference`
- Severity: `yellow`
- Recommended action: `Rewrite`
- Linear-ready: `True`
- Auto-resolved: `False`
- Reason: Active item contains retired IA, retired terminology, or unsafe language; rewrite or retire before reuse.
- Involved active paths:
  - `AOS29` — `prompts/batches/AOS29.md` (partial_implementation; release proof)

### 72. Retired IA/terminology reference in MEG01_ADVANCED_RENDERING_ELIGIBILITY_GATE

- Candidate ID: `AMB28-retired_ia_or_terminology_reference-23458078`
- Evidence type: `retired_ia_or_terminology_reference`
- Severity: `yellow`
- Recommended action: `Rewrite`
- Linear-ready: `True`
- Auto-resolved: `False`
- Reason: Active item contains retired IA, retired terminology, or unsafe language; rewrite or retire before reuse.
- Involved active paths:
  - `MEG01_ADVANCED_RENDERING_ELIGIBILITY_GATE` — `docs/codex/visual-quality/MEG01_ADVANCED_RENDERING_ELIGIBILITY_GATE.md` (partial_implementation; release proof)

### 73. Retired IA/terminology reference in SA13

- Candidate ID: `AMB28-retired_ia_or_terminology_reference-23458991`
- Evidence type: `retired_ia_or_terminology_reference`
- Severity: `yellow`
- Recommended action: `Rewrite`
- Linear-ready: `True`
- Auto-resolved: `False`
- Reason: Active item contains retired IA, retired terminology, or unsafe language; rewrite or retire before reuse.
- Involved active paths:
  - `SA13` — `prompts/batches/SA13.md` (partial_implementation; release proof)

### 74. Retired IA/terminology reference in MOAT_RUNTIME_ACCEPTANCE_CRITERIA

- Candidate ID: `AMB28-retired_ia_or_terminology_reference-23570149`
- Evidence type: `retired_ia_or_terminology_reference`
- Severity: `yellow`
- Recommended action: `Rewrite`
- Linear-ready: `True`
- Auto-resolved: `False`
- Reason: Active item contains retired IA, retired terminology, or unsafe language; rewrite or retire before reuse.
- Involved active paths:
  - `MOAT_RUNTIME_ACCEPTANCE_CRITERIA` — `docs/codex/MOAT_RUNTIME_ACCEPTANCE_CRITERIA.md` (partial_implementation; audit)

### 75. Retired IA/terminology reference in EB32_Cross_Kernel_Dependency_And_Gate_Integration_Prompt

- Candidate ID: `AMB28-retired_ia_or_terminology_reference-23880071`
- Evidence type: `retired_ia_or_terminology_reference`
- Severity: `yellow`
- Recommended action: `Rewrite`
- Linear-ready: `True`
- Auto-resolved: `False`
- Reason: Active item contains retired IA, retired terminology, or unsafe language; rewrite or retire before reuse.
- Involved active paths:
  - `EB32_Cross_Kernel_Dependency_And_Gate_Integration_Prompt` — `docs/codex/batches/EB32_Cross_Kernel_Dependency_And_Gate_Integration_Prompt.md` (partial_implementation; release proof)

### 76. Retired IA/terminology reference in EB07_Life_Memory_Graph_Canon_And_Domain_Model_Prompt

- Candidate ID: `AMB28-retired_ia_or_terminology_reference-24151675`
- Evidence type: `retired_ia_or_terminology_reference`
- Severity: `yellow`
- Recommended action: `Rewrite`
- Linear-ready: `True`
- Auto-resolved: `False`
- Reason: Active item contains retired IA, retired terminology, or unsafe language; rewrite or retire before reuse.
- Involved active paths:
  - `EB07_Life_Memory_Graph_Canon_And_Domain_Model_Prompt` — `docs/codex/batches/EB07_Life_Memory_Graph_Canon_And_Domain_Model_Prompt.md` (partial_implementation; release proof)

### 77. Retired IA/terminology reference in AFI09_Time_LifeShape_Field

- Candidate ID: `AMB28-retired_ia_or_terminology_reference-24189342`
- Evidence type: `retired_ia_or_terminology_reference`
- Severity: `yellow`
- Recommended action: `Rewrite`
- Linear-ready: `True`
- Auto-resolved: `False`
- Reason: Active item contains retired IA, retired terminology, or unsafe language; rewrite or retire before reuse.
- Involved active paths:
  - `AFI09_Time_LifeShape_Field` — `docs/codex/batches/AFI09_Time_LifeShape_Field.md` (partial_implementation; release proof)

### 78. Retired IA/terminology reference in CHROME-AUDIT-01

- Candidate ID: `AMB28-retired_ia_or_terminology_reference-24221599`
- Evidence type: `retired_ia_or_terminology_reference`
- Severity: `yellow`
- Recommended action: `Rewrite`
- Linear-ready: `True`
- Auto-resolved: `False`
- Reason: Active item contains retired IA, retired terminology, or unsafe language; rewrite or retire before reuse.
- Involved active paths:
  - `CHROME-AUDIT-01` — `prompts/batches/CHROME-AUDIT-01.md` (partial_implementation; release proof)

### 79. Retired IA/terminology reference in PFC40

- Candidate ID: `AMB28-retired_ia_or_terminology_reference-24268889`
- Evidence type: `retired_ia_or_terminology_reference`
- Severity: `yellow`
- Recommended action: `Rewrite`
- Linear-ready: `True`
- Auto-resolved: `False`
- Reason: Active item contains retired IA, retired terminology, or unsafe language; rewrite or retire before reuse.
- Involved active paths:
  - `PFC40` — `prompts/batches/PFC40.md` (partial_implementation; release proof)

### 80. Retired IA/terminology reference in AOS04_Control_Plane_Work_Classifier_Prompt

- Candidate ID: `AMB28-retired_ia_or_terminology_reference-24407357`
- Evidence type: `retired_ia_or_terminology_reference`
- Severity: `yellow`
- Recommended action: `Rewrite`
- Linear-ready: `True`
- Auto-resolved: `False`
- Reason: Active item contains retired IA, retired terminology, or unsafe language; rewrite or retire before reuse.
- Involved active paths:
  - `AOS04_Control_Plane_Work_Classifier_Prompt` — `docs/codex/batches/AOS04_Control_Plane_Work_Classifier_Prompt.md` (partial_implementation; release proof)

### 81. Retired IA/terminology reference in PD13_Plan_Recovery_And_Pressure_Review_Prompt

- Candidate ID: `AMB28-retired_ia_or_terminology_reference-24666856`
- Evidence type: `retired_ia_or_terminology_reference`
- Severity: `yellow`
- Recommended action: `Rewrite`
- Linear-ready: `True`
- Auto-resolved: `False`
- Reason: Active item contains retired IA, retired terminology, or unsafe language; rewrite or retire before reuse.
- Involved active paths:
  - `PD13_Plan_Recovery_And_Pressure_Review_Prompt` — `docs/codex/batches/PD13_Plan_Recovery_And_Pressure_Review_Prompt.md` (partial_implementation; release proof)

### 82. Retired IA/terminology reference in EB13_Trust_Privacy_User_Control_Canon_Prompt

- Candidate ID: `AMB28-retired_ia_or_terminology_reference-24743389`
- Evidence type: `retired_ia_or_terminology_reference`
- Severity: `yellow`
- Recommended action: `Rewrite`
- Linear-ready: `True`
- Auto-resolved: `False`
- Reason: Active item contains retired IA, retired terminology, or unsafe language; rewrite or retire before reuse.
- Involved active paths:
  - `EB13_Trust_Privacy_User_Control_Canon_Prompt` — `docs/codex/batches/EB13_Trust_Privacy_User_Control_Canon_Prompt.md` (partial_implementation; release proof)

### 83. Retired IA/terminology reference in AOS27_AmbitionsOS_App_Store_Claim_Truth_Prompt

- Candidate ID: `AMB28-retired_ia_or_terminology_reference-25107861`
- Evidence type: `retired_ia_or_terminology_reference`
- Severity: `yellow`
- Recommended action: `Rewrite`
- Linear-ready: `True`
- Auto-resolved: `False`
- Reason: Active item contains retired IA, retired terminology, or unsafe language; rewrite or retire before reuse.
- Involved active paths:
  - `AOS27_AmbitionsOS_App_Store_Claim_Truth_Prompt` — `docs/codex/batches/AOS27_AmbitionsOS_App_Store_Claim_Truth_Prompt.md` (partial_implementation; release proof)

### 84. Retired IA/terminology reference in PFC32

- Candidate ID: `AMB28-retired_ia_or_terminology_reference-25213032`
- Evidence type: `retired_ia_or_terminology_reference`
- Severity: `yellow`
- Recommended action: `Rewrite`
- Linear-ready: `True`
- Auto-resolved: `False`
- Reason: Active item contains retired IA, retired terminology, or unsafe language; rewrite or retire before reuse.
- Involved active paths:
  - `PFC32` — `prompts/batches/PFC32.md` (partial_implementation; release proof)

### 85. Retired IA/terminology reference in DAV05_Plan_LifeShapeMap_And_CapacityVisuals_Implementation_Prompt

- Candidate ID: `AMB28-retired_ia_or_terminology_reference-25375273`
- Evidence type: `retired_ia_or_terminology_reference`
- Severity: `yellow`
- Recommended action: `Rewrite`
- Linear-ready: `True`
- Auto-resolved: `False`
- Reason: Active item contains retired IA, retired terminology, or unsafe language; rewrite or retire before reuse.
- Involved active paths:
  - `DAV05_Plan_LifeShapeMap_And_CapacityVisuals_Implementation_Prompt` — `docs/codex/batches/DAV05_Plan_LifeShapeMap_And_CapacityVisuals_Implementation_Prompt.md` (partial_implementation; source-only)

### 86. Retired IA/terminology reference in DAV_DYNAMIC_VISUAL_SOURCE_TRUTH_AND_SURFACE_MAP

- Candidate ID: `AMB28-retired_ia_or_terminology_reference-25493303`
- Evidence type: `retired_ia_or_terminology_reference`
- Severity: `yellow`
- Recommended action: `Rewrite`
- Linear-ready: `True`
- Auto-resolved: `False`
- Reason: Active item contains retired IA, retired terminology, or unsafe language; rewrite or retire before reuse.
- Involved active paths:
  - `DAV_DYNAMIC_VISUAL_SOURCE_TRUTH_AND_SURFACE_MAP` — `docs/codex/DAV_DYNAMIC_VISUAL_SOURCE_TRUTH_AND_SURFACE_MAP.md` (partial_implementation; release proof)

### 87. Retired IA/terminology reference in UI-STUDIO-03-REALITY-MERIDIAN-ART-DIRECTION

- Candidate ID: `AMB28-retired_ia_or_terminology_reference-25875049`
- Evidence type: `retired_ia_or_terminology_reference`
- Severity: `yellow`
- Recommended action: `Rewrite`
- Linear-ready: `True`
- Auto-resolved: `False`
- Reason: Active item contains retired IA, retired terminology, or unsafe language; rewrite or retire before reuse.
- Involved active paths:
  - `UI-STUDIO-03-REALITY-MERIDIAN-ART-DIRECTION` — `prompts/batches/ui-flagship/UI-STUDIO-03-REALITY-MERIDIAN-ART-DIRECTION.md` (partial_implementation; audit)

### 88. Retired IA/terminology reference in MOAT-GOAL-REALITY-GOALS-BRIDGE-05

- Candidate ID: `AMB28-retired_ia_or_terminology_reference-25991940`
- Evidence type: `retired_ia_or_terminology_reference`
- Severity: `yellow`
- Recommended action: `Rewrite`
- Linear-ready: `True`
- Auto-resolved: `False`
- Reason: Active item contains retired IA, retired terminology, or unsafe language; rewrite or retire before reuse.
- Involved active paths:
  - `MOAT-GOAL-REALITY-GOALS-BRIDGE-05` — `prompts/batches/MOAT-GOAL-REALITY-GOALS-BRIDGE-05.md` (partial_implementation; release proof)

### 89. Retired IA/terminology reference in SA27

- Candidate ID: `AMB28-retired_ia_or_terminology_reference-26142636`
- Evidence type: `retired_ia_or_terminology_reference`
- Severity: `yellow`
- Recommended action: `Rewrite`
- Linear-ready: `True`
- Auto-resolved: `False`
- Reason: Active item contains retired IA, retired terminology, or unsafe language; rewrite or retire before reuse.
- Involved active paths:
  - `SA27` — `prompts/batches/SA27.md` (partial_implementation; release proof)

### 90. Retired IA/terminology reference in PD03_Today_Step_Session_Depth_Prompt

- Candidate ID: `AMB28-retired_ia_or_terminology_reference-26360152`
- Evidence type: `retired_ia_or_terminology_reference`
- Severity: `yellow`
- Recommended action: `Rewrite`
- Linear-ready: `True`
- Auto-resolved: `False`
- Reason: Active item contains retired IA, retired terminology, or unsafe language; rewrite or retire before reuse.
- Involved active paths:
  - `PD03_Today_Step_Session_Depth_Prompt` — `docs/codex/batches/PD03_Today_Step_Session_Depth_Prompt.md` (partial_implementation; release proof)

### 91. Retired IA/terminology reference in FRONTEND_PRIMITIVE_MISUSE_AND_DENSITY_GATE

- Candidate ID: `AMB28-retired_ia_or_terminology_reference-26470256`
- Evidence type: `retired_ia_or_terminology_reference`
- Severity: `yellow`
- Recommended action: `Rewrite`
- Linear-ready: `True`
- Auto-resolved: `False`
- Reason: Active item contains retired IA, retired terminology, or unsafe language; rewrite or retire before reuse.
- Involved active paths:
  - `FRONTEND_PRIMITIVE_MISUSE_AND_DENSITY_GATE` — `docs/codex/FRONTEND_PRIMITIVE_MISUSE_AND_DENSITY_GATE.md` (unknown; screenshot)

### 92. Retired IA/terminology reference in EB29_Voice_First_Operation_And_Motor_Accessibility_Prompt

- Candidate ID: `AMB28-retired_ia_or_terminology_reference-26658954`
- Evidence type: `retired_ia_or_terminology_reference`
- Severity: `yellow`
- Recommended action: `Rewrite`
- Linear-ready: `True`
- Auto-resolved: `False`
- Reason: Active item contains retired IA, retired terminology, or unsafe language; rewrite or retire before reuse.
- Involved active paths:
  - `EB29_Voice_First_Operation_And_Motor_Accessibility_Prompt` — `docs/codex/batches/EB29_Voice_First_Operation_And_Motor_Accessibility_Prompt.md` (partial_implementation; release proof)

### 93. Retired IA/terminology reference in UI-STUDIO-06-CLOSURE-RECOVERY-INTERACTIONS

- Candidate ID: `AMB28-retired_ia_or_terminology_reference-27212956`
- Evidence type: `retired_ia_or_terminology_reference`
- Severity: `yellow`
- Recommended action: `Rewrite`
- Linear-ready: `True`
- Auto-resolved: `False`
- Reason: Active item contains retired IA, retired terminology, or unsafe language; rewrite or retire before reuse.
- Involved active paths:
  - `UI-STUDIO-06-CLOSURE-RECOVERY-INTERACTIONS` — `prompts/batches/ui-flagship/UI-STUDIO-06-CLOSURE-RECOVERY-INTERACTIONS.md` (partial_implementation; audit)

### 94. Retired IA/terminology reference in TODAY-REALITY-MERIDIAN-VISUAL-01

- Candidate ID: `AMB28-retired_ia_or_terminology_reference-27367898`
- Evidence type: `retired_ia_or_terminology_reference`
- Severity: `yellow`
- Recommended action: `Rewrite`
- Linear-ready: `True`
- Auto-resolved: `False`
- Reason: Active item contains retired IA, retired terminology, or unsafe language; rewrite or retire before reuse.
- Involved active paths:
  - `TODAY-REALITY-MERIDIAN-VISUAL-01` — `prompts/batches/TODAY-REALITY-MERIDIAN-VISUAL-01.md` (partial_implementation; source-only)

### 95. Retired IA/terminology reference in FCP29

- Candidate ID: `AMB28-retired_ia_or_terminology_reference-27507527`
- Evidence type: `retired_ia_or_terminology_reference`
- Severity: `yellow`
- Recommended action: `Rewrite`
- Linear-ready: `True`
- Auto-resolved: `False`
- Reason: Active item contains retired IA, retired terminology, or unsafe language; rewrite or retire before reuse.
- Involved active paths:
  - `FCP29` — `prompts/batches/FCP29.md` (partial_implementation; release proof)

### 96. Retired IA/terminology reference in PX12_Accessibility_Cognitive_Load_Emotional_Safety_Prompt

- Candidate ID: `AMB28-retired_ia_or_terminology_reference-27881766`
- Evidence type: `retired_ia_or_terminology_reference`
- Severity: `yellow`
- Recommended action: `Rewrite`
- Linear-ready: `True`
- Auto-resolved: `False`
- Reason: Active item contains retired IA, retired terminology, or unsafe language; rewrite or retire before reuse.
- Involved active paths:
  - `PX12_Accessibility_Cognitive_Load_Emotional_Safety_Prompt` — `docs/codex/batches/PX12_Accessibility_Cognitive_Load_Emotional_Safety_Prompt.md` (partial_implementation; release proof)

### 97. Retired IA/terminology reference in MOAT-ALIGNMENT-01

- Candidate ID: `AMB28-retired_ia_or_terminology_reference-28020826`
- Evidence type: `retired_ia_or_terminology_reference`
- Severity: `yellow`
- Recommended action: `Rewrite`
- Linear-ready: `True`
- Auto-resolved: `False`
- Reason: Active item contains retired IA, retired terminology, or unsafe language; rewrite or retire before reuse.
- Involved active paths:
  - `MOAT-ALIGNMENT-01` — `prompts/batches/MOAT-ALIGNMENT-01.md` (partial_implementation; release proof)

### 98. Retired IA/terminology reference in IOS26_CORE_REPLACEMENT_P0_CONTRACTS

- Candidate ID: `AMB28-retired_ia_or_terminology_reference-28183942`
- Evidence type: `retired_ia_or_terminology_reference`
- Severity: `yellow`
- Recommended action: `Rewrite`
- Linear-ready: `True`
- Auto-resolved: `False`
- Reason: Active item contains retired IA, retired terminology, or unsafe language; rewrite or retire before reuse.
- Involved active paths:
  - `IOS26_CORE_REPLACEMENT_P0_CONTRACTS` — `docs/codex/IOS26_CORE_REPLACEMENT_P0_CONTRACTS.md` (partial_implementation; release proof)

### 99. Retired IA/terminology reference in PFC33

- Candidate ID: `AMB28-retired_ia_or_terminology_reference-2819570`
- Evidence type: `retired_ia_or_terminology_reference`
- Severity: `yellow`
- Recommended action: `Rewrite`
- Linear-ready: `True`
- Auto-resolved: `False`
- Reason: Active item contains retired IA, retired terminology, or unsafe language; rewrite or retire before reuse.
- Involved active paths:
  - `PFC33` — `prompts/batches/PFC33.md` (partial_implementation; release proof)

### 100. Retired IA/terminology reference in VISUAL-CANON-MOAT-01

- Candidate ID: `AMB28-retired_ia_or_terminology_reference-28497383`
- Evidence type: `retired_ia_or_terminology_reference`
- Severity: `yellow`
- Recommended action: `Rewrite`
- Linear-ready: `True`
- Auto-resolved: `False`
- Reason: Active item contains retired IA, retired terminology, or unsafe language; rewrite or retire before reuse.
- Involved active paths:
  - `VISUAL-CANON-MOAT-01` — `prompts/batches/VISUAL-CANON-MOAT-01.md` (partial_implementation; release proof)

### 101. Retired IA/terminology reference in AMBITIONSOS_AOS_EVIDENCE_LEDGER

- Candidate ID: `AMB28-retired_ia_or_terminology_reference-28937996`
- Evidence type: `retired_ia_or_terminology_reference`
- Severity: `yellow`
- Recommended action: `Rewrite`
- Linear-ready: `True`
- Auto-resolved: `False`
- Reason: Active item contains retired IA, retired terminology, or unsafe language; rewrite or retire before reuse.
- Involved active paths:
  - `AMBITIONSOS_AOS_EVIDENCE_LEDGER` — `docs/codex/AMBITIONSOS_AOS_EVIDENCE_LEDGER.md` (partial_implementation; tests)

### 102. Retired IA/terminology reference in BATCH-32-explainability-and-source-audit-surfaces

- Candidate ID: `AMB28-retired_ia_or_terminology_reference-28958047`
- Evidence type: `retired_ia_or_terminology_reference`
- Severity: `yellow`
- Recommended action: `Rewrite`
- Linear-ready: `True`
- Auto-resolved: `False`
- Reason: Active item contains retired IA, retired terminology, or unsafe language; rewrite or retire before reuse.
- Involved active paths:
  - `BATCH-32-explainability-and-source-audit-surfaces` — `docs/codex/batches/BATCH-32-explainability-and-source-audit-surfaces.md` (unknown; audit)

### 103. Retired IA/terminology reference in MOAT-COMPLETE-AUTONOMOUS-01

- Candidate ID: `AMB28-retired_ia_or_terminology_reference-29271676`
- Evidence type: `retired_ia_or_terminology_reference`
- Severity: `yellow`
- Recommended action: `Rewrite`
- Linear-ready: `True`
- Auto-resolved: `False`
- Reason: Active item contains retired IA, retired terminology, or unsafe language; rewrite or retire before reuse.
- Involved active paths:
  - `MOAT-COMPLETE-AUTONOMOUS-01` — `prompts/batches/MOAT-COMPLETE-AUTONOMOUS-01.md` (partial_implementation; release proof)

### 104. Retired IA/terminology reference in RHC06

- Candidate ID: `AMB28-retired_ia_or_terminology_reference-29275962`
- Evidence type: `retired_ia_or_terminology_reference`
- Severity: `yellow`
- Recommended action: `Rewrite`
- Linear-ready: `True`
- Auto-resolved: `False`
- Reason: Active item contains retired IA, retired terminology, or unsafe language; rewrite or retire before reuse.
- Involved active paths:
  - `RHC06` — `prompts/batches/RHC06.md` (partial_implementation; release proof)

### 105. Retired IA/terminology reference in PK34

- Candidate ID: `AMB28-retired_ia_or_terminology_reference-2931566`
- Evidence type: `retired_ia_or_terminology_reference`
- Severity: `yellow`
- Recommended action: `Rewrite`
- Linear-ready: `True`
- Auto-resolved: `False`
- Reason: Active item contains retired IA, retired terminology, or unsafe language; rewrite or retire before reuse.
- Involved active paths:
  - `PK34` — `prompts/batches/PK34.md` (partial_implementation; release proof)

### 106. Retired IA/terminology reference in EB01_External_Brain_Source_Truth_And_Kernel_Architecture_Prompt

- Candidate ID: `AMB28-retired_ia_or_terminology_reference-30142209`
- Evidence type: `retired_ia_or_terminology_reference`
- Severity: `yellow`
- Recommended action: `Rewrite`
- Linear-ready: `True`
- Auto-resolved: `False`
- Reason: Active item contains retired IA, retired terminology, or unsafe language; rewrite or retire before reuse.
- Involved active paths:
  - `EB01_External_Brain_Source_Truth_And_Kernel_Architecture_Prompt` — `docs/codex/batches/EB01_External_Brain_Source_Truth_And_Kernel_Architecture_Prompt.md` (partial_implementation; release proof)

### 107. Retired IA/terminology reference in PFC37

- Candidate ID: `AMB28-retired_ia_or_terminology_reference-30326291`
- Evidence type: `retired_ia_or_terminology_reference`
- Severity: `yellow`
- Recommended action: `Rewrite`
- Linear-ready: `True`
- Auto-resolved: `False`
- Reason: Active item contains retired IA, retired terminology, or unsafe language; rewrite or retire before reuse.
- Involved active paths:
  - `PFC37` — `prompts/batches/PFC37.md` (partial_implementation; release proof)

### 108. Retired IA/terminology reference in PX18_PXOS_Implementation_Readiness_Reorder_Prompt

- Candidate ID: `AMB28-retired_ia_or_terminology_reference-30388776`
- Evidence type: `retired_ia_or_terminology_reference`
- Severity: `yellow`
- Recommended action: `Rewrite`
- Linear-ready: `True`
- Auto-resolved: `False`
- Reason: Active item contains retired IA, retired terminology, or unsafe language; rewrite or retire before reuse.
- Involved active paths:
  - `PX18_PXOS_Implementation_Readiness_Reorder_Prompt` — `docs/codex/batches/PX18_PXOS_Implementation_Readiness_Reorder_Prompt.md` (partial_implementation; release proof)

### 109. Retired IA/terminology reference in SI17_Top_Level_Surface_Composition_Implementation_Prompt

- Candidate ID: `AMB28-retired_ia_or_terminology_reference-30425219`
- Evidence type: `retired_ia_or_terminology_reference`
- Severity: `yellow`
- Recommended action: `Rewrite`
- Linear-ready: `True`
- Auto-resolved: `False`
- Reason: Active item contains retired IA, retired terminology, or unsafe language; rewrite or retire before reuse.
- Involved active paths:
  - `SI17_Top_Level_Surface_Composition_Implementation_Prompt` — `docs/codex/batches/SI17_Top_Level_Surface_Composition_Implementation_Prompt.md` (partial_implementation; release proof)

### 110. Retired IA/terminology reference in CODEX_OS_ENGINE_SUPPLEMENT_2026_05_08

- Candidate ID: `AMB28-retired_ia_or_terminology_reference-30634389`
- Evidence type: `retired_ia_or_terminology_reference`
- Severity: `yellow`
- Recommended action: `Rewrite`
- Linear-ready: `True`
- Auto-resolved: `False`
- Reason: Active item contains retired IA, retired terminology, or unsafe language; rewrite or retire before reuse.
- Involved active paths:
  - `CODEX_OS_ENGINE_SUPPLEMENT_2026_05_08` — `docs/codex/CODEX_OS_ENGINE_SUPPLEMENT_2026_05_08.md` (partial_implementation; tests)

### 111. Retired IA/terminology reference in AMB_GLOBAL_REMAINING_TRAIN_BLUEPRINT

- Candidate ID: `AMB28-retired_ia_or_terminology_reference-31181548`
- Evidence type: `retired_ia_or_terminology_reference`
- Severity: `yellow`
- Recommended action: `Rewrite`
- Linear-ready: `True`
- Auto-resolved: `False`
- Reason: Active item contains retired IA, retired terminology, or unsafe language; rewrite or retire before reuse.
- Involved active paths:
  - `AMB_GLOBAL_REMAINING_TRAIN_BLUEPRINT` — `docs/codex/AMB_GLOBAL_REMAINING_TRAIN_BLUEPRINT.json` (unknown; tests)

### 112. Retired IA/terminology reference in PD01_Product_Depth_Canon_Inventory_And_Ownership_Map_Prompt

- Candidate ID: `AMB28-retired_ia_or_terminology_reference-31418747`
- Evidence type: `retired_ia_or_terminology_reference`
- Severity: `yellow`
- Recommended action: `Rewrite`
- Linear-ready: `True`
- Auto-resolved: `False`
- Reason: Active item contains retired IA, retired terminology, or unsafe language; rewrite or retire before reuse.
- Involved active paths:
  - `PD01_Product_Depth_Canon_Inventory_And_Ownership_Map_Prompt` — `docs/codex/batches/PD01_Product_Depth_Canon_Inventory_And_Ownership_Map_Prompt.md` (partial_implementation; release proof)

### 113. Retired IA/terminology reference in SOURCE_ATLAS_UNIVERSAL_SOURCE_BINDER_COVERAGE_MAP

- Candidate ID: `AMB28-retired_ia_or_terminology_reference-31495722`
- Evidence type: `retired_ia_or_terminology_reference`
- Severity: `yellow`
- Recommended action: `Rewrite`
- Linear-ready: `True`
- Auto-resolved: `False`
- Reason: Active item contains retired IA, retired terminology, or unsafe language; rewrite or retire before reuse.
- Involved active paths:
  - `SOURCE_ATLAS_UNIVERSAL_SOURCE_BINDER_COVERAGE_MAP` — `docs/codex/SOURCE_ATLAS_UNIVERSAL_SOURCE_BINDER_COVERAGE_MAP.md` (partial_implementation; screenshot)

### 114. Retired IA/terminology reference in PX03_Goals_Mission_Control_Experience_Prompt

- Candidate ID: `AMB28-retired_ia_or_terminology_reference-32165945`
- Evidence type: `retired_ia_or_terminology_reference`
- Severity: `yellow`
- Recommended action: `Rewrite`
- Linear-ready: `True`
- Auto-resolved: `False`
- Reason: Active item contains retired IA, retired terminology, or unsafe language; rewrite or retire before reuse.
- Involved active paths:
  - `PX03_Goals_Mission_Control_Experience_Prompt` — `docs/codex/batches/PX03_Goals_Mission_Control_Experience_Prompt.md` (partial_implementation; release proof)

### 115. Retired IA/terminology reference in TIME-PRESSURE-LEDGER-VISUAL-01

- Candidate ID: `AMB28-retired_ia_or_terminology_reference-32489796`
- Evidence type: `retired_ia_or_terminology_reference`
- Severity: `yellow`
- Recommended action: `Rewrite`
- Linear-ready: `True`
- Auto-resolved: `False`
- Reason: Active item contains retired IA, retired terminology, or unsafe language; rewrite or retire before reuse.
- Involved active paths:
  - `TIME-PRESSURE-LEDGER-VISUAL-01` — `prompts/batches/TIME-PRESSURE-LEDGER-VISUAL-01.md` (partial_implementation; source-only)

### 116. Retired IA/terminology reference in GLOBAL_BATCH_REPAIR_LOOP_PROTOCOL

- Candidate ID: `AMB28-retired_ia_or_terminology_reference-32569660`
- Evidence type: `retired_ia_or_terminology_reference`
- Severity: `yellow`
- Recommended action: `Rewrite`
- Linear-ready: `True`
- Auto-resolved: `False`
- Reason: Active item contains retired IA, retired terminology, or unsafe language; rewrite or retire before reuse.
- Involved active paths:
  - `GLOBAL_BATCH_REPAIR_LOOP_PROTOCOL` — `docs/codex/GLOBAL_BATCH_REPAIR_LOOP_PROTOCOL.md` (partial_implementation; audit)

### 117. Retired IA/terminology reference in SIG03_Today_Signature_Experience_Implementation_Prompt

- Candidate ID: `AMB28-retired_ia_or_terminology_reference-3260181`
- Evidence type: `retired_ia_or_terminology_reference`
- Severity: `yellow`
- Recommended action: `Rewrite`
- Linear-ready: `True`
- Auto-resolved: `False`
- Reason: Active item contains retired IA, retired terminology, or unsafe language; rewrite or retire before reuse.
- Involved active paths:
  - `SIG03_Today_Signature_Experience_Implementation_Prompt` — `docs/codex/batches/SIG03_Today_Signature_Experience_Implementation_Prompt.md` (partial_implementation; source-only)

### 118. Retired IA/terminology reference in FVQ03_DRILLDOWN_AND_EXTERNAL_SURFACE_VISUAL_SWEEP

- Candidate ID: `AMB28-retired_ia_or_terminology_reference-32647135`
- Evidence type: `retired_ia_or_terminology_reference`
- Severity: `yellow`
- Recommended action: `Rewrite`
- Linear-ready: `True`
- Auto-resolved: `False`
- Reason: Active item contains retired IA, retired terminology, or unsafe language; rewrite or retire before reuse.
- Involved active paths:
  - `FVQ03_DRILLDOWN_AND_EXTERNAL_SURFACE_VISUAL_SWEEP` — `docs/codex/visual-quality/FVQ03_DRILLDOWN_AND_EXTERNAL_SURFACE_VISUAL_SWEEP.md` (partial_implementation; release proof)

### 119. Retired IA/terminology reference in EB02_Universal_Capture_Canon_And_Domain_Model_Prompt

- Candidate ID: `AMB28-retired_ia_or_terminology_reference-32807045`
- Evidence type: `retired_ia_or_terminology_reference`
- Severity: `yellow`
- Recommended action: `Rewrite`
- Linear-ready: `True`
- Auto-resolved: `False`
- Reason: Active item contains retired IA, retired terminology, or unsafe language; rewrite or retire before reuse.
- Involved active paths:
  - `EB02_Universal_Capture_Canon_And_Domain_Model_Prompt` — `docs/codex/batches/EB02_Universal_Capture_Canon_And_Domain_Model_Prompt.md` (partial_implementation; release proof)

### 120. Retired IA/terminology reference in FL02_Life_Inventory_Object_Model_Prompt

- Candidate ID: `AMB28-retired_ia_or_terminology_reference-33011404`
- Evidence type: `retired_ia_or_terminology_reference`
- Severity: `yellow`
- Recommended action: `Rewrite`
- Linear-ready: `True`
- Auto-resolved: `False`
- Reason: Active item contains retired IA, retired terminology, or unsafe language; rewrite or retire before reuse.
- Involved active paths:
  - `FL02_Life_Inventory_Object_Model_Prompt` — `docs/codex/batches/FL02_Life_Inventory_Object_Model_Prompt.md` (unknown; audit)

### 121. Retired IA/terminology reference in HBI-09

- Candidate ID: `AMB28-retired_ia_or_terminology_reference-33046162`
- Evidence type: `retired_ia_or_terminology_reference`
- Severity: `yellow`
- Recommended action: `Rewrite`
- Linear-ready: `True`
- Auto-resolved: `False`
- Reason: Active item contains retired IA, retired terminology, or unsafe language; rewrite or retire before reuse.
- Involved active paths:
  - `HBI-09` — `prompts/batches/HBI-09.md` (partial_implementation; release proof)

### 122. Retired IA/terminology reference in PK39

- Candidate ID: `AMB28-retired_ia_or_terminology_reference-33151472`
- Evidence type: `retired_ia_or_terminology_reference`
- Severity: `yellow`
- Recommended action: `Rewrite`
- Linear-ready: `True`
- Auto-resolved: `False`
- Reason: Active item contains retired IA, retired terminology, or unsafe language; rewrite or retire before reuse.
- Involved active paths:
  - `PK39` — `prompts/batches/PK39.md` (partial_implementation; release proof)

### 123. Retired IA/terminology reference in EB04_Capture_Classification_And_Clarification_Prompt

- Candidate ID: `AMB28-retired_ia_or_terminology_reference-34098741`
- Evidence type: `retired_ia_or_terminology_reference`
- Severity: `yellow`
- Recommended action: `Rewrite`
- Linear-ready: `True`
- Auto-resolved: `False`
- Reason: Active item contains retired IA, retired terminology, or unsafe language; rewrite or retire before reuse.
- Involved active paths:
  - `EB04_Capture_Classification_And_Clarification_Prompt` — `docs/codex/batches/EB04_Capture_Classification_And_Clarification_Prompt.md` (partial_implementation; release proof)

### 124. Retired IA/terminology reference in AOS27

- Candidate ID: `AMB28-retired_ia_or_terminology_reference-34107929`
- Evidence type: `retired_ia_or_terminology_reference`
- Severity: `yellow`
- Recommended action: `Rewrite`
- Linear-ready: `True`
- Auto-resolved: `False`
- Reason: Active item contains retired IA, retired terminology, or unsafe language; rewrite or retire before reuse.
- Involved active paths:
  - `AOS27` — `prompts/batches/AOS27.md` (partial_implementation; release proof)

### 125. Retired IA/terminology reference in FVQ01_RENDERED_VISUAL_FRESHNESS_AND_FLAGSHIP_PROMPT

- Candidate ID: `AMB28-retired_ia_or_terminology_reference-34205995`
- Evidence type: `retired_ia_or_terminology_reference`
- Severity: `yellow`
- Recommended action: `Rewrite`
- Linear-ready: `True`
- Auto-resolved: `False`
- Reason: Active item contains retired IA, retired terminology, or unsafe language; rewrite or retire before reuse.
- Involved active paths:
  - `FVQ01_RENDERED_VISUAL_FRESHNESS_AND_FLAGSHIP_PROMPT` — `docs/codex/batches/FVQ01_RENDERED_VISUAL_FRESHNESS_AND_FLAGSHIP_PROMPT.md` (partial_implementation; release proof)

### 126. Retired IA/terminology reference in AOS26_AmbitionsOS_Privacy_Performance_QA_Prompt

- Candidate ID: `AMB28-retired_ia_or_terminology_reference-34440350`
- Evidence type: `retired_ia_or_terminology_reference`
- Severity: `yellow`
- Recommended action: `Rewrite`
- Linear-ready: `True`
- Auto-resolved: `False`
- Reason: Active item contains retired IA, retired terminology, or unsafe language; rewrite or retire before reuse.
- Involved active paths:
  - `AOS26_AmbitionsOS_Privacy_Performance_QA_Prompt` — `docs/codex/batches/AOS26_AmbitionsOS_Privacy_Performance_QA_Prompt.md` (partial_implementation; release proof)

### 127. Retired IA/terminology reference in SA01_SA32_SOURCE_ATLAS_FULL_MATURITY_TRAIN

- Candidate ID: `AMB28-retired_ia_or_terminology_reference-3456008`
- Evidence type: `retired_ia_or_terminology_reference`
- Severity: `yellow`
- Recommended action: `Rewrite`
- Linear-ready: `True`
- Auto-resolved: `False`
- Reason: Active item contains retired IA, retired terminology, or unsafe language; rewrite or retire before reuse.
- Involved active paths:
  - `SA01_SA32_SOURCE_ATLAS_FULL_MATURITY_TRAIN` — `docs/codex/batch-trains/SA01_SA32_SOURCE_ATLAS_FULL_MATURITY_TRAIN.md` (partial_implementation; tests)

### 128. Retired IA/terminology reference in FCP28

- Candidate ID: `AMB28-retired_ia_or_terminology_reference-345687`
- Evidence type: `retired_ia_or_terminology_reference`
- Severity: `yellow`
- Recommended action: `Rewrite`
- Linear-ready: `True`
- Auto-resolved: `False`
- Reason: Active item contains retired IA, retired terminology, or unsafe language; rewrite or retire before reuse.
- Involved active paths:
  - `FCP28` — `prompts/batches/FCP28.md` (partial_implementation; release proof)

### 129. Retired IA/terminology reference in CODEX_VISUAL_QA_PROTOCOL

- Candidate ID: `AMB28-retired_ia_or_terminology_reference-34648498`
- Evidence type: `retired_ia_or_terminology_reference`
- Severity: `yellow`
- Recommended action: `Rewrite`
- Linear-ready: `True`
- Auto-resolved: `False`
- Reason: Active item contains retired IA, retired terminology, or unsafe language; rewrite or retire before reuse.
- Involved active paths:
  - `CODEX_VISUAL_QA_PROTOCOL` — `docs/codex/CODEX_VISUAL_QA_PROTOCOL.md` (unknown; screenshot)

### 130. Retired IA/terminology reference in RHC02

- Candidate ID: `AMB28-retired_ia_or_terminology_reference-34697772`
- Evidence type: `retired_ia_or_terminology_reference`
- Severity: `yellow`
- Recommended action: `Rewrite`
- Linear-ready: `True`
- Auto-resolved: `False`
- Reason: Active item contains retired IA, retired terminology, or unsafe language; rewrite or retire before reuse.
- Involved active paths:
  - `RHC02` — `prompts/batches/RHC02.md` (partial_implementation; release proof)

### 131. Retired IA/terminology reference in EB19_Product_Maturity_Onboarding_Canon_Prompt

- Candidate ID: `AMB28-retired_ia_or_terminology_reference-34746213`
- Evidence type: `retired_ia_or_terminology_reference`
- Severity: `yellow`
- Recommended action: `Rewrite`
- Linear-ready: `True`
- Auto-resolved: `False`
- Reason: Active item contains retired IA, retired terminology, or unsafe language; rewrite or retire before reuse.
- Involved active paths:
  - `EB19_Product_Maturity_Onboarding_Canon_Prompt` — `docs/codex/batches/EB19_Product_Maturity_Onboarding_Canon_Prompt.md` (partial_implementation; release proof)

### 132. Retired IA/terminology reference in MOAT-GOAL-REALITY-TODAY-BRIDGE-06

- Candidate ID: `AMB28-retired_ia_or_terminology_reference-34808042`
- Evidence type: `retired_ia_or_terminology_reference`
- Severity: `yellow`
- Recommended action: `Rewrite`
- Linear-ready: `True`
- Auto-resolved: `False`
- Reason: Active item contains retired IA, retired terminology, or unsafe language; rewrite or retire before reuse.
- Involved active paths:
  - `MOAT-GOAL-REALITY-TODAY-BRIDGE-06` — `prompts/batches/MOAT-GOAL-REALITY-TODAY-BRIDGE-06.md` (partial_implementation; release proof)

### 133. Retired IA/terminology reference in AMB-FLAGSHIP-UI-CODEX-STUDIO-INSTALL-01

- Candidate ID: `AMB28-retired_ia_or_terminology_reference-34874740`
- Evidence type: `retired_ia_or_terminology_reference`
- Severity: `yellow`
- Recommended action: `Rewrite`
- Linear-ready: `True`
- Auto-resolved: `False`
- Reason: Active item contains retired IA, retired terminology, or unsafe language; rewrite or retire before reuse.
- Involved active paths:
  - `AMB-FLAGSHIP-UI-CODEX-STUDIO-INSTALL-01` — `docs/codex/review-boards/AMB-FLAGSHIP-UI-CODEX-STUDIO-INSTALL-01.md` (unknown; screenshot)

### 134. Retired IA/terminology reference in PX07_Action_Closure_Recovery_Experience_Prompt

- Candidate ID: `AMB28-retired_ia_or_terminology_reference-3540325`
- Evidence type: `retired_ia_or_terminology_reference`
- Severity: `yellow`
- Recommended action: `Rewrite`
- Linear-ready: `True`
- Auto-resolved: `False`
- Reason: Active item contains retired IA, retired terminology, or unsafe language; rewrite or retire before reuse.
- Involved active paths:
  - `PX07_Action_Closure_Recovery_Experience_Prompt` — `docs/codex/batches/PX07_Action_Closure_Recovery_Experience_Prompt.md` (partial_implementation; release proof)

### 135. Retired IA/terminology reference in FLAGSHIP_COMPLETION_OBJECT_SCORECARD

- Candidate ID: `AMB28-retired_ia_or_terminology_reference-35441374`
- Evidence type: `retired_ia_or_terminology_reference`
- Severity: `yellow`
- Recommended action: `Rewrite`
- Linear-ready: `True`
- Auto-resolved: `False`
- Reason: Active item contains retired IA, retired terminology, or unsafe language; rewrite or retire before reuse.
- Involved active paths:
  - `FLAGSHIP_COMPLETION_OBJECT_SCORECARD` — `docs/codex/FLAGSHIP_COMPLETION_OBJECT_SCORECARD.md` (partial_implementation; source-only)

### 136. Retired IA/terminology reference in PK40

- Candidate ID: `AMB28-retired_ia_or_terminology_reference-35606657`
- Evidence type: `retired_ia_or_terminology_reference`
- Severity: `yellow`
- Recommended action: `Rewrite`
- Linear-ready: `True`
- Auto-resolved: `False`
- Reason: Active item contains retired IA, retired terminology, or unsafe language; rewrite or retire before reuse.
- Involved active paths:
  - `PK40` — `prompts/batches/PK40.md` (partial_implementation; release proof)

### 137. Retired IA/terminology reference in AOS23_Governance_Kernel_Registry_Prompt

- Candidate ID: `AMB28-retired_ia_or_terminology_reference-35744325`
- Evidence type: `retired_ia_or_terminology_reference`
- Severity: `yellow`
- Recommended action: `Rewrite`
- Linear-ready: `True`
- Auto-resolved: `False`
- Reason: Active item contains retired IA, retired terminology, or unsafe language; rewrite or retire before reuse.
- Involved active paths:
  - `AOS23_Governance_Kernel_Registry_Prompt` — `docs/codex/batches/AOS23_Governance_Kernel_Registry_Prompt.md` (partial_implementation; release proof)

### 138. Retired IA/terminology reference in SA10B

- Candidate ID: `AMB28-retired_ia_or_terminology_reference-35752129`
- Evidence type: `retired_ia_or_terminology_reference`
- Severity: `yellow`
- Recommended action: `Rewrite`
- Linear-ready: `True`
- Auto-resolved: `False`
- Reason: Active item contains retired IA, retired terminology, or unsafe language; rewrite or retire before reuse.
- Involved active paths:
  - `SA10B` — `prompts/batches/SA10B.md` (partial_implementation; release proof)

### 139. Retired IA/terminology reference in SIG_APPLE_AWARD_CALIBER_SCORECARD

- Candidate ID: `AMB28-retired_ia_or_terminology_reference-35965413`
- Evidence type: `retired_ia_or_terminology_reference`
- Severity: `yellow`
- Recommended action: `Rewrite`
- Linear-ready: `True`
- Auto-resolved: `False`
- Reason: Active item contains retired IA, retired terminology, or unsafe language; rewrite or retire before reuse.
- Involved active paths:
  - `SIG_APPLE_AWARD_CALIBER_SCORECARD` — `docs/codex/SIG_APPLE_AWARD_CALIBER_SCORECARD.md` (partial_implementation; release proof)

### 140. Retired IA/terminology reference in EB16_Private_Mode_And_Sensitive_Area_Controls_Prompt

- Candidate ID: `AMB28-retired_ia_or_terminology_reference-36205991`
- Evidence type: `retired_ia_or_terminology_reference`
- Severity: `yellow`
- Recommended action: `Rewrite`
- Linear-ready: `True`
- Auto-resolved: `False`
- Reason: Active item contains retired IA, retired terminology, or unsafe language; rewrite or retire before reuse.
- Involved active paths:
  - `EB16_Private_Mode_And_Sensitive_Area_Controls_Prompt` — `docs/codex/batches/EB16_Private_Mode_And_Sensitive_Area_Controls_Prompt.md` (partial_implementation; release proof)

### 141. Retired IA/terminology reference in MOAT_RUNTIME_BATCH_OVERLAY

- Candidate ID: `AMB28-retired_ia_or_terminology_reference-36374258`
- Evidence type: `retired_ia_or_terminology_reference`
- Severity: `yellow`
- Recommended action: `Rewrite`
- Linear-ready: `True`
- Auto-resolved: `False`
- Reason: Active item contains retired IA, retired terminology, or unsafe language; rewrite or retire before reuse.
- Involved active paths:
  - `MOAT_RUNTIME_BATCH_OVERLAY` — `docs/codex/MOAT_RUNTIME_BATCH_OVERLAY.json` (partial_implementation; release proof)

### 142. Retired IA/terminology reference in CODEX_QUALITY_SYSTEM_REPAIR_PROTOCOL

- Candidate ID: `AMB28-retired_ia_or_terminology_reference-36499611`
- Evidence type: `retired_ia_or_terminology_reference`
- Severity: `yellow`
- Recommended action: `Rewrite`
- Linear-ready: `True`
- Auto-resolved: `False`
- Reason: Active item contains retired IA, retired terminology, or unsafe language; rewrite or retire before reuse.
- Involved active paths:
  - `CODEX_QUALITY_SYSTEM_REPAIR_PROTOCOL` — `docs/codex/CODEX_QUALITY_SYSTEM_REPAIR_PROTOCOL.md` (partial_implementation; tests)

### 143. Retired IA/terminology reference in PK33

- Candidate ID: `AMB28-retired_ia_or_terminology_reference-36796056`
- Evidence type: `retired_ia_or_terminology_reference`
- Severity: `yellow`
- Recommended action: `Rewrite`
- Linear-ready: `True`
- Auto-resolved: `False`
- Reason: Active item contains retired IA, retired terminology, or unsafe language; rewrite or retire before reuse.
- Involved active paths:
  - `PK33` — `prompts/batches/PK33.md` (partial_implementation; release proof)

### 144. Retired IA/terminology reference in AQOS_AUTONOMOUS_QUALITY_CONTINUATION_PROMPT

- Candidate ID: `AMB28-retired_ia_or_terminology_reference-36924143`
- Evidence type: `retired_ia_or_terminology_reference`
- Severity: `yellow`
- Recommended action: `Rewrite`
- Linear-ready: `True`
- Auto-resolved: `False`
- Reason: Active item contains retired IA, retired terminology, or unsafe language; rewrite or retire before reuse.
- Involved active paths:
  - `AQOS_AUTONOMOUS_QUALITY_CONTINUATION_PROMPT` — `docs/codex/batches/AQOS_AUTONOMOUS_QUALITY_CONTINUATION_PROMPT.md` (partial_implementation; release proof)

### 145. Retired IA/terminology reference in EB26_Cognitive_Load_Modes_And_Interface_Density_Prompt

- Candidate ID: `AMB28-retired_ia_or_terminology_reference-37141049`
- Evidence type: `retired_ia_or_terminology_reference`
- Severity: `yellow`
- Recommended action: `Rewrite`
- Linear-ready: `True`
- Auto-resolved: `False`
- Reason: Active item contains retired IA, retired terminology, or unsafe language; rewrite or retire before reuse.
- Involved active paths:
  - `EB26_Cognitive_Load_Modes_And_Interface_Density_Prompt` — `docs/codex/batches/EB26_Cognitive_Load_Modes_And_Interface_Density_Prompt.md` (partial_implementation; release proof)

### 146. Retired IA/terminology reference in SI01_SI18_SIGNATURE_INTERFACE_IMPLEMENTATION_TRAIN

- Candidate ID: `AMB28-retired_ia_or_terminology_reference-37329725`
- Evidence type: `retired_ia_or_terminology_reference`
- Severity: `yellow`
- Recommended action: `Rewrite`
- Linear-ready: `True`
- Auto-resolved: `False`
- Reason: Active item contains retired IA, retired terminology, or unsafe language; rewrite or retire before reuse.
- Involved active paths:
  - `SI01_SI18_SIGNATURE_INTERFACE_IMPLEMENTATION_TRAIN` — `docs/codex/batch-trains/SI01_SI18_SIGNATURE_INTERFACE_IMPLEMENTATION_TRAIN.md` (partial_implementation; audit)

### 147. Retired IA/terminology reference in AOS29_AmbitionsOS_Repair_Train_Prompt

- Candidate ID: `AMB28-retired_ia_or_terminology_reference-37478111`
- Evidence type: `retired_ia_or_terminology_reference`
- Severity: `yellow`
- Recommended action: `Rewrite`
- Linear-ready: `True`
- Auto-resolved: `False`
- Reason: Active item contains retired IA, retired terminology, or unsafe language; rewrite or retire before reuse.
- Involved active paths:
  - `AOS29_AmbitionsOS_Repair_Train_Prompt` — `docs/codex/batches/AOS29_AmbitionsOS_Repair_Train_Prompt.md` (partial_implementation; release proof)

### 148. Retired IA/terminology reference in CODEX-OS-GOVERNANCE-FULL-AUTONOMY-INTEGRATION-01

- Candidate ID: `AMB28-retired_ia_or_terminology_reference-37485863`
- Evidence type: `retired_ia_or_terminology_reference`
- Severity: `yellow`
- Recommended action: `Rewrite`
- Linear-ready: `True`
- Auto-resolved: `False`
- Reason: Active item contains retired IA, retired terminology, or unsafe language; rewrite or retire before reuse.
- Involved active paths:
  - `CODEX-OS-GOVERNANCE-FULL-AUTONOMY-INTEGRATION-01` — `prompts/batches/CODEX-OS-GOVERNANCE-FULL-AUTONOMY-INTEGRATION-01.md` (partial_implementation; release proof)

### 149. Retired IA/terminology reference in AOS02_Life_Graph_Event_Log_Foundation_Prompt

- Candidate ID: `AMB28-retired_ia_or_terminology_reference-3748999`
- Evidence type: `retired_ia_or_terminology_reference`
- Severity: `yellow`
- Recommended action: `Rewrite`
- Linear-ready: `True`
- Auto-resolved: `False`
- Reason: Active item contains retired IA, retired terminology, or unsafe language; rewrite or retire before reuse.
- Involved active paths:
  - `AOS02_Life_Graph_Event_Log_Foundation_Prompt` — `docs/codex/batches/AOS02_Life_Graph_Event_Log_Foundation_Prompt.md` (partial_implementation; release proof)

### 150. Retired IA/terminology reference in BATCH-16-canon-batch-13-shared-life-household-intelligence

- Candidate ID: `AMB28-retired_ia_or_terminology_reference-37720989`
- Evidence type: `retired_ia_or_terminology_reference`
- Severity: `yellow`
- Recommended action: `Rewrite`
- Linear-ready: `True`
- Auto-resolved: `False`
- Reason: Active item contains retired IA, retired terminology, or unsafe language; rewrite or retire before reuse.
- Involved active paths:
  - `BATCH-16-canon-batch-13-shared-life-household-intelligence` — `docs/codex/batches/BATCH-16-canon-batch-13-shared-life-household-intelligence.md` (unknown; audit)

### 151. Retired IA/terminology reference in AMB-FE-BE-MOAT-SCENARIO-PROOF-98

- Candidate ID: `AMB28-retired_ia_or_terminology_reference-37860046`
- Evidence type: `retired_ia_or_terminology_reference`
- Severity: `yellow`
- Recommended action: `Rewrite`
- Linear-ready: `True`
- Auto-resolved: `False`
- Reason: Active item contains retired IA, retired terminology, or unsafe language; rewrite or retire before reuse.
- Involved active paths:
  - `AMB-FE-BE-MOAT-SCENARIO-PROOF-98` — `prompts/batches/amb-fe-be/AMB-FE-BE-MOAT-SCENARIO-PROOF-98.md` (partial_implementation; release proof)

### 152. Retired IA/terminology reference in AOS30

- Candidate ID: `AMB28-retired_ia_or_terminology_reference-38403382`
- Evidence type: `retired_ia_or_terminology_reference`
- Severity: `yellow`
- Recommended action: `Rewrite`
- Linear-ready: `True`
- Auto-resolved: `False`
- Reason: Active item contains retired IA, retired terminology, or unsafe language; rewrite or retire before reuse.
- Involved active paths:
  - `AOS30` — `prompts/batches/AOS30.md` (partial_implementation; release proof)

### 153. Retired IA/terminology reference in FL01_FL06_FOUND_LIFE_LAYER_TRAIN

- Candidate ID: `AMB28-retired_ia_or_terminology_reference-38489069`
- Evidence type: `retired_ia_or_terminology_reference`
- Severity: `yellow`
- Recommended action: `Rewrite`
- Linear-ready: `True`
- Auto-resolved: `False`
- Reason: Active item contains retired IA, retired terminology, or unsafe language; rewrite or retire before reuse.
- Involved active paths:
  - `FL01_FL06_FOUND_LIFE_LAYER_TRAIN` — `docs/codex/batch-trains/FL01_FL06_FOUND_LIFE_LAYER_TRAIN.md` (partial_implementation; audit)

### 154. Retired IA/terminology reference in PK26

- Candidate ID: `AMB28-retired_ia_or_terminology_reference-38828533`
- Evidence type: `retired_ia_or_terminology_reference`
- Severity: `yellow`
- Recommended action: `Rewrite`
- Linear-ready: `True`
- Auto-resolved: `False`
- Reason: Active item contains retired IA, retired terminology, or unsafe language; rewrite or retire before reuse.
- Involved active paths:
  - `PK26` — `prompts/batches/PK26.md` (partial_implementation; release proof)

### 155. Retired IA/terminology reference in DPTG00_Physical_Device_Terminal_Gate_Lock_Prompt

- Candidate ID: `AMB28-retired_ia_or_terminology_reference-39436323`
- Evidence type: `retired_ia_or_terminology_reference`
- Severity: `yellow`
- Recommended action: `Rewrite`
- Linear-ready: `True`
- Auto-resolved: `False`
- Reason: Active item contains retired IA, retired terminology, or unsafe language; rewrite or retire before reuse.
- Involved active paths:
  - `DPTG00_Physical_Device_Terminal_Gate_Lock_Prompt` — `docs/codex/batches/DPTG00_Physical_Device_Terminal_Gate_Lock_Prompt.md` (partial_implementation; release proof)

### 156. Retired IA/terminology reference in SIG_SIGNATURE_EXPERIENCE_RUNBOOK

- Candidate ID: `AMB28-retired_ia_or_terminology_reference-39523396`
- Evidence type: `retired_ia_or_terminology_reference`
- Severity: `yellow`
- Recommended action: `Rewrite`
- Linear-ready: `True`
- Auto-resolved: `False`
- Reason: Active item contains retired IA, retired terminology, or unsafe language; rewrite or retire before reuse.
- Involved active paths:
  - `SIG_SIGNATURE_EXPERIENCE_RUNBOOK` — `docs/codex/SIG_SIGNATURE_EXPERIENCE_RUNBOOK.md` (partial_implementation; source-only)

### 157. Retired IA/terminology reference in AMB-CODEX-OS-VISUAL-QA-GATE

- Candidate ID: `AMB28-retired_ia_or_terminology_reference-39699379`
- Evidence type: `retired_ia_or_terminology_reference`
- Severity: `yellow`
- Recommended action: `Rewrite`
- Linear-ready: `True`
- Auto-resolved: `False`
- Reason: Active item contains retired IA, retired terminology, or unsafe language; rewrite or retire before reuse.
- Involved active paths:
  - `AMB-CODEX-OS-VISUAL-QA-GATE` — `docs/codex/os/AMB-CODEX-OS-VISUAL-QA-GATE.md` (unknown; screenshot)

### 158. Retired IA/terminology reference in SIGNATURE-VISUAL-INSTRUMENTS-ENCYCLOPEDIA-07

- Candidate ID: `AMB28-retired_ia_or_terminology_reference-39733392`
- Evidence type: `retired_ia_or_terminology_reference`
- Severity: `yellow`
- Recommended action: `Rewrite`
- Linear-ready: `True`
- Auto-resolved: `False`
- Reason: Active item contains retired IA, retired terminology, or unsafe language; rewrite or retire before reuse.
- Involved active paths:
  - `SIGNATURE-VISUAL-INSTRUMENTS-ENCYCLOPEDIA-07` — `prompts/batches/SIGNATURE-VISUAL-INSTRUMENTS-ENCYCLOPEDIA-07.md` (partial_implementation; audit)

### 159. Retired IA/terminology reference in AMBITIONS_SIGNATURE_LANGUAGE_SYSTEM

- Candidate ID: `AMB28-retired_ia_or_terminology_reference-39890462`
- Evidence type: `retired_ia_or_terminology_reference`
- Severity: `yellow`
- Recommended action: `Rewrite`
- Linear-ready: `True`
- Auto-resolved: `False`
- Reason: Active item contains retired IA, retired terminology, or unsafe language; rewrite or retire before reuse.
- Involved active paths:
  - `AMBITIONS_SIGNATURE_LANGUAGE_SYSTEM` — `docs/codex/AMBITIONS_SIGNATURE_LANGUAGE_SYSTEM.md` (partial_implementation; audit)

### 160. Retired IA/terminology reference in AMBITIONSOS_SURFACE_ENCAPSULATION_MATRIX

- Candidate ID: `AMB28-retired_ia_or_terminology_reference-39959263`
- Evidence type: `retired_ia_or_terminology_reference`
- Severity: `yellow`
- Recommended action: `Rewrite`
- Linear-ready: `True`
- Auto-resolved: `False`
- Reason: Active item contains retired IA, retired terminology, or unsafe language; rewrite or retire before reuse.
- Involved active paths:
  - `AMBITIONSOS_SURFACE_ENCAPSULATION_MATRIX` — `docs/codex/AMBITIONSOS_SURFACE_ENCAPSULATION_MATRIX.md` (partial_implementation; audit)

### 161. Retired IA/terminology reference in EB37_External_Brain_Privacy_Threat_Model_Prompt

- Candidate ID: `AMB28-retired_ia_or_terminology_reference-40002984`
- Evidence type: `retired_ia_or_terminology_reference`
- Severity: `yellow`
- Recommended action: `Rewrite`
- Linear-ready: `True`
- Auto-resolved: `False`
- Reason: Active item contains retired IA, retired terminology, or unsafe language; rewrite or retire before reuse.
- Involved active paths:
  - `EB37_External_Brain_Privacy_Threat_Model_Prompt` — `docs/codex/batches/EB37_External_Brain_Privacy_Threat_Model_Prompt.md` (partial_implementation; release proof)

### 162. Retired IA/terminology reference in AOS13_Source_Truth_Claim_State_Machine_Prompt

- Candidate ID: `AMB28-retired_ia_or_terminology_reference-40040477`
- Evidence type: `retired_ia_or_terminology_reference`
- Severity: `yellow`
- Recommended action: `Rewrite`
- Linear-ready: `True`
- Auto-resolved: `False`
- Reason: Active item contains retired IA, retired terminology, or unsafe language; rewrite or retire before reuse.
- Involved active paths:
  - `AOS13_Source_Truth_Claim_State_Machine_Prompt` — `docs/codex/batches/AOS13_Source_Truth_Claim_State_Machine_Prompt.md` (partial_implementation; release proof)

### 163. Retired IA/terminology reference in PK00_PK41_PLATFORM_KERNEL_TRAIN

- Candidate ID: `AMB28-retired_ia_or_terminology_reference-40292406`
- Evidence type: `retired_ia_or_terminology_reference`
- Severity: `yellow`
- Recommended action: `Rewrite`
- Linear-ready: `True`
- Auto-resolved: `False`
- Reason: Active item contains retired IA, retired terminology, or unsafe language; rewrite or retire before reuse.
- Involved active paths:
  - `PK00_PK41_PLATFORM_KERNEL_TRAIN` — `docs/codex/batch-trains/PK00_PK41_PLATFORM_KERNEL_TRAIN.md` (partial_implementation; release proof)

### 164. Retired IA/terminology reference in PK30

- Candidate ID: `AMB28-retired_ia_or_terminology_reference-40893573`
- Evidence type: `retired_ia_or_terminology_reference`
- Severity: `yellow`
- Recommended action: `Rewrite`
- Linear-ready: `True`
- Auto-resolved: `False`
- Reason: Active item contains retired IA, retired terminology, or unsafe language; rewrite or retire before reuse.
- Involved active paths:
  - `PK30` — `prompts/batches/PK30.md` (partial_implementation; release proof)

### 165. Retired IA/terminology reference in OBJECT-OS-CANON-01

- Candidate ID: `AMB28-retired_ia_or_terminology_reference-41190519`
- Evidence type: `retired_ia_or_terminology_reference`
- Severity: `yellow`
- Recommended action: `Rewrite`
- Linear-ready: `True`
- Auto-resolved: `False`
- Reason: Active item contains retired IA, retired terminology, or unsafe language; rewrite or retire before reuse.
- Involved active paths:
  - `OBJECT-OS-CANON-01` — `prompts/batches/OBJECT-OS-CANON-01.md` (partial_implementation; release proof)

### 166. Retired IA/terminology reference in AOS08_Alternate_Path_Kernel_Path_Portfolio_Prompt

- Candidate ID: `AMB28-retired_ia_or_terminology_reference-41231606`
- Evidence type: `retired_ia_or_terminology_reference`
- Severity: `yellow`
- Recommended action: `Rewrite`
- Linear-ready: `True`
- Auto-resolved: `False`
- Reason: Active item contains retired IA, retired terminology, or unsafe language; rewrite or retire before reuse.
- Involved active paths:
  - `AOS08_Alternate_Path_Kernel_Path_Portfolio_Prompt` — `docs/codex/batches/AOS08_Alternate_Path_Kernel_Path_Portfolio_Prompt.md` (partial_implementation; release proof)

### 167. Retired IA/terminology reference in PK17

- Candidate ID: `AMB28-retired_ia_or_terminology_reference-41366215`
- Evidence type: `retired_ia_or_terminology_reference`
- Severity: `yellow`
- Recommended action: `Rewrite`
- Linear-ready: `True`
- Auto-resolved: `False`
- Reason: Active item contains retired IA, retired terminology, or unsafe language; rewrite or retire before reuse.
- Involved active paths:
  - `PK17` — `prompts/batches/PK17.md` (partial_implementation; release proof)

### 168. Retired IA/terminology reference in AMB-POST23-02-UNDERDELIVERY-REPAIR

- Candidate ID: `AMB28-retired_ia_or_terminology_reference-41421122`
- Evidence type: `retired_ia_or_terminology_reference`
- Severity: `yellow`
- Recommended action: `Rewrite`
- Linear-ready: `True`
- Auto-resolved: `False`
- Reason: Active item contains retired IA, retired terminology, or unsafe language; rewrite or retire before reuse.
- Involved active paths:
  - `AMB-POST23-02-UNDERDELIVERY-REPAIR` — `docs/codex/reports/AMB-POST23-02-UNDERDELIVERY-REPAIR.md` (partial_implementation; release proof)

### 169. Retired IA/terminology reference in SA24

- Candidate ID: `AMB28-retired_ia_or_terminology_reference-41597999`
- Evidence type: `retired_ia_or_terminology_reference`
- Severity: `yellow`
- Recommended action: `Rewrite`
- Linear-ready: `True`
- Auto-resolved: `False`
- Reason: Active item contains retired IA, retired terminology, or unsafe language; rewrite or retire before reuse.
- Involved active paths:
  - `SA24` — `prompts/batches/SA24.md` (partial_implementation; release proof)

### 170. Retired IA/terminology reference in PD18_Product_Depth_Handoff_And_Next_Lane_Readiness_Prompt

- Candidate ID: `AMB28-retired_ia_or_terminology_reference-41610798`
- Evidence type: `retired_ia_or_terminology_reference`
- Severity: `yellow`
- Recommended action: `Rewrite`
- Linear-ready: `True`
- Auto-resolved: `False`
- Reason: Active item contains retired IA, retired terminology, or unsafe language; rewrite or retire before reuse.
- Involved active paths:
  - `PD18_Product_Depth_Handoff_And_Next_Lane_Readiness_Prompt` — `docs/codex/batches/PD18_Product_Depth_Handoff_And_Next_Lane_Readiness_Prompt.md` (partial_implementation; release proof)

### 171. Retired IA/terminology reference in AMB-REPO-GREEN-FLAGSHIP-RESET-MASTER-01-T11-TIME-EXTRACTION

- Candidate ID: `AMB28-retired_ia_or_terminology_reference-41705496`
- Evidence type: `retired_ia_or_terminology_reference`
- Severity: `yellow`
- Recommended action: `Rewrite`
- Linear-ready: `True`
- Auto-resolved: `False`
- Reason: Active item contains retired IA, retired terminology, or unsafe language; rewrite or retire before reuse.
- Involved active paths:
  - `AMB-REPO-GREEN-FLAGSHIP-RESET-MASTER-01-T11-TIME-EXTRACTION` — `prompts/batches/AMB-REPO-GREEN-FLAGSHIP-RESET-MASTER-01-T11-TIME-EXTRACTION.md` (partial_implementation; tests)

### 172. Retired IA/terminology reference in HBI-10

- Candidate ID: `AMB28-retired_ia_or_terminology_reference-41732364`
- Evidence type: `retired_ia_or_terminology_reference`
- Severity: `yellow`
- Recommended action: `Rewrite`
- Linear-ready: `True`
- Auto-resolved: `False`
- Reason: Active item contains retired IA, retired terminology, or unsafe language; rewrite or retire before reuse.
- Involved active paths:
  - `HBI-10` — `prompts/batches/HBI-10.md` (partial_implementation; release proof)

### 173. Retired IA/terminology reference in AMB-FLAGSHIP-UI-CODEX-STUDIO-INSTALL-01

- Candidate ID: `AMB28-retired_ia_or_terminology_reference-42421688`
- Evidence type: `retired_ia_or_terminology_reference`
- Severity: `yellow`
- Recommended action: `Rewrite`
- Linear-ready: `True`
- Auto-resolved: `False`
- Reason: Active item contains retired IA, retired terminology, or unsafe language; rewrite or retire before reuse.
- Involved active paths:
  - `AMB-FLAGSHIP-UI-CODEX-STUDIO-INSTALL-01` — `prompts/batches/AMB-FLAGSHIP-UI-CODEX-STUDIO-INSTALL-01.md` (partial_implementation; release proof)

### 174. Retired IA/terminology reference in EB28_Plain_Language_Anxiety_Safe_Copy_And_Explain_This_Screen_Prompt

- Candidate ID: `AMB28-retired_ia_or_terminology_reference-42484788`
- Evidence type: `retired_ia_or_terminology_reference`
- Severity: `yellow`
- Recommended action: `Rewrite`
- Linear-ready: `True`
- Auto-resolved: `False`
- Reason: Active item contains retired IA, retired terminology, or unsafe language; rewrite or retire before reuse.
- Involved active paths:
  - `EB28_Plain_Language_Anxiety_Safe_Copy_And_Explain_This_Screen_Prompt` — `docs/codex/batches/EB28_Plain_Language_Anxiety_Safe_Copy_And_Explain_This_Screen_Prompt.md` (partial_implementation; release proof)

### 175. Retired IA/terminology reference in FRONTEND_AUTHORITY_GLOBAL_TRAIN_HOOK

- Candidate ID: `AMB28-retired_ia_or_terminology_reference-42654035`
- Evidence type: `retired_ia_or_terminology_reference`
- Severity: `yellow`
- Recommended action: `Rewrite`
- Linear-ready: `True`
- Auto-resolved: `False`
- Reason: Active item contains retired IA, retired terminology, or unsafe language; rewrite or retire before reuse.
- Involved active paths:
  - `FRONTEND_AUTHORITY_GLOBAL_TRAIN_HOOK` — `docs/codex/FRONTEND_AUTHORITY_GLOBAL_TRAIN_HOOK.md` (unknown; release proof)

### 176. Retired IA/terminology reference in AOS19_Experience_Kernel_Celestial_Cognitive_Load_Prompt

- Candidate ID: `AMB28-retired_ia_or_terminology_reference-42726185`
- Evidence type: `retired_ia_or_terminology_reference`
- Severity: `yellow`
- Recommended action: `Rewrite`
- Linear-ready: `True`
- Auto-resolved: `False`
- Reason: Active item contains retired IA, retired terminology, or unsafe language; rewrite or retire before reuse.
- Involved active paths:
  - `AOS19_Experience_Kernel_Celestial_Cognitive_Load_Prompt` — `docs/codex/batches/AOS19_Experience_Kernel_Celestial_Cognitive_Load_Prompt.md` (partial_implementation; release proof)

### 177. Retired IA/terminology reference in SA26

- Candidate ID: `AMB28-retired_ia_or_terminology_reference-42767958`
- Evidence type: `retired_ia_or_terminology_reference`
- Severity: `yellow`
- Recommended action: `Rewrite`
- Linear-ready: `True`
- Auto-resolved: `False`
- Reason: Active item contains retired IA, retired terminology, or unsafe language; rewrite or retire before reuse.
- Involved active paths:
  - `SA26` — `prompts/batches/SA26.md` (partial_implementation; release proof)

### 178. Retired IA/terminology reference in GLOBAL_AUTONOMOUS_QUALITY_OVERLAY

- Candidate ID: `AMB28-retired_ia_or_terminology_reference-42803985`
- Evidence type: `retired_ia_or_terminology_reference`
- Severity: `yellow`
- Recommended action: `Rewrite`
- Linear-ready: `True`
- Auto-resolved: `False`
- Reason: Active item contains retired IA, retired terminology, or unsafe language; rewrite or retire before reuse.
- Involved active paths:
  - `GLOBAL_AUTONOMOUS_QUALITY_OVERLAY` — `docs/codex/GLOBAL_AUTONOMOUS_QUALITY_OVERLAY.md` (partial_implementation; audit)

### 179. Retired IA/terminology reference in SA17

- Candidate ID: `AMB28-retired_ia_or_terminology_reference-43510496`
- Evidence type: `retired_ia_or_terminology_reference`
- Severity: `yellow`
- Recommended action: `Rewrite`
- Linear-ready: `True`
- Auto-resolved: `False`
- Reason: Active item contains retired IA, retired terminology, or unsafe language; rewrite or retire before reuse.
- Involved active paths:
  - `SA17` — `prompts/batches/SA17.md` (partial_implementation; release proof)

### 180. Retired IA/terminology reference in RHC04

- Candidate ID: `AMB28-retired_ia_or_terminology_reference-43910453`
- Evidence type: `retired_ia_or_terminology_reference`
- Severity: `yellow`
- Recommended action: `Rewrite`
- Linear-ready: `True`
- Auto-resolved: `False`
- Reason: Active item contains retired IA, retired terminology, or unsafe language; rewrite or retire before reuse.
- Involved active paths:
  - `RHC04` — `prompts/batches/RHC04.md` (partial_implementation; release proof)

### 181. Retired IA/terminology reference in CODEX_QUALITY_SYSTEM_SCRIPT_MAP

- Candidate ID: `AMB28-retired_ia_or_terminology_reference-44070086`
- Evidence type: `retired_ia_or_terminology_reference`
- Severity: `yellow`
- Recommended action: `Rewrite`
- Linear-ready: `True`
- Auto-resolved: `False`
- Reason: Active item contains retired IA, retired terminology, or unsafe language; rewrite or retire before reuse.
- Involved active paths:
  - `CODEX_QUALITY_SYSTEM_SCRIPT_MAP` — `docs/codex/CODEX_QUALITY_SYSTEM_SCRIPT_MAP.md` (unknown; release proof)

### 182. Retired IA/terminology reference in PK29

- Candidate ID: `AMB28-retired_ia_or_terminology_reference-44673085`
- Evidence type: `retired_ia_or_terminology_reference`
- Severity: `yellow`
- Recommended action: `Rewrite`
- Linear-ready: `True`
- Auto-resolved: `False`
- Reason: Active item contains retired IA, retired terminology, or unsafe language; rewrite or retire before reuse.
- Involved active paths:
  - `PK29` — `prompts/batches/PK29.md` (partial_implementation; release proof)

### 183. Retired IA/terminology reference in AOS25_AmbitionsOS_Test_Fixture_Library_Prompt

- Candidate ID: `AMB28-retired_ia_or_terminology_reference-44827563`
- Evidence type: `retired_ia_or_terminology_reference`
- Severity: `yellow`
- Recommended action: `Rewrite`
- Linear-ready: `True`
- Auto-resolved: `False`
- Reason: Active item contains retired IA, retired terminology, or unsafe language; rewrite or retire before reuse.
- Involved active paths:
  - `AOS25_AmbitionsOS_Test_Fixture_Library_Prompt` — `docs/codex/batches/AOS25_AmbitionsOS_Test_Fixture_Library_Prompt.md` (partial_implementation; release proof)

### 184. Retired IA/terminology reference in AOS11_Reality_Drift_Bounded_Reflow_Prompt

- Candidate ID: `AMB28-retired_ia_or_terminology_reference-45023912`
- Evidence type: `retired_ia_or_terminology_reference`
- Severity: `yellow`
- Recommended action: `Rewrite`
- Linear-ready: `True`
- Auto-resolved: `False`
- Reason: Active item contains retired IA, retired terminology, or unsafe language; rewrite or retire before reuse.
- Involved active paths:
  - `AOS11_Reality_Drift_Bounded_Reflow_Prompt` — `docs/codex/batches/AOS11_Reality_Drift_Bounded_Reflow_Prompt.md` (partial_implementation; release proof)

### 185. Retired IA/terminology reference in BATCH-13-canon-batch-10-life-graph-foundation

- Candidate ID: `AMB28-retired_ia_or_terminology_reference-45032509`
- Evidence type: `retired_ia_or_terminology_reference`
- Severity: `yellow`
- Recommended action: `Rewrite`
- Linear-ready: `True`
- Auto-resolved: `False`
- Reason: Active item contains retired IA, retired terminology, or unsafe language; rewrite or retire before reuse.
- Involved active paths:
  - `BATCH-13-canon-batch-10-life-graph-foundation` — `docs/codex/batches/BATCH-13-canon-batch-10-life-graph-foundation.md` (unknown; audit)

### 186. Retired IA/terminology reference in PD09_Capture_Placement_Review_Prompt

- Candidate ID: `AMB28-retired_ia_or_terminology_reference-45418723`
- Evidence type: `retired_ia_or_terminology_reference`
- Severity: `yellow`
- Recommended action: `Rewrite`
- Linear-ready: `True`
- Auto-resolved: `False`
- Reason: Active item contains retired IA, retired terminology, or unsafe language; rewrite or retire before reuse.
- Involved active paths:
  - `PD09_Capture_Placement_Review_Prompt` — `docs/codex/batches/PD09_Capture_Placement_Review_Prompt.md` (partial_implementation; release proof)

### 187. Retired IA/terminology reference in PXOS_PRODUCT_DECISION_LEDGER

- Candidate ID: `AMB28-retired_ia_or_terminology_reference-45423500`
- Evidence type: `retired_ia_or_terminology_reference`
- Severity: `yellow`
- Recommended action: `Rewrite`
- Linear-ready: `True`
- Auto-resolved: `False`
- Reason: Active item contains retired IA, retired terminology, or unsafe language; rewrite or retire before reuse.
- Involved active paths:
  - `PXOS_PRODUCT_DECISION_LEDGER` — `docs/codex/PXOS_PRODUCT_DECISION_LEDGER.md` (unknown; release proof)

### 188. Retired IA/terminology reference in MOAT_RUNTIME_GOLDEN_SCENARIOS

- Candidate ID: `AMB28-retired_ia_or_terminology_reference-454433`
- Evidence type: `retired_ia_or_terminology_reference`
- Severity: `yellow`
- Recommended action: `Rewrite`
- Linear-ready: `True`
- Auto-resolved: `False`
- Reason: Active item contains retired IA, retired terminology, or unsafe language; rewrite or retire before reuse.
- Involved active paths:
  - `MOAT_RUNTIME_GOLDEN_SCENARIOS` — `docs/codex/MOAT_RUNTIME_GOLDEN_SCENARIOS.md` (unknown; release proof)

### 189. Retired IA/terminology reference in AMB-POST23-TRUTH-AUDIT-REPAIR-ROUTING

- Candidate ID: `AMB28-retired_ia_or_terminology_reference-45573475`
- Evidence type: `retired_ia_or_terminology_reference`
- Severity: `yellow`
- Recommended action: `Rewrite`
- Linear-ready: `True`
- Auto-resolved: `False`
- Reason: Active item contains retired IA, retired terminology, or unsafe language; rewrite or retire before reuse.
- Involved active paths:
  - `AMB-POST23-TRUTH-AUDIT-REPAIR-ROUTING` — `docs/codex/batch-trains/post-23-truth-audit/AMB-POST23-TRUTH-AUDIT-REPAIR-ROUTING.md` (partial_implementation; release proof)

### 190. Retired IA/terminology reference in AOS03_Graph_Delta_Review_Projection_Store_Prompt

- Candidate ID: `AMB28-retired_ia_or_terminology_reference-45637686`
- Evidence type: `retired_ia_or_terminology_reference`
- Severity: `yellow`
- Recommended action: `Rewrite`
- Linear-ready: `True`
- Auto-resolved: `False`
- Reason: Active item contains retired IA, retired terminology, or unsafe language; rewrite or retire before reuse.
- Involved active paths:
  - `AOS03_Graph_Delta_Review_Projection_Store_Prompt` — `docs/codex/batches/AOS03_Graph_Delta_Review_Projection_Store_Prompt.md` (partial_implementation; release proof)

### 191. Retired IA/terminology reference in AOS28_AmbitionsOS_Handoff_Prompt

- Candidate ID: `AMB28-retired_ia_or_terminology_reference-45773987`
- Evidence type: `retired_ia_or_terminology_reference`
- Severity: `yellow`
- Recommended action: `Rewrite`
- Linear-ready: `True`
- Auto-resolved: `False`
- Reason: Active item contains retired IA, retired terminology, or unsafe language; rewrite or retire before reuse.
- Involved active paths:
  - `AOS28_AmbitionsOS_Handoff_Prompt` — `docs/codex/batches/AOS28_AmbitionsOS_Handoff_Prompt.md` (partial_implementation; release proof)

### 192. Retired IA/terminology reference in GLOBAL_PATCH_TRAIN_INTERRUPTED_RUN_RECOVERY_PROTOCOL

- Candidate ID: `AMB28-retired_ia_or_terminology_reference-4600454`
- Evidence type: `retired_ia_or_terminology_reference`
- Severity: `yellow`
- Recommended action: `Rewrite`
- Linear-ready: `True`
- Auto-resolved: `False`
- Reason: Active item contains retired IA, retired terminology, or unsafe language; rewrite or retire before reuse.
- Involved active paths:
  - `GLOBAL_PATCH_TRAIN_INTERRUPTED_RUN_RECOVERY_PROTOCOL` — `docs/codex/GLOBAL_PATCH_TRAIN_INTERRUPTED_RUN_RECOVERY_PROTOCOL.md` (partial_implementation; screenshot)

### 193. Retired IA/terminology reference in EFC00_Flagship_Proof_Operating_Layer_Integration_Prompt

- Candidate ID: `AMB28-retired_ia_or_terminology_reference-46274596`
- Evidence type: `retired_ia_or_terminology_reference`
- Severity: `yellow`
- Recommended action: `Rewrite`
- Linear-ready: `True`
- Auto-resolved: `False`
- Reason: Active item contains retired IA, retired terminology, or unsafe language; rewrite or retire before reuse.
- Involved active paths:
  - `EFC00_Flagship_Proof_Operating_Layer_Integration_Prompt` — `docs/codex/batches/EFC00_Flagship_Proof_Operating_Layer_Integration_Prompt.md` (partial_implementation; release proof)

### 194. Retired IA/terminology reference in DAV03_Today_DayTimelineRail_And_HeroStepPanel_Implementation_Prompt

- Candidate ID: `AMB28-retired_ia_or_terminology_reference-46341715`
- Evidence type: `retired_ia_or_terminology_reference`
- Severity: `yellow`
- Recommended action: `Rewrite`
- Linear-ready: `True`
- Auto-resolved: `False`
- Reason: Active item contains retired IA, retired terminology, or unsafe language; rewrite or retire before reuse.
- Involved active paths:
  - `DAV03_Today_DayTimelineRail_And_HeroStepPanel_Implementation_Prompt` — `docs/codex/batches/DAV03_Today_DayTimelineRail_And_HeroStepPanel_Implementation_Prompt.md` (partial_implementation; source-only)

### 195. Retired IA/terminology reference in frontend-gap-backlog

- Candidate ID: `AMB28-retired_ia_or_terminology_reference-46357580`
- Evidence type: `retired_ia_or_terminology_reference`
- Severity: `yellow`
- Recommended action: `Rewrite`
- Linear-ready: `True`
- Auto-resolved: `False`
- Reason: Active item contains retired IA, retired terminology, or unsafe language; rewrite or retire before reuse.
- Involved active paths:
  - `frontend-gap-backlog` — `docs/codex/frontend-gap-backlog.md` (partial_implementation; release proof)

### 196. Retired IA/terminology reference in IOS26_ANTI_CARD_VALIDATOR_SPEC

- Candidate ID: `AMB28-retired_ia_or_terminology_reference-46637847`
- Evidence type: `retired_ia_or_terminology_reference`
- Severity: `yellow`
- Recommended action: `Rewrite`
- Linear-ready: `True`
- Auto-resolved: `False`
- Reason: Active item contains retired IA, retired terminology, or unsafe language; rewrite or retire before reuse.
- Involved active paths:
  - `IOS26_ANTI_CARD_VALIDATOR_SPEC` — `docs/codex/frontend/IOS26_ANTI_CARD_VALIDATOR_SPEC.md` (partial_implementation; tests)

### 197. Retired IA/terminology reference in CODEX_BUILD_SHERIFF_PROTOCOL

- Candidate ID: `AMB28-retired_ia_or_terminology_reference-46680224`
- Evidence type: `retired_ia_or_terminology_reference`
- Severity: `yellow`
- Recommended action: `Rewrite`
- Linear-ready: `True`
- Auto-resolved: `False`
- Reason: Active item contains retired IA, retired terminology, or unsafe language; rewrite or retire before reuse.
- Involved active paths:
  - `CODEX_BUILD_SHERIFF_PROTOCOL` — `docs/codex/CODEX_BUILD_SHERIFF_PROTOCOL.md` (unknown; tests)

### 198. Retired IA/terminology reference in PK19

- Candidate ID: `AMB28-retired_ia_or_terminology_reference-46687253`
- Evidence type: `retired_ia_or_terminology_reference`
- Severity: `yellow`
- Recommended action: `Rewrite`
- Linear-ready: `True`
- Auto-resolved: `False`
- Reason: Active item contains retired IA, retired terminology, or unsafe language; rewrite or retire before reuse.
- Involved active paths:
  - `PK19` — `prompts/batches/PK19.md` (partial_implementation; release proof)

### 199. Retired IA/terminology reference in PX13_Empty_Edge_Degraded_States_Prompt

- Candidate ID: `AMB28-retired_ia_or_terminology_reference-46800257`
- Evidence type: `retired_ia_or_terminology_reference`
- Severity: `yellow`
- Recommended action: `Rewrite`
- Linear-ready: `True`
- Auto-resolved: `False`
- Reason: Active item contains retired IA, retired terminology, or unsafe language; rewrite or retire before reuse.
- Involved active paths:
  - `PX13_Empty_Edge_Degraded_States_Prompt` — `docs/codex/batches/PX13_Empty_Edge_Degraded_States_Prompt.md` (partial_implementation; release proof)

### 200. Retired IA/terminology reference in SA_NEXT_ELIGIBLE_BATCH_PROMPT

- Candidate ID: `AMB28-retired_ia_or_terminology_reference-46907006`
- Evidence type: `retired_ia_or_terminology_reference`
- Severity: `yellow`
- Recommended action: `Rewrite`
- Linear-ready: `True`
- Auto-resolved: `False`
- Reason: Active item contains retired IA, retired terminology, or unsafe language; rewrite or retire before reuse.
- Involved active paths:
  - `SA_NEXT_ELIGIBLE_BATCH_PROMPT` — `docs/codex/batches/SA_NEXT_ELIGIBLE_BATCH_PROMPT.md` (partial_implementation; release proof)

### 201. Retired IA/terminology reference in BATCH-27-update-and-freshness-engine

- Candidate ID: `AMB28-retired_ia_or_terminology_reference-47266087`
- Evidence type: `retired_ia_or_terminology_reference`
- Severity: `yellow`
- Recommended action: `Rewrite`
- Linear-ready: `True`
- Auto-resolved: `False`
- Reason: Active item contains retired IA, retired terminology, or unsafe language; rewrite or retire before reuse.
- Involved active paths:
  - `BATCH-27-update-and-freshness-engine` — `docs/codex/batches/BATCH-27-update-and-freshness-engine.md` (unknown; audit)

### 202. Retired IA/terminology reference in TRAIN_04D_CAPTURE_RUNTIME_FACTORING_FUTURE_PROOF

- Candidate ID: `AMB28-retired_ia_or_terminology_reference-47647535`
- Evidence type: `retired_ia_or_terminology_reference`
- Severity: `yellow`
- Recommended action: `Rewrite`
- Linear-ready: `True`
- Auto-resolved: `False`
- Reason: Active item contains retired IA, retired terminology, or unsafe language; rewrite or retire before reuse.
- Involved active paths:
  - `TRAIN_04D_CAPTURE_RUNTIME_FACTORING_FUTURE_PROOF` — `prompts/trains/ios26-flagship/TRAIN_04D_CAPTURE_RUNTIME_FACTORING_FUTURE_PROOF.md` (partial_implementation; release proof)

### 203. Retired IA/terminology reference in PX20_PXOS_Beyond_Roadmap_Prompt

- Candidate ID: `AMB28-retired_ia_or_terminology_reference-47973054`
- Evidence type: `retired_ia_or_terminology_reference`
- Severity: `yellow`
- Recommended action: `Rewrite`
- Linear-ready: `True`
- Auto-resolved: `False`
- Reason: Active item contains retired IA, retired terminology, or unsafe language; rewrite or retire before reuse.
- Involved active paths:
  - `PX20_PXOS_Beyond_Roadmap_Prompt` — `docs/codex/batches/PX20_PXOS_Beyond_Roadmap_Prompt.md` (partial_implementation; release proof)

### 204. Retired IA/terminology reference in PXEQ_VISUAL_SYSTEM_CONSERVATIVE_FUTURISM_RULES

- Candidate ID: `AMB28-retired_ia_or_terminology_reference-47976113`
- Evidence type: `retired_ia_or_terminology_reference`
- Severity: `yellow`
- Recommended action: `Rewrite`
- Linear-ready: `True`
- Auto-resolved: `False`
- Reason: Active item contains retired IA, retired terminology, or unsafe language; rewrite or retire before reuse.
- Involved active paths:
  - `PXEQ_VISUAL_SYSTEM_CONSERVATIVE_FUTURISM_RULES` — `docs/codex/PXEQ_VISUAL_SYSTEM_CONSERVATIVE_FUTURISM_RULES.md` (partial_implementation; source-only)

### 205. Retired IA/terminology reference in LDI21

- Candidate ID: `AMB28-retired_ia_or_terminology_reference-48735443`
- Evidence type: `retired_ia_or_terminology_reference`
- Severity: `yellow`
- Recommended action: `Rewrite`
- Linear-ready: `True`
- Auto-resolved: `False`
- Reason: Active item contains retired IA, retired terminology, or unsafe language; rewrite or retire before reuse.
- Involved active paths:
  - `LDI21` — `prompts/batches/LDI21.md` (partial_implementation; release proof)

### 206. Retired IA/terminology reference in GATE_RESULT_MANIFEST_SCHEMA

- Candidate ID: `AMB28-retired_ia_or_terminology_reference-49083238`
- Evidence type: `retired_ia_or_terminology_reference`
- Severity: `yellow`
- Recommended action: `Rewrite`
- Linear-ready: `True`
- Auto-resolved: `False`
- Reason: Active item contains retired IA, retired terminology, or unsafe language; rewrite or retire before reuse.
- Involved active paths:
  - `GATE_RESULT_MANIFEST_SCHEMA` — `docs/codex/GATE_RESULT_MANIFEST_SCHEMA.md` (partial_implementation; audit)

### 207. Retired IA/terminology reference in EB21_Concierge_Setup_And_Planning_Defaults_Onboarding_Prompt

- Candidate ID: `AMB28-retired_ia_or_terminology_reference-49213166`
- Evidence type: `retired_ia_or_terminology_reference`
- Severity: `yellow`
- Recommended action: `Rewrite`
- Linear-ready: `True`
- Auto-resolved: `False`
- Reason: Active item contains retired IA, retired terminology, or unsafe language; rewrite or retire before reuse.
- Involved active paths:
  - `EB21_Concierge_Setup_And_Planning_Defaults_Onboarding_Prompt` — `docs/codex/batches/EB21_Concierge_Setup_And_Planning_Defaults_Onboarding_Prompt.md` (partial_implementation; release proof)

### 208. Retired IA/terminology reference in SA32

- Candidate ID: `AMB28-retired_ia_or_terminology_reference-49253159`
- Evidence type: `retired_ia_or_terminology_reference`
- Severity: `yellow`
- Recommended action: `Rewrite`
- Linear-ready: `True`
- Auto-resolved: `False`
- Reason: Active item contains retired IA, retired terminology, or unsafe language; rewrite or retire before reuse.
- Involved active paths:
  - `SA32` — `prompts/batches/SA32.md` (partial_implementation; release proof)

### 209. Retired IA/terminology reference in HPS_CROSS_TRAIN_INTEGRATION_MAP

- Candidate ID: `AMB28-retired_ia_or_terminology_reference-49527040`
- Evidence type: `retired_ia_or_terminology_reference`
- Severity: `yellow`
- Recommended action: `Rewrite`
- Linear-ready: `True`
- Auto-resolved: `False`
- Reason: Active item contains retired IA, retired terminology, or unsafe language; rewrite or retire before reuse.
- Involved active paths:
  - `HPS_CROSS_TRAIN_INTEGRATION_MAP` — `docs/codex/HPS_CROSS_TRAIN_INTEGRATION_MAP.md` (partial_implementation; release proof)

### 210. Retired IA/terminology reference in PD08_Goal_Alternate_Path_And_Tradeoff_Depth_Prompt

- Candidate ID: `AMB28-retired_ia_or_terminology_reference-49590602`
- Evidence type: `retired_ia_or_terminology_reference`
- Severity: `yellow`
- Recommended action: `Rewrite`
- Linear-ready: `True`
- Auto-resolved: `False`
- Reason: Active item contains retired IA, retired terminology, or unsafe language; rewrite or retire before reuse.
- Involved active paths:
  - `PD08_Goal_Alternate_Path_And_Tradeoff_Depth_Prompt` — `docs/codex/batches/PD08_Goal_Alternate_Path_And_Tradeoff_Depth_Prompt.md` (partial_implementation; release proof)

### 211. Retired IA/terminology reference in PXOS_DRIFT_DETECTION_PROTOCOL

- Candidate ID: `AMB28-retired_ia_or_terminology_reference-49945571`
- Evidence type: `retired_ia_or_terminology_reference`
- Severity: `yellow`
- Recommended action: `Rewrite`
- Linear-ready: `True`
- Auto-resolved: `False`
- Reason: Active item contains retired IA, retired terminology, or unsafe language; rewrite or retire before reuse.
- Involved active paths:
  - `PXOS_DRIFT_DETECTION_PROTOCOL` — `docs/codex/PXOS_DRIFT_DETECTION_PROTOCOL.md` (unknown; release proof)

### 212. Retired IA/terminology reference in HISTORICAL_BASELINE_GLOBAL_TRAIN_MANIFEST

- Candidate ID: `AMB28-retired_ia_or_terminology_reference-50332786`
- Evidence type: `retired_ia_or_terminology_reference`
- Severity: `yellow`
- Recommended action: `Rewrite`
- Linear-ready: `True`
- Auto-resolved: `False`
- Reason: Active item contains retired IA, retired terminology, or unsafe language; rewrite or retire before reuse.
- Involved active paths:
  - `HISTORICAL_BASELINE_GLOBAL_TRAIN_MANIFEST` — `docs/codex/HISTORICAL_BASELINE_GLOBAL_TRAIN_MANIFEST.json` (unknown; release proof)

### 213. Retired IA/terminology reference in SA12

- Candidate ID: `AMB28-retired_ia_or_terminology_reference-50371090`
- Evidence type: `retired_ia_or_terminology_reference`
- Severity: `yellow`
- Recommended action: `Rewrite`
- Linear-ready: `True`
- Auto-resolved: `False`
- Reason: Active item contains retired IA, retired terminology, or unsafe language; rewrite or retire before reuse.
- Involved active paths:
  - `SA12` — `prompts/batches/SA12.md` (partial_implementation; release proof)

### 214. Retired IA/terminology reference in FL06_Weekly_Life_Sweep_Ritual_Prompt

- Candidate ID: `AMB28-retired_ia_or_terminology_reference-50412865`
- Evidence type: `retired_ia_or_terminology_reference`
- Severity: `yellow`
- Recommended action: `Rewrite`
- Linear-ready: `True`
- Auto-resolved: `False`
- Reason: Active item contains retired IA, retired terminology, or unsafe language; rewrite or retire before reuse.
- Involved active paths:
  - `FL06_Weekly_Life_Sweep_Ritual_Prompt` — `docs/codex/batches/FL06_Weekly_Life_Sweep_Ritual_Prompt.md` (partial_implementation; release proof)

### 215. Retired IA/terminology reference in GLOBAL_HPS_COMPLETION_ORDER_OVERLAY

- Candidate ID: `AMB28-retired_ia_or_terminology_reference-50598879`
- Evidence type: `retired_ia_or_terminology_reference`
- Severity: `yellow`
- Recommended action: `Rewrite`
- Linear-ready: `True`
- Auto-resolved: `False`
- Reason: Active item contains retired IA, retired terminology, or unsafe language; rewrite or retire before reuse.
- Involved active paths:
  - `GLOBAL_HPS_COMPLETION_ORDER_OVERLAY` — `docs/codex/GLOBAL_HPS_COMPLETION_ORDER_OVERLAY.md` (partial_implementation; release proof)

### 216. Retired IA/terminology reference in PK31

- Candidate ID: `AMB28-retired_ia_or_terminology_reference-50908752`
- Evidence type: `retired_ia_or_terminology_reference`
- Severity: `yellow`
- Recommended action: `Rewrite`
- Linear-ready: `True`
- Auto-resolved: `False`
- Reason: Active item contains retired IA, retired terminology, or unsafe language; rewrite or retire before reuse.
- Involved active paths:
  - `PK31` — `prompts/batches/PK31.md` (partial_implementation; release proof)

### 217. Retired IA/terminology reference in MOAT-UNIVERSAL-GOAL-REALITY-COMPILER-01

- Candidate ID: `AMB28-retired_ia_or_terminology_reference-51745767`
- Evidence type: `retired_ia_or_terminology_reference`
- Severity: `yellow`
- Recommended action: `Rewrite`
- Linear-ready: `True`
- Auto-resolved: `False`
- Reason: Active item contains retired IA, retired terminology, or unsafe language; rewrite or retire before reuse.
- Involved active paths:
  - `MOAT-UNIVERSAL-GOAL-REALITY-COMPILER-01` — `prompts/batches/MOAT-UNIVERSAL-GOAL-REALITY-COMPILER-01.md` (partial_implementation; release proof)

### 218. Retired IA/terminology reference in PFC38

- Candidate ID: `AMB28-retired_ia_or_terminology_reference-51767361`
- Evidence type: `retired_ia_or_terminology_reference`
- Severity: `yellow`
- Recommended action: `Rewrite`
- Linear-ready: `True`
- Auto-resolved: `False`
- Reason: Active item contains retired IA, retired terminology, or unsafe language; rewrite or retire before reuse.
- Involved active paths:
  - `PFC38` — `prompts/batches/PFC38.md` (partial_implementation; release proof)

### 219. Retired IA/terminology reference in EB09_Life_Event_Decision_And_Context_Recall_Memory_Prompt

- Candidate ID: `AMB28-retired_ia_or_terminology_reference-51799116`
- Evidence type: `retired_ia_or_terminology_reference`
- Severity: `yellow`
- Recommended action: `Rewrite`
- Linear-ready: `True`
- Auto-resolved: `False`
- Reason: Active item contains retired IA, retired terminology, or unsafe language; rewrite or retire before reuse.
- Involved active paths:
  - `EB09_Life_Event_Decision_And_Context_Recall_Memory_Prompt` — `docs/codex/batches/EB09_Life_Event_Decision_And_Context_Recall_Memory_Prompt.md` (partial_implementation; release proof)

### 220. Retired IA/terminology reference in AMBITIONSOS_AOS_TRACEABILITY_MATRIX

- Candidate ID: `AMB28-retired_ia_or_terminology_reference-51937999`
- Evidence type: `retired_ia_or_terminology_reference`
- Severity: `yellow`
- Recommended action: `Rewrite`
- Linear-ready: `True`
- Auto-resolved: `False`
- Reason: Active item contains retired IA, retired terminology, or unsafe language; rewrite or retire before reuse.
- Involved active paths:
  - `AMBITIONSOS_AOS_TRACEABILITY_MATRIX` — `docs/codex/AMBITIONSOS_AOS_TRACEABILITY_MATRIX.md` (partial_implementation; release proof)

### 221. Retired IA/terminology reference in EB34_External_Brain_Command_Surface_Integration_Prompt

- Candidate ID: `AMB28-retired_ia_or_terminology_reference-52022654`
- Evidence type: `retired_ia_or_terminology_reference`
- Severity: `yellow`
- Recommended action: `Rewrite`
- Linear-ready: `True`
- Auto-resolved: `False`
- Reason: Active item contains retired IA, retired terminology, or unsafe language; rewrite or retire before reuse.
- Involved active paths:
  - `EB34_External_Brain_Command_Surface_Integration_Prompt` — `docs/codex/batches/EB34_External_Brain_Command_Surface_Integration_Prompt.md` (partial_implementation; release proof)

### 222. Retired IA/terminology reference in EB08_Memory_Source_Confidence_And_Trust_Decay_Prompt

- Candidate ID: `AMB28-retired_ia_or_terminology_reference-52396302`
- Evidence type: `retired_ia_or_terminology_reference`
- Severity: `yellow`
- Recommended action: `Rewrite`
- Linear-ready: `True`
- Auto-resolved: `False`
- Reason: Active item contains retired IA, retired terminology, or unsafe language; rewrite or retire before reuse.
- Involved active paths:
  - `EB08_Memory_Source_Confidence_And_Trust_Decay_Prompt` — `docs/codex/batches/EB08_Memory_Source_Confidence_And_Trust_Decay_Prompt.md` (partial_implementation; release proof)

### 223. Retired IA/terminology reference in PD07_Goal_Proof_And_Decision_History_Depth_Prompt

- Candidate ID: `AMB28-retired_ia_or_terminology_reference-52411717`
- Evidence type: `retired_ia_or_terminology_reference`
- Severity: `yellow`
- Recommended action: `Rewrite`
- Linear-ready: `True`
- Auto-resolved: `False`
- Reason: Active item contains retired IA, retired terminology, or unsafe language; rewrite or retire before reuse.
- Involved active paths:
  - `PD07_Goal_Proof_And_Decision_History_Depth_Prompt` — `docs/codex/batches/PD07_Goal_Proof_And_Decision_History_Depth_Prompt.md` (partial_implementation; release proof)

### 224. Retired IA/terminology reference in AFI15_Founder_Acceptance_Review

- Candidate ID: `AMB28-retired_ia_or_terminology_reference-52523180`
- Evidence type: `retired_ia_or_terminology_reference`
- Severity: `yellow`
- Recommended action: `Rewrite`
- Linear-ready: `True`
- Auto-resolved: `False`
- Reason: Active item contains retired IA, retired terminology, or unsafe language; rewrite or retire before reuse.
- Involved active paths:
  - `AFI15_Founder_Acceptance_Review` — `docs/codex/batches/AFI15_Founder_Acceptance_Review.md` (partial_implementation; release proof)

### 225. Retired IA/terminology reference in FAANG_FRONTEND_IMPLEMENTATION_TEAM_OPERATING_SYSTEM

- Candidate ID: `AMB28-retired_ia_or_terminology_reference-52654879`
- Evidence type: `retired_ia_or_terminology_reference`
- Severity: `yellow`
- Recommended action: `Rewrite`
- Linear-ready: `True`
- Auto-resolved: `False`
- Reason: Active item contains retired IA, retired terminology, or unsafe language; rewrite or retire before reuse.
- Involved active paths:
  - `FAANG_FRONTEND_IMPLEMENTATION_TEAM_OPERATING_SYSTEM` — `docs/codex/frontend-implementation/FAANG_FRONTEND_IMPLEMENTATION_TEAM_OPERATING_SYSTEM.md` (partial_implementation; tests)

### 226. Retired IA/terminology reference in AQOS_AUTONOMOUS_QUALITY_OPERATING_SYSTEM

- Candidate ID: `AMB28-retired_ia_or_terminology_reference-53087073`
- Evidence type: `retired_ia_or_terminology_reference`
- Severity: `yellow`
- Recommended action: `Rewrite`
- Linear-ready: `True`
- Auto-resolved: `False`
- Reason: Active item contains retired IA, retired terminology, or unsafe language; rewrite or retire before reuse.
- Involved active paths:
  - `AQOS_AUTONOMOUS_QUALITY_OPERATING_SYSTEM` — `docs/codex/quality/AQOS_AUTONOMOUS_QUALITY_OPERATING_SYSTEM.md` (partial_implementation; release proof)

### 227. Retired IA/terminology reference in AOS15_Local_Language_Kernel_Planning_Prompt

- Candidate ID: `AMB28-retired_ia_or_terminology_reference-53242312`
- Evidence type: `retired_ia_or_terminology_reference`
- Severity: `yellow`
- Recommended action: `Rewrite`
- Linear-ready: `True`
- Auto-resolved: `False`
- Reason: Active item contains retired IA, retired terminology, or unsafe language; rewrite or retire before reuse.
- Involved active paths:
  - `AOS15_Local_Language_Kernel_Planning_Prompt` — `docs/codex/batches/AOS15_Local_Language_Kernel_Planning_Prompt.md` (partial_implementation; release proof)

### 228. Retired IA/terminology reference in AOS10_Commitment_Time_Kernel_Prompt

- Candidate ID: `AMB28-retired_ia_or_terminology_reference-53631081`
- Evidence type: `retired_ia_or_terminology_reference`
- Severity: `yellow`
- Recommended action: `Rewrite`
- Linear-ready: `True`
- Auto-resolved: `False`
- Reason: Active item contains retired IA, retired terminology, or unsafe language; rewrite or retire before reuse.
- Involved active paths:
  - `AOS10_Commitment_Time_Kernel_Prompt` — `docs/codex/batches/AOS10_Commitment_Time_Kernel_Prompt.md` (partial_implementation; release proof)

### 229. Retired IA/terminology reference in AOS18_Evaluation_Golden_Scenarios_Prompt

- Candidate ID: `AMB28-retired_ia_or_terminology_reference-53648885`
- Evidence type: `retired_ia_or_terminology_reference`
- Severity: `yellow`
- Recommended action: `Rewrite`
- Linear-ready: `True`
- Auto-resolved: `False`
- Reason: Active item contains retired IA, retired terminology, or unsafe language; rewrite or retire before reuse.
- Involved active paths:
  - `AOS18_Evaluation_Golden_Scenarios_Prompt` — `docs/codex/batches/AOS18_Evaluation_Golden_Scenarios_Prompt.md` (partial_implementation; release proof)

### 230. Retired IA/terminology reference in SA15

- Candidate ID: `AMB28-retired_ia_or_terminology_reference-53835462`
- Evidence type: `retired_ia_or_terminology_reference`
- Severity: `yellow`
- Recommended action: `Rewrite`
- Linear-ready: `True`
- Auto-resolved: `False`
- Reason: Active item contains retired IA, retired terminology, or unsafe language; rewrite or retire before reuse.
- Involved active paths:
  - `SA15` — `prompts/batches/SA15.md` (partial_implementation; release proof)

### 231. Retired IA/terminology reference in SA21

- Candidate ID: `AMB28-retired_ia_or_terminology_reference-54061326`
- Evidence type: `retired_ia_or_terminology_reference`
- Severity: `yellow`
- Recommended action: `Rewrite`
- Linear-ready: `True`
- Auto-resolved: `False`
- Reason: Active item contains retired IA, retired terminology, or unsafe language; rewrite or retire before reuse.
- Involved active paths:
  - `SA21` — `prompts/batches/SA21.md` (partial_implementation; release proof)

### 232. Retired IA/terminology reference in FVQ02_TOP_LEVEL_SURFACE_VISUAL_SWEEP

- Candidate ID: `AMB28-retired_ia_or_terminology_reference-54174032`
- Evidence type: `retired_ia_or_terminology_reference`
- Severity: `yellow`
- Recommended action: `Rewrite`
- Linear-ready: `True`
- Auto-resolved: `False`
- Reason: Active item contains retired IA, retired terminology, or unsafe language; rewrite or retire before reuse.
- Involved active paths:
  - `FVQ02_TOP_LEVEL_SURFACE_VISUAL_SWEEP` — `docs/codex/visual-quality/FVQ02_TOP_LEVEL_SURFACE_VISUAL_SWEEP.md` (unknown; release proof)

### 233. Retired IA/terminology reference in SA19

- Candidate ID: `AMB28-retired_ia_or_terminology_reference-54266556`
- Evidence type: `retired_ia_or_terminology_reference`
- Severity: `yellow`
- Recommended action: `Rewrite`
- Linear-ready: `True`
- Auto-resolved: `False`
- Reason: Active item contains retired IA, retired terminology, or unsafe language; rewrite or retire before reuse.
- Involved active paths:
  - `SA19` — `prompts/batches/SA19.md` (partial_implementation; release proof)

### 234. Retired IA/terminology reference in FE-07-ROOT-SURFACES

- Candidate ID: `AMB28-retired_ia_or_terminology_reference-54592296`
- Evidence type: `retired_ia_or_terminology_reference`
- Severity: `yellow`
- Recommended action: `Rewrite`
- Linear-ready: `True`
- Auto-resolved: `False`
- Reason: Active item contains retired IA, retired terminology, or unsafe language; rewrite or retire before reuse.
- Involved active paths:
  - `FE-07-ROOT-SURFACES` — `prompts/batches/amb-fe-be/FE-07-ROOT-SURFACES.md` (partial_implementation; tests)

### 235. Retired IA/terminology reference in EB27_Dynamic_Type_VoiceOver_And_Reduce_Motion_Prompt

- Candidate ID: `AMB28-retired_ia_or_terminology_reference-54773449`
- Evidence type: `retired_ia_or_terminology_reference`
- Severity: `yellow`
- Recommended action: `Rewrite`
- Linear-ready: `True`
- Auto-resolved: `False`
- Reason: Active item contains retired IA, retired terminology, or unsafe language; rewrite or retire before reuse.
- Involved active paths:
  - `EB27_Dynamic_Type_VoiceOver_And_Reduce_Motion_Prompt` — `docs/codex/batches/EB27_Dynamic_Type_VoiceOver_And_Reduce_Motion_Prompt.md` (partial_implementation; release proof)

### 236. Retired IA/terminology reference in DAV_PRODUCT_EXPERIENCE_SCORECARD

- Candidate ID: `AMB28-retired_ia_or_terminology_reference-55300179`
- Evidence type: `retired_ia_or_terminology_reference`
- Severity: `yellow`
- Recommended action: `Rewrite`
- Linear-ready: `True`
- Auto-resolved: `False`
- Reason: Active item contains retired IA, retired terminology, or unsafe language; rewrite or retire before reuse.
- Involved active paths:
  - `DAV_PRODUCT_EXPERIENCE_SCORECARD` — `docs/codex/DAV_PRODUCT_EXPERIENCE_SCORECARD.md` (partial_implementation; release proof)

### 237. Retired IA/terminology reference in AMB-REPO-GREEN-FLAGSHIP-RESET-MASTER-01-T09-GOALS-EXTRACTION

- Candidate ID: `AMB28-retired_ia_or_terminology_reference-55605573`
- Evidence type: `retired_ia_or_terminology_reference`
- Severity: `yellow`
- Recommended action: `Rewrite`
- Linear-ready: `True`
- Auto-resolved: `False`
- Reason: Active item contains retired IA, retired terminology, or unsafe language; rewrite or retire before reuse.
- Involved active paths:
  - `AMB-REPO-GREEN-FLAGSHIP-RESET-MASTER-01-T09-GOALS-EXTRACTION` — `prompts/batches/AMB-REPO-GREEN-FLAGSHIP-RESET-MASTER-01-T09-GOALS-EXTRACTION.md` (partial_implementation; tests)

### 238. Retired IA/terminology reference in SA11

- Candidate ID: `AMB28-retired_ia_or_terminology_reference-5567797`
- Evidence type: `retired_ia_or_terminology_reference`
- Severity: `yellow`
- Recommended action: `Rewrite`
- Linear-ready: `True`
- Auto-resolved: `False`
- Reason: Active item contains retired IA, retired terminology, or unsafe language; rewrite or retire before reuse.
- Involved active paths:
  - `SA11` — `prompts/batches/SA11.md` (partial_implementation; release proof)

### 239. Retired IA/terminology reference in EB39_External_Brain_Handoff_And_RC_Readiness_Implications_Prompt

- Candidate ID: `AMB28-retired_ia_or_terminology_reference-55750817`
- Evidence type: `retired_ia_or_terminology_reference`
- Severity: `yellow`
- Recommended action: `Rewrite`
- Linear-ready: `True`
- Auto-resolved: `False`
- Reason: Active item contains retired IA, retired terminology, or unsafe language; rewrite or retire before reuse.
- Involved active paths:
  - `EB39_External_Brain_Handoff_And_RC_Readiness_Implications_Prompt` — `docs/codex/batches/EB39_External_Brain_Handoff_And_RC_Readiness_Implications_Prompt.md` (partial_implementation; release proof)

### 240. Retired IA/terminology reference in RHC03

- Candidate ID: `AMB28-retired_ia_or_terminology_reference-55876317`
- Evidence type: `retired_ia_or_terminology_reference`
- Severity: `yellow`
- Recommended action: `Rewrite`
- Linear-ready: `True`
- Auto-resolved: `False`
- Reason: Active item contains retired IA, retired terminology, or unsafe language; rewrite or retire before reuse.
- Involved active paths:
  - `RHC03` — `prompts/batches/RHC03.md` (partial_implementation; release proof)

### 241. Retired IA/terminology reference in SOURCE_ATLAS_GATE_MATRIX

- Candidate ID: `AMB28-retired_ia_or_terminology_reference-55887398`
- Evidence type: `retired_ia_or_terminology_reference`
- Severity: `yellow`
- Recommended action: `Rewrite`
- Linear-ready: `True`
- Auto-resolved: `False`
- Reason: Active item contains retired IA, retired terminology, or unsafe language; rewrite or retire before reuse.
- Involved active paths:
  - `SOURCE_ATLAS_GATE_MATRIX` — `docs/codex/SOURCE_ATLAS_GATE_MATRIX.md` (partial_implementation; screenshot)

### 242. Retired IA/terminology reference in SIGNATURE_INTERFACE_SWIFTUI_ARCHITECTURE_MAP

- Candidate ID: `AMB28-retired_ia_or_terminology_reference-57236882`
- Evidence type: `retired_ia_or_terminology_reference`
- Severity: `yellow`
- Recommended action: `Rewrite`
- Linear-ready: `True`
- Auto-resolved: `False`
- Reason: Active item contains retired IA, retired terminology, or unsafe language; rewrite or retire before reuse.
- Involved active paths:
  - `SIGNATURE_INTERFACE_SWIFTUI_ARCHITECTURE_MAP` — `docs/codex/SIGNATURE_INTERFACE_SWIFTUI_ARCHITECTURE_MAP.md` (partial_implementation; release proof)

### 243. Retired IA/terminology reference in SA16

- Candidate ID: `AMB28-retired_ia_or_terminology_reference-57309418`
- Evidence type: `retired_ia_or_terminology_reference`
- Severity: `yellow`
- Recommended action: `Rewrite`
- Linear-ready: `True`
- Auto-resolved: `False`
- Reason: Active item contains retired IA, retired terminology, or unsafe language; rewrite or retire before reuse.
- Involved active paths:
  - `SA16` — `prompts/batches/SA16.md` (partial_implementation; release proof)

### 244. Retired IA/terminology reference in AQOS_SCRIPT_AND_TOOL_MAP

- Candidate ID: `AMB28-retired_ia_or_terminology_reference-57527432`
- Evidence type: `retired_ia_or_terminology_reference`
- Severity: `yellow`
- Recommended action: `Rewrite`
- Linear-ready: `True`
- Auto-resolved: `False`
- Reason: Active item contains retired IA, retired terminology, or unsafe language; rewrite or retire before reuse.
- Involved active paths:
  - `AQOS_SCRIPT_AND_TOOL_MAP` — `docs/codex/quality/AQOS_SCRIPT_AND_TOOL_MAP.md` (partial_implementation; release proof)

### 245. Retired IA/terminology reference in SA10C

- Candidate ID: `AMB28-retired_ia_or_terminology_reference-57818058`
- Evidence type: `retired_ia_or_terminology_reference`
- Severity: `yellow`
- Recommended action: `Rewrite`
- Linear-ready: `True`
- Auto-resolved: `False`
- Reason: Active item contains retired IA, retired terminology, or unsafe language; rewrite or retire before reuse.
- Involved active paths:
  - `SA10C` — `prompts/batches/SA10C.md` (partial_implementation; release proof)

### 246. Retired IA/terminology reference in EB38_External_Brain_Accessibility_Evidence_Closeout_Prompt

- Candidate ID: `AMB28-retired_ia_or_terminology_reference-58235384`
- Evidence type: `retired_ia_or_terminology_reference`
- Severity: `yellow`
- Recommended action: `Rewrite`
- Linear-ready: `True`
- Auto-resolved: `False`
- Reason: Active item contains retired IA, retired terminology, or unsafe language; rewrite or retire before reuse.
- Involved active paths:
  - `EB38_External_Brain_Accessibility_Evidence_Closeout_Prompt` — `docs/codex/batches/EB38_External_Brain_Accessibility_Evidence_Closeout_Prompt.md` (partial_implementation; release proof)

### 247. Retired IA/terminology reference in CODEX_QUALITY_SYSTEM_GATE_MATRIX

- Candidate ID: `AMB28-retired_ia_or_terminology_reference-58483242`
- Evidence type: `retired_ia_or_terminology_reference`
- Severity: `yellow`
- Recommended action: `Rewrite`
- Linear-ready: `True`
- Auto-resolved: `False`
- Reason: Active item contains retired IA, retired terminology, or unsafe language; rewrite or retire before reuse.
- Involved active paths:
  - `CODEX_QUALITY_SYSTEM_GATE_MATRIX` — `docs/codex/CODEX_QUALITY_SYSTEM_GATE_MATRIX.md` (partial_implementation; release proof)

### 248. Retired IA/terminology reference in HPS_GATE_MATRIX

- Candidate ID: `AMB28-retired_ia_or_terminology_reference-58798338`
- Evidence type: `retired_ia_or_terminology_reference`
- Severity: `yellow`
- Recommended action: `Rewrite`
- Linear-ready: `True`
- Auto-resolved: `False`
- Reason: Active item contains retired IA, retired terminology, or unsafe language; rewrite or retire before reuse.
- Involved active paths:
  - `HPS_GATE_MATRIX` — `docs/codex/HPS_GATE_MATRIX.md` (partial_implementation; tests)

### 249. Retired IA/terminology reference in PX09_Copy_Language_Explanation_System_Prompt

- Candidate ID: `AMB28-retired_ia_or_terminology_reference-59019336`
- Evidence type: `retired_ia_or_terminology_reference`
- Severity: `yellow`
- Recommended action: `Rewrite`
- Linear-ready: `True`
- Auto-resolved: `False`
- Reason: Active item contains retired IA, retired terminology, or unsafe language; rewrite or retire before reuse.
- Involved active paths:
  - `PX09_Copy_Language_Explanation_System_Prompt` — `docs/codex/batches/PX09_Copy_Language_Explanation_System_Prompt.md` (partial_implementation; release proof)

### 250. Retired IA/terminology reference in PFC12_App_Groups_Shared_Storage_Boundary_Prompt

- Candidate ID: `AMB28-retired_ia_or_terminology_reference-59379707`
- Evidence type: `retired_ia_or_terminology_reference`
- Severity: `yellow`
- Recommended action: `Rewrite`
- Linear-ready: `True`
- Auto-resolved: `False`
- Reason: Active item contains retired IA, retired terminology, or unsafe language; rewrite or retire before reuse.
- Involved active paths:
  - `PFC12_App_Groups_Shared_Storage_Boundary_Prompt` — `docs/codex/batches/PFC12_App_Groups_Shared_Storage_Boundary_Prompt.md` (unknown; release proof)

### 251. Retired IA/terminology reference in FVQ01_RENDERED_VISUAL_FRESHNESS_AND_FLAGSHIP_GATE

- Candidate ID: `AMB28-retired_ia_or_terminology_reference-59572796`
- Evidence type: `retired_ia_or_terminology_reference`
- Severity: `yellow`
- Recommended action: `Rewrite`
- Linear-ready: `True`
- Auto-resolved: `False`
- Reason: Active item contains retired IA, retired terminology, or unsafe language; rewrite or retire before reuse.
- Involved active paths:
  - `FVQ01_RENDERED_VISUAL_FRESHNESS_AND_FLAGSHIP_GATE` — `docs/codex/visual-quality/FVQ01_RENDERED_VISUAL_FRESHNESS_AND_FLAGSHIP_GATE.md` (partial_implementation; release proof)

### 252. Retired IA/terminology reference in UI-STUDIO-04-START-HERE-COMMAND-OBJECT

- Candidate ID: `AMB28-retired_ia_or_terminology_reference-59573709`
- Evidence type: `retired_ia_or_terminology_reference`
- Severity: `yellow`
- Recommended action: `Rewrite`
- Linear-ready: `True`
- Auto-resolved: `False`
- Reason: Active item contains retired IA, retired terminology, or unsafe language; rewrite or retire before reuse.
- Involved active paths:
  - `UI-STUDIO-04-START-HERE-COMMAND-OBJECT` — `prompts/batches/ui-flagship/UI-STUDIO-04-START-HERE-COMMAND-OBJECT.md` (partial_implementation; audit)

### 253. Retired IA/terminology reference in AMB-CODEX-OS-LAUNCH-BELIEVABILITY-GATE

- Candidate ID: `AMB28-retired_ia_or_terminology_reference-60147544`
- Evidence type: `retired_ia_or_terminology_reference`
- Severity: `yellow`
- Recommended action: `Rewrite`
- Linear-ready: `True`
- Auto-resolved: `False`
- Reason: Active item contains retired IA, retired terminology, or unsafe language; rewrite or retire before reuse.
- Involved active paths:
  - `AMB-CODEX-OS-LAUNCH-BELIEVABILITY-GATE` — `docs/codex/os/AMB-CODEX-OS-LAUNCH-BELIEVABILITY-GATE.md` (partial_implementation; source-only)

### 254. Retired IA/terminology reference in PX15_Cross_Surface_Continuity_Prompt

- Candidate ID: `AMB28-retired_ia_or_terminology_reference-60183591`
- Evidence type: `retired_ia_or_terminology_reference`
- Severity: `yellow`
- Recommended action: `Rewrite`
- Linear-ready: `True`
- Auto-resolved: `False`
- Reason: Active item contains retired IA, retired terminology, or unsafe language; rewrite or retire before reuse.
- Involved active paths:
  - `PX15_Cross_Surface_Continuity_Prompt` — `docs/codex/batches/PX15_Cross_Surface_Continuity_Prompt.md` (partial_implementation; release proof)

### 255. Retired IA/terminology reference in PD17_Cross_Surface_Proof_And_Review_Integration_Prompt

- Candidate ID: `AMB28-retired_ia_or_terminology_reference-60744596`
- Evidence type: `retired_ia_or_terminology_reference`
- Severity: `yellow`
- Recommended action: `Rewrite`
- Linear-ready: `True`
- Auto-resolved: `False`
- Reason: Active item contains retired IA, retired terminology, or unsafe language; rewrite or retire before reuse.
- Involved active paths:
  - `PD17_Cross_Surface_Proof_And_Review_Integration_Prompt` — `docs/codex/batches/PD17_Cross_Surface_Proof_And_Review_Integration_Prompt.md` (partial_implementation; release proof)

### 256. Retired IA/terminology reference in AOS25

- Candidate ID: `AMB28-retired_ia_or_terminology_reference-60831672`
- Evidence type: `retired_ia_or_terminology_reference`
- Severity: `yellow`
- Recommended action: `Rewrite`
- Linear-ready: `True`
- Auto-resolved: `False`
- Reason: Active item contains retired IA, retired terminology, or unsafe language; rewrite or retire before reuse.
- Involved active paths:
  - `AOS25` — `prompts/batches/AOS25.md` (partial_implementation; release proof)

### 257. Retired IA/terminology reference in AQOS01_AQOS30_AUTONOMOUS_QUALITY_TRAIN

- Candidate ID: `AMB28-retired_ia_or_terminology_reference-61147223`
- Evidence type: `retired_ia_or_terminology_reference`
- Severity: `yellow`
- Recommended action: `Rewrite`
- Linear-ready: `True`
- Auto-resolved: `False`
- Reason: Active item contains retired IA, retired terminology, or unsafe language; rewrite or retire before reuse.
- Involved active paths:
  - `AQOS01_AQOS30_AUTONOMOUS_QUALITY_TRAIN` — `docs/codex/quality/AQOS01_AQOS30_AUTONOMOUS_QUALITY_TRAIN.md` (unknown; release proof)

### 258. Retired IA/terminology reference in EB20_Value_Based_Onboarding_And_First_Week_Success_Prompt

- Candidate ID: `AMB28-retired_ia_or_terminology_reference-61493178`
- Evidence type: `retired_ia_or_terminology_reference`
- Severity: `yellow`
- Recommended action: `Rewrite`
- Linear-ready: `True`
- Auto-resolved: `False`
- Reason: Active item contains retired IA, retired terminology, or unsafe language; rewrite or retire before reuse.
- Involved active paths:
  - `EB20_Value_Based_Onboarding_And_First_Week_Success_Prompt` — `docs/codex/batches/EB20_Value_Based_Onboarding_And_First_Week_Success_Prompt.md` (partial_implementation; release proof)

### 259. Retired IA/terminology reference in SA28_LDI15_AOS24_MANIFEST_RERUN_DIRECTIVE

- Candidate ID: `AMB28-retired_ia_or_terminology_reference-63349517`
- Evidence type: `retired_ia_or_terminology_reference`
- Severity: `yellow`
- Recommended action: `Rewrite`
- Linear-ready: `True`
- Auto-resolved: `False`
- Reason: Active item contains retired IA, retired terminology, or unsafe language; rewrite or retire before reuse.
- Involved active paths:
  - `SA28_LDI15_AOS24_MANIFEST_RERUN_DIRECTIVE` — `docs/codex/SA28_LDI15_AOS24_MANIFEST_RERUN_DIRECTIVE.md` (partial_implementation; release proof)

### 260. Retired IA/terminology reference in RHC05

- Candidate ID: `AMB28-retired_ia_or_terminology_reference-63384416`
- Evidence type: `retired_ia_or_terminology_reference`
- Severity: `yellow`
- Recommended action: `Rewrite`
- Linear-ready: `True`
- Auto-resolved: `False`
- Reason: Active item contains retired IA, retired terminology, or unsafe language; rewrite or retire before reuse.
- Involved active paths:
  - `RHC05` — `prompts/batches/RHC05.md` (partial_implementation; release proof)

### 261. Retired IA/terminology reference in ios26-toolchain-matrix

- Candidate ID: `AMB28-retired_ia_or_terminology_reference-6359892`
- Evidence type: `retired_ia_or_terminology_reference`
- Severity: `yellow`
- Recommended action: `Rewrite`
- Linear-ready: `True`
- Auto-resolved: `False`
- Reason: Active item contains retired IA, retired terminology, or unsafe language; rewrite or retire before reuse.
- Involved active paths:
  - `ios26-toolchain-matrix` — `docs/codex/ios26-toolchain-matrix.md` (partial_implementation; audit)

### 262. Retired IA/terminology reference in PX17_Release_Truth_Product_Messaging_Prompt

- Candidate ID: `AMB28-retired_ia_or_terminology_reference-6365892`
- Evidence type: `retired_ia_or_terminology_reference`
- Severity: `yellow`
- Recommended action: `Rewrite`
- Linear-ready: `True`
- Auto-resolved: `False`
- Reason: Active item contains retired IA, retired terminology, or unsafe language; rewrite or retire before reuse.
- Involved active paths:
  - `PX17_Release_Truth_Product_Messaging_Prompt` — `docs/codex/batches/PX17_Release_Truth_Product_Messaging_Prompt.md` (partial_implementation; release proof)

### 263. Retired IA/terminology reference in PD10_Capture_Correction_And_Confidence_Loops_Prompt

- Candidate ID: `AMB28-retired_ia_or_terminology_reference-63762908`
- Evidence type: `retired_ia_or_terminology_reference`
- Severity: `yellow`
- Recommended action: `Rewrite`
- Linear-ready: `True`
- Auto-resolved: `False`
- Reason: Active item contains retired IA, retired terminology, or unsafe language; rewrite or retire before reuse.
- Involved active paths:
  - `PD10_Capture_Correction_And_Confidence_Loops_Prompt` — `docs/codex/batches/PD10_Capture_Correction_And_Confidence_Loops_Prompt.md` (partial_implementation; release proof)

### 264. Retired IA/terminology reference in FCP01_FCP30_FLAGSHIP_COMPLETION_TRAIN

- Candidate ID: `AMB28-retired_ia_or_terminology_reference-64009554`
- Evidence type: `retired_ia_or_terminology_reference`
- Severity: `yellow`
- Recommended action: `Rewrite`
- Linear-ready: `True`
- Auto-resolved: `False`
- Reason: Active item contains retired IA, retired terminology, or unsafe language; rewrite or retire before reuse.
- Involved active paths:
  - `FCP01_FCP30_FLAGSHIP_COMPLETION_TRAIN` — `docs/codex/batch-trains/FCP01_FCP30_FLAGSHIP_COMPLETION_TRAIN.md` (partial_implementation; release proof)

### 265. Retired IA/terminology reference in EB40_Ambitions_4_0_External_Brain_Closeout_Prompt

- Candidate ID: `AMB28-retired_ia_or_terminology_reference-64055242`
- Evidence type: `retired_ia_or_terminology_reference`
- Severity: `yellow`
- Recommended action: `Rewrite`
- Linear-ready: `True`
- Auto-resolved: `False`
- Reason: Active item contains retired IA, retired terminology, or unsafe language; rewrite or retire before reuse.
- Involved active paths:
  - `EB40_Ambitions_4_0_External_Brain_Closeout_Prompt` — `docs/codex/batches/EB40_Ambitions_4_0_External_Brain_Closeout_Prompt.md` (partial_implementation; release proof)

### 266. Retired IA/terminology reference in FL01_Founder_Backstory_Product_Soul_Lock_Prompt

- Candidate ID: `AMB28-retired_ia_or_terminology_reference-64088720`
- Evidence type: `retired_ia_or_terminology_reference`
- Severity: `yellow`
- Recommended action: `Rewrite`
- Linear-ready: `True`
- Auto-resolved: `False`
- Reason: Active item contains retired IA, retired terminology, or unsafe language; rewrite or retire before reuse.
- Involved active paths:
  - `FL01_Founder_Backstory_Product_Soul_Lock_Prompt` — `docs/codex/batches/FL01_Founder_Backstory_Product_Soul_Lock_Prompt.md` (partial_implementation; audit)

### 267. Retired IA/terminology reference in EB03_Universal_Capture_Composer_And_Routing_Prompt

- Candidate ID: `AMB28-retired_ia_or_terminology_reference-64096867`
- Evidence type: `retired_ia_or_terminology_reference`
- Severity: `yellow`
- Recommended action: `Rewrite`
- Linear-ready: `True`
- Auto-resolved: `False`
- Reason: Active item contains retired IA, retired terminology, or unsafe language; rewrite or retire before reuse.
- Involved active paths:
  - `EB03_Universal_Capture_Composer_And_Routing_Prompt` — `docs/codex/batches/EB03_Universal_Capture_Composer_And_Routing_Prompt.md` (partial_implementation; release proof)

### 268. Retired IA/terminology reference in AOS07_Local_Goal_Packs_Requirement_Slots_Prompt

- Candidate ID: `AMB28-retired_ia_or_terminology_reference-64179804`
- Evidence type: `retired_ia_or_terminology_reference`
- Severity: `yellow`
- Recommended action: `Rewrite`
- Linear-ready: `True`
- Auto-resolved: `False`
- Reason: Active item contains retired IA, retired terminology, or unsafe language; rewrite or retire before reuse.
- Involved active paths:
  - `AOS07_Local_Goal_Packs_Requirement_Slots_Prompt` — `docs/codex/batches/AOS07_Local_Goal_Packs_Requirement_Slots_Prompt.md` (partial_implementation; release proof)

### 269. Retired IA/terminology reference in AQOS_REQUIRED_EVIDENCE_MATRIX

- Candidate ID: `AMB28-retired_ia_or_terminology_reference-64181021`
- Evidence type: `retired_ia_or_terminology_reference`
- Severity: `yellow`
- Recommended action: `Rewrite`
- Linear-ready: `True`
- Auto-resolved: `False`
- Reason: Active item contains retired IA, retired terminology, or unsafe language; rewrite or retire before reuse.
- Involved active paths:
  - `AQOS_REQUIRED_EVIDENCE_MATRIX` — `docs/codex/quality/AQOS_REQUIRED_EVIDENCE_MATRIX.md` (partial_implementation; release proof)

### 270. Retired IA/terminology reference in PFC39

- Candidate ID: `AMB28-retired_ia_or_terminology_reference-64185679`
- Evidence type: `retired_ia_or_terminology_reference`
- Severity: `yellow`
- Recommended action: `Rewrite`
- Linear-ready: `True`
- Auto-resolved: `False`
- Reason: Active item contains retired IA, retired terminology, or unsafe language; rewrite or retire before reuse.
- Involved active paths:
  - `PFC39` — `prompts/batches/PFC39.md` (partial_implementation; release proof)

### 271. Retired IA/terminology reference in F03_5_Today_Execution_State_Contract_Hardening_Prompt

- Candidate ID: `AMB28-retired_ia_or_terminology_reference-64412950`
- Evidence type: `retired_ia_or_terminology_reference`
- Severity: `yellow`
- Recommended action: `Rewrite`
- Linear-ready: `True`
- Auto-resolved: `False`
- Reason: Active item contains retired IA, retired terminology, or unsafe language; rewrite or retire before reuse.
- Involved active paths:
  - `F03_5_Today_Execution_State_Contract_Hardening_Prompt` — `docs/codex/batches/F03_5_Today_Execution_State_Contract_Hardening_Prompt.md` (partial_implementation; tests)

### 272. Retired IA/terminology reference in GLOBAL-VISUAL-CANON-MOAT-INSTALL-TRAIN-01

- Candidate ID: `AMB28-retired_ia_or_terminology_reference-64652736`
- Evidence type: `retired_ia_or_terminology_reference`
- Severity: `yellow`
- Recommended action: `Rewrite`
- Linear-ready: `True`
- Auto-resolved: `False`
- Reason: Active item contains retired IA, retired terminology, or unsafe language; rewrite or retire before reuse.
- Involved active paths:
  - `GLOBAL-VISUAL-CANON-MOAT-INSTALL-TRAIN-01` — `prompts/batches/GLOBAL-VISUAL-CANON-MOAT-INSTALL-TRAIN-01.md` (partial_implementation; release proof)

### 273. Retired IA/terminology reference in START-HERE-REALITY-RECOGNITION-01

- Candidate ID: `AMB28-retired_ia_or_terminology_reference-64921026`
- Evidence type: `retired_ia_or_terminology_reference`
- Severity: `yellow`
- Recommended action: `Rewrite`
- Linear-ready: `True`
- Auto-resolved: `False`
- Reason: Active item contains retired IA, retired terminology, or unsafe language; rewrite or retire before reuse.
- Involved active paths:
  - `START-HERE-REALITY-RECOGNITION-01` — `prompts/batches/START-HERE-REALITY-RECOGNITION-01.md` (partial_implementation; release proof)

### 274. Retired IA/terminology reference in UI-STUDIO-01-SURFACE-BRIEF-SYSTEM

- Candidate ID: `AMB28-retired_ia_or_terminology_reference-65090740`
- Evidence type: `retired_ia_or_terminology_reference`
- Severity: `yellow`
- Recommended action: `Rewrite`
- Linear-ready: `True`
- Auto-resolved: `False`
- Reason: Active item contains retired IA, retired terminology, or unsafe language; rewrite or retire before reuse.
- Involved active paths:
  - `UI-STUDIO-01-SURFACE-BRIEF-SYSTEM` — `prompts/batches/ui-flagship/UI-STUDIO-01-SURFACE-BRIEF-SYSTEM.md` (partial_implementation; release proof)

### 275. Retired IA/terminology reference in IOS26_OBJECT_FRONTEND_BATCH_INSERTION_PLAN

- Candidate ID: `AMB28-retired_ia_or_terminology_reference-65485713`
- Evidence type: `retired_ia_or_terminology_reference`
- Severity: `yellow`
- Recommended action: `Rewrite`
- Linear-ready: `True`
- Auto-resolved: `False`
- Reason: Active item contains retired IA, retired terminology, or unsafe language; rewrite or retire before reuse.
- Involved active paths:
  - `IOS26_OBJECT_FRONTEND_BATCH_INSERTION_PLAN` — `docs/codex/frontend/IOS26_OBJECT_FRONTEND_BATCH_INSERTION_PLAN.md` (partial_implementation; tests)

### 276. Retired IA/terminology reference in EB24_Onboarding_Receipts_Skip_Later_And_Setup_Recovery_Prompt

- Candidate ID: `AMB28-retired_ia_or_terminology_reference-6556037`
- Evidence type: `retired_ia_or_terminology_reference`
- Severity: `yellow`
- Recommended action: `Rewrite`
- Linear-ready: `True`
- Auto-resolved: `False`
- Reason: Active item contains retired IA, retired terminology, or unsafe language; rewrite or retire before reuse.
- Involved active paths:
  - `EB24_Onboarding_Receipts_Skip_Later_And_Setup_Recovery_Prompt` — `docs/codex/batches/EB24_Onboarding_Receipts_Skip_Later_And_Setup_Recovery_Prompt.md` (partial_implementation; release proof)

### 277. Retired IA/terminology reference in GLOBAL_BATCH_EXECUTION_ORCHESTRATOR

- Candidate ID: `AMB28-retired_ia_or_terminology_reference-65664534`
- Evidence type: `retired_ia_or_terminology_reference`
- Severity: `yellow`
- Recommended action: `Rewrite`
- Linear-ready: `True`
- Auto-resolved: `False`
- Reason: Active item contains retired IA, retired terminology, or unsafe language; rewrite or retire before reuse.
- Involved active paths:
  - `GLOBAL_BATCH_EXECUTION_ORCHESTRATOR` — `docs/codex/GLOBAL_BATCH_EXECUTION_ORCHESTRATOR.md` (partial_implementation; release proof)

### 278. Retired IA/terminology reference in IR01_FAANG_FRONTEND_INTERFACE_RECOVERY_PROMPT

- Candidate ID: `AMB28-retired_ia_or_terminology_reference-65667175`
- Evidence type: `retired_ia_or_terminology_reference`
- Severity: `yellow`
- Recommended action: `Rewrite`
- Linear-ready: `True`
- Auto-resolved: `False`
- Reason: Active item contains retired IA, retired terminology, or unsafe language; rewrite or retire before reuse.
- Involved active paths:
  - `IR01_FAANG_FRONTEND_INTERFACE_RECOVERY_PROMPT` — `docs/codex/batches/IR01_FAANG_FRONTEND_INTERFACE_RECOVERY_PROMPT.md` (partial_implementation; release proof)

### 279. Retired IA/terminology reference in MOAT-GOAL-REALITY-FIXTURE-LAB-02

- Candidate ID: `AMB28-retired_ia_or_terminology_reference-65821975`
- Evidence type: `retired_ia_or_terminology_reference`
- Severity: `yellow`
- Recommended action: `Rewrite`
- Linear-ready: `True`
- Auto-resolved: `False`
- Reason: Active item contains retired IA, retired terminology, or unsafe language; rewrite or retire before reuse.
- Involved active paths:
  - `MOAT-GOAL-REALITY-FIXTURE-LAB-02` — `prompts/batches/MOAT-GOAL-REALITY-FIXTURE-LAB-02.md` (partial_implementation; release proof)

### 280. Retired IA/terminology reference in OBJECT_OS_NATIVE_SURFACES

- Candidate ID: `AMB28-retired_ia_or_terminology_reference-66075999`
- Evidence type: `retired_ia_or_terminology_reference`
- Severity: `yellow`
- Recommended action: `Rewrite`
- Linear-ready: `True`
- Auto-resolved: `False`
- Reason: Active item contains retired IA, retired terminology, or unsafe language; rewrite or retire before reuse.
- Involved active paths:
  - `OBJECT_OS_NATIVE_SURFACES` — `docs/codex/OBJECT_OS_NATIVE_SURFACES.md` (unknown; screenshot)

### 281. Retired IA/terminology reference in PK24

- Candidate ID: `AMB28-retired_ia_or_terminology_reference-66148505`
- Evidence type: `retired_ia_or_terminology_reference`
- Severity: `yellow`
- Recommended action: `Rewrite`
- Linear-ready: `True`
- Auto-resolved: `False`
- Reason: Active item contains retired IA, retired terminology, or unsafe language; rewrite or retire before reuse.
- Involved active paths:
  - `PK24` — `prompts/batches/PK24.md` (partial_implementation; release proof)

### 282. Retired IA/terminology reference in PFC31

- Candidate ID: `AMB28-retired_ia_or_terminology_reference-66195525`
- Evidence type: `retired_ia_or_terminology_reference`
- Severity: `yellow`
- Recommended action: `Rewrite`
- Linear-ready: `True`
- Auto-resolved: `False`
- Reason: Active item contains retired IA, retired terminology, or unsafe language; rewrite or retire before reuse.
- Involved active paths:
  - `PFC31` — `prompts/batches/PFC31.md` (partial_implementation; release proof)

### 283. Retired IA/terminology reference in AMB-REPO-GREEN-FLAGSHIP-RESET-MASTER-01-T07-UI-PRIMITIVE-ORG

- Candidate ID: `AMB28-retired_ia_or_terminology_reference-66204250`
- Evidence type: `retired_ia_or_terminology_reference`
- Severity: `yellow`
- Recommended action: `Rewrite`
- Linear-ready: `True`
- Auto-resolved: `False`
- Reason: Active item contains retired IA, retired terminology, or unsafe language; rewrite or retire before reuse.
- Involved active paths:
  - `AMB-REPO-GREEN-FLAGSHIP-RESET-MASTER-01-T07-UI-PRIMITIVE-ORG` — `prompts/batches/AMB-REPO-GREEN-FLAGSHIP-RESET-MASTER-01-T07-UI-PRIMITIVE-ORG.md` (partial_implementation; tests)

### 284. Retired IA/terminology reference in SA20

- Candidate ID: `AMB28-retired_ia_or_terminology_reference-66226402`
- Evidence type: `retired_ia_or_terminology_reference`
- Severity: `yellow`
- Recommended action: `Rewrite`
- Linear-ready: `True`
- Auto-resolved: `False`
- Reason: Active item contains retired IA, retired terminology, or unsafe language; rewrite or retire before reuse.
- Involved active paths:
  - `SA20` — `prompts/batches/SA20.md` (partial_implementation; release proof)

### 285. Retired IA/terminology reference in PX05_Plan_Life_Shape_Experience_Prompt

- Candidate ID: `AMB28-retired_ia_or_terminology_reference-66290527`
- Evidence type: `retired_ia_or_terminology_reference`
- Severity: `yellow`
- Recommended action: `Rewrite`
- Linear-ready: `True`
- Auto-resolved: `False`
- Reason: Active item contains retired IA, retired terminology, or unsafe language; rewrite or retire before reuse.
- Involved active paths:
  - `PX05_Plan_Life_Shape_Experience_Prompt` — `docs/codex/batches/PX05_Plan_Life_Shape_Experience_Prompt.md` (partial_implementation; release proof)

### 286. Retired IA/terminology reference in PK27

- Candidate ID: `AMB28-retired_ia_or_terminology_reference-66335507`
- Evidence type: `retired_ia_or_terminology_reference`
- Severity: `yellow`
- Recommended action: `Rewrite`
- Linear-ready: `True`
- Auto-resolved: `False`
- Reason: Active item contains retired IA, retired terminology, or unsafe language; rewrite or retire before reuse.
- Involved active paths:
  - `PK27` — `prompts/batches/PK27.md` (partial_implementation; release proof)

### 287. Retired IA/terminology reference in AMB-REPO-AUTHORITY-06-ACTIVE-DRIFT-REPAIR

- Candidate ID: `AMB28-retired_ia_or_terminology_reference-66816138`
- Evidence type: `retired_ia_or_terminology_reference`
- Severity: `yellow`
- Recommended action: `Rewrite`
- Linear-ready: `True`
- Auto-resolved: `False`
- Reason: Active item contains retired IA, retired terminology, or unsafe language; rewrite or retire before reuse.
- Involved active paths:
  - `AMB-REPO-AUTHORITY-06-ACTIVE-DRIFT-REPAIR` — `prompts/batches/AMB-REPO-AUTHORITY-06-ACTIVE-DRIFT-REPAIR.md` (partial_implementation; release proof)

### 288. Retired IA/terminology reference in LDI18

- Candidate ID: `AMB28-retired_ia_or_terminology_reference-66877072`
- Evidence type: `retired_ia_or_terminology_reference`
- Severity: `yellow`
- Recommended action: `Rewrite`
- Linear-ready: `True`
- Auto-resolved: `False`
- Reason: Active item contains retired IA, retired terminology, or unsafe language; rewrite or retire before reuse.
- Involved active paths:
  - `LDI18` — `prompts/batches/LDI18.md` (partial_implementation; release proof)

### 289. Retired IA/terminology reference in AOS20_Adaptation_Kernel_Local_Personalization_Prompt

- Candidate ID: `AMB28-retired_ia_or_terminology_reference-66914326`
- Evidence type: `retired_ia_or_terminology_reference`
- Severity: `yellow`
- Recommended action: `Rewrite`
- Linear-ready: `True`
- Auto-resolved: `False`
- Reason: Active item contains retired IA, retired terminology, or unsafe language; rewrite or retire before reuse.
- Involved active paths:
  - `AOS20_Adaptation_Kernel_Local_Personalization_Prompt` — `docs/codex/batches/AOS20_Adaptation_Kernel_Local_Personalization_Prompt.md` (partial_implementation; release proof)

### 290. Retired IA/terminology reference in AMB-REPO-GREEN-FLAGSHIP-RESET-MASTER-01

- Candidate ID: `AMB28-retired_ia_or_terminology_reference-67647555`
- Evidence type: `retired_ia_or_terminology_reference`
- Severity: `yellow`
- Recommended action: `Rewrite`
- Linear-ready: `True`
- Auto-resolved: `False`
- Reason: Active item contains retired IA, retired terminology, or unsafe language; rewrite or retire before reuse.
- Involved active paths:
  - `AMB-REPO-GREEN-FLAGSHIP-RESET-MASTER-01` — `prompts/batches/AMB-REPO-GREEN-FLAGSHIP-RESET-MASTER-01.md` (partial_implementation; release proof)

### 291. Retired IA/terminology reference in LDI15

- Candidate ID: `AMB28-retired_ia_or_terminology_reference-67647848`
- Evidence type: `retired_ia_or_terminology_reference`
- Severity: `yellow`
- Recommended action: `Rewrite`
- Linear-ready: `True`
- Auto-resolved: `False`
- Reason: Active item contains retired IA, retired terminology, or unsafe language; rewrite or retire before reuse.
- Involved active paths:
  - `LDI15` — `prompts/batches/LDI15.md` (partial_implementation; release proof)

### 292. Retired IA/terminology reference in FE-02-DESIGN-LANGUAGE

- Candidate ID: `AMB28-retired_ia_or_terminology_reference-67710715`
- Evidence type: `retired_ia_or_terminology_reference`
- Severity: `yellow`
- Recommended action: `Rewrite`
- Linear-ready: `True`
- Auto-resolved: `False`
- Reason: Active item contains retired IA, retired terminology, or unsafe language; rewrite or retire before reuse.
- Involved active paths:
  - `FE-02-DESIGN-LANGUAGE` — `prompts/batches/amb-fe-be/FE-02-DESIGN-LANGUAGE.md` (partial_implementation; screenshot)

### 293. Retired IA/terminology reference in AQOS_REPAIR_BATCH_GENERATOR_PROTOCOL

- Candidate ID: `AMB28-retired_ia_or_terminology_reference-68020254`
- Evidence type: `retired_ia_or_terminology_reference`
- Severity: `yellow`
- Recommended action: `Rewrite`
- Linear-ready: `True`
- Auto-resolved: `False`
- Reason: Active item contains retired IA, retired terminology, or unsafe language; rewrite or retire before reuse.
- Involved active paths:
  - `AQOS_REPAIR_BATCH_GENERATOR_PROTOCOL` — `docs/codex/quality/AQOS_REPAIR_BATCH_GENERATOR_PROTOCOL.md` (partial_implementation; screenshot)

### 294. Retired IA/terminology reference in IRQ-02

- Candidate ID: `AMB28-retired_ia_or_terminology_reference-68198516`
- Evidence type: `retired_ia_or_terminology_reference`
- Severity: `yellow`
- Recommended action: `Rewrite`
- Linear-ready: `True`
- Auto-resolved: `False`
- Reason: Active item contains retired IA, retired terminology, or unsafe language; rewrite or retire before reuse.
- Involved active paths:
  - `IRQ-02` — `prompts/batches/IRQ-02.md` (partial_implementation; release proof)

### 295. Retired IA/terminology reference in AMB-POST23-04-NEXT-TRAIN-RECOMMENDATION

- Candidate ID: `AMB28-retired_ia_or_terminology_reference-68335231`
- Evidence type: `retired_ia_or_terminology_reference`
- Severity: `yellow`
- Recommended action: `Rewrite`
- Linear-ready: `True`
- Auto-resolved: `False`
- Reason: Active item contains retired IA, retired terminology, or unsafe language; rewrite or retire before reuse.
- Involved active paths:
  - `AMB-POST23-04-NEXT-TRAIN-RECOMMENDATION` — `docs/codex/reports/AMB-POST23-04-NEXT-TRAIN-RECOMMENDATION.md` (partial_implementation; release proof)

### 296. Retired IA/terminology reference in FE-11-PREVIEWS-VISUAL-QA

- Candidate ID: `AMB28-retired_ia_or_terminology_reference-68425714`
- Evidence type: `retired_ia_or_terminology_reference`
- Severity: `yellow`
- Recommended action: `Rewrite`
- Linear-ready: `True`
- Auto-resolved: `False`
- Reason: Active item contains retired IA, retired terminology, or unsafe language; rewrite or retire before reuse.
- Involved active paths:
  - `FE-11-PREVIEWS-VISUAL-QA` — `prompts/batches/amb-fe-be/FE-11-PREVIEWS-VISUAL-QA.md` (partial_implementation; screenshot)

### 297. Retired IA/terminology reference in PK28

- Candidate ID: `AMB28-retired_ia_or_terminology_reference-68436344`
- Evidence type: `retired_ia_or_terminology_reference`
- Severity: `yellow`
- Recommended action: `Rewrite`
- Linear-ready: `True`
- Auto-resolved: `False`
- Reason: Active item contains retired IA, retired terminology, or unsafe language; rewrite or retire before reuse.
- Involved active paths:
  - `PK28` — `prompts/batches/PK28.md` (partial_implementation; release proof)

### 298. Retired IA/terminology reference in SA31

- Candidate ID: `AMB28-retired_ia_or_terminology_reference-68669777`
- Evidence type: `retired_ia_or_terminology_reference`
- Severity: `yellow`
- Recommended action: `Rewrite`
- Linear-ready: `True`
- Auto-resolved: `False`
- Reason: Active item contains retired IA, retired terminology, or unsafe language; rewrite or retire before reuse.
- Involved active paths:
  - `SA31` — `prompts/batches/SA31.md` (partial_implementation; release proof)

### 299. Retired IA/terminology reference in AOS09_Option_Value_North_Star_Prompt

- Candidate ID: `AMB28-retired_ia_or_terminology_reference-68899942`
- Evidence type: `retired_ia_or_terminology_reference`
- Severity: `yellow`
- Recommended action: `Rewrite`
- Linear-ready: `True`
- Auto-resolved: `False`
- Reason: Active item contains retired IA, retired terminology, or unsafe language; rewrite or retire before reuse.
- Involved active paths:
  - `AOS09_Option_Value_North_Star_Prompt` — `docs/codex/batches/AOS09_Option_Value_North_Star_Prompt.md` (partial_implementation; release proof)

### 300. Retired IA/terminology reference in AFI06_Today_Reality_Meridian

- Candidate ID: `AMB28-retired_ia_or_terminology_reference-69414803`
- Evidence type: `retired_ia_or_terminology_reference`
- Severity: `yellow`
- Recommended action: `Rewrite`
- Linear-ready: `True`
- Auto-resolved: `False`
- Reason: Active item contains retired IA, retired terminology, or unsafe language; rewrite or retire before reuse.
- Involved active paths:
  - `AFI06_Today_Reality_Meridian` — `docs/codex/batches/AFI06_Today_Reality_Meridian.md` (partial_implementation; tests)

- ... 1436 more active candidates in JSON

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
