<!-- AMBITIONS_RUNNER_REQUIRED: true -->
<!-- RUN_WITH: scripts/ambitions-codex-train.sh -->
<!-- DIRECT_CODEX_EXECUTION: forbidden_unless_user_explicitly_bypasses_runner -->

# Batch ID

`PK14-CONDUCTOR-REPAIR-01`

# Runner Command

```bash
make batch BATCH=PK14-CONDUCTOR-REPAIR-01 PROMPT=prompts/batches/PK14-CONDUCTOR-REPAIR-01.md
```

# Objective

Repair the autonomous global-train conductor and PK14 handoff behavior so the train cannot enter recursive child-runner retry loops.

Then produce a clean, bounded, runner-compatible `PK14` prompt for exactly one future PK14 attempt.

This is **not PK14 implementation**.

Do not run PK14 in this batch.
Do not run the full global train in this batch.
Do not implement PK14 source changes in this batch.
Do not touch app source.
Do not claim PK14 is complete.

The goal is to make the conductor safe, then prepare one clean PK14 retry.

---

# Current Failure Evidence

The previous autonomous run stopped Red with this state:

* `AUTO-HARDEN-01` completed Green and committed.
* `GLOBAL-SEQUENCE-AUTONOMY-01` completed Green and committed.
* `RUN-GLOBAL-BATCH-TRAIN-TO-COMPLETION` stopped Red at `PK14`.
* `PK14` produced a Yellow child run, then a Red child run.
* The conductor began repeating same-root retry/cleanup behavior.
* Remaining PK14 runner processes were manually stopped.
* Tracked worktree was restored clean on `main`.
* No PK14 source/state/registry commit exists.
* Untracked local artifacts may remain under `.codex/runs/` and `prompts/batches/PK14.md`.
* Next eligible batch remains `PK14 Durable Command/Event Ledger`.
* Normal autonomous batches remaining remain `80`.
* Real future work remaining remains `92`.

Treat this as a conductor/runner loop-control failure until proven otherwise.

---

# Active Source Truth To Inspect

Read these first:

1. `docs/truth/README.md`
2. `docs/truth/PRODUCT_DESIGN_TRUTH.md`
3. `docs/truth/IMPLEMENTATION_TRUTH.md`
4. `docs/truth/RELEASE_TRUTH.md`
5. `docs/truth/CODEX_PROCESS_TRUTH.md`
6. `docs/truth/HISTORICAL_POLICY.md`
7. `AGENTS.md`
8. `.codex/state/active-batch.yml`
9. `.codex/reports/current-batch-train-state.md`
10. `docs/audits/global-sequence-autonomy-audit.md`
11. `prompts/batches/RUN-GLOBAL-BATCH-TRAIN-TO-COMPLETION.md`
12. `prompts/batches/PK14.md`, if present
13. `.codex/runs/RUN-GLOBAL-BATCH-TRAIN-TO-COMPLETION/20260510T072129Z/`, if present
14. `.codex/runs/PK14/20260510T073722Z/final-summary.md`, if present
15. `.codex/runs/PK14/20260510T074120Z/final-summary.md`, if present
16. `scripts/ambitions-codex-train.sh`
17. `scripts/ambitions-wrap-prompt.sh`
18. `scripts/ambitions-prompt-audit.sh`
19. `Makefile`
20. `docs/codex/ambitions-hybrid-runner.md`

If run artifacts are untracked but present locally, inspect them. Do not commit `.codex/runs/` unless repo policy explicitly allows committing summarized proof artifacts. Prefer creating a committed audit report instead.

---

# Required Diagnosis

Create:

```text
docs/audits/pk14-conductor-repair-report.md
```

It must answer:

1. Did the parent conductor invoke nested child runner processes?
2. Did `RUN-GLOBAL-BATCH-TRAIN-TO-COMPLETION` allow more than one PK14 attempt without a fresh human/Green gate?
3. Did the parent confuse Yellow, Red, accepted Yellow, and retryable Red?
4. Did the PK14 prompt itself cause recursive calls back into the global train?
5. Did `PK14.md` exist before the run, or was it generated during the failed parent run?
6. Was PK14 Yellow due to implementation risk, validation unavailable, missing acceptance criteria, or runner/conductor loop behavior?
7. What exact loop guard must be added before another global run?

