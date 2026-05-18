<!-- AMBITIONS_RUNNER_REQUIRED: true -->
<!-- RUN_WITH: scripts/ambitions-codex-train.sh -->
<!-- DIRECT_CODEX_EXECUTION: forbidden_unless_user_explicitly_bypasses_runner -->

# FE-04-PRIMITIVES

## Batch Identity

- Batch ID: `FE-04-PRIMITIVES`
- Objective: define the code-backed or planned Ambitions primitives including Graphite Recess, Quiet Glass Shelf, Inspectable Strip, Ambient Vignette, Seam Line, Luminous Trace, Meridian Node, Current Time Glow, Proof Trail, Receipt Drawer, Source Freshness Badge, Closure Prompt, Start Here, LifeShape, Atmosphere Composer, Constellation lane, and User System Profile.
- Stage: frontend/implementation

## Active Source Truth to Inspect

- `docs/truth/PRODUCT_DESIGN_TRUTH.md`
- `docs/truth/IMPLEMENTATION_TRUTH.md`
- `Sources/AmbitionsDesignSystem/`
- `AppUI/Sources/AmbitionsWidgetUI/`
- `Native/Ambitions/Features/`
- `frontend/visual-encyclopedia/`

## Allowed Scope

- Shared primitive definitions, previews, and focused tests only.
- Additive primitives that preserve existing shell and surface ownership.

## Forbidden Scope

- No generic card stack or dashboard primitives.
- No new top-level destination.
- No unsupported claim of finished product behavior.

## Expected Changes

- Name the primitive system with repo-native terms.
- Tie primitives to surface roles and state.
- Keep the primitives reusable and narrow.

## Validation Expectations

- `git status --short`
- `git diff --check`
- focused tests for the owner package or source files
- `make prompt-audit`

## Visual Proof Expectations

- If primitives are visual, include preview coverage for normal and edge states.

## Accessibility Proof Expectations

- If primitives are visual, include Dynamic Type, Reduce Motion, contrast, and non-color proof.

## Hard Red Stop Conditions

- A primitive becomes a generic UI wrapper.
- A primitive silently changes IA or route behavior.
- A primitive requires a release claim.

## Rollback Expectations

- Remove only the primitive files changed by this batch.

## Runner Command

```bash
ALLOW_DIRTY=1 AUTO_BRANCH=0 AUTO_COMMIT=0 ACCESS_MODE=full \
  scripts/ambitions-codex-train.sh \
  FE-04-PRIMITIVES \
  prompts/batches/amb-fe-be/FE-04-PRIMITIVES.md
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
