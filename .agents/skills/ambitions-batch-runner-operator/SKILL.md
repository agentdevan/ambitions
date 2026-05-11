---
name: ambitions-batch-runner-operator
description: Execute Ambitions batches through the approved runner with bounded scope and rollback-aware closeout.
---

## Inputs
- Batch prompt, required runner header, target scope.

## Steps
1. Confirm run in clean repository if not explicitly allowed.
2. Verify prompt header and runner path are present.
3. Execute through `scripts/ambitions-codex-train.sh` or `make batch` command path.
4. Track status, collect evidence, and preserve path-limited diff.

## Checks
- No bypassing runner unless explicit user phrase permits it.
- No scope extension outside approved files.
- Red stops on forbidden cost, app-source edits, or release claim gaps.

## Rollback
- Use scoped restore commands.
- Never use `git reset --hard` as default.
