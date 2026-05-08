# Model Tier Deferral Ledger

Status: Active ledger for Mini-to-Senior batch deferrals.
Date: 2026-05-08
Scope: Tracks batches intentionally deferred by the Mini Execution Tier and resolved by the Senior Judgment Tier.

This ledger is not a Green report. It is a queue of obligations. A batch listed here is not complete unless a later entry closes it with evidence.

## Rules

- Mini may add entries only under `docs/codex/MODEL_TIER_EXECUTION_POLICY.md`.
- Mini must not mark a deferred batch Green.
- Senior must preserve the original entry and append a resolution entry.
- A deferred batch may be skipped by the Mini train only when it is not a blocking prerequisite.
- If a deferral becomes blocking, the train stops until the Senior tier resolves it.
- Do not erase history. Mark stale entries `Superseded` with evidence instead.

## Entry Format

```md
### DEF-YYYYMMDD-NN — <batch id / title>

- Status: Open / Closed / Superseded / Red
- Created by tier: Mini Execution Tier / Unknown under Mini-safe rules
- Created date:
- Source batch:
- Why Mini deferred:
- Senior-only gate:
- Blocking status: non-blocking / blocking / unknown
- Safe-to-continue reason:
- Files touched before deferral:
- Validation before deferral:
- No-claim boundary:
- Required Senior action:
- Resolution:
- Resolution evidence:
```

## Open Deferrals

None at policy creation.

## Closed Deferrals

None at policy creation.

## Superseded Deferrals

None at policy creation.

## Hard Red Notes

If Mini defers a blocking prerequisite or cannot prove safe continuation, it must stop with a Red report instead of adding a non-blocking deferral.
