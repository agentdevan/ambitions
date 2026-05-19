<!-- AMBITIONS_RUNNER_REQUIRED: true -->
<!-- RUN_WITH: scripts/ambitions-codex-train.sh -->
<!-- DIRECT_CODEX_EXECUTION: forbidden_unless_user_explicitly_bypasses_runner -->

# AMB-INTELLIGENCE-CLOSURE-LEARNING-LOCAL-MEMORY-05

## Batch ID
AMB-INTELLIGENCE-CLOSURE-LEARNING-LOCAL-MEMORY-05

## Runner command
scripts/ambitions-codex-train.sh AMB-INTELLIGENCE-CLOSURE-LEARNING-LOCAL-MEMORY-05 prompts/moat-install/AMB-INTELLIGENCE-CLOSURE-LEARNING-LOCAL-MEMORY-05.md

## Objective
Define closure learning and local memory controls as recovery-first runtime proof assets.

## Active source truth to inspect
- docs/truth/PRODUCT_MOAT_TRUTH.md
- docs/trust/AMB_LOCAL_FIRST_TRUST_SPEC.md
- docs/contracts/AMB_PROJECTION_CONTRACT_REGISTRY.md

## Allowed scope
- docs/proof/ and docs/trust/
- docs/runtime/

## Forbidden scope
- automatic coercive behavior changes without closure receipts

## Implementation requirements
- add closure receipt path and local memory controls in proof/trust docs
- define recovery-first decision mutation and blocked-goal unstick assumptions

## Validation expectations
- python3 scripts/ambitions_validate_proof_receipts.py
- python3 scripts/ambitions_validate_trust_privacy.py

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
- closure mutation without command/receipt trace
- claims without evidence in trust section

## Rollback expectations
- remove trust/proof additions only.

## Expected final report format
AMB-INTELLIGENCE-CLOSURE-LEARNING-LOCAL-MEMORY-05 — Final Report

Status: Green / Yellow / Red

1. Summary
2. Files modified
3. Source truth inspected
4. Runtime/proof changes
5. Claims updated
6. Validation commands run
7. Validation outputs
8. Rollback plan
9. Known Yellow items
10. Known Red items
11. Next runner command

## Immediate next runner command
scripts/ambitions-codex-train.sh AMB-PROOF-RECEIPTS-FRESHNESS-WHY-NOT-CHOSEN-06 prompts/moat-install/AMB-PROOF-RECEIPTS-FRESHNESS-WHY-NOT-CHOSEN-06.md
