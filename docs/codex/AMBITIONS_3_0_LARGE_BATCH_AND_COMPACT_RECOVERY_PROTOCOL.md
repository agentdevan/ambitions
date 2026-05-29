# Ambitions 3.0 Large Batch And Compact Recovery Protocol

<!-- AMB-291-CANON-HYGIENE-REPAIR: BEGIN -->

> AMB-291 repair status: **canon-hygiene-reconciled**
> This file was reviewed as part of the actual canon content/hygiene rewrite pass.
> It is not standalone active product truth. Use `docs/truth/*` and current manifest/sequence authority before implementation.
> Conflict types reconciled: same_surface_multiple_active_batches
> Prior recommended actions: Expedite
> Candidate references: AMB28-same_surface_multiple_active_batches-66075429

<!-- AMB-291-CANON-HYGIENE-REPAIR: END -->

<!-- AMB-291-CANON-HYGIENE-HEADER: BEGIN -->

> Canon hygiene status: **codex-reference**
> AMB-291 note: This Codex reference supports process or execution, but active truth remains in docs/truth and current manifests.
> Active authority: `docs/truth/*`, `docs/codex/GLOBAL_BATCH_SEQUENCE_AUTHORITY.json`, and `docs/codex/IOS26_FLAGSHIP_TRAIN_MANIFEST.yml`.
> Before using this file for implementation, run `make change-impact-check` and follow `docs/ops/change-protocol/implementation-prompt-template.md`.
> Resolution classes: authority-rewrite, merge-overlap, merge-overlap-before-proof
> Dispositions: merge-before-proof, merge-or-sequence-surface-ownership, rewrite-authority-reference

<!-- AMB-291-CANON-HYGIENE-HEADER: END -->

Status: Active long-run protocol

## Purpose

XL work must survive long prompts, context compaction, interruptions, and
partial failures without duplicate work or stale assumptions.

## Checkpoint Frequency

- XS/S/M: checkpoint in final closeout.
- L: checkpoint before validation and before commit.
- XL: checkpoint after every phase and before every commit.
- XXL: split before work begins.

## Checkpoint Contents

- current phase,
- files touched,
- decisions made,
- validation run,
- failures,
- open risks,
- next exact action,
- stop conditions.

## Commit Strategy

Commit when a coherent slice is validated and useful alone. Do not commit
generated junk, partial product behavior hidden behind docs, or changes that
cannot be explained after compaction.

## Compaction Recovery

1. Read latest user request and final/summary state.
2. Run `git status --short` and `git log -1 --oneline`.
3. Read `.codex/reports/current-run-state.md`.
4. Read the selected context pack and operation protocol.
5. Inspect staged/uncommitted changes.
6. Continue only from repo evidence.

## Memory Drift Detection

Treat memory as stale when commit hashes, simulator availability, validation
results, or active docs could have changed. Verify from files and commands.

## Split Mid-Run

Split when a third primitive appears, a persistence/navigation/release claim
enters scope, validation reveals unrelated failures, or role review blocks the
current plan.

## XL Batch Requirements

Every XL batch must declare before edits:

- checkpoint plan,
- phase list,
- stop conditions,
- validation after every phase,
- partial commit or report strategy,
- rollback plan,
- files allowed and forbidden,
- role review order,
- human approval triggers.

## Batch Train Orchestrator

When a prompt spans multiple Ambitions 3.0 batches, load `docs/codex/AMBITIONS_3_0_BATCH_TRAIN_ORCHESTRATOR.md`, select exactly one manifest under `docs/codex/batch-trains/`, initialize `.codex/reports/current-batch-train-state.md`, and continue only on Green. Yellow/Red stops with repair/resume material. FAANG handoff remains PARTIAL unless its gate is re-run and passes.

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
