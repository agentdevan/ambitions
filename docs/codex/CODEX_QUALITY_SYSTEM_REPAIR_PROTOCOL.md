# Codex Quality System Repair Protocol

<!-- AMB-291-CANON-HYGIENE-HEADER: BEGIN -->

> Canon hygiene status: **codex-reference**
> AMB-291 note: This Codex reference supports process or execution, but active truth remains in docs/truth and current manifests.
> Active authority: `docs/truth/*`, `docs/codex/GLOBAL_BATCH_SEQUENCE_AUTHORITY.json`, and `docs/codex/IOS26_FLAGSHIP_TRAIN_MANIFEST.yml`.
> Before using this file for implementation, run `make change-impact-check` and follow `docs/ops/change-protocol/implementation-prompt-template.md`.
> Resolution classes: authority-rewrite, terminology-quarantine
> Dispositions: quarantine-or-rewrite-terminology, rewrite-authority-reference

<!-- AMB-291-CANON-HYGIENE-HEADER: END -->
<!-- markdownlint-disable MD013 -->

Status: Active CQS repair protocol
Date: 2026-05-05

## Classifications

- Green: batch scope complete, validation adequate or strong, no unresolved
  safety risk.
- Accepted Yellow: nonblocking risk is documented with owner, repair path, and
  explicit no-claim boundary.
- Recoverable Red: failure is caused by current work and can be repaired in
  scope without weakening canon, broad refactor, hidden mutation, or product
  invention.
- Hard Red: continuing would break the app, corrupt data, weaken canon, hide a
  security/privacy issue, require human proof, require unsupported legal/
  release claims, or require deleting tests/weakening gates.

## Repair Loop

1. Reproduce or identify the failure.
2. Classify whether it is current-batch-caused.
3. Repair only the smallest in-scope owner files.
4. Rerun the needs review validation plus the minimum adjacent proof.
5. Repeat once if the second repair is narrower and evidence improves.
6. Split a repair batch only when the split lowers risk and has clear owner
   files.
7. Stop as Hard Red when no safe repair path remains.

## Accepted Yellow Rules

Accepted Yellow is allowed only when the remaining issue is non-destructive,
bounded, documented, and has an owner. It must not cover build failure, data
loss, security exposure, hidden mutation, unsupported claims, or product drift.

## Stop Report Requirements

A Hard Red stop report must include exact blocker, files touched, rollback path,
operator checklist, validation logs, evidence gaps, and the exact resume prompt
after the blocker is resolved.

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
