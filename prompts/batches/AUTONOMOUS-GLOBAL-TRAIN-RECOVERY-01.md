<!-- AMBITIONS_RUNNER_REQUIRED: true -->
<!-- RUN_WITH: scripts/ambitions-codex-train.sh -->
<!-- DIRECT_CODEX_EXECUTION: forbidden_unless_user_explicitly_bypasses_runner -->

# Batch ID

`AUTONOMOUS-GLOBAL-TRAIN-RECOVERY-01`

# Objective

Recover Ambitions global batch execution so it can run autonomously from the
current repo state without nested runner loops, self-blocking process checks,
dirty-worktree inheritance, Xcode lock churn, or manual prompt drip.

Codex is authorized to act as a senior autonomous Ambitions engineering
department. If the current runner architecture is the cause of failures, simplify
it, bypass it for this recovery, or decommission it as the default execution path.
The goal is completing the remaining global batch train efficiently while
preserving source truth, proof honesty, rollback discipline, and Ambitions
quality.

Do not preserve the runner for its own sake.
Do not run a nested global conductor loop.
Do not make release/readiness/accessibility/performance/device/TestFlight/App
Store claims without current proof.

# Required Initial Read Order

Read first:

1. `docs/truth/README.md`
2. `docs/truth/PRODUCT_DESIGN_TRUTH.md`
3. `docs/truth/IMPLEMENTATION_TRUTH.md`
4. `docs/truth/RELEASE_TRUTH.md`
5. `docs/truth/CODEX_PROCESS_TRUTH.md`
6. `docs/truth/HISTORICAL_POLICY.md`
7. `AGENTS.md`
8. `.codex/state/active-batch.yml`
9. `.codex/state/global-train-attempt-ledger.md`, if present
10. `.codex/reports/current-batch-train-state.md`
11. `docs/audits/global-sequence-autonomy-audit.md`, if present
12. `docs/audits/global-runner-loop-proof-report.md`, if present
13. `docs/audits/runner-repair-autopilot-report.md`, if present
14. `docs/codex/BATCH_REGISTRY.md`
15. `docs/codex/GLOBAL_QUEUE_MATURITY_LEDGER.md`
16. `docs/codex/GLOBAL_QUEUE_CANONICAL_ORDER.json`
17. `docs/codex/GLOBAL_FULL_STACK_COMPLETION_ORDER.md`
18. `docs/codex/GLOBAL_FULL_STACK_COMPLETION_ORDER_EFC_PEAK_OVERLAY.md`
19. `docs/codex/BATCH_REGISTRY_EFC_OVERLAY.md`
20. `docs/codex/EFC_FLAGSHIP_PROOF_OPERATING_LAYER.md`
21. `docs/codex/POST_BATCH_GATE_REGISTRY.md`
22. `docs/codex/MODEL_TIER_EXECUTION_POLICY.md`
23. `docs/codex/MODEL_TIER_BATCH_MATRIX.md`
24. `scripts/ambitions-codex-train.sh`, if still relevant
25. `scripts/ambitions-global-train-supervisor.sh`, if still relevant
26. `scripts/ambitions-process-preflight.sh`, if present
27. `scripts/ambitions-prompt-audit.sh`
28. `Makefile`
29. `prompts/batches/PK15.md`, if present
30. `prompts/batches/PK15-FINALIZE-01.md`, if present
31. current git status and diff

Truth hierarchy:

```text
docs/truth/*
→ live repo source/project/test/script evidence
→ current batch state
→ current run artifacts
→ canonical queue/order
→ registry/support docs
→ historical docs
```

# Phase 0 - Stop Runaway Work

Before edits, inspect:

```bash
pgrep -fl 'ambitions-codex-train|codex exec|xcodebuild' || true
ps -axo pid=,ppid=,command= | grep -E 'ambitions-codex-train|codex exec|xcodebuild' | grep -v grep || true
```

If actual runaway runner/Codex/xcodebuild processes exist, stop only those real
conflicts:

```bash
pkill -f 'ambitions-codex-train' || true
pkill -f 'codex exec' || true
pkill -f '/usr/bin/xcodebuild|/Applications/Xcode.*xcodebuild|xcodebuild -project|xcodebuild .* test|xcodebuild .* build' || true
sleep 3
pgrep -fl 'ambitions-codex-train|codex exec|xcodebuild' || true
```

Do not kill `xcodebuildmcp` helpers unless they are actually running an Xcode
build/test job.

# Phase 1 - Snapshot And Classify Dirty Worktree

