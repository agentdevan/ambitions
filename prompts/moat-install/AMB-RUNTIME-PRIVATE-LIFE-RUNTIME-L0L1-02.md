<!-- AMBITIONS_RUNNER_REQUIRED: true -->
<!-- RUN_WITH: scripts/ambitions-codex-train.sh -->
<!-- DIRECT_CODEX_EXECUTION: forbidden_unless_user_explicitly_bypasses_runner -->

# AMB-RUNTIME-PRIVATE-LIFE-RUNTIME-L0L1-02

## Batch ID
AMB-RUNTIME-PRIVATE-LIFE-RUNTIME-L0L1-02

## Runner command
scripts/ambitions-codex-train.sh AMB-RUNTIME-PRIVATE-LIFE-RUNTIME-L0L1-02 prompts/moat-install/AMB-RUNTIME-PRIVATE-LIFE-RUNTIME-L0L1-02.md

## Objective
Install private-life runtime spec with L0-L4 maturity and runtime-only decision ownership.

## Active source truth to inspect
- docs/truth/PRODUCT_MOAT_TRUTH.md
- docs/authority/AMB_ROOT_IA_CANON.md
- docs/runtime/AMB_PRIVATE_LIFE_RUNTIME_SPEC.md

## Allowed scope
- update `docs/runtime/AMB_PRIVATE_LIFE_RUNTIME_SPEC.md`
- update `docs/contracts/AMB_PROJECTION_CONTRACT_REGISTRY.md`
- adjust runtime-related authority docs

## Forbidden scope
- frontend ranking logic in this batch
- adding app runtime code

## Implementation requirements
- enforce runtime ownership of Start Here, source freshness, closure truth, and not-chosen reasons
- define entity set in `docs/runtime/AMB_PRIVATE_LIFE_RUNTIME_SPEC.md`
- ensure projection contracts identify runtime identity ownership

## Validation expectations
- python3 scripts/ambitions_validate_runtime_authority.py
- python3 scripts/ambitions_validate_projection_contracts.py

## Accessibility expectations
- Preserve VoiceOver semantic summaries, labels/values/hints, Dynamic Type resilience, Reduce Motion equivalents, hit targets, focus order, color-independent meaning, motion-independent meaning, privacy-safe wording, and stale/conflict/unavailable state accessibility where applicable.
- No accessibility claim may be marked Green from intent alone.

## Hard Red stop conditions
- UI claimed to select final Start Here candidate
- runtime identity omitted in required contracts
- closure mutation outside command pipeline claims

## Rollback expectations
- restore runtime contract edits only.
- keep existing source code unchanged.

## Visual proof expectations
- none required.

## Privacy / trust expectations
- no cloud AI required claim in runtime definitions.

## Continuity expectations
- runtime unavailable and conflict states documented.

## Expected final report format
AMB-RUNTIME-PRIVATE-LIFE-RUNTIME-L0L1-02 — Final Report

Status: Green / Yellow / Red

1. Summary
2. Files created
3. Files modified
4. Source truth inspected
5. Runtime ownership proof
6. Contracts updated
7. Fixtures added
8. Validators added
9. Validation commands run
10. Validation outputs
11. Rollback instructions
12. Hard Red checks
13. Known Yellow items
14. Known Red items
15. Next runner command

## Immediate next runner command
scripts/ambitions-codex-train.sh AMB-BRIDGE-RUNTIME-FRONTEND-PROJECTION-CONTRACTS-03 prompts/moat-install/AMB-BRIDGE-RUNTIME-FRONTEND-PROJECTION-CONTRACTS-03.md
