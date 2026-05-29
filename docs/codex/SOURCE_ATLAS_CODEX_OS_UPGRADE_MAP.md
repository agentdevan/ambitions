# Source Atlas Codex OS Upgrade Map

<!-- AMB-291-CANON-HYGIENE-REPAIR: BEGIN -->

> AMB-291 repair status: **canon-hygiene-reconciled**
> This file was reviewed as part of the actual canon content/hygiene rewrite pass.
> It is not standalone active product truth. Use `docs/truth/*` and current manifest/sequence authority before implementation.
> Conflict types reconciled: same_source_file_targeted_by_multiple_active_batches, same_surface_multiple_active_batches
> Prior recommended actions: Expedite, Merge
> Candidate references: AMB28-same_source_file_targeted_by_multiple_active_batches-12644284, AMB28-same_source_file_targeted_by_multiple_active_batches-21433652, AMB28-same_source_file_targeted_by_multiple_active_batches-26774985, AMB28-same_source_file_targeted_by_multiple_active_batches-42833998, AMB28-same_source_file_targeted_by_multiple_active_batches-52105410, AMB28-same_source_file_targeted_by_multiple_active_batches-57517626, AMB28-same_source_file_targeted_by_multiple_active_batches-80089837, AMB28-same_source_file_targeted_by_multiple_active_batches-86054496, AMB28-same_surface_multiple_active_batches-66075429

<!-- AMB-291-CANON-HYGIENE-REPAIR: END -->

<!-- AMB-291-CANON-HYGIENE-HEADER: BEGIN -->

> Canon hygiene status: **codex-reference**
> AMB-291 note: This Codex reference supports process or execution, but active truth remains in docs/truth and current manifests.
> Active authority: `docs/truth/*`, `docs/codex/GLOBAL_BATCH_SEQUENCE_AUTHORITY.json`, and `docs/codex/IOS26_FLAGSHIP_TRAIN_MANIFEST.yml`.
> Before using this file for implementation, run `make change-impact-check` and follow `docs/ops/change-protocol/implementation-prompt-template.md`.
> Resolution classes: authority-rewrite, merge-overlap
> Dispositions: merge-or-sequence-file-ownership, merge-or-sequence-surface-ownership, rewrite-authority-reference

<!-- AMB-291-CANON-HYGIENE-HEADER: END -->
<!-- markdownlint-disable MD013 -->

Status: Active Codex OS upgrade map for Source Atlas and SAP composition/projection lock.
Date: 2026-05-06

## Purpose

Source Atlas is a trust-critical system. This map makes Source Atlas enforceable by Codex through reviewer skills, advisory scripts, reports, stop conditions, and composition/projection anti-sprawl gates.

## Required reviewer skills

Create or invoke equivalent protocols for:

1. `source-atlas-architect`
2. `source-pack-schema-reviewer`
3. `source-claim-state-reviewer`
4. `requirement-graph-reviewer`
5. `proof-map-reviewer`
6. `universal-source-binder-reviewer`
7. `source-container-coverage-reviewer`
8. `url-source-import-reviewer`
9. `pdf-ocr-extraction-reviewer`
10. `source-claim-review-flow-reviewer`
11. `source-pack-validator-reviewer`
12. `source-freshness-broker-reviewer`
13. `user-source-privacy-reviewer`
14. `source-atlas-no-claim-reviewer`
15. `source-atlas-fvq-reviewer`
16. `source-atlas-pack-factory-reviewer`
17. `source-atlas-aos-ldi-integration-reviewer`
18. `source-atlas-composition-architect`
19. `goal-projection-reviewer`
20. `capability-graph-reviewer`
21. `projection-recipe-reviewer`
22. `alternative-path-option-value-reviewer`
23. `pack-duplication-reviewer`
24. `generated-step-boundary-reviewer`

Each skill must define:

- files to inspect
- pass criteria
- Yellow criteria
- Hard Red criteria
- required tests/previews
- privacy/source/no-claim risks
- composition/projection risks when relevant
- required report sections

## Required advisory scripts

Create or invoke equivalent scripts:

