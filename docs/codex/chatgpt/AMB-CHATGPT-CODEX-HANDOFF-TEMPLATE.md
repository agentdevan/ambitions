# AMB-CHATGPT-CODEX-HANDOFF-TEMPLATE

Status: supporting prompt template

```md
<!-- AMBITIONS_RUNNER_REQUIRED: true -->
<!-- RUN_WITH: scripts/ambitions-codex-train.sh -->
<!-- DIRECT_CODEX_EXECUTION: forbidden_unless_user_explicitly_bypasses_runner -->

# <BATCH_ID>

## Type

<installer|audit|repair|implementation|review|release gate|visual QA|privacy audit|continuity proof>

## Objective

<Describe the bounded outcome.>

## Active source truth to inspect first

- `docs/truth/README.md`
- `docs/truth/PRODUCT_DESIGN_TRUTH.md`
- `docs/truth/IMPLEMENTATION_TRUTH.md`
- `docs/truth/RELEASE_TRUTH.md`
- `docs/truth/CODEX_PROCESS_TRUTH.md`
- `docs/truth/HISTORICAL_POLICY.md`

## Allowed scope

<List exact files and directories.>

## Forbidden scope

<List exact out-of-scope areas.>

## Validation expectations

<List exact commands and what evidence they must produce.>

## Proof and claim boundaries

<State what may not be claimed.>

## Rollback

<State the safe rollback path.>
```