---

# Required Repairs

Patch only the smallest files needed to enforce the following rules.

## Rule 1 — No recursive runner nesting by default

The global conductor prompt must not recursively launch unlimited child runners from inside a parent runner without a guard.

Required behavior:

* A parent global-train run may launch a child batch only when a conductor lock/attempt marker proves no same-batch child run is active.
* A child batch may not launch the global train.
* A batch prompt may not tell Codex to run itself or recursively rerun the parent.
* The conductor must stop after one failed child attempt unless a bounded repair prompt is generated.

Add a clear rule to `prompts/batches/RUN-GLOBAL-BATCH-TRAIN-TO-COMPLETION.md`.

## Rule 2 — One child attempt per batch per parent pass

For each selected batch:

* one clean runner attempt allowed
* if Green: continue
* if accepted Yellow: continue only with owner/reason/retirement/resume path
* if Yellow not accepted: stop parent Yellow/Red and emit repair prompt
* if Red: stop parent Red and emit repair prompt
* no automatic second same-batch runner attempt from the parent conductor

Repair attempts must be separate named batches, such as:

```text
PK14-REPAIR-01
```

or explicitly through the runner’s own bounded repair phase, not a new uncontrolled parent loop.

## Rule 3 — PK14 retry must be one clean attempt

Create or repair:

```text
prompts/batches/PK14.md
```

It must be runner-compatible and must include:

```md
<!-- AMBITIONS_RUNNER_REQUIRED: true -->
<!-- RUN_WITH: scripts/ambitions-codex-train.sh -->
<!-- DIRECT_CODEX_EXECUTION: forbidden_unless_user_explicitly_bypasses_runner -->
```

It must clearly say:

* This is a single clean PK14 attempt.
* Do not invoke the global train.
* Do not invoke `make batch` recursively.
* Do not rerun PK14 from inside PK14.
* If PK14 fails validation, use runner repair phase only.
* If still Yellow/Red after runner repair, stop and report.
* No second external PK14 attempt.
* No cleanup loop.
* No broad retries.

## Rule 4 — Add a conductor lock/attempt ledger if needed

If the cleanest fix requires a small local conductor ledger, create one of:

```text
.codex/state/global-train-attempt-ledger.md
```

or:

```text
docs/codex/GLOBAL_TRAIN_ATTEMPT_LEDGER.md
```

Prefer `.codex/state/global-train-attempt-ledger.md` if it is treated as compact state, or docs if committed state is expected.

It should track:

* parent batch ID
* child batch ID
* attempt count
* status
* proof path
* next action
* whether retry is allowed

Do not overbuild.

## Rule 5 — Parent prompt must generate repair prompt, not rerun

If child batch fails, the global conductor must create:

```text
prompts/batches/<FAILED_BATCH_ID>-REPAIR-01.md
```

or a similarly named bounded repair prompt.

It must not rerun the failed batch automatically in the same parent loop.

---

# Allowed Scope

You may modify only:

```text
docs/audits/pk14-conductor-repair-report.md
prompts/batches/RUN-GLOBAL-BATCH-TRAIN-TO-COMPLETION.md
prompts/batches/PK14.md
prompts/batches/PK14-REPAIR-01.md
docs/codex/ambitions-hybrid-runner.md
docs/codex/POST_BATCH_GATE_REGISTRY.md
docs/codex/GLOBAL_FULL_STACK_COMPLETION_ORDER.md
docs/codex/GLOBAL_QUEUE_MATURITY_LEDGER.md
docs/codex/GLOBAL_QUEUE_CANONICAL_ORDER.json
docs/codex/BATCH_REGISTRY.md
.codex/state/active-batch.yml
.codex/reports/current-batch-train-state.md
.codex/state/global-train-attempt-ledger.md
Makefile
scripts/ambitions-codex-train.sh
scripts/ambitions-prompt-audit.sh
```