- `scripts/sa-source-container-coverage-scan.sh`
- `scripts/sa-pack-schema-validate.sh`
- `scripts/sa-pack-validate.sh`
- `scripts/sa-no-claim-scan.sh`
- `scripts/sa-source-freshness-scan.sh`
- `scripts/sa-ocr-review-required-scan.sh`
- `scripts/sa-user-source-not-official-scan.sh`
- `scripts/sa-offline-fallback-scan.sh`
- `scripts/sa-source-ui-fvq-scan.sh`
- `scripts/sa-high-risk-claim-scan.sh`
- `scripts/sa-pack-revocation-rollback-scan.sh`
- `scripts/sa-private-document-leak-scan.sh`
- `scripts/sa-fixture-coverage-scan.sh`
- `scripts/sa-composition-projection-scan.sh`
- `scripts/sa-pack-duplication-scan.sh`
- `scripts/sa-projection-fixture-coverage-scan.sh`
- `scripts/sa-generated-step-boundary-scan.sh`
- `scripts/sa-alternative-path-option-value-scan.sh`

Scripts must be non-mutating by default, safe to run locally, and must not print private source contents or secrets.

## Mandatory invocation triggers

Source Atlas review is mandatory when work touches:

- source packs
- claim states
- requirements
- starter kits
- proof maps
- freshness
- source import
- URL/PDF/image/text parsing
- OCR
- user source review
- source/freshness UI
- AOS/LDI source integration
- job posting parsing
- school/certification parsing
- legal/civic/professional source handling
- Pack Factory tooling
- Freshness Broker manifests
- source pack signatures/revocation/rollback
- domain packs
- capability graphs
- level ladders
- role overlays
- requirement overlays
- path overlays
- projection recipes
- GoalProjection
- PersonalPathInstance
- StepCandidateSeed
- AlternativePathSet
- OptionValueMap
- pack composition or aliasing

## Batch report additions

Source Atlas batch reports must include:

- Source Atlas primitives touched
- source containers touched
- document categories touched
- source states covered
- privacy states covered
- review flow status
- no-claim scan status
- offline fallback status
- composition/projection status
- duplicate pack/claim status
- skill-slice status if relevant
- highest-path reuse status if relevant
- alternative path / option value status if relevant
- generated-step boundary status if relevant
- FVQ rendered proof status if UI-affecting
- AOS/LDI integration status if relevant
- unresolved Yellow items with owner

## Hard Red additions

Stop on:

- user-provided source labeled official
- OCR output saved as official/current without review
- job posting treated as universal requirement
- school/certification eligibility guaranteed
- hidden claim/goal/proof/memory mutation
- private document text printed to logs or analytics
- source pack loads without validation
- stale high-risk claim drives recommendation as current
- app requires internet for basic cached/source-needed behavior
- Source Atlas standalone top-level source surface or marketplace appears
- hosted AI/user-data-server/live-API dependency is introduced without explicit scope/legal review
- one pack per individual goal phrase
- pro/elite pack duplicates lower-level graph nodes instead of reusing shared nodes
- narrow skill goal loads entire elite/pro path without reason
- final scheduled steps are stored as universal pack output
- PersonalPathInstance cannot vary by user context
- serious path has no alternative path/option value handling or explicit no-known-alternative statement

## Physical skill requirements

SA04 created physical skill files for the first composition/projection reviewer
set:

- `.codex/skills/source-atlas-composition-architect/SKILL.md`
- `.codex/skills/goal-projection-reviewer/SKILL.md`
- `.codex/skills/capability-graph-reviewer/SKILL.md`
- `.codex/skills/projection-recipe-reviewer/SKILL.md`
- `.codex/skills/alternative-path-option-value-reviewer/SKILL.md`
- `.codex/skills/pack-duplication-reviewer/SKILL.md`
- `.codex/skills/generated-step-boundary-reviewer/SKILL.md`

If physical scripts are not yet created, batches must mark the gap Yellow with owner and cannot close runtime implementation as Green if the missing script would have caught a touched failure mode.

## Closeout

SA32 cannot close until all skills/scripts are created or mapped, every SA/SAP gate is owned, and later AOS/LDI/FCP/PFC batches have mandatory Source Atlas and composition/projection review triggers.

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
