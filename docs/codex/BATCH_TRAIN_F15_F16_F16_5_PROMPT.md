# F15-F16-F16.5 Legacy UI Architecture Train Runner

<!-- AMB-291-CANON-HYGIENE-REPAIR: BEGIN -->

> AMB-291 repair status: **canon-hygiene-reconciled**
> This file was reviewed as part of the actual canon content/hygiene rewrite pass.
> It is not standalone active product truth. Use `docs/truth/*` and current manifest/sequence authority before implementation.
> Conflict types reconciled: same_surface_multiple_active_batches
> Prior recommended actions: Expedite
> Candidate references: AMB28-same_surface_multiple_active_batches-13212827

<!-- AMB-291-CANON-HYGIENE-REPAIR: END -->

<!-- AMB-291-CANON-HYGIENE-HEADER: BEGIN -->

> Canon hygiene status: **codex-reference**
> AMB-291 note: This Codex reference supports process or execution, but active truth remains in docs/truth and current manifests.
> Active authority: `docs/truth/*`, `docs/codex/GLOBAL_BATCH_SEQUENCE_AUTHORITY.json`, and `docs/codex/IOS26_FLAGSHIP_TRAIN_MANIFEST.yml`.
> Before using this file for implementation, run `make change-impact-check` and follow `docs/ops/change-protocol/implementation-prompt-template.md`.
> Resolution classes: merge-overlap, merge-overlap-before-proof
> Dispositions: merge-before-proof, merge-or-sequence-surface-ownership

<!-- AMB-291-CANON-HYGIENE-HEADER: END -->

Path: docs/codex/BATCH_TRAIN_F15_F16_F16_5_PROMPT.md
Status: Copy/paste ready train runner prompt


You are Codex on `main` executing an Ambitions 3.0 gated batch train.

Read order: README.md; docs/README.md; docs/canon/Ambitions_3_0_Source_Of_Truth_Override.md; docs/canon/Ambitions_3_0_Front_End_Redesign_Index.md; docs/canon/Ambitions_3_0_Rebuild_Operating_Model.md; docs/canon/Ambitions_3_0_Primitive_Architecture.md; docs/canon/Ambitions_3_0_Product_Language_System.md; docs/codex/BATCH_REGISTRY.md; docs/codex/CONTEXT_INDEX.md; docs/codex/AMBITIONS_3_0_BATCH_TRAIN_ORCHESTRATOR.md; selected manifest; selected batch prompt; current run-state files.

Rules: load exactly one train manifest; never invent a train sequence; never skip a listed batch; never skip F03.5/F13.5/F16.5 when their trigger fires; never auto-run an Architecture Train implementation unless explicitly approved; never auto-run F17 Shell/Meridian implementation without explicit approval; Yellow/Red stops; Green may continue only after report, validation, commit, and matching next prompt.

Every train starts by validating prerequisites, task width, train type, source docs, context packs, skills, operations, validation packs, allowed files, forbidden files, Definition of Ready, Definition of Done, architecture/file responsibility gates, copy/privacy/accessibility gates, UI-test contract rules, dependency/workflow prohibition, commit policy, repair prompt generation, rollback guidance, compaction recovery, and final report path.

No skipped batch rule: if a batch appears unnecessary, stop with a Yellow report explaining why, evidence, risk, recommended human decision, and revised manifest proposal.

Final output quality bar: Result PASS/PARTIAL/FAIL; train name/type; batches attempted/completed/skipped/skip approvals; gate result per batch; commit shas/messages; build/focused/full/copy/privacy/accessibility/architecture/doc-QA status; allowed/forbidden files touched; stop reports; remaining risks; next exact prompt; FAANG handoff still PARTIAL unless the gate is re-run and passes.


## Train-Specific Instructions
Manifest: docs/codex/batch-trains/F15_F16_F16_5_Legacy_UI_Architecture_Train.md. Prerequisites: F01-F14 truth known, migration map exists, UI test contract exists, architecture scan exists. F15 owns identifier migration; F16 owns UI test modernization; F16.5 owns architecture hardening if triggered.

## Known Evidence
F01 complete. F02 complete. F03 complete. Full UI smoke has known failures. FAANG handoff remains PARTIAL. Legacy language/internal identifier debt remains. `TodayExecutionViewState.swift` exceeds the architecture threshold and F03.5 is the next safe batch.

## Source-of-truth references

<!-- AMB-291-SOURCE-OF-TRUTH-REFERENCES: BEGIN -->

This file must not be treated as standalone active canon. Current authority must be resolved through:

- `docs/truth/README.md`
- `docs/truth/PRODUCT_DESIGN_TRUTH.md`
- `docs/truth/PRODUCT_MOAT_TRUTH.md`
- `docs/truth/IMPLEMENTATION_TRUTH.md`
- `docs/truth/RELEASE_TRUTH.md`
- `docs/truth/CODEX_PROCESS_TRUTH.md`
- `docs/truth/HISTORICAL_POLICY.md`
- `docs/codex/GLOBAL_BATCH_SEQUENCE_AUTHORITY.json`
- `docs/codex/IOS26_FLAGSHIP_TRAIN_MANIFEST.yml`
- `docs/ops/change-protocol/change-request-template.md`
- `docs/ops/change-protocol/change-impact-check.md`
- `docs/ops/change-protocol/implementation-prompt-template.md`
- `docs/ops/change-protocol/post-implementation-proof-reconciliation.md`

<!-- AMB-291-SOURCE-OF-TRUTH-REFERENCES: END -->

## Non-claims

<!-- AMB-291-NON-CLAIMS: BEGIN -->

- This file does not prove implementation.
- This file does not prove build success.
- This file does not prove test success.
- This file does not prove accessibility validation.
- This file does not prove performance validation.
- This file does not prove device validation.
- This file does not prove privacy/legal approval.
- This file does not prove TestFlight readiness.
- This file does not prove App Store readiness.
- This file does not prove release readiness.
- Linear status is not repo truth.

<!-- AMB-291-NON-CLAIMS: END -->
