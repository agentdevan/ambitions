# Autonomous Train Fastpath

Status: Active speed-layer governance  
Date: 2026-05-13

## Purpose

The autonomous train fastpath exists to speed up the existing Ambitions loop:

```text
Install -> Review -> Advance Train -> Push -> Repeat
```

It does not replace the Ambitions runner. It routes to the next batch, applies HBI/MRI guardrails, delegates execution to the runner, and reduces repeated manual decision overhead.

## Primary command

```bash
make autonomous-train
```

The fastpath wrapper is:

```bash
python3 scripts/ambitions-autonomous-train-fastpath.py --until-complete
```

## Installed helpers

```text
scripts/ambitions-next-batch-router.py
scripts/ambitions-owned-files-detector.py
scripts/ambitions-batch-closeout-accelerator.py
scripts/ambitions-red-repair-router.py
scripts/ambitions-autonomous-train-fastpath.py
```

## Operating rules

- Do not add new tests for speed-layer operation.
- Use existing guards and validators only.
- Do not bypass `scripts/ambitions-codex-train.sh`.
- Do not bypass canonical queue truth.
- Do not stage unrelated files.
- Do not stage `.codex/runs`, Xcode logs/results, DerivedData, or unrelated generated artifacts.
- Do not make release, device, App Store, TestFlight, accessibility, privacy/legal, or commercial-readiness claims.
- HBI and MRI overlays must be factored into every applicable batch.

## Quick commands

```bash
python3 scripts/ambitions-autonomous-train-fastpath.py --status
python3 scripts/ambitions-autonomous-train-fastpath.py --next
python3 scripts/ambitions-autonomous-train-fastpath.py --once --dry-run --no-push
python3 scripts/ambitions-next-batch-router.py --dry-run --prefer-hbi
python3 scripts/ambitions-owned-files-detector.py --batch <BATCH_ID> --print-git-add
python3 scripts/ambitions-red-repair-router.py --json < failure.log
```

## Claim boundary

This speed layer is orchestration support only. It is not product implementation proof, test proof, build proof, release proof, or device proof.
