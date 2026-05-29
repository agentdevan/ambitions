# LDI Batch Gate Matrix

<!-- AMB-291-CANON-HYGIENE-REPAIR: BEGIN -->

> AMB-291 repair status: **canon-hygiene-reconciled**
> This file was reviewed as part of the actual canon content/hygiene rewrite pass.
> It is not standalone active product truth. Use `docs/truth/*` and current manifest/sequence authority before implementation.
> Conflict types reconciled: same_surface_multiple_active_batches
> Prior recommended actions: Expedite
> Candidate references: AMB28-same_surface_multiple_active_batches-96568748

<!-- AMB-291-CANON-HYGIENE-REPAIR: END -->

<!-- AMB-291-CANON-HYGIENE-HEADER: BEGIN -->

> Canon hygiene status: **codex-reference**
> AMB-291 note: This Codex reference supports process or execution, but active truth remains in docs/truth and current manifests.
> Active authority: `docs/truth/*`, `docs/codex/GLOBAL_BATCH_SEQUENCE_AUTHORITY.json`, and `docs/codex/IOS26_FLAGSHIP_TRAIN_MANIFEST.yml`.
> Before using this file for implementation, run `make change-impact-check` and follow `docs/ops/change-protocol/implementation-prompt-template.md`.
> Resolution classes: authority-rewrite, merge-overlap
> Dispositions: merge-or-sequence-surface-ownership, rewrite-authority-reference

<!-- AMB-291-CANON-HYGIENE-HEADER: END -->

<!-- markdownlint-disable MD013 -->

Status: Active gate matrix for LDI batches. LDI01-LDI12 are Green after
explicit user-directed early insertion; no full runtime implementation is claimed.

| Gate | Applies when | Green | Yellow | Red |
| --- | --- | --- | --- | --- |
| LDI Source Truth Gate | Every LDI batch and LDI-aware SI/PD/AOS hook | LDI canon and active Ambitions canon are read and conflicts resolved. | Minor stale link documented. | Missing source truth or conflict affects safety. |
| Handling Lane Gate | Capture/routing/review work | Exactly one primary canonical lane and optional secondary flags are named. | Lane is planned but not implemented; owner named. | Unknown lane or plan activation without review. |
| Safety Legality Feasibility Gate | Any capture/dream routing | Unsafe, crisis, professional-boundary, fantasy, minor, and sensitive cases are handled honestly. | Fixture gap has owner and no unsafe path ships. | Harmful/illegal/professional advice operationalized. |
| Source Claim Pack Gate | Claims/packs/source freshness | Claims are atomic, source-backed, versioned, fresh/stale/conflict-aware. | Draft/source gap marked non-production. | Official verification or source truth claim without proof. |
| Pack Supply Chain Gate | Pack import/update | Checksum, provenance, signature, rollback, no executable logic. | Future manifest gap documented. | Untrusted executable pack logic. |
| Local-First Privacy Gate | User data/sync/archive | User state remains local/private iCloud where allowed; no user-data server. | Future CloudKit/archive work deferred. | Backend/user-data/account/telemetry introduced. |
| No Silent Mutation Gate | Recompiler/plan changes | Commitments require explicit approval. | Suggestions recalculated only with owner. | Commitment moves silently. |
| Professional Boundary Gate | Regulated domains | Scaffolds/source states/verification boundaries only. | Human/professional review required. | Legal/medical/financial/immigration advice claim. |
| Release Claim Safety Gate | Every LDI report | Non-claims are explicit. | Human proof pending but no readiness claim. | App Store/TestFlight/device/public accessibility/release claim without proof. |

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
