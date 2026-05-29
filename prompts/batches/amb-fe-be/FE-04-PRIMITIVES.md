<!-- AMB-291-CANON-HYGIENE-HEADER: BEGIN -->

> Canon hygiene status: **execution-work-order-needs-sequencing**
> AMB-291 note: This batch/prompt is a work-order artifact and must be sequenced before execution.
> Active authority: `docs/truth/*`, `docs/codex/GLOBAL_BATCH_SEQUENCE_AUTHORITY.json`, and `docs/codex/IOS26_FLAGSHIP_TRAIN_MANIFEST.yml`.
> Before using this file for implementation, run `make change-impact-check` and follow `docs/ops/change-protocol/implementation-prompt-template.md`.
> Resolution classes: merge-overlap, terminology-quarantine
> Dispositions: merge-or-sequence-file-ownership, merge-or-sequence-surface-ownership, quarantine-or-rewrite-terminology

<!-- AMB-291-CANON-HYGIENE-HEADER: END -->
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

- No generic card stack or surface primitives.
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

## Source-of-truth references

<!-- AMB-291-SOURCE-OF-TRUTH-REFERENCES: BEGIN -->

This file must not be treated as standalone active canon. Current authority must be resolved through:

- `docs/truth/README.md`
- `docs/truth/PRODUCT_DESIGN_TRUTH.md`
- `docs/truth/PRODUCT_MOAT_TRUTH.md`
- `docs/truth/IMPLEMENTATION_TRUTH.md`
- `docs/truth/RELEASE_TRUTH.md`
- `docs/truth/CODEX_PROCESS_TRUTH.md`
- `docs/truth/HISTORICAL_POLICY.md`
- `docs/codex/GLOBAL_BATCH_SEQUENCE_AUTHORITY.json`
- `docs/codex/IOS26_FLAGSHIP_TRAIN_MANIFEST.yml`
- `docs/ops/change-protocol/change-request-template.md`
- `docs/ops/change-protocol/change-impact-check.md`
- `docs/ops/change-protocol/implementation-prompt-template.md`
- `docs/ops/change-protocol/post-implementation-proof-reconciliation.md`

<!-- AMB-291-SOURCE-OF-TRUTH-REFERENCES: END -->

## Non-claims

<!-- AMB-291-NON-CLAIMS: BEGIN -->

- This file does not prove implementation.
- This file does not prove build success.
- This file does not prove test success.
- This file does not prove accessibility validation.
- This file does not prove performance validation.
- This file does not prove device validation.
- This file does not prove privacy/legal approval.
- This file does not prove TestFlight readiness.
- This file does not prove App Store readiness.
- This file does not prove release readiness.
- Linear status is not repo truth.

<!-- AMB-291-NON-CLAIMS: END -->
