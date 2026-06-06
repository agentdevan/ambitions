<!-- AMBITIONS_RUNNER_REQUIRED: true -->
<!-- RUN_WITH: scripts/ambitions-codex-train.sh -->
<!-- DIRECT_CODEX_EXECUTION: forbidden_unless_user_explicitly_bypasses_runner -->

# Batch ID

`<BATCH_ID>`

This prompt is intended to be run through
`scripts/ambitions-codex-train.sh`, not pasted as a direct implementation
prompt.

## Objective

Describe the bounded batch outcome. Do not include unrelated cleanup,
architecture expansion, release claims, or future batch work.

Active user-facing IA is `Today / Goals / Time / Motion / You`.
`Capture` is the global Atmosphere Composer/action layer, not a tab.
`Motion` replaces `Pulse`; `Pulse` is historical / prior working-name context only.
Plan remains an internal compatibility seam only where current source/truth
allows it.

If this packet depends on a recently accepted predecessor, include a packet-local
clearance block before the execution scope:

```text
PREVIOUS_PACKET_CLEARANCE:
- <issue> accepted Yellow/Green, commit <sha>, no Red blockers.
- Yellow debt: <owned non-blocking evidence debt>.
- Do not reopen older Red artifacts unless current source or guard evidence
  shows a new active Red.
```

## Active Source Truth To Inspect

- `docs/truth/README.md`
- `docs/truth/PRODUCT_DESIGN_TRUTH.md`
- `docs/truth/IMPLEMENTATION_TRUTH.md`
- `docs/truth/RELEASE_TRUTH.md`
- `docs/truth/CODEX_PROCESS_TRUTH.md`
- `.codex/VALIDATION_HARNESS.md`
- `.codex/REVIEW_BOARD.md`
- `.codex/PR_PROTOCOL.md`
- relevant source owner files
- relevant tests

## Allowed Scope

- List exact files or directories the batch may change.
- List exact tests or validation scripts the batch may run.
- Keep implementation bounded to the GPT-5.5 plan handoff.

## Forbidden Scope

- No app feature outside this batch.
- No SwiftUI redesign outside the named owner seam.
- No production source outside allowed files.
- No dependency, hosted CI, provider/backend, signing, entitlement, or project
  mutation unless explicitly scoped and approved.
- No canon rewrite.
- No release, accessibility, privacy, performance, or production claims without
  current evidence.

## Validation Expectations

- `git diff --check`
- `scripts/codex-forbidden-claim-scan.sh <changed files>`
- focused build/test commands selected by GPT-5.5 planning
- review-board lanes selected from `.codex/REVIEW_BOARD.md`
- exact commands, exit codes, and not-run checks recorded

If the prompt lint/pre-guard failure is limited to wording, missing inspection
terms, or old-term prompt triggers, the runner may enter explicit prompt
self-heal mode, repair only this prompt, and continue without requiring a
manual rerun. Prompt self-heal must be reported separately from source edits.

## Xcode Fast-Trust Route

- Use the Ambitions Xcode Build Lab wrapper for simulator build/test proof:
  `make xcode-focused-test BATCH=<BATCH_ID> TEST=<test-id>` or
  `scripts/ambitions-xcode-validate.sh --batch <BATCH_ID> --lane focused-test --test <test-id>`.
- After any Swift source or Swift test edit, run build-for-testing before
  focused tests. Do not accept focused-test proof from stale test bundles or
  from raw logs that executed zero intended tests.
- Focused test suites run serially by default with unique per-suite artifact
  directories. Prefer fully qualified test identifiers and record raw executed
  suite/test counts from the wrapper summary.
- Use `make xcode-build-for-testing` once when build reuse is useful or Swift
  source/test files changed before focused tests.
- Use `make xcode-test-plan` only when the batch genuinely needs a test plan.
- Prefer `ambitionsProof.run_named_validation` wrapper-native validations when
  using MCP proof.
- Do not run raw `xcodebuild` from nested Codex phases unless this prompt
  explicitly requires raw command proof.
- Do not retry `xcodebuildmcp.test_sim` after a 120-second timeout; recover
  through the wrapper lane and record the timeout as not XCTest proof.
- Wrapper summaries under `.codex/xcode-summaries/` are local engineering
  evidence only and do not imply release/device/accessibility/performance proof.

## Visual Proof Expectations If UI Changes

- Capture current screenshot/preview/simulator evidence when visual quality is
  claimed.
- Include default and non-ideal states when practical.
- Record Dynamic Type, Reduce Motion, and accessibility proof or explicitly
  state they were not run.
- Do not claim visual approval from docs alone.

## Hard Red Stop Conditions

- Source mutation outside allowed scope.
- The bounded patch model makes architecture, canon, continuation, cleanup, or final commit
  decisions.
- False implementation, release, accessibility, privacy, performance, device,
  hosted CI, or production claim.
- Blocked backend/provider/cloud/external LLM reintroduction.
- Obsolete authority path overrides `docs/truth/*`.
- Validation contradiction or missing rollback.

## Rollback Expectations

- Record the starting commit.
- Save changed-file summary and patch.
- On Red, leave changes uncommitted unless the runner is explicitly configured
  with `AUTO_ROLLBACK_ON_RED=1`.
- If a commit is created, the runner does not push by default. Enable push only
  with explicit owner intent:

```bash
AUTO_PUSH=1 make batch BATCH=<BATCH_ID> PROMPT=<PROMPT_FILE>
```

- No release, build, accessibility, performance, visual, device, TestFlight, or
  App Store proof is implied by the runner.
- Use the runner-provided rollback command if the batch must be discarded.

## Runner Command

```bash
make batch BATCH=<BATCH_ID> PROMPT=<PROMPT_FILE>
```
