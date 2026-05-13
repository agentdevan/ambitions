# Historical Baseline Global Train Install Report

Status: Active governance / prompt / guard install  
Date: 2026-05-13  
Branch: `main`

## Installed

Historical Baseline train control-plane artifacts are installed on `main`.

Core files:

- `docs/codex/HISTORICAL_BASELINE_GLOBAL_TRAIN_OVERLAY.md`
- `docs/codex/HISTORICAL_BASELINE_GLOBAL_TRAIN_MANIFEST.json`
- `docs/codex/batch-trains/HBI00_RRE01_HISTORICAL_BASELINE_TRAIN.md`
- `scripts/ambitions-historical-baseline-train-guard.py`
- `prompts/batches/HBI-GLOBAL-TRAIN-HANDOFF-01.md`

Runner prompts installed:

```text
HBI-00
HBI-01
HBI-02
HBI-03
HBI-04
HBI-05
HBI-06
HBI-07
HBI-08
SCI-01
SCI-02
SCI-03
IRQ-01
IRQ-02
HBI-09
HBI-10
PRI-01
RHE-01
PPL-01
PPL-02
LSF-01
MGP-01
RRE-01
```

## Queue relationship

Canonical queue order is preserved. This install does not directly rewrite `docs/codex/GLOBAL_QUEUE_CANONICAL_ORDER.json`.

The intended pickup rule is:

1. Continue the active canonical queue.
2. If `SA17` is next, run `SA17` next.
3. Apply the Historical Baseline overlay through the Source Atlas import/review foundation.
4. Run the HBI-family sequence from the manifest before downstream source-aware maturity claims.

## Guard

Run:

```bash
python3 scripts/ambitions-historical-baseline-train-guard.py
```

The guard checks installation/discoverability only.

## Handoff command

```bash
make batch BATCH=HBI-GLOBAL-TRAIN-HANDOFF-01 PROMPT=prompts/batches/HBI-GLOBAL-TRAIN-HANDOFF-01.md
```

Equivalent:

```bash
scripts/ambitions-codex-train.sh HBI-GLOBAL-TRAIN-HANDOFF-01 prompts/batches/HBI-GLOBAL-TRAIN-HANDOFF-01.md
```

## Claim boundary

This install is not runtime implementation proof and does not prove build, visual, accessibility, device, release, TestFlight, App Store, or legal readiness.
