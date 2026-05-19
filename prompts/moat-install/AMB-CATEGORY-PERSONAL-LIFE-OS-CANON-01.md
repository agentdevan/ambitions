<!-- AMBITIONS_RUNNER_REQUIRED: true -->
<!-- RUN_WITH: scripts/ambitions-codex-train.sh -->
<!-- DIRECT_CODEX_EXECUTION: forbidden_unless_user_explicitly_bypasses_runner -->

# AMB-CATEGORY-PERSONAL-LIFE-OS-CANON-01

## Batch ID
AMB-CATEGORY-PERSONAL-LIFE-OS-CANON-01

## Runner command
scripts/ambitions-codex-train.sh AMB-CATEGORY-PERSONAL-LIFE-OS-CANON-01 prompts/moat-install/AMB-CATEGORY-PERSONAL-LIFE-OS-CANON-01.md

## Objective
Install the category moat canon: Personal Life OS framing and active anti-generic IA model.

## Active source truth to inspect
- docs/truth/PRODUCT_DESIGN_TRUTH.md
- docs/truth/PRODUCT_MOAT_TRUTH.md
- docs/truth/IMPLEMENTATION_TRUTH.md
- docs/authority/AMB_MOAT_OS_AUTHORITY_MODEL.md

## Allowed scope
- docs/authority/AMB_MOAT_OS_AUTHORITY_MODEL.md
- docs/authority/AMB_ROOT_IA_CANON.md
- docs/moats/AMB_MOAT_OS_IMPLEMENTATION_MAP.md

## Forbidden scope
- introducing top-level Plan, Habits, Insights, Profile
- task/calendar/chatbot framing

## Implementation requirements
- lock category to Personal Life OS in authority docs
- lock top-level IA to Today / Goals / Capture / Time / You
- classify obsolete/legacy authority terms in obsolete register

## Validation expectations
- python3 scripts/ambitions_validate_authority_drift.py
- python3 scripts/ambitions_validate_batch_ids.py

## Accessibility expectations
- Preserve VoiceOver semantic summaries, labels/values/hints, Dynamic Type resilience, Reduce Motion equivalents, hit targets, focus order, color-independent meaning, motion-independent meaning, privacy-safe wording, and stale/conflict/unavailable state accessibility where applicable.
- No accessibility claim may be marked Green from intent alone.

## Hard Red stop conditions
- mismatch between active truth and documented top-level IA
- evidence-less category claims made Green

## Rollback expectations
- remove changes to authority files and restore previous versions only for these files.

## Visual proof expectations
- Not applicable.

## Privacy / trust expectations
- avoid task-list and shame language.

## Continuity expectations
- none required.

## Expected final report format
AMB-CATEGORY-PERSONAL-LIFE-OS-CANON-01 — Final Report

Status: Green / Yellow / Red

1. Summary
2. Files created
3. Files modified
4. Source truth inspected
5. Authority changes
6. Incompatibility fixes
7. Claim registry changes
8. Validation commands run
9. Validation outputs
10. Hard Red checks
11. Rollback instructions
12. Known Yellow items
13. Known Red items
14. Next runner command

## Immediate next runner command
scripts/ambitions-codex-train.sh AMB-RUNTIME-PRIVATE-LIFE-RUNTIME-L0L1-02 prompts/moat-install/AMB-RUNTIME-PRIVATE-LIFE-RUNTIME-L0L1-02.md
