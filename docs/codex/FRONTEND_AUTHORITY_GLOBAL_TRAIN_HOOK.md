# Frontend Authority Global Train Hook

<!-- AMB-291-CANON-HYGIENE-HEADER: BEGIN -->

> Canon hygiene status: **codex-reference-needs-owner-triage**
> AMB-291 note: This Codex reference is retained but requires owner/status clarification before it drives implementation.
> Active authority: `docs/truth/*`, `docs/codex/GLOBAL_BATCH_SEQUENCE_AUTHORITY.json`, and `docs/codex/IOS26_FLAGSHIP_TRAIN_MANIFEST.yml`.
> Before using this file for implementation, run `make change-impact-check` and follow `docs/ops/change-protocol/implementation-prompt-template.md`.
> Resolution classes: authority-rewrite, merge-overlap, status-expedite, terminology-quarantine
> Dispositions: clarify-status-before-use, merge-or-sequence-file-ownership, merge-or-sequence-surface-ownership, quarantine-or-rewrite-terminology, rewrite-authority-reference

<!-- AMB-291-CANON-HYGIENE-HEADER: END -->

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
- the implementation surface does not confirm active IA Green
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
