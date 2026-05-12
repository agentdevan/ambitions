# Post-PK Speed Train Operating Model

Status: active after PK41 or with explicit operator override  
Authority: subordinate to `docs/truth/*`, `AGENTS.md`, and current queue state

## Purpose

The post-PK speed layer exists to accelerate every remaining non-PK batch after the Platform Kernel train closes.

It preserves the Ambitions batch discipline while removing the slowest failure modes:

- stale prompt labels,
- stale state mirrors,
- broad historical claim scans during install,
- separate implementation and advancement commits,
- repeated manual blocker interpretation,
- one-size-fits-all validation.

## Standard Batch Loop

Each batch should close as:

```text
install -> focused review -> focused validation -> closeout report -> state advancement -> one commit -> push -> next batch
```

A batch is not done until the next executable batch is already set.

## Proof Philosophy

Use the minimum honest proof that matches the batch lane.

- Docs/control-plane: diff, JSON/syntax checks, prompt/claim scan on touched/current files.
- Model-only: focused model tests if Swift source changed.
- Service-only: focused owner tests if available.
- Source Atlas: focused model/query/importer tests for touched owner.
- UI/visual: screenshot/preview proof only when visual completion is claimed.
- Release/device/accessibility/performance: terminal gates only.

## Non-Negotiables

Do not claim:

- release readiness,
- TestFlight readiness,
- App Store readiness,
- physical-device validation,
- public accessibility conformance,
- performance validation,
- privacy/legal approval,
- global completion,
- visual runtime completion,
- full-suite Green,

unless the batch actually produced current proof.

## Primary Scripts

- `scripts/ambitions-post-pk-speed-router.py`
- `scripts/ambitions-post-pk-speed-train.sh`
- `scripts/ambitions-advance-batch-state.py`
- `scripts/ambitions-state-advance-validate.py`
- `scripts/ambitions-closeout-coalesce.py`
- `scripts/ambitions-repair-classifier.py`
- `scripts/ambitions-bundle-next-batches.py`
- `scripts/ambitions-prompt-queue-consistency.py`

## Commands

```bash
make post-pk-speed-status
make post-pk-speed-next
make post-pk-speed-once
MAX_BATCHES=10 make post-pk-speed-train
make post-pk-speed-final-gate
```

## PK Safety

By default, post-PK speed train refuses `PK*` batches. Finish PK with the existing PK process. If the operator intentionally wants to use the post-PK wrapper for a PK batch, they must set:

```bash
ALLOW_PK_IN_POST_PK_SPEED=1
```

## Final Gates

Heavy gates should be run after bundles or at terminal proof points, not after every batch.
