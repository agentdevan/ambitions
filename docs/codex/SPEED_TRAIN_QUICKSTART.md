# Speed Train Quickstart

Status: active operator quickstart  
Date: 2026-05-12

## Goal

Run the remaining Ambitions batches as fast as possible while preserving:

- no stale state reruns,
- no unsupported completion/readiness claims,
- no recursive global conductor loops,
- no false release/accessibility/device/privacy proof.

## One-time start

```bash
git pull --ff-only
make speed-status
```

## Run one batch

```bash
make speed-once
```

## Xcode timing evidence

Speed Train requires the repo-local benchmark helper to be discoverable:

```bash
scripts/ambitions-xcode-benchmark.sh --status
```

Xcode wrapper runs write timing summaries under ignored
`.codex/xcode-benchmarks/`. Use those summaries to diagnose slow focused lanes
before deleting repo-local DerivedData or escalating to build-for-testing,
test-plan, UI proof, or terminal proof lanes.

## Run until blocked or until `MAX_BATCHES` is reached

```bash
MAX_BATCHES=10 make speed-train
```

## Aggressive default behavior

Speed Train runs child batches with:

```bash
AUTO_BRANCH=0
ALLOW_MAIN_COMMIT=1
AUTO_COMMIT=1
AUTO_PUSH=1
KEEP_GOING_ON_YELLOW=1
ALLOW_YELLOW_COMMIT=1
MAX_REPAIR_PASSES=1
ACCESS_MODE=full
```

## If local preflight blocks on known intentional dirty files

Prefer cleaning/classifying the files. If the operator explicitly accepts the dirty state:

```bash
SPEED_ALLOW_DIRTY=1 MAX_BATCHES=5 make speed-train
```

## Final gate after a speed run

Default final gate skips Xcode heavy build:

```bash
make speed-final-gate
```

Run the heavy build-for-testing gate:

```bash
SPEED_RUN_HEAVY_FINAL_GATE=1 make speed-final-gate
```

## Expected next start

Current speed start should be:

```text
PK22 SideEffectLedger Foundation
```

Then proceed:

```text
PK23 -> PK24 -> PK25 -> PK26 -> PK27 -> PK28
```

## Stop conditions

Stop immediately for:

- Red or unknown child status,
- repeated same-batch loop,
- queue state mismatch,
- stale active/current-run/current-train mirror,
- unsupported completion/readiness claim,
- missing prompt,
- branch/ref/preflight hard blocker,
- compile/source failure if surfaced by focused validation.
