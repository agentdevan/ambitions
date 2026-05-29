# Gate Result Manifest Schema

<!-- AMB-291-CANON-HYGIENE-HEADER: BEGIN -->

> Canon hygiene status: **codex-reference**
> AMB-291 note: This Codex reference supports process or execution, but active truth remains in docs/truth and current manifests.
> Active authority: `docs/truth/*`, `docs/codex/GLOBAL_BATCH_SEQUENCE_AUTHORITY.json`, and `docs/codex/IOS26_FLAGSHIP_TRAIN_MANIFEST.yml`.
> Before using this file for implementation, run `make change-impact-check` and follow `docs/ops/change-protocol/implementation-prompt-template.md`.
> Resolution classes: authority-rewrite, merge-overlap, merge-overlap-before-proof, terminology-quarantine
> Dispositions: merge-before-proof, merge-or-sequence-file-ownership, quarantine-or-rewrite-terminology, rewrite-authority-reference

<!-- AMB-291-CANON-HYGIENE-HEADER: END -->
<!-- markdownlint-disable MD013 -->

Status: Active schema for machine-readable gate closeout manifests.
Date: 2026-05-06
Schema version: `gate-result-manifest.v1`

## Purpose

Markdown batch reports remain the human-readable narrative. Gate result manifests provide the structured ledger needed for deterministic validation, trend analysis, provenance, and future CI hardening.

Every CQS-enhanced batch should create a manifest at:

```text
docs/audits/gate-results/<batch-id>-gate-result.json
```

## Required top-level fields

```json
{
  "schema_version": "gate-result-manifest.v1",
  "manifest_id": "<batch-id>-gate-result",
  "created_at": "YYYY-MM-DDTHH:MM:SSZ",
  "batch": {
    "id": "<BATCH_ID>",
    "name": "<Batch name>",
    "train": "<Train>",
    "result": "green | accepted_yellow | recoverable_red | hard_red",
    "active_before": "<previous active batch or null>",
    "next_eligible": "<next batch or null>"
  },
  "git": {
    "branch": "main",
    "base_sha": "<sha before batch>",
    "head_sha": "<sha after batch>",
    "remote_main_sha": "<origin/main sha at validation>",
    "commit_sha": "<commit sha or null>",
    "commit_author": "<author if available or unknown>",
    "commit_timestamp": "<timestamp if available or unknown>",
    "working_tree_clean": true
  },
  "mode": {
    "strict": false,
    "advisory": true,
    "reason": "CQS scripts are advisory by default unless strict mode is explicitly enabled."
  },
  "skills_invoked": [],
  "scripts_invoked": [],
  "gates": [],
  "validation_commands": [],
  "artifacts": [],
  "yellow_items": [],
  "red_items": [],
  "no_claim_boundaries": [],
  "release_claims": {
    "testflight_ready": false,
    "app_store_ready": false,
    "legal_compliance_claimed": false,
    "production_source_truth_claimed": false
  }
}
```

## Gate result object

Each `gates[]` item must use:

```json
{
  "gate_id": "cqs.product_drift",
  "gate_name": "Product Drift Gate",
  "family": "CQS | FCP | HPS | SA | AOS | LDI | PFC | FVQ | Other",
  "status": "pass | accepted_yellow | recoverable_red | hard_red | not_applicable | not_run",
  "mode": "strict | advisory | manual",
  "evidence": ["file or command evidence"],
  "notes": "short explanation",
  "owner": "owner for Yellow/Red or null"
}
```

## Script invocation object

Each `scripts_invoked[]` item must use:

```json
{
  "script": "scripts/cqs-product-drift-scan.sh",
  "command": "scripts/cqs-product-drift-scan.sh || true",
  "status": "pass | advisory_warning | needs review | not_run",
  "exit_code": 0,
  "strict_mode": false,
  "summary": "short result"
}
```

## Validation command object

Each `validation_commands[]` item must use:

```json
{
  "command": "git diff --check",
  "status": "pass | fail | not_run",
  "summary": "short result"
}
```

## Artifact object

Each `artifacts[]` item must use:

```json
{
  "path": "docs/audits/example.md",
  "kind": "report | fixture | manifest | rendered_proof | source_seed | other",
  "classification": "evidence | research_seed | production | docs_only",
  "production_use": false
}
```

## Hard Red manifest failures

A manifest is invalid if:

- required top-level fields are missing
- `schema_version` is not `gate-result-manifest.v1`
- `batch.result` is outside the allowed result enum
- a gate status is outside the allowed status enum
- `release_claims.*` are true without explicit source-truth evidence
- `production_source_truth_claimed` is true for research seed data
- `git.working_tree_clean` is false while result is Green

## No-claim boundary

This schema does not make gates automatically hard-blocking. It creates a machine-readable evidence layer. CI strictness must be declared per workflow/job/train.

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
