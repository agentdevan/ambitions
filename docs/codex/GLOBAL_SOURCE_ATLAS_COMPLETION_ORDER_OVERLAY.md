# Global Source Atlas Completion Order Overlay

<!-- AMB-291-CANON-HYGIENE-HEADER: BEGIN -->

> Canon hygiene status: **codex-reference**
> AMB-291 note: This Codex reference supports process or execution, but active truth remains in docs/truth and current manifests.
> Active authority: `docs/truth/*`, `docs/codex/GLOBAL_BATCH_SEQUENCE_AUTHORITY.json`, and `docs/codex/IOS26_FLAGSHIP_TRAIN_MANIFEST.yml`.
> Before using this file for implementation, run `make change-impact-check` and follow `docs/ops/change-protocol/implementation-prompt-template.md`.
> Resolution classes: authority-rewrite, merge-overlap
> Dispositions: merge-or-sequence-surface-ownership, rewrite-authority-reference

<!-- AMB-291-CANON-HYGIENE-HEADER: END -->
<!-- markdownlint-disable MD013 -->

Status: Active high-priority overlay for inserting Source Atlas before deep AOS/LDI and source/freshness-dependent work.
Date: 2026-05-06

## Purpose

This overlay inserts Source Atlas into the global full-stack train as the source/freshness/claim substrate required for real-world requirement intelligence.

It does not replay completed work. It controls only the earliest safe remaining insertion point.

## Preferred placement

1. Finish active batch safely.
2. Do not replay completed FCP/PFC/FL/FVQ/CQS/HPS work.
3. Run HPS01-HPS12 if not already Green or accepted Yellow.
4. Run SA01-SA32.
5. Continue deep AOS runtime batches.
6. Continue LDI runtime batches.
7. Continue source/freshness-dependent platform or external surface implementation.

## Required insertion condition

Source Atlas must run before any unimplemented batch that:

- compiles real-world requirements
- generates dream/path requirements
- claims official/current source knowledge
- parses user-provided URL/PDF/image/text sources
- uses OCR-derived source text
- maps proof to external requirements
- updates paths from changed source claims
- drives Start Here from external source requirements
- performs AOS/LDI source truth runtime behavior

## Phase SA — Source Atlas Full Maturity

SA01 Source Atlas Canon Lock.
SA02 Source Atlas Gate Matrix.
SA03 Universal Source Binder Coverage Map.
SA04 Source Atlas Codex OS Upgrade.
SA05 Source Atlas Global Order And Integration Lock.
SA06 Pack Schema Implementation.
SA07 Claim State Machine.
SA08 Requirement Graph Implementation.
SA09 Proof Map Implementation.
SA10 Freshness And Risk Model Implementation.
SA11 Source Atlas Store.
SA12 Source Atlas Query Engine.
SA13 Source Needed Mode.
SA14 Local Impact Matcher.
SA15 Offline Fallback Runtime.
SA16 Source Container Model.
SA17 URL Source Importer.
SA18 Plain Text Importer.
SA19 PDF Import Boundary.
SA20 PDFKit Text Extraction.
SA21 Vision OCR Fallback.
SA22 Image / Screenshot Importer.
SA23 Document Type Classifier.
SA24 Claim Candidate Extractor.
SA25 Source Review Sheet / Claim Review Drawer.
SA26 User Mini-Pack Builder.
SA27 Pack Factory Lite.
SA28 Pack Diff / Changed Claim Tooling.
SA29 Hash / Signature / Revocation Tooling.
SA30 Freshness Broker Manifest Contract.
SA31 Official Source Adapter Contracts.
SA32 Source Atlas UI Primitives / QA / Handoff.

## Blocks until Source Atlas closes

Unless a batch is explicitly docs-only and independent of external source requirements, the following must not perform runtime source/requirement intelligence until SA closes Green or accepted Yellow with owners:

- AOS Goal Path Compiler runtime that uses real-world requirements.
- AOS Start Here recommendation runtime that cites external requirements.
- AOS Source Truth runtime that claims source freshness.
- LDI Requirement Graph runtime.
- LDI Eligibility/Deadline runtime.
- LDI Freshness Broker runtime.
- LDI Today bridge when external source requirements drive steps.
- Any PDF/OCR/user-source import path.
- Any pack download/update/runtime path.

## Accepted Yellow rule

If the global train has already passed an ideal Source Atlas insertion point, do not replay completed batches. Document accepted Yellow and make Source Atlas govern remaining work, future repair, and handoff.

## No-claim boundary

This overlay does not claim Source Atlas runtime implementation, PDF parsing, OCR behavior, source pack freshness, hosted AI, sync, CloudKit, user-data server, official database, legal compliance, TestFlight readiness, or App Store readiness.

It only defines the required safe ordering and dependency gates.

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
