<!-- AMBITIONS_RUNNER_REQUIRED: true -->
<!-- RUN_WITH: scripts/ambitions-codex-train.sh -->
<!-- DIRECT_CODEX_EXECUTION: forbidden_unless_user_explicitly_bypasses_runner -->

# AMB-OS-INTEGRATED-FREEZE-NO-FALSE-GREEN-15

## Batch ID
AMB-OS-INTEGRATED-FREEZE-NO-FALSE-GREEN-15

## Runner command
scripts/ambitions-codex-train.sh AMB-OS-INTEGRATED-FREEZE-NO-FALSE-GREEN-15 prompts/moat-install/AMB-OS-INTEGRATED-FREEZE-NO-FALSE-GREEN-15.md

## Objective
Run the final installer freeze that prevents false Green and prepares next actionable runner command.

## Active source truth to inspect
- docs/release/AMB_CLAIM_REGISTRY.md
- docs/codex/AMB_CODEX_GOVERNANCE_SPEC.md
- scripts/ambitions_validate_*.py

## Allowed scope
- docs/release/
- docs/codex/
- scripts/
- Makefile

## Forbidden scope
- claiming release readiness with missing evidence
- removing validator or prompt coverage

## Implementation requirements
- run all validation commands.
- mark unresolved claims as Yellow and unresolved blockers as Red where required.
- produce complete installer final report and rollback instructions.

## Validation expectations
- all validator commands listed in this batch
- make validate-ambitions-os
- git diff --check

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
- duplicate batch IDs
- missing required downstream prompts
- any proof claim without required artifacts

## Rollback expectations
- revert all docs and prompt files in this installer scope.

## Expected final report format
AMB-OS-INTEGRATED-FREEZE-NO-FALSE-GREEN-15 — Final Report

Status: Green / Yellow / Red

1. Summary
2. Files created
3. Files modified
4. Source truth inspected
5. Validators status
6. Visual proof status
7. Accessibility proof status
8. Trust status
9. Continuity status
10. Claim registry status
11. Hard Red checks
12. Validation commands run
13. Validation outputs
14. Rollback instructions
15. Known Yellow items
16. Known Red items
17. Immediate next runner command