Run:

```bash
STAMP="$(date -u +%Y%m%dT%H%M%SZ)"
mkdir -p .codex/safety
git status --short --branch | tee ".codex/safety/status-before-autonomous-recovery-$STAMP.txt"
git diff --stat | tee ".codex/safety/diffstat-before-autonomous-recovery-$STAMP.txt"
git diff --numstat | sort -nr | tee ".codex/safety/numstat-before-autonomous-recovery-$STAMP.txt"
git diff --name-status | tee ".codex/safety/name-status-before-autonomous-recovery-$STAMP.txt"
git diff > ".codex/safety/full-diff-before-autonomous-recovery-$STAMP.patch"
git ls-files --others --exclude-standard | tee ".codex/safety/untracked-before-autonomous-recovery-$STAMP.txt"
```

Classify every dirty path:

- A. valid PK15 source/test work
- B. valid runner/governance/autonomy work
- C. generated/build/run artifacts
- D. untracked `.codex/runs` evidence
- E. temporary logs/output
- F. unexpected risky changes

Expected valid PK15 paths may include `Native/Ambitions/Persistence/`,
`Native/AmbitionsTests/Persistence/ActionReceiptHistoryRepositoryTests.swift`,
PK15 audit docs, `.codex/state/`, `.codex/reports/`, and queue/registry files.

# Phase 2 - Clean Dirty Worktree Without Losing Real Work

Reduce the dirty tree to only valid active work.

Preserve valid PK15 source/test work and valid governance/autonomy work. Remove
or ignore `.codex/runs/**`. Remove generated/build artifacts when safe. Restore
unrelated tracked files from HEAD only after the safety patch exists. Never use
`git clean -fdx`.

Allowed cleanup examples:

```bash
rm -rf .codex/runs
git clean -fd -- output DerivedData .build 2>/dev/null || true
git restore -- <unrelated-tracked-path>
```

If classification is uncertain, create
`docs/audits/autonomous-recovery-dirty-worktree-report.md` and continue only on a
conservative path-limited cleanup.

# Phase 3 - Decide Whether To Keep Or Replace The Runner

Inspect runner/supervisor scripts and answer:

1. Is `scripts/ambitions-codex-train.sh` causing loop/self-block failures?
2. Is `scripts/ambitions-global-train-supervisor.sh` reliable enough?
3. Is process preflight robust?
4. Are repair/finalization states represented correctly?
5. Does using the runner add more complexity than value?

If the runner remains the bottleneck, create `scripts/ambitions-autonomous-train.sh`
with:

```bash
scripts/ambitions-autonomous-train.sh --status
scripts/ambitions-autonomous-train.sh --next
scripts/ambitions-autonomous-train.sh --run-current
scripts/ambitions-autonomous-train.sh --until-complete
```

It must run one batch at a time, never recursively spawn itself, determine the
next eligible batch from queue/state, run or repair each batch, commit
path-limited results, update queue/state, and stop only on unrecoverable safety
conditions.

If the old runner is decommissioned as default, update docs and Makefile so the
new default command is:

```bash
make autonomous-train
```

or:

```bash
scripts/ambitions-autonomous-train.sh --until-complete
```

# Phase 4 - Finish PK15

Do not restart PK15 from scratch unless the existing PK15 diff is invalid.

If current PK15 diff is valid:

1. finalize existing PK15 work
2. run focused PK15 validation
3. classify unrelated full-suite failures
4. update PK15 report/state/queue
5. commit path-limited PK15 work
6. continue to PK16

If current PK15 diff is invalid, revert only invalid PK15 paths after the safety
patch exists, regenerate PK15 cleanly, validate, commit if Green or accepted
Yellow, then continue.

Expected PK15 validation:

- focused `ActionReceiptHistoryRepositoryTests` or exact owning PK15 tests
- `git diff --check`
- queue JSON parse if queue changed
- claim scan if available

Do not rerun full suite repeatedly when the only known failure is
`ExternalSurfaceVerificationChecklistTests.testM04ExistingProjectionsCarryStalePrivateAndFallbackBehavior`.
If accepted Yellow is needed, record owner `QA / External Surface`, reason,
retirement condition, and resume path.

# Phase 5 - Autonomous Batch Execution Model

After PK15 closes, continue remaining global train:

```text
one batch
→ bounded implementation
→ focused validation
→ automatic repair if ordinary failure
→ commit
→ update queue/state
→ next batch
```

