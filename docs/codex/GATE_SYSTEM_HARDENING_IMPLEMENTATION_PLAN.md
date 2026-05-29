# Gate System Hardening Implementation Plan

<!-- AMB-291-CANON-HYGIENE-HEADER: BEGIN -->

> Canon hygiene status: **codex-reference**
> AMB-291 note: This Codex reference supports process or execution, but active truth remains in docs/truth and current manifests.
> Active authority: `docs/truth/*`, `docs/codex/GLOBAL_BATCH_SEQUENCE_AUTHORITY.json`, and `docs/codex/IOS26_FLAGSHIP_TRAIN_MANIFEST.yml`.
> Before using this file for implementation, run `make change-impact-check` and follow `docs/ops/change-protocol/implementation-prompt-template.md`.
> Resolution classes: authority-rewrite
> Dispositions: rewrite-authority-reference

<!-- AMB-291-CANON-HYGIENE-HEADER: END -->

Status: Active implementation plan for converting Ambitions' existing gate toolkit into a more deterministic gate system.
Date: 2026-05-06

## Source audit basis

The Deep Research gate audit classifies the repository as having:

- implemented gate framework artifacts
- implemented downstream gate usage in several real batches
- partial CI hard enforcement
- planned/future train-specific gate families
- absent compiled gate engine / structured machine-readable ledger

This plan directly targets the audit's recommended next steps:

1. Wire CQS/advisory scans into CI.
2. Add a machine-readable gate-result manifest.
3. Strengthen gate-backed code/reporting only through named matrix paths.
4. Formalize commit provenance in closeout reporting.

## Product constraint

This is Codex OS / governance hardening only.

It must not:

- edit product Swift behavior
- claim release/TestFlight/App Store readiness
- convert future AOS/HPS/Source Atlas matrices into implemented runtime behavior
- treat advisory gates as universal hard blockers before strictness policy is explicitly declared
- create false proof of completed batches

## Implementation slices

### GH01 — CI advisory gate job

Add a GitHub Actions workflow that runs CQS and Source Atlas advisory scans in non-mutating mode.

Default behavior:

- pull_request: run advisory scans and upload/report output
- push to main: run advisory scans
- strict failure only for mechanical/file-integrity issues, not all advisory warnings

Rationale: the audit found that current workflows focus on build/test/archive while CQS scripts are not visibly wired into CI.

### GH02 — Gate result manifest schema

Add a JSON schema/template for gate outcomes.

Required fields:

- manifest id/version
- batch id/train id
- git branch/base/head
- commit provenance
- invoked skills
- invoked scripts
- gate results
- strict/advisory mode
- Yellow/Red items
- no-claim boundaries
- validation commands
- generated artifacts
- next eligible batch

### GH03 — Gate result validator

Add a local validator script that verifies manifests contain required fields and valid result statuses.

The validator must be non-mutating and safe for CI.

### GH04 — Batch report template upgrade

Update the batch report template to require a linked machine-readable gate manifest and commit provenance section.

### GH05 — Closeout prompt

Add a reusable Codex prompt that makes future batches create/update gate manifests without guessing.

## Strictness policy

Initial CI should be advisory-first because existing scripts were explicitly designed as advisory unless strict mode is enabled.

Hard failures should be limited to:

- script execution failure caused by repo/tooling breakage
- invalid gate manifest JSON
- missing required files when the batch claims gate closure
- private content leak in known scan paths
- production/release/App Store/current official claims without evidence

Future strict mode can be raised per train after each scan has low false positives.

## Expected result

After this plan is implemented, Ambitions will have:

- CI visibility for CQS/Source Atlas advisory scans
- a structured gate-result ledger format
- local manifest validation
- stronger batch closeout provenance
- reduced reliance on prose-only Markdown reports

This still does not create a compiled runtime gate engine or product-feature implementation. It is the next enforcement layer between governance docs and CI-hard policy.

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
