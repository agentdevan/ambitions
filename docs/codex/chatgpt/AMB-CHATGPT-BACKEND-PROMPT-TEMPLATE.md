# AMB-CHATGPT-BACKEND-PROMPT-TEMPLATE

Status: supporting prompt template

```md
<!-- AMBITIONS_RUNNER_REQUIRED: true -->
<!-- RUN_WITH: scripts/ambitions-codex-train.sh -->
<!-- DIRECT_CODEX_EXECUTION: forbidden_unless_user_explicitly_bypasses_runner -->

# <BACKEND_BATCH_ID>

## Type

repair

## Objective

<Describe the bounded backend or local durability slice.>

## Required truth files

- `docs/truth/README.md`
- `docs/truth/PRODUCT_DESIGN_TRUTH.md`
- `docs/truth/IMPLEMENTATION_TRUTH.md`
- `docs/truth/RELEASE_TRUTH.md`

## Must preserve

- local-first behavior
- no custom server requirement unless explicitly scoped
- projection ownership
- deterministic recommendation behavior
- receipts and durable state
- privacy claim honesty
- Apple continuity when relevant

## Validation

- exact unit or integration tests
- exact logs or proof artifacts
- exact claim boundaries
```
