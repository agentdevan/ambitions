# Run State Refresh Protocol

## When To Use

Use at phase boundaries, after context compaction, after interruption, or before
continuing a long prompt.

## Required Inputs

- `.codex/reports/current-run-state.md`
- Selected context pack.
- Current `git status --short`.

## Exact Steps

1. Read current run state.
2. Re-read selected context pack.
3. Verify branch, HEAD, and worktree.
4. Compare touched files with allowed/forbidden files.
5. Reconstruct decisions/tests/failures from repo files if chat context is
   uncertain.
6. Continue only when next phase and stop conditions are clear.

## Output Artifacts

- Updated run state or run report.
- Closeout risk if state could not be reconstructed.

## Stop Conditions

- Worktree contains unexplained changes.
- Current task no longer matches newest user request.
- Context cannot identify next safe phase.
