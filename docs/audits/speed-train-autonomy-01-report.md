# SPEED-TRAIN-AUTONOMY-01 Report

Status: GitHub-side Speed Train overlay installed. Local execution was not run in this chat.  
Date: 2026-05-12

## Objective

Make Ambitions batch execution more autonomous and much faster while preserving the canonical Ambitions runner and proof honesty.

## Installed updates

1. `docs/codex/SPEED_TRAIN_OPERATING_MODEL.md`
   - Defines the active speed overlay, light per-batch gates, final heavy gate timing, and no-claim boundaries.

2. `scripts/ambitions-speed-train.sh`
   - Adds the high-throughput operator loop over the existing autonomous train and canonical batch runner.

3. `Makefile`
   - Adds `speed-status`, `speed-next`, `speed-once`, `speed-train`, `speed-train-until-blocked`, and `speed-final-gate`.

4. `docs/codex/SPEED_TRAIN_LANE_POLICY.json`
   - Defines validation lanes for docs/control-plane, domain-model, service-seam, persistence/schema, UI/visual, and terminal-release/device batches.

5. `scripts/ambitions-speed-queue-guard.py`
   - Blocks speed execution when queue state and active next-batch state disagree.

6. `scripts/ambitions-speed-train.sh`
   - Integrated stale-state checks, queue guard, unsupported-claim scan, and lane policy helper.

7. `scripts/ambitions-speed-lane-policy.py`
   - Prints the advisory Speed Train lane and expected checks for the next batch.

8. `docs/codex/SPEED_TRAIN_QUICKSTART.md`
   - Adds the operator quickstart and commands.

9. `docs/codex/ambitions-hybrid-runner.md`
   - Documents Speed Train as the maximum-throughput wrapper while preserving the canonical runner.

10. `prompts/batches/SPEED-TRAIN-AUTONOMY-01.md`
    - Adds a runner-compatible preservation prompt for future Codex sessions.

11. `docs/codex/CODEX_OS_INDEX.md`
    - Adds Speed Train docs and commands to the Codex OS index.

12. `docs/audits/speed-train-autonomy-01-report.md`
    - This report.

## Commands added

```bash
make speed-status
make speed-next
make speed-once
make speed-train
make speed-train-until-blocked
make speed-final-gate
```

## Fast path

```bash
MAX_BATCHES=10 make speed-train
```

## One-batch path

```bash
make speed-once
```

## Final gate

```bash
make speed-final-gate
```

Heavy final gate:

```bash
SPEED_RUN_HEAVY_FINAL_GATE=1 make speed-final-gate
```

## Speed defaults

Speed Train launches child batches with:

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

## Expected next batch

Current intended start:

```text
PK22 SideEffectLedger Foundation
```

The queue guard should reject execution if live state no longer agrees.

## Local validation required

```bash
git pull --ff-only
bash -n scripts/ambitions-speed-train.sh
python3 -m py_compile scripts/ambitions-speed-queue-guard.py scripts/ambitions-speed-lane-policy.py scripts/ambitions-stale-state-check.py scripts/ambitions-unsupported-claim-scan.py
python3 -m json.tool docs/codex/SPEED_TRAIN_LANE_POLICY.json >/tmp/ambitions-speed-train-lane-policy-check.json
python3 scripts/ambitions-stale-state-check.py
python3 scripts/ambitions-speed-queue-guard.py PK22
python3 scripts/ambitions-speed-lane-policy.py PK22
python3 scripts/ambitions-unsupported-claim-scan.py docs prompts .codex
make speed-next
```

## Claims not made

This pass does not claim PK22 completion, implementation batch completion, local runner execution, xcodegen proof, xcodebuild proof, simulator proof, physical-device proof, release readiness, TestFlight readiness, App Store readiness, public accessibility conformance, performance validation, privacy/legal approval, visual runtime completion, or global train completion.

## Recommended next action

```bash
git pull --ff-only
make speed-status
MAX_BATCHES=10 make speed-train
```
