<!-- AMBITIONS_RUNNER_REQUIRED: true -->
<!-- RUN_WITH: scripts/ambitions-codex-train.sh -->
<!-- DIRECT_CODEX_EXECUTION: forbidden_unless_user_explicitly_bypasses_runner -->

# AMB-CODEX-BATCH-TRAINS-VALIDATORS-HARD-RED-ROLLBACK-12

## Batch ID
AMB-CODEX-BATCH-TRAINS-VALIDATORS-HARD-RED-ROLLBACK-12

## Runner command
scripts/ambitions-codex-train.sh AMB-CODEX-BATCH-TRAINS-VALIDATORS-HARD-RED-ROLLBACK-12 prompts/moat-install/AMB-CODEX-BATCH-TRAINS-VALIDATORS-HARD-RED-ROLLBACK-12.md

## Objective
Install and standardize all installer validators and no-false-green rules.

## Active source truth to inspect
- docs/authority/AMB_CODEX_GOVERNANCE_SPEC.md
- docs/truth/CODEX_PROCESS_TRUTH.md

## Allowed scope
- scripts/ambitions_validate_*.py
- Makefile validation targets

## Forbidden scope
- non-standard libs in installers
- bypassing duplicate batch ID checks
- wrapping text before prompt header

## Implementation requirements
- create/update all validator scripts under standard-library Python constraints.
- add Makefile targets listed in the installer objective.
- keep validation output machine-readable and Green/Red clear.

## Validation expectations
- python3 scripts/ambitions_validate_prompt_headers.py
- python3 scripts/ambitions_validate_batch_ids.py
- python3 scripts/ambitions_validate_authority_drift.py
- python3 scripts/ambitions_validate_claim_registry.py
- python3 scripts/ambitions_validate_projection_contracts.py
- python3 scripts/ambitions_validate_runtime_authority.py
- python3 scripts/ambitions_validate_proof_receipts.py
- python3 scripts/ambitions_validate_visual_proof.py
- python3 scripts/ambitions_validate_accessibility_gates.py
- python3 scripts/ambitions_validate_trust_privacy.py
- python3 scripts/ambitions_validate_continuity_claims.py
- python3 scripts/ambitions_validate_moat_install.py
- make validate-ambitions-os

## Visual proof expectations
- Not applicable unless this batch changes UI, visual specs, screenshot candidate identity, or visual proof claims.
- No visual or screenshot readiness may be marked Green without registry-backed source proof and validation evidence.

## Accessibility expectations
- Preserve VoiceOver semantic summaries, labels/values/hints, Dynamic Type resilience, Reduce Motion equivalents, hit targets, focus order, color-independent meaning, motion-independent meaning, privacy-safe wording, and stale/conflict/unavailable state accessibility where applicable.
- No accessibility claim may be marked Green from intent alone.

## Privacy / trust expectations
- Preserve local-first/on-device-first posture, no required cloud AI, no analytics SDK, no custom server dependency, receipt-backed changes, privacy redaction expectations, and proof-backed trust claims where applicable.
- No local-first, private, no-cloud-AI, no-analytics, offline, export, delete/reset, or trust claim may be marked Green without evidence.

## Continuity expectations
- Not applicable unless this batch touches iCloud/CloudKit, sync, restore, migration, offline queue, conflict, source freshness after restore, or continuity claims.
- No synced/restored/continuity-complete claim may be marked Green without conflict/restore/migration/source-freshness proof.

## Hard Red stop conditions
- duplicate batch IDs
- missing headers
- release claim without proof linkage

## Rollback expectations
- revert validator edits and Makefile changes only.

## Expected final report format
AMB-CODEX-BATCH-TRAINS-VALIDATORS-HARD-RED-ROLLBACK-12 — Final Report

Status: Green / Yellow / Red

1. Summary
2. Files created
3. Files modified
4. Validator set status
5. Validation commands run
6. Validation outputs
7. Hard Red checks
8. Rollback instructions
9. Known Yellow items
10. Known Red items
11. Next runner command

## Immediate next runner command
scripts/ambitions-codex-train.sh AMB-RELEASE-CLAIM-REGISTRY-PROOF-SCREENSHOT-CANDIDATE-13 prompts/moat-install/AMB-RELEASE-CLAIM-REGISTRY-PROOF-SCREENSHOT-CANDIDATE-13.md
