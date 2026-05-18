# AMB-CHATGPT-UI-PROMPT-TEMPLATE

Status: supporting prompt template

```md
<!-- AMBITIONS_RUNNER_REQUIRED: true -->
<!-- RUN_WITH: scripts/ambitions-codex-train.sh -->
<!-- DIRECT_CODEX_EXECUTION: forbidden_unless_user_explicitly_bypasses_runner -->

# <UI_BATCH_ID>

## Type

visual QA

## Objective

<Describe the UI slice and the exact visual truth needed.>

## Required truth files

- `docs/truth/README.md`
- `docs/truth/PRODUCT_DESIGN_TRUTH.md`
- `docs/truth/IMPLEMENTATION_TRUTH.md`
- `docs/truth/RELEASE_TRUTH.md`

## Must preserve

- one-primary-object design
- accessibility
- Dynamic Type
- Reduce Motion
- no card-stack fallback
- no generic dashboard language

## Validation

- rendered evidence
- screenshots or previews
- accessibility checks when relevant
- exact files changed
```
