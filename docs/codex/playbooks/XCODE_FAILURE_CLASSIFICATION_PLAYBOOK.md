# Playbook: Failure Classification

<!-- AMB-291-CANON-HYGIENE-REPAIR: BEGIN -->

> AMB-291 repair status: **canon-hygiene-reconciled**
> This file was reviewed as part of the actual canon content/hygiene rewrite pass.
> It is not standalone active product truth. Use `docs/truth/*` and current manifest/sequence authority before implementation.
> Conflict types reconciled: same_surface_multiple_active_batches, stale_or_unknown_active_status
> Prior recommended actions: Expedite
> Candidate references: AMB28-same_surface_multiple_active_batches-66075429, AMB28-stale_or_unknown_active_status-98390148

<!-- AMB-291-CANON-HYGIENE-REPAIR: END -->

<!-- AMB-291-CANON-HYGIENE-HEADER: BEGIN -->

> Canon hygiene status: **codex-reference-needs-owner-triage**
> AMB-291 note: This Codex reference is retained but requires owner/status clarification before it drives implementation.
> Active authority: `docs/truth/*`, `docs/codex/GLOBAL_BATCH_SEQUENCE_AUTHORITY.json`, and `docs/codex/IOS26_FLAGSHIP_TRAIN_MANIFEST.yml`.
> Before using this file for implementation, run `make change-impact-check` and follow `docs/ops/change-protocol/implementation-prompt-template.md`.
> Resolution classes: authority-rewrite, merge-overlap, merge-overlap-before-proof, status-expedite
> Dispositions: clarify-status-before-use, merge-before-proof, merge-or-sequence-surface-ownership, rewrite-authority-reference

<!-- AMB-291-CANON-HYGIENE-HEADER: END -->

## Core failure classes

- `compile_error` → compile failures
- `test_failure` / `test_discovery_failure`
- `simulator_boot_failure`
- `stale_derived_data` / `xcodegen_project_drift`
- `missing_destination`
- `signing_error`
- `tool_missing`
- `test_timeout`
- `unknown`

## Procedure

1. Use validator summary exit code and `failure_category`.
2. Confirm wrapper emitted class by checking logs and mapped code.
3. Apply targeted repair:
   - `compile_error`, `xcodegen_project_drift`, `stale_derived_data` → compile fix or local DerivedData cleanup
   - `simulator_boot_failure` → simulator repair playbook (one retry)
   - `tool_missing` → install missing tool or run with available fallback
   - `missing_destination` / `test_discovery_failure` → check test selectors or simulator availability

## Rollover policy

- Unknown classes default to exit 26 and must be manually diagnosed before retrying.

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
