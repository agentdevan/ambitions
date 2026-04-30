# Large Batch Checkpoint Protocol

## When To Use

Use for L/XL work, long prompts, or after context compaction.

## Exact Steps

1. Define checkpoint plan before edits.
2. Record phase list and stop conditions.
3. Validate after each phase.
4. Commit only coherent slices.
5. Rebuild state from repo files after compaction.
6. Split when scope crosses task width gates.

## Output Artifacts

- Checkpoint report.
- Updated run state for XL work.
- Partial commit or audit report strategy.

## Stop Conditions

- State cannot be reconstructed.
- Unrelated work appears in diff.
- Validation failure cannot be classified.
