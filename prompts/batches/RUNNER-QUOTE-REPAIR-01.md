<!-- AMBITIONS_RUNNER_REQUIRED: true -->
<!-- RUN_WITH: scripts/ambitions-codex-train.sh -->
<!-- DIRECT_CODEX_EXECUTION: forbidden_unless_user_explicitly_bYPASSES_runner -->

# RUNNER-QUOTE-REPAIR-01 — Repair Ambitions Runner Runtime Quoting Failure

## Batch ID

RUNNER-QUOTE-REPAIR-01

## Objective

Repair the runtime quoting failure that blocked `MOAT-ALIGNMENT-01` after GPT-5.5 conductor Phase 01 completed Green.

Observed failure:

```text
scripts/ambitions-codex-train.sh: line 940: unexpected EOF while looking for matching '"'
make: *** [batch-no-commit] Error 2
```

Important observed evidence:

```text
bash -n scripts/ambitions-codex-train.sh
EXIT:0
```

Therefore, this is likely not a static shell syntax error. It is likely a runtime command/string construction issue around Phase 02 dispatch, generated command execution, quote handling, heredoc handling, eval usage, or generated model output being inserted into shell.

This batch must repair the runner so `MOAT-ALIGNMENT-01` can resume safely.

## Runner Command

Preferred:

```bash
scripts/ambitions-codex-train.sh RUNNER-QUOTE-REPAIR-01 prompts/batches/RUNNER-QUOTE-REPAIR-01.md
```

If the runner cannot execute because this batch is repairing the runner itself, perform a bounded manual repair patch to the runner only, then validate using the commands below. Do not touch product source or canon in the repair patch.

## Active Source Truth To Inspect First

Read before editing:

```text
docs/truth/README.md
docs/truth/CODEX_PROCESS_TRUTH.md
docs/truth/RELEASE_TRUTH.md
AGENTS.md
README.md
Makefile
scripts/ambitions-codex-train.sh
scripts/ambitions-control-plane-check.py
scripts/ambitions-final-report-gate.py
.codex/runs/MOAT-ALIGNMENT-01/20260511T190612Z/final/01-plan.final.md
```

If the exact run folder does not exist, locate the latest `MOAT-ALIGNMENT-01` run under:

```text
.codex/runs/MOAT-ALIGNMENT-01/
```

## Required Diagnostics

Run and capture output:

```bash
git status --short

bash -n scripts/ambitions-codex-train.sh

nl -ba scripts/ambitions-codex-train.sh | sed -n '900,970p'

RUN_ROOT=".codex/runs/MOAT-ALIGNMENT-01/20260511T190612Z"
find "$RUN_ROOT" -maxdepth 4 -type f | sort || true

sed -n '1,260p' "$RUN_ROOT/final/01-plan.final.md" || true

grep -RIn \
  -e 'eval' \
  -e 'bash -lc' \
  -e 'line 940' \
  -e 'PHASE' \
  -e 'spark' \
  -e 'codex' \
  "$RUN_ROOT" scripts/ambitions-codex-train.sh Makefile .codex/runs/MOAT-ALIGNMENT-01 \
  | head -160 || true
```

## Required Repair

Find the exact runtime path that produces:

```text
unexpected EOF while looking for matching '"'
```

Repair it with the safest minimal change.

Preferred repair principles:

```text
- avoid eval where possible
- avoid building shell commands as unescaped strings
- prefer bash arrays for command invocation
- quote all run paths, prompt paths, output paths, and model-output paths
- keep markdown/model output as file content, not shell syntax
- preserve no-auto-branch and no-auto-commit flows
- preserve dirty-worktree support when ALLOW_DIRTY=1
- preserve approval-safe behavior
- do not weaken runner safety gates
```

If `eval` or `bash -lc "$generated_command"` is required, wrap it defensively and ensure generated text cannot introduce unmatched quotes from prompt/model content.

Add a regression guard if feasible:

