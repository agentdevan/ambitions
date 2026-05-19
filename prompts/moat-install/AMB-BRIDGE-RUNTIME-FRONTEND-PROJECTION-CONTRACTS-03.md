<!-- AMBITIONS_RUNNER_REQUIRED: true -->
<!-- RUN_WITH: scripts/ambitions-codex-train.sh -->
<!-- DIRECT_CODEX_EXECUTION: forbidden_unless_user_explicitly_bypasses_runner -->

# AMB-BRIDGE-RUNTIME-FRONTEND-PROJECTION-CONTRACTS-03

## Batch ID
AMB-BRIDGE-RUNTIME-FRONTEND-PROJECTION-CONTRACTS-03

## Runner command
scripts/ambitions-codex-train.sh AMB-BRIDGE-RUNTIME-FRONTEND-PROJECTION-CONTRACTS-03 prompts/moat-install/AMB-BRIDGE-RUNTIME-FRONTEND-PROJECTION-CONTRACTS-03.md

## Objective
Install bridge contract map between runtime, bridge, and frontend projections.

## Active source truth to inspect
- docs/truth/IMPLEMENTATION_TRUTH.md
- docs/runtime/AMB_PRIVATE_LIFE_RUNTIME_SPEC.md
- docs/contracts/AMB_PROJECTION_CONTRACT_REGISTRY.md

## Allowed scope
- docs/contracts/
- docs/proof/
- docs/codex/AMB_CODEX_GOVERNANCE_SPEC.md

## Forbidden scope
- implement runtime/frontend bridge code
- claim contract readiness without schema fields

## Implementation requirements
- Ensure required contracts list and all required contract fields exist.
- Add runtime/projection identity and unavailable states for each contract.
- Keep migration/versioning requirements explicit.

## Validation expectations
- python3 scripts/ambitions_validate_projection_contracts.py
- python3 scripts/ambitions_validate_claim_registry.py

## Accessibility expectations
- Preserve VoiceOver semantic summaries, labels/values/hints, Dynamic Type resilience, Reduce Motion equivalents, hit targets, focus order, color-independent meaning, motion-independent meaning, privacy-safe wording, and stale/conflict/unavailable state accessibility where applicable.
- No accessibility claim may be marked Green from intent alone.

## Hard Red stop conditions
- missing required contract
- missing runtime identity on core contracts
- contract with ambiguous ownership

## Rollback expectations
- remove and restore contract/proof specs only.

## Visual proof expectations
- none.

## Privacy / trust expectations
- include privacy semantics in every contract.

## Continuity expectations
- continuity contract must include conflict and partial restore semantics.

## Expected final report format
AMB-BRIDGE-RUNTIME-FRONTEND-PROJECTION-CONTRACTS-03 — Final Report

Status: Green / Yellow / Red

1. Summary
2. Files created
3. Files modified
4. Source truth inspected
5. Contracts added/updated
6. Missing contract remediations
7. Validation commands run
8. Validation outputs
9. Rollback instructions
10. Known Yellow items
11. Known Red items
12. Next runner command

## Immediate next runner command
scripts/ambitions-codex-train.sh AMB-INTELLIGENCE-DETERMINISTIC-CANDIDATE-COMPETITION-04 prompts/moat-install/AMB-INTELLIGENCE-DETERMINISTIC-CANDIDATE-COMPETITION-04.md
