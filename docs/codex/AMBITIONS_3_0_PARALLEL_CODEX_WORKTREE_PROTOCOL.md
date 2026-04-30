# Ambitions 3.0 Parallel Codex Worktree Protocol

Status: Active coordination protocol

## Purpose

Parallel Codex worktrees can speed independent work but must not corrupt shared navigation, routing, models, or release truth.

## Allowed Lanes

- Docs-only audit.
- Dependency docs.
- Isolated test modernization.
- Independent primitive planning.

## Unsafe Lanes

- Shared routing.
- Shared view state.
- Shared domain models.
- Shell/navigation.
- Persistence migrations.
- Mass renames.

## Naming

Use descriptive worktree names tied to the batch or audit, such as `ambitions-doc-audit` or `ambitions-ui-test-contract`. Normal Ambitions execution still defaults to `main` unless the user explicitly requests worktrees.

## Merge Policy

Merge lower-risk docs/audit lanes before code lanes. Re-run validation in `main` after integration. Resolve conflicts by preserving active 3.0 source truth and implementation evidence.

## Stop Conditions

Do not parallelize when two lanes would touch the same routing, shell, persistence, shared model, or release gate.
