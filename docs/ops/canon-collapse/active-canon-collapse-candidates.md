# Active Canon Collapse Candidates

Status: GREEN
Generated UTC: 2026-05-29T12:43:58Z
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

- Active candidates: `468`
- Historical-only residue: `0`
- Red active candidates: `0`
- Auto-resolved candidates: `0`

### Active candidates by action

- `Expedite`: `214`
- `Finish proof`: `21`
- `Merge`: `203`
- `Rewrite`: `30`

### Active candidates by conflict type

- `duplicate_stable_id`: `31`
- `missing_source_of_truth_reference`: `21`
- `retired_ia_or_terminology_reference`: `9`
- `same_source_file_targeted_by_multiple_active_batches`: `172`
- `source_only_implementation_missing_proof`: `27`
- `stale_or_unknown_active_status`: `208`

## Next bounded action bundle

- Bundle ID: `canon-collapse-finish-proof-bundle`
- Title: Finish proof for active source-only / missing-proof items
- Recommended action: `Finish proof`
- Candidate count: `21`
- Reason: Source-only or missing-proof work cannot be treated as complete.

### Bundle candidate IDs

- `AMB28-source_only_implementation_missing_proof-18187313`
- `AMB28-source_only_implementation_missing_proof-18602262`
- `AMB28-source_only_implementation_missing_proof-329720`
- `AMB28-source_only_implementation_missing_proof-33075517`
- `AMB28-source_only_implementation_missing_proof-38774666`
- `AMB28-source_only_implementation_missing_proof-41744582`
- `AMB28-source_only_implementation_missing_proof-44250454`
- `AMB28-source_only_implementation_missing_proof-44864164`
- `AMB28-source_only_implementation_missing_proof-46583565`
- `AMB28-source_only_implementation_missing_proof-49562131`
- `AMB28-source_only_implementation_missing_proof-55235798`
- `AMB28-source_only_implementation_missing_proof-61842138`
- `AMB28-source_only_implementation_missing_proof-64666452`
- `AMB28-source_only_implementation_missing_proof-6516509`
- `AMB28-source_only_implementation_missing_proof-69617344`
- `AMB28-source_only_implementation_missing_proof-78349230`
- `AMB28-source_only_implementation_missing_proof-82962295`
- `AMB28-source_only_implementation_missing_proof-92298325`
- `AMB28-source_only_implementation_missing_proof-92792165`
- `AMB28-source_only_implementation_missing_proof-95286941`
- `AMB28-source_only_implementation_missing_proof-99183681`

### Bundle repo paths

- `docs/codex/CHAMPION_MERGE_TRAIN_MANIFEST.yml`
- `docs/codex/HARNESS_LINEAR.md`
- `docs/codex/HARNESS_RUNS.md`
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

### 1. Retired IA/terminology reference in HISTORICAL_BASELINE_GLOBAL_TRAIN_MANIFEST

- Candidate ID: `AMB28-retired_ia_or_terminology_reference-14535318`
- Evidence type: `retired_ia_or_terminology_reference`
- Severity: `yellow`
- Recommended action: `Rewrite`
- Linear-ready: `True`
- Auto-resolved: `False`
- Reason: Active item contains retired IA, retired terminology, or unsafe language; rewrite or retire before reuse.
- Involved active paths:
  - `HISTORICAL_BASELINE_GLOBAL_TRAIN_MANIFEST` — `docs/codex/HISTORICAL_BASELINE_GLOBAL_TRAIN_MANIFEST.json` (unknown; release proof)

### 2. Retired IA/terminology reference in TRAIN_08_CAPTURE_ATMOSPHERE_COMPOSER_FINAL_OBJECT

- Candidate ID: `AMB28-retired_ia_or_terminology_reference-14552405`
- Evidence type: `retired_ia_or_terminology_reference`
- Severity: `yellow`
- Recommended action: `Rewrite`
- Linear-ready: `True`
- Auto-resolved: `False`
- Reason: Active item contains retired IA, retired terminology, or unsafe language; rewrite or retire before reuse.
- Involved active paths:
  - `TRAIN_08_CAPTURE_ATMOSPHERE_COMPOSER_FINAL_OBJECT` — `prompts/trains/ios26-flagship/TRAIN_08_CAPTURE_ATMOSPHERE_COMPOSER_FINAL_OBJECT.md` (partial_implementation; source-only)

### 3. Retired IA/terminology reference in AMB_GLOBAL_REMAINING_TRAIN_BLUEPRINT

- Candidate ID: `AMB28-retired_ia_or_terminology_reference-19889629`
- Evidence type: `retired_ia_or_terminology_reference`
- Severity: `yellow`
- Recommended action: `Rewrite`
- Linear-ready: `True`
- Auto-resolved: `False`
- Reason: Active item contains retired IA, retired terminology, or unsafe language; rewrite or retire before reuse.
- Involved active paths:
  - `AMB_GLOBAL_REMAINING_TRAIN_BLUEPRINT` — `docs/codex/AMB_GLOBAL_REMAINING_TRAIN_BLUEPRINT.json` (unknown; tests)

### 4. Retired IA/terminology reference in parallel-guard-concept-registry

- Candidate ID: `AMB28-retired_ia_or_terminology_reference-30202767`
- Evidence type: `retired_ia_or_terminology_reference`
- Severity: `yellow`
- Recommended action: `Rewrite`
- Linear-ready: `True`
- Auto-resolved: `False`
- Reason: Active item contains retired IA, retired terminology, or unsafe language; rewrite or retire before reuse.
- Involved active paths:
  - `parallel-guard-concept-registry` — `docs/codex/parallel-guard-concept-registry.yml` (partial_implementation; source-only)

### 5. Retired IA/terminology reference in TRAIN_04D_CAPTURE_RUNTIME_FACTORING_FUTURE_PROOF

- Candidate ID: `AMB28-retired_ia_or_terminology_reference-31226555`
- Evidence type: `retired_ia_or_terminology_reference`
- Severity: `yellow`
- Recommended action: `Rewrite`
- Linear-ready: `True`
- Auto-resolved: `False`
- Reason: Active item contains retired IA, retired terminology, or unsafe language; rewrite or retire before reuse.
- Involved active paths:
  - `TRAIN_04D_CAPTURE_RUNTIME_FACTORING_FUTURE_PROOF` — `prompts/trains/ios26-flagship/TRAIN_04D_CAPTURE_RUNTIME_FACTORING_FUTURE_PROOF.md` (partial_implementation; release proof)

### 6. Retired IA/terminology reference in existing-code-champion-coverage

- Candidate ID: `AMB28-retired_ia_or_terminology_reference-66413049`
- Evidence type: `retired_ia_or_terminology_reference`
- Severity: `yellow`
- Recommended action: `Rewrite`
- Linear-ready: `True`
- Auto-resolved: `False`
- Reason: Active item contains retired IA, retired terminology, or unsafe language; rewrite or retire before reuse.
- Involved active paths:
  - `existing-code-champion-coverage` — `docs/codex/existing-code-champion-coverage.yml` (unknown; release proof)

### 7. Retired IA/terminology reference in HARNESS_ARTIFACT_SCHEMA

- Candidate ID: `AMB28-retired_ia_or_terminology_reference-72645401`
- Evidence type: `retired_ia_or_terminology_reference`
- Severity: `yellow`
- Recommended action: `Rewrite`
- Linear-ready: `True`
- Auto-resolved: `False`
- Reason: Active item contains retired IA, retired terminology, or unsafe language; rewrite or retire before reuse.
- Involved active paths:
  - `HARNESS_ARTIFACT_SCHEMA` — `docs/codex/HARNESS_ARTIFACT_SCHEMA.md` (partial_implementation; audit)

### 8. Retired IA/terminology reference in MOAT_RUNTIME_BATCH_OVERLAY

- Candidate ID: `AMB28-retired_ia_or_terminology_reference-76754967`
- Evidence type: `retired_ia_or_terminology_reference`
- Severity: `yellow`
- Recommended action: `Rewrite`
- Linear-ready: `True`
- Auto-resolved: `False`
- Reason: Active item contains retired IA, retired terminology, or unsafe language; rewrite or retire before reuse.
- Involved active paths:
  - `MOAT_RUNTIME_BATCH_OVERLAY` — `docs/codex/MOAT_RUNTIME_BATCH_OVERLAY.json` (partial_implementation; release proof)

### 9. Retired IA/terminology reference in AMB-LINEAR-TEMPLATE-MANIFEST

- Candidate ID: `AMB28-retired_ia_or_terminology_reference-92674495`
- Evidence type: `retired_ia_or_terminology_reference`
- Severity: `yellow`
- Recommended action: `Rewrite`
- Linear-ready: `True`
- Auto-resolved: `False`
- Reason: Active item contains retired IA, retired terminology, or unsafe language; rewrite or retire before reuse.
- Involved active paths:
  - `AMB-LINEAR-TEMPLATE-MANIFEST` — `docs/codex/linear-templates/AMB-LINEAR-TEMPLATE-MANIFEST.yml` (partial_implementation; release proof)

### 10. Missing source-of-truth references in AMB_REMAINING_BATCH_REFERENCE

- Candidate ID: `AMB28-missing_source_of_truth_reference-12572321`
- Evidence type: `missing_source_of_truth_reference`
- Severity: `yellow`
- Recommended action: `Rewrite`
- Linear-ready: `True`
- Auto-resolved: `False`
- Reason: Active item lacks required source-of-truth references; rewrite before implementation use.
- Involved active paths:
  - `AMB_REMAINING_BATCH_REFERENCE` — `docs/codex/AMB_REMAINING_BATCH_REFERENCE.json` (partial_implementation; release proof)

### 11. Missing source-of-truth references in IOS26_DEPENDENCY_GRAPH

- Candidate ID: `AMB28-missing_source_of_truth_reference-1458041`
- Evidence type: `missing_source_of_truth_reference`
- Severity: `yellow`
- Recommended action: `Rewrite`
- Linear-ready: `True`
- Auto-resolved: `False`
- Reason: Active item lacks required source-of-truth references; rewrite before implementation use.
- Involved active paths:
  - `IOS26_DEPENDENCY_GRAPH` — `docs/codex/ios26/IOS26_DEPENDENCY_GRAPH.yml` (partial_implementation; source-only)

### 12. Missing source-of-truth references in existing-code-champion-coverage

- Candidate ID: `AMB28-missing_source_of_truth_reference-17277905`
- Evidence type: `missing_source_of_truth_reference`
- Severity: `yellow`
- Recommended action: `Rewrite`
- Linear-ready: `True`
- Auto-resolved: `False`
- Reason: Active item lacks required source-of-truth references; rewrite before implementation use.
- Involved active paths:
  - `existing-code-champion-coverage` — `docs/codex/existing-code-champion-coverage.yml` (unknown; release proof)

### 13. Missing source-of-truth references in HARNESS_ARTIFACT_SCHEMA

- Candidate ID: `AMB28-missing_source_of_truth_reference-24269100`
- Evidence type: `missing_source_of_truth_reference`
- Severity: `yellow`
- Recommended action: `Rewrite`
- Linear-ready: `True`
- Auto-resolved: `False`
- Reason: Active item lacks required source-of-truth references; rewrite before implementation use.
- Involved active paths:
  - `HARNESS_ARTIFACT_SCHEMA` — `docs/codex/HARNESS_ARTIFACT_SCHEMA.md` (partial_implementation; audit)

### 14. Missing source-of-truth references in GLOBAL_QUEUE_CANONICAL_ORDER

- Candidate ID: `AMB28-missing_source_of_truth_reference-25247502`
- Evidence type: `missing_source_of_truth_reference`
- Severity: `yellow`
- Recommended action: `Rewrite`
- Linear-ready: `True`
- Auto-resolved: `False`
- Reason: Active item lacks required source-of-truth references; rewrite before implementation use.
- Involved active paths:
  - `GLOBAL_QUEUE_CANONICAL_ORDER` — `docs/codex/GLOBAL_QUEUE_CANONICAL_ORDER.json` (partial_implementation; release proof)

### 15. Missing source-of-truth references in IOS26_BATCH_MATRIX

- Candidate ID: `AMB28-missing_source_of_truth_reference-28229775`
- Evidence type: `missing_source_of_truth_reference`
- Severity: `yellow`
- Recommended action: `Rewrite`
- Linear-ready: `True`
- Auto-resolved: `False`
- Reason: Active item lacks required source-of-truth references; rewrite before implementation use.
- Involved active paths:
  - `IOS26_BATCH_MATRIX` — `docs/codex/ios26/IOS26_BATCH_MATRIX.yml` (partial_implementation; release proof)

### 16. Missing source-of-truth references in SPEED_TRAIN_LANE_POLICY

- Candidate ID: `AMB28-missing_source_of_truth_reference-30454764`
- Evidence type: `missing_source_of_truth_reference`
- Severity: `yellow`
- Recommended action: `Rewrite`
- Linear-ready: `True`
- Auto-resolved: `False`
- Reason: Active item lacks required source-of-truth references; rewrite before implementation use.
- Involved active paths:
  - `SPEED_TRAIN_LANE_POLICY` — `docs/codex/SPEED_TRAIN_LANE_POLICY.json` (unknown; release proof)

### 17. Missing source-of-truth references in IOS26_PROMPT_FREEZE_HASHES

- Candidate ID: `AMB28-missing_source_of_truth_reference-30793201`
- Evidence type: `missing_source_of_truth_reference`
- Severity: `yellow`
- Recommended action: `Rewrite`
- Linear-ready: `True`
- Auto-resolved: `False`
- Reason: Active item lacks required source-of-truth references; rewrite before implementation use.
- Involved active paths:
  - `IOS26_PROMPT_FREEZE_HASHES` — `docs/codex/ios26/IOS26_PROMPT_FREEZE_HASHES.json` (partial_implementation; release proof)

### 18. Missing source-of-truth references in CHAMPION_MERGE_AND_INTELLIGENCE_CONSOLIDATION_SUPPORT

- Candidate ID: `AMB28-missing_source_of_truth_reference-37732249`
- Evidence type: `missing_source_of_truth_reference`
- Severity: `yellow`
- Recommended action: `Rewrite`
- Linear-ready: `True`
- Auto-resolved: `False`
- Reason: Active item lacks required source-of-truth references; rewrite before implementation use.
- Involved active paths:
  - `CHAMPION_MERGE_AND_INTELLIGENCE_CONSOLIDATION_SUPPORT` — `prompts/trains/ios26-flagship/support/CHAMPION_MERGE_AND_INTELLIGENCE_CONSOLIDATION_SUPPORT.md` (partial_implementation; release proof)

### 19. Missing source-of-truth references in HARNESS_RUNS

- Candidate ID: `AMB28-missing_source_of_truth_reference-3871956`
- Evidence type: `missing_source_of_truth_reference`
- Severity: `yellow`
- Recommended action: `Rewrite`
- Linear-ready: `True`
- Auto-resolved: `False`
- Reason: Active item lacks required source-of-truth references; rewrite before implementation use.
- Involved active paths:
  - `HARNESS_RUNS` — `docs/codex/HARNESS_RUNS.md` (partial_implementation; source-only)

### 20. Missing source-of-truth references in TRAIN_04L

- Candidate ID: `AMB28-missing_source_of_truth_reference-39132693`
- Evidence type: `missing_source_of_truth_reference`
- Severity: `yellow`
- Recommended action: `Rewrite`
- Linear-ready: `True`
- Auto-resolved: `False`
- Reason: Active item lacks required source-of-truth references; rewrite before implementation use.
- Involved active paths:
  - `TRAIN_04L` — `docs/codex/CHAMPION_MERGE_TRAIN_MANIFEST.yml` (partial_implementation; source-only)

### 21. Missing source-of-truth references in AMB_GLOBAL_REMAINING_TRAIN_BLUEPRINT

- Candidate ID: `AMB28-missing_source_of_truth_reference-40651660`
- Evidence type: `missing_source_of_truth_reference`
- Severity: `yellow`
- Recommended action: `Rewrite`
- Linear-ready: `True`
- Auto-resolved: `False`
- Reason: Active item lacks required source-of-truth references; rewrite before implementation use.
- Involved active paths:
  - `AMB_GLOBAL_REMAINING_TRAIN_BLUEPRINT` — `docs/codex/AMB_GLOBAL_REMAINING_TRAIN_BLUEPRINT.json` (unknown; tests)

### 22. Missing source-of-truth references in concept-lock-registry

- Candidate ID: `AMB28-missing_source_of_truth_reference-5062944`
- Evidence type: `missing_source_of_truth_reference`
- Severity: `yellow`
- Recommended action: `Rewrite`
- Linear-ready: `True`
- Auto-resolved: `False`
- Reason: Active item lacks required source-of-truth references; rewrite before implementation use.
- Involved active paths:
  - `concept-lock-registry` — `docs/codex/concept-lock-registry.yml` (partial_implementation; tests)

### 23. Missing source-of-truth references in parallel-guard-concept-registry

- Candidate ID: `AMB28-missing_source_of_truth_reference-5485442`
- Evidence type: `missing_source_of_truth_reference`
- Severity: `yellow`
- Recommended action: `Rewrite`
- Linear-ready: `True`
- Auto-resolved: `False`
- Reason: Active item lacks required source-of-truth references; rewrite before implementation use.
- Involved active paths:
  - `parallel-guard-concept-registry` — `docs/codex/parallel-guard-concept-registry.yml` (partial_implementation; source-only)

### 24. Missing source-of-truth references in IOS26-FLAGSHIP

- Candidate ID: `AMB28-missing_source_of_truth_reference-61407127`
- Evidence type: `missing_source_of_truth_reference`
- Severity: `yellow`
- Recommended action: `Rewrite`
- Linear-ready: `True`
- Auto-resolved: `False`
- Reason: Active item lacks required source-of-truth references; rewrite before implementation use.
- Involved active paths:
  - `IOS26-FLAGSHIP` — `docs/codex/IOS26_FLAGSHIP_EXECUTION_STATE.yml` (partial_implementation; source-only)

### 25. Missing source-of-truth references in HARNESS_PLAN

- Candidate ID: `AMB28-missing_source_of_truth_reference-63410170`
- Evidence type: `missing_source_of_truth_reference`
- Severity: `yellow`
- Recommended action: `Rewrite`
- Linear-ready: `True`
- Auto-resolved: `False`
- Reason: Active item lacks required source-of-truth references; rewrite before implementation use.
- Involved active paths:
  - `HARNESS_PLAN` — `docs/codex/HARNESS_PLAN.md` (unknown; audit)

### 26. Missing source-of-truth references in HISTORICAL_BASELINE_GLOBAL_TRAIN_MANIFEST

- Candidate ID: `AMB28-missing_source_of_truth_reference-66129978`
- Evidence type: `missing_source_of_truth_reference`
- Severity: `yellow`
- Recommended action: `Rewrite`
- Linear-ready: `True`
- Auto-resolved: `False`
- Reason: Active item lacks required source-of-truth references; rewrite before implementation use.
- Involved active paths:
  - `HISTORICAL_BASELINE_GLOBAL_TRAIN_MANIFEST` — `docs/codex/HISTORICAL_BASELINE_GLOBAL_TRAIN_MANIFEST.json` (unknown; release proof)

### 27. Missing source-of-truth references in HARNESS_LINEAR

- Candidate ID: `AMB28-missing_source_of_truth_reference-72258897`
- Evidence type: `missing_source_of_truth_reference`
- Severity: `yellow`
- Recommended action: `Rewrite`
- Linear-ready: `True`
- Auto-resolved: `False`
- Reason: Active item lacks required source-of-truth references; rewrite before implementation use.
- Involved active paths:
  - `HARNESS_LINEAR` — `docs/codex/HARNESS_LINEAR.md` (partial_implementation; source-only)

### 28. Missing source-of-truth references in ldi06-pack-registry-fixture

- Candidate ID: `AMB28-missing_source_of_truth_reference-75733691`
- Evidence type: `missing_source_of_truth_reference`
- Severity: `yellow`
- Recommended action: `Rewrite`
- Linear-ready: `True`
- Auto-resolved: `False`
- Reason: Active item lacks required source-of-truth references; rewrite before implementation use.
- Involved active paths:
  - `ldi06-pack-registry-fixture` — `docs/codex/fixtures/ldi/ldi06-pack-registry-fixture.json` (partial_implementation; source-only)

### 29. Missing source-of-truth references in TRAIN_04L_OBJECT_FRONTEND_LIVING_CHROME_FOUNDATION

- Candidate ID: `AMB28-missing_source_of_truth_reference-93534137`
- Evidence type: `missing_source_of_truth_reference`
- Severity: `yellow`
- Recommended action: `Rewrite`
- Linear-ready: `True`
- Auto-resolved: `False`
- Reason: Active item lacks required source-of-truth references; rewrite before implementation use.
- Involved active paths:
  - `TRAIN_04L_OBJECT_FRONTEND_LIVING_CHROME_FOUNDATION` — `prompts/trains/ios26-flagship/TRAIN_04L_OBJECT_FRONTEND_LIVING_CHROME_FOUNDATION.md` (partial_implementation; release proof)

### 30. Missing source-of-truth references in MOAT_RUNTIME_BATCH_OVERLAY

- Candidate ID: `AMB28-missing_source_of_truth_reference-95371168`
- Evidence type: `missing_source_of_truth_reference`
- Severity: `yellow`
- Recommended action: `Rewrite`
- Linear-ready: `True`
- Auto-resolved: `False`
- Reason: Active item lacks required source-of-truth references; rewrite before implementation use.
- Involved active paths:
  - `MOAT_RUNTIME_BATCH_OVERLAY` — `docs/codex/MOAT_RUNTIME_BATCH_OVERLAY.json` (partial_implementation; release proof)

### 31. Source-only or missing-proof implementation state: TRAIN_11_PERSISTENCE_MIGRATION_EXPORT_DELETE_APP_GROUP

- Candidate ID: `AMB28-source_only_implementation_missing_proof-18187313`
- Evidence type: `source_only_implementation_missing_proof`
- Severity: `yellow`
- Recommended action: `Finish proof`
- Linear-ready: `True`
- Auto-resolved: `False`
- Reason: Active item is partial/source-only/missing-proof; finish proof before treating as complete.
- Involved active paths:
  - `TRAIN_11_PERSISTENCE_MIGRATION_EXPORT_DELETE_APP_GROUP` — `prompts/trains/ios26-flagship/TRAIN_11_PERSISTENCE_MIGRATION_EXPORT_DELETE_APP_GROUP.md` (partial_implementation; source-only)

### 32. Source-only or missing-proof implementation state: TRAIN_13_ACCESSIBILITY_EQUIVALENCE

- Candidate ID: `AMB28-source_only_implementation_missing_proof-18602262`
- Evidence type: `source_only_implementation_missing_proof`
- Severity: `yellow`
- Recommended action: `Finish proof`
- Linear-ready: `True`
- Auto-resolved: `False`
- Reason: Active item is partial/source-only/missing-proof; finish proof before treating as complete.
- Involved active paths:
  - `TRAIN_13_ACCESSIBILITY_EQUIVALENCE` — `prompts/trains/ios26-flagship/TRAIN_13_ACCESSIBILITY_EQUIVALENCE.md` (partial_implementation; source-only)

### 33. Source-only or missing-proof implementation state: TRAIN_04L

- Candidate ID: `AMB28-source_only_implementation_missing_proof-329720`
- Evidence type: `source_only_implementation_missing_proof`
- Severity: `yellow`
- Recommended action: `Finish proof`
- Linear-ready: `True`
- Auto-resolved: `False`
- Reason: Active item is partial/source-only/missing-proof; finish proof before treating as complete.
- Involved active paths:
  - `TRAIN_04L` — `docs/codex/CHAMPION_MERGE_TRAIN_MANIFEST.yml` (partial_implementation; source-only)

### 34. Source-only or missing-proof implementation state: TRAIN_14_PERFORMANCE_INSTRUMENTS_POWER

- Candidate ID: `AMB28-source_only_implementation_missing_proof-33075517`
- Evidence type: `source_only_implementation_missing_proof`
- Severity: `yellow`
- Recommended action: `Finish proof`
- Linear-ready: `True`
- Auto-resolved: `False`
- Reason: Active item is partial/source-only/missing-proof; finish proof before treating as complete.
- Involved active paths:
  - `TRAIN_14_PERFORMANCE_INSTRUMENTS_POWER` — `prompts/trains/ios26-flagship/TRAIN_14_PERFORMANCE_INSTRUMENTS_POWER.md` (partial_implementation; source-only)

### 35. Source-only or missing-proof implementation state: TRAIN_01_IOS26_MINIMUM_MIGRATION_FOUNDATION

- Candidate ID: `AMB28-source_only_implementation_missing_proof-38774666`
- Evidence type: `source_only_implementation_missing_proof`
- Severity: `yellow`
- Recommended action: `Finish proof`
- Linear-ready: `True`
- Auto-resolved: `False`
- Reason: Active item is partial/source-only/missing-proof; finish proof before treating as complete.
- Involved active paths:
  - `TRAIN_01_IOS26_MINIMUM_MIGRATION_FOUNDATION` — `prompts/trains/ios26-flagship/TRAIN_01_IOS26_MINIMUM_MIGRATION_FOUNDATION.md` (partial_implementation; source-only)

### 36. Source-only or missing-proof implementation state: IOS26-FLAGSHIP

- Candidate ID: `AMB28-source_only_implementation_missing_proof-41744582`
- Evidence type: `source_only_implementation_missing_proof`
- Severity: `yellow`
- Recommended action: `Finish proof`
- Linear-ready: `True`
- Auto-resolved: `False`
- Reason: Active item is partial/source-only/missing-proof; finish proof before treating as complete.
- Involved active paths:
  - `IOS26-FLAGSHIP` — `docs/codex/IOS26_FLAGSHIP_EXECUTION_STATE.yml` (partial_implementation; source-only)

### 37. Source-only or missing-proof implementation state: parallel-guard-concept-registry

- Candidate ID: `AMB28-source_only_implementation_missing_proof-44250454`
- Evidence type: `source_only_implementation_missing_proof`
- Severity: `yellow`
- Recommended action: `Finish proof`
- Linear-ready: `True`
- Auto-resolved: `False`
- Reason: Active item is partial/source-only/missing-proof; finish proof before treating as complete.
- Involved active paths:
  - `parallel-guard-concept-registry` — `docs/codex/parallel-guard-concept-registry.yml` (partial_implementation; source-only)

### 38. Source-only or missing-proof implementation state: TRAIN_08_CAPTURE_ATMOSPHERE_COMPOSER_FINAL_OBJECT

- Candidate ID: `AMB28-source_only_implementation_missing_proof-44864164`
- Evidence type: `source_only_implementation_missing_proof`
- Severity: `yellow`
- Recommended action: `Finish proof`
- Linear-ready: `True`
- Auto-resolved: `False`
- Reason: Active item is partial/source-only/missing-proof; finish proof before treating as complete.
- Involved active paths:
  - `TRAIN_08_CAPTURE_ATMOSPHERE_COMPOSER_FINAL_OBJECT` — `prompts/trains/ios26-flagship/TRAIN_08_CAPTURE_ATMOSPHERE_COMPOSER_FINAL_OBJECT.md` (partial_implementation; source-only)

### 39. Source-only or missing-proof implementation state: HARNESS_LINEAR

- Candidate ID: `AMB28-source_only_implementation_missing_proof-46583565`
- Evidence type: `source_only_implementation_missing_proof`
- Severity: `yellow`
- Recommended action: `Finish proof`
- Linear-ready: `True`
- Auto-resolved: `False`
- Reason: Active item is partial/source-only/missing-proof; finish proof before treating as complete.
- Involved active paths:
  - `HARNESS_LINEAR` — `docs/codex/HARNESS_LINEAR.md` (partial_implementation; source-only)

### 40. Source-only or missing-proof implementation state: TRAIN_07_GOALS_CONSTELLATION_ATLAS_FINAL_OBJECT

