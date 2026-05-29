# AmbitionsOS AOS Batch Gate Matrix

<!-- AMB-291-CANON-HYGIENE-HEADER: BEGIN -->

> Canon hygiene status: **codex-reference**
> AMB-291 note: This Codex reference supports process or execution, but active truth remains in docs/truth and current manifests.
> Active authority: `docs/truth/*`, `docs/codex/GLOBAL_BATCH_SEQUENCE_AUTHORITY.json`, and `docs/codex/IOS26_FLAGSHIP_TRAIN_MANIFEST.yml`.
> Before using this file for implementation, run `make change-impact-check` and follow `docs/ops/change-protocol/implementation-prompt-template.md`.
> Resolution classes: authority-rewrite, merge-overlap, merge-overlap-before-proof, terminology-quarantine
> Dispositions: merge-before-proof, merge-or-sequence-surface-ownership, quarantine-or-rewrite-terminology, rewrite-authority-reference

<!-- AMB-291-CANON-HYGIENE-HEADER: END -->

Status: Active train gate matrix; AOS01 Accepted Yellow and AOS02-AOS23 Green

| Batch | Kernel | Primitive | Surface | Preconditions | Skills | Review Board | Validation Pack | Fixture Pack | Source | Privacy | Performance | Compatibility | Maintainability | Release | Logs | Stop | Next |
| --- | --- | --- | --- | --- | --- | --- | --- | --- | --- | --- | --- | --- | --- | --- | --- | --- | --- |
| AOS01 | Governance / Runtime | mapped 3.0 primitive | all | blocks all AOS work | AOS skills | AOS boards | AOS packs | fixture group | review | review | review | review | review | no claim | evidence log | gate failure | next manifest row |
| AOS02 | Life Graph | mapped 3.0 primitive | Goals/Plan/You | depends on AOS01 | AOS skills | AOS boards | AOS packs | fixture group | review | review | review | review | review | no claim | evidence log | gate failure | next manifest row |
| AOS03 | Life Graph | mapped 3.0 primitive | all projections | depends on AOS02 | AOS skills | AOS boards | AOS packs | fixture group | review | review | review | review | review | no claim | evidence log | gate failure | next manifest row |
| AOS04 | Control Plane | mapped 3.0 primitive | all | depends on AOS01-AOS03 | AOS skills | AOS boards | AOS packs | fixture group | review | review | review | review | review | no claim | evidence log | gate failure | next manifest row |
| AOS05 | Starting Position | mapped 3.0 primitive | Goals/You | depends on AOS02-AOS04 | AOS skills | AOS boards | AOS packs | fixture group | review | review | review | review | review | no claim | evidence log | gate failure | next manifest row |
| AOS06 | Goal Path | mapped 3.0 primitive | Goals | depends on AOS05 | AOS skills | AOS boards | AOS packs | fixture group | review | review | review | review | review | no claim | evidence log | gate failure | next manifest row |
| AOS07 | Goal Path | mapped 3.0 primitive | Goals | depends on AOS06 | AOS skills | AOS boards | AOS packs | fixture group | review | review | review | review | review | no claim | evidence log | gate failure | next manifest row |
| AOS08 | Alternate Path | mapped 3.0 primitive | Goal Detail | depends on AOS05-AOS07 | AOS skills | AOS boards | AOS packs | fixture group | review | review | review | review | review | no claim | evidence log | gate failure | next manifest row |
| AOS09 | Alternate Path | mapped 3.0 primitive | Goal Detail/Plan | depends on AOS08 | AOS skills | AOS boards | AOS packs | fixture group | review | review | review | review | review | no claim | evidence log | gate failure | next manifest row |
| AOS10 | Commitment Time | mapped 3.0 primitive | Plan/Today | depends on AOS02-AOS04 | AOS skills | AOS boards | AOS packs | fixture group | review | review | review | review | review | no claim | evidence log | gate failure | next manifest row |
| AOS11 | Reality Drift | mapped 3.0 primitive | Today/Plan | depends on AOS10 and AOS12 | AOS skills | AOS boards | AOS packs | fixture group | review | review | review | review | review | no claim | evidence log | gate failure | next manifest row |
| AOS12 | Proof Trust | mapped 3.0 primitive | Today/Goal Detail/You | depends on AOS02-AOS04 | AOS skills | AOS boards | AOS packs | fixture group | review | review | review | review | review | no claim | evidence log | gate failure | next manifest row |
| AOS13 | Source Truth | mapped 3.0 primitive | You/Goal Detail | depends on AOS02-AOS04 | AOS skills | AOS boards | AOS packs | fixture group | review | review | review | review | review | no claim | evidence log | gate failure | next manifest row |
| AOS14 | Recommendation | mapped 3.0 primitive | Today | depends on AOS04, AOS12, and AOS13 | AOS skills | AOS boards | AOS packs | fixture group | review | review | review | review | review | no claim | evidence log | gate failure | next manifest row |
| AOS15 | Local Language | mapped 3.0 primitive | Capture/You | depends on AOS04, AOS13, AOS14, and deterministic fallback | AOS skills | AOS boards | AOS packs | fixture group | review | review | review | review | review | no claim | evidence log | gate failure | next manifest row |
| AOS16 | Performance Energy | mapped 3.0 primitive | all | must be active before runtime-heavy implementation | AOS skills | AOS boards | AOS packs | fixture group | review | review | review | review | review | no claim | evidence log | gate failure | next manifest row |
| AOS17 | Privacy Safety | mapped 3.0 primitive | all/external | must be active before external/sensitive projection work | AOS skills | AOS boards | AOS packs | fixture group | review | review | review | review | review | no claim | evidence log | gate failure | next manifest row |
| AOS18 | Evaluation | mapped 3.0 primitive | all | depends on AOS01-AOS17 contracts | AOS skills | AOS boards | AOS packs | fixture group | review | review | review | review | review | no claim | evidence log | gate failure | next manifest row |
| AOS19 | Experience | mapped 3.0 primitive | all | depends on AOS18 | AOS skills | AOS boards | AOS packs | fixture group | review | review | review | review | review | no claim | evidence log | gate failure | next manifest row |
| AOS20 | Adaptation | mapped 3.0 primitive | You/Today/Plan | depends on AOS14 and AOS18 | AOS skills | AOS boards | AOS packs | fixture group | review | review | review | review | review | no claim | evidence log | gate failure | next manifest row |
| AOS21 | Interoperability | mapped 3.0 primitive | external | depends on AOS16, AOS17, and interoperability privacy gates | AOS skills | AOS boards | AOS packs | fixture group | review | review | review | review | review | no claim | evidence log | gate failure | next manifest row |
| AOS22 | Longevity | mapped 3.0 primitive | You/Goals | depends on AOS02, AOS12, and AOS13 | AOS skills | AOS boards | AOS packs | fixture group | review | review | review | review | review | no claim | evidence log | gate failure | next manifest row |
| AOS23 | Governance | mapped 3.0 primitive | Codex OS | depends on all kernel contracts | AOS skills | AOS boards | AOS registry and train-integrity packs | fixture group | review | review | review | review | review | no claim | `AMBITIONSOS_AOS_GOVERNANCE_KERNEL_REGISTRY.md`; AOS23 report | gate failure | LDI01 by optimized global order unless dependency review selects another eligible batch |
| AOS24 | Experience | mapped 3.0 primitive | Today/Goals/Capture/Plan/You | depends on AOS18-AOS23 | AOS skills | AOS boards | AOS packs | fixture group | review | review | review | review | review | no claim | evidence log | gate failure | next manifest row |
| AOS25 | Evaluation | mapped 3.0 primitive | tests | depends on AOS18 and AOS24 | AOS skills | AOS boards | AOS packs | fixture group | review | review | review | review | review | no claim | evidence log | gate failure | next manifest row |
| AOS26 | Evaluation | mapped 3.0 primitive | all | depends on AOS16, AOS17, AOS18, and AOS25 | AOS skills | AOS boards | AOS packs | fixture group | review | review | review | review | review | no claim | evidence log | gate failure | next manifest row |
| AOS27 | Governance | mapped 3.0 primitive | release docs | depends on AOS26 | AOS skills | AOS boards | AOS packs | fixture group | review | review | review | review | review | no claim | evidence log | gate failure | next manifest row |
| AOS28 | Governance | mapped 3.0 primitive | handoff | depends on AOS27 | AOS skills | AOS boards | AOS packs | fixture group | review | review | review | review | review | no claim | evidence log | gate failure | next manifest row |
| AOS29 | Governance | mapped 3.0 primitive | repair | runs only after needs review/Yellow AOS gates are classified | AOS skills | AOS boards | AOS packs | fixture group | review | review | review | review | review | no claim | evidence log | gate failure | next manifest row |
| AOS30 | Governance | mapped 3.0 primitive | roadmap | runs only after AOS28 or explicit user decision | AOS skills | AOS boards | AOS packs | fixture group | review | review | review | review | review | no claim | evidence log | gate failure | next manifest row |

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
