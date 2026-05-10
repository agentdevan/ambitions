<!-- AMBITIONS_RUNNER_REQUIRED: true -->
<!-- RUN_WITH: scripts/ambitions-codex-train.sh -->
<!-- DIRECT_CODEX_EXECUTION: forbidden_unless_user_explicitly_bypasses_runner -->

# Batch ID

`CLEAR-RUNNER-CONFLICTS-01`

# Runner Command

```bash
make batch BATCH=CLEAR-RUNNER-CONFLICTS-01 PROMPT=prompts/batches/CLEAR-RUNNER-CONFLICTS-01.md
```

# Objective

Clear the active overlapping PK15/Codex/Xcode process conflict, preserve and commit the loop-proof global-train governance layer, and leave the repo ready for exactly one top-level `PK15-FINALIZE-01` run.

This is a **runner/process/governance cleanup and commit gate**.

Do **not** run PK15.
Do **not** run `PK15-FINALIZE-01`.
Do **not** run the full global train.
Do **not** implement app features.
Do **not** touch app source except to preserve pre-existing PK15 dirty work as-is.
Do **not** claim PK15 completion.

The goal is:

1. Stop overlapping runner/Codex/Xcode processes.
2. Confirm no runner/Codex/Xcode process remains.
3. Separate pre-existing PK15 dirty work from loop-proof governance files.
4. Commit only the loop-proof governance layer if it is valid.
5. Leave PK15 source/test diff uncommitted for `PK15-FINALIZE-01`.
6. Report the exact next command.

---

# Ambitions Standard

Operate as a senior FAANG-level repo/process department:

* source-truth first
* no uncontrolled automation loops
* no nested runner recursion
* no broad staging
* no hidden mutation
* no false completion claims
* no release/readiness claims
* path-limited commits only
* preserve user/source work
* leave a clean, deterministic next step

---

# Known Current State

The previous batch reported:

* `GLOBAL-RUNNER-LOOP-PROOF-01` reached `STATUS: YELLOW`.
* Loop-proof governance files were changed.
* Existing PK15 persistence/test changes were already dirty and unresolved.
* Active conflicting processes were detected:

  * PK15/Codex runner processes including `7766`, `17012`, `17021`, `17023`
  * active `xcodebuild` process `26422`
* `PK15-FINALIZE-01` was not run because process overlap would recreate the failure.
* Next safe batch should be:
  `make batch BATCH=PK15-FINALIZE-01 PROMPT=prompts/batches/PK15-FINALIZE-01.md`

Treat active process overlap as the primary blocker.

---

# Active Source Truth To Inspect

Read first:

1. `docs/truth/README.md`
2. `docs/truth/CODEX_PROCESS_TRUTH.md`
3. `docs/truth/RELEASE_TRUTH.md`
4. `AGENTS.md`
5. `.codex/state/global-train-attempt-ledger.md`, if present
6. `docs/audits/global-runner-loop-proof-report.md`, if present
7. `docs/codex/global-train-supervisor.md`, if present
8. `prompts/_BATCH_FINALIZE_TEMPLATE.md`, if present
9. `prompts/batches/PK15-FINALIZE-01.md`, if present
10. `scripts/ambitions-global-train-supervisor.sh`, if present
11. `scripts/ambitions-codex-train.sh`
12. `scripts/ambitions-prompt-audit.sh`
13. `Makefile`

Also inspect:

```bash
git status --short --branch
git diff --name-only
pgrep -fl 'ambitions-codex-train|codex exec|xcodebuild' || true
```

---

# Required Work

## 1. Stop Conflicting Processes

Check active processes:

```bash
pgrep -fl 'ambitions-codex-train|codex exec|xcodebuild' || true
```

If active conflicting processes exist, stop them safely:

```bash
kill 7766 17012 17021 17023 26422 2>/dev/null || true
sleep 3
pgrep -fl 'ambitions-codex-train|codex exec|xcodebuild' || true
```

If those PIDs are stale but other matching processes remain, use:

```bash
pkill -f 'ambitions-codex-train|codex exec|xcodebuild' || true
sleep 3
pgrep -fl 'ambitions-codex-train|codex exec|xcodebuild' || true
```

Do not kill unrelated user processes.

If matching processes remain after this, stop with `STATUS: RED`.

## 2. Inspect Dirty Worktree

Run:

```bash
git status --short --branch
git diff --name-only
```

Classify changed files into:

```text
A. loop-proof governance files from GLOBAL-RUNNER-LOOP-PROOF-01
B. unresolved PK15 source/test files
C. untracked .codex/runs evidence artifacts
D. unexpected files
```

Do not stage or commit unresolved PK15 source/test files.

Do not stage `.codex/runs/**`.

If unexpected files exist, stop Yellow or Red depending on risk and report them.

## 3. Validate Governance Layer

Validate only governance/tooling files, not PK15 implementation.

Run:

