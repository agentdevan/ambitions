# Paste-Ready Codex Installer Prompt — Object Frontend iOS 26 Expansion

You are Codex operating in repo `agentdevan/ambitions`.

## Mission

Install the Ambitions Object Frontend implementation package and update/extend the iOS 26 train so Ambitions ships an object-first SwiftUI frontend that inherits AmbitionsDesignSystem and removes generic card architecture from active top-level surfaces.

Do not redesign from taste. Implement the object frontend authority, validator, batch prompts, and train expansion safely.

## Non-negotiable authorities

Read first:

```text
docs/truth/PRODUCT_DESIGN_TRUTH.md
docs/truth/IMPLEMENTATION_TRUTH.md
docs/truth/CODEX_PROCESS_TRUTH.md
docs/truth/HISTORICAL_POLICY.md
docs/codex/IOS26_FLAGSHIP_TRAIN_MANIFEST.yml
docs/codex/ios26/IOS26_IMPLEMENTATION_ORDER.md
docs/codex/ios26/IOS26_BATCH_MATRIX.yml
```

Then install/read these new files:

```text
docs/codex/frontend/AMB_OBJECT_FRONTEND_IMPLEMENTATION_SPEC.md
docs/codex/frontend/IOS26_OBJECT_FRONTEND_BATCH_INSERTION_PLAN.md
docs/codex/frontend/IOS26_ANTI_CARD_VALIDATOR_SPEC.md
docs/codex/frontend/IOS26_EXISTING_BATCH_EXPANSION_DIRECTIVES.md
docs/codex/frontend/OBJECT_FRONTEND_GREEN_YELLOW_RED_RUBRIC.md
```

## Required files to create

Create:

```text
docs/codex/frontend/AMB_OBJECT_FRONTEND_IMPLEMENTATION_SPEC.md
docs/codex/frontend/IOS26_OBJECT_FRONTEND_BATCH_INSERTION_PLAN.md
docs/codex/frontend/IOS26_ANTI_CARD_VALIDATOR_SPEC.md
docs/codex/frontend/IOS26_EXISTING_BATCH_EXPANSION_DIRECTIVES.md
docs/codex/frontend/OBJECT_FRONTEND_GREEN_YELLOW_RED_RUBRIC.md
prompts/batches/IOS26-T04L-B01-living-chrome-object-purity.md
prompts/batches/IOS26-T10-B04-global-object-purity-sweep.md
scripts/ios26-anti-card-check.py
```

Install the markdown content from the provided artifact package exactly, then adapt only paths that are proven different by repo inspection.

## Required prompt/batch updates

Add new train before T05:

```text
TRAIN_04L — Object Frontend Living Chrome Foundation
IOS26-T04L-B01-living-chrome-object-purity.md
```

Add new batch after T10-B03:

```text
IOS26-T10-B04-global-object-purity-sweep.md
```

Expand existing prompts in place:

```text
IOS26-T05-B01-reality-meridian-recomposition.md
IOS26-T06-B02-lifeshape-field-surface.md
IOS26-T07-B01-constellation-atlas-root.md
IOS26-T08-B01-atmosphere-composer-dominance.md
IOS26-T09-B01-runtime-affecting-profile.md
IOS26-T09-B02-trust-memory-controls.md
IOS26-T10-B01-receipt-lineage-service.md
IOS26-T10-B02-cross-surface-proof-drawer.md
IOS26-T10-B03-recovery-replay.md
```

Do not add T05-B04, T06-B04, T07-B04, T08-B04, or T09-B04 by default. The final Wave 10 decision is to embed object-purity into existing object install batches and add only T04L-B01 plus T10-B04.

## Validator requirements

Implement:

```bash
python3 scripts/ios26-anti-card-check.py --surface shell --batch IOS26-T04L-B01
python3 scripts/ios26-anti-card-check.py --surface today --batch IOS26-T05-B01
python3 scripts/ios26-anti-card-check.py --surface time --batch IOS26-T06-B02
python3 scripts/ios26-anti-card-check.py --surface goals --batch IOS26-T07-B01
python3 scripts/ios26-anti-card-check.py --surface capture --batch IOS26-T08-B01
python3 scripts/ios26-anti-card-check.py --surface you --batch IOS26-T09-B02
python3 scripts/ios26-anti-card-check.py --surface proof --batch IOS26-T10-B03
python3 scripts/ios26-anti-card-check.py --surface global --batch IOS26-T10-B04
```

Validator must write Markdown and JSON reports under:

```text
build/reports/frontend-object-purity/
```

## Manifest/order updates

After prompts are created, update generated train/order artifacts using repo scripts where available.

Expected artifacts:

```text
docs/codex/IOS26_FLAGSHIP_TRAIN_MANIFEST.yml
docs/codex/ios26/IOS26_IMPLEMENTATION_ORDER.md
docs/codex/ios26/IOS26_BATCH_MATRIX.yml
docs/codex/ios26/IOS26_PROMPT_FREEZE_HASHES.json
docs/codex/IOS26_FLAGSHIP_SEQUENTIAL_RUNBOOK.md
```

Do not hand-maintain generated files if a repo script owns them.

## Required validation

Run repo-supported validation. At minimum, run:

```bash
python3 scripts/ios26-anti-card-check.py --surface global --batch IOS26-FRONTEND-INSTALL
python3 scripts/ios26-flagship-preflight.py --batch IOS26-T04L-B01
```

Then inspect Makefile/scripts and run the narrowest supported build/test command covering changed scripts, docs, prompts, and app source.

## Proof artifacts

Write:

```text
build/reports/frontend-object-purity/object-frontend-install.md
build/reports/frontend-object-purity/object-frontend-train-update.md
build/reports/frontend-object-purity/validator-install.md
```

## Green gates

Green only if:

- docs installed
- prompts installed/expanded
- T04L and T10-B04 added to manifest/order
- validator exists and runs
- no generated-file ownership violated
- proof artifacts written
- no release/readiness/accessibility/performance overclaim

## Yellow gates

Yellow only with exact owner, reason, no-claim boundary, follow-up gate, and repair-cycle evidence.

## Red gates

Red if:

- frontend spec overwrites design-system truth
- broad token redesign occurs without scope
- T04L/T10-B04 not inserted
- validator missing
- object-purity requirements omitted from T05–T10
- generated artifacts are manually corrupted
- active card architecture is accepted as Green

## Final report

Return:

```text
Status: Green / Yellow / Red
Files changed by category:
Docs:
Prompts:
Scripts:
Generated manifest/order:
Proof artifacts:
Commands run:
Commands not run:
Validator status:
Train insertion status:
Existing prompt expansion status:
Design-system changes:
Yellow items:
Red items:
Next batch:
```
