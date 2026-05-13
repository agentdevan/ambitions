<!-- AMBITIONS_RUNNER_REQUIRED: true -->
<!-- RUN_WITH: scripts/ambitions-codex-train.sh -->
<!-- DIRECT_CODEX_EXECUTION: forbidden_unless_user_explicitly_bypasses_runner -->

# HBI-07 - LinkedIn/GitHub Archives

## Batch ID

HBI-07

## Runner command

```bash
scripts/ambitions-codex-train.sh HBI-07 prompts/batches/HBI-07.md
```

Equivalent:

```bash
make batch BATCH=HBI-07 PROMPT=prompts/batches/HBI-07.md
```

## Objective

Implement user-supplied LinkedIn/GitHub archive parsing for Historical Baseline so career, project, skill, and proof-like archive entries can become local evidence and review-gated candidate claims.

## Active source truth to inspect

- `docs/truth/README.md`
- `docs/truth/PRODUCT_DESIGN_TRUTH.md`
- `docs/truth/IMPLEMENTATION_TRUTH.md`
- `docs/truth/RELEASE_TRUTH.md`
- `docs/truth/CODEX_PROCESS_TRUTH.md`
- `docs/codex/HISTORICAL_BASELINE_GLOBAL_TRAIN_OVERLAY.md`
- `docs/codex/HISTORICAL_BASELINE_GLOBAL_TRAIN_MANIFEST.json`
- `docs/codex/batch-trains/HBI00_RRE01_HISTORICAL_BASELINE_TRAIN.md`
- `prompts/batches/HBI-06.md`

## Allowed scope

- Local parsing for user-supplied archive files.
- Source records, evidence items, candidate extraction hooks, fixtures, and archive tests.
- No-account-link import paths.

## Forbidden scope

- Live OAuth connector.
- Always-on third-party sync.
- Hosted parsing backend.
- Direct active-goal creation.
- Release/readiness claims.

## Validation expectations

Run archive fixture tests and relevant source/privacy tests. Prove archive data remains local, sourced, and review-gated.

## Visual proof expectations

Only if user-facing import UI changes.

## Hard Red stop conditions

Stop if implementation requires live account linking, cloud parsing, source provenance loss, or review-gating bypass.

## Rollback expectations

Revert only HBI-07-owned parser, fixture, test, and report files.

## Final report expectations

Create `docs/audits/hbi-07-batch-closeout-report.md` with archive fixture proof, no-live-connector confirmation, and next eligible batch.
