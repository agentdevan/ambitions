# AMB-CHATGPT-APP-STORE-HONESTY-PROMPT-TEMPLATE

Status: supporting prompt template

```md
<!-- AMBITIONS_RUNNER_REQUIRED: true -->
<!-- RUN_WITH: scripts/ambitions-codex-train.sh -->
<!-- DIRECT_CODEX_EXECUTION: forbidden_unless_user_explicitly_bypasses_runner -->

# <APP_STORE_BATCH_ID>

## Type

release gate

## Objective

<Describe the review or repair needed for store-facing claims.>

## Required truth files

- `docs/truth/README.md`
- `docs/truth/PRODUCT_DESIGN_TRUTH.md`
- `docs/truth/IMPLEMENTATION_TRUTH.md`
- `docs/truth/RELEASE_TRUTH.md`

## Must preserve

- implementation-backed claims only
- privacy label honesty
- no fake screenshots
- no hidden data collection claims
- local-first proof boundaries
- continuity proof boundaries

## Validation

- claim scan
- evidence packet review
- screenshot or preview truth when applicable
```