- Candidate ID: `AMB28-source_only_implementation_missing_proof-49562131`
- Evidence type: `source_only_implementation_missing_proof`
- Severity: `yellow`
- Recommended action: `Finish proof`
- Linear-ready: `True`
- Auto-resolved: `False`
- Reason: Active item is partial/source-only/missing-proof; finish proof before treating as complete.
- Involved active paths:
  - `TRAIN_07_GOALS_CONSTELLATION_ATLAS_FINAL_OBJECT` — `prompts/trains/ios26-flagship/TRAIN_07_GOALS_CONSTELLATION_ATLAS_FINAL_OBJECT.md` (partial_implementation; source-only)

### 41. Source-only or missing-proof implementation state: IOS26_DEPENDENCY_GRAPH

- Candidate ID: `AMB28-source_only_implementation_missing_proof-55235798`
- Evidence type: `source_only_implementation_missing_proof`
- Severity: `yellow`
- Recommended action: `Finish proof`
- Linear-ready: `True`
- Auto-resolved: `False`
- Reason: Active item is partial/source-only/missing-proof; finish proof before treating as complete.
- Involved active paths:
  - `IOS26_DEPENDENCY_GRAPH` — `docs/codex/ios26/IOS26_DEPENDENCY_GRAPH.yml` (partial_implementation; source-only)

### 42. Source-only or missing-proof implementation state: TRAIN_09_YOU_USER_SYSTEM_PROFILE

- Candidate ID: `AMB28-source_only_implementation_missing_proof-61842138`
- Evidence type: `source_only_implementation_missing_proof`
- Severity: `yellow`
- Recommended action: `Finish proof`
- Linear-ready: `True`
- Auto-resolved: `False`
- Reason: Active item is partial/source-only/missing-proof; finish proof before treating as complete.
- Involved active paths:
  - `TRAIN_09_YOU_USER_SYSTEM_PROFILE` — `prompts/trains/ios26-flagship/TRAIN_09_YOU_USER_SYSTEM_PROFILE.md` (partial_implementation; source-only)

### 43. Source-only or missing-proof implementation state: TRAIN_15_REPO_HYGIENE_NAMING_DRIFT_HISTORICAL_QUARANTINE

- Candidate ID: `AMB28-source_only_implementation_missing_proof-64666452`
- Evidence type: `source_only_implementation_missing_proof`
- Severity: `yellow`
- Recommended action: `Finish proof`
- Linear-ready: `True`
- Auto-resolved: `False`
- Reason: Active item is partial/source-only/missing-proof; finish proof before treating as complete.
- Involved active paths:
  - `TRAIN_15_REPO_HYGIENE_NAMING_DRIFT_HISTORICAL_QUARANTINE` — `prompts/trains/ios26-flagship/TRAIN_15_REPO_HYGIENE_NAMING_DRIFT_HISTORICAL_QUARANTINE.md` (partial_implementation; source-only)

### 44. Source-only or missing-proof implementation state: TRAIN_05_TODAY_REALITY_MERIDIAN_FINAL_OBJECT

- Candidate ID: `AMB28-source_only_implementation_missing_proof-6516509`
- Evidence type: `source_only_implementation_missing_proof`
- Severity: `yellow`
- Recommended action: `Finish proof`
- Linear-ready: `True`
- Auto-resolved: `False`
- Reason: Active item is partial/source-only/missing-proof; finish proof before treating as complete.
- Involved active paths:
  - `TRAIN_05_TODAY_REALITY_MERIDIAN_FINAL_OBJECT` — `prompts/trains/ios26-flagship/TRAIN_05_TODAY_REALITY_MERIDIAN_FINAL_OBJECT.md` (partial_implementation; source-only)

### 45. Source-only or missing-proof implementation state: TRAIN_04_GOAL_INTENT_TO_DAY_COMPILER

- Candidate ID: `AMB28-source_only_implementation_missing_proof-69617344`
- Evidence type: `source_only_implementation_missing_proof`
- Severity: `yellow`
- Recommended action: `Finish proof`
- Linear-ready: `True`
- Auto-resolved: `False`
- Reason: Active item is partial/source-only/missing-proof; finish proof before treating as complete.
- Involved active paths:
  - `TRAIN_04_GOAL_INTENT_TO_DAY_COMPILER` — `prompts/trains/ios26-flagship/TRAIN_04_GOAL_INTENT_TO_DAY_COMPILER.md` (partial_implementation; source-only)

### 46. Source-only or missing-proof implementation state: TRAIN_06_TIME_LIFESHAPE_FIELD_FINAL_OBJECT

- Candidate ID: `AMB28-source_only_implementation_missing_proof-78349230`
- Evidence type: `source_only_implementation_missing_proof`
- Severity: `yellow`
- Recommended action: `Finish proof`
- Linear-ready: `True`
- Auto-resolved: `False`
- Reason: Active item is partial/source-only/missing-proof; finish proof before treating as complete.
- Involved active paths:
  - `TRAIN_06_TIME_LIFESHAPE_FIELD_FINAL_OBJECT` — `prompts/trains/ios26-flagship/TRAIN_06_TIME_LIFESHAPE_FIELD_FINAL_OBJECT.md` (partial_implementation; source-only)

### 47. Source-only or missing-proof implementation state: TRAIN_10_PROOF_RECEIPTS_CLOSURE_RECOVERY_REPLAY

- Candidate ID: `AMB28-source_only_implementation_missing_proof-82962295`
- Evidence type: `source_only_implementation_missing_proof`
- Severity: `yellow`
- Recommended action: `Finish proof`
- Linear-ready: `True`
- Auto-resolved: `False`
- Reason: Active item is partial/source-only/missing-proof; finish proof before treating as complete.
- Involved active paths:
  - `TRAIN_10_PROOF_RECEIPTS_CLOSURE_RECOVERY_REPLAY` — `prompts/trains/ios26-flagship/TRAIN_10_PROOF_RECEIPTS_CLOSURE_RECOVERY_REPLAY.md` (partial_implementation; source-only)

### 48. Source-only or missing-proof implementation state: TRAIN_12_EXTERNAL_SURFACES_WIDGETS_INTENTS_SHARE

- Candidate ID: `AMB28-source_only_implementation_missing_proof-92298325`
- Evidence type: `source_only_implementation_missing_proof`
- Severity: `yellow`
- Recommended action: `Finish proof`
- Linear-ready: `True`
- Auto-resolved: `False`
- Reason: Active item is partial/source-only/missing-proof; finish proof before treating as complete.
- Involved active paths:
  - `TRAIN_12_EXTERNAL_SURFACES_WIDGETS_INTENTS_SHARE` — `prompts/trains/ios26-flagship/TRAIN_12_EXTERNAL_SURFACES_WIDGETS_INTENTS_SHARE.md` (partial_implementation; source-only)

### 49. Source-only or missing-proof implementation state: TRAIN_03_PRIVATE_LIFE_RUNTIME_PROOF_HARNESS

- Candidate ID: `AMB28-source_only_implementation_missing_proof-92792165`
- Evidence type: `source_only_implementation_missing_proof`
- Severity: `yellow`
- Recommended action: `Finish proof`
- Linear-ready: `True`
- Auto-resolved: `False`
- Reason: Active item is partial/source-only/missing-proof; finish proof before treating as complete.
- Involved active paths:
  - `TRAIN_03_PRIVATE_LIFE_RUNTIME_PROOF_HARNESS` — `prompts/trains/ios26-flagship/TRAIN_03_PRIVATE_LIFE_RUNTIME_PROOF_HARNESS.md` (partial_implementation; source-only)

### 50. Source-only or missing-proof implementation state: ldi06-pack-registry-fixture

- Candidate ID: `AMB28-source_only_implementation_missing_proof-95286941`
- Evidence type: `source_only_implementation_missing_proof`
- Severity: `yellow`
- Recommended action: `Finish proof`
- Linear-ready: `True`
- Auto-resolved: `False`
- Reason: Active item is partial/source-only/missing-proof; finish proof before treating as complete.
- Involved active paths:
  - `ldi06-pack-registry-fixture` — `docs/codex/fixtures/ldi/ldi06-pack-registry-fixture.json` (partial_implementation; source-only)

### 51. Source-only or missing-proof implementation state: HARNESS_RUNS

- Candidate ID: `AMB28-source_only_implementation_missing_proof-99183681`
- Evidence type: `source_only_implementation_missing_proof`
- Severity: `yellow`
- Recommended action: `Finish proof`
- Linear-ready: `True`
- Auto-resolved: `False`
- Reason: Active item is partial/source-only/missing-proof; finish proof before treating as complete.
- Involved active paths:
  - `HARNESS_RUNS` — `docs/codex/HARNESS_RUNS.md` (partial_implementation; source-only)

### 52. Duplicate stable ID: PK24

- Candidate ID: `AMB28-duplicate_stable_id-10341794`
- Evidence type: `duplicate_stable_id`
- Severity: `yellow`
- Recommended action: `Merge`
- Linear-ready: `True`
- Auto-resolved: `False`
- Reason: Duplicate stable ID appears in active work; merge, namespace, or retire duplicate authority.
- Involved active paths:
  - `PK24` — `docs/codex/batch-prep/PK24.md` (partial_implementation; release proof)
  - `PK24` — `prompts/batches/PK24.md` (partial_implementation; release proof)

### 53. Duplicate stable ID: PK22

- Candidate ID: `AMB28-duplicate_stable_id-20505307`
- Evidence type: `duplicate_stable_id`
- Severity: `yellow`
- Recommended action: `Merge`
- Linear-ready: `True`
- Auto-resolved: `False`
- Reason: Duplicate stable ID appears in active work; merge, namespace, or retire duplicate authority.
- Involved active paths:
  - `PK22` — `docs/codex/batch-prep/PK22.md` (partial_implementation; release proof)
  - `PK22` — `prompts/batches/PK22.md` (partial_implementation; release proof)

### 54. Duplicate stable ID: AMB-REPO-GREEN-FLAGSHIP-RESET-MASTER-01-T05-SOURCE-REFRACTOR-MAP

- Candidate ID: `AMB28-duplicate_stable_id-23954191`
- Evidence type: `duplicate_stable_id`
- Severity: `yellow`
- Recommended action: `Merge`
- Linear-ready: `True`
- Auto-resolved: `False`
- Reason: Duplicate stable ID appears in active work; merge, namespace, or retire duplicate authority.
- Involved active paths:
  - `AMB-REPO-GREEN-FLAGSHIP-RESET-MASTER-01-T05-SOURCE-REFRACTOR-MAP` — `prompts/batches/AMB-REPO-GREEN-FLAGSHIP-RESET-MASTER-01-T05-SOURCE-REFRACTOR-MAP.md` (partial_implementation; release proof)

### 55. Duplicate stable ID: AMB-FILE-BY-FILE-REPO-AUDIT-01

- Candidate ID: `AMB28-duplicate_stable_id-25996756`
- Evidence type: `duplicate_stable_id`
- Severity: `yellow`
- Recommended action: `Merge`
- Linear-ready: `True`
- Auto-resolved: `False`
- Reason: Duplicate stable ID appears in active work; merge, namespace, or retire duplicate authority.
- Involved active paths:
  - `AMB-FILE-BY-FILE-REPO-AUDIT-01` — `prompts/batches/AMB-FILE-BY-FILE-REPO-AUDIT-01.md` (partial_implementation; release proof)

### 56. Duplicate stable ID: AMB_GLOBAL_REMAINING_TRAIN_BLUEPRINT

- Candidate ID: `AMB28-duplicate_stable_id-29848640`
- Evidence type: `duplicate_stable_id`
- Severity: `yellow`
- Recommended action: `Merge`
- Linear-ready: `True`
- Auto-resolved: `False`
- Reason: Duplicate stable ID appears in active work; merge, namespace, or retire duplicate authority.
- Involved active paths:
  - `AMB_GLOBAL_REMAINING_TRAIN_BLUEPRINT` — `docs/codex/AMB_GLOBAL_REMAINING_TRAIN_BLUEPRINT.md` (unknown; release proof)
  - `AMB_GLOBAL_REMAINING_TRAIN_BLUEPRINT` — `docs/codex/AMB_GLOBAL_REMAINING_TRAIN_BLUEPRINT.json` (unknown; tests)

### 57. Duplicate stable ID: PK16

- Candidate ID: `AMB28-duplicate_stable_id-43943736`
- Evidence type: `duplicate_stable_id`
- Severity: `yellow`
- Recommended action: `Merge`
- Linear-ready: `True`
- Auto-resolved: `False`
- Reason: Duplicate stable ID appears in active work; merge, namespace, or retire duplicate authority.
- Involved active paths:
  - `PK16` — `docs/codex/batch-prep/PK16.md` (partial_implementation; release proof)

### 58. Duplicate stable ID: PK20

- Candidate ID: `AMB28-duplicate_stable_id-48574625`
- Evidence type: `duplicate_stable_id`
- Severity: `yellow`
- Recommended action: `Merge`
- Linear-ready: `True`
- Auto-resolved: `False`
- Reason: Duplicate stable ID appears in active work; merge, namespace, or retire duplicate authority.
- Involved active paths:
  - `PK20` — `docs/codex/batch-prep/PK20.md` (partial_implementation; release proof)
  - `PK20` — `prompts/batches/PK20.md` (partial_implementation; release proof)

### 59. Duplicate stable ID: AMB-CODEX-OS-FLAGSHIP-UPGRADE-INSTALL-01

- Candidate ID: `AMB28-duplicate_stable_id-53214177`
- Evidence type: `duplicate_stable_id`
- Severity: `yellow`
- Recommended action: `Merge`
- Linear-ready: `True`
- Auto-resolved: `False`
- Reason: Duplicate stable ID appears in active work; merge, namespace, or retire duplicate authority.
- Involved active paths:
  - `AMB-CODEX-OS-FLAGSHIP-UPGRADE-INSTALL-01` — `docs/codex/reports/AMB-CODEX-OS-FLAGSHIP-UPGRADE-INSTALL-01.md` (partial_implementation; release proof)

### 60. Duplicate stable ID: AMB-REPO-GREEN-FLAGSHIP-RESET-MASTER-01-T03-VOCAB-LEDGER

- Candidate ID: `AMB28-duplicate_stable_id-57424148`
- Evidence type: `duplicate_stable_id`
- Severity: `yellow`
- Recommended action: `Merge`
- Linear-ready: `True`
- Auto-resolved: `False`
- Reason: Duplicate stable ID appears in active work; merge, namespace, or retire duplicate authority.
- Involved active paths:
  - `AMB-REPO-GREEN-FLAGSHIP-RESET-MASTER-01-T03-VOCAB-LEDGER` — `prompts/batches/AMB-REPO-GREEN-FLAGSHIP-RESET-MASTER-01-T03-VOCAB-LEDGER.md` (partial_implementation; release proof)

### 61. Duplicate stable ID: PK25

- Candidate ID: `AMB28-duplicate_stable_id-61458636`
- Evidence type: `duplicate_stable_id`
- Severity: `yellow`
- Recommended action: `Merge`
- Linear-ready: `True`
- Auto-resolved: `False`
- Reason: Duplicate stable ID appears in active work; merge, namespace, or retire duplicate authority.
- Involved active paths:
  - `PK25` — `docs/codex/batch-prep/PK25.md` (partial_implementation; release proof)
  - `PK25` — `prompts/batches/PK25.md` (partial_implementation; release proof)

### 62. Duplicate stable ID: AMB-POST23-01-TRUTH-AUDIT

- Candidate ID: `AMB28-duplicate_stable_id-63511949`
- Evidence type: `duplicate_stable_id`
- Severity: `yellow`
- Recommended action: `Merge`
- Linear-ready: `True`
- Auto-resolved: `False`
- Reason: Duplicate stable ID appears in active work; merge, namespace, or retire duplicate authority.
- Involved active paths:
  - `AMB-POST23-01-TRUTH-AUDIT` — `prompts/batches/post-23-truth-audit/AMB-POST23-01-TRUTH-AUDIT.md` (partial_implementation; release proof)
  - `AMB-POST23-01-TRUTH-AUDIT` — `docs/codex/reports/AMB-POST23-01-TRUTH-AUDIT.md` (partial_implementation; release proof)

### 63. Duplicate stable ID: AMB-REPO-GREEN-FLAGSHIP-RESET-MASTER-01

- Candidate ID: `AMB28-duplicate_stable_id-64821029`
- Evidence type: `duplicate_stable_id`
- Severity: `yellow`
- Recommended action: `Merge`
- Linear-ready: `True`
- Auto-resolved: `False`
- Reason: Duplicate stable ID appears in active work; merge, namespace, or retire duplicate authority.
- Involved active paths:
  - `AMB-REPO-GREEN-FLAGSHIP-RESET-MASTER-01` — `prompts/batches/AMB-REPO-GREEN-FLAGSHIP-RESET-MASTER-01.md` (partial_implementation; release proof)

### 64. Duplicate stable ID: AMB_REMAINING_BATCH_REFERENCE

- Candidate ID: `AMB28-duplicate_stable_id-65767025`
- Evidence type: `duplicate_stable_id`
- Severity: `yellow`
- Recommended action: `Merge`
- Linear-ready: `True`
- Auto-resolved: `False`
- Reason: Duplicate stable ID appears in active work; merge, namespace, or retire duplicate authority.
- Involved active paths:
  - `AMB_REMAINING_BATCH_REFERENCE` — `docs/codex/AMB_REMAINING_BATCH_REFERENCE.json` (partial_implementation; release proof)
  - `AMB_REMAINING_BATCH_REFERENCE` — `docs/codex/AMB_REMAINING_BATCH_REFERENCE.md` (partial_implementation; release proof)

### 65. Duplicate stable ID: AMB-POST23-02-UNDERDELIVERY-REPAIR

- Candidate ID: `AMB28-duplicate_stable_id-66290067`
- Evidence type: `duplicate_stable_id`
- Severity: `yellow`
- Recommended action: `Merge`
- Linear-ready: `True`
- Auto-resolved: `False`
- Reason: Duplicate stable ID appears in active work; merge, namespace, or retire duplicate authority.
- Involved active paths:
  - `AMB-POST23-02-UNDERDELIVERY-REPAIR` — `prompts/batches/post-23-truth-audit/AMB-POST23-02-UNDERDELIVERY-REPAIR.md` (partial_implementation; release proof)

### 66. Duplicate stable ID: BL-00

- Candidate ID: `AMB28-duplicate_stable_id-68177081`
- Evidence type: `duplicate_stable_id`
- Severity: `yellow`
- Recommended action: `Merge`
- Linear-ready: `True`
- Auto-resolved: `False`
- Reason: Duplicate stable ID appears in active work; merge, namespace, or retire duplicate authority.
- Involved active paths:
  - `BL-00` — `docs/codex/IOS26_FLAGSHIP_BACKLOG_MAP.md` (partial_implementation; release proof)
  - `BL-00` — `docs/codex/backlog/ios26-flagship-maturation-backlog.md` (partial_implementation; release proof)

### 67. Duplicate stable ID: README

- Candidate ID: `AMB28-duplicate_stable_id-68717022`
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

### 68. Duplicate stable ID: POST99-UI-SUITE-REVIEW-IMPLEMENTATION-00

- Candidate ID: `AMB28-duplicate_stable_id-69045932`
- Evidence type: `duplicate_stable_id`
- Severity: `yellow`
- Recommended action: `Merge`
- Linear-ready: `True`
- Auto-resolved: `False`
- Reason: Duplicate stable ID appears in active work; merge, namespace, or retire duplicate authority.
- Involved active paths:
  - `POST99-UI-SUITE-REVIEW-IMPLEMENTATION-00` — `docs/codex/reports/POST99-UI-SUITE-REVIEW-IMPLEMENTATION-00.md` (partial_implementation; release proof)

### 69. Duplicate stable ID: PK18

- Candidate ID: `AMB28-duplicate_stable_id-70531698`
- Evidence type: `duplicate_stable_id`
- Severity: `yellow`
- Recommended action: `Merge`
- Linear-ready: `True`
- Auto-resolved: `False`
- Reason: Duplicate stable ID appears in active work; merge, namespace, or retire duplicate authority.
- Involved active paths:
  - `PK18` — `docs/codex/batch-prep/PK18.md` (partial_implementation; release proof)
  - `PK18` — `prompts/batches/PK18.md` (partial_implementation; release proof)

### 70. Duplicate stable ID: PK17

- Candidate ID: `AMB28-duplicate_stable_id-73413133`
- Evidence type: `duplicate_stable_id`
- Severity: `yellow`
- Recommended action: `Merge`
- Linear-ready: `True`
- Auto-resolved: `False`
- Reason: Duplicate stable ID appears in active work; merge, namespace, or retire duplicate authority.
- Involved active paths:
  - `PK17` — `docs/codex/batch-prep/PK17.md` (partial_implementation; release proof)
  - `PK17` — `prompts/batches/PK17.md` (partial_implementation; release proof)

### 71. Duplicate stable ID: IOS26-FLAGSHIP

- Candidate ID: `AMB28-duplicate_stable_id-74638918`
- Evidence type: `duplicate_stable_id`
- Severity: `yellow`
- Recommended action: `Merge`
- Linear-ready: `True`
- Auto-resolved: `False`
- Reason: Duplicate stable ID appears in active work; merge, namespace, or retire duplicate authority.
- Involved active paths:
  - `IOS26-FLAGSHIP` — `docs/codex/IOS26_FLAGSHIP_TRAIN_MANIFEST.yml` (partial_implementation; release proof)
  - `IOS26-FLAGSHIP` — `docs/codex/IOS26_FLAGSHIP_EXECUTION_STATE.yml` (partial_implementation; source-only)

### 72. Duplicate stable ID: FE-12-CHROME-CONTRACTS-HARDENING

- Candidate ID: `AMB28-duplicate_stable_id-74829296`
- Evidence type: `duplicate_stable_id`
- Severity: `yellow`
- Recommended action: `Merge`
- Linear-ready: `True`
- Auto-resolved: `False`
- Reason: Duplicate stable ID appears in active work; merge, namespace, or retire duplicate authority.
- Involved active paths:
  - `FE-12-CHROME-CONTRACTS-HARDENING` — `prompts/batches/amb-fe-be/FE-12-CHROME-CONTRACTS-HARDENING.md` (partial_implementation; release proof)
  - `FE-12-CHROME-CONTRACTS-HARDENING` — `docs/codex/reports/FE-12-CHROME-CONTRACTS-HARDENING.md` (partial_implementation; release proof)

### 73. Duplicate stable ID: existing-code-champion-coverage

- Candidate ID: `AMB28-duplicate_stable_id-75198276`
- Evidence type: `duplicate_stable_id`
- Severity: `yellow`
- Recommended action: `Merge`
- Linear-ready: `True`
- Auto-resolved: `False`
- Reason: Duplicate stable ID appears in active work; merge, namespace, or retire duplicate authority.
- Involved active paths:
  - `existing-code-champion-coverage` — `docs/codex/existing-code-champion-coverage.yml` (unknown; release proof)

### 74. Duplicate stable ID: AMB-POST23-04-NEXT-TRAIN-RECOMMENDATION

- Candidate ID: `AMB28-duplicate_stable_id-77788699`
- Evidence type: `duplicate_stable_id`
- Severity: `yellow`
- Recommended action: `Merge`
- Linear-ready: `True`
- Auto-resolved: `False`
- Reason: Duplicate stable ID appears in active work; merge, namespace, or retire duplicate authority.
- Involved active paths:
  - `AMB-POST23-04-NEXT-TRAIN-RECOMMENDATION` — `prompts/batches/post-23-truth-audit/AMB-POST23-04-NEXT-TRAIN-RECOMMENDATION.md` (partial_implementation; release proof)
  - `AMB-POST23-04-NEXT-TRAIN-RECOMMENDATION` — `docs/codex/reports/AMB-POST23-04-NEXT-TRAIN-RECOMMENDATION.md` (partial_implementation; release proof)

### 75. Duplicate stable ID: PK23

- Candidate ID: `AMB28-duplicate_stable_id-83204803`
- Evidence type: `duplicate_stable_id`
- Severity: `yellow`
- Recommended action: `Merge`
- Linear-ready: `True`
- Auto-resolved: `False`
- Reason: Duplicate stable ID appears in active work; merge, namespace, or retire duplicate authority.
- Involved active paths:
  - `PK23` — `docs/codex/batch-prep/PK23.md` (partial_implementation; release proof)
  - `PK23` — `prompts/batches/PK23.md` (partial_implementation; release proof)

### 76. Duplicate stable ID: AMB-REPO-GREEN-FLAGSHIP-RESET-MASTER-01-T17-FINAL-IA-SCAN

- Candidate ID: `AMB28-duplicate_stable_id-85964898`
- Evidence type: `duplicate_stable_id`
- Severity: `yellow`
- Recommended action: `Merge`
- Linear-ready: `True`
- Auto-resolved: `False`
- Reason: Duplicate stable ID appears in active work; merge, namespace, or retire duplicate authority.
- Involved active paths:
  - `AMB-REPO-GREEN-FLAGSHIP-RESET-MASTER-01-T17-FINAL-IA-SCAN` — `prompts/batches/AMB-REPO-GREEN-FLAGSHIP-RESET-MASTER-01-T17-FINAL-IA-SCAN.md` (partial_implementation; release proof)

### 77. Duplicate stable ID: PK19

- Candidate ID: `AMB28-duplicate_stable_id-86971351`
- Evidence type: `duplicate_stable_id`
- Severity: `yellow`
- Recommended action: `Merge`
- Linear-ready: `True`
- Auto-resolved: `False`
- Reason: Duplicate stable ID appears in active work; merge, namespace, or retire duplicate authority.
- Involved active paths:
  - `PK19` — `docs/codex/batch-prep/PK19.md` (partial_implementation; release proof)
  - `PK19` — `prompts/batches/PK19.md` (partial_implementation; release proof)

### 78. Duplicate stable ID: PK21

- Candidate ID: `AMB28-duplicate_stable_id-91492237`
- Evidence type: `duplicate_stable_id`
- Severity: `yellow`
- Recommended action: `Merge`
- Linear-ready: `True`
- Auto-resolved: `False`
- Reason: Duplicate stable ID appears in active work; merge, namespace, or retire duplicate authority.
- Involved active paths:
  - `PK21` — `docs/codex/batch-prep/PK21.md` (partial_implementation; release proof)
  - `PK21` — `prompts/batches/PK21.md` (partial_implementation; release proof)

### 79. Duplicate stable ID: AMB-FE-BE-PREFLIGHT-00

- Candidate ID: `AMB28-duplicate_stable_id-96631487`
- Evidence type: `duplicate_stable_id`
- Severity: `yellow`
- Recommended action: `Merge`
- Linear-ready: `True`
- Auto-resolved: `False`
- Reason: Duplicate stable ID appears in active work; merge, namespace, or retire duplicate authority.
- Involved active paths:
  - `AMB-FE-BE-PREFLIGHT-00` — `prompts/batches/amb-fe-be/AMB-FE-BE-PREFLIGHT-00.md` (partial_implementation; release proof)

### 80. Duplicate stable ID: AMB-POST23-03-AUTHORITY-CLEANUP-AND-ROUTING

- Candidate ID: `AMB28-duplicate_stable_id-96690304`
- Evidence type: `duplicate_stable_id`
- Severity: `yellow`
- Recommended action: `Merge`
- Linear-ready: `True`
- Auto-resolved: `False`
- Reason: Duplicate stable ID appears in active work; merge, namespace, or retire duplicate authority.
- Involved active paths:
  - `AMB-POST23-03-AUTHORITY-CLEANUP-AND-ROUTING` — `prompts/batches/post-23-truth-audit/AMB-POST23-03-AUTHORITY-CLEANUP-AND-ROUTING.md` (partial_implementation; release proof)
  - `AMB-POST23-03-AUTHORITY-CLEANUP-AND-ROUTING` — `docs/codex/reports/AMB-POST23-03-AUTHORITY-CLEANUP-AND-ROUTING.md` (partial_implementation; release proof)

