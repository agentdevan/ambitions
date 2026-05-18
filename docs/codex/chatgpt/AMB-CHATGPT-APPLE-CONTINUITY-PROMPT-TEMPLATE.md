# AMB-CHATGPT-APPLE-CONTINUITY-PROMPT-TEMPLATE

Status: supporting prompt template

```md
<!-- AMBITIONS_RUNNER_REQUIRED: true -->
<!-- RUN_WITH: scripts/ambitions-codex-train.sh -->
<!-- DIRECT_CODEX_EXECUTION: forbidden_unless_user_explicitly_bypasses_runner -->

# <CONTINUITY_BATCH_ID>

## Type

continuity proof

## Objective

<Describe the Apple continuity or restore-path slice.>

## Required truth files

- `docs/truth/README.md`
- `docs/truth/PRODUCT_DESIGN_TRUTH.md`
- `docs/truth/IMPLEMENTATION_TRUTH.md`
- `docs/truth/RELEASE_TRUTH.md`

## Must preserve

- local store as primary
- optional user-owned iCloud/CloudKit continuity where authorized
- no custom account system unless explicitly scoped
- no custom server unless explicitly scoped
- offline state handling
- disabled-iCloud handling
- new iPhone restore-path honesty
- conflict artifacts or notes
- Trust Console projection when relevant
- privacy copy and claim boundaries

## Validation

- exact continuity scenarios
- exact artifacts
- exact missing-proof notes
```
