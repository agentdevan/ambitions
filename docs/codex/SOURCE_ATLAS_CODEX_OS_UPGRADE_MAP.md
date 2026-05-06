# Source Atlas Codex OS Upgrade Map
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
- Source Atlas dashboard/tab/marketplace appears
- hosted AI/user-data-server/live-API dependency is introduced without explicit scope/legal review
- one pack per individual goal phrase
- pro/elite pack duplicates lower-level graph nodes instead of reusing shared nodes
- narrow skill goal loads entire elite/pro path without reason
- final scheduled steps are stored as universal pack output
- PersonalPathInstance cannot vary by user context
- serious path has no alternative path/option value handling or explicit no-known-alternative statement

## Physical skill requirements

SAP05 or the earliest Source Atlas Codex OS batch must create or map physical skill files for:

- `.codex/skills/source-atlas-composition-architect.md`
- `.codex/skills/goal-projection-reviewer.md`
- `.codex/skills/capability-graph-reviewer.md`
- `.codex/skills/projection-recipe-reviewer.md`
- `.codex/skills/alternative-path-option-value-reviewer.md`
- `.codex/skills/pack-duplication-reviewer.md`
- `.codex/skills/generated-step-boundary-reviewer.md`

If physical scripts are not yet created, batches must mark the gap Yellow with owner and cannot close runtime implementation as Green if the missing script would have caught a touched failure mode.

## Closeout

SA32 cannot close until all skills/scripts are created or mapped, every SA/SAP gate is owned, and later AOS/LDI/FCP/PFC batches have mandatory Source Atlas and composition/projection review triggers.
