<!-- AMBITIONS_RUNNER_REQUIRED: true -->
<!-- RUN_WITH: scripts/ambitions-codex-train.sh -->
<!-- DIRECT_CODEX_EXECUTION: forbidden_unless_user_explicitly_bypasses_runner -->

# Batch ID

`RUNNER-REPAIR-AUTOPILOT-01`

# Runner Command

```bash
ALLOW_DIRTY=1 ALLOW_MAIN_COMMIT=1 AUTO_BRANCH=0 make batch BATCH=RUNNER-REPAIR-AUTOPILOT-01 PROMPT=prompts/batches/RUNNER-REPAIR-AUTOPILOT-01.md
```

# Objective

Actually fix the Ambitions runner/supervisor repair loop so current dirty batch work can be finalized without self-blocking, false process matches, nested loops, repeated same-root retries, or manual babysitting.

This batch must repair the automation system, not PK15 product code.

The immediate bug to fix:

* `PK15-FINALIZE-01` stopped Red in Phase 01 because its process preflight matched its own active runner process.
* The same broad preflight also matched `xcodebuildmcp` helper processes because their names contain `xcodebuild`.
* There was no actual active `xcodebuild` validation job.
* Therefore the preflight was too broad and created a false Hard Red.
* This class of failure must be fixed centrally, not patched manually per prompt.

The required outcome:

1. Add a reusable process-preflight helper that distinguishes real conflicting processes from the current runner and benign helper names.
2. Update the runner/supervisor/finalization prompt system to use that helper.
3. Add a bounded repair-autopilot path for unresolved batch finalization.
4. Update `PK15-FINALIZE-01` so it no longer self-blocks.
5. Validate the repair without running PK15 implementation or the global train.
6. Leave the repo ready to run one clean `PK15-FINALIZE-01` attempt.
7. If safe, commit and push only this runner/governance repair.

Do **not** run PK15 product implementation.
Do **not** run the full global train.
Do **not** touch app source.
Do **not** claim PK15 complete.
Do **not** claim release/build/accessibility/performance/device/App Store/TestFlight readiness.

---

# Ambitions Standard

Operate at Ambitions’ senior-department bar:

* evidence-bound automation
* no false Red loops
* no uncontrolled retries
* no nested runner recursion
* no broad process matching
* no hidden mutation
* no broad staging
* no false completion claims
* path-limited commits only
* source-truth first
* validation honest
* repair loops bounded and deterministic

Codex must behave like a senior platform/build/release automation team.

---

# Active Source Truth To Inspect

Read these first:

1. `docs/truth/README.md`
2. `docs/truth/CODEX_PROCESS_TRUTH.md`
3. `docs/truth/RELEASE_TRUTH.md`
4. `docs/truth/IMPLEMENTATION_TRUTH.md`
5. `AGENTS.md`
6. `.codex/state/global-train-attempt-ledger.md`
7. `.codex/reports/current-batch-train-state.md`
8. `docs/codex/global-train-supervisor.md`
9. `docs/audits/global-runner-loop-proof-report.md`
10. `prompts/_BATCH_FINALIZE_TEMPLATE.md`
11. `prompts/batches/PK15-FINALIZE-01.md`
12. `scripts/ambitions-codex-train.sh`
13. `scripts/ambitions-global-train-supervisor.sh`
14. `scripts/ambitions-prompt-audit.sh`
15. `Makefile`

Also inspect current dirty files:

```bash
git status --short --branch
git diff --name-only
```

---

# Required Diagnosis

Create or update:

```text
docs/audits/runner-repair-autopilot-report.md
```

It must answer:

1. Why did `PK15-FINALIZE-01` self-block?
2. Which process patterns are too broad?
3. Which processes should count as blockers?
4. Which processes should be ignored?
5. How does the new helper avoid matching the current runner?
6. How does the new helper avoid treating `xcodebuildmcp` as a real validation job?
7. How does the new repair-autopilot prevent repeated same-root failures?
8. What exact command should run next?

---

# Required Repair 1 — Add Central Process Preflight Helper

Create:

```text
scripts/ambitions-process-preflight.sh
```

The script must be bash:

```bash
#!/usr/bin/env bash
set -Eeuo pipefail
```

It must support:

```bash
scripts/ambitions-process-preflight.sh --status
scripts/ambitions-process-preflight.sh --assert-clear
scripts/ambitions-process-preflight.sh --json
```

## It must detect real blockers

Blockers:

* another `scripts/ambitions-codex-train.sh` process **not equal to the current runner/process tree**
* another `codex exec` process **not equal to the current runner/process tree**
* a real `xcodebuild` validation/build process
* a real `xcodebuild` process launched by this repo
* a stale lock file whose PID is alive

## It must ignore false positives

