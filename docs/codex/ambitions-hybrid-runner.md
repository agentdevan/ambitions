<!-- AMB-291-CANON-HYGIENE-REPAIR: BEGIN -->

> AMB-291 repair status: **canon-hygiene-reconciled**
> This file was reviewed as part of the actual canon content/hygiene rewrite pass.
> It is not standalone active product truth. Use `docs/truth/*` and current manifest/sequence authority before implementation.
> Conflict types reconciled: retired_ia_or_terminology_reference, same_source_file_targeted_by_multiple_active_batches, same_surface_multiple_active_batches
> Prior recommended actions: Expedite, Merge, Rewrite
> Candidate references: AMB28-retired_ia_or_terminology_reference-97855985, AMB28-same_source_file_targeted_by_multiple_active_batches-19279448, AMB28-same_source_file_targeted_by_multiple_active_batches-71092207, AMB28-same_source_file_targeted_by_multiple_active_batches-7699744, AMB28-same_surface_multiple_active_batches-13212827, AMB28-same_surface_multiple_active_batches-26899932, AMB28-same_surface_multiple_active_batches-34058953, AMB28-same_surface_multiple_active_batches-66075429, AMB28-same_surface_multiple_active_batches-96568748

<!-- AMB-291-CANON-HYGIENE-REPAIR: END -->
<!-- AMB-291-CANON-HYGIENE-HEADER: BEGIN -->

> Canon hygiene status: **codex-reference**
> AMB-291 note: This Codex reference supports process or execution, but active truth remains in docs/truth and current manifests.
> Active authority: `docs/truth/*`, `docs/codex/GLOBAL_BATCH_SEQUENCE_AUTHORITY.json`, and `docs/codex/IOS26_FLAGSHIP_TRAIN_MANIFEST.yml`.
> Before using this file for implementation, run `make change-impact-check` and follow `docs/ops/change-protocol/implementation-prompt-template.md`.
> Resolution classes: merge-overlap, terminology-quarantine
> Dispositions: merge-or-sequence-file-ownership, merge-or-sequence-surface-ownership, quarantine-or-rewrite-terminology

<!-- AMB-291-CANON-HYGIENE-HEADER: END -->
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

For global train continuation with one bounded child-at-a-time loop, use:

```bash
make autonomous-train
```

That command uses `scripts/ambitions-autonomous-train.sh` (status / next / one-child-run / until-complete mode) so the conductor path remains top-level and non-recursive.

For maximum-throughput continuation, use Speed Train mode:

```bash
make speed-train
```

Speed Train uses `scripts/ambitions-speed-train.sh` as an aggressive top-level operator loop over `scripts/ambitions-autonomous-train.sh`. It keeps the canonical runner, but defaults to no runner-created branches, main commits, auto-push, accepted-Yellow continuation, one repair pass, stale-state checks, queue-guard checks, unsupported-claim scans, and final heavy validation as a separate gate.

Useful Speed Train commands:

```bash
make speed-status
make speed-next
make speed-once
MAX_BATCHES=10 make speed-train
make speed-final-gate
SPEED_RUN_HEAVY_FINAL_GATE=1 make speed-final-gate
```

Speed Train authority and usage are documented in:

- `docs/codex/SPEED_TRAIN_OPERATING_MODEL.md`
- `docs/codex/SPEED_TRAIN_QUICKSTART.md`
- `docs/codex/SPEED_TRAIN_LANE_POLICY.json`

Audit active prompt files with:

```bash
make prompt-audit
```

Run the runner self-check without invoking Codex phases with:

```bash
make batch-self-check
```

Run a deterministic read-only audit without creating a branch, run directory,
commit, or push:

```bash
make batch-read-only-audit BATCH=<BATCH_ID> PROMPT=prompts/batches/<BATCH_ID>.md
```

The runner is `scripts/ambitions-codex-train.sh`. It performs model phasing:
GPT-5.5 plans, GPT-5.4-mini applies only the bounded patch, and GPT-5.5
reviews, repairs, validates, and decides final commit eligibility.