### 81. Duplicate stable ID: AMB-POST23-00-COMPLETION-SENTINEL

- Candidate ID: `AMB28-duplicate_stable_id-97710953`
- Evidence type: `duplicate_stable_id`
- Severity: `yellow`
- Recommended action: `Merge`
- Linear-ready: `True`
- Auto-resolved: `False`
- Reason: Duplicate stable ID appears in active work; merge, namespace, or retire duplicate authority.
- Involved active paths:
  - `AMB-POST23-00-COMPLETION-SENTINEL` — `prompts/batches/post-23-truth-audit/AMB-POST23-00-COMPLETION-SENTINEL.md` (partial_implementation; release proof)
  - `AMB-POST23-00-COMPLETION-SENTINEL` — `docs/codex/reports/AMB-POST23-00-COMPLETION-SENTINEL.md` (unknown; release proof)

### 82. Duplicate stable ID: AMB-FLAGSHIP-UI-CODEX-STUDIO-INSTALL-01

- Candidate ID: `AMB28-duplicate_stable_id-98792120`
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

### 83. Same source file targeted by multiple active items: Native/Ambitions/Runtime/GoalRealityReceiptClosureService.swift

- Candidate ID: `AMB28-same_source_file_targeted_by_multiple_active_batches-10010327`
- Evidence type: `same_source_file_targeted_by_multiple_active_batches`
- Severity: `yellow`
- Recommended action: `Merge`
- Linear-ready: `True`
- Auto-resolved: `False`
- Reason: Multiple active work items target the same source file; merge or sequence ownership before implementation.
- Involved active paths:
  - `MOAT-GOAL-REALITY-LOCAL-PERSISTENCE-08` — `prompts/batches/MOAT-GOAL-REALITY-LOCAL-PERSISTENCE-08.md` (partial_implementation; release proof)
  - `MOAT-GOAL-REALITY-RECEIPT-CLOSURE-07` — `prompts/batches/MOAT-GOAL-REALITY-RECEIPT-CLOSURE-07.md` (partial_implementation; release proof)

### 84. Same source file targeted by multiple active items: scripts/ambitions-prompt-queue-consistency.py

- Candidate ID: `AMB28-same_source_file_targeted_by_multiple_active_batches-10033083`
- Evidence type: `same_source_file_targeted_by_multiple_active_batches`
- Severity: `yellow`
- Recommended action: `Merge`
- Linear-ready: `True`
- Auto-resolved: `False`
- Reason: Multiple active work items target the same source file; merge or sequence ownership before implementation.
- Involved active paths:
  - `OBS00-OPENAI-BUILD-SUITE-INSTALL` — `prompts/batches/OBS00-OPENAI-BUILD-SUITE-INSTALL.md` (partial_implementation; release proof)
  - `OBS04-PROMPT-REPAIR-BATCH-REPORT-LAYER` — `prompts/batches/OBS04-PROMPT-REPAIR-BATCH-REPORT-LAYER.md` (partial_implementation; release proof)
  - `OBS06-SPEED-TRAIN-INTEGRATION` — `prompts/batches/OBS06-SPEED-TRAIN-INTEGRATION.md` (partial_implementation; release proof)
  - `OPENAI_BUILD_SUITE_ADOPTION_MATRIX` — `docs/codex/OPENAI_BUILD_SUITE_ADOPTION_MATRIX.md` (unknown; release proof)
  - `POST_PK_SPEED_TRAIN_OPERATING_MODEL` — `docs/codex/POST_PK_SPEED_TRAIN_OPERATING_MODEL.md` (unknown; release proof)
  - `PROMPT_REPAIR_LAYER` — `docs/codex/PROMPT_REPAIR_LAYER.md` (unknown; release proof)

### 85. Same source file targeted by multiple active items: Native/AmbitionsTests/Domain/InspectableIntelligenceGoldenScenarioTests.swift

- Candidate ID: `AMB28-same_source_file_targeted_by_multiple_active_batches-1004432`
- Evidence type: `same_source_file_targeted_by_multiple_active_batches`
- Severity: `yellow`
- Recommended action: `Merge`
- Linear-ready: `True`
- Auto-resolved: `False`
- Reason: Multiple active work items target the same source file; merge or sequence ownership before implementation.
- Involved active paths:
  - `MOAT-MOONSHOT-BACKEND-FULL-TRAIN-01` — `prompts/batches/MOAT-MOONSHOT-BACKEND-FULL-TRAIN-01.md` (partial_implementation; release proof)
  - `MOAT-MOONSHOT-PROOF-PATH-01` — `prompts/batches/MOAT-MOONSHOT-PROOF-PATH-01.md` (partial_implementation; release proof)
  - `MOAT-UNIVERSAL-GOAL-REALITY-COMPILER-01` — `prompts/batches/MOAT-UNIVERSAL-GOAL-REALITY-COMPILER-01.md` (partial_implementation; release proof)
  - `MOAT-GOAL-REALITY-SOURCE-PACKS-09` — `prompts/batches/MOAT-GOAL-REALITY-SOURCE-PACKS-09.md` (partial_implementation; release proof)
  - `PRIVATE-LIFE-RUNTIME-GOLDEN-SCENARIO-PROOF-01` — `prompts/batches/PRIVATE-LIFE-RUNTIME-GOLDEN-SCENARIO-PROOF-01.md` (partial_implementation; release proof)

### 86. Same source file targeted by multiple active items: Native/AmbitionsTests/Runtime/AmbitionsRuntimeBoundaryTests.swift

- Candidate ID: `AMB28-same_source_file_targeted_by_multiple_active_batches-1027665`
- Evidence type: `same_source_file_targeted_by_multiple_active_batches`
- Severity: `yellow`
- Recommended action: `Merge`
- Linear-ready: `True`
- Auto-resolved: `False`
- Reason: Multiple active work items target the same source file; merge or sequence ownership before implementation.
- Involved active paths:
  - `BATCH-33-intelligence-runtime-integration` — `docs/codex/batches/BATCH-33-intelligence-runtime-integration.md` (partial_implementation; release proof)
  - `MOAT-GOAL-REALITY-RUNTIME-SERVICE-03` — `prompts/batches/MOAT-GOAL-REALITY-RUNTIME-SERVICE-03.md` (partial_implementation; release proof)

### 87. Same source file targeted by multiple active items: scripts/ambitions-swift6-modernization-scan.py

- Candidate ID: `AMB28-same_source_file_targeted_by_multiple_active_batches-11343904`
- Evidence type: `same_source_file_targeted_by_multiple_active_batches`
- Severity: `yellow`
- Recommended action: `Merge`
- Linear-ready: `True`
- Auto-resolved: `False`
- Reason: Multiple active work items target the same source file; merge or sequence ownership before implementation.
- Involved active paths:
  - `AMB-FE-BE-INTEGRATED-PROOF-99` — `prompts/batches/amb-fe-be/AMB-FE-BE-INTEGRATED-PROOF-99.md` (partial_implementation; release proof)
  - `AMB-FE-BE-PREFLIGHT-00` — `prompts/batches/amb-fe-be/AMB-FE-BE-PREFLIGHT-00.md` (partial_implementation; release proof)
  - `CODEX_QUALITY_SYSTEM_SCRIPT_MAP` — `docs/codex/CODEX_QUALITY_SYSTEM_SCRIPT_MAP.md` (unknown; release proof)

### 88. Same source file targeted by multiple active items: scripts/ambitions-xcode-validate.sh

- Candidate ID: `AMB28-same_source_file_targeted_by_multiple_active_batches-11450640`
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

### 89. Same source file targeted by multiple active items: Native/AmbitionsTests/Runtime/AmbitionsRuntimeGoalIntelligenceServiceTests.swift

- Candidate ID: `AMB28-same_source_file_targeted_by_multiple_active_batches-11469737`
- Evidence type: `same_source_file_targeted_by_multiple_active_batches`
- Severity: `yellow`
- Recommended action: `Merge`
- Linear-ready: `True`
- Auto-resolved: `False`
- Reason: Multiple active work items target the same source file; merge or sequence ownership before implementation.
- Involved active paths:
  - `BATCH-33-intelligence-runtime-integration` — `docs/codex/batches/BATCH-33-intelligence-runtime-integration.md` (partial_implementation; release proof)
  - `MOONSHOT_PROOF_PATH_BACKEND_MASTER_PLAN` — `docs/codex/MOONSHOT_PROOF_PATH_BACKEND_MASTER_PLAN.md` (partial_implementation; release proof)
  - `MOAT-MOONSHOT-BACKEND-FULL-TRAIN-01` — `prompts/batches/MOAT-MOONSHOT-BACKEND-FULL-TRAIN-01.md` (partial_implementation; release proof)
  - `MOAT-MOONSHOT-PROOF-PATH-01` — `prompts/batches/MOAT-MOONSHOT-PROOF-PATH-01.md` (partial_implementation; release proof)
  - `MOAT-UNIVERSAL-GOAL-REALITY-COMPILER-01` — `prompts/batches/MOAT-UNIVERSAL-GOAL-REALITY-COMPILER-01.md` (partial_implementation; release proof)

### 90. Same source file targeted by multiple active items: scripts/ldi-safety-redteam-fixture-check.py

- Candidate ID: `AMB28-same_source_file_targeted_by_multiple_active_batches-11907983`
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

### 91. Same source file targeted by multiple active items: scripts/ambitions-repo-authority-validate.py

- Candidate ID: `AMB28-same_source_file_targeted_by_multiple_active_batches-12595675`
- Evidence type: `same_source_file_targeted_by_multiple_active_batches`
- Severity: `yellow`
- Recommended action: `Merge`
- Linear-ready: `True`
- Auto-resolved: `False`
- Reason: Multiple active work items target the same source file; merge or sequence ownership before implementation.
- Involved active paths:
  - `AMB-REPO-AUTHORITY-07-GATES-FINAL-PROOF` — `prompts/batches/AMB-REPO-AUTHORITY-07-GATES-FINAL-PROOF.md` (partial_implementation; release proof)
  - `README-SOURCE-TRUTH-LINK-AND-CLAIM-REPAIR-01` — `prompts/batches/README-SOURCE-TRUTH-LINK-AND-CLAIM-REPAIR-01.md` (partial_implementation; release proof)
  - `REPO-AUTHORITY-LEGACY-ACTIVE-HEADER-CLEANUP-01` — `prompts/batches/REPO-AUTHORITY-LEGACY-ACTIVE-HEADER-CLEANUP-01.md` (partial_implementation; release proof)

### 92. Same source file targeted by multiple active items: Native/Ambitions/Runtime/AmbitionsRuntimeFactory.swift

- Candidate ID: `AMB28-same_source_file_targeted_by_multiple_active_batches-129032`
- Evidence type: `same_source_file_targeted_by_multiple_active_batches`
- Severity: `yellow`
- Recommended action: `Merge`
- Linear-ready: `True`
- Auto-resolved: `False`
- Reason: Multiple active work items target the same source file; merge or sequence ownership before implementation.
- Involved active paths:
  - `BATCH-33-intelligence-runtime-integration` — `docs/codex/batches/BATCH-33-intelligence-runtime-integration.md` (partial_implementation; release proof)
  - `MOONSHOT_PROOF_PATH_BACKEND_MASTER_PLAN` — `docs/codex/MOONSHOT_PROOF_PATH_BACKEND_MASTER_PLAN.md` (partial_implementation; release proof)
  - `MOAT-MOONSHOT-BACKEND-FULL-TRAIN-01` — `prompts/batches/MOAT-MOONSHOT-BACKEND-FULL-TRAIN-01.md` (partial_implementation; release proof)
  - `MOAT-MOONSHOT-PROOF-PATH-01` — `prompts/batches/MOAT-MOONSHOT-PROOF-PATH-01.md` (partial_implementation; release proof)
  - `MOAT-UNIVERSAL-GOAL-REALITY-COMPILER-01` — `prompts/batches/MOAT-UNIVERSAL-GOAL-REALITY-COMPILER-01.md` (partial_implementation; release proof)
  - `MOAT-GOAL-REALITY-RUNTIME-SERVICE-03` — `prompts/batches/MOAT-GOAL-REALITY-RUNTIME-SERVICE-03.md` (partial_implementation; release proof)

### 93. Same source file targeted by multiple active items: Native/Ambitions/Features/Today/TodayReadModelProjector.swift

- Candidate ID: `AMB28-same_source_file_targeted_by_multiple_active_batches-13559838`
- Evidence type: `same_source_file_targeted_by_multiple_active_batches`
- Severity: `yellow`
- Recommended action: `Merge`
- Linear-ready: `True`
- Auto-resolved: `False`
- Reason: Multiple active work items target the same source file; merge or sequence ownership before implementation.
- Involved active paths:
  - `BACKEND-FINAL-FORM-LOCAL-FIRST-HUMAN-01` — `prompts/batches/BACKEND-FINAL-FORM-LOCAL-FIRST-HUMAN-01.md` (partial_implementation; release proof)
  - `AMB-POST23-01-TRUTH-AUDIT` — `docs/codex/reports/AMB-POST23-01-TRUTH-AUDIT.md` (partial_implementation; release proof)

### 94. Same source file targeted by multiple active items: scripts/ambitions-throughput-plan.sh

- Candidate ID: `AMB28-same_source_file_targeted_by_multiple_active_batches-14523684`
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

### 95. Same source file targeted by multiple active items: Native/Ambitions/Domain/AmbitionsOSExperienceModels.swift

- Candidate ID: `AMB28-same_source_file_targeted_by_multiple_active_batches-14909139`
- Evidence type: `same_source_file_targeted_by_multiple_active_batches`
- Severity: `yellow`
- Recommended action: `Merge`
- Linear-ready: `True`
- Auto-resolved: `False`
- Reason: Multiple active work items target the same source file; merge or sequence ownership before implementation.
- Involved active paths:
  - `AMBITIONSOS_AOS_TRACEABILITY_MATRIX` — `docs/codex/AMBITIONSOS_AOS_TRACEABILITY_MATRIX.md` (partial_implementation; release proof)
  - `AMBITIONSOS_AOS_PRIVACY_PROJECTION_LEDGER` — `docs/codex/AMBITIONSOS_AOS_PRIVACY_PROJECTION_LEDGER.md` (unknown; release proof)
  - `existing-code-champion-coverage` — `docs/codex/existing-code-champion-coverage.yml` (unknown; release proof)

### 96. Same source file targeted by multiple active items: Native/Ambitions/Domain/GoalRealityRiskModels.swift

- Candidate ID: `AMB28-same_source_file_targeted_by_multiple_active_batches-15161586`
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
  - `MOAT-GOAL-REALITY-SOURCE-PACKS-09` — `prompts/batches/MOAT-GOAL-REALITY-SOURCE-PACKS-09.md` (partial_implementation; release proof)

### 97. Same source file targeted by multiple active items: Native/Ambitions/Features/Goals/GoalsViewModels.swift

- Candidate ID: `AMB28-same_source_file_targeted_by_multiple_active_batches-15689898`
- Evidence type: `same_source_file_targeted_by_multiple_active_batches`
- Severity: `yellow`
- Recommended action: `Merge`
- Linear-ready: `True`
- Auto-resolved: `False`
- Reason: Multiple active work items target the same source file; merge or sequence ownership before implementation.
- Involved active paths:
  - `repo-audit-baseline` — `docs/codex/repo-audit-baseline.md` (partial_implementation; release proof)
  - `PK19` — `prompts/batches/PK19.md` (partial_implementation; release proof)

### 98. Same source file targeted by multiple active items: Native/Ambitions/Features/Today/TodayViewModel.swift

- Candidate ID: `AMB28-same_source_file_targeted_by_multiple_active_batches-16035433`
- Evidence type: `same_source_file_targeted_by_multiple_active_batches`
- Severity: `yellow`
- Recommended action: `Merge`
- Linear-ready: `True`
- Auto-resolved: `False`
- Reason: Multiple active work items target the same source file; merge or sequence ownership before implementation.
- Involved active paths:
  - `repo-audit-baseline` — `docs/codex/repo-audit-baseline.md` (partial_implementation; release proof)
  - `PK17` — `prompts/batches/PK17.md` (partial_implementation; release proof)
  - `PK18` — `prompts/batches/PK18.md` (partial_implementation; release proof)

### 99. Same source file targeted by multiple active items: scripts/ambitions-frontend-architecture-atlas-check.py

- Candidate ID: `AMB28-same_source_file_targeted_by_multiple_active_batches-17172969`
- Evidence type: `same_source_file_targeted_by_multiple_active_batches`
- Severity: `yellow`
- Recommended action: `Merge`
- Linear-ready: `True`
- Auto-resolved: `False`
- Reason: Multiple active work items target the same source file; merge or sequence ownership before implementation.
- Involved active paths:
  - `FRONTEND-SURFACE-RECIPE-COMPLETENESS-REVIEW-001` — `prompts/batches/FRONTEND-SURFACE-RECIPE-COMPLETENESS-REVIEW-001.md` (partial_implementation; release proof)
  - `FLAGSHIP-OBJECT-SYSTEM-01` — `prompts/batches/FLAGSHIP-OBJECT-SYSTEM-01.md` (partial_implementation; release proof)

### 100. Same source file targeted by multiple active items: Native/Ambitions/Domain/AmbitionsOSPrivacySafetyModels.swift

- Candidate ID: `AMB28-same_source_file_targeted_by_multiple_active_batches-17458192`
- Evidence type: `same_source_file_targeted_by_multiple_active_batches`
- Severity: `yellow`
- Recommended action: `Merge`
- Linear-ready: `True`
- Auto-resolved: `False`
- Reason: Multiple active work items target the same source file; merge or sequence ownership before implementation.
- Involved active paths:
  - `AMBITIONSOS_AOS_TRACEABILITY_MATRIX` — `docs/codex/AMBITIONSOS_AOS_TRACEABILITY_MATRIX.md` (partial_implementation; release proof)
  - `PK26` — `prompts/batches/PK26.md` (partial_implementation; release proof)
  - `AOS27` — `prompts/batches/AOS27.md` (partial_implementation; release proof)
  - `PFC34` — `prompts/batches/PFC34.md` (partial_implementation; release proof)
  - `AMBITIONSOS_AOS_PRIVACY_PROJECTION_LEDGER` — `docs/codex/AMBITIONSOS_AOS_PRIVACY_PROJECTION_LEDGER.md` (unknown; release proof)
  - `AMBITIONSOS_AOS_SOURCE_TRUTH_CLAIM_LEDGER` — `docs/codex/AMBITIONSOS_AOS_SOURCE_TRUTH_CLAIM_LEDGER.md` (unknown; release proof)
  - `existing-code-champion-coverage` — `docs/codex/existing-code-champion-coverage.yml` (unknown; release proof)

### 101. Same source file targeted by multiple active items: scripts/ambitions_validate_prompt_headers.py

- Candidate ID: `AMB28-same_source_file_targeted_by_multiple_active_batches-1827678`
- Evidence type: `same_source_file_targeted_by_multiple_active_batches`
- Severity: `yellow`
- Recommended action: `Merge`
- Linear-ready: `True`
- Auto-resolved: `False`
- Reason: Multiple active work items target the same source file; merge or sequence ownership before implementation.
- Involved active paths:
  - `AMB_CODEX_GOVERNANCE_SPEC` — `docs/codex/AMB_CODEX_GOVERNANCE_SPEC.md` (partial_implementation; release proof)
  - `AMB-FILE-BY-FILE-REPO-AUDIT-01` — `prompts/batches/AMB-FILE-BY-FILE-REPO-AUDIT-01.md` (partial_implementation; release proof)
  - `AMB-REPO-GREEN-FLAGSHIP-RESET-MASTER-01` — `prompts/batches/AMB-REPO-GREEN-FLAGSHIP-RESET-MASTER-01.md` (partial_implementation; release proof)

### 102. Same source file targeted by multiple active items: Native/Ambitions/Runtime/GoalRealitySourceBoundaryService.swift

- Candidate ID: `AMB28-same_source_file_targeted_by_multiple_active_batches-18737887`
- Evidence type: `same_source_file_targeted_by_multiple_active_batches`
- Severity: `yellow`
- Recommended action: `Merge`
- Linear-ready: `True`
- Auto-resolved: `False`
- Reason: Multiple active work items target the same source file; merge or sequence ownership before implementation.
- Involved active paths:
  - `MOAT-GOAL-REALITY-EVAL-HARNESS-10` — `prompts/batches/MOAT-GOAL-REALITY-EVAL-HARNESS-10.md` (partial_implementation; release proof)
  - `MOAT-GOAL-REALITY-SOURCE-PACKS-09` — `prompts/batches/MOAT-GOAL-REALITY-SOURCE-PACKS-09.md` (partial_implementation; release proof)

### 103. Same source file targeted by multiple active items: Native/Ambitions/Domain/AmbitionsOSInteroperabilityModels.swift

- Candidate ID: `AMB28-same_source_file_targeted_by_multiple_active_batches-20274285`
- Evidence type: `same_source_file_targeted_by_multiple_active_batches`
- Severity: `yellow`
- Recommended action: `Merge`
- Linear-ready: `True`
- Auto-resolved: `False`
- Reason: Multiple active work items target the same source file; merge or sequence ownership before implementation.
- Involved active paths:
  - `AMBITIONSOS_AOS_TRACEABILITY_MATRIX` — `docs/codex/AMBITIONSOS_AOS_TRACEABILITY_MATRIX.md` (partial_implementation; release proof)
  - `AMBITIONSOS_AOS_PRIVACY_PROJECTION_LEDGER` — `docs/codex/AMBITIONSOS_AOS_PRIVACY_PROJECTION_LEDGER.md` (unknown; release proof)
  - `existing-code-champion-coverage` — `docs/codex/existing-code-champion-coverage.yml` (unknown; release proof)

### 104. Same source file targeted by multiple active items: Native/AmbitionsTests/Runtime/MoonshotProofPathRuntimeTests.swift

- Candidate ID: `AMB28-same_source_file_targeted_by_multiple_active_batches-20294355`
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
  - `MOAT-UNIVERSAL-GOAL-REALITY-COMPILER-01` — `prompts/batches/MOAT-UNIVERSAL-GOAL-REALITY-COMPILER-01.md` (partial_implementation; release proof)

### 105. Same source file targeted by multiple active items: scripts/ambitions-mri-materialize-prompts.py

- Candidate ID: `AMB28-same_source_file_targeted_by_multiple_active_batches-209761`
- Evidence type: `same_source_file_targeted_by_multiple_active_batches`
- Severity: `yellow`
- Recommended action: `Merge`
- Linear-ready: `True`
- Auto-resolved: `False`
- Reason: Multiple active work items target the same source file; merge or sequence ownership before implementation.
- Involved active paths:
  - `MRI00-MOAT-RUNTIME-GAP-LOCK` — `prompts/batches/MRI00-MOAT-RUNTIME-GAP-LOCK.md` (partial_implementation; release proof)
  - `FRONTEND-SURFACE-RECIPE-COMPLETENESS-REVIEW-001` — `prompts/batches/FRONTEND-SURFACE-RECIPE-COMPLETENESS-REVIEW-001.md` (partial_implementation; release proof)

### 106. Same source file targeted by multiple active items: scripts/ldi-source-pack-schema-check.py

- Candidate ID: `AMB28-same_source_file_targeted_by_multiple_active_batches-2129993`
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

### 107. Same source file targeted by multiple active items: scripts/ai/acx_repair.py

- Candidate ID: `AMB28-same_source_file_targeted_by_multiple_active_batches-21796509`
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

### 108. Same source file targeted by multiple active items: scripts/validate-repo-authority.sh

- Candidate ID: `AMB28-same_source_file_targeted_by_multiple_active_batches-22228552`
- Evidence type: `same_source_file_targeted_by_multiple_active_batches`
- Severity: `yellow`
- Recommended action: `Merge`
- Linear-ready: `True`
- Auto-resolved: `False`
- Reason: Multiple active work items target the same source file; merge or sequence ownership before implementation.
- Involved active paths:
  - `README-SOURCE-TRUTH-LINK-AND-CLAIM-REPAIR-01` — `prompts/batches/README-SOURCE-TRUTH-LINK-AND-CLAIM-REPAIR-01.md` (partial_implementation; release proof)
  - `REPO-AUTHORITY-LEGACY-ACTIVE-HEADER-CLEANUP-01` — `prompts/batches/REPO-AUTHORITY-LEGACY-ACTIVE-HEADER-CLEANUP-01.md` (partial_implementation; release proof)
  - `TOP-LEVEL-IA-PLAN-LEAK-REGRESSION-01` — `prompts/batches/TOP-LEVEL-IA-PLAN-LEAK-REGRESSION-01.md` (partial_implementation; release proof)

### 109. Same source file targeted by multiple active items: scripts/test-local.sh

- Candidate ID: `AMB28-same_source_file_targeted_by_multiple_active_batches-22244100`
- Evidence type: `same_source_file_targeted_by_multiple_active_batches`
- Severity: `yellow`
- Recommended action: `Merge`
- Linear-ready: `True`
- Auto-resolved: `False`
- Reason: Multiple active work items target the same source file; merge or sequence ownership before implementation.
- Involved active paths:
  - `AMBITIONS_3_0_CONTEXT_LOADING_AND_TASK_ROUTING` — `docs/codex/AMBITIONS_3_0_CONTEXT_LOADING_AND_TASK_ROUTING.md` (partial_implementation; release proof)
  - `F27_Final_FAANG_Handoff_Gate_Rerun_Prompt` — `docs/codex/batches/F27_Final_FAANG_Handoff_Gate_Rerun_Prompt.md` (partial_implementation; release proof)
  - `PFC05_CI_Local_Toolchain_Reproducibility_Prompt` — `docs/codex/batches/PFC05_CI_Local_Toolchain_Reproducibility_Prompt.md` (partial_implementation; release proof)
  - `F21_5_UI_Flake_Reliability_Hardening_Prompt` — `docs/codex/batches/F21_5_UI_Flake_Reliability_Hardening_Prompt.md` (unknown; release proof)

### 110. Same source file targeted by multiple active items: Native/Ambitions/Domain/AmbitionsOSAdaptationModels.swift

- Candidate ID: `AMB28-same_source_file_targeted_by_multiple_active_batches-22304939`
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

### 111. Same source file targeted by multiple active items: Native/Ambitions/Domain/MoonshotProofPathModels.swift

- Candidate ID: `AMB28-same_source_file_targeted_by_multiple_active_batches-22644831`
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
  - `MOAT-UNIVERSAL-GOAL-REALITY-COMPILER-01` — `prompts/batches/MOAT-UNIVERSAL-GOAL-REALITY-COMPILER-01.md` (partial_implementation; release proof)

### 112. Same source file targeted by multiple active items: Native/Ambitions/Persistence/SwiftDataModels.swift

- Candidate ID: `AMB28-same_source_file_targeted_by_multiple_active_batches-23581771`
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

### 113. Same source file targeted by multiple active items: Native/Ambitions/Services/GoalPathCompilerService.swift

- Candidate ID: `AMB28-same_source_file_targeted_by_multiple_active_batches-23849675`
- Evidence type: `same_source_file_targeted_by_multiple_active_batches`
- Severity: `yellow`
- Recommended action: `Merge`
- Linear-ready: `True`
- Auto-resolved: `False`
- Reason: Multiple active work items target the same source file; merge or sequence ownership before implementation.
- Involved active paths:
  - `BATCH-24-path-compiler-foundation` — `docs/codex/batches/BATCH-24-path-compiler-foundation.md` (unknown; release proof)
  - `BATCH-25-domain-pack-framework` — `docs/codex/batches/BATCH-25-domain-pack-framework.md` (unknown; release proof)

### 114. Same source file targeted by multiple active items: scripts/ambitions-xcode-test-focused.sh

