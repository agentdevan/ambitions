<!-- AMBITIONS_RUNNER_REQUIRED: true -->
<!-- RUN_WITH: scripts/ambitions-codex-train.sh -->
<!-- DIRECT_CODEX_EXECUTION: forbidden_unless_user_explicitly_bypasses_runner -->

# HBI-04 - Calendar/Reminders

## Batch ID

HBI-04

## Runner command

```bash
scripts/ambitions-codex-train.sh HBI-04 prompts/batches/HBI-04.md
```

Equivalent:

```bash
make batch BATCH=HBI-04 PROMPT=prompts/batches/HBI-04.md
```

## Objective

Implement the Historical Baseline Calendar/Reminders adapter using the repo-approved EventKit boundary so user-authorized calendar/reminder data can become evidence drafts, source records, and run receipts.

## Active source truth to inspect

- `docs/truth/README.md`
- `docs/truth/PRODUCT_DESIGN_TRUTH.md`
- `docs/truth/IMPLEMENTATION_TRUTH.md`
- `docs/truth/RELEASE_TRUTH.md`
- `docs/truth/CODEX_PROCESS_TRUTH.md`
- `docs/codex/HISTORICAL_BASELINE_GLOBAL_TRAIN_OVERLAY.md`
- `docs/codex/HISTORICAL_BASELINE_GLOBAL_TRAIN_MANIFEST.json`
- `docs/codex/batch-trains/HBI00_RRE01_HISTORICAL_BASELINE_TRAIN.md`
- `prompts/batches/HBI-03.md`
- existing EventKit, SideEffectLedger, Source Atlas, and privacy code/tests

## Allowed scope

- EventKit-backed adapter implementation through existing repo-approved boundaries.
- User-authorized calendar/reminder evidence drafts.
- Source records, source receipts, import preview/run receipts.
- Calendar/reminder fixtures and tests.

## Forbidden scope

- Auto-goal creation.
- Silent background calendar/reminder scanning.
- Calendar data treated as identity or ambition truth without review.
- New cloud sync, hosted backend, or external/cloud LLM dependency.
- Release/readiness claims.

## Validation expectations

Run focused Calendar/Reminders fixture tests and relevant privacy/source tests. Prove imported entries remain evidence/candidates and do not become active goals directly.

## Visual proof expectations

Only required if user-facing UI is touched. Otherwise not required.

## Hard Red stop conditions

Stop if EventKit access bypasses user authorization, if imported events create active goals, if stale/recurring obligations are not review-gated, or if privacy/source receipts cannot be produced.

## Rollback expectations

Revert only HBI-04-owned adapter, fixtures, tests, and report files.

## Final report expectations

Create `docs/audits/hbi-04-batch-closeout-report.md` with EventKit boundary proof, validation commands, no-auto-goal confirmation, and next eligible batch.
