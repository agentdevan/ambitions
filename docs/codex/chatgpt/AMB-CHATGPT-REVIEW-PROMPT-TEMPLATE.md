# AMB-CHATGPT-REVIEW-PROMPT-TEMPLATE

Status: supporting prompt template

```md
<!-- AMBITIONS_RUNNER_REQUIRED: true -->
<!-- RUN_WITH: scripts/ambitions-codex-train.sh -->
<!-- DIRECT_CODEX_EXECUTION: forbidden_unless_user_explicitly_bypasses_runner -->

# <REVIEW_ID>

## Type

review

## Review target

<Files, docs, or claim set to review.>

## Required truth files

- `docs/truth/README.md`
- `docs/truth/PRODUCT_DESIGN_TRUTH.md`
- `docs/truth/IMPLEMENTATION_TRUTH.md`
- `docs/truth/RELEASE_TRUTH.md`
- `docs/truth/CODEX_PROCESS_TRUTH.md`

## Questions

- What is true now?
- What is still unproven?
- What is stale or conflicting?
- What should be Red?
- What proof is missing?

## Output

- Findings first
- File references
- Claim boundaries
- Next safe step
```