Ignore:

* the current `RUNNER-REPAIR-AUTOPILOT-01` runner process
* parent shell process of this batch
* current `codex exec` process executing this batch
* `xcodebuildmcp`
* MCP helper processes whose command contains `xcodebuildmcp`
* grep/pgrep helper processes
* dead PIDs
* stale lock files whose PID is no longer alive, after reporting and safely clearing or advising cleanup

## It must be careful

Do not kill processes.

Do not mutate the repo except optional stale lock cleanup if implemented safely.

If blockers exist, print:

```text
STATUS: BLOCKED
```

If clear, print:

```text
STATUS: CLEAR
```

If uncertain, print:

```text
STATUS: UNKNOWN
```

`--assert-clear` must exit:

* `0` for clear
* `86` for blocked
* `87` for unknown

The helper must use reliable process inspection, not only broad `pgrep -fl xcodebuild`.

Acceptable implementation approaches:

* inspect `ps -axo pid=,ppid=,command=`
* exclude `$$`, parent shell, and process ancestry where possible
* match real `xcodebuild` command carefully, not substring `xcodebuildmcp`
* match `codex exec` carefully
* match `ambitions-codex-train.sh` carefully

---

# Required Repair 2 — Wire Helper Into Supervisor

Update:

```text
scripts/ambitions-global-train-supervisor.sh
```

Replace broad process checks with:

```bash
scripts/ambitions-process-preflight.sh --assert-clear
```

The supervisor must stop if the helper returns blocked or unknown.

It must not use broad:

```bash
pgrep -fl 'ambitions-codex-train|codex exec|xcodebuild'
```

except as debug output after the helper has classified blockers.

---

# Required Repair 3 — Wire Helper Into Finalization Template

Update:

```text
prompts/_BATCH_FINALIZE_TEMPLATE.md
prompts/batches/PK15-FINALIZE-01.md
```

Replace broad hard-red process preflight with:

```bash
scripts/ambitions-process-preflight.sh --assert-clear
```

The finalization prompt must say:

* Do not treat the current runner process as a blocker.
* Do not treat `xcodebuildmcp` as a real `xcodebuild` validation job.
* If the helper reports blocked, stop Red and report exact blockers.
* If the helper reports clear, continue.
* If the helper reports unknown, stop Yellow/Red depending on risk.

---

# Required Repair 4 — Add Repair Autopilot Command

Add to `Makefile`:

```make
repair-status
repair-next
repair-current
```

Expected behavior:

```bash
make repair-status
make repair-next
make repair-current
```

## `repair-status`

Runs:

```bash
scripts/ambitions-process-preflight.sh --status
git status --short --branch
```

## `repair-next`

Prints the next safe repair/finalization target from:

1. `.codex/state/global-train-attempt-ledger.md`
2. existing `*-FINALIZE-01.md`
3. existing `*-REPAIR-01.md`
4. current active batch state

For the current state, it should identify:

```text
PK15-FINALIZE-01
```

## `repair-current`

Must be safe and deterministic.

It may run only when:

* process preflight is clear
* next safe target is a `*-FINALIZE-01` or `*-REPAIR-01` prompt
* prompt exists
* dirty worktree is expected or allowed

It should print the exact command before running.

For current state, expected command:

```bash
ALLOW_DIRTY=1 ALLOW_MAIN_COMMIT=1 AUTO_BRANCH=0 make batch BATCH=PK15-FINALIZE-01 PROMPT=prompts/batches/PK15-FINALIZE-01.md
```

Do not make `repair-current` run global train.

---

# Required Repair 5 — Update Runner Self-Check

Update `scripts/ambitions-codex-train.sh --self-check` if needed so it verifies:

* process preflight helper exists
* process preflight helper syntax passes
* process preflight helper does not classify `xcodebuildmcp` as a blocker in a sample/mock or documented test path
* nested-run guard still exists
* path-limited staging still exists
* no auto-push default regression

If runner self-check cannot include mocks safely, document that the process helper is validated separately.

---

# Required Repair 6 — Add Prompt/Runbook Guidance

Update:

```text
docs/codex/global-train-supervisor.md
docs/audits/global-runner-loop-proof-report.md
docs/audits/runner-repair-autopilot-report.md
```

They must say:

* broad `pgrep` is forbidden as a Hard Red gate
* use `scripts/ambitions-process-preflight.sh`
* `xcodebuildmcp` is not an `xcodebuild` validation process
* the current runner process is not a conflict
* unresolved batch work should use finalization/repair prompt, not rerun original batch
* full train resumes only after finalization closes Green or accepted Yellow

---

# Allowed Scope

You may modify only:

