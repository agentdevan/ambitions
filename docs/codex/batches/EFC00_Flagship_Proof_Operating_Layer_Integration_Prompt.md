# EFC00 — Flagship Proof Operating Layer Integration Prompt

<!-- AMB-291-CANON-HYGIENE-HEADER: BEGIN -->

> Canon hygiene status: **execution-work-order-needs-language-check**
> AMB-291 note: This batch/prompt may contain legacy language residue and must follow current canonical terminology before use.
> Active authority: `docs/truth/*`, `docs/codex/GLOBAL_BATCH_SEQUENCE_AUTHORITY.json`, and `docs/codex/IOS26_FLAGSHIP_TRAIN_MANIFEST.yml`.
> Before using this file for implementation, run `make change-impact-check` and follow `docs/ops/change-protocol/implementation-prompt-template.md`.
> Resolution classes: terminology-quarantine
> Dispositions: quarantine-or-rewrite-terminology

<!-- AMB-291-CANON-HYGIENE-HEADER: END -->

<!-- markdownlint-disable MD013 -->

Status: Active source-truth prompt for EFC00.  
Date: 2026-05-08  
Batch code: EFC00  
Type: docs/governance/proof sequencing only.

## Mission

Install the EFC Flagship Proof Operating Layer into the Ambitions repo without interrupting the active global batch train.

EFC00 must wire EFC into the repo as a peak-proof overlay, not as a parallel feature train. It must preserve the current active batch and add proof obligations for AFI/FCP/PK/AOS/LDI/Source Atlas/PFC/FVQ/REC/CQS work.

## Required Active-Batch Check

Before any write, read:

- `.codex/state/active-batch.yml`
- `.codex/reports/current-batch-train-state.md`
- `.codex/reports/current-run-state.md`
- `docs/codex/BATCH_REGISTRY.md`
- `docs/codex/GLOBAL_FULL_STACK_COMPLETION_ORDER.md`

If Codex advances the active batch during EFC00, preserve the newer state and do not force stale active-batch values.

## Allowed Files

- `docs/codex/EFC_FLAGSHIP_PROOF_OPERATING_LAYER.md`
- `docs/codex/BATCH_REGISTRY_EFC_OVERLAY.md`
- `docs/codex/GLOBAL_FULL_STACK_COMPLETION_ORDER_EFC_PEAK_OVERLAY.md`
- `docs/codex/batch-trains/EFC00_EFC18_FLAGSHIP_PROOF_CLOSURE_OVERLAY.md`
- `docs/codex/batches/EFC00_Flagship_Proof_Operating_Layer_Integration_Prompt.md`
- `docs/audits/efc00-flagship-proof-operating-layer-integration-report.md`
- `.codex/state/active-batch.yml` only as a compact mirror update preserving the current active batch
- `docs/README.md`, `docs/codex/README.md`, and `AGENTS.md` only to index the overlay and read-order rules

## Forbidden Files / Actions

- Production Swift.
- Persistence schema.
- Route/raw-value changes.
- Project/signing/entitlement changes.
- Dependency changes.
- Hosted CI workflow changes.
- Release/platform claim changes.
- App Store/TestFlight/device/accessibility/legal/privacy claims.
- Any active-batch overwrite that ignores the latest `.codex/state/active-batch.yml`.
- Any new top-level tab or product surface.
- Hosted AI, user-data server, analytics, telemetry, productivity scoring, shame/proof thread mechanics, or silent mutation.

## Required Outputs

1. EFC operating layer source truth.
2. EFC registry overlay.
3. EFC peak global sequencing overlay.
4. EFC00-EFC18 overlay train manifest.
5. EFC00 prompt.
6. EFC00 audit report.
7. Updated index/read-order files.
8. Active-batch mirror preserving the current active batch.

## Required Closeout Report

The closeout report must include:

- active batch before EFC00 writes
- active batch after EFC00 writes
- concurrency collisions encountered
- files changed
- behavior changed / not changed
- validation performed / not performed
- no-claim boundaries
- next eligible active batch
- EFC inheritance rule for the next batch
- rollback path

## Green Criteria

EFC00 is Green only if:

- EFC source truth exists.
- EFC is indexed from docs/Codex entry points.
- active batch is preserved, not overwritten.
- EFC peak overlay says existing trains remain implementation owners.
- EFC adds missing proof owner batches only where necessary.
- EFC claims no implementation, release, device, public accessibility, legal/privacy, hosted AI, sync, hosted CI, or App Store readiness.

## Yellow Criteria

Accepted Yellow is allowed if:

- active Codex state changes mid-run and EFC00 preserves the newer state;
- large registry/run-state files cannot be safely rewritten without risking collision, but an overlay file and compact mirror record the new proof ordering;
- local validation cannot run from the current environment, provided the report says docs-only proof and no app behavior changed.

## Red Criteria

Hard Red if:

- active batch is overwritten with stale state;
- EFC is treated as a product implementation train;
- release/device/accessibility/legal/privacy claims are added without evidence;
- production Swift or schema files are changed by EFC00.

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