Only touch scripts if prompt-level/governance-level repair is insufficient.

Prefer repairing prompts/governance before changing runner code.

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
Native/AmbitionsTests/
Native/AmbitionsUITests/
```

Do not:

* implement PK14 source changes
* run PK14
* run the full global train
* run nested `make batch` commands from this batch
* add hosted CI
* add dependencies
* add signing/TestFlight/App Store automation
* add external/cloud LLM behavior
* delete historical material
* claim PK14 complete
* mark PK14 Green
* modify release truth
* claim release/build/accessibility/performance/visual proof

---

# Validation Expectations

Run and record:

```bash
git diff --check
python3 -m json.tool docs/codex/GLOBAL_QUEUE_CANONICAL_ORDER.json >/tmp/ambitions-global-queue-json-check.txt
bash -n scripts/ambitions-codex-train.sh
bash -n scripts/ambitions-prompt-audit.sh
test -x scripts/ambitions-codex-train.sh
test -x scripts/ambitions-prompt-audit.sh
make -n batch BATCH=PK14 PROMPT=prompts/batches/PK14.md
make -n batch BATCH=RUN-GLOBAL-BATCH-TRAIN-TO-COMPLETION PROMPT=prompts/batches/RUN-GLOBAL-BATCH-TRAIN-TO-COMPLETION.md
scripts/ambitions-prompt-audit.sh
```

If runner self-check exists, run:

```bash
scripts/ambitions-codex-train.sh --self-check
```

Do not run:

```bash
make batch BATCH=PK14 PROMPT=prompts/batches/PK14.md
```

Do not run:

```bash
make batch BATCH=RUN-GLOBAL-BATCH-TRAIN-TO-COMPLETION PROMPT=prompts/batches/RUN-GLOBAL-BATCH-TRAIN-TO-COMPLETION.md
```

---

# Hard Red Stop Conditions

Stop immediately with `STATUS: RED` if:

* you need to touch app source
* you need to touch `docs/truth/*`
* PK14 implementation would be required in this batch
* the global train would need to be run to validate this repair
* recursive runner behavior cannot be prevented
* the PK14 prompt cannot be made single-attempt safe
* validation cannot establish that the prompt no longer authorizes uncontrolled retry loops
* queue state would need to falsely mark PK14 complete
* any unsupported release/build/test/accessibility/performance/visual claim would be introduced

---

# Rollback Expectations

Before mutation, record current branch and commit.

If this batch fails Red:

* leave changes uncommitted unless runner auto-rollback is explicitly enabled
* list touched files
* provide path-limited restore instructions

If committed, rollback is:

```bash
git revert <commit-sha>
```

---

# Final Report Format

End with:

````markdown
## Status

STATUS: GREEN | STATUS: YELLOW | STATUS: RED

## Scope

What was requested and what was actually changed.

## Failure Diagnosis

- parent nested child runner:
- repeated PK14 attempts:
- Yellow/Red handling defect:
- PK14 prompt recursion risk:
- root cause:
- repair chosen:

## Files Changed

- path — reason

## Loop Guards Added

- guard
- file
- effect

## PK14 Retry Readiness

- `prompts/batches/PK14.md` exists:
- single-attempt safe:
- does not invoke global train:
- does not invoke recursive make batch:
- ready for one clean run:

## Validation

Commands run:
- command — exit code — result

Commands not run:
- command — reason

## Claims Not Made

- PK14 completion
- global train completion
- release readiness
- build success beyond recorded commands
- test success beyond recorded commands
- visual quality
- accessibility conformance
- performance validation
- device validation
- TestFlight/App Store readiness

## Next Recommended Step

If Green, run exactly one clean PK14 attempt:

```bash
make batch BATCH=PK14 PROMPT=prompts/batches/PK14.md
````

Do not rerun the full global train until PK14 closes Green or an accepted Yellow is recorded with owner, reason, retirement condition, and resume path.
