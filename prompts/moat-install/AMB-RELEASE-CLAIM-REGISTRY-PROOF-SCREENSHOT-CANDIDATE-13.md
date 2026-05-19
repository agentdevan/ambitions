<!-- AMBITIONS_RUNNER_REQUIRED: true -->
<!-- RUN_WITH: scripts/ambitions-codex-train.sh -->
<!-- DIRECT_CODEX_EXECUTION: forbidden_unless_user_explicitly_bypasses_runner -->

# AMB-RELEASE-CLAIM-REGISTRY-PROOF-SCREENSHOT-CANDIDATE-13

## Batch ID
AMB-RELEASE-CLAIM-REGISTRY-PROOF-SCREENSHOT-CANDIDATE-13

## Runner command
scripts/ambitions-codex-train.sh AMB-RELEASE-CLAIM-REGISTRY-PROOF-SCREENSHOT-CANDIDATE-13 prompts/moat-install/AMB-RELEASE-CLAIM-REGISTRY-PROOF-SCREENSHOT-CANDIDATE-13.md

## Objective
Complete release claim registry and screenshot candidate proof registry.

## Active source truth to inspect
- docs/release/AMB_CLAIM_REGISTRY.md
- docs/visual/AMB_SCREENSHOT_CANDIDATE_REGISTRY.md

## Allowed scope
- docs/release/

## Forbidden scope
- marking claim rows Green without evidence columns

## Implementation requirements
- include all required release and screenshot claims.
- keep claim matrix with source proof and validation command columns.
- enforce screenshot scenes required by installer spec.

## Validation expectations
- python3 scripts/ambitions_validate_claim_registry.py
- python3 scripts/ambitions_validate_visual_proof.py

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
- claim rows with invalid proof-less Green
- required screenshot candidate omitted

## Rollback expectations
- restore claim registry files only.

## Visual proof expectations
- required screenshot scenes in registry and validation commands.

## Expected final report format
AMB-RELEASE-CLAIM-REGISTRY-PROOF-SCREENSHOT-CANDIDATE-13 — Final Report

Status: Green / Yellow / Red

1. Summary
2. Files modified
3. Claims added/updated
4. Screenshot scenes added
5. Validation commands run
6. Validation outputs
7. Hard Red checks
8. Rollback instructions
9. Known Yellow items
10. Known Red items
11. Next runner command

## Immediate next runner command
scripts/ambitions-codex-train.sh AMB-MARKET-DEFINING-INTEGRATED-POLISH-14 prompts/moat-install/AMB-MARKET-DEFINING-INTEGRATED-POLISH-14.md
