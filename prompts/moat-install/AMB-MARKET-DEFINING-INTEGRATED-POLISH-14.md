<!-- AMBITIONS_RUNNER_REQUIRED: true -->
<!-- RUN_WITH: scripts/ambitions-codex-train.sh -->
<!-- DIRECT_CODEX_EXECUTION: forbidden_unless_user_explicitly_bypasses_runner -->

# AMB-MARKET-DEFINING-INTEGRATED-POLISH-14

## Batch ID
AMB-MARKET-DEFINING-INTEGRATED-POLISH-14

## Runner command
scripts/ambitions-codex-train.sh AMB-MARKET-DEFINING-INTEGRATED-POLISH-14 prompts/moat-install/AMB-MARKET-DEFINING-INTEGRATED-POLISH-14.md

## Objective
Finalize integrated polish and cross-surface consistency checks for installer artifacts.

## Active source truth to inspect
- docs/moats/AMB_MOAT_OS_IMPLEMENTATION_MAP.md
- docs/contracts/AMB_PROJECTION_CONTRACT_REGISTRY.md

## Allowed scope
- docs/moats
- docs/proof
- docs/visual

## Forbidden scope
- any new source code

## Implementation requirements
- ensure cross-surface consistency checks and state matrix references exist.
- align polish claims with release and accessibility matrices.

## Validation expectations
- python3 scripts/ambitions_validate_moat_install.py
- make validate-ambitions-os

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
- cross-surface mismatch without fixture coverage

## Rollback expectations
- revert only docs modifications for this batch.

## Expected final report format
AMB-MARKET-DEFINING-INTEGRATED-POLISH-14 — Final Report

Status: Green / Yellow / Red

1. Summary
2. Files modified
3. Cross-surface consistency checks
4. Source truth inspected
5. Validation commands run
6. Validation outputs
7. Hard Red checks
8. Rollback instructions
9. Known Yellow items
10. Known Red items
11. Next runner command

## Immediate next runner command
scripts/ambitions-codex-train.sh AMB-OS-INTEGRATED-FREEZE-NO-FALSE-GREEN-15 prompts/moat-install/AMB-OS-INTEGRATED-FREEZE-NO-FALSE-GREEN-15.md
