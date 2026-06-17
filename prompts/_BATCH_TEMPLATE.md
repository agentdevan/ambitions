<!-- AMBITIONS_RUNNER_REQUIRED: true -->
<!-- RUN_WITH: scripts/ambitions-codex-train.sh -->
<!-- DIRECT_CODEX_EXECUTION: forbidden_unless_user_explicitly_bypasses_runner -->

# Batch ID

`<BATCH_ID>`

This prompt is intended to be run through `scripts/ambitions-codex-train.sh`, not pasted as a direct implementation prompt, unless the user explicitly bypasses the legacy runner.

## Objective

Describe the bounded batch outcome. Do not include unrelated cleanup, architecture expansion, release claims, or future batch work.

Active product law:

```text
Persistent surfaces: Today / Goals / Time / You
Global composer: Capture
Cross-surface behavior: Motion
Trust inspection: Proof / Source / Privacy / History / Receipts
```

Capture is the global Atmosphere Composer / Open Field action layer, not a tab, inbox, notes feed, category grid, chatbot, or persistent floating button.

Motion is Stage/Motion behavior, not a tab, destination, activity feed, analytics surface, score, streak, or progress dashboard.

Plan/Profile/Captures/Pulse/Motion-tab/Capture-tab language is historical or compatibility context only unless active truth explicitly scopes a migration.

Ambitions Accounts are optional launch identity/entitlement infrastructure using Sign in with Apple and Google Sign-In. Offline core value must work with no account. R2 is Source Atlas/reference freshness infrastructure only and is not a user-data backend.

Hosted AI services, external/cloud LLMs, cloud model APIs, server-side profiling, and hosted personal-data intelligence are excluded from core architecture.

If this packet depends on a recently accepted predecessor, include a packet-local clearance block before the execution scope:

```text
PREVIOUS_PACKET_CLEARANCE:
- <issue> accepted Yellow/Green, commit <sha>, no Red blockers.
- Yellow debt: <owned non-blocking evidence debt>.
- Do not reopen older Red artifacts unless current source or guard evidence shows a new active Red.
```

## Active Source Truth To Inspect

- `docs/truth/README.md`
- `docs/truth/PRODUCT_DESIGN_TRUTH.md`
- `docs/truth/PRODUCT_MOAT_TRUTH.md`
- `docs/truth/IMPLEMENTATION_TRUTH.md`
- `docs/truth/RELEASE_TRUTH.md`
- `docs/truth/CODEX_PROCESS_TRUTH.md`
- `.codex/os/AMBITIONS_OPERATING_CONTEXT.md`
- relevant source owner files
- relevant tests
- relevant scripts/guards

## Allowed Scope

- List exact files or directories the batch may change.
- List exact tests or validation scripts the batch may run.
- Keep implementation bounded to the accepted plan handoff.

## Forbidden Scope

- No app feature outside this batch.
- No SwiftUI redesign outside the named owner seam.
- No production source outside allowed files.
- No dependency, hosted CI, signing, entitlement, account, provider, R2, or project mutation unless explicitly scoped and approved.
- No canon rewrite unless explicitly scoped and approved.
- No release, accessibility, privacy, performance, account, R2, device, or production claims without current evidence.
- No Motion root destination.
- No Capture root destination.
- No account requirement for core local app value.
- No private life graph storage in hosted backend.
- No private user context in R2/Source Atlas requests.

## Validation Expectations

- `git diff --check`
- `scripts/codex-forbidden-claim-scan.sh <changed files>`
- `python3 scripts/ambitions_validate_authority_drift.py` when canon/authority wording changes
- focused build/test commands selected by planning when Swift source changes
- exact commands, exit codes, and not-run checks recorded

If the prompt lint/pre-guard failure is limited to wording, missing inspection terms, or old-term prompt triggers, the runner may enter explicit prompt self-heal mode, repair only this prompt, and continue without requiring a manual rerun. Prompt self-heal must be reported separately from source edits.

## Xcode Fast-Trust Route

- Use the Ambitions Xcode Build Lab wrapper for simulator build/test proof:
  `make xcode-focused-test BATCH=<BATCH_ID> TEST=<test-id>` or
  `scripts/ambitions-xcode-validate.sh --batch <BATCH_ID> --lane focused-test --test <test-id>`.
- After any Swift source or Swift test edit, run build-for-testing before focused tests.
- Do not accept focused-test proof from stale test bundles or from raw logs that executed zero intended tests.
- Focused test suites run serially by default with unique per-suite artifact directories.
- Prefer fully qualified test identifiers and record raw executed suite/test counts from the wrapper summary.
- Use `make xcode-build-for-testing` once when build reuse is useful or Swift source/test files changed before focused tests.
- Use `make xcode-test-plan` only when the batch genuinely needs a test plan.
- Do not run raw `xcodebuild` from nested Codex phases unless this prompt explicitly requires raw command proof.
- Do not retry `xcodebuildmcp.test_sim` after a 120-second timeout; recover through the wrapper lane and record the timeout as not XCTest proof.
- Wrapper summaries under `.codex/xcode-summaries/` are local engineering evidence only and do not imply release/device/accessibility/performance proof.

## Visual Proof Expectations If UI Changes

- Capture current screenshot/preview/simulator evidence when visual quality is claimed.
- Include default and non-ideal states when practical.
- Record Dynamic Type, Reduce Motion, and accessibility proof or explicitly state they were not run.
- Do not claim visual approval from docs alone.

## Account / R2 Proof Expectations If Network-Affiliated Code Changes

- Prove offline core still works without account or state that proof was not run.
- Prove private life graph data does not leave the device or state that proof was not run.
- Prove R2 requests contain no private user context or state that proof was not run.
- Prove account/auth/entitlement behavior only with current source/log evidence.
- Do not claim account auth, R2 freshness, entitlement, or privacy readiness from source presence alone.

## Hard Red Stop Conditions

- Source mutation outside allowed scope.
- The bounded patch model makes architecture, canon, continuation, cleanup, or final commit decisions.
- False implementation, release, accessibility, privacy, performance, account, R2, device, hosted CI, or production claim.
- Hosted AI/cloud LLM/core model dependency is introduced.
- Motion is reintroduced as root destination.
- Capture is reintroduced as root destination.
- A fifth/sixth persistent surface appears.
- Account sign-in becomes required for core local app value.
- Private life graph backend appears.
- R2 receives private user context.
- Obsolete authority path overrides `docs/truth/*`.
- Validation contradiction or missing rollback.

## Rollback Expectations

- Record the starting commit.
- Save changed-file summary and patch.
- On Red, leave changes uncommitted unless the runner is explicitly configured with `AUTO_ROLLBACK_ON_RED=1`.
- If a commit is created, the runner does not push by default. Enable push only with explicit owner intent:

```bash
AUTO_PUSH=1 make batch BATCH=<BATCH_ID> PROMPT=<PROMPT_FILE>
```

- No release, build, accessibility, performance, visual, device, account, R2, TestFlight, or App Store proof is implied by the runner.
- Use the runner-provided rollback command if the batch must be discarded.

## Runner Command

```bash
make batch BATCH=<BATCH_ID> PROMPT=<PROMPT_FILE>
```
