<!-- AMBITIONS_RUNNER_REQUIRED: true -->
<!-- RUN_WITH: scripts/ambitions-codex-train.sh -->
<!-- DIRECT_CODEX_EXECUTION: forbidden_unless_user_explicitly_bypasses_runner -->

# AMB-PROOF-RECEIPTS-FRESHNESS-WHY-NOT-CHOSEN-06

## Batch ID
AMB-PROOF-RECEIPTS-FRESHNESS-WHY-NOT-CHOSEN-06

## Runner command
scripts/ambitions-codex-train.sh AMB-PROOF-RECEIPTS-FRESHNESS-WHY-NOT-CHOSEN-06 prompts/moat-install/AMB-PROOF-RECEIPTS-FRESHNESS-WHY-NOT-CHOSEN-06.md

## Objective
Create proof and receipt specification for why-this/why-now, not-chosen reasons, and source freshness.

## Active source truth to inspect
- docs/truth/RELEASE_TRUTH.md
- docs/proof/AMB_PROOF_RECEIPT_SYSTEM_SPEC.md
- docs/contracts/AMB_PROJECTION_CONTRACT_REGISTRY.md

## Allowed scope
- docs/proof/
- docs/release/AMB_CLAIM_REGISTRY.md

## Forbidden scope
- fake proof claims

## Implementation requirements
- specify required proof fields in proof spec.
- integrate not-chosen reasons and replay identity.
- keep receipt requirements strict and explicit.

## Validation expectations
- python3 scripts/ambitions_validate_proof_receipts.py
- python3 scripts/ambitions_validate_claim_registry.py

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
- proof surface without unavailable/stale state handling
- claim of AI confidence in recommendation proof

## Rollback expectations
- restore proof and release docs only.

## Expected final report format
AMB-PROOF-RECEIPTS-FRESHNESS-WHY-NOT-CHOSEN-06 — Final Report

Status: Green / Yellow / Red

1. Summary
2. Files created
3. Files modified
4. Proof requirements added
5. Validation commands run
6. Validation outputs
7. Rollback instructions
8. Known Yellow items
9. Known Red items
10. Next runner command

## Immediate next runner command
scripts/ambitions-codex-train.sh AMB-VISUAL-PERSONAL-REALITY-INSTRUMENT-FOUNDATION-07 prompts/moat-install/AMB-VISUAL-PERSONAL-REALITY-INSTRUMENT-FOUNDATION-07.md