- Candidate ID: `AMB28-same_source_file_targeted_by_multiple_active_batches-2483699`
- Evidence type: `same_source_file_targeted_by_multiple_active_batches`
- Severity: `yellow`
- Recommended action: `Merge`
- Linear-ready: `True`
- Auto-resolved: `False`
- Reason: Multiple active work items target the same source file; merge or sequence ownership before implementation.
- Involved active paths:
  - `XCODE-BUILD-SYSTEM-MAX-01-REPAIR-01` — `prompts/batches/XCODE-BUILD-SYSTEM-MAX-01-REPAIR-01.md` (partial_implementation; release proof)
  - `XCODE-PERF-RUNNER-MATURITY-01` — `prompts/batches/XCODE-PERF-RUNNER-MATURITY-01.md` (partial_implementation; release proof)

### 115. Same source file targeted by multiple active items: scripts/eb-active-train-integration-gate.sh

- Candidate ID: `AMB28-same_source_file_targeted_by_multiple_active_batches-25086941`
- Evidence type: `same_source_file_targeted_by_multiple_active_batches`
- Severity: `yellow`
- Recommended action: `Merge`
- Linear-ready: `True`
- Auto-resolved: `False`
- Reason: Multiple active work items target the same source file; merge or sequence ownership before implementation.
- Involved active paths:
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
  - ... 30 more

### 116. Same source file targeted by multiple active items: Native/AmbitionsUITests/AmbitionsUITests.swift

- Candidate ID: `AMB28-same_source_file_targeted_by_multiple_active_batches-27271396`
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
  - `AMB-POST23-01-TRUTH-AUDIT` — `docs/codex/reports/AMB-POST23-01-TRUTH-AUDIT.md` (partial_implementation; release proof)

### 117. Same source file targeted by multiple active items: scripts/ldi-pack-supply-chain-scan.py

- Candidate ID: `AMB28-same_source_file_targeted_by_multiple_active_batches-2900653`
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

### 118. Same source file targeted by multiple active items: Native/AmbitionsTests/Services/AmbitionsCommandExecutorTests.swift

- Candidate ID: `AMB28-same_source_file_targeted_by_multiple_active_batches-29232168`
- Evidence type: `same_source_file_targeted_by_multiple_active_batches`
- Severity: `yellow`
- Recommended action: `Merge`
- Linear-ready: `True`
- Auto-resolved: `False`
- Reason: Multiple active work items target the same source file; merge or sequence ownership before implementation.
- Involved active paths:
  - `PK22` — `prompts/batches/PK22.md` (partial_implementation; release proof)
  - `BACKEND-FINAL-FORM-LOCAL-FIRST-HUMAN-01` — `prompts/batches/BACKEND-FINAL-FORM-LOCAL-FIRST-HUMAN-01.md` (partial_implementation; release proof)

### 119. Same source file targeted by multiple active items: scripts/ai/acx_closeout.py

- Candidate ID: `AMB28-same_source_file_targeted_by_multiple_active_batches-29239191`
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

### 120. Same source file targeted by multiple active items: Native/Ambitions/Features/You/YouScreen.swift

- Candidate ID: `AMB28-same_source_file_targeted_by_multiple_active_batches-2983325`
- Evidence type: `same_source_file_targeted_by_multiple_active_batches`
- Severity: `yellow`
- Recommended action: `Merge`
- Linear-ready: `True`
- Auto-resolved: `False`
- Reason: Multiple active work items target the same source file; merge or sequence ownership before implementation.
- Involved active paths:
  - `ALIGN-01-NAMING` — `prompts/batches/ALIGN-01-NAMING.md` (partial_implementation; release proof)
  - `AMB-POST23-01-TRUTH-AUDIT` — `docs/codex/reports/AMB-POST23-01-TRUTH-AUDIT.md` (partial_implementation; release proof)

### 121. Same source file targeted by multiple active items: Native/Ambitions/Domain/AmbitionsOSLivingDreamTodayBridgeModels.swift

- Candidate ID: `AMB28-same_source_file_targeted_by_multiple_active_batches-29833757`
- Evidence type: `same_source_file_targeted_by_multiple_active_batches`
- Severity: `yellow`
- Recommended action: `Merge`
- Linear-ready: `True`
- Auto-resolved: `False`
- Reason: Multiple active work items target the same source file; merge or sequence ownership before implementation.
- Involved active paths:
  - `MOAT-MOONSHOT-BACKEND-FULL-TRAIN-01` — `prompts/batches/MOAT-MOONSHOT-BACKEND-FULL-TRAIN-01.md` (partial_implementation; release proof)
  - `MOAT-MOONSHOT-PROOF-PATH-01` — `prompts/batches/MOAT-MOONSHOT-PROOF-PATH-01.md` (partial_implementation; release proof)
  - `MOAT-UNIVERSAL-GOAL-REALITY-COMPILER-01` — `prompts/batches/MOAT-UNIVERSAL-GOAL-REALITY-COMPILER-01.md` (partial_implementation; release proof)
  - `existing-code-champion-coverage` — `docs/codex/existing-code-champion-coverage.yml` (unknown; release proof)

### 122. Same source file targeted by multiple active items: scripts/ci-local-parity.sh

- Candidate ID: `AMB28-same_source_file_targeted_by_multiple_active_batches-29867836`
- Evidence type: `same_source_file_targeted_by_multiple_active_batches`
- Severity: `yellow`
- Recommended action: `Merge`
- Linear-ready: `True`
- Auto-resolved: `False`
- Reason: Multiple active work items target the same source file; merge or sequence ownership before implementation.
- Involved active paths:
  - `PFC01_PFC40_PLATFORM_FRAMEWORK_COMPLIANCE_TRAIN` — `docs/codex/batch-trains/PFC01_PFC40_PLATFORM_FRAMEWORK_COMPLIANCE_TRAIN.md` (partial_implementation; release proof)
  - `PFC05_CI_Local_Toolchain_Reproducibility_Prompt` — `docs/codex/batches/PFC05_CI_Local_Toolchain_Reproducibility_Prompt.md` (partial_implementation; release proof)

### 123. Same source file targeted by multiple active items: Native/Ambitions/Domain/AmbitionsOSProofTrustModels.swift

- Candidate ID: `AMB28-same_source_file_targeted_by_multiple_active_batches-30641025`
- Evidence type: `same_source_file_targeted_by_multiple_active_batches`
- Severity: `yellow`
- Recommended action: `Merge`
- Linear-ready: `True`
- Auto-resolved: `False`
- Reason: Multiple active work items target the same source file; merge or sequence ownership before implementation.
- Involved active paths:
  - `AMBITIONSOS_AOS_TRACEABILITY_MATRIX` — `docs/codex/AMBITIONSOS_AOS_TRACEABILITY_MATRIX.md` (partial_implementation; release proof)
  - `existing-code-champion-coverage` — `docs/codex/existing-code-champion-coverage.yml` (unknown; release proof)

### 124. Same source file targeted by multiple active items: scripts/ambitions-historical-baseline-train-guard.py

- Candidate ID: `AMB28-same_source_file_targeted_by_multiple_active_batches-30768575`
- Evidence type: `same_source_file_targeted_by_multiple_active_batches`
- Severity: `yellow`
- Recommended action: `Merge`
- Linear-ready: `True`
- Auto-resolved: `False`
- Reason: Multiple active work items target the same source file; merge or sequence ownership before implementation.
- Involved active paths:
  - `AUTONOMOUS-TRAIN-FASTPATH-01` — `prompts/batches/AUTONOMOUS-TRAIN-FASTPATH-01.md` (partial_implementation; release proof)
  - `HBI-GLOBAL-TRAIN-HANDOFF-01` — `prompts/batches/HBI-GLOBAL-TRAIN-HANDOFF-01.md` (partial_implementation; release proof)
  - `RRE-01` — `prompts/batches/RRE-01.md` (partial_implementation; release proof)

### 125. Same source file targeted by multiple active items: scripts/cqs-architecture-boundary-scan.sh

- Candidate ID: `AMB28-same_source_file_targeted_by_multiple_active_batches-30805174`
- Evidence type: `same_source_file_targeted_by_multiple_active_batches`
- Severity: `yellow`
- Recommended action: `Merge`
- Linear-ready: `True`
- Auto-resolved: `False`
- Reason: Multiple active work items target the same source file; merge or sequence ownership before implementation.
- Involved active paths:
  - `CQS01_CQS24_CODEX_QUALITY_SYSTEM_TRAIN` — `docs/codex/batch-trains/CQS01_CQS24_CODEX_QUALITY_SYSTEM_TRAIN.md` (partial_implementation; release proof)
  - `PFC02_Architecture_Boundary_And_Module_Map_Prompt` — `docs/codex/batches/PFC02_Architecture_Boundary_And_Module_Map_Prompt.md` (partial_implementation; release proof)
  - `GATE_SYSTEM_HARDENING_NEXT_PROMPT` — `docs/codex/batches/GATE_SYSTEM_HARDENING_NEXT_PROMPT.md` (partial_implementation; release proof)
  - `CODEX_QUALITY_SYSTEM_SCRIPT_MAP` — `docs/codex/CODEX_QUALITY_SYSTEM_SCRIPT_MAP.md` (unknown; release proof)

### 126. Same source file targeted by multiple active items: scripts/sa-generated-step-boundary-scan.sh

- Candidate ID: `AMB28-same_source_file_targeted_by_multiple_active_batches-30846286`
- Evidence type: `same_source_file_targeted_by_multiple_active_batches`
- Severity: `yellow`
- Recommended action: `Merge`
- Linear-ready: `True`
- Auto-resolved: `False`
- Reason: Multiple active work items target the same source file; merge or sequence ownership before implementation.
- Involved active paths:
  - `SOURCE_ATLAS_CODEX_OS_UPGRADE_MAP` — `docs/codex/SOURCE_ATLAS_CODEX_OS_UPGRADE_MAP.md` (partial_implementation; release proof)
  - `GATE_SYSTEM_HARDENING_NEXT_PROMPT` — `docs/codex/batches/GATE_SYSTEM_HARDENING_NEXT_PROMPT.md` (partial_implementation; release proof)

### 127. Same source file targeted by multiple active items: Native/Ambitions/Features/Plan/PlanFeatureService.swift

- Candidate ID: `AMB28-same_source_file_targeted_by_multiple_active_batches-31915754`
- Evidence type: `same_source_file_targeted_by_multiple_active_batches`
- Severity: `yellow`
- Recommended action: `Merge`
- Linear-ready: `True`
- Auto-resolved: `False`
- Reason: Multiple active work items target the same source file; merge or sequence ownership before implementation.
- Involved active paths:
  - `PK21` — `prompts/batches/PK21.md` (partial_implementation; release proof)
  - `PK37` — `prompts/batches/PK37.md` (partial_implementation; release proof)
  - `LDI15` — `prompts/batches/LDI15.md` (partial_implementation; release proof)

### 128. Same source file targeted by multiple active items: Native/Ambitions/Runtime/GoalRealityCompiler.swift

- Candidate ID: `AMB28-same_source_file_targeted_by_multiple_active_batches-34500819`
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
  - `MOAT-GOAL-REALITY-RECEIPT-CLOSURE-07` — `prompts/batches/MOAT-GOAL-REALITY-RECEIPT-CLOSURE-07.md` (partial_implementation; release proof)
  - `MOAT-GOAL-REALITY-RUNTIME-SERVICE-03` — `prompts/batches/MOAT-GOAL-REALITY-RUNTIME-SERVICE-03.md` (partial_implementation; release proof)
  - `MOAT-GOAL-REALITY-SOURCE-PACKS-09` — `prompts/batches/MOAT-GOAL-REALITY-SOURCE-PACKS-09.md` (partial_implementation; release proof)

### 129. Same source file targeted by multiple active items: Native/Ambitions/App/AppContainerFactory.swift

- Candidate ID: `AMB28-same_source_file_targeted_by_multiple_active_batches-35022831`
- Evidence type: `same_source_file_targeted_by_multiple_active_batches`
- Severity: `yellow`
- Recommended action: `Merge`
- Linear-ready: `True`
- Auto-resolved: `False`
- Reason: Multiple active work items target the same source file; merge or sequence ownership before implementation.
- Involved active paths:
  - `repo-audit-baseline` — `docs/codex/repo-audit-baseline.md` (partial_implementation; release proof)
  - `BACKEND-FINAL-FORM-LOCAL-FIRST-HUMAN-01` — `prompts/batches/BACKEND-FINAL-FORM-LOCAL-FIRST-HUMAN-01.md` (partial_implementation; release proof)
  - `existing-code-champion-coverage` — `docs/codex/existing-code-champion-coverage.yml` (unknown; release proof)

### 130. Same source file targeted by multiple active items: Native/Ambitions/Services/KnowledgeProviderBoundary.swift

- Candidate ID: `AMB28-same_source_file_targeted_by_multiple_active_batches-35026564`
- Evidence type: `same_source_file_targeted_by_multiple_active_batches`
- Severity: `yellow`
- Recommended action: `Merge`
- Linear-ready: `True`
- Auto-resolved: `False`
- Reason: Multiple active work items target the same source file; merge or sequence ownership before implementation.
- Involved active paths:
  - `BATCH-20-knowledge-provider-boundary` — `docs/codex/batches/BATCH-20-knowledge-provider-boundary.md` (unknown; release proof)
  - `BATCH-21-external-knowledge-ingestion-core` — `docs/codex/batches/BATCH-21-external-knowledge-ingestion-core.md` (unknown; release proof)

### 131. Same source file targeted by multiple active items: Native/Ambitions/Persistence/PortableSnapshotContracts.swift

- Candidate ID: `AMB28-same_source_file_targeted_by_multiple_active_batches-35615454`
- Evidence type: `same_source_file_targeted_by_multiple_active_batches`
- Severity: `yellow`
- Recommended action: `Merge`
- Linear-ready: `True`
- Auto-resolved: `False`
- Reason: Multiple active work items target the same source file; merge or sequence ownership before implementation.
- Involved active paths:
  - `PFC07_Migration_Ladder_And_Backward_Compatibility_Tests_Prompt` — `docs/codex/batches/PFC07_Migration_Ladder_And_Backward_Compatibility_Tests_Prompt.md` (partial_implementation; release proof)
  - `PK30` — `prompts/batches/PK30.md` (partial_implementation; release proof)
  - `PK31` — `prompts/batches/PK31.md` (partial_implementation; release proof)
  - `BACKEND-FINAL-FORM-LOCAL-FIRST-HUMAN-01` — `prompts/batches/BACKEND-FINAL-FORM-LOCAL-FIRST-HUMAN-01.md` (partial_implementation; release proof)
  - `AMB-POST23-01-TRUTH-AUDIT` — `docs/codex/reports/AMB-POST23-01-TRUTH-AUDIT.md` (partial_implementation; release proof)
  - `PFC08_Corruption_Recovery_Backup_Restore_Plan_Prompt` — `docs/codex/batches/PFC08_Corruption_Recovery_Backup_Restore_Plan_Prompt.md` (unknown; release proof)

### 132. Same source file targeted by multiple active items: Native/Ambitions/Domain/AmbitionsOSAlternatePathModels.swift

- Candidate ID: `AMB28-same_source_file_targeted_by_multiple_active_batches-35940937`
- Evidence type: `same_source_file_targeted_by_multiple_active_batches`
- Severity: `yellow`
- Recommended action: `Merge`
- Linear-ready: `True`
- Auto-resolved: `False`
- Reason: Multiple active work items target the same source file; merge or sequence ownership before implementation.
- Involved active paths:
  - `AMBITIONSOS_AOS_TRACEABILITY_MATRIX` — `docs/codex/AMBITIONSOS_AOS_TRACEABILITY_MATRIX.md` (partial_implementation; release proof)
  - `existing-code-champion-coverage` — `docs/codex/existing-code-champion-coverage.yml` (unknown; release proof)

### 133. Same source file targeted by multiple active items: scripts/ldi-gate-check.sh

- Candidate ID: `AMB28-same_source_file_targeted_by_multiple_active_batches-36335147`
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

### 134. Same source file targeted by multiple active items: Native/Ambitions/Features/Today/TodayExecutionViewState.swift

- Candidate ID: `AMB28-same_source_file_targeted_by_multiple_active_batches-36622102`
- Evidence type: `same_source_file_targeted_by_multiple_active_batches`
- Severity: `yellow`
- Recommended action: `Merge`
- Linear-ready: `True`
- Auto-resolved: `False`
- Reason: Multiple active work items target the same source file; merge or sequence ownership before implementation.
- Involved active paths:
  - `F03_5_Today_Execution_State_Contract_Hardening_Prompt` — `docs/codex/batches/F03_5_Today_Execution_State_Contract_Hardening_Prompt.md` (partial_implementation; release proof)
  - `PK17` — `prompts/batches/PK17.md` (partial_implementation; release proof)

### 135. Same source file targeted by multiple active items: Native/Ambitions/App/AppIntentLaunchRouter.swift

- Candidate ID: `AMB28-same_source_file_targeted_by_multiple_active_batches-36670396`
- Evidence type: `same_source_file_targeted_by_multiple_active_batches`
- Severity: `yellow`
- Recommended action: `Merge`
- Linear-ready: `True`
- Auto-resolved: `False`
- Reason: Multiple active work items target the same source file; merge or sequence ownership before implementation.
- Involved active paths:
  - `PFC18_App_Intents_Shortcuts_Implementation_And_Tests_Prompt` — `docs/codex/batches/PFC18_App_Intents_Shortcuts_Implementation_And_Tests_Prompt.md` (partial_implementation; release proof)
  - `existing-code-champion-coverage` — `docs/codex/existing-code-champion-coverage.yml` (unknown; release proof)

### 136. Same source file targeted by multiple active items: Native/AmbitionsTests/Runtime/GoalRealityReceiptTests.swift

- Candidate ID: `AMB28-same_source_file_targeted_by_multiple_active_batches-37290351`
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

### 137. Same source file targeted by multiple active items: scripts/eb-no-5-version-drift-scan.sh

- Candidate ID: `AMB28-same_source_file_targeted_by_multiple_active_batches-37431091`
- Evidence type: `same_source_file_targeted_by_multiple_active_batches`
- Severity: `yellow`
- Recommended action: `Merge`
- Linear-ready: `True`
- Auto-resolved: `False`
- Reason: Multiple active work items target the same source file; merge or sequence ownership before implementation.
- Involved active paths:
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
  - ... 30 more

### 138. Same source file targeted by multiple active items: Native/Ambitions/Domain/RecommendationExplanationModels.swift

- Candidate ID: `AMB28-same_source_file_targeted_by_multiple_active_batches-38025327`
- Evidence type: `same_source_file_targeted_by_multiple_active_batches`
- Severity: `yellow`
- Recommended action: `Merge`
- Linear-ready: `True`
- Auto-resolved: `False`
- Reason: Multiple active work items target the same source file; merge or sequence ownership before implementation.
- Involved active paths:
  - `PK33` — `prompts/batches/PK33.md` (partial_implementation; release proof)
  - `MOAT-GOAL-REALITY-RECEIPT-CLOSURE-07` — `prompts/batches/MOAT-GOAL-REALITY-RECEIPT-CLOSURE-07.md` (partial_implementation; release proof)

### 139. Same source file targeted by multiple active items: scripts/ai/acx_accessibility_packet.py

- Candidate ID: `AMB28-same_source_file_targeted_by_multiple_active_batches-39405009`
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

### 140. Same source file targeted by multiple active items: scripts/ai/acx.py

- Candidate ID: `AMB28-same_source_file_targeted_by_multiple_active_batches-39685319`
- Evidence type: `same_source_file_targeted_by_multiple_active_batches`
- Severity: `yellow`
- Recommended action: `Merge`
- Linear-ready: `True`
- Auto-resolved: `False`
- Reason: Multiple active work items target the same source file; merge or sequence ownership before implementation.
- Involved active paths:
  - `CODEX_OS_PEAK_OPERATING_PROTOCOL` — `docs/codex/CODEX_OS_PEAK_OPERATING_PROTOCOL.md` (partial_implementation; release proof)
  - `CODEX_ACX_LOCAL_EXECUTOR` — `docs/codex/CODEX_ACX_LOCAL_EXECUTOR.md` (partial_implementation; release proof)
  - `CODEX_AGENT_PROTOCOL` — `docs/codex/CODEX_AGENT_PROTOCOL.md` (partial_implementation; release proof)
  - `CODEX_OS_UPGRADE_AUDIT_2026_05_07` — `docs/codex/CODEX_OS_UPGRADE_AUDIT_2026_05_07.md` (partial_implementation; release proof)
  - `CODEX_OS_REPAIR_SPEED_PROOF_UPGRADE_AUDIT_2026_05_08` — `docs/codex/CODEX_OS_REPAIR_SPEED_PROOF_UPGRADE_AUDIT_2026_05_08.md` (partial_implementation; release proof)
  - `CODEX_QUALITY_SYSTEM_SCRIPT_MAP` — `docs/codex/CODEX_QUALITY_SYSTEM_SCRIPT_MAP.md` (unknown; release proof)

### 141. Same source file targeted by multiple active items: scripts/ambitions-state-advance-validate.py

- Candidate ID: `AMB28-same_source_file_targeted_by_multiple_active_batches-39781651`
- Evidence type: `same_source_file_targeted_by_multiple_active_batches`
- Severity: `yellow`
- Recommended action: `Merge`
- Linear-ready: `True`
- Auto-resolved: `False`
- Reason: Multiple active work items target the same source file; merge or sequence ownership before implementation.
- Involved active paths:
  - `POST_PK_CLOSEOUT_CONTRACT` — `docs/codex/POST_PK_CLOSEOUT_CONTRACT.md` (partial_implementation; release proof)
  - `POST_PK_SPEED_TRAIN_OPERATING_MODEL` — `docs/codex/POST_PK_SPEED_TRAIN_OPERATING_MODEL.md` (unknown; release proof)

### 142. Same source file targeted by multiple active items: Native/Ambitions/Domain/GoalEngine/GoalEngineContracts.swift

- Candidate ID: `AMB28-same_source_file_targeted_by_multiple_active_batches-39825800`
- Evidence type: `same_source_file_targeted_by_multiple_active_batches`
- Severity: `yellow`
- Recommended action: `Merge`
- Linear-ready: `True`
- Auto-resolved: `False`
- Reason: Multiple active work items target the same source file; merge or sequence ownership before implementation.
- Involved active paths:
  - `repo-audit-baseline` — `docs/codex/repo-audit-baseline.md` (partial_implementation; release proof)
  - `BATCH-23-generalized-goal-understanding-contracts` — `docs/codex/batches/BATCH-23-generalized-goal-understanding-contracts.md` (unknown; release proof)

### 143. Same source file targeted by multiple active items: scripts/ai/acx_sanitized_evidence.py

- Candidate ID: `AMB28-same_source_file_targeted_by_multiple_active_batches-40315774`
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

### 144. Same source file targeted by multiple active items: Native/AmbitionsTests/Domain/AmbitionsOSLivingDreamTodayBridgeModelsTests.swift

- Candidate ID: `AMB28-same_source_file_targeted_by_multiple_active_batches-41160817`
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
  - `MOAT-UNIVERSAL-GOAL-REALITY-COMPILER-01` — `prompts/batches/MOAT-UNIVERSAL-GOAL-REALITY-COMPILER-01.md` (partial_implementation; release proof)

### 145. Same source file targeted by multiple active items: Native/Ambitions/Domain/AmbitionsCommandModels.swift

- Candidate ID: `AMB28-same_source_file_targeted_by_multiple_active_batches-4149124`
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

### 146. Same source file targeted by multiple active items: Native/Ambitions/AppIntents/OpenAmbitionsDestinationIntent.swift

- Candidate ID: `AMB28-same_source_file_targeted_by_multiple_active_batches-41712926`
- Evidence type: `same_source_file_targeted_by_multiple_active_batches`
- Severity: `yellow`
- Recommended action: `Merge`
- Linear-ready: `True`
- Auto-resolved: `False`
- Reason: Multiple active work items target the same source file; merge or sequence ownership before implementation.
- Involved active paths:
  - `PFC18_App_Intents_Shortcuts_Implementation_And_Tests_Prompt` — `docs/codex/batches/PFC18_App_Intents_Shortcuts_Implementation_And_Tests_Prompt.md` (partial_implementation; release proof)
  - `existing-code-champion-coverage` — `docs/codex/existing-code-champion-coverage.yml` (unknown; release proof)

### 147. Same source file targeted by multiple active items: scripts/ldi-release-claim-scan.sh

- Candidate ID: `AMB28-same_source_file_targeted_by_multiple_active_batches-42388605`
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

### 148. Same source file targeted by multiple active items: scripts/validate-dev-tools.sh

- Candidate ID: `AMB28-same_source_file_targeted_by_multiple_active_batches-43146531`
- Evidence type: `same_source_file_targeted_by_multiple_active_batches`
- Severity: `yellow`
- Recommended action: `Merge`
- Linear-ready: `True`
- Auto-resolved: `False`
- Reason: Multiple active work items target the same source file; merge or sequence ownership before implementation.
- Involved active paths:
  - `AMBITIONS_3_0_CONTEXT_LOADING_AND_TASK_ROUTING` — `docs/codex/AMBITIONS_3_0_CONTEXT_LOADING_AND_TASK_ROUTING.md` (partial_implementation; release proof)
  - `PFC01_Repo_And_Build_System_Inventory_Prompt` — `docs/codex/batches/PFC01_Repo_And_Build_System_Inventory_Prompt.md` (partial_implementation; release proof)
  - `PFC05_CI_Local_Toolchain_Reproducibility_Prompt` — `docs/codex/batches/PFC05_CI_Local_Toolchain_Reproducibility_Prompt.md` (partial_implementation; release proof)

### 149. Same source file targeted by multiple active items: Native/Ambitions/Domain/GoalEngine/GoalEngineOrchestrator.swift

- Candidate ID: `AMB28-same_source_file_targeted_by_multiple_active_batches-4322346`
- Evidence type: `same_source_file_targeted_by_multiple_active_batches`
- Severity: `yellow`
- Recommended action: `Merge`
- Linear-ready: `True`
- Auto-resolved: `False`
- Reason: Multiple active work items target the same source file; merge or sequence ownership before implementation.
- Involved active paths:
  - `repo-audit-baseline` — `docs/codex/repo-audit-baseline.md` (partial_implementation; release proof)
  - `BATCH-23-generalized-goal-understanding-contracts` — `docs/codex/batches/BATCH-23-generalized-goal-understanding-contracts.md` (unknown; release proof)

### 150. Same source file targeted by multiple active items: scripts/ambitions-prompt-audit.sh

- Candidate ID: `AMB28-same_source_file_targeted_by_multiple_active_batches-43725207`
- Evidence type: `same_source_file_targeted_by_multiple_active_batches`
- Severity: `yellow`
- Recommended action: `Merge`
- Linear-ready: `True`
- Auto-resolved: `False`
- Reason: Multiple active work items target the same source file; merge or sequence ownership before implementation.
- Involved active paths:
  - `RHC01` — `prompts/batches/RHC01.md` (partial_implementation; release proof)
  - `CODEX-RUNNER-READ-ONLY-AUDIT-MODE-01` — `prompts/batches/CODEX-RUNNER-READ-ONLY-AUDIT-MODE-01.md` (partial_implementation; release proof)

### 151. Same source file targeted by multiple active items: scripts/ldi-handling-lane-scan.sh

- Candidate ID: `AMB28-same_source_file_targeted_by_multiple_active_batches-43961835`
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

### 152. Same source file targeted by multiple active items: Native/AmbitionsTests/App/AppContainerFactoryTests.swift

