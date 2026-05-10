<!-- markdownlint-disable MD013 -->

# Ambitions Hybrid Runner

Status: Active workflow note  
Authority: Subordinate to `docs/truth/*` and `AGENTS.md`

Future ChatGPT-generated prompts should be saved to a file first. Wrap raw
prompts with required metadata using:

```bash
scripts/ambitions-wrap-prompt.sh <BATCH_ID> <raw-prompt.md>
```

The required wrapper header is defined in `prompts/_RUNNER_REQUIRED_HEADER.md` and
must include all three fields:

`AMBITIONS_RUNNER_REQUIRED`, `RUN_WITH: scripts/ambitions-codex-train.sh`, and
`DIRECT_CODEX_EXECUTION: forbidden_unless_user_explicitly_bypasses_runner`.

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

Run the runner self-check without invoking Codex phases with:

```bash
make batch-self-check
```

The runner is `scripts/ambitions-codex-train.sh`. It performs model phasing:
GPT-5.5 plans, GPT-5.3-Codex-Spark applies only the bounded patch, and GPT-5.5
reviews, repairs, validates, and decides final commit eligibility.

Local CLI compatibility note: the current Codex CLI supports full-access runner
execution with `--sandbox danger-full-access`. It does not require an
`--ask-for-approval` flag for this local runner path.

Direct pasted Codex implementation is forbidden unless the user explicitly says
"bypass the Ambitions runner."

Auto-commit means the runner may commit only after the final GPT-5.5 gate says
the result is eligible. Auto-push is default-off. Push requires explicit owner
intent:

```bash
AUTO_PUSH=1 make batch BATCH=<BATCH_ID> PROMPT=prompts/batches/<BATCH_ID>.md
```

The runner stages only explicit eligible changed paths, excludes
`.codex/runs/**`, saves staged and unstaged path lists, and does not use broad
staging shortcuts.

When `.codex/state/active-batch.yml` clearly forbids branch creation, the runner
stops before creating a branch unless the owner explicitly sets
`ALLOW_RUNNER_BRANCH_EXCEPTION=1` or disables runner branch creation with
`AUTO_BRANCH=0`.

Active user-facing IA is `Today / Goals / Capture / Time / You`. `Plan` remains
an internal compatibility seam only where current source/truth allows it.

The runner does not imply release, build, test, accessibility, performance,
visual, device, TestFlight, or App Store proof.

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
