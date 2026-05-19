<!-- AMBITIONS_RUNNER_REQUIRED: true -->
<!-- RUN_WITH: scripts/ambitions-codex-train.sh -->
<!-- DIRECT_CODEX_EXECUTION: forbidden_unless_user_explicitly_bypasses_runner -->

# AMB-TRUST-LOCAL-FIRST-PRIVACY-HONESTY-USER-CONTROLS-09

## Batch ID
AMB-TRUST-LOCAL-FIRST-PRIVACY-HONESTY-USER-CONTROLS-09

## Runner command
scripts/ambitions-codex-train.sh AMB-TRUST-LOCAL-FIRST-PRIVACY-HONESTY-USER-CONTROLS-09 prompts/moat-install/AMB-TRUST-LOCAL-FIRST-PRIVACY-HONESTY-USER-CONTROLS-09.md

## Objective
Install trust posture, local-first controls, and privacy-honesty constraints.

## Active source truth to inspect
- docs/truth/PRODUCT_MOAT_TRUTH.md
- docs/trust/AMB_LOCAL_FIRST_TRUST_SPEC.md

## Allowed scope
- docs/trust/
- docs/release/AMB_CLAIM_REGISTRY.md

## Forbidden scope
- adding analytics/cloud AI claims as required core behavior
- overclaiming privacy without evidence

## Implementation requirements
- enforce claims for offline, delete/reset/export, local memory controls, and no cloud dependency.
- map each to proof status and validation command.

## Validation expectations
- python3 scripts/ambitions_validate_trust_privacy.py
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
- missing dependency scan proof fields
- privacy claim set to Green without artifact IDs

## Rollback expectations
- revert trust and claim updates only.

## Privacy expectations
- include privacy redaction and third-party dependency scan controls.

## Expected final report format
AMB-TRUST-LOCAL-FIRST-PRIVACY-HONESTY-USER-CONTROLS-09 — Final Report

Status: Green / Yellow / Red

1. Summary
2. Files modified
3. Trust/proof fields added
4. Validation commands run
5. Validation outputs
6. Privacy proof status
7. Rollback instructions
8. Known Yellow items
9. Known Red items
10. Next runner command

## Immediate next runner command
scripts/ambitions-codex-train.sh AMB-CONTINUITY-APPLE-NATIVE-CONFLICT-RESTORE-PROOF-10 prompts/moat-install/AMB-CONTINUITY-APPLE-NATIVE-CONFLICT-RESTORE-PROOF-10.md
