<!-- AMBITIONS_RUNNER_REQUIRED: true -->
<!-- RUN_WITH: scripts/ambitions-codex-train.sh -->
<!-- DIRECT_CODEX_EXECUTION: forbidden_unless_user_explicitly_bypasses_runner -->

# Batch ID

`RUN-GLOBAL-BATCH-TRAIN-TO-COMPLETION`

# Status

BLOCKED UNTIL AUTO-HARDEN-01 AND GLOBAL-SEQUENCE-AUTONOMY-01 ARE GREEN.

# Objective

Run the remaining Ambitions global batch train autonomously through the
canonical hybrid runner, using bounded repair cycles, until the normal
autonomous remaining queue is complete or a true Hard Red occurs.

Do not directly paste implementation batches into Codex. Do not bypass the
runner unless the user explicitly says:

```text
bypass the Ambitions runner.
```

# Required Autonomous Execution Model

Use the canonical runner for every batch:

```bash
make batch BATCH=<BATCH_ID> PROMPT=<PROMPT_FILE>
```

or:

```bash
scripts/ambitions-codex-train.sh <BATCH_ID> <PROMPT_FILE>
```

The runner performs:

```text
GPT-5.5 plan -> GPT-5.3-Codex-Spark bounded patch -> GPT-5.5 review/repair/final commit
```

Spark must never own architecture, canon, continuation, repo cleanup, or final
commit eligibility. GPT-5.5 owns planning, sequence selection, source truth,
review, repair, and final continuation decisions.

Every batch must inherit EFC applicability where relevant. Every batch must
close with Green, accepted Yellow, or Red. Continue through Green. Continue
through accepted Yellow only when owner, reason, retirement condition,
no-claim boundary, and resume path are recorded. Stop on Hard Red.

# Required Read Order For Each Loop

1. Refresh repo status.
2. Read `docs/truth/README.md`.
3. Read `docs/truth/PRODUCT_DESIGN_TRUTH.md`.
4. Read `docs/truth/IMPLEMENTATION_TRUTH.md`.
5. Read `docs/truth/RELEASE_TRUTH.md`.
6. Read `docs/truth/CODEX_PROCESS_TRUTH.md`.
7. Read `docs/truth/HISTORICAL_POLICY.md`.
8. Read `.codex/state/active-batch.yml`.
9. Read `.codex/reports/current-batch-train-state.md`.
10. Read `docs/codex/BATCH_REGISTRY.md`.
11. Read `docs/codex/GLOBAL_QUEUE_MATURITY_LEDGER.md`.
12. Read `docs/codex/GLOBAL_QUEUE_CANONICAL_ORDER.json`.
13. Read `docs/codex/GLOBAL_FULL_STACK_COMPLETION_ORDER.md`.
14. Read `docs/codex/GLOBAL_FULL_STACK_COMPLETION_ORDER_EFC_PEAK_OVERLAY.md`.
15. Read `docs/codex/BATCH_REGISTRY_EFC_OVERLAY.md`.
16. Read `docs/codex/EFC_FLAGSHIP_PROOF_OPERATING_LAYER.md`.
17. Read `docs/codex/POST_BATCH_GATE_REGISTRY.md`.

# Required Batch Loop

1. Determine the next eligible batch from live state.
2. Prefer live unfinished current-run state over fallback queue data.
3. Ensure the prompt file exists for that batch.
4. If the prompt is missing, generate a runner-compatible prompt from the batch
   registry, canonical order, active truth files, and allowed scope.
5. Add the required runner header to any generated prompt.
6. Run that batch through the runner.
7. Inspect runner result, changed files, validation proof, and final status.
8. If Green, update state and continue.
9. If Yellow, determine whether it is accepted Yellow or blocking Yellow.
10. If accepted Yellow, record owner, reason, retirement condition,
    no-claim boundary, and resume path; then continue.
11. If blocking Yellow, attempt bounded repair only if safe and inside scope.
12. If Red, attempt an allowed repair cycle only when the Red is within scope
    and repairable.
