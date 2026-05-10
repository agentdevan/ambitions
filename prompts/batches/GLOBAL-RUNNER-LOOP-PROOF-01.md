<!-- AMBITIONS_RUNNER_REQUIRED: true -->
<!-- RUN_WITH: scripts/ambitions-codex-train.sh -->
<!-- DIRECT_CODEX_EXECUTION: forbidden_unless_user_explicitly_bypasses_runner -->

# Batch ID

`GLOBAL-RUNNER-LOOP-PROOF-01`

# Runner Command

```bash
make batch BATCH=GLOBAL-RUNNER-LOOP-PROOF-01 PROMPT=prompts/batches/GLOBAL-RUNNER-LOOP-PROOF-01.md
```

# Objective

Fix the Ambitions global batch-train operating model so the remaining global batch train can run start-to-finish autonomously through the canonical runner without recursive loops, repeated same-root retries, phase restarts that duplicate work, nested child runner churn, concurrent Xcode build locks, or uncontrolled cleanup/retry behavior.

This is a Codex OS / runner / conductor / batch-governance hardening batch.

Do not implement app features. Do not run PK15 or any other product batch inside this batch. Do not run the full global train inside this batch. Do not touch app source. Do not claim release readiness, app completion, visual quality, accessibility conformance, physical-device validation, performance validation, TestFlight readiness, or App Store readiness.

# Required Design Decision

```text
Top-level train supervisor selects one batch at a time.
Each selected batch runs through the canonical runner exactly once.
The runner owns its internal 5.5 -> Spark -> 5.5 lifecycle.
If a batch stops Yellow/Red before final commit, the supervisor creates a finalization/repair prompt and stops.
The next invocation resumes from the ledger, not from guesswork.
```

Do not design a conductor that recursively runs unlimited child batches inside a single Codex phase. Do not design a conductor that reacts to `UNKNOWN` artifacts by launching another copy of the same child batch. Do not design a conductor that restarts a batch from Phase 02 when a patch already exists and needs final review.

# Required Repairs

- Add `.codex/state/global-train-attempt-ledger.md`.
- Add `prompts/_BATCH_FINALIZE_TEMPLATE.md`.
- Repair `prompts/batches/RUN-GLOBAL-BATCH-TRAIN-TO-COMPLETION.md`.
- Add `scripts/ambitions-global-train-supervisor.sh`.
- Add Makefile targets: `global-train-status`, `global-train-next`, `global-train-once`, `global-train-until-complete`.
- Add `docs/codex/global-train-supervisor.md`.
- Add `prompts/batches/PK15-FINALIZE-01.md` if current repo state shows unresolved PK15 work.
- Add `docs/audits/global-runner-loop-proof-report.md`.

# Allowed Scope

```text
.codex/state/global-train-attempt-ledger.md
docs/audits/global-runner-loop-proof-report.md
docs/codex/global-train-supervisor.md
docs/codex/ambitions-hybrid-runner.md
docs/codex/POST_BATCH_GATE_REGISTRY.md
docs/codex/BATCH_REGISTRY.md
docs/codex/GLOBAL_QUEUE_MATURITY_LEDGER.md
docs/codex/GLOBAL_QUEUE_CANONICAL_ORDER.json
.codex/state/active-batch.yml
.codex/reports/current-batch-train-state.md
prompts/_BATCH_FINALIZE_TEMPLATE.md
prompts/batches/RUN-GLOBAL-BATCH-TRAIN-TO-COMPLETION.md
prompts/batches/PK15-FINALIZE-01.md
scripts/ambitions-global-train-supervisor.sh
scripts/ambitions-codex-train.sh
scripts/ambitions-prompt-audit.sh
Makefile
```

# Forbidden Scope

Do not modify `Native/`, `Sources/`, `AppUI/`, `Package.swift`, `project.yml`, `docs/truth/`, `.github/`, `Native/AmbitionsTests/`, or `Native/AmbitionsUITests/`.

# Validation Expectations

Run and record exact command, exit code, and result:

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

Do not run the full global train, PK15, or the global conductor prompt as validation for this batch.

# Final Safe Full-Train Command

After this batch is Green, the repo must provide:

```bash
make global-train-until-complete
```

or:

```bash
scripts/ambitions-global-train-supervisor.sh --until-complete
```

STATUS: UNKNOWN
