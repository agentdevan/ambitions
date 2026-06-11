# UIQL-001 Activation Contract Repair

Status: Green for the scoped stale-test repair; Yellow for broader UIQL proof not exercised here.

## Scope

UIQL-001 preflight found a Red dependency before UIQL-002: `Native/AmbitionsTests/App/ActivationContractTests.swift` still asserted the prior `Today / Goals / Capture / Time / You` tab list even though `AppTab.allCases` and onboarding copy now use `Today / Goals / Time / Motion / You` with Capture as a global route.

This repair updates only the stale test assertion. It does not change runtime source, product behavior, visual design, accessibility semantics, screenshots, dependencies, release posture, or owner approval state.

## Touched Files

- `Native/AmbitionsTests/App/ActivationContractTests.swift`
- `artifacts/ui-quality-lockdown/UIQL-run-state.md`
- `artifacts/ui-quality-lockdown/UIQL_CHANGELOG.md`
- `artifacts/ui-quality-lockdown/UIQL_REPAIR_LOG.md`
- `artifacts/proof-ledger/PROOF_LEDGER.md`
- `artifacts/proof-ledger/proof-index.json`
- UIQL script output logs under `artifacts/ui-quality-lockdown/script-output/`

## Change

- Renamed the affected test to state the intent: activation rules remain available without promoting legacy/global routes to canonical tabs.
- Updated canonical app tab expectation to `Today / Goals / Time / Motion / You`.
- Added explicit proof that `AppTab.allCases` does not include `.capture`.
- Checked onboarding surface rows align with canonical `AppTab.allCases`.
- Kept Capture and Plan-era activation rules as supporting/global/legacy route coverage, including `Capture` and `Time` titles.

## Validation

- `bash .agents/skills/uiql-quality-lockdown/scripts/uiql-preflight.sh`
  - Exit: `1`
  - Artifact: `artifacts/ui-quality-lockdown/script-output/program-preflight-20260611T011330.log`
  - Result: Red only because the intended test repair was dirty during mid-edit.
- `bash .agents/skills/uiql-quality-lockdown/scripts/uiql-mini-regression.sh`
  - Exit: `0`
  - Artifacts: `artifacts/ui-quality-lockdown/script-output/uiql-banned-copy.log`, `uiql-card-anatomy.log`, `uiql-shell.log`
- `scripts/ambitions-xcode-test-focused.sh --batch UIQL-001 --only-testing AmbitionsTests/ActivationContractTests`
  - Exit: non-Green/stale proof
  - Artifact: `artifacts/ui-quality-lockdown/script-output/UIQL-001-activation-contract-focused-test-20260611T051330Z.log`
  - Result: Reproduced the old failing assertion from a stale test bundle, so this was not accepted as repair proof.
- `scripts/ambitions-xcode-build-for-testing.sh --batch UIQL-001`
  - Exit: `0`
  - Artifact: `artifacts/ui-quality-lockdown/script-output/UIQL-001-build-for-testing-20260611T051751Z.log`
  - Result: Build-for-testing succeeded and compiled `ActivationContractTests.swift`; wrapper reported a missing result bundle after success.
- `scripts/ambitions-xcode-test-focused.sh --batch UIQL-001 --only-testing AmbitionsTests/ActivationContractTests`
  - Exit: `0`
  - Artifact: `artifacts/ui-quality-lockdown/script-output/UIQL-001-activation-contract-focused-test-rebuilt-20260611T051909Z.log`
  - Result: 4 `ActivationContractTests`, 0 failures.
- `bash scripts/codex/program-proof-index.sh uiql`
  - Exit: `0`
  - Artifact: `artifacts/ui-quality-lockdown/script-output/program-proof-index-20260611T012300.log`
  - Result: proof index regenerated with 3 entries.
- `bash scripts/codex/program-closeout-check.sh uiql UIQL-001`
  - Exit: `1`
  - Artifact: `artifacts/ui-quality-lockdown/script-output/program-closeout-check-UIQL-001-20260611T012300.log`
  - Result: Red only because the intended test repair was dirty before commit; rerun after clean commit is required.
- `git diff --check`
  - Exit: `0`
  - Artifact: terminal command output only.

## Gate Status

- Green: scoped stale Activation Contract test repair.
- Yellow: visual/accessibility proof was not part of this repair and remains required before any UIQL product Green claim.
- Red: none remaining for the UIQL-001 blocker that prevented UIQL-002 start.

## Linear Closeout Text

Linear issue `UIQL-001` was not found by available connector fetch. Manual closeout text:

```text
UIQL-001 Activation Contract canon repair

- Pushed to main: pending this commit
- App runtime source changed: no
- Test source changed: yes, scoped stale canon assertion only
- New canonical tabs asserted: Today / Goals / Time / Motion / You
- Capture top-level tab asserted: no
- Capture retained as global/supporting activation route: yes
- Validation:
  - uiql-preflight: mid-edit Red from dirty intended repair only
  - uiql-mini-regression: exit 0
  - build-for-testing: exit 0
  - focused ActivationContractTests after rebuild: 4 tests, 0 failures
- Red blockers remaining: none for UIQL-001 stale Activation Contract dependency
- Yellow: screenshots/accessibility/release/owner approval not claimed
- Next: confirm UIQL-002 authority and begin UIQL-002 on clean main
```
