# Autonomous Train Fastpath Install Report

Status: Active speed-layer install  
Date: 2026-05-13  
Branch: `main`

## Installed files

```text
scripts/ambitions-next-batch-router.py
scripts/ambitions-owned-files-detector.py
scripts/ambitions-batch-closeout-accelerator.py
scripts/ambitions-red-repair-router.py
scripts/ambitions-autonomous-train-fastpath.py
docs/codex/AUTONOMOUS_TRAIN_FASTPATH.md
prompts/batches/AUTONOMOUS-TRAIN-FASTPATH-01.md
.codex/skills/autonomous-train-conductor.md
.codex/skills/hbi-mri-overlay-reviewer.md
.codex/skills/owned-file-stager.md
.codex/skills/accepted-yellow-classifier.md
.codex/skills/batch-closeout-editor.md
scripts/ambitions-autonomous-train.sh
```

## Entrypoint

`make autonomous-train` continues to use the existing Makefile target path. The existing shell entrypoint now delegates to:

```bash
python3 scripts/ambitions-autonomous-train-fastpath.py
```

## Speed intent

The speed layer supports:

```text
Install -> Review -> Advance Train -> Push -> Repeat
```

It routes the next batch, applies HBI/MRI guardrails, delegates real execution to the existing Ambitions runner, classifies failures, classifies changed files for safe staging, and creates closeout report skeletons.

## Not included

This install does not add new tests, new test frameworks, new hosted services, new external dependencies, a queue rewrite, app implementation, build proof, release proof, device proof, App Store/TestFlight proof, accessibility proof, or privacy/legal approval.

## Suggested checks

```bash
python3 scripts/ambitions-autonomous-train-fastpath.py --status
python3 scripts/ambitions-autonomous-train-fastpath.py --next
python3 scripts/ambitions-autonomous-train-fastpath.py --once --dry-run --no-push
python3 scripts/ambitions-next-batch-router.py --dry-run --prefer-hbi
```

## Claim boundary

This is an orchestration-speed install only. It is not product implementation proof or readiness proof.
