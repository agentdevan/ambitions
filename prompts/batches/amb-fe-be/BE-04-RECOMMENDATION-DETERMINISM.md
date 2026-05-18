<!-- AMBITIONS_RUNNER_REQUIRED: true -->
<!-- RUN_WITH: scripts/ambitions-codex-train.sh -->
<!-- DIRECT_CODEX_EXECUTION: forbidden_unless_user_explicitly_bypasses_runner -->

# BE-04-RECOMMENDATION-DETERMINISM

## Batch Identity

- Batch ID: `BE-04-RECOMMENDATION-DETERMINISM`
- Objective: keep Start Here and recommended-step frames deterministic, inspectable, and free of LLM dependency.
- Stage: backend/implementation

## Active Source Truth to Inspect

- `docs/truth/README.md`
- `docs/truth/PRODUCT_DESIGN_TRUTH.md`
- `docs/truth/IMPLEMENTATION_TRUTH.md`
- `Native/Ambitions/Domain/`
- `Native/Ambitions/Services/`
- `Native/Ambitions/Features/Today/`
- `Native/Ambitions/Features/Goals/`
- `docs/status/current-implementation-map.md`

## Allowed Scope

- Deterministic recommendation code, tests, and current read-model seams.
- Small additive changes that preserve source explainability.

## Forbidden Scope

- No cloud inference, no model confidence labels, no AI theater.
- No hidden recommendation mutation.

## Expected Changes

- Make recommendation frames repeatable with fixed IDs/clocks where needed.
- Keep the source and reason visible.
- Preserve local-only execution.

## Validation Expectations

- `git status --short`
- `git diff --check`
- focused `xcodebuild` tests
- `./scripts/build-local.sh`

## Visual Proof Expectations

- None unless UI frames are changed.

## Accessibility Proof Expectations

- None unless UI frames are changed.

## Hard Red Stop Conditions

- Any LLM dependency enters the recommendation path.
- Any explanation becomes non-inspectable or non-deterministic.
- Any unsupported release claim appears.

## Rollback Expectations

- Remove only the batch-owned recommendation changes.

## Runner Command

```bash
ALLOW_DIRTY=1 AUTO_BRANCH=0 AUTO_COMMIT=0 ACCESS_MODE=full \
  scripts/ambitions-codex-train.sh \
  BE-04-RECOMMENDATION-DETERMINISM \
  prompts/batches/amb-fe-be/BE-04-RECOMMENDATION-DETERMINISM.md
```

## Final Report Format

- Status
- Summary
- Repo OS / Repo Doctor integration
- Files changed
- Installed train location
- Recommended next runner command
- Full recommended execution order
- Validation
- Classification
- Risks / blockers
- Worktree hygiene
- Rollback
- Next decision needed from user
