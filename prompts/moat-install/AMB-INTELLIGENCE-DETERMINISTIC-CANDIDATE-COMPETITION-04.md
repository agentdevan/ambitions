<!-- AMBITIONS_RUNNER_REQUIRED: true -->
<!-- RUN_WITH: scripts/ambitions-codex-train.sh -->
<!-- DIRECT_CODEX_EXECUTION: forbidden_unless_user_explicitly_bypasses_runner -->

# AMB-INTELLIGENCE-DETERMINISTIC-CANDIDATE-COMPETITION-04

## Batch ID
AMB-INTELLIGENCE-DETERMINISTIC-CANDIDATE-COMPETITION-04

## Runner command
scripts/ambitions-codex-train.sh AMB-INTELLIGENCE-DETERMINISTIC-CANDIDATE-COMPETITION-04 prompts/moat-install/AMB-INTELLIGENCE-DETERMINISTIC-CANDIDATE-COMPETITION-04.md

## Objective
Install deterministic candidate competition and ranking/critic constraints in docs contracts and runtime map.

## Active source truth to inspect
- docs/moats/AMB_MOAT_OS_IMPLEMENTATION_MAP.md
- docs/contracts/AMB_PROJECTION_CONTRACT_REGISTRY.md

## Allowed scope
- docs/moats and contracts and proof spec additions

## Forbidden scope
- runtime code changes
- claim deterministic loop Green without replay evidence

## Implementation requirements
- define `CandidateRankingLedger`, `ConstraintFirewall`, `RuntimeCritic`, and `DecisionReplayContract` in contracts/runtime references.
- note fallback/recovery behavior for runtime unavailable and stale source.

## Validation expectations
- python3 scripts/ambitions_validate_projection_contracts.py
- python3 scripts/ambitions_validate_runtime_authority.py
- python3 scripts/ambitions_validate_moat_install.py

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
- missing fallback path for unavailable state
- missing not-chosen reasons semantics

## Rollback expectations
- revert updated moats/proof references if invariants fail.

## Expected final report format
AMB-INTELLIGENCE-DETERMINISTIC-CANDIDATE-COMPETITION-04 — Final Report

Status: Green / Yellow / Red

1. Summary
2. Files modified
3. Contracts updated
4. Source truth inspected
5. Validation expectations
6. Validation outputs
7. Hard Red checks
8. Rollback instructions
9. Known Yellow items
10. Known Red items
11. Next runner command

## Immediate next runner command
scripts/ambitions-codex-train.sh AMB-INTELLIGENCE-CLOSURE-LEARNING-LOCAL-MEMORY-05 prompts/moat-install/AMB-INTELLIGENCE-CLOSURE-LEARNING-LOCAL-MEMORY-05.md
