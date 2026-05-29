# LDI Dependency Graph

<!-- AMB-291-CANON-HYGIENE-HEADER: BEGIN -->

> Canon hygiene status: **codex-reference**
> AMB-291 note: This Codex reference supports process or execution, but active truth remains in docs/truth and current manifests.
> Active authority: `docs/truth/*`, `docs/codex/GLOBAL_BATCH_SEQUENCE_AUTHORITY.json`, and `docs/codex/IOS26_FLAGSHIP_TRAIN_MANIFEST.yml`.
> Before using this file for implementation, run `make change-impact-check` and follow `docs/ops/change-protocol/implementation-prompt-template.md`.
> Resolution classes: authority-rewrite, rewrite-authority-before-proof
> Dispositions: rewrite-authority-before-proof, rewrite-authority-reference

<!-- AMB-291-CANON-HYGIENE-HEADER: END -->

<!-- markdownlint-disable MD013 -->

Status: Active dependency graph. LDI01-LDI12 are Green after explicit
user-directed early insertion; no full LDI runtime is claimed.

## Placement

LDI01 starts after AOS30 by default. On 2026-05-07, the active global train
received explicit user direction to continue without stopping unless
unrecoverable Red, and the optimized global order selected LDI01 after AOS23
Governance Kernel Registry as a docs/Codex OS source-truth gate before later
AOS UI integration. This does not authorize LDI runtime implementation.

LDI13-LDI22 remain serial LDI successors after LDI12 Green or accepted Yellow.

## Required Predecessors

- SI must expose reusable handling lane, source state, receipt, privacy, degraded-state, and review primitives where relevant.
- PD must provide owned drill-down homes for LDI review surfaces where relevant.
- AOS must create kernel contracts and local runtime boundaries before LDI deepens implementation.
- AOS24 UI integration must not expose LDI user-facing intelligence without relevant SI/PD/AOS/LDI gates.
- PD runtime-touching batches must stop if LDI/AOS source truth, proof trust, recommendation, privacy, or recompiler gates are not ready.

## Serial Dependencies

LDI01 -> LDI02 -> LDI03 -> LDI04 -> LDI05 -> LDI06 -> LDI07 -> LDI08 -> LDI09 -> LDI10 -> LDI11 -> LDI12 -> LDI13 -> LDI14 -> LDI15 -> LDI16 -> LDI17 -> LDI18 -> LDI19 -> LDI20 -> LDI21 -> LDI22.

## Cross-Train Hooks

SI handles visual primitives, PD handles drill-down homes, AOS handles foundational contracts, LDI handles dream intelligence implementation depth. No train may claim another train's work without evidence.

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