```bash
git diff --check
python3 -m json.tool docs/codex/GLOBAL_QUEUE_CANONICAL_ORDER.json >/tmp/ambitions-global-queue-json-check.txt
bash -n scripts/ambitions-codex-train.sh
bash -n scripts/ambitions-prompt-audit.sh
bash -n scripts/ambitions-global-train-supervisor.sh
test -x scripts/ambitions-codex-train.sh
test -x scripts/ambitions-prompt-audit.sh
test -x scripts/ambitions-global-train-supervisor.sh
make -n global-train-status
make -n global-train-next
make -n global-train-once
make -n global-train-until-complete
scripts/ambitions-global-train-supervisor.sh --status
scripts/ambitions-global-train-supervisor.sh --next
scripts/ambitions-prompt-audit.sh
scripts/ambitions-codex-train.sh --self-check
```

If any command cannot run because unresolved PK15 source dirt interferes, report exactly and stop Yellow.

## 4. Commit Only Loop-Proof Governance Files

If validation passes, stage only these files if present/changed:

```text
.codex/state/global-train-attempt-ledger.md
scripts/ambitions-global-train-supervisor.sh
Makefile
prompts/_BATCH_FINALIZE_TEMPLATE.md
prompts/batches/PK15-FINALIZE-01.md
prompts/batches/RUN-GLOBAL-BATCH-TRAIN-TO-COMPLETION.md
prompts/batches/GLOBAL-RUNNER-LOOP-PROOF-01.md
docs/codex/global-train-supervisor.md
docs/audits/global-runner-loop-proof-report.md
```

Do not use:

```bash
git add -A
git add .
git commit -a
```

Use path-limited `git add`.

Before commit, run:

```bash
git diff --cached --check
git diff --cached --name-only
```

Confirm the staged set excludes:

```text
.codex/runs/**
Native/**
Sources/**
AppUI/**
Package.swift
project.yml
docs/truth/**
```

Commit message:

```text
GLOBAL-RUNNER-LOOP-PROOF-01: harden global train supervisor
```

Commit body must include:

* process overlap cleared
* loop guards preserved
* supervisor commands validated
* PK15 left unresolved for finalization
* claims not made

Push to `main` only if commit succeeds and the current branch is `main`.

## 5. Leave PK15 Work Alone

Do not revert PK15 work.

Do not commit PK15 work.

Do not run PK15.

Do not run `PK15-FINALIZE-01`.

The output should leave the repo ready for this next command:

```bash
ALLOW_DIRTY=1 ALLOW_MAIN_COMMIT=1 AUTO_BRANCH=0 make batch BATCH=PK15-FINALIZE-01 PROMPT=prompts/batches/PK15-FINALIZE-01.md
```

---

# Allowed Scope

You may modify or commit only:

```text
.codex/state/global-train-attempt-ledger.md
scripts/ambitions-global-train-supervisor.sh
Makefile
prompts/_BATCH_FINALIZE_TEMPLATE.md
prompts/batches/PK15-FINALIZE-01.md
prompts/batches/RUN-GLOBAL-BATCH-TRAIN-TO-COMPLETION.md
prompts/batches/GLOBAL-RUNNER-LOOP-PROOF-01.md
docs/codex/global-train-supervisor.md
docs/audits/global-runner-loop-proof-report.md
```

You may read any file needed for diagnosis.

---

# Forbidden Scope

Do not modify or commit:

```text
Native/
Sources/
AppUI/
Package.swift
project.yml
docs/truth/
.github/
Native/AmbitionsTests/
Native/AmbitionsUITests/
.codex/runs/
```

Do not:

* run PK15
* run PK15-FINALIZE-01
* run global train
* implement app features
* repair source tests
* edit app code
* delete run artifacts
* broad-stage files
* claim PK15 completion
* claim global train completion
* claim release/build/accessibility/performance/device/App Store/TestFlight readiness

---

# Hard Red Stop Conditions

Stop with `STATUS: RED` if:

* conflicting runner/Codex/Xcode processes cannot be stopped
* governance files cannot be separated from PK15 dirty work
* validation fails for the governance layer
* staging would include PK15 source/test files
* staging would include `.codex/runs/**`
* staging would require broad `git add -A`
* current branch is not `main` and push target is unclear
* loop-proof governance is incomplete or unsafe
* a PK15 or global train run would be required to validate this batch

---

# Final Report Format

End with:

```markdown
## Status

STATUS: GREEN | STATUS: YELLOW | STATUS: RED

## Scope

What was cleared, validated, staged, committed, and pushed.

## Processes

- before:
- stopped:
- remaining:

## Worktree Classification

- loop-proof governance files:
- unresolved PK15 files:
- untracked run artifacts:
- unexpected files:

## Validation

Commands run:
- command - exit code - result

Commands not run:
- command - reason

## Commit

- committed:
- commit SHA:
- pushed:
- staged files:

## PK15 State

- PK15 source/test work preserved:
- PK15 committed:
- PK15 finalize prompt exists:
- ready for finalization:

## Claims Not Made

- PK15 completion
- global train completion
- release readiness
- full build/test success
- visual quality
- accessibility conformance
- performance validation
- device validation
- TestFlight/App Store readiness

## Next Command

If Green, run:

```bash
ALLOW_DIRTY=1 ALLOW_MAIN_COMMIT=1 AUTO_BRANCH=0 make batch BATCH=PK15-FINALIZE-01 PROMPT=prompts/batches/PK15-FINALIZE-01.md
```

Do not run `make global-train-until-complete` until `PK15-FINALIZE-01` closes Green or accepted Yellow.
```
