<!-- AMBITIONS_RUNNER_REQUIRED: true -->
<!-- RUN_WITH: scripts/ambitions-codex-train.sh -->
<!-- DIRECT_CODEX_EXECUTION: forbidden_unless_user_explicitly_bypasses_runner -->

# AMB-VISUAL-PERSONAL-REALITY-INSTRUMENT-FOUNDATION-07

## Batch ID
AMB-VISUAL-PERSONAL-REALITY-INSTRUMENT-FOUNDATION-07

## Runner command
scripts/ambitions-codex-train.sh AMB-VISUAL-PERSONAL-REALITY-INSTRUMENT-FOUNDATION-07 prompts/moat-install/AMB-VISUAL-PERSONAL-REALITY-INSTRUMENT-FOUNDATION-07.md

## Objective
Define projection-bound visual system components and premium interaction primitives.

## Active source truth to inspect
- docs/truth/PRODUCT_DESIGN_TRUTH.md
- docs/visual/AMB_PERSONAL_REALITY_INSTRUMENT_SPEC.md

## Allowed scope
- docs/visual/
- docs/accessibility/

## Forbidden scope
- stack-of-cards dashboard primitives as core pattern
- claim visual claims without proof/contract mapping

## Implementation requirements
- lock visual objects to projection contracts.
- define visual design system terms in docs/visual.
- include reduced-motion equivalents.

## Validation expectations
- python3 scripts/ambitions_validate_visual_proof.py
- python3 scripts/ambitions_validate_accessibility_gates.py

## Accessibility expectations
- Preserve VoiceOver semantic summaries, labels/values/hints, Dynamic Type resilience, Reduce Motion equivalents, hit targets, focus order, color-independent meaning, motion-independent meaning, privacy-safe wording, and stale/conflict/unavailable state accessibility where applicable.
- No accessibility claim may be marked Green from intent alone.

## Continuity expectations
- Not applicable unless this batch touches iCloud/CloudKit, sync, restore, migration, offline queue, conflict, source freshness after restore, or continuity claims.
- No synced/restored/continuity-complete claim may be marked Green without conflict/restore/migration/source-freshness proof.

## Hard Red stop conditions
- visual surface claims without contract or screenshot metadata
- unsupported motion semantics

## Rollback expectations
- revert visual spec only.

## Visual proof expectations
- required screenshot scenes in `docs/visual/AMB_SCREENSHOT_CANDIDATE_REGISTRY.md`.

## Privacy / trust expectations
- ensure privacy redaction mode appears in visual spec.

## Expected final report format
AMB-VISUAL-PERSONAL-REALITY-INSTRUMENT-FOUNDATION-07 — Final Report

Status: Green / Yellow / Red

1. Summary
2. Files created
3. Files modified
4. Visual moats updated
5. Visual proof status
6. Validation commands run
7. Validation outputs
8. Rollback instructions
9. Known Yellow items
10. Known Red items
11. Next runner command

## Immediate next runner command
scripts/ambitions-codex-train.sh AMB-VISUAL-FLAGSHIP-SURFACES-TODAY-GOALS-CAPTURE-TIME-YOU-08 prompts/moat-install/AMB-VISUAL-FLAGSHIP-SURFACES-TODAY-GOALS-CAPTURE-TIME-YOU-08.md
