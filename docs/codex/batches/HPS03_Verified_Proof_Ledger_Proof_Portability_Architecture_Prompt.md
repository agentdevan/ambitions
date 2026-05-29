# HPS03 Verified Proof Ledger Proof Portability Architecture Prompt

<!-- AMB-291-CANON-HYGIENE-REPAIR: BEGIN -->

> AMB-291 repair status: **canon-hygiene-reconciled**
> This file was reviewed as part of the actual canon content/hygiene rewrite pass.
> It is not standalone active product truth. Use `docs/truth/*` and current manifest/sequence authority before implementation.
> Conflict types reconciled: same_surface_multiple_active_batches
> Prior recommended actions: Expedite
> Candidate references: AMB28-same_surface_multiple_active_batches-26899932

<!-- AMB-291-CANON-HYGIENE-REPAIR: END -->

<!-- AMB-291-CANON-HYGIENE-HEADER: BEGIN -->

> Canon hygiene status: **execution-work-order-needs-sequencing**
> AMB-291 note: This batch/prompt is a work-order artifact and must be sequenced before execution.
> Active authority: `docs/truth/*`, `docs/codex/GLOBAL_BATCH_SEQUENCE_AUTHORITY.json`, and `docs/codex/IOS26_FLAGSHIP_TRAIN_MANIFEST.yml`.
> Before using this file for implementation, run `make change-impact-check` and follow `docs/ops/change-protocol/implementation-prompt-template.md`.
> Resolution classes: authority-rewrite, merge-overlap
> Dispositions: merge-or-sequence-surface-ownership, rewrite-authority-reference

<!-- AMB-291-CANON-HYGIENE-HEADER: END -->
<!-- markdownlint-disable MD013 -->

Status: Complete / Accepted Yellow as docs-domain architecture.
Date: 2026-05-06
Train: HPS01-HPS12 Human Progress Systems Upgrade Train
Owner: Proof Trust / Source Truth

## Purpose

Define the Verified Proof Ledger and proof portability architecture that
Ambitions, AOS, LDI, Source Atlas, Found Life, Goal paths, Action Closure,
export/import, and external-surface work must inherit.

HPS03 is docs-domain architecture only. It does not implement a runtime ledger,
schema, persistence, export format, verifier product, public credential,
marketplace, sync, cloud, account, AI runtime, or UI.

## Allowed Files

- HPS03 canon/prompt/report docs
- HPS train status
- global-order, registry, context, dependency, and run-state docs

## Forbidden Files

- Production Swift
- Persistence/schema/migration files
- Runtime proof ledger store
- Export/import implementation
- Sync/cloud/account/backend
- Hosted AI or model adapter implementation
- Verifier roles, public credentials, marketplace, API product, or institution
  workflow implementation
- Top-level navigation or visible all-proof control surface
- Source Atlas runtime, PDF/OCR, URL import, pack download/update, or official
  source behavior
- Release/App Store/TestFlight/device/accessibility/acquisition claims

## Required Acceptance

- Proof object families exist.
- Proof state fields exist.
- Proof strength and portability states exist.
- Proof-to-requirement mapping exists.
- Privacy and redaction rules exist.
- Future verifier boundary exists without product implementation.
- API contract families exist for proof read, proposal, portability, and
  receipt.
- Silent proof creation, promotion, export, or externalization is forbidden.
- Proof remains user-owned and never becomes a score, feed, marketplace, public
  credential, or official validation claim.

## Validation

Run docs-only validation and targeted CQS scans. Missing HPS physical advisory
scripts remain accepted Yellow under the HPS Codex OS owner until implemented.

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
