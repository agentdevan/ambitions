# Ambitions 3.0 Large Batch And Compact Recovery Protocol

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
