<!-- AMBITIONS_RUNNER_REQUIRED: true -->
<!-- RUN_WITH: scripts/ambitions-codex-train.sh -->
<!-- DIRECT_CODEX_EXECUTION: forbidden_unless_user_explicitly_bypasses_runner -->

# BE-06-PROTECTED-TIME-PRIVACY

## Batch Identity

- Batch ID: `BE-06-PROTECTED-TIME-PRIVACY`
- Objective: enforce protected-time rules plus privacy, export/delete, local-only posture, and no SDK/regression checks.
- Stage: backend/implementation

## Active Source Truth to Inspect

- `docs/truth/README.md`
- `docs/truth/PRODUCT_DESIGN_TRUTH.md`
- `docs/truth/IMPLEMENTATION_TRUTH.md`
- `docs/truth/RELEASE_TRUTH.md`
- `Native/Ambitions/Domain/`
- `Native/Ambitions/Services/`
- `Native/Ambitions/Persistence/`
- `Native/Ambitions/Resources/PrivacyInfo.xcprivacy`
- `Native/Ambitions/Support/Ambitions.entitlements`
- `docs/status/release-evidence-packet.md`

## Allowed Scope

- Privacy/protected-time source and tests only.
- Export/delete posture updates only where already supported by active truth.

## Forbidden Scope

- No new SDKs, no hosted sync, no cloud data path.
- No privacy or release claims without evidence.

## Expected Changes

- Keep protected time enforceable and readable.
- Preserve local-first privacy boundaries.
- Make export/delete posture explicit where already implemented.

## Validation Expectations

- `git status --short`
- `git diff --check`
- focused `xcodebuild` tests
- `./scripts/build-local.sh`
- any in-repo privacy scan that already exists

## Visual Proof Expectations

- None unless privacy state is shown in UI.

## Accessibility Proof Expectations

- None unless privacy state is shown in UI.

## Hard Red Stop Conditions

- Any external SDK or hosted dependency appears.
- Any privacy posture weakens local-only controls.
- Any export/delete claim outruns proof.

## Rollback Expectations

- Restore only the batch-owned privacy and protected-time changes.

## Runner Command

```bash
ALLOW_DIRTY=1 AUTO_BRANCH=0 AUTO_COMMIT=0 ACCESS_MODE=full \
  scripts/ambitions-codex-train.sh \
  BE-06-PROTECTED-TIME-PRIVACY \
  prompts/batches/amb-fe-be/BE-06-PROTECTED-TIME-PRIVACY.md
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
