<!-- AMB-291-CANON-HYGIENE-HEADER: BEGIN -->

> Canon hygiene status: **execution-work-order-needs-sequencing**
> AMB-291 note: This batch/prompt is a work-order artifact and must be sequenced before execution.
> Active authority: `docs/truth/*`, `docs/codex/GLOBAL_BATCH_SEQUENCE_AUTHORITY.json`, and `docs/codex/IOS26_FLAGSHIP_TRAIN_MANIFEST.yml`.
> Before using this file for implementation, run `make change-impact-check` and follow `docs/ops/change-protocol/implementation-prompt-template.md`.
> Resolution classes: authority-rewrite, merge-overlap, merge-overlap-before-proof
> Dispositions: merge-before-proof, merge-or-sequence-authority, merge-or-sequence-file-ownership, merge-or-sequence-surface-ownership, rewrite-authority-reference

<!-- AMB-291-CANON-HYGIENE-HEADER: END -->
<!-- AMBITIONS_RUNNER_REQUIRED: true -->
<!-- RUN_WITH: scripts/ambitions-codex-train.sh -->
<!-- DIRECT_CODEX_EXECUTION: forbidden_unless_user_explicitly_bypasses_runner -->

# AMB-POST23-02-UNDERDELIVERY-REPAIR

This runner batch repairs only high-priority under-delivery found by `AMB-POST23-01-TRUTH-AUDIT`.

Use these repo OS files as controlling instructions:

- `docs/codex/batch-trains/post-23-truth-audit/AMB-POST23-TRUTH-AUDIT-MANIFEST.md`
- `docs/codex/batch-trains/post-23-truth-audit/AMB-POST23-TRUTH-AUDIT-REPAIR-ROUTING.md`
- `docs/codex/batch-trains/post-23-truth-audit/AMB-POST23-TRUTH-AUDIT-CLASSIFICATION-RUBRIC.md`

Frontend authority is mandatory for any UI/source-facing repair in this batch.
Consume the Encyclopedia Frontend OS before touching SwiftUI or surface code:

- `ENCYCLOPEDIA_TO_FRONTEND_OS`
- `frontend-authority-packet`
- `frontend-authority-preflight`
- `build/reports/frontend-authority-packets`
- `build/reports/frontend-authority-preflight`

Surface ID: `today_root_reality_meridian`
Surface ID: `goals_root_constellation_atlas`
Surface ID: `capture_root_atmosphere_composer`
Surface ID: `time_root_lifeshape_field`
Surface ID: `you_root_user_system_profile`

Allowed scope is bounded repair of the original 23-batch foundation. Do not install UI Suite implementation, Backend Flagship, Frontend Flagship, Apple continuity implementation, custom server work, or broad redesign.

Required output:

`docs/codex/reports/AMB-POST23-02-UNDERDELIVERY-REPAIR.md`

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
