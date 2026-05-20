# Global Queue Resolver Repair Report

Status: Green
Date: 2026-05-19
Batch: GLOBAL-QUEUE-RESOLVER-REPAIR

## Scope

This repair installs one authoritative next-batch resolver for Ambitions global and autonomous train routing.

The resolver selects a batch and exact prompt path only. It does not execute Codex directly, bypass the Ambitions runner, weaken prompt metadata checks, or claim any app behavior, build, test, device, accessibility, performance, privacy/legal, release, or train-completion proof.

## Changed Behavior

- Added `scripts/ambitions-next-batch-resolver.py`.
- Updated `scripts/global-train-next-batch.sh` to delegate to the resolver.
- Updated `scripts/ambitions-global-train-supervisor.sh` so `--next`, `--once`, and `--until-complete` use the same resolver result.
- Updated `scripts/ambitions-autonomous-train-fastpath.py` so `make autonomous-train-next` uses the same resolver result.
- Kept `scripts/ambitions-next-batch-router.py` as a compatibility wrapper around the authoritative resolver.

## Resolver Rules

Selection order:

1. valid active Codex OS selection files
2. `.codex/state/active-batch.yml`
3. current active train state and finalization ledger
4. train manifests under `docs/codex/batch-trains/**`
5. nested runnable prompts under `prompts/batches/**/*.md`
6. legacy flat queue and flat prompt fallback

Runnable prompts must include all three runner metadata lines:

```html
<!-- AMBITIONS_RUNNER_REQUIRED: true -->
<!-- RUN_WITH: scripts/ambitions-codex-train.sh -->
<!-- DIRECT_CODEX_EXECUTION: forbidden_unless_user_explicitly_bypasses_runner -->
```

Ordered train handling:

- execution order files are preferred when present
- manifest and README order are used as fallback order sources
- prompt filename sorting is used only when no order source exists
- Green and accepted/closed Yellow evidence may be skipped
- plain Yellow remains unfinished and is not skipped

## Proof

Commands run:

```bash
python3 scripts/ambitions-next-batch-resolver.py --self-test
python3 scripts/ambitions-next-batch-resolver.py --json --train post-23-truth-audit
python3 scripts/ambitions-next-batch-resolver.py --json --legacy-only
scripts/global-train-next-batch.sh --field prompt_path
make global-train-next
make autonomous-train-next
python3 -m py_compile scripts/ambitions-next-batch-resolver.py scripts/ambitions-next-batch-router.py scripts/ambitions-autonomous-train-fastpath.py
make prompt-audit
```

Observed results:

- resolver self-test proved nested runnable prompt discovery, legacy flat prompt discovery, and missing runner metadata rejection
- nested post-23 dry-run selected `AMB-POST23-01-TRUTH-AUDIT` with exact prompt path `prompts/batches/post-23-truth-audit/AMB-POST23-01-TRUTH-AUDIT.md`
- legacy-only dry-run selected a flat runnable prompt path, proving flat prompts still work as fallback
- `scripts/global-train-next-batch.sh --field prompt_path` returned `prompts/batches/CS02C.md`
- `make global-train-next` returned `Next batch: CS02C` and `Prompt: prompts/batches/CS02C.md`
- `make autonomous-train-next` returned the same resolver result
- `make prompt-audit` returned Green with 399 active runnable prompts audited and 917 support/eval/template/historical files classified as non-actionable

## Current Selected Batch

The current full resolver result selects:

```text
Batch: CS02C
Prompt: prompts/batches/CS02C.md
Source: .codex/state/active-batch.yml
Reason: active batch mirror
```

This is expected because active-batch state has priority over manifest and prompt scanning when it points at a valid runnable prompt.

## Non-Claims

This repair does not claim:

- the selected batch has run
- any train is complete
- app behavior changed
- release readiness
- TestFlight or App Store readiness
- physical-device proof
- public accessibility conformance
- privacy/legal approval
- performance proof

## Rollback

Restore the touched resolver and wrapper files:

```bash
git restore -- scripts/ambitions-next-batch-resolver.py scripts/ambitions-next-batch-router.py scripts/global-train-next-batch.sh scripts/ambitions-global-train-supervisor.sh scripts/ambitions-autonomous-train-fastpath.py docs/audits/global-queue-resolver-repair-report.md
```

STATUS: GREEN