Local CLI compatibility note: the current Codex CLI supports full-access runner
execution with `--sandbox danger-full-access`. It does not require an
`--ask-for-approval` flag for this local runner path.

Direct pasted Codex implementation is forbidden unless the user explicitly says
"bypass the Ambitions runner."

Auto-commit means the runner may commit only after the final GPT-5.5 gate says
the result is eligible. Auto-push is default-off for normal batches. Speed Train intentionally sets auto-push on by default for throughput.

```bash
AUTO_PUSH=1 make batch BATCH=<BATCH_ID> PROMPT=prompts/batches/<BATCH_ID>.md
```

The runner stages only explicit eligible changed paths, excludes
`.codex/runs/**`, saves staged and unstaged path lists, and does not use broad
staging shortcuts.

If the final GPT-5.5 gate has already created an eligible commit and the
worktree is clean outside `.codex/runs/**`, the runner records that `HEAD` commit
as the batch commit instead of re-staging paths already committed by the gate.

When `.codex/state/active-batch.yml` clearly forbids branch creation, the runner
stops before creating a branch unless the owner explicitly sets
`ALLOW_RUNNER_BRANCH_EXCEPTION=1` or disables runner branch creation with
`AUTO_BRANCH=0`. Speed Train intentionally uses `AUTO_BRANCH=0`.

Conductor safety rule:

- Codex phase subprocesses export an active runner context, and nested
  `make batch` / `scripts/ambitions-codex-train.sh` invocations are blocked by
  default. Use a top-level operator loop to launch the next child batch after
  the parent run closes, unless a bounded owner-approved exception explicitly
  sets `ALLOW_NESTED_BATCH=1`.
- Do not emit parent prompts that instruct a batch to invoke itself or to invoke
  the global conductor recursively.
- A parent should record one child attempt in ledger state for the current
  parent pass/run and stop on non-green child outcomes, routing to
  `<FAILED_BATCH_ID>-REPAIR-01` instead of re-run.
- Historical closed attempts remain audit evidence; they do not become Green and
  do not permanently block a separately approved clean child attempt.
- PK-level prompts must be single-attempt by default and must explicitly forbid
  recursive `make batch` patterns.

Active user-facing IA is `Today / Goals / Capture / Time / You`. `Plan` remains
an internal compatibility seam only where current source/truth allows it.

The runner does not imply release, build, test, accessibility, performance,
visual, device, TestFlight, or App Store proof. Speed Train also does not imply those proofs; it only increases batch throughput.

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

## Source-of-truth references

<!-- AMB-291-SOURCE-OF-TRUTH-REFERENCES: BEGIN -->

This file must not be treated as standalone active canon. Current authority must be resolved through:

- `docs/truth/README.md`
- `docs/truth/PRODUCT_DESIGN_TRUTH.md`
- `docs/truth/PRODUCT_MOAT_TRUTH.md`
- `docs/truth/IMPLEMENTATION_TRUTH.md`
- `docs/truth/RELEASE_TRUTH.md`
- `docs/truth/CODEX_PROCESS_TRUTH.md`
- `docs/truth/HISTORICAL_POLICY.md`
- `docs/codex/GLOBAL_BATCH_SEQUENCE_AUTHORITY.json`
- `docs/codex/IOS26_FLAGSHIP_TRAIN_MANIFEST.yml`
- `docs/ops/change-protocol/change-request-template.md`
- `docs/ops/change-protocol/change-impact-check.md`
- `docs/ops/change-protocol/implementation-prompt-template.md`
- `docs/ops/change-protocol/post-implementation-proof-reconciliation.md`

<!-- AMB-291-SOURCE-OF-TRUTH-REFERENCES: END -->

## Non-claims

<!-- AMB-291-NON-CLAIMS: BEGIN -->

- This file does not prove implementation.
- This file does not prove build success.
- This file does not prove test success.
- This file does not prove accessibility validation.
- This file does not prove performance validation.
- This file does not prove device validation.
- This file does not prove privacy/legal approval.
- This file does not prove TestFlight readiness.
- This file does not prove App Store readiness.
- This file does not prove release readiness.
- Linear status is not repo truth.

<!-- AMB-291-NON-CLAIMS: END -->
