<!-- AMB-291-CANON-HYGIENE-HEADER: BEGIN -->

> Canon hygiene status: **execution-work-order-needs-sequencing**
> AMB-291 note: This batch/prompt is a work-order artifact and must be sequenced before execution.
> Active authority: `docs/truth/*`, `docs/codex/GLOBAL_BATCH_SEQUENCE_AUTHORITY.json`, and `docs/codex/IOS26_FLAGSHIP_TRAIN_MANIFEST.yml`.
> Before using this file for implementation, run `make change-impact-check` and follow `docs/ops/change-protocol/implementation-prompt-template.md`.
> Resolution classes: merge-overlap
> Dispositions: merge-or-sequence-file-ownership, merge-or-sequence-surface-ownership

<!-- AMB-291-CANON-HYGIENE-HEADER: END -->
<!-- AMBITIONS_RUNNER_REQUIRED: true -->
<!-- RUN_WITH: scripts/ambitions-codex-train.sh -->
<!-- DIRECT_CODEX_EXECUTION: forbidden_unless_user_explicitly_bypasses_runner -->

# HBI-00 — Canon + Authority Docs

## Batch ID

HBI-00

## Runner command

```bash
scripts/ambitions-codex-train.sh HBI-00 prompts/batches/HBI-00.md
```

Equivalent:

```bash
make batch BATCH=HBI-00 PROMPT=prompts/batches/HBI-00.md
```

## Objective

Install Historical Baseline canon and source hierarchy authority so later batches can implement current-state construction without drift.

## Active source truth to inspect

- `docs/truth/README.md`
- `docs/truth/PRODUCT_DESIGN_TRUTH.md`
- `docs/truth/PRODUCT_MOAT_TRUTH.md`
- `docs/truth/IMPLEMENTATION_TRUTH.md`
- `docs/truth/RELEASE_TRUTH.md`
- `docs/truth/CODEX_PROCESS_TRUTH.md`
- `docs/codex/HISTORICAL_BASELINE_GLOBAL_TRAIN_OVERLAY.md`
- `docs/codex/HISTORICAL_BASELINE_GLOBAL_TRAIN_MANIFEST.json`
- `docs/codex/batch-trains/HBI00_RRE01_HISTORICAL_BASELINE_TRAIN.md`
- `docs/codex/GLOBAL_QUEUE_CANONICAL_ORDER.json`

## Allowed scope

- Canon and authority docs for Historical Baseline.
- Source hierarchy definitions.
- Queue/registry references that make HBI active in the global train.
- Validation/report scaffolding for this canon-only batch.

## Forbidden scope

- Production code changes.
- Swift schema or UI implementation.
- Source importer implementation.
- Release, device, TestFlight, App Store, accessibility, privacy, or legal readiness claims.

## Validation expectations

- Canon title/path gate passes.
- Prompt audit remains clean or documented Accepted Yellow.
- Queue references resolve to existing files.
- Final report documents that this is canon/governance only.

## Visual proof expectations

Not required. This batch must not touch UI.

## Hard Red stop conditions

Stop if implementation code changes become necessary, active IA drifts from Today / Goals / Capture / Time / You, the canonical queue is corrupted, external/cloud LLM core behavior is introduced, or release/readiness claims would be required without proof.

## Rollback expectations

Revert only HBI-00-owned canon/queue/report files. Do not revert unrelated queue or source-truth work.

## Final report expectations

Create `docs/audits/hbi-00-batch-closeout-report.md` with source truth inspected, files changed, validation commands/exit codes, no-code-change confirmation, and next eligible batch.

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
