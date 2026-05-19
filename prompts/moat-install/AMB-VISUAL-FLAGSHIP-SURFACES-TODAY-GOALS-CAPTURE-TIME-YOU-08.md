<!-- AMBITIONS_RUNNER_REQUIRED: true -->
<!-- RUN_WITH: scripts/ambitions-codex-train.sh -->
<!-- DIRECT_CODEX_EXECUTION: forbidden_unless_user_explicitly_bypasses_runner -->

# AMB-VISUAL-FLAGSHIP-SURFACES-TODAY-GOALS-CAPTURE-TIME-YOU-08

## Batch ID
AMB-VISUAL-FLAGSHIP-SURFACES-TODAY-GOALS-CAPTURE-TIME-YOU-08

## Runner command
scripts/ambitions-codex-train.sh AMB-VISUAL-FLAGSHIP-SURFACES-TODAY-GOALS-CAPTURE-TIME-YOU-08 prompts/moat-install/AMB-VISUAL-FLAGSHIP-SURFACES-TODAY-GOALS-CAPTURE-TIME-YOU-08.md

## Objective
Define flagship surface behavior alignment for Today/Goals/Capture/Time/You with projection coverage.

## Active source truth to inspect
- docs/authority/AMB_ROOT_IA_CANON.md
- docs/visual/AMB_PERSONAL_REALITY_INSTRUMENT_SPEC.md
- docs/accessibility/AMB_ACCESSIBILITY_MOAT_MATRIX.md

## Allowed scope
- docs/visual/
- docs/accessibility/

## Forbidden scope
- changing IA structure

## Implementation requirements
- map each flag ship surface to required contracts and proof states.
- enforce non-generic projection behavior and dense-state semantics.

## Validation expectations
- python3 scripts/ambitions_validate_accessibility_gates.py
- python3 scripts/ambitions_validate_visual_proof.py

## Accessibility expectations
- Preserve VoiceOver semantic summaries, labels/values/hints, Dynamic Type resilience, Reduce Motion equivalents, hit targets, focus order, color-independent meaning, motion-independent meaning, privacy-safe wording, and stale/conflict/unavailable state accessibility where applicable.
- No accessibility claim may be marked Green from intent alone.

## Continuity expectations
- Not applicable unless this batch touches iCloud/CloudKit, sync, restore, migration, offline queue, conflict, source freshness after restore, or continuity claims.
- No synced/restored/continuity-complete claim may be marked Green without conflict/restore/migration/source-freshness proof.

## Hard Red stop conditions
- missing required surfaces from matrix
- no reduction for motion/accessibility edge states

## Rollback expectations
- revert visual surface docs only.

## Visual proof expectations
- update screenshot registry for required states.

## Privacy / trust expectations
- include not-shaming and non-judgment copy.

## Expected final report format
AMB-VISUAL-FLAGSHIP-SURFACES-TODAY-GOALS-CAPTURE-TIME-YOU-08 — Final Report

Status: Green / Yellow / Red

1. Summary
2. Files modified
3. Surface mappings
4. Contract mappings
5. Validation commands run
6. Validation outputs
7. Rollback instructions
8. Known Yellow items
9. Known Red items
10. Next runner command

## Immediate next runner command
scripts/ambitions-codex-train.sh AMB-TRUST-LOCAL-FIRST-PRIVACY-HONESTY-USER-CONTROLS-09 prompts/moat-install/AMB-TRUST-LOCAL-FIRST-PRIVACY-HONESTY-USER-CONTROLS-09.md