- Candidate ID: `AMB28-same_source_file_targeted_by_multiple_active_batches-44287607`
- Evidence type: `same_source_file_targeted_by_multiple_active_batches`
- Severity: `yellow`
- Recommended action: `Merge`
- Linear-ready: `True`
- Auto-resolved: `False`
- Reason: Multiple active work items target the same source file; merge or sequence ownership before implementation.
- Involved active paths:
  - `BATCH-33-intelligence-runtime-integration` — `docs/codex/batches/BATCH-33-intelligence-runtime-integration.md` (partial_implementation; release proof)
  - `MOAT-GOAL-REALITY-RUNTIME-SERVICE-03` — `prompts/batches/MOAT-GOAL-REALITY-RUNTIME-SERVICE-03.md` (partial_implementation; release proof)

### 153. Same source file targeted by multiple active items: Native/Ambitions/Domain/GoalRealityProofModels.swift

- Candidate ID: `AMB28-same_source_file_targeted_by_multiple_active_batches-44686547`
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

### 154. Same source file targeted by multiple active items: Native/Ambitions/Runtime/GoalRealityValidator.swift

- Candidate ID: `AMB28-same_source_file_targeted_by_multiple_active_batches-45339683`
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
  - `MOAT-GOAL-REALITY-RECEIPT-CLOSURE-07` — `prompts/batches/MOAT-GOAL-REALITY-RECEIPT-CLOSURE-07.md` (partial_implementation; release proof)
  - `MOAT-GOAL-REALITY-RUNTIME-SERVICE-03` — `prompts/batches/MOAT-GOAL-REALITY-RUNTIME-SERVICE-03.md` (partial_implementation; release proof)
  - `MOAT-GOAL-REALITY-SOURCE-PACKS-09` — `prompts/batches/MOAT-GOAL-REALITY-SOURCE-PACKS-09.md` (partial_implementation; release proof)

### 155. Same source file targeted by multiple active items: Native/Ambitions/Features/Today/TodayFeatureService.swift

- Candidate ID: `AMB28-same_source_file_targeted_by_multiple_active_batches-45952777`
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

### 156. Same source file targeted by multiple active items: scripts/ambitions-autonomous-train-fastpath.py

- Candidate ID: `AMB28-same_source_file_targeted_by_multiple_active_batches-46969410`
- Evidence type: `same_source_file_targeted_by_multiple_active_batches`
- Severity: `yellow`
- Recommended action: `Merge`
- Linear-ready: `True`
- Auto-resolved: `False`
- Reason: Multiple active work items target the same source file; merge or sequence ownership before implementation.
- Involved active paths:
  - `AUTONOMOUS_TRAIN_FASTPATH` — `docs/codex/AUTONOMOUS_TRAIN_FASTPATH.md` (partial_implementation; release proof)
  - `AUTONOMOUS-TRAIN-FASTPATH-01` — `prompts/batches/AUTONOMOUS-TRAIN-FASTPATH-01.md` (partial_implementation; release proof)

### 157. Same source file targeted by multiple active items: Native/Ambitions/Persistence/StorageSchemaVersionLedger.swift

- Candidate ID: `AMB28-same_source_file_targeted_by_multiple_active_batches-47254400`
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

### 158. Same source file targeted by multiple active items: scripts/ai/acx_build_triage.py

- Candidate ID: `AMB28-same_source_file_targeted_by_multiple_active_batches-47462598`
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

### 159. Same source file targeted by multiple active items: Native/Ambitions/Services/AmbitionsCommandExecutor.swift

- Candidate ID: `AMB28-same_source_file_targeted_by_multiple_active_batches-48574655`
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

### 160. Same source file targeted by multiple active items: scripts/ambitions-deriveddata-manager.sh

- Candidate ID: `AMB28-same_source_file_targeted_by_multiple_active_batches-48680103`
- Evidence type: `same_source_file_targeted_by_multiple_active_batches`
- Severity: `yellow`
- Recommended action: `Merge`
- Linear-ready: `True`
- Auto-resolved: `False`
- Reason: Multiple active work items target the same source file; merge or sequence ownership before implementation.
- Involved active paths:
  - `XCODE-PERF-RUNNER-MATURITY-01` — `prompts/batches/XCODE-PERF-RUNNER-MATURITY-01.md` (partial_implementation; release proof)
  - `XCODE_BUILD_LAB_PROTOCOL` — `docs/codex/XCODE_BUILD_LAB_PROTOCOL.md` (unknown; release proof)
  - `DERIVEDDATA_HYGIENE_PLAYBOOK` — `docs/codex/playbooks/DERIVEDDATA_HYGIENE_PLAYBOOK.md` (unknown; release proof)

### 161. Same source file targeted by multiple active items: scripts/sa-pack-duplication-scan.sh

- Candidate ID: `AMB28-same_source_file_targeted_by_multiple_active_batches-4880860`
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

### 162. Same source file targeted by multiple active items: Native/Ambitions/ExternalSnapshots/NextStepActivityAttributes.swift

- Candidate ID: `AMB28-same_source_file_targeted_by_multiple_active_batches-48850924`
- Evidence type: `same_source_file_targeted_by_multiple_active_batches`
- Severity: `yellow`
- Recommended action: `Merge`
- Linear-ready: `True`
- Auto-resolved: `False`
- Reason: Multiple active work items target the same source file; merge or sequence ownership before implementation.
- Involved active paths:
  - `PFC16_Live_Activities_Implementation_And_Tests_Prompt` — `docs/codex/batches/PFC16_Live_Activities_Implementation_And_Tests_Prompt.md` (partial_implementation; release proof)
  - `PK23` — `prompts/batches/PK23.md` (partial_implementation; release proof)

### 163. Same source file targeted by multiple active items: Native/AmbitionsTests/Persistence/PortableRestoreRollbackTests.swift

- Candidate ID: `AMB28-same_source_file_targeted_by_multiple_active_batches-49732070`
- Evidence type: `same_source_file_targeted_by_multiple_active_batches`
- Severity: `yellow`
- Recommended action: `Merge`
- Linear-ready: `True`
- Auto-resolved: `False`
- Reason: Multiple active work items target the same source file; merge or sequence ownership before implementation.
- Involved active paths:
  - `BACKEND-FINAL-FORM-LOCAL-FIRST-HUMAN-01` — `prompts/batches/BACKEND-FINAL-FORM-LOCAL-FIRST-HUMAN-01.md` (partial_implementation; release proof)
  - `MOAT-GOAL-REALITY-LOCAL-PERSISTENCE-08` — `prompts/batches/MOAT-GOAL-REALITY-LOCAL-PERSISTENCE-08.md` (partial_implementation; release proof)

### 164. Same source file targeted by multiple active items: scripts/ai/acx_impact.py

- Candidate ID: `AMB28-same_source_file_targeted_by_multiple_active_batches-50007329`
- Evidence type: `same_source_file_targeted_by_multiple_active_batches`
- Severity: `yellow`
- Recommended action: `Merge`
- Linear-ready: `True`
- Auto-resolved: `False`
- Reason: Multiple active work items target the same source file; merge or sequence ownership before implementation.
- Involved active paths:
  - `CODEX_OS_ENGINE_SUPPLEMENT_2026_05_08` — `docs/codex/CODEX_OS_ENGINE_SUPPLEMENT_2026_05_08.md` (partial_implementation; release proof)
  - `CODEX_OS_REPAIR_SPEED_PROOF_UPGRADE_AUDIT_2026_05_08` — `docs/codex/CODEX_OS_REPAIR_SPEED_PROOF_UPGRADE_AUDIT_2026_05_08.md` (partial_implementation; release proof)
  - `PK00_Current_Backend_Proof_Baseline` — `docs/codex/batches/PK00_Current_Backend_Proof_Baseline.md` (partial_implementation; release proof)
  - `PK01_Package_Module_Boundary_Scaffold` — `docs/codex/batches/PK01_Package_Module_Boundary_Scaffold.md` (partial_implementation; release proof)
  - `PK02_Architecture_Boundary_Scanner` — `docs/codex/batches/PK02_Architecture_Boundary_Scanner.md` (partial_implementation; release proof)
  - `CODEX_QUALITY_SYSTEM_SCRIPT_MAP` — `docs/codex/CODEX_QUALITY_SYSTEM_SCRIPT_MAP.md` (unknown; release proof)
  - `CODEX_SPEED_ENGINE` — `docs/codex/CODEX_SPEED_ENGINE.md` (unknown; release proof)

### 165. Same source file targeted by multiple active items: Native/Ambitions/App/AppNavigation.swift

- Candidate ID: `AMB28-same_source_file_targeted_by_multiple_active_batches-50504119`
- Evidence type: `same_source_file_targeted_by_multiple_active_batches`
- Severity: `yellow`
- Recommended action: `Merge`
- Linear-ready: `True`
- Auto-resolved: `False`
- Reason: Multiple active work items target the same source file; merge or sequence ownership before implementation.
- Involved active paths:
  - `repo-audit-baseline` — `docs/codex/repo-audit-baseline.md` (partial_implementation; release proof)
  - `existing-code-champion-coverage` — `docs/codex/existing-code-champion-coverage.yml` (unknown; release proof)

### 166. Same source file targeted by multiple active items: scripts/sa-composition-projection-scan.sh

- Candidate ID: `AMB28-same_source_file_targeted_by_multiple_active_batches-51529509`
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

### 167. Same source file targeted by multiple active items: Native/Ambitions/Domain/AmbitionsOSOptionValueModels.swift

- Candidate ID: `AMB28-same_source_file_targeted_by_multiple_active_batches-5175798`
- Evidence type: `same_source_file_targeted_by_multiple_active_batches`
- Severity: `yellow`
- Recommended action: `Merge`
- Linear-ready: `True`
- Auto-resolved: `False`
- Reason: Multiple active work items target the same source file; merge or sequence ownership before implementation.
- Involved active paths:
  - `AMBITIONSOS_AOS_TRACEABILITY_MATRIX` — `docs/codex/AMBITIONSOS_AOS_TRACEABILITY_MATRIX.md` (partial_implementation; release proof)
  - `existing-code-champion-coverage` — `docs/codex/existing-code-champion-coverage.yml` (unknown; release proof)

### 168. Same source file targeted by multiple active items: scripts/global-train-status-summary.sh

- Candidate ID: `AMB28-same_source_file_targeted_by_multiple_active_batches-5189057`
- Evidence type: `same_source_file_targeted_by_multiple_active_batches`
- Severity: `yellow`
- Recommended action: `Merge`
- Linear-ready: `True`
- Auto-resolved: `False`
- Reason: Multiple active work items target the same source file; merge or sequence ownership before implementation.
- Involved active paths:
  - `GLOBAL_PATCH_TRAIN_INTERRUPTED_RUN_RECOVERY_PROTOCOL` — `docs/codex/GLOBAL_PATCH_TRAIN_INTERRUPTED_RUN_RECOVERY_PROTOCOL.md` (partial_implementation; release proof)
  - `TIME_REPLACES_PLAN_COMPATIBILITY_LEDGER` — `docs/codex/TIME_REPLACES_PLAN_COMPATIBILITY_LEDGER.md` (partial_implementation; release proof)

### 169. Same source file targeted by multiple active items: scripts/dav-reduce-motion-check.sh

- Candidate ID: `AMB28-same_source_file_targeted_by_multiple_active_batches-52276327`
- Evidence type: `same_source_file_targeted_by_multiple_active_batches`
- Severity: `yellow`
- Recommended action: `Merge`
- Linear-ready: `True`
- Auto-resolved: `False`
- Reason: Multiple active work items target the same source file; merge or sequence ownership before implementation.
- Involved active paths:
  - `DAV02_Reusable_Living_Visual_Primitives_Implementation_Prompt` — `docs/codex/batches/DAV02_Reusable_Living_Visual_Primitives_Implementation_Prompt.md` (partial_implementation; release proof)
  - `DAV10_AdaptiveMotion_ReduceMotion_And_StateTransitions_Prompt` — `docs/codex/batches/DAV10_AdaptiveMotion_ReduceMotion_And_StateTransitions_Prompt.md` (partial_implementation; release proof)
  - `ACCESSIBILITY-DYNAMIC-TYPE-REDUCE-MOTION-PROOF-01` — `prompts/batches/ACCESSIBILITY-DYNAMIC-TYPE-REDUCE-MOTION-PROOF-01.md` (partial_implementation; release proof)

### 170. Same source file targeted by multiple active items: Native/Ambitions/Runtime/GoalRealityFixtureLab.swift

- Candidate ID: `AMB28-same_source_file_targeted_by_multiple_active_batches-52321411`
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
  - `MOAT-GOAL-REALITY-RUNTIME-SERVICE-03` — `prompts/batches/MOAT-GOAL-REALITY-RUNTIME-SERVICE-03.md` (partial_implementation; release proof)

### 171. Same source file targeted by multiple active items: Native/Ambitions/Domain/GoalEngine/GoalPathCompilerModels.swift

- Candidate ID: `AMB28-same_source_file_targeted_by_multiple_active_batches-52762975`
- Evidence type: `same_source_file_targeted_by_multiple_active_batches`
- Severity: `yellow`
- Recommended action: `Merge`
- Linear-ready: `True`
- Auto-resolved: `False`
- Reason: Multiple active work items target the same source file; merge or sequence ownership before implementation.
- Involved active paths:
  - `BATCH-24-path-compiler-foundation` — `docs/codex/batches/BATCH-24-path-compiler-foundation.md` (unknown; release proof)
  - `BATCH-25-domain-pack-framework` — `docs/codex/batches/BATCH-25-domain-pack-framework.md` (unknown; release proof)

### 172. Same source file targeted by multiple active items: scripts/ambitions_validate_batch_ids.py

- Candidate ID: `AMB28-same_source_file_targeted_by_multiple_active_batches-52782290`
- Evidence type: `same_source_file_targeted_by_multiple_active_batches`
- Severity: `yellow`
- Recommended action: `Merge`
- Linear-ready: `True`
- Auto-resolved: `False`
- Reason: Multiple active work items target the same source file; merge or sequence ownership before implementation.
- Involved active paths:
  - `AMB_CODEX_GOVERNANCE_SPEC` — `docs/codex/AMB_CODEX_GOVERNANCE_SPEC.md` (partial_implementation; release proof)
  - `AMB-FILE-BY-FILE-REPO-AUDIT-01` — `prompts/batches/AMB-FILE-BY-FILE-REPO-AUDIT-01.md` (partial_implementation; release proof)
  - `AMB-REPO-GREEN-FLAGSHIP-RESET-MASTER-01` — `prompts/batches/AMB-REPO-GREEN-FLAGSHIP-RESET-MASTER-01.md` (partial_implementation; release proof)

### 173. Same source file targeted by multiple active items: scripts/dav-visual-primitive-inventory.sh

- Candidate ID: `AMB28-same_source_file_targeted_by_multiple_active_batches-52881103`
- Evidence type: `same_source_file_targeted_by_multiple_active_batches`
- Severity: `yellow`
- Recommended action: `Merge`
- Linear-ready: `True`
- Auto-resolved: `False`
- Reason: Multiple active work items target the same source file; merge or sequence ownership before implementation.
- Involved active paths:
  - `DAV01_Dynamic_Visual_Source_Truth_And_Surface_Map_Prompt` — `docs/codex/batches/DAV01_Dynamic_Visual_Source_Truth_And_Surface_Map_Prompt.md` (partial_implementation; release proof)
  - `DAV02_Reusable_Living_Visual_Primitives_Implementation_Prompt` — `docs/codex/batches/DAV02_Reusable_Living_Visual_Primitives_Implementation_Prompt.md` (partial_implementation; release proof)

### 174. Same source file targeted by multiple active items: Native/AmbitionsWidgetExtension/NextStepWidget.swift

- Candidate ID: `AMB28-same_source_file_targeted_by_multiple_active_batches-5325357`
- Evidence type: `same_source_file_targeted_by_multiple_active_batches`
- Severity: `yellow`
- Recommended action: `Merge`
- Linear-ready: `True`
- Auto-resolved: `False`
- Reason: Multiple active work items target the same source file; merge or sequence ownership before implementation.
- Involved active paths:
  - `PFC14_WidgetKit_Implementation_And_Tests_Prompt` — `docs/codex/batches/PFC14_WidgetKit_Implementation_And_Tests_Prompt.md` (partial_implementation; release proof)
  - `AMB-REPO-AUTHORITY-00-SAFETY-SNAPSHOT` — `prompts/batches/AMB-REPO-AUTHORITY-00-SAFETY-SNAPSHOT.md` (partial_implementation; release proof)
  - `AMB-REPO-AUTHORITY-06-ACTIVE-DRIFT-REPAIR` — `prompts/batches/AMB-REPO-AUTHORITY-06-ACTIVE-DRIFT-REPAIR.md` (partial_implementation; release proof)
  - `PFC13_WidgetKit_Strategy_And_Object_Map_Prompt` — `docs/codex/batches/PFC13_WidgetKit_Strategy_And_Object_Map_Prompt.md` (unknown; release proof)

### 175. Same source file targeted by multiple active items: Native/Ambitions/Services/SmartAttachmentService.swift

- Candidate ID: `AMB28-same_source_file_targeted_by_multiple_active_batches-53970276`
- Evidence type: `same_source_file_targeted_by_multiple_active_batches`
- Severity: `yellow`
- Recommended action: `Merge`
- Linear-ready: `True`
- Auto-resolved: `False`
- Reason: Multiple active work items target the same source file; merge or sequence ownership before implementation.
- Involved active paths:
  - `TRAIN_04D_CAPTURE_RUNTIME_FACTORING_FUTURE_PROOF` — `prompts/trains/ios26-flagship/TRAIN_04D_CAPTURE_RUNTIME_FACTORING_FUTURE_PROOF.md` (partial_implementation; release proof)
  - `concept-lock-registry` — `docs/codex/concept-lock-registry.yml` (partial_implementation; tests)

### 176. Same source file targeted by multiple active items: Native/Ambitions/Domain/Planning/PlanningDomainModels.swift

- Candidate ID: `AMB28-same_source_file_targeted_by_multiple_active_batches-5404318`
- Evidence type: `same_source_file_targeted_by_multiple_active_batches`
- Severity: `yellow`
- Recommended action: `Merge`
- Linear-ready: `True`
- Auto-resolved: `False`
- Reason: Multiple active work items target the same source file; merge or sequence ownership before implementation.
- Involved active paths:
  - `PK21` — `prompts/batches/PK21.md` (partial_implementation; release proof)
  - `LDI15` — `prompts/batches/LDI15.md` (partial_implementation; release proof)

### 177. Same source file targeted by multiple active items: Native/Ambitions/Persistence/PortableSnapshotService.swift

- Candidate ID: `AMB28-same_source_file_targeted_by_multiple_active_batches-54469683`
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

### 178. Same source file targeted by multiple active items: Native/AmbitionsTests/Domain/SafeAutomationPolicyModelsTests.swift

- Candidate ID: `AMB28-same_source_file_targeted_by_multiple_active_batches-56279565`
- Evidence type: `same_source_file_targeted_by_multiple_active_batches`
- Severity: `yellow`
- Recommended action: `Merge`
- Linear-ready: `True`
- Auto-resolved: `False`
- Reason: Multiple active work items target the same source file; merge or sequence ownership before implementation.
- Involved active paths:
  - `PK22` — `prompts/batches/PK22.md` (partial_implementation; release proof)
  - `BACKEND-FINAL-FORM-LOCAL-FIRST-HUMAN-01` — `prompts/batches/BACKEND-FINAL-FORM-LOCAL-FIRST-HUMAN-01.md` (partial_implementation; release proof)

### 179. Same source file targeted by multiple active items: Native/Ambitions/Domain/SourceAtlasPackModels.swift

- Candidate ID: `AMB28-same_source_file_targeted_by_multiple_active_batches-57764906`
- Evidence type: `same_source_file_targeted_by_multiple_active_batches`
- Severity: `yellow`
- Recommended action: `Merge`
- Linear-ready: `True`
- Auto-resolved: `False`
- Reason: Multiple active work items target the same source file; merge or sequence ownership before implementation.
- Involved active paths:
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
  - ... 19 more

### 180. Same source file targeted by multiple active items: scripts/ios26-plan-freeze.py

- Candidate ID: `AMB28-same_source_file_targeted_by_multiple_active_batches-57922462`
- Evidence type: `same_source_file_targeted_by_multiple_active_batches`
- Severity: `yellow`
- Recommended action: `Merge`
- Linear-ready: `True`
- Auto-resolved: `False`
- Reason: Multiple active work items target the same source file; merge or sequence ownership before implementation.
- Involved active paths:
  - `IOS26_BATCH_MATRIX` — `docs/codex/ios26/IOS26_BATCH_MATRIX.yml` (partial_implementation; release proof)
  - `IOS26_DEPENDENCY_GRAPH` — `docs/codex/ios26/IOS26_DEPENDENCY_GRAPH.yml` (partial_implementation; source-only)

### 181. Same source file targeted by multiple active items: Native/Ambitions/Domain/AmbitionsOSCommitmentTimeModels.swift

- Candidate ID: `AMB28-same_source_file_targeted_by_multiple_active_batches-58060782`
- Evidence type: `same_source_file_targeted_by_multiple_active_batches`
- Severity: `yellow`
- Recommended action: `Merge`
- Linear-ready: `True`
- Auto-resolved: `False`
- Reason: Multiple active work items target the same source file; merge or sequence ownership before implementation.
- Involved active paths:
  - `AMBITIONSOS_AOS_TRACEABILITY_MATRIX` — `docs/codex/AMBITIONSOS_AOS_TRACEABILITY_MATRIX.md` (partial_implementation; release proof)
  - `existing-code-champion-coverage` — `docs/codex/existing-code-champion-coverage.yml` (unknown; release proof)

### 182. Same source file targeted by multiple active items: Native/Ambitions/Services/ExternalActionCommandService.swift

- Candidate ID: `AMB28-same_source_file_targeted_by_multiple_active_batches-58367660`
- Evidence type: `same_source_file_targeted_by_multiple_active_batches`
- Severity: `yellow`
- Recommended action: `Merge`
- Linear-ready: `True`
- Auto-resolved: `False`
- Reason: Multiple active work items target the same source file; merge or sequence ownership before implementation.
- Involved active paths:
  - `PFC18_App_Intents_Shortcuts_Implementation_And_Tests_Prompt` — `docs/codex/batches/PFC18_App_Intents_Shortcuts_Implementation_And_Tests_Prompt.md` (partial_implementation; release proof)
  - `PFC20_Notifications_Calendar_Reminders_Implementation_Proof_Prompt` — `docs/codex/batches/PFC20_Notifications_Calendar_Reminders_Implementation_Proof_Prompt.md` (partial_implementation; release proof)

### 183. Same source file targeted by multiple active items: scripts/openai-build-suite-validate.py

- Candidate ID: `AMB28-same_source_file_targeted_by_multiple_active_batches-58689366`
- Evidence type: `same_source_file_targeted_by_multiple_active_batches`
- Severity: `yellow`
- Recommended action: `Merge`
- Linear-ready: `True`
- Auto-resolved: `False`
- Reason: Multiple active work items target the same source file; merge or sequence ownership before implementation.
- Involved active paths:
  - `OBS00-OPENAI-BUILD-SUITE-INSTALL` — `prompts/batches/OBS00-OPENAI-BUILD-SUITE-INSTALL.md` (partial_implementation; release proof)
  - `OBS01-CODEX-MULTI-AGENT-BUILD-SYSTEM` — `prompts/batches/OBS01-CODEX-MULTI-AGENT-BUILD-SYSTEM.md` (partial_implementation; release proof)
  - `OBS02-REPO-INTELLIGENCE-LAYER` — `prompts/batches/OBS02-REPO-INTELLIGENCE-LAYER.md` (partial_implementation; release proof)
  - `OBS03-OPENAI-EVAL-QA-LAYER` — `prompts/batches/OBS03-OPENAI-EVAL-QA-LAYER.md` (partial_implementation; release proof)
  - `OBS06-SPEED-TRAIN-INTEGRATION` — `prompts/batches/OBS06-SPEED-TRAIN-INTEGRATION.md` (partial_implementation; release proof)
  - `CODEX_MULTI_AGENT_BUILD_SYSTEM` — `docs/codex/CODEX_MULTI_AGENT_BUILD_SYSTEM.md` (unknown; release proof)
  - `OPENAI_BUILD_SUITE_USAGE_POLICY` — `docs/codex/OPENAI_BUILD_SUITE_USAGE_POLICY.md` (unknown; release proof)

### 184. Same source file targeted by multiple active items: scripts/eb-no-unsupported-claim-scan.sh

- Candidate ID: `AMB28-same_source_file_targeted_by_multiple_active_batches-59029607`
- Evidence type: `same_source_file_targeted_by_multiple_active_batches`
- Severity: `yellow`
- Recommended action: `Merge`
- Linear-ready: `True`
- Auto-resolved: `False`
- Reason: Multiple active work items target the same source file; merge or sequence ownership before implementation.
- Involved active paths:
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
  - ... 30 more

### 185. Same source file targeted by multiple active items: Native/Ambitions/Domain/ActionClosureReceiptModels.swift

- Candidate ID: `AMB28-same_source_file_targeted_by_multiple_active_batches-59677121`
- Evidence type: `same_source_file_targeted_by_multiple_active_batches`
- Severity: `yellow`
- Recommended action: `Merge`
- Linear-ready: `True`
- Auto-resolved: `False`
- Reason: Multiple active work items target the same source file; merge or sequence ownership before implementation.
- Involved active paths:
  - `PK18` — `prompts/batches/PK18.md` (partial_implementation; release proof)
  - `LDI15` — `prompts/batches/LDI15.md` (partial_implementation; release proof)
  - `MOAT-GOAL-REALITY-RECEIPT-CLOSURE-07` — `prompts/batches/MOAT-GOAL-REALITY-RECEIPT-CLOSURE-07.md` (partial_implementation; release proof)
  - `existing-code-champion-coverage` — `docs/codex/existing-code-champion-coverage.yml` (unknown; release proof)

### 186. Same source file targeted by multiple active items: Native/Ambitions/Domain/AmbitionsOSLongevityModels.swift

- Candidate ID: `AMB28-same_source_file_targeted_by_multiple_active_batches-60889341`
- Evidence type: `same_source_file_targeted_by_multiple_active_batches`
- Severity: `yellow`
- Recommended action: `Merge`
- Linear-ready: `True`
- Auto-resolved: `False`
- Reason: Multiple active work items target the same source file; merge or sequence ownership before implementation.
- Involved active paths:
  - `AMBITIONSOS_AOS_TRACEABILITY_MATRIX` — `docs/codex/AMBITIONSOS_AOS_TRACEABILITY_MATRIX.md` (partial_implementation; release proof)
  - `AMBITIONSOS_AOS_PRIVACY_PROJECTION_LEDGER` — `docs/codex/AMBITIONSOS_AOS_PRIVACY_PROJECTION_LEDGER.md` (unknown; release proof)
  - `existing-code-champion-coverage` — `docs/codex/existing-code-champion-coverage.yml` (unknown; release proof)

### 187. Same source file targeted by multiple active items: Native/Ambitions/App/AppExternalRouting.swift

- Candidate ID: `AMB28-same_source_file_targeted_by_multiple_active_batches-61093423`
- Evidence type: `same_source_file_targeted_by_multiple_active_batches`
- Severity: `yellow`
- Recommended action: `Merge`
- Linear-ready: `True`
- Auto-resolved: `False`
- Reason: Multiple active work items target the same source file; merge or sequence ownership before implementation.
- Involved active paths:
  - `repo-audit-baseline` — `docs/codex/repo-audit-baseline.md` (partial_implementation; release proof)
  - `PFC18_App_Intents_Shortcuts_Implementation_And_Tests_Prompt` — `docs/codex/batches/PFC18_App_Intents_Shortcuts_Implementation_And_Tests_Prompt.md` (partial_implementation; release proof)
  - `existing-code-champion-coverage` — `docs/codex/existing-code-champion-coverage.yml` (unknown; release proof)

