# AFI01 — Canon Language Purge

<!-- AMB-291-CANON-HYGIENE-HEADER: BEGIN -->

> Canon hygiene status: **execution-work-order-needs-sequencing**
> AMB-291 note: This batch/prompt is a work-order artifact and must be sequenced before execution.
> Active authority: `docs/truth/*`, `docs/codex/GLOBAL_BATCH_SEQUENCE_AUTHORITY.json`, and `docs/codex/IOS26_FLAGSHIP_TRAIN_MANIFEST.yml`.
> Before using this file for implementation, run `make change-impact-check` and follow `docs/ops/change-protocol/implementation-prompt-template.md`.
> Resolution classes: authority-rewrite, merge-overlap
> Dispositions: merge-or-sequence-surface-ownership, rewrite-authority-reference

<!-- AMB-291-CANON-HYGIENE-HEADER: END -->

<!-- markdownlint-disable MD013 -->

Status: Complete / Accepted Yellow
Owner: Ambitions Flagship Interface
Scope: docs/canon, docs/codex, reports, helper scans

## Purpose

Remove compatibility names from active canon, active prompts, visual QA, and
global train language. Preserve legacy terms only when they are clearly marked
as Archive, Migration, historical evidence, compatibility debt, or explicit
hard-Red guardrails.

## Required Source Truth

- `docs/AmbitionsCanon/10_Ambitions_Flagship_Interface_Canon.md`
- `docs/AmbitionsCanon/01A_Product_Canon_Flagship_Amendment.md`
- `docs/AmbitionsCanon/11_Canonical_Vocabulary_And_Copy_Bible.md`
- `docs/AmbitionsCanon/15_AFI_Implementation_Lane.md`
- `docs/codex/AMBITIONS_CANON_UI_COMPLETION_INSERTION_OVERLAY.md`
- `docs/audits/afi-stash-reconciliation-report.md`

## Result

Accepted Yellow.

Active AFI language now names the top-level interface as:

```text
Today / Goals / Capture / Time / You
```

`Plan` is not a top-level destination. It remains valid as contextual/action
language such as Adjust plan, Shape week, Review pressure, or compatibility
history.

## Allowed Changes

- Canon language corrections.
- Global-order and run-state corrections.
- Helper-scan banned-term updates.
- Closeout/report updates.

## Forbidden Changes

- Production Swift changes.
- Route/raw-value/persistence/schema changes.
- New app feature behavior.
- Visual Green, accessibility conformance, device, release, App Store,
  TestFlight, privacy/legal, or production-readiness claims.

## Validation

- Banned-name scan over active AFI/governance files.
- `bash -n` for touched helper scripts.
- `git diff --check`.
- ACX quick/docs/batch-closeout bundles.

## Yellow Carry

Historical docs and old batch evidence may still contain Plan-era terminology.
Those are not active canon. AFI02 must lock the hierarchy and continue reducing
any remaining ambiguity where old evidence is not explicitly historical.

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
