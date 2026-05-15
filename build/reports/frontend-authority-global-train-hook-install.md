# Frontend Authority Global Train Hook Install Report

Status: INSTALLED / ACTIVE IN GLOBAL TRAIN SUPERVISOR

Installed: 2026-05-14

## Summary

Installed the Encyclopedia Frontend OS hook into the live global train launch path.

The live global train supervisor now calls the frontend authority hook before launching a selected child batch. This makes frontend/UI/visual batches route through the Encyclopedia Frontend OS packet/preflight workflow instead of starting from broad repo browsing.

## Files Changed

- `scripts/ambitions-global-train-frontend-authority-check.py`
- `docs/codex/FRONTEND_AUTHORITY_GLOBAL_TRAIN_HOOK.md`
- `scripts/ambitions-global-train-supervisor.sh`
- `build/reports/frontend-authority-global-train-hook-install.md`

## Runtime Integration

The supervisor file now defines:

```bash
FRONTEND_AUTHORITY_CHECK="scripts/ambitions-global-train-frontend-authority-check.py"
```

Before calling the canonical runner, `run_once` calls:

```bash
run_frontend_authority_hook "$batch" "$prompt"
```

The hook executes:

```bash
python3 scripts/ambitions-global-train-frontend-authority-check.py --batch "$batch" --prompt "$prompt"
```

## What The Hook Enforces

For non-frontend batches, the hook passes without requiring a surface packet.

For frontend/UI/visual batches, the hook blocks launch unless:

- Encyclopedia Frontend OS final gate is Green
- frontend authority packet index exists and includes root destination packets
- frontend implementation dashboard has active IA Green
- prompt has Ambitions runner headers
- prompt declares a known surface ID
- prompt explicitly consumes the frontend authority packet/preflight workflow

## Why This Matters

Future global-train frontend work now has to enter through the operational encyclopedia layer:

1. surface ID
2. authority packet
3. preflight
4. generated implementation prompt
5. source binding
6. proof contract
7. receipt/drift/dashboard follow-up

## Proof Boundary

This install does not modify production SwiftUI UI, generate screenshots, claim implementation proof, claim accessibility conformance, claim device proof, or claim release/App Store readiness.

The hook proves only that the global train launch path enforces frontend authority routing.

## Manual Verification Commands

```bash
python3 scripts/ambitions-global-train-frontend-authority-check.py --batch TODAY-REALITY-MERIDIAN-FLAGSHIP-IMPLEMENTATION-01 --prompt prompts/generated/frontend/TODAY-REALITY-MERIDIAN-FLAGSHIP-IMPLEMENTATION-01.md
make global-train-next
```

Do not run `make global-train-once` unless you intend to launch the next global batch.
