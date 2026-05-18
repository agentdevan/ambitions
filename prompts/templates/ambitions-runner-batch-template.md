<!-- AMBITIONS_RUNNER_REQUIRED: true -->
<!-- RUN_WITH: scripts/ambitions-codex-train.sh -->
<!-- DIRECT_CODEX_EXECUTION: forbidden_unless_user_explicitly_bypasses_runner -->

# Ambitions Runner Batch Template

This template is supporting prompt infrastructure. It does not override
`docs/truth/*`, the active queue, or the Ambitions runner.

## Batch ID

`<BATCH_ID>`

## Type

`installer | audit | repair | implementation | review | release gate | visual QA | privacy audit | continuity proof`

## Objective

<Describe the bounded outcome.>

## Active source truth to inspect first

- `docs/truth/README.md`
- `docs/truth/PRODUCT_DESIGN_TRUTH.md`
- `docs/truth/IMPLEMENTATION_TRUTH.md`
- `docs/truth/RELEASE_TRUTH.md`
- `docs/truth/CODEX_PROCESS_TRUTH.md`

## Allowed scope

<List exact files and directories.>

## Forbidden scope

<List exact out-of-scope areas.>

## Validation expectations

<List exact commands and proof requirements.>

## Rollback

<List the safe rollback path.>
