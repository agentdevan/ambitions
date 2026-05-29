# AmbitionsOS AOS Source Truth Claim Ledger

<!-- AMB-291-CANON-HYGIENE-HEADER: BEGIN -->

> Canon hygiene status: **codex-reference-needs-owner-triage**
> AMB-291 note: This Codex reference is retained but requires owner/status clarification before it drives implementation.
> Active authority: `docs/truth/*`, `docs/codex/GLOBAL_BATCH_SEQUENCE_AUTHORITY.json`, and `docs/codex/IOS26_FLAGSHIP_TRAIN_MANIFEST.yml`.
> Before using this file for implementation, run `make change-impact-check` and follow `docs/ops/change-protocol/implementation-prompt-template.md`.
> Resolution classes: authority-rewrite, merge-overlap, status-expedite
> Dispositions: clarify-status-before-use, merge-or-sequence-file-ownership, rewrite-authority-reference

<!-- AMB-291-CANON-HYGIENE-HEADER: END -->

Status: Future source-truth claim ledger

Every source-sensitive claim records claim, domain, source state, freshness, official verification need, user-facing label, affected decisions, tests, and review date.

## AOS17 Privacy Safety Kernel

Status: Green value-contract proof.

Claim boundary:

- inferred memory is not treated as fact without review
- source-backed privacy projection remains review-gated for sensitive areas
- user-provided or inferred sensitive material is not official/current proof by default
- external projection requires redaction posture and receipt proof

Evidence:

- `Native/Ambitions/Domain/AmbitionsOSPrivacySafetyModels.swift`
- `Native/AmbitionsTests/Domain/AmbitionsOSPrivacySafetyModelsTests.swift`
- `docs/audits/aos17-privacy-safety-kernel-report.md`

Not claimed:

- official source verification
- source import runtime
- privacy compliance
- legal review completion
- source freshness proof

## AOS18 Evaluation Golden Scenarios

Status: Green value-contract proof.

Claim boundary:

- source-sensitive and high-risk scenarios require ready review and non-blocking
  freshness before consequential evaluation can be treated as passed
- generated or user-provided source material is not official/current proof by
  default
- claim-truth scenarios must block unsupported release, device, platform,
  public-accessibility, legal/privacy, source-certification, AI runtime, LDI
  runtime, and production-readiness claims unless evidence exists
- passed scenarios require evidence links or proof receipts

Evidence:

- `Native/Ambitions/Domain/AmbitionsOSEvaluationModels.swift`
- `Native/AmbitionsTests/Domain/AmbitionsOSEvaluationModelsTests.swift`
- `docs/audits/aos18-evaluation-golden-scenarios-report.md`

Not claimed:

- official source verification
- source import runtime
- source freshness proof
- evaluation runner runtime
- model evaluation runtime
- release/platform/device/public-accessibility/legal/privacy readiness

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