### 188. Same source file targeted by multiple active items: Native/Ambitions/Services/GoalContradictionService.swift

- Candidate ID: `AMB28-same_source_file_targeted_by_multiple_active_batches-61176019`
- Evidence type: `same_source_file_targeted_by_multiple_active_batches`
- Severity: `yellow`
- Recommended action: `Merge`
- Linear-ready: `True`
- Auto-resolved: `False`
- Reason: Multiple active work items target the same source file; merge or sequence ownership before implementation.
- Involved active paths:
  - `AMB-POST23-01-TRUTH-AUDIT` — `docs/codex/reports/AMB-POST23-01-TRUTH-AUDIT.md` (partial_implementation; release proof)
  - `BATCH-30-contradiction-engine` — `docs/codex/batches/BATCH-30-contradiction-engine.md` (unknown; release proof)

### 189. Same source file targeted by multiple active items: Native/AmbitionsTests/Persistence/PortableSnapshotServiceTests.swift

- Candidate ID: `AMB28-same_source_file_targeted_by_multiple_active_batches-61743002`
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

### 190. Same source file targeted by multiple active items: Native/Ambitions/Domain/AmbitionsOSRealityDriftModels.swift

- Candidate ID: `AMB28-same_source_file_targeted_by_multiple_active_batches-64778297`
- Evidence type: `same_source_file_targeted_by_multiple_active_batches`
- Severity: `yellow`
- Recommended action: `Merge`
- Linear-ready: `True`
- Auto-resolved: `False`
- Reason: Multiple active work items target the same source file; merge or sequence ownership before implementation.
- Involved active paths:
  - `AMBITIONSOS_AOS_TRACEABILITY_MATRIX` — `docs/codex/AMBITIONSOS_AOS_TRACEABILITY_MATRIX.md` (partial_implementation; release proof)
  - `existing-code-champion-coverage` — `docs/codex/existing-code-champion-coverage.yml` (unknown; release proof)

### 191. Same source file targeted by multiple active items: Native/AmbitionsTests/Runtime/GoalRealityCompilerCoreTests.swift

- Candidate ID: `AMB28-same_source_file_targeted_by_multiple_active_batches-65348645`
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

### 192. Same source file targeted by multiple active items: Native/Ambitions/Services/GoalUnderstandingService.swift

- Candidate ID: `AMB28-same_source_file_targeted_by_multiple_active_batches-65699806`
- Evidence type: `same_source_file_targeted_by_multiple_active_batches`
- Severity: `yellow`
- Recommended action: `Merge`
- Linear-ready: `True`
- Auto-resolved: `False`
- Reason: Multiple active work items target the same source file; merge or sequence ownership before implementation.
- Involved active paths:
  - `AMB-POST23-01-TRUTH-AUDIT` — `docs/codex/reports/AMB-POST23-01-TRUTH-AUDIT.md` (partial_implementation; release proof)
  - `BATCH-23-generalized-goal-understanding-contracts` — `docs/codex/batches/BATCH-23-generalized-goal-understanding-contracts.md` (unknown; release proof)

### 193. Same source file targeted by multiple active items: Native/Ambitions/Runtime/MoonshotProofPathRuntime.swift

- Candidate ID: `AMB28-same_source_file_targeted_by_multiple_active_batches-66070026`
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
  - `MOAT-UNIVERSAL-GOAL-REALITY-COMPILER-01` — `prompts/batches/MOAT-UNIVERSAL-GOAL-REALITY-COMPILER-01.md` (partial_implementation; release proof)

### 194. Same source file targeted by multiple active items: Native/Ambitions/Domain/AmbitionsOSGoalPathCompilerModels.swift

- Candidate ID: `AMB28-same_source_file_targeted_by_multiple_active_batches-66737508`
- Evidence type: `same_source_file_targeted_by_multiple_active_batches`
- Severity: `yellow`
- Recommended action: `Merge`
- Linear-ready: `True`
- Auto-resolved: `False`
- Reason: Multiple active work items target the same source file; merge or sequence ownership before implementation.
- Involved active paths:
  - `AMBITIONSOS_AOS_TRACEABILITY_MATRIX` — `docs/codex/AMBITIONSOS_AOS_TRACEABILITY_MATRIX.md` (partial_implementation; release proof)
  - `existing-code-champion-coverage` — `docs/codex/existing-code-champion-coverage.yml` (unknown; release proof)

### 195. Same source file targeted by multiple active items: Native/AmbitionsTests/Domain/AmbitionsOSEvaluationModelsTests.swift

- Candidate ID: `AMB28-same_source_file_targeted_by_multiple_active_batches-66812187`
- Evidence type: `same_source_file_targeted_by_multiple_active_batches`
- Severity: `yellow`
- Recommended action: `Merge`
- Linear-ready: `True`
- Auto-resolved: `False`
- Reason: Multiple active work items target the same source file; merge or sequence ownership before implementation.
- Involved active paths:
  - `AMBITIONSOS_AOS_PRIVACY_PROJECTION_LEDGER` — `docs/codex/AMBITIONSOS_AOS_PRIVACY_PROJECTION_LEDGER.md` (unknown; release proof)
  - `AMBITIONSOS_AOS_SOURCE_TRUTH_CLAIM_LEDGER` — `docs/codex/AMBITIONSOS_AOS_SOURCE_TRUTH_CLAIM_LEDGER.md` (unknown; release proof)

### 196. Same source file targeted by multiple active items: Native/Ambitions/Domain/AmbitionsOSEvaluationModels.swift

- Candidate ID: `AMB28-same_source_file_targeted_by_multiple_active_batches-66919976`
- Evidence type: `same_source_file_targeted_by_multiple_active_batches`
- Severity: `yellow`
- Recommended action: `Merge`
- Linear-ready: `True`
- Auto-resolved: `False`
- Reason: Multiple active work items target the same source file; merge or sequence ownership before implementation.
- Involved active paths:
  - `AMBITIONSOS_AOS_TRACEABILITY_MATRIX` — `docs/codex/AMBITIONSOS_AOS_TRACEABILITY_MATRIX.md` (partial_implementation; release proof)
  - `AMBITIONSOS_AOS_PRIVACY_PROJECTION_LEDGER` — `docs/codex/AMBITIONSOS_AOS_PRIVACY_PROJECTION_LEDGER.md` (unknown; release proof)
  - `AMBITIONSOS_AOS_SOURCE_TRUTH_CLAIM_LEDGER` — `docs/codex/AMBITIONSOS_AOS_SOURCE_TRUTH_CLAIM_LEDGER.md` (unknown; release proof)
  - `existing-code-champion-coverage` — `docs/codex/existing-code-champion-coverage.yml` (unknown; release proof)

### 197. Same source file targeted by multiple active items: Native/Ambitions/Persistence/SwiftDataRepositories.swift

- Candidate ID: `AMB28-same_source_file_targeted_by_multiple_active_batches-67639845`
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

### 198. Same source file targeted by multiple active items: Native/Ambitions/Persistence/LegacyImportService.swift

- Candidate ID: `AMB28-same_source_file_targeted_by_multiple_active_batches-67759420`
- Evidence type: `same_source_file_targeted_by_multiple_active_batches`
- Severity: `yellow`
- Recommended action: `Merge`
- Linear-ready: `True`
- Auto-resolved: `False`
- Reason: Multiple active work items target the same source file; merge or sequence ownership before implementation.
- Involved active paths:
  - `PFC07_Migration_Ladder_And_Backward_Compatibility_Tests_Prompt` — `docs/codex/batches/PFC07_Migration_Ladder_And_Backward_Compatibility_Tests_Prompt.md` (partial_implementation; release proof)
  - `PFC08_Corruption_Recovery_Backup_Restore_Plan_Prompt` — `docs/codex/batches/PFC08_Corruption_Recovery_Backup_Restore_Plan_Prompt.md` (unknown; release proof)

### 199. Same source file targeted by multiple active items: Native/Ambitions/Persistence/SyncCapabilityContracts.swift

- Candidate ID: `AMB28-same_source_file_targeted_by_multiple_active_batches-680518`
- Evidence type: `same_source_file_targeted_by_multiple_active_batches`
- Severity: `yellow`
- Recommended action: `Merge`
- Linear-ready: `True`
- Auto-resolved: `False`
- Reason: Multiple active work items target the same source file; merge or sequence ownership before implementation.
- Involved active paths:
  - `PFC07_Migration_Ladder_And_Backward_Compatibility_Tests_Prompt` — `docs/codex/batches/PFC07_Migration_Ladder_And_Backward_Compatibility_Tests_Prompt.md` (partial_implementation; release proof)
  - `PK30` — `prompts/batches/PK30.md` (partial_implementation; release proof)
  - `BACKEND-FINAL-FORM-LOCAL-FIRST-HUMAN-01` — `prompts/batches/BACKEND-FINAL-FORM-LOCAL-FIRST-HUMAN-01.md` (partial_implementation; release proof)
  - `PFC08_Corruption_Recovery_Backup_Restore_Plan_Prompt` — `docs/codex/batches/PFC08_Corruption_Recovery_Backup_Restore_Plan_Prompt.md` (unknown; release proof)

### 200. Same source file targeted by multiple active items: Native/AmbitionsTests/App/ExternalSurfaceSnapshotTests.swift

- Candidate ID: `AMB28-same_source_file_targeted_by_multiple_active_batches-69365704`
- Evidence type: `same_source_file_targeted_by_multiple_active_batches`
- Severity: `yellow`
- Recommended action: `Merge`
- Linear-ready: `True`
- Auto-resolved: `False`
- Reason: Multiple active work items target the same source file; merge or sequence ownership before implementation.
- Involved active paths:
  - `PFC14_WidgetKit_Implementation_And_Tests_Prompt` — `docs/codex/batches/PFC14_WidgetKit_Implementation_And_Tests_Prompt.md` (partial_implementation; release proof)
  - `PFC16_Live_Activities_Implementation_And_Tests_Prompt` — `docs/codex/batches/PFC16_Live_Activities_Implementation_And_Tests_Prompt.md` (partial_implementation; release proof)

### 201. Same source file targeted by multiple active items: scripts/ambitions-moat-drift-scan.py

- Candidate ID: `AMB28-same_source_file_targeted_by_multiple_active_batches-70215980`
- Evidence type: `same_source_file_targeted_by_multiple_active_batches`
- Severity: `yellow`
- Recommended action: `Merge`
- Linear-ready: `True`
- Auto-resolved: `False`
- Reason: Multiple active work items target the same source file; merge or sequence ownership before implementation.
- Involved active paths:
  - `AMB-REPO-AUTHORITY-06-ACTIVE-DRIFT-REPAIR` — `prompts/batches/AMB-REPO-AUTHORITY-06-ACTIVE-DRIFT-REPAIR.md` (partial_implementation; release proof)
  - `AMB-REPO-AUTHORITY-07-GATES-FINAL-PROOF` — `prompts/batches/AMB-REPO-AUTHORITY-07-GATES-FINAL-PROOF.md` (partial_implementation; release proof)

### 202. Same source file targeted by multiple active items: scripts/ambitions-bundle-next-batches.py

- Candidate ID: `AMB28-same_source_file_targeted_by_multiple_active_batches-71257573`
- Evidence type: `same_source_file_targeted_by_multiple_active_batches`
- Severity: `yellow`
- Recommended action: `Merge`
- Linear-ready: `True`
- Auto-resolved: `False`
- Reason: Multiple active work items target the same source file; merge or sequence ownership before implementation.
- Involved active paths:
  - `POST_PK_BATCH_BUNDLES` — `docs/codex/POST_PK_BATCH_BUNDLES.md` (unknown; release proof)
  - `POST_PK_SPEED_TRAIN_OPERATING_MODEL` — `docs/codex/POST_PK_SPEED_TRAIN_OPERATING_MODEL.md` (unknown; release proof)

### 203. Same source file targeted by multiple active items: Native/Ambitions/Domain/AmbitionsOSLivingDreamSourceClaimGraphModels.swift

- Candidate ID: `AMB28-same_source_file_targeted_by_multiple_active_batches-71609911`
- Evidence type: `same_source_file_targeted_by_multiple_active_batches`
- Severity: `yellow`
- Recommended action: `Merge`
- Linear-ready: `True`
- Auto-resolved: `False`
- Reason: Multiple active work items target the same source file; merge or sequence ownership before implementation.
- Involved active paths:
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
  - ... 20 more

### 204. Same source file targeted by multiple active items: Native/Ambitions/Services/KnowledgeIngestionService.swift

- Candidate ID: `AMB28-same_source_file_targeted_by_multiple_active_batches-71913104`
- Evidence type: `same_source_file_targeted_by_multiple_active_batches`
- Severity: `yellow`
- Recommended action: `Merge`
- Linear-ready: `True`
- Auto-resolved: `False`
- Reason: Multiple active work items target the same source file; merge or sequence ownership before implementation.
- Involved active paths:
  - `AMB-POST23-01-TRUTH-AUDIT` — `docs/codex/reports/AMB-POST23-01-TRUTH-AUDIT.md` (partial_implementation; release proof)
  - `BATCH-21-external-knowledge-ingestion-core` — `docs/codex/batches/BATCH-21-external-knowledge-ingestion-core.md` (unknown; release proof)

### 205. Same source file targeted by multiple active items: Native/Ambitions/Domain/AmbitionsOSLivingDreamCapacityBridgeModels.swift

- Candidate ID: `AMB28-same_source_file_targeted_by_multiple_active_batches-71981989`
- Evidence type: `same_source_file_targeted_by_multiple_active_batches`
- Severity: `yellow`
- Recommended action: `Merge`
- Linear-ready: `True`
- Auto-resolved: `False`
- Reason: Multiple active work items target the same source file; merge or sequence ownership before implementation.
- Involved active paths:
  - `MOAT-MOONSHOT-BACKEND-FULL-TRAIN-01` — `prompts/batches/MOAT-MOONSHOT-BACKEND-FULL-TRAIN-01.md` (partial_implementation; release proof)
  - `MOAT-MOONSHOT-PROOF-PATH-01` — `prompts/batches/MOAT-MOONSHOT-PROOF-PATH-01.md` (partial_implementation; release proof)
  - `MOAT-UNIVERSAL-GOAL-REALITY-COMPILER-01` — `prompts/batches/MOAT-UNIVERSAL-GOAL-REALITY-COMPILER-01.md` (partial_implementation; release proof)
  - `existing-code-champion-coverage` — `docs/codex/existing-code-champion-coverage.yml` (unknown; release proof)

### 206. Same source file targeted by multiple active items: Native/Ambitions/Runtime/AmbitionsRuntimeContracts.swift

- Candidate ID: `AMB28-same_source_file_targeted_by_multiple_active_batches-72339105`
- Evidence type: `same_source_file_targeted_by_multiple_active_batches`
- Severity: `yellow`
- Recommended action: `Merge`
- Linear-ready: `True`
- Auto-resolved: `False`
- Reason: Multiple active work items target the same source file; merge or sequence ownership before implementation.
- Involved active paths:
  - `BATCH-33-intelligence-runtime-integration` — `docs/codex/batches/BATCH-33-intelligence-runtime-integration.md` (partial_implementation; release proof)
  - `MOONSHOT_PROOF_PATH_BACKEND_MASTER_PLAN` — `docs/codex/MOONSHOT_PROOF_PATH_BACKEND_MASTER_PLAN.md` (partial_implementation; release proof)
  - `MOAT-MOONSHOT-BACKEND-FULL-TRAIN-01` — `prompts/batches/MOAT-MOONSHOT-BACKEND-FULL-TRAIN-01.md` (partial_implementation; release proof)
  - `MOAT-MOONSHOT-PROOF-PATH-01` — `prompts/batches/MOAT-MOONSHOT-PROOF-PATH-01.md` (partial_implementation; release proof)
  - `MOAT-UNIVERSAL-GOAL-REALITY-COMPILER-01` — `prompts/batches/MOAT-UNIVERSAL-GOAL-REALITY-COMPILER-01.md` (partial_implementation; release proof)
  - `MOAT-GOAL-REALITY-RUNTIME-SERVICE-03` — `prompts/batches/MOAT-GOAL-REALITY-RUNTIME-SERVICE-03.md` (partial_implementation; release proof)

### 207. Same source file targeted by multiple active items: scripts/sa-projection-fixture-coverage-scan.sh

- Candidate ID: `AMB28-same_source_file_targeted_by_multiple_active_batches-728255`
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

### 208. Same source file targeted by multiple active items: scripts/ambitions-next-batch-router.py

- Candidate ID: `AMB28-same_source_file_targeted_by_multiple_active_batches-73111064`
- Evidence type: `same_source_file_targeted_by_multiple_active_batches`
- Severity: `yellow`
- Recommended action: `Merge`
- Linear-ready: `True`
- Auto-resolved: `False`
- Reason: Multiple active work items target the same source file; merge or sequence ownership before implementation.
- Involved active paths:
  - `AUTONOMOUS_TRAIN_FASTPATH` — `docs/codex/AUTONOMOUS_TRAIN_FASTPATH.md` (partial_implementation; release proof)
  - `AUTONOMOUS-TRAIN-FASTPATH-01` — `prompts/batches/AUTONOMOUS-TRAIN-FASTPATH-01.md` (partial_implementation; release proof)

### 209. Same source file targeted by multiple active items: Native/Ambitions/Domain/AmbitionsOSLocalLanguageModels.swift

- Candidate ID: `AMB28-same_source_file_targeted_by_multiple_active_batches-73170763`
- Evidence type: `same_source_file_targeted_by_multiple_active_batches`
- Severity: `yellow`
- Recommended action: `Merge`
- Linear-ready: `True`
- Auto-resolved: `False`
- Reason: Multiple active work items target the same source file; merge or sequence ownership before implementation.
- Involved active paths:
  - `AMBITIONSOS_AOS_TRACEABILITY_MATRIX` — `docs/codex/AMBITIONSOS_AOS_TRACEABILITY_MATRIX.md` (partial_implementation; release proof)
  - `existing-code-champion-coverage` — `docs/codex/existing-code-champion-coverage.yml` (unknown; release proof)

### 210. Same source file targeted by multiple active items: scripts/ambitions_validate_visual_proof.py

- Candidate ID: `AMB28-same_source_file_targeted_by_multiple_active_batches-7324153`
- Evidence type: `same_source_file_targeted_by_multiple_active_batches`
- Severity: `yellow`
- Recommended action: `Merge`
- Linear-ready: `True`
- Auto-resolved: `False`
- Reason: Multiple active work items target the same source file; merge or sequence ownership before implementation.
- Involved active paths:
  - `POST_BATCH_GATE_REGISTRY` — `docs/codex/POST_BATCH_GATE_REGISTRY.md` (partial_implementation; release proof)
  - `AMB_CODEX_GOVERNANCE_SPEC` — `docs/codex/AMB_CODEX_GOVERNANCE_SPEC.md` (partial_implementation; release proof)

### 211. Same source file targeted by multiple active items: scripts/ambitions-advance-batch-state.py

- Candidate ID: `AMB28-same_source_file_targeted_by_multiple_active_batches-73627538`
- Evidence type: `same_source_file_targeted_by_multiple_active_batches`
- Severity: `yellow`
- Recommended action: `Merge`
- Linear-ready: `True`
- Auto-resolved: `False`
- Reason: Multiple active work items target the same source file; merge or sequence ownership before implementation.
- Involved active paths:
  - `POST_PK_CLOSEOUT_CONTRACT` — `docs/codex/POST_PK_CLOSEOUT_CONTRACT.md` (partial_implementation; release proof)
  - `POST_PK_SPEED_TRAIN_OPERATING_MODEL` — `docs/codex/POST_PK_SPEED_TRAIN_OPERATING_MODEL.md` (unknown; release proof)

### 212. Same source file targeted by multiple active items: Native/Ambitions/Runtime/AmbitionsRuntimeGoalIntelligence.swift

- Candidate ID: `AMB28-same_source_file_targeted_by_multiple_active_batches-73653090`
- Evidence type: `same_source_file_targeted_by_multiple_active_batches`
- Severity: `yellow`
- Recommended action: `Merge`
- Linear-ready: `True`
- Auto-resolved: `False`
- Reason: Multiple active work items target the same source file; merge or sequence ownership before implementation.
- Involved active paths:
  - `BATCH-33-intelligence-runtime-integration` — `docs/codex/batches/BATCH-33-intelligence-runtime-integration.md` (partial_implementation; release proof)
  - `MOONSHOT_PROOF_PATH_BACKEND_MASTER_PLAN` — `docs/codex/MOONSHOT_PROOF_PATH_BACKEND_MASTER_PLAN.md` (partial_implementation; release proof)
  - `MOAT-MOONSHOT-BACKEND-FULL-TRAIN-01` — `prompts/batches/MOAT-MOONSHOT-BACKEND-FULL-TRAIN-01.md` (partial_implementation; release proof)
  - `MOAT-MOONSHOT-PROOF-PATH-01` — `prompts/batches/MOAT-MOONSHOT-PROOF-PATH-01.md` (partial_implementation; release proof)
  - `MOAT-UNIVERSAL-GOAL-REALITY-COMPILER-01` — `prompts/batches/MOAT-UNIVERSAL-GOAL-REALITY-COMPILER-01.md` (partial_implementation; release proof)
  - `MOAT-GOAL-REALITY-RUNTIME-SERVICE-03` — `prompts/batches/MOAT-GOAL-REALITY-RUNTIME-SERVICE-03.md` (partial_implementation; release proof)

### 213. Same source file targeted by multiple active items: Native/Ambitions/Domain/AmbitionsOSControlPlaneModels.swift

- Candidate ID: `AMB28-same_source_file_targeted_by_multiple_active_batches-74170203`
- Evidence type: `same_source_file_targeted_by_multiple_active_batches`
- Severity: `yellow`
- Recommended action: `Merge`
- Linear-ready: `True`
- Auto-resolved: `False`
- Reason: Multiple active work items target the same source file; merge or sequence ownership before implementation.
- Involved active paths:
  - `AMBITIONSOS_AOS_TRACEABILITY_MATRIX` — `docs/codex/AMBITIONSOS_AOS_TRACEABILITY_MATRIX.md` (partial_implementation; release proof)
  - `existing-code-champion-coverage` — `docs/codex/existing-code-champion-coverage.yml` (unknown; release proof)

### 214. Same source file targeted by multiple active items: Native/AmbitionsTests/Persistence/EventLedgerRepositoryTests.swift

- Candidate ID: `AMB28-same_source_file_targeted_by_multiple_active_batches-74207161`
- Evidence type: `same_source_file_targeted_by_multiple_active_batches`
- Severity: `yellow`
- Recommended action: `Merge`
- Linear-ready: `True`
- Auto-resolved: `False`
- Reason: Multiple active work items target the same source file; merge or sequence ownership before implementation.
- Involved active paths:
  - `PK22` — `prompts/batches/PK22.md` (partial_implementation; release proof)
  - `BACKEND-FINAL-FORM-LOCAL-FIRST-HUMAN-01` — `prompts/batches/BACKEND-FINAL-FORM-LOCAL-FIRST-HUMAN-01.md` (partial_implementation; release proof)

### 215. Same source file targeted by multiple active items: scripts/ambitions-parallel-implementation-guard.py

- Candidate ID: `AMB28-same_source_file_targeted_by_multiple_active_batches-75084707`
- Evidence type: `same_source_file_targeted_by_multiple_active_batches`
- Severity: `yellow`
- Recommended action: `Merge`
- Linear-ready: `True`
- Auto-resolved: `False`
- Reason: Multiple active work items target the same source file; merge or sequence ownership before implementation.
- Involved active paths:
  - `AMB-INTELLIGENCE-CONSOLIDATION-CHAMPION-MERGE-PLAN-02` — `prompts/batches/AMB-INTELLIGENCE-CONSOLIDATION-CHAMPION-MERGE-PLAN-02.md` (partial_implementation; release proof)
  - `AMB-INTELLIGENCE-CONSOLIDATION-CHAMPION-SELECTION-01` — `prompts/batches/AMB-INTELLIGENCE-CONSOLIDATION-CHAMPION-SELECTION-01.md` (partial_implementation; release proof)

### 216. Same source file targeted by multiple active items: scripts/ambitions-xcode-sim-health.sh

- Candidate ID: `AMB28-same_source_file_targeted_by_multiple_active_batches-759262`
- Evidence type: `same_source_file_targeted_by_multiple_active_batches`
- Severity: `yellow`
- Recommended action: `Merge`
- Linear-ready: `True`
- Auto-resolved: `False`
- Reason: Multiple active work items target the same source file; merge or sequence ownership before implementation.
- Involved active paths:
  - `XCODE-PERF-RUNNER-MATURITY-01` — `prompts/batches/XCODE-PERF-RUNNER-MATURITY-01.md` (partial_implementation; release proof)
  - `XCODE_BUILD_LAB_PROTOCOL` — `docs/codex/XCODE_BUILD_LAB_PROTOCOL.md` (unknown; release proof)
  - `XCODE_SICK_SIMULATOR_PLAYBOOK` — `docs/codex/playbooks/XCODE_SICK_SIMULATOR_PLAYBOOK.md` (unknown; release proof)

### 217. Same source file targeted by multiple active items: scripts/sa-research-seeds-integrity-scan.sh

- Candidate ID: `AMB28-same_source_file_targeted_by_multiple_active_batches-78971988`
- Evidence type: `same_source_file_targeted_by_multiple_active_batches`
- Severity: `yellow`
- Recommended action: `Merge`
- Linear-ready: `True`
- Auto-resolved: `False`
- Reason: Multiple active work items target the same source file; merge or sequence ownership before implementation.
- Involved active paths:
  - `GATE_SYSTEM_HARDENING_NEXT_PROMPT` — `docs/codex/batches/GATE_SYSTEM_HARDENING_NEXT_PROMPT.md` (partial_implementation; release proof)
  - `SOURCE_ATLAS_RESEARCH_SEEDS_V1_IMPORT_REPORT` — `docs/codex/SOURCE_ATLAS_RESEARCH_SEEDS_V1_IMPORT_REPORT.md` (unknown; release proof)
  - `SOURCE_ATLAS_RESEARCH_SEEDS_V1_IMPORT_PROMPT` — `docs/codex/batches/SOURCE_ATLAS_RESEARCH_SEEDS_V1_IMPORT_PROMPT.md` (unknown; release proof)

### 218. Same source file targeted by multiple active items: Native/Ambitions/ExternalSnapshots/ExternalWidgetProjection.swift

- Candidate ID: `AMB28-same_source_file_targeted_by_multiple_active_batches-8002601`
- Evidence type: `same_source_file_targeted_by_multiple_active_batches`
- Severity: `yellow`
- Recommended action: `Merge`
- Linear-ready: `True`
- Auto-resolved: `False`
- Reason: Multiple active work items target the same source file; merge or sequence ownership before implementation.
- Involved active paths:
  - `PFC14_WidgetKit_Implementation_And_Tests_Prompt` — `docs/codex/batches/PFC14_WidgetKit_Implementation_And_Tests_Prompt.md` (partial_implementation; release proof)
  - `PFC13_WidgetKit_Strategy_And_Object_Map_Prompt` — `docs/codex/batches/PFC13_WidgetKit_Strategy_And_Object_Map_Prompt.md` (unknown; release proof)

### 219. Same source file targeted by multiple active items: Native/AmbitionsTests/Persistence/PreMigrationBackupTests.swift

- Candidate ID: `AMB28-same_source_file_targeted_by_multiple_active_batches-81828634`
- Evidence type: `same_source_file_targeted_by_multiple_active_batches`
- Severity: `yellow`
- Recommended action: `Merge`
- Linear-ready: `True`
- Auto-resolved: `False`
- Reason: Multiple active work items target the same source file; merge or sequence ownership before implementation.
- Involved active paths:
  - `BACKEND-FINAL-FORM-LOCAL-FIRST-HUMAN-01` — `prompts/batches/BACKEND-FINAL-FORM-LOCAL-FIRST-HUMAN-01.md` (partial_implementation; release proof)
  - `MOAT-GOAL-REALITY-LOCAL-PERSISTENCE-08` — `prompts/batches/MOAT-GOAL-REALITY-LOCAL-PERSISTENCE-08.md` (partial_implementation; release proof)

