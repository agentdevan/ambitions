<!-- markdownlint-disable MD013 -->

# Ambitions Hybrid Runner

Status: Active workflow note  
Authority: Subordinate to `docs/truth/*` and `AGENTS.md`

Future ChatGPT-generated prompts should be saved to a file first. Wrap raw
prompts with:

```bash
scripts/ambitions-wrap-prompt.sh <BATCH_ID> <raw-prompt.md>
```

Create a future prompt by copying `prompts/_BATCH_TEMPLATE.md` and filling in
the batch ID, objective, allowed scope, forbidden scope, validation, visual
proof expectations, Hard Red stops, and rollback notes.

Run future batches with:

```bash
make batch BATCH=<BATCH_ID> PROMPT=prompts/batches/<BATCH_ID>.md
```

Audit active prompt files with:

```bash
make prompt-audit
```

The runner is `scripts/ambitions-codex-train.sh`. It performs model phasing:
GPT-5.5 plans, GPT-5.3-Codex-Spark applies only the bounded patch, and GPT-5.5
reviews, repairs, validates, and decides final commit eligibility.

Direct pasted Codex implementation is forbidden unless the user explicitly says
"bypass the Ambitions runner."

Auto-commit means the runner may commit only after the final GPT-5.5 gate says
the result is eligible. By default, a created commit is pushed to the current
batch branch with a normal `git push -u origin <branch>`. It never force-pushes.
Disable this with `AUTO_PUSH=0`.

Hard Red means stop immediately, leave changes uncommitted for inspection by
default, and use the rollback command saved under `.codex/runs/<BATCH>/<time>/`
if the run must be discarded.

Disable auto-commit with:

```bash
make batch-no-commit BATCH=SI07 PROMPT=prompts/SI07.md
```

Use workspace sandboxing instead of full access with:

```bash
make batch-workspace BATCH=SI07 PROMPT=prompts/SI07.md
```
