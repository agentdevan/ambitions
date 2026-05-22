<!-- AMBITIONS_RUNNER_REQUIRED: true -->
<!-- RUN_WITH: scripts/ambitions-codex-train.sh -->
<!-- DIRECT_CODEX_EXECUTION: forbidden_unless_user_explicitly_bypasses_runner -->
# TRAIN_04A - Life Context & Historical Catch-Up Runtime Inputs

## Objective
Install and run the `Life Context & Historical Catch-Up Runtime Inputs` train only through the Ambitions runner when dependencies are satisfied.

## Why it exists
Ambitions cannot produce truly personalized daily steps if the user's life starts on download day. This train installs the local-first domain, intake, runtime projection, user controls, receipts, and proof that allow the Private Life Runtime to plan from user-owned life context and pre-download history.

This is not demographic profiling. It is visible, editable, deletable, source-labeled, freshness-labeled, explainable, local-first Life Context.

## Dependencies
See `docs/codex/IOS26_FLAGSHIP_TRAIN_MANIFEST.yml`. This train depends on TRAIN_03 and TRAIN_04 and sits after TRAIN_04 and before TRAIN_05.

## Batch list
- IOS26-T04A-B01
- IOS26-T04A-B02
- IOS26-T04A-B03
- IOS26-T04A-B04
- IOS26-T04A-B05
- IOS26-T04A-B06

## Source scope
See the exact source areas in each mapped batch prompt.

## Validation gates
Runner metadata, dependency proof, command logs, Green/Yellow/Red closeout, and post-batch gates for accepted Yellow.

## Proof artifacts
Use `build/reports/life-context/` and the specific batch prompt.

## Product standard
The system must feel like: "Ambitions is getting caught up on my life so it can plan from reality."

It must not feel like: "Ambitions is profiling me."

All context must be local-first, user-owned, visible, editable, deletable, source-labeled, freshness-labeled, explainable, runtime-affecting only when allowed, and receipt-backed when changed.

## Train-level acceptance gate
Create `build/reports/life-context/TRAIN_04A_CLOSEOUT.md` when the train is executed.

The closeout must include:
- Status: Green / Yellow / Red
- Batches completed
- Files changed
- Runtime models added
- Persistence proof
- Catch-up flow proof
- Scenario proof
- You controls proof
- Privacy/local-first proof
- Accessibility support status
- Known gaps
- Claims allowed
- Claims forbidden
- Next train eligibility

## Claims allowed only if Green
- "Ambitions has a local-first Life Context layer."
- "Life Context can affect runtime recommendations."
- "Historical context can be captured, reviewed, corrected, and excluded."
- "The same goal can produce different plans for different life contexts."
- "Life Context personalization is inspectable through a factor ledger."
- "Recommendation changes can be traced to source-labeled, freshness-aware, user-controlled factors."

## Claims forbidden unless proven
- "Perfect plans"
- "Verified accessibility"
- "Production-ready App Store context system"
- "Fully accurate local opportunity discovery"
- "Medical, legal, recruiting, or professional advice"
- "Automatic demographic optimization"
- "Demographic template planning"
- "AI profile buckets"
- "Static user archetype recommendations"
- "Hidden behavioral manipulation"

## Red/Yellow/Green closeout rules
Green requires evidence. Yellow requires owner, reason, no-claim boundary, and gate. Red stops.

## Rollback strategy
Rollback only touched files. Preserve unrelated dirty work.

## Sequential commands for that train
```bash
scripts/ambitions-codex-train.sh IOS26-T04A-B01 prompts/batches/IOS26-T04A-B01-life-context-domain.md
scripts/ambitions-codex-train.sh IOS26-T04A-B02 prompts/batches/IOS26-T04A-B02-historical-catchup-intake.md
scripts/ambitions-codex-train.sh IOS26-T04A-B03 prompts/batches/IOS26-T04A-B03-runtime-effect-proof.md
scripts/ambitions-codex-train.sh IOS26-T04A-B04 prompts/batches/IOS26-T04A-B04-you-controls-receipts.md
scripts/ambitions-codex-train.sh IOS26-T04A-B05 prompts/batches/IOS26-T04A-B05-you-life-context-premium-panel.md
scripts/ambitions-codex-train.sh IOS26-T04A-B06 prompts/batches/IOS26-T04A-B06-anti-bucket-factor-ledger-proof.md
```

## Batch summaries
- IOS26-T04A-B01: `prompts/batches/IOS26-T04A-B01-life-context-domain.md`
- IOS26-T04A-B02: `prompts/batches/IOS26-T04A-B02-historical-catchup-intake.md`
- IOS26-T04A-B03: `prompts/batches/IOS26-T04A-B03-runtime-effect-proof.md`
- IOS26-T04A-B04: `prompts/batches/IOS26-T04A-B04-you-controls-receipts.md`
- IOS26-T04A-B05: `prompts/batches/IOS26-T04A-B05-you-life-context-premium-panel.md`
- IOS26-T04A-B06: `prompts/batches/IOS26-T04A-B06-anti-bucket-factor-ledger-proof.md` - anti-bucket personalization and first-class factor ledger proof for deterministic, inspectable, multi-factor recommendation reasoning.

## Post-batch gates
Record accepted Yellow gates in `docs/codex/POST_BATCH_GATE_REGISTRY.md`.