### 220. Same source file targeted by multiple active items: scripts/ambitions-authority-supersession-check.py

- Candidate ID: `AMB28-same_source_file_targeted_by_multiple_active_batches-82673004`
- Evidence type: `same_source_file_targeted_by_multiple_active_batches`
- Severity: `yellow`
- Recommended action: `Merge`
- Linear-ready: `True`
- Auto-resolved: `False`
- Reason: Multiple active work items target the same source file; merge or sequence ownership before implementation.
- Involved active paths:
  - `AMB-REPO-AUTHORITY-06-ACTIVE-DRIFT-REPAIR` — `prompts/batches/AMB-REPO-AUTHORITY-06-ACTIVE-DRIFT-REPAIR.md` (partial_implementation; release proof)
  - `AMB-REPO-AUTHORITY-07-GATES-FINAL-PROOF` — `prompts/batches/AMB-REPO-AUTHORITY-07-GATES-FINAL-PROOF.md` (partial_implementation; release proof)

### 221. Same source file targeted by multiple active items: Native/AmbitionsTests/Persistence/SyncCapabilityTests.swift

- Candidate ID: `AMB28-same_source_file_targeted_by_multiple_active_batches-82690549`
- Evidence type: `same_source_file_targeted_by_multiple_active_batches`
- Severity: `yellow`
- Recommended action: `Merge`
- Linear-ready: `True`
- Auto-resolved: `False`
- Reason: Multiple active work items target the same source file; merge or sequence ownership before implementation.
- Involved active paths:
  - `PFC07_Migration_Ladder_And_Backward_Compatibility_Tests_Prompt` — `docs/codex/batches/PFC07_Migration_Ladder_And_Backward_Compatibility_Tests_Prompt.md` (partial_implementation; release proof)
  - `BACKEND-FINAL-FORM-LOCAL-FIRST-HUMAN-01` — `prompts/batches/BACKEND-FINAL-FORM-LOCAL-FIRST-HUMAN-01.md` (partial_implementation; release proof)

### 222. Same source file targeted by multiple active items: Native/AmbitionsTests/App/ExternalWidgetProjectionTests.swift

- Candidate ID: `AMB28-same_source_file_targeted_by_multiple_active_batches-82940118`
- Evidence type: `same_source_file_targeted_by_multiple_active_batches`
- Severity: `yellow`
- Recommended action: `Merge`
- Linear-ready: `True`
- Auto-resolved: `False`
- Reason: Multiple active work items target the same source file; merge or sequence ownership before implementation.
- Involved active paths:
  - `PFC14_WidgetKit_Implementation_And_Tests_Prompt` — `docs/codex/batches/PFC14_WidgetKit_Implementation_And_Tests_Prompt.md` (partial_implementation; release proof)
  - `PFC13_WidgetKit_Strategy_And_Object_Map_Prompt` — `docs/codex/batches/PFC13_WidgetKit_Strategy_And_Object_Map_Prompt.md` (unknown; release proof)

### 223. Same source file targeted by multiple active items: scripts/ambitions-xcode-benchmark.sh

- Candidate ID: `AMB28-same_source_file_targeted_by_multiple_active_batches-837459`
- Evidence type: `same_source_file_targeted_by_multiple_active_batches`
- Severity: `yellow`
- Recommended action: `Merge`
- Linear-ready: `True`
- Auto-resolved: `False`
- Reason: Multiple active work items target the same source file; merge or sequence ownership before implementation.
- Involved active paths:
  - `XCODE-PERF-RUNNER-MATURITY-01` — `prompts/batches/XCODE-PERF-RUNNER-MATURITY-01.md` (partial_implementation; release proof)
  - `XCODE_BUILD_LAB_PROTOCOL` — `docs/codex/XCODE_BUILD_LAB_PROTOCOL.md` (unknown; release proof)
  - `SPEED_TRAIN_LANE_POLICY` — `docs/codex/SPEED_TRAIN_LANE_POLICY.json` (unknown; release proof)
  - `SPEED_TRAIN_QUICKSTART` — `docs/codex/SPEED_TRAIN_QUICKSTART.md` (unknown; release proof)

### 224. Same source file targeted by multiple active items: scripts/cqs-preview-coverage-scan.sh

- Candidate ID: `AMB28-same_source_file_targeted_by_multiple_active_batches-84772233`
- Evidence type: `same_source_file_targeted_by_multiple_active_batches`
- Severity: `yellow`
- Recommended action: `Merge`
- Linear-ready: `True`
- Auto-resolved: `False`
- Reason: Multiple active work items target the same source file; merge or sequence ownership before implementation.
- Involved active paths:
  - `CQS01_CQS24_CODEX_QUALITY_SYSTEM_TRAIN` — `docs/codex/batch-trains/CQS01_CQS24_CODEX_QUALITY_SYSTEM_TRAIN.md` (partial_implementation; release proof)
  - `CODEX_QUALITY_SYSTEM_SCRIPT_MAP` — `docs/codex/CODEX_QUALITY_SYSTEM_SCRIPT_MAP.md` (unknown; release proof)

### 225. Same source file targeted by multiple active items: Native/AmbitionsTests/Domain/AmbitionsOSPrivacySafetyModelsTests.swift

- Candidate ID: `AMB28-same_source_file_targeted_by_multiple_active_batches-85145527`
- Evidence type: `same_source_file_targeted_by_multiple_active_batches`
- Severity: `yellow`
- Recommended action: `Merge`
- Linear-ready: `True`
- Auto-resolved: `False`
- Reason: Multiple active work items target the same source file; merge or sequence ownership before implementation.
- Involved active paths:
  - `AMBITIONSOS_AOS_PRIVACY_PROJECTION_LEDGER` — `docs/codex/AMBITIONSOS_AOS_PRIVACY_PROJECTION_LEDGER.md` (unknown; release proof)
  - `AMBITIONSOS_AOS_SOURCE_TRUTH_CLAIM_LEDGER` — `docs/codex/AMBITIONSOS_AOS_SOURCE_TRUTH_CLAIM_LEDGER.md` (unknown; release proof)

### 226. Same source file targeted by multiple active items: scripts/ambitions-post-pk-speed-train.sh

- Candidate ID: `AMB28-same_source_file_targeted_by_multiple_active_batches-85363527`
- Evidence type: `same_source_file_targeted_by_multiple_active_batches`
- Severity: `yellow`
- Recommended action: `Merge`
- Linear-ready: `True`
- Auto-resolved: `False`
- Reason: Multiple active work items target the same source file; merge or sequence ownership before implementation.
- Involved active paths:
  - `MOAT_RUNTIME_AUTONOMOUS_ROUTING_POLICY` — `docs/codex/MOAT_RUNTIME_AUTONOMOUS_ROUTING_POLICY.md` (unknown; release proof)
  - `POST_PK_SPEED_TRAIN_OPERATING_MODEL` — `docs/codex/POST_PK_SPEED_TRAIN_OPERATING_MODEL.md` (unknown; release proof)

### 227. Same source file targeted by multiple active items: scripts/ai/acx_local.py

- Candidate ID: `AMB28-same_source_file_targeted_by_multiple_active_batches-86403610`
- Evidence type: `same_source_file_targeted_by_multiple_active_batches`
- Severity: `yellow`
- Recommended action: `Merge`
- Linear-ready: `True`
- Auto-resolved: `False`
- Reason: Multiple active work items target the same source file; merge or sequence ownership before implementation.
- Involved active paths:
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

### 228. Same source file targeted by multiple active items: scripts/ambitions-codex-train.sh

- Candidate ID: `AMB28-same_source_file_targeted_by_multiple_active_batches-86410496`
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
  - ... 288 more

### 229. Same source file targeted by multiple active items: scripts/ambitions-xcode-build-for-testing.sh

- Candidate ID: `AMB28-same_source_file_targeted_by_multiple_active_batches-86906656`
- Evidence type: `same_source_file_targeted_by_multiple_active_batches`
- Severity: `yellow`
- Recommended action: `Merge`
- Linear-ready: `True`
- Auto-resolved: `False`
- Reason: Multiple active work items target the same source file; merge or sequence ownership before implementation.
- Involved active paths:
  - `XCODE-BUILD-SYSTEM-MAX-01-REPAIR-01` — `prompts/batches/XCODE-BUILD-SYSTEM-MAX-01-REPAIR-01.md` (partial_implementation; release proof)
  - `XCODE-PERF-RUNNER-MATURITY-01` — `prompts/batches/XCODE-PERF-RUNNER-MATURITY-01.md` (partial_implementation; release proof)

### 230. Same source file targeted by multiple active items: scripts/ambitions-closeout-coalesce.py

- Candidate ID: `AMB28-same_source_file_targeted_by_multiple_active_batches-88067432`
- Evidence type: `same_source_file_targeted_by_multiple_active_batches`
- Severity: `yellow`
- Recommended action: `Merge`
- Linear-ready: `True`
- Auto-resolved: `False`
- Reason: Multiple active work items target the same source file; merge or sequence ownership before implementation.
- Involved active paths:
  - `POST_PK_CLOSEOUT_CONTRACT` — `docs/codex/POST_PK_CLOSEOUT_CONTRACT.md` (partial_implementation; release proof)
  - `POST_PK_SPEED_TRAIN_OPERATING_MODEL` — `docs/codex/POST_PK_SPEED_TRAIN_OPERATING_MODEL.md` (unknown; release proof)

### 231. Same source file targeted by multiple active items: Native/Ambitions/Domain/GoalRealityReceiptModels.swift

- Candidate ID: `AMB28-same_source_file_targeted_by_multiple_active_batches-8855702`
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

### 232. Same source file targeted by multiple active items: Native/Ambitions/Features/Time/TimeScreen.swift

- Candidate ID: `AMB28-same_source_file_targeted_by_multiple_active_batches-88902023`
- Evidence type: `same_source_file_targeted_by_multiple_active_batches`
- Severity: `yellow`
- Recommended action: `Merge`
- Linear-ready: `True`
- Auto-resolved: `False`
- Reason: Multiple active work items target the same source file; merge or sequence ownership before implementation.
- Involved active paths:
  - `ALIGN-01-NAMING` — `prompts/batches/ALIGN-01-NAMING.md` (partial_implementation; release proof)
  - `AMB-POST23-01-TRUTH-AUDIT` — `docs/codex/reports/AMB-POST23-01-TRUTH-AUDIT.md` (partial_implementation; release proof)

### 233. Same source file targeted by multiple active items: Native/Ambitions/Domain/AmbitionsOSLivingDreamPathPortfolioModels.swift

- Candidate ID: `AMB28-same_source_file_targeted_by_multiple_active_batches-89129757`
- Evidence type: `same_source_file_targeted_by_multiple_active_batches`
- Severity: `yellow`
- Recommended action: `Merge`
- Linear-ready: `True`
- Auto-resolved: `False`
- Reason: Multiple active work items target the same source file; merge or sequence ownership before implementation.
- Involved active paths:
  - `MOAT-MOONSHOT-BACKEND-FULL-TRAIN-01` — `prompts/batches/MOAT-MOONSHOT-BACKEND-FULL-TRAIN-01.md` (partial_implementation; release proof)
  - `MOAT-MOONSHOT-PROOF-PATH-01` — `prompts/batches/MOAT-MOONSHOT-PROOF-PATH-01.md` (partial_implementation; release proof)
  - `MOAT-UNIVERSAL-GOAL-REALITY-COMPILER-01` — `prompts/batches/MOAT-UNIVERSAL-GOAL-REALITY-COMPILER-01.md` (partial_implementation; release proof)
  - `MOAT-GOAL-REALITY-SOURCE-PACKS-09` — `prompts/batches/MOAT-GOAL-REALITY-SOURCE-PACKS-09.md` (partial_implementation; release proof)
  - `existing-code-champion-coverage` — `docs/codex/existing-code-champion-coverage.yml` (unknown; release proof)

### 234. Same source file targeted by multiple active items: Native/Ambitions/Integrations/CalendarReminders/EventKitIntegrationService.swift

- Candidate ID: `AMB28-same_source_file_targeted_by_multiple_active_batches-89150564`
- Evidence type: `same_source_file_targeted_by_multiple_active_batches`
- Severity: `yellow`
- Recommended action: `Merge`
- Linear-ready: `True`
- Auto-resolved: `False`
- Reason: Multiple active work items target the same source file; merge or sequence ownership before implementation.
- Involved active paths:
  - `PFC20_Notifications_Calendar_Reminders_Implementation_Proof_Prompt` — `docs/codex/batches/PFC20_Notifications_Calendar_Reminders_Implementation_Proof_Prompt.md` (partial_implementation; release proof)
  - `PK24` — `prompts/batches/PK24.md` (partial_implementation; release proof)

### 235. Same source file targeted by multiple active items: Native/Ambitions/Domain/AmbitionsOSSourceTruthModels.swift

- Candidate ID: `AMB28-same_source_file_targeted_by_multiple_active_batches-89238597`
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

### 236. Same source file targeted by multiple active items: Native/Ambitions/Support/ReleasePerformanceResponsivenessReport.swift

- Candidate ID: `AMB28-same_source_file_targeted_by_multiple_active_batches-89294029`
- Evidence type: `same_source_file_targeted_by_multiple_active_batches`
- Severity: `yellow`
- Recommended action: `Merge`
- Linear-ready: `True`
- Auto-resolved: `False`
- Reason: Multiple active work items target the same source file; merge or sequence ownership before implementation.
- Involved active paths:
  - `PK36` — `prompts/batches/PK36.md` (partial_implementation; release proof)
  - `PFC36` — `prompts/batches/PFC36.md` (partial_implementation; release proof)

### 237. Same source file targeted by multiple active items: Native/Ambitions/Domain/EventLedgerModels.swift

- Candidate ID: `AMB28-same_source_file_targeted_by_multiple_active_batches-89567946`
- Evidence type: `same_source_file_targeted_by_multiple_active_batches`
- Severity: `yellow`
- Recommended action: `Merge`
- Linear-ready: `True`
- Auto-resolved: `False`
- Reason: Multiple active work items target the same source file; merge or sequence ownership before implementation.
- Involved active paths:
  - `PK18` — `prompts/batches/PK18.md` (partial_implementation; release proof)
  - `PK22` — `prompts/batches/PK22.md` (partial_implementation; release proof)
  - `PK27` — `prompts/batches/PK27.md` (partial_implementation; release proof)
  - `existing-code-champion-coverage` — `docs/codex/existing-code-champion-coverage.yml` (unknown; release proof)

### 238. Same source file targeted by multiple active items: scripts/ambitions_codex_os_validate.py

- Candidate ID: `AMB28-same_source_file_targeted_by_multiple_active_batches-89908733`
- Evidence type: `same_source_file_targeted_by_multiple_active_batches`
- Severity: `yellow`
- Recommended action: `Merge`
- Linear-ready: `True`
- Auto-resolved: `False`
- Reason: Multiple active work items target the same source file; merge or sequence ownership before implementation.
- Involved active paths:
  - `AMB-FILE-BY-FILE-REPO-AUDIT-01` — `prompts/batches/AMB-FILE-BY-FILE-REPO-AUDIT-01.md` (partial_implementation; release proof)
  - `AMB-REPO-GREEN-FLAGSHIP-RESET-MASTER-01` — `prompts/batches/AMB-REPO-GREEN-FLAGSHIP-RESET-MASTER-01.md` (partial_implementation; release proof)

### 239. Same source file targeted by multiple active items: Native/AmbitionsTests/Runtime/GoalRealityRuntimeBoundaryTests.swift

- Candidate ID: `AMB28-same_source_file_targeted_by_multiple_active_batches-90326764`
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
  - `MOAT-GOAL-REALITY-RUNTIME-SERVICE-03` — `prompts/batches/MOAT-GOAL-REALITY-RUNTIME-SERVICE-03.md` (partial_implementation; release proof)

### 240. Same source file targeted by multiple active items: Native/Ambitions/Domain/AmbitionsOSLivingDreamStartingPositionPrivacyIntakeModels.swift

- Candidate ID: `AMB28-same_source_file_targeted_by_multiple_active_batches-92255170`
- Evidence type: `same_source_file_targeted_by_multiple_active_batches`
- Severity: `yellow`
- Recommended action: `Merge`
- Linear-ready: `True`
- Auto-resolved: `False`
- Reason: Multiple active work items target the same source file; merge or sequence ownership before implementation.
- Involved active paths:
  - `MOAT-MOONSHOT-BACKEND-FULL-TRAIN-01` — `prompts/batches/MOAT-MOONSHOT-BACKEND-FULL-TRAIN-01.md` (partial_implementation; release proof)
  - `MOAT-MOONSHOT-PROOF-PATH-01` — `prompts/batches/MOAT-MOONSHOT-PROOF-PATH-01.md` (partial_implementation; release proof)
  - `MOAT-UNIVERSAL-GOAL-REALITY-COMPILER-01` — `prompts/batches/MOAT-UNIVERSAL-GOAL-REALITY-COMPILER-01.md` (partial_implementation; release proof)
  - `existing-code-champion-coverage` — `docs/codex/existing-code-champion-coverage.yml` (unknown; release proof)

### 241. Same source file targeted by multiple active items: scripts/cqs-performance-budget-scan.sh

- Candidate ID: `AMB28-same_source_file_targeted_by_multiple_active_batches-92777858`
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

### 242. Same source file targeted by multiple active items: Native/Ambitions/Persistence/SwiftDataStore.swift

- Candidate ID: `AMB28-same_source_file_targeted_by_multiple_active_batches-9435585`
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
  - `PFC08_Corruption_Recovery_Backup_Restore_Plan_Prompt` — `docs/codex/batches/PFC08_Corruption_Recovery_Backup_Restore_Plan_Prompt.md` (unknown; release proof)

### 243. Same source file targeted by multiple active items: Native/Ambitions/Domain/AmbitionsOSPerformanceEnergyModels.swift

- Candidate ID: `AMB28-same_source_file_targeted_by_multiple_active_batches-94943221`
- Evidence type: `same_source_file_targeted_by_multiple_active_batches`
- Severity: `yellow`
- Recommended action: `Merge`
- Linear-ready: `True`
- Auto-resolved: `False`
- Reason: Multiple active work items target the same source file; merge or sequence ownership before implementation.
- Involved active paths:
  - `AMBITIONSOS_AOS_TRACEABILITY_MATRIX` — `docs/codex/AMBITIONSOS_AOS_TRACEABILITY_MATRIX.md` (partial_implementation; release proof)
  - `PK36` — `prompts/batches/PK36.md` (partial_implementation; release proof)
  - `PFC36` — `prompts/batches/PFC36.md` (partial_implementation; release proof)
  - `existing-code-champion-coverage` — `docs/codex/existing-code-champion-coverage.yml` (unknown; release proof)

### 244. Same source file targeted by multiple active items: Native/Ambitions/Features/Plan/PlanCalendarAwarenessSupport.swift

- Candidate ID: `AMB28-same_source_file_targeted_by_multiple_active_batches-95492587`
- Evidence type: `same_source_file_targeted_by_multiple_active_batches`
- Severity: `yellow`
- Recommended action: `Merge`
- Linear-ready: `True`
- Auto-resolved: `False`
- Reason: Multiple active work items target the same source file; merge or sequence ownership before implementation.
- Involved active paths:
  - `PFC20_Notifications_Calendar_Reminders_Implementation_Proof_Prompt` — `docs/codex/batches/PFC20_Notifications_Calendar_Reminders_Implementation_Proof_Prompt.md` (partial_implementation; release proof)
  - `PK24` — `prompts/batches/PK24.md` (partial_implementation; release proof)

### 245. Same source file targeted by multiple active items: Native/Ambitions/Services/CaptureService.swift

- Candidate ID: `AMB28-same_source_file_targeted_by_multiple_active_batches-9560908`
- Evidence type: `same_source_file_targeted_by_multiple_active_batches`
- Severity: `yellow`
- Recommended action: `Merge`
- Linear-ready: `True`
- Auto-resolved: `False`
- Reason: Multiple active work items target the same source file; merge or sequence ownership before implementation.
- Involved active paths:
  - `repo-audit-baseline` — `docs/codex/repo-audit-baseline.md` (partial_implementation; release proof)
  - `PK20` — `prompts/batches/PK20.md` (partial_implementation; release proof)
  - `AMB-POST23-01-TRUTH-AUDIT` — `docs/codex/reports/AMB-POST23-01-TRUTH-AUDIT.md` (partial_implementation; release proof)

### 246. Same source file targeted by multiple active items: Native/Ambitions/Domain/AmbitionsOSRecommendationStartHereModels.swift

- Candidate ID: `AMB28-same_source_file_targeted_by_multiple_active_batches-96229912`
- Evidence type: `same_source_file_targeted_by_multiple_active_batches`
- Severity: `yellow`
- Recommended action: `Merge`
- Linear-ready: `True`
- Auto-resolved: `False`
- Reason: Multiple active work items target the same source file; merge or sequence ownership before implementation.
- Involved active paths:
  - `AMBITIONSOS_AOS_TRACEABILITY_MATRIX` — `docs/codex/AMBITIONSOS_AOS_TRACEABILITY_MATRIX.md` (partial_implementation; release proof)
  - `PK33` — `prompts/batches/PK33.md` (partial_implementation; release proof)
  - `MOAT-MOONSHOT-BACKEND-FULL-TRAIN-01` — `prompts/batches/MOAT-MOONSHOT-BACKEND-FULL-TRAIN-01.md` (partial_implementation; release proof)
  - `MOAT-MOONSHOT-PROOF-PATH-01` — `prompts/batches/MOAT-MOONSHOT-PROOF-PATH-01.md` (partial_implementation; release proof)
  - `MOAT-UNIVERSAL-GOAL-REALITY-COMPILER-01` — `prompts/batches/MOAT-UNIVERSAL-GOAL-REALITY-COMPILER-01.md` (partial_implementation; release proof)
  - `FLAGSHIP-OBJECT-SYSTEM-01` — `prompts/batches/FLAGSHIP-OBJECT-SYSTEM-01.md` (partial_implementation; release proof)
  - `MOAT-GOAL-REALITY-SOURCE-PACKS-09` — `prompts/batches/MOAT-GOAL-REALITY-SOURCE-PACKS-09.md` (partial_implementation; release proof)
  - `existing-code-champion-coverage` — `docs/codex/existing-code-champion-coverage.yml` (unknown; release proof)

### 247. Same source file targeted by multiple active items: scripts/ambitions-xcode-test-plan.sh

- Candidate ID: `AMB28-same_source_file_targeted_by_multiple_active_batches-96443318`
- Evidence type: `same_source_file_targeted_by_multiple_active_batches`
- Severity: `yellow`
- Recommended action: `Merge`
- Linear-ready: `True`
- Auto-resolved: `False`
- Reason: Multiple active work items target the same source file; merge or sequence ownership before implementation.
- Involved active paths:
  - `XCODE-BUILD-SYSTEM-MAX-01-REPAIR-01` — `prompts/batches/XCODE-BUILD-SYSTEM-MAX-01-REPAIR-01.md` (partial_implementation; release proof)
  - `XCODE-PERF-RUNNER-MATURITY-01` — `prompts/batches/XCODE-PERF-RUNNER-MATURITY-01.md` (partial_implementation; release proof)

### 248. Same source file targeted by multiple active items: Native/Ambitions/Domain/AmbitionsOSLocalGoalPackModels.swift

- Candidate ID: `AMB28-same_source_file_targeted_by_multiple_active_batches-96574707`
- Evidence type: `same_source_file_targeted_by_multiple_active_batches`
- Severity: `yellow`
- Recommended action: `Merge`
- Linear-ready: `True`
- Auto-resolved: `False`
- Reason: Multiple active work items target the same source file; merge or sequence ownership before implementation.
- Involved active paths:
  - `AMBITIONSOS_AOS_TRACEABILITY_MATRIX` — `docs/codex/AMBITIONSOS_AOS_TRACEABILITY_MATRIX.md` (partial_implementation; release proof)
  - `existing-code-champion-coverage` — `docs/codex/existing-code-champion-coverage.yml` (unknown; release proof)

### 249. Same source file targeted by multiple active items: scripts/global-train-next-batch.sh

- Candidate ID: `AMB28-same_source_file_targeted_by_multiple_active_batches-96812255`
- Evidence type: `same_source_file_targeted_by_multiple_active_batches`
- Severity: `yellow`
- Recommended action: `Merge`
- Linear-ready: `True`
- Auto-resolved: `False`
- Reason: Multiple active work items target the same source file; merge or sequence ownership before implementation.
- Involved active paths:
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
  - ... 17 more

### 250. Same source file targeted by multiple active items: Native/Ambitions/Domain/AmbitionsOSStartingPositionModels.swift

- Candidate ID: `AMB28-same_source_file_targeted_by_multiple_active_batches-97040876`
- Evidence type: `same_source_file_targeted_by_multiple_active_batches`
- Severity: `yellow`
- Recommended action: `Merge`
- Linear-ready: `True`
- Auto-resolved: `False`
- Reason: Multiple active work items target the same source file; merge or sequence ownership before implementation.
- Involved active paths:
  - `AMBITIONSOS_AOS_TRACEABILITY_MATRIX` — `docs/codex/AMBITIONSOS_AOS_TRACEABILITY_MATRIX.md` (partial_implementation; release proof)
  - `existing-code-champion-coverage` — `docs/codex/existing-code-champion-coverage.yml` (unknown; release proof)

### 251. Same source file targeted by multiple active items: Native/AmbitionsTests/Persistence/PersistenceRepositoryTests.swift

- Candidate ID: `AMB28-same_source_file_targeted_by_multiple_active_batches-98294267`
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

### 252. Same source file targeted by multiple active items: scripts/cqs-accessibility-motion-scan.sh

- Candidate ID: `AMB28-same_source_file_targeted_by_multiple_active_batches-98674729`
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

### 253. Same source file targeted by multiple active items: Native/AmbitionsTests/Runtime/GoalRealityNegativeFixtureTests.swift

- Candidate ID: `AMB28-same_source_file_targeted_by_multiple_active_batches-99122285`
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

### 254. Same source file targeted by multiple active items: scripts/openai-build-suite-dry-run.py

- Candidate ID: `AMB28-same_source_file_targeted_by_multiple_active_batches-9933079`
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

### 255. Source-only or missing-proof implementation state: HARNESS-T00-B01-baseline-audit

- Candidate ID: `AMB28-source_only_implementation_missing_proof-11169397`
- Evidence type: `source_only_implementation_missing_proof`
- Severity: `yellow`
- Recommended action: `Expedite`
- Linear-ready: `True`
- Auto-resolved: `False`
- Reason: Active item is partial/source-only/missing-proof; finish proof before treating as complete.
- Involved active paths:
  - `HARNESS-T00-B01-baseline-audit` — `prompts/batches/HARNESS-T00-B01-baseline-audit.md` (partial_implementation; audit)

### 256. Source-only or missing-proof implementation state: HARNESS-T01-B01-docs

- Candidate ID: `AMB28-source_only_implementation_missing_proof-64306305`
- Evidence type: `source_only_implementation_missing_proof`
- Severity: `yellow`
- Recommended action: `Expedite`
- Linear-ready: `True`
- Auto-resolved: `False`
- Reason: Active item is partial/source-only/missing-proof; finish proof before treating as complete.
- Involved active paths:
  - `HARNESS-T01-B01-docs` — `prompts/batches/HARNESS-T01-B01-docs.md` (partial_implementation; audit)

### 257. Source-only or missing-proof implementation state: TRAIN_00_REPO_TRUTH_AUDIT_VALIDATION_BASELINE

