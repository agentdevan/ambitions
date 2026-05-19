<!-- AMBITIONS_RUNNER_REQUIRED: true -->
<!-- RUN_WITH: scripts/ambitions-codex-train.sh -->
<!-- DIRECT_CODEX_EXECUTION: forbidden_unless_user_explicitly_bypasses_runner -->

# AMB-CONTINUITY-APPLE-NATIVE-CONFLICT-RESTORE-PROOF-10

## Batch ID
AMB-CONTINUITY-APPLE-NATIVE-CONFLICT-RESTORE-PROOF-10

## Runner command
scripts/ambitions-codex-train.sh AMB-CONTINUITY-APPLE-NATIVE-CONFLICT-RESTORE-PROOF-10 prompts/moat-install/AMB-CONTINUITY-APPLE-NATIVE-CONFLICT-RESTORE-PROOF-10.md

## Objective
Install continuity proof model for Apple-native sync conflict and restore.

## Active source truth to inspect
- docs/continuity/AMB_APPLE_CONTINUITY_CONFLICT_RESTORE_SPEC.md
- docs/contracts/AMB_PROJECTION_CONTRACT_REGISTRY.md

## Allowed scope
- docs/continuity/
- docs/release/
- docs/proof/

## Forbidden scope
- claiming continuity complete without conflict/restore receipts

## Implementation requirements
- define conflict, partial restore, migration, offline queue, and degraded states.
- link continuity receipt fields to release claims.

## Validation expectations
- python3 scripts/ambitions_validate_continuity_claims.py
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

## Hard Red stop conditions
- source freshness after restore absent
- conflict review not represented as product object

## Rollback expectations
- revert continuity and claim docs only.

## Continuity expectations
- no synced/restore-ready claim without proof artifacts.

## Expected final report format
AMB-CONTINUITY-APPLE-NATIVE-CONFLICT-RESTORE-PROOF-10 — Final Report

Status: Green / Yellow / Red

1. Summary
2. Files modified
3. Continuity states added
4. Validation commands run
5. Validation outputs
6. Rollback instructions
7. Known Yellow items
8. Known Red items
9. Next runner command

## Immediate next runner command
scripts/ambitions-codex-train.sh AMB-ACCESSIBILITY-SEMANTIC-EQUIVALENTS-DENSE-RUNTIME-11 prompts/moat-install/AMB-ACCESSIBILITY-SEMANTIC-EQUIVALENTS-DENSE-RUNTIME-11.md
