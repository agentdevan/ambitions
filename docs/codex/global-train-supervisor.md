# Global Train Supervisor

Status: Active Codex OS runbook
Authority: Supporting process doc subordinate to `docs/truth/*`

The global train should be run by the external supervisor script, not by a long-lived nested Codex conductor phase.

## Why This Exists

The previous recursive conductor model could start a parent prompt, generate or select a child batch, launch the child through the runner, see incomplete/Yellow/Unknown artifacts, and then launch another attempt before the first path was finalized. That caused repeated same-root retries, Phase 02 reruns when final GPT-5.5 review was needed, and overlapping validation/Xcode lock risk.

The repair is a single-owner loop:

```text
one batch -> one runner lifecycle -> inspect result -> update ledger -> continue or stop
```

## Commands

```bash
make global-train-status
make global-train-next
make global-train-once
make global-train-until-complete
```

Direct script equivalents:

```bash
scripts/ambitions-global-train-supervisor.sh --status
scripts/ambitions-global-train-supervisor.sh --next
scripts/ambitions-global-train-supervisor.sh --once
scripts/ambitions-global-train-supervisor.sh --until-complete
```

Default script mode is `--once`.

## Attempt Ledger

The supervisor consults `.codex/state/global-train-attempt-ledger.md`.

Supported unresolved states:

- `running`
- `yellow-unresolved`
- `red-unresolved`
- `unknown-unresolved`
- `repair-required`
- `finalization-required`
- `blocked`

Continuation states:

- `green`
- `accepted-yellow`

An unresolved state blocks a normal rerun. The next step must be a separately named finalization or repair prompt, such as `PK15-FINALIZE-01`.

## Yellow Handling

Yellow may continue only when all of this is recorded:

- owner
- reason
- no-claim boundary
- retirement condition
- resume path
- proof path
- why continuation is safe

Missing Yellow acceptance data keeps the state unresolved and stops the supervisor.

## Red And Unknown Handling

Red stops. Unknown is treated as unresolved unless artifact inspection proves otherwise. A build lock or active conflicting runner/Codex/Xcode process also stops.

The supervisor does not kill processes automatically. It reports process IDs and exits.

## Finalization Prompts

Use `prompts/_BATCH_FINALIZE_TEMPLATE.md` to create finalization prompts. A finalization prompt reviews existing diff/artifacts and must not rerun Spark implementation or the original batch from scratch.

Current unresolved PK15 work is routed through:

```bash
make batch BATCH=PK15-FINALIZE-01 PROMPT=prompts/batches/PK15-FINALIZE-01.md
```

## Non-Claims

Supervisor Green means the operating model and local script checks passed. It does not prove app build success, full test success, release readiness, visual quality, accessibility conformance, performance validation, physical-device validation, TestFlight readiness, App Store readiness, legal/privacy approval, or global train completion.