- Candidate ID: `AMB28-source_only_implementation_missing_proof-74068354`
- Evidence type: `source_only_implementation_missing_proof`
- Severity: `yellow`
- Recommended action: `Expedite`
- Linear-ready: `True`
- Auto-resolved: `False`
- Reason: Active item is partial/source-only/missing-proof; finish proof before treating as complete.
- Involved active paths:
  - `TRAIN_00_REPO_TRUTH_AUDIT_VALIDATION_BASELINE` — `prompts/trains/ios26-flagship/TRAIN_00_REPO_TRUTH_AUDIT_VALIDATION_BASELINE.md` (partial_implementation; audit)

### 258. Source-only or missing-proof implementation state: HARNESS_README

- Candidate ID: `AMB28-source_only_implementation_missing_proof-75886511`
- Evidence type: `source_only_implementation_missing_proof`
- Severity: `yellow`
- Recommended action: `Expedite`
- Linear-ready: `True`
- Auto-resolved: `False`
- Reason: Active item is partial/source-only/missing-proof; finish proof before treating as complete.
- Involved active paths:
  - `HARNESS_README` — `docs/codex/HARNESS_README.md` (partial_implementation; audit)

### 259. Source-only or missing-proof implementation state: HARNESS_PLAN

- Candidate ID: `AMB28-source_only_implementation_missing_proof-76737212`
- Evidence type: `source_only_implementation_missing_proof`
- Severity: `yellow`
- Recommended action: `Expedite`
- Linear-ready: `True`
- Auto-resolved: `False`
- Reason: Active item is partial/source-only/missing-proof; finish proof before treating as complete.
- Involved active paths:
  - `HARNESS_PLAN` — `docs/codex/HARNESS_PLAN.md` (unknown; audit)

### 260. Source-only or missing-proof implementation state: HARNESS_ARTIFACT_SCHEMA

- Candidate ID: `AMB28-source_only_implementation_missing_proof-84824084`
- Evidence type: `source_only_implementation_missing_proof`
- Severity: `yellow`
- Recommended action: `Expedite`
- Linear-ready: `True`
- Auto-resolved: `False`
- Reason: Active item is partial/source-only/missing-proof; finish proof before treating as complete.
- Involved active paths:
  - `HARNESS_ARTIFACT_SCHEMA` — `docs/codex/HARNESS_ARTIFACT_SCHEMA.md` (partial_implementation; audit)

### 261. Unknown active status: SOURCE_ATLAS_HPS_AOS_LDI_INTEGRATION_MAP

- Candidate ID: `AMB28-stale_or_unknown_active_status-1128024`
- Evidence type: `stale_or_unknown_active_status`
- Severity: `yellow`
- Recommended action: `Expedite`
- Linear-ready: `True`
- Auto-resolved: `False`
- Reason: Active item status is unknown or stale; expedite clarification before implementation depends on it.
- Involved active paths:
  - `SOURCE_ATLAS_HPS_AOS_LDI_INTEGRATION_MAP` — `docs/codex/SOURCE_ATLAS_HPS_AOS_LDI_INTEGRATION_MAP.md` (unknown; release proof)

### 262. Unknown active status: SIG05_Plan_Signature_Experience_Implementation_Prompt

- Candidate ID: `AMB28-stale_or_unknown_active_status-1211062`
- Evidence type: `stale_or_unknown_active_status`
- Severity: `yellow`
- Recommended action: `Expedite`
- Linear-ready: `True`
- Auto-resolved: `False`
- Reason: Active item status is unknown or stale; expedite clarification before implementation depends on it.
- Involved active paths:
  - `SIG05_Plan_Signature_Experience_Implementation_Prompt` — `docs/codex/batches/SIG05_Plan_Signature_Experience_Implementation_Prompt.md` (unknown; release proof)

### 263. Unknown active status: SOURCE_ATLAS_RESEARCH_SEEDS_V1_LIMITATIONS

- Candidate ID: `AMB28-stale_or_unknown_active_status-12274178`
- Evidence type: `stale_or_unknown_active_status`
- Severity: `yellow`
- Recommended action: `Expedite`
- Linear-ready: `True`
- Auto-resolved: `False`
- Reason: Active item status is unknown or stale; expedite clarification before implementation depends on it.
- Involved active paths:
  - `SOURCE_ATLAS_RESEARCH_SEEDS_V1_LIMITATIONS` — `docs/codex/SOURCE_ATLAS_RESEARCH_SEEDS_V1_LIMITATIONS.md` (unknown; release proof)

### 264. Unknown active status: MCP06_SOURCE_ATLAS_PACK_MCP_PLAN

- Candidate ID: `AMB28-stale_or_unknown_active_status-12321975`
- Evidence type: `stale_or_unknown_active_status`
- Severity: `yellow`
- Recommended action: `Expedite`
- Linear-ready: `True`
- Auto-resolved: `False`
- Reason: Active item status is unknown or stale; expedite clarification before implementation depends on it.
- Involved active paths:
  - `MCP06_SOURCE_ATLAS_PACK_MCP_PLAN` — `docs/codex/MCP06_SOURCE_ATLAS_PACK_MCP_PLAN.md` (unknown; release proof)

### 265. Unknown active status: AQOS_BATCH_IMPACT_CLASSIFIER

- Candidate ID: `AMB28-stale_or_unknown_active_status-12377021`
- Evidence type: `stale_or_unknown_active_status`
- Severity: `yellow`
- Recommended action: `Expedite`
- Linear-ready: `True`
- Auto-resolved: `False`
- Reason: Active item status is unknown or stale; expedite clarification before implementation depends on it.
- Involved active paths:
  - `AQOS_BATCH_IMPACT_CLASSIFIER` — `docs/codex/quality/AQOS_BATCH_IMPACT_CLASSIFIER.md` (unknown; release proof)

### 266. Unknown active status: F24_Privacy_Trust_Local_Data_Redaction_QA_Prompt

- Candidate ID: `AMB28-stale_or_unknown_active_status-14122889`
- Evidence type: `stale_or_unknown_active_status`
- Severity: `yellow`
- Recommended action: `Expedite`
- Linear-ready: `True`
- Auto-resolved: `False`
- Reason: Active item status is unknown or stale; expedite clarification before implementation depends on it.
- Involved active paths:
  - `F24_Privacy_Trust_Local_Data_Redaction_QA_Prompt` — `docs/codex/batches/F24_Privacy_Trust_Local_Data_Redaction_QA_Prompt.md` (unknown; release proof)

### 267. Unknown active status: BATCH-26-resource-graph-and-source-ranking

- Candidate ID: `AMB28-stale_or_unknown_active_status-1431041`
- Evidence type: `stale_or_unknown_active_status`
- Severity: `yellow`
- Recommended action: `Expedite`
- Linear-ready: `True`
- Auto-resolved: `False`
- Reason: Active item status is unknown or stale; expedite clarification before implementation depends on it.
- Involved active paths:
  - `BATCH-26-resource-graph-and-source-ranking` — `docs/codex/batches/BATCH-26-resource-graph-and-source-ranking.md` (unknown; release proof)

### 268. Unknown active status: XCODE_VALIDATION_LANE_MATRIX

- Candidate ID: `AMB28-stale_or_unknown_active_status-14697862`
- Evidence type: `stale_or_unknown_active_status`
- Severity: `yellow`
- Recommended action: `Expedite`
- Linear-ready: `True`
- Auto-resolved: `False`
- Reason: Active item status is unknown or stale; expedite clarification before implementation depends on it.
- Involved active paths:
  - `XCODE_VALIDATION_LANE_MATRIX` — `docs/codex/XCODE_VALIDATION_LANE_MATRIX.md` (unknown; release proof)

### 269. Unknown active status: AMBITIONS_3_0_RUN_STATE_PROTOCOL

- Candidate ID: `AMB28-stale_or_unknown_active_status-15557722`
- Evidence type: `stale_or_unknown_active_status`
- Severity: `yellow`
- Recommended action: `Expedite`
- Linear-ready: `True`
- Auto-resolved: `False`
- Reason: Active item status is unknown or stale; expedite clarification before implementation depends on it.
- Involved active paths:
  - `AMBITIONS_3_0_RUN_STATE_PROTOCOL` — `docs/codex/AMBITIONS_3_0_RUN_STATE_PROTOCOL.md` (unknown; release proof)

### 270. Unknown active status: FCP09_Motion_Haptics_Reduced_Motion_Proof_Prompt

- Candidate ID: `AMB28-stale_or_unknown_active_status-16298445`
- Evidence type: `stale_or_unknown_active_status`
- Severity: `yellow`
- Recommended action: `Expedite`
- Linear-ready: `True`
- Auto-resolved: `False`
- Reason: Active item status is unknown or stale; expedite clarification before implementation depends on it.
- Involved active paths:
  - `FCP09_Motion_Haptics_Reduced_Motion_Proof_Prompt` — `docs/codex/batches/FCP09_Motion_Haptics_Reduced_Motion_Proof_Prompt.md` (unknown; release proof)

### 271. Unknown active status: PXOS_DRIFT_DETECTION_PROTOCOL

- Candidate ID: `AMB28-stale_or_unknown_active_status-16926993`
- Evidence type: `stale_or_unknown_active_status`
- Severity: `yellow`
- Recommended action: `Expedite`
- Linear-ready: `True`
- Auto-resolved: `False`
- Reason: Active item status is unknown or stale; expedite clarification before implementation depends on it.
- Involved active paths:
  - `PXOS_DRIFT_DETECTION_PROTOCOL` — `docs/codex/PXOS_DRIFT_DETECTION_PROTOCOL.md` (unknown; release proof)

### 272. Unknown active status: FCP13A_Action_Closure_Diamond_Prompt

- Candidate ID: `AMB28-stale_or_unknown_active_status-17418578`
- Evidence type: `stale_or_unknown_active_status`
- Severity: `yellow`
- Recommended action: `Expedite`
- Linear-ready: `True`
- Auto-resolved: `False`
- Reason: Active item status is unknown or stale; expedite clarification before implementation depends on it.
- Involved active paths:
  - `FCP13A_Action_Closure_Diamond_Prompt` — `docs/codex/batches/FCP13A_Action_Closure_Diamond_Prompt.md` (unknown; release proof)

### 273. Unknown active status: BATCH-23-generalized-goal-understanding-contracts

- Candidate ID: `AMB28-stale_or_unknown_active_status-1744944`
- Evidence type: `stale_or_unknown_active_status`
- Severity: `yellow`
- Recommended action: `Expedite`
- Linear-ready: `True`
- Auto-resolved: `False`
- Reason: Active item status is unknown or stale; expedite clarification before implementation depends on it.
- Involved active paths:
  - `BATCH-23-generalized-goal-understanding-contracts` — `docs/codex/batches/BATCH-23-generalized-goal-understanding-contracts.md` (unknown; release proof)

### 274. Unknown active status: SIG07_You_Signature_Experience_Implementation_Prompt

- Candidate ID: `AMB28-stale_or_unknown_active_status-17725668`
- Evidence type: `stale_or_unknown_active_status`
- Severity: `yellow`
- Recommended action: `Expedite`
- Linear-ready: `True`
- Auto-resolved: `False`
- Reason: Active item status is unknown or stale; expedite clarification before implementation depends on it.
- Involved active paths:
  - `SIG07_You_Signature_Experience_Implementation_Prompt` — `docs/codex/batches/SIG07_You_Signature_Experience_Implementation_Prompt.md` (unknown; release proof)

### 275. Unknown active status: F19_Shell_Route_Parity_Fallback_Safety_Prompt

- Candidate ID: `AMB28-stale_or_unknown_active_status-17823422`
- Evidence type: `stale_or_unknown_active_status`
- Severity: `yellow`
- Recommended action: `Expedite`
- Linear-ready: `True`
- Auto-resolved: `False`
- Reason: Active item status is unknown or stale; expedite clarification before implementation depends on it.
- Involved active paths:
  - `F19_Shell_Route_Parity_Fallback_Safety_Prompt` — `docs/codex/batches/F19_Shell_Route_Parity_Fallback_Safety_Prompt.md` (unknown; release proof)

### 276. Unknown active status: AMB-CODEX-OS-PROOF-LEDGER

- Candidate ID: `AMB28-stale_or_unknown_active_status-18136074`
- Evidence type: `stale_or_unknown_active_status`
- Severity: `yellow`
- Recommended action: `Expedite`
- Linear-ready: `True`
- Auto-resolved: `False`
- Reason: Active item status is unknown or stale; expedite clarification before implementation depends on it.
- Involved active paths:
  - `AMB-CODEX-OS-PROOF-LEDGER` — `docs/codex/os/AMB-CODEX-OS-PROOF-LEDGER.md` (unknown; release proof)

### 277. Unknown active status: AMB-CHATGPT-FLAGSHIP-BAR

- Candidate ID: `AMB28-stale_or_unknown_active_status-18428243`
- Evidence type: `stale_or_unknown_active_status`
- Severity: `yellow`
- Recommended action: `Expedite`
- Linear-ready: `True`
- Auto-resolved: `False`
- Reason: Active item status is unknown or stale; expedite clarification before implementation depends on it.
- Involved active paths:
  - `AMB-CHATGPT-FLAGSHIP-BAR` — `docs/codex/chatgpt/AMB-CHATGPT-FLAGSHIP-BAR.md` (unknown; release proof)

### 278. Unknown active status: FL03_Commitment_Memory_Open_Loop_Registry_Prompt

- Candidate ID: `AMB28-stale_or_unknown_active_status-1976845`
- Evidence type: `stale_or_unknown_active_status`
- Severity: `yellow`
- Recommended action: `Expedite`
- Linear-ready: `True`
- Auto-resolved: `False`
- Reason: Active item status is unknown or stale; expedite clarification before implementation depends on it.
- Involved active paths:
  - `FL03_Commitment_Memory_Open_Loop_Registry_Prompt` — `docs/codex/batches/FL03_Commitment_Memory_Open_Loop_Registry_Prompt.md` (unknown; release proof)

### 279. Unknown active status: FRONTEND_SCREENSHOT_EVIDENCE_STANDARD

- Candidate ID: `AMB28-stale_or_unknown_active_status-20283743`
- Evidence type: `stale_or_unknown_active_status`
- Severity: `yellow`
- Recommended action: `Expedite`
- Linear-ready: `True`
- Auto-resolved: `False`
- Reason: Active item status is unknown or stale; expedite clarification before implementation depends on it.
- Involved active paths:
  - `FRONTEND_SCREENSHOT_EVIDENCE_STANDARD` — `docs/codex/FRONTEND_SCREENSHOT_EVIDENCE_STANDARD.md` (unknown; release proof)

### 280. Unknown active status: IOS26_CORE_REPLACEMENT_JOURNEY_SPEC

- Candidate ID: `AMB28-stale_or_unknown_active_status-20846279`
- Evidence type: `stale_or_unknown_active_status`
- Severity: `yellow`
- Recommended action: `Expedite`
- Linear-ready: `True`
- Auto-resolved: `False`
- Reason: Active item status is unknown or stale; expedite clarification before implementation depends on it.
- Involved active paths:
  - `IOS26_CORE_REPLACEMENT_JOURNEY_SPEC` — `docs/codex/IOS26_CORE_REPLACEMENT_JOURNEY_SPEC.md` (unknown; release proof)

### 281. Unknown active status: AMB-CHATGPT-REVIEW-PROMPT-TEMPLATE

- Candidate ID: `AMB28-stale_or_unknown_active_status-20986828`
- Evidence type: `stale_or_unknown_active_status`
- Severity: `yellow`
- Recommended action: `Expedite`
- Linear-ready: `True`
- Auto-resolved: `False`
- Reason: Active item status is unknown or stale; expedite clarification before implementation depends on it.
- Involved active paths:
  - `AMB-CHATGPT-REVIEW-PROMPT-TEMPLATE` — `docs/codex/chatgpt/AMB-CHATGPT-REVIEW-PROMPT-TEMPLATE.md` (unknown; release proof)

### 282. Unknown active status: BATCH-24-path-compiler-foundation

- Candidate ID: `AMB28-stale_or_unknown_active_status-21360250`
- Evidence type: `stale_or_unknown_active_status`
- Severity: `yellow`
- Recommended action: `Expedite`
- Linear-ready: `True`
- Auto-resolved: `False`
- Reason: Active item status is unknown or stale; expedite clarification before implementation depends on it.
- Involved active paths:
  - `BATCH-24-path-compiler-foundation` — `docs/codex/batches/BATCH-24-path-compiler-foundation.md` (unknown; release proof)

### 283. Unknown active status: REPO_INTELLIGENCE_LAYER

- Candidate ID: `AMB28-stale_or_unknown_active_status-21479880`
- Evidence type: `stale_or_unknown_active_status`
- Severity: `yellow`
- Recommended action: `Expedite`
- Linear-ready: `True`
- Auto-resolved: `False`
- Reason: Active item status is unknown or stale; expedite clarification before implementation depends on it.
- Involved active paths:
  - `REPO_INTELLIGENCE_LAYER` — `docs/codex/REPO_INTELLIGENCE_LAYER.md` (unknown; release proof)

### 284. Unknown active status: AMB-CHATGPT-APP-STORE-HONESTY-PROMPT-TEMPLATE

- Candidate ID: `AMB28-stale_or_unknown_active_status-21756879`
- Evidence type: `stale_or_unknown_active_status`
- Severity: `yellow`
- Recommended action: `Expedite`
- Linear-ready: `True`
- Auto-resolved: `False`
- Reason: Active item status is unknown or stale; expedite clarification before implementation depends on it.
- Involved active paths:
  - `AMB-CHATGPT-APP-STORE-HONESTY-PROMPT-TEMPLATE` — `docs/codex/chatgpt/AMB-CHATGPT-APP-STORE-HONESTY-PROMPT-TEMPLATE.md` (unknown; release proof)

### 285. Unknown active status: AMBITIONS_3_0_SKILL_SYSTEM_INDEX

- Candidate ID: `AMB28-stale_or_unknown_active_status-21899531`
- Evidence type: `stale_or_unknown_active_status`
- Severity: `yellow`
- Recommended action: `Expedite`
- Linear-ready: `True`
- Auto-resolved: `False`
- Reason: Active item status is unknown or stale; expedite clarification before implementation depends on it.
- Involved active paths:
  - `AMBITIONS_3_0_SKILL_SYSTEM_INDEX` — `docs/codex/AMBITIONS_3_0_SKILL_SYSTEM_INDEX.md` (unknown; release proof)

### 286. Unknown active status: F20_External_Surface_Privacy_Projection_Prompt

- Candidate ID: `AMB28-stale_or_unknown_active_status-22057420`
- Evidence type: `stale_or_unknown_active_status`
- Severity: `yellow`
- Recommended action: `Expedite`
- Linear-ready: `True`
- Auto-resolved: `False`
- Reason: Active item status is unknown or stale; expedite clarification before implementation depends on it.
- Involved active paths:
  - `F20_External_Surface_Privacy_Projection_Prompt` — `docs/codex/batches/F20_External_Surface_Privacy_Projection_Prompt.md` (unknown; release proof)

### 287. Unknown active status: F18_5_Shell_Architecture_Hardening_Prompt

- Candidate ID: `AMB28-stale_or_unknown_active_status-22970366`
- Evidence type: `stale_or_unknown_active_status`
- Severity: `yellow`
- Recommended action: `Expedite`
- Linear-ready: `True`
- Auto-resolved: `False`
- Reason: Active item status is unknown or stale; expedite clarification before implementation depends on it.
- Involved active paths:
  - `F18_5_Shell_Architecture_Hardening_Prompt` — `docs/codex/batches/F18_5_Shell_Architecture_Hardening_Prompt.md` (unknown; release proof)

### 288. Unknown active status: CODEX_BUILD_SHERIFF_PROTOCOL

- Candidate ID: `AMB28-stale_or_unknown_active_status-24236122`
- Evidence type: `stale_or_unknown_active_status`
- Severity: `yellow`
- Recommended action: `Expedite`
- Linear-ready: `True`
- Auto-resolved: `False`
- Reason: Active item status is unknown or stale; expedite clarification before implementation depends on it.
- Involved active paths:
  - `CODEX_BUILD_SHERIFF_PROTOCOL` — `docs/codex/CODEX_BUILD_SHERIFF_PROTOCOL.md` (unknown; release proof)

### 289. Unknown active status: BATCH_REPORT_LAYER

- Candidate ID: `AMB28-stale_or_unknown_active_status-2433310`
- Evidence type: `stale_or_unknown_active_status`
- Severity: `yellow`
- Recommended action: `Expedite`
- Linear-ready: `True`
- Auto-resolved: `False`
- Reason: Active item status is unknown or stale; expedite clarification before implementation depends on it.
- Involved active paths:
  - `BATCH_REPORT_LAYER` — `docs/codex/BATCH_REPORT_LAYER.md` (unknown; release proof)

### 290. Unknown active status: SIG_FLUIDITY_AND_DELIGHT_PROTOCOL

- Candidate ID: `AMB28-stale_or_unknown_active_status-24435181`
- Evidence type: `stale_or_unknown_active_status`
- Severity: `yellow`
- Recommended action: `Expedite`
- Linear-ready: `True`
- Auto-resolved: `False`
- Reason: Active item status is unknown or stale; expedite clarification before implementation depends on it.
- Involved active paths:
  - `SIG_FLUIDITY_AND_DELIGHT_PROTOCOL` — `docs/codex/SIG_FLUIDITY_AND_DELIGHT_PROTOCOL.md` (unknown; release proof)

### 291. Unknown active status: PXEQ_SURFACE_BEHAVIOR_MATRIX

- Candidate ID: `AMB28-stale_or_unknown_active_status-24971666`
- Evidence type: `stale_or_unknown_active_status`
- Severity: `yellow`
- Recommended action: `Expedite`
- Linear-ready: `True`
- Auto-resolved: `False`
- Reason: Active item status is unknown or stale; expedite clarification before implementation depends on it.
- Involved active paths:
  - `PXEQ_SURFACE_BEHAVIOR_MATRIX` — `docs/codex/PXEQ_SURFACE_BEHAVIOR_MATRIX.md` (unknown; release proof)

### 292. Unknown active status: SIG_EMOTIONAL_DESIGN_MOMENTS_MAP

- Candidate ID: `AMB28-stale_or_unknown_active_status-25059142`
- Evidence type: `stale_or_unknown_active_status`
- Severity: `yellow`
- Recommended action: `Expedite`
- Linear-ready: `True`
- Auto-resolved: `False`
- Reason: Active item status is unknown or stale; expedite clarification before implementation depends on it.
- Involved active paths:
  - `SIG_EMOTIONAL_DESIGN_MOMENTS_MAP` — `docs/codex/SIG_EMOTIONAL_DESIGN_MOMENTS_MAP.md` (unknown; release proof)

### 293. Unknown active status: SPEED_TRAIN_QUICKSTART

- Candidate ID: `AMB28-stale_or_unknown_active_status-2621936`
- Evidence type: `stale_or_unknown_active_status`
- Severity: `yellow`
- Recommended action: `Expedite`
- Linear-ready: `True`
- Auto-resolved: `False`
- Reason: Active item status is unknown or stale; expedite clarification before implementation depends on it.
- Involved active paths:
  - `SPEED_TRAIN_QUICKSTART` — `docs/codex/SPEED_TRAIN_QUICKSTART.md` (unknown; release proof)

### 294. Unknown active status: AMBITIONS_3_0_PARALLEL_CODEX_WORKTREE_PROTOCOL

- Candidate ID: `AMB28-stale_or_unknown_active_status-26547472`
- Evidence type: `stale_or_unknown_active_status`
- Severity: `yellow`
- Recommended action: `Expedite`
- Linear-ready: `True`
- Auto-resolved: `False`
- Reason: Active item status is unknown or stale; expedite clarification before implementation depends on it.
- Involved active paths:
  - `AMBITIONS_3_0_PARALLEL_CODEX_WORKTREE_PROTOCOL` — `docs/codex/AMBITIONS_3_0_PARALLEL_CODEX_WORKTREE_PROTOCOL.md` (unknown; release proof)

### 295. Unknown active status: HISTORICAL_BASELINE_GLOBAL_TRAIN_MANIFEST

- Candidate ID: `AMB28-stale_or_unknown_active_status-27349501`
- Evidence type: `stale_or_unknown_active_status`
- Severity: `yellow`
- Recommended action: `Expedite`
- Linear-ready: `True`
- Auto-resolved: `False`
- Reason: Active item status is unknown or stale; expedite clarification before implementation depends on it.
- Involved active paths:
  - `HISTORICAL_BASELINE_GLOBAL_TRAIN_MANIFEST` — `docs/codex/HISTORICAL_BASELINE_GLOBAL_TRAIN_MANIFEST.json` (unknown; release proof)

### 296. Unknown active status: SIG13_Signature_Preview_Gallery_And_Demo_Scenarios_Prompt

- Candidate ID: `AMB28-stale_or_unknown_active_status-2738275`
- Evidence type: `stale_or_unknown_active_status`
- Severity: `yellow`
- Recommended action: `Expedite`
- Linear-ready: `True`
- Auto-resolved: `False`
- Reason: Active item status is unknown or stale; expedite clarification before implementation depends on it.
- Involved active paths:
  - `SIG13_Signature_Preview_Gallery_And_Demo_Scenarios_Prompt` — `docs/codex/batches/SIG13_Signature_Preview_Gallery_And_Demo_Scenarios_Prompt.md` (unknown; release proof)

### 297. Unknown active status: BATCH-30-contradiction-engine

- Candidate ID: `AMB28-stale_or_unknown_active_status-28343670`
- Evidence type: `stale_or_unknown_active_status`
- Severity: `yellow`
- Recommended action: `Expedite`
- Linear-ready: `True`
- Auto-resolved: `False`
- Reason: Active item status is unknown or stale; expedite clarification before implementation depends on it.
- Involved active paths:
  - `BATCH-30-contradiction-engine` — `docs/codex/batches/BATCH-30-contradiction-engine.md` (unknown; release proof)

### 298. Unknown active status: Launch_Operator_Runbook

- Candidate ID: `AMB28-stale_or_unknown_active_status-30370110`
- Evidence type: `stale_or_unknown_active_status`
- Severity: `yellow`
- Recommended action: `Expedite`
- Linear-ready: `True`
- Auto-resolved: `False`
- Reason: Active item status is unknown or stale; expedite clarification before implementation depends on it.
- Involved active paths:
  - `Launch_Operator_Runbook` — `docs/codex/Launch_Operator_Runbook.md` (unknown; release proof)

### 299. Unknown active status: F30_Beyond_3_0_Continuation_Plan_Prompt

- Candidate ID: `AMB28-stale_or_unknown_active_status-30565979`
- Evidence type: `stale_or_unknown_active_status`
- Severity: `yellow`
- Recommended action: `Expedite`
- Linear-ready: `True`
- Auto-resolved: `False`
- Reason: Active item status is unknown or stale; expedite clarification before implementation depends on it.
- Involved active paths:
  - `F30_Beyond_3_0_Continuation_Plan_Prompt` — `docs/codex/batches/F30_Beyond_3_0_Continuation_Plan_Prompt.md` (unknown; release proof)

### 300. Unknown active status: AMB-POST23-00-COMPLETION-SENTINEL

- Candidate ID: `AMB28-stale_or_unknown_active_status-31701305`
- Evidence type: `stale_or_unknown_active_status`
- Severity: `yellow`
- Recommended action: `Expedite`
- Linear-ready: `True`
- Auto-resolved: `False`
- Reason: Active item status is unknown or stale; expedite clarification before implementation depends on it.
- Involved active paths:
  - `AMB-POST23-00-COMPLETION-SENTINEL` — `docs/codex/reports/AMB-POST23-00-COMPLETION-SENTINEL.md` (unknown; release proof)

- ... 168 more active candidates in JSON

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
