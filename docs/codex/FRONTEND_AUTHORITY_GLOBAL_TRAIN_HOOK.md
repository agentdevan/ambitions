# Frontend Authority Global Train Hook

Status: Active global-train enforcement hook

Batch/source: `ENCYCLOPEDIA-TO-FRONTEND-OPERATING-SYSTEM-06`

## Purpose

The Visual Encyclopedia is now the operational frontend authority for UI, visual, design-system, and frontend implementation work.

Future global-train batches that touch frontend/UI/visual surfaces must not launch from broad repo browsing or generic prompt prose. They must consume the Encyclopedia Frontend OS through a surface packet, preflight, source binding, proof contract, and implementation receipt path.

## Enforcement Script

The live global-train supervisor calls:

```bash
python3 scripts/ambitions-global-train-frontend-authority-check.py --batch <BATCH_ID> --prompt <PROMPT_FILE>
```

The hook blocks a frontend/UI-relevant batch if:

- the Encyclopedia Frontend OS final gate is missing or not Green
- the frontend authority packet index is missing or incomplete
- root destination packets are missing
- the implementation dashboard does not confirm active IA Green
- the batch prompt lacks Ambitions runner headers
- the batch prompt does not declare a surface ID
- the declared surface ID is unknown
- the prompt does not explicitly consume the frontend authority packet/preflight workflow

## Frontend Batch Requirement

Every frontend/UI/visual implementation batch should start from:

```bash
make frontend-authority-packet SURFACE=<surface_id>
make frontend-authority-preflight SURFACE=<surface_id>
make frontend-implementation-prompt SURFACE=<surface_id> BATCH=<BATCH_ID>
```

Then run the generated prompt through the Ambitions runner:

```bash
scripts/ambitions-codex-train.sh <BATCH_ID> prompts/generated/frontend/<BATCH_ID>.md
```

## Scope

This hook applies to batches touching:

- SwiftUI frontend source
- top-level destinations
- visual encyclopedia surfaces
- visual primitives
- design-system implementation
- Today / Goals / Capture / Time / You UI
- generated frontend prompts
- frontend proof/receipt pathways

Non-frontend docs/platform/backend/runtime batches pass the hook without requiring a surface packet.

## Proof Boundary

Passing this hook does not prove implementation quality, screenshots, device behavior, public accessibility conformance, release readiness, or App Store readiness.

It only proves the batch is correctly routed through the frontend authority control plane before launch.

## Hard Rule

A UI-affecting batch may not close Green merely because this hook passed. It still needs the proof required by its generated packet and prompt.