```text
- a lightweight shell/Python test or script check that exercises prompt paths and generated phase files containing:
  - quotes
  - apostrophes
  - parentheses
  - brackets
  - markdown fences
  - long lines
```

The regression does not need to call external models. It should validate runner quoting/path handling where practical.

## Allowed Scope

You may modify only:

```text
scripts/ambitions-codex-train.sh
scripts/ambitions-control-plane-check.py
scripts/ambitions-final-report-gate.py
Makefile
scripts/
docs/status/
prompts/batches/RUNNER-QUOTE-REPAIR-01.md
```

Use the smallest possible patch.

## Forbidden Scope

Do not modify:

```text
Native/Ambitions/
Native/AmbitionsTests/
Native/AmbitionsUITests/
Sources/
AppUI/Sources/
docs/truth/PRODUCT_DESIGN_TRUTH.md
docs/truth/PRODUCT_MOAT_TRUTH.md
docs/AmbitionsCanon/
project.yml
Package.swift
```

Do not continue `MOAT-ALIGNMENT-01` inside this repair batch.

Do not commit automatically.

Do not delete existing dirty work.

Do not make product/canon/source changes.

Do not claim `MOAT-ALIGNMENT-01` is implemented.

## Validation Expectations

Run:

```bash
bash -n scripts/ambitions-codex-train.sh

git diff -- scripts/ambitions-codex-train.sh Makefile scripts docs/status prompts/batches

python3 scripts/ambitions-control-plane-check.py || true
python3 scripts/ambitions-final-report-gate.py || true
```

Then run a dry/safe runner validation if supported by existing runner flags.

If no dry-run flag exists, run the closest non-mutating check available and document the limitation.

Do not run `MOAT-ALIGNMENT-01` until this repair is complete and the diff is reviewed.

## Post-Repair Resume Command

After this repair is complete and reviewed, resume the moat batch with no commit and no branch creation:

```bash
ALLOW_DIRTY=1 AUTO_BRANCH=0 AUTO_COMMIT=0 make batch-no-commit BATCH=MOAT-ALIGNMENT-01 PROMPT=prompts/batches/MOAT-ALIGNMENT-01.md
```

If `batch-no-commit` ignores `AUTO_COMMIT=0`, repair the Makefile/runner so no-commit mode cannot hardcode auto-commit.

## Visual Proof Expectations

No UI changes are allowed in this repair batch.

Visual proof is not required.

## Hard Red Stop Conditions

Stop and report Red if:

```text
- repair requires broad runner rewrite beyond the quoting/runtime path
- repair touches product source or canon
- repair deletes existing dirty work
- repair weakens approval, commit, branch, validation, or final-report safety
- repair makes runner auto-commit in no-commit mode
- repair hides failed commands
- repair claims MOAT-ALIGNMENT-01 implementation completed
```

## Rollback Expectations

Before editing, record:

```bash
git status --short
git rev-parse --abbrev-ref HEAD
git rev-parse HEAD
```

Keep the patch minimal and reversible.

If repair fails, leave diagnostic notes in:

```text
docs/status/runner-quote-repair-report.md
```

Do not commit.

## Final Report Required

Report exactly:

```text
Status: Green / Yellow / Red
Batch ID:
Branch:
Commit before repair:
Files changed:
Root cause:
Exact runner path fixed:
Commands run:
Commands passed:
Commands failed:
Commands not run:
MOAT-ALIGNMENT-01 status:
Resume command:
Unproven:
Rollback notes:
```

## Success Criteria

Green only if:

```text
- root cause is identified
- minimal runner quoting/path repair is applied
- bash -n passes
- no product/canon/source files are touched
- no auto-commit happens
- no dirty work is deleted
- safe resume command is provided
```

Yellow if:

```text
- diagnostics identify the likely root cause
- partial repair is made
- runner still needs a manual follow-up
- no product/canon/source files are touched
```

Red if:

```text
- runner remains broken with no clear diagnosis
- product/canon/source files are changed
- dirty work is damaged
- no-commit safety is weakened
```
