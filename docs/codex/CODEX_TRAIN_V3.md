# Codex Train V3

Status: Active runner design for new GitHub Actions Codex trains.  
Scope: GitHub Actions execution, batch manifest semantics, gate routing, artifact policy, and proof discipline.  
Owner posture: Process authority subordinate to `docs/truth/*`.

## Why V3 exists

V3 replaces recovery-era runner behavior for new Ambitions trains.

The old release recovery path is still present for historical recovery work, but new product/architecture trains should use V3.

V3 goals:

- typed batches instead of filename inference
- manifest-owned sequencing
- Python-first orchestration
- no prompt mutation in CI
- no generated output under `build/reports`
- no universal source gates for audit batches
- one commit per Green batch by default
- fail closed on Red
- upload ephemeral proof as Actions artifacts

## Workflow

Use:

```text
.github/workflows/ambitions-codex-train-v3.yml
```

Default train:

```text
object-stage-mega-train
```

Default manifest:

```text
trains/object-stage-mega-train/train.json
```

## Batch types

### audit

For source maps, risk registers, migration boundaries, and proof planning.

Runs no source-owner/champion coverage gate and no Xcode build by default.

### docs

For truth/process docs.

Runs docs and claim-boundary gates.

### source

For app source and tests.

Runs source gates, authority gates, local-first boundary, and build when enabled.

### visual

For UI reconstruction.

Runs source gates plus visual/accessibility proof expectations from the prompt.

### schema

For SwiftData or persistence model changes.

Runs source gates plus migration/default/rollback proof expectations from the prompt.

### validation

For final test/proof/truth updates.

Runs authority, boundary, build, and focused validation as configured.

## Artifact policy

Ephemeral runner logs:

```text
artifacts/codex-train-v3/runs/
```

Durable train proof:

```text
artifacts/object-stage-mega-train/
```

Do not write new generated runner reports under:

```text
build/reports/
```

## Prompt policy

V3 does not self-heal prompts in CI.

If a prompt is invalid, V3 fails preflight and writes a batch report. Prompt files must be edited deliberately in source control.

## Commit policy

Default strategy is one commit per Green batch.

No commit on Red.

Yellow should not commit unless a manifest/policy explicitly allows it later.

## Running manually on the self-hosted runner

```bash
python3 scripts/codex/train_v3.py \
  --train object-stage-mega-train \
  --start-batch AMB-AOM-00 \
  --end-batch AMB-AOM-00 \
  --mode dry-run \
  --commit-strategy none
```

Execute AOM-00:

```bash
python3 scripts/codex/train_v3.py \
  --train object-stage-mega-train \
  --start-batch AMB-AOM-00 \
  --end-batch AMB-AOM-00 \
  --mode execute \
  --commit-strategy batch
```

Resume full train:

```bash
python3 scripts/codex/train_v3.py \
  --train object-stage-mega-train \
  --start-batch AMB-AOM-01 \
  --mode execute \
  --commit-strategy batch \
  --run-xcode-build \
  --run-tests focused
```

## Hard rules

- `docs/truth/PRODUCT_DESIGN_TRUTH.md` wins product conflicts.
- Manifest batch type wins gate selection.
- Audit batches do not run source-owner gates.
- CI does not mutate prompts.
- Generated proof does not go to `build/reports`.
- No release/readiness/account/R2/accessibility/device claims without proof.
