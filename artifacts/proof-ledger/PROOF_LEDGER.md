# Proof Ledger

Status: Active Codex OS v2 proof ledger
Authority: Process evidence ledger, subordinate to `docs/truth/RELEASE_TRUTH.md`

## Rules

Entries must include claim, commit, touched files, command, exit code, artifact path, screenshot path if visual, scope, non-claims, freshness, responsible program, related Linear issue, and Green/Yellow/Red evidence status.

## Entries

### 2026-06-11 - AMB-CODEX-OS-V2 Initial Validator Audit

- Claim: Existing Codex OS validator/doctor expectations were audited before v2 install.
- Commit: working tree before install from `b5bfa2ed891a412e0d9e43b99c744422fe2a990c`.
- Touched files: audit logs under `artifacts/codex-os-v2/script-output/`.
- Command: `python3 scripts/ambitions-codex-os-validate.py`; `python3 scripts/ambitions-codex-os-doctor.py`; `make scripts-doctor`; `make repo-doctor`.
- Exit code: validate `1`; doctor `0`; scripts-doctor `2`; repo-doctor terminated after bounded timeout.
- Artifact path: `artifacts/codex-os-v2/script-output/`.
- Screenshot path if visual: not applicable.
- Scope: Codex OS governance audit only.
- Non-claims: no app build, tests, accessibility, performance, privacy/legal, device, TestFlight, App Store, or release readiness proof.
- Freshness: current on 2026-06-11 for the local working tree.
- Responsible program: CODEX-OS.
- Related Linear issue: AMB-CODEX-OS-V2-001.
- Evidence status: Yellow/Red existing drift documented.

### 2026-06-11 - UIQL-001 Program Preflight

- Claim: UIQL-001 program preflight and authority refresh ran on `main` and identified the next UIQL dependency.
- Commit: pending UIQL-001 closeout commit at report creation.
- Touched files: UIQL artifacts, proof ledger, script-output logs.
- Command: `bash .agents/skills/uiql-quality-lockdown/scripts/uiql-preflight.sh`; `bash .agents/skills/uiql-quality-lockdown/scripts/uiql-mini-regression.sh`.
- Exit code: preflight `0`; mini-regression `0`.
- Artifact path: `artifacts/ui-quality-lockdown/UIQL-001_PREFLIGHT_REPORT.md`; `artifacts/ui-quality-lockdown/script-output/`.
- Screenshot path if visual: not applicable.
- Scope: UIQL preflight and authority refresh only.
- Non-claims: no app source change, app test change, screenshot proof, visual approval, accessibility conformance, owner approval, release readiness, TestFlight readiness, App Store readiness, physical-device proof, performance proof, or privacy/legal approval.
- Freshness: current on 2026-06-11 for branch `main` at start HEAD `51db282625ff08fba17fe89faa0f26273adbd73e`.
- Responsible program: UIQL.
- Related Linear issue: UIQL-001; issue not found by available Linear fetch.
- Evidence status: UIQL-001 preflight Green; dependent UIQL work Red-blocked by stale Activation Contract IA/test expectation.

### 2026-06-11 - UIQL-001 Activation Contract Canon Repair

- Claim: The stale `ActivationContractTests` expectation that promoted Capture into canonical `AppTab.allCases` was repaired and validated after rebuilding the test bundle.
- Commit: pending UIQL-001 repair closeout commit at report creation.
- Touched files: `Native/AmbitionsTests/App/ActivationContractTests.swift`; UIQL repair artifacts; proof ledger.
- Command: `bash .agents/skills/uiql-quality-lockdown/scripts/uiql-mini-regression.sh`; `scripts/ambitions-xcode-build-for-testing.sh --batch UIQL-001`; `scripts/ambitions-xcode-test-focused.sh --batch UIQL-001 --only-testing AmbitionsTests/ActivationContractTests`.
- Exit code: mini-regression `0`; build-for-testing `0`; rebuilt focused test `0`.
- Artifact path: `artifacts/ui-quality-lockdown/UIQL-001_ACTIVATION_CONTRACT_REPAIR.md`; `artifacts/ui-quality-lockdown/script-output/UIQL-001-build-for-testing-20260611T051751Z.log`; `artifacts/ui-quality-lockdown/script-output/UIQL-001-activation-contract-focused-test-rebuilt-20260611T051909Z.log`.
- Screenshot path if visual: not applicable.
- Scope: UIQL stale test-canon repair only.
- Non-claims: no runtime behavior change, screenshot proof, visual approval, accessibility conformance, owner approval, release readiness, TestFlight readiness, App Store readiness, physical-device proof, performance proof, privacy/legal approval, or broader UIQL product Green.
- Freshness: current on 2026-06-11 for branch `main` after rebuilding local derived data.
- Responsible program: UIQL.
- Related Linear issue: UIQL-001; issue not found by available Linear fetch.
- Evidence status: Green for the scoped stale Activation Contract test repair; Yellow for visual/accessibility/release/owner claims not in scope.
