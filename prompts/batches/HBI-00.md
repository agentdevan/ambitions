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
