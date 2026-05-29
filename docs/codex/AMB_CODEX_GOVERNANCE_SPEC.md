# AMB_CODEX_GOVERNANCE_SPEC

<!-- AMB-291-CANON-HYGIENE-HEADER: BEGIN -->

> Canon hygiene status: **codex-reference**
> AMB-291 note: This Codex reference supports process or execution, but active truth remains in docs/truth and current manifests.
> Active authority: `docs/truth/*`, `docs/codex/GLOBAL_BATCH_SEQUENCE_AUTHORITY.json`, and `docs/codex/IOS26_FLAGSHIP_TRAIN_MANIFEST.yml`.
> Before using this file for implementation, run `make change-impact-check` and follow `docs/ops/change-protocol/implementation-prompt-template.md`.
> Resolution classes: authority-rewrite, merge-overlap, terminology-quarantine
> Dispositions: merge-or-sequence-file-ownership, quarantine-or-rewrite-terminology, rewrite-authority-reference

<!-- AMB-291-CANON-HYGIENE-HEADER: END -->

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
- remove only generated prompts that needs review governance.
- keep historical evidence and source files untouched unless explicit follow-up.

## Source-of-truth references

<!-- AMB-291-SOURCE-OF-TRUTH-REFERENCES: BEGIN -->

This file must not be treated as standalone active canon. Current authority must be resolved through:

- `docs/truth/README.md`
- `docs/truth/PRODUCT_DESIGN_TRUTH.md`
- `docs/truth/PRODUCT_MOAT_TRUTH.md`
- `docs/truth/IMPLEMENTATION_TRUTH.md`
- `docs/truth/RELEASE_TRUTH.md`
- `docs/truth/CODEX_PROCESS_TRUTH.md`
- `docs/truth/HISTORICAL_POLICY.md`
- `docs/codex/GLOBAL_BATCH_SEQUENCE_AUTHORITY.json`
- `docs/codex/IOS26_FLAGSHIP_TRAIN_MANIFEST.yml`
- `docs/ops/change-protocol/change-request-template.md`
- `docs/ops/change-protocol/change-impact-check.md`
- `docs/ops/change-protocol/implementation-prompt-template.md`
- `docs/ops/change-protocol/post-implementation-proof-reconciliation.md`

<!-- AMB-291-SOURCE-OF-TRUTH-REFERENCES: END -->

## Non-claims

<!-- AMB-291-NON-CLAIMS: BEGIN -->

- This file does not prove implementation.
- This file does not prove build success.
- This file does not prove test success.
- This file does not prove accessibility validation.
- This file does not prove performance validation.
- This file does not prove device validation.
- This file does not prove privacy/legal approval.
- This file does not prove TestFlight readiness.
- This file does not prove App Store readiness.
- This file does not prove release readiness.
- Linear status is not repo truth.

<!-- AMB-291-NON-CLAIMS: END -->
