<!-- AMBITIONS_RUNNER_REQUIRED: true -->
<!-- RUN_WITH: scripts/ambitions-codex-train.sh -->
<!-- DIRECT_CODEX_EXECUTION: forbidden_unless_user_explicitly_bypasses_runner -->

# BE-03-REALITY-MERIDIAN-CAPACITY

## Batch Identity

- Batch ID: `BE-03-REALITY-MERIDIAN-CAPACITY`
- Objective: make Reality Meridian and time reality projection backend-owned and UI-consumable, including protected time, vacation/away, pressure, conflicts, and time-fit proof.
- Stage: backend/implementation

## Active Source Truth to Inspect

- `docs/truth/README.md`
- `docs/truth/PRODUCT_DESIGN_TRUTH.md`
- `docs/truth/IMPLEMENTATION_TRUTH.md`
- `Native/Ambitions/Domain/`
- `Native/Ambitions/Services/`
- `Native/Ambitions/Features/Time/`
- `Native/Ambitions/Features/Today/`
- `docs/status/current-implementation-map.md`
- `docs/codex/batch-trains/amb-fe-be/AMB-FE-BE-CONTRACTS.md`

## Allowed Scope

- Backend projection code and consumer read models for time/capacity.
- Focused tests for protected time, pressure, and conflicts.

## Forbidden Scope

- No calendar clone, no new tab, no hidden schedule mutation.
- No cloud scheduler or hosted sync assumption.

## Expected Changes

- Make capacity and reality projection explicit.
- Keep protected-time state readable by the UI.
- Preserve deterministic time-fit reporting.

## Validation Expectations

- `git status --short`
- `git diff --check`
- focused `xcodebuild` tests
- `./scripts/build-local.sh`

## Visual Proof Expectations

- None unless the batch changes consumed UI state.

## Accessibility Proof Expectations

- None unless the batch changes consumed UI state.

## Hard Red Stop Conditions

- Any change turns Time into a calendar clone.
- Any change silently writes user schedule data.
- Any change claims device or release proof.

## Rollback Expectations

- Revert only the projection and test changes owned by this batch.

## Runner Command

```bash
ALLOW_DIRTY=1 AUTO_BRANCH=0 AUTO_COMMIT=0 ACCESS_MODE=full \
  scripts/ambitions-codex-train.sh \
  BE-03-REALITY-MERIDIAN-CAPACITY \
  prompts/batches/amb-fe-be/BE-03-REALITY-MERIDIAN-CAPACITY.md
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
