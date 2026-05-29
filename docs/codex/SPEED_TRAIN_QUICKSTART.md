# Speed Train Quickstart

<!-- AMB-291-CANON-HYGIENE-HEADER: BEGIN -->

> Canon hygiene status: **codex-reference**
> AMB-291 note: This Codex reference supports process or execution, but active truth remains in docs/truth and current manifests.
> Active authority: `docs/truth/*`, `docs/codex/GLOBAL_BATCH_SEQUENCE_AUTHORITY.json`, and `docs/codex/IOS26_FLAGSHIP_TRAIN_MANIFEST.yml`.
> Before using this file for implementation, run `make change-impact-check` and follow `docs/ops/change-protocol/implementation-prompt-template.md`.
> Resolution classes: authority-rewrite, merge-overlap, merge-overlap-before-proof
> Dispositions: merge-before-proof, merge-or-sequence-file-ownership, merge-or-sequence-surface-ownership, rewrite-authority-reference

<!-- AMB-291-CANON-HYGIENE-HEADER: END -->

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

## Source-of-truth references

<!-- AMB-291-SOURCE-OF-TRUTH-REFERENCES: BEGIN -->

This file must not be treated as standalone active canon. Current authority must be resolved through:

- `docs/truth/README.md`
- `docs/truth/PRODUCT_DESIGN_TRUTH.md`
- `docs/truth/PRODUCT_MOAT_TRUTH.md`
- `docs/truth/IMPLEMENTATION_TRUTH.md`
- `docs/truth/RELEASE_TRUTH.md`
- `docs/truth/CODEX_PROCESS_TRUTH.md`
- `docs/truth/HISTORICAL_POLICY.md`
- `docs/codex/GLOBAL_BATCH_SEQUENCE_AUTHORITY.json`
- `docs/codex/IOS26_FLAGSHIP_TRAIN_MANIFEST.yml`
- `docs/ops/change-protocol/change-request-template.md`
- `docs/ops/change-protocol/change-impact-check.md`
- `docs/ops/change-protocol/implementation-prompt-template.md`
- `docs/ops/change-protocol/post-implementation-proof-reconciliation.md`

<!-- AMB-291-SOURCE-OF-TRUTH-REFERENCES: END -->

## Non-claims

<!-- AMB-291-NON-CLAIMS: BEGIN -->

- This file does not prove implementation.
- This file does not prove build success.
- This file does not prove test success.
- This file does not prove accessibility validation.
- This file does not prove performance validation.
- This file does not prove device validation.
- This file does not prove privacy/legal approval.
- This file does not prove TestFlight readiness.
- This file does not prove App Store readiness.
- This file does not prove release readiness.
- Linear status is not repo truth.

<!-- AMB-291-NON-CLAIMS: END -->