No nested global conductor. No repeated same-root repair more than twice. No
concurrent Xcode builds. No broad dirty-tree inheritance.

# Ordinary Red Handling

Ordinary Red means repair required, not permanent stop. Diagnose, patch within
current batch scope, rerun focused validation, commit if fixed, and continue.

# Unrecoverable Red Handling

Stop only for genuinely unrecoverable Red:

- source truth conflict that cannot be resolved safely
- required truth file missing
- queue/order cannot be parsed or reconstructed
- dirty worktree contains unknown user work that cannot be separated
- destructive data loss would be required
- secrets/signing/provisioning would be touched
- forbidden external/backend/cloud/provider/hosted CI work would be required
- privacy/legal ambiguity requiring human approval
- repeated same-root failure after two focused repairs
- validation environment unavailable and no focused proof can be produced
- Git state unsafe to commit
- rollback impossible

# Validation Policy

Choose validation by scope.

Minimum docs/governance validation:

```bash
git diff --check
bash -n changed shell scripts
python3 -m json.tool changed JSON files
```

Minimum source validation:

```bash
git diff --check
xcodegen generate if needed
focused xcodebuild tests for touched area
```

Separate run, passed, failed, not run, skipped with reason, and unproven.

# Commit Policy

Commit after each Green or accepted-Yellow batch. Use path-limited staging only.
Never use `git add -A`, `git add .`, or `git commit -a`.

Never commit `.codex/runs/**`, `DerivedData/**`, `.build/**`, output log noise
unless intentionally selected proof, secrets, or signing material.

# Required Report

Create or update:

```text
docs/audits/autonomous-global-train-recovery-report.md
```

Include:

- Status
- Dirty Worktree Cleanup
- Runner Decision
- PK15 Result
- Autonomous Execution Model
- Remaining Queue
- Validation
- Claims Not Made

Maintain state/registry/queue files only when evidence supports updates.

# Allowed Scope

Recovery/governance phase may change:

```text
scripts/
Makefile
prompts/
docs/codex/
docs/audits/
.codex/state/
.codex/reports/
```

PK15 phase may change:

```text
Native/Ambitions/Persistence/
Native/AmbitionsTests/Persistence/
docs/audits/pk15-*.md
.codex/state/
.codex/reports/
docs/codex/BATCH_REGISTRY.md
docs/codex/GLOBAL_QUEUE_MATURITY_LEDGER.md
docs/codex/GLOBAL_QUEUE_CANONICAL_ORDER.json
```

Subsequent batch scope must be determined from registry/order/truth files and
recorded before edits.

# Forbidden Global Scope Without Explicit Approval

Do not modify `docs/truth/`, `.github/workflows/`, signing/provisioning
material, secrets, external/backend/provider config, hosted CI, App
Store/TestFlight automation, new dependencies, account systems, or external/cloud
LLM core integration.

# Top-Level IA Rule

Active user-facing top-level IA is:

```text
Today / Goals / Capture / Time / You
```

`Plan` is not active top-level IA.

# Release Claim Rule

Do not claim release-ready, production-ready, TestFlight-ready, App Store-ready,
device-validated, fully accessible, performance-validated, privacy/legal-approved,
CI-proven, or full test suite Green unless current proof exists and
`RELEASE_TRUTH.md` allows it.

# Final Completion Criteria

Continue until complete queue/state agreement or unrecoverable Red. Ordinary
failures must be repaired automatically.

# Final Response Format

End with:

```markdown
## Status

STATUS: GREEN | STATUS: YELLOW | STATUS: RED

## What Was Fixed

- dirty worktree:
- runner/supervisor:
- PK15:
- autonomous train:

## Runner Decision

- kept:
- replaced:
- removed as default:
- final command:

## Batches Completed

| Batch | Status | Commit | Validation | Notes |
|---|---|---|---|---|

## Repairs Performed

| Batch | Failure | Repair | Result |
|---|---|---|---|

## Remaining Work

- next batch:
- normal autonomous remaining:
- real future work remaining:

## Validation Summary

Commands run:
- command — exit code — result

Commands not run:
- command — reason

## Commits

- commit — batch — summary

## Accepted Yellow

- item — owner — reason — retirement condition — resume path

## Unrecoverable Red, If Any

- reason:
- evidence:
- safest next action:

## Claims Not Made

- release readiness
- full test success unless proven
- visual quality unless proven
- accessibility conformance
- performance validation
- physical-device validation
- TestFlight/App Store readiness
- privacy/legal approval

## Next Command

If not complete, provide exactly one command to continue.
```