```text
scripts/ambitions-process-preflight.sh
scripts/ambitions-global-train-supervisor.sh
scripts/ambitions-codex-train.sh
scripts/ambitions-prompt-audit.sh
Makefile
prompts/_BATCH_FINALIZE_TEMPLATE.md
prompts/batches/PK15-FINALIZE-01.md
docs/codex/global-train-supervisor.md
docs/audits/global-runner-loop-proof-report.md
docs/audits/runner-repair-autopilot-report.md
.codex/state/global-train-attempt-ledger.md
```

You may read any file needed for diagnosis.

---

# Forbidden Scope

Do not modify:

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
```

Do not:

* run PK15
* run `PK15-FINALIZE-01`
* run the full global train
* edit app source
* fix product tests
* commit PK15 dirty source/test work
* delete `.codex/runs/`
* kill processes
* add hosted CI
* add dependencies
* add signing/TestFlight/App Store automation
* add backend/provider/cloud/LLM behavior
* use broad staging
* claim PK15 completion
* claim global train completion

---

# Validation Expectations

Run and record:

```bash
git diff --check
bash -n scripts/ambitions-process-preflight.sh
bash -n scripts/ambitions-global-train-supervisor.sh
bash -n scripts/ambitions-codex-train.sh
bash -n scripts/ambitions-prompt-audit.sh
test -x scripts/ambitions-process-preflight.sh
test -x scripts/ambitions-global-train-supervisor.sh
test -x scripts/ambitions-codex-train.sh
scripts/ambitions-process-preflight.sh --status
scripts/ambitions-process-preflight.sh --assert-clear
make -n repair-status
make -n repair-next
make -n repair-current
make -n global-train-status
make -n global-train-next
scripts/ambitions-global-train-supervisor.sh --status
scripts/ambitions-global-train-supervisor.sh --next
scripts/ambitions-codex-train.sh --self-check
scripts/ambitions-prompt-audit.sh
```

If `scripts/ambitions-process-preflight.sh --assert-clear` reports blocked because a real process exists, do not kill it. Stop Red and report.

If it reports blocked only because of the current runner or `xcodebuildmcp`, repair the helper and rerun validation.

Do not run:

```bash
make repair-current
make batch BATCH=PK15-FINALIZE-01 ...
make global-train-until-complete
```

This batch must set up the repair autopilot but not execute PK15 finalization.

---

# Commit Rule

If Green:

* stage only explicit allowed files
* do not stage PK15 source/test files
* do not stage `.codex/runs/**`
* do not use `git add -A`
* do not use `git add .`
* do not use `git commit -a`

Commit message:

```text
RUNNER-REPAIR-AUTOPILOT-01: fix process preflight and repair flow
```

Commit body must include:

* process preflight false-positive repair
* repair-current target
* validation results
* PK15 remains unresolved
* claims not made

Push to `main` if branch is `main` and commit succeeds.

---

# Hard Red Stop Conditions

Stop with `STATUS: RED` if:

* process preflight cannot avoid self-matching
* `xcodebuildmcp` still causes a blocker classification
* real active `xcodebuild` / runner / codex process exists
* helper is uncertain and cannot be made deterministic
* app source would need to be touched
* PK15 would need to be run to validate this batch
* broad process matching remains as a hard-red gate
* broad staging is required
* validation fails
* unsupported release/readiness claims would be introduced

---

# Final Report Format

End with:

```markdown
## Status

STATUS: GREEN | STATUS: YELLOW | STATUS: RED

## Scope

What was fixed and what was not run.

## Root Cause Fixed

- self-runner false positive:
- xcodebuildmcp false positive:
- broad pgrep hard-red gate:
- repair cycle automation:

## Files Changed

- path — reason

## Process Preflight

- helper:
- status:
- assert-clear:
- blockers:
- ignored false positives:

## Repair Autopilot

- repair-status:
- repair-next:
- repair-current:
- next target:

## Validation

Commands run:
- command — exit code — result

Commands not run:
- command — reason

## Commit

- committed:
- commit SHA:
- pushed:
- staged files:

## PK15 State

- PK15 dirty work preserved:
- PK15 committed:
- next safe command:

## Claims Not Made

- PK15 completion
- global train completion
- release readiness
- build success beyond recorded commands
- test success beyond recorded commands
- visual quality
- accessibility conformance
- performance validation
- physical-device validation
- TestFlight/App Store readiness

## Next Command

If Green, run:

```bash
make repair-current
```

Expected resolved command:

```bash
ALLOW_DIRTY=1 ALLOW_MAIN_COMMIT=1 AUTO_BRANCH=0 make batch BATCH=PK15-FINALIZE-01 PROMPT=prompts/batches/PK15-FINALIZE-01.md
```

Do not run `make global-train-until-complete` until PK15 finalization closes Green or accepted Yellow.
```
