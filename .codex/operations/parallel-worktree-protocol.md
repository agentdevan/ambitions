# Parallel Worktree Protocol

Use only when the user explicitly allows parallel work or multiple independent Codex lanes.

## Steps

1. Split work into non-overlapping lanes.
2. Name each lane and forbidden overlap.
3. Assign validation per lane.
4. Merge docs/audit lanes first.
5. Re-run integration validation on `main`.

## Stop Conditions

Stop if lanes overlap shell, routing, persistence, shared models, or mass renames.
