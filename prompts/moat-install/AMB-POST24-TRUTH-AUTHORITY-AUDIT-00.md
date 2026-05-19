<!-- AMBITIONS_RUNNER_REQUIRED: true -->
<!-- RUN_WITH: scripts/ambitions-codex-train.sh -->
<!-- DIRECT_CODEX_EXECUTION: forbidden_unless_user_explicitly_bypasses_runner -->

# AMB-POST24-TRUTH-AUTHORITY-AUDIT-00

## Batch ID
AMB-POST24-TRUTH-AUTHORITY-AUDIT-00

## Runner command
scripts/ambitions-codex-train.sh AMB-POST24-TRUTH-AUTHORITY-AUDIT-00 prompts/moat-install/AMB-POST24-TRUTH-AUTHORITY-AUDIT-00.md

## Objective
Create the post-24 authority audit report and classify legacy vs active content.

## Active source truth to inspect
- docs/truth/README.md
- docs/truth/PRODUCT_DESIGN_TRUTH.md
- docs/truth/PRODUCT_MOAT_TRUTH.md
- docs/truth/IMPLEMENTATION_TRUTH.md
- AGENTS.md

## Allowed scope
- create/update `docs/authority/*`
- create/update `docs/moats/`
- create/update prompt headers and authority-only registry files

## Forbidden scope
- app source changes
- UI implementation
- new dependencies

## Implementation requirements
- Install `docs/authority/AMB_POST24_TRUTH_AUDIT.md` with active/supporting/historical tags.
- Include explicit Plan/Habits/Insights/Profile conflict checks.
- Add current source-truth precedence and next known unknowns.

## Validation expectations
- python3 scripts/ambitions_validate_authority_drift.py
- python3 scripts/ambitions_validate_prompt_headers.py

## Accessibility expectations
- Preserve VoiceOver semantic summaries, labels/values/hints, Dynamic Type resilience, Reduce Motion equivalents, hit targets, focus order, color-independent meaning, motion-independent meaning, privacy-safe wording, and stale/conflict/unavailable state accessibility where applicable.
- No accessibility claim may be marked Green from intent alone.

## Hard Red stop conditions
- cannot resolve root IA from active source truth
- active authority conflict with old top-level IA

## Rollback expectations
- delete only created files for this batch if no longer valid.
- restore tracked files in `docs/authority/*` as needed.

## Visual proof expectations
- Not applicable for this docs-only authority batch.

## Privacy / trust expectations
- none required

## Continuity expectations
- none required

## Expected final report format
AMB-POST24-TRUTH-AUTHORITY-AUDIT-00 — Final Report

Status: Green / Yellow / Red

1. Summary
2. Files created
3. Files modified
4. Source truth inspected
5. Authority changes
6. Claim registry updates
7. Validation commands run
8. Validation outputs
9. Hard Red checks
10. Known Yellow items
11. Known Red items
12. Next runner command

## Immediate next runner command
scripts/ambitions-codex-train.sh AMB-CATEGORY-PERSONAL-LIFE-OS-CANON-01 prompts/moat-install/AMB-CATEGORY-PERSONAL-LIFE-OS-CANON-01.md
