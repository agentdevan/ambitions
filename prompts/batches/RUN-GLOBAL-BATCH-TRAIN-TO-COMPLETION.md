<!-- AMBITIONS_RUNNER_REQUIRED: true -->
<!-- RUN_WITH: scripts/ambitions-codex-train.sh -->
<!-- DIRECT_CODEX_EXECUTION: forbidden_unless_user_explicitly_bypasses_runner -->

# Batch ID

`RUN-GLOBAL-BATCH-TRAIN-TO-COMPLETION`

# Status

Supervisor-compatible only. This prompt is no longer an unbounded nested conductor loop.

# Objective

Prepare, inspect, or repair global train state while preserving the loop-proof operating model. The global train should be run by the external supervisor script, not by a long-lived nested Codex conductor phase.

For full autonomous continuation, use:

```bash
make global-train-until-complete
```

or:

```bash
scripts/ambitions-global-train-supervisor.sh --until-complete
```

# Required Autonomous Execution Model

The safe model is:

```text
top-level supervisor -> one selected batch -> canonical runner lifecycle -> inspect result -> ledger update -> continue or stop
```

The runner owns its internal GPT-5.5 plan, Spark bounded patch, and GPT-5.5 review/finalization lifecycle. A parent global-train pass may launch at most one child batch. If this prompt is invoked through the runner, it may inspect state, create/repair prompts, or launch one child batch only, then exit with the next command.

# Required Read Order

1. `docs/truth/README.md`
2. `docs/truth/PRODUCT_DESIGN_TRUTH.md`
3. `docs/truth/IMPLEMENTATION_TRUTH.md`
4. `docs/truth/RELEASE_TRUTH.md`
5. `docs/truth/CODEX_PROCESS_TRUTH.md`
6. `docs/truth/HISTORICAL_POLICY.md`
7. `.codex/state/active-batch.yml`
8. `.codex/reports/current-batch-train-state.md`
9. `.codex/state/global-train-attempt-ledger.md`
10. `docs/codex/BATCH_REGISTRY.md`
11. `docs/codex/GLOBAL_QUEUE_MATURITY_LEDGER.md`
12. `docs/codex/GLOBAL_QUEUE_CANONICAL_ORDER.json`
13. `docs/codex/GLOBAL_FULL_STACK_COMPLETION_ORDER.md`
14. `docs/codex/GLOBAL_FULL_STACK_COMPLETION_ORDER_EFC_PEAK_OVERLAY.md`
15. `docs/codex/BATCH_REGISTRY_EFC_OVERLAY.md`
16. `docs/codex/EFC_FLAGSHIP_PROOF_OPERATING_LAYER.md`
17. `docs/codex/POST_BATCH_GATE_REGISTRY.md`

# Loop Controls

- One child batch maximum per parent pass.
- No child batch may invoke this global conductor prompt.
- No prompt may invoke nested `make batch` unless a separate owner-approved exception explicitly says so.
- An incomplete artifact, missing final summary, or `UNKNOWN` child status must be inspected and recorded. It must not trigger a same-batch relaunch.
- `UNKNOWN` is `unknown-unresolved` unless artifact inspection proves Green or accepted Yellow.
- A failed same-root attempt requires `<BATCH_ID>-REPAIR-01.md` or `<BATCH_ID>-FINALIZE-01.md`, not a normal rerun.
- A batch with existing uncommitted bounded work must go through finalization, not Phase 02 restart.
- No concurrent Xcode commands. Check process state before validation:

```bash
pgrep -fl 'ambitions-codex-train|codex exec|xcodebuild' || true
```

# Result Handling

After one child batch returns:

- Green: update state and exit with the next recommended command.
- Accepted Yellow: record owner, reason, no-claim boundary, retirement condition, resume path, proof path, why continuation is safe, then exit with the next recommended command.
- Unaccepted Yellow: generate `<BATCH_ID>-FINALIZE-01.md` or `<BATCH_ID>-REPAIR-01.md`, update the ledger, and exit.
- Red: generate `<BATCH_ID>-REPAIR-01.md`, update the ledger, and exit.
- Unknown: classify as `unknown-unresolved`, update the ledger, and exit.

# Forbidden Behavior

- Do not run unlimited child batches inside one Codex phase.
- Do not rerun the same child batch in the same parent pass.
- Do not rerun Spark when an existing patch only needs final GPT-5.5 review/finalization.
- Do not launch the global conductor from a child batch.
- Do not run the full global train from inside this prompt. Use the supervisor script.
- Do not touch app source from this governance prompt.
- Do not make release, visual, accessibility, performance, physical-device, TestFlight, App Store, legal/privacy, or global-completion claims without proof.

# Runner Command

This prompt is allowed only for bounded inspection/repair:

```bash
make batch BATCH=RUN-GLOBAL-BATCH-TRAIN-TO-COMPLETION PROMPT=prompts/batches/RUN-GLOBAL-BATCH-TRAIN-TO-COMPLETION.md
```

For actual full-train continuation, use:

```bash
make global-train-until-complete
```

STATUS: UNKNOWN