13. If repair succeeds, rerun validation and continue.
14. If repair fails, repeats the same root failure, or expands scope, stop with
    Hard Red.
15. Repeat until no normal autonomous batches remain.

# Current Sequence Rules

- Active truth files are obeyed.
- Live unfinished current-run state wins over fallback queue.
- Completed and historical batches are not runnable.
- EFC proof owners are overlays unless no existing owner can produce required
  proof.
- Conditional CS batches are trigger-only and not in the normal autonomous path
  unless a named trigger exists.
- Dependency-blocked batches are not run early.
- PK storage, data-safety, side-effect, privacy, intelligence, performance, and
  package foundations run before dependent source/freshness/intelligence/release
  claims.
- Source Atlas batches must become reachable before source-dependent LDI, AOS,
  FCP, or PFC claims that depend on freshness/source operations.
- IR-01 Big Frontend Recovery Implementation, or an equivalent live UI recovery
  pass, must close Green or accepted Yellow with owner before further visible
  top-level UI expansion.
- RHC hygiene tail does not block implementation unless a hygiene Hard Red
  exists.
- Active user-facing IA is `Today / Goals / Capture / Time / You`.
- `Plan` remains only an internal compatibility seam or contextual/action noun
  where current truth allows it.
- No queue doc may revive obsolete top-level IA, stale release claims, hosted CI
  assumptions, or external/cloud LLM core architecture.

# Required Repair Loop

Use at most one repair pass per batch unless the runner or active prompt
explicitly allows more.

Repair discipline:

- diagnose root cause
- repair only within the allowed batch boundary
- do not weaken tests or gates
- do not broaden architecture to make a batch Green
- do not delete tests to pass
- do not lower accessibility, privacy, release, source-truth, or safety gates
- if the same failure repeats, stop Hard Red
- if source truth conflict appears, stop Hard Red
- if app source mutation happens outside scope, stop Hard Red

# Required Completion Criteria

Global completion requires:

- no `executable_now` remaining
- no `executable_later` remaining
- all dependency-blocked batches either completed after prerequisites or still
  correctly classified with explicit blockers
- overlays absorbed or invoked by owner batches
- conditional triggers either not triggered or closed by named target
- prompt audit Green or accepted Yellow with classification
- runner self-check Green
- queue, state, and registry agree
- release truth preserved
- no unsupported release/readiness claims

# Required Non-Claims

This prompt and any global-train closeout must preserve these non-claims unless
current raw evidence proves otherwise:

- not release-ready
- not App Store-ready
- not TestFlight-ready
- not device-validated unless real proof exists
- not accessibility-conformant unless real proof exists
- not performance-validated unless real proof exists
- not privacy/legal-approved unless owner proof exists
- not visually accepted unless rendered screenshots and owner review exist

# Stop Conditions

Stop with Hard Red if:

- `AUTO-HARDEN-01` is not Green before this prompt runs
- `GLOBAL-SEQUENCE-AUTONOMY-01` is not Green before this prompt runs
- active truth files cannot be read
- canonical queue files cannot be parsed
- remaining batch counts cannot be reconciled
- the next eligible batch is ambiguous after live-state reconciliation
- a required prompt cannot be generated safely
- the runner is missing or unsafe
- app source would need to be touched outside a selected implementation batch
- `docs/truth/*` would need to be touched
- validation fails in a way that makes the queue unsafe
- the run would claim release, accessibility, performance, device, TestFlight,
  App Store, visual, legal/privacy, hosted CI, sync/cloud, or global completion
  proof without current evidence

# Runner Command

Do not run this prompt until the status line above is unblocked by Green
closeouts for `AUTO-HARDEN-01` and `GLOBAL-SEQUENCE-AUTONOMY-01`.

```bash
make batch BATCH=RUN-GLOBAL-BATCH-TRAIN-TO-COMPLETION PROMPT=prompts/batches/RUN-GLOBAL-BATCH-TRAIN-TO-COMPLETION.md
```

