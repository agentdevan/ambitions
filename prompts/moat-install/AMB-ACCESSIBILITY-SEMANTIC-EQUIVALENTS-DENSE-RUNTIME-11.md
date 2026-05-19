<!-- AMBITIONS_RUNNER_REQUIRED: true -->
<!-- RUN_WITH: scripts/ambitions-codex-train.sh -->
<!-- DIRECT_CODEX_EXECUTION: forbidden_unless_user_explicitly_bypasses_runner -->

# AMB-ACCESSIBILITY-SEMANTIC-EQUIVALENTS-DENSE-RUNTIME-11

## Batch ID
AMB-ACCESSIBILITY-SEMANTIC-EQUIVALENTS-DENSE-RUNTIME-11

## Runner command
scripts/ambitions-codex-train.sh AMB-ACCESSIBILITY-SEMANTIC-EQUIVALENTS-DENSE-RUNTIME-11 prompts/moat-install/AMB-ACCESSIBILITY-SEMANTIC-EQUIVALENTS-DENSE-RUNTIME-11.md

## Objective
Install semantic-accessibility matrix for dense runtime intelligence and flagship surfaces.

## Active source truth to inspect
- docs/truth/IMPLEMENTATION_TRUTH.md
- docs/accessibility/AMB_ACCESSIBILITY_MOAT_MATRIX.md

## Allowed scope
- docs/accessibility/

## Forbidden scope
- claiming accessibility Green without semantic equivalent coverage

## Implementation requirements
- require each dense surface in matrix with VO, DT, Reduce Motion, and state coverage.
- include error/conflict/unavailable semantics.

## Validation expectations
- python3 scripts/ambitions_validate_accessibility_gates.py

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
- missing core surfaces
- color-only meaning in required surfaces

## Rollback expectations
- restore accessibility matrix only.

## Expected final report format
AMB-ACCESSIBILITY-SEMANTIC-EQUIVALENTS-DENSE-RUNTIME-11 — Final Report

Status: Green / Yellow / Red

1. Summary
2. Files modified
3. Required surface matrix status
4. Validation commands run
5. Validation outputs
6. Rollback instructions
7. Known Yellow items
8. Known Red items
9. Next runner command

## Immediate next runner command
scripts/ambitions-codex-train.sh AMB-CODEX-BATCH-TRAINS-VALIDATORS-HARD-RED-ROLLBACK-12 prompts/moat-install/AMB-CODEX-BATCH-TRAINS-VALIDATORS-HARD-RED-ROLLBACK-12.md
