# POST-PK-SPEED-UPGRADE-01 Report

Status: GitHub-side speed tooling installed. Local validation was not run in this chat.  
Date: 2026-05-12

## Objective

Install high-impact post-PK batch completion speed upgrades without touching PK implementation, app runtime source, package/project files, release automation, signing, entitlements, or hosted/cloud behavior.

## Installed Files

### Scripts

- `scripts/ambitions-post-pk-speed-router.py`
- `scripts/ambitions-advance-batch-state.py`
- `scripts/ambitions-state-advance-validate.py`
- `scripts/ambitions-closeout-coalesce.py`
- `scripts/ambitions-repair-classifier.py`
- `scripts/ambitions-bundle-next-batches.py`
- `scripts/ambitions-post-pk-speed-train.sh`

### Docs

- `docs/codex/POST_PK_SPEED_TRAIN_OPERATING_MODEL.md`
- `docs/codex/POST_PK_PROOF_LIGHT_POLICY.md`
- `docs/codex/POST_PK_CLOSEOUT_CONTRACT.md`
- `docs/codex/POST_PK_BATCH_BUNDLES.md`
- `docs/codex/POST_PK_REPAIR_DECISION_TREE.md`

### Operator Prompts

- `prompts/desktop/POST_PK_FAST_TRAIN_OPERATOR.md`
- `prompts/desktop/POST_PK_REPAIR_OPERATOR.md`
- `prompts/desktop/POST_PK_BUNDLE_OPERATOR.md`

### Makefile

- `Makefile.post-pk-speed`

## What This Enables

After PK41 or explicit operator override, Codex Desktop can use:

```bash
make -f Makefile.post-pk-speed post-pk-speed-status
make -f Makefile.post-pk-speed post-pk-speed-next
make -f Makefile.post-pk-speed post-pk-speed-once
MAX_BATCHES=10 make -f Makefile.post-pk-speed post-pk-speed-train
make -f Makefile.post-pk-speed post-pk-speed-final-gate
```

## Speed Improvements

- Batch-lane routing replaces one-size-fits-all validation.
- State advancement can be generated deterministically.
- State advancement can be validated independently.
- Closeout coalescing supports one commit containing implementation, report, and state advancement.
- Repair classifier turns failures into fast repair actions.
- Bundle planner keeps context warm across Source Atlas, LDI/AOS tails, FCP/PFC closeout, RHC, and visual/runtime work.
- Post-PK wrapper avoids the broad historical claim scanner during per-batch install.
- Desktop prompts give Codex Desktop explicit operator modes.

## Boundaries

No app runtime source was intentionally changed. No `Native/Ambitions/**`, `Native/AmbitionsTests/**`, `Package.swift`, `project.yml`, `.github/**`, signing, entitlement, release automation, hosted backend, telemetry, analytics, or app runtime OpenAI integration was intentionally added.

## Local Validation Recommended

Run after pulling:

```bash
git pull --ff-only
python3 -m py_compile \
  scripts/ambitions-post-pk-speed-router.py \
  scripts/ambitions-advance-batch-state.py \
  scripts/ambitions-state-advance-validate.py \
  scripts/ambitions-closeout-coalesce.py \
  scripts/ambitions-repair-classifier.py \
  scripts/ambitions-bundle-next-batches.py
bash -n scripts/ambitions-post-pk-speed-train.sh
make -f Makefile.post-pk-speed post-pk-router-help
make -f Makefile.post-pk-speed post-pk-advance-help
make -f Makefile.post-pk-speed post-pk-repair-help
make -f Makefile.post-pk-speed post-pk-bundles
```

## Usage After PK41

```bash
git pull --ff-only
make -f Makefile.post-pk-speed post-pk-speed-status
MAX_BATCHES=10 make -f Makefile.post-pk-speed post-pk-speed-train
```

If intentionally using during remaining PK tail:

```bash
ALLOW_PK_IN_POST_PK_SPEED=1 MAX_BATCHES=3 make -f Makefile.post-pk-speed post-pk-speed-train
```

## Claims Not Made

This install does not claim any batch completion, PK completion, Source Atlas completion, visual runtime completion, app runtime behavior, release readiness, TestFlight readiness, App Store readiness, device proof, public accessibility conformance, performance validation, privacy/legal approval, production readiness, or global train completion.
