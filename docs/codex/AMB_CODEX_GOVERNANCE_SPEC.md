# AMB_CODEX_GOVERNANCE_SPEC

## Runner policy

- Every batch must use:
  - `scripts/ambitions-codex-train.sh`
  - or `make batch BATCH=<id> PROMPT=<path>`
- Required prompt header:
  - `<!-- AMBITIONS_RUNNER_REQUIRED: true -->`
  - `<!-- RUN_WITH: scripts/ambitions-codex-train.sh -->`
  - `<!-- DIRECT_CODEX_EXECUTION: forbidden_unless_user_explicitly_bypasses_runner -->`

## Validation gates

- `scripts/ambitions_validate_prompt_headers.py`
- `scripts/ambitions_validate_batch_ids.py`
- `scripts/ambitions_validate_authority_drift.py`
- `scripts/ambitions_validate_claim_registry.py`
- `scripts/ambitions_validate_projection_contracts.py`
- `scripts/ambitions_validate_runtime_authority.py`
- `scripts/ambitions_validate_proof_receipts.py`
- `scripts/ambitions_validate_visual_proof.py`
- `scripts/ambitions_validate_accessibility_gates.py`
- `scripts/ambitions_validate_trust_privacy.py`
- `scripts/ambitions_validate_continuity_claims.py`
- `scripts/ambitions_validate_moat_install.py`
- `make validate-ambitions-os`

## Hard-red boundaries

- Duplicate batch IDs
- missing headers
- active authority drift
- release-ready claims without proof
- prompt header violations
- irreversible deletions

## No false Green contract

- Claims remain Yellow unless evidence commands and proof paths are in repo artifacts.

## Rollback format

- revert only docs/scripts in this scope.
- remove only generated prompts that failed governance.
- keep historical evidence and source files untouched unless explicit follow-up.
