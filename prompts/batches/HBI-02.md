<!-- AMBITIONS_RUNNER_REQUIRED: true -->
<!-- RUN_WITH: scripts/ambitions-codex-train.sh -->
<!-- DIRECT_CODEX_EXECUTION: forbidden_unless_user_explicitly_bypasses_runner -->

# HBI-02 - Evidence Vault

## Batch ID

HBI-02

## Runner command

```bash
scripts/ambitions-codex-train.sh HBI-02 prompts/batches/HBI-02.md
```

Equivalent:

```bash
make batch BATCH=HBI-02 PROMPT=prompts/batches/HBI-02.md
```

## Objective

Implement the local Evidence Vault for Historical Baseline: evidence digests, local file references, content hashes, provenance links, and deletion-safe records.

## Active source truth to inspect

- `docs/truth/README.md`
- `docs/truth/IMPLEMENTATION_TRUTH.md`
- `docs/truth/RELEASE_TRUTH.md`
- `docs/truth/CODEX_PROCESS_TRUTH.md`
- `docs/codex/HISTORICAL_BASELINE_GLOBAL_TRAIN_OVERLAY.md`
- `docs/codex/HISTORICAL_BASELINE_GLOBAL_TRAIN_MANIFEST.json`
- `prompts/batches/HBI-01.md`
- current storage/domain source and tests

## Allowed scope

- Local evidence-vault storage/service objects.
- Content hash and digest handling.
- Local file reference/bookmark abstractions where repo architecture supports them.
- Vault tests and fixtures.

## Forbidden scope

- Cloud storage.
- Network-backed evidence persistence.
- Real source import adapters.
- UI polish.
- Release/readiness claims.

## Validation expectations

Run vault-focused tests and relevant storage validation. Prove evidence can be stored, linked to source records, hashed, redacted/deleted by policy, and queried without cloud dependency.

## Visual proof expectations

Not required unless UI is touched.

## Hard Red stop conditions

Stop if evidence cannot retain provenance, if cloud/network storage is introduced, if deletion semantics are unsafe, or if this batch requires unplanned migration risk.

## Rollback expectations

Revert only HBI-02-owned vault, fixture, test, and report files.

## Final report expectations

Create `docs/audits/hbi-02-batch-closeout-report.md` with validation commands, vault behavior, no-cloud confirmation, rollback notes, and next eligible batch.
